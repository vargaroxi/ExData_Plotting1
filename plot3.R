library(data.table)
library(lubridate)

## LOAD THE DATA

if(!exists("hpcdata")) {
  con <- file("household_power_consumption.txt", "r")
  
  date1 <- "1/2/2007"; date2 <- "2/2/2007"
  result <- list()
  i <- 1
  
  header <- readLines(con, n=1)
  col_names <- strsplit(header, ";")[[1]]
  
  repeat {
    lines <- readLines(con, n = 100000)
    if (length(lines) == 0) break
    
    dt <- fread(text = lines, header = FALSE)
    setnames(dt, col_names)
    
    dt <- dt[Date %in% c(date1, date2)]
    if(nrow(dt) > 0){
      result[[i]] <- dt
      i <- i+1
    }
  }
  
  close(con)
  hpcdata <- rbindlist(result)
  hpcdata$DateTime <- as.POSIXct(paste(hpcdata$Date, hpcdata$Time), format=  "%d/%m/%Y %H:%M:%S" )
}


png(filename = "plot3.png")

with(hpcdata, {plot(DateTime, Sub_metering_1, type = "l", 
                  ylab = "Energy sub metering",
                  xlab = "", xaxt = "n")
  lines(DateTime, Sub_metering_2, type = "l", col = "red")
  lines(DateTime, Sub_metering_3, type = "l", col = "blue")})

legend("topright", lty = rep(1,3), 
       col = c("black", "red", "blue"), 
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

ticks <- seq(min(hpcdata$DateTime), max(hpcdata$DateTime) + days(1), by="days")
axis(1, at = ticks, labels = format(ticks, "%A"))

dev.off()
