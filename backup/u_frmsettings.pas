unit U_frmSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, RichMemo, IniFiles, Types, MyUtils, Math;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Button1: TButton;
    chkFileScan: TCheckBox;
    chkFileParse: TCheckBox;
    chkDataBaseUpdate: TCheckBox;
    chkPvUpload: TCheckBox;
    chkZoomLevelSet: TCheckBox;
    chkDebugModeOn: TCheckBox;
    cmdClear: TButton;
    cmdVireEdit: TButton;
    cmdGetPath: TButton;
    cmdSettingsSave: TButton;
    cmdSettingsExit: TButton;
    lblProcessing: TLabel;
    txtEarliestTimes: TEdit;
    txtLatestTimes: TEdit;
    txtMaxTimes: TEdit;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    lblValidation: TLabel;
    Label30: TLabel;
    RichMemo1: TRichMemo;
    txtMaxBatchRecs: TEdit;
    txtPvUploadSlotTimeReset: TEdit;
    txtPvUploadSlotDateReset: TEdit;
    txtPvGetOutputDelay: TEdit;
    txtMaxLiveRecs: TEdit;
    txtMaxOutputRetries: TEdit;
    txtMaxLiveRetries: TEdit;
    txtMaxUploadSlotRetries: TEdit;
    txtPvGetStatusDelay: TEdit;
    txtPvUploadSlotDelay: TEdit;
    txtPvUploadSlotLimit: TEdit;
    txtPvUploadSlotRemaining: TEdit;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    txtZoomLevel: TEdit;
    txtMaxDebugRecs: TEdit;
    txtDebugRecs: TEdit;
    Label18: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    txtPvSystemDate: TEdit;
    txtPvSystemName: TEdit;
    txtPvInvModel: TEdit;
    Label17: TLabel;
    txtPvApiKey: TEdit;
    txtPvSystemID: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    lblPvSystemTab: TLabel;
    txtPvFileScan: TEdit;
    txtPvUploadStartDelay: TEdit;
    txtPvUploadInt: TEdit;
    txtPvUploadSlotCheck: TEdit;
    txtNextPvSlotCheck: TEdit;
    txtPvErrorLogCheck: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    lblFileScanHms: TLabel;
    lblPvUploadStartDelay: TLabel;
    lblPvUploadHms: TLabel;
    lblPvUploadSlotCheck: TLabel;
    lblNextPvSlotCheckHms: TLabel;
    Label20: TLabel;
    lblPvErrorLogCheck: TLabel;
    Label9: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    txtApplicationPath: TEdit;
    txtDebugLogFilePath: TEdit;
    Label1: TLabel;
    Label8: TLabel;
    txtCurlPath: TEdit;
    txtLogFilePath: TEdit;
    txtTempPath: TEdit;
    txtArchivePath: TEdit;
    txtDataBasePath: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    PageControl1: TPageControl;
    TabPaths: TTabSheet;
    TabTimers: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure cmdSettingsExitClick(Sender: TObject);
    procedure cmdGetPathClick(Sender: TObject);
    procedure cmdSettingsSaveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabTimersContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure txtArchivePathEditingDone(Sender: TObject);
    procedure txtDataBasePathClick(Sender: TObject);
    procedure txtDataBasePathEditingDone(Sender: TObject);
    procedure txtDebugLogFilePathClick(Sender: TObject);
    procedure txtDebugLogFilePathEditingDone(Sender: TObject);
    procedure txtLogFilePathClick(Sender: TObject);
    procedure txtLogFilePathEditingDone(Sender: TObject);
    procedure txtPvErrorLogCheckEditingDone(Sender: TObject);
    procedure txtPvFileScanChange(Sender: TObject);
    procedure txtPvFileScanEditingDone(Sender: TObject);
    procedure txtPvFileScanExit(Sender: TObject);
    procedure txtPvUploadIntEditingDone(Sender: TObject);
    procedure txtPvUploadSlotCheckEditingDone(Sender: TObject);
    procedure txtPvUploadStartDelayClick(Sender: TObject);
    procedure txtPvUploadStartDelayEditingDone(Sender: TObject);
    procedure txtTempPathClick(Sender: TObject);
    procedure txtArchivePathClick(Sender: TObject);
    procedure txtTempPathEditingDone(Sender: TObject);
    Procedure ValidateSettings;
    Procedure UpdateLabel(strName:TLabel; strText:String);
  private

  public

  end;

var
  frmSettings: TfrmSettings;
implementation
uses U_frmAuroraDataUpload, u_PvUpload;
{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.txtArchivePathClick(Sender: TObject);
begin
    self.cmdGetPath.Enabled:=True;
end;

procedure TfrmSettings.txtTempPathEditingDone(Sender: TObject);
begin
With TEdit(Sender) Do
Begin
//Get textBox name, TxtBox text
ValidateSettings;
End;{With}
End;{Procedure txtTempPathEditingDone}

procedure TfrmSettings.cmdGetPathClick(Sender: TObject);
//This works for browsing for folder and inserting it in text field
//Text field can be coloured if necessary
Var
  ctrlName:String;
  myEdit:TEdit;

begin
  //Which control has focus
  ctrlName:=ActiveControl.name;
  // var
  //  myEdit: TEdit;
  //...
  myEdit := TEdit(frmSettings.FindComponent(ctrlName));

  // SelectDirectoryDialog1 is on Dialogs tab
  // Can browse all file systen if Finder preferences
  // include the host computer in SideBar Locations
   if SelectDirectoryDialog1.Execute then
       begin
       myEdit.Text:=SelectDirectoryDialog1.Filename;
       myEdit.Font.color:=clDefault;
       self.cmdSettingsSave.Enabled:=True;
       end
   else
       Begin
       Self.cmdGetPath.Enabled:=True
   end;
   self.cmdSettingsSave.setfocus;
end;

procedure TfrmSettings.cmdSettingsExitClick(Sender: TObject);
begin
  frmSettings.Close;
end;

procedure TfrmSettings.Button1Click(Sender: TObject);
begin

   RichMemo1.lines.Insert(0,'QWERTYUIOP');
   RichMemo1.SetRangeColor(0,10,clRed);
   RichMemo1.lines.Insert(0,'ZXCVBNM');
   RichMemo1.SetRangeColor(0,7,clBlack);

end;

procedure TfrmSettings.cmdSettingsSaveClick(Sender: TObject);
Var
  fIni:       TiniFile;
  iniFile:    String;
begin
  iniFile:= GetPath(3, True) + '/PvUpload.ini';
  fIni := TIniFile.Create(IniFile);
  fIni.WriteString( 'FilePaths', 'LogFilePath',frmSettings.txtLogFilePath.Text);
  g.LogFilePath:=frmSettings.txtLogFilePath.Text;

  fIni.WriteString( 'FilePaths', 'DataBasepath',frmSettings.txtDataBasePath.Text);
  g.DataBasePath:=frmSettings.txtDataBasePath.Text;

  ShowMessage('Settings saved successfully');
  self.cmdSettingsSave.Enabled:=false;
  self.cmdSettingsExit.setfocus;

end;

procedure TfrmSettings.FormActivate(Sender: TObject);
begin
  //frmSettings.TabSheet1.SetFocus;

end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
lblPvSystemTab.Caption:= 'These parameters are required for uploading PV data ' +
                 'to PvOutput.org and for ' + LineEnding + 'managing the ' +
                 'application. You will need to sign on and ' +
                 'create an account';
lblValidation.Caption:= 'These values are used to test data values to determine if' +
                 LineEnding + 'the datafile is complete.  Data is still ' +
                 'processed but a ' + LineEnding + 'warning is generated';
lblprocessing.Caption:= 'If checked these parts of processing will be carried out.' +LineEnding +
                'Eg. if internet connection is unavailable for some time' + LineEnding +
                'the data upload could be unchecked to avoid repeated' + LineEnding +
                'error messages being logged.'

end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  //Set Paths tab to visible
  PageControl1.ActivePageIndex:=0;
  frmSettings.cmdGetPath.enabled:=False;
end;

procedure TfrmSettings.TabTimersContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TfrmSettings.txtArchivePathEditingDone(Sender: TObject);
begin
 With TEdit(Sender) Do
Begin
//Get textBox name, TxtBox text
ValidateSettings;
End;{With}
End;{Procedure txtArchivePathEditingDone}

procedure TfrmSettings.txtDataBasePathClick(Sender: TObject);
begin
    self.cmdGetPath.Enabled:=True;
end;

procedure TfrmSettings.txtDataBasePathEditingDone(Sender: TObject);
begin
With TEdit(Sender) Do
Begin
ValidateSettings;
End;{With}
End;{Procedure txtDataBasePathEditingDone}

procedure TfrmSettings.txtDebugLogFilePathClick(Sender: TObject);
begin
    self.cmdGetPath.Enabled:=True;
end;

procedure TfrmSettings.txtDebugLogFilePathEditingDone(Sender: TObject);
begin
With TEdit(Sender) Do
Begin
ValidateSettings;
End;{With}
End;{Procedure txtDebugLogFilePathEditingDone}

procedure TfrmSettings.txtLogFilePathClick(Sender: TObject);
begin
  self.cmdGetPath.Enabled:=True;
end;

procedure TfrmSettings.txtLogFilePathEditingDone(Sender: TObject);
begin
With TEdit(Sender) Do
Begin
ValidateSettings;
End;{With}
End;{Procedure txtLogFilePathEditingDone}

procedure TfrmSettings.txtPvErrorLogCheckEditingDone(Sender: TObject);
begin
With TEdit(Sender) Do
Begin
ValidateSettings;
End;{With}
End;{Procedure txtPvErrorLogCheckEditingDone}

procedure TfrmSettings.txtPvFileScanChange(Sender: TObject);
begin

end;

procedure TfrmSettings.txtPvFileScanEditingDone(Sender: TObject);
begin
  With TEdit(Sender) Do
  Begin
  ValidateSettings;
End;{With}
end;

procedure TfrmSettings.txtPvFileScanExit(Sender: TObject);
begin

end;

procedure TfrmSettings.txtPvUploadIntEditingDone(Sender: TObject);
begin
  With TEdit(Sender) Do
  Begin
  ValidateSettings;
End;{With}
End;{Procedure txtPvUploadIntEditingDone}

procedure TfrmSettings.txtPvUploadSlotCheckEditingDone(Sender: TObject);
begin
With TEdit(Sender) Do
Begin
ValidateSettings;
End;{With}
End;{txtPvUploadSlotCheckEditingDone}

procedure TfrmSettings.txtPvUploadStartDelayClick(Sender: TObject);
begin

end;

Procedure TfrmSettings.txtPvUploadStartDelayEditingDone(Sender: TObject);
Begin
With TEdit(Sender) Do
  Begin
  ValidateSettings;
  UpdateLabel(lblPvUploadStartDelay, Text);
End;{With}

End;{Procedure txtPvUploadStartDelayEditingDone}



procedure TfrmSettings.txtTempPathClick(Sender: TObject);
begin
  self.cmdGetPath.Enabled:=True;
end;

//------------------------------------------------------------------------------
//Procedure : ValidateSettings
//Author    : Richard Wilkinson
//Date      : 20/07/2024
//Purpose   : To check if a setting has been changed
//          : and set/unset cmdSaveSetting accordingly
//------------------------------------------------------------------------------
Procedure TfrmSettings.ValidateSettings;
Var
  tmpState:  Boolean; //Temp valuse for button state
Begin
  tmpState:=False;
  //Paths
  //If g.ApplicationPath <> frmSettings.txtApplicationPath.Text Then tmpState:=True;  //Not editable
  //If g.CurlPath <> frmSettings.txtCurlPath.Text Then tmpState:=true; Not used
  If g.LogFilePath <> frmSettings.txtLogFilePath.Text Then tmpState:=True;
  if g.TempPath <> frmSettings.txtTempPath.Text Then tmpState:=True;
  If g.ArchivePath <> frmSettings.txtArchivePath.Text Then tmpState:=True;
  If g.DataBasePath <> frmSettings.txtDatabasePath.Text Then tmpState:=True;
  If g.DebugLogFilePath <> txtDebugLogFilePath.Text Then tmpState:=True;

  //Timers
  If g.PvUploadStartDelay <> strToInt64(frmSettings.txtPvUploadStartDelay.text) Then tmpState:=True;
  If g.PvFileScan <>         strToInt64(frmSettings.txtPvFileScan.text)         Then tmpState:=True;
  If g.PvUploadInt <>        strToInt64(frmSettings.txtPvUploadInt.Text)        Then tmpState:=True;
  If g.PvUploadSlotCheck <>  strToInt64(frmSettings.txtPvUploadSlotCheck.Text)  Then tmpState:=True;
  If g.PvErrorLogCheck <>    StrToInt64(frmSettings.txtPvErrorLogCheck.Text)    Then tmpState:=True;

//PV System

//Processing

//Validation

//PV Upload

//Now set the state of cmdsettings button
  frmSettings.cmdSettingsSave.Enabled:=tmpState;
End;{Procedure ValidateSettings}

//------------------------------------------------------------------------------
//Procedure : UpdateLabel
//Author    : Richard Wilkinson
//Date      : 25/07/2024
//Purpose   : Update the label to the right of textbox if its value is updated
//------------------------------------------------------------------------------
Procedure TfrmSettings.UpdateLabel(strName:TLabel; strText:String);
Var
  secs: Single;
  strSecs1, strLabel:String;
Begin
  secs:=strToFloat(strText)/1000;
  SecsToString(Floor(secs), strSecs1, strLabel, HrsOff);
  strName.Caption:=strSecs1+ ' ' + strLabel;
End;{Procedure UpdateLabel}




end.

