#set the parameters

m<-20000 #number of features
rep<-1000 #number of repetitions 
n<-12  #number of samples 
pi1<-0.15 #proportion of truely active features
pi0<-1-pi1     #proportion of truely null features
truenum<-round(m*pi0) #number of truely null features
lamda<-0  #variance of truely null hypotheses are larger(=1)\smaller=(-1)
gamma<-1  #effect size
sigdf<-4   #degrees of freedom for sigma's distribution
s02<-4   #prior sigma
ntop<-100 #number of top features to select

fdp<-matrix(NA, ncol = ntop, nrow = rep)

set.seed(123)
for(k in 1:rep){
  sigmai<- sigdf * s02 * (1/rchisq(m, df=sigdf))
  sigmai<-sort(sigmai)
  rk<-1:m/(m+1)
  wi=rk^(lamda/2)*(1-rk)^(-lamda/2) #weights for choosing true hypothesis
  wi<-wi/sum(wi)
  nullset<-sample(1:m, truenum, replace = FALSE, prob = wi) #inexes for truely null probs
  altset<-!(1:m %in% nullset)
  ###dataset
  data<- data.frame(probeID = 1:m, b0=rep(0,m), b1=rep(0,m))
  
  data$b0<-data$b0<- 0 #b0 for all probs 
  data$b1[altset]<- sqrt(s02) * rnorm(sum(altset), 0, gamma)  #b1 for active probs
  data$b1[nullset]<-0 #b1 for none active(true null) probs
  
  data$sigma<-sigmai #save variances
  
  #true\false nullstatus
  data$isnull<-FALSE
  data$isnull[nullset]<-TRUE
  
  #generate y per probe and calculate t and p value
  X=cbind(rep(1,n),rep(0:1, n/2)) #design matrix
  mean<- as.matrix(data[,c(2,3)]) %*% t(X)
  err<- matrix(rnorm(m*n), m, n) *sqrt(sigmai)
  y<-mean+err
  
  #df for the ttest
  df<- n-2
  
  #estimated beta
  betahat <-apply(y,1,function(k)
  {solve(crossprod(X)) %*% crossprod(X, k)})
  data$betahat<-betahat[2,]
  
  yhat<-t(X %*% betahat)
  res <- y - yhat
  sighat <- rowSums(res^2)/df
  c <- solve(crossprod(X))[2,2]
  
  #ttest
  tval <- betahat[2,] / sqrt(c * sighat)
  data$pval <- 2*pt(-abs(tval), df=df)
  data<-data[complete.cases(data),]
  
  #adjusting pval 
  data$pval.fdr<-p.adjust(data$pval,method ="BH")
  
  #select significant by p-val
  sub_data<-subset(data,data$pval.fdr<=0.05)
  
  #order by beta
  sub_data <- sub_data[order(-abs(sub_data$betahat)),] 
  
  #get the number of discovery
  nd<-min(nrow(sub_data), ntop)
  
  #calculated fdr
  if(nd>0){
    qsum<-cumsum(sub_data$isnull[1:nd])/(1:nd)
    fdp[k,]<-c(qsum,rep(qsum[nd], ntop-nd))
  }  else err.vol[k,]<-rep(0,ntop)
  
  print(k)
}


