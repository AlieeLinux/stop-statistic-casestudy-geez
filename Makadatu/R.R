# ARIMAX MODEL IMPLEMENTATION IN R (Single Block)
# This code simulates time series data, fits an auto-SARIMAX model 
# (ARIMA with external regressors, XREG), performs diagnostics, and forecasts.
# ----------------------------------------------------------------------

# 1. SETUP AND DATA SIMULATION
# ----------------------------------------------------------------------

# Check and install 'forecast' package if necessary
if (!requireNamespace("forecast", quietly = TRUE)) {
      install.packages("forecast")
}
library(forecast)

# Set seed for reproducibility
set.seed(42)

# Parameters for simulation
n <- 120  # 10 years of monthly data
h <- 24   # 2-year forecast horizon
time_index <- 1:n

# Dependent Variable (Y): Simulating a series with trend, seasonality, and noise
seasonality <- 10 * sin(2 * pi * time_index / 12)
trend <- 0.5 * time_index
arma_noise <- arima.sim(model = list(ar = 0.7, ma = 0.3), n = n)

# External Regressor (X): Simulating a variable correlated with Y
marketing_spend <- rpois(n, lambda = 5) + (time_index / 50) + seasonality / 5

# Final time series Y = Trend + Seasonality + X effect + Noise
Y <- trend + seasonality + 2 * marketing_spend + arma_noise + rnorm(n, sd = 5)

# Convert Y and X to Time Series objects (Starting Jan 2016, Monthly freq=12)
Y_ts <- ts(Y, start = c(2016, 1), frequency = 12)
X_ts <- ts(marketing_spend, start = c(2016, 1), frequency = 12)


# 2. MODEL FITTING (SARIMAX)
# ----------------------------------------------------------------------

# Fit the SARIMAX model using auto.arima()
# The function automatically finds the best ARIMA(p,d,q)(P,D,Q)[12] order.
# xreg = X_ts includes the 'marketing_spend' as an external regressor.
# seasonal = TRUE ensures the Seasonal ARIMA component is searched.
sarimax_model <- auto.arima(
                              y = Y_ts,
                                xreg = X_ts,
                                seasonal = TRUE,
                                  stepwise = TRUE, # Use faster stepwise search for production
                                  approximation = FALSE
                                  )

# Print the model structure and coefficients
message("\n--- SARIMAX Model Summary ---")
print(sarimax_model)


# 3. DIAGNOSTICS
# ----------------------------------------------------------------------

# Plot residuals to check for white noise
message("\n--- Residual Check Plot (Should look like white noise) ---")
checkresiduals(sarimax_model)


# 4. FORECASTING
# ----------------------------------------------------------------------

# Prepare future values for the External Regressor (X)
# *CRITICAL STEP:* XREG forecasts must be supplied for the forecast horizon (h).
# For this example, we assume the future 'marketing_spend' will be constant 
# at the average of the last year (12 periods).
future_marketing_spend <- rep(mean(tail(marketing_spend, 12)), h)
future_X_ts <- ts(future_marketing_spend, start = end(Y_ts)[1] + floor((end(Y_ts)[2] + 1)/12), frequency = 12)


# Generate the forecast using the fitted SARIMAX model
sarimax_forecast <- forecast(
                               object = sarimax_model,
                                 xreg = future_X_ts, # Pass the future XREG values
                                 h = h
                                 )

# Plot the forecast
message("\n--- SARIMAX Forecast Plot (24 Months) ---")
plot(
       sarimax_forecast,
         main = "SARIMAX Forecast: Y with Marketing Spend (XREG)",
         xlab = "Year",
           ylab = "Value",
           include = 60 # Show the last 5 years of historical data
           )

# Print the final forecast values
message("\n--- Forecasted Values (Y) ---")
print(sarimax_forecast)
