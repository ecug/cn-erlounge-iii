object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 354
  ClientWidth = 535
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
  object WB: TEmbeddedWB
    Left = 0
    Top = 0
    Width = 535
    Height = 354
    Align = alClient
    TabOrder = 0
    DisableCtrlShortcuts = 'N'
    OnGetExternal = WBGetExternal
    About = ' EmbeddedWB http://bsalsa.com/'
    PrintOptions.Margins.Left = 19.050000000000000000
    PrintOptions.Margins.Right = 19.050000000000000000
    PrintOptions.Margins.Top = 19.050000000000000000
    PrintOptions.Margins.Bottom = 19.050000000000000000
    PrintOptions.Header = '&w&bPage &p of &P'
    PrintOptions.HTMLHeader.Strings = (
      '<HTML></HTML>')
    PrintOptions.Footer = '&u&b&d'
    PrintOptions.Orientation = poPortrait
    UserAgent = ' EmbeddedWB http://bsalsa.com/'
    ExplicitLeft = 8
    ExplicitTop = 7
    ExplicitWidth = 522
    ExplicitHeight = 425
    ControlData = {
      4C000000F3350000ED2B00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 32
    Top = 24
  end
end
