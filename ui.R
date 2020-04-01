# Define UI for application that draws a VP
##############
  
ui<-shinyUI(pageWithSidebar(
  headerPanel("Active Volcano Plot"),
  
  sidebarPanel(
    h3("Input"),
    div(style =" margin-top:-1em ", 
      fluidRow(  column(9,checkboxInput('header', 'Header', FALSE)),
      column(9,radioButtons('sep', 'Separator', c( Tab='\t', Comma=','), 'Tab', inline=TRUE)),
      column(12,radioButtons('quote', 'Quote',
                          c(None='', 'Double'='"', 'Single'="'"), 'Double', inline=TRUE))  )),
  
        div(style ="margin-bottom:-1em ",
        fileInput('cvsfile', 'Choose file',
                  accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')) ),
  
    tags$hr(tags$style(HTML("hr {border-top: 1px solid #000000;}"))),
    
    h4("Selection type"),  
    selectInput("selecttype", "Select features by",
                choices = c("Number of Top", "Threshold")),
    
    tags$hr(tags$style(HTML("hr {border-top: 1px solid #000000;}"))),
    
 div(style ="margin-top:-1em",
    uiOutput("sliderpval"),
    uiOutput("numtop"),
    uiOutput("thrtype"),
    uiOutput("sliderfc1"),
    uiOutput("sliderfc2"),
    
    textInput('xlabel', "Label for X-axis", 'Fold Change'),
    textInput('ylabel', "Label for Y-axis", '-Log10 p-value')  
                                                          , width = 4),
 downloadButton("downloadData", "Download Selected Features")),

  #output
  mainPanel(
      tabsetPanel(
      tabPanel("Volcano Plot",
                tableOutput('table'),
                tags$hr(),
              plotOutput(outputId = 'volcano', width = "800px", height = "600px")),
      tabPanel("Data Preview", tableOutput("contents")),
               tabPanel("Help",
                        h3("About"),
                        h4("This Shiny app is designed to create volcano plot with type I error control over
                           any set of selected features."),
                        h4("This means that changing the thresholds for Fold Change and p-value will not inflated the
                           type I error rate."),
                        h3("Input File"),
                        h4("The input file should be in text format with 3 columns in this order:
                           featureID, fold change, raw p-value."),
                        h4("The properties of the file include:"),
                        h4("-Header (Is the header included in the file?)"),
                        h4("-Seperator (How are columns seperated?)"),
                        h4("-Quotes (Which type of quotes is used for character?)"))
      
           )
        )
))
