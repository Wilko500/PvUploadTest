unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, vTimedProcess,
  MyUtils;

Function CheckForUploadSlots(): Boolean;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
Var
  p:         TTimedProcess;          //The process
  Params:    Array[0..4] of String;  //Array for parameters
  response:  String;                 //The response
  i:         Boolean;                //Var for function result
  UnixDate:    Int64;                //Test Unix date
  str:         String;               //Temp var
begin

i:=CheckForUploadSlots;


{
  //Attemp to start a timed TProcess
  //Send  X-Rate-Limit-Limit: request to PvOutput.org
  Params[0]:= '-i';
  Params[1]:= '-H' + 'X-Rate-Limit: 1'; ;
  Params[2]:= '-H' + 'X-Pvoutput-Apikey:ae134a083d06abfa7e371f9ec883a834052ae26a';
  Params[3]:= '-H' + 'X-Pvoutput-SystemId: 26065';;
  Params[4]:= 'http://pvoutput.org/service/r2/getstatus.jsp';
  p:=TTimedProcess.Create ('Curl', Params, 1);
  //Run process
  i:=p.Run;
  //Get response
  response:=p.Response;
  //Test function UnixDateToStr
  Memo1.Clear;
  Memo1.Append (p.Response);
  UnixDate:= 1713481200; // 18-04-2024  23:00:00
  str:=UnixDateToStr(UnixDate, 'D', False);
  //Test Delay function
  //Delay(2000);
  Edit1.text:=str;
  str:=UnixDateToStr(UnixDate, 'T', True);
  Edit2.Text:=str;
  str:=UnixDateToStr(UnixDate, 'B', True);
  Edit3.Text:=str;
}
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Button1.SetFocus;
end;

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
  i, j, k:         Int32;                  //Loop counter
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
  For i := 1 to 3 Do   //3 comes from gstrMaxUploadSlotRetries
    Begin
    //WriteLn('Loop Count=' + IntToStr(i));
    Delay(500);  //Delay 500ms for response
    //What if there is no response or no returned output?
    //Get response
    Form1.Memo1.Clear;
    Response:=p.Response;
    // reate stringlist array for ease of access
    strResponse:=TStringList.create;
    strResponse.text:=Response;
    Form1.Memo1.Append(strResponse.Text);
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
              //Update fields ( & Globals & Settings in final program)
              Form1.Edit1.Text:= IntToStr(iLimitRemaining);
              Form1.Edit2.Text:= IntToStr(iLimit);
              Form1.Edit3.Text:= strResetDate + ' ' + strResetTime;
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
    Form1.Edit3.Text:= 'Chk Upload slote, no response';
    Result:=False;
    End
Else
    Begin
    Result:=True
End;{If}

Except

End;{Try}
End;{Function CheckForUploadSlots}
end.

