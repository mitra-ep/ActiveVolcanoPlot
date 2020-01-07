library(shiny)
suppressPackageStartupMessages(library(hommel))
suppressPackageStartupMessages(library(ggplot2))

# Define server logic required to draw a histogram
server <- function(input, output) {
  #inpud data
  
  # reading in file
  input.data <- reactive({
    req(input$file1)
    inFile <- input$file1
           dataframe <- read.csv(
           inFile$datapath,
            header=input$header,
            sep=input$sep,
             quote=input$quote)
                                  })

  
  #slider values
  output$sliderfc1<- renderUI({
    indata<-input.data()
    maxkaw <- round(max(as.numeric(indata[,2])),2)
    minkaw <- round(min(as.numeric(indata[,2])),2)
    conditionalPanel(
      "input.selection == 'non-Symetric'",
      sliderInput("vthresh1","Fold Change Threshold:", min = minkaw, 
                  max   = maxkaw,
                  value = c(-2,2), step=0.1)  )


                 })
  
  
  output$sliderfc2<- renderUI({
    indata<-input.data()
    kaw <- round(max(abs(as.numeric(indata[,2]))),2)
    conditionalPanel(
      "input.selection == 'Symetric' ",
      sliderInput("vthresh2","Fold Change Threshold:", min= 0, 
                  max = kaw,
                  value = 2, step=0.1)  )
    
  })
  
  
  #slider values
  output$sliderpval<- renderUI({
    indata<-input.data()
    maxkaw <- round(-log10(as.numeric(min(indata[,3]))),2)
    minkaw <- round(-log10(as.numeric(max(indata[,3]))),2)
    sliderInput("pthresh","p-value Threshold (-Log10):", min = minkaw, 
                max = maxkaw,
                value = 2, step=0.1)
  })
  
  #Data overview
  output$contents <- renderTable({
    indata<-input.data()
    if(is.null(input$file1)) return(NULL);
    head(indata,30);
  })
  
  
  #ARI calculations and table
  
  output$table<-renderTable({
     indata<-input.data()
     pthr<-10^(-1*input$pthresh)
     if(input$selection=="Symetric"){
      tright<- input$vthresh2
      tleft<- -1*input$vthresh2
      select<-which(abs(indata[,2])> tright & indata[,3]<pthr)
      }  else{
      tright<- input$vthresh1[1]
      tleft<- input$vthresh1[2]
      select<-union(which(indata[,2]<tright & indata[,3]<pthr),
                   which(indata[,2]>tleft & indata[,3]<pthr))
      }
    
      hom<-hommel(indata[,3])
    
      numslec<-length(select)
    
      if(numslec!=0){
        FDPbar<-fdp(hom, ix=select)
        TDPbar<-tdp(hom, ix=select)
    
        FDPhat<-fdp(hom, ix=select, alpha = 0.5)
        TDPhat<-tdp(hom, ix=select, alpha = 0.5)
      }else{
        FDPbar<-0
        TDPbar<-0
        
        FDPhat<-0
        TDPhat<-0 
      } 
    
      outframe<-data.frame(Selected=c(paste(numslec), round(numslec/length(indata[,2]),2)),
                        True_Discovery=c(paste(round(numslec*TDPhat,2),"(",round(numslec*TDPbar,2),",",numslec,")" ), 
                                          paste(round(TDPhat,2),"(",round(TDPbar,2),",",1,")")),
                        False_Discovery=c(paste(round(numslec*FDPhat,2),"(",0,",",round(numslec*FDPbar,2),")" ), 
                                          paste(round(FDPhat,2),"(",0,",",round(FDPbar,2),")")))
        rownames(outframe)<-c("Number", "Proportion")
        colnames(outframe)<-c("Selected",paste("True Discovery","(",paste0(95,"%"),"CI",")" ),
                              paste("False Discovery","(",paste0(95,"%"),"CI",")" ) )
        outframe}, rownames = TRUE, align = 'c')
  
  #VP plot
  output$volcano <- renderPlot({
      indata<-input.data()
      #filtering values
      colcod<-rep(0,length(indata[,1]))
      pthr<-10^(-1*input$pthresh)
      
      if(input$selection=="Symetric"){
        tright<- input$vthresh2
        tleft<- -1*(input$vthresh2)
        selected<-which(abs(indata[,2])> tright & indata[,3]< pthr)
        colcod[selected]<-1 }
      
      if(input$selection=="non-Symetric"){
        tright<-input$vthresh1[1]
        tleft<- input$vthresh1[2]
        selected<-union(which(indata[,2]<tright & indata[,3]< pthr),
                        which(indata[,2]>tleft & indata[,3]< pthr) )
        colcod[selected]<-1 }
      
      
      
      #volcano plot
      avp<-ggplot(indata) +
        geom_point(aes(x = indata[,2], y = -log10(indata[,3]),color = factor(colcod)))+
        geom_hline(yintercept=input$pthresh, linetype="solid", color = "grey", size=1)+
        geom_vline(xintercept=tright, linetype="solid", color = "grey", size=1)+
        geom_vline(xintercept=tleft, linetype="solid", color = "grey", size=1)+
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
      
  select_out=function(){
    indata<-input.data()
    
    #filter features
    pthr<-10^(-1*input$pthresh)
    
    if(input$selection=="Symetric"){
      tright<- input$vthresh2
      tleft<- -1*(input$vthresh2)
      selected<-which(abs(indata[,2])> tright & indata[,3]< pthr)}
    
    if(input$selection=="non-Symetric"){
      tright<-input$vthresh1[1]
      tleft<- input$vthresh1[2]
      selected<-union(which(indata[,2]<tright & indata[,3]< pthr),
                      which(indata[,2]>tleft & indata[,3]< pthr) ) }
    
    indata[selected,]}    
  # Downloadable csv of selected features
  output$downloadData <- downloadHandler(
         filename = function() {
        paste("selected", ".csv", sep = "")
         },
        
    content = function(file) {
      write.csv(select_out(), file, row.names = FALSE)
    }
  )
  
  }
  
