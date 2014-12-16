object dmData: TdmData
  OldCreateOrder = False
  Height = 512
  Width = 878
  object Timer: TTimer
    Interval = 2000
    OnTimer = TimerTimer
    Left = 704
    Top = 288
  end
  object KanguruClient: TRESTClient
    Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    BaseURL = 'http://192.168.0.26/Kanguru/api'
    Params = <>
    HandleRedirects = True
    Left = 520
    Top = 264
  end
  object GetProductRequest: TRESTRequest
    Client = KanguruClient
    Params = <>
    Resource = 'Product/Current'
    Response = GetProductResponse
    SynchronizedEvents = False
    Left = 600
    Top = 312
  end
  object GetProductResponse: TRESTResponse
    Left = 432
    Top = 352
  end
  object idImgLoader: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 400
    Top = 136
  end
  object GetCustomerRequest: TRESTRequest
    Client = KanguruClient
    Params = <>
    Resource = 'Customer/Current'
    Response = GetCustomerResponse
    SynchronizedEvents = False
    Left = 600
    Top = 384
  end
  object GetCustomerResponse: TRESTResponse
    Left = 456
    Top = 424
  end
end
