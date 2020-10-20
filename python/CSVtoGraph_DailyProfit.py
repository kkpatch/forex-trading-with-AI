import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.gridspec as gridspec

# DailyProfit
profit_ADXandRSI_DailyProfit = pd.read_csv(r'C:\Users\kkeng\Desktop\backtest\ADX+RSI\1-1-2020 to 30-6-2020\profit_ADX+RSI_DailyProfit.csv',encoding="utf-16",sep='\t')
profit_ADXandPsar_DailyProfit = pd.read_csv(r'C:\Users\kkeng\Desktop\backtest\ADX+PSar\1-1-2020 to 30-6-2020\profit_ADX+PSar_DailyProfit.csv',encoding="utf-16",sep='\t')

profit_ADXandRSI_DailyProfit["Date"] = pd.to_datetime(profit_ADXandRSI_DailyProfit["Date"])
profit_ADXandRSI_DailyProfit["Date"] = profit_ADXandRSI_DailyProfit["Date"].dt.strftime('%m/%d')
profit_ADXandRSI_DailyProfit.set_index(['Date'],inplace=True)

profit_ADXandPsar_DailyProfit["Date"] = pd.to_datetime(profit_ADXandPsar_DailyProfit["Date"])
profit_ADXandPsar_DailyProfit["Date"] = profit_ADXandPsar_DailyProfit["Date"].dt.strftime('%m/%d')
profit_ADXandPsar_DailyProfit.set_index(['Date'],inplace=True)

# print(profit_ADXandPsar_DailyProfit)
# profit each day
df_outer = pd.concat([profit_ADXandPsar_DailyProfit,profit_ADXandRSI_DailyProfit ],axis=1, ignore_index=True)
df_outer = df_outer.sort_index()
print(df_outer)
df_outer.rename(columns={0:'ADX+PSar Profit'}, inplace=True)
df_outer.rename(columns={1:'ADX+RSI  Profit'}, inplace=True)
df_outer['ADX+PSar Profit'] = df_outer['ADX+PSar Profit'].fillna(0)
df_outer['ADX+RSI  Profit'] = df_outer['ADX+RSI  Profit'].fillna(0)


# fig, axes  = plt.subplots(nrows=1, ncols=2)
# df_outer.plot.bar(ax=axes[0],figsize=(10,3))
# plt.show()


#number of profit each day
count1 = sum(map(lambda x : x>0, df_outer['ADX+PSar Profit']))
count2 = sum(map(lambda x : x<0, df_outer['ADX+PSar Profit']))

data = [count1,count2]
print(count1,count2)
NumofProfitAndLoss_EachDay_ADXandPSar = pd.DataFrame(data,columns=[['ADX+PSar']],index=['Profit','loss'])
print(NumofProfitAndLoss_EachDay_ADXandPSar)

count3 = sum(map(lambda x : x>0, df_outer['ADX+RSI  Profit']))
count4 = sum(map(lambda x : x<0, df_outer['ADX+RSI  Profit']))

data2 = [count3,count4]
# print(count3,count4)
NumofProfitAndLoss_EachDay_ADXandRSI = pd.DataFrame(data2,columns=[['ADX+RSI']],index=['Profit','loss'])
print(NumofProfitAndLoss_EachDay_ADXandRSI)

# NumofProfitAndLoss_EachDay.plot.pie(subplots=True, figsize=(5, 5))
# plt.show()
####

##### order
plt.figure(figsize=(10, 10))
G = gridspec.GridSpec(2, 7)
axes_1 = plt.subplot(G[0, :])
df_outer.plot(kind='bar', ax=axes_1)
axes_2 = plt.subplot(G[1,:1])
NumofProfitAndLoss_EachDay_ADXandPSar.plot(kind='pie',subplots=True,ax=axes_2)
axes_3 = plt.subplot(G[1,2:])
NumofProfitAndLoss_EachDay_ADXandRSI.plot(kind='pie',subplots=True,ax=axes_3)


plt.show()