
tabUpload = fluidPage(
  
  # Input: Select a file ----
  fluidRow(   
          box( width = 4, shinyFilesButton("serverDbfile" ,label="Fasta file to create blast database", title="", multiple=FALSE)),
          box( width = 8, textOutput("dbfilepaths"))
          ),
  h5("Or"),
  fileInput("fileInputDB", "Upload a fasta File :", multiple = FALSE),

  radioButtons("typeDB", "Sequences type :",
               choices = c(
                           "nucl" = "nucl",
                           "prot" = "prot"),
               selected = "nucl"),
  
  textInput("nameDB", "Database name:"),
  
  actionButton("createDB", "Create a new blast database :", class="btn btn-primary"),
  
  verbatimTextOutput("createDBres")
  
)

