object MiniBrowserFrm: TMiniBrowserFrm
  Left = 0
  Top = 0
  Caption = 'Socks changer service'
  ClientHeight = 667
  ClientWidth = 888
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object DevTools: TCEFWindowParent
    Left = 888
    Top = 0
    Width = 0
    Height = 604
    Align = alRight
    TabOrder = 0
    Visible = False
  end
  object BottomPanel: TPanel
    Left = 0
    Top = 604
    Width = 888
    Height = 63
    Align = alBottom
    TabOrder = 1
    object GetNewIdenty: TButton
      Left = 4
      Top = 10
      Width = 393
      Height = 44
      Caption = 'Get new identy'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = GetNewIdentyClick
    end
    object OpenBrowserWithNewIdenty: TButton
      Left = 416
      Top = 8
      Width = 401
      Height = 46
      Caption = 'Open browser with new identy'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = OpenBrowserWithNewIdentyClick
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 888
    Height = 604
    ActivePage = TabSheet1
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Service'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      object CEFWindowParent1: TCEFWindowParent
        Left = 0
        Top = 0
        Width = 880
        Height = 575
        Align = alClient
        TabStop = True
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Manual input'
      ImageIndex = 2
      object Label1: TLabel
        Left = 24
        Top = 19
        Width = 68
        Height = 14
        Caption = 'Proxy string:'
      end
      object Label2: TLabel
        Left = 24
        Top = 47
        Width = 29
        Height = 14
        Caption = 'Host:'
      end
      object Label3: TLabel
        Left = 24
        Top = 75
        Width = 27
        Height = 14
        Caption = 'Port:'
      end
      object Label4: TLabel
        Left = 24
        Top = 111
        Width = 58
        Height = 14
        Caption = 'Username:'
      end
      object Label5: TLabel
        Left = 24
        Top = 139
        Width = 55
        Height = 14
        Caption = 'Password:'
      end
      object HostManualInput: TEdit
        Left = 98
        Top = 44
        Width = 135
        Height = 22
        Enabled = False
        TabOrder = 0
      end
      object PortManualInput: TEdit
        Left = 98
        Top = 72
        Width = 135
        Height = 22
        Enabled = False
        TabOrder = 1
      end
      object UsernameManualInput: TEdit
        Left = 98
        Top = 108
        Width = 135
        Height = 22
        Enabled = False
        TabOrder = 2
      end
      object PasswordManualInput: TEdit
        Left = 98
        Top = 136
        Width = 135
        Height = 22
        Enabled = False
        TabOrder = 3
      end
      object ProxyStringManualInput: TEdit
        Left = 98
        Top = 16
        Width = 207
        Height = 22
        TabOrder = 4
      end
      object Button1: TButton
        Left = 24
        Top = 176
        Width = 209
        Height = 25
        Caption = 'Set proxy to Firefox'
        TabOrder = 5
        OnClick = Button1Click
      end
    end
    object Logs: TTabSheet
      Caption = 'Logs'
      ImageIndex = 1
      object AppLog: TMemo
        Left = 0
        Top = 0
        Width = 880
        Height = 575
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object Chromium1: TChromium
    OnResolvedHostAvailable = Chromium1ResolvedHostAvailable
    OnLoadEnd = Chromium1LoadEnd
    OnLoadError = Chromium1LoadError
    OnLoadingStateChange = Chromium1LoadingStateChange
    OnStatusMessage = Chromium1StatusMessage
    OnLoadingProgressChange = Chromium1LoadingProgressChange
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnCertificateError = Chromium1CertificateError
    OnSelectClientCertificate = Chromium1SelectClientCertificate
    OnBeforeResourceLoad = Chromium1BeforeResourceLoad
    OnResourceResponse = Chromium1ResourceResponse
    Left = 8
    Top = 112
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 16
    Top = 48
  end
end
