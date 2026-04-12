{*******************************************************
* Project: LisLoader
* Unit: CmcoDataModuleUnit.pas
* Description: модуль данных для работы с базой данных СМСО
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}

unit Save.CmcoSaveDataModuleUnit;

interface

uses
  System.SysUtils, System.Classes, Lib.Cmco.BaseCmcoDataModuleUnit, UniProvider,
  MySQLUniProvider, Data.DB, DBAccess, Uni, MemDS, Lib.Data.DataSetHelperUnit,
  Lib.Data.UniConnectionHelperUnit, System.Variants, Load.FHIRModel,
  Load.PendingOrdersUnit, Load.RESTParamsUnit, Lib.Logger.LoggerUnit,
  System.StrUtils, System.Generics.Collections;

type
  TCmcoActionStatus = (acsStarted, acsWaiting,
    acsCompleted, acsCancelled, acsNoResult);
  //// 'Статус выполнения: 0-Начато, 1-Ожидание, 2-Закончено, 3-Отменено, 4-Без результата',

  TCmcoPropType = class
  strict private
    FId: Integer;
    FTypeName: String;
    FUnitId: Variant;
  public
    property Id: Integer read FId write FId;
    property TypeName: String read FTypeName write FTypeName;
    property UnitId: Variant read FUnitId write FUnitId;
  end;

  TCmcoDiagReportMetadata = class
  strict private
    FActionId: Variant;
    FActionTypeId: Variant;
    FBundle: TBundle;
    FDiagReport: TDiagnosticReport;
    FOrderRespose: TOrderResponse;
    FPropTypes: TDictionary<TObservation, TCmcoPropType>;
    procedure SetActionId(const Value: Variant);
    procedure SetActionTypeId(const Value: Variant);
    procedure SetBundle(const Value: TBundle);
    procedure SetDiagReport(const Value: TDiagnosticReport);
    procedure SetOrderRespose(const Value: TOrderResponse);
  public
    constructor Create;
    destructor Destroy; override;
    property ActionId: Variant read FActionId write SetActionId;
    property ActionTypeId: Variant read FActionTypeId write SetActionTypeId;
    property Bundle: TBundle read FBundle write SetBundle;
    property DiagReport: TDiagnosticReport read FDiagReport write SetDiagReport;
    property OrderRespose: TOrderResponse read FOrderRespose write SetOrderRespose;
    property PropTypes: TDictionary<TObservation, TCmcoPropType> read FPropTypes;
  end;


  /// <summary>TCmcoDataModule
  /// модуль данных для взаимодействия с базой данных СМСО
  /// </summary>
  TCmcoSaveDataModule = class(TBaseCmcoDataModule)
    procedure DataModuleCreate(Sender: TObject);
  strict private
    FDiagReport: TDiagnosticReport;
    FOrderRespose: TOrderResponse;
    function OrderId: string;
    procedure SaveDiagReportToCmcoAction;
  private
  protected
    FBundle: TBundle;
    FOrderResponce: TOrderResponse;
    function FindDiagReport(AReference: TReference): TDiagnosticReport;
    function StatusTextToCmcoActionStatusValue(AStatus: String): Integer;
    procedure SaveCompletedOrder;
    procedure SaveNotCompletedOrder;
    procedure SaveOrderResponce(AOrderResponce: TOrderResponse);
    procedure SetNotCompletedOrderStatus(AOrder: TOrderResponse);
    procedure UpdateBundleCmcoRecords;
  public
    procedure SaveBundle(ABundle: TBundle);
  end;

  function CmcoSaveDataModule: TCmcoSaveDataModule;

implementation

uses
  AppStringsUnit, Lib.Options.OptionsStorageUnit,
  Lib.ThreadObjectPoolUnit, Save.MetadataUnit, Save.ActionDataUnit;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

  function CmcoSaveDataModule: TCmcoSaveDataModule;
  begin
    Result := ThreadObjectPool.GetOrCreateComponent<TCmcoSaveDataModule>();
  end;

resourcestring
  SCmcoActionTypeNotFound = 'В СМСО не найден тип действия для документа-направления %s';
  SRbTestNotFound = 'Не найден тип параметра исследования с кодом %s в таблице rbTest';
  STestNotFound = 'Не удалось найти запись о типе параметра с кодом "%s"';
  SActionNotFound = 'Направление с идентификатором "%s" не найдено в БД СМСО';
  SCanNotFindOrderId = 'Не удалось определить номер заказа в ответе ЛИС';
  SMisDocumentNotFound = 'Не удалось найти документ-направление на '+
  'диагностику с GUID "%s" в БД СМСО';
  SForDiagResultOfOrder = 'Для результатов исследования "%s" заказа "%s" ';
  SCanNotGetRequestGUID = 'Не удалось определить GUID запроса';
  SNoRequestArrayInJSON = 'в JSON отсутствует массив Request';


const
  SLisServerParamNum = 65;
  SAuthAndMisGuidParamNum = 66;



procedure TCmcoSaveDataModule.DataModuleCreate(Sender: TObject);
begin
  inherited;
  UserId := AppOptionsStorage.LoadIntegerValue('Options', 'UserId', 1);
end;

function TCmcoSaveDataModule.FindDiagReport(AReference: TReference):
    TDiagnosticReport;
begin
  Result := nil;
  FBundle.TryFindResourceByFullUrl<TDiagnosticReport>(AReference.Reference, Result);
end;

function TCmcoSaveDataModule.OrderId: string;
begin
  Result := '';
  if (FOrderRespose <> nil) and (FOrderRespose.Identifier.Count > 0) then
    Result := FOrderRespose.Identifier[0].Value;
end;

procedure TCmcoSaveDataModule.SaveBundle(ABundle: TBundle);
begin
  FBundle := ABundle;
  for var vOrderResponce in FBundle.FindResources<TOrderResponse> do
    SaveOrderResponce(vOrderResponce);
  UpdateBundleCmcoRecords();
end;

procedure TCmcoSaveDataModule.SaveCompletedOrder;
begin
  for var vRef in FOrderResponce.Fulfillment do
  begin
    if FBundle.TryFindResourceByFullUrl<TDiagnosticReport>(vRef.Reference, FDiagReport) then
      SaveDiagReportToCmcoAction();
  end;
end;

procedure TCmcoSaveDataModule.SaveDiagReportToCmcoAction;
begin
  var vMetadata := TCmcoDiagReportMetadata.Create;
  try
    if Metadata.TryFillCmcoMetadata(vMetadata) then
      ActionData.SaveDiagReportToCmcoAction(vMetadata);
  finally
    vMetadata.Free;
  end;
end;

procedure TCmcoSaveDataModule.SaveNotCompletedOrder;
begin
  // TODO -cMM: TCmcoSaveDataModule.SaveNotCompletedOrder default body inserted
end;

procedure TCmcoSaveDataModule.SaveOrderResponce(AOrderResponce: TOrderResponse);
var
  vStatus: string;
begin
  FOrderResponce := AOrderResponce;
  if OrderId <> '' then
  begin
    vStatus := FOrderResponce.OrderStatus;
    if AnsiSameText(vStatus, SCompleted) then
      SaveCompletedOrder()
    else
      SaveNotCompletedOrder();
  end
  else
    Logger.Error(SCanNotFindOrderId);
end;

procedure TCmcoSaveDataModule.SetNotCompletedOrderStatus(AOrder:
    TOrderResponse);
begin
  // TODO -cMM: TCmcoSaveDataModule.SetNotCompletedOrderStatus default body inserted
end;

function TCmcoSaveDataModule.StatusTextToCmcoActionStatusValue(AStatus:
    String): Integer;
begin
// Статус выполнения: 0-Начато, 1-Ожидание, 2-Закончено, 3-Отменено, 4-Без результата',
  if AnsiSameText(AStatus, SFinal) then
    Result := 2
  else
  if AnsiSameText(AStatus, SCancelled) then
    Result := 3
  else
  if AnsiSameText(AStatus, SRejected) then
    Result := 4
  else
    raise Exception.Create('Неизвестный статус документа ' +  AStatus);
end;

procedure TCmcoSaveDataModule.UpdateBundleCmcoRecords;
begin
  // TODO -cMM: TCmcoSaveDataModule.UpdateBundleCmcoRecords default body inserted
end;

constructor TCmcoDiagReportMetadata.Create;
begin
  inherited Create;
  FPropTypes := TDictionary<TObservation, TCmcoPropType>.Create();
end;

destructor TCmcoDiagReportMetadata.Destroy;
begin
  for var vPair in FPropTypes do
    vPair.Value.Free;

  FPropTypes.Free;
  inherited Destroy;
end;

procedure TCmcoDiagReportMetadata.SetActionId(const Value: Variant);
begin
  FActionId := Value;
end;

procedure TCmcoDiagReportMetadata.SetActionTypeId(const Value: Variant);
begin
  FActionTypeId := Value;
end;

procedure TCmcoDiagReportMetadata.SetBundle(const Value: TBundle);
begin
  FBundle := Value;
end;

procedure TCmcoDiagReportMetadata.SetDiagReport(const Value: TDiagnosticReport);
begin
  FDiagReport := Value;
end;

procedure TCmcoDiagReportMetadata.SetOrderRespose(const Value: TOrderResponse);
begin
  FOrderRespose := Value;
end;

end.

