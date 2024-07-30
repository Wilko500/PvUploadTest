unit Unit1;

{$mode objfpc}{$H+}
  {$modeswitch objectivec1}
interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, U_frmSettings, CocoaAll, strUtils, IniFiles;

type

  { TForm1 }

  TForm1 = class(TForm)

 // Timer1:   TTimer;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Label1: TLabel;
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
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblTitle: TLabel;
    ListView1: TListView;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Timer1Timer(Sender: TObject);

 Var Timer1:  TTimer;
  private

  public

  end;

var
  Form1: TForm1;
 function GetSignificantDir(DirLocation: qword; DomainMask: qword; count: byte): string;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.Label7Click(Sender: TObject);
begin

end;


procedure TForm1.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
   item.Selected:=False;
   item.Focused:=False;


end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  lblTitle.Caption:=TimeToStr(Now);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin

Timer1:=TTimer.Create(nil);
Timer1.OnTimer:=@Timer1Timer;
Timer1.interval:=5000;   //Time in msecs
Timer1.enabled:=False;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  frmSettings.showModal;
end;

procedure TForm1.Button4Click(Sender: TObject);

  Begin
   Timer1.enabled:=True;

end;

procedure TForm1.Button5Click(Sender: TObject);
var i, i1:int32;
  strTmp:   string;
  fIni:   TIniFile;
  iniFile, strKey: String;
begin
  //ShowMessage('Users dir: ' +  GetSignificantDir(NSUserDirectory,NSLocalDomainMask,0));
// User Directory
//     ShowMessage('User''s dir: ' + NSStringToString(NSHomeDirectory));
     //Gives    User's dir: /Users/richardwilkinson
for i:= 0 to 10 do
     Begin
     //ShowMessage('User application dir ' + IntToStr(i) + ': '
     //     + GetSignificantDir(NSAllApplicationsDirectory,NSUserDomainMask,i))
          end;
     // Gives 0  User application dir 0: /Users/richardwilkinson/Applications
      //showMessage(application.ExeName );
      ///Volumes/MacHD-SSD-Data/LocBucket/FpLazStuff/PvUploadTest/PvUploadTest.app/Contents/MacOS/PvUploadTest
      //showMessage(ExtractFilePath(application.ExeName) );
      ///Volumes/MacHD-SSD-Data/LocBucket/FpLazStuff/PvUploadTest/PvUploadTest.app/Contents/MacOS/


      //Get application name
      //showMessage( NSBundle.mainBundle.bundlePath.UTF8String);
      strTmp:=NSBundle.mainBundle.bundlePath.UTF8String;
      ///Volumes/MacHD-SSD-Data/LocBucket/FpLazStuff/PvUploadTest/PvUploadTest.app
      i:=  Rpos('/', strTmp) +1;
      i1:=Rpos('.', strTmp) -i;
      ShowMessage('App Name=' + MidStr(strTmp,i,i1));



     //Need to get application support dir
     // ie ~/Library/Application Support/com.example.MyApp/
     // where com.example.MyApp is bundle id
     // foe my Lazarus created apps bundle id is com.company.MyApp  (MyApp is app name)

     //Applucatiion support folder
     // /Users/richardwilkinson/Library/Application Support/MyApp
     //test read ini file

    iniFile:='/Library/Preferences/' +  MidStr(strTmp,i,i1) + '/PvUpload.ini';
    fIni := TIniFile.Create(IniFile);
    strKey:=fIni.ReadString('PvSystem', 'PvSystemId', '999');  // Gets 26065
    showmessage(strKey);
    showMessage(iniFile);  // /Library/Preferences/PvUploadTest/PvUpload.ini
    fIni.Free;
end;
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
end.
