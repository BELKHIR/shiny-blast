
 output$queryfilepaths <- renderText({
    if (is.integer(input$serverqueryfile)) {
      paste0("No query files have been selected")
    } else {
      fics = parseFilePaths(c(Data="/Data",Results="/Results"), input$serverqueryfile)
      queryFile = fics$datapath[1]
      paste0(queryFile)
    }
  })

blastresults <- eventReactive(input$blast, {
  
  #gather input and set up temp file
  if (is.integer(input$serverqueryfile))
  {
    query <- input$query
    tmp <- tempfile(fileext = ".fa")

    #this makes sure the fasta is formatted properly
    if (startsWith(query, ">")){
      writeLines(query, tmp)
    } else {
      writeLines(paste0(">Query\n",query), tmp)
    }
    queryFile = tmp
  } else {
   tmp = parseFilePaths(c(Data="/Data",Results="/Results"), input$serverqueryfile)$datapath[1]
  } 

    # chooses the right database
    if (input$db == "nr"){
      db <- "nr"
      remote <- c("-remote")
    } else {
      db <- paste0(path_to_database, input$db, "/", input$db, ".fasta")
      remote <- c("")
    }
       
    print(db)
    
  print(paste0(input$program," -query ",tmp," -db ",db," -evalue ",input$eval," -outfmt 5 -max_hsps ",input$max_hsps," -max_target_seqs ",input$max_target_seqs," ", remote))
  
  #calls the blast
  data <- system(paste0(input$program," -query ",tmp," -db ",db," -evalue ",input$eval," -outfmt 5 -max_hsps ",input$max_hsps," -max_target_seqs ",input$max_target_seqs," ", remote), intern = T)

  #TODO check if success

  #Allow download
  shinyjs::enable("downloadblastRes")

  xmlParse(data)


}, ignoreNULL= T)

#Now to parse the results...
parsedresults <- reactive({
  if (is.null(blastresults())){}
  else {
    xmltop = xmlRoot(blastresults())
    
    #the first chunk is for multi-fastas
    results <- xpathApply(blastresults(), '//Iteration',function(row){
      query_ID <- getNodeSet(row, 'Iteration_query-def') %>% sapply(., xmlValue)
      hit_IDs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_id') %>% sapply(., xmlValue)
      hit_Defs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_def') %>% sapply(., xmlValue)
      hit_length <- getNodeSet(row, 'Iteration_hits//Hit//Hit_len') %>% sapply(., xmlValue)
      bitscore <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_bit-score') %>% sapply(., xmlValue)
      eval <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_evalue') %>% sapply(., xmlValue)
      if ( length(hit_IDs) > 0 ) {  cbind(query_ID,hit_IDs,hit_Defs,hit_length,bitscore,eval) }
    })
    #this ensures that NAs get added for no hits
    results <-  rbind.fill(lapply(results,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
   

    results
  }
})

#makes the datatable
output$blastResults <- renderDataTable({
  if (is.null(blastresults())){
    
  } else {
    df = parsedresults()
    if (nrow(df) == 0) df = data.frame(Result="No hits found")
    df;
  }
}, selection="single")

#this chunk gets the alignemnt information from a clicked row
output$clicked <- renderTable({
  if(is.null(input$blastResults_rows_selected)){}
  else{
    xmltop = xmlRoot(blastresults())
    clicked = input$blastResults_rows_selected
    tableout<- data.frame(parsedresults()[clicked,])
    
    names(tableout) <- c("")

    rownames(tableout)  <- NULL
    colnames(tableout) <-  c("Query ID","Hit ID", "Hit name","Length", "Bit Score", "e-value")
    data.frame(tableout)
  }
},rownames =F,colnames =T)


output$msa <- renderMsaR({
  if(is.null(input$blastResults_rows_selected)){}
  else{
    xmltop = xmlRoot(blastresults())
    
    clicked = input$blastResults_rows_selected
    
    #loop over the xml to get the alignments
    align <- xpathApply(blastresults(), '//Iteration',function(row){
      top <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_qseq') %>% sapply(., xmlValue)
      hit_IDs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_id') %>% sapply(., xmlValue)
      query_ID <- getNodeSet(row, 'Iteration_query-def') %>% sapply(., xmlValue)
      hit_Defs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_def') %>% sapply(., xmlValue)

      mid <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_midline') %>% sapply(., xmlValue)
      bottom <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_hseq') %>% sapply(., xmlValue)
    
      rbind(top,bottom,hit_IDs,hit_Defs,query_ID)
    })
    
   
    alignx <- do.call("cbind", align)
    
    tmp <- tempfile(fileext = ".fa")
    cat(tmp)  

    #this makes sure the fasta is formatted properly
    strAlig = paste0(">",alignx[5,clicked],"\n",alignx[1, clicked],'\n>',alignx[4,clicked],'\n',alignx[2, clicked])
    writeLines(strAlig, tmp)
    
    msaR(tmp,   seqlogo = F)
    
  }
})
  
output$downloadblastRes <- downloadHandler(
    filename = function() {
        paste0("blastRes", queryFile ,"-onDb-",isolate(input$db) )
    },
    content = function(file) {
      if(is.null(parsedresults() ) ) return(NULL)   
      write.table(parsedresults(), file , append = FALSE, quote = F, sep = "\t",row.names = FALSE, col.names=TRUE)

    }
  )