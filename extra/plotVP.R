library(ggplot2)
load("Data/exData.RData")


exData$selected<-0
exData$selected[which(abs(exData$betahat)>1 & exData$pval.fdr<0.1)]<-1


#volcano plot
ggplot() +
     geom_point(data=exData,aes(x = betahat, y = -log10(pval),
                                 color = factor(selected), shape=as.factor(8*isnull)))+
     geom_hline(yintercept=-log10(max(exData$pval[exData$selected==1])),
                 linetype="solid", color = "gray95", size=1)+
     geom_vline(xintercept=1, linetype="solid", color = "gray95", size=1)+
     geom_vline(xintercept=-1, linetype="solid", color = "gray95", size=1)+
     scale_colour_manual(name = "",
                        labels = c("Selected" ,"Not Selected"),
                        values = c("red", "blue"),
                        limits = c("1", "0")) +
     scale_shape_manual(name = "",labels = c("Null" ,"non-Null"),
                         values = c(16, 17)) +
     xlab("Fold Change") +
     ylab("-Log10 p-value")+
     theme_minimal()+
     theme(legend.position = "bottom")