//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"

//+------------------------------------------------------------------+
//| Debug                                                            |
//+------------------------------------------------------------------+
void Debug(string texto)
  { 
   if(Strategy.Debug)
     {
      Global.filehandle = FileOpen(Global.subfolder+"\\"+MQLInfoString(MQL_PROGRAM_NAME)
                                                   +"_Debug_"+"M"+(string)Period()+".txt",FILE_READ|FILE_WRITE|FILE_CSV);
      if(Global.filehandle!= INVALID_HANDLE)
        {
         FileSeek(Global.filehandle,0,SEEK_END);
         FileWrite(Global.filehandle,(string)TimeCurrent()+texto);
         FileFlush(Global.filehandle);
         FileClose(Global.filehandle);
        }
      else Alert("Operation FileOpen debug failed, error ",GetLastError()); 
      ResetLastError();
     }
   
  }
  
void Debug_Set_Init()
  {
   // abre o arquivo de debug e aloca o set de gerenciamento de estrategias
   if(Strategy.Debug)
    {
     if(Robo == 1)    // Hall
       {      
        Debug(" ################## Inicio do Debug ##################"+"\n"
              +" Robot:                       "+MQLInfoString(MQL_PROGRAM_NAME)+"\n"
              +" Ativo:                       "+_Symbol+"_M"+(string)Period()+"\n"
              +" Habilitar_Sigma:             "+(string)Strategy.Habilitar_Sigma+"\n"
              +" Modo Simulation:             "+(string)Strategy.Simulation+"\n"  
/*              
              +"##### PARAMETROS #####"+"\n"
              +" Global.contratos:                    "+Global.contratos+"\n" 
              +" Global.pip:                          "+Global.pip+"\n" 
              +" Global.sigma_enter:                  "+Global.sigma_enter+"\n" 
              +" Global.sigma_factor_gain:            "+Global.sigma_factor_gain+"\n" 
              +" Global.sigma_factor_loss:            "+Global.sigma_factor_loss+"\n" 
              +" Global.sigma_dynamic_stop:           "+Global.sigma_dynamic_stop+"\n" 
              +" Global.volat_mean:                   "+Global.volat_mean+"\n" 
              +" Global.volat_min:                    "+Global.volat_min+"\n"
*/                               
                                                                                           );
       }          
           
    }
        
   // abre o arquivo de alertas
   Debug_Alert(" Inicio do Alert - Robô: "+MQLInfoString(MQL_PROGRAM_NAME)+" - Ativo: "+Symbol() );
     
  }  // fim da Debug_Set_Init()
  
//+------------------------------------------------------------------+
//| Alerts                                                           |
//+------------------------------------------------------------------+
void Debug_Alert(string texto)
  {
   Global.filehandle_alert = FileOpen(Global.subfolder+"\\"+MQLInfoString(MQL_PROGRAM_NAME)
                                                      +"_Alert_"+"M"+(string)Period()+".txt",FILE_READ|FILE_WRITE|FILE_CSV);
   if(Global.filehandle_alert!= INVALID_HANDLE)
     {
      FileSeek(Global.filehandle_alert,0,SEEK_END);
      FileWrite(Global.filehandle_alert,(string)TimeCurrent()+texto);
      FileFlush(Global.filehandle_alert);
      FileClose(Global.filehandle_alert);
     }
   else Alert("Operation FileOpen alert failed, error: ",GetLastError() );
        ResetLastError();
   
   }  // fim da Debug_Alert



//+------------------------------------------------------------------+