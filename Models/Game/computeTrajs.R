
# compute trajs and store into readable files

library(dplyr)
library(ggplot2)

setwd(paste0(Sys.getenv('CS_HOME'),'/MediationEcotox/Models/Game'))

source('functions.R')

datadir = '/mnt/volume1/juste/ComplexSystems/MediationEcotox/Results/Game/20160427_LHSGRID/split/'

for(prelevementProba in c(0.6,0.8,1.0)){for(predatorCarrying in c(0.01,0.015,0.02)){for(preyReproduction in c(0.01,0.015,0.02)){
  fileprefix=paste0(datadir,predatorCarrying,'-',format(prelevementProba,nsmall=1),'-',ppreyReproduction)
  res = getTrajs(list(prelevementProba=prelevementProba,predatorCarrying=predatorCarrying,preyReproduction=preyReproduction,filetype='.csv'),datadir,FALSE)
  trajx = res$trajx;trajy=res$trajy;trajs=res$trajs
  traj0 = trajs[,c(2,1)]
  save(trajx,trajy,traj0,file=paste0(fileprefix,'.RData'))
}}}