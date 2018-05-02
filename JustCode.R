#load libraries------------------------------------------------------------------
library("sqldf")

#Check for file, and DL if not available------------------------------------------
fileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
destfile <- "StormData.csv"
if(!file.exists(destfile))
  {
  download.file(fileURL,
                destfile)
  }

#read main data into a dataframe-------------------------------------------------
StormData <- read.csv("StormData.csv", header = TRUE, stringsAsFactors = FALSE)

#Get data on the injuries and fatalities  ---------------------------------------------
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



#Get data on economic effect ------------------------------------------------------

#find unique values of PROPDMGEXP
PROPDMGEXP_uniqueElements <- sqldf::sqldf("SELECT PROPDMGEXP, COUNT(PROPDMGEXP) 
                                          FROM StormData
                                          GROUP BY PROPDMGEXP")



#find unique values of CROPDMGEXP
CROPDMGEXP_uniqueElements <- sqldf::sqldf("SELECT CROPDMGEXP, COUNT(CROPDMGEXP) 
                                          FROM StormData
                                          GROUP BY CROPDMGEXP")


#20180502 1325 At this time it would appear that the remarks
#field will not help identify the unique value exp
#Maybe explore the dropping of these?
#query to figure out if the strange EPX values are explained in remarks
CROP_PROPDMGEXP_StrangeValueRemarks <- sqldf::sqldf(
"SELECT PROPDMG, 
PROPDMGEXP,
CROPDMG,
CROPDMGEXP, 
REMARKS
FROM StormData
WHERE REMARKS <> ''
")
#removed from above query as they had no appearent effect
#AND (PROPDMGEXP <> 'K' OR PROPDMGEXP <> 'B' OR PROPDMGEXP <> '0' OR PROPDMGEXP <> '')
#AND (CROPDMGEXP <> 'K' OR CROPDMGEXP <> 'B' OR CROPDMGEXP <> '0' OR CROPDMGEXP <> '')

# The query for CROP and PROP will have to have cases that
# account for the variation in the EXp values
