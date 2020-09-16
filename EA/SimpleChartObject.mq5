int status = 0;
void OnTick()
  {
   int HighestCandle,LowestCandle;
   
   double High[],Low[];
   
   ArraySetAsSeries(High,true);
   
   ArraySetAsSeries(Low,true);
   
   int NumberOfCandles = Bars(_Symbol,_Period);
      
   string NumberOfCandlesText = IntegerToString(NumberOfCandles);
   
   CopyHigh(_Symbol,_Period,0,30,High);
   
   CopyLow(_Symbol,_Period,0,30,Low);
   
   HighestCandle = ArrayMaximum(High,0,30);
   
   LowestCandle = ArrayMinimum(Low,0,30);
   
   MqlRates PriceInformation[];
   
   ArraySetAsSeries(PriceInformation,true);
   
   int data = CopyRates(_Symbol,_Period,0,Bars(_Symbol,_Period),PriceInformation);
   
   ObjectDelete(_Symbol,"Rectangle");
   if(StringSubstr(PriceInformation[0].time,11,5) >= "17:00" && StringSubstr(PriceInformation[0].time,11,5) <= "17:59"){
      status = 0;
   }
   else if(StringSubstr(PriceInformation[0].time,11,5)>"17:59" && status == 0){
      drawRect();
      ObjectCreate
      (
         _Symbol,                               
         NumberOfCandlesText,                           
         OBJ_RECTANGLE,
         0,                                     //in main window
         PriceInformation[28].time,             //left border candle30
         PriceInformation[HighestCandle].high,  //upper border highest candle
         PriceInformation[0].time,              //right border candle0
         PriceInformation[LowestCandle].low     //lower border lowest candle
      );
      ObjectSetInteger(0,NumberOfCandlesText,OBJPROP_COLOR,clrBlue);   
      ObjectSetInteger(0,NumberOfCandlesText,OBJPROP_FILL,clrBlue);   
      status = 1;
   }
   
//   
   Comment( "Time:   ",StringSubstr(PriceInformation[0].time,11,5),"\n",
            "Status: ",status,"\n"
           );
  }

void drawRect()
{

}