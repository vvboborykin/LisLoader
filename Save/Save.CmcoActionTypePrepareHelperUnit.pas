unit Save.CmcoActionTypePrepareHelperUnit;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  Load.FHIRModel, Save.CmcoSaveDataModuleUnit, Lib.Logger.LoggerUnit;

type
  TCmcoActionTypePrepareHelper = class helper for TCmcoSaveDataModule
  strict private
    procedure CreateObservationCmcoPropType;
    function GetObservationTestId: Variant;
    function GetObservationUnitId: Variant;
    function FindDiagReportCmcoActionType: Boolean;
    function FindObservationCmcoPropType(ATestId: Variant): Boolean;
    function PrepareCmcoActionPropertyTypes: Boolean;
    function PrepareObservationCmcoPropertyType: Boolean;
    procedure UpdateObservationPropType;
  protected
    function PrepareCmcoActionType: Boolean;
  end;

implementation

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


procedure TCmcoActionTypePrepareHelper.CreateObservationCmcoPropType;
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
    FieldValues['template_id'] := null;
    FieldValues['name'] := vName;
    FieldValues['shortName'] := '';
    FieldValues['descr'] := vTestCode;
    FieldValues['unit_id'] := vUnitId;
    FieldValues['typeName'] := vTypeName;
    FieldValues['valueDomain'] := '';
    FieldValues['defaultValue'] := null;
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
    FieldValues['laboratoryCalculator'] := null;
    FieldValues['inActionsSelectionTable'] := 0;
    FieldValues['redactorSizeFactor'] := 0;
    FieldValues['isFrozen'] := 0;
    FieldValues['typeEditable'] := 1;
    FieldValues['visibleInDR'] := 0;
    FieldValues['userProfile_id'] := null;
    FieldValues['userProfileBehaviour'] := 0;
    FieldValues['isRequired'] := 0;
    FieldValues['isNorm'] := 0;

    Post;
  end;
end;

function TCmcoActionTypePrepareHelper.FindDiagReportCmcoActionType: Boolean;
begin
  qryActionType.ReopenWithParams(['ActionTypeId', qryAction['actionType_id']]);
  Result := not qryActionType.IsEmpty;
end;

function TCmcoActionTypePrepareHelper.FindObservationCmcoPropType(ATestId:
    Variant): Boolean;
begin
  Result := qryPropType.Locate('test_id', ATestId, []);
end;

function TCmcoActionTypePrepareHelper.GetObservationTestId: Variant;
begin
  Result := null;
  var vCode := FObservation.CodeCoding.Code;
  qryTest.ReopenWithParams(['Code', vCode]);
  if not qryTest.IsEmpty then
    Result := qryTest['id']
  else
    Logger.Error(STestNotFound, [vCode]);
end;

function TCmcoActionTypePrepareHelper.GetObservationUnitId: Variant;

  function GetRangeBoundUnit(ABound: TRangeBound): Variant;
  begin
    Result := null;
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
      if (Result = null) and (vRefRange.High <> nil) then
        Result := GetRangeBoundUnit(vRefRange.High);
      if Result <> null then
        Break;
    end;
  end;
end;

function TCmcoActionTypePrepareHelper.PrepareCmcoActionPropertyTypes: Boolean;
var
  vObservation: TObservation;
begin
  Result := True;
  for var vRef in FReport.Result do
  begin
    if FBundle.TryFindResourceByFullUrl<TObservation>(vRef.Reference, FObservation) then
    begin
      Result := Result and PrepareObservationCmcoPropertyType();
      if not Result then
        Break;
    end;
  end;
end;

function TCmcoActionTypePrepareHelper.PrepareCmcoActionType: Boolean;
begin
  Result := False;
  if not qryAction.IsEmpty then
  begin
    if FindDiagReportCmcoActionType() then
      Result := PrepareCmcoActionPropertyTypes()
    else
      Logger.Error(SCmcoActionTypeNotFound, [qryAction['id']]);
  end
  else
    Logger.Error(SActionNotFound, [qryAction['id']])
end;

function TCmcoActionTypePrepareHelper.PrepareObservationCmcoPropertyType:
    Boolean;
begin
  Result := False;
  var vTestId := GetObservationTestId();

  if vTestId <> null then
  begin
    if not FindObservationCmcoPropType(vTestId) then
      CreateObservationCmcoPropType()
    else
      UpdateObservationPropType;
  end
  else
    Logger.Error(SRbTestNotFound, [FObservation.CodeCoding.Code])
end;

procedure TCmcoActionTypePrepareHelper.UpdateObservationPropType;
begin

end;

end.
