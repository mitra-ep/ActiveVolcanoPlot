library(ggplot2)
load("Data/exData.RData")


exData$selected<-0
exData$selected[which(abs(exData$logFC)>2 & exData$adj.P.Val<0.05)]<-1


#volcano plot
ggplot() +
     geom_point(data=exData,aes(x = logFC, y = -log10(P.Value),
                                 color = factor(selected),
                                shape=truth),size=3)+
     geom_hline(yintercept=-log10(max(exData$P.Value[exData$selected==1])),
                 linetype="solid", color = "black", size=1)+
     geom_vline(xintercept=2, linetype="solid", color = "black", size=1)+
     geom_vline(xintercept=-2, linetype="solid", color = "black", size=1)+
     scale_colour_manual(name = "",
                        labels = c("Selected" ,"Not Selected"),
                        values = c("red", "blue"),
                        limits = c("1", "0")) +
     scale_shape_manual(name = "",labels = c("False Discovery" ,"True Discovery"),
                         values = c(17, 16)) +
     xlab("Fold Change") +
     ylab("-Log10 p-value")+
     theme_minimal(base_size=22,base_family = "serif")+
     theme(legend.position = "bottom")
