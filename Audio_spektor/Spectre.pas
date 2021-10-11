
/////////////////////////////////////////////////////////////////////////////
//                                                                         //
//      Spectre -- a component to create wav spectrum with Delphi 5...     //
//                             by Eric Tisseyre                            //
//                           date 10 / 11 / 2010                           //
//       Please send comments, suggestions to ricquetto@orange.fr          //
//  I would like to do the same thing with Mp3 files, but i need help !    //
//                                                                         //
//                           Thank You !                                   //
/////////////////////////////////////////////////////////////////////////////


{ Annotation : Composant Eric Tisseyre
  En complément à ce composant, un petit programme qui l'explicite.
  (une fois le composant installé ;-)
  Ce composant est utilisé de manière plus étoffé dans
  un projet visible ici = http://www.edialbum.fr/presentation.php
  En conséquence, des propriétés ou événements sont ici sous exploitées.
  les ajouter rendrait ce composant illisible.

  Mon souhait est d'étendre les possibilités d'affichage aux Mp3 et wma
  Si vous connaissez la manière de décompresser ou plus simplement interpréter des datas compressés
  pour les dessiner, vous apporterez de l'eau à mon moulin qui est en rade.}


{ Voilà la structure :

   O________________________A________________B___________________________________________C
[HS/______OA = début_______/___AB = bloc____/_____________BC = Fin hors Bloc_____________C]

 A et B sont les positions curseurs DebBloc et EndBloc en octet
 les data commence en O soient à 44 octets = HS = Header Size

 Les valeurs AB pourront être utilisées pour des mixages, traitements de volume, fade...)}

unit Spectre;

interface

uses Windows, SysUtils, Forms, Controls, Classes, Mplayer, ExtCtrls, StdCtrls, graphics;

const // Information état d''avancement ou d'échec...
      FWError = -1;  FWMci = -2; FWClose = -3; 
      FWOpen = -6;  FWSpectre = -7; FWOk = -8;

Const RC = #13#10;
      HS = 44 ;        // Header Size = Taille de l'entete d'un fichier "normal" wav (ci aprés)

type Array4 = array[1..4] of char;

type TDG = record
         D: byte;
         G: byte;
         end;

type TWavHeader = record
        Riff: array4;                   // Chaine 'RifF' sur 4 Octet
        Size1: LongWord;                // Longueur du fichier sur 4 octets (-8)
        wave: array4;                   // Chaine 'WAVE' sur 4 octets
        Fmt : array4;                   // Chaine 'fmt ' sur 4 octets
        LgStruct: LongWord;             // Longueur structure entete Wav sur 4 octets
        Pcm : Word;                     // Type de format utilise sur 2 octets
        NbCanaux: Word;                 // Nb de canaux utilise sur 2 octets
        Freq: LongWord;                 // Frequence d'echantillonage sur 4 octets = Sample Rate
        MoyOctSec: LongWord;            // Nb moyen d'octet par seconde sur 4 octets
        OctPerEch: Word;                // Nb d'octet par echantillon sur 2 octets
        BitSample: Word;                // Echantillonnage sur 8 ou 16 bits sur 2 octets
        Data: array4;                   // Chaine 'data' sur 4 octets
        Size2: LongWord;                // Longueur des donnees d'echantillon sur 4 octets (= Size1 - 36)
end;


Type
     TNotifyEvent = procedure(Sender: TObject; Event: Integer) of Object;
     // Définition de l'événenement OnNotify de l'objet TSpectre
     
     TNotifyPosit = procedure(Sender: TObject; Time: integer) of Object;
     // Définition de l'événement pour indication de la position de lecture ou curseur

     TNotifyPositPlay = procedure(Sender: TObject; Time: integer) of Object;
     // Définition de l'événement pour indication de la position de lecture ou curseur

     TNotifyLoad = procedure(Sender: TObject; Position, Maxi: integer) of Object;
     // Définition de l'événement pour indication de la position du process

   TSpectre = Class(TCustomPanel)

   private
     { Déclarations Privées }
     FFileName : TFilename;
     FDuree, FDebutBloc, FFinBloc : LongWord ;     // variable de temps
     FPlaySon, OkWav : boolean ;
     decaldata, FAmplitude : word ;
     DebBloc, EndBloc, PosLect, Bloc : TShape;
     Player : TMediaPlayer;
     Img : TImage;
     PlayTimer : TTimer;
     PanelParent : TPanel;
     FWavHeader: TWavHeader;
     PositLect : Cardinal ;
     OctOA, OctAB, OctOC : integer ;               // variable de position octet
     FMp3Size1 : integer;                          // size mp3 affiché dans l'image
     spectre: array of TDG;

     FNotifyEvent    : TNotifyEvent;
     FNotifyStartPlay: TNotifyEvent;
     FNotifyStopPlay : TNotifyEvent;
     FNotifyPosit    : TNotifyPosit;
     FNotifyPosPlay  : TNotifyPositPlay;
     FNotifyLoad     : TNotifyLoad;
     FNotifyBloc     : TNotifyEvent;
     FNotifydbBloc   : TNotifyEvent;

   protected
     // Méthode des événements internes
     procedure GetInfoEvent(msg: integer);         // genere FNotifyEvent(Self, Msge)
     procedure SetFileName(Value: TFilename);
     procedure BtnMouseDown(Sender: TObject;Button: TMouseButton;Shift: TShiftState; X,Y: Integer);
     procedure CurseurMove(Sender: TObject;Shift: TShiftState; X,Y: Integer); // OnMouseMove sur l'image
     procedure ReceiveLevel(Level,Max: Integer);            // Recevoir niveau du travail effectué
     Procedure DoBlocMove;                                  // procedure positions Marqueurs + OA + AB ;
     procedure PlayerNotify(Sender: Tobject);
     procedure PlayerTime(Sender: TObject);
     procedure TabSpectre(dobloc : boolean);
   public
     Constructor Create(AOwner: TComponent); Override;
     Destructor Destroy; Override;
     procedure StopPlayer;
     procedure PlayBloc;
     procedure PositionPlay(posit : cardinal);
     procedure Dessine;
     procedure CloseWav ;
     Function PrepareLect : boolean;

     // Déclaration des propriétés public de TSpectre
     property Duree: LongWord Read FDuree write FDuree ;                   // Lecture de la durée du fichier
     property LongOctOA : integer Read OctOA;                              // Longueur OA en smallint div 4 * 4
     property LongOctAB : integer Read OctAB;                              // Longueur AB en smallint div 4 * 4
     property LongOctOC : integer read OctOC;                              // nb de smallint du fichier - 44
     property Amplitude: word Read FAmplitude Write FAmplitude;
     property NomFile: TFilename Read FFilename Write SetFilename;
     property GetNbMode : word Read FWavHeader.NbCanaux;
     property GetNbBits : word Read FWavHeader.Bitsample;
     property GetNbFreq : Longword Read FWavHeader.Freq ;
     property Playson : boolean Read FPlaySon default false;

   published
     property OnNotifyEvent: TNotifyEvent Read FNotifyEvent Write FNotifyEvent;           // Notifier messages / event
     property OnNotifyPosition: TNotifyPosit Read FNotifyPosit Write FNotiFyPosit;        // Notifier position curseur
     property OnNotifyLoad: TNotifyLoad Read FNotifyLoad Write FNotifyLoad;               // Notification position chargement
     property OnNotifyPlayPosition: TNotifyPositPlay Read FNotifyPosPlay Write FNotifyPosPlay ;
     property OnNotifyStartPlay: TNotifyEvent Read FNotifyStartPlay Write FNotifyStartPlay;// Notifier Le debut de lecture
     property OnNotifyStopPlay: TNotifyEvent Read FNotifyStopPlay Write FNotifyStopPlay;   // Notifier la fin de lecture
     property OnNotifyBloc: TNotifyEvent Read FNotifyBloc Write FNotifyBloc;
     property OnNotifydbBloc: TNotifyEvent Read FNotifydbBloc Write FNotifydbBloc;
     property visible default false;
     property align default Alnone;
     property Tag;
end;

     procedure Register;
     Function maximise( A,B : integer) : integer;
     Function minimise( A,B : integer) : integer;

implementation

Constructor TSpectre.Create(AOwner:TComponent);
begin
  Inherited Create(AOwner);
  Width           := 209;
  Height          := 78 ;
  FDuree          := 0;
  PositLect       := 0;
  FAmplitude      := 100;
  Visible         := false;
  Spectre         := nil;
  FFilename       := '';
  decaldata       := 0;  //  Header Size dynamique entre 44 et 3000 octets

  PanelParent := TPanel.Create(Self);
  With PanelParent do begin
       Parent:= Self;
       BorderStyle:= bsnone;
       BevelInner:= Bvnone;
       BevelOuter:= BvNone;
       color:= clblack; end;

  Img := TImage.Create(Self);
  
  Bloc := TShape.Create(Self);
  With Bloc do begin
       Parent := PanelParent;
       Brush.Color := ClNavy ;
       Pen.Mode := PmMerge ;
       Visible := true; enabled := false ;
       left := 0 ;
       Width := 1;
       Top := 0;
       OnMouseDown := BtnMouseDown;
       OnMouseMove := CurseurMove;
       end;

  PosLect := TShape.Create(Self);
  With PosLect do begin
       Parent := PanelParent;
       Brush.Color := ClRed;
       Pen.Color := ClRed;
       left := 0 ; Width := 1; Top := 2;
       Visible := true ;
       end;

  DebBloc := TShape.Create(Self);
  With DebBloc do begin
       Parent := PanelParent;
       Brush.Color := ClRed; Pen.Color := ClRed;
       enabled := false ;
       Left := 0 ; Width := 1 ; Top := 2 ; Visible := true;
       OnMouseMove := CurseurMove; end;

  EndBloc := TShape.Create(Self);
  With EndBloc do begin
       Parent := PanelParent;
       Brush.Color := ClFuchsia ;
       Pen.Color := ClPurple;
       enabled := false ;
       Left := 0 ; Width := 1; Top := 2;
       Visible := True;
       OnMouseMove := CurseurMove; end;

  Player := TMediaPlayer.Create(Self);
  With Player do begin
       Parent := Nil;
       AutoOpen:=False;
       Visible := false ;
       DeviceType := dtAutoSelect;
       TimeFormat := tfMilliseconds
       end;

  PlayTimer := TTimer.Create(Self);
  With PlayTimer do begin
       Enabled := False;
       Interval := 13 ;
       OnTimer := PlayerTime;
       end;

end;

destructor TSpectre.Destroy;
begin
  Playtimer.enabled:= false;
  Playtimer.free;
  FreeAndNil(img);
  spectre:= nil;
  Player.enabled := false ;
  Player.free ;
  Inherited Destroy;
end;

Function maximise( A,B : integer) : integer;
begin
  if A >= B then result:= A else result:= B;
end;

Function minimise( A,B : integer) : integer;
begin
  if A <= B then result:= A else result:= B
end;

procedure TSpectre.CloseWav ;
begin
  visible:= false;
  Fduree:= 0;
  FFilename:= '';
  spectre:= nil;
  okwav:= false;
  decaldata:= 0;
  PositLect:= 0;
  GetInfoEvent(FWClose);
end ;

procedure TSpectre.SetFileName(Value : TFilename);
  var Filstream : TFileStream ; Compress : boolean;
begin
  if not fileExists(value) then exit ;
  Filstream := nil; FFilename := '' ;
  OkWav := false; decaldata:= 0;
  Compress:= (Uppercase(extractfileExt(Value)) <> '.WAV');
  if Compress then with Player do try
       if mode = MpPlaying
          then Stop; Close;
       PlayTimer.Enabled:= false;
       Parent:= Self;
       Filename:= Value;
       open;
       FDuree:= Length;
       close;
       except GetInfoEvent(FWMci); exit end;
  FFilename := Value ;
  try FilStream := TFileStream.Create(FFilename, FmOpenRead or fmShareDenyNone);
      Filstream.position := 0 ;
      OctOC := (FilStream.size-Hs) div 4 * 4;
      if Compress
         then begin // fichier Mp3 ou Wma
              FMp3Size1:= filstream.size; // info récupérée dans dessine !
              Setlength(spectre, width);
              visible := true;
              dessine;
              GetInfoEvent(FWOpen);
              end
         else with FWavHeader do begin
              Filstream.read(FWavHeader,HS) ;
              OkWav:= (Wave='WAVE') and ((BitSample = 8) or (BitSample = 16));
              if OkWav and (data <> 'data') // Fichier dynamique ?
                 then begin
                      while (data <> 'data') and (decaldata < 3000) do begin
                            inc(decaldata, 2);
                            Filstream.position:= decaldata+36;
                            Filstream.read(data, 4); end;
                      if decaldata < 3000
                         then begin
                              data:= 'data';
                              size2:= size1-36;
                              LgStruct:= 16;
                              OctOC:= OctOC-decaldata
                              end
                         else OkWav:= false;
                 end;
              if OkWav then FDuree:= round(Size2 div OctPerEch / Freq * 1000)
                       else begin
                            closewav;
                            GetInfoEvent(FWError)
                            end;
              end;
  Finally  FreeAndNil(Filstream); end;
  if OkWav 
     then begin
          Setlength(spectre, width); // adaptation à ricwav0
          visible := true;
          Tabspectre(false);
          GetInfoEvent(FWOpen);
          end;
end;

procedure TSpectre.TabSpectre(dobloc : boolean);  // tableau pour dessiner le spectre audio
  var Filstream : TFileStream ;
      i, deb, fin, dif : integer;
      val08 : byte;
      val16 : smallint;
      pas : real;
begin
  Filstream := nil;
  if not okWav then exit;
  try FilStream := TFileStream.Create(FFilename, FmOpenRead);
      if (filstream.size-HS < 256)
         then begin
              closewav;
              exit;
         end;
      GetInfoEvent(FWSpectre);
      pas := (Filstream.size-HS) / Length(spectre); // le pas > 2 => lecture de + 1 smallInt !
      if DoBloc
       then begin deb := muldiv(Length(spectre), OctOA, OctOC);
                  fin := muldiv(Length(spectre), OctOA+OctAB, OctOC);
                  i:= deb;
       end
       else begin deb := 0; fin := Length(spectre); i:= 0; end ;
      dif := maximise(1,(fin-deb) div 64);  // Pour informer de la progression du process si fichier long
      case FWavHeader.Bitsample of
         16 : while i < fin-4 do begin
              Filstream.position:= trunc(i*pas) div 4 * 4 + HS;
              filstream.read(val16,2);
              spectre[i].G:= abs(val16 div $FF);
              filstream.read(val16,2);
              spectre[i].D:= abs(val16 div $FF);
              i := i+1;
              if i mod dif = 0 then ReceiveLevel(i-deb, fin-deb); end ;
         08 : while i < fin-2 do begin
              Filstream.position:= trunc(i*pas) div 2 * 2 + HS ;
              filstream.read(val08,1);
              spectre[i].G:= abs(val08 - $80);
              filstream.read(val08,1);
              spectre[i].D:= abs(val08 - $80);
              i := i+1;
              if i mod dif = 0 then ReceiveLevel(i-deb, fin-deb); end
         end;
  finally FreeAndNil(filstream); end;
  GetInfoEvent(FWOk);
  dessine;
end;

Procedure TSpectre.BtnMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState; X,Y:Integer);
begin
  case Button of
       MbLeft : begin
                if (ssctrl in shift)
                   then begin
                        if Assigned(FNotifydbBloc) then FNotifydbBloc(Self, x);
                        exit
                        end
                   else begin
                        DebBloc.Left:= x;
                        PosLect.left:= x;
                        PositLect:= muldiv(x,FDuree,Width);
                        if endBloc.Left < x then endbloc.Left := x ;
                        end;
                end;
       MbRight: begin EndBloc.Left:= x; if DebBloc.Left > x then debbloc.Left:= x end;
       MbMiddle:begin if Assigned(FNotifydbBloc) then FNotifydbBloc(Self, x); exit end;
  end;
  DoBlocMove;
  if (tag = 0) and ((ssleft in shift) or (EndBloc.Left = DebBloc.Left))
     then GetInfoEvent(PositLect);
  if Playtimer.enabled and (ssleft in shift) and (Player.mode = MpPlaying)
     then try
          Player.StartPos := Muldiv(x,FDuree,Width);
          if Assigned(OnNotifyStartPlay) then FNotifyStartPlay(Self, Player.startPos);
          Player.Play ;
          Except GetInfoEvent(FWmci) end;
end;

Procedure TSpectre.CurseurMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
begin
  If not playson and Assigned(FNotifyPosit) then FNotifyPosit(Self, muldiv(X,FDuree,Width));
end;

procedure TSpectre.PositionPlay(posit : cardinal); // posit = temps cumulé début de l'image
begin
  if (Fduree = 0) then exit;
  if posit > duree then posit:= duree;
  DebBloc.Left:= muldiv(width, posit, FDuree);
  PosLect.left := DebBloc.left;
  PositLect:= Posit;
end;

Procedure TSpectre.DoBlocMove;// div 4 * 4 afin que position toujours sur échantillon left
begin
  if (width < 2) or (OctOC < 256) then begin closewav; exit end;
  if (DebBloc.left < 0) or (DebBloc.left > width)
     then DebBloc.left := 0 ;
  if (EndBloc.left < 0) or (EndBloc.left > width)
     then EndBloc.left := width ;
  With bloc do begin
       Parent := Nil;
       Parent := PanelParent;
       Left := minimise(DebBloc.Left, EndBloc.Left) ;
       width := abs(EndBloc.Left-DebBloc.Left)
       end;
  OctOA := muldiv(Bloc.Left,OctOC,Width) div 4 * 4; // OA est tjrs >= 0
  if OctOA < decaldata
     then OctOA:= Decaldata;
  OctAB := Muldiv(Bloc.Width, OctOC, img.Width) div 4 * 4;
  if cardinal(OctOA + OctAB) > FWavHeader.size2
     then OctAB:= (integer(FWavHeader.size2)-OctOA) div 4 * 4;
  if OctOA >= OctOC //  prise en compte des incertitudes positions curseurs
     then begin OctOA:= OctOC div 4 * 4; OctAB:= 0 end
     else if OctOA + OctAB > OctOC
          then begin OctAB:= (OctOC - OctOA) div 4 * 4 end;
  FDebutBloc   := Muldiv(OctOA, FDuree, OctOC) div 4 * 4;
  FFinBloc     := Muldiv(OctOA + OctAB, FDuree, OctOC) div 4 * 4;
  PosLect.left := DebBloc.left;
  if Assigned(FNotifyBloc)
     then FNotifyBloc(Self, Muldiv(OctAB,FDuree,OctOC));
end;

procedure TSpectre.Dessine;
  var pas, Coeft: real;  // rapport hauteur image sur niveau sons
      posit, Milieu, Quart, TroisQuart, Haut, Long : word;
      i, k, D, G, DX, GX, nbspectrum : integer;
      infofile : shortstring;

  const mode : array[1..2] of shortString = ('mono', 'Stéréo');
begin
  if (FDuree = 0) then exit ;

  With PanelParent do begin
       Top:= 0; Left:= 0;
       Width:= Self.Width ;
       Height:= Self.Height  ;
       DebBloc.Height:= Height;
       EndBloc.Height:= Height;
       PosLect.Height:= Height;
       Bloc.Height:= Height;
       end;

  if Img <> Nil
     then begin Img.Parent:= Nil; Img.Destroy; Img:= Nil; repaint end;
  if Img = Nil then Img:= TImage.Create(Self);
  With Img do begin
       Parent:= PanelParent;
       OnMouseDown:= BtnMouseDown;
       OnMouseMove:= CurseurMove ;
       Top:= 0; Left:= 0;
       Height:= Parent.Height; Width:= Parent.Width;
       end;

  Long:= maximise(Width,1); Haut:= Height;
  Milieu := Haut div 2; Quart := Haut div 4; TroisQuart := Quart*3;
  With Img.Canvas do begin
      Brush.Color := ClBlack; floodFill(1,1,ClRed,FsBorder); Pen.Color := ClOlive; pen.Width := 1 ;
      MoveTo(0,0); LineTo(Long,0); MoveTo(0,Milieu); LineTo(Long,Milieu); MoveTo(0,Haut-1); LineTo(Long,Haut-1);
      Pen.Style := PsDot; MoveTo(0,Quart); LineTo(Long,Quart); MoveTo(0,TroisQuart); LineTo(Long,TroisQuart);
      Pen.Style := PsSolid; MoveTo(0,0); LineTo(0,Haut); MoveTo(Long-1,0); LineTo(Long-1,Haut) end ;
      
  posit := 0; i := 0;
  Pas := length(Spectre) / Long ;
  nbspectrum:= trunc(pas);
  Coeft := Haut/$80*FAmplitude/100 ;
  if okWav
     then begin
          with FWavHeader do begin
          infofile:= format( 'Data = %d Ko ; T = %d ms ; Format = (%d Hz, %d bits, ',
                     [size1 div 1024,Fduree,Freq,BitSample])+mode[nbCanaux]+')';
          end;

          if (tag in [1,2,3]) then img.canvas.Pen.Color:= ClOlive else img.canvas.Pen.Color:= Clgray ;
          GX:=0; DX:=0;
          While i < length(Spectre)-pas do begin
                G:=0; D:=0;
                for k:= 1 to nbspectrum do begin
                    G := maximise(G, round((Spectre[i].G) * Coeft));
                    D := maximise(D, round((Spectre[i].D) * Coeft));
                    end;
                G := (G+GX) div 2; GX := G;
                D := (D+DX) div 2; DX := D;
                Img.Canvas.Moveto(posit,Milieu-G);
                Img.Canvas.Lineto(posit,Milieu+D);
                posit := posit+1 ; i:= round(pas*posit); end
          end 
     else begin // if FWavHeader.Wave = 'WMA or MP3' or not good wav then
          infofile:= format( 'Taille = %d Ko ; Durée = %d ms ; (Spectre => Fichier Wav)',
                     [FMp3Size1 div 1024, Fduree]);
          // Voilà : nous y sommes, c'est là que je voudrais progresser ! En attendant :
          img.canvas.Pen.Color:= Clgray ;
          While posit < width do begin
                G := trunc(sin(posit/pi*10)*15);
                Img.Canvas.Moveto(posit,Milieu-G);
                Img.Canvas.Lineto(posit,Milieu+G);
                posit:= posit+1 ; end ;
          end;
       
  with img.canvas do begin
       Font.color:= ClSilver ;
       textout( 2,haut-16, infoFile);
       textout( 2, quart-4, 'L');
       textout( 2, troisquart-8, 'R');
       Font.color := ClRed ;
       textout( 2,2,'Fichier = '+ extractFilename(FFileName)) ;
       Pen.Color := ClLime; Pen.Style := PsDot; MoveTo(0,Milieu); LineTo(Long,Milieu); end;
  With DebBloc do begin Parent := Nil; Parent := PanelParent; enabled:= false end;
  With EndBloc do begin Parent := Nil; Parent := PanelParent; enabled:= false end;
  With PosLect do begin Parent := Nil; Parent := PanelParent; enabled:= false end;
end;

Function TSpectre.PrepareLect : boolean;
begin
  result := false;
  if not fileExists(FFilename)
     then exit ;
  if debbloc.left >= width
     then debbloc.Left:= 0;
  PosLect.left:= DebBloc.left;
  With player do Try
    Parent:= Self;
    Notify:= True;
    OnNotify:= PlayerNotify;
    Close;
    Filename:= Pchar(FFileName) ;
    update;
    Open;
    if Assigned(OnNotifyStartPlay)
       then FNotifyStartPlay(Self, StartPos);
    FPlaySon:= true; result := true;
  Except GetInfoEvent(FWmci) end;
  if result then begin
  if PositLect >= FDuree
       then player.StartPos:= muldiv(debBloc.Left,Fduree,Width)
       else player.StartPos:= maximise(PositLect, muldiv(debBloc.Left,Fduree,Width));
  end;
end;

Procedure TSpectre.PlayBloc;
begin
if PrepareLect then Player.Play;
end;

Procedure TSpectre.StopPlayer;
begin
  FPlaySon:= false; 
  Player.Parent:= Self; PlayTimer.Enabled:= false;
  if Assigned(OnNotifyStopPlay)
     then FNotifyStopPlay(Self, player.position);
  With Player do
       if mode = MpPlaying
          then begin Stop; Close; end;
end;

Procedure TSpectre.PlayerNotify(Sender: TObject);
begin
  Sleep(5);
  With Player do Case mode of
       MpStopped, mpPaused, mpNotReady :
                    begin PlayTimer.Enabled:= false; Stop;
                          FPlaySon:= false;
                          if Assigned(OnNotifyStopPlay)
                             then FNotifyStopPlay(Self, player.position); Close; end;
       MpPlaying  : begin PosLect.Parent:= PanelParent;
                          PlayTimer.Enabled:= True;
                          FPlaySon:= true;
                          if not Okwav and (longword(position) = duree)
                             then FNotifyStopPlay(Self, player.position);
                          // pb de détection fin mp3 réglé ainsi pour vista ?
                    end;
       end;
end;

Procedure TSpectre.PlayerTime(Sender:TObject);
begin
  with Player do case Mode of
       MpPlaying : if Assigned(OnNotifyPlayPosition)
                      then begin
                           FNotifyPosPlay(Self, Position);
                           PosLect.Left := Muldiv(PanelParent.Width,Position,FDuree)
                           end;
       MpStopped,
       mpNotReady : begin PlayTimer.Enabled:= False; FPlaySon:= false; end;
       end;
end;

procedure TSpectre.GetInfoEvent(msg : integer);
begin
  if Assigned(FNotifyEvent) then FNotifyEvent(Self, Msg);
end ;

Procedure TSpectre.ReceiveLevel(Level, Max: Integer);
begin
  if Assigned(FNotifyLoad) then FNotifyLoad(self, Level,Max);
end;

procedure Register;
begin
  RegisterComponents('Exemples', [TSpectre]);
end;

End.


