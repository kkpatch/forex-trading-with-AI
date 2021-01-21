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

input int RSI_Period = 14;                //RSI: Period
input int ATR_Period = 7;                //ATR: Period
input int EMA_Period = 200;               //EMA: Period
double input RiskReward = 2.5;            //RiskPerReward(1:...):  
double input checkPoint1Multiple = 1.5;   //checkPoint1Multiple:
double input checkPoint2Multiple = 1;     //checkPoint2Multiple:

double SL;
//input int stoploss = 1500;       //StopLoss: 
double TP;
//input int takeprofit = 400;     //TakeProfit: 
double checkPoint1;
double checkPoint2;
double checkPoint3;
double priceOpen;



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
   int movingAverageDefination = iMA (_Symbol,_Period,EMA_Period,0,MODE_SMA,PRICE_CLOSE);
   CopyBuffer(movingAverageDefination,0,0,3,myMovingAverageArray); //copy from movingAverageDefination to myMovingAverageArray
   
   double PriceArray[];
   int AverageTrueRangeDefinition = iATR(_Symbol,_Period,ATR_Period); 
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
   if(newbar == 0){
      if(myMovingAverageArray[0]<Bid){
         if(myRSIArray[1]<70 && myRSIArray[0]>70){
            if(PositionsTotal()==0){
               SL = PriceInfo[0].open-AverageTrueRangeValue;
               TP = Ask + ((Ask - SL) * RiskReward);
               checkPoint1 = Ask + ((Ask - SL) *checkPoint1Multiple);               
               checkPoint2 = Ask + ((Ask - SL) *checkPoint2Multiple);
               //checkPoint3 = Ask + ((Ask - SL) *0.5);
               priceOpen = Ask;
               
               trade.Buy(0.1,NULL,Ask,SL,TP,NULL);

               newbar=1;
            }    
         }
      }
   }
   
   if(PositionsTotal() == 1 && Ask > checkPoint1){
      CheckTrailingStop(TP,checkPoint2);
   }
   //else if(PositionsTotal() == 1 && Ask > checkPoint2){
   //   CheckTrailingStop(TP,checkPoint3);
   //}
//Comment(PriceInfo[0].open, "\n",
//        AverageTrueRangeValue
//        );   
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
void CheckTrailingStop(double TP,double priceOpen)
   {
      
      //Go through all positions
      for(int i = PositionsTotal()-1;i>=0;i--)
      {
         string symbol = PositionGetSymbol(i);
         
         if(_Symbol == symbol){
         
            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
            
            trade.PositionModify(PositionTicket,priceOpen,TP); //rise the current stop loss by 10 points
         }
      }
   }