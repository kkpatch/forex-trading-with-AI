//+------------------------------------------------------------------+
//|                                     Stochastic+BollingerBand.mq5 |
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

CTrade trade;

string tmpDate = "";
string date = "";
int count = 1;
double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
double profit;
double tmpProfit = 0;
double eq ;

int filehandle;

int OnInit()
  {
  //+------------------------------------------------------------------+
  //|  File Init                                                       |
  //+------------------------------------------------------------------+
   ResetLastError();
   filehandle=FileOpen("profit.csv",FILE_WRITE|FILE_CSV);
   if(filehandle!=INVALID_HANDLE)
     {      
      Print("File opened correctly");
     }
   else Print("Error in opening file,",GetLastError());

   return(INIT_SUCCEEDED);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
   FileClose(filehandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   datetime timeLocal = TimeLocal(); 
   date = TimeToString(timeLocal,TIME_DATE);
   if(tmpDate != date && tmpDate != ""){
      
      FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
      tmpProfit = profit;
      count++;
   }
   else
   {
      eq = AccountInfoDouble(ACCOUNT_EQUITY);
      profit = eq - Balance;
   }
   string time = TimeToString(timeLocal,TIME_SECONDS);
      
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   string signal = "";
   
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
   
   int StochasticDefinition = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
   int BollingerBandsDefinition = iBands(_Symbol,_Period,20,0,2,PRICE_CLOSE);
   
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
   

   if(StringSubstr(time,0,5)>="18:00" && StringSubstr(time,0,5)<="23:59"){
      if(Ask < myLowerBandValue)
         if(KValue0<20 && DValue0<20)
      //K value crossed D value from below
            if((KValue0>DValue0) && (KValue1<DValue1)) signal = "buy";
   
      if(Bid > myUpperBandValue)
         if(KValue0>80 && DValue0>80)
      //K value crossed D value from above
            if((KValue0<DValue0) && (KValue1>DValue1)) signal = "sell";
   
      if(PositionsTotal() < 1){
         if(signal == "sell") trade.Sell(0.1,NULL,Bid,(Bid+1500*_Point),(Bid-2500*_Point),NULL);
         if(signal == "buy" ) trade.Buy(0.1,NULL,Ask,(Ask-1500*_Point),(Ask+2500*_Point),NULL);
      }
      
   //if(PositionsTotal() == 1){
   //   PositionSelectByTicket(PositionGetTicket(0));
   //   if(PositionGetDouble(POSITION_PROFIT) > MaxProfit) MaxProfit = PositionGetDouble(POSITION_PROFIT);
   //}
   }
   Comment(HistoryOrdersTotal(),"\n",HistoryDealsTotal());
   tmpDate = date;
   
  }
void CloseAll()
   {
      for(int i = PositionsTotal()-1;i>=0;i--)
      {
         PositionSelectByTicket(PositionGetTicket(i));
         trade.PositionClose(PositionGetTicket(i));
      }
   }
void SaveProfit()
{
   
}
//+------------------------------------------------------------------+