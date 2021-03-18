# Stats on gridcode metrics 
require(ggplot2)
require(dplyr)
require(tibble)
require(readr)
require(tidyr)
require(RColorBrewer)
require(ggthemes)
require(lme4)
####################################
# load in non-rotation analysed data
csvImport = read_csv('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/gridCAT/gridCAT_X_results_global.csv')
csvImport[1] <- lapply(csvImport[1],factor)

# tidy data
gridmag.untidy <- csvImport %>% select(Subject,starts_with("GCmagnitude")) 
gridmag.gather <- gridmag.untidy %>% gather(Model,Grid_Magnitude,starts_with("GCmag"))
gridmag <- separate(gridmag.gather,Model,c(NA,"Run","ROI","Side","XFold"),"_")
rm(gridmag.gather,gridmag.untidy)

# plot magnitudes of runs
gridmag.pmEC <- gridmag %>% filter(ROI %in% "pmEC")

pd <- position_dodge(0.2)
ggplot(gridmag.pmEC, aes(Side,Grid_Magnitude)) +
  geom_boxplot(aes(fill=Run),outlier.shape = NA,alpha=0.6, show.legend = TRUE) +
  scale_fill_brewer(palette="YlGnBu") +
  labs(title = "Grid cell like signals at 7T fMRI", x = "Side", y = "Magnitude of Grid-like Signal")

ggplot(gridmag, aes(ROI,Grid_Magnitude)) +
  geom_boxplot(aes(fill=Run),outlier.shape = NA,alpha=0.6, show.legend = TRUE) +
  facet_grid(~Side,scales = "free") +
  scale_fill_brewer(palette="YlGnBu") +
  scale_x_discrete(labels = c("Anterolateral EC","Posteromedial EC", "Anterolateral EC","Posteromedial EC")) +
  labs(title = "Grid cell like signals at 7T fMRI, all Runs", x = "Region", y = "Magnitude of Grid-like Signal")

gridmag.allRuns <- gridmag %>% filter(Run %in% "allRuns")
ggplot(gridmag.allRuns, aes(ROI,Grid_Magnitude)) +
  geom_boxplot(aes(fill=ROI),outlier.shape = NA,alpha=0.6, show.legend = FALSE) +
  facet_grid(~Side,scales = "free") +
  geom_line(aes(group=Subject), alpha=0.4, position = pd) +
  geom_point(aes(group=Subject,fill=Subject),size=2,shape=21,position = pd) +
#  scale_fill_brewer(palette="YlGnBu") +
  scale_x_discrete(labels = c("Anterolateral EC","Posteromedial EC", "Anterolateral EC","Posteromedial EC")) +
  labs(title = "Grid cell like signals at 7T fMRI collapsed across runs", x = "Region", y = "Magnitude of Grid-like Signal")

#########################################
# read in new data

csvImportNR= read_csv('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/gridCAT/gridCAT_X_nr_results_global.csv')
csvImportNR[1:2] <- lapply(csvImportNR[1:2],factor)

# tidy data
gridmagNR.untidy <- csvImportNR %>% select(Subject,starts_with("GCmagnitude")) 
gridmagNR.gather <- gridmagNR.untidy %>% gather(Model,Grid_Magnitude,starts_with("GCmag"))
gridmagNR <- separate(gridmagNR.gather,Model,c(NA,"Run","ROI","Side","XFold"),"_")
rm(gridmagNR.gather,gridmagNR.untidy)

# plot magnitudes of runs
gridmagNR.pmEC <- gridmagNR %>% filter(ROI %in% "pmEC")

pd <- position_dodge(0.2)
ggplot(gridmagNR.pmEC, aes(Side,Grid_Magnitude)) +
  geom_boxplot(aes(fill=Run),outlier.shape = NA,alpha=0.6, show.legend = TRUE) +
  scale_fill_brewer(palette="YlGnBu") +
  labs(title = "Grid cell like signals at 7T fMRI", x = "Side", y = "Magnitude of Grid-like Signal")

ggplot(gridmagNR, aes(ROI,Grid_Magnitude)) +
  geom_boxplot(aes(fill=Run),alpha=0.6, show.legend = TRUE) +
  facet_grid(~Side,scales = "free") +
  scale_fill_brewer(palette="YlGnBu") +
  scale_x_discrete(labels = c("Anterolateral EC","Posteromedial EC", "Anterolateral EC","Posteromedial EC")) +
  labs(title = "Grid cell like signals at 7T fMRI, all Runs", x = "Region", y = "Magnitude of Grid-like Signal")

gridmagNR.allRuns <- gridmagNR %>% filter(Run %in% "allRuns")
ggplot(gridmagNR.allRuns, aes(ROI,Grid_Magnitude)) +
  geom_boxplot(aes(fill=ROI),outlier.shape = NA,alpha=0.6, show.legend = FALSE) +
  facet_grid(~Side,scales = "free") +
  geom_line(aes(group=Subject), alpha=0.4, position = pd) +
  geom_point(aes(group=Subject),size=2,shape=21,position = pd) +
  scale_fill_brewer(palette="YlGnBu") +
  scale_x_discrete(labels = c("Anterolateral EC","Posteromedial EC", "Anterolateral EC","Posteromedial EC")) +
  labs(title = "Grid cell like signals at 7T fMRI collapsed across runs", x = "Region", y = "Magnitude of Grid-like Signal")



