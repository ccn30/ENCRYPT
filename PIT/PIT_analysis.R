## PIT analysis
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


###########################################################################
# some summary stats

MeanRoterror <- mean(PITall$AAerror)
MeanADerror <- mean(PITall$ADerror)
table(PITall$Block,PITall$Env) # check randomisation of environment order

# summary table
sumPITall <- PITall %>% 
  group_by(Code,Env,Type) %>% 
  summarize(ADerrorMEAN = mean(ADerror),ADerrorSE = sd(ADerror)/sqrt(n()), n_samples = n())

sumPITall_CB <- PITall %>% 
  group_by(Code,Type) %>% 
  summarize(ADerrorMEAN = mean(ADerror),ADerrorSE = sd(ADerror)/sqrt(n()), n_samples = n())


# plot ADerror by environment type and trial type
pd <- position_dodge2(0.4)
ggplot(data=PITall,aes(x=Type,y=ADerror,colour=Type)) +
  facet_grid(~Env) +
  geom_boxplot(outlier.shape = NA,show.legend=FALSE) +
  geom_point(aes(colour=Type),position=pd,alpha=0.8,show.legend=FALSE) +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  labs(title='Absolute distance error by environment and trial type',x='Trial type',y='Euclidean distance error')

# plot roational error by environment type and trial type
pd <- position_dodge2(0.4)
ggplot(data=PITall,aes(x=Type,y=PAerror,colour=Type)) +
  facet_grid(~Env) +
  geom_boxplot(outlier.shape = NA,show.legend=FALSE) +
  geom_point(aes(colour=Type),position=pd,alpha=0.8,show.legend=FALSE) +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  ylim(0,3) +
  labs(title='Relative rotation error by environment and trial type',x='Trial type',y='Relative rotation error')

# check for staitsical difference between trial type and environment type
# distance error
PIT_ADerr_aov <- aov(data=PITall, ADerror ~ Env * Type)
summary(PIT_ADerr_aov) # there is a main effect of type
PIT_ADerr_tukey <- TukeyHSD(PIT_ADerr_aov) # significant difference 3vs1
#angular error
PIT_AAerr_aov <- aov(data=PITall,AAerror ~ Env * Type)
summary(PIT_AAerr_aov)
PIT_AAerr_tukey <- TukeyHSD(PIT_AAerr_aov)


# plot AD error across trial type

# with boxplot
pd <- position_dodge2(0.3)
ggplot(data=PITall,aes(x=Type,y=ADerror,colour=Type)) +
  geom_boxplot(outlier.shape = NA,show.legend=FALSE,width=0.8) +
  geom_jitter(aes(colour=Type),width=0.2,alpha=0.8,show.legend=FALSE) +
  scale_colour_manual(values = c("#008000", "#008B8B", "#66CDAA")) +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  labs(title='Euclidean distance error by trial type',x='Trial type',y='Euclidean distance error') +
  geom_signif(comparisons=list(c("1","3")),map_signif_level=TRUE,colour='black')

# with violin
ggplot(data=PITall,aes(x=Type,y=ADerror,colour=Type)) +
  geom_violin(aes(fill=Type,alpha=0.5),show.legend=FALSE) +
  geom_jitter(height=0,width=0.3,show.legend = FALSE) +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  labs(title='Euclidean distance error by trial type',x='Trial type',y='Euclidean distance error')

# split by under or over rotation
ggplot(data=PITall,aes(x=Type,y=ADerror,colour=OoB)) +
  geom_boxplot() +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  labs(title='Distance error by trial type',x='Trial type',y='Euclidean distance error',colour="Type of distance error")


# Plot AA error across trial type

# with boxplot
pd <- position_dodge2(0.3)
ggplot(data=PITall,aes(x=Type,y=AAerror,colour=Type)) +
  geom_boxplot(outlier.shape = NA,show.legend=FALSE,width=0.8) +
  geom_jitter(aes(colour=Type),width=0.2,alpha=0.8,show.legend=FALSE) +
  scale_colour_manual(values = c("#008000", "#008B8B", "#66CDAA")) +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  labs(title='Angular error by trial type',x='Trial type',y='Angular error') +
  geom_signif(comparisons=list(c("1","3")),map_signif_level=TRUE,colour='black')

# split by under or over rotation
ggplot(data=PITall,aes(x=Type,y=AAerror,colour=PAng)) +
  geom_boxplot() +
  scale_x_discrete(labels = c("No change","No optic flow", "No distal cues")) +
  labs(title='Angular error by trial type',x='Trial type',y='Angular error',colour="Type of rotation error")


###############################################################
# plot all triggered positions

ggplot(PITall,aes(Flag1_1, Flag1_2)) + 
  geom_point(size=6,colour='green') +
  geom_point(aes(Trig_1,Trig_2,colour=Mean_AD_error),alpha=0.9) +
  scale_colour_manual(values=c("#FFEAA5", "#38808F"),
                      name="Distance error",
                      labels=c("Below average","Above average")) +
  xlim(-3,3) + ylim(-3,3) +
  labs(title='Estimated locations of Cone 1',x='',y='') +
  theme(plot.background = element_rect(fill = "#191970"),
        panel.background = element_rect(fill = "#191970"),
        panel.grid.minor = element_blank(),
        panel.grid.major= element_blank(),
        axis.text = element_text(colour="white"),
        plot.title = element_text(colour="white",face="bold"),
        legend.background = element_rect(fill = "#191970"),
        legend.title = element_text(colour="white"),
        legend.text = element_text(colour="white")
        )

# plot triggered positions just for one cone 1 location
PITall.c1ex <- PITall %>% filter(Flag1_1 > 1.5 & Flag1_2 > 1.5)
PITall.c1c3.ex <- PITall.c1ex %>% filter(Flag3_1 < 0 & Flag3_2 > 0)

ggplot(PITall.c1c3.ex,aes(Flag1_1, Flag1_2)) + 
  geom_point(size=6,colour='green') +
#  geom_point(aes(Flag3_1,Flag3_2)) +
  geom_point(aes(Trig_1,Trig_2,colour=Mean_AD_error),alpha=0.9) +
  scale_colour_manual(values=c("#FFEAA5", "#38808F"),
                      name="Distance error",
                      labels=c("Below average","Above average")) +
  xlim(-2.5,2.5) + ylim(-2.5,2.5) +
  labs(title='Estimated locations of Cone 1',x='',y='') +
  theme(plot.background = element_rect(fill = "#191970"),
        panel.background = element_rect(fill = "#191970",colour="white"),
        panel.grid.minor = element_blank(),
        panel.grid.major= element_blank(),
        axis.text = element_text(colour="white"),
#        axis.line = element_line(colour="white"),
        plot.title = element_text(colour="white",face="bold"),
        legend.background = element_rect(fill = "#191970"),
        legend.title = element_text(colour="white"),
        legend.text = element_text(colour="white")
  )

# plot above with lines

ggplot(PITall.c1c3.ex,aes(Flag1_1, Flag1_2)) + 
  geom_point(size=6,colour='white') +
#  geom_point(aes(Flag2_1,Flag2_2),colour='white') +
#   geom_label(label="Cone 1", x=2.4,y=2,label.padding=unit(0.1,"lines")) +
#  geom_point(aes(x=0,y=-2),colour='white') +
  geom_point(aes(Flag3_1,Flag3_2),colour='white') +
  geom_point(aes(Trig_1,Trig_2),alpha=0.9,colour="#38808F",show.legend = FALSE) +
  geom_segment(aes(x=Flag3_1,y=Flag3_2,xend=Trig_1,yend=Trig_2),colour="#38808F",alpha=0.3,show.legend = FALSE) +
#  geom_segment(aes(x=Flag1_1,y=Flag1_2,xend=0,yend=-2),colour='white') +
#  facet_grid(~Mean_AD_error) +
  xlim(-2.5,2.5) + ylim(-2.5,2.5) +
  labs(title='Estimated locations of Cone 1 from Cone 3',x='',y='') +
  theme(plot.background = element_rect(fill = "#191970"),
        panel.background = element_rect(fill = "#191970"), #,colour="white"),
        panel.grid.minor = element_blank(),
        panel.grid.major= element_blank(),
        axis.text = element_text(colour="white"),
        #        axis.line = element_line(colour="white"),
        plot.title = element_text(colour="white",face="bold"),
        legend.background = element_rect(fill = "#191970"),
        legend.title = element_text(colour="white"),
        legend.text = element_text(colour="white"),
        strip.background = element_rect(colour='white',fill='white')
  )


# plot example triangle
PITex <- PITall.c1c3.ex[1,]
ggplot(PITex) +
  geom_point(aes(Flag1_1,Flag1_2), size=6, colour="green") +
  geom_point(aes(Flag3_1,Flag3_2),colour='white') +
  xlim(-2.5,2.5) + ylim(-2.5,2.5) +
  geom_point(aes(Flag2_1,Flag2_2),colour='white') +
  geom_point(aes(Trig_1,Trig_2),alpha=0.9) +
  geom_segment(aes(x=Flag3_1,y=Flag3_2,xend=Trig_1,yend=Trig_2),alpha=0.3,show.legend = FALSE) +
  geom_segment(aes(Flag1_1,Flag1_2,xend=Flag2_1,yend=Flag2_2),colour='white') +
  geom_segment(aes(Flag3_1,Flag3_2,xend=Flag2_1,yend=Flag2_2),colour='white') +
  labs(title='Estimated locations of Cone 1',x='',y='') +
  theme(plot.background = element_rect(fill = "#191970"),
        panel.background = element_rect(fill = "#191970",colour="white"),
        panel.grid.minor = element_blank(),
        panel.grid.major= element_blank(),
        axis.text = element_text(colour="white"),
        #        axis.line = element_line(colour="white"),
        plot.title = element_text(colour="white",face="bold"),
        legend.background = element_rect(fill = "#191970"),
        legend.title = element_text(colour="white"),
        legend.text = element_text(colour="white"),
        strip.background = element_rect(colour='white',fill='white')
  )

