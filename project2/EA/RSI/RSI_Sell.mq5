//+------------------------------------------------------------------+
//|                                                          Rsi.mq5 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>

CTrade trade; 

input int RSI_Period = 14;          //RSI: Period

double SL;
//input int stoploss = 1500;        //StopLoss: 
double TP;
//input int takeprofit = 400;       //TakeProfit: 
double input RiskReward = 2.5;       //Risk:Reward(1:...):     
double checkPoint;

int newbar = 0;

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   //--- RSI Setup
   double myRSIArray[];
   int myRSIDefinition = iRSI(_Symbol,_Period,RSI_Period,PRICE_CLOSE);
   ArraySetAsSeries(myRSIArray,true);
   CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
   //---
   
   double myMovingAverageArray[];
   int movingAverageDefination = iMA (_Symbol,_Period,200,0,MODE_SMA,PRICE_CLOSE);
   CopyBuffer(movingAverageDefination,0,0,3,myMovingAverageArray); //copy from movingAverageDefination to myMovingAverageArray
   
   double PriceArray[];
   int AverageTrueRangeDefinition = iATR(_Symbol,_Period,14); 
   ArraySetAsSeries(PriceArray,true);
   CopyBuffer(AverageTrueRangeDefinition,0,0,3,PriceArray);
   double AverageTrueRangeValue = NormalizeDouble(PriceArray[0],2);
   
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true); 
   int PriceData = CopyRates(_Symbol,_Period,0,3,PriceInfo);
   
   int CandleNumber = Bars(_Symbol,_Period); 
   if(CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
      newbar = 0;
   }
   
   datetime timeCurrent = TimeCurrent();
   string date = TimeToString(TimeGMT(),TIME_DATE); 
   string time = TimeToString(timeCurrent,TIME_SECONDS);
   
   if(newbar == 0){
      if(date != "2020.03.26" && StringSubstr(time,0,5) != "08:00")
       if(myMovingAverageArray[0]>Bid){
         if(myRSIArray[1]>30 && myRSIArray[0]<30){
            if(PositionsTotal()==0){
               SL = PriceInfo[0].high+AverageTrueRangeValue;
               TP = Bid - ((SL - Bid) *2);
               checkPoint = Bid - (SL - Bid);
               
               trade.Sell(0.1,NULL,Bid,SL,TP,NULL);
               newbar=1;
            }    
         }
      }
   }
   
   //if(PositionsTotal() == 1 && Bid < checkPoint){
   //   CheckTrailingStop(TP);
   //}

  }
//+------------------------------------------------------------------+
string CheckForNewCandle(int CandleNumber)
   {
      static int LastCandleNumber;
      
      string IsNewCandle = "no new candle";
      
      if(CandleNumber>LastCandleNumber)
      {
         IsNewCandle = "YES, A NEW CANDLE APPEARED!";
         LastCandleNumber = CandleNumber;
      }
      
      return IsNewCandle;
   }
void CloseAll()
   {
      for(int i = PositionsTotal()-1;i>=0;i--)
      {
         PositionSelectByTicket(PositionGetTicket(i));
         trade.PositionClose(PositionGetTicket(i));
      }
   }
 void CheckTrailingStop(double TP)
   {
      //double SL = NormalizeDouble(Bid+150*_Point,_Digits);
      
      //Go through all positions
      for(int i = PositionsTotal()-1;i>=0;i--){
         
         string symbol = PositionGetSymbol(i); //get the symbol of the position
         
         if(_Symbol == symbol) //if currency pair is equal
         
            //if we have a sell position
            if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL)
            {
               //get the ticket number
               ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
               
               //calculate the current stop loss
               double CurrentStopLoss = PositionGetDouble(POSITION_SL);
               
               double PositionPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
               
               trade.PositionModify(PositionTicket,PositionPriceOpen,TP);
         
            }
      }
   }