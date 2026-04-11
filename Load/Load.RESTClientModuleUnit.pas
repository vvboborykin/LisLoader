{*******************************************************
* Project: LisLoader
* Unit: RESTClientModuleUnit.pas
* Description: модуль REST клиента для взаимодействия с ЛИС
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}

unit Load.RESTClientModuleUnit;

interface

uses
  System.SysUtils, System.Classes, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, System.JSON,
  Load.RESTParamsUnit, Load.LisServiceResultUnit;

type
  /// <summary>TRESTClientModule
  /// модуль REST клиента для взаимодействия с ЛИС
  /// </summary>
  TRESTClientModule = class(TDataModule)
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
  strict private
    FOrderId: string;
    /// <summary>BuildRequestJSONObject
    /// построить JSON объект запроса
    /// </summary>
    /// <param name="AParams"> (TRESTParams) параметры запроса</param>
    /// <returns>TJSONObject - сформированный JSON объект</returns>
    function BuildRequestJSONObject(AParams: TRESTParams): TJSONObject;
  public
    /// <summary>LoadOrderResultJSONString
    /// загрузить данные по заказу из ЛИС
    /// </summary>
    /// <param name="AParams"> (TRESTParams) параметры запроса</param>
    /// <returns>TLisServiceResult - результат выполнения запроса</returns>
    function LoadOrderResultJSONString(AParams: TRESTParams; AOrderId: string):
        TLisServiceResult;
  end;


implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

function TRESTClientModule.BuildRequestJSONObject(AParams: TRESTParams):
    TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', 'Parameters');
  var vParams := TJSONArray.Create;

  var vObj := TJSONObject.Create;
  vObj.AddPair('name', 'SourceCode');
  vObj.AddPair('valueString', AParams.MisGuid);
  vParams.Add(vObj);

  vObj := TJSONObject.Create;
  vObj.AddPair('name', 'TargetCode');
  vObj.AddPair('valueString', AParams.MisGuid);
  vParams.Add(vObj);

  vObj := TJSONObject.Create;
  vObj.AddPair('name', 'OrderMisID');
  vObj.AddPair('valueString', FOrderId);
  vParams.Add(vObj);

  Result.AddPair('parameter', vParams);
end;

function TRESTClientModule.LoadOrderResultJSONString(AParams: TRESTParams;
    AOrderId: string): TLisServiceResult;
begin
  FOrderId := AOrderId;
  Result.JSON := '';
  Result.Error := '';
  var vRequestJSONObject := BuildRequestJSONObject(AParams);
  try
    RESTClient.BaseURL := AParams.LisServerBase + '/$getresult?_format=json';
    RESTRequest.Params.ParameterByName('Authorization').Value := 'BARSLIS ' + AParams.AuthGuid;
    RESTRequest.ClearBody;
    RESTRequest.AddBody(vRequestJSONObject);
    RESTRequest.Execute;
    if RESTResponse.StatusCode > 300 then
      Result.Error := RESTResponse.StatusCode.ToString() + ' ' +
        RESTResponse.StatusText;
    Result.JSON := RESTResponse.Content;
  finally
    vRequestJSONObject.Free;
  end;
end;

end.
