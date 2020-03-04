setwd('~/Desktop')

rm(list=ls())

library(abind)
library(rjags)
library(runjags)
library(R2jags)
library(R2WinBUGS)

## ------------------------------------------------------------
## create data

## number of sites the species can actually occupy
nsite <- 100
##
## numer of 'known absence sites' (E.g., sites in Europe for a North
## American bee) Change nsite.foreign from 0 to any other value. 
nsite.foreign <- 1000
## occupancy in each time period
## note: we find this effect even when the occupancy is the same in both periods
psi.1 <- 0.8
psi.2 <- 0.8 
## actual detectability in each time period
p.1 <- 0.3
p.2 <- 0.5
## number of visits to each site
nvisit <- 3

## create occupancy matrix for nsite actually occupied sites
X <- array(0, dim=c(nsite=nsite, nvisit=nvisit, nera=2))

## fill in with detections according to era-specific detection
## probabilities
X[,,1] <- rbinom(n=length(X[,,1]), size=1, prob=p.1)
X[,,2] <- rbinom(n=length(X[,,2]), size=1, prob=p.2)

## subset to sites with at least one detection
##
## NOTE: this means that parameters used to simulate occupancy and
## detectability are no longer meaningful
X <- X[apply(X,1,sum)>0,,,drop=FALSE]

## add known zero occupancy sites
if(nsite.foreign>0) {
  X.zero <- array(0, dim=c(nsite=nsite.foreign,nvisit=nvisit,nera=2))
  X <- abind(X,X.zero,along=1)
}

nsite <- dim(X)[1]
nvisit <- dim(X)[2]
nera <- dim(X)[3]

## ------------------------------------------------------------
## package data for JAGS
my.data <- list(X=X,
                nsite=nsite,
                nvisit=nvisit,
                nera=nera)

## ------------------------------------------------------------
## inits
Z.init <- apply(X, c(1, 3), max)
inits <- function(){
  list(z=Z.init)
}
make.inits <- function() {
  RNG <- parallel.seeds("base::BaseRNG", 1)
  c(list(Z=Z.init), RNG[[1]])
}
inits1 <- make.inits()
inits2 <- make.inits()
inits3 <- make.inits()

## ------------------------------------------------------------
## parameters to track
my.params <- c('psi', 'p', 'Z')

## ------------------------------------------------------------
## occupancy model
my.model <- function() {
  
  for(era in 1:nera) {
    ## occupancy
    psi[era] ~ dunif(0,1)
    ## detectability
    p[era] ~ dunif(0,1)
    
    ## Likelihood
    for(site in 1:nsite) {
      ## Occurrence
      Z[site,era] ~ dbern(psi[era])
      p.eff[site,era] <- Z[site,era] * p[era]
      for(visit in 1:nvisit) {
        ## Detection 
        X[site,visit,era] ~ dbern(p.eff[site,era])
      }
    }
  }
}
write.model(my.model, con='model.txt')

## ------------------------------------------------------------
## run model and save output
jags.out <- run.jags(model='model.txt',
                     monitor=my.params,
                     data=my.data,
                     inits=list(inits1,inits2,inits3),
                     n.chains=3,
                     adapt=1000,
                     burnin=1000,
                     sample=100,
                     thin=100,
                     method="parallel")

## ------------------------------------------------------------
## create Z array
sims.mat <- do.call(rbind, jags.out$mcmc)
vars <- dimnames(sims.mat)[[2]]
Z <- vars[grep('Z\\[', vars)]
niter <- dim(sims.mat)[1]
Z.sims.array <<- array(sims.mat[,Z],
                       dim=c(iter=niter,
                             nsite=nsite,
                             nera=nera))

## ------------------------------------------------------------
## average across MCMC iterations and then subset Z 
##
## calculate mean across iterations
Z.means.all <- apply(Z.sims.array, 2:3, mean)
## subset down to only sites where the species was detected
Z.means.sub <- Z.means.all[apply(X, 1, sum)>0,]

## ------------------------------------------------------------
## calculate estimated mean change in occupancy at occupied sites
## (a value other than zero is incorrect)
mean(Z.means.sub[,2]-Z.means.sub[,1])

## compare with mean change in occupancy from the raw data
##
## first drop zero sites again
X <- X[apply(X,1,sum)>0,,,drop=FALSE]
Z.actual <- (apply(X, c(1,3), sum)>0)*1
diff(apply(Z.actual, 2, mean))

## for large nsite.foreign, these values are the same
