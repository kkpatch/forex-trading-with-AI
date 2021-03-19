#include <Trade\Trade.mqh>

CTrade trade;   
int status = 0;

//--- file variable


string tmpDate = "";
string date = "";
int count = 1;
double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
double profit;
double tmpProfit = 0;
double eq ;
//---
int filehandle;         //profit each day
int filehandle2;        //profit each order
int filehandle3;

double price;
datetime openTime;
datetime closeTime;

input group           "File Name" 
input string filename  = "profit_ADX+RSI_DailyProfit.csv";                    //FileName: 
input string filename2 = "profit_ADX+RSI_EachOrder.csv";                      //FileName2: 
input string filename3 = "profit_ADX+RSI_DailyProfit+NotOpenOrder.csv";       //FileName3:

input group           "Average Directional Movement Index" 
input int ADX_Period = 14;                //ADX: Period

input group           "Relative Strength Index" 
input int RSI_Period = 7;                 //RSI: Period

input group           "Moving Average"
input int MA_Period = 200;                //MA: Period
input int MA_Shift = 0;                   //MA: Shift
input ENUM_MA_METHOD MA_Method=MODE_SMA;  //MA: Method

input group           "StopLoss/TakeProfit"
double SL;
input int stoploss = 300;       //StopLoss: 
double TP;
input int takeprofit = 500;     //TakeProfit: 

string   adx_status = "";

double openPrice;
double checkPoint;
double checkPoint2;
string CurrentType = "";

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
   filehandle3=FileOpen(filename3,FILE_WRITE|FILE_CSV);
   if(filehandle3!=INVALID_HANDLE)
     {      
      Print("File opened correctly");
     }
   else Print("Error in opening file,",GetLastError());
   
   FileWrite(filehandle,"Date","Profit");
   FileWrite(filehandle2,"OpenTime","CloseTime","OpenPrice","ClosePrice","StopLoss","TakeProfit","OrderProfit","Info");
   FileWrite(filehandle3,"Date","Profit");

//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
//---
   if(profit-tmpProfit!=0){ 
      FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
      FileWrite(filehandle3,tmpDate,NormalizeDouble(profit-tmpProfit,2));  
   }
   FileClose(filehandle);
   FileClose(filehandle2);
   FileClose(filehandle3);
  }


void OnTick() 
   {
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);   
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   MqlRates PriceInfo[]; 
   ArraySetAsSeries(PriceInfo,true);
   int Data = CopyRates(_Symbol,_Period,0,3,PriceInfo);
   
   //--- ADX Setup 
   double PriceArray[];
   double UpperBandArray[];
   double LowerBandArray[];
   int ADXDefinition = iADX(_Symbol,_Period,ADX_Period);
   ArraySetAsSeries(PriceArray,true);
   ArraySetAsSeries(UpperBandArray,true);
   ArraySetAsSeries(LowerBandArray,true);  
   CopyBuffer(ADXDefinition,0,0,3,PriceArray);
   CopyBuffer(ADXDefinition,1,0,3,UpperBandArray);
   CopyBuffer(ADXDefinition,2,0,3,LowerBandArray);
   //---
   
   //--- RSI Setup
   double myRSIArray[];
   int myRSIDefinition = iRSI(_Symbol,_Period,RSI_Period,PRICE_CLOSE);
   ArraySetAsSeries(myRSIArray,true);
   CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
   //---
   
   double myMovingAverageArray[];
   ArraySetAsSeries(myMovingAverageArray,true);
   int movingAverageDefination = iMA (_Symbol,_Period,MA_Period,MA_Shift,MA_Method,PRICE_CLOSE);
   CopyBuffer(movingAverageDefination,0,0,3,myMovingAverageArray); //copy from movingAverageDefination to myMovingAverageArray

   //---
   
   int CandleNumber = Bars(_Symbol,_Period);
      
   if(UpperBandArray[0] > LowerBandArray[0] && UpperBandArray[1] < LowerBandArray[1]){
      if(PriceArray[0] > 25 )
         if(myMovingAverageArray[0]<Ask)
            if(myRSIArray[0] > 50 )
               if(PositionsTotal()==0){
                  if(stoploss == 0) SL = stoploss;
                  if(stoploss != 0) SL = (Ask-stoploss*_Point);
                  if(takeprofit == 0) TP = stoploss;
                  if(takeprofit != 0) TP = (Ask+takeprofit*_Point);
                  
                  checkPoint = Ask + ((takeprofit*_Point)*0.6);
                  CurrentType = "Buy";
                  openPrice = Ask;
                  
                  trade.Buy(0.1,NULL,Ask,SL,TP,NULL);
               }
   }
   else if(UpperBandArray[0] < LowerBandArray[0] && UpperBandArray[1] > LowerBandArray[1]){
      if(PriceArray[0] > 25 )
         if(myMovingAverageArray[0]>Bid)
            if(myRSIArray[0] < 50 )
               if(PositionsTotal()==0){
                  if(stoploss == 0) SL = stoploss;
                  if(stoploss != 0) SL = (Bid+stoploss*_Point);
                  if(takeprofit == 0) TP = stoploss;
                  if(takeprofit != 0) TP = (Bid-takeprofit*_Point);
                  
                  checkPoint = Bid - ((takeprofit*_Point)*0.6); 
                  CurrentType = "Sell";
                  openPrice = Bid;
                  
                  trade.Sell(0.1,NULL,Bid,SL,TP,NULL);
                     
               }
   }
         
                    
   if(CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
      if(PositionsTotal() == 1 && CurrentType == "Buy"){
         if(PriceInfo[1].close >= checkPoint && PriceInfo[1].low>PriceInfo[2].low)
         //if(PriceArray[1].close - openPrice)
            CheckTrailingStop(openPrice,TP,PriceInfo[1].low);
      }
      if(PositionsTotal() == 1 && CurrentType == "Sell"){
         if(PriceInfo[1].close <= checkPoint && PriceInfo[1].high<PriceInfo[2].high)
            CheckTrailingStop(openPrice,TP,PriceInfo[1].high); 

      }  
   }           


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
// void InfoEachOrder(string info)
//   {
//   uint     TotalNumberOfDeals;
//   ulong    TicketNumber = 0;
//   double   openPrice = 0;
//   double   stoplosss = 0;
//   double   takeprofitt = 0;
//   double   OrderProfit = 0;
//   double   closePrice = 0;
//
//   closeTime = TimeCurrent();
//   HistorySelect(0,TimeCurrent());
//   TotalNumberOfDeals = HistoryOrdersTotal();
//   uint i = 0;
//   for(uint i = 0;i<TotalNumberOfDeals-1;i++)
//   {
//      if((TicketNumber=HistoryOrderGetTicket(i))>0)
//      {
//         stoplosss = HistoryOrderGetDouble(TicketNumber,ORDER_SL);
//         takeprofitt = HistoryOrderGetDouble(TicketNumber,ORDER_TP);
//      }
//   }
//   if((TicketNumber=HistoryOrderGetTicket(i))>0){
//      closePrice = HistoryDealGetDouble(HistoryOrderGetTicket(HistoryOrdersTotal()-1),DEAL_PRICE); 
//      OrderProfit = HistoryDealGetDouble(HistoryOrderGetTicket(HistoryOrdersTotal()-1),DEAL_PROFIT);
//   }
//   openPrice = closePrice - (OrderProfit/10.0);
//   if(info == "SL/TP"){
//      if(OrderProfit > 0)  info = "TP";
//      else info = "SL";
//   }        
//   FileWrite(filehandle2,openTime,closeTime,openPrice,closePrice,stoplosss,takeprofitt,OrderProfit,info);
// }
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