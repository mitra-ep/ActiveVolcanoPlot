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
                        h4("About"),
                        h5("This Shiny app is designed to create volcano plot with type I error control over any set of
                            selected features. It incorporates closed testing with Simes local test to build simultaneous
                            confidence bound for any subset of features, along with a median point estimate.This means that
                            changing the thresholds for fold change and p-value will not inflated the type I error rate over
                            the selected features.",br(),br(), "You can download the list of selected features using",
                           em("Download Selected Features"),"button. For reproducibility, the last 3 rows of the csv file includes
                           the thresholds used for selection. It is also easy to save the plot by right-clicking on
                           the image and selecting",em("Save image as..."), "option."),
                          tags$div(
                          "To learn more about the app and the inflation of type I error due to classic volcano plots,
                          visit this",
                          tags$a(href="https://github.com/mitra-ep/ActiveVolcanoPlot", 
                                 "github page.")
                        ),

                        h4("Input File"),
                        h5("The input file should be in text format with 3 columns in this order:
                           featureID, fold change (log2FC), raw p-value (not adjusted).") )
      
           )
        )
))
