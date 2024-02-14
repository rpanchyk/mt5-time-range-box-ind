//+------------------------------------------------------------------+
//|                                                 TimeRangeBox.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, rpanchyk"
#property link      "https://github.com/rpanchyk"
#property version   "1.00"
#property description "Indicator shows predefined time ranges,"
#property description "limited by calculated highest and lowest price"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1

// includes
#include <Object.mqh>
#include <arrays/arrayobj.mqh>

enum ENUM_TIME_ZONE
  {
   TZauto = 99, // auto
   TZp12 = 12, // +12
   TZp11 = 11, // +11
   TZp10 = 10, // +10
   TZp9 = 9, // +9
   TZp8 = 8, // +8
   TZp7 = 7, // +7
   TZp6 = 6, // +6
   TZp5 = 5, // +5
   TZp4 = 4, // +4
   TZp3 = 3, // +3
   TZp2 = 2, // +2
   TZp1 = 1, // +1
   TZzero = 0, // 0 (GMT)
   TZm1 = -1, // -1
   TZm2 = -2, // -2
   TZm3 = -3, // -3
   TZm4 = -4, // -4
   TZm5 = -5, // -5
   TZm6 = -6, // -6
   TZm7 = -7, // -7
   TZm8 = -8, // -8
   TZm9 = -9, // -9
   TZm10 = -10, // -10
   TZm11 = -11, // -11
   TZm12 = -12 // -12
  };

enum ENUM_BORDER_STYLE
  {
   BORDER_STYLE_SOLID = STYLE_SOLID, // Solid
   BORDER_STYLE_DASH = STYLE_DASH // Dash
  };

//+------------------------------------------------------------------+
//| Time Range Config                                                |
//+------------------------------------------------------------------+
class Config : public CObject
  {
public:
                     Config(
      int            id,
      int            startHour,
      int            startMinute,
      int            endHour,
      int            endMinute,
      color          colour
   ) :
                     m_Id(id),
                     m_StartHour(startHour),
                     m_StartMinute(startMinute),
                     m_EndHour(endHour),
                     m_EndMinute(endMinute),
                     m_Color(colour)
     {}
                    ~Config() {}
   static Config*    Parse(int id, string config)
     {
      string range[];
      int rangeSize = StringSplit(config, StringGetCharacter("_", 0), range);
      if(rangeSize != 3)
        {
         PrintFormat("Error: range [%i] with config [%s] has unacceptable format", id, config);
         return NULL;
        }

      string startTime[];
      int startTimeSize = StringSplit(range[0], StringGetCharacter(":", 0), startTime);
      if(startTimeSize != 2)
        {
         PrintFormat("Error: range [%i] with start time [%s] has unacceptable format", id, range[0]);
         return NULL;
        }
      int startHour = (int) StringToInteger(startTime[0]);
      int startMinute = (int) StringToInteger(startTime[1]);

      string endTime[];
      int endTimeSize = StringSplit(range[1], StringGetCharacter(":", 0), endTime);
      if(endTimeSize != 2)
        {
         PrintFormat("Error: range [%i] with end time [%s] has unacceptable format", id, range[1]);
         return NULL;
        }
      int endHour = (int) StringToInteger(endTime[0]);
      int endMinute = (int) StringToInteger(endTime[1]);

      color colour = StringToColor(range[2]);

      return new Config(id, startHour, startMinute, endHour, endMinute, colour);
     }
   int               GetId() { return m_Id; }
   int               GetStartHour() { return m_StartHour; }
   int               GetStartMinute() { return m_StartMinute; }
   int               GetEndHour() { return m_EndHour; }
   int               GetEndMinute() { return m_EndMinute; }
   color             GetColor() { return m_Color; }
   string            ToString()
     {
      return StringFormat("Config[Id=%i, StartHour=%i, StartMinute=%i, EndHour=%i, EndMinute=%i, Color=%s]",
                          m_Id, m_StartHour, m_StartMinute, m_EndHour, m_EndMinute, ColorToString(m_Color));
     }
private:
   int               m_Id;
   int               m_StartHour;
   int               m_StartMinute;
   int               m_EndHour;
   int               m_EndMinute;
   color             m_Color;
  };

//+------------------------------------------------------------------+
//| Time Range Box                                                   |
//+------------------------------------------------------------------+
class Box : public CObject
  {
public:
                     Box(
      int            id,
      datetime       start,
      datetime       end,
      double         low,
      double         high,
      color          colour
   ) :
                     m_Id(id),
                     m_Start(start),
                     m_End(end),
                     m_Low(low),
                     m_High(high),
                     m_Color(colour)
     {}
                    ~Box() {}
   void              Draw()
     {
      string objName = OBJECT_PREFIX + TimeToString(m_Start);

      if(ObjectFind(0, objName) < 0)
        {
         ObjectCreate(0, objName, OBJ_RECTANGLE, 0, m_Start, m_Low, m_End, m_High);

         ObjectSetInteger(0, objName, OBJPROP_COLOR, m_Color);
         ObjectSetInteger(0, objName, OBJPROP_FILL, InpFill);
         ObjectSetInteger(0, objName, OBJPROP_STYLE, InpBoderStyle);
         ObjectSetInteger(0, objName, OBJPROP_WIDTH, InpBorderWidth);
         ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
         ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
         ObjectSetInteger(0, objName, OBJPROP_ZORDER, 0);
        }
     }
   int               GetId() { return m_Id; }
   void              SetId(int id) { m_Id = id; }
   datetime          GetStart() { return m_Start; }
   void              SetStart(datetime start) { m_Start = start; }
   datetime          GetEnd() { return m_End; }
   void              SetEnd(datetime end) { m_End = end; }
   double            GetLow() { return m_Low; }
   void              SetLow(double low) { m_Low = low; }
   double            GetHigh() { return m_High; }
   void              SetHigh(double high) { m_High = high; }
   color             GetColor() { return m_Color; }
   void              SetColor(color colour) { m_Color = colour; }
   string            ToString()
     {
      return StringFormat("Box[Id=%i, Start=%s, End=%s, Low=%f, High=%f, Color=%s]",
                          m_Id, TimeToString(m_Start), TimeToString(m_End), m_Low, m_High, ColorToString(m_Color));
     }
private:
   int               m_Id;
   datetime          m_Start;
   datetime          m_End;
   double            m_Low;
   double            m_High;
   color             m_Color;
  };

// buffers
double TimeRangeBoxIdBuffer[]; // range identifier
double TimeRangeBoxLowBuffer[]; // range lowest price
double TimeRangeBoxHighBuffer[]; // range highest price

// config
input group "Section :: Main";
input ENUM_TIME_ZONE InpTimeZoneOffsetHours = TZauto; // Time zone (offset in hours)
input string InpRanges = "23:00_08:00_clrLightGray,07:00_16:00_clrLightGreen,12:00_20:00_clrYellow"; // Time ranges (GMT)
input bool InpDebugEnabled = false; // Endble debug (verbose logging)
input group "Section :: Style";
input bool InpFill = true; // Fill solid (true) or transparent (false)
input ENUM_BORDER_STYLE InpBoderStyle = BORDER_STYLE_SOLID; // Border line style
input int InpBorderWidth = 2; // Border line width

// constants
const string OBJECT_PREFIX = "TRB_";

// runtime
CArrayObj configs;
CArrayObj boxes;
int timeShiftSeconds;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("TimeRangeBox initialization started");

   ArrayInitialize(TimeRangeBoxIdBuffer, NULL);
   ArrayInitialize(TimeRangeBoxLowBuffer, NULL);
   ArrayInitialize(TimeRangeBoxHighBuffer, NULL);

   ArraySetAsSeries(TimeRangeBoxIdBuffer, true);
   ArraySetAsSeries(TimeRangeBoxLowBuffer, true);
   ArraySetAsSeries(TimeRangeBoxHighBuffer, true);

   SetIndexBuffer(0, TimeRangeBoxIdBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, TimeRangeBoxLowBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, TimeRangeBoxHighBuffer, INDICATOR_CALCULATIONS);

   timeShiftSeconds = (InpTimeZoneOffsetHours == TZauto ? getTimeZoneOffsetHours() : InpTimeZoneOffsetHours) * 60 * 60;

   string ranges[];
   int rangesSize = StringSplit(InpRanges, StringGetCharacter(",", 0), ranges);
   for(int i = 0; i < rangesSize; i++)
     {
      Config *config = Config::Parse(i + 1, ranges[i]);
      if(config == NULL)
        {
         return INIT_PARAMETERS_INCORRECT;
        }
      Print("Parsed ", config.ToString());
      configs.Add(config);
     }

   Print("TimeRangeBox initialization finished");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("TimeRangeBox deinitialization started");

   ArrayFree(TimeRangeBoxIdBuffer);
   ArrayFree(TimeRangeBoxLowBuffer);
   ArrayFree(TimeRangeBoxHighBuffer);

   configs.Clear();
   boxes.Clear();

   if(!MQLInfoInteger(MQL_TESTER))
     {
      ObjectsDeleteAll(0, OBJECT_PREFIX);
     }

   Print("TimeRangeBox deinitialization finished");
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   int limit = (int) MathMin(rates_total, rates_total - prev_calculated + 1);
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   MqlDateTime currMdt;
   MqlDateTime startMdt;
   MqlDateTime endMdt;

   datetime currDt;
   datetime startDt;
   datetime endDt;

   for(int i = limit - 1; i > 0; i--)
     {
      datetime dt = time[i];
      if(InpDebugEnabled)
        {
         PrintFormat("Bar [%i] at [%s] GMT", i, TimeToString(dt));
        }

      TimeToStruct(dt, currMdt);
      currMdt.sec = 0;
      currDt = StructToTime(currMdt);

      TimeToStruct(dt, startMdt);
      startMdt.sec = 0;

      TimeToStruct(dt, endMdt);
      endMdt.sec = 0;

      for(int j = 0; j < configs.Total(); j++)
        {
         Config *config = configs.At(j);

         startMdt.hour = config.GetStartHour();
         startMdt.min = config.GetStartMinute();
         endMdt.hour = config.GetEndHour();
         endMdt.min = config.GetEndMinute();

         int prevDayDiff = startMdt.hour > endMdt.hour ? 86400 : 0; // range starts on previous day

         startDt = StructToTime(startMdt) - prevDayDiff + timeShiftSeconds;
         endDt = StructToTime(endMdt) + timeShiftSeconds;

         if(currDt >= startDt && currDt < endDt)
           {
            addBox(config.GetId(), startDt, endDt, low[i], high[i], config.GetColor(), i);
           }
        }
     }

   if(InpDebugEnabled)
     {
      PrintFormat("Drawn [%i] boxes", boxes.Total());
     }
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Get offset in hours between current time zone and GMT            |
//+------------------------------------------------------------------+
int getTimeZoneOffsetHours()
  {
   datetime serverTime = TimeTradeServer();
   datetime gmtTime = TimeGMT();

   int offsetSeconds = ((int)serverTime) - ((int)gmtTime);
   int offsetHours = offsetSeconds / 3600;

   PrintFormat("Detected time offset [%i] hours", offsetHours);
   return offsetHours;
  }

//+------------------------------------------------------------------+
//| Add or update existing box and draw it                           |
//+------------------------------------------------------------------+
void addBox(int id, datetime start, datetime end, double low, double high, color colour, int i)
  {
   Box *box = NULL;
   for(int i = boxes.Total() - 1; i >= 0; i--)
     {
      Box *candidate = boxes.At(i);
      if(candidate.GetId() == id)
        {
         box = candidate;
         break;
        }
     }

   if(box != NULL && box.GetStart() == start)
     {
      if(box.GetLow() > low || box.GetHigh() < high)
        {
         box.SetLow(MathMin(box.GetLow(), low));
         box.SetHigh(MathMax(box.GetHigh(), high));

         ObjectsDeleteAll(0, OBJECT_PREFIX + TimeToString(start));

         box.Draw();
         if(InpDebugEnabled)
           {
            PrintFormat("Box [%i] redrawn", boxes.Total());
           }
        }
     }
   else
     {
      box = new Box(id, start, end, low, high, colour);
      boxes.Add(box);

      box.Draw();
      if(InpDebugEnabled)
        {
         PrintFormat("Box [%i] drawn", boxes.Total());
        }
     }

   TimeRangeBoxIdBuffer[i] = box.GetId();
   TimeRangeBoxLowBuffer[i] = box.GetLow();
   TimeRangeBoxHighBuffer[i] = box.GetHigh();
  }
//+------------------------------------------------------------------+
