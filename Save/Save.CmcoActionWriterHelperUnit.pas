unit Save.CmcoActionWriterHelperUnit;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  Save.CmcoSaveDataModuleUnit, Load.FHIRModel, System.Generics.Collections,
  Lib.Data.DataSetHelperUnit;

type
  TCmcoActionWriterHelper = class helper for TCmcoSaveDataModule
  private
    procedure CreateObservationCmcoActionProp;
    procedure CreateObservationCmcoPropValue;
    function FindObservationCmcoActionProp: Boolean;
    function FindObservationCmcoPropValue: Boolean;
    function GetDiagReportDate: TDateTime;
    function GetObservationNormText: string;
    procedure MarkCmcoActionClosed(AStatus: TCmcoActionStatus);
    procedure SaveCompletedDiagReportToCmcoAction;
    procedure SaveNotCompletedDiagReportToCmcoAction;
    procedure SaveObservationCmcoPropValue;
    procedure SaveObservationsToCmcoActionProperties;
    procedure SaveObservationToCmcoActionProperty;
    procedure UpdateObservationActionProp;
    procedure UpdateObservationPropValue;
  protected
    procedure SaveDiagReportToCmcoAction;
  end;

implementation

uses
  Save.CmcoActionTypePrepareHelperUnit, AppStringsUnit;

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


procedure TCmcoActionWriterHelper.CreateObservationCmcoActionProp;
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

procedure TCmcoActionWriterHelper.CreateObservationCmcoPropValue;
begin
  // TODO -cMM: TCmcoActionWriterHelper.CreateObservationCmcoPropValue default body inserted
end;

function TCmcoActionWriterHelper.FindObservationCmcoActionProp: Boolean;
begin
  Result := qryActionProperty.Locate('type_id', qryPropType['id'], []);
end;

function TCmcoActionWriterHelper.FindObservationCmcoPropValue: Boolean;
begin
  Result := False;
  // TODO -cMM: TCmcoActionWriterHelper.FindObservationCmcoPropValue default body inserted
end;

function TCmcoActionWriterHelper.GetDiagReportDate: TDateTime;
begin
  if not TryFHIRStrToDateTime(FReport.Issued, Result) then
    Result := ServerDateTime;
end;

function TCmcoActionWriterHelper.GetObservationNormText: string;
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

procedure TCmcoActionWriterHelper.MarkCmcoActionClosed(AStatus:
    TCmcoActionStatus);
begin
  qryAction.EditFieldValues['status'] := Integer(AStatus);
  qryAction.EditFieldValues['endDate'] := GetDiagReportDate();
  qryAction.PostEx;
end;

procedure TCmcoActionWriterHelper.SaveCompletedDiagReportToCmcoAction;
begin
  if PrepareCmcoActionType() then
  begin
    SaveObservationsToCmcoActionProperties();
    MarkCmcoActionClosed(acsCompleted);
    UpdateModifyMarkers(qryAction);
  end;
end;

procedure TCmcoActionWriterHelper.SaveDiagReportToCmcoAction;
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

procedure TCmcoActionWriterHelper.SaveNotCompletedDiagReportToCmcoAction;
begin
  // TODO -cMM: TCmcoActionWriterHelper.SaveNotCompletedDiagReportToCmcoAction default body inserted
end;

procedure TCmcoActionWriterHelper.SaveObservationCmcoPropValue;
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

procedure TCmcoActionWriterHelper.SaveObservationsToCmcoActionProperties;
begin
  for var vRef in FReport.Result do
    if FBundle.TryFindResourceByFullUrl<TObservation>(vRef.Reference, FObservation) then
      SaveObservationToCmcoActionProperty();
end;

procedure TCmcoActionWriterHelper.SaveObservationToCmcoActionProperty;
begin
  if FindObservationCmcoActionProp() then
    UpdateObservationActionProp()
  else
    CreateObservationCmcoActionProp();

  SaveObservationCmcoPropValue();
end;

procedure TCmcoActionWriterHelper.UpdateObservationActionProp;
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

procedure TCmcoActionWriterHelper.UpdateObservationPropValue;
begin
  // TODO -cMM: TCmcoActionWriterHelper.UpdateObservationPropValue default body inserted
end;

end.
