#Create a check to si
#download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2","StormData.csv")

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

