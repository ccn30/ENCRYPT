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

# make master table
filesList=lapply(csvFiles,read_csv)
PITall <- bind_rows(filesList)
PITall[1:6] <- lapply(PITall[1:6],factor)


#ggplot(PITall, aes(Code,ADerror)) + geom_jitter(width=.5,size=.5) + coord_polar() + geom_text(aes())


MeanADerror <- mean(PITall$ADerror)
 

ggplot(PITall,aes(Flag1_1, Flag1_2)) + 
  geom_point(size=4,colour='white') +
  geom_point(aes(Trig_1,Trig_2,color=ADerror>MeanADerror),alpha=0.9) +
  xlim(-3,3) + ylim(-3,3) +
  scale_fill_manual(palette="GnBu") +
  labs(title='Triggered positions for Cone 1',x='',y='') +
  theme(plot.backgroun = element_rect(fill = "#191970"),panel.background = element_rect(fill = "#191970"),panel.grid.minor = element_blank(),panel.grid.major=element_blank())

# plot example triangles??
