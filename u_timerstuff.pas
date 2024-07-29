unit u_TimerStuff;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;
Var
    HrsOn:Boolean=True;
    HrsOff:Boolean=False;

implementation
//Uses
//  u_frmAuroraDataUpload;

//In form implimentation
Var
  TmrDisplayDate_flag:  Boolean;
  TmrDisplayDate_Remain: Int64;
  TmrDisplayDate_Initial: Int64;
  TmrDisplayDate_Duration: Int64;


Procedure TmrDisplayDateTimer(Sender: TObject);
Var
    secs:Int64;
    strSecs1:String;
    strLabel:String;
    t:Int64;

Begin
If TmrDisplayDate_flag = False Then
    Begin
    //Get timer interval, only done once
    t:=1000; ////StrToInt64(txtOneShotInt.text);
    TmrDisplayDate.Interval:=t;
    TmrDisplayDate_flag:=True;
{EndIf}End;
//Get number of seconds until timer should fire
secs:= Trunc(GetTickCount64()/1000);
TmrDisplayDate_Remain:=TmrDisplayDate_Duration - (secs - TmrDisplayDate_Initial);
//Format seconds remaining
SecsToString(TmrDisplayDate_Remain, strSecs1, strLabel, HrsOff);
    If TmrDisplayDate_Remain <= 0 Then
        //This is fire
        Begin
        //Set countdown to zero
        label1.caption:= strSecs1 + ' ' + strLabel;
        //Call Fire procedure
        TmrDisplayDateFire;
        //Stop Timer, reset Initial value and restart
        TmrDisplayDate.enabled:=False;
        TmrDisplayDate_Initial:=Trunc(GetTickCount64()/1000);
        TmrDisplayDate.enabled:=True;
        End
    Else
        Begin
        //This is tick
        //Call Tick procedure
       TmrDisplayDateTick(strSecs1, strLabel);
    {EndId}End;
{EndProc}End;


procedure TmrDisplayDateTick(SecsRemain: String; strLabel: String);
//This is tick event
begin
  label1.caption:= SecsRemain + ' ' + strLabel;
end;


procedure TmrDisplayDateFire();
//This is Fire event
begin
  Memo1.lines.add ('TimerFire at ' + TimeToStr(now));
end;

end.

