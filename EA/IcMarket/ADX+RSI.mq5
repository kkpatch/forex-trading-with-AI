#include <Trade\Trade.mqh>

CTrade trade;   
int status = 0;

input string filename = "profit_IcMarket.csv";      //FileName: 

int filehandle;
string tmpDate = "";
string date = "";
int count = 1;
double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
double profit;
double tmpProfit = 0;
double eq ;

double SL;
input int stoploss = 0;     //Stoploss: 

string adx_status = "";
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

//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
//---
   if(profit-tmpProfit!=0){ 
      FileWrite(filehandle,tmpDate,NormalizeDouble(profit-tmpProfit,2));
      
   }FileClose(filehandle);
  }


void OnTick()
  {

  //--- Draw Object Setup
   datetime timeCurrent = TimeCurrent(); 
   string time = TimeToString(timeCurrent,TIME_SECONDS);   
   int HighestCandle,LowestCandle;   
   double High[],Low[];  
   ArraySetAsSeries(High,true);   
   ArraySetAsSeries(Low,true);  
   CopyHigh(_Symbol,_Period,0,30,High);   
   CopyLow(_Symbol,_Period,0,30,Low);   
   HighestCandle = ArrayMaximum(High,0,30);   
   LowestCandle = ArrayMinimum(Low,0,30);
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
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);   
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   int NumberOfCandles = Bars(_Symbol,_Period);
   string NumberOfCandlesText2 = IntegerToString(NumberOfCandles*2);
   
   int CandleNumber = Bars(_Symbol,_Period);
   
  //--- ADX Setup 
   double PriceArray[];
   double UpperBandArray[];
   double LowerBandArray[];
   int ADXDefinition = iADX(_Symbol,_Period,14);
   ArraySetAsSeries(PriceArray,true);
   ArraySetAsSeries(UpperBandArray,true);
   ArraySetAsSeries(LowerBandArray,true);  
   CopyBuffer(ADXDefinition,0,0,3,PriceArray);
   CopyBuffer(ADXDefinition,1,0,3,UpperBandArray);
   CopyBuffer(ADXDefinition,2,0,3,LowerBandArray);
   //---
   
   //--- RSI Setup
   double myRSIArray[];
   int myRSIDefinition = iRSI(_Symbol,_Period,14,PRICE_CLOSE);
   ArraySetAsSeries(myRSIArray,true);
   CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
   //---
   
   //--- Draw Object
   if(StringSubstr(time,0,5)>="19:00" && StringSubstr(time,0,5)<="19:59"){
      status = 0;
   }
   if(StringSubstr(time,0,5)=="20:00" && status == 0){
      MqlRates PriceInformation[];  
      ArraySetAsSeries(PriceInformation,true); 
      int data = CopyRates(_Symbol,_Period,0,Bars(_Symbol,_Period),PriceInformation);
      ObjectCreate
      (
         _Symbol,                               
         TimeCurrent(),                           
         OBJ_RECTANGLE,
         0,                                     //in main window
         PriceInformation[24].time,             //left border candle30
         PriceInformation[HighestCandle].high,  //upper border highest candle
         PriceInformation[0].time,              //right border candle0
         PriceInformation[LowestCandle].low     //lower border lowest candle         
      );
      ObjectSetInteger(0,TimeCurrent(),OBJPROP_COLOR,clrBlue);   
      ObjectSetInteger(0,TimeCurrent(),OBJPROP_FILL,clrBlue);   
      status = 1;
      CloseAll();
   }
   //---
   
   if(StringSubstr(time,0,5)>="14:00" && StringSubstr(time,0,5)<="19:59"){
      if(PositionsTotal()==0){
      if(UpperBandArray[0] > LowerBandArray[0] && UpperBandArray[1] < LowerBandArray[1]){
         if(PriceArray[0] > 25 )
            //if(ADXValue0 > ADXValue1)
            //if(UpperBandArray[0] > UpperBandArray[1] && LowerBandArray[0] < LowerBandArray[1]){
               //if(UpperBandArray[0] - LowerBandArray[0] > UpperBandArray[1] - LowerBandArray[1]){
               if(myRSIArray[0] > 50 ){
                     if(stoploss == 0) SL = stoploss;
                     else SL = (Ask-stoploss*_Point);
                     trade.Buy(0.1,NULL,Ask,SL,(Ask+250*_Point),NULL);
                     adx_status = "";
                     //if(PositionsTotal()==0)
                     //trade.Buy(0.1,NULL,Ask,0,(Ask+250*_Point),NULL);
                  }
               //}
            //}
         //}
         }
       }
       if(CheckForNewCandle(CandleNumber) == "YES, A NEW CANDLE APPEARED!"){
         if(UpperBandArray[1] < LowerBandArray[1] && UpperBandArray[2] > LowerBandArray[2]){
            adx_status = "sell";
            CloseAll();
            } 
       }
           
      // if(UpperBandArray[0] < LowerBandArray[0] && UpperBandArray[1] > LowerBandArray[1]){
      //    if(PriceArray[0] > 25)
      //      //if(ADXValue0 > ADXValue1)
      //      //if(UpperBandArray[0] < UpperBandArray[1] && LowerBandArray[0] > LowerBandArray[1]){
      //         //if(LowerBandArray[0] - UpperBandArray[0] > LowerBandArray[1] - UpperBandArray[1]){
      //         if(myRSIArray[0] < 50 )
      //            if(PositionsTotal()==0){
      //               trade.Sell(0.1,NULL,Bid,(Bid+1000*_Point),(Bid-1000*_Point),NULL);
      //               //signal = "sell";
      //               //ObjectCreate(_Symbol,NumberOfCandlesText2,OBJ_ARROW,0,TimeCurrent(),Bid);
      //               //ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_ARROWCODE,159);
      //               //ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_COLOR,clrPurple);
      //               //ObjectSetInteger(0,NumberOfCandlesText2,OBJPROP_WIDTH,3);
      //            //}
      //         //}
      //      //}
      //   }
      //}
      }
      //Comment(adx_status);   








   
   //Comment( "PriceArray[0]: ", PriceArray[0], "\n",
   //         "PriceArray[1]: ", PriceArray[1], "\n",
   //         "UpperBandArray[0]: ", UpperBandArray[0], "\n",
   //         "UpperBandArray[1]: ", UpperBandArray[1], "\n",
   //         "LowerBandArray[0]: ", LowerBandArray[0], "\n",
   //         "LowerBandArray[1]: ", LowerBandArray[1], "\n",
   //         "RSIArray[0]: ", myRSIArray[0], "\n",
   //         "RSIArray[1]: ", myRSIArray[1]
   //);
//   
   //Comment( "Time:   ",StringSubstr(PriceInformation[0].time,11,5),"\n",
   //         "Status: ",status,"\n"
   //        );
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