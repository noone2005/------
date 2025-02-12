object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #22823#39134#30340#31508#35760#26412
  ClientHeight = 599
  ClientWidth = 985
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OnCreate = FormCreate
  TextHeight = 15
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 313
    Height = 599
    Align = alLeft
    Caption = 'pnlLeft'
    TabOrder = 0
    object TreeView1: TTreeView
      Left = 1
      Top = 1
      Width = 311
      Height = 578
      Align = alClient
      Indent = 19
      PopupMenu = PopupMenu1
      TabOrder = 0
      OnChange = TreeView1Change
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 579
      Width = 311
      Height = 19
      Panels = <>
    end
  end
  object pnlRight: TPanel
    Left = 313
    Top = 0
    Width = 480
    Height = 599
    Align = alLeft
    Caption = 'pnlRight'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 1
      Top = 1
      Width = 8
      Height = 597
    end
    object Memo1: TMemo
      Left = 9
      Top = 1
      Width = 470
      Height = 597
      Align = alClient
      Lines.Strings = (
        'Memo1')
      TabOrder = 0
      OnChange = Memo1Change
      ExplicitWidth = 416
    end
  end
  object Panel1: TPanel
    Left = 800
    Top = 0
    Width = 185
    Height = 599
    Align = alRight
    Caption = 'Panel1'
    TabOrder = 2
    ExplicitLeft = 872
    ExplicitTop = 424
    ExplicitHeight = 41
    object ListBox1: TListBox
      Left = 1
      Top = 1
      Width = 183
      Height = 597
      Align = alClient
      ItemHeight = 15
      TabOrder = 0
      ExplicitLeft = 64
      ExplicitTop = 336
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
  object MainMenu1: TMainMenu
    Left = 441
    Top = 272
    object mnuFile: TMenuItem
      Caption = 'file'
      object mnuSave: TMenuItem
        Caption = 'save'
        OnClick = mnuSaveClick
      end
      object mnuLoad: TMenuItem
        Caption = 'load'
        OnClick = mnuLoadClick
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 97
    Top = 344
    object mnuAddLevel1: TMenuItem
      Caption = 'addlevel1'
      OnClick = mnuAddLevel1Click
    end
    object mnuAddLevel2: TMenuItem
      Caption = 'addlevel2'
      OnClick = mnuAddLevel2Click
    end
    object mnuAddLevel3: TMenuItem
      Caption = 'addlevel3'
      OnClick = mnuAddLevel3Click
    end
    object mnuDelete: TMenuItem
      Caption = 'delete'
      OnClick = mnuDeleteClick
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 569
    Top = 464
  end
  object OpenDialog1: TOpenDialog
    Left = 681
    Top = 480
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 473
    Top = 520
  end
end
