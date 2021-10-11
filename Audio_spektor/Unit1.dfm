object Form1: TForm1
  Left = 247
  Top = 122
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Audio spektor'
  ClientHeight = 264
  ClientWidth = 929
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -24
  Font.Name = 'Times New Roman'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 27
  object StopPlay: TSpeedButton
    Left = 632
    Top = 8
    Width = 289
    Height = 49
    Caption = 'Stop / Play'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    Glyph.Data = {
      CE000000424DCE0000000000000076000000280000000E0000000B0000000100
      04000000000058000000430B0000430B0000100000001000000000FF00008080
      8000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000233222222222
      2265230332222222225023000332222222DA2300000332222243230000000332
      2238230000000003326F23000000033222142300000332222263230003322222
      2272230332222222226F233222222222226E}
    ParentFont = False
    Spacing = 8
    OnClick = StopPlayClick
  end
  object Open: TSpeedButton
    Left = 8
    Top = 8
    Width = 305
    Height = 49
    Caption = 'Open / Close'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -23
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    Glyph.Data = {
      06020000424D0602000000000000760000002800000019000000190000000100
      04000000000090010000130B0000130B0000100000001000000000000000FF00
      00000943FF0000FFFF0080808000C8D0D400DDE2E400EAEDEE00EAEDEF00F2F4
      F500FFFFFF000000000000000000000000000000000000000000988888888888
      8888888888889000000065555555555555555555555560000000640000000000
      00000000000560000000645A5A5A5A5A5A5A5A5A5A056000000064A5A5A5A5A5
      A5A5A5A5A50560000000645A5000000000000A5A5A056000000064A500353535
      353530A5A50560000000645A03035353535353000A056000000064A50A053535
      35353501050560000000645A03A05353535353500A056000000064A50A3A0000
      05353530050560000000645A03A3A3A3A00000000A056000000064A50A3A322A
      223A3A3A050560000000645A03A3A22322A223220A056000000064A50A3A3A2A
      32322A22050560000000645A03A3A323A2A323A20A056000000064A5A0004A22
      22AA2AA2050560000000645A5A5A4444444422224A056000000064A5A5A5A5A5
      A5A5A5A5A505600000006400000000000000000000056000000064A011111111
      1111110A0A056000000064444444444444444444444560000000655555555555
      5555555555556000000065555555555555555555555560000000766666666666
      66666666666670000000}
    ParentFont = False
    Spacing = 8
    OnClick = OpenClick
  end
  object Label3: TLabel
    Left = 679
    Top = 82
    Width = 180
    Height = 27
    Caption = 'Dimension du bloc'
  end
  object Label4: TLabel
    Left = 638
    Top = 113
    Width = 268
    Height = 28
    Alignment = taCenter
    AutoSize = False
    Caption = '000'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -23
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 72
    Top = 82
    Width = 144
    Height = 27
    Caption = 'Position cursor'
  end
  object Label7: TLabel
    Left = 21
    Top = 113
    Width = 289
    Height = 27
    Alignment = taCenter
    AutoSize = False
    Caption = '000'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -23
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 471
    Top = 7
    Width = 29
    Height = 28
    Flat = True
    Glyph.Data = {
      72010000424D7201000000000000760000002800000015000000150000000100
      040000000000FC000000330B0000330B00001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777777770007777777777777777777770007777777777777777777770007777
      7777CCCCCC7777777000777777CCCCCCCCCC7777700077777CCCCCCCCCCCC777
      70007777CCCCCBBBBCCCCC7770007777CCCCCCBBCCCCCC777000777CCCCCCCBB
      CCCCCCC77000777CCCCCCCBBCCCCCCC77000777CCCCCCCBBCCCCCCC77000777C
      CCCCCBBBCCCCCCC77000777CCCCCCCCCCCCCCCC770007777CCCCCCCCCCCCCC77
      70007777CCCCCCBBCCCCCC77700077777CCCCCBBCCCCC7777000777777CCCCCC
      CCCC7777700077777777CCCCCC77777770007777777777777777777770007777
      77777777777777777000777777777777777777777000}
    OnClick = SpeedButton1Click
  end
  object Label1: TLabel
    Left = 350
    Top = 72
    Width = 246
    Height = 81
    Alignment = taCenter
    Caption = 
      'Clic gauche et droit sur la piste audio pour d'#1081'finir des '#1081'chanti' +
      'llons...'
    WordWrap = True
  end
  object Spectre1: TSpectre
    Left = 0
    Top = 171
    Width = 929
    Height = 93
    OnNotifyPosition = Spectre1NotifyPosition
    OnNotifyPlayPosition = Spectre1NotifyPosition
    OnNotifyBloc = Spectre1NotifyBloc
    visible = True
    align = alBottom
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      #39'Music files : wav + mp3 + wma'#39'|*.wav;*.mp3;*.wma|Fichier Mp3|*.' +
      'mp3|Fichier Wav|*.wav|Fichier Wma|*.wma'
    Left = 328
    Top = 8
  end
end
