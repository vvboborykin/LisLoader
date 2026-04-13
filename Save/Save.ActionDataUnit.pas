unit Save.ActionDataUnit;

interface

uses
  System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess, Uni,
  Lib.Data.DataSetHelperUnit, Lib.Data.UniConnectionHelperUnit,
  Save.CmcoSaveDataModuleUnit, Load.FHIRModel, System.StrUtils,
  Save.CmcoDiagReportMetadataUnit;

type
  TActionData = class(TDataModule)
    qryAction: TUniQuery;
    dsAction: TDataSource;
    qryActionProperty: TUniQuery;
    dsActionProperty: TDataSource;
    qryPropValue: TUniQuery;
    dsPropValue: TDataSource;
    procedure DataModuleDestroy(Sender: TObject);
    procedure qryActionBeforePost(DataSet: TDataSet);
  strict private
    FCmcoMetadata: TCmcoDiagReportMetadata;
    FObservation: TObservation;
    FPropType: TCmcoPropType;
    function ServerDateTime: TDateTime;
    function UserId: Variant;
    procedure CreateObservationCmcoActionProp;
    function FindObservationCmcoActionProp: Boolean;
    function GetDiagReportDate: TDateTime;
    function GetObservationNormText: string;
    procedure SetCmcoActionStatus(AStatus: TCmcoActionStatus);
    procedure SaveCompletedDiagReportToCmcoAction;
    procedure SaveNotCompletedDiagReportToCmcoAction;
    procedure SaveObservationCmcoPropValue;
    procedure SaveObservationsToCmcoActionProperties;
    procedure SaveObservationToCmcoActionProperty;
    procedure UpdateObservationActionProp;
  protected
    procedure UpdateModifyMarkers(ADataSet: TDataSet);
  public
    procedure SaveDiagReportToCmcoAction(ACmcoMetadata: TCmcoDiagReportMetadata);
  end;

  function ActionData: TActionData;

implementation

uses
  Lib.ThreadObjectPoolUnit, AppStringsUnit;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

  function ActionData: TActionData;
  begin
    Result := ThreadObjectPool.GetOrCreateComponent<TActionData>();
  end;

procedure TActionData.CreateObservationCmcoActionProp;
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
    FieldValues['type_id'] := FPropType.Id;
    FieldValues['unit_id'] := FPropType.UnitId;
    FieldValues['norm'] := GetObservationNormText();
    FieldValues['isAssigned'] := 0;
    FieldValues['evaluation'] := 0;

    Post;
  end;
end;

procedure TActionData.DataModuleDestroy(Sender: TObject);
begin
  ThreadObjectPool.RemoveObject(Self, False)
end;

function TActionData.FindObservationCmcoActionProp: Boolean;
begin
  Result := qryActionProperty.Locate('type_id', FPropType.Id, []);
end;

function TActionData.GetDiagReportDate: TDateTime;
begin
  if not TryFHIRStrToDateTime(FCmcoMetadata.DiagReport.Issued, Result) then
    Result := ServerDateTime;
end;

function TActionData.GetObservationNormText: string;
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

procedure TActionData.SetCmcoActionStatus(AStatus: TCmcoActionStatus);
begin
  qryAction.EditFieldValues['status'] := Integer(AStatus);
  if not (AStatus in [acsStarted, acsWaiting]) then
    qryAction.EditFieldValues['endDate'] := GetDiagReportDate();
  qryAction.PostEx;
end;

procedure TActionData.qryActionBeforePost(DataSet: TDataSet);
begin
  inherited;
  UpdateModifyMarkers(DataSet);
end;

procedure TActionData.SaveCompletedDiagReportToCmcoAction;
begin
  SaveObservationsToCmcoActionProperties();
  SetCmcoActionStatus(acsCompleted);
  UpdateModifyMarkers(qryAction);
end;

procedure TActionData.SaveDiagReportToCmcoAction(ACmcoMetadata:
    TCmcoDiagReportMetadata);
begin
  FCmcoMetadata := ACmcoMetadata;
  var vStatus := FCmcoMetadata.DiagReport.Status;
  if AnsiSameText(vStatus, SFinal) then
    SaveCompletedDiagReportToCmcoAction()
  else
    SaveNotCompletedDiagReportToCmcoAction();
end;

procedure TActionData.SaveNotCompletedDiagReportToCmcoAction;
begin
  // TODO -cMM: TActionData.SaveNotCompletedDiagReportToCmcoAction default body inserted
end;

procedure TActionData.SaveObservationCmcoPropValue;
var
  vTableName: string;
  vValue: Variant;
begin
  if AnsiSameText(FPropType.TypeName, 'String') then
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

procedure TActionData.SaveObservationsToCmcoActionProperties;
begin
  for var vRef in FCmcoMetadata.DiagReport.Result do
    if FCmcoMetadata.Bundle.TryFindResourceByFullUrl<TObservation>(vRef.Reference, FObservation) then
      SaveObservationToCmcoActionProperty();
end;

procedure TActionData.SaveObservationToCmcoActionProperty;
begin
  FPropType := FCmcoMetadata.PropTypes[FObservation];
  if FindObservationCmcoActionProp() then
    UpdateObservationActionProp()
  else
    CreateObservationCmcoActionProp();
  SaveObservationCmcoPropValue();
end;

function TActionData.ServerDateTime: TDateTime;
begin
  Result := CmcoSaveDataModule.ServerDateTime;
end;

procedure TActionData.UpdateModifyMarkers(ADataSet: TDataSet);

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

procedure TActionData.UpdateObservationActionProp;
begin
  with qryActionProperty do
  begin
    Edit;

    FieldValues['modifyDatetime'] := ServerDateTime;
    FieldValues['modifyPerson_id'] := UserId;
    FieldValues['deleted'] := 0;
    FieldValues['unit_id'] := FPropType.UnitId;
    FieldValues['norm'] := GetObservationNormText();
    FieldValues['isAssigned'] := 0;
    FieldValues['evaluation'] := 0;

    Post;
  end;
end;

function TActionData.UserId: Variant;
begin
  Result := CmcoSaveDataModule.UserId;
  // TODO -cMM: TActionData.UserId default body inserted
end;

end.
