#
# This is merely an adaptation of https://github.com/ScientistJake/Shiny_BLAST
# Adde a way to upload sequences to create a new blast database
# Added alignment visualisation with msaR
# A Dockerfile can be used to deploy the app inside a container

library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyFiles)

library(DT)
library(XML)
library(dplyr)
library(plyr)
library(stringr)
library(msaR)

#upload size 100 Mo
options(shiny.maxRequestSize = 100*1024^2)

source("./pages/pages_def_home.R", local = T)
source("./pages/pages_def_upload.R", local = T)
source("./R/menugauche.R", local = T)

path_to_database <<- "/Results/db/"

style <- tags$style(HTML(readLines("www/style.css")) )
UI <- dashboardPage(
   
  skin = "green",
  dashboardHeader(title="Shiny-Blast", titleWidth = 230),
  dashboardSidebar(width = 230, MenuGauche ),
  
  dashboardBody(
    shinyjs::useShinyjs(),
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.min.readable.css")) ,
    tags$head(tags$script(src = "message-handler.js")),
    tags$head(style),
    tabItems(
      tabItem(tabName = "Home",         tabHome),
      tabItem(tabName = "Upload",         tabUpload)
    )
  )
)

server <- function( input, output, session) {
  
  namedb <- c()
  queryFile <- ""
  # disable the downdload button on page load
  shinyjs::disable("downloadblastRes")

  shinyFileChoose(input, "serverDbfile", root=c(Data="/Data",Results="/Results"),filetypes=c('fasta', 'fas'), session = session)

  shinyFileChoose(input, "serverqueryfile", root=c(Data="/Data",Results="/Results"),filetypes=c('fasta', 'fas'), session = session)

  for(d in list.dirs(path_to_database)) {
    if(basename(d) != "db") {
      namedb <- c(namedb, basename(d))
    }
  }
  
  DB_COLLECTION <<- c(namedb, "nr")
  
  updateSelectInput(session, "db",  choices = DB_COLLECTION)
  
  source("./server/opt_home.R", local=TRUE)
  source("./server/opt_upload.R", local=TRUE)
}

shinyApp(ui = UI, server = server)
