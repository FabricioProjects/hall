//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"

//+------------------------------------------------------------------+
//| Parametros de entrada                                            |
//+------------------------------------------------------------------+
// Numero do robo
input int  Robo = 1;   // 0 = Genesis   1 = Hall   2 = Nature

//+------------------------------------------------------------------+
//| Pre Defined Structs                                              |
//+------------------------------------------------------------------+
// Interaction between the client terminal and a trade server for sending our trade requests.
MqlTradeRequest     mrequest; 
// As result of a trade request, a trade server returns data about the trade request processing result.
MqlTradeResult      mresult;  
// Before sending a request for a trade operation to a trade server, it is recommended to check it.
MqlTradeCheckResult mcheck; 
// Information about the prices, volumes and spread of each candle. 
MqlRates            mrate[];  
// The date type structure contains eight fields of the int type. 
MqlDateTime         str1;

// ##########################################################################################################
 
//+------------------------------------------------------------------+
//| Strategies managment                                             |
//+------------------------------------------------------------------+
void Strategy_Manager()
  {
   Strategy.Habilitar_Sigma = true;
   Strategy.Simulation      = true;
   Strategy.Debug           = true;
   Strategy.Object          = true;
   Strategy.Leverage        = false;

  }
  
void Strategy_Manager_False()
  {
   Strategy.Habilitar_Sigma = false;
   Strategy.Debug           = false;
   Strategy.Object          = false;
   Strategy.Leverage        = false;
   
  }  
    
//+------------------------------------------------------------------+
//| Signals                                                          |
//+------------------------------------------------------------------+
// Booleanos utilizados nas estrategias e sub-estrategias
void Bool_Init()
  {
   Signals.LongPosition       = false;           
   Signals.ShortPosition      = false;          
   Signals.TradeSignal_Sigma  = false;
   Flag.HV                    = false;  
   Flag.HV_Open               = false;
   Flag.HV_NY                 = false;
   Flag.HV_Tarde              = false; 
   Flag.LV                    = false;
   Flag.LV_Open               = false;
   Flag.LV_NY                 = false;
   Flag.LV_Tarde              = false;
   Flag.Sigma                 = false;
   Flag.Break_Even            = false;
   Flag.RP                    = false;
   Flag.Once                  = false;
   Flag.Segunda_Entrada       = false;
   Flag.First_Tick            = false;
   Flag.Long_Once             = false;
   Flag.Short_Once            = false;

  }

//+------------------------------------------------------------------+
//| Variáveis Globais                                                |
//+------------------------------------------------------------------+
// definição das variaveis globais de inicialização
void Global_Init()
   {
    // identificadores 
    Global.b             = (string)(long)TimeCurrent();
    Global.identificador = MQLInfoString(MQL_PROGRAM_NAME);   
    Global.folder_symbol = _Symbol+"_M"+(string)Period();         
    Global.subfolder     = Global.identificador+"_"+Global.folder_symbol+"_"+Global.b;
    // file handles
    Global.filehandle       = -1;                    
    Global.filehandle_alert = -1;   
    // outros           
    Global.timer_info  = -1;
    Global.timer_limit = (long)((0.667) * Period() * 60);
    Global.candle_sec  = Period() * 60;
   }
  
//+------------------------------------------------------------------+
//| Atribuições Dinamicas                                            |
//+------------------------------------------------------------------+
void Dynamic_Var()
  {    
   // informação do spread para toda a rotina OnTick() 
   Global.price_last = SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   Global.price_ask  = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   Global.price_bid  = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   Global.spread     = MathAbs(Global.price_ask - Global.price_bid);
   Global.sigma_1    = Ind.mid_band[0] - Ind.lower_band[0];          
   Global.timer      = (long)TimeCurrent() - (long)mrate[0].time;

  }


   
// DEFINIÇÕES
//+------------------------------------------------------------------+
//| Strategies managment                                             |
//+------------------------------------------------------------------+
struct Args_Strategy
  {
   bool Habilitar_Sigma;            // habilitação da estrategia sigma  
   bool Simulation;                 // switch do modo simulação e produção
   bool Debug;                      // habilitação do debug
   bool Object;                     // habilitação de objetos no chart
   bool Leverage;
   
  } Strategy;

//+------------------------------------------------------------------+
//| Signals                                                          |
//+------------------------------------------------------------------+
struct Args_Signals
  {
   bool TradeSignal_Sigma;          // sinal de entrada de operação
   bool LongPosition;               // Indica se a posição long esta em aberto (true) ou fechada (false)
   bool ShortPosition;              // Indica se a posição short esta em aberto (true) ou fechada (false)
   
  } Signals;
  
//+------------------------------------------------------------------+
//| Flags                                                            |
//+------------------------------------------------------------------+
struct Args_Flag
  {
   bool Sigma;                      // operação finalizada
   bool HV;                         // regime high volat (9:00 a 17:00)
   bool HV_Open;                    // regime low volat (9:00 a 9:30)
   bool HV_NY;                      // regime low volat (9:30 a 14:00)
   bool HV_Tarde;                   // regime low volat (14:00 a 17:00)
   bool LV;                         // habilitação do regime low volat
   bool LV_Open;                    // regime low volat (9:00 a 9:30)
   bool LV_NY;                      // regime low volat (9:30 a 14:00)
   bool LV_Tarde;                   // regime low volat (14:00 a 17:00)
   bool Break_Even;                 // break even acionado
   bool RP;                         // realização parcial  
   bool Once;                       // proteção para evitar entradas multiplas
   bool Candle_1;                   // sinalizada se o tick está no candle de entrada ou posterior
   bool Segunda_Entrada;            // segunda entrada
   bool Execution;                  // execução de pending orders
   bool First_Tick;                 // atribuições do primeiro tick de mercado
   bool Long_Once;
   bool Short_Once;

  } Flag;  

//+------------------------------------------------------------------+
//| Variáveis Globais                                                |
//+------------------------------------------------------------------+
struct Global_Variables   
  {
   // variáveis datetime
   datetime date1;                  // variaveis globais para uso e manipulação do datetime
   // variáveis string
   string identificador;            // nome do robo
   string b;                        // tempo em unixtime na pasta de saida q contem os arquivos gerados no codigo
   string folder_symbol;            // nome do ativo e timeframe
   string subfolder;                // nome da subpasta do debug
   // variáveis double
   double price_last;               // cotação do ultimo negocio
   double price_ask;                // cotação do ask corrente
   double price_bid;                // cotação do bid corrente
   double spread;                   // spread corrente
   double price_open;               // preço da posição em aberto (seja media ou nao)
   double price_close;              // preço no termino de uma operação
   double Stop_Gain;                // nivel do stop gain 
   double Stop_Loss;                // nivel do stop loss 
   double be_long;                  // nivel de acionamento break even long
   double be_short;                 // nivel de acionamento break even short
   double pip;                      // variação de 1 pip do ativo
   double sigma_1;                  // 1 desvio padrao da MM20
   double sigma_enter;              // desvio padrão da entrada
   double sigma_factor_gain;        // desvio padrao do alvo em relação ao preço de entrada
   double sigma_factor_loss;        // desvio padrao do loss em relação ao preço de entrada
   double sigma_dynamic_stop;       // desvio padrao do stop dinamico nos candles posteriores
   double fixed_stop;               // desvio padrao do stop fixo 
   double volat_mean;               // divisão entre os regimes high volat e low volat
   double volat_min;                // volatilidade minima 
   
   double delta_volat;
   double delta_volat_dynamic;
   double x;
   double sigma_factor;
   // variáveis long
   long   timer;                    // evolução temporal do candle atual em segundos
   long   timer_info;               // evolução temporal do candle atual em segundos
   long   timer_limit;              // limite do timer para a segunda entrada  
   long   candle_sec;               // quantidade de segundos de um candle  
   long   candle_timer;             // unixtame do final do candle
   // variáveis int
   int    contratos;                // numero de contratos
   int    hour,min,sec;             // manipulação de horários
   int    filehandle_deal;          // handle do arquivo de negocios
   int    filehandle;               // handle da saida de debug
   int    filehandle_alert;         // handle da saida de alertas
   int    filehandle_Date_Control;
   
  } Global;


//+------------------------------------------------------------------+




