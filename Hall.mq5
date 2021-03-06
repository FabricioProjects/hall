//-------------------------------------------------------------------+
//|                                                 Hall_Sigma.mq5   |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014 - 2016, Fabrício Amaral"
#property link      "http://executive.com.br/"
#property version   "1.1"

// Standard Libraries
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
// Hall Libraries
#include "Args.mqh"
#include "Trade.mqh"
//#include "Trade_Limit.mqh"
#include "Debug.mqh"
#include "Indicators.mqh"
#include "Misc.mqh"
// Estrategias
#include "Sigma.mqh"
// Objetos
#include "Object_sg.mqh"
#include "Object_sl.mqh"
// Controle de Datas
#include "Date_Control.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
// definições globais, feitas somente uma vez
int OnInit()
  { 
   // Gerenciamento de estrategias e sub-estrategias.        ##Args##            
   Strategy_Manager();   
   // Booleanos Signal.                                      ##Args##
   Bool_Init();  
   // Definição das variáveis globais.                       ##Args##        
   Global_Init(); 
   // Disponibilidade de barras e sincronização.             ##Misc##
   Data_Synchro();   
   // Call, Indexação, Séries - indicadores.                 ##Indicators##     
   Indicators_Hall();                             
   // Dados sobre a conta, ativo                             ##Misc##
//   AccountInfo();     
//   SymbolInfo(); 
   // Inicialização do set de arquivos que compôe o Debug.   ##Debug##    
   Debug_Set_Init();  
   // Definicao do regime de volatilidade 
   Symbol_Def_Volat();

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Indicators_Release();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {  
  // tempo do tick em datetime para toda a rotina OnTick()  
  TimeToStruct(Global.date1 = TimeCurrent(),str1); 
  // reset da flag do first tick
  Reset_First_Tick();
  // atribuição dos buffers para toda a OnTick()      
  Buffers();                                             //  ##Indicators##
  // atribuição das variaveis dinamicas
  Dynamic_Var();                                         //  ##Args##
  
  if(Flag.First_Tick == true)
    {   
     // operação finalizada no tick anterior 
     if(Flag.Sigma == true)
       {
        Reset_Trade();                                   //  ##Misc##
       }  
     // operação não finalizada no tick anterior
     if(Flag.Sigma == false)
       {
        //+------------------------------------------------------------------+
        //| CONTROLE DE HORARIOS E REGIME DE VOLATILIDADE                    |
        //+------------------------------------------------------------------+ 
        if(Signals.TradeSignal_Sigma == false)
          {
           // monitoramento de troca de regime
           Flag_Reset();                                 //  ##Misc##
           // seleciona o regime de volatilidade
           Volat_Regime_Control();                       //  ##Misc##
           // regime High_Volat
           if(Flag.HV == true && Flag.LV == false)
             {
              Time_Control_HV();                         //  ##Misc##
             }
           // regime Low_Volat  
           if(Flag.LV == true && Flag.HV == false)
             {
              Time_Control_LV();                         //  ##Misc##
             }  
          }
        
        // verificação de volatilidade muito baixa  
        if(Flag.LV == false && Flag.HV == false) return;
        
        // verificação de spread anormal
        if(Global.spread > 4*Global.pip)
          {Debug_Alert(" Global.spread: "+(string)Global.spread); return;}
          
        //+------------------------------------------------------------------+
        //| ESTRATÉGIA SIGMA                                                 |
        //+------------------------------------------------------------------+                                                
        if(   Strategy.Habilitar_Sigma == true 
           && Flag.Sigma == false             )
          {  
           Estrategia_Sigma();                           //  ##Sigma## 
          }   
       } // fim da if(Flag.Sigma == false)
        
    } 
  else {Hall_First_Tick();}                              //  ##Misc##
    
 } // fim da OnTick()




  