# -*- coding: utf-8 -*-
"""
Created on Wed Mar  3 00:33:44 2021

@author: kkeng
"""

#Import the libraries
import math
from tkinter import *
from tkinter import ttk ,filedialog #ttk -> themed tk
from threading import *

from datetime import date,datetime

import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from tensorflow import keras
from keras.models import Sequential
from keras.layers import Dense, LSTM
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import datetime

from sklearn.metrics import accuracy_score


root = Tk()

DateStart = date(2011,1,1)
DateEnd= date(2020,1,1)

def pathButton_click(e):
    global tv_path
    root.directory = filedialog.askdirectory()
    tv_path.set(root.directory)
    
    #model = keras.models.load_model(tv_path.get())
    
def predict_click():
    #print(cbo_day.get(),cbo_month.get(),cbo_year.get())    
    global DateStart
    global DateEnd
    mm_start = month_list.index(cbo_start_month.get())+1
    mm_end = month_list.index(cbo_start_month.get())+1
    DateStart = date(int(cbo_start_year.get()), mm_start, int(cbo_start_day.get()))
    DateEnd = date(int(cbo_end_year.get()), mm_end, int(cbo_end_day.get()))
    print(f'DateStart: {DateStart} \nDateEnd: {DateEnd}')
    
    #print(currency_list[currency_list.index(cbo_currency.get())])
    testModel()
    
currency_list = ['EURUSD','USDCHF','GBPUSD','USDJPY','AUDUSD','XAUUSD']
month_list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'] 


tv_path = StringVar()    
#root.directory = filedialog.askdirectory()
pathLabel = Label(root, text="Path: ")
pathLabel.grid(row=0,column=0, sticky=W)
endLabel = Label(root, textvariable=tv_path)
endLabel.grid(row=0,column=1,columnspan=6, sticky=W)
pathBtn = Button(root,text="Browse")
pathBtn.grid(row=0,column=8,padx=10,pady=10)
pathBtn.bind("<Button-1>",pathButton_click)

currencyLabel = Label(root, text="Currency: ")
currencyLabel.grid(row=1,column=0, sticky=W)
cbo_currency = ttk.Combobox(root,values=currency_list,width=7)
cbo_currency.current(0)
cbo_currency.grid(row=1,column=1)

# lstmLabel = Label(root, text="Date")
# lstmLabel.grid(row=2,column=0, sticky=W)

# startLabel = Label(root, text="Start")
# startLabel.grid(row=3,column=0, sticky=E)

# cbo_start_day = ttk.Combobox(root,values=list(range(1,32)),width=3,state="readonly")
# cbo_start_day.current(0)
# cbo_start_day.grid(row=3,column=1,sticky = E)

# cbo_start_month = ttk.Combobox(root,values=month_list,width=4,state="readonly")
# cbo_start_month.current(0)
# cbo_start_month.grid(row=3,column=2)

# cbo_start_year = ttk.Combobox(root,values=list(range(2000,2021)),width=4)
# cbo_start_year.current(10)
# cbo_start_year.grid(row=3,column=3)

# space = Label(root, text="",padx=10)
# space.grid(row=3,column=4)

# endLabel = Label(root, text="End")
# endLabel.grid(row=3,column=5, sticky=W)

# cbo_end_day = ttk.Combobox(root,values=list(range(1,32)),width=3,state="readonly")
# cbo_end_day.current(0)
# cbo_end_day.grid(row=3,column=6)

# cbo_end_month = ttk.Combobox(root,values=month_list,width=4,state="readonly")
# cbo_end_month.current(11)
# cbo_end_month.grid(row=3,column=7)

# cbo_end_year = ttk.Combobox(root,values=list(range(2000,2021)),width=4)
# cbo_end_year.current(20)
# cbo_end_year.grid(row=3,column=8,sticky = W )

# label = ["Testing Data Len (%):","Number of Candlestick:"]
# for i in range(len(label)):
#     Label(root, text=label[i]).grid(row=i+4,columnspan=2, sticky=W)
# tv_NumOfTestDataLen = IntVar()
# tv_NumOfCandlestick = IntVar()
# Entry(root,textvariable=tv_NumOfTestDataLen,width=2).grid(row=4,column=2)
# Entry(root,textvariable=tv_NumOfCandlestick,width=2).grid(row=5,column=2)
 

tv_NumOfCandlestick = IntVar()
Label(root, text="Number of Candlestick:").grid(row=2,columnspan=2, sticky=W)
Entry(root,textvariable=tv_NumOfCandlestick,width=2).grid(row=2,column=2)
                                                         
btn = Button(root,text="Predict",command=predict_click)
btn.grid(row=8,columnspan=9,padx=10,pady=10)


root.mainloop()


