library(shiny)
suppressPackageStartupMessages(library(hommel))
suppressPackageStartupMessages(library(ggplot2))

# Define server logic required to draw a histogram
server <- function(input, output) {
  ##inpud data
  input.data <- reactive({
    req(input$cvsfile)
    inFile <- input$cvsfile
    dataframe <- read.csv(
      inFile$datapath,
      header=input$header,
      sep=input$sep,
      quote=input$quote)
  })

  
  ##select symmetry type
  output$thrtype<-renderUI({
    conditionalPanel(
      "input.selecttype=='Threshold'",
      selectInput("thrtype", "FC threshold",
                  choices = c("Symmetric", "non-Symmetric"))    )
  })
  
  
  #input top number
  output$numtop<- renderUI({ 
    indata<-input.data()
    pthr<-10^(-1*input$pthresh)
    mockd<-indata[indata[,3]<pthr ,]
    
    conditionalPanel(
      "input.selecttype=='Number of Top'",
      numericInput("numtop", "Number of Top", 20, min = 1, max = nrow(mockd), step = NA,
                   width = NULL)  )
  })
  
  #non-symetryc slider values for beta
  output$sliderfc1<- renderUI({
    indata<-input.data()
    maxkaw <- round(max(as.numeric(indata[,2])),2)
    minkaw <- round(min(as.numeric(indata[,2])),2)
    conditionalPanel(
      "input.selecttype!== 'Number of Top' && input.thrtype == 'non-Symmetric'",
    #condition = "input.thrtype=='non-Symmetric'",
    sliderInput("sliderfc1","Fold Change Threshold:", min = minkaw, 
                  max   = maxkaw,
                  value = c(-2,2), step=0.1)  )
                 })
  
  #symetryc slider values for beta
  output$sliderfc2<- renderUI({
    indata<-input.data()
    kaw <- round(max(abs(as.numeric(indata[,2]))),2)
    conditionalPanel(
      "input.selecttype!== 'Number of Top' && input.thrtype == 'Symmetric'",
      #condition = "input.thrtype=='Symmetric'",
      sliderInput("sliderfc2","Fold Change Threshold:", min= 0, 
                  max = kaw,
                  value = 2, step=0.1)  )
    
      })
 
  
  #slider values for p threshold
  output$sliderpval<- renderUI({
    indata<-input.data()
    maxkaw <- round(-log10(as.numeric(min(indata[,3]))),2)
    minkaw <- round(-log10(as.numeric(max(indata[,3]))),2)
    sliderInput("pthresh","p-value Threshold (-Log10):", min = minkaw, 
                max = maxkaw,
                value = 2, step=0.1)
  })
  
  ##Data overview
  output$contents <- renderTable({
    req(input$cvsfile)
    indata<-input.data()
    if(is.null(input$cvsfile)) return(NULL);
    head(indata,30);
  })
  
  ##make the selection
  select.fun <- reactive({
      indata<-input.data()
      pthr<-10^(-1*input$pthresh)
      
      if(input$selecttype == "Number of Top"){
        req(input$numtop)
        mockd<-indata[indata[,3]<pthr ,]
        mockd<-mockd[order(-abs(mockd[,2])),]
        mockd<-mockd[1:input$numtop,]
        selected<-which(indata[,1] %in% mockd[,1])
        
        vl<-indata[selected,2]
        tright<- min(vl[vl > 0])
        tleft<- max(vl[vl < 0])
            }else{ 
        
      if(input$thrtype=="Symmetric"){
          tright<- input$sliderfc2
          tleft<- -1*input$sliderfc2
          selected<-which(abs(indata[,2])> tright & indata[,3]<pthr)
      }
      if(input$thrtype=="non-Symmetric"){
          tright<- input$sliderfc1[1]
          tleft<- input$sliderfc1[2]
          selected<-union(which(indata[,2]<tright & indata[,3]<pthr),
                        which(indata[,2]>tleft & indata[,3]<pthr))
        }
      }

      return(vals<-list(selected, c(tright=tright,tleft=tleft)))
    
  })
  
  ##ARI calculations and table
  output$table<-renderTable({
    indata<-input.data()
    vals<-select.fun()
    numslec<-length(vals[[1]])
    
    if(numslec!=0 ){
      hom<-hommel(indata[,3])
    
      numslec<-length(vals[[1]])
    
        FDPbar<-fdp(hom, ix=vals[[1]])
        TDPbar<-tdp(hom, ix=vals[[1]])
    
        FDPhat<-fdp(hom, ix=vals[[1]], alpha = 0.5)
        TDPhat<-tdp(hom, ix=vals[[1]], alpha = 0.5)
      }else{
        
        FDPbar<-0
        TDPbar<-0
        
        FDPhat<-0
        TDPhat<-0 
      } 
    
   outframe<-data.frame(Selected=c(paste(numslec), "-"),
                        True_Discovery=c(paste(round(numslec*TDPhat,2),
                                               "(",round(numslec*TDPbar,2),",",numslec,")" ), 
                                          paste(round(TDPhat,2),
                                                "(",round(TDPbar,2),",",1,")")),
                        False_Discovery=c(paste(round(numslec*FDPhat,2),
                                                "(",0,",",round(numslec*FDPbar,2),")" ), 
                                          paste(round(FDPhat,2),
                                                "(",0,",",round(FDPbar,2),")")))
        rownames(outframe)<-c("Number", "Proportion")
        colnames(outframe)<-c("Selected",paste("True Discovery","(",paste0(95,"%"),"CI",")" ),
                              paste("False Discovery","(",paste0(95,"%"),"CI",")" ) )
        outframe}, rownames = TRUE, align = 'c')
  
  
  
  ##Active VP plot
  output$volcano <- renderPlot({
    indata<-input.data()
    vals<-select.fun()
      
      numslec<-length(vals[[1]])

            colcod<-rep(0,length(indata[,1]))
      colcod[vals[[1]]]<-1       
     
      #volcano plot
      avp<-ggplot(indata) +
        geom_point(aes(x = indata[,2], y = -log10(indata[,3]),color = factor(colcod)))+
        geom_hline(yintercept=input$pthresh, linetype="solid", color = "grey", size=1)+
        geom_vline(xintercept=vals[[2]]["tright"], linetype="solid", color = "grey", size=1)+
        geom_vline(xintercept=vals[[2]]["tleft"], linetype="solid", color = "grey", size=1)+
        scale_colour_manual(name = "Status",
                            labels = c("Selected" ,"Not Selected"),
                            values = c("red", "blue"),
                            limits = c("1", "0")) +   
        xlab(input$xlabel) +
        ylab(input$ylabel)+
        theme_bw()+
        theme(legend.position="right",
              text = element_text(size=14),
              strip.background = element_rect(colour = "white",fill = "gray97"))
      
      return(avp)
      
      }, height = 400, width = 600)
      
  
  # Downloadable csv of selected features
  output$downloadData <- downloadHandler(
         filename = function() {
        paste("selected", ".csv", sep = "")
         },
        
        content = function(file) {
          indata<-input.data()
          selected<-select.fun()
          numslec<-length(selected)
          if(numslec!=0){
            indata2<-indata[selected[1:numslec],]}
          write.csv(indata2, file, row.names = FALSE)
        }

  )
  
  }
  
