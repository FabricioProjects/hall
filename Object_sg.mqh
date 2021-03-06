//+------------------------------------------------------------------+
//|                                                                  |
//|                                            Copyright 2014-2016   |
//|                                             by Fabrício Amaral   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2016, Fabrício Amaral"
#property link      "http://executive.com.br/"

//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate_1(const long            chart_ID=0,        // chart's ID
                   const string          name="Stop_Gain",  // line name
                   const int             sub_window=0,      // subwindow index
                   double                sg=0,              // line stop gain
                   const color           clr=clrGreen,      // line color
                   const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                   const int             width=1,           // line width
                   const bool            back=false,        // in the background
                   const bool            selection=true,    // highlight to move
                   const bool            hidden=true,       // hidden in the object list
                   const long            z_order=0)         // priority for mouse click
  {
//--- set it at the sg
   sg = Global.Stop_Gain;
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,sg))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
    
//+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
bool HLineMove_1(const long   chart_ID=0,   // chart's ID
                 const string name="Stop_Gain", // line name
                 double       sg=0)      // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   sg = Global.Stop_Gain;
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,sg))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool HLineDelete_1(const long   chart_ID=0,   // chart's ID
                   const string name="Stop_Gain") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
   
//+------------------------------------------------------------------+