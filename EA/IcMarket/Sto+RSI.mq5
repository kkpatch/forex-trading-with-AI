//+------------------------------------------------------------------+
//|                                                 ParabolicSAR.mq5 |
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

int rect_status = 0;
int newbar = 0;

int filehandle;         //profit each day
input string filename = "profit_ADX+PSar_DailyProfit.csv";      //FileName: 
string tmpDate = "";
string date = "";
int count = 1;
double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
double profit;
double tmpProfit = 0;
double eq ;

int filehandle2;        //profit each order
input string filename2 = "profit_ADX+PSar_EachOrder.csv";          //FileName2: 
double SL;
input int stoploss = 0;       //StopLoss: 
double TP;
input int takeprofit = 0;     //TakeProfit: 
double price;
datetime openTime;
datetime closeTime;

bool     OrderOpen = false;

int OnInit()
  {
//---
   ResetLastError();
   filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV);
   if(filehandle!=INVALID_HANDLE)
     {      
      Print("File opened correctly");
     }
   else Print("Error in opening file,",GetLastError());
   filehandle2=FileOpen(filename2,FILE_WRITE|FILE_CSV);
   if(filehandle2!=INVALID_HANDLE)
     {      
      Print("File opened correctly");
     }
   else Print("Error in opening file,",GetLastError());
   
   FileWrite(filehandle,"Date","Profit");
   FileWrite(filehandle2,"OpenTime","CloseTime","OpenPrice","ClosePrice","StopLoss","TakeProfit","OrderProfit","Info");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //if(profit-tmpProfit!=0){ 
   //   FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));     
   //}
   FileClose(filehandle);
   FileClose(filehandle2);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---  

   //--- Add Profit to CSV
   datetime timeForAddProfitToCSV = TimeCurrent(); 
   date = TimeToString(timeForAddProfitToCSV,TIME_DATE);
   if(tmpDate != date && tmpDate != ""){
      if(profit-tmpProfit!=0){    
         FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
         tmpProfit = profit;
         count++;
      }
   }
   else
   {
      eq = AccountInfoDouble(ACCOUNT_EQUITY);
      profit = eq - Balance;
   }
   //--- ... + tmpDate = date; in last line
   //---
   
   double timeCurrent = TimeCurrent();
   string time_Ontick = TimeToString(timeCurrent,TIME_SECONDS);  
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   string signal = "";
      
   MqlRates PriceArray[]; 
   ArraySetAsSeries(PriceArray,true);
   int Data = CopyRates(_Symbol,_Period,0,3,PriceArray);
   
   //--- RSI Setup
   double myRSIArray[];
   int myRSIDefinition = iRSI(_Symbol,_Period,14,PRICE_CLOSE);
   ArraySetAsSeries(myRSIArray,true);
   CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
   //---
   
   //--- Sto Setup
   double KArray[];
   double DArray[];   
   ArraySetAsSeries(KArray,true);
   ArraySetAsSeries(DArray,true);
   int StochasticDefinition = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,STO_LOWHIGH);
   CopyBuffer(StochasticDefinition,0,0,3,KArray);
   CopyBuffer(StochasticDefinition,1,0,3,DArray);
   //---
   
   
   
   DrawRect();
   int CandleNumber = Bars(_Symbol,_Period);
   
   if(StringSubstr(time_Ontick,0,5) >= "14:00" && StringSubstr(time_Ontick,0,5)<="19:59"){
       if(CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
         if(KArray[0]<DArray[0] && KArray[1]>DArray[1]){
            if(myRSIArray[0]<50){
               if(PositionsTotal()==0){
                  trade.Sell(0.1,NULL,Bid,Bid+75*_Point,Bid-100*_Point,NULL);
               }     
            }
         }
       }
   }
   tmpDate = date;
  }
//+------------------------------------------------------------------+

void DrawRect(){  //--- Add int rect_status = 0; before OnInit() function
   //--- Draw Object Setup
   int BarNumber = 60/_Period*6;
   
   datetime timeCurrent = TimeCurrent(); 
   string time = TimeToString(timeCurrent,TIME_SECONDS);   
   int HighestCandle,LowestCandle;   
   double High[],Low[];  
   ArraySetAsSeries(High,true);   
   ArraySetAsSeries(Low,true);  
   CopyHigh(_Symbol,_Period,0,BarNumber,High);   
   CopyLow(_Symbol,_Period,0,BarNumber,Low);   
   HighestCandle = ArrayMaximum(High,0,BarNumber);   
   LowestCandle = ArrayMinimum(Low,0,BarNumber);
   //--- 
   //--- Draw Object
   if(StringSubstr(time,0,5)>="19:00" && StringSubstr(time,0,5)<="19:59"){
      rect_status = 0;
   }
   if(StringSubstr(time,0,5)=="20:00" && rect_status == 0){
      MqlRates PriceInformation[];  
      ArraySetAsSeries(PriceInformation,true); 
      int data = CopyRates(_Symbol,_Period,0,Bars(_Symbol,_Period),PriceInformation);
      ObjectCreate
      (
         _Symbol,                               
         TimeCurrent(),                           
         OBJ_RECTANGLE,
         0,                                     //in main window
         PriceInformation[BarNumber].time,             //left border candle30
         PriceInformation[HighestCandle].high,  //upper border highest candle
         PriceInformation[0].time,              //right border candle0
         PriceInformation[LowestCandle].low     //lower border lowest candle         
      );
      ObjectSetInteger(0,TimeCurrent(),OBJPROP_COLOR,clrBlue);   
      ObjectSetInteger(0,TimeCurrent(),OBJPROP_FILL,clrBlue);   
      rect_status = 1;
      
      
      //--- Optional
      if(PositionsTotal() == 1){
         CloseAll();
         InfoEachOrder("Close in 00:00");
         OrderOpen = false;
      }
         
      newbar = 0;
      //---
      
      
   }
   //---
}

void CloseAll()
   {
      for(int i = PositionsTotal()-1;i>=0;i--)
      {
         PositionSelectByTicket(PositionGetTicket(i));
         trade.PositionClose(PositionGetTicket(i));
      }
   }
   
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
void InfoEachOrder(string info)
   {
   uint     TotalNumberOfDeals;
   ulong    TicketNumber = 0;
   double   openPrice = 0;
   double   stoplosss = 0;
   double   takeprofitt = 0;
   double   OrderProfit = 0;
   double   closePrice = 0;

   closeTime = TimeCurrent();
   HistorySelect(0,TimeCurrent());
   TotalNumberOfDeals = HistoryOrdersTotal();
   uint i = 0;
   
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   if(openTime != closeTime){
      for(uint i = 0;i<TotalNumberOfDeals-1;i++)
      {
         if((TicketNumber=HistoryOrderGetTicket(i))>0)
         {
            //openPrice = HistoryOrderGetDouble(TicketNumber,ORDER_PRICE_OPEN);
            stoplosss = HistoryOrderGetDouble(TicketNumber,ORDER_SL);
            takeprofitt = HistoryOrderGetDouble(TicketNumber,ORDER_TP);
            closePrice = HistoryDealGetDouble(TicketNumber,DEAL_PRICE); 
            //OrderProfit = HistoryDealGetDouble(TicketNumber,DEAL_PROFIT);
         }
      }
   }
   else{
      for(uint i = 0;i<TotalNumberOfDeals;i++)
      {
         if((TicketNumber=HistoryOrderGetTicket(i))>0)
         {
            //openPrice = HistoryOrderGetDouble(TicketNumber,ORDER_PRICE_OPEN);
            stoplosss = HistoryOrderGetDouble(TicketNumber,ORDER_SL);
            takeprofitt = HistoryOrderGetDouble(TicketNumber,ORDER_TP);
            closePrice = HistoryDealGetDouble(TicketNumber,DEAL_PRICE);
            if(stoplosss == 0){
               stoplosss = HistoryOrderGetDouble(HistoryOrderGetTicket(i-1),ORDER_SL);
               takeprofitt = HistoryOrderGetDouble(HistoryOrderGetTicket(i-1),ORDER_TP);
               closePrice = HistoryDealGetDouble(HistoryOrderGetTicket(i-1),DEAL_PRICE);
            } 
            //OrderProfit = HistoryDealGetDouble(TicketNumber,DEAL_PROFIT);
         }
      }
   }
   openPrice = Bid;
   OrderProfit = (openPrice - closePrice)*10;
      //openPrice = closePrice - (OrderProfit/10.0);
      if(info == "SL/TP"){
         if(OrderProfit > 0)  info = "TP";
         else info = "SL";
      }        
   FileWrite(filehandle2,openTime,closeTime,openPrice,closePrice,stoplosss,takeprofitt,OrderProfit,info);
      
 }