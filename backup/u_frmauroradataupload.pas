unit U_frmAuroraDataUpload;

{$mode objfpc}{$H+}
//  {$modeswitch objectivec1}
interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, U_frmSettings, IniFiles, DateUtils,
  U_clsGlobals, vinfo, MyUtils, SQLite3Conn, LCLType, RichMemo;

type

  { TfrmAuroraDataUpload }

  TfrmAuroraDataUpload = class(TForm)
  Button1: TButton;
  lblCurDate: TLabel;
  RmPvUploadLog: TRichMemo;
  RmFileScanLog: TRichMemo;
  RmPvUploadError: TRichMemo;
  RmFileScanError: TRichMemo;
  RmUploadDays: TRichMemo;
  RmLoggedDays: TRichMemo;

    tmrDisplayDate:   TTimer;
    cmdSettings: TButton;
    Button2: TButton;
    Button3: TButton;
    cmdStart: TButton;
    Button5: TButton;
    cmdfrmAuroraExit: TButton;
    Button7: TButton;
    Button8: TButton;
    lblVer: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblSystemName: TLabel;
    Label7: TLabel;
    lblInvModel: TLabel;
    lblSystemDate: TLabel;
    lblTitle: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
 //     g: TGlobals;

    procedure Button1Click(Sender: TObject);
    procedure cmdSettingsClick(Sender: TObject);
    procedure cmdStartClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure cmdfrmAuroraExitClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure RmPvUploadErrorChange(Sender: TObject);
    procedure tmrDisplayDateStartTimer(Sender: TObject);
    procedure tmrDisplayDateTimer(Sender: TObject);
    Function GetProgramVer(): String;
//    procedure SendTextToMemo(aControl:TMemo; strText:String; TopBot: Boolean);
//    Function GetPath(PathType: Int32; ForApp: Boolean): String;
//    Function GetAppName(IncPath: Boolean): String;
    Procedure SecsToString(Secs:int64; OUT strSecs:String; OUT strLabel:String; blnHrs:Boolean);
    procedure TmrDisplayDateFire();
    procedure TmrDisplayDateTick(SecsRemain: String; strLabel: String);

//  Const
//    HrsOn:Boolean=True;
//    HrsOff:Boolean=False;

Private
  FActivated:  Boolean;
  gCanClose:   Boolean;  //Flag set to False in Form.Load to prevent form close by red Form close icon
                         //     set to true in cmdExit to allow form to be closed


Public

End;

Var
  g: TGlobals;
  gSys: TSys;
  frmAuroraDataUpload: TfrmAuroraDataUpload;
 // Function GetSignificantDir(DirLocation: qword; DomainMask: qword; count: byte): string;

Implementation

{$R *.lfm}
Uses
  u_PvUpload;

Var
  //For Timer tmrDisplayDate
  tmrDisplayDate_flag:  Boolean;
  tmrDisplayDate_Remain: Int64;
  tmrDisplayDate_Initial: Int64;
  tmrDisplayDate_Duration: Int64;
{ TfrmAuroraDataUpload }

{procedure TfrmAuroraDataUpload.tmrDisplayDateTimer(Sender: TObject);
VAR
  tmpDate:    String;
begin
  tmpDate:=FormatDateTime('hh:nn:ss', Now) + ' on ' + FormatDateTime('dd mmm yyyy', Now);
  lblCurDate.Caption:=tmpDate;

end;
}


Procedure TfrmAuroraDataUpload.FormCreate(Sender: TObject);
begin
//Set flag for preventing Activate code running multiple times
//Set to True at end of Activation code
FActivated:=False;
gcanClose:=False;

End;{Procedure FormCreate}

procedure TfrmAuroraDataUpload.RmPvUploadErrorChange(Sender: TObject);
begin

end;


Procedure TfrmAuroraDataUpload.cmdSettingsClick(Sender: TObject);
Begin
  //Show form Settings
  frmSettings.cmdSettingsSave.Enabled:=False;
  frmSettings.ShowModal;
End;{Procedure cmdSettingsClick}

procedure TfrmAuroraDataUpload.Button1Click(Sender: TObject);
Var
  strSecs1, strLabel: String;
  secs: Int64;
Begin
  //showMessage(IntToStr(g.PvUploadStartDelay));
  //secs=StrToInt64('300');
  //secs:=StrToInt64('300');
  //SecsToString(secs, strSecs1, strLabel, HrsOff);
  //ShowMessage(strSecs1 + ' ' + strLabel);

end;

procedure TfrmAuroraDataUpload.cmdStartClick(Sender: TObject);

  Begin
   //PvUploadProcessing;

   FileScanProcessing;

end;

procedure TfrmAuroraDataUpload.Button5Click(Sender: TObject);
var
  fIni:   TIniFile;
  iniFile, strKey: String;
  strTime:   string;
  dtTime: TDateTime;
begin

 exit;

     showMessage('DeBugModeOn = ' + BoolToStr(g.DeBugModeOn));
     showmessage('ZoomlevelSet =' + BoolToStr(g.ZoomLevelSet));
    iniFile:= GetPath(3, True) + '/PvUpload.ini';
    //iniFile:=strTmp1 + '/Preferences/' +  MidStr(strTmp,i,i1) + '/PvUpload.ini';
    fIni := TIniFile.Create(IniFile);
    strKey:=fIni.ReadString('PvSystem', 'PvSystemId', '999');  // Gets 26065
    showmessage('PvSystem ID = ' + strKey);
    showMessage('IniFile Path = ' + iniFile);  // /Library/Preferences/PvUploadTest/PvUpload.ini
    //fIni.WriteBool( 'PvSystem', 'ZoomLevelSet', False);
    fIni.Free;
end;
Procedure TfrmAuroraDataUpload.cmdfrmAuroraExitClick(Sender: TObject);
begin
    if MessageDlg('Do you wish to Exit?', mtConfirmation, [mbYes, mbNo],0) = mrYes Then
      Begin
      gCanClose:=True;
      close; //Exit program

      end
    else
      Exit; //Exit this procedure and continue program
  end;

procedure TfrmAuroraDataUpload.FormActivate(Sender: TObject);
Var
  tmpDate:    String;
//  TmrDisplayDate: TTimer;
begin
  If Not FActivated Then
    Begin
    //Get program version details
    lblVer.Caption:=GetProgramVer;

    //Create class for Globals
    g:=TGlobals.Create();
    //And class for system values
    gSys:=TSys.Create();
    //Load ini file settings
    LoadFormFromIni;
    //And then globals
    LoadGlobals;
    //Fill in system details
    lblSystemName.Caption:=g.PvSystemName;
    lblInvModel.Caption:=g.PvInvModel;
    lblSystemDate.Caption:=g.PvSystemDate;
    //Current Date
    tmpDate:=FormatDateTime('hh:nn:ss', now) + ' on ' + FormatdateTime('DD MMM YYYY',Now);
    lblCurDate.Caption:=tmpDate;

    //Set uptimers
    TmrDisplayDate:=TTimer.Create(nil);
    //TmrDisplayDate.OnTimer:=@TmrDisplayDate;
    TmrDisplayDate.interval:=5;   //Time in msecs
    TmrDisplayDate.enabled:=True;
    //SendTextToMemo(frmAuroraDataUpload.RmFileScanError, FormatDateTime('hh' + ':' + 'nn' + ':' + 'ss' , Now()) + ' - ' +
    //             'Started', True);



    //Set flag to prevent Activation code running a second time
    FActivated := True;
  End;
End;{Procedure FormActivate}

procedure TfrmAuroraDataUpload.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
    if gCanClose = False then
      Begin
      //ShowMessage('Sender=' + Sender.);
      ShowMessage('You must use the Exit button to close this program');
      CanClose:=False ;
      end
    else
      Begin
      canClose:=True;
      end;
end;


//------------------------------------------------------------------------------
//Function  : GetProgramVer
//Author    : Richard Wilkinson
//Date      : 27/4/24
//Purpose   : Get program version Information
//------------------------------------------------------------------------------
//
Function TfrmAuroraDataUpload.GetProgramVer(): String;
Var
  ProgramVer : String;
  Info: TVersionInfo;
  FMajorVersionStr: String;
  FMinorVersionStr: String;
  FRevisionStr: String;
begin

  //Create function to return ProgramVer as a string Maj.Min.Rev eg  "Ver 1.2.3"
  // [0] = Major version, [1] = Minor ver, [3] = Revision, [4] = Build Number
  // The above values can be found in the menu: Project > Project Options > Version Info
  Info := TVersionInfo.Create;
  Info.Load(HINSTANCE);
  FMajorVersionStr :=IntToStr(Info.FixedInfo.FileVersion[0]);
  FMinorVersionStr :=IntToStr(Info.FixedInfo.FileVersion[1]);
  FRevisionStr     :=IntToStr(Info.FixedInfo.FileVersion[2]);
  // FBuildNumberStr  :=IntToStr(Info.FixedInfo.FileVersion[3]);
  Info.Free;
  ProgramVer:=  FMajorVersionStr + '.' +  FMinorVersionStr + '.' +  FRevisionStr;
 //showmessage('BuildNum = ' + ProgramVer);
 Result:= 'Ver ' + ProgramVer;
End;{Function GetProgramVer}

//------------------------------------------------------------------------------
//Procedure : SecsToString
//Author    : Richard Wilkinson
//Date      : 17/07/2024
//Purpose   : Take an integer value of seconds and return formatted string h:m:s
//          : And matching label eg 23:10:25 h:m:s or 01:08 m:s
//          : Optionally include/exclude Hrs
//------------------------------------------------------------------------------
Procedure TfrmAuroraDataUpload.SecsToString(Secs:int64; OUT strSecs:String; OUT strLabel:String; blnHrs:Boolean);
Var
  T:          Int64; // Work variable
  H:          Int64;
  M:          Int64;
  S:          Int64;
Begin
  T:=Secs;
  H:=Trunc(Secs/3600);
  T:=T-(3600*H);
  M:=Trunc(T/60);
  T:=T-(60*M);
  S:=T;
  strSecs:=RightStr('0'+IntToStr(H),2) + ':' +
           RightStr('0'+IntToStr(M),2) + ':' +
           RightStr('0'+IntToStr(S),2);
  strLabel:='h:m:s';
  If blnHrs = HrsOff Then
      Begin
      strSecs:=RightStr(strSecs,5);
      strLabel:='m:s';
  End;{If}
End;{Procedure SecsToString}


//==============================================================================
//The following code is a series of timers
//Based on TTimer with additions to allow separate handlers for Tick and Fire
//The main timer handler that calls Tick and Fire
//==============================================================================

//------------------------------------------------------------------------------
//Timer     : DisplayDate
//Author    : Richard Wilkinson
//Date      : 17/07/2024
//Purpose   : Display current date and time on main form
//          : Updated every second
//------------------------------------------------------------------------------
procedure TfrmAuroraDataUpload.tmrDisplayDateTimer(Sender: TObject);
Var
    secs:Int64;
    strSecs1:String;
    strLabel:String;
    t:Int64;
Begin
If tmrDisplayDate_flag = False Then
    Begin
    //Get timer interval, only done once
    t:=StrToInt64('120000'); //Need variable for this or setting
    tmrDisplayDate.Interval:=t;
    tmrDisplayDate_flag:=True;
{EndIf}End;
//Get number of seconds until timer should fire
secs:= Trunc(GetTickCount64()/1000);
tmrDisplayDate_Remain:=tmrDisplayDate_Duration - (secs - tmrDisplayDate_Initial);
//Format seconds remaining
SecsToString(tmrDisplayDate_Remain, strSecs1, strLabel, HrsOff);
    If TmrDisplayDate_Remain <= 0 Then
        //This is fire
        Begin
        //Set countdown to zero
        lblCurDate.caption:= strSecs1 + ' ' + strLabel;
        //Call Fire procedure
        tmrDisplayDateFire;
        //Stop Timer, reset Initial value and restart
        tmrDisplayDate.enabled:=False;
        tmrDisplayDate_Initial:=Trunc(GetTickCount64()/1000);
        tmrDisplayDate.enabled:=True;
        End
    Else
        Begin
        //This is tick
        //Call Tick procedure
       TmrDisplayDateTick(strSecs1, strLabel);
    {EndId}End;
{EndProc}End;
//==============================================================================
//Timer initialization code
//==============================================================================
Procedure TfrmAuroraDataUpload.tmrDisplayDateStartTimer(Sender: TObject);
Var
  t:  Int64;
Begin
//Make first fire after 5msecs, then reset to propper interval
tmrDisplayDate.Interval:=5;
tmrDisplayDate_flag:=False;
t:=StrToInt64('120000'); //Need a variable for this or setting
tmrDisplayDate.Enabled:=true;
tmrDisplayDate_Duration:=Trunc(t/1000);
tmrDisplayDate_Initial:=Trunc(GetTickCount64()/1000);
End;{Procedure tmrDisplayDateStartTimer}
//==============================================================================
//Timer Tick code
//==============================================================================
Procedure TfrmAuroraDataUpload.TmrDisplayDateTick(SecsRemain: String; strLabel: String);
//This is tick event
Begin
  lblCurDate.caption:= FormatDateTime('hh:nn:ss', Now) + ' on ' + FormatDateTime('dd mmm yyyy', Now); //SecsRemain + ' ' + strLabel;
End;{Procedure TmrDisplayDateTick}
//==============================================================================
//Timer Fire code
//==============================================================================
Procedure TfrmAuroraDataUpload.TmrDisplayDateFire();
//This is Fire event
Begin
  //For this timer nothing to do except reset timer to start again
  //Memo1.lines.add ('TimerFire at ' + TimeToStr(now));
  tmrDisplayDate.Enabled:=False;
  tmrDisplayDate.Enabled:=True;
End;{Procedure TmrDisplayDateFire}


End.
