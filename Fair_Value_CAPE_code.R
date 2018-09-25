## Fair Value CAPE Ratio - 
## -------------------------------------------------------------------------------------------------
## The "fair-value" CAPE ratio (i.e., the value that the actual CAPE ratio should eventually revert to) varies over time
## , dependent on the state of the economy, as measured by real interest rates, expected inflation, and measures of 
## financial #volatility.
## In our framework, lower real bond yields imply lower real earnings yields and a higher "fair-value" CAPE ratio, all
##  else equal. Real yields matter in our framework, not nominal yields per se as in the so-called Fed Model.
## -------------------------------------------------------------------------------------------------
## low real bond yields justify higher CAPE ratios today versus historical averages, yet they are very likely to prove
##  insufficient in generating average stock returns over the next decade.
##  ------------------------------------------------------------------------------------------------
##  hypothesis : lower real bond yields should imply lower earnings yields and thus higher equilibrium or "fair-value"
##   CAPE ratios, all else equal.
##   -----------------------------------------------------------------------------------------------
##   There are two steps to complete the project - 
##   Step 1: A VAR model with earnings yields, 1/CAPE
##   we do not forecast returns directly, but rather forecast the inverse of the CAPE ratio itself. 
##   Specifically, we estimate a vector autoregressive (VAR) model with twelve monthly lags
##          List of Variables includes  - (five variables in the VAR model in logarithmic form)
##            1. CAPE real earnings yield, or 1/CAPE
##            2. Real 10-year bond yields, or nominal Treasury yield less an estimated 10-year expected inflation
##               rate (see Appendix)
##            3. Year-over-year CPI inflation rate
##            4. Realized S&P500 price volatility, over trailing 12 months, and 
##            5. Realized volatility of changes in our real bond yield series, over trailing 12 months
##            
##     Note that we lag the "E" in the CAPE ratio by six months and the CPI data two months to account for real-time
##     data availability at any month end.
##     
##     The motivation of including these five VAR variables derives from Asness (2003), who finds that earnings
##     yield rises when bond yields rise, when stock volatility rises, and when bond market volatility falls.
##            
##   Step 2: Impute stock returns from the CAPE earnings yield forecasts - 
##      Rather than estimating equation (1), we calculate future returns directly based on their three components, 
##      thereby reducing estimation bias.
##      StockReturn = (%change in P/E Ratio) + (%change in earnings growth) + (Divivdend Yield)
##      %change in P/E Ratio is given by the VAR Modelling output.
##      
##      1. we assume that earnings growth is constant and equal to its long-term average, 
##      2. while the dividend yield is the product of the earnings yield times the payout ratio
##      
##      As a result, only earnings yield (1/CAPE) has to be forecasted via regression in order to predict stock 
##      returns at a given horizon.
##      
##      At any point in time, the VAR can forecast out for ten years the CAPE earnings yield.
##      
##      And, via step 2, derive an expected future 10-year-ahead return on U.S. stocks.
##   
##   Note : The motivation of including these five VAR variables derives from Asness (2003), who finds that earnings
##   yield rises when bond yields rise, when stock volatility rises, and when bond market volatility falls. Arnott, 
##   Chaves, and Chow (2015) find that both real yields and inflation expectations are positively related to the 
##   earnings yield on U.S. stocks. It remains unclear why inflation expectations - a component of nominal bond 
##   yields - should influence earnings yields since stocks are a long-run inflation hedge (Illmanen, 2011, ch. 8). 
##   Importantly, this so-called "inflation illusion" effect is weaker in our VAR model than the effect from real 
##   bond yields given the joint dynamics of our VAR model.
##   
##   Note : The benefit of our "sum of parts" approach is that it should mitigate so-called Stambaugh (1999) bias 
##   that can plague predictive regressions with persistent regressors like CAPE ratios that involve overlapping 
##   data (Nelson and Kim, 1993). In results unreported here but available upon request, including changes in 
##   earnings growth in the VAR does not materially alter the results. Consistent with Cochrane (2008), changes in 
##   earnings yields help predict future stock returns, not earnings growth.
##   
## -------------------------------------------------------------------------------------------------
rootData <- "C:/Users/Rahul Kumar/Desktop/UPSC/Economics/Fair Value CAPE Ration - US Stock Return Forecast/data"
#install.packages("quantmod")
library(quantmod)

## we use a separate environment which we call sp500 to store the downloaded data.
sp500 <- new.env()
getSymbols("^GSPC", env = sp500, src = "yahoo", from = "1950-01-01")
getSymbols("SP500", env = sp500, src = "FRED", from = "1950-01-01")
##--------------------------------------------------------------------------------------------------
## There are several possibilities, to load the variable GSPC from the environment sp500 to a variable in
## the global environment (also known as the workspace), e.g., via
GSPC <- sp500$GSPC
GSPC1 <- get("GSPC", envir = sp500)
GSPC2 <- with(sp500, GSPC)
GSPC3 <- sp500[["GSPC"]]
rm(GSPC1, GSPC2, GSPC3)
##--------------------------------------------------------------------------------------------------
## FRED CPI Data - Non Seasonally Adjusted
getSymbols("CPIAUCNS", env = sp500, src = "FRED", from = "1950-01-01")
##--------------------------------------------------------------------------------------------------
## Writing the data in csv format - 

sp500data <- data.frame(index(sp500$GSPC), sp500$GSPC)
colnames(sp500data)[1] <- "Date"

USCPI <- data.frame(index(sp500$CPIAUCSL), sp500$CPIAUCSL)
colnames(USCPI)[1] <- "Date"


write.csv(sp500data, paste(rootData,"/sp500_index_yahoo.csv", sep = ""), row.names = FALSE)
write.csv(USCPI, paste(rootData,"/USCPI_NSA_Fred.csv", sep = ""), row.names = FALSE)
##--------------------------------------------------------------------------------------------------
## the command tryCatch we handle unusual conditions, including errors and warnings.
## if the data from a company are not available from yahoo finance, the message "Symbol ...
## not downloadable!" is given. (For simplicity, we only download the symbols starting with 'A'.)
nasdaq100 <- read.csv(paste(rootData, "/nasdaq100list.csv", sep = ""))
names(nasdaq100)

 nasdaq <- new.env()
 for (i in nasdaq100$Symbol) { #for (i in nasdaq100$Symbol[startsWith(as.character(nasdaq100$Symbol), "A")]) {
   cat("Downloading time series for symbol '", i, "' ...\n", sep = "")
   status <- tryCatch(getSymbols(i, env = nasdaq, src = "yahoo", from = as.Date("2000-01-01")), error = identity)
   if (inherits( status, "error"))
     cat("Symbol '", i, "' not downloadable!\n", sep = "")
 }
 
 with(nasdaq,addOBV(AAPL))
 
##--------------------------------------------------------------------------------------------------
##
