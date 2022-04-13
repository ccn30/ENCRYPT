# Stats gridCAT output and PIT
require(ggplot2)
require(dplyr)
require(tibble)
require(readr)
require(tidyr)
require(RColorBrewer)
require(ggthemes)
require(lme4)

####################################

## import gridCAT data

csvImportNR= read_csv('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/gridCAT/gridCAT_X_nr_results_global.csv')
csvImportNR[1:2] <- lapply(csvImportNR[1:2],factor)

# tidy girdCAT data
gridmagNR.untidy <- csvImportNR %>% select(Subject,Code,starts_with("GCmagnitude")) 
gridmagNR.gather <- gridmagNR.untidy %>% gather(Model,Grid_Magnitude,starts_with("GCmag"))
gridmagNR <- separate(gridmagNR.gather,Model,c(NA,"Run","ROI","Side","XFold"),"_")
rm(gridmagNR.gather,gridmagNR.untidy)
gridmagNR.pmEC <- gridmagNR %>% filter(ROI %in% "pmEC")

## import PIT data

resultsDir <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/PIT'
scriptDir <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts/PIT/slurmoutputs'
setwd(scriptDir)
csvFiles <- list.files(resultsDir,pattern="*.csv",full.names=1)

# make master table
filesList=lapply(csvFiles,read_csv)
PITall <- bind_rows(filesList[2:36])
PITall[1:6] <- lapply(PITall[1:6],factor)

# make distance error factor variable
MeanADerror <- mean(PITall$ADerror)
PITall <- PITall %>% mutate(Mean_AD_error=cut(ADerror,breaks = c(-Inf, MeanADerror, Inf), labels = c("Low distance error","High distance error")))
PITall <- PITall %>% mutate(PDist=cut(PDerror,breaks = c(-Inf,1,Inf), labels = c("Under","Over")))
PITall <- PITall %>% mutate(PAng=cut(PAerror,breaks = c(-Inf,1,Inf), labels = c("Under","Over")))

#####################################
# join gridCAT and PITdata (summary version)

# make PIT table into summaries 
sumPITall_CB <- PITall %>% 
  group_by(Code,Type) %>% 
  summarize(ADerrorMEAN = mean(ADerror),ADerrorSE = sd(ADerror)/sqrt(n()), n_samples = n())

# join gridCAT and PIT summary
PITxGridCAT <- left_join(gridmagNR.pmEC,sumPITall_CB,by="Code")
PITxGridCAT[1:6] <- lapply(PITxGridCAT[1:6],factor)
PITxGridCAT <- rename(PITxGridCAT,PIT_Trial_Type=Type)

# join gridCAT and PIT all data
PITallxGridCAT <- left_join(gridmagNR.pmEC,PITall,by="Code")
PITallxGridCAT[1:6] <- lapply(PITallxGridCAT[1:6],factor)
PITallxGridCAT <- rename(PITallxGridCAT,PIT_Trial_Type=Type)
#####################################
# plot association (MEANs)

# grid mag x mean AD error, all PIT trial types by run
PITxGridCAT_allRuns <- filter(PITxGridCAT,Run=="allRuns")
ggplot(PITxGridCAT,aes(Grid_Magnitude,ADerrorMEAN)) +
  geom_point() +
  facet_wrap(~Run)

# grid mag all runs right pmEC x mean ADerror by PIT trial type
ggplot(filter(PITxGridCAT_allRuns,Side=="right"),aes(Grid_Magnitude,ADerrorMEAN)) +
  geom_point() +
  facet_wrap(~PIT_Trial_Type)

# all runs average, right pmEC x mean AD error
PITxGridCAT_allRunsR_PITNoDistCues <- filter(PITxGridCAT,Run=="allRuns",Side=="right",PIT_Trial_Type=="3")
PITxGridCAT_allRunsL_PITNoDistCues <- filter(PITxGridCAT,Run=="allRuns",Side=="left",PIT_Trial_Type=="3")
ggplot(PITxGridCAT_allRunsL_PITNoDistCues,aes(Grid_Magnitude,ADerrorMEAN)) +
  geom_point()

#####################################
# plot association (ALL)

# right pmEC grid mag all runs x PDerror by PIT trial type
PITallxGridCAT_allRunsR <- filter(PITallxGridCAT,Side=="right",Run=="allRuns")

ggplot(PITallxGridCAT_allRunsR,aes(Grid_Magnitude,ADerror)) +
  geom_point() +
  facet_wrap(~PIT_Trial_Type,labeller = labeller(PIT_Trial_Type=c("1" = "No change",
                                                                  "2" = "No optic flow", 
                                                                  "3" = "No distal cues"))) + 
  labs(title="Association of grid magnitude (right pmEC, all runs) with distance error in PIT, by trial type") 

# right pmEC grid mag all runs x number of times OoB




