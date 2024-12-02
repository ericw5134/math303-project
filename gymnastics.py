# Importing necessary libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as stats
import statsmodels.formula.api as ols
import seaborn as sns
from scipy.stats import kendalltau

# Data input
data = {
    "Order": [1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 
              1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8],
    "Rank": [4, 6, 8, 2, 1, 5, 7, 3, 8, 5, 4, 7, 2, 1, 6, 3, 2, 6, 7, 3, 8, 1, 5, 4,
             2, 4, 1, 8, 3, 7, 5, 6, 3, 6, 1, 2, 8, 7, 4, 5, 4, 2, 3, 5, 6, 8, 7, 1]
}
df = pd.DataFrame(data)

# Descriptive statistics
average_rank = df.groupby("Order")["Rank"].mean()
print("Average Rank by Order:\n", average_rank)

# Scatter plot
plt.figure(figsize=(10, 6))
plt.scatter(df["Order"], df["Rank"], alpha=0.7, label="Rank by Order")
plt.plot(average_rank.index, average_rank.values, color="red", linestyle="--", label="Average Rank")
plt.title("Order vs Rank")
plt.xlabel("Order (Performance Sequence)")
plt.ylabel("Rank (Final Position)")
plt.legend()
plt.grid()
plt.show()

# Correlation analysis (Spearman and Kendall's τ)
spearman_corr, spearman_p = stats.spearmanr(df["Order"], df["Rank"])
kendall_corr, kendall_p = stats.kendalltau(df["Order"], df["Rank"])
print(f"Spearman Correlation: {spearman_corr:.2f}, p-value: {spearman_p:.4f}")
print(f"Kendall's Tau Correlation: {kendall_corr:.2f}, p-value: {kendall_p:.4f}")





plt.figure(figsize=(10, 6))


sns.regplot(x="Order", y="Rank", data=df, scatter=False, color="red", line_kws={"label": "Spearman Trend Line"})

# add Spearman correlation
plt.text(1, max(df["Rank"])-1, f"Spearman Correlation: {spearman_corr:.2f}", fontsize=12, color="black")
plt.text(1, max(df["Rank"])-1.5, f"p-value: {spearman_p:.4f}", fontsize=12, color="black")

# plot
plt.title("Spearman Correlation: Order vs Rank", fontsize=16)
plt.xlabel("Order (Performance Sequence)", fontsize=12)
plt.ylabel("Rank (Final Position)", fontsize=12)
plt.xticks(range(1, 9))
plt.yticks(range(1, 9))
plt.legend()
plt.grid(alpha=0.5)
plt.show()



# Kendall's Tau 
kendall_corr, kendall_p = kendalltau(df["Order"], df["Rank"])

# plot Kendall's Tau 
plt.figure(figsize=(10, 6))


sns.regplot(x="Order", y="Rank", data=df, scatter=False, color="blue", line_kws={"label": "Kendall's Tau Trend Line"})


plt.text(1, max(df["Rank"]) - 1, f"Kendall's Tau Correlation: {kendall_corr:.2f}", fontsize=12, color="black")
plt.text(1, max(df["Rank"]) - 1.5, f"p-value: {kendall_p:.4f}", fontsize=12, color="black")

# plot
plt.title("Kendall's Tau Correlation: Order vs Rank", fontsize=16)
plt.xlabel("Order (Performance Sequence)", fontsize=12)
plt.ylabel("Rank (Final Position)", fontsize=12)
plt.xticks(range(1, 9))
plt.yticks(range(1, 9))
plt.legend()
plt.grid(alpha=0.5)

# 显示图表
plt.show()




# Simple linear regression
model = ols.ols("Rank ~ Order", data=df).fit()
print(model.summary())

# Regression fit plot
plt.figure(figsize=(10, 6))
plt.scatter(df["Order"], df["Rank"], alpha=0.7, label="Rank by Order")
plt.plot(df["Order"], model.predict(), color="red", label="Fitted Line")
plt.title("Linear Regression: Order vs Rank")
plt.xlabel("Order (Performance Sequence)")
plt.ylabel("Rank (Final Position)")
plt.legend()
plt.grid()
plt.show()
