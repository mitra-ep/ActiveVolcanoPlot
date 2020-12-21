# Intro

This page is the reference code page for the simulations used to portray the inherent problem of classic volcano plots. It also includes codes for the suggested alternative approach which is implemented in the *Active Volcano Plot* shiny app.

# Type I error inflation with classic volcano Plots

Here we introduce very briefly the issue with classic volcano plots and give some examples. The issue and type I error inflation mechanism is extensively discussed in a paper which is currently under review. Volcano plots are extensively used to filter more relevant features (e.g. genes) in studies where many discoveries are made (aka many DE features). VPs are an example of double filtering where first the statistical significance filter (adjusted P-value < 0.05) and then the clinical significance (e.g. |logFC| > 5) is applied to select *top* features. This approach dismisses the fact that BH and other FDR-controling methods only contol the type I error over the complete list of features and not the subsets. This is famously known as the subsetting feature which does not hold for FDR-controling methods. Therefore, post-hoc selected features are not anymore controled for type I error. Furthermore, the second filter depends on logFC which in turn depends on the estimated variance of the features. Simply put, logFC filter not only selects feature with large effect size, but also thoes with a large variance. This may result in selection of features that are actualy not relevant or technically a false discoery. 

## Simulation study example

The codes to reproduce the simulation results under different parameters in provided above ('simVPProb.R'). The data are generated based on a simple regression model with a group variable. The goal is to detect the differentially expressed features between two groups (diseased vs control). Here we will use the example data produced under following parameters:\
Number of features = 20000 , denoted by m\
sample size = 12, denoted by n\
proportion of truly active features = 0.2 , denoted by pi1\
effect size = 1 , denoted by gamma\

For simplicity we do not include the effect of variance here, which is controled by lambda in the codes (here lambda=0). Simulations are repeated 1000 times and the corresponding data are plotted below. False discovery proportion (FDP) for selecting top 1 to 100 features is:

<img src="https://github.com/mitra-ep/ActiveVolcanoPlot/blob/master/Data/BarPlot0.png" width="100" height="100">

This means that under these parameters about 14 percent of the time *top* discovery is actually a false dicovery.

**Note:** You can checkout the 'resample_SRP059039.rmd' file for an example of RNA-seq study with the same issue.

# Active Volcano Plot

R application that uses *shiny* to build a user interface to get an Active volcano plot for the specified dataset. The name *Active* refers to the fact that modification of thresholds does not inflate type I error. *Post-hoc* selection of features is allowed due to use of closed testing.

See https://mebpr.shinyapps.io/activevp/ to use the online version (Updated on 20-12-2020).
