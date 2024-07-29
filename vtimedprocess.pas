unit vTimedProcess;

{$mode ObjFPC}{$H+}

interface

uses
  process, Classes, SysUtils, Dialogs;

type

  { TTimedProcess }
  //Code from marcov
  //Link: https://forum.lazarus.freepascal.org/index.php/topic,50525.msg368880.html#msg368880

  TTimedProcess = class
  private
    FProcess: TProcess;
    FTimeoutSeconds: Integer;
    FTimedOut: Boolean;
    FResponse: string;
    FStarted: TDateTime;
    procedure CommandEvent(Sender, Context: TObject; Status: TRunCommandEventCode; const Message: string);
  public
    constructor Create(const ProcessName: string; const Commands: array of string; const TimeoutSeconds: Integer);
    destructor Destroy; override;
    property TimedOut: Boolean read FTimedOut;
    property Response: string read FResponse;
    function Run: Boolean;
  end;

implementation

constructor TTimedProcess.Create(const ProcessName: string; const Commands: array of string; const TimeoutSeconds: Integer);
var
  command: string;
begin
  FProcess := TProcess.Create(nil);
  FTimeoutSeconds := TimeoutSeconds;
  FProcess.Executable := ProcessName;
  FProcess.Options := [poRunIdle];
  FProcess.OnRunCommandEvent := @CommandEvent;
  for command in Commands do
    begin
      FProcess.Parameters.Add(command);
    end;
  //ShowMessage(FProcess.Parameters.Text);
end;

destructor TTimedProcess.Destroy;
begin
  FProcess.Free;
  inherited Destroy;
end;

function TTimedProcess.Run: Boolean;
var
  error: string;
  exitStatus: Integer;
begin
  FStarted := Now;
  FTimedOut := False;
  FResponse := '';
  Result := FProcess.RunCommandLoop(FResponse, error, exitStatus) = 0;
  //ShowMessage('ExitStatus=' + IntToStr(exitStatus));
  if FTimedOut then Result := False;
  //if FTimedOut OR (exitStatus <> 0 ) then Result := False;
end;

procedure TTimedProcess.CommandEvent(Sender, Context: TObject; Status: TRunCommandEventCode; const Message: string);
begin
  if Status = RunCommandIdle then
  begin
    if 24 * 60 * 60 * (Now - FStarted) > FTimeoutSeconds then
    begin
      FTimedOut := True;
      FProcess.Terminate(255);
      Exit;
    end;
    Sleep(FProcess.RunCommandSleepTime);
  end;
end;

end.

