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

#TODO: Delete exploratory l8r
#start exploring data

ex1_GetIntialPplDMG <- sqldf::sqldf("SELECT STATE, EVTYPE, 
SUM(FATALITIES), SUM(INJURIES), (SUM(FATALITIES) + SUM(INJURIES)) AS FatalAndInjuresCombined
                                    FROM StormData
                                    GROUP BY STATE, EVTYPE
                                    ORDER BY STATE, EVTYPE")
