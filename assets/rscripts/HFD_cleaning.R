####Setup####
library(HMDHFDplus)
library(jsonlite)
library(dplyr)
options(scipen=10)

####Read HFD username and password from local file####
####You may also just enter them manually####
HFDcredentials <- read.csv("~/Documents/creds/HFD.csv", stringsAsFactors = FALSE)

####Pull list of Human Fertility Collection and Database countries for labeling stuff and getting data####
HFCcountries <- getHFCcountries(names = TRUE)
HFDcountries <- getHFDcountries()

####Get data from HFD, may take a minute####
for (country in HFDcountries){
  assign(paste(country,"data",sep=""),readHFDweb(CNTRY = country, item ="asfrRR", username=HFDcredentials$username, password = HFDcredentials$password))
}

####Prep to join country names to HFD codes as getHFDcountries() does not by default####
countrylist <- NULL
countrylist$code <- HFDcountries

alldata <- list()
count <-1
####Munge pulled data to a nice JSON for use with D3####
for(country in HFDcountries){
  
  tempmatrix <- matrix(nrow=44,ncol=length(seq(min(get(paste(country,"data",sep=""))$Year),max(get(paste(country,"data",sep=""))$Year))))

  for(year in seq(min(get(paste(country,"data",sep=""))$Year),max(get(paste(country,"data",sep=""))$Year))){
    tempmatrix[,1 + year - min(get(paste(country,"data",sep=""))$Year)] <- as.vector(filter(get(paste(country,"data",sep="")), Year==year)$ASFR)
  }
  
  colnames(tempmatrix) <- as.character(seq(min(get(paste(country,"data",sep=""))$Year),max(get(paste(country,"data",sep=""))$Year)))

  tempmatrix <- round(tempmatrix,3)
  tempmatrix <- as.list(data.frame(tempmatrix))
  
  tempjson <- NULL
  tempjson$minyear <- min(get(paste(country,"data",sep=""))$Year)
  tempjson$maxyear <- max(get(paste(country,"data",sep=""))$Year)
  tempjson$countryname <- HFCcountries[match(country,HFCcountries$Code),1]
  if(country == "FRATNP"){
    tempjson$countryname <- "France"
  }
  tempjson$ages <- seq(12,55)
  tempjson$fertilityrates <- tempmatrix
  alldata[count] <- list(tempjson)
  names(alldata)[count] <- country
  #tempjson <- toJSON(tempjson,digits=6,pretty=TRUE)
  
  #write(tempjson,paste("~/GitHub/chartsoncharts/assets/interactives/HFD/data/",country,".json",sep=""))
  assign(paste(country,"json",sep=""),tempjson)
  
  countrylist$country[match(country,HFDcountries)] <- HFCcountries[match(country,HFCcountries$Code),1]
  count <-count + 1
}
alldata <- toJSON(alldata,digits=6,pretty=TRUE)
write(alldata,paste("~/GitHub/chartsoncharts/assets/interactives/HFD/data/alldata.json",sep=""))

####France code is not the same between HFD and HFC, manually fix for now####
countrylist$country[match("FRATNP",countrylist$code)] <- "France"

countrylist$code <- c("None",countrylist$code)
countrylist$country <- c("None",countrylist$country)

####Generate empty json for "None" option. Not optimal and creates unneccesary get requests, but quick####

write(toJSON(c),"~/GitHub/chartsoncharts/assets/interactives/HFD/data/None.json")

####This will be the menu reference file for the D3 viz####
write.csv(countrylist,"~/GitHub/chartsoncharts/assets/interactives/HFD/data/countrylist.csv",row.names=FALSE)
alldata$AUT <- AUTjson
alldata$BGR <- BGRjson
alldata$BLR <- BLRjson
alldata$CAN <- CANjson
alldata$CHE <- CHEjson
alldata$CHL <- CHLjson
alldata$CZE <- CZEjson
alldata$DEUTE <- DEUTEjson
alldata$DEUTNP <- DEUTNPjson
alldata$DEUTW <- DEUTWjson
alldata$EST <- ESTjson
alldata$FIN <- FINjson
alldata$FRATNP <- FRATNPjson
test <- list("aut" = AUTjson, "usa" = USAjson)

