# function to extract relevant PREVENT data from master file by CB code

library(tidyverse)
require(readxl)
require(RColorBrewer)
require(ggthemes)
require(lme4)
require(ggsignif)

# CbcodesIN must have subjectID column name
CBcodesIN <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/ENCRYPT_MasterCBcodes.csv'
PREVENTmetaIN <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/PREVENT/Baseline_eCRF.xlsx'

extractPREVENT <- function(CBcodesIN,PREVENTmetaIN) {
  CBcodes <- read_csv(CBcodesIN)
  PREVENTmeta <- read_excel(PREVENTmetaIN)
  ENCRYPT_data <- left_join(CBcodes,PREVENTmeta, by="subjectID")
}
ENCRYPT_data <- extractPREVENT(CBcodesIN,PREVENTmetaIN)

setwd("/lustre/scratch/wbic-beta/ccn30/ENCRYPT/PREVENT")
write_csv(ENCRYPT_data, "PREVENTdata_ENCRYPTn35.csv")