
# Phase space / Liapounov phase diagram for Prey Predator model

setwd(paste0(Sys.getenv('CS_HOME'),'/MediationEcotox/Results/PreyPredator'))

library(dplyr)
library(ggplot2)

source('functions.R')

resfiles = list.files(path="split")

# parameter def
for(sheepGain in c(20,60,100)){for(wolfGain in c(20,60,100)){for(sheepRepro in c(5,10,20)){
  for(wolfRepro in c(5,10,20)){for(grassRegrow in c(20,60,100)){

#sheepGain=20;wolfGain=20;
#sheepRepro=5;wolfRepro=5;
withGrass=1;#grassRegrow=100;

resname=paste0('res/full/withGrass',withGrass,'_grassRegrow',grassRegrow,'_sheepGain',sheepGain,'_wolfGain',wolfGain,'_sheepRepro',sheepRepro,'_wolfRepro',wolfRepro)
show(resname)

trajs <- as.tbl(read.csv(paste0('split/',grassRegrow,'.0-',sheepGain,'.0-',sheepRepro,'.0-',withGrass,'.0-',wolfGain,'.0-',wolfRepro,'.0.csv'),header=FALSE,stringsAsFactors = FALSE))
names(trajs)[1:2]=c("x0","y0")

# check initial discrepancy
#plot(trajs[,1],trajs[,2])

# try to plot raw trajectories
trajx=list();trajy=list()
for(i in 1:nrow(trajs)){
  trajx[[i]]=as.numeric(strsplit(as.character(trajs[i,3]),'-')[[1]])
  trajy[[i]]=as.numeric(strsplit(as.character(trajs[i,4]),'-')[[1]])
}

# filter trajectory within some bounds
# bx=c(-1,1000);by=c(-1,1000)
# rows = which(sapply(trajx,min)>bx[1]&sapply(trajx,max)<bx[2]&sapply(trajy,min)>by[1]&sapply(trajy,max)<by[2])
# otrajx=trajx;otrajy=trajy;trajx=list();trajy=list()
# for(i in 1:length(rows)){trajx[[i]]=otrajx[[rows[i]]];trajy[[i]]=otrajy[[rows[i]]]}
# trajs=trajs[rows,]

# try with ggplot
trajid = c();trajtimes=c()
trajlength = sapply(trajx,length)-1
for(i in 1:length(trajlength)){trajid=append(trajid,rep(i,trajlength[i]));trajtimes=append(trajtimes,1:trajlength[i])}
d = data.frame(xs=unlist(lapply(trajx,function(l){l[1:(length(l)-1)]})),
               ys=unlist(lapply(trajy,function(l){l[1:(length(l)-1)]})),
               xe=unlist(lapply(trajx,function(l){l[2:length(l)]})),
               ye=unlist(lapply(trajy,function(l){l[2:length(l)]})),
               x0=trajs[trajid,1],y0=trajs[trajid,2],
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
  }}}}}

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


