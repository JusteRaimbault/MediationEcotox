

getTrajs <- function(params,filter){
  if("file" %in% names(params)){
    trajs <- as.tbl(read.csv(params$file,header=FALSE,stringsAsFactors = FALSE))
  }else{
    trajs <- as.tbl(read.csv(paste0('split/',params$grassRegrow,'.0-',params$sheepGain,'.0-',params$sheepRepro,'.0-',params$withGrass,'.0-',params$wolfGain,'.0-',params$wolfRepro,'.0.csv'),header=FALSE,stringsAsFactors = FALSE))
  }
    
  # try to plot raw trajectories
  trajx=list();trajy=list()
  for(i in 1:nrow(trajs)){
    trajx[[i]]=as.numeric(strsplit(as.character(trajs[i,3]),'-')[[1]])
    trajy[[i]]=as.numeric(strsplit(as.character(trajs[i,4]),'-')[[1]])
  }
  
  if(filter != FALSE){
    bx = filter$bx;by=filter$by
    rows = which(sapply(trajx,min)>bx[1]&sapply(trajx,max)<bx[2]&sapply(trajy,min)>by[1]&sapply(trajy,max)<by[2])
    otrajx=trajx;otrajy=trajy;trajx=list();trajy=list()
    for(i in 1:length(rows)){trajx[[i]]=otrajx[[rows[i]]];trajy[[i]]=otrajy[[rows[i]]]}
    trajs=trajs[rows,]
  }
  
  return(list(trajx=trajx,trajy=trajy,trajs=trajs))
}


