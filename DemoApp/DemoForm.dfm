object fmDemo: TfmDemo
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = #1044#1077#1084#1086' '#1086#1082#1085#1072' "'#1057#1086#1073#1099#1090#1080#1103'"'
  ClientHeight = 524
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 293
    Height = 62
    Align = alTop
    Caption = 'TopPanel'
    TabOrder = 0
    object btnChangeEdge: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 33
      Height = 31
      Align = alLeft
      Caption = 'Edge'
      TabOrder = 0
      OnClick = btnChangeEdgeClick
    end
    object chkAutohide: TCheckBox
      AlignWithMargins = True
      Left = 4
      Top = 41
      Width = 285
      Height = 17
      Align = alBottom
      Caption = 'Autohide'
      TabOrder = 1
      OnClick = chkAutohideClick
    end
  end
  object mmoEvents: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 71
    Width = 293
    Height = 450
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object tmr1: TTimer
    OnTimer = tmr1Timer
    Left = 128
    Top = 136
  end
end
