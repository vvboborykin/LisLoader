object RESTClientModule: TRESTClientModule
  Height = 480
  Width = 640
  object RESTClient: TRESTClient
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'utf-8, *;q=0.8'
    BaseURL = 'http://172.30.254.175/api/int/fhir/$getresult?_format=json'
    ContentType = 'application/json'
    Params = <>
    RaiseExceptionOn500 = False
    SynchronizedEvents = False
    Left = 128
    Top = 40
  end
  object RESTRequest: TRESTRequest
    AssignedValues = [rvConnectTimeout, rvReadTimeout]
    Client = RESTClient
    Method = rmPOST
    Params = <
      item
        Kind = pkHTTPHEADER
        Name = 'Accept-Encoding'
        Options = [poDoNotEncode]
        Value = 'gzip, deflate'
      end
      item
        Kind = pkHTTPHEADER
        Name = 'Authorization'
        Options = [poDoNotEncode]
        Value = 'BARSLIS 93a89932-1bda-4d05-930b-1239d09f5400'
      end
      item
        Kind = pkHTTPHEADER
        Name = 'User-Agent'
        Options = [poDoNotEncode]
        Value = 'python-requests/2.10.0'
      end
      item
        Kind = pkHTTPHEADER
        Name = 'Accept'
        Options = [poDoNotEncode]
        Value = '*/*'
      end
      item
        Kind = pkHTTPHEADER
        Name = 'Connection'
        Options = [poDoNotEncode]
        Value = 'keep-alive'
      end
      item
        Kind = pkREQUESTBODY
        Name = 'body53E8CF41C6DB433ABEFEA033ED28087D'
        Value = 
          '{"resourceType": "Parameters", "parameter": [{"name": "SourceCod' +
          'e", "valueString": "914c7c78-b61b-438a-853b-4fc99f663a25"}, {"na' +
          'me": "TargetCode", "valueString": "914c7c78-b61b-438a-853b-4fc99' +
          'f663a25"}, {"name": "OrderMisID", "valueString": "026260001256"}' +
          ']}'
        ContentTypeStr = 'application/json'
      end>
    Response = RESTResponse
    SynchronizedEvents = False
    Left = 184
    Top = 136
  end
  object RESTResponse: TRESTResponse
    ContentType = 'application/json'
    ContentEncoding = 'gzip'
    Left = 264
    Top = 48
  end
end
