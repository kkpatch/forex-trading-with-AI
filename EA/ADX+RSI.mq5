//+------------------------------------------------------------------+
//|                                                          ADX.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

string signal = "";

CTrade trade;

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
   double PriceArray[];
   double UpperBandArray[];
   double LowerBandArray[];
   
   double myRSIArray[];
   
   datetime timeLocal = TimeLocal(); 
   string time = TimeToString(timeLocal,TIME_SECONDS);
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);   
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   int ADXDefinition = iADX(_Symbol,_Period,14);
   
   MqlRates PriceInformation[];
   
   int NumberOfCandles = Bars(_Symbol,_Period);
   string NumberOfCandlesText2 = IntegerToString(NumberOfCandles*2);
   
   ArraySetAsSeries(myRSIArray,true);
   ArraySetAsSeries(PriceInformation,true);
      
   int Data = CopyRates(_Symbol,_Period,0,3,PriceInformation);
   
   ArraySetAsSeries(PriceArray,true);
   ArraySetAsSeries(UpperBandArray,true);
   ArraySetAsSeries(LowerBandArray,true);
   
   CopyBuffer(ADXDefinition,0,0,3,PriceArray);
   CopyBuffer(ADXDefinition,1,0,3,UpperBandArray);
   CopyBuffer(ADXDefinition,2,0,3,LowerBandArray);
   
   double ADXValue0 = NormalizeDouble(PriceArray[0],2);
   double UpperBandValue0 = NormalizeDouble(UpperBandArray[0],2);
   double LowerBandValue0 = NormalizeDouble(LowerBandArray[0],2);
   double ADXValue1 = NormalizeDouble(PriceArray[1],2);
   double UpperBandValue1 = NormalizeDouble(UpperBandArray[1],2);
   double LowerBandValue1 = NormalizeDouble(LowerBandArray[1],2);
   string name = "open";
   
   int myRSIDefinition = iRSI(_Symbol,_Period,14,PRICE_CLOSE);
   CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
   double myRSIValue = NormalizeDouble(myRSIArray[0],2);
   if(StringSubstr(time,0,5)>="11:00" && StringSubstr(time,0,5)<="17:59"){
      if(PriceArray[0] > 25 && PriceArray[0] > PriceArray[1]){
         if(UpperBandArray[0] > LowerBandArray[0] && UpperBandArray[1] > LowerBandArray[1]){
            if(UpperBandArray[0] > UpperBandArray[1] && LowerBandArray[0] < LowerBandArray[1]){
               if(UpperBandArray[0] - LowerBandArray[0] > UpperBandArray[1] - LowerBandArray[1]){
                  if(myRSIArray[0] > myRSIArray[1] ){
                     signal = "buy";
                  }
               }
            }
         }
         if(UpperBandArray[0] < LowerBandArray[0] && UpperBandArray[1] < LowerBandArray[1]){
            if(UpperBandArray[0] < UpperBandArray[1] && LowerBandArray[0] > LowerBandArray[1]){
               if(LowerBandArray[0] - UpperBandArray[0] > LowerBandArray[1] - UpperBandArray[1]){
                  if(myRSIArray[0] < myRSIArray[1]){
                     signal = "sell";
                  }
               }
            }
         }
      }
         if(signal == "sell"){
            ObjectCreate(_Symbol,NumberOfCandlesText2,OBJ_ARROW,0,TimeCurrent(),Bid);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_ARROWCODE,159);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_WIDTH,3);
            signal = "";
         }
         if(signal == "buy"){
            ObjectCreate(_Symbol,NumberOfCandlesText2,OBJ_ARROW,0,TimeCurrent(),Ask);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_ARROWCODE,159);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_WIDTH,3);
            signal = "";
         }
   }
   Comment(
            "ADX[0]: ", ADXValue0, "\n",
            "ADX[1]: ", ADXValue1, "\n",
            "DI+[0]: ", UpperBandValue0, "\n",
            "DI+[1]: ", UpperBandValue1, "\n",
            "DI-[0]: ", LowerBandValue0, "\n",
            "DI-[1]: ", LowerBandValue1, "\n"
          );
   
   
   /*if(PriceArray[0] > 40 && PriceArray[1] < 40)
   {
      if(UpperBandValue1 > LowerBandValue1 && UpperBandValue0 < LowerBandValue0){
         //ObjectCreate(_Symbol,NumberOfCandlesText,OBJ_ARROW_SELL,0,TimeCurrent(),Bid);
         //type = "Trend SELL";
         //if(myRSIArray[1]<30){
            //sell
            ObjectCreate(_Symbol,NumberOfCandlesText2,OBJ_ARROW,0,TimeCurrent(),Bid);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_ARROWCODE,159);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_WIDTH,3);
         }
//         
      //}
      if(UpperBandValue1 < LowerBandValue1 && UpperBandValue0 > LowerBandValue0){
         //ObjectCreate(_Symbol,NumberOfCandlesText,OBJ_ARROW_SELL,0,TimeCurrent(),Bid);
         //type = "Trend SELL";
         //if(myRSIArray[1]>70 ){
            //buy
            ObjectCreate(_Symbol,NumberOfCandlesText2,OBJ_ARROW,0,TimeCurrent(),Ask);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_ARROWCODE,159);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_WIDTH,3);
         }
      //}
//      /*if(UpperBandValue1 < LowerBandValue1 && UpperBandValue0 > LowerBandValue0){
//         ObjectCreate(_Symbol,NumberOfCandlesText,OBJ_ARROW_BUY,0,TimeCurrent(),PriceInformation[1].low);
//         type = "Trend BUY";
//         trade.BuyStop(0.1,Ask+675*_Point,_Symbol,0,0,ORDER_TIME_GTC,0,"");
//      }*/
//   }
//   else
//   {
//      type = "SideWay";
//   }
   
  }
//+------------------------------------------------------------------+




      

      

      
