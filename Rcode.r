# Load necessary libraries
#but run  install.packages(c("forecast", "tseries", "readr", "ggplot2")) First
library(forecast)
library(tseries)
library(readr)
library(ggplot2)

# Load the data
data <- read_csv("realistic_retail_data.csv")

# Create a Time Series Object
# Assuming data is daily. frequency=7 for weekly seasonality, 365 for yearly.
ts_data <- ts(data$Daily_Sales_Revenue, frequency = 7)

# Check for Stationarity
# If p-value > 0.05, the data is non-stationary and needs differencing (d > 0)
print(adf.test(ts_data))

# Decompose the Time Series (Optional, to visualize Trend/Seasonality)
decomp <- decompose(ts_data)
plot(decomp)

# Fit ARIMA Model
# auto.arima will automatically determine the best (p,d,q) and seasonality
fit <- auto.arima(ts_data, seasonal = TRUE, stepwise = FALSE, approximation = FALSE)

# Print model summary
summary(fit)

# Check Residuals
# Ensure residuals look like white noise (no patterns left)
checkresiduals(fit)

# Forecast
# Forecast the next 30 days
forecast_values <- forecast(fit, h = 30)

# Plot Forecast
 forecast_plot <- autoplot(forecast_values) +
  ggtitle("ARIMA Forecast for Daily Sales Revenue") +
  ylab("Revenue") +
  xlab("Time") +
  theme_minimal()


# Display the plot
print(forecast_plot)

# Save the plot as an image (PNG)
ggsave("forecast_plot.png", plot = forecast_plot, width = 10, height = 6, dpi = 300)

# Seasonal diff
ts_diff <- diff(ts_data, differences = 1)

# Save Daily Sales Plot
png("daily_sales_revenue.png", width=800, height=400) # Open file
plot(ts_diff, main="Daily Sales Revenue Over Time", ylab="Revenue", xlab="Time")
dev.off() # Close and save file

# Save Scatter Plot (Marketing vs Sales)
png("marketing_vs_sales.png", width=800, height=600)
plot(data$Marketing_Spend, data$Daily_Sales_Revenue,
     main="Relationship between Marketing Spend and Sales",
     xlab="Marketing Spend", ylab="Sales Revenue", pch=19, col="blue")
# Add regression line
abline(lm(data$Daily_Sales_Revenue ~ data$Marketing_Spend), col="red")
dev.off()
