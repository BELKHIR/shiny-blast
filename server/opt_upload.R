cmdOut= "CreateDB result"

createDBresUpdate <- function(){
    output$createDBres <- renderText({ cmdOut })
  }

createDBresUpdate();

#DB_COLLECTION
  observeEvent(input$createDB, {


    if (input$nameDB == "") return(NULL)

    if(input$nameDB %in% DB_COLLECTION) {
      #TODO alert
    } else {

          if (is.null(input$fileInputDB))
          {
              fics = parseFilePaths(c(Data="/Data",Results="/Results"),input$serverDbfile)
              if (nrow(fics)>0) {
                tmp_path = fics$datapath[1]
              }
              else return(NULL)
          }
          else
          {
            if (input$fileInputDB$datapath == "") return(NULL)
            tmp_path = input$fileInputDB$datapath
          }

      print(tmp_path)
      
      new_path <- paste0(path_to_database, str_replace_all(input$nameDB,' ','_') , "/",str_replace_all(input$nameDB,' ','_'),".fasta")
      
      print(new_path)
      
      dir.create(paste0(path_to_database, str_replace_all(input$nameDB,' ','_')))
      file.copy(tmp_path, new_path)
      cmd <- paste0("makeblastdb -in ",new_path," -dbtype ", input$typeDB, ' 2>&1')
      cmdOut <<- system(cmd, intern=TRUE)
      #rv <- reactiveValues(a = x)
      #output$createDBres <- renderText({rv$a})
      createDBresUpdate();

      #if the command fail, the attribute status is created with a non null value != 0
      if (!is.integer(attr(cmdOut,"status")) ) {

      collection <- c(DB_COLLECTION, str_replace_all(input$nameDB,' ','_'))
      updateSelectInput(session, "db", label = "Database:", choices = collection)
      DB_COLLECTION <<- collection

      showModal(modalDialog(
        title = "Success",
        paste0("A new blast database is created: ", input$nameDB)
      ))
      }
    }
  })

  output$dbfilepaths <- renderText({
    if (is.integer(input$serverDbfile)) {
      paste0("No file have been selected")
    } else {
      fics = parseFilePaths(c(Data="/Data",Results="/Results"), input$serverDbfile)
      paste0(fics$datapath[1])
    }
  })