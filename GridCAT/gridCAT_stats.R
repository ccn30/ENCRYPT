# Stats on gridcode metrics 
require(ggplot2)
require(dplyr)
require(tibble)
require(readr)
require(tidyr)

# includes demographics
tgridcode = read_csv('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/gridCAT_outX_totalresults.csv');
tgridtaskin = read.csv('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/gridCATbehaviourresults.csv');
#demographics = read.csv('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/demographics.csv')

######### TIDY DATA #############
# recode age cont to cat in tgridcodein
tgridcodein <- tgridcode %>% mutate(Age=cut(Age,breaks = c(-Inf, 30, Inf), labels = c("Young","Old")))

# cant gather tstability / mag / sStability = different values

# get magnitude
grid.mag.untidy = tgridcodein %>% select(Subject,Age,Gender,starts_with("GCmagnitude"))

grid.mag <- grid.mag.untidy %>% gather(Model,Grid_Magnitude,starts_with("GCmag"))
grid.mag.sep <- separate(grid.mag,Model,c(NA,"Run",NA,NA,"Model"),"_")

rm(grid.mag.untidy)

# get spatial stability
#Rayleigh Z
grid.sStability.z.untidy <- tgridcodein %>% select(Subject,Age,Gender,starts_with("sStability_zRay"))

grid.sStability.z <- grid.sStability.z.untidy %>% gather(Model,Grid_sStabilityZ,starts_with("sStability"))
grid.sStability.z.sep <- separate(grid.sStability.z,Model,c(NA,NA,"Run",NA,NA,"Model"),"_")
#Rayleigh p
grid.sStability.p.untidy <- tgridcodein %>% select(Subject,Age,Gender,starts_with("sStability_pRay"))

grid.sStability.p <- grid.sStability.p.untidy %>% gather(Model,Grid_sStabilityP,starts_with("sStability"))
grid.sStability.p.sep <- separate(grid.sStability.p,Model,c(NA,NA,"Run",NA,NA,"Model"),"_")

rm(grid.sStability.p.untidy,grid.sStability.z.untidy)

# get temporal stability
grid.tStability.untidy <- tgridcodein %>% select(Subject,Age,Gender,starts_with("tStability"))

grid.tStability <- grid.tStability.untidy %>% gather(Model,Grid_tStability,starts_with("tStability"))
grid.tStability.sep <- separate(grid.tStability,Model,c(NA,NA,"RunComparison",NA,NA,"Model"),"_")
rm(grid.tStability.untidy)

#filter(RunComparison == "allRunsAvgVSrun1")
#dim(tgridcodein)

############## Stats and Plot #################

# compare magnitude in different models, using average of all runs
gridmagav <- filter(grid.mag.sep,Run == "allRuns")

modelcomp_mag <- lm(data = gridmagav,Grid_Magnitude~Model)
modelcomp_mag.stats <- anova(modelcomp_mag)

ggplot(gridmagav, aes(Model,Grid_Magnitude,fill = Model)) +
  geom_boxplot()
# Plot magnitude per run across models
gridmagruns <- filter(grid.mag.sep,Run != "allRuns")



# tStABILITY RUN1 vs RUN2
tStab.run1vsrun2 <- filter(grid.tStability.sep,RunComparison == "run1VSrun2")
modelcom_tStab1vs2 <- lm(data = tStab.run1vsrun2,Grid_tStability~Model)
summary(modelcom_tStab1vs2)
ggplot(tStab.run1vsrun2, aes(Model,Grid_tStability,fill=Model)) +
  geom_boxplot()
# tStability Run2 vs Run3
tStab.run2vsrun3 <- filter(grid.tStability.sep,RunComparison == "run2VSrun3")
modelcom_tStab2vs3 <- lm(data = tStab.run2vsrun3,Grid_tStability~Model)
summary(modelcom_tStab2vs3)
ggplot(tStab.run2vsrun3, aes(Model,Grid_tStability,fill=Model)) +
  geom_boxplot()
# frequency of Rayligh significance across all runs, all models

# age differences
# magnitude
agecomp.mag <- glm(data = gridmagav)
ggplot(filter(gridmagav,Age>30), aes(Model,Grid_Magnitude,fill = Model)) +
  geom_boxplot()
ggplot(gridmagav, aes(y=Grid_Magnitude,x=interaction(Model,Age),fill = Age)) +
  geom_boxplot()
ggplot(gridmagav, aes(y=Grid_Magnitude,x=Model)) +
  geom_boxplot() +
  facet_wrap(~Age)
interaction.plot(gridmagav$Model,gridmagav$Age,gridmagav$Grid_Magnitude,xlab="Model",ylab="Mean Grid Magnitude",trace.label="Age",type='b',pch=4,col=c('blue','red'))
#ggplot(gridmagav,aes(y = Grid_Magnitude)) +
  geom_boxplot(aes(x = Model, colour = Model)) +
  geom_boxplot(aes(x = Age, colour = Age))

attach(gridmagav)
interaction.plot(Grid_Magnitude$Model,Grid_Magnitude$Age)