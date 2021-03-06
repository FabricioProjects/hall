//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"

//+------------------------------------------------------------------+
//| Miscelânea                                                       |
//+------------------------------------------------------------------+
void Data_Synchro()
  {
   // Verificação de disponibilidade de barras.
   int bars = Bars(_Symbol,PERIOD_CURRENT);
   if(bars > 0)
     { 
      // voz de inicialização
      PlaySound("hall_init");
//      Debug(" Number of bars for the symbol "+_Symbol+"_M"+(string)Period()+" at the moment = "+(string)bars);       
     }
   else  // Sem barras disponíveis
     {
      // Dados sobre o ativo podem não estar sincronizados com os dados no servidor
      bool synchronized = false;
      // Contador de loop
      int attempts = 0;
      // Faz 5 tentativas de espera por sincronização
      while(attempts < 5)
        {
         if(SeriesInfoInteger(_Symbol,0,SERIES_SYNCHRONIZED))
           {
            // Sincronização feita, sair
            synchronized = true;
            break;
           }
         // Aumentar o contador
         attempts++;
         // Espera 10 milissegundos até a próxima iteração
         Sleep(10);
        }
      // Sair do loop após sincronização
      if(synchronized)
        {
         Alert(" Number of bars for the symbol-period 15/5 at the moment = "+(string)bars); 
         Alert("The first date in the terminal history for the symbol-period at the moment = "+
              (string)(datetime)SeriesInfoInteger(_Symbol,0,SERIES_FIRSTDATE));     
         Alert("The first date in the history for the symbol on the server = "+
              (string)(datetime)SeriesInfoInteger(_Symbol,0,SERIES_SERVER_FIRSTDATE));  
        }
      // Sincronização dos dados não aconteceu
      else
        {
         Alert(" Failed to get number of bars for "+_Symbol);   
        }
     }
   
   // Do we have sufficient bars to work?
   if(bars < 61) // total number of bars is less than 61?
     {
      Alert(" We have less than 61 bars on the chart, an Expert Advisor terminated!! ");   
     }
  }
  
//+------------------------------------------------------------------+
//| UNIXTIME FIRST TICK                                              |
//+------------------------------------------------------------------+   
// atribuições no primeiro tick
void Hall_First_Tick()
  {
   // primeiro tick do dia
   if(   str1.hour >= 9
      && str1.hour <  17  )    
     {
      if(Strategy.Simulation)
        {
         Strategy_Manager();
         Date_Control_Open();    
        }                 
      Flag.First_Tick = true;
      Flag.Long_Once  = false;
      Flag.Short_Once = false;
      Flag.HV_Open    = false;
      Flag.HV_NY      = false;
      Flag.HV_Tarde   = false;
      Flag.LV_Open    = false;
      Flag.LV_NY      = false;
      Flag.LV_Tarde   = false;
      Debug(" Flag.First_Tick: "+(string)Flag.First_Tick+"\n");
      // Gerenciamento para evitar entradas multiplas
      if(!Strategy.Simulation)
        {
         if(Period() == 15){Sleep(1);}
         if(Period() == 5) {Sleep(1000);}
         if(Period() == 2) {Sleep(1400);}    
        }                   
     }
      
  }  // fim da Hall_First_Tick()    
  
  
//+------------------------------------------------------------------+
//| RESET                                                            |
//+------------------------------------------------------------------+   
// reset apos finalizar uma operação  
void Reset_Trade()
  {
     Signals.LongPosition       = false;    
     Signals.ShortPosition      = false;    
     Signals.TradeSignal_Sigma  = false;
     Flag.Break_Even            = false;
     Flag.Segunda_Entrada       = false;
     Flag.RP                    = false;
     if(Strategy.Simulation)
       {
        Flag.Sigma    = false;
        Flag.Once     = false;
        Flag.HV_Open  = false;
        Flag.HV_NY    = false;
        Flag.HV_Tarde = false;
        Flag.LV_Open  = false;
        Flag.LV_NY    = false;
        Flag.LV_Tarde = false;
        if(Strategy.Object)
           {   
            //--- delete a horizontal line
            if(   !HLineDelete_1(0,"Stop_Gain")
               || !HLineDelete_2(0,"Stop_Loss") )
              {
               Debug( " failed to delete a horizontal line! ");
              } 
           }       
       }
     else
       {  
        Debug(" Operacao finalizada: Expert Removed ");  
        Alert(" Operacao finalizada: Expert Removed ");  
        ExpertRemove(); return;  // remove o EA apos finalizar uma operação
       } 
  }  
  
void Reset_First_Tick()
  {
   if(str1.hour == 17 && str1.min >= 1)  
     {
      Flag.First_Tick = false;                  
     } 
     
  } // fim da First_Tick_Reset()  
  
//+------------------------------------------------------------------+
//| INFORMAÇÃO DINÂMICA                                              |
//+------------------------------------------------------------------+    
// monitoramento da proximidade do preço atual em relação a entrada prevista  
void Dynamic_Information()
  {
   double diff_down = (Ind.mid_band[0] - Global.sigma_enter * Global.sigma_1);
   double diff_up   = (Ind.mid_band[0] + Global.sigma_enter * Global.sigma_1);
   
   // somente uma saida por segundo
   if(Global.timer_info == Global.timer) return;
   
   // monitoramento da proximidade do preço atual em relação a entrada prevista
   if(mrate[0].close <= Ind.mid_band[0])
     {
      int a = (int)(NormalizeDouble(mrate[0].close - diff_down,0)/Global.pip);
      if(a <= 9) Debug(" Aprox. "+(string)a+" Pips"+"  Timer(s): "+(string)Global.timer);
     }
   else
     {
      int b = (int)(NormalizeDouble(diff_up - mrate[0].close,0)/Global.pip);
      if(b <= 9) Debug(" Aprox. "+(string)b+" Pips"+"  Timer(s): "+(string)Global.timer);
     } 
   Global.timer_info = Global.timer;  
   
  }  // fim da Dynamic_Information()  
 
//+------------------------------------------------------------------+
//| CONTROLE DE VOZ                                                  |
//+------------------------------------------------------------------+    
void Vox_Control()                    //  ##Trade##
  {
   switch(Period())
     {
      case 5 :
         if(_Symbol == "WINV16")PlaySound("enter_win_5");
         if(_Symbol == "WDOV16")PlaySound("enter_wdo_5");
         break;
      case 2 :
         if(_Symbol == "WINV16")PlaySound("enter_win_2");
         if(_Symbol == "WDOV16")PlaySound("enter_wdo_2");
         break;
      case 15:
         if(_Symbol == "WINV16")PlaySound("enter_win_15");
         if(_Symbol == "WDOV16")PlaySound("enter_wdo_15");
         break;
     }
  }

//+------------------------------------------------------------------+
//| CONTROLE DE HORARIOS                                             |
//+------------------------------------------------------------------+  
void Time_Control_HV()                    
  {  
   // controle de horario HV_Open
   if(   str1.hour == 09 && str1.min < 30
      && Flag.HV_Open == false           )
     { 
      Flag.HV_Open  = true;
      Symbol_Def_HV_Open();
      Debug(" ######## HIGH_VOLAT_OPEN ");
      Var_Set();
      return; 
     }  
   // controle de horario HV_NY 
   if(   (   (str1.hour == 09 && str1.min  >= 30) 
          || (str1.hour >  09 && str1.hour <  14))
      && Flag.HV_NY == false                      )
     { 
      Flag.HV_NY = true;
      Symbol_Def_HV_NY();
      Debug(" ######## HIGH_VOLAT_NY ");
      Var_Set();
      return;  
     }   
   // controle de horario HV_Tarde 
   if(   (   str1.hour >= 14  
          && str1.hour <  17)
      && Flag.HV_Tarde == false )
     { 
      Flag.HV_Tarde = true;
      Symbol_Def_HV_Tarde();
      Debug(" ######## HIGH_VOLAT_TARDE ");
      Var_Set();
      return; 
     }    
   // final do pregão 
   if(!Strategy.Simulation)
     {
      if(str1.hour >= 17 )
        { 
         Flag.Sigma = true;
         Debug(" Final do Pregao: Expert Removed ");
         Alert(" Final do Pregao: Expert Removed ");
         ExpertRemove(); return;  
        } 
     }         
   
  }  // fim da Time_Control_HV() 

void Time_Control_LV()                    
  {
   // controle de horario LV_Open
   if(   str1.hour == 09 && str1.min < 30
      && Flag.LV_Open == false           )
     { 
      Flag.LV_Open  = true;
      Symbol_Def_LV_Open();
      Debug(" ######## LOW_VOLAT_OPEN ");
      Var_Set();
      return; 
     }  
   // controle de horario LV_NY 
   if(   (   (str1.hour == 09 && str1.min  >= 30) 
          || (str1.hour >  09 && str1.hour <  14))
      && Flag.LV_NY == false                      )
     { 
      Flag.LV_NY = true;
      Symbol_Def_LV_NY();
      Debug(" ######## LOW_VOLAT_NY ");
      Var_Set();
      return;  
     }   
   // controle de horario LV_Tarde 
   if(   (   str1.hour >= 14  
          && str1.hour <  17)
      && Flag.LV_Tarde == false )
     { 
      Flag.LV_Tarde = true;
      Symbol_Def_LV_Tarde();
      Debug(" ######## LOW_VOLAT_TARDE ");
      Var_Set();
      return; 
     }  
   // final do pregão 
   if(!Strategy.Simulation)
     {
      if(str1.hour >= 17 )
        { 
         Flag.Sigma = true;
         Debug(" Final do Pregao: Expert Removed ");
         Alert(" Final do Pregao: Expert Removed ");
         ExpertRemove(); return;  
        }
     }           
   
  }  // fim da Time_Control_LV() 
  
//+------------------------------------------------------------------+
//| CONTROLE DOS REGIMES DE VOLATILIDADE                             |
//+------------------------------------------------------------------+ 
void Volat_Regime_Control()                    
  {
   // controle de divisao dos regimes
   if(Ind.BBandwidth_Buffer[1] > Global.volat_mean)
     { 
      Flag.HV = true;
      Flag.LV = false;
      return;  
     } 
   if(   Ind.BBandwidth_Buffer[1] <= Global.volat_mean 
      && Ind.BBandwidth_Buffer[1] >  Global.volat_min  
                                                       )
     { 
      Flag.HV = false;
      Flag.LV = true;
      return;  
     }     
   if(Ind.BBandwidth_Buffer[1] <=  Global.volat_min)
     { 
      Flag.HV = false;
      Flag.LV = false;
      return;  
     }        
  }  // fim da Volat_Regime_Control()
  
void Flag_Reset()                    
  {
   // controle de transição entre os regimes
   if(Global.timer == 0 || Global.timer == 1)
     {
      if(   (   Ind.BBandwidth_Buffer[1] > Global.volat_mean
             && Ind.BBandwidth_Buffer[2] < Global.volat_mean )
         || (   Ind.BBandwidth_Buffer[1] > Global.volat_min
             && Ind.BBandwidth_Buffer[2] < Global.volat_min  )
         || (   Ind.BBandwidth_Buffer[1] < Global.volat_mean
             && Ind.BBandwidth_Buffer[2] > Global.volat_mean )  )
        { 
         Flag.HV_Open   = false;
         Flag.HV_NY     = false;
         Flag.HV_Tarde  = false;
         Flag.LV_Open   = false;
         Flag.LV_NY     = false;
         Flag.LV_Tarde  = false;
         Debug(" Troca de Regime ");
         Debug(" Ind.BBandwidth_Buffer[1]: "+(string)NormalizeDouble(Ind.BBandwidth_Buffer[1],2));
         Debug(" Ind.BBandwidth_Buffer[2]: "+(string)NormalizeDouble(Ind.BBandwidth_Buffer[2],2));
         Sleep(2200);
         Debug(" Sleep(2200) ");
         
        } 
      }  
   }    

void Var_Set()
  {
   Debug(
          " ######## PARAMETROS "+"\n"
         +" Global.contratos:            "+(string)Global.contratos+"\n" 
         +" Global.pip:                  "+(string)Global.pip+"\n" 
         +" Global.sigma_enter:          "+(string)Global.sigma_enter+"\n" 
         +" Global.sigma_factor_gain:    "+(string)Global.sigma_factor_gain+"\n" 
         +" Global.sigma_factor_loss:    "+(string)Global.sigma_factor_loss+"\n" 
         +" Global.sigma_dynamic_stop:   "+(string)Global.sigma_dynamic_stop+"\n" 
         +" Global.volat_mean:           "+(string)Global.volat_mean+"\n" 
         +" Global.volat_min:            "+(string)Global.volat_min+"\n"                 
                                                                                 );  
  }  // fim da Var_Set()   

//+------------------------------------------------------------------+
//| CONTROLE DO CANDLE DE ENTRADA OU POSTERIOR                       |
//+------------------------------------------------------------------+    
void Candle_Flag()
  {
   if((long)TimeCurrent() >  Global.candle_timer){Flag.Candle_1 = false;}
   if((long)TimeCurrent() <= Global.candle_timer){Flag.Candle_1 = true;}
  }  

//+------------------------------------------------------------------+
//| CONTROLE DINAMICO DO STOP LOSS                                   |
//+------------------------------------------------------------------+   
// 0.2 => volatilidade minima começa com 1 + 0.2 = 1.2 sigma sl 
void Sigma_Factor_SL()
  {  
   Global.delta_volat_dynamic = (Global.volat_mean - Ind.BBandwidth_Buffer[0]);
   Global.x                   = (0.2) * (Global.delta_volat_dynamic / Global.delta_volat);
   Global.sigma_factor        = (1 + Global.x);
  } 
    
//+------------------------------------------------------------------+
//| DEFINIÇÕES QUE DEPENDEM DO ATIVO                                 |
//+------------------------------------------------------------------+   
void Symbol_Def_Volat()
  {
   //  ############################## mini indice ########################################
   // M5
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.volat_mean         = -0.4;   // separação entre os regimes LV e HV
      Global.volat_min          = -1.2;   // regime de volatilidade muito baixa
      Global.delta_volat        = (Global.volat_mean - Global.volat_min);
     } 
   // M2  
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.volat_mean         = -0.84;   // separação entre os regimes LV e HV
      Global.volat_min          = -1.9;   // regime de volatilidade muito baixa
      Global.delta_volat        = (Global.volat_mean - Global.volat_min);
     } 
   // M15  
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.volat_mean         = 0.16;   // separação entre os regimes LV e HV
      Global.volat_min          = -0.4;   // regime de volatilidade muito baixa
      Global.delta_volat        = (Global.volat_mean - Global.volat_min);
     }       

   //  ############################## mini dolar ########################################  
   // M5
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.volat_mean         = -0.68;   // separação entre os regimes LV e HV
      Global.volat_min          = -1.57;   // regime de volatilidade muito baixa
      Global.delta_volat        = (Global.volat_mean - Global.volat_min);
     } 
   // M2  
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.volat_mean         = -1.1;   // separação entre os regimes LV e HV
      Global.volat_min          = -2.25;   // regime de volatilidade muito baixa
      Global.delta_volat        = (Global.volat_mean - Global.volat_min);
     } 
   // M15  
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.volat_mean         = -0.15;   // separação entre os regimes LV e HV
      Global.volat_min          = -0.73;   // regime de volatilidade muito baixa
      Global.delta_volat        = (Global.volat_mean - Global.volat_min);
     }       
                           
  }  // fim da Symbol_Def_Volat()

void Symbol_Def_HV_Open()
  {
   //  ############################## mini indice ########################################
   // M5 HV_Open
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.64;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 HV_Open 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.75;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 HV_Open 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // M15: precisa ser par
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.6;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       

   //  ############################## mini dolar ########################################  
   // M5 HV_Open
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.85;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 HV_Open 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.94;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 HV_Open 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // ### M15: precisa ser par
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 3.19;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.0;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 1.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       
                           
  }  // fim da Symbol_Def_HV_Open()
  
void Symbol_Def_HV_NY()
  {
   //  ############################## mini indice ########################################
   // M5 HV_NY
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.64;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 HV_NY 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.75;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 HV_NY 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // M15: precisa ser par
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.6;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       

   //  ############################## mini dolar ########################################  
   // M5 HV_NY
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.85;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 HV_NY 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.94;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 HV_NY 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // ### M15: precisa ser par
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.43;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.0;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 1.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       
                           
  }  // fim da Symbol_Def_HV_NY()  
  
void Symbol_Def_HV_Tarde()
  {
   //  ############################## mini indice ########################################
   // M5 HV_Tarde
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.64;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 HV_Tarde 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.75;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 HV_Tarde 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // M15: precisa ser par
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.6;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       

   //  ############################## mini dolar ########################################  
   // M5 HV_Tarde
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.85;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 HV_Tarde 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.94;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 HV_Tarde 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // ### M15: precisa ser par
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.3;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.0;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 1.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       
                           
  }  // fim da Symbol_Def_HV_Tarde()  

void Symbol_Def_LV_Open()
  {
   //  ############################## mini indice ########################################
   // M5 LV_Open
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 100.0;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 LV_Open 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 100.0;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 LV_Open 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // M15: precisa ser par
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 100.0;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       

   //  ############################## mini dolar ########################################  
   // M5 LV_Open
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 100.0;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 LV_Open  
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 100.0;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 LV_Open 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // ### M15: precisa ser par
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 3.57;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.0;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 1.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       
                           
  }  // fim da Symbol_Def_LV_Open()
   
void Symbol_Def_LV_NY()               
  {
   //  ############################## mini indice ########################################
   // M5 LV_NY
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.9;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 LV_NY 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 3.1;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 LV_NY 
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // M15: precisa ser par
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.65;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       

   //  ############################## mini dolar ########################################  
   // M5 LV_NY
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.75;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 LV_NY 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.9;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 LV_NY  
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // ### M15: precisa ser par
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.58;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.0;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 1.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       
                           
  }  // fim da Symbol_Def_LV_NY()  
   
void Symbol_Def_LV_Tarde()               
  { 
   //  ############################## mini indice ########################################
   // M5 LV_Tarde
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 5       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.75;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 LV_Tarde  
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 2       )
     {
      Global.contratos          = 2;       // numero de contratos em negociações reais
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 3.5;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 LV_Tarde  
   if((   _Symbol == "WINV16"
       || _Symbol == "WIN$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // M15: precisa ser par
      Global.pip                = 5;       // variação de 1 pip do ativo
      Global.sigma_enter        = 2.65;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       

   //  ############################## mini dolar ########################################  
   // M5 LV_Tarde
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 5       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.75;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M2 LV_Tarde 
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 2       )
     {
      Global.contratos          = 1;       // numero de contratos em negociações reais
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 3.45;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.1;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 2.1;     // desvio padrao do stop dinamico nos candles posteriores
     } 
   // M15 LV_Tarde  
   if((   _Symbol == "WDOV16"
       || _Symbol == "WDO$D")
      && Period() == 15       )
     {
      Global.contratos          = 2;       // ### M15: precisa ser par
      Global.pip                = 0.5;     // variação de 1 pip do ativo
      Global.sigma_enter        = 2.48;     // desvio padrão da entrada
      Global.sigma_factor_gain  = 1.0;     // desvio padrao do alvo em relação ao preço de entrada
      Global.sigma_factor_loss  = 1.0;     // desvio padrao do loss em relação ao preço de entrada
      Global.sigma_dynamic_stop = 1.1;     // desvio padrao do stop dinamico nos candles posteriores
     }       
                           
  }  // fim da Symbol_Def_LV_Tarde()  
  
  
//+------------------------------------------------------------------+
//| SLEEP FORÇADO                                                    |
//+------------------------------------------------------------------+   
// sleep forçado pois a função Sleep() não para a rolagem de ticks
void Force_Sleep(uint k)
  {
   int i=0,j=900000000;
   uint count_init,count_end,count_delay;
   count_init = GetTickCount();
   do
     {  
      count_end = GetTickCount();
      count_delay = count_end - count_init;  
      if(count_delay >= k){break;}    
      i++; 
     }
   while(i<j);
   Debug(" Force_Sleep "+_Symbol+"_M"+(string)Period()+" Delay: "+(string)count_delay+" Milisec"+"\n"); 
  
  }  // fim da Force_Sleep(uint k)
    
                                                                                                   
//+------------------------------------------------------------------+
//| ACCOUNT INFO                                                     |
//+------------------------------------------------------------------+
void AccountInfo()
  {
//--- object for working with the account
   CAccountInfo account;
//--- receiving the account number, the Expert Advisor is launched at
   long login=account.Login();
   Debug(" Login= "+(string)login);
//--- clarifying account type
   ENUM_ACCOUNT_TRADE_MODE account_type=account.TradeMode();
//--- if the account is real, the Expert Advisor is stopped immediately!
   if(account_type==ACCOUNT_TRADE_MODE_REAL)
     {
//      MessageBox("The Expert Advisor has been launched on a real account!");
      Debug(" The Expert Advisor has been launched on a real account!");
//      return(-1);
     }
//--- displaying the account type    
   Debug(" Account type: "+EnumToString(account_type));
//--- clarifying if we can trade on this account
   if(account.TradeAllowed())
      Debug(" Trading on this account is allowed");
   else
      Debug(" Trading on this account is forbidden: you may have entered using the Investor password");
//--- clarifying if we can use an Expert Advisor on this account
   if(account.TradeExpert())
      Debug(" Automated trading on this account is allowed");
   else
      Debug(" Automated trading using Expert Advisors and scripts on this account is forbidden");
//--- clarifying if the permissible number of orders has been set
   int orders_limit=account.LimitOrders();
   if(orders_limit!=0)Debug(" Maximum permissible amount of active pending orders: "+(string)orders_limit);
//--- displaying company and server names
   Debug(" "+account.Company()+" : server "+account.Server());
//--- displaying balance and current profit on the account in the end
   Debug(" Balance= "+(string)account.Balance()+"  Profit= "+(string)account.Profit()+"   Equity= "+(string)account.Equity());
   Debug(" "+__FUNCTION__+"  completed"+"\n"); //---
  }       
  
//+------------------------------------------------------------------+
//| SYMBOL INFO                                                      |
//+------------------------------------------------------------------+
void SymbolInfo()
  {
//--- object for receiving symbol settings
   CSymbolInfo symbol_info;
//--- set the name for the appropriate symbol
   symbol_info.Name(_Symbol);
//--- receive current rates and display
   symbol_info.RefreshRates();
   Debug(" "+symbol_info.Name()+" ("+symbol_info.Description()+")"+
         "  Bid= "+(string)symbol_info.Bid()+"   Ask= "+(string)symbol_info.Ask());
//--- receive minimum freeze levels for trade operations
   Debug(" StopsLevel= "+(string)symbol_info.StopsLevel()+" pips, FreezeLevel= "+
         (string)symbol_info.FreezeLevel()+" pips");
//--- receive the number of decimal places and point size
   Debug(" Digits= "+(string)symbol_info.Digits()+
         ", Point= "+DoubleToString(symbol_info.Point(),symbol_info.Digits()));
//--- spread info
   Debug(" SpreadFloat="+(string)symbol_info.SpreadFloat()+", Spread(current)= "+
         (string)symbol_info.Spread()+" pips");
//--- request order execution type for limitations
   Debug(" Limitations for trade operations: "+EnumToString(symbol_info.TradeMode())+
         " ("+symbol_info.TradeModeDescription()+")");
//--- clarifying trades execution mode
   Debug(" Trades execution mode: "+EnumToString(symbol_info.TradeExecution())+
         " ("+symbol_info.TradeExecutionDescription()+")");
//--- clarifying contracts price calculation method
   Debug(" Contract price calculation: "+EnumToString(symbol_info.TradeCalcMode())+
         " ("+symbol_info.TradeCalcModeDescription()+")");
//--- sizes of contracts
   Debug(" Standard contract size: "+(string)symbol_info.ContractSize()+
         " ("+symbol_info.CurrencyBase()+")");
//--- minimum and maximum volumes in trade operations
   Debug(" Volume info: LotsMin= "+(string)symbol_info.LotsMin()+"  LotsMax= "+(string)symbol_info.LotsMax()+
         "  LotsStep= "+(string)symbol_info.LotsStep());
//--- Account margin mode 
   ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE); 
   //--- Now transform the value of  the enumeration into an understandable form 
   string trade_mode; 
   switch(margin_mode) 
     { 
      case  ACCOUNT_MARGIN_MODE_RETAIL_NETTING: 
         trade_mode="ACCOUNT_MARGIN_MODE_RETAIL_NETTING"; 
         Debug(" trade_mode: "+trade_mode); 
         break; 
      case  ACCOUNT_MARGIN_MODE_EXCHANGE: 
         trade_mode="ACCOUNT_MARGIN_MODE_EXCHANGE"; 
         Debug(" trade_mode: "+trade_mode); 
         break; 
      case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING: 
         trade_mode="ACCOUNT_MARGIN_MODE_RETAIL_HEDGING"; 
         Debug(" trade_mode: "+trade_mode); 
         break; 
     }      
//--- 
   Debug(" "+__FUNCTION__+"  completed"+"\n");
//---
   }
   
   
   
   
//+------------------------------------------------------------------+