import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta

# Set a seed for reproducibility
np.random.seed(42)

def generate_arima_ready_dataset(n_rows=250):
    # 1. Create the Time Index (Daily data for ~8 months)
    start_date = datetime(2023, 1, 1)
    dates = [start_date + timedelta(days=i) for i in range(n_rows)]

    # 2. Generate Underlying Components for "Realism"
    # Time variable t (0 to n)
    t = np.arange(n_rows)
    
    # Trend: Linear growth
    trend = 0.5 * t 
    
    # Seasonality: Sine wave to mimic weekly cycles (period = 7)
    # 2*pi*t / 7 ensures the cycle repeats every 7 days
    seasonality = 10 * np.sin(2 * np.pi * t / 7)
    
    # 3. Generate Correlated Features (Columns 1-4)
    
    # Marketing Spend (Correlated to Sales, plus random variance)
    # Modeled as a random walk with drift to look realistic
    marketing_spend = 1000 + np.cumsum(np.random.normal(0, 10, n_rows))
    
    # Website Traffic (Correlated to Marketing Spend)
    web_traffic = (marketing_spend * 2.5) + np.random.normal(0, 100, n_rows)
    
    # Temperature (Seasonal pattern - simpler sine wave)
    temperature = 20 + 10 * np.sin(2 * np.pi * t / 365) + np.random.normal(0, 2, n_rows)
    
    # 4. Generate the Target: Daily Sales (Column 5)
    # Sales = Base + Trend + Seasonality + (Marketing Influence) + Noise
    noise = np.random.normal(0, 5, n_rows)
    base_sales = 500
    
    # We add 10% of marketing spend to sales to create exogenous correlation
    sales = base_sales + trend + seasonality + (0.1 * marketing_spend) + noise

    # 5. Generate Categorical/State Data (Columns 6-8)
    
    # Day of Week (0=Monday, 6=Sunday)
    day_of_week = [d.weekday() for d in dates]
    
    # Is Weekend (Binary Flag)
    is_weekend = [1 if d.weekday() >= 5 else 0 for d in dates]
    
    # Inventory Levels (Mean reverting process)
    inventory = []
    current_inv = 1000
    for s in sales:
        current_inv = current_inv - (s * 0.1) + np.random.randint(0, 100) # Sold some, restocked some
        if current_inv < 0: current_inv = 0
        inventory.append(round(current_inv))

    # 6. Assemble DataFrame
    df = pd.DataFrame({
        'Date': dates,
        'Daily_Sales_Revenue': np.round(sales, 2),  # The Target for ARIMA
        'Marketing_Spend': np.round(marketing_spend, 2),
        'Website_Visitors': np.round(web_traffic).astype(int),
        'Avg_Temperature_C': np.round(temperature, 1),
        'Inventory_Units': inventory,
        'Day_of_Week': day_of_week,
        'Is_Weekend': is_weekend
    })
    
    return df

# Generate and view the data
df = generate_arima_ready_dataset()

# Display first few rows and basic stats
print("--- Dataset Head ---")
print(df.head())
print("\n--- Correlation Matrix (To prove realism) ---")
print(df[['Daily_Sales_Revenue', 'Marketing_Spend', 'Avg_Temperature_C']].corr())

# Optional: Save to CSV
df.to_csv('realistic_retail_data.csv', index=False)
