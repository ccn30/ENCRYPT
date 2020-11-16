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

# make distance error factor variable

MeanADerror <- mean(PITall$ADerror)
PITall <- PITall %>% mutate(Mean_AD_error=cut(ADerror,breaks = c(-Inf, MeanADerror, Inf), labels = c("Low distance error","High distance error")))


# some summary stats
MeanRoterror <- mean(PITall$AAerror)



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

