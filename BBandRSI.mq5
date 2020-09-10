#include<Trade\Trade.mqh>

CTrade trade;
double max_spread = 0;
int PositionCheck = 0;
double Ask_History[3];
double Bid_History[3];

int  Sel_Type = 0;
string Type = "";
double loss;

double MaxProfit = 0;

void OnTick()
  {
      datetime time = TimeLocal();
      
      string signal = "";
      
      string hoursAndMinutes = TimeToString(time,TIME_MINUTES);
      
      double spread = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);    
      if(spread>max_spread)   max_spread = spread;
      /*Comment(
               "Spread     : ",DoubleToString(spread,1),"\n",
               "Max Spread : ",DoubleToString(max_spread,1),"\n"
              );*/
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      double MiddleBandArray[];
      double UpperBandArray[];
      double LowerBandArray[];
      double myRSIArray[];
        
      ArraySetAsSeries(MiddleBandArray,true);
      ArraySetAsSeries(UpperBandArray,true);
      ArraySetAsSeries(LowerBandArray,true);
      ArraySetAsSeries(myRSIArray,true);
      
      int BollingerBandsDefinition = iBands(_Symbol,_Period,20,0,2,PRICE_CLOSE);
      int myRSIDefinition = iRSI(_Symbol,_Period,14,PRICE_CLOSE);
      
      CopyBuffer(BollingerBandsDefinition,0,0,3,MiddleBandArray);
      CopyBuffer(BollingerBandsDefinition,1,0,3,UpperBandArray);
      CopyBuffer(BollingerBandsDefinition,2,0,3,LowerBandArray);
      CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
      
      double myMiddleBandValue = MiddleBandArray[0];
      double myUpperBandValue = UpperBandArray[0];
      double myLowerBandValue = LowerBandArray[0];
      
      double myRSIValue0 = NormalizeDouble(myRSIArray[0],2);
      double myRSIValue1 = NormalizeDouble(myRSIArray[1],2);
      double myRSIValue2 = NormalizeDouble(myRSIArray[2],2);
      
      Comment( "Time: ",TimeLocal(),"\n",
               "RSI0: ",myRSIValue0,"\n",
               "RSI1: ",myRSIValue1,"\n",
               "RSI2: ",myRSIValue2,"\n"
             );

         MaxProfit = 0;
         if(Ask<myLowerBandValue){
            if(myRSIValue0 < 30){
               signal = "buy";
            }
         }
         if(Bid>myUpperBandValue){
            if(myRSIValue0 > 70){
               signal = "sell";
            }
         }

      if(PositionsTotal() < 1){
         if(signal == "sell") trade.Sell(0.1,NULL,Bid,(Bid+1500*_Point),(Bid-2500*_Point),NULL);
         if(signal == "buy" ) trade.Buy(0.1,NULL,Ask,(Ask-1500*_Point),(Ask+2500*_Point),NULL);
      }
      
      

  }