#Import the libraries
import math
import pandas_datareader as web
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from keras.models import Sequential
from keras.layers import Dense, LSTM
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
plt.style.use('fivethirtyeight')

from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()
import MetaTrader5 as mt5


# connect to MetaTrader 5
if not mt5.initialize():
    print("initialize() failed")
    mt5.shutdown()

# request connection status and parameters
print(mt5.terminal_info())
# get data on MetaTrader 5 version
print(mt5.version())

# get bars from different symbols in a number of ways
xauusd_rates2 = mt5.copy_rates_from_pos("EURUSD", mt5.TIMEFRAME_M15, 0, 2048)

getClose = []
print('xauusd_rates2(', len(xauusd_rates2), ')')
for val in xauusd_rates2[:2048]:
    #print(val['close'])
    getClose.append(val['close'])
getClose = np.array(getClose)
print(type(getClose))
dataset = np.reshape(getClose, (-1, 1))

training_data_len = math.ceil( len(dataset) *.8)

print(getClose)
print(dataset)

#Scale the all of the data to be values between 0 and 1
scaler = MinMaxScaler(feature_range=(0, 1))
scaled_data = scaler.fit_transform(dataset)

#Create the scaled training data set
train_data = scaled_data[0:training_data_len  , : ]
#Split the data into x_train and y_train data sets
x_train=[]
y_train = []
for i in range(60,len(train_data)):
    x_train.append(train_data[i-60:i,0])
    y_train.append(train_data[i,0])

#Convert x_train and y_train to numpy arrays
x_train, y_train = np.array(x_train), np.array(y_train)
print('x_train shape: ',x_train.shape)
print('y_train shape: ',y_train.shape)
print('x_train before reshape: ',x_train)
print('y_train before reshape: ',y_train)

#Reshape the data into the shape accepted by the LSTM
x_train = np.reshape(x_train, (x_train.shape[0],x_train.shape[1],1))
print('x_train after reshape: ',x_train)

#Build the LSTM network model
model = Sequential()
model.add(LSTM(units=50, return_sequences=True,input_shape=(x_train.shape[1],1)))
model.add(LSTM(units=50, return_sequences=False))
model.add(Dense(units=25))
model.add(Dense(units=1))

#Compile the model
model.compile(optimizer='adam', loss='mean_squared_error')

#Train the model
model.fit(x_train, y_train, batch_size=1, epochs=10)

#Test data set
test_data = scaled_data[training_data_len - 60: , : ]
#Create the x_test and y_test data sets
x_test = []
y_test =  dataset[training_data_len : , : ] #Get all of the rows from index 1603 to the rest and all of the columns (in this case it's only column 'Close'), so 2003 - 1603 = 400 rows of data
for i in range(60,len(test_data)):
    x_test.append(test_data[i-60:i,0])

#Convert x_test to a numpy array
x_test = np.array(x_test)

#Reshape the data into the shape accepted by the LSTM
x_test = np.reshape(x_test, (x_test.shape[0],x_test.shape[1],1))

#Getting the models predicted price values
predictions = model.predict(x_test)
predictions = scaler.inverse_transform(predictions)#Undo scaling

print('x_test shape: ',x_test.shape)
print('y_test shape: ',y_test.shape)
print('predict shape: ',predictions.shape)

#Calculate/Get the value of RMSE
rmse=np.sqrt(np.mean(((predictions- y_test)**2)))
print(rmse)
x1 = []
x2 = []
for i in range(1639,2048):
    x1.append(i)
for i in range(2048):
    x2.append(i)
# print(predictions)
# print(type(predictions))

plt.title('Model')
plt.plot(x2,getClose)
plt.plot(x1,predictions)
plt.xlabel('Candlestick', fontsize=18)
plt.ylabel('Close Price ', fontsize=18)
plt.legend(['Close Prices','Predictions'], loc='lower right')
plt.show()
# #Plot/Create the data for the graph
# train = getClose[:training_data_len]
# valid = getClose[training_data_len:]
# valid['Predictions'] = predictions
#
# #Visualize the data
# plt.figure(figsize=(16,8))
# plt.title('Model')
# plt.xlabel('Date', fontsize=18)
# plt.ylabel('Close Price USD ($)', fontsize=18)
# plt.plot(train['close'])
# plt.plot(valid[['close', 'Predictions']])
# plt.legend(['Train', 'Val', 'Predictions'], loc='lower right')
# plt.show()