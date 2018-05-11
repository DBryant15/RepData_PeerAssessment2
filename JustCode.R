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

# Key to define the EXP values:
#
# (+) = 1
#
# numeric 0..8 = 10
#
# H,h = hundreds = 100
# 
# K,k = kilos = thousands = 1,000
# 
# M,m = millions = 1,000,000
# 
# B,b = billions = 1,000,000,000
# 
# (-) = 0
# 
# (?) = 0
# 
# black/empty character = 0
# 

StormData_w_ColumnforFullNumericCost <- sqldf::sqldf("SELECT *, 
CASE 
WHEN CROPDMGEXP = '+' THEN 1 
WHEN CROPDMGEXP = '0' THEN 10 
WHEN CROPDMGEXP = '1' THEN 10 
WHEN CROPDMGEXP = '2' THEN 10 
WHEN CROPDMGEXP = '3' THEN 10 
WHEN CROPDMGEXP = '4' THEN 10 
WHEN CROPDMGEXP = '5' THEN 10 
WHEN CROPDMGEXP = '6' THEN 10 
WHEN CROPDMGEXP = '7' THEN 10 
WHEN CROPDMGEXP = '8' THEN 10 
WHEN CROPDMGEXP = '9' THEN 10 
WHEN CROPDMGEXP = 'H' THEN 100 
WHEN CROPDMGEXP = 'h' THEN 100 
WHEN CROPDMGEXP = 'K' THEN 1000 
WHEN CROPDMGEXP = 'k' THEN 1000 
WHEN CROPDMGEXP = 'M' THEN 1000000 
WHEN CROPDMGEXP = 'm' THEN 1000000 
WHEN CROPDMGEXP = 'B' THEN 1000000000 
WHEN CROPDMGEXP = 'b' THEN 1000000000 
ELSE 0
END CROP_MULT, 
CASE 
WHEN PROPDMGEXP = '+' THEN 1 
WHEN PROPDMGEXP = '0' THEN 10 
WHEN PROPDMGEXP = '1' THEN 10 
WHEN PROPDMGEXP = '2' THEN 10 
WHEN PROPDMGEXP = '3' THEN 10 
WHEN PROPDMGEXP = '4' THEN 10 
WHEN PROPDMGEXP = '5' THEN 10 
WHEN PROPDMGEXP = '6' THEN 10 
WHEN PROPDMGEXP = '7' THEN 10 
WHEN PROPDMGEXP = '8' THEN 10 
WHEN PROPDMGEXP = '9' THEN 10 
WHEN PROPDMGEXP = 'H' THEN 100 
WHEN PROPDMGEXP = 'h' THEN 100 
WHEN PROPDMGEXP = 'K' THEN 1000 
WHEN PROPDMGEXP = 'k' THEN 1000 
WHEN PROPDMGEXP = 'M' THEN 1000000 
WHEN PROPDMGEXP = 'm' THEN 1000000 
WHEN PROPDMGEXP = 'B' THEN 1000000000 
WHEN PROPDMGEXP = 'b' THEN 1000000000 
ELSE 0
END PROP_MULT
FROM StormData")

StormData_w_ColumnforFullNumericCost_r2 <- sqldf::sqldf( 
"SELECT *,
(CROP_MULT * CROPDMG) AS CROPDMG_COST,
(PROP_MULT * PROPDMG) AS PROPDMG_COST 
FROM StormData_w_ColumnforFullNumericCost" 
)

#Prep all for plotting

StormData_w_Cost_PerEventType_CropDamage <- sqldf::sqldf(
  "SELECT EVTYPE, SUM(CROPDMG_COST) as SUM_OF_CROP_DAMAGE
  FROM StormData_w_ColumnforFullNumericCost_r2
  WHERE CROPDMG_COST > 0 
  GROUP BY EVTYPE 
  ORDER BY SUM(CROPDMG_COST) DESC
  LIMIT 10"
)

StormData_w_Cost_PerEventType_PropDamage <- sqldf::sqldf(
  "SELECT EVTYPE, SUM(PROPDMG_COST) as SUM_OF_PROP_DAMAGE
  FROM StormData_w_ColumnforFullNumericCost_r2
  WHERE PROPDMG_COST > 0 
  GROUP BY EVTYPE 
  ORDER BY SUM(PROPDMG_COST) DESC
  LIMIT 10"
)

StormData_PplDamage_TOP10 <- sqldf::sqldf(
  "Select * FROM PplDMG_GroupedBy_EVTYPE LIMIT 10"
)

#plot data--------------------------------------------
#20180511 1454 DWB -- Need to work on this as I need to 
#ensure that the bar plot's y axis gets labeled properly
#also need to get a more accurate x label.
barplot(StormData_PplDamage_TOP10$`SUM(FatalAndInjuresCombined)`,
        main="Storm Injuries and Fatalities", horiz=TRUE
        )

###Exploratory statements
# ##find unique values of PROPDMGEXP and COST--------------------------
# PROPDMGEXP_COUNTuniqueElements_r2 <- sqldf::sqldf("SELECT PROPDMGEXP, COUNT(PROPDMGEXP), SUM(PROPDMG_COST)  
#                                                FROM StormData_w_ColumnforFullNumericCost_r2
#                                                GROUP BY PROPDMGEXP")
# 
# 
# 
# ##find unique values of CROPDMGEXP and COST--------------------------------
# CROPDMGEXP_COUNTuniqueElements_r2 <- sqldf::sqldf(
#   "SELECT CROPDMGEXP, COUNT(CROPDMGEXP), SUM(CROPDMG_COST) 
#   FROM StormData_w_ColumnforFullNumericCost_r2
#   GROUP BY CROPDMGEXP")

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
