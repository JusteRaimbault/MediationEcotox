
# results of ecosystem model exploration

setwd(paste0(Sys.getenv('CS_HOME'),'/MediationEcotox/Results/Ecosystem_simple_LHS'))

library(dplyr)

res <- as.tbl(read.csv('2016_04_12_14_50_14_GRID.csv'))

gres <- res %>% group_by(id) %>% summarise(
  collapsed=mean(collapsed),finalSpecies=mean(finalSpecies),finalTime=mean(finalTime),speciesBalance=mean(speciesBalance),
  energyFromFishes=mean(energyFromFishes),energyFromRessources=mean(energyFromRessources),initialBalance=mean(initialBalance),
  maturAge=mean(maturAge),maxAge=mean(maxAge),movingCost=mean(movingCost),numFishes=mean(numFishes),numRessources=mean(numRessources),
  reproductionCost=mean(reproductionCost),ressourceRenewal=mean(ressourceRenewal)
)

data.frame(gres[gres$finalTime==2000,])
data.frame(gres[gres$finalSpecies>1.1,])
