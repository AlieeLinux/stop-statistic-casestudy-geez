# ==============================================================================
# SARIMA Modeling for DATASETSRENZ.csv (With PNG Export)
# ==============================================================================

# 1. Install and Load Required Packages ----------------------------------------
if(!require(forecast)) install.packages("forecast")
if(!require(tseries)) install.packages("tseries")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(readr)) install.packages("readr")

library(forecast)
library(tseries)
library(ggplot2)
library(readr)

# 2. Load the Data -------------------------------------------------------------
data <- read_csv("DATASETSRENZ.csv")

# 3. Create a Time Series Object -----------------------------------------------
# Frequency = 12 (Monthly), Start = Jan 2006
ts_data <- ts(data$AvgDailyTraffic, 
              start = c(2006, 1), 
              frequency = 12)

# --- SAVE GRAPH 1: Raw Data Plot ---
png("01_Traffic_History.png", width = 800, height = 600)
plot(ts_data, 
     main = "Average Daily Traffic (2006 - Present)", 
     ylab = "Traffic Volume", 
     xlab = "Year",
     col = "blue")
dev.off() # This saves the file

# 4. Fit the SARIMA Model ------------------------------------------------------
sarima_model <- auto.arima(ts_data, seasonal = TRUE, stepwise = FALSE, approximation = FALSE)
print(summary(sarima_model))

# --- SAVE GRAPH 2: Model Residuals ---
png("02_Model_Residuals.png", width = 800, height = 600)
checkresiduals(sarima_model)
dev.off() # This saves the file

# 5. Forecast Future Values ----------------------------------------------------
forecast_horizon <- 24 # 2 years
my_forecast <- forecast(sarima_model, h = forecast_horizon)

# --- SAVE GRAPH 3: The Forecast ---
png("03_Final_Forecast.png", width = 1000, height = 600)
# We use print() here to ensure the ggplot renders inside the png device
print(
  autoplot(my_forecast) +
    ggtitle("SARIMA Forecast of Average Daily Traffic") +
    xlab("Year") +
    ylab("Avg Daily Traffic") +
    theme_minimal()
)
dev.off() # This saves the file

# 6. Save Forecast Numbers to CSV ----------------------------------------------
write.csv(my_forecast, "Traffic_Forecast_Results.csv")

message("All done! Check your folder for the PNG files.")
