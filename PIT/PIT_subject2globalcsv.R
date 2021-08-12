## Script to compile individual subject csv PIT files into single master table csv

require(ggplot2)
require(dplyr)
require(tibble)
require(readr)
require(tidyr)
require(RColorBrewer)
require(ggthemes)
require(lme4)
require(ggsignif)

#* * * * * * * * * * * * * * * * KEY INFO * * * * * * * * * * * * * * *  *  
#* 12 Trials repeated in 3 blocks, with different return con/env type    *
#* <Trial><Info> = 3 levels: NoChange (1) NoOpticFlow (2) NoDistalCue (3)*
#* <EnvironmentNumber> = 3 levels: 0 / 1 / 2                             *
#* <ReachedOutOfBounds> = logical TRUE (1) / FALSE (0)                   *
#* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

## import PIT data subject csv files
resultsDir <- '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/PIT'
scriptDir <- '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/scripts/PIT'
setwd(scriptDir)
csvFiles <- list.files(resultsDir,pattern="*.csv",full.names=1)

# make master table
filesList=lapply(csvFiles,read_csv)
PITall <- bind_rows(filesList[1:length(filesList)])
PITall[1:6] <- lapply(PITall[1:6],factor)

# make distance error factor variable
MeanADerror <- mean(PITall$ADerror)
PITall <- PITall %>% mutate(Mean_AD_error=cut(ADerror,breaks = c(-Inf, MeanADerror, Inf), labels = c("Low distance error","High distance error")))
PITall <- PITall %>% mutate(PDist=cut(PDerror,breaks = c(-Inf,1,Inf), labels = c("Under","Over")))
PITall <- PITall %>% mutate(PAng=cut(PAerror,breaks = c(-Inf,1,Inf), labels = c("Under","Over")))

# save to results dir
write.csv(PITall,paste(resultsDir,'/Global_Results/PITall.csv',sep=""),row.names=FALSE)
rm(PITall)


