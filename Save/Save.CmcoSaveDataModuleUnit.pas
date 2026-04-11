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



  /// <summary>TCmcoDataModule
  /// модуль данных для взаимодействия с базой данных СМСО
  /// </summary>
  TCmcoSaveDataModule = class(TBaseCmcoDataModule)
    qryActionLis: TUniQuery;
    dsActionLis: TDataSource;
    qryAction: TUniQuery;
    dsAction: TDataSource;
    qryActionType: TUniQuery;
    dsActionType: TDataSource;
    qryPropType: TUniQuery;
    dsPropType: TDataSource;
    qryUnit: TUniQuery;
    dsUnit: TDataSource;
    qryTest: TUniQuery;
    dsTest: TDataSource;
    qryActionProperty: TUniQuery;
    dsActionProperty: TDataSource;
    qryPropValue: TUniQuery;
    dsPropValue: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure qryActionBeforePost(DataSet: TDataSet);
  private
    procedure CreateObservationCmcoActionProp;
    procedure CreateObservationCmcoPropValue;
    function FindDiagReport(AReference: TReference): TDiagnosticReport;
    function FindDiagReportAction: Boolean;
    function FindObservationCmcoActionProp: Boolean;
    function FindObservationCmcoPropValue: Boolean;
    function GetDiagReportDate: TDateTime;
    function GetDiagReportRequestReference: string;
    procedure SaveCompletedDiagReportToCmcoAction;
    function StatusTextToCmcoActionStatusValue(AStatus: String): Integer;
    function GetMisDocumentId(AOrderId, ARequestGuid: String): Variant;
    function GetObservationNormText: string;
    procedure MarkCmcoActionClosed(AStatus: TCmcoActionStatus);
    function OrderId: string;
    procedure SaveCompletedOrder;
    procedure SaveDiagReportToCmcoAction;
    procedure SaveNotCompletedDiagReportToCmcoAction;
    procedure SaveNotCompletedOrder;
    procedure SaveObservationCmcoPropValue;
    procedure SaveObservationsToCmcoActionProperties;
    procedure SaveObservationToCmcoActionProperty;
    procedure SaveOrderResponce(AOrderResponce: TOrderResponse);
    procedure SetNotCompletedOrderStatus(AOrder: TOrderResponse);
    procedure UpdateBundleCmcoRecords;
    procedure UpdateModifyMarkers(ADataSet: TDataSet);
    procedure UpdateObservationActionProp;
    procedure UpdateObservationPropValue;
  protected
    FActionId: Variant;
    FBundle: TBundle;
    FObservation: TObservation;
    FOrderResponce: TOrderResponse;
    FReport: TDiagnosticReport;
  public
    procedure SaveBundle(ABundle: TBundle);
  end;

implementation

uses
  AppStringsUnit, Lib.Options.OptionsStorageUnit,
  Save.CmcoActionTypePrepareHelperUnit;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

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



procedure TCmcoSaveDataModule.CreateObservationCmcoActionProp;
begin
  with qryActionProperty do
  begin
    Append;

    FieldValues['createDatetime'] := ServerDateTime;
    FieldValues['createPerson_id'] := UserId;
    FieldValues['modifyDatetime'] := ServerDateTime;
    FieldValues['modifyPerson_id'] := UserId;
    FieldValues['deleted'] := 0;
    FieldValues['action_id'] := qryAction['id'];
    FieldValues['type_id'] := qryActionType['id'];
    FieldValues['unit_id'] := qryActionType['unit_id'];
    FieldValues['norm'] := GetObservationNormText();
    FieldValues['isAssigned'] := 0;
    FieldValues['evaluation'] := 0;

    Post;
  end;
end;

procedure TCmcoSaveDataModule.CreateObservationCmcoPropValue;
begin
  // TODO -cMM: TCmcoSaveDataModule.CreateObservationCmcoPropValue default body inserted
end;

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

function TCmcoSaveDataModule.FindDiagReportAction: Boolean;
begin
  var vRequestGuid := GetDiagReportRequestReference;
  qryActionLis.ReopenWithParams(['RequestUid', vRequestGuid, 'OrderId', OrderId]);
  qryAction.ReopenWithParams(['ActionId', qryActionLis['action_id']]);
  Result := not qryAction.IsEmpty;
end;

function TCmcoSaveDataModule.FindObservationCmcoActionProp: Boolean;
begin
  Result := qryActionProperty.Locate('type_id', qryPropType['id'], []);
end;

function TCmcoSaveDataModule.FindObservationCmcoPropValue: Boolean;
begin
  Result := False;
  // TODO -cMM: TCmcoSaveDataModule.FindObservationCmcoPropValue default body inserted
end;

function TCmcoSaveDataModule.GetDiagReportDate: TDateTime;
begin
  if not TryFHIRStrToDateTime(FReport.Issued, Result) then
    Result := ServerDateTime;
end;

function TCmcoSaveDataModule.GetDiagReportRequestReference: string;
var
  vRequest: TList<TReference>;
begin
  Result := '';
  vRequest := FReport.Request;
  if vRequest.Count > 0 then
  begin
    Result := vRequest[0].Reference;
    Result := Result.Substring(Result.IndexOf('/') + 1);
  end
end;

function TCmcoSaveDataModule.GetMisDocumentId(AOrderId, ARequestGuid: String):
    Variant;
begin
  with qryActionLis do
  begin
    ReopenWithParams(['OrderId', AOrderId, 'RequestUid', ARequestGuid]);
    Result := Null;
    if not IsEmpty then
      Result := FieldValues['action_id'];
    Close;
  end;
end;

function TCmcoSaveDataModule.GetObservationNormText: string;
begin
  Result := '';
  if (FObservation <> nil) then
  begin
    for var vRefRange in FObservation.ReferenceRange do
    begin
      if vRefRange.Text <> '' then
        Result := vRefRange.Text
      else
      begin
        if vRefRange.Low <> nil then
          Result := vRefRange.Low.Value.ToString();
        if vRefRange.High <> nil then
          Result := Result + IfThen(Result = '', '0', ' - ') +
            vRefRange.High.Value.ToString();
      end;
    end;
  end;
end;

procedure TCmcoSaveDataModule.MarkCmcoActionClosed(AStatus: TCmcoActionStatus);
begin
  qryAction.EditFieldValues['status'] := Integer(AStatus);
  qryAction.EditFieldValues['endDate'] := GetDiagReportDate();
  qryAction.PostEx;
end;

function TCmcoSaveDataModule.OrderId: string;
begin
  Result := '';
  if (FOrderResponce <> nil) and (FOrderResponce.Identifier.Count > 0) then
    Result := FOrderResponce.Identifier[0].Value;
end;

procedure TCmcoSaveDataModule.qryActionBeforePost(DataSet: TDataSet);
begin
  inherited;
  UpdateModifyMarkers(DataSet);
end;

procedure TCmcoSaveDataModule.SaveBundle(ABundle: TBundle);
begin
  FBundle := ABundle;
  for var vOrderResponce in FBundle.FindResources<TOrderResponse> do
    SaveOrderResponce(vOrderResponce);
  UpdateBundleCmcoRecords();
end;

procedure TCmcoSaveDataModule.SaveCompletedDiagReportToCmcoAction;
begin
  if PrepareCmcoActionType() then
  begin
    SaveObservationsToCmcoActionProperties();
    MarkCmcoActionClosed(acsCompleted);
    UpdateModifyMarkers(qryAction);
  end;
end;

procedure TCmcoSaveDataModule.SaveCompletedOrder;
begin
  for var vRef in FOrderResponce.Fulfillment do
  begin
    if FBundle.TryFindResourceByFullUrl<TDiagnosticReport>(vRef.Reference, FReport) then
      SaveDiagReportToCmcoAction();
  end;
end;

procedure TCmcoSaveDataModule.SaveDiagReportToCmcoAction;
begin
  if FindDiagReportAction() then
  begin
    var vStatus := FReport.Status;
    if AnsiSameText(vStatus, SFinal) then
      SaveCompletedDiagReportToCmcoAction()
    else
      SaveNotCompletedDiagReportToCmcoAction();
  end;
end;

procedure TCmcoSaveDataModule.SaveNotCompletedDiagReportToCmcoAction;
begin
  // TODO -cMM: TCmcoSaveDataModule.SaveNotCompletedDiagReportToCmcoAction default body inserted
end;

procedure TCmcoSaveDataModule.SaveNotCompletedOrder;
begin
  // TODO -cMM: TCmcoSaveDataModule.SaveNotCompletedOrder default body inserted
end;

procedure TCmcoSaveDataModule.SaveObservationCmcoPropValue;
var
  vTableName: string;
  vValue: Variant;
begin
  if AnsiSameText(qryPropType['typeName'], 'String') then
    vTableName := 'ActionProperty_String'
  else
    vTableName := 'ActionProperty_Double';


  if FObservation.Value.ValueQuantity <> nil then
    vValue := FObservation.Value.ValueQuantity.Value
  else
    vValue := FObservation.Value.ValueString;

  with qryPropValue do
  begin
    ReopenWithParams([], ['TableName', vTableName]);
    if IsEmpty then
    begin
      Append;
      FieldValues['index'] := 0;
      FieldValues['id'] := qryActionProperty['id'];
      FieldValues['value'] := vValue;
    end
    else
      EditFieldValues['value'] := vValue;

    PostEx;
  end;
end;

procedure TCmcoSaveDataModule.SaveObservationsToCmcoActionProperties;
begin
  for var vRef in FReport.Result do
    if FBundle.TryFindResourceByFullUrl<TObservation>(vRef.Reference, FObservation) then
      SaveObservationToCmcoActionProperty();
end;

procedure TCmcoSaveDataModule.SaveObservationToCmcoActionProperty;
begin
  if FindObservationCmcoActionProp() then
    UpdateObservationActionProp()
  else
    CreateObservationCmcoActionProp();

  SaveObservationCmcoPropValue();
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

procedure TCmcoSaveDataModule.UpdateModifyMarkers(ADataSet: TDataSet);

  Procedure UpdateField(AFieldName: String; AValue: Variant);
  begin
    var vField := ADataSet.FindField(AFieldName);
    if vField <> nil then
      ADataSet.EditFieldValues[AFieldName] := AValue;
  end;

begin
  UpdateField('modifyUser_id', UserId);
  UpdateField('modifyDateTime', ServerDateTime);
end;

procedure TCmcoSaveDataModule.UpdateObservationActionProp;
begin
  with qryActionProperty do
  begin
    Edit;

    FieldValues['modifyDatetime'] := ServerDateTime;
    FieldValues['modifyPerson_id'] := UserId;
    FieldValues['deleted'] := 0;
    FieldValues['unit_id'] := qryActionType['unit_id'];
    FieldValues['norm'] := GetObservationNormText();
    FieldValues['isAssigned'] := 0;
    FieldValues['evaluation'] := 0;

    Post;
  end;
end;

procedure TCmcoSaveDataModule.UpdateObservationPropValue;
begin
  // TODO -cMM: TCmcoSaveDataModule.UpdateObservationPropValue default body inserted
end;

end.

