//-------------------------------------------------------------------+
//|                                              Market_Analysis.mq5 |
//|                                            Copyright 2014 - 2016 |
//|                                               by Fabrício Amaral |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014 - 2016, Fabrício Amaral"
#property link      "http://executive.com.br/"
   
//+------------------------------------------------------------------+
//| DATE CONTROL ARQUIVO DE SAIDA                                    |
//+------------------------------------------------------------------+
void Date_Control_File(string texto)
  { 
   Global.filehandle_Date_Control = FileOpen(Global.subfolder+"\\"+MQLInfoString(MQL_PROGRAM_NAME)
                                                      +"_Date_Control.txt",FILE_READ|FILE_WRITE|FILE_CSV);
   if(Global.filehandle_Date_Control != INVALID_HANDLE)
     {
      FileSeek(Global.filehandle_Date_Control,0,SEEK_END);
      FileWrite(Global.filehandle_Date_Control,(string)TimeCurrent()+"   "+texto);    // TimeCurrent() em datetime para validação
//      FileWrite(Global.filehandle_Date_Control,texto);
      FileFlush(Global.filehandle_Date_Control);
      FileClose(Global.filehandle_Date_Control);
     }
   else Alert("Operation FileOpen filehandle_Date_Control failed, error: ",GetLastError() );
        ResetLastError();
   
  }    
   
// controle de dias nao considerados por dias incompletos: str1.hour > 9
void Date_Control_Open()
  {  
   if( str1.hour > 9 )  
     {
      Date_Control_File(" Dia descartado: str1.hour > 9 ");
      Strategy_Manager_False();
     }
  
  }  // fim da Date_Control_Open()
    

//+------------------------------------------------------------------+