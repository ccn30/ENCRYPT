## PIT analysis
require(ggplot2)
require(dplyr)
require(tibble)
require(readr)
require(tidyr)
require(RColorBrewer)
require(ggthemes)
require(lme4)

resultsDir <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/PIT'
scriptDir <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts/PIT/slurmoutputs'
setwd(scriptDir)
csvFiles <- list.files(resultsDir,pattern="*.csv",full.names=1)

nFiles <- length(csvFiles)

# make master table 

for(i in 1:nFiles)
{
  output[i] <- paste("csv",i,sep="")
  assign(output[i], as_tibble(read.csv(csvFiles[i])))
}
for(i in 0:nFiles)
{
  test <- paste(as.name(output[i]))
  PITall <- bind_rows(as.name(output[i+1]))
}
PITall <- bind_rows(csv1,csv2,csv3,csv4)

