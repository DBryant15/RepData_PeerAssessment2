#load libraries
library("sqldf")

#Check for file, and DL if not available
fileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
destfile <- "StormData.csv"
if(!file.exists(destfile))
  {
  download.file(fileURL,
                destfile)
  }

#read main data into a dataframe
StormData <- read.csv("StormData.csv", header = TRUE, stringsAsFactors = FALSE)

#Get data on the injuries and fatalities happening 
GetIntialPplDMG <- sqldf::sqldf("
SELECT STATE, 
EVTYPE, 
SUM(FATALITIES) as TotalStateFatailies, 
SUM(INJURIES) as TotalStateInjuries, 
(SUM(FATALITIES) + SUM(INJURIES)) AS FatalAndInjuresCombined
FROM StormData
GROUP BY STATE, EVTYPE
ORDER BY STATE, EVTYPE")

PplDMG_GroupedBy_EVTYPE <-  sqldf::sqldf("SELECT EVTYPE, SUM(FatalAndInjuresCombined)  
                                         FROM GetIntialPplDMG
                                         GROUP BY EVTYPE
                                         ORDER BY SUM(FatalAndInjuresCombined) DESC")

#PROPDMGEXP
PROPDMGEXP_uniqueElements <- sqldf::sqldf("SELECT PROPDMGEXP, COUNT(PROPDMGEXP) 
                                          FROM StormData
                                          GROUP BY PROPDMGEXP")

#find unique values of CROPDMGEXP
CROPDMGEXP_uniqueElements <- sqldf::sqldf("SELECT CROPDMGEXP, COUNT(PROPDMGEXP) 
                                          FROM StormData
                                          GROUP BY CROPDMGEXP")


#Get data on economic effect
# GetIntialPplDMG <- sqldf::sqldf("
# SELECT STATE, 
# EVTYPE, 
# , 
# SUM(INJURIES) as TotalStateInjuries, 
# (SUM(FATALITIES) + SUM(INJURIES)) AS FatalAndInjuresCombined
# FROM StormData
# GROUP BY STATE, EVTYPE
# ORDER BY STATE, EVTYPE")