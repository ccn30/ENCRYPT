## Script to compile individual subject csv vol files into single master table csv

require(tidyverse)

## import vol data subject csv files
resultsDir <- '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/volume'
scriptDir <- '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/scripts/Structural'
setwd(scriptDir)
csvFilesL <- list.files(resultsDir,pattern="*left.csv",full.names=1)
csvFilesR <- list.files(resultsDir,pattern="*right.csv",full.names=1)

# make master table
filesListL=lapply(csvFilesL,read_csv)
filesListR=lapply(csvFilesR,read_csv)
volsL <- bind_rows(filesListL[1:length(filesListL)])
volsR <- bind_rows(filesListR[1:length(filesListR)])

volsL <- volsL %>% 
  mutate(side = "left") %>% 
  filter(LabelID != "0") %>%
  mutate(Label = case_when(LabelID == 1 ~ "CA1",
                           LabelID == 2 ~ "CA2",
                           LabelID == 3 ~ "DG",
                           LabelID == 4 ~ "CA3",
                           LabelID == 5 ~ "Tail",
                           LabelID == 8 ~ "Sub",
                           LabelID == 9 ~ "EC",
                           LabelID == 10 ~ "PrC",
                           LabelID == 11 ~ "A36",
                           LabelID == 12 ~ "PhC",
                           LabelID == 17 ~ "pmEC",
                           LabelID == 18 ~ "alEC")) %>%
  select("subjectID","side","Label","Count","Vol(mm^3)")

volsR <- volsR %>% 
  mutate(side = "right") %>% 
  filter(LabelID != "0") %>%
  mutate(Label = case_when(LabelID == 1 ~ "CA1",
                           LabelID == 2 ~ "CA2",
                           LabelID == 3 ~ "DG",
                           LabelID == 4 ~ "CA3",
                           LabelID == 5 ~ "Tail",
                           LabelID == 8 ~ "Sub",
                           LabelID == 9 ~ "EC",
                           LabelID == 10 ~ "PrC",
                           LabelID == 11 ~ "A36",
                           LabelID == 12 ~ "PhC",
                           LabelID == 17 ~ "pmEC",
                           LabelID == 18 ~ "alEC")) %>%
  select("subjectID","side","Label","Count","Vol(mm^3)")

vols <- bind_rows(volsR, volsL)
write.csv(vols,paste(resultsDir,'/c3d_volsMTL_global_n55.csv',sep=""),row.names=FALSE)
