# Load Philippine Cities dataset (filter Cebu City → subset to 342 rows)
df <- read.csv("./ssss.csv")  
df_cebu <- df[df$City == "Cebu City", ][1:342, ]  # Cebu only, 342 rows
df <- df_cebu
df$Date_num <- as.numeric(as.Date(df$Date))
print(paste("Cebu City Dataset loaded:", nrow(df), "rows,", ncol(df), "columns"))

# Standard climate variables 
vars_to_plot <- c("Temperature", "Humidity", "Precipitation", "Wind_Speed",
                  "Pressure", "Cloud_Cover", "Visibility", "Feels_Like")

#  3-MONTH MOVING AVERAGE FILTER (Professor requirement)
for (var in vars_to_plot) {
  if(var %in% colnames(df)) {
    df[[paste0(var, "_MA3")]] <- rollmean(df[[var]], k = 3, fill = NA, align = "center")
  }
}
print("3-Month Moving Averages computed for Cebu City climate variables")

# Reshape for multi-variable visualization
df_long <- df %>%
  select(Date_num, ends_with("_MA3")) %>%
  pivot_longer(cols = -Date_num, names_to = "Variable", values_to = "Value")

# =====================================================
# PLOT 1: MULTI-VARIABLE 3-MONTH MA TRENDS (8+ Variables)
# =====================================================
p1 <- ggplot(df_long, aes(x = Date_num, y = Value, color = Variable)) +
  geom_line(size = 1, alpha = 0.😎 +
  labs(
    title = "Cebu City Climate Variables - 3-Month Moving Average Trends",
    subtitle = "PAGASA-Aligned Daily Weather Data (342 Observations)",
    x = "Date (Numeric)",
    y = "Climate Variable Value",
    color = "Variables"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", legend.title = element_blank())

print(p1)  # GRAPH 1: All 8 variables on one plot

# =====================================================
# PLOT 2: Temperature - Raw vs 3-Mo MA vs LOESS Smoothing
# =====================================================
if("Temperature" %in% colnames(df)) {
  df$Temp_LOESS <- lowess(df$Date_num, df$Temperature, f = 0.25, iter = 3)$y

  p2 <- ggplot(df, aes(x = Date_num)) +
    geom_line(aes(y = Temperature), alpha = 0.3, color = "gray50", size = 0.5) +
    geom_line(aes(y = Temperature_MA3), color = "red", linetype = "dashed", size = 1.2) +
    geom_line(aes(y = Temp_LOESS), color = "blue", size = 1.2) +
    labs(
      title = "Cebu City Temperature: Raw (Gray) vs 3-Mo MA (Red) vs LOESS (Blue)",
      x = "Date (Numeric)",
      y = "Temperature (°C)"
    ) +
    theme_minimal()
  print(p2)  # GRAPH 2: Smoothing comparison
}

print("Cebu City Analysis Complete - 2 Graphs Displayed")

