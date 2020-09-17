////+------------------------------------------------------------------+
////|                                     Stochastic+BollingerBand.mq5 |
////|                        Copyright 2020, MetaQuotes Software Corp. |
////|                                             https://www.mql5.com |
////+------------------------------------------------------------------+
//#property copyright "Copyright 2020, MetaQuotes Software Corp."
//#property link      "https://www.mql5.com"
//#property version   "1.00"
////+------------------------------------------------------------------+
////| Expert initialization function                                   |
////+------------------------------------------------------------------+
//#include <Trade\Trade.mqh>
//
//CTrade trade;
//
//string tmpDate = "";
//string date = "";
//int count = 1;
//double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
//double profit;
//double tmpProfit = 0;
//double eq ;
//
//int filehandle;
//
//int OnInit()
//  {
//  //+------------------------------------------------------------------+
//  //|  File Init                                                       |
//  //+------------------------------------------------------------------+
//   ResetLastError();
//   filehandle=FileOpen("profit.csv",FILE_WRITE|FILE_CSV);
//   if(filehandle!=INVALID_HANDLE)
//     {      
//      Print("File opened correctly");
//     }
//   else Print("Error in opening file,",GetLastError());
//
//   return(INIT_SUCCEEDED);
//   return(INIT_SUCCEEDED);
//  }
////+------------------------------------------------------------------+
////| Expert deinitialization function                                 |
////+------------------------------------------------------------------+
//void OnDeinit(const int reason)
//  {
////---
//   FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
//   FileClose(filehandle);
//  }
////+------------------------------------------------------------------+
////| Expert tick function                                             |
////+------------------------------------------------------------------+
//void OnTick()
//  {
////---
//   datetime timeLocal = TimeLocal(); 
//   date = TimeToString(timeLocal,TIME_DATE);
//   if(tmpDate != date && tmpDate != ""){
//      
//      FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
//      tmpProfit = profit;
//      count++;
//   }
//   else
//   {
//      eq = AccountInfoDouble(ACCOUNT_EQUITY);
//      profit = eq - Balance;
//   }
//   string time = TimeToString(timeLocal,TIME_SECONDS);
//      
//   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
//   
//   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
//   
//   string signal = "";
//   
//   double KArray[];
//   double DArray[];
//   double MiddleBandArray[];
//   double UpperBandArray[];
//   double LowerBandArray[];
//   
//   ArraySetAsSeries(KArray,true);
//   ArraySetAsSeries(DArray,true);
//   ArraySetAsSeries(MiddleBandArray,true);
//   ArraySetAsSeries(UpperBandArray,true);
//   ArraySetAsSeries(LowerBandArray,true);
//   
//   int StochasticDefinition = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
//   int BollingerBandsDefinition = iBands(_Symbol,_Period,20,0,2,PRICE_CLOSE);
//   
//   CopyBuffer(StochasticDefinition,0,0,3,KArray); //buffer 0
//   CopyBuffer(StochasticDefinition,1,0,3,DArray); //buffer 1
//   CopyBuffer(BollingerBandsDefinition,0,0,3,MiddleBandArray);
//   CopyBuffer(BollingerBandsDefinition,1,0,3,UpperBandArray);
//   CopyBuffer(BollingerBandsDefinition,2,0,3,LowerBandArray);
//   
//   double KValue0 = KArray[0];
//   double DValue0 = DArray[0];
//   
//   double KValue1 = KArray[1];
//   double DValue1 = DArray[1];
//   
//   double myMiddleBandValue = MiddleBandArray[0];
//   double myUpperBandValue = UpperBandArray[0];
//   double myLowerBandValue = LowerBandArray[0];
//   
//
//   if(StringSubstr(time,0,5)>="18:00" && StringSubstr(time,0,5)<="23:59"){
//      if(Ask < myLowerBandValue)
//         if(KValue0<20 && DValue0<20)
//      //K value crossed D value from below
//            if((KValue0>DValue0) && (KValue1<DValue1)) signal = "buy";
//   
//      if(Bid > myUpperBandValue)
//         if(KValue0>80 && DValue0>80)
//      //K value crossed D value from above
//            if((KValue0<DValue0) && (KValue1>DValue1)) signal = "sell";
//   
//      if(PositionsTotal() < 1){
//         if(signal == "sell") trade.Sell(0.1,NULL,Bid,(Bid+1500*_Point),(Bid-2500*_Point),NULL);
//         if(signal == "buy" ) trade.Buy(0.1,NULL,Ask,(Ask-1500*_Point),(Ask+2500*_Point),NULL);
//      }
//      
//   //if(PositionsTotal() == 1){
//   //   PositionSelectByTicket(PositionGetTicket(0));
//   //   if(PositionGetDouble(POSITION_PROFIT) > MaxProfit) MaxProfit = PositionGetDouble(POSITION_PROFIT);
//   //}
//   }
//   Comment(HistoryOrdersTotal(),"\n",HistoryDealsTotal());
//   tmpDate = date;
//   
//  }
//void CloseAll()
//   {
//      for(int i = PositionsTotal()-1;i>=0;i--)
//      {
//         PositionSelectByTicket(PositionGetTicket(i));
//         trade.PositionClose(PositionGetTicket(i));
//      }
//   }
//void SaveProfit()
//{
//   
//}





//+------------------------------------------------------------------+
//|                                                     BBandSto.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include<Trade\Trade.mqh>

CTrade trade;

input int k_period = 5;                //Stochastic: K_Period
input int d_period = 3;                //Stochastic: D_Period
input int slowing = 5;                 //Stochastic: Slow

input int ma_period = 20;              //Bollinger Bands: Peirod
input int ma_shift = 0;                //Bollinger Bands: Shift
input double bband_deviation = 2.000;  //Bollinger Bands: Deviaation

input double volumn = 0.1;             //Order: Volumn(lot) 
input int StopLoss = 2500;             //Order: Stop Loss(Point)                
int Count = 0;
int bar1 = 0;

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
   
   string signal = "";
   
   datetime timeCurrent = TimeCurrent(); 
   string time = TimeToString(timeCurrent,TIME_SECONDS);
   
   int CandleNumber = Bars(_Symbol,_Period);
   string NewCandleAppeared = "";
   //NewCandleAppeared = CheckForNewCandle(CandleNumber);
   
   MqlRates PriceInformation[];
   ArraySetAsSeries(PriceInformation,true);
   int Data = CopyRates(_Symbol,_Period,0,3,PriceInformation);
   //Comment(PriceInformation[1].close);
   
   double KArray[];
   double DArray[];
   double MiddleBandArray[];
   double UpperBandArray[];
   double LowerBandArray[];
   
   ArraySetAsSeries(KArray,true);
   ArraySetAsSeries(DArray,true);
   ArraySetAsSeries(MiddleBandArray,true);
   ArraySetAsSeries(UpperBandArray,true);
   ArraySetAsSeries(LowerBandArray,true);
   
   int StochasticDefinition = iStochastic(_Symbol,_Period,k_period,d_period,slowing,MODE_SMA,STO_LOWHIGH);
   int BollingerBandsDefinition = iBands(_Symbol,_Period,ma_period,ma_shift,bband_deviation,PRICE_CLOSE);
   
   CopyBuffer(StochasticDefinition,0,0,3,KArray); //buffer 0
   CopyBuffer(StochasticDefinition,1,0,3,DArray); //buffer 1
   CopyBuffer(BollingerBandsDefinition,0,0,3,MiddleBandArray);
   CopyBuffer(BollingerBandsDefinition,1,0,3,UpperBandArray);
   CopyBuffer(BollingerBandsDefinition,2,0,3,LowerBandArray);
   
   double KValue0 = KArray[0];
   double DValue0 = DArray[0];
   
   double KValue1 = KArray[1];
   double DValue1 = DArray[1];
   
   double myMiddleBandValue = MiddleBandArray[0];
   double myUpperBandValue = UpperBandArray[0];
   double myLowerBandValue = LowerBandArray[0];
   
   double myRSIArray[];
   int myRSIDefinition = iRSI(_Symbol,_Period,14,PRICE_CLOSE);
   CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
   double myRSIValue = NormalizeDouble(myRSIArray[0],2);
   
   //Comment(PriceInformation[1].close);
   if(StringSubstr(time,0,5)>="11:00" && StringSubstr(time,0,5)<="17:59"){
   if(CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
      if(PriceInformation[2].close < LowerBandArray[2]){
      //Comment("Close: ", PriceInformation[1].close, "\n",
      //        "LowerBandArray: ", LowerBandArray[1], "\n", "Out LowerBand");
         if(KArray[2] < 20 && DArray[2] < 20){
            if(PriceInformation[1].close > LowerBandArray[1]){
               if(KArray[1] > DArray[1] && KArray[2] < DArray[2]){
               //ObjectCreate(_Symbol,TimeCurrent(),OBJ_ARROW,0,TimeCurrent(),PriceInformation[2].close);
               //ObjectSetInteger(0,TimeCurrent(),OBJPROP_ARROWCODE,159);
               //ObjectSetInteger(0,TimeCurrent(),OBJPROP_COLOR,clrRed);
               //ObjectSetInteger(0,TimeCurrent(),OBJPROP_WIDTH,3);
               if(myRSIArray[0] < 30)
                  if(PositionsTotal()==0)
                     trade.Buy(volumn,NULL,Ask,(Ask-StopLoss*_Point),0,NULL);
               }
            }
         }
      }
     if(PriceInformation[2].close > UpperBandArray[2]){
      //Comment("Close: ", PriceInformation[1].close, "\n",
      //        "LowerBandArray: ", LowerBandArray[1], "\n", "Out LowerBand");
         if(KArray[2] > 80 && DArray[2] > 80){
            if(PriceInformation[1].close < UpperBandArray[1]){
               if(KArray[1] < DArray[1] && KArray[2] > DArray[2]){
               //ObjectCreate(_Symbol,TimeCurrent(),OBJ_ARROW,0,TimeCurrent(),PriceInformation[2].close);
               //ObjectSetInteger(0,TimeCurrent(),OBJPROP_ARROWCODE,159);
               //ObjectSetInteger(0,TimeCurrent(),OBJPROP_COLOR,clrRed);
               //ObjectSetInteger(0,TimeCurrent(),OBJPROP_WIDTH,3);
               if(myRSIArray[0] > 70)
                  if(PositionsTotal()==0)
                     trade.Sell(volumn,NULL,Bid,(Bid+StopLoss*_Point),0,NULL);
                     //trade.SellStop(0.1,Bid-675*_Point,_Symbol,(Bid+2675*_Point),0,ORDER_TIME_GTC,0,"");
               }
            }
         }
      }
   }
   
   if(PositionsTotal() == 1){
      PositionSelectByTicket(PositionGetTicket(0));
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         if(Bid > MiddleBandArray[0]){
            CloseAll();
         }
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         if(Bid < MiddleBandArray[0]){
            CloseAll();
         }
      }
   }
   if(StringSubstr(time,0,5)>"18:00"){
      CloseAll();
   }
   //else{
   //   Comment("Close: ", PriceInformation[1].close, "\n",
   //           "LowerBandArray: ", LowerBandArray[1], "\n",
   //           "KValue: ", KValue1, "\n",
   //           "DValue: ", DValue1 
   //           );
   //}
   //Comment(bar1);
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

