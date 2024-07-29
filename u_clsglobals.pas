 unit U_clsGlobals;

{$mode ObjFPC}{$H+}

interface

Type
  TGlobals = Class

Private
  //xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxfor git test
  //FilePaths
  v_ApplicationPath:          String;
  v_CurlPath:                 String;
  v_LogFilePath:              String;
  v_TempPath:                 String;
  v_ArchivePath:              String;
  v_DataBasePath:             String;
  v_DebugLogFilePath:         String;
  //Timers
  v_PvFileScan:               Int64;
  v_PvUploadStartDelay:       Int64;
  v_PvUploadInt:              Int64;
  v_PvUploadSlotCheck:        Int64;
  v_PvErrorLogCheck:          Int64;
  //PvSystem
  v_PvSystemId:               String;
  v_PvApiKey:                 String;
  v_PvSystemName:             String;
  v_PvInvModel:               String;
  v_PvSystemDate:             String;
  v_ZoomLevel:                Int32;
  v_ZoomLevelSet:             Boolean;
  v_DebugModeOn:              Boolean;
  v_MaxDebugRecs:             Int32;
  v_DebugRecs:                Int32;
  //Processing
  v_FileScan:                 Boolean;
  v_FileParse:                Boolean;
  v_DataBaseUpdate:           Boolean;
  v_PvUpload:                 Boolean;
  //Validation
  v_EarliestTimes:            String;
  v_LatestTimes:              String;
  v_MaxTimes:                 String;
  //PvUpload
  v_MaxBatchRecs:             Int32;
  v_MaxLiveRecs:              Int32;
  v_MaxOutputRetries:         Int32;
  v_PvGetOutputDelay:         Int32;
  v_MaxLiveRetries:           Int32;
  v_PvGetStatusDelay:         Int32;
  v_MaxUploadSlotRetries:     Int32;
  v_PvUploadSlotDelay:        Int32;
  v_PvUploadSlotLimit:        Int32;
  v_PvUploadSlotRemaining:    Int32;
  v_PvUploadSlotDateReset:    String;
  v_PvUploadSlotTimeReset:    String;
  //Other Gobals used
  v_LastLogFileFound:         String;

Public
  Constructor Create();
  //FilePaths
  Property ApplicationPath: String Read v_ApplicationPath Write v_ApplicationPath;
  Property CurlPath: String Read v_CurlPath Write v_CurlPath;
  Property LogFilePath: String Read v_LogFilePath Write v_LogFilePath;
  Property TempPath: String Read v_TempPath Write v_TempPath;
  Property ArchivePath: String Read v_ArchivePath Write v_ArchivePath;
  Property DataBasePath: String Read v_DataBasePath Write v_DataBasePath;
  Property DebugLogFilePath: String Read v_DebugLogFilePath Write v_DebugLogFilePath;
  //Timers
  Property PvFileScan: Int64 Read v_PvFileScan Write v_PvFileScan;
  Property PvUploadStartDelay: Int64 Read v_PvUploadStartDelay Write v_PvUploadStartDelay;
  Property PvUploadInt: Int64 Read v_PvUploadInt Write v_PvUploadInt;
  Property PvUploadSlotCheck: Int64 Read v_PvUploadSlotCheck Write v_PvUploadSlotCheck;
  Property PvErrorLogCheck: Int64 Read v_PvErrorLogCheck Write v_PvErrorLogCheck;
  //PvSystem
  Property PvSystemId: String Read v_PvSystemId Write v_PvSystemId;
  Property PvApiKey: String Read v_PvApiKey Write v_PvApiKey;
  Property PvSystemName: String Read v_PvSystemName Write v_PvSystemName;
  Property PvInvModel: String Read v_PvInvModel Write v_PvInvModel;
  Property PvSystemDate: String Read v_PvSystemDate Write v_PvSystemDate;
  Property ZoomLevel: Int32 Read v_Zoomlevel Write v_ZoomLevel;
  Property ZoomLevelSet: Boolean Read v_ZoomLevelSet Write v_ZoomLevelSet;
  Property DeBugModeOn: Boolean Read v_DebugModeOn Write v_DebugModeOn;
  Property MaxDebugRecs: Int32 Read v_MaxDebugRecs Write v_MaxDebugRecs;
  Property DebugRecs: Int32 Read v_DebugRecs Write v_DebugRecs;
  //Processing
  Property FileScan: Boolean Read v_FileScan Write v_FileScan;
  Property FileParse: Boolean Read v_FileParse Write v_FileParse;
  Property DataBaseUpdate: Boolean Read v_DataBaseUpdate Write v_DataBaseUpdate;
  Property PvUpload: Boolean Read v_PvUpload Write v_PvUpload;
  //Validation
  Property EarliestTimes: String Read v_EarliestTimes Write v_EarliestTimes;
  Property LatestTimes: String Read v_LatestTimes Write v_LatestTimes;
  Property MaxTimes: String Read v_MaxTimes Write v_MaxTimes;
  //PvUpload
  Property MaxBatchRecs: Int32 Read v_MaxBatchRecs Write v_MaxBatchRecs;
  Property MaxLiveRecs: Int32 Read v_MaxLiveRecs Write v_MaxLiveRecs;
  Property MaxOutputRetries: Int32 Read v_MaxOutputRetries Write v_MaxOutputRetries;
  Property PvGetOutputDelay: Int32 Read v_PvGetOutputDelay Write v_PvGetOutputDelay;
  Property MaxLiveRetries: Int32 Read v_MaxLiveRetries Write v_MaxLiveRetries;
  Property PvGetStatusDelay: Int32 Read v_PvGetStatusDelay Write v_PvGetStatusDelay;
  Property MaxUploadSlotRetries: Int32 Read v_MaxUploadSlotRetries Write v_MaxUploadSlotRetries;
  Property PvUploadSlotDelay: Int32 Read v_PvUploadSlotDelay Write v_PvUploadSlotDelay;
  Property PvUploadSlotLimit: Int32 Read v_PvUploadSlotLimit Write v_PvUploadSlotLimit;
  Property PvUploadSlotRemaining: Int32 Read v_PvUploadSlotRemaining Write v_PvUploadSlotRemaining;
  Property PvUploadSlotDateReset: String Read v_PvUploadSlotDateReset Write v_PvUploadSlotDateReset;
  Property PvUploadSlotTimeReset: String Read v_PvUploadSlotTimeReset Write v_PvUploadSlotTimeReset;
  //Other Globals used
  Property LastLogFileFound: String Read v_LastLogFileFound Write v_LastLogFileFound;
End;

Type
  TSys = Class
Private
  v_SystemName:     String;
  v_SystemDate:    String;
  v_ColNames:      String;
  v_ColUnits:      String;
  v_Model:         String;
  v_MPPT:          String;
  v_SystemTime:    String;
  v_SysTimeOn:     String;
  v_SysTimeOff:    String;
  v_EnergyToday:   Single;
  v_EnergyLife:    Single;
  v_clsVar:        Int32;
  v_clsState:      Boolean;
Public
  Constructor Create();
  Property SystemName: String Read v_SystemName Write v_SystemName;
  Property SystemDate: String Read v_SystemDate Write v_SystemDate;
  Property ColNames: String Read v_ColNames Write v_ColNames;
  Property ColUnits: String Read v_ColUnits Write v_ColUnits;
  Property Model: String Read v_Model Write v_Model;
  Property MPPT: string Read v_MPPT Write v_MPPT;
  Property SystemTime: String Read v_SystemTime Write v_SystemTime;
  Property SysTimeOn: String Read v_SysTimeOn Write v_SysTimeOn;
  Property SysTimeOff: String Read v_SysTimeOff Write v_SysTimeOff;
  Property EnergyToday: Single Read v_EnergyToday Write v_EnergyToday;
  Property EnergyLife: Single Read v_EnergyLife Write v_EnergyLife;
  Property clsState: Boolean Read v_clsState;
End;

Implementation

Uses
  Classes, SysUtils;

Constructor TGlobals.Create();
Begin
  //FilePaths
  ApplicationPath:='NotSet';
  CurlPath:='NotSet';
  LogFilePath:='NotSet';
  TempPath:='NotSet';
  ArchivePath:='NotSet';
  DataBasePath:='NotSet';
  DebugLogFilePath:='NotSet';
  //Timers
  PvFileScan:=300000;
  PvUploadStartDelay:=300000;
  PvUploadInt:=300000;
  PvUploadSlotCheck:=300000;
  PvErrorLogCheck:=300000;
  //PvSystem
  PvSystemId:='Not Set';
  PvApiKey:='Not Set';
  PvSystemName:='Not Set';
  PvInvModel:='Not Set';
  PvSystemDate:='Not Set';
  ZoomLevel:=0;
  ZoomLevelSet:=False;
  DeBugModeOn:=False;
  MaxDebugRecs:=0;
  DebugRecs:= 0;
  //Processing
  FileScan:=False;
  FileParse:=False;
  DataBaseUpdate:=False;
  PvUpload:=False;
  //Validation
  EarliestTimes:= 'Not Set';
  LatestTimes:= 'Not Set';
  MaxTimes:= 'Not Set';
  //PvUpload
  MaxBatchRecs:=0;
  MaxLiveRecs:=0;
  MaxOutputRetries:=0;
  PvGetOutputDelay:=0;
  MaxLiveRetries:=0;
  PvGetStatusDelay:=0;
  MaxUploadSlotRetries:=0;
  PvUploadSlotDelay:=0;
  PvUploadSlotLimit:=0;
  PvUploadSlotRemaining:=0;
  PvUploadSlotDateReset:= 'Not Set';
  PvUploadSlotTimeReset:= 'Not Set';
  //Other Globals used
  LastLogFileFound:= '';
End;
Constructor TSys.Create();
Begin
  v_SystemName:='XX';
  v_SystemDate:='XX';
  v_ColNames:='XX';
  v_ColUnits:='XX';
  v_Model:='XX';
  v_MPPT:='X';
  v_SystemTime:='XX';
  v_SysTimeOn:='XX';
  v_SysTimeOff:='XX';
  v_EnergyToday:=0.0;
  v_EnergyLife:=0.0;
  v_clsVar:=0;
End;

End.

