
# Phase space / Liapounov phase diagram for Prey Predator model

setwd(paste0(Sys.getenv('CS_HOME'),'/MediationEcotox/Models/Game'))

library(dplyr)
library(ggplot2)

source('functions.R')

datadir = '/Volumes/Data/ComplexSystems/MediationEcotox/Results/Game/20160427_LHSGRID/split/'
resdir = paste0(Sys.getenv('CS_HOME'),'/MediationEcotox/Results/Game')
resfiles = list.files(path=resdir)

# parameter def
for(prelevementProba in c(0.6,0.8,1.0)){for(predatorCarrying in c(0.01,0.015,0.02)){for(preyReproduction in c(0.01,0.015,0.02)){
  
  prelevementProba = 1.0
  predatorCarrying = 0.015
  preyReproduction = 0.015
  
  res = getTrajs(list(prelevementProba=prelevementProba,predatorCarrying=predatorCarrying,preyReproduction=preyReproduction,filetype='.RData'),datadir,FALSE)
  trajx = res$trajx;trajy=res$trajy;trajs=res$trajs;rm(res)
  
  # try with ggplot
  trajid = c();trajtimes=c()
  trajlength = sapply(trajx,length)-1
  for(i in 1:length(trajlength)){trajid=append(trajid,rep(i,trajlength[i]));trajtimes=append(trajtimes,1:trajlength[i])}
  d = data.frame(xs=unlist(lapply(trajx,function(l){l[1:(length(l)-1)]})),
                 ys=unlist(lapply(trajy,function(l){l[1:(length(l)-1)]})),
                 xe=unlist(lapply(trajx,function(l){l[2:length(l)]})),
                 ye=unlist(lapply(trajy,function(l){l[2:length(l)]})),
                 x0=trajs[trajid,2],y0=trajs[trajid,1],
                 id=trajid,times=trajtimes)
  
  
  g=ggplot(d)
  g+geom_segment(aes(x=xs,y=ys,xend=xe,yend=ye,colour=trajtimes))+ scale_colour_gradient(low="yellow",high="red")
  #ylim(c(0,250))+xlim(c(0,250))
  ggsave(filename=paste0(resname,'_trajs.png'))
  
  #}}}}}
  
  
  # try better representation with speed field
  step=10;
  x=seq(from=step/2,to=1000,by=step)
  y=seq(from=step/2,to=400,by=step)
  
  xcors=c();ycors=c();xspeed=c();yspeed=c()
  for(xx in x){for(yy in y){
    rows = (abs(d[,1]-xx)<step/2)&(abs(d[,2]-yy)<step/2)
    if(length(which(rows))>4){
      xcors=append(xcors,xx);ycors=append(ycors,yy)
      xspeed = append(xspeed,mean(d[rows,3]-d[rows,1]))
      yspeed = append(yspeed,mean(d[rows,4]-d[rows,2]))
    }
  }}
  
  g=ggplot(data.frame(x=xcors,y=ycors,xs=xspeed,ys=yspeed),aes(x=x,y=y))
  g+geom_segment(aes(xend = x + xs, yend = y+ys,colour=abs(xs)+abs(ys)),
                 arrow = arrow(length = unit(0.1,"cm")))+ scale_colour_gradient(low="green",high="red")
  #+ theme(axis.ticks = element_line(linetype = "dashed"), 
  #  plot.background = element_rect(fill = "white"), 
  #  legend.position = "bottom", legend.direction = "horizontal")
  
  ggsave(filename=paste0(resname,'_speed.png'))
}}}

###
#  pseudo liapounov : MSE trajs from a given cell

step=25
x=seq(from=step/2,to=250,by=step)
y=seq(from=step/2,to=250,by=step)
liap = c()
trajdiff = function(t1,t2){
    if(length(t1)>length(t2)){tt1=t1;tt2=append(t2,rep(t2[length(t2)],(length(t1)-length(t2))))}else{tt1=t2;tt2=append(t1,rep(t1[length(t1)],(length(t2)-length(t1))))}
    return(sum((tt1-tt2)^2))
}
xcors=c();ycors=c()
for(xx in x){for (yy in y){
  rows = (abs(trajs[,1]-xx)<step/2)&(abs(trajs[,2]-yy)<step/2)
  mse = 0
  for(k1 in which(rows)){# do it dirty
    for(k2 in which(rows)){
      mse = mse + trajdiff(trajx[[k1]],trajx[[k2]])+trajdiff(trajy[[k1]],trajy[[k2]])
    }
  }
  xcors=append(xcors,xx);ycors=append(ycors,yy);liap=append(liap,mse)
}}

g=ggplot(data.frame(x=xcors,y=ycors,liap=liap))
g+geom_raster(aes(x=x,y=y,fill=liap))+ scale_fill_gradient(low="yellow",high="red")


