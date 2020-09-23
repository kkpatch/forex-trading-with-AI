int status = 0;

void OnTick()
  {
      DrawRect();
  }

void DrawRect(){
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
   if(StringSubstr(time,0,5)>="11:00" && StringSubstr(time,0,5)<="16:59"){
      status = 0;
   }
   if(StringSubstr(time,0,5)=="17:00" && status == 0){
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
      status = 1;
   }
   //---
}