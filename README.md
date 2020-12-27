# Intro

This page is the reference code page for the simulations used to portray the inherent problem of classic volcano plots. Read below for an overview of this issue. Here you can also find codes for the suggested alternative approach which is implemented in the *Active Volcano Plot* shiny app.

# Active Volcano Plot

R application that uses *shiny* to build a user interface to get an Active volcano plot for the specified dataset. The name *Active* refers to the fact that modification of thresholds does not inflate type I error. *Post-hoc* selection of features is allowed due to use of closed testing.

See https://mebpr.shinyapps.io/activevp/ to use the online version (Updated on 20-12-2020).


# Type I error inflation with classic volcano Plots

Here we introduce very briefly the issue with classic volcano plots (VP) and give some examples. The type I error inflation mechanism of classic VPs is extensively discussed in a paper which is currently under review. VPs are extensively used to filter more relevant features (e.g. genes) in studies where many discoveries are made (aka many DE features are present). VPs are an example of double filtering where first the statistical significance filter (adjusted P-value < 0.05) and then the clinical significance (e.g. |logFC| > 5) is applied to select *top* features. This approach dismisses the fact that BH and other FDR-controlling methods only control the type I error over the complete list of features and not the subsets. This is famously known as the sub-setting feature which does not hold for FDR-controlling methods. Therefore, post-hoc selected features are not anymore controlled for type I error. Furthermore, the second filter depends on logFC which in turn depends on the estimated variance of the features. Simply put, logFC filter not only selects feature with large effect size, but also those with a large variance. This may result in selection of features that are actually not relevant or technically a false discovery. 

## Examples

### Simulation experiment
The codes to reproduce the simulation results under different parameters in provided above ('extra/simVPProb.R'). The data are generated based on a simple regression model with the group indicator as the independent variable. The goal is to detect the differentially expressed features between two groups (diseased vs control). Here we will use the example data produced under following parameters:\

Number of features = 20000 , denoted by m\
sample size = 12, denoted by n\
proportion of truly active features = 0.2 , denoted by pi1\
effect size = 1 , denoted by gamma

For simplicity we do not include the effect of variance here, which is controlled by lambda in the codes (here λ=0). Simulations are repeated 1000 times and the corresponding data are plotted below. False discovery proportion (FDP) for selecting top 1 to 100 features is:

<img src="https://github.com/mitra-ep/ActiveVolcanoPlot/blob/master/extra/BarPlot0.png" width="70%" height="70%" />


This means that under these parameters about 14 percent of the time *top* discovery is actually a false discovery.\
The inflation gets worse, if the null features have larger variances (this can be checked by setting λ>0 in simulation codes). Although, the problem resolves if λ<0. This is a feature of dataset and is not easy to check for this assumption holds. So the application of classic volcano plot assumes that λ<0, which may not be true. Furthermore, using the _limma_ package (voom) will also worsen the issue as the shrinkage method will implicitly imposes such a relationship. All these properties are explained with details in the paper.

### RNA-seq data

You can go through the 'resample_SRP059039.rmd' file for an example of RNA-seq study with the same issue. We have used subject permutation for some of the features, making them Null features. Nevertheless, analyzing this data set, shows that some of the Null genes are selected by classic VP:

<img src="https://github.com/mitra-ep/ActiveVolcanoPlot/blob/master/extra/VP_exData.png" width="80%" height="80%"/>

For this example, 33436 genes were analyzed where the TDP was 0.11. By setting the p-threshold at 0.05 for FDR adjusted p-values and |logFC| threshold at 2, 145 genes are selected. Although the theoretical FDR level is 0.05*(1-0.11)=0.04, the FDP is 37/145=0.26. You can browse the data using Active VP shiny app and correctly estimate the FDP for any set of thresholds.

