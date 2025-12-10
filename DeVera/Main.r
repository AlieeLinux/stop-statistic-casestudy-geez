# Load necessary libraries
library(forecast)
library(tseries)
library(readr)
library(ggplot2)

# ===============================
# 1. LOAD THE DATA
# ===============================

# Replace with your filename (CSV from PSA or data.gov.ph)
inflation_data <- read_csv("./cookie_dataset_numeric.csv")

# View first rows
head(inflation_data)


# ===============================
# 2. CREATE A TIME-SERIES OBJECT
# ===============================

# Assuming your CSV has a column named "Inflation_Rate"
# and one row per month (Jan 2015 – Dec 2025)
ts_inflation <- ts(inflation_data$Inflation_Rate,
                   start = c(2015, 1),
                   frequency = 12)   # monthly data

# Plot the raw inflation time-series
plot(ts_inflation,
     main = "Monthly Philippine Inflation Rate (2015–2025)",
     xlab = "Year", ylab = "Inflation Rate (%)")


# ===============================
# 3. CHECK FOR STATIONARITY
#    (ADF Test)
# ===============================

adf_result <- adf.test(ts_inflation)
print(adf_result)

# If p-value > 0.05 → non-stationary → ARIMA will apply differencing


# ===============================
# 4. DECOMPOSE THE TIME SERIES
# ===============================

decomp <- decompose(ts_inflation)
plot(decomp)


# ===============================
# 5. FIT ARIMA MODEL USING auto.arima()
# ===============================

arima_model <- auto.arima(ts_inflation,
                          seasonal = TRUE,
                          stepwise = FALSE,
                          approximation = FALSE)

summary(arima_model)


# ===============================
# 6. CHECK RESIDUALS
#    Residuals must look like white noise
# ===============================

checkresiduals(arima_model)


# ===============================
# 7. FORECAST THE NEXT 12 MONTHS
# ===============================

forecasted_values <- forecast(arima_model, h = 12)

# Plot forecast
forecast_plot <- autoplot(forecasted_values) +
  ggtitle("12-Month Forecast of Philippine Inflation Rate") +
  ylab("Inflation Rate (%)") +
  xlab("Year") +
  theme_minimal()

print(forecast_plot)

# Save the forecast plot
ggsave("inflation_forecast_plot.png",
       plot = forecast_plot,
       width = 10, height = 6, dpi = 300)


# ===============================
# 8. DIFFERENCED DATA PLOT (Optional)
# ===============================

ts_diff <- diff(ts_inflation)

png("inflation_diff_plot.png", width = 800, height = 400)
plot(ts_diff,
     main = "Differenced Inflation Rate (Stationarity Check)",
     xlab = "Year", ylab = "Differenced Inflation")
dev.off()


# ===============================
# 9. SAVE ORIGINAL TREND PLOT
# ===============================

png("inflation_trend.png", width = 800, height = 400)
plot(ts_inflation,
     main = "Philippine Inflation Trend (2015–2025)",
     xlab = "Year", ylab = "Inflation Rate (%)")
dev.off()

