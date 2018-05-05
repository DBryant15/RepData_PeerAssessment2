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

##find unique values of PROPDMGEXP--------------------------
PROPDMGEXP_COUNTuniqueElements <- sqldf::sqldf("SELECT PROPDMGEXP, COUNT(PROPDMGEXP) 
                                          FROM StormData
                                          GROUP BY PROPDMGEXP")



##find unique values of CROPDMGEXP--------------------------------
CROPDMGEXP_COUNTuniqueElements <- sqldf::sqldf(
"SELECT CROPDMGEXP, COUNT(CROPDMGEXP) 
FROM StormData
GROUP BY CROPDMGEXP")

##Statements to explore exact values in EXP

###Result of this QRY implys that 465934 (the majority of PROPDMGEXP) are =''----------
PROPDMGEXP_EXPLOREuniqueElements <- sqldf::sqldf(
"SELECT COUNT(PROPDMGEXP) 
FROM StormData
WHERE PROPDMGEXP = '' 
GROUP BY PROPDMGEXP")

###Result of this QRY: grouping the 465934 to see what they are ----------
PROPDMGEXP_EXPLORE2uniqueElements <- sqldf::sqldf("
SELECT PROPDMG, count(PROPDMG) 
FROM StormData
WHERE PROPDMGEXP = '' 
GROUP BY PROPDMG")

###Result of this QRY implys that 618413 (the majority of CROPDMGEXP) are =''---------
CROPDMGEXP_EXPLOREuniqueElements <- sqldf::sqldf("
SELECT COUNT(CROPDMGEXP) 
FROM StormData 
WHERE CROPDMGEXP = ''
GROUP BY CROPDMGEXP")

###Result of this QRY: grouping the 618413 to see what they are ----------
CROPDMGEXP_EXPLORE2uniqueElements <- sqldf::sqldf("
SELECT CROPDMG, count(CROPDMG)
FROM StormData
WHERE CROPDMGEXP = '' 
GROUP BY CROPDMG")

##TODO: this will be the case statement to handle the unique values of StormData-----

StormData_w_ColumnforFullNumericCost <- sqldf::sqldf("SELECT *, '1' as new_Column
                                                     FROM StormData")

##Exploratory statement: Get non-blank REMARKS------------------------------------
#20180502 1325 At this time it would appear that the remarks
#field will not help identify the unique value exp
#Maybe explore the dropping of these?
#query to figure out if the strange EXP values are explained in remarks
# CROP_PROPDMGEXP_StrangeValueRemarks <- sqldf::sqldf(
# "SELECT PROPDMG, 
# PROPDMGEXP,
# CROPDMG,
# CROPDMGEXP, 
# REMARKS
# FROM StormData
# WHERE REMARKS <> ''
# ")
#removed from above query as they had no appearent effect
#AND (PROPDMGEXP <> 'K' OR PROPDMGEXP <> 'B' OR PROPDMGEXP <> '0' OR PROPDMGEXP <> '')
#AND (CROPDMGEXP <> 'K' OR CROPDMGEXP <> 'B' OR CROPDMGEXP <> '0' OR CROPDMGEXP <> '')

# The query for CROP and PROP will have to have cases that
# account for the variation in the EXp values
