unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls, Types;

type

  { TfrmSettings }

  TfrmSettings = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    procedure Edit6Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private

  public

  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.lfm}

{ TfrmSettings }

procedure TfrmSettings.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmSettings.Label7Click(Sender: TObject);
begin

end;

procedure TfrmSettings.FormActivate(Sender: TObject);
begin
  TabSheet1.SetFocus;
end;

procedure TfrmSettings.Edit6Change(Sender: TObject);
begin

end;

procedure TfrmSettings.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

end.

