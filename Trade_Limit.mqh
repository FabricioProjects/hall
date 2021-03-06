//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"
  
//+------------------------------------------------------------------+
//| Pending Orders                                                   |
//+------------------------------------------------------------------+
void Buy_Limit()
  {
   CTrade  trade;
   int   i=0,j=60000000;
   ulong ticket;
   uint  count_init,count_end,count_delay;   // contagem em milisegundos
   Flag.Execution = false; 
   Debug(" ###################################### ");
   Debug(" Global.price_last: "+(string)Global.price_last);
   Debug(" Global.price_bid : "+(string)Global.price_bid);
   
   if(trade.BuyLimit(Global.contratos,Global.price_last))
     {
      Debug(" BuyLimit() Method Executed Successfully. Return code= "+(string)trade.ResultRetcode());     
      count_init = GetTickCount(); 
      do
        {
         if(PositionSelect(_Symbol))
           {  
            count_end                = GetTickCount();
            count_delay              = count_end - count_init;
            Deal(" ############### LAST DEAL ###############"+"\n"
                 +" Buy_Limit_Execution:    "+(string)count_delay+" milisec");
            Deal_Info();
            Flag.Execution           = true;
            Signals.LongPosition     = true;
            Flag.Once                = true;
            Global.price_open = PositionGetDouble(POSITION_PRICE_OPEN);
            Vox_Control();
            Debug(" Price_Trade_Start: "+(string)Global.price_open+"\n"
                  +" Volume_Last_Deal : "+(string)Global.contratos);   
            break;
           }
         i++; 
        }
      while(i<j);
     
      // caso complete o loop...
      if(Flag.Execution == false)
        {
         // delete the pending order
         int ord_total = OrdersTotal();
         Debug(" Total de Ordens: "+(string)ord_total);
         if(ord_total>0)
           {
            for(int k=ord_total-1;k>=0;k--)
              {
               ticket = OrderGetTicket(k);
               if(trade.OrderDelete(ticket))
                 {
                  Debug(" Pending Order Deleted ");
                  Debug(" Total de Ordens: "+(string)OrdersTotal());
                 } 
               else Debug(" Pending Order NOT Deleted "); 
              } 
           }    
        } 
     }
   else
     {
      Debug(" BuyLimit() Method Failed. Return code= "+(string)trade.ResultRetcode()); 
      Flag.Execution = false;
      return; 
     }     
    
  }  // fim da Buy_Limit()
  

void Sell_Limit()
  {
   CTrade  trade;
   int   i=0,j=60000000;
   ulong ticket;
   uint  count_init,count_end,count_delay;   // contagem em milisegundos
   Flag.Execution = false; 
   Debug(" ###################################### ");
   Debug(" Global.price_ask : "+(string)Global.price_ask);
   Debug(" Global.price_last: "+(string)Global.price_last);
   
   if(trade.SellLimit(Global.contratos,Global.price_last))
     {
      Debug(" SellLimit() Method Executed Successfully. Return code= "+(string)trade.ResultRetcode());     
      count_init = GetTickCount(); 
      do
        {
         if(PositionSelect(_Symbol))
           {  
            count_end                = GetTickCount();
            count_delay              = count_end - count_init;
            Deal(" ############### LAST DEAL ###############"+"\n"
                 +" Sell_Limit_Execution:   "+(string)count_delay+" milisec");
            Deal_Info();
            Flag.Execution           = true;
            Signals.ShortPosition    = true;
            Flag.Once                = true;
            Global.price_open        = PositionGetDouble(POSITION_PRICE_OPEN);
            Vox_Control();
            Debug(" Price_Trade_Start: "+(string)Global.price_open+"\n"
                 +" Volume_Last_Deal : "+(string)Global.contratos);  
            break;
           }
         i++; 
        }
      while(i<j);
     
      // caso complete o loop...
      if(Flag.Execution == false)
        {
         // delete the pending order
         int ord_total = OrdersTotal();
         Debug(" Total de Ordens: "+(string)ord_total);
         if(ord_total>0)
           {
            for(int k=ord_total-1;k>=0;k--)
              {
               ticket = OrderGetTicket(k);
               if(trade.OrderDelete(ticket))
                 {
                  Debug(" Pending Order Deleted ");
                  Debug(" Total de Ordens: "+(string)OrdersTotal());
                 } 
               else Debug(" Pending Order NOT Deleted "); 
              } 
           }  
        } 
     }
   else
     {
      Debug(" SellLimit() Method Failed. Return code= "+(string)trade.ResultRetcode()); 
      Flag.Execution = false;
      return; 
     }
            
    
  }  // fim da Sell_Limit()
//+------------------------------------------------------------------+




