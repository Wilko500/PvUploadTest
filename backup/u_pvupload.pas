unit u_PvUpload;

{$mode ObjFPC}{$H+}
{$modeswitch objectivec1}


interface

uses
  Classes, SysUtils, IniFiles, U_frmSettings, CocoaAll, Dialogs, strUtils,
  Forms, Controls, Graphics, StdCtrls, ComCtrls, ExtCtrls, U_clsGlobals,
  MyUtils, vTimedProcess, sqlite3conn, SQLDB, FileUtil, DateUtils, Db, math;
Type
 ar12 = Array[1..12] Of String;
 ari12 = Array[1..12] Of Int32;
 ar19 = Array[1..19] Of String;

Procedure LoadFormFromIni();
Procedure LoadGlobals();
Function GetPath(PathType: Int32; ForApp: Boolean): String;
function GetSignificantDir(DirLocation: qword; DomainMask: qword; count: byte): string;
Function GetAppName(IncPath: Boolean): String;
Function CheckForUploadSlots: Boolean;
Procedure UpdateLogWindows();
Function openDB(dbName: string): boolean;
function sqlDBError(const msg: string): string;
Procedure closeDB;
Function ScanForLogFile(): String;
Function DateToDMY(DateYMD: String): String;
Procedure FileScanProcessing();
Procedure CopyMoveFile(SourcePath, DestPath, FileName, CopyMove, strError: String);
Procedure AppendData(FileName, FromPath, ToPath: String);
Function DataRecs(FileName, FilePath: String): Int32;
Function DoArchive(FileName, FromPath, ToPath: String): String;
Function IsDataComplete(fDate: String; iSysS, iData: Int32; sSect, sFirstTime, sLastTime: String): String;
Procedure LoadTimesStr(VAR arStrTimes: ar12; strArrayOfTimes, strType: String);
Procedure LoadTimesNum(VAR arStrNumbers: ari12; strArrayOfNumbers: String);
Function GetMonthNo(fDate: string): Int32;
Procedure FileParse(fDate, TempPath: String; VAR iData: Int32; VAR Complete: String);
Function MyDateDiff(sDorT, sNow, sthen: String): Int32;
Function DoesTimeExist( DayId: Int32; sTime: String): Boolean;
//Function GetUnitId(sColName, sUnit: String): Int32;
Function GetUnitId: Int32;
Function GetDayId(sDate, sTimeOn, sTimeOff: String; iEnergyToday,
                  iEnergyLife: Single; iInvId: Int32): Int32;
//Procedure ReadSyFile(fDate: String; VAR TimeOn, TimeOff: String; VAR EnergyToday, EnergyLife: Single);
Procedure ReadSyFile(fDate: String);
//Procedure ReadInFile(fDate: String; VAR SystemName, SystemDate: String);
Procedure ReadInFile(fDate: String);
Procedure ReadUnFile(fDate: String; VAR sColNames, sUnits: String);
//Function GetInverterId(ModelNo, SystemName, MPPT, ColNames, ColUnits: String): Int32;
Function GetInverterId: Int32;
Procedure UpdatePeakAndDaily(strDate: String);
Procedure UpDateDataBase(fDate: String; VAR iDup, iUpd, iZero: Int32; sComplete, sSysName, sModel, sSysDate:String);
Function IsRecAllZero(arIn:ar19): Boolean;
//Function DataRecs(sFileNme, sFilePath: String): Int32;
Function IsSlotFree(): Boolean;
Procedure ResetUpdateSlots(intChange:Int32);
Function GetResponseAddStatus(iSent:Int32; strArray:String): Boolean;
Procedure PvUploadProcessing;
Procedure GetModelMPPT(fDate:String);

//Procedure Delay(dSecs:Int64);

Var
  sqlite3: TSQLite3Connection;
  dbTrans: TSQLTransaction;
  dbQuery: TSQLQuery;
implementation
Uses
U_frmAuroraDataUpload;

//------------------------------------------------------------------------------
//Procedure : LoadFormFromIni
//Author    : Richard Wilkinson
//Date      : 26/4/24
//Purpose   : To load frmSettings fields from Ini file
//------------------------------------------------------------------------------
//
Procedure LoadFormFromIni();
Var
 fIni:    TIniFile;
 IniFile: String;
 strKey:  String;
Begin
iniFile:= GetPath(3, True) + '/PvUpload.ini';
//showMessage('Test - IniFile Path = ' + iniFile);
If FileExists(IniFile) = True Then
 //Found ini file
 Begin
 fIni := TIniFile.Create(IniFile);
 //FilePaths
 strKey:=fIni.ReadString('FilePaths', 'ApplicationPath', '999');
 frmSettings.txtApplicationPath.Text:= strKey;
 frmSettings.txtCurlPath.Text:= 'Not used';
 strKey:=fIni.ReadString('FilePaths', 'LogFilePath', '999');
 frmSettings.txtLogFilePath.Text:= strKey;
 If Not DirectoryExists(strKey) Then frmSettings.txtLogFilePath.Font.color:=clRed;
 strKey:=fIni.ReadString('FilePaths', 'TempPath', '999');
 frmSettings.txtTempPath.Text:= strKey;
 If Not DirectoryExists(strKey) Then frmSettings.txtTempPath.Font.color:=clRed;
 strKey:=fIni.ReadString('FilePaths', 'ArchivePath', '999');
 frmSettings.txtArchivePath.Text:= strKey;
 If Not DirectoryExists(strKey) Then frmSettings.txtArchivePath.Font.color:=clRed;
 strKey:=fIni.ReadString('FilePaths', 'DatabasePath', '999');
 frmSettings.txtDatabasePath.Text:= strKey;
 If Not DirectoryExists(strKey) Then frmSettings.txtDatabasePath.Font.color:=clRed;
 strKey:=fIni.ReadString('FilePaths', 'DebugLogFilePath', '999');
 frmSettings.txtDebugLogFilePath.Text:= strKey;
 If Not DirectoryExists(strKey) Then frmSettings.txtDebugLogFilePath.Font.color:=clRed;
 //Timers
 strKey:=fIni.ReadString('Timers', 'FileScan', '999');
 frmSettings.txtPvFileScan.Text:=strKey;
 strKey:=fIni.ReadString('Timers', 'PvUploadStartDelay', '999');
   frmSettings.txtPvUploadStartDelay.Text:=strKey;
 strKey:=fIni.ReadString('Timers', 'PvUpload', '999');
   frmSettings.txtPvUploadInt.Text:=strKey;
 strKey:=fIni.ReadString('Timers', 'PvUploadSlotCheck', '999');
   frmSettings.txtPvUploadSlotCheck.Text:=strKey;
 strKey:=fIni.ReadString('Timers', 'PvErrorLogCheck', '999');
   frmSettings.txtPvErrorLogCheck.Text:=strKey;
 //PVSystem
 strKey:=fIni.ReadString('PvSystem', 'PvApiKey', '999');
 frmSettings.txtPvApiKey.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'PvSystemId', '999');
 frmSettings.txtPvSystemId.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'PvSystemName', '999');
 frmSettings.txtPvSystemName.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'PvInvModel', '999');
 frmSettings.txtPvInvModel.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'PvSystemDate', '999');
 frmSettings.txtPvSystemDate.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'ZoomLevel', '999');
 frmSettings.txtZoomLevel.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'MaxDebugRecs', '999');
 frmSettings.txtMaxDebugRecs.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'DebugRecs', '999');
 frmSettings.txtDebugRecs.Text:=strKey;
 strKey:=fIni.ReadString('PvSystem', 'ZoomLevelSet', '999');
 If strKey = '1' Then frmSettings.chkZoomlevelSet.State:=cbChecked
                 Else frmSettings.chkZoomlevelSet.State:=cbUnChecked;
  strKey:=fIni.ReadString('PvSystem', 'DebugModeOn', '999');
 If strKey = '1' Then frmSettings.chkDebugModeOn.State:=cbChecked
                 Else frmSettings.chkDebugModeOn.State:=cbUnChecked;
 //Processing
  strKey:=fIni.ReadString('Processing', 'FileScan', '999');
  If strKey = '1' Then frmSettings.chkFileScan.State:=cbChecked;
  strKey:=fIni.ReadString('Processing', 'FileParse', '999');
  If strKey = '1' Then frmSettings.chkFileParse.State:=cbChecked;
   strKey:=fIni.ReadString('Processing', 'DataBaseUpdate', '999');
  If strKey = '1' Then frmSettings.chkDataBaseUpdate.State:=cbChecked;
  strKey:=fIni.ReadString('Processing', 'PvUpload', '999');
  If strKey = '1' Then frmSettings.chkPvUpload.State:=cbChecked;
 //Validation
 strKey:=fIni.ReadString('Validation', 'EarliestTimes', '999');
 frmSettings.txtEarliestTimes.Text:=strKey;
 strKey:=fIni.ReadString('Validation', 'LatestTimes', '999');
 frmSettings.txtLatestTimes.Text:=strKey;
 strKey:=fIni.ReadString('Validation', 'MaxTimes', '999');
 frmSettings.txtMaxTimes.Text:=strKey;
 //PVUpload
 strKey:=fIni.ReadString('PVUpload', 'MaxBatchRecs', '999');
 frmSettings.txtMaxBatchRecs.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'MaxLiveRecs', '999');
 frmSettings.txtMaxLiveRecs.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'MaxOutputRetries', '999');
 frmSettings.txtMaxOutputRetries.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvGetOutputDelay', '999');
 frmSettings.txtPvGetOutputDelay.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'MaxLiveRetries', '999');
 frmSettings.txtMaxLiveRetries.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvGetStatusDelay', '999');
 frmSettings.txtPvGetStatusDelay.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'MaxUploadSlotRetries', '999');
 frmSettings.txtMaxUploadSlotRetries.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvUploadSlotDelay', '999');
 frmSettings.txtPvUploadSlotDelay.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvUploadSlotLimit', '999');
 frmSettings.txtPvUploadSlotLimit.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvUploadSlotRemaining', '999');
 frmSettings.txtPvUploadSlotRemaining.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvUploadSlotDateReset', '999');
 frmSettings.txtPvUploadSlotDateReset.Text:=strKey;
 strKey:=fIni.ReadString('PVUpload', 'PvUploadSlotTimeReset', '999');
 frmSettings.txtPvUploadSlotTimeReset.Text:=strKey;
 fIni.Free;
 End
Else
 Begin
 ShowMessage('PvUploadIni file not found at ' + IniFile);
End;{If}


End;{Procedure LoadFormFromIni}

//------------------------------------------------------------------------------
//Procedure : LoadGlobals
//Author    : Richard Wilkinson
//Date      : 26/4/24
//Purpose   : Load class clsGlobals with values from frmSettings
//------------------------------------------------------------------------------
//
Procedure LoadGlobals();
Begin
//FilePaths
g.ApplicationPath:=frmSettings.txtApplicationPath.Text;
g.CurlPath:=frmSettings.txtCurlPath.Text;
g.LogFilePath:=frmSettings.txtLogFilePath.Text;
g.TempPath:=frmSettings.txtTempPath.Text;
g.ArchivePath:= frmSettings.txtArchivePath.Text;
g.DataBasePath:=frmSettings.txtDatabasePath.Text;
g.DebugLogFilePath:=frmSettings.txtDebugLogFilePath.Text;
//Timers
g.PvFileScan:=StrToInt64(frmSettings.txtPvFileScan.Text);
g.PvUploadStartDelay:=StrToInt64(frmSettings.txtPvUploadStartDelay.Text);
g.PvUploadInt:=StrToInt64(frmSettings.txtPvUploadInt.Text);
g.PvUploadStartDelay:=StrToInt64(frmSettings.txtPvUploadSlotCheck.Text);
g.PvErrorLogCheck:=StrToInt64(frmSettings.txtPvErrorLogCheck.Text);
//PvSystem
g.PvSystemId:=frmSettings.txtPvSystemID.Text;
g.PvApiKey:=frmSettings.txtPvApiKey.Text;
g.PvSystemName:=frmSettings.txtPvSystemName.Text;
g.PvInvModel:=frmSettings.txtPvInvModel.Text;
g.PvSystemDate:=frmSettings.txtPvSystemDate.Text;
g.ZoomLevel:=StrToInt(frmSettings.txtZoomLevel.Text);
If frmSettings.chkZoomLevelSet.Checked  = True then   g.ZoomLevelSet:= True
                                              Else  g.ZoomLevelSet:= False;
If frmSettings.chkDebugModeOn.Checked  = True then   g.DeBugModeOn:= True
                                              Else  g.DeBugModeOn:= False;
g.MaxDebugRecs:=StrToInt(frmSettings.txtMaxDebugRecs.Text);
g.DebugRecs:=StrToInt(frmSettings.txtDebugRecs.Text);

//Processing
If frmSettings.chkFileScan.Checked  = True then   g.FileScan:= True
                                              Else  g.FileScan:= False;
If frmSettings.chkFileParse.Checked  = True then   g.FileParse:= True
                                              Else  g.FileParse:= False;
If frmSettings.chkDataBaseUpdate.Checked  = True then   g.DataBaseUpdate:= True
                                              Else  g.DataBaseUpdate:= False;
If frmSettings.chkPvUpload.Checked  = True then   g.PvUpload:= True
                                              Else  g.PvUpload:= False;
//Validation
g.EarliestTimes:=frmSettings.txtEarliestTimes.Text;
g.LatestTimes:=frmsettings.txtLatestTimes.Text;
g.MaxTimes:=frmsettings.txtMaxTimes.Text;
//UPLoad
g.MaxBatchRecs:=StrToInt(frmSettings.txtMaxBatchRecs.Text);
g.MaxLiveRecs:=StrToInt(frmSettings.txtMaxLiveRecs.Text);
g.MaxOutputRetries:=StrToInt(frmsettings.txtMaxOutputRetries.Text);
g.PvGetOutputDelay:=StrToInt(frmSettings.txtPvGetOutputDelay.Text);
g.MaxLiveRetries:=StrToInt(frmSettings.txtMaxLiveRetries.Text);
g.PvGetStatusDelay:=StrToInt(frmSettings.txtPvGetStatusDelay.Text);
g.MaxUploadSlotRetries:=StrToInt(frmSettings.txtMaxUploadSlotRetries.Text);
g.PvUploadSlotDelay:=StrToInt(frmSettings.txtPvUploadSlotDelay.Text);
g.PvUploadSlotLimit:=StrToInt(frmSettings.txtPvUploadSlotLimit.Text);
g.PvUploadSlotRemaining:=StrToInt(frmSettings.txtPvUploadSlotRemaining.Text);
g.PvUploadSlotDateReset:=frmSettings.txtPvUploadSlotDateReset.Text;
g.PvUploadSlotTimeReset:=frmSettings.txtPvUploadSlotTimeReset.Text;

{
240   Call LoadTimesStr(argStrEarliestTimes(), frmSettings.txtEarliestTimes, "E")
250   Call LoadTimesStr(argStrLatestTimes(), frmSettings.txtLatestTimes, "L")
260   Call LoadTimesNum(argIntMaxTimes(), frmSettings.txtMaxTimes)
}

End;{Procedure LoadGlobals}

//------------------------------------------------------------------------------
//Function  : GetPath
//Author    : Richard Wilkinson
//Date      : 29/4/24
//Purpose   : Function to return significant system (not user) file path
//          : PathType = 1 Library
//          :          = 2 Application
//          :          = 3 Library preferences
//          :          = 4 Application Support
//          : ForApp  True  = for app based paths include app name
//------------------------------------------------------------------------------
//
Function GetPath(PathType: Int32; ForApp: Boolean): String;
Const
  IncPath: Boolean = True;
  NoIncPath: Boolean = False;
Var
  strTmp: String;
Begin
  Case PathType Of
  1: //Library
    Begin
    strTmp:=GetSignificantDir(NSLibraryDirectory,NSLocalDomainMask,0);
    End;
  2: //Application
    Begin
    strTmp:=GetSignificantDir(NSAllApplicationsDirectory,NSLocalDomainMask,0);
    End;
  3: //Library Preferences
    Begin
    //Cant find call to get Preferences so hard coded as fix
    strTmp:=GetSignificantDir(NSLibraryDirectory,NSLocalDomainMask,0) + '/Preferences';
    If ForApp = True Then strTmp:= StrTmp + '/' + GetAppName(NoIncPath);
    End;
  4: //Application Support
    Begin
    strTmp:= GetSignificantDir(NSApplicationSupportDirectory,NSLocalDomainMask,0);
    If ForApp = True Then strTmp:= StrTmp + '/' + GetAppName(NoIncPath);
    End
  Else
    //Can't get here
    Begin
    strTmp:='';
    Writeln('Invalid option in Function GetPaths=' + IntToStr(PathType));
    End;
  End;{Case}
Result:= strTmp;
End;{Function GetPath}

function GetSignificantDir(DirLocation: qword; DomainMask: qword; count: byte): string;
var
  paths : NSArray;
begin
  paths := NSSearchPathForDirectoriesInDomains(DirLocation, DomainMask, True);
  if(count < paths.count) then
    Result := NSString(paths.objectAtIndex(Count)).UTF8String
  else
    Result := '';
end;

//------------------------------------------------------------------------------
//Function  : GetAppName
//Author    : Richard Wilkinson
//Date      : 29/4/24
//Purpose   : Function to return the application name (MacOs)
//          : IncPath = incluse path with app name
//------------------------------------------------------------------------------
//
Function GetAppName(IncPath: Boolean): String;
Var
  strTmp: String;
  strAppName, strAppPath:    String;
  i, i1:  Integer;
Begin
//Get application name
  //showMessage( NSBundle.mainBundle.bundlePath.UTF8String);
  strTmp:=NSBundle.mainBundle.bundlePath.UTF8String;
  //Gives /Volumes/MacHD-SSD-Data/LocBucket/FpLazStuff/PvUploadTest/PvUploadTest.app
  //From command line there is no bundle
  //Gives /Volumes/MacHD-SSD-Data/LocBucket/FpLazStuff/PvUploadTest
  i:=  Rpos('/', strTmp) +1;
  i1:=Rpos('.', strTmp) -i;
  If i1 < 0 Then
      // no bundle, running from command line maybe?
      Begin
      i1:= length(strTmp); //Fix so that correct AppName is returned when run from command line
      strAppName:= MidStr(strTmp,i,i1);
      strAppPath:=MidStr(strTmp, 1, Length(strTmp));
      End
  Else
      //Running from bundle
      Begin
      strAppName:= MidStr(strTmp,i,i1);
      strAppPath:= MidStr(strTmp, 1, i - 2);
  End;{EndIf}

If IncPath = True Then
  Begin
  Result:=strAppPath
  End
Else
  Begin
  Result:=strAppName;
End;{EndIf}
End;{Function GetAppName}

//------------------------------------------------------------------------------
//Function  : CheckForUploadSlots
//Author    : Richard Wilkinson
//Date      : 06/10/2015
//Purpose   : Check PvOutput.org for availability of upload slots
//          : Store results on frmSettings and .ini file
//          : While running, the program will maintain slot count
//------------------------------------------------------------------------------
//
Function CheckForUploadSlots(): Boolean;
Var
  p:               TTimedProcess;          //The process to run Curl
  Params:          Array[0..4] of String;  //Array for parameters to send via Curl
  Response:        String;                 //The response
  strResponse:     TStringList;            //Response a string list
  iStatus:         Boolean;                //Var for function result
  i, j   :         Int32;                  //Loop counter
  i1:              Int32;                  //Work Var
  strReset:        String;                 //Work Var
  iLimitRemaining: Int32;                  //Slot limit remaining
  iLimit:          Int32;                  //Slot Limit
  strResetDate:    String;                 //Last Slot reset Date
  strResetTime:    String;                 //Last Slot reset Time
  blnReadComplete: Boolean;                //Flag, True = sucessful read
Begin
Try
  //Send  X-Rate-Limit-Limit: request to PvOutput.org
  Params[0]:= '-i';
  Params[1]:= '-H' + 'X-Rate-Limit: 1'; ;
  Params[2]:= '-H' + 'X-Pvoutput-Apikey:ae134a083d06abfa7e371f9ec883a834052ae26a';
  Params[3]:= '-H' + 'X-Pvoutput-SystemId: 26065';;
  Params[4]:= 'http://pvoutput.org/service/r2/getstatus.jsp';
  //Create process
  p:=TTimedProcess.Create ('Curl', Params, 1);
  //Run it
  iStatus:=p.Run;

  blnReadComplete:=False;
  For i := 1 to g.MaxUploadSlotRetries Do   //3 comes from gstrMaxUploadSlotRetries
    Begin
    //Delay(100);  //Delay 100ms response, probably not needed
    //What if there is no response or no returned output?
    //Get response
    frmAuroraDataUpload.RmFileScanError.Clear;
    Response:=p.Response;
    // reate stringlist array for ease of access
    strResponse:=TStringList.create;
    strResponse.text:=Response;
    frmAuroraDataUpload.RmFileScanError.Append(strResponse.Text);
    //WriteLn(IntToStr(strResponse.count));
    For j:= 0 to strResponse.count - 1 Do
      Begin
      //WriteLn('Loop Index=' + IntToStr(i));
      //Get limit remaining
      i1:= Pos('X-Rate-Limit-Remaining:', strResponse[j]);
      If i1 > 0 Then
          Begin
          iLimitRemaining:= StrToInt(Copy(strResponse[j],i1 + 23));
      End;{If}
      //Get limit
      i1:= Pos('X-Rate-Limit-Limit:', strResponse[j]);
      If i1 > 0 Then
          Begin
          iLimit:= StrToInt(Copy(strResponse[j],i1 + 19));
      End;{If}
      //Get Limit reset date/time
      i1:= Pos('X-Rate-Limit-Reset:', strResponse[j]);
      If i1 > 0 Then
          Begin
          strReset:= Copy(strResponse[j],i1 + 19); //reset date/time Unix form
          If Length(strReset) = 11 Then
              Begin
              strResetDate:=UnixDateToStr(StrToInt64(strReset), 'D', True);
              strResetTime:=UnixDateToStr(StrToInt64(strReset), 'T', False);
              //Update fields & Globals
              frmSettings.txtPvUploadSlotLimit.Text:=IntToStr(iLimit);
              frmSettings.txtPvUploadSlotRemaining.Text:=IntToStr(iLimitRemaining);
              frmSettings.txtPvUploadSlotDateReset.Text:=strResetDate;
              frmSettings.txtPvUploadSlotTimeReset.Text:=strResetTime;
              g.PvUploadSlotLimit:= iLimit;
              g.PvUploadSlotRemaining:= iLimitRemaining;
              g.PvUploadSlotDateReset:= strResetDate;
              g.PvUploadSlotTimeReset:= strResetTime;
              SendTextToMemo(frmAuroraDataUpload.RmPvUploadError, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                                    FormatDateTime('yyyy-mm-dd', Now()) + ' - ' +
                                    'Slot count/date/time reset', True);
              blnReadComplete:= True;
              Break; //Exit;{For j}
          End;{If}
          //Read not sucessful for Limit-Reset, try again
      End;{If}
    End;{For j}
    //If inner loop exited because read complete then exit outer loop
    If blnReadComplete = True Then Break;
  End;{For i}
//If we get here read failure has occurred after 3 attempts
If blnReadComplete = False Then
    Begin
    WriteLn('Chk Upload slote, no response');
    //Log message here
//    Form1.Edit3.Text:= 'Chk Upload slote, no response';
    Result:=False;
    End
Else
    Begin
    Result:=True
End;{If}

Except

End;{Try}
End;{Function CheckForUploadSlots}

//------------------------------------------------------------------------------
//Procedure : UpdateLogWindows
//Author    : Richard Wilkinson
//Date      : 06/10/2015
//Purpose   : This procedure updates the DaysLogged and DaysUploaded
//          : windows.  Data is retrieved from thr database at the
//          : end of DataBaseUpdate procedure
//------------------------------------------------------------------------------

// Need to review code and check program flow for error conditions
// What happens in no records
Procedure UpdateLogWindows();
Var
  strSql:        String;  //SQL command
  strDbFullPath: String;  //Full path to database
  strOne:        String;
  StrTwo:        String;
Begin
  strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
  If OpenDb(strDbFullPath) = True Then
    Begin
    //Database opened ok, continue
    //Do Days Logged first
    strSql:= 'SELECT  Days.DATE, Days.COMPLETE  From Days ORDER BY Days.DATE DESC Limit 50;';
    dBQuery.SQL.Text:=strSql;
    dBQuery.Open;
    If dBQuery.EOF Then
      Begin
      //No records returned
      WriteLn('In UpdateLogWindows no records returned');
      End
    Else
      Begin
      //Process records in reverse order so descending order preserved in list
      dBQuery.last;
      While NOT dBQuery.BOF Do
        Begin
        strOne:=dBQuery.FieldByName('DATE').AsString;
        strTwo:=dBQuery.FieldByName('COMPLETE').AsString;
        frmAuroraDataUpload.RmLoggedDays.Lines.Insert(0,strOne + ' ' + strTwo);
        dBQuery.Prior;
      End;{While}
    End;{If}
    dBQuery.Close;

    //Then Days uploaded
    strSql:= 'SELECT Days.DATE, Days.UPLOADED  From Days ORDER BY Days.DATE DESC Limit 50;';
    dBQuery.SQL.Text:=strSql;
    dBQuery.Open;
    If dBQuery.EOF Then
      Begin
      //No records returned
      WriteLn('In UpdateLogWindows no records returned');
      End
    Else
      Begin
      //Process records in reverse order so descending order preserved in list
      dBQuery.last;
      While NOT dBQuery.BOF Do
        Begin
        strOne:=dBQuery.FieldByName('DATE').AsString;
        strTwo:=dBQuery.FieldByName('UPLOADED').AsString;
        frmAuroraDataUpload.RmUploadDays.Lines.Insert(0, strOne + ' ' + strTwo);
        dBQuery.Prior;
      End;{While}
    End;{If};
    dBQuery.Close;
    End
  Else
    Begin
    //Error opening database
    ShowMessage('Unable to open database');
  End;{If}
  CloseDb;
End;{Procedure UpdateLogWindows}


Function openDB(dbName: string): boolean;
//These defined in  Interface so they are global
//Var
//  sqlite3: TSQLite3Connection;
//  dbTrans: TSQLTransaction;
//  dbQuery: TSQLQuery;
begin
// create components
  sqlite3 := TSQLite3Connection.Create(nil);
  dbTrans := TSQLTransaction.Create(nil);
  dbQuery := TSQLQuery.Create(nil);
///////                                    slNames := TStringList.Create;
// setup components
  sqlite3.Transaction   := dbTrans;
  dbTrans.Database      := sqlite3;
  dbQuery.Transaction   := dbTrans;
  dbQuery.Database      := sqlite3;
//  slNames.CaseSensitive := false;
// setup db
  sqlite3.DatabaseName := dbName;
  sqlite3.HostName     := 'localhost';
  sqlite3.CharSet      := 'UTF8';
// open db
//WriteLn(dbName);
if  FileExists(dbName) then
    try
      sqlite3.Open;
      result := sqlite3.Connected;
    except
      on E: Exception do
      begin
      sqlite3.Close;
      writeln(sqlDBError(E.Message));
      end;
    end
else
    begin
    result := false;
    writeln('Database file "',dbName,'" is not found.');
{EndIf}end;
end;
function sqlDBError(const msg: string): string;
begin
  // error message reformatting
  result := 'ERROR: '+StringReplace(msg,'TSQLite3Connection : ','',[]);
end;
Procedure closeDB;
begin
// disconnect
if sqlite3.Connected then
begin
    dbTrans.Commit;
    dbQuery.Close;
    sqlite3.Close;
end;
end;

//------------------------------------------------------------------------------
//Function  : ScanForLogFile
//Author    : Richard Wilkinson
//Date      : 06/10/2015
//Purpose   : This procedure scans for the oldest log file available,
//          : parses it, does some database update, and archives log file
//          : when necessary
//------------------------------------------------------------------------------
Function ScanForLogFile(): String;

Var
  OldestDate:       TDate;
  OldestName:       String;
  i, j:             Int32;
  LogFiles:         TStringList;
  tmpFile:          String;
  tmpFile2:         String;
  tmpFileJustName:  String;
  tmpExt:           String;
  DateOfFile:       TDate;
Begin
  LogFiles := TStringList.Create;
  i:= 0;
  OldestDate:= Now();
  OldestName:= '';
  FindAllFiles(LogFiles, g.LogFilePath, '*.log;', False); //find all .log files
  //Loop through files in TStringList LogFiles
  For j := 0 to LogFiles.Count - 1 do
      Begin
      tmpFile:=ExtractFileName(LogFiles[j]);                   //  2024-05-08.log
      tmpFileJustName:= Copy(tmpFile,1,Rpos('.', tmpFile) -1); //  2024-05-08
          DateOfFile:= StrToDate(DateToDMY(tmpFileJustName));
          If DateOfFile < OldestDate Then
              Begin
              OldestDate:= DateOfFile;
              OldestName:= tmpFile;
              i:= 1;
          End;{If}
  End;{For}
  //Finished, return result
  If i = 1 Then
      Begin
      Result:= OldestName;
      End
  Else
      Begin
      Result:= 'Do Nothing';
  End;{If}
End;{Function ScanForLogFile}
//------------------------------------------------------------------------------
//Function  : DateToDMY
//Author    : Richard Wilkinson
//Date      : 10/05/2024
//Purpose   : Function to change date string from 2024-05-08 format
//          : to  08/05/2024 suitable for Pascal StrToDate function
//------------------------------------------------------------------------------
Function DateToDMY(DateYMD: String): String;
Var
  tmpStr:    String;
  Begin
      tmpStr:= MidStr(DateYMD,9,2) + '-' +
               MidStr(DateYMD,6,2) + '-' +
               MidStr(DateYMD,1,4);
  Result:= tmpStr;
  End;{Function DateToDMY}

//------------------------------------------------------------------------------
//Procedure : FileScanProcessing
//Author    : Richard Wilkinson
//Date      : 11/05/2024
//Purpose   : This procedure manages the scanning and processing of log files
//          : Logfiles are scanned, processed and archived and
//          : the Database updated
//------------------------------------------------------------------------------
Procedure FileScanProcessing();
Var
  tmp:         String;     //Work var
  strTime:     String;     //Current time for messages
  strMsg:      String;     //Work var
  strDate:     String;     //Date part of filename from FileScan
  strError:    String;     //Check,  not used in filescanproccessing, take out of copymovefile
  iRecsFound:  Int32;      //Returned by FileScan
  strComplete: String;     //Returned by FileScan
  iDup:        Int32;      //Record counts returned from UpDateDataBase
  iUpd:        Int32;
  iZero:       Int32;
  strSystemName: String;   //System info returned from UpDateDataBase
  strModelNo:    String;
  strSystemDate: String;
  tmpDate:     TDateTime;  //Work var
  iDiff:       Int32;      //Work var
  strArc:      String;     //Archive status returned from function DoArchive
  sDate:       String;     //Date in format yyyy/mm/dd for SQL operations
Begin

  //FileScan, look for logfiles to process
  If g.FileScan = True Then
      Begin
      //Scan for log files
      tmp:= ScanForLogFile;  //get the oldest logfile available
      If tmp = 'Do Nothing' Then
          Begin
          //In existing program this message is not used
          //Temporarily supress messages that no files available
          //strTime:=FormatDateTime('hh:nn', Now);
          //strMsg:= strTime + ' - ' +   'no files available';
          //SendTextToMemo(frmAuroraDataUpload.Memo5, strMsg, True);
          End
      Else
          Begin
          //Do not repeat file found messages
          If tmp <> g.LastLogFileFound Then
              Begin
              strTime:=FormatDateTime('hh:nn', Now);
              strMsg:= strTime + ' - ' + tmp + ' found';
              SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, strMsg, True);
          End;{If}
          CopyMoveFile(g.LogFilePath, g.TempPath, tmp, 'C', strError)
          End;
      End{If}
  Else
      Begin
      //To ensure that FileParse is not called if FileScan is turned off
      tmp:= 'Do Nothing';
  End;{If}
  strDate:= MidStr(tmp, 1, 10);   //get name part of filename ie yyyy-mm-dd
  //For testing show filename passed on to FileParse

  //FileParse
  If (g.FileParse = True) AND (tmp <> 'Do Nothing') Then
      Begin
      //Call fileParse
      FileParse(strDate, g.TempPath, iRecsFound, strComplete);
      WriteLn('Return from FileParse: strComplete=' + strComplete);
      //WriteLn(IntToStr(iRecsFound) + ' passed back from  FileParse');
      If tmp <> g.LastLogFileFound Then  SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                                           tmp + ' ' + IntToStr(iRecsFound) + ' Record(s) found', True);
      DeleteFile( g.TempPath + '/' + tmp)  //Delete temp copy of logfile from temp folder
 End;{If}

//DataBase Update
  If (g.DataBaseUpdate = True) And (iRecsFound > 0) And (tmp <> 'Do Nothing') Then
      Begin
      //Do an update if there are records to process
      UpdateDataBase(strDate, iDup, iUpd, iZero, strComplete, strSystemName, strModelNo, strSystemDate);
      //Update message windows with processing results
      //New records
      If iUpd > 0 Then
          Begin
          //Message  to log window
          SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                                           tmp + ' ' + IntToStr(iUpd) + ' Record(s) added', True);
          //Update form system area
          frmAuroraDataUpload.lblSystemName.Caption:=strSystemName;
          frmAuroraDataUpload.lblInvModel.Caption:=strModelNo;
          frmAuroraDataUpload.lblSystemDate.Caption:=strSystemDate;
          //Update Peak and daily energy from database, only if records have been added
          //Get Date in format yyyy/mm/dd for sql operations
          //sDate:=stringReplace(strDate , '-',  '/' ,[rfReplaceAll]);
          UpdatePeakAndDaily(strDate)
      End;{If}
      //Duplicared records
      If iDup > 0 Then
          Begin
          //Message  to log window
          If tmp <> g.LastLogFileFound Then SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                                                           tmp + ' ' + IntToStr(iDup) + ' dup. record(s) skipped' , True);
      End;{If}
      //Zero records
      If iZero > 0 Then
          Begin
          //Message  to log window
          If tmp <> g.LastLogFileFound Then SendTextToMemo(frmAuroraDataUpload.RmFileScanError, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                                                           tmp + ' ' + IntToStr(iZero) + ' zero record(s) ignored'  , True);
      End;{If}
      //Is this file finished with?
      //Need date if format d/m/y for function DaysBetween, use my function DateForDiff
      tmpDate:=DateForDiff(strDate); //Returns DateTime from string
      iDiff:=DaysBetween(tmpDate, Now);
      Case Sign(iDiff) Of
           1:  Begin //Diff is Positive
               //File date is older than today
               If strComplete = 'Y' Then
                   Begin
                   //File is complete, archive
                   SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' + tmp + ' Archived', True);
                   CopyMoveFile(g.LogFilePath, g.ArchivePath, tmp, 'M', strError)
                   End
               Else
                   Begin
                   //File is partial, log
                   If tmp <> g.LastLogFileFound Then SendTextToMemo(frmAuroraDataUpload.RmFileScanError, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - '
                                                                    + tmp + ' Warning - partial?', True);
                   //Do archive check here as may be new file with same date
                   //This can occur if inverter see increased light levels after night time shutdownPublic Function DoArchive(strFileName As String, strFromPath As String, strToPath As String) As String
                   strArc:= DoArchive(tmp, g.LogFilePath, g.ArchivePath);
                   WriteLn('In FileScanProcessing 816 strARC=' + strArc);
                   Case strArc Of
                       'ARC': Begin
                              CopyMoveFile(g.LogFilePath, g.ArchivePath, tmp, 'M', strError);
                              SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' + tmp + ' Archived', True);
                              End;
                       'ARCDEL': Begin
                                 SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' -' + tmp + ' Data Saved', True);
                                 SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' + tmp + ' Deleted', True);
                                 End
                   End;{Case}
               End;{If}
               End;
           0:  Begin //Diff is zero
                   //File is today, may not be finished yet
                   If strComplete = 'Y' Then
                       Begin
                       //File is complete, archive
                       SendTextToMemo(frmAuroraDataUpload.RmFileScanLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' + tmp + ' Archived', True);
                       CopyMoveFile(g.LogFilePath, g.ArchivePath, tmp, 'M', strError);
                       End
                   Else
                       Begin
                       //File is partial, may not be complete yet, do nothing
                       WriteLn('File is partial, may not be complete yet, do nothing');
                   End;{If}
               End;
           -1:  ShowMessage('=== 1  ' + IntToStr(iDiff));  //Diff is NEgative
      End;{Case}
  End;{If (g.DataBaseUpdate = True)}
  g.LastLogFileFound :=tmp;   //Save last logfile name
  //Refresh web View -- Is this necessary???
  //RefreshWebPage(True)
End;{Procedure FileScanProcessing}

//------------------------------------------------------------------------------
//Procedure : CopyMoveFile
//Author    : Richard Wilkinson
//Date      : 11/05/2024
//Purpose   : Procedure to copy of move file from source path to dest path
//          : CopyMove is a flag 'C' = Copy file
//          :                    'M' = Move file
//------------------------------------------------------------------------------
Procedure CopyMoveFile(SourcePath, DestPath, FileName, CopyMove, strError: String);
Var
  strSrc:   String;
  ret:      Boolean;
Begin
  //ShowMessage(SourcePath + '/' + FileName);
  strSrc:= SourcePath + '/' + FileName;
  If FileExists(strSrc) Then
      Begin
      //Log file exists so copy to temp folder
      //Check that dest folder exists
      If Not DirectoryExists(DestPath) Then
          Begin
          //Need to create dest folder
          ret:= CreateDir(DestPath);
          {End}
      End;{If}
      //Do the copy or move
      Case CopyMove Of
          'C' : CopyFile(strSrc, DestPath + '/' + FileName, True);
          'M' : Begin
          //ShowMessage('Dest=' + DestPath + lineending + 'strSrc=' + strSrc);
                DeleteFile(DestPath + '/' + FileName);
                CopyFile(strSrc, DestPath + '/' + FileName, True);
                DeleteFile(SourcePath + '/' + FileName);
                End
      Else
          ShowMessage('Invalid option ' + CopyMove);
      End;{Case}
      End
  Else
      Begin
      strError:= 'File ' + strSrc + ' not found';
      ShowMessage(strError);
      {End}
  End;{If}
End;{Procedure CopyMove}

//------------------------------------------------------------------------------
//Procedure : AppendData
//Author    : Richard Wilkinson
//Date      : 12/05/2024
//Purpose   : Add data records from source path to dest path
//          : Called from DoArchive to handle condition when inverter starts
//          : to log after inverster restart on same day
//------------------------------------------------------------------------------
Procedure AppendData(FileName, FromPath, ToPath: String);
Var
    pFrom:   String;
    pTo:     String;
    fFrom:   Text;
    fTo:     Text;
    strLine: String;
Label
    NextLine;     //This label is used to help simulate VB6's IF - ELSEIF
Begin
    //Open files
    pFrom:= FromPath + '/' + FileName;
    pTo:= ToPath + '/'+ FileName;
    Assign(fFrom, pFrom);
    Reset(fFrom);
    Assign(fTo, pTo);
    Append(fTo);
    While Not EOF(fFRom) Do
        Begin
        ReadLn(fFrom, strLine);
        If Length(strLine) = 0 Then
            Begin
            //Ignore line
            GOTO NextLine;
        End;{If}
        If MidStr(strLine, 3, 1) = ':' Then
            Begin
            //This is data
            WriteLn(fTo, strLine);
            GoTo NextLine;
        End;{If}
        NextLine:
    End;{While}
    Close(fFrom);
    Close(fTo);
End;{Procedure AppendData}

//------------------------------------------------------------------------------
//Procedure : DataRecs
//Author    : Richard Wilkinson
//Date      : 13/05/2024
//Purpose   : Return the number of data records in the supplied file
//------------------------------------------------------------------------------
Function DataRecs(FileName, FilePath: String): Int32;
Var
  strFile:    String;
  fFile:      Text;
  strLine:    String;
  iData:      Int32;
Label
  NextLine;     //This label is used to help simulate VB6's IF - ELSEIF
Begin
  strFile:= FilePath + '/' + FileName;
  Assign(fFile, strFile);
  Reset(fFile);
  iData:=0;
  While Not EOF(fFile) Do
      Begin
      ReadLn(fFile, strLine);
      If Length(strLine) = 0 Then
          Begin
          //Ignore line
          GoTo NextLine;
      End;{If}
      If MidStr(strLine, 3, 1) = ':' Then
          Begin
          //This is a data line
          iData:= iData + 1;
          GoTo NextLine;
      End;{If}
      NextLine:
  End;{While}
  Result:=iData;
  Close(fFile);
End;{Function DataRecs}

//------------------------------------------------------------------------------
//Function  : DoArchive
//Author    : Richard Wilkinson
//Date      : 13/05/2024
//Purpose   : Handle the archive process, determining whether the current
//          : logfile shoiuld be archived, deleted or its data appended to
//          : the existing archive
//          : Very occassionally the inverter willswitch on after shutting down
//          : for the night if light levels have raised.  Inverter thinks it
//          : is morning!
//------------------------------------------------------------------------------
Function DoArchive(FileName, FromPath, ToPath: String): String;
Var
  iCurDataRecs:  Int32;
  iArcDataRecs:  Int32;
  iRet:          String;
Label
    Done;        //This label is used to help simulate VB6's IF - ELSEIF
Begin
  //Need to check if archive file exists, if not the Datarecs will fail
  If Not FileExists(ToPath + '/' + FileName) Then
      Begin
      //If no archive then just do regular archive
      iRet:='ARC';
      End
  Else
      Begin
      //Do records/archive checks
      iCurDataRecs:=DataRecs(FileName, FromPath);
      iArcDataRecs:=DataRecs(FileName, ToPath);
      If iCurDataRecs = iArcDataRecs Then
          Begin
          //Same number of data recs so ok to do regular archive
          iRet:='ARC';
          GoTo Done;
      End;{If}
      If iCurDataRecs > iArcDataRecs Then
          Begin
          //More recs in current file than archive, do regular archive
          iRet:='ARC';
          GoTo Done;
      End;{If}
      If iCurDataRecs < iArcDataRecs Then
          Begin
          //Likely just one or two recs after inverter restart on same day
          //Do append and delete the current file
          AppendData(FileName, FromPath, ToPath);
          DeleteFile(FromPath + '/' + FileName);
          iRet:='ARCDEL';
          GoTo Done;
      End;{If}
  End;{If}
  Done:
Result:=iRet;
End;{Function DoArchive}

//------------------------------------------------------------------------------
//Function  : IsDataComplete
//Author    : Richard Wilkinson
//Date      : 13/05/2024
//Purpose   : Function to check data and make an assessment of the data
//          : completeness
//          : Returns Y if data is complete otherwise N
//------------------------------------------------------------------------------
Function IsDataComplete(fDate: String; iSysS, iData: Int32; sSect, sFirstTime, sLastTime: String): String;
Var
  strDataState:    String;
  argStrEarliestTimes: ar12;
  argStrLatestTimes:   ar12;
  argintMaxTimes:      ari12;
  gstrEarliestTime:    String;
  gstrLatestTime:      String;
  gintMaxTimes:        Int32;
  idays:               Int64;
  iMins:               Int64;
  aNow:                TDateTime;
  aThen:               TDateTime;
Label
  lblNext;             ////This label is used to help simulate VB6's IF - ELSEIF
Begin
  //Uses globals gstrEarliestTime, gstrLatestTime, gintMaxTimes
  //Assumption is that data is complete if iSysS=5 and strSect="SysS"
  //Lookup values for use in this routine
  LoadTimesStr(argStrEarliestTimes, g.EarliestTimes, 'E');
  LoadTimesStr(argStrLatestTimes, g.LatestTimes, 'L');
  LoadTimesNum(argintMaxTimes, g.MaxTimes);
  gstrEarliestTime:= argStrEarliestTimes[GetMonthNo(fDate)];
  gstrLatestTime:= argStrLatestTimes[GetMonthNo(fDate)];
  gintMaxTimes:= argIntMaxTimes[GetMonthNo(fDate)];

// ShowMessage('Time:' + IntToStr(MyDateDiff('T', '15:30', '14:28')));
// ShowMessage('Date:' + IntToStr(MyDateDiff('D', '2024-05-14', '2024-04-13')));

  strDataState:= 'Y';
  If (iSysS = 5) And (sSect = 'SysS') Then   //First end state
      Begin
      //Assumption true so far strDataState = "Y"
      If iData >= gintMaxTimes Then
          Begin
          //Still ok
          //ShowMessage('Early=' + IntToStr(MyDateDiff('T', sFirstTime, gstrEarliestTime)));
          //SHowMessage('Late=' + IntToStr(MyDateDiff('T', sLastTime, gstrLatestTime)));
          If (MyDateDiff('T', sFirstTime, gstrEarliestTime) >= 0) AND
             (MyDateDiff('T', sLastTime, gstrLatestTime) >= 0) Then     //Was <= error!!
              Begin
              //Still OK
              strDataState:='Y';
              End
          Else
              Begin
              strDataState:='M';
              WriteLn(fDate + ' - fail at start time:F/E: ' + sFirstTime + '/' + gstrEarliestTime);
              WriteLn(fDate + ' - fail at end time:L/L: ' + sLastTime + '/' + gstrLatestTime);
          End;{If}
          End
     Else
         Begin
         strDataState:='M';
         WriteLn(fDate + ' - fail at number of times:Actual/Max ' + IntToStr(iData) + '/' + IntToStr(gintMaxTimes));
     End;{If}
     GoTo lblNext;
     End;{If}
  {Else}If iSysS = 0 Then
      Begin
      //System section missing
      strDataState:= 'N';
      WriteLn(fDate + ' - fail at System section missing');
      GoTo lblNext
  End;{If}
  lblNext:
  WriteLn('End of first state ' + strDataState);
  //Alternate end state, typically after power cut or program restart. EOF is at section "data"
  If sSect = 'Data' Then
      Begin
      WriteLn('In sSect = Data');
      //Maybe partial
      If iSysS = 5 Then
          Begin
          //Still ok
          strDataState:='Y';
          If iData >= gintMaxTimes Then
             Begin
             //Still ok
             strDataState:='Y';
             If (sFirstTime <= gstrEarliestTime) Or (sLastTime >= gstrLatestTime) Then
                 Begin
                 //Still ok
                 strDataState:='Y';
                 End
                Else
                 Begin
                 strDataState:='N';
             End;{If}
             End
          Else
             Begin
             strDataState:='N';
          End;{If}
          End
      Else
          Begin
          strDataState:='N';
      End;{If}
//      End
  End;{If}
WriteLn('End of second state ' + strDataState);
Result:=strDataState;
WriteLn('IsdataComplete returned = ' + strDataState);
End;{Function IsDataComplete}

//------------------------------------------------------------------------------
//Procedure : LoadTimesStr
//Author    : Richard Wilkinson
//Date      : 13/05/2024
//Purpose   : Load earliestTime values from global var (from ini file)
//          : into array
//------------------------------------------------------------------------------
Procedure LoadTimesStr(VAR arStrTimes: ar12; strArrayOfTimes, strType: String);
Var
  i:               Int32;
  strTimeAssumed:  String;
  tmpList:         TStringArray;
Begin
Try
  //This routine will fail if the input attary of times is not present or has
  //less than 12 entries.  The Try - Except will catch this error and replace
  //the missing values with default values
  If strType = 'E' Then strTimeAssumed:= '08:00';
  If strType = 'L' Then strTimeAssumed:= '16:00';
  tmpList:=strArrayOfTimes.Split([';']);
  For i:= 1 to 12 Do
      Begin
      arStrTimes[i]:=tmpList[i-1];
  End;{For}
Except
  SendTextToMemo(frmAuroraDataUpload.RmFileScanError, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                 FormatDateTime('yyyy-mm-dd', Now()) + ' - ' +
                 'Not enough time values', True);
  For i:= 1 To 12 Do
      Begin
      arStrTimes[i]:=strTimeAssumed;
  End;{For}
End;
End;{Procedure LoadTimesStr}

//------------------------------------------------------------------------------
//Procedure : LoadTimesNum
//Author    : Richard Wilkinson
//Date      : 14/05/2024
//Purpose   : Load max number of times values from global var (from ini file)
//          : into array
//------------------------------------------------------------------------------
Procedure LoadTimesNum(VAR arStrNumbers: ari12; strArrayOfNumbers: String);
Var
  i:                  Int32;
  intNumberAssumed:   Int32;
  tmpList:            TStringArray;
Begin
Try
  //This routine will fail if the input attary of numbers is not present or has
  //less than 12 entries.  The Try - Except will catch this error and replace
  //the missing values with default values
  intNumberAssumed:= 50;
  tmpList:=strArrayOfNumbers.Split([';']);
  For i:= 1 to 12 Do
      Begin
      arStrNumbers[i]:=StrToInt(tmpList[i-1]);
  End;{For}
Except
  SendTextToMemo(frmAuroraDataUpload.RmFileScanError, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                 FormatDateTime('yyyy-mm-dd', Now()) + ' - ' +
                 'Not enough time values', True);
  For i:= 1 To 12 Do
      Begin
      arStrNumbers[i]:=intNumberAssumed;
  End;{For}
End;
End;{Procedure LoadTimesNum}

//------------------------------------------------------------------------------
//Function  : GetMonthNo
//Author    : Richard Wilkinson
//Date      : 14/05/2024
//Purpose   : Return the month no as int from string form of date yyyy-mm-dd
//------------------------------------------------------------------------------
Function GetMonthNo(fDate: string): Int32;
Begin
  GetMonthNo:=StrToInt(MidStr(fDate,6,2));
End;{Function GetMonthNo}

//------------------------------------------------------------------------------
//Procedure : FileParse
//Author    : Richard Wilkinson
//Date      : 14/05/2024
//Purpose   : Read log file and parse it into 4 separate file for the sections
//          : yyyy-mm-dd-DA   for data records
//          : yyyy-mm-dd-IN   for Inverter info
//          : yyyy-mm-dd-SY   for System info
//          : yyyy-mm-dd-UN   for Units info
//------------------------------------------------------------------------------
Procedure FileParse(fDate, TempPath: String; VAR iData: Int32; VAR Complete: String);
Var
   DatFiles:        TStringList;
   iDat:            Int32;
   i:               Int32;
   fLog:            Text;
   fDat:            Text;
   fIn:             Text;
   fSys:            Text;
   fUn:             Text;
   strLine:         String;
   iInfo:           Int32;
   iUnit:           Int32;
   iSys:            Int32;
   strSect:         String;
   strFirstTime:    String;
   strLastTime:     String;
Label
    lblNext;

Begin
  //Check for existing temp files, delete if found
  DatFiles:= TStringList.Create;
  FindAllFiles(DatFiles, TempPath, '*.dat', False); //find all temp data files
  iDat:=datFiles.Count;
  If iDat > 0 Then
      Begin
      //Files found to delete
      For i:= 0 To iDat - 1 Do
          Begin
          DeleteFile(DatFiles[i]);
      End;{For}
  End;{If}
  //Ceate & open files for input and output
  Assign(fLog, TempPath + '/' + fDate + '.log'); //Input log file
  Assign(fDat, TempPath + '/' + fDate + '-DA.dat'); //Output inverter info file
  Assign(fIn, TempPath + '/' + fDate + '-IN.dat'); //Output inverter info file
  Assign(fSys, TempPath + '/' + fDate + '-SY.dat'); //Output inverter info file
  Assign(fUn, TempPath + '/' + fDate + '-UN.dat'); //Output inverter info file
  Reset(fLog);
  ReWrite(fDat);
  ReWrite(fIn);
  ReWrite(fSys);
  ReWrite(fUn);
  While Not EOF(fLog) Do
      Begin
      //Parse file one line at a time
      ReadLn(fLog, strLine);
      If MidStr(strLine, 4,6) = '[info]' Then
          Begin
          //The log file comtains 3 sDatenon printing chars at the start
          strLine:= MidStr(StrLine, 4, 999);
          iInfo:=0;
          strSect:='Info';
          GoTo lblNext;
      End;{If}
      If LeftStr(strLine, 14) = '[measurements]' Then
          Begin
          iUnit:=0;
          strSect:='Unit';
          GoTo lblNext;
      End;{If}
      If LeftStr(strLine, 7) = '[start]' Then
          Begin
          iData:=0;
          strSect:='Data';
          GoTo lblNext;
      End;{If}
      If LeftStr(strLine, 15) = '[system status]' then
          Begin
          iSys:=-1;
          strSect:='SysS';
          GoTo lblnext;
      End;{If}
      If Length(strLine) = 0 Then
          Begin
          //Blank line, ignore
          strSect:='Skip';
          GoTo lblNext;
      End;{If}
      If MidStr(strLine,3 , 1) = ':' Then
          Begin
          //This is a data record but something is probably out of place in file
          strSect:='Data';
          GoTo lblNext;
      End;{If}
      lblNext:
      Case strSect Of
          'Skip': ; //Do nothing
          'Info': Begin
                  iInfo:= iInfo + 1;
                  If iInfo > 1 Then WriteLn(fIn, strLine);
                  End;
          'Unit': Begin
                  iUnit:= iUnit + 1;
                  If iUnit > 1 Then WriteLn(fUn, strLine);
                  End;
          'SysS': Begin
                  iSys:= iSys + 1;
                  If iSys > 0 Then WriteLn(fSys, strLine);
                  End;
          'Data': Begin
                  iData:= iData + 1;
                  If iData = 2 Then strFirstTime:= MidStr(strLine, 1, 5);
                  //Assumes that time is first field
                  If iData > 1 Then
                      Begin
                      strLastTime:= MidStr(strLine, 1, 5);
                      WriteLn(fDat, strline);
                  End;{If}
                  End;{Case Data}
      End;{Case}
  End;{While}
  iData:= iData -1; //adjust count for skipped header record

//These two lines missing but in Lazarus return Complete not strComplete
//        ' Now do some checking to see if the data is complete
  Complete:=IsDataComplete(fDate, iSys, iData, strSect, strFirstTime, strLastTime);

  //And close files
  Close(fLog);
  Close(fDat);
  Close(fIn);
  Close(fSys);
  Close(fUn);
  //WriteLn('FileParse found ' + IntToStr(iData) + ' Recs');
End;{Procedure FileParse}

//------------------------------------------------------------------------------
//Function  : MyDateDiff
//Author    : Richard Wilkinson
//Date      : 15/05/2024
//Purpose   : Function to return the number of minutes/Days between
//          : two times/dates.  Function needed because standard DateTime
//          : functions cannot handle yyyy-mm-dd date format
//------------------------------------------------------------------------------
Function MyDateDiff(sDorT, sNow, sthen: String): Int32;
  Var
     aNow:       TDateTime;
     aThen:      TDateTime;
     iMins:      Int32;
     iDays:      Int32;
  Begin
  If sDorT = 'T' Then
      Begin
      aNow:=strToTime(sNow);
      aThen:=strToTime(sThen);
      iMins:=MinutesBetween(aNow, aThen);
      Result:=iMins;
      End
      //process time
  Else
      Begin
      //process Date
      aNow:=ISO8601ToDate(sNow);
      aThen:=ISO8601ToDate(sThen);
      iDays:=DaysBetween(aNow, aThen);
      Result:=iDays;
  End;{If}
End;{Function MyDateDiff}

//------------------------------------------------------------------------------
//Function  : DoesTimeExist
//Author    : Richard Wilkinson
//Date      : 16/05/2024
//Purpose   : Function to check if record exists current record, Date & Time
//          : The day id passed as the day record's ID, not the string date
//          : Returns Boolean
//------------------------------------------------------------------------------
Function DoesTimeExist( DayId: Int32; sTime: String): Boolean;
Var
   strSQL:        String;
   strDbFullPath: String;
   iTime:         Int32;
Begin
Result:=False;
strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
If OpenDb(strDbFullPath) = True Then
    Begin
    //Database opened ok, continue
    strSql:= 'SELECT  * FROM Times WHERE DayId = ' + IntToStr(DayId) + ' AND Time = ' + QuotedStr(sTime);
    //ShowMessage(strSQL);
    dBQuery.SQL.Text:=strSql;
    dBQuery.Open;
    dbQuery.Last;
    iTime:=dbQuery.recordcount;
    If iTime = 0 Then
        Begin
        //Not found
        Result:=False;
        End
    Else
        Begin
        //Found
        Result:=True;
    End;{If}
    //Done, close database
    CloseDb;
End;{If}
End;{Function DoesTimeExist}

//------------------------------------------------------------------------------
//Function  : GetUnitId
//Author    : Richard Wilkinson
//Date      : 16/05/2024
//Purpose   : Function to return UnitId from Units table for supplied values
//          : if it exists, create it if not
//          : Returns UnitID as integer
//------------------------------------------------------------------------------
//Function GetUnitId(sColName, sUnit: String): Int32;
Function GetUnitId: Int32;
Var
   strDbFullPath: String;
   strSQL:        String;
   iUnit:         Int32;
   iUnitID:       Int32;
Begin
iUnitID:=0;  //Initialise return value
strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
If OpenDb(strDbFullPath) = True Then
    Begin
    strSQL:='SELECT * FROM Units WHERE ColNames = ' + QuotedStr(gSys.ColNames);
    dBQuery.SQL.Text:=strSql;
    dBQuery.Open;
    dbQuery.Last;
    iUnit:=dBQuery.recordcount;
    If iUnit = 0 Then
        Begin
        //Not found, need to add
        dBQuery.Append;
        dbQuery.FieldByName('ColNames').AsString:=gSys.ColNames;
        dBQuery.FieldByName('ColUnits').AsString:=gSys.ColUnits;
        dBQuery.ApplyUpdates;
        //And get the id of inserted record
        iUnitID:=dbQuery.FieldByName('UnitID').AsInteger;
        End
    Else
        Begin
        //Found, continue
        iUnitID:=dbQuery.FieldByName('UnitID').AsInteger;
    End;{If}
End;{If}
Result:=iUnitID;
CloseDb;
End;{Function GetUnitId}

//------------------------------------------------------------------------------
//Function  : GetDayId
//Author    : Richard Wilkinson
//Date      : 16/05/2024
//Purpose   : Function to return DayId from Days table for supplied date
//          : if it exists, if it does not exist then create it
//          : Returns DayId as integer
//------------------------------------------------------------------------------
Function GetDayId(sDate, sTimeOn, sTimeOff: String; iEnergyToday,
                  iEnergyLife: Single; iInvId: Int32): Int32;
Var
   strSQL:         String;
   strDbFullPath:  String;
   iDay:           Int32;
Label              lblNext;
Begin
iDay:=0;  //Initialise return value
strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
If OpenDb(strDbFullPath) = True Then
    Begin
    strSQL:='SELECT * FROM Days WHERE Date = ' + QuotedStr(sDate);
    //showMessage(strSQL);
    dBQuery.SQL.Text:=strSql;
    dBTrans.active:=True;
    dBQuery.Open;
    dbQuery.Last;
    iDay:=dBQuery.recordcount;
    If iDay = 0 Then
        Begin
        //Not found, need to add
        dBQuery.Append;
        dbQuery.FieldByName('Date').AsString:=sDate;
        dBQuery.FieldByName('Uploaded').AsString:='N';
        dBQuery.FieldByName('Complete').AsString:='N';
        dBQuery.FieldByName('TimeOn').AsString:=gSys.SysTimeOn;
        dBQuery.FieldByName('TimeOff').AsString:=gSys.SysTimeOff;
        dBQuery.FieldByName('EnergyToday').AsFloat:=iEnergyToday;
        //Update peak later
        dBQuery.FieldByName('EnergyLife').AsFloat:=iEnergyLife;
        //WriteLn('Date=' + sDate + '  EnergyToday=' + FloatToStr(iEnergyLife));
        dBQuery.FieldByName('InverterId').AsInteger:=iInvId;
        dBQuery.ApplyUpdates;
        //And get the id of inserted record
        iDay:=dbQuery.FieldByName('DayId').AsInteger;
        GoTo lblNext;
    End;{If}
    {Else}If iDay = 1 Then
        Begin
        //Found, continue
        iDay:=dbQuery.FieldByName('DayId').AsInteger;
    End{If}
Else
    Begin
    //Unexpected record count
    WriteLn('Unexpected record count = ' + IntToStr(iDay) +
             ' at ' + sDate + '  ' + sTimeOn);
    End;
End;{If}
lblNext:
dBTrans.Commit;
Result:=iDay;
CloseDb;
End;{Function GetDayId}

//------------------------------------------------------------------------------
//Procedure : ReadSyFile
//Author    : Richard Wilkinson
//Date      : 16/05/2024
//Purpose   : To read information file, yyyy-mm-dd-SY.dat and
//          : Get values for class properties gSys. SysTimeOn, SysTimeOff,
//          : EnergyToday and Energylife
//------------------------------------------------------------------------------
//Procedure ReadSyFile(fDate: String; VAR TimeOn, TimeOff: String; VAR EnergyToday, EnergyLife: Single);
Procedure ReadSyFile(fDate: String);
Var
   fPath: String;
   fNo:   Text;
   strLine:    String;
   i, j:       Int32;
   tmpList:    TStringArray;
   itmp:       Int32;
Begin
Try
  //Assign & open input file
  itmp:=0;
  fPath:=g.TempPath + '/' + fDate + '-SY.dat';
  Assign(fNo, fpath);
  Reset(fNo);
  //System Time
  //Skip over systen Date/Time   //add later
  ReadLn(fNo, strLine);

  //System On Time
  ReadLn(fNo, strLine);
  i:=Pos(':', strLine);
  j:=Length(strLine);
  If j > i+2 Then
      Begin
      tmpList:=MidStr(strLine,i+2,j-i).Split([' ']);
      //TimeOn:=LeftStr(tmpList[1], 5);
      gSys.SysTimeOn:=LeftStr(tmpList[1], 5);
      itmp:=1;
      End
  Else
      Begin
      //Not provided
      //TimeOn:='00:00';
      gSys.SysTimeOn:='00:00';
  End;{If}
  //System Off Time
  ReadLn(fNo, strLine);
  i:=Pos(':', strLine);
  j:=Length(strLine);
  If j > i+2 Then
      Begin
      tmpList:=MidStr(strLine,i+2,j-i).Split([' ']);
      //TimeOff:=LeftStr(tmpList[1], 5);
      gSys.SysTimeOff:=LeftStr(tmpList[1], 5);
      itmp:=2;
      End
  Else
      Begin
      //Not provided
      //TimeOff:='00:00';
      gSys.SysTimeOff:='00:00';
  End;{If}
  //Energy Today
      ReadLn(fNo, strLine);
      i:=Pos(':', strLine);
      j:=Length(strLine);
  If j > i+2 Then
      Begin
      tmpList:=MidStr(strLine,i+2,j-i).Split([' ']);
      //EnergyToday:=StrToFloat(tmpList[0]);
      gSys.EnergyToday:=StrToFloat(tmpList[0]);
      itmp:=3;
      End
  Else
      Begin
      //Not provided
      //EnergyToday:=0;
      gSys.EnergyToday:=0;
  End;{If}
  //Energy Life
  ReadLn(fNo, strLine);
  i:=Pos(':', strLine);
  j:=Length(strLine);
  If j > i+2 Then
      Begin
      tmpList:=MidStr(strLine,i+2,j-i).Split([' ']);
      //EnergyLife:=StrToFloat(tmpList[0]);
      gSys.EnergyLife:=StrToFloat(tmpList[0]);
      //WriteLn('ReadSys EnergyLife=' + FloatToStr(EnergyLife));
      itmp:=4;
      End
  Else
     Begin
     //Not provided
     //EnergyLife:=0;
     gSys.EnergyLife:=0;
  End;{If}
Except
  on E: Exception do
     Begin
     Case itmp Of
         1: Begin
         //TimeOff:='';
         //EnergyToday:=0;
         //EnergyLife:=0;
         gSys.SysTimeOff:='XX';
         gSys.EnergyToday:=0;
         gSys.EnergyLife:=0;
         End;
         2: Begin
         //EnergyToday:=0;
         //EnergyLife:=0;
         gSys.EnergyToday:=0;
         gSys.EnergyLife:=0;
         End;
         3: Begin
         //EnergyLife:=0;
         gSys.EnergyLife:=0;
         End;
         4:
     End;{Case};
     WriteLn( 'Error in Procedure "ReadSyFile" : '+ E.ClassName + '  ' + E.Message );
     End;
End;{Try}
End;{Procedure ReadSyFile}

//------------------------------------------------------------------------------
//Procedure : ReadInFile
//Author    : Richard Wilkinson
//Date      : 19/05/2024
//Purpose   : To read information file, yyyy-mm-dd-SY.dat and
//          : Get values for class properties gSys. SystemName and SystemDate
//------------------------------------------------------------------------------
//Procedure ReadInFile(fDate: String; VAR SystemName, SystemDate: String);
Procedure ReadInFile(fDate: String);
Var
  fPath:       String;
  fNo:         Text;
  strLine:     String;
  i, j:        Int32;
Begin
Try
  //Assign & open input file
  fPath:=g.TempPath + '/' + fDate + '-IN.dat';
  Assign(fNo, fPath);
  {$I-}
  Reset(fNo);
  {$I+}
  //SysTem Name
  ReadLn(fNo, strLine);
  i:=Length(strLine);
  j:=Pos(':', strLine);
  If i - j > 1 Then
      Begin
      //OK to get System Name
      //SystemName:=MidStr(strLine, J+2, i-j+1);
      gSys.SystemName:=MidStr(strLine, J+2, i-j+1);
      End
  Else
      Begin
      //SystemName:='Not provided';
      gSys.SystemName:='Not provided';
  End;{If}
  //System Date
  ReadLn(fNo, strLine);
  i:=Length(strLine);
  j:=Pos(':', strLine);
  If i - j > 1 Then
      Begin
      //OK to get System Name
      //SystemDate:=MidStr(strLine, J+2, i-j+1);
      gSys.SystemDate:=MidStr(strLine, J+2, i-j+1);
      End
  Else
      Begin
      //SystemDate:='Not provided';
      gSys.SystemDate:='Not provided';
  End;{If}
  Close(fNo);
Except
  On E: Exception Do
  Begin
  WriteLn('Error in procedure "ReadINFile"" :' + E.ClassName + ' ' + E.Message);
  //SystemName:='Not provided';
  gSys.SystemName:='Not provided';
  If ioResult > 0 Then Close(fNo);
  End;
End;{Try}
End;{Procedure ReadInFile}

//------------------------------------------------------------------------------
//Procedure : ReadUnFile
//Author    : Richard Wilkinson
//Date      : 19/05/2024
//Purpose   : To read units file, yyyy-mm-dd-UN.dat and
//          : return ColumnNames and Units
//------------------------------------------------------------------------------
Procedure ReadUnFile(fDate: String; VAR sColNames, sUnits: String);
Var
  fPath:     String;
  fNo:       Text;
  strLine:   String;
  i, j:      Int32;
Begin
Try
  //Assign & open input file
  fPath:=g.TempPath + '/' + fDate + '-UN.dat';
  Assign(fNo, fPath);
  {$I-}
  Reset(fNo);
  {$I+}
  //Read Column Names
  ReadLn(fNo, strLine);
  i:=Length(strLine);
  j:=Pos('GENFREQ', strLine);
  If j > 0 Then
      Begin
      //OK to get column Names
      sColNames:=MidStr(strLine, 1, i-1);  //Last char is redundant
      gSys.ColNames:=MidStr(strLine, 1, i-1);  //Last char is redundant
      End
  Else
      Begin
      gSys.ColNames:='Not provided';
  End;{If}
  //Read Units
  ReadLn(fNo, strLine);
  i:=Length(strLine);
  j:=Pos('Hz', strLine);
  If j > 0 Then
      Begin
      //OK to get column Names
      sUnits:=MidStr(strLine, 1, i-1);  //Last char is redundant
      gSys.ColUnits:=MidStr(strLine, 1, i-1);  //Last char is redundant
      End
  Else
      Begin
      sUnits:='Not provided';
      gSys.ColUnits:='Not provided';
  End;{If}
Close(fNo);
Except
    On E: Exception Do
    Begin
      WriteLn('Error in procedure "ReadUNFile"" :' + E.ClassName + ' ' + E.Message);
      sColNames:='Not provided';
      sUnits:='Not provided';
      If ioResult > 0 Then Close(fNo);
      //Close(fNo);
    End;
End;{Try}
End;{Procedure ReadUnFile}

//------------------------------------------------------------------------------
//Function  : GetInverterId
//Author    : Richard Wilkinson
//Date      : 19/05/2024
//Purpose   : To return the InverterId based on SystemName and ModelNo
//------------------------------------------------------------------------------
//Function GetInverterId(ModelNo, SystemName, MPPT, ColNames, ColUnits: String): Int32;
Function GetInverterId: Int32;
Var
  strSQL:         String;
  iInv:           Int32;
  iRecs:          Int32;
  strDbFullPath:  String;
Begin
TRY
  iInv:=0;  //Initialise return value
  strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
  If OpenDb(strDbFullPath) = True Then
      Begin
      strSql:='SELECT * FROM inverters WHERE ModelNo = ' + QuotedStr(gSys.Model) +
              ' AND SystemName = ' + QuotedStr(gSys.SystemName) + ';';
      //WriteLn(strSQL);
      dBQuery.SQL.Text:=strSql;
      dBQuery.Open;
      dbQuery.Last;
      iRecs:=dBQuery.RecordCount;
      If iRecs = 0 Then
          Begin
          //Not found add record
          dBQuery.Append;
          dBQuery.FieldByName('SystemName').AsString:=gSys.SystemName;
          dBQuery.FieldByName('ModelNo').AsString:=gSys.Model;
          dBQuery.FieldByName('MPPT').AsString:=gSys.MPPT;
          dBQuery.FieldByName('ColNames').AsString:=gSys.ColNames;
          dBQuery.FieldByName('ColUnits').AsString:=gSys.ColUnits;
          dBQuery.ApplyUpdates;
          //And get InverterId
          iInv:=dBQuery.FieldByName('InverterId').AsInteger;
          End
      Else
          Begin
          iInv:=dBQuery.FieldByName('InverterId').AsInteger;
      End;{If}
      Result:=iInv;
      //WriteLn(IntToStr(iInv));
      CloseDb;
  End;{If}
Except
  On E: Exception Do
  Begin
  WriteLn('Error in function "GetInverterId" :' + E.ClassName + ' ' + E.Message);
  End;
End;{Try}
End;{Function GetInverterId}

//------------------------------------------------------------------------------
//Procedure : UpdatePeakAndDaily
//Author    : Richard Wilkinson
//Date      : 19/05/2024
//Purpose   : To look up the daily energy total and peak generation value
//          : from Times table and update Days the Days table accordingly
//------------------------------------------------------------------------------
Procedure UpdatePeakAndDaily(strDate: String);
Var
  strDbFullPath: String;
  strSQL:        String;
  iPeak:         Int32;
  iDays:         Int32;
  Peak:          Single;
  EToday:        Int32;
  UpdateOk:      Boolean;
Begin
Try
  UpdateOK:=False;
  strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
  If OpenDb(strDbFullPath) = True Then
  strSql:='SELECT MAX(Times.pac) AS PEAK, MAX(Times.energy) as ' + QuotedStr('Energy Today') + ' FROM ' +
           'Days Inner Join Times on Days.dayid = Times.DayId WHERE Days.Date = ' + QuotedStr(strDate) + ';';


 //showMessage(strSQL);
  dBQuery.SQL.Text:=strSql;
  dBQuery.Open;
  dbQuery.Last;
  iPeak:=dBQuery.RecordCount;
  If iPeak = 1 Then
      Begin
      //Values found
      Peak:=dBquery.FieldByName('Peak').AsFloat;
      EToday:=dBquery.FieldByName('Energy Today').AsInteger;
      UpdateOK:=True;
      End
  Else
      Begin
      //Cannot get values as either too many records returned or none
      WriteLn('Error in "UpdatePeakAndDaily": incorrect record count returned');
      UpdateOk:=False;
  End;{If}
  //dBQuery.Close;
  CloseDb;
  OpenDb(strDbFullPath);
  //If values found from Times and if record exists in Days then update
  strSql:='SELECT * FROM DAYS WHERE Date = ' + QuotedStr(strDate) + ';';
  dBQuery.SQL.Text:=strSql;
  dBQuery.Open;
  DbQuery.Last;
  iDays:=DbQuery.RecordCount;
  dBQuery.Close;
  //ShowMessage(strSQL + LineEnding + 'iDays=' + IntToStr(iDays));
  If( iDays = 1) AND (UpdateOk = True) Then
      Begin
      //Ok to do update, but Sqlite may be in read only mode, quirk of using
      //multiple tables so need to close and re-open database
      dBQuery.SQL.Text:=strSql;
      dBTrans.Active:=True;;
      dBQuery.Open;
      DbQuery.Last;
      DbQuery.Edit;
      DbQuery.FieldByName('Peak').AsString:= FloatToStrF(Peak, ffFixed, 8, 1); //AsFloat:=Peak;
      DbQuery.FieldByName('EnergyToday').AsString:=FloatToStrF(EToday, ffFixed, 8, 0); //AsInteger:=EToday;
      DbQuery.ApplyUpdates;
      //ShowMessage('Done');
      End
  Else
      Begin
      //Unable to do update
      WriteLn('Unable to update in "UpdatePeakAndDaily": Days count = ' + IntToStr(iDays));
  End;{If}
  dBTrans.Commit;
CloseDb;

  //For testing
  //showMessage('Date=' + sDate + LineEnding +
  //            'Peak=' + FloatToStrF(Peak, ffFixed, 8, 1) + lineEnding + 'Energy Today=' + IntToStr(EToday));

Except
  On E: Exception Do
  Begin
  WriteLn('Error in function "UpdatePeakAndDaily"" :' + E.ClassName + ' ' + E.Message);
  End;
End;{Try}
End;{Procedure}

//------------------------------------------------------------------------------
//Procedure : DataBaseUpdate
//Author    : Richard Wilkinson
//Date      : 20/05/2024
//Purpose   : To read data from the -.DA.dat file and upload the data
//          : to the PvUpload database
//          : fDate in format yyyy-mm-dd is used for file operations only
//          : sDate, derived from fDate in format yyyy/mm/dd is used for date comparisons
//------------------------------------------------------------------------------
Procedure UpDateDataBase(fDate: String; VAR iDup, iUpd, iZero: Int32; sComplete, sSysName, sModel, sSysDate:String);
Var
  i:           Integer;             //Work var
  fPath:       String;              //For datafile access
  fNo:         Text;
  strLine:     String;
  arData:      TStringArray;        //For reading and splitting data line
  arDataLen:   Int32;
  iNewRecs:    Int32;               //Record counts
  iDupRecs:    Int32;
  iZeroRecs:   Int32;
  sSystemName: String;              //Returned by ReadInFile
  sSystemDate: String;
  sColNames:   String;              //returned by ReadUnFile
  sUnits:      String;
  sTimeOn:     String;              //Returned by ReadSyFile
  sTimeOff:    String;
  sEnergyToday:Single;
  sEnergyLife: Single;
  arInp:       ar19;                //An array ofelements used for writing a new Time record
  sUnitId:     Int32;
  sDayId:      Int32;               //Work var
  sDate:       String;              //Date in format yyyy/mm/dd
  iInvId:      Int32;               //Returned InverterId
  Complete:    String;              //Day's data completed status
  sTime:       String;              //Work var
  InverterID:  Int32;               //InverterID returned by GetInverterId
  DayId:       Int32;               //Work var
  UpLoaded:    String;              //Day uploaded status
  sMPPT:       String;              //Work var

Begin
Try

//Need to get Model & MPPT now so we can call ImnverterID, required for GetDayID
//So open -DA.dat file, get it and close
GetModelMPPT(fDate);  //Gets gSys. Model & MPPT

//Extract relevant information from temp files -In, -Un, -Sy

//First Information file -In
//ReadInFile(fDate, sSystemName, sSystemDate); //Gets gSys. SystemName & SystemDate
ReadInFile(fDate); //Gets gSys. SystemName & SystemDate

//Second Units file -Un
ReadUnFile(fDate, sColNames, sUnits); //Gets gSys ColNames & ColUnits

//Third System file -Sy
//Gets gSys. SysTimeOn & SysTimeOff & EnergyToday & EnergyLife
//ReadSyFile(fDate, sTimeOn, sTimeOff, sEnergyToday, sEnergyLife);
ReadSyFile(fDate);

//But we also do need ColNames & ColUnits for GetInverterID later in code
//sUnitId:=GetUnitId(sColNames, sUnits);  //Gets gSys ColNames & ColUnits
sUnitId:=GetUnitId;  //Gets gSys ColNames & ColUnits

//And InverterID for call to GetDayId
//Because it comes from reading the -DA.dat file
//InverterID:=GetInverterId(gSys.Model, sSystemName, gSys.MPPT, sColNames, sUnits);
InverterID:=GetInverterId;

//And get DayId for database inserts
sDayId:=GetDayId(fDate, gSys.SysTimeOn, gSys.SysTimeOff, gSys.EnergyToday, gSys.EnergyLife, InverterID);
//sDayId:=GetDayId(fDate, sTimeOn, sTimeOff, sEnergyToday, sEnergyLife, 99); //iInvId not known yet

//Now loop through all data lines in -DA.dat file and process
  iDupRecs:=0;
  iNewRecs:=0;
  iZeroRecs:=0;
  //Assign & open data file
  fPath:=g.TempPath + '/' + fDate + '-DA.dat';
  Assign(fNo, fPath);
  Reset(fNo);
  While Not Eof(fNo) Do
      Begin
      ReadLn(fNo, strLine);
      //Turn this string into a record of time,  need new function
      //08:02;2;PVI-3.6-OUTD-UK;D;131.4;0.0;0.0;92.8;0.0;0.0;238.8;0.8;0.0;18.9;17.8;0.0;14.1;0;0;
      //Ignore trailing ';' thus 19 elements running 0 to 18 in arData[i]
      If RightStr(strLine, 1) = ';' Then strLine:= MidStr(strLine,1, Length(strLine)-1);
      arData:=strLine.Split([';']);
      arDataLen:=length(arData);   //TSTringArray from -DA.dat file
      //Create array[1..19]  of string for input values
      For i:= 0 to arDataLen - 1 Do   //Remember length is number of elements, they start at zero
          Begin
          arInp[i+1]:= arData[i];
      End;{For}
      //WriteLn(strLine);
      If Not IsRecAllZero(arInp) Then
          //Ensure that record is not all zero's
          Begin
          //Use this record
          sTime:= arInp[1];   //arInp[1] = time
              //Does time exist in table times
              If DoesTimeExist( sDayId, sTime) = False Then
                  Begin
                  //Ok to insert new record in table Times but first
                  //We need InverterId for SQL insert plus items returned by GetInverterID
                  sMPPT:=arInp[4];
                  sModel:= arInp[3];
                  DayId:=sDayId;  //Is returned by function call DoesTimeExist
                  UpLoaded:='N';  //As this is a new record, always = 'N'
                  //InverterID:=GetInverterId(sModel, sSystemName, sMPPT, sColNames, sUnits);
                  InverterID:=GetInverterId;
                  dbTrans.Active:=True;
                  dbQuery.SQL.Text:='INSERT INTO TIMES (DayID, Time, Uploaded, Model, Address, MPPT, ' +
                                    'VDC1, IDC1, PDC1, VDC2, IDC2, PDC2, VAC, ' +
                                    'IAC, PAC, TINV, TINT, Energy, RISO, ILEAK, GenFreq) ' +
                                    'VALUES (' + IntToStr(DayID) + ', ' +   //DayId
                                    QuotedStr(arInp[1]) + ', ' +            //Time
                                    QuotedStr(Uploaded) + ', ' +            //Uploaded
                                    IntToStr(InverterID) + ', ' +           //Model
                                    arInp[2] + ', ' +                       //Address
                                    QuotedStr(arInp[4]) + ', ' +            //MPPT
                                    arInp[5] + ', ' +                       //VCD1
                                    arInp[6] + ', ' +                       //IDC1
                                    arInp[7] + ', ' +                       //PDC1
                                    arInp[8] + ', ' +                       //VDC2
                                    arInp[9] + ', ' +                       //IDC2
                                    arInp[10] + ', ' +                      //PDC2
                                    arInp[11] + ', ' +                      //VAC
                                    arInp[12] + ', ' +                      //IAC
                                    arInp[13] + ', ' +                      //PAC
                                    arInp[14] + ', ' +                      //TINV
                                    arInp[15] + ', ' +                      //TINT
                                    arInp[16] + ', ' +                      //Energy
                                    arInp[17] + ', ' +                      //RISO
                                    arInp[18] + ', ' +                      //ILEAK
                                    arInp[19] + ');';                       //GENFREQ
                  dbQuery.ExecSQL;
                  dbTrans.Commit;
                  Inc(iNewRecs);
                  //WriteLn('Insert ' + IntToStr(iNewRecs));
                  End
              Else
                  Begin
                  //Time already exists
                  Inc(IdupRecs);
                  //WriteLn('Duplicate time ignore : ' + arInp[1]);
              End;{If DoesTimeExist}
          End
      Else
          Begin
          //A zero record, ignore
          Inc(iZeroRecs);
      End;{If IsRecAllZero}
  End;{While}
  If iNewRecs >= 0 Then iUpd:=iNewRecs;
  If iDupRecs >= 0 Then iDup:=iDupRecs;
  If iZeroRecs >= 0 Then iZero:=iZeroRecs;
  Close(fNo);

Except
On E: EDataBaseError Do
  Begin
  //Needs Db in Uses statement
  WriteLn('Raised Exception: ' + E.ClassName + ' With message: ' + E.Message);
  End;
  On E: Exception Do
  Begin
  WriteLn('Error in procedure "UpDateDataBase" :' + E.ClassName + ' ' + E.Message);
  End;
End;{Try}
End;{Procedure UpDateDataBase}

//------------------------------------------------------------------------------
//Function  : IsRecAllZero
//Author    : Richard Wilkinson
//Date      : 23/05/2024
//Purpose   : To check if allelements of time record are zero
//          : Return True if yes, else False
//------------------------------------------------------------------------------
Function IsRecAllZero(arIn:ar19): Boolean;
Var
  iLen:     Int32;
  i:        Int32;
  tmp:      String;
Begin
iLen:=High(arIn);
//Loop through data elements checking fo zero
Result:=True;  //Zero record unless we find non zero values
For i:= 5 to iLen Do
    Begin
    tmp:=arIn[i];
    Case tmp Of
        '0':    ;
        '0.0': ;
        Else
          Result:=False;
    End;{Case}
End;{For}
//For testing
//WriteLn(IntToStr(iLen) + '    ' + arIn[1] + '   ' +  arIn[19] + '   ' + BoolToStr(Result));
End;{Function IsRecAllZero}

//------------------------------------------------------------------------------
//Function  : IsSlotFree
//Author    : Richard Wilkinson
//Date      : 01/07/2024
//Purpose   : To check if slot is free for data upload
//          : Look in class Global PvUploadSlotRemaining
//          : Return true if yes, else false
//------------------------------------------------------------------------------
Function IsSlotFree(): Boolean;
Begin
If g.PvUploadSlotRemaining > 2 Then
    Begin
    Result:= True;
    End
Else
    Begin
    Result:= False;
End;{If}
End;{Function IsSlotFree}

//------------------------------------------------------------------------------
//Procedure : ResetUpdateSlots
//Author    : Richard Wilkinson
//Date      : 01/07/2024
//Purpose   : To check if slot is free for data upload
//          : To reset UpdateSlots to Max value on the hour
//          : intChange = 0 reset to max value
//          : intChange <0 decrement slot count
//------------------------------------------------------------------------------
Procedure ResetUpdateSlots(intChange:Int32);
Var
  strTmp:       String;
  strResetTime: String;
  fIni:         TiniFile;
  iniFile:      String;
  dtTime:       TDateTime;
Begin
Try
    If intChange = 0 Then
        Begin
        //Reset slot count to max value and reset time to current hour
        iniFile:= GetPath(3, True) + '/PvUpload.ini';
        fIni := TIniFile.Create(IniFile);
        g.PvUploadSlotRemaining:=g.PvUploadSlotLimit;
        frmSettings.txtPvUploadSlotRemaining.Text:=IntToStr(g.PvUploadSlotLimit);
        fIni.WriteString( 'PvUpload', 'PvUploadSlotRemaining', IntToStr(g.PvUploadSlotLimit));
        // And then reset time
        //Get PvUploadTimeReset from form and add 1 hour
        dtTime:=  StrToTime(g.PvUploadSlotTimeReset);
        dtTime:=IncHour(dtTime);
        strResetTime:=FormatDateTime('hh:nn', dtTime);
        fIni.WriteString( 'PvUpload', 'PvUploadSlotTimeReset',strResetTime);
        g.PvUploadSlotTimeReset:=strResetTime;
        frmSettings.txtPvUploadSlotTimeReset.Text:=strResetTime;
        SendTextToMemo(frmAuroraDataUpload.RmPvUploadLog, FormatDateTime('hh' + ':' + 'nn', Now()) + ' - ' +
                       FormatDateTime('yyyy-mm-dd', Now()) + ' - ' +
                       'Slot count/time reset', True);
        fIni.Free;
    End;{If}
    If intChange < 0 Then
        Begin
        //Decrement slot count
        iniFile:= GetPath(3, True) + '/PvUpload.ini';
        fIni := TIniFile.Create(IniFile);
        strTmp:=IntToStr(g.PvUploadSlotRemaining + intChange);
        g.PvUploadSlotRemaining:=StrToInt(strTmp);
        frmSettings.txtPvUploadSlotRemaining.Text:=strtmp;
        fIni.WriteString( 'PvUpload', 'PvUploadSlotRemaining',strTmp);
        fIni.Free;
    End;{If}
Except
  on E: Exception do
      Begin
      WriteLn( 'Error in Procedure "ResetUpdateSlots" : '+ E.ClassName + '  ' + E.Message );
      End;
End;{Try}
End;{Procedure ResetUpdateSlots}

//------------------------------------------------------------------------------
//Procedure : PvUploadProcessing
//Author    : Richard Wilkinson
//Date      : 01/07/2024
//Purpose   : Handle all necessary processes to query if data is ready for
//          : upload, to upload, to handle return code and update database
//------------------------------------------------------------------------------
Procedure PvUploadProcessing;
Var
  strDbFullPath:   String;
  strSQL:          String;
  iCount:          Int32;
  strSQLStatus:    String;
Begin
ShowMessage('Starting PvUploadProcessing');
//Open database
strDbFullPath:= g.DataBasePath + '/' + 'PvDataBase.db';
If OpenDb(strDbFullPath) = True Then
    Begin
    strSQLStatus:='SELECT TIMES.Time, TIMES.Uploaded, TIMES.PAC, TIMES.Energy ' +
                   'FROM Times LIMIT 10';
    showMessage(strSQLStatus);
    dBQuery.SQL.Text:=strSQLStatus;
    dBQuery.Open;
    dbQuery.Last;
    iCount:=dBQuery.RecordCount;
End;{If}
showMessage(IntToStr (iCount));
//SQL for top 10 records ready for uploading
strSQLStatus:='SELECT * FROM Times LIMIT 10';
//Are upload slots available?
If NOT IsSlotFree Then
    Begin
    Exit;{Sub}
End;{If}

//Open recordset

//Generate command line for Curl

//Decrement slot count

//Send data request to PvOutput.org

//Process AddStatusResponse

//Update Database

CloseDb;

End;{Procedure PvUploadProcessing}

//------------------------------------------------------------------------------
//Function  : GetResponseAddStatus
//Author    : Richard Wilkinson
//Date      : 01/07/2024
//Purpose   : Get response to attempted AddStatus upload request to PvOutput.org
//------------------------------------------------------------------------------
Function GetResponseAddStatus(iSent:Int32; strArray:String): Boolean;
Begin
Result:=True;
End;{Function GetResponsrAddStatus}

//------------------------------------------------------------------------------
//Function  : GetModel
//Author    : Richard Wilkinson
//Date      : 10/07/2024
//Purpose   : To get model Name from the -DA.dat file
//          : This in required in advance of reading the data from the full
//          : -Da.dat file
//------------------------------------------------------------------------------
Procedure GetModelMPPT(fDate:String);
Var
  fPath:    String;
  fNo:      Text;
  arData:   TStringArray;
  arDataLen:Int32;
  strLine:  String;
Begin
  //Assign & open data file
  fPath:=g.TempPath + '/' + fDate + '-DA.dat';
  Assign(fNo, fPath);
  Reset(fNo);
  ReadLn(fNo, strLine);     //First line should be enough
  arData:=strLine.Split([';']);
  arDataLen:=length(arData);
  If arDataLen > 3 Then
      //Enough elements returned
      Begin
      gSys.Model:=arData[2];
      gSys.MPPT:=arData[3];
      End
  Else
      Begin
      WriteLn('Function GetModel found insufficient data for: ' + fDate);
      gSys.Model:='XX';
      gSys.MPPT:='X';
  End;{If}
Close(fNo);
End;{Function GetModel}








End.

