# Function to extract relevant PREVENT data by CBcode from master file 'meta'

library(tidyverse)
require(readxl)
require(RColorBrewer)
require(ggthemes)
require(lme4)
require(ggsignif)

# CbcodesIN must have subjectID column name
CBcodesIN <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/ENCRYPT_MasterCBcodes.csv'
PREVENTmetaIN <- '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/PREVENT/Baseline_eCRF.xlsx'

# define function
extractPREVENT <- function(CBcodesIN,PREVENTmetaIN) {
  CBcodes <- read_csv(CBcodesIN)
  PREVENTmeta <- read_excel(PREVENTmetaIN)
  ENCRYPT_data <- left_join(CBcodes,PREVENTmeta, by="subjectID")
}

# run function and get output variable
ENCRYPT_data <- extractPREVENT(CBcodesIN,PREVENTmetaIN)

# write to CSV file in PREVENT dir
setwd("/lustre/scratch/wbic-beta/ccn30/ENCRYPT/PREVENT")
write_csv(ENCRYPT_data, "PREVENTdata_ENCRYPTn39.csv")

