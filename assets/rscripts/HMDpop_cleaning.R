library(demography)
library(HMDHFDplus)
library(jsonlite)

HMDcountries <- getHMDcountries()
HFDcountries <- getHFDcountries()
HFCcountries <- getHFCcountries(names=TRUE)
countries <- NULL
country <- "USA"
test <- hmd.pop(country,"sjh09@my.fsu.edu","velocity")

count <- 1
countries <-NULL
countrykey <-NULL
for (country in HMDcountries){
  tempmatrix <- hmd.pop(country,"sjh09@my.fsu.edu","velocity")
  tempmatrix <- extract.ages(tempmatrix, age=0:100)
  
  tempmatrix$label <- HFCcountries[match(country,HFCcountries$Code),1]
  if(country == "FRATNP"){
    tempmatrix$label <- "France, Total Population"
  }
  if(country == "FRACNP"){
    tempmatrix$label <- "France, Civilians"
  }
  if(country == "NZL_NP"){
    tempmatrix$label <- "New Zealand, Total"
  }
  if(country == "NZL_MA"){
    tempmatrix$label <- "New Zealand, Maori"
  }
  if(country == "NZL_NM"){
    tempmatrix$label <- "New Zealand, Non-Maori"
  }
  if(country == "GBRCENW"){
    tempmatrix$label <- "UK, England/Wales Civilians"
  }
  if(country == "GBRTENW"){
    tempmatrix$label <- "UK, England/Wales Total"
  }
  class(tempmatrix) <- NULL
  tempmatrix$pop$total <- NULL
  countries[count]<-list(tempmatrix)
  names(countries)[count] <- country

  countrykey$label <- tempmatrix$label
  names(countrykey)[count] <- country
  tempjson <- toJSON(tempmatrix,digits=6,pretty=TRUE)
  write(tempjson,paste("~/GitHub/chartsoncharts/assets/interactives/HMD/data/",country,".json",sep=""))
  count <- count + 1
}

alldata <- toJSON(countries,digits=6,pretty=TRUE)
write(alldata,paste("~/GitHub/chartsoncharts/assets/interactives/HMD/data/alldata.json",sep=""))
countrykey$BEL <- NULL
countrykeyjson <- toJSON(countrykey,pretty=TRUE)
write(countrykeyjson,"~/GitHub/chartsoncharts/assets/interactives/HMD/data/countrykey.json")
