library(shinydashboard)
MenuGauche = sidebarMenu(id = "sidebarmenu",
                         
                         menuItem("Run Blast", tabName = "Home",  icon = icon("home", lib="font-awesome"), newtab = FALSE),
                         
                         menuItem("New Database", tabName = "Upload",  icon = icon("upload", lib="font-awesome"), newtab = FALSE),
                         
                         br(), br(),
                         
                         menuItem("Powered by mbb",  href = "http://mbb.univ-montp2.fr/MBB/index.php", newtab = TRUE, icon = icon("book", lib="font-awesome"), selected = NULL),
                         
                         menuItem("Team", icon = icon("book", lib="font-awesome"),
                                  menuItem("Jimmy Lopez",  href = "http://www.isem.univ-montp2.fr/recherche/les-plate-formes/bioinformatique-labex/personnel/lopez-jimmy", newtab = TRUE,   icon = shiny::icon("male"), selected = NULL  ),
                                  
                                  menuItem("Khalid Belkhir",  href = "http://www.isem.univ-montp2.fr/recherche/les-plate-formes/bioinformatique-labex/personnel/belkhir-khalid/", newtab = TRUE,   icon = shiny::icon("male"), selected = NULL  )
                                  

                         )
                         
)
