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


string tmpDate = "";
string date = "";
int count = 1;
double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
double profit;
double tmpProfit = 0;
double eq ;

int filehandle;         //profit each day
int filehandle2;        //profit each order
int filehandle3; 

input group           "File Name" 
input string filename  = "profit_ADX+PSar_DailyProfit.csv";                    //FileName: 
input string filename2 = "profit_ADX+PSar_EachOrder.csv";                      //FileName2: 
input string filename3 = "profit_ADX+PSar_DailyProfit+NotOpenOrder.csv";       //FileName3:

input group           "Average Directional Movement Index" 
input int ADX_Period = 14;                //ADX: Period

input group           "Parabolic SAR" 
input double PSar_Step = 0.03;            //PSar: Step
input double PSar_Maximum = 0.2;          //PSar: Maximum

input group           "Moving Average"
input int MA_Period = 200;                //MA: Period
input int MA_Shift = 0;                   //MA: Shift
input ENUM_MA_METHOD MA_Method=MODE_SMA;  //MA: Method



input group           "Other"
double SL;
double TP;
input int stoploss = 200;                 //StopLoss: 
input int takeprofit = 400;               //TakeProfit:
input double lotSize = 0.1;              //LotSize: 

double price;
datetime openTime;
datetime closeTime;
double TickMax = 0;
double TickMin = 0;

double openPrice;
double checkPoint;
double checkPoint2;
string CurrentType = "";

bool     OrderOpen = false;
bool     CalculateTick = false;

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
   filehandle3=FileOpen(filename3,FILE_WRITE|FILE_CSV);
   if(filehandle3!=INVALID_HANDLE)
     {      
      Print("File opened correctly");
     }
   else Print("Error in opening file,",GetLastError());
   
   FileWrite(filehandle,"Date","Profit");
   FileWrite(filehandle2,"OpenTime","CloseTime","OpenPrice","ClosePrice","StopLoss","TakeProfit","OrderProfit","TickMax","TickMin","Info");
   FileWrite(filehandle3,"Date","Profit");
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
   FileClose(filehandle3);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---  
   
   double timeCurrent = TimeCurrent();
   string time_Ontick = TimeToString(timeCurrent,TIME_SECONDS);  
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   string signal = "";
   
   MqlRates PriceArray[]; 
   ArraySetAsSeries(PriceArray,true);
   int Data = CopyRates(_Symbol,_Period,0,3,PriceArray);
   
   //--- PSar Setup   
   double mySARArray[];
   int SARDefinition = iSAR(_Symbol,_Period,PSar_Step, PSar_Maximum);
   ArraySetAsSeries(mySARArray,true);
   CopyBuffer(SARDefinition,0,0,3,mySARArray);
   //---
   
   //--- ADX Setup 
   double ADX_PriceArray[];
   double ADX_UpperBandArray[];
   double ADX_LowerBandArray[];
   int ADXDefinition = iADX(_Symbol,_Period,ADX_Period);
   ArraySetAsSeries(ADX_PriceArray,true);
   ArraySetAsSeries(ADX_UpperBandArray,true);
   ArraySetAsSeries(ADX_LowerBandArray,true);  
   CopyBuffer(ADXDefinition,0,0,3,ADX_PriceArray);
   CopyBuffer(ADXDefinition,1,0,3,ADX_UpperBandArray);
   CopyBuffer(ADXDefinition,2,0,3,ADX_LowerBandArray);
   //---
   
   double myMovingAverageArray[];
   int movingAverageDefination = iMA (_Symbol,_Period,MA_Period,MA_Shift,MA_Method,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray,true);
   CopyBuffer(movingAverageDefination,0,0,3,myMovingAverageArray); //copy from movingAverageDefination to myMovingAverageArray
   
   int CandleNumber = Bars(_Symbol,_Period);

      if(ADX_UpperBandArray[0] > ADX_LowerBandArray[0] && ADX_UpperBandArray[1] < ADX_LowerBandArray[1]){
         if(ADX_PriceArray[0] > 25){
            if(mySARArray[0] < PriceArray[0].low){
               if(myMovingAverageArray[0] < Ask){
                  if(PositionsTotal()<1){
                     if(stoploss == 0) SL = stoploss;
                     if(stoploss != 0) SL = (Ask-stoploss*_Point);
                     if(takeprofit == 0) TP = stoploss;
                     if(takeprofit != 0) TP = (Ask+takeprofit*_Point);
                     
                     checkPoint = Ask + ((takeprofit*_Point)*0.6);
                     CurrentType = "Buy";
                     openPrice = Ask;
                     
                     trade.Buy(lotSize,NULL,Ask,SL,TP,NULL);
                     
                  }
               }
            }
         }
      }
         
      else if(ADX_UpperBandArray[0] < ADX_LowerBandArray[0] && ADX_UpperBandArray[1] > ADX_LowerBandArray[1]){
         if(ADX_PriceArray[0] > 25){
            if(mySARArray[0] > PriceArray[0].high){
               if(myMovingAverageArray[0] > Bid){
                  if(PositionsTotal()<1){                  
                     if(stoploss == 0) SL = stoploss;
                     if(stoploss != 0) SL = (Bid+stoploss*_Point);
                     if(takeprofit == 0) TP = stoploss;
                     if(takeprofit != 0) TP = (Bid-takeprofit*_Point);
                     
                     checkPoint = Bid - ((takeprofit*_Point)*0.6);
                     CurrentType = "Sell";
                     openPrice = Bid;
                      
                     trade.Sell(lotSize,NULL,Bid,SL,TP,NULL);
                     
                  }
               }
            }
         }
      }
   if(CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
      if(PositionsTotal() == 1 && CurrentType == "Buy"){
         if(PriceArray[1].close >= checkPoint && PriceArray[1].low>PriceArray[2].low)
         //if(PriceArray[1].close - openPrice)
            CheckTrailingStop(openPrice,TP,PriceArray[1].low);
      }
      if(PositionsTotal() == 1 && CurrentType == "Sell"){
         if(PriceArray[1].close <= checkPoint && PriceArray[1].high<PriceArray[2].high)
            CheckTrailingStop(openPrice,TP,PriceArray[1].high); 

      }  
   }               
   tmpDate = date;
   //Comment((PriceArray[1].close - openPrice)*10000);
  }
//+------------------------------------------------------------------+


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
void CheckTrailingStop(double priceOpen,double TP,double chk)
   {
      for(int i = PositionsTotal()-1;i>=0;i--){
         
         string symbol = PositionGetSymbol(i);
         
         if(_Symbol == symbol){
            if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY)
            {
               ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
               double CurrentStopLoss = PositionGetDouble(POSITION_SL);               
               double PositionPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
               if(chk > CurrentStopLoss)
                  trade.PositionModify(PositionTicket,chk,TP);
         
            }
            if(PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL)
            {
               ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
               double CurrentStopLoss = PositionGetDouble(POSITION_SL);               
               double PositionPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
               if(chk < CurrentStopLoss)
                  trade.PositionModify(PositionTicket,chk,TP);

         
            }
         }
         
            
      }
   }