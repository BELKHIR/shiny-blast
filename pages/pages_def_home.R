
tabHome = fluidPage(


          #This block gives us all the inputs:
          mainPanel(
            fluidRow(   
            box( width = 4, shinyFilesButton("serverqueryfile" ,label="Fasta file with query sequences", title="", multiple=FALSE)),
            box( width = 8, textOutput("queryfilepaths"))
            ),
            h5("Or"),
  
            textAreaInput('query', 'Input sequence:', value = "", placeholder = "", width = "600px", height="200px"),
            fluidRow(   
            box( width = 2, selectInput("db", "Select Database  (You can create New one via New Database menu) :", choices=c("LvTx","nr"), width="600px")),
            box( width = 2, selectInput("program", "Program:", choices=c("blastn","tblastn"), width="100px")),
            box( width = 2, selectInput("eval", "e-value:", choices=c(1,0.001,1e-4,1e-5,1e-10), width="120px")),
             
            box( width = 2, numericInput("max_hsps", "Max alignments per query", value = 1, min = 1, max =10,step = 1) ),
            box( width = 2, numericInput("max_target_seqs", "# aligned seq to keep", value = 10, min = 1, max =100,step = 1) ),

            box( width = 2, actionButton("blast", "Run BLAST!", class="btn btn-primary"))
            )
          ),
          
          #this snippet generates a progress indicator for long BLASTs
          div(class = "busy",  
              p("Calculation in progress.."), 
              img(src="https://i.stack.imgur.com/8puiO.gif", height = 100, width = 100,align = "center")
          ),
          
          #Basic results output
          mainPanel(
            downloadButton("downloadblastRes", "Download Results"),
            br(),
            DT::dataTableOutput("blastResults"),
            p("Selected hit alignment:", tableOutput("clicked") ),
            verbatimTextOutput("alignment"),
            msaROutput("msa", width="100%")
          )
)