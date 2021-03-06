//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"

//+------------------------------------------------------------------+
//| SIGMA STRATEGY                                                   |
//+------------------------------------------------------------------+ 
void Estrategia_Sigma()
   {
   // Verificação das condições de negociação   
   if(   PositionSelect(_Symbol) == false
      && Flag.Once == false              )
     {
      // verifica horários permitidos para entrada de operação
      if(   Period() == 5           // 5 = periodo do timeframe
         && Global.timer <= 150 )   // 150 = 2.5 minutos
        {
         if(!Strategy.Simulation) {Dynamic_Information();}     // Debug de informações relevantes
         Sigma();
         return;                    // sai da função e prossegue no mesmo tick
        }
      if(   Period() == 2           // 2 = periodo do timeframe
         && Global.timer <= 60  )   // 60 = 1 minuto
        {
         if(!Strategy.Simulation) {Dynamic_Information();}     // Debug de informações relevantes  
         Sigma();  
         return;                    // sai da função e prossegue no mesmo tick
        }  
      if(   Period() == 15          // 15 = periodo do timeframe
         && Global.timer <= 450  )  // 450 = 2.5 minutos
        {
         if(!Strategy.Simulation) {Dynamic_Information();}     // Debug de informações relevantes
         Sigma();
         return;                    // sai da função e prossegue no mesmo tick  
        }  
     }
   else
     {
      if(   PositionSelect(_Symbol)   == true
         && Signals.TradeSignal_Sigma == true )
        {
         Sigma_SL_SG();
        }
      else
        {
         // Gerenciamento para evitar entradas multiplas
         if(Period() == 15){Sleep(1);}
         if(Period() == 5) {Sleep(1000);}
         if(Period() == 2) {Sleep(1400);} 
         Debug(" Trade em Andamento ou Flag.Once: "+(string)Flag.Once);
         return; 
        }  
     }
     
   }  // fim da Estrategia_Sigma()
   
  
void Sigma()
  {
   //+------------------------------------------------------------------+
   //| COMPRA                                                           |
   //+------------------------------------------------------------------+
   if(   Global.price_last <= Ind.mid_band[0] - Global.sigma_enter * Global.sigma_1
      && Strategy.Simulation == false)
     {Debug(" Entrada Long a Mercado: "+(string)Global.price_last+"\n");}
   // Condições de compra Sigma
   if(   Signals.LongPosition == false
      && Flag.Long_Once       == false
      && Global.price_ask <= Ind.mid_band[0] - Global.sigma_enter * Global.sigma_1 )                                                             
     { 
      // abre posição de compra
      OpenLongPosition();   
      if(Signals.LongPosition == true)
        {
         Signals.TradeSignal_Sigma = true;
         Global.candle_timer = (long)TimeCurrent() + Global.candle_sec - Global.timer;
         
//         Global.fixed_stop   = Ind.mid_band[0] - Global.sigma_dynamic_stop * Global.sigma_1;  
//         Global.Stop_Gain    = Global.price_open + Global.sigma_factor_gain * Global.sigma_1;
//         Global.Stop_Loss    = Global.price_open - Global.sigma_factor_loss * Global.sigma_1;

         Sigma_Factor_SL();
         Global.Stop_Gain    = Global.price_open + Global.sigma_factor * Global.sigma_1;
         Global.Stop_Loss    = Global.price_open - Global.sigma_factor * Global.sigma_1;
         Debug(" Global.sigma_factor: "+(string)Global.sigma_factor);
         
         // definicao do alvo considerando grandes gaps
//         if(Global.Stop_Gain >= Global.fixed_stop)
//           {
//            Global.Stop_Gain = Global.fixed_stop;
//           } 
//         Global.be_long = (Global.price_open + (0.75)*(Global.Stop_Gain - Global.price_open)); 
 
         Debug(" Price_Open: "+(string)Global.price_open); 
         Debug(" Stop_Gain : "+DoubleToString(Global.Stop_Gain,_Digits)); 
         Debug(" Stop_Loss : "+DoubleToString(Global.Stop_Loss,_Digits)+"\n");   
         if(Strategy.Object)
           {
            //--- create sg and sl levels
            if(!HLineCreate_1(0,"Stop_Gain",0,Global.Stop_Gain,clrGreen,STYLE_SOLID,2,false,true,true,0))
              {
               return;
              }    
            if(!HLineCreate_2(0,"Stop_Loss",0,Global.Stop_Loss,clrRed,STYLE_SOLID,2,false,true,true,0))
              {
               return;
              }   
           }                        
        }
      else
        {
         Alert(" Falhou a Tentativa de Entrada!!!");
         return;
        }       
     }
   
   //+------------------------------------------------------------------+
   //| VENDA                                                            |
   //+------------------------------------------------------------------+
   if(   Global.price_last >= Ind.mid_band[0] + Global.sigma_enter * Global.sigma_1
      && Strategy.Simulation == false)
     {Debug(" Entrada Short a Mercado: "+(string)Global.price_last+"\n");}
   // Condições de venda Sigma
   if(   Signals.ShortPosition == false
      && Flag.Short_Once       == false
      && Global.price_bid >= Ind.mid_band[0] + Global.sigma_enter * Global.sigma_1 )
     {
      // abre posição de venda
      OpenShortPosition();
      if(Signals.ShortPosition == true)
        {
         Signals.TradeSignal_Sigma = true;
         Global.candle_timer = (long)TimeCurrent() + Global.candle_sec - Global.timer;
         
//         Global.fixed_stop   = Ind.mid_band[0] + Global.sigma_dynamic_stop * Global.sigma_1;      
//         Global.Stop_Gain    = Global.price_open - Global.sigma_factor_gain * Global.sigma_1;
//         Global.Stop_Loss    = Global.price_open + Global.sigma_factor_loss * Global.sigma_1;
         
         Sigma_Factor_SL();
         Global.Stop_Gain    = Global.price_open - Global.sigma_factor * Global.sigma_1;
         Global.Stop_Loss    = Global.price_open + Global.sigma_factor * Global.sigma_1;
         Debug(" Global.sigma_factor: "+(string)Global.sigma_factor);
         
         // definicao do alvo considerando grandes gaps
//         if(Global.Stop_Gain <= Global.fixed_stop)
//           {
//            Global.Stop_Gain = Global.fixed_stop;
//           } 
//         Global.be_short =  (Global.price_open - (0.75)*(Global.price_open - Global.Stop_Gain));
   
         Debug(" Price_Open: "+(string)Global.price_open); 
         Debug(" Stop_Gain : "+DoubleToString(Global.Stop_Gain,_Digits)); 
         Debug(" Stop_Loss : "+DoubleToString(Global.Stop_Loss,_Digits)+"\n");  
         if(Strategy.Object)
           {   
            //--- create a horizontal line
            if(!HLineCreate_1(0,"Stop_Gain",0,Global.Stop_Gain,clrGreen,STYLE_SOLID,2,false,true,true,0))
              {
               return;
              }    
            if(!HLineCreate_2(0,"Stop_Loss",0,Global.Stop_Loss,clrRed,STYLE_SOLID,2,false,true,true,0))
              {
               return;
              }   
           }                           
        }
      else
        {
         Alert(" Falhou a Tentativa de Entrada!!!");
         return;
        }       
     }
           
  } // fim da Sigma()   

void Sigma_SL_SG()
  {  
   Candle_Flag();    // controle se esta no candle de entrada ou posterior
   
   //+------------------------------------------------------------------+
   //| COMPRA SL e SG                                                   |
   //+------------------------------------------------------------------+
   if(Signals.LongPosition == true)
     {
      // verifica condições de entrada alavancada
      if(Strategy.Leverage) { Leverage_Long();
                              Break_Even_Long(); }

      
      // verificação de saida gain de posição de compra
      if(   Global.price_last >= Global.Stop_Gain
         && (Flag.HV_Open || Flag.LV_Open) )
        { 
         CloseLongPosition();
         Debug(" Stop de Operação Long por Stop_Gain "+"\n");
         Flag.Sigma = true;
         return;
        }   
         

      // verificação de RP de posição de compra 
      if(   Signals.LongPosition
         && Global.price_last >= Ind.mid_band[0] - 2.0 * Global.sigma_1 
         && Flag.RP == false         )
        { 
         Global.contratos = Global.contratos/2;
         OpenShortPosition(); 
         Signals.LongPosition = true;
         Signals.ShortPosition = false;
         Debug(" RP de operação de compra "+"\n");
         Flag.Break_Even = true;
         Flag.RP = true;
         return;
        }   
      if(   Flag.Break_Even == true    
         && Global.price_last <= Global.price_open )
        {
         CloseLongPosition();
         Debug(" Stop de Operação Long por Break Even "+"\n");
         Flag.Sigma = true;
         return;
        }     

 
      // verificação de saida loss de posição de compra 
      if(   Global.price_bid <= Global.Stop_Loss
//         && Flag.Candle_1 == false               
                                                 )
        { 
         CloseLongPosition();
         if(Flag.Candle_1 == true)
           {
            Flag.Long_Once = true;
            Debug(" Flag.Long_Once: "+(string)Flag.Long_Once);
           } 
         Flag.Sigma = true;
         Debug(" Stop de Operação Long por Stop_Loss "+"\n");
         return;
        }  
              
      // saida no candle seguinte por stop dinamico   
      if(   Global.price_last >= Ind.mid_band[0] - Global.sigma_dynamic_stop * Global.sigma_1                                           
//         && Flag.Candle_1 == false  
                                    )
        {
         CloseLongPosition();
         Debug(" Stop de Operação Long por Stop Dinamico no Candle Posterior ");
         Debug(" Global.sigma_dynamic_stop: "+(string)Global.sigma_dynamic_stop+"\n");
         Flag.Sigma = true;
         return;
        }  
       
       // saida por time  
      if(str1.hour == 17)  
        {
         CloseLongPosition();
         Debug(" Stop de Operação Long por Time "+"\n");
         Flag.Sigma = true;
         return;                  
        }     
          
      }   //  fim do if(Signals.LongPosition == true)     
          
   //+------------------------------------------------------------------+
   //| VENDA SL e SG                                                    |
   //+------------------------------------------------------------------+ 
   if(Signals.ShortPosition == true)
     { 
      // verifica condições de entrada alavancada
      if(Strategy.Leverage) { Leverage_Short();
                              Break_Even_Short(); }
      
      // verificação de saida gain de posição de venda  
      if(   Global.price_last <= Global.Stop_Gain
         && (Flag.HV_Open || Flag.LV_Open)        )
        {
         CloseShortPosition();
         Debug(" Stop de Operação Short por Stop Gain "+"\n");
         Flag.Sigma = true;
         return;
        }       

      // verificação de RP de posição de venda 
      if(   Signals.ShortPosition
         && Global.price_last <= Ind.mid_band[0] + 2.0 * Global.sigma_1 
         && Flag.RP == false         )
        { 
         Global.contratos = Global.contratos/2;
         OpenLongPosition(); 
         Signals.LongPosition  = false;
         Signals.ShortPosition = true;
         Debug(" RP de operação de venda "+"\n");
         Flag.Break_Even = true;
         Flag.RP = true;
         return;
        }   
      if(   Flag.Break_Even == true    
         && Global.price_last >= Global.price_open )
        {
         CloseShortPosition();
         Debug(" Stop de Operação Short por Break Even "+"\n");
         Flag.Sigma = true;
         return;
        }    


      // verificação de saida loss de posição de venda 
      if(   Global.price_ask >= Global.Stop_Loss
//         && Flag.Candle_1 == false  
                                                 )
        {
         CloseShortPosition();
         if(Flag.Candle_1 == true)
           {
            Flag.Short_Once = true;
            Debug(" Flag.Short_Once: "+(string)Flag.Short_Once);
           } 
         Flag.Sigma = true;
         Debug(" Stop de Operação Short por Stop_Loss "+"\n");
         return;
        }  
        
      // saida no candle seguinte por stop dinamico     
      if(   Global.price_last <= Ind.mid_band[0] + Global.sigma_dynamic_stop * Global.sigma_1 
//         && Flag.Candle_1 == false  
                                    )
        {
         CloseShortPosition();
         Debug(" Stop de Operação Short por Stop Dinamico "+"\n");
         Debug(" Global.sigma_dynamic_stop: "+(string)Global.sigma_dynamic_stop);
         Flag.Sigma = true;
         return;
        }  
        
      // saida por time  
      if(str1.hour == 17)  
        {
         CloseShortPosition();
         Debug(" Stop de Operação Short por Time "+"\n");
         Flag.Sigma = true;
         return;                  
        }   
        
     }  // fim da if(Signals.ShortPosition == true)            
     
  } // fim da Sigma_SL_SG()
  
 
//+------------------------------------------------------------------+


void Leverage_Long()
  {
   // verificação de saida loss ou aumento de posicao no candle de entrada
   if(   Global.price_last <= Global.Stop_Loss
      && Flag.Candle_1 == true     
      && Flag.Segunda_Entrada == false )
     { 
      // segunda entrada proibida
      if(Global.timer > Global.timer_limit)
        {
         CloseLongPosition();
         Debug(" Stop de Operação Long por Stop_Loss no Candle de Entrada ");
         Debug(" Timer: "+(string)Global.timer);
         Debug(" Global.timer_limit: "+(string)Global.timer_limit);
         Flag.Sigma = true;
         return;
        } 
      // segunda entrada permitida  
      if(Global.timer <= Global.timer_limit)
        {
         // flag e aumento da posição 
         Flag.Segunda_Entrada = true;
         Global.contratos     = 4*Global.contratos;
         if(Strategy.Simulation) {OpenLongPosition();}
         else                    {Increase_LongPosition();}              
         // redefinicao dos parametros do controle de risco
         Global.fixed_stop = Ind.mid_band[0] - Global.sigma_dynamic_stop * Global.sigma_1;
         Global.Stop_Gain  = Global.price_open + Global.sigma_factor_gain * Global.sigma_1;
         Global.Stop_Loss  = Global.price_open - Global.sigma_factor_loss * Global.sigma_1;
         if(Global.Stop_Gain >= Global.fixed_stop)
           {
            Global.Stop_Gain = Global.fixed_stop;
           } 
         // nivel de acionamento do break even  
         Global.be_long = (Global.price_open + (0.75)*(Global.Stop_Gain - Global.price_open));   
         Debug(" Price_Open: "+(string)Global.price_open);   
         if(Strategy.Object)
           { 
            //--- move the stop
            if(HLineMove_1(0,"Stop_Gain",Global.Stop_Gain))
              {
               Debug(" Stop_Gain : "+DoubleToString(Global.Stop_Gain,_Digits));   
              }    
            if(HLineMove_sl(0,"Stop_Loss",Global.Stop_Loss))
              {
               Debug(" Stop_Loss : "+DoubleToString(Global.Stop_Loss,_Digits));   
              } 
           }                                       
        }
     }  
     
   // verificação de saida loss da segunda entrada no candle da entrada
   if(   Global.price_bid <= Global.Stop_Loss
      && Flag.Candle_1 == true     
      && Flag.Segunda_Entrada == true )
     { 
      CloseLongPosition();
      Debug(" Stop da Segunda Entrada Long por Stop_Loss no Candle de Entrada ");
      Flag.Sigma = true;
      return;
     }       
  
  }
  
void Break_Even_Long()
  {
   // SAIDA LONG POR BREAK EVEN 
   if(   Flag.Break_Even == false
      && Flag.Segunda_Entrada == true
      && Global.price_last >= Global.be_long  )   
     { 
      Flag.Break_Even = true;
      Debug(" Break_Even: "+(string)(Global.price_open + 2*Global.pip)+"\n");
      //--- move the stop
      if(!HLineMove_be_Long(0,"Stop_Loss",Global.price_open))
      return;
     }   
   if(   Flag.Break_Even == true    
      && Global.price_last <= Global.price_open + 2*Global.pip )
     {
      CloseLongPosition();
      Debug(" Stop de Operação Long por Break Even ");
      Flag.Sigma = true;
      return;
     }  
  
  }  
  
  
void Leverage_Short()
  {
   // verificação de saida loss ou aumento de posicao no candle de entrada
   if(   Global.price_last >= Global.Stop_Loss
      && Flag.Candle_1 == true     
      && Flag.Segunda_Entrada == false )
     { 
      // segunda entrada proibida
      if(Global.timer > Global.timer_limit)
        {
         CloseShortPosition();
         Debug(" Stop de Operação Short por Stop_Loss no Candle de Entrada ");
         Debug(" Timer: "+(string)Global.timer);
         Debug(" Global.timer_limit: "+(string)Global.timer_limit);
         Flag.Sigma = true;
         return;
        } 
      // segunda entrada permitida  
      if(Global.timer <= Global.timer_limit)
        {
         // flag e aumento da posição
         Flag.Segunda_Entrada = true;
         Global.contratos     = 4*Global.contratos;
         if(Strategy.Simulation) {OpenShortPosition();}
         else                    {Increase_ShortPosition();}                 
         // redefinicao dos parametros do controle de risco   
         Global.fixed_stop = Ind.mid_band[0] + Global.sigma_dynamic_stop * Global.sigma_1;
         Global.Stop_Gain  = Global.price_open - Global.sigma_factor_gain * Global.sigma_1;
         Global.Stop_Loss  = Global.price_open + Global.sigma_factor_loss * Global.sigma_1;      
         if(Global.Stop_Gain <= Global.fixed_stop)
           {
            Global.Stop_Gain = Global.fixed_stop;
           } 
         // nivel de acionamento do break even 
         Global.be_short = (Global.price_open - (0.75)*(Global.price_open - Global.Stop_Gain));  
         Debug(" Price_Open: "+(string)Global.price_open);  
         if(Strategy.Object)
           {  
            //--- move the stop
            if(HLineMove_1(0,"Stop_Gain",Global.Stop_Gain))
              { 
               Debug(" Stop_Gain : "+DoubleToString(Global.Stop_Gain,_Digits));  
              }    
            if(HLineMove_sl(0,"Stop_Loss",Global.Stop_Loss))
              {
               Debug(" Stop_Loss : "+DoubleToString(Global.Stop_Loss,_Digits));   
              } 
           }                                        
        }
     }
     
   // verificação de saida loss da segunda entrada no candle da entrada
   if(   Global.price_ask >= Global.Stop_Loss
      && Flag.Candle_1 == true     
      && Flag.Segunda_Entrada == true )
     { 
      CloseShortPosition();
      Debug(" Stop da Segunda Entrada Short por Stop_Loss no Candle de Entrada ");
      Flag.Sigma = true;
      return;
     }            
  
  }  
  
void Break_Even_Short()
  {
   // SAIDA SHORT POR BREAK EVEN 
   if(   Flag.Break_Even == false
      && Flag.Segunda_Entrada == true
      && Global.price_last <= Global.be_short )   
     { 
      Flag.Break_Even = true;
      Debug(" Break_Even: "+(string)(Global.price_open - 2*Global.pip)+"\n");
      //--- move the stop
      if(!HLineMove_be_Short(0,"Stop_Loss",Global.price_open))
      return;
     }     
   if(   Flag.Break_Even == true    
      && Global.price_last >= Global.price_open - 2*Global.pip )
     {
      CloseShortPosition();
      Debug(" Stop de Operação Short por Break Even ");
      Flag.Sigma = true;
      return;
     } 
  
  }  