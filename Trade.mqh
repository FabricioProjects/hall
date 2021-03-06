//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"
  
//+------------------------------------------------------------------+
//| Order Info                                                       |
//+------------------------------------------------------------------+
void Deal(string texto)
  { 
   Global.filehandle_deal = FileOpen(Global.subfolder+"\\"+MQLInfoString(MQL_PROGRAM_NAME)
                                                +"_Deal"+"_M"+(string)Period()+".txt",FILE_READ|FILE_WRITE|FILE_CSV);
   if(Global.filehandle_deal!= INVALID_HANDLE)
     {
      FileSeek(Global.filehandle_deal,0,SEEK_END);
      FileWrite(Global.filehandle_deal,(string)TimeCurrent()+texto);
      FileFlush(Global.filehandle_deal);
      FileClose(Global.filehandle_deal);
     }
   else Alert("Operation FileOpen Deal Failed, Error ",GetLastError()); 
   ResetLastError();
   
  }
 
// dados atualizados da posição fornecidos pelo broker 
void Deal_Info()
  {
   Deal( "\n"
        +" SYMBOL:        "+(string)PositionGetString (POSITION_SYMBOL)+"\n" 
        +" IDENTIFIER:    "+(string)PositionGetInteger(POSITION_IDENTIFIER)+"\n"  
        +" UNIXTIME:      "+(string)PositionGetInteger(POSITION_TIME)+"\n" 
        +" BUY(0)SELL(1): "+(string)PositionGetInteger(POSITION_TYPE)+"\n"  
        +" VOLUME:        "+(string)PositionGetDouble (POSITION_VOLUME)+"\n" 
        +" PRICE_OPEN:    "+(string)PositionGetDouble (POSITION_PRICE_OPEN)+"\n" 
        +" PRICE_CURRENT: "+(string)PositionGetDouble (POSITION_PRICE_CURRENT)+"\n"  
       );
   Global.price_open = PositionGetDouble(POSITION_PRICE_OPEN);
     
  }  
          
//+------------------------------------------------------------------+
//| Open Long position                                               |
//+------------------------------------------------------------------+
void OpenLongPosition()
  {
   CTrade  trade;
   if(!trade.Buy(Global.contratos))
     {
      Debug(" Buy() Failed. Return Code: "+(string)trade.ResultRetcode()+
            ". Descrição do código: "+trade.ResultRetcodeDescription());
      return;
     }
   else
     {
      Debug(" Buy() Successfully, Retcode: "+(string)trade.ResultRetcode()+" ("+trade.ResultRetcodeDescription()+")");
      Debug(" ################# Deal ################# "+"\n"
         +" Global.price_ask : "+(string)Global.price_ask+"\n"
         +" Global.price_last: "+(string)Global.price_last+"\n"
         +" Global.price_bid : "+(string)Global.price_bid+"\n"
         +" Global.spread    : "+(string)Global.spread        );      
      // Mecanismo de segurança para ter certeza q a corretora atualizou a posição da trade
      int i=0,j=50000000;
      uint count_init,count_end,count_delay;
      count_init = GetTickCount();
      do
        {
         if(PositionSelect(_Symbol))
           {
            count_end = GetTickCount();
            count_delay = count_end - count_init;
            Debug(" Entrada Long, Delay: "+(string)count_delay+" Milisec");
            Deal_Info();
            break;
           }
         i++; 
        }
      while(i<j);
      
      if(!PositionSelect(_Symbol))  // caso complete o loop inteiro...
        {  
         Alert(" Tentativa de Entrada Long com Latencia Alta!!!!!!!" );
         Debug(" Tentativa de Entrada Long com Latencia Alta!!!!!!!" );
         return;
        }    
       
      Signals.LongPosition = true;    

     }  // fim da else (!trade.Buy(Global.contratos))
      
    // commission emulation
    if(Strategy.Simulation) 
      {
       double commission = 2*Global.contratos;
       TesterWithdrawal(commission);
      } 
    // Voz de entrada  
    Vox_Control();                // ##Misc##  
    // Proteção para evitar multiplas entradas
    Flag.Once = true;
       
  } // fim da OpenLongPosition()
  
//+------------------------------------------------------------------+
//| Increase Long position                                           |
//+------------------------------------------------------------------+
void Increase_LongPosition()
  {
   CTrade  trade;
   if(!trade.Buy(Global.contratos))
     {
      Debug(" Buy() Failed. Retcode: "+(string)trade.ResultRetcode()+
            ". Descrição do Código: "+trade.ResultRetcodeDescription());
      return;
     }
   else
     {
      Debug(" Buy() Successfully, Retcode: "+(string)trade.ResultRetcode()+" ("+trade.ResultRetcodeDescription()+")");  
      Debug(" ################# Deal ################# "+"\n"
            +" Global.price_ask : "+(string)Global.price_ask+"\n"
            +" Global.price_last: "+(string)Global.price_last+"\n"
            +" Global.price_bid : "+(string)Global.price_bid+"\n"
            +" Global.spread    : "+(string)Global.spread        );                
      // Mecanismo de segurança para ter certeza q a corretora atualizou a posição da trade
      int i=0,j=500000000;
      uint count_init,count_end,count_delay;
      count_init = GetTickCount();
      do
        {
         if(   PositionSelect(_Symbol)
            && PositionGetDouble(POSITION_PRICE_OPEN) != Global.price_open
            && PositionGetDouble(POSITION_VOLUME)     >  Global.contratos  )
           {
            count_end = GetTickCount();
            count_delay = count_end - count_init;
            Debug(" Segunda Entrada Long, Delay: "+(string)count_delay+" Milisec");
            Deal_Info();
            break;
           }
         i++; 
        }
      while(i<j);
      // caso complete o loop inteiro...
      if(PositionGetDouble(POSITION_VOLUME) < Global.contratos)  
        {  
         Alert(" Tentativa da Segunda Entrada Long Falhou!!!!!!!" );
         Debug(" Tentativa da Segunda Entrada Long Falhou!!!!!!!" );
         CloseLongPosition();
         Flag.Sigma = true;
         return;
        }    
               
     }
       
    // commission emulation
    if(Strategy.Simulation) 
      {
       double commission = 2*Global.contratos;
       TesterWithdrawal(commission);
      }  
       
  } // fim da Increase_LongPosition()  
  

//+------------------------------------------------------------------+
//| Open Short position                                              |
//+------------------------------------------------------------------+
void OpenShortPosition()
  {
   CTrade  trade;
   if(!trade.Sell(Global.contratos))
     {
      Debug(" Sell() Failed. Retcode: "+(string)trade.ResultRetcode()+
            ". Descrição do Código: "+trade.ResultRetcodeDescription());
     }
   else
     {
      Debug(" Sell() Successfully, Retcode: "+(string)trade.ResultRetcode()+" ("+trade.ResultRetcodeDescription()+")");
      Debug(" ################# Deal ################# "+"\n"
         +" Global.price_ask : "+(string)Global.price_ask+"\n"
         +" Global.price_last: "+(string)Global.price_last+"\n"
         +" Global.price_bid : "+(string)Global.price_bid+"\n" 
         +" Global.spread    : "+(string)Global.spread         );      
      // Mecanismo de segurança para ter certeza q a corretora atualizou a posição da trade
      int i=0,j=50000000;
      uint count_init,count_end,count_delay;
      count_init = GetTickCount();
      do
        {
         if(PositionSelect(_Symbol))
           {
            count_end = GetTickCount();
            count_delay = count_end - count_init;
            Debug(" Entrada Short, Delay: "+(string)count_delay+" milisec"); 
            Deal_Info();
            break;
           }
         i++; 
        }
      while(i<j);
 
     if(!PositionSelect(_Symbol)) // caso complete o loop inteiro...
        {  
         Alert(" Tentativa de Entrada Short com Latencia Alta!!!!!!! ");
         Debug(" Tentativa de Entrada Short com Latencia Alta!!!!!!! ");
         return;
        }  
      
      Signals.ShortPosition = true;    

     }  // fim da else (!trade.Sell(Global.contratos))
     
    // commission emulation
    if(Strategy.Simulation) 
      {
       double commission = 2*Global.contratos;
       TesterWithdrawal(commission);
      }  
    // Voz de entrada  
    Vox_Control();                // ##Misc##  
    // Proteção para evitar multiplas entradas
    Flag.Once = true;  
      
  } // fim da OpenShortPosition()
  
//+------------------------------------------------------------------+
//| Increase Short position                                           |
//+------------------------------------------------------------------+
void Increase_ShortPosition()
  {
   CTrade  trade;  
   if(!trade.Sell(Global.contratos))
     {
      Debug(" Sell() Failed. Retcode: "+(string)trade.ResultRetcode()+
            ". Descrição do Código: "+trade.ResultRetcodeDescription());
      return;
     }
   else
     {
      Debug(" Sell() Successfully, Retcode: "+(string)trade.ResultRetcode()+" ("+trade.ResultRetcodeDescription()+")");    
      Debug(" ################# Deal ################# "+"\n"
         +" Global.price_ask : "+(string)Global.price_ask+"\n"
         +" Global.price_last: "+(string)Global.price_last+"\n"
         +" Global.price_bid : "+(string)Global.price_bid+"\n"
         +" Global.spread    : "+(string)Global.spread        );            
      // Mecanismo de segurança para ter certeza q a corretora atualizou a posição da trade
      int i=0,j=500000000;
      uint count_init,count_end,count_delay;
      count_init = GetTickCount();
      do
        {
         if(   PositionSelect(_Symbol)
            && PositionGetDouble(POSITION_PRICE_OPEN) != Global.price_open
            && PositionGetDouble(POSITION_VOLUME)     >  Global.contratos  )
           {
            count_end = GetTickCount();
            count_delay = count_end - count_init;
            Debug(" Segunda Entrada Short, Delay: "+(string)count_delay+" Milisec");
            Deal_Info();
            break;
           }
         i++; 
        }
      while(i<j);
      // caso complete o loop inteiro...
      if(PositionGetDouble(POSITION_VOLUME) < Global.contratos)  
        {  
         Alert(" Tentativa da Segunda Entrada Short Falhou!!!!!!!" );
         Debug(" Tentativa da Segunda Entrada Short Falhou!!!!!!!" );
         CloseShortPosition();
         Flag.Sigma = true;
         return;
        }           
     }
       
    // commission emulation
    if(Strategy.Simulation) 
      {
       double commission = 2*Global.contratos;
       TesterWithdrawal(commission);
      }  
       
  } // fim da Increase_ShortPosition() 
    

//+------------------------------------------------------------------+
//| Close Long position                                              |
//+------------------------------------------------------------------+
void CloseLongPosition()
  {
   CTrade  trade;
   //--- closing a position at the current symbol
   if(!trade.PositionClose(_Symbol))
     {
      Debug(" ################# Close Fail ################# ");
      Debug(" PositionClose() Failed. Retcode: "+(string)trade.ResultRetcode()+
            ". Descrição do código: "+trade.ResultRetcodeDescription());
     }
   else
     {
      Debug(" PositionClose() Successfully, Retcode: "+(string)trade.ResultRetcode()+" ("+trade.ResultRetcodeDescription()+")"); 
      Debug(" ################# Close ################ "+"\n"
            +" Global.price_ask : "+(string)Global.price_ask+"\n"
            +" Global.price_last: "+(string)Global.price_last+"\n"
            +" Global.price_bid : "+(string)Global.price_bid+"\n"
            +" Global.spread    : "+(string)Global.spread        );                            
     }
     
    // Mecanismo de segurança para ter certeza q a corretora atualizou a posição da trade
    int i=0,j=10000000;
    uint time_init,time_end,time_delay;
    time_init = GetTickCount();
    do
      {
       if(!PositionSelect(_Symbol))
         {
          time_end = GetTickCount();
          time_delay = time_end - time_init;
          Debug(" Saida Long, Position: "+(string)PositionSelect(_Symbol)+", Delay: "+(string)time_delay+" Milisec");
          HistorySelect(0, TimeCurrent());
          Global.price_close = HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-1),DEAL_PRICE);
          Debug(" Price_Close: "+(string)Global.price_close);
          Deal_Info();
          break;
         }
       i++; 
      }
    while(i<j);
    
    // caso complete o loop inteiro...
    if(PositionSelect(_Symbol)) 
      {
       Alert(" Saida Long com Latencia Alta!!!!!!! ");
       Debug(" Saida Long com Latencia Alta!!!!!!! ");
      }  
       
  } // fim da CloseLongPosition
      
//+------------------------------------------------------------------+
//| Close Short position                                             |
//+------------------------------------------------------------------+
void CloseShortPosition()
  {
   CTrade  trade;
   //--- closing a position at the current symbol
   if(!trade.PositionClose(_Symbol))
     {
      Debug(" ################# Close Fail ################# ");
      Debug(" PositionClose() Failed. Retcode: "+(string)trade.ResultRetcode()+
            ". Descrição do código: "+trade.ResultRetcodeDescription());
     }
   else
     {
      Debug(" PositionClose() Successfully, Retcode: "+(string)trade.ResultRetcode()+" ("+trade.ResultRetcodeDescription()+")");
      Debug(" ################# Close ################ "+"\n"
            +" Global.price_ask : "+(string)Global.price_ask+"\n"
            +" Global.price_last: "+(string)Global.price_last+"\n"
            +" Global.price_bid : "+(string)Global.price_bid+"\n"
            +" Global.spread    : "+(string)Global.spread        );       
                           
     } 
     
    // mecanismo de segurança para ter certeza q a corretora atualizou a posição da trade
    int i=0,j=100000000;
    uint time_init,time_end,time_delay;
    time_init = GetTickCount(); 
    do
      {
       if(!PositionSelect(_Symbol))
         {
          time_end = GetTickCount();
          time_delay = time_end - time_init;
          Debug(" Saida Short, Position: "+(string)PositionSelect(_Symbol)+", Delay: "+(string)time_delay+" Milisec");
          HistorySelect(0, TimeCurrent());
          Global.price_close = HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-1),DEAL_PRICE);
          Debug(" Price_Close: "+(string)Global.price_close);
          Deal_Info();
          break;
         }
       i++; 
      }
    while(i<j);
    
    // caso complete o loop inteiro...
    if(PositionSelect(_Symbol)) 
      {
       Alert(" Saida Short com Latencia Alta!!!!!!! ");
       Debug(" Saida Short com Latencia Alta!!!!!!! ");
      }  
      
  } // fim da CloseShortPosition
  
  

//+------------------------------------------------------------------+




