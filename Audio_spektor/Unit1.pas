unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, Spectre, StdCtrls;

type
  TForm1 = class(TForm)
    Spectre1: TSpectre;
    StopPlay: TSpeedButton;
    Open: TSpeedButton;
    OpenDialog1: TOpenDialog;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    procedure OpenClick(Sender: TObject);
    procedure StopPlayClick(Sender: TObject);
    procedure Spectre1NotifyBloc(Sender: TObject; Event: Integer);
    procedure Spectre1NotifyPosition(Sender: TObject; Time: Integer);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.OpenClick(Sender: TObject);
begin
  if Spectre1.duree > 0
     then begin
          if Spectre1.playSon then Spectre1.stopPlayer;
          Spectre1.closewav;
          end
     else if opendialog1.execute
          then spectre1.NomFile:= opendialog1.filename;
end;

procedure TForm1.StopPlayClick(Sender: TObject);
begin
  if Spectre1.playSon
     then spectre1.StopPlayer
     else Spectre1.PlayBloc;
end;

procedure TForm1.Spectre1NotifyBloc(Sender: TObject; Event: Integer);
begin
Label4.caption := format('%.2d:%.2d:%.3d',[Event div 60000,(Event div 1000) mod 60,Event mod 1000])
end;

procedure TForm1.Spectre1NotifyPosition(Sender: TObject; Time: Integer);
begin
Label7.caption := format('%.2d:%.2d:%.3d',[time div 60000,(Time div 1000) mod 60,Time mod 1000])
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
  const rc = #13#10;
begin
  showmessage( 'Question:'+rc+
               'Comment obtenir un spectre audio avec Mp3 file?'+rc+rc+
               'Objectif:'+rc+
               'Finaliser un projet accessible sur:'+rc+
               'http://www.edialbum.fr/'+rc+rc+'Merci!')
end;

end.
