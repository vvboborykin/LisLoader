unit Save.MetadataUnit;

interface

uses
  System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Uni,
  System.StrUtils, Load.FHIRModel, System.Variants, Lib.Data.DataSetHelperUnit,
  Lib.Logger.LoggerUnit, Lib.Data.UniConnectionHelperUnit,
  Save.CmcoSaveDataModuleUnit, System.Generics.Collections,
  Save.CmcoDiagReportMetadataUnit;

type
  TMetadata = class(TDataModule)
    qryActionType: TUniQuery;
    dsActionType: TDataSource;
    qryPropType: TUniQuery;
    dsPropType: TDataSource;
    qryUnit: TUniQuery;
    dsUnit: TDataSource;
    qryTest: TUniQuery;
    dsTest: TDataSource;
    qryActionLis: TUniQuery;
    dsActionLis: TDataSource;
    qryAction: TUniQuery;
    dsAction: TDataSource;
    procedure DataModuleDestroy(Sender: TObject);
  strict private
    FCmcoMetadata: TCmcoDiagReportMetadata;
    FObservation: TObservation;
    procedure AppendObservationMetadata;
    function conMain: TUniConnection;
    procedure CreateObservationCmcoPropType;
    function FindDiagReportCmcoActionType: Boolean;
    function FindObservationCmcoPropType(ATestId: Variant): Boolean;
    function GetActionTypeId: Variant;
    function GetObservationTestId: Variant;
    function GetObservationUnitId: Variant;
    function PrepareCmcoActionPropertyTypes: Boolean;
    function PrepareObservationCmcoPropertyType: Boolean;
    procedure UpdateObservationPropType;
    function FindDiagReportCmcoAction: Boolean;
    function GetDiagReportRequestReference: string;
    function OrderId: string;
  public
    function TryFillCmcoMetadata(ACmcoMetadata: TCmcoDiagReportMetadata): Boolean;
  end;

  function Metadata: TMetadata;

implementation

uses
  Lib.ThreadObjectPoolUnit;

{%CLASSGROUP 'System.Classes.TPersistent'}

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


{$R *.dfm}

  function Metadata: TMetadata;
  begin
    Result := ThreadObjectPool.GetOrCreateComponent<TMetadata>();
  end;

procedure TMetadata.AppendObservationMetadata;
begin
  var vProp := TCmcoPropType.Create;
  vProp.Id := qryPropType['id'];
  vProp.TypeName := qryPropType['typeName'];
  vProp.UnitId := qryPropType['unit_id'];
  FCmcoMetadata.PropTypes.Add(FObservation, vProp);
end;

function TMetadata.conMain: TUniConnection;
begin
  Result := qryActionType.Connection;
end;

procedure TMetadata.DataModuleDestroy(Sender: TObject);
begin
  ThreadObjectPool.RemoveObject(Self, False);
end;

procedure TMetadata.CreateObservationCmcoPropType;
var
  vActionTypeId: Integer;
  vName: string;
  vNextIdx: Integer;
  vTestCode: string;
  vTestId: variant;
  vTypeName: string;
  vUnitId: Variant;
begin
  vActionTypeId := qryActionType['id'];
  vName := qryTest['name'];
  vTestCode := qryTest['code'];
  vTestId := qryTest['id'];
  vTypeName := IfThen(FObservation.Value.ValueQuantity = nil, 'String', 'Double');
  vUnitId := GetObservationUnitId();

  vNextIdx := conMain.SelectScalar('SELECT MAX(apt.idx) ' +
    'FROM ActionPropertyType apt ' +
    'WHERE apt.deleted = 0 AND apt.actionType_id = :ActTypeId',
    [vActionTypeId]);

  if vNextIdx = Null then
    vNextIdx := 0;

  vNextIdx := vNextIdx + 1;

  with qryPropType do
  begin
    Append;

    FieldValues['deleted'] := 0;
    FieldValues['actionType_id'] := vActionTypeId;
    FieldValues['idx'] := vNextIdx;
    FieldValues['template_id'] := Null;
    FieldValues['name'] := vName;
    FieldValues['shortName'] := '';
    FieldValues['descr'] := vTestCode;
    FieldValues['unit_id'] := vUnitId;
    FieldValues['typeName'] := vTypeName;
    FieldValues['valueDomain'] := '';
    FieldValues['defaultValue'] := Null;
    FieldValues['isVector'] := 0;
    FieldValues['norm'] := '';
    FieldValues['sex'] := 0;
    FieldValues['age'] := '';
    FieldValues['penalty'] := 0;
    FieldValues['visibleInJobTicket'] := 0;
    FieldValues['visibleInTableRedactor'] := 0;
    FieldValues['isAssignable'] := 0;
    FieldValues['test_id'] := vTestId;
    FieldValues['defaultEvaluation'] := 3;
    FieldValues['canChangeOnlyOwner'] := 2;
    FieldValues['isActionNameSpecifier'] := 0;
    FieldValues['laboratoryCalculator'] := Null;
    FieldValues['inActionsSelectionTable'] := 0;
    FieldValues['redactorSizeFactor'] := 0;
    FieldValues['isFrozen'] := 0;
    FieldValues['typeEditable'] := 1;
    FieldValues['visibleInDR'] := 0;
    FieldValues['userProfile_id'] := Null;
    FieldValues['userProfileBehaviour'] := 0;
    FieldValues['isRequired'] := 0;
    FieldValues['isNorm'] := 0;

    Post;
  end;
end;

function TMetadata.FindDiagReportCmcoAction: Boolean;
begin
  var vRequestGuid := GetDiagReportRequestReference;
  qryActionLis.ReopenWithParams(['RequestUid', vRequestGuid, 'OrderId', OrderId]);
  if not qryActionLis.IsEmpty then
  begin
    FCmcoMetadata.ActionId := qryActionLis['action_id'];
    qryAction.ReopenWithParams(['ActionId', FCmcoMetadata.ActionId]);
    FCmcoMetadata.ActionTypeId := qryAction['actionType_id'];
  end
  else
  begin
    FCmcoMetadata.ActionId := Null;
    FCmcoMetadata.ActionTypeId := Null;
  end;
  Result := FCmcoMetadata.ActionId <> Null;
  if not Result then
    Logger.Error(SActionNotFound, [vRequestGuid]);
end;

function TMetadata.FindDiagReportCmcoActionType: Boolean;
begin
  qryActionType.ReopenWithParams(['ActionTypeId', FCmcoMetadata.ActionTypeId]);
  Result := not qryActionType.IsEmpty;
end;

function TMetadata.FindObservationCmcoPropType(ATestId: Variant): Boolean;
begin
  Result := qryPropType.Locate('test_id', ATestId, []);
end;


function TMetadata.GetActionTypeId: Variant;
begin
  Result := conMain.SelectScalar('SELECT actionType_id FROM Action WHERE id = :Id LIMIT 1',
    [FCmcoMetadata.ActionId]);
end;

function TMetadata.GetDiagReportRequestReference: string;
var
  vRequest: TList<TReference>;
begin
  Result := '';
  vRequest := FCmcoMetadata.DiagReport.Request;
  if vRequest.Count > 0 then
  begin
    Result := vRequest[0].Reference;
    Result := Result.Substring(Result.IndexOf('/') + 1);
  end
end;

function TMetadata.GetObservationTestId: Variant;
begin
  Result := Null;
  var vCode := FObservation.CodeCoding.Code;
  qryTest.ReopenWithParams(['Code', vCode]);
  if not qryTest.IsEmpty then
    Result := qryTest['id']
  else
    Logger.Error(STestNotFound, [vCode]);
end;

function TMetadata.GetObservationUnitId: Variant;

  function GetRangeBoundUnit(ABound: TRangeBound): Variant;
  begin
    Result := Null;
    if ABound.Code <> '' then
    begin
      qryUnit.ReopenWithParams(['Code', ABound.Code]);
      if not qryUnit.IsEmpty then
        Result := qryUnit['id'];
    end;
  end;

begin
  Result := Null;
  if (FObservation <> nil) and (FObservation.ReferenceRange <> nil) then
  begin
    for var vRefRange in FObservation.ReferenceRange do
    begin
      if vRefRange.Low <> nil then
        Result := GetRangeBoundUnit(vRefRange.Low);
      if (Result = Null) and (vRefRange.High <> nil) then
        Result := GetRangeBoundUnit(vRefRange.High);
      if Result <> Null then
        Break;
    end;
  end;
end;

function TMetadata.OrderId: string;
begin
  Result := '';
  if (FCmcoMetadata.OrderRespose <> nil)
    and (FCmcoMetadata.OrderRespose.Identifier.Count > 0) then
      Result := FCmcoMetadata.OrderRespose.Identifier[0].Value;
end;

function TMetadata.PrepareCmcoActionPropertyTypes: Boolean;
begin
  Result := True;
  for var vRef in FCmcoMetadata.DiagReport.Result do
  begin
    if FCmcoMetadata.Bundle.TryFindResourceByFullUrl<TObservation>(vRef.Reference, FObservation) then
    begin
      Result := Result and PrepareObservationCmcoPropertyType();
      if not Result then
        Break;
    end;
  end;
end;

function TMetadata.TryFillCmcoMetadata(ACmcoMetadata: TCmcoDiagReportMetadata):
    Boolean;
begin
  Result := False;
  FCmcoMetadata := ACmcoMetadata;
  if FindDiagReportCmcoAction() then
  begin
    if FindDiagReportCmcoActionType() then
      Result := PrepareCmcoActionPropertyTypes()
    else
      Logger.Error(SCmcoActionTypeNotFound, [FCmcoMetadata.ActionId.ToString]);
  end;
end;

function TMetadata.PrepareObservationCmcoPropertyType: Boolean;
begin
  Result := False;
  var vTestId := GetObservationTestId();
  if vTestId <> null then
  begin
    if not FindObservationCmcoPropType(vTestId) then
      CreateObservationCmcoPropType()
    else
      UpdateObservationPropType;
    AppendObservationMetadata();
    Result := True;
  end
  else
    Logger.Error(SRbTestNotFound, [FObservation.CodeCoding.Code])
end;

procedure TMetadata.UpdateObservationPropType;
begin

end;

end.
