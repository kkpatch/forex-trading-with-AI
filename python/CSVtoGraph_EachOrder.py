import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.gridspec as gridspec

#read CSV file
profit_ADXandRSI_EachOrder = pd.read_csv(r'C:\Users\kkeng\Desktop\backtest\ADX+RSI\1-1-2020 to 30-6-2020\profit_ADX+RSI_EachOrder.csv',encoding="utf-16",sep='\t')
profit_ADXandPsar_EachOrder = pd.read_csv(r'C:\Users\kkeng\Desktop\backtest\ADX+PSar\1-1-2020 to 30-6-2020\profit_ADX+PSar_EachOrder.csv',encoding="utf-16",sep='\t')

#set 'OpenTime' column to datetime, index
profit_ADXandRSI_EachOrder["OpenTime"] = pd.to_datetime(profit_ADXandRSI_EachOrder["OpenTime"])
profit_ADXandRSI_EachOrder["OpenTime"] = profit_ADXandRSI_EachOrder["OpenTime"].dt.strftime('%m/%d %H:%M:%S')
print(profit_ADXandRSI_EachOrder["OpenTime"])
profit_ADXandRSI_EachOrder.set_index(['OpenTime'],inplace=True)
profit_ADXandPsar_EachOrder["OpenTime"] = pd.to_datetime(profit_ADXandPsar_EachOrder["OpenTime"])
profit_ADXandPsar_EachOrder["OpenTime"] = profit_ADXandPsar_EachOrder["OpenTime"].dt.strftime('%m/%d %H:%M:%S')
profit_ADXandPsar_EachOrder.set_index(['OpenTime'],inplace=True)

#change column name 'OrderProfit' -> ... Profit
profit_ADXandRSI_EachOrder.rename(columns={'OrderProfit':'ADX+RSI Profit'}, inplace=True)
profit_ADXandPsar_EachOrder.rename(columns={'OrderProfit':'ADX+PSar Profit'}, inplace=True)

#concat profit column
df_outer = pd.concat([profit_ADXandRSI_EachOrder['ADX+RSI Profit'],profit_ADXandPsar_EachOrder['ADX+PSar Profit']],axis=1 )
df_outer = df_outer.sort_index()
df_outer['ADX+RSI Profit'] = df_outer['ADX+RSI Profit'].fillna(0)
df_outer['ADX+PSar Profit'] = df_outer['ADX+PSar Profit'].fillna(0)

print(df_outer)

# df_outer.plot(kind='bar')
# plt.show()

# #number of profit each day
# count1 = sum(map(lambda x : x>0, profit_ADXandRSI_EachOrder['OrderProfit']))
# count2 = sum(map(lambda x : x<0, profit_ADXandRSI_EachOrder['OrderProfit']))
# count3 = sum(map(lambda x : x>0, profit_ADXandPsar_EachOrder['OrderProfit']))
# count4 = sum(map(lambda x : x<0, profit_ADXandPsar_EachOrder['OrderProfit']))
#
# data = [[count1,count2],[count3,count4]]
# # print(count1,count2)
# NumofProfitAndLoss_EachOrder = pd.DataFrame(data,columns=['ADX+PSar','ADX+RSI'],index=['Profit','loss'])
# # print(NumofProfitAndLoss_EachDay)
# NumofProfitAndLoss_EachOrder.plot.pie(subplots=True, figsize=(5, 5))
# plt.show()
# ####

#count 'Info'

#change column name 'OrderProfit' -> ... Profit

#info for close order
profit_ADXandRSI_EachOrder.rename(columns={'Info':'ADX+RSI Info'}, inplace=True)
profit_ADXandPsar_EachOrder.rename(columns={'Info':'ADX+PSar Info'}, inplace=True)
#split each info and create info dataframe
count_ADXandRSI_info = profit_ADXandRSI_EachOrder['ADX+RSI Info'].value_counts()
count_ADXandPsar_info = profit_ADXandPsar_EachOrder['ADX+PSar Info'].value_counts()
count_ADXandRSI_info = count_ADXandRSI_info.to_frame()
count_ADXandPsar_info = count_ADXandPsar_info.to_frame()
df_outer2 = pd.concat([count_ADXandRSI_info,count_ADXandPsar_info],axis=1 )
print(df_outer2)

#print(count_ADXandRSI_info)
# df_outer2.plot.bar()

#number of profit each day
count1 = sum(map(lambda x : x>=0, profit_ADXandRSI_EachOrder['ADX+RSI Profit']))
count2 = sum(map(lambda x : x<0, profit_ADXandRSI_EachOrder['ADX+RSI Profit']))
count3 = sum(map(lambda x : x>=0, profit_ADXandPsar_EachOrder['ADX+PSar Profit']))
count4 = sum(map(lambda x : x<0, profit_ADXandPsar_EachOrder['ADX+PSar Profit']))
#print(np.count_nonzero(profit_ADXandPsar_EachOrder['ADX+PSar Profit'] > 0))
data2 = [[count1,count3],[count2,count4]]
# print(count3,count4)
NumofProfitAndLoss_EachDay = pd.DataFrame(data2,columns=['ADX+RSI','ADX+PSar'],index=['Profit','loss'])
print(NumofProfitAndLoss_EachDay)


#MaxProfit/Loss of each EA
data3 = [[df_outer['ADX+RSI Profit'].max(),df_outer['ADX+PSar Profit'].max()],[df_outer['ADX+RSI Profit'].min(),df_outer['ADX+PSar Profit'].min()]]
MaxProfitAndLoss = pd.DataFrame(data3,columns=['ADX+RSI','ADX+PSar'],index=['Max Profit','Max loss'])
print(MaxProfitAndLoss)

#create grid
plt.figure(figsize=(10, 15))
G = gridspec.GridSpec(5, 3)
axes_1 = plt.subplot(G[0:2, :])
df_outer.plot(kind='bar', ax=axes_1)
axes_2 = plt.subplot(G[3:5,0])
axes_2.set_title('Close order info')
df_outer2.plot(kind='bar', ax=axes_2, rot=0)
plt.xticks(rotation=30, horizontalalignment="center")
axes_3 = plt.subplot(G[3:5,1])
axes_3.set_title('Number of profit/loss')
NumofProfitAndLoss_EachDay.plot(kind='bar', ax=axes_3, rot=0)
axes_4 = plt.subplot(G[3:5,2])
axes_4.set_title('Max profit/loss')
MaxProfitAndLoss.plot(kind='bar', ax=axes_4, rot=0)
# count_ADXandRSI_info.plot.pie(ax=axes[0],y='Number',wedgeprops=dict(width=0.5),startangle=-40,legend=True)
# count_ADXandPsar_info.plot.pie(ax=axes[1],wedgeprops=dict(width=0.5),startangle=-40,labels= count_ADXandPsar_info,legend=True)

x_offset = -0.05
y_offset = 0.02
for p in axes_2.patches:
    b = p.get_bbox()
    val = "{:.0f}".format(b.y1 + b.y0)
    axes_2.annotate(val, ((b.x0 + b.x1)/2 + x_offset, b.y1 + y_offset))
for p in axes_3.patches:
    b = p.get_bbox()
    val = "{:.0f}".format(b.y1 + b.y0)
    axes_3.annotate(val, ((b.x0 + b.x1)/2 + x_offset, b.y1 + y_offset))
for p in axes_4.patches:
    b = p.get_bbox()
    val = "{:.2f}".format(b.y1 + b.y0)
    axes_4.annotate(val, ((b.x0 + b.x1)/2 + -0.1, b.y1 + y_offset))


plt.show()

