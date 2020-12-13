# Intro

This page is the reference code page for the simulation study used to portray the problem of classic Volcano plots. It also icludes the codes for the suggested alternative approach which is implemented in the *Active Volcano plot* shiny app.

# Type I error Inflation with classic Volcano Plots

Here we introduce very briefly the issue with classic Volcano Plots and give an example of that issue in a simulation study. The issue and reasoning is extensively discussed in a paper which is currently under review. Volcano plots are extensively used to filter more relevant features (i.e, genes) in studies where there are many discoveries (aka hits). VPs are an example of double filtering where features are selected based on first the statistical significance filter (adjusted P-value < 0.05) and then the clinical significance  (e.g. |logFC| > 5). This approach dismisses the fact that BH and other FDR-controling methods only contol the type I error over the complete list of features and not the subsets. This is famously known as the subsetting feature which does not hold for FDR-controling methods. Therefore, post-hoc selected features are not anymore controled for type I error. Furthermore, the second filter depends on logFC which in turn depends on the estimated variance of the features. Simply out, logFC filter, not only selects feature with large effect size, but also thoes with a large variance. This can result in selection of features that are actualy not relevant or technically a false discoery. 

## Example Simulations

The codes to reproduce the simulation results under different parameters in provided above ('simProb.R'). Here we will use the example data produced under following parameters:
Number of features = 20000 , denoted by m
sample size = 12, denoted by n
proportion of truly active features = 0.2 , denoted by pi1
effect size = 1 , denoted by gamma

For simplicity we do no include the effect of variance here, which is controled by lambda (here lambda=0) in the simulation codes. Simulations are repeated 1000 times and the corresponding data is saved as ''.

# Active Volcano Plot

R application that uses *shiny* to build a user interface to get an Active volcano plot for the specified dataset. The name *Active* refers to the fact that modification of thresholds does not inflate type I error. *Post-hoc* selection of features is allowed due to use of closed testing.

See https://mebpr.shinyapps.io/activevp/ to use the online version (Updated on 1-4-2020).
