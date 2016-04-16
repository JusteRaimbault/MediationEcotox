
# splitting huge res file into small phase spaces

setwd(paste0(Sys.getenv('CS_HOME'),'/MediationEcotox/Results/PreyPredator'))

#res <- read.csv('2016_04_13_12_33_12_LHSGRID_EGI.csv')
res<-read.csv('head.csv')

library(dplyr)

df = as.tbl(res) %>% group_by(grassRegrow,sheepGain,sheepRepro,withGrass,wolfGain,wolfRepro)
