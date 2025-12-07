# Load libraries
library(ggplot2)
library(tidyr)
library(dplyr)
library(zoo)

# Load dataset and DEBUG first
df <- read.csv("philippine_cities_weather_2025.csv")
print("Original dataset columns:")
print(colnames(df))
print("First 5 rows:")
print(head(df))

# Find Cebu (case-insensitive) and check columns
cebu_rows <- grep("cebu", tolower(df$City), ignore.case = TRUE)
print(paste("Cebu rows found:", length(cebu_rows)))

if(length(cebu_rows) > 0) {
  df_cebu <- df[cebu_rows, ][1:342, ]
} else {
  print("No Cebu found - using first 342 rows")
  df_cebu <- df[1:342, ]
}
df <- df_cebu
print(paste("Final dataset:", nrow(df), "rows"))

# Handle Date column (flexible naming)
date_col <- grep("date|time|day", tolower(colnames(df)), value = TRUE)[1]
if(length(date_col) > 0) {
  df$Date <- df[[date_col]]
} else {
  df$Date <- seq(as.Date("2025-01-01"), by = "day", length.out = nrow(df))
}
df$Date_num <- as.numeric(as.Date(df$Date))
print(paste("Date column used:", date_col))

# Climate variables (flexible matching)
vars_to_plot <- c("Temperature", "Humidity", "Precipitation", "Wind", "Pressure", 
                  "Cloud", "Visibility", "Feels")
available_vars <- intersect(vars_to_plot, colnames(df))
print(paste("Variables found:", paste(available_vars, collapse = ", ")))

# 3-MONTH MOVING AVERAGE
for (var in available_vars) {
  df[[paste0(var, "_MA3")]] <- rollmean(df[[var]], k = 3, fill = NA, align = "center")
}

# Multi-variable plot
df_long <- df %>%
  select(Date_num, ends_with("_MA3")) %>%
  pivot_longer(cols = -Date_num, names_to = "Variable", values_to = "Value")

p1 <- ggplot(df_long, aes(x = Date_num, y = Value, color = Variable)) +
  geom_line(size = 1, alpha = 0.😎 +
  labs(title = "Cebu City Climate Variables - 3-Month Moving Average Trends",
       subtitle = paste("Daily Data (", nrow(df), "Observations)"),
       x = "Date", y = "Value") +
  theme_minimal() + theme(legend.position = "bottom")

print(p1)

# Temperature smoothing
temp_col <- grep("temp", tolower(colnames(df)), value = TRUE)[1]
if(length(temp_col) > 0) {
  df$Temp_LOESS <- lowess(df$Date_num, df[[temp_col]], f = 0.25, iter = 3)$y
  df$Temp_raw <- df[[temp_col]]
  df$Temp_MA3 <- df[[paste0(temp_col, "_MA3")]]
  
  p2 <- ggplot(df, aes(x = Date_num)) +
    geom_line(aes(y = Temp_raw), alpha = 0.3, color = "gray") +
    geom_line(aes(y = Temp_MA3), color = "red", linetype = "dashed", size = 1.2) +
    geom_line(aes(y = Temp_LOESS), color = "blue", size = 1.2) +
    labs(title = "Temperature: Raw vs 3-Mo MA vs LOESS", x = "Date", y = "Temperature") +
    theme_minimal()
  print(p2)
}

print("ANALYSIS COMPLETE - 1-2 Graphs Displayed")
