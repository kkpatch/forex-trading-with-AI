from tkinter import *
from tkinter import ttk ,filedialog #ttk -> themed tk
from threading import *

from datetime import date,datetime

import math
import time
from threading import *

import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from tensorflow import keras
from keras.models import Sequential
from keras.layers import Dense, LSTM
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

import MetaTrader5 as mt5
import pytz

from sklearn.metrics import accuracy_score, confusion_matrix

def saveModelBtn_threading(): 
    # Call work function 
    t1=Thread(target=saveModelBtn_click) 
    t1.start()

def predictBtn_threading(): 
    # Call work function 
    t2=Thread(target=predictBtn_click) 
    t2.start()
    
def selectModelPathBtn_SaveModel_click(e):
    global ModelPath_SaveModel
    root.directory = filedialog.askdirectory()
    ModelPath_SaveModel.set(root.directory)
    
def selectConfigPathBtn_SaveModel_click(e):
    global ConfigPath_SaveModel
    root.directory = filedialog.askdirectory()
    ConfigPath_SaveModel.set(root.directory)
    
def saveModelBtn_click():
    global ModelPath_SaveModel
    global ConfigPath_SaveModel
    global model
    global tv_NumOfCandlestick
    global timeframe
    global timeframe_mt5
    
    
    #+------------------------------------------------------------------+
    #| SaveModel: Row 3                                                 |
    #+------------------------------------------------------------------+
    SaveModelStatus = StringVar()
    
    SaveModelStatus.set("Saving Model...")
    SaveModelStatusLabel_SaveModel = Label(labelframe2, text=SaveModelStatus.get())
    SaveModelStatusLabel_SaveModel.grid(row=3,column=0,columnspan=11)
    print(SaveModelStatus.get())
       
    model.save(ModelPath_SaveModel.get())
    

    SaveModelStatus.set("Saving Config...")
    SaveModelStatusLabel_SaveModel = Label(labelframe2, text=SaveModelStatus.get())
    SaveModelStatusLabel_SaveModel.grid(row=3,column=0,columnspan=11)
    print(SaveModelStatus.get())
    currency = currency_list[currency_list.index(cbo_currency.get())]
    tf = cbo_timeframe.get()
    df = pd.DataFrame(data={'Currency': [currency], 'CandleStick': [tv_NumOfCandlestick.get()], 'Timeframe': [tf]})
    df.to_csv(f'{ConfigPath_SaveModel.get()}/config.csv',index=False)
    
    SaveModelStatus.set("Save Completed")
    SaveModelStatusLabel_SaveModel = Label(labelframe2, text=SaveModelStatus.get())
    SaveModelStatusLabel_SaveModel.grid(row=3,column=0,columnspan=11)
    print(SaveModelStatus.get())

def selectModelPathBtn_Predict_click(e):
    global ModelPath_Predict
    root.directory = filedialog.askdirectory()
    ModelPath_Predict.set(root.directory)
    
def selectConfigPathBtn_Predict_click(e):
    global ConfigPath_Predict
    root.directory = filedialog.askopenfilename()
    ConfigPath_Predict.set(root.directory)

    
def predictBtn_click():
    global ModelPath_Predict
    global ConfigPath_Predict
    
    
    df = pd.read_csv(ConfigPath_Predict.get())
    cs = df["CandleStick"][0]
    print(df)
    
    # establish connection to MetaTrader 5 terminal
    if not mt5.initialize():
        print("initialize() failed, error code =",mt5.last_error())
        quit()
    if(df["Timeframe"][0] == 'H1'):
        rates = mt5.copy_rates_from_pos(df["Currency"][0], mt5.TIMEFRAME_H1, 1, cs+2)
    if(df["Timeframe"][0] == 'H4'):
        rates = mt5.copy_rates_from_pos(df["Currency"][0], mt5.TIMEFRAME_H4, 1, cs+2)
    if(df["Timeframe"][0] == 'D1'):
        rates = mt5.copy_rates_from_pos(df["Currency"][0], mt5.TIMEFRAME_D1, 1, cs+2)
    #print(rates)
    
    mt5.shutdown()
    
    # create DataFrame out of the obtained data
    rates_frame = pd.DataFrame(rates)
    # convert time in seconds into the datetime format
    rates_frame['time']=pd.to_datetime(rates_frame['time'], unit='s')
                           
    # display data
    print("\nDisplay dataframe with data")
    print(rates_frame)
    
    #Create a new dataframe with only the 'Close' column
    data = rates_frame.filter(['close'])

    #Converting the dataframe to a numpy array
    dataset = data.values

    #Scale the all of the data to be values between 0 and 1 
    scaler = MinMaxScaler(feature_range=(0, 1)) 
    scaled_data = scaler.fit_transform(dataset)
    
    #Split the data into x_train and y_train data sets
    x_test=[]
    
    x_test.append(scaled_data[1:cs+1,0])
    x_test.append(scaled_data[2:cs+2,0])
    
    # print(x_train)
    # print(y_train)
    
    #Convert x_train and y_train to numpy arrays
    x_test = np.array(x_test)
    
    #Reshape the data into the shape accepted by the LSTM
    x_test = np.reshape(x_test, (x_test.shape[0],x_test.shape[1],1))
    print(x_test)
    
    predictStatus = StringVar()
    #+------------------------------------------------------------------+
    #| Predict: Row 3                                                   |
    #+------------------------------------------------------------------+    
    predictStatus.set("Loading Model...")
    predictStatusLabel_Predict = Label(labelframe5, text=predictStatus.get())
    predictStatusLabel_Predict.grid(row=3,column=0,columnspan=10)
    print(predictStatus.get())
    
    model = keras.models.load_model(ModelPath_Predict.get())

    #+------------------------------------------------------------------+
    #| Predict: Row 3                                                   |
    #+------------------------------------------------------------------+    
    predictStatus.set("Predict Trend...")
    predictStatusLabel_Predict = Label(labelframe5, text=predictStatus.get())
    predictStatusLabel_Predict.grid(row=3,column=0,columnspan=10)
    print(predictStatus.get())

    #Getting the models predicted price values
    predictions = model.predict(x_test) 
    predictions = scaler.inverse_transform(predictions)#Undo scaling

    print(predictions[0])
    
    trend = 'UpTrend' if predictions[0] < predictions[1] else 'DownTrend'
    #+------------------------------------------------------------------+
    #| Predict: Row 3                                                   |
    #+------------------------------------------------------------------+    
    predictStatus.set("Predict Completed")
    predictStatusLabel_Predict = Label(labelframe5, text=predictStatus.get())
    predictStatusLabel_Predict.grid(row=3,column=0,columnspan=10)
    print(predictStatus.get())
    #+------------------------------------------------------------------+
    #| Predict: Row 4                                                   |
    #+------------------------------------------------------------------+
    PredictResult = Label(labelframe5, 
                          text=f'Close Price Predict of Pre Candle: {predictions[0]}\nClose Price Predict of Current Candle: {predictions[1]}\nPredicted Trend: {trend}',
                          width=42,justify=LEFT,anchor=W)
    PredictResult.grid(row=4,column=0,columnspan=10,sticky=W,pady=10)

    
def TrainBtn_click():
    #print(cbo_day.get(),cbo_month.get(),cbo_year.get())    
    global DateStart
    global DateEnd
    mm_start = month_list.index(cbo_start_month.get())+1
    mm_end = month_list.index(cbo_end_month.get())+1
    DateStart = date(int(cbo_start_year.get()), mm_start, int(cbo_start_day.get()))
    DateEnd = date(int(cbo_end_year.get()), mm_end, int(cbo_end_day.get()))
    
    trainModel()
    
def trainModel():
    global DateStart
    global DateEnd
    global tv_NumOfCandlestick
    global tv_NumOfTrainDataLen
    global tv_NumOfEpoch
    global tv_path
    global timeframe
    global timeframe_mt5
    global selectModelPath
    global model
    
    if not mt5.initialize():
        print("initialize() failed, error code =",mt5.last_error())
        quit()
        
    # set time zone to UTC
    timezone = pytz.timezone("Etc/UTC")
    # create 'datetime' object in UTC time zone to avoid the implementation of a local time zone offset
    utc_from = datetime(DateStart.year, DateStart.month, DateStart.day, tzinfo=timezone)
    utc_to = datetime(DateEnd.year, DateEnd.month, DateEnd.day, tzinfo=timezone)
    
    currency = currency_list[currency_list.index(cbo_currency.get())]
    tf = timeframe_mt5[timeframe_list.index(cbo_timeframe.get())]
    print(tf)
    if(tf == 16385):
        rates = mt5.copy_rates_range(currency, mt5.TIMEFRAME_H1, utc_from, utc_to)
    if(tf == 16388):
        rates = mt5.copy_rates_range(currency, mt5.TIMEFRAME_H4, utc_from, utc_to)
    if(tf == 16408):
        rates = mt5.copy_rates_range(currency, mt5.TIMEFRAME_D1, utc_from, utc_to)
    print(type(tf))
    # get 10 EURUSD H4 bars starting from 01.10.2020 in UTC time zone
    #rates = mt5.copy_rates_range(currency, mt5.TIMEFRAME_D1, utc_from, utc_to)
 
    # shut down connection to the MetaTrader 5 terminal
    mt5.shutdown()
    # display each element of obtained data in a new line
    print("Display obtained data 'as is'")
    # for rate in rates:
    #     print(rate)
    # create DataFrame out of the obtained data
    rates_frame = pd.DataFrame(rates)
    # convert time in seconds into the datetime format
    rates_frame['time']=pd.to_datetime(rates_frame['time'], unit='s')
    print("\nDisplay dataframe with data")
    #print(rates_frame)
    rates_frame = rates_frame[:-1]
    #rates_frame.drop([0])
    rates_frame.set_index("time",inplace=True)
    
    print(rates_frame)
    
    #Create a new dataframe with only the 'Close' column
    data = rates_frame.filter(['close'])
    
    #Converting the dataframe to a numpy array
    dataset = data.values
    
    #Get /Compute the number of rows to train the model on
    training_data_len = math.ceil( len(dataset) *(tv_NumOfTrainDataLen.get()/100)) 

    #Scale the all of the data to be values between 0 and 1 
    scaler = MinMaxScaler(feature_range=(0, 1)) 
    scaled_data = scaler.fit_transform(dataset)
    
    #Create the scaled training data set 
    train_data = scaled_data[0:training_data_len  , : ]
    #Split the data into x_train and y_train data sets
    x_train=[]
    y_train = []
    for i in range(tv_NumOfCandlestick.get(),len(train_data)):
        x_train.append(train_data[i-tv_NumOfCandlestick.get():i,0])
        y_train.append(train_data[i,0])
    #Convert x_train and y_train to numpy arrays
    x_train, y_train = np.array(x_train), np.array(y_train)
    #Reshape the data into the shape accepted by the LSTM
    x_train = np.reshape(x_train, (x_train.shape[0],x_train.shape[1],1))
    print(x_train)
    
    #Build the LSTM network model
    model = Sequential()
    model.add(LSTM(units=50, return_sequences=True,input_shape=(x_train.shape[1],1)))
    model.add(LSTM(units=50, return_sequences=False))
    model.add(Dense(units=25))
    model.add(Dense(units=1))

    #Compile the model
    model.compile(optimizer='adam', loss='mean_squared_error')
    
    #Train the model
    history_callback = model.fit(x_train, y_train, batch_size=1, epochs=tv_NumOfEpoch.get())
    #loss_history = history_callback.history['val_accuracy']
    print(history_callback.history.keys())
    
    #Test data set
    test_data = scaled_data[training_data_len - tv_NumOfCandlestick.get(): , : ]
    
    #Create the x_test and y_test data sets
    x_test = []
    y_test =  dataset[training_data_len : , : ] #Get all of the rows from index 1603 to the rest and all of the columns (in this case it's only column 'Close'), so 2003 - 1603 = 400 rows of data
    
    for i in range(tv_NumOfCandlestick.get(),len(test_data)):
        x_test.append(test_data[i-tv_NumOfCandlestick.get():i,0])
    
    
    # print(tv_NumOfCandlestick.get())
    # print(len(test_data))
    # print(x_test)
    # print(y_test)
        
    #Convert x_test to a numpy array 
    x_test = np.array(x_test)

    #Reshape the data into the shape accepted by the LSTM
    x_test = np.reshape(x_test, (x_test.shape[0],x_test.shape[1],1))
    
    #Getting the models predicted price values
    predictions = model.predict(x_test) 
    predictions = scaler.inverse_transform(predictions)#Undo scaling

    rmse=np.sqrt(np.mean(((predictions- y_test)**2)))
    print(rmse)
    print("-------------------------------------------------")
    
    #Plot/Create the data for the graph
    train = data[:training_data_len]
    valid = data[training_data_len:]
    valid['Predictions'] = predictions

    valid['ShiftClose'] = valid['close'].shift(periods=1)
    valid['ShiftPredict'] = valid['Predictions'].shift(periods=1)
    valid.drop(valid.index[0],inplace=True)
    #print(valid[['close', 'Predictions']])
    
    valid['RealTrend'] = valid.apply(lambda x: 'DownTrend' if x['ShiftClose']-x['close'] > 0 else 'UpTrend',axis=1 )
    valid['PredictTrend'] =  valid.apply(lambda x: 'DownTrend' if x['ShiftPredict']-x['Predictions'] > 0 else 'UpTrend',axis=1 )

    Accuracy = accuracy_score(valid['RealTrend'], valid['PredictTrend'])
    print(valid)
    print(accuracy_score(valid['RealTrend'], valid['PredictTrend']))
    print(accuracy_score(valid['RealTrend'], valid['PredictTrend'],normalize=False))
    
    #+------------------------------------------------------------------+
    #| Result: Row 0                                                    |
    #+------------------------------------------------------------------+
    RMSELabel = Label(labelframe4, text=f'RMSE: {rmse}',justify=LEFT)
    RMSELabel.grid(row=0,column=0, sticky=W)    
    tn, fp, fn, tp = confusion_matrix(valid['RealTrend'], valid['PredictTrend']).ravel()
    print(tn, fp, fn, tp)
    PredicToTrendLabel = Label(labelframe4, 
                               text=f'Change Predict Result To Trend\nAccuracy: {Accuracy}\nTP: {tp}     FP: {fp}\nFN: {fn}     TN: {tn}',anchor=W)
    PredicToTrendLabel.grid(row=0,column=1, sticky=W,padx = 10)
    
    #+------------------------------------------------------------------+
    #| SaveModel: Row 0                                                 |
    #+------------------------------------------------------------------+      
    PathLabel_SaveModel = Label(labelframe2, text="Model Path:")
    PathLabel_SaveModel.grid(row=0,column=0,pady=10, sticky=W)
    ModelPathLabel_SaveModel = Label(labelframe2, textvariable=ModelPath_SaveModel,width=45,anchor = W)
    ModelPathLabel_SaveModel.grid(row=0,column=1,columnspan=9)
    selectModelPathBtn_SaveModel = Button(labelframe2,text="Browse")
    selectModelPathBtn_SaveModel.grid(row=0,column=10, sticky=E)
    selectModelPathBtn_SaveModel.bind("<Button-1>",selectModelPathBtn_SaveModel_click)
    
    #+------------------------------------------------------------------+
    #| SaveModel: Row 1                                                 |
    #+------------------------------------------------------------------+   
    PathLabel2_SaveModel = Label(labelframe2, text="Config Path:")
    PathLabel2_SaveModel.grid(row=1,column=0,pady=10, sticky=W)
    ConfigPathLabel_SaveModel = Label(labelframe2, textvariable=ConfigPath_SaveModel,width=45,anchor = W)
    ConfigPathLabel_SaveModel.grid(row=1,column=1,columnspan=9)
    selectConfigPathBtn_SaveModel = Button(labelframe2,text="Browse")
    selectConfigPathBtn_SaveModel.grid(row=1,column=10, sticky=E)
    selectConfigPathBtn_SaveModel.bind("<Button-1>",selectConfigPathBtn_SaveModel_click)    
    
    #+------------------------------------------------------------------+
    #| SaveModel: Row 2                                                 |
    #+------------------------------------------------------------------+
    savePathBtn = Button(labelframe2,text="Save",command=saveModelBtn_threading)
    savePathBtn.grid(row=2,column=0,columnspan=12,pady=10)

    

    
    
    #Visualize the data
    figure = plt.figure(figsize=(8,4))
    #plt.title('Model')
    plt.xlabel('Date', fontsize=10)
    plt.ylabel('Close Price USD ($)', fontsize=10)
    plt.rc('xtick', labelsize=10) 
    plt.rc('ytick', labelsize=10)
    #plt.plot(train['Profit+Swap'])
    plt.plot(valid[['close', 'Predictions']])
    plt.legend(['Train', 'Val', 'Predictions'], loc='lower right')
    
    chart_type = FigureCanvasTkAgg(figure, labelframe3)
    chart_type.get_tk_widget().grid(row=0,column=0)
    
    plt.show()
    
month_list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']    
currency_list = ['EURUSD','USDCHF','GBPUSD','USDJPY','AUDUSD','XAUUSD']
timeframe_list =["H1","H4","D1"]
timeframe_mt5 = [mt5.TIMEFRAME_H1,mt5.TIMEFRAME_H4,mt5.TIMEFRAME_D1]

root = Tk()
root.title('Project2')
root.option_add("*Font","25")

labelframe = LabelFrame(root, text="Train & Test Model")
labelframe.grid(row=0,column=0,sticky=N+E+W+S)
labelframe2 = LabelFrame(root, text="Save Model")
labelframe2.grid(row=2,column=1,sticky=N+E+W+S)
labelframe3 = LabelFrame(root, text="Graph")
labelframe3.grid(row=0,column=1,sticky=N+E+W+S)
labelframe4 = LabelFrame(root, text="Result")
labelframe4.grid(row=1,column=1,sticky=N+E+W+S)
labelframe5 = LabelFrame(root, text="Predict")
labelframe5.grid(row=1,column=0,rowspan = 2, sticky=N+E+W+S)
 

#+------------------------------------------------------------------+
#| Train: Row 0                                                     |
#+------------------------------------------------------------------+
currencyLabel = Label(labelframe, text="Currency: ")
currencyLabel.grid(row=0,column=0,pady=10, sticky=W)
cbo_currency = ttk.Combobox(labelframe,values=currency_list,width=7)
cbo_currency.current(0)
cbo_currency.grid(row=0,column=1)

timeframeLabel = Label(labelframe, text="Timeframe: ")
timeframeLabel.grid(row=0,column=2,columnspan=3, sticky=E)
cbo_timeframe = ttk.Combobox(labelframe,values=timeframe_list,width=3)
cbo_timeframe.current(2)
cbo_timeframe.grid(row=0,column=5)

#+------------------------------------------------------------------+
#| Train: Row 1                                                     |
#+------------------------------------------------------------------+
lstmLabel = Label(labelframe, text="Date")
lstmLabel.grid(row=1,column=0, sticky=W)

#+------------------------------------------------------------------+
#| Train: Row 2                                                     |
#+------------------------------------------------------------------+
startLabel = Label(labelframe, text="Start")
startLabel.grid(row=2,column=0, sticky=W)

cbo_start_day = ttk.Combobox(labelframe,values=list(range(1,32)),width=3,state="readonly")
cbo_start_day.current(0)
cbo_start_day.grid(row=2,column=1, sticky=E)

cbo_start_month = ttk.Combobox(labelframe,values=month_list,width=4,state="readonly")
cbo_start_month.current(0)
cbo_start_month.grid(row=2,column=2)

cbo_start_year = ttk.Combobox(labelframe,values=list(range(2000,2021)),width=4)
cbo_start_year.current(10)
cbo_start_year.grid(row=2,column=3)

space = Label(labelframe, text="",padx=10)
space.grid(row=2,column=4)

endLabel = Label(labelframe, text="End")
endLabel.grid(row=2,column=5, sticky=W)

cbo_end_day = ttk.Combobox(labelframe,values=list(range(1,32)),width=3,state="readonly")
cbo_end_day.current(0)
cbo_end_day.grid(row=2,column=6)

cbo_end_month = ttk.Combobox(labelframe,values=month_list,width=4,state="readonly")
cbo_end_month.current(0)
cbo_end_month.grid(row=2,column=7)

cbo_end_year = ttk.Combobox(labelframe,values=list(range(2000,2022)),width=4)
cbo_end_year.current(21)
cbo_end_year.grid(row=2,column=8, sticky=W)

#+------------------------------------------------------------------+
#| Train: Row 3-4                                                   |
#+------------------------------------------------------------------+
label = ["Training Data Len (%):","Number of Candlestick:"]
for i in range(len(label)):
    Label(labelframe, text=label[i]).grid(row=i+3,columnspan=4, sticky=W)

tv_NumOfTrainDataLen = IntVar(value=80)
tv_NumOfCandlestick = IntVar(value=3)
Entry(labelframe,textvariable=tv_NumOfTrainDataLen,width=2).grid(row=3,column=2)
Entry(labelframe,textvariable=tv_NumOfCandlestick,width=2).grid(row=4,column=2)

#+------------------------------------------------------------------+
#| Train: Row 5-6                                                   |
#+------------------------------------------------------------------+
lstmLabel = Label(labelframe, text="LSTM")
lstmLabel.grid(row=5,column=0, sticky=W)

epochLabel = Label(labelframe, text="Epochs: ")
epochLabel.grid(row=6,column=0, sticky=W)

tv_NumOfEpoch = IntVar(value=1)
Entry(labelframe,width=3,textvariable=tv_NumOfEpoch).grid(row=6,column=1)

#+------------------------------------------------------------------+
#| Train: Row 8                                                     |
#+------------------------------------------------------------------+
btn = Button(labelframe,text="Train & Test",command=TrainBtn_click)
btn.grid(row=8,column=0,columnspan=12, sticky='',pady=40)

#+------------------------------------------------------------------+
#| Predict: Row 0                                                   |
#+------------------------------------------------------------------+    
ModelPath_Predict = StringVar()    
PathLabel_Predict = Label(labelframe5, text="Model Path:")
PathLabel_Predict.grid(row=0,column=0,pady=10, sticky=W)
ModelPathLabel_Predict = Label(labelframe5, textvariable=ModelPath_Predict,width=40,anchor = W)
ModelPathLabel_Predict.grid(row=0,column=1,columnspan=8)
selectModelPathBtn_Predict = Button(labelframe5,text="Browse")
selectModelPathBtn_Predict.grid(row=0,column=9, sticky=E)
selectModelPathBtn_Predict.bind("<Button-1>",selectModelPathBtn_Predict_click)

#+------------------------------------------------------------------+
#| Predict: Row 1                                                   |
#+------------------------------------------------------------------+    
ConfigPath_Predict = StringVar()    
PathLabel2_Predict = Label(labelframe5, text="Config Path:")
PathLabel2_Predict.grid(row=1,column=0,pady=10, sticky=W)
ConfigPathLabel_Predict = Label(labelframe5, textvariable=ConfigPath_Predict,width=40,anchor = W)
ConfigPathLabel_Predict.grid(row=1,column=1,columnspan=8)
selectConfigPathBtn_Predict = Button(labelframe5,text="Browse")
selectConfigPathBtn_Predict.grid(row=1,column=9, sticky=E)
selectConfigPathBtn_Predict.bind("<Button-1>",selectConfigPathBtn_Predict_click)

#+------------------------------------------------------------------+
#| Predict: Row 2                                                   |
#+------------------------------------------------------------------+
predictBtn = Button(labelframe5,text="Predict",command = predictBtn_threading)
predictBtn.grid(row=2,column=0,columnspan=12,pady=10)

#+------------------------------------------------------------------+
#| SaveModel: Variable                                              |
#+------------------------------------------------------------------+
ModelPath_SaveModel = StringVar()
ConfigPath_SaveModel = StringVar()  



root.mainloop()