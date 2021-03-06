//+------------------------------------------------------------------+
//| RP                                                               |
//+------------------------------------------------------------------+ 
    
   // verificação de RP de posição de compra M15
   if(   Period() == 15
      && Signals.LongPosition
      && price >= Global.Stop_Gain 
      && Flag.RP == false         )
     { 
      Global.contratos = Global.contratos/2;
      OpenShortPosition(); 
      Signals.LongPosition = true;
      Signals.ShortPosition = false;
      Debug(" RP de operação de compra ");
      Flag.Break_Even = true;
      Flag.RP = true;
      //--- move the stop
      if(!HLineMove_be(0,"Stop_Loss",Global.price_trade_start))
      return;
     }          
     
   // verificação de RP de posição de venda M15
   if(   Period() == 15
      && Signals.ShortPosition
      && price <= Global.Stop_Gain 
      && Flag.RP == false         )
     { 
      Global.contratos = Global.contratos/2;
      OpenLongPosition(); 
      Signals.LongPosition = false;
      Signals.ShortPosition = true;
      Debug(" RP de operação de venda ");
      Flag.Break_Even = true;
      Flag.RP = true;
      //--- move the stop
      if(!HLineMove_2(0,"Stop_Loss",Global.price_trade_start))
      return;
     }     

//+------------------------------------------------------------------+
//| MOMENTUM                                                         |
//+------------------------------------------------------------------+  
// controle do panic stop loss de instituições  
bool Momentum_Short()
  {
   long   time_delay = (long(TimeCurrent()) - long(mrate[0].time)); // delay de saturação do price_velocity
   Debug(" Price_Velocity_Buffer >= 3: "+(string)Ind.Price_Velocity_Buffer[0]);
   if(   time_delay >= 3                               // segundos
      && Ind.Price_Velocity_Buffer[0] >= 3 )           // pips
     {
      return(true);
     } 
   return(false);  
  }
  
bool Momentum_Long()
  {
   long   time_delay = (long(TimeCurrent()) - long(mrate[0].time)); // delay de saturação do price_velocity
   Debug(" Price_Velocity_Buffer <= 3: "+(string)Ind.Price_Velocity_Buffer[0]);
   if(   time_delay >= 3                               // segundos
      && Ind.Price_Velocity_Buffer[0] <= 3 )           // pips
     {
      return(true);
     } 
   return(false);  
  }  
  
  
void Sigma_Factor_SL()
  {  
   Global.delta_volat_dynamic = (Global.volat_mean - Ind.BBandwidth_Buffer[0]);
   Global.x                   = (0.2) * (Global.delta_volat_dynamic / Global.delta_volat);
   Global.sigma_factor        = (1 + Global.x);
  } 