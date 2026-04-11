{*******************************************************
* Project: LisLoader
* Unit: OrderLoaderUnit.pas
* Description: загрузчик данных по заказу
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Load.OrderLoaderUnit;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  System.Threading, Lib.Logger.LoggerUnit, Load.RESTClientModuleUnit,
  System.JSON, System.JSON.Builders, Load.FHIRModel, Load.LisServiceResultUnit,
  Load.RESTParamsUnit, System.SyncObjs;

type
  /// <summary>TOrderLoader
  /// загрузчик данных по заказу
  /// </summary>
  TOrderLoader = class(TObject)
  strict private
    class var FRESTParamsCache: TRESTParams;
  strict private
    FLoadResult: TLisServiceResult;
    FLock: TCriticalSection;
    FOrderId: string;
    FTask: ITask;
    function GetLoadParams: TRESTParams;
    function LoadOrderResultsFromLis: Boolean;
    procedure ReportForLoadingFault;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>TOrderLoader.LoadOrder
    /// загрузить данные из ЛИС
    /// </summary>
    /// <param name="AOrderId"> (string) номер заказа</param>
    /// <param name="ATask"> (ITask) вычислительный поток в рамках которого идет работа</param>
    function LoadOrder(AOrderId: string; ATask: ITask; out AResult:
        TLisServiceResult): Boolean;
  end;

implementation

uses
  Load.CmcoLoadDataModuleUnit;

resourcestring
  SLisDataReceived = 'Данные по заказу %s получены из ЛИС';
  SLisLoadError = 'Ошибка получения данных по заказу %s - ';
  SLoadingError = 'Ошибка загрузки заказа %s: %s';
  SLoadStarted = 'Начата загрузка заказа %s';

constructor TOrderLoader.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create();
end;

destructor TOrderLoader.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

function TOrderLoader.GetLoadParams: TRESTParams;
begin
  FLock.Enter;
  try
    if FRESTParamsCache.LisServerBase = '' then
    begin
      var vCmcoData := TCmcoLoadDataModule.Create(nil);
      try
        FRESTParamsCache := vCmcoData.GetRestParams();
      finally
        vCmcoData.Free;
      end;
    end;
    Result := FRESTParamsCache;
  finally
    FLock.Leave;
  end;
end;

function TOrderLoader.LoadOrder(AOrderId: string; ATask: ITask; out AResult:
    TLisServiceResult): Boolean;
begin
  FTask := ATask;
  FOrderId := AOrderId;
  Logger.Info(SLoadStarted, [AOrderId]);
  Result := False;
  try
    ATask.CheckCanceled;
    Result := LoadOrderResultsFromLis();
    if Result then
      AResult := FLoadResult;
  except
    on E: Exception do
    begin
      Logger.Error(SLoadingError, [AOrderId, E.Message]);
    end;
  end;
end;

function TOrderLoader.LoadOrderResultsFromLis: Boolean;
var
  vParams: TRESTParams;
begin
  var vRESTModule := TRESTClientModule.Create(nil);
  try
    vParams := GetLoadParams();
    FLoadResult := vRESTModule.LoadOrderResultJSONString(vParams, FOrderId);
    Result := FLoadResult.Error = '';
    if Result then
      Logger.Info(SLisDataReceived, [FOrderId])
    else
      ReportForLoadingFault;
  finally
    vRESTModule.Free;
  end;
end;

procedure TOrderLoader.ReportForLoadingFault;
var
  vMessage: string;
begin
  FTask.CheckCanceled;
  var vText := SLisLoadError + FLoadResult.Error;
  if FLoadResult.JSON <> '' then
  begin
    var vObject := TJSONObject.ParseJSONValue(FLoadResult.JSON);
    if (vObject <> nil) and (vObject.TryGetValue<string>('message', vMessage)) then
    vText := vText + ': ' + vMessage;
  end;
  Logger.Error(vText, [FOrderId]);
end;

end.
