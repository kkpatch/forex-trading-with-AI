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
double TP;
input int stoploss = 300;       //StopLoss:
input int takeprofit = 500;     //TakeProfit: 

string   adx_status = "";

bool     OrderOpen = false;

int OpenOrderBarNumber = 0;

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
   
   //--- MA Setup
   double myMovingAverageArray[];
   ArraySetAsSeries(myMovingAverageArray,true);
   int movingAverageDefination = iMA (_Symbol,_Period,MA_Period,MA_Shift,MA_Method,PRICE_CLOSE);  
   CopyBuffer(movingAverageDefination,0,0,6,myMovingAverageArray); //copy from movingAverageDefination to myMovingAverageArray
   //---
   
   //--- PriceInfo Setup
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo,true); 
   int PriceData = CopyRates(_Symbol,_Period,0,4,PriceInfo);
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
                  OpenOrderBarNumber = CandleNumber;
                  
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
                  OpenOrderBarNumber = CandleNumber;

                  trade.Sell(0.1,NULL,Bid,SL,TP,NULL);
                     
               }
   }
   //if(PositionsTotal() == 1 && CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
   //   CheckPosition(PriceInfo[1].close,PriceInfo[2].close,PriceInfo[3].close,PriceInfo[2].close,PriceInfo[3].close,
   //                 myMovingAverageArray[1],myMovingAverageArray[2],myMovingAverageArray[3],myMovingAverageArray[4],myMovingAverageArray[5],
   //                 OpenOrderBarNumber,CandleNumber);
   //}
   //Comment(myMovingAverageArray[0],"\n",myMovingAverageArray[1],"\n",myMovingAverageArray[2],"\n",myMovingAverageArray[3]);
   //Comment(OpenOrderBarNumber);      
                    



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
   for(uint i = 0;i<TotalNumberOfDeals-1;i++)
   {
      if((TicketNumber=HistoryOrderGetTicket(i))>0)
      {
         stoplosss = HistoryOrderGetDouble(TicketNumber,ORDER_SL);
         takeprofitt = HistoryOrderGetDouble(TicketNumber,ORDER_TP);
      }
   }
   if((TicketNumber=HistoryOrderGetTicket(i))>0){
      closePrice = HistoryDealGetDouble(HistoryOrderGetTicket(HistoryOrdersTotal()-1),DEAL_PRICE); 
      OrderProfit = HistoryDealGetDouble(HistoryOrderGetTicket(HistoryOrdersTotal()-1),DEAL_PROFIT);
   }
   openPrice = closePrice - (OrderProfit/10.0);
   if(info == "SL/TP"){
      if(OrderProfit > 0)  info = "TP";
      else info = "SL";
   }        
   FileWrite(filehandle2,openTime,closeTime,openPrice,closePrice,stoplosss,takeprofitt,OrderProfit,info);
 }
 
 void CheckPosition(double PriceInfo1_Close, double PriceInfo2_Close, double PriceInfo3_Close, double PriceInfo4_Close, double PriceInfo5_Close,
                    double MA1, double MA2, double MA3, double MA4, double MA5,
                    int OpenOrderNumber ,int CurrentNumber)
   {
      double PositionType;
      string Position;
      MA1 = NormalizeDouble(MA1,6);
      MA2 = NormalizeDouble(MA2,6);
      MA3 = NormalizeDouble(MA3,6);
      MA4 = NormalizeDouble(MA4,6);
      MA5 = NormalizeDouble(MA5,6);
      for(int i = PositionsTotal()-1;i>=0;i--)
         {
            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
            
            PositionType = PositionGetInteger(POSITION_TYPE);
            
            string symbol = PositionGetSymbol(i); //get position symbol to make sure that the position belongs to the current chart
            
            //if(_Symbol == symbol)
            //   if(PositionType == POSITION_TYPE_BUY)
                  
         }
      if(PositionType == POSITION_TYPE_BUY){
         Position = "Buy";
      }
      if(PositionType == POSITION_TYPE_SELL){
         Position = "Sell";
      }
      //Comment("PriceInfo1_Close: ", PriceInfo1_Close, "\n",
      //        "PriceInfo2_Close: ", PriceInfo2_Close, "\n",
      //        "PriceInfo3_Close: ", PriceInfo3_Close, "\n",
      //        "MA1:              ", MA1, "\n",
      //        "MA2:              ", MA2, "\n",
      //        "MA3:              ", MA3, "\n",
      //        "OpenOrderNumber:  ", OpenOrderNumber, "\n",
      //        "CurrentNumber:    ", CurrentNumber, "\n",
      //        "CurrentNumber-OpenOrderNumber: ", CurrentNumber-OpenOrderNumber, "\n",
      //        "Position: ", Position
      //       );
      if(CurrentNumber-OpenOrderNumber > 300){
         
         string Position = "";
//         for(int i = PositionsTotal()-1;i>=0;i--)
//         {
//            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
//            
//            PositionType = PositionGetInteger(POSITION_TYPE);
//            
//            string symbol = PositionGetSymbol(i); //get position symbol to make sure that the position belongs to the current chart
//            
//            //if(_Symbol == symbol)
//            //   if(PositionType == POSITION_TYPE_BUY)
//                  
//         }
         if(PositionType == POSITION_TYPE_BUY){
            //Position = "Buy";
            if(PriceInfo1_Close < MA1)
               if(PriceInfo2_Close < MA2)
                  if(PriceInfo3_Close < MA3)
                     if(PriceInfo4_Close < MA4)
                        if(PriceInfo5_Close < MA5)
                           CloseAll();
         }
         if(PositionType == POSITION_TYPE_SELL){
            //Position = "Sell";
            if(PriceInfo1_Close > MA1)
               if(PriceInfo2_Close > MA2)
                  if(PriceInfo3_Close > MA3)
                     if(PriceInfo4_Close > MA4)
                        if(PriceInfo5_Close > MA5)
                           CloseAll();
         }
      }
      

      //Comment(Position, "\n",
      //       PositionType, "\n",
      //       PositionsTotal());
   }