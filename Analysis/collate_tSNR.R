## import PIT data subject csv files

tSNRdir <- '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/tSNR'
csvFiles <- list.files(tSNRdir,pattern="*.csv",full.names=1)

# make master table
filesList=lapply(csvFiles,read_csv)
tSNRall <- bind_rows(filesList[1:length(filesList)])

setwd("/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/tSNR")
write_csv(tSNRall, "tSNR_collated_n55.csv")

ggplot(tSNRall, aes(Mask,Mean)) +
  geom_boxplot(outlier.shape = NA,alpha=0.6, show.legend = TRUE)

ggplot(tSNRall, aes(Mask,max)) +
  geom_boxplot(outlier.shape = NA,alpha=0.6, show.legend = TRUE)

ggplot(filter(tSNRall,Mask=="ASHS_EC",Mean>12), aes(as.factor(Code),Mean)) +
  geom_boxplot(outlier.shape = NA,alpha=0.6, show.legend = TRUE)
