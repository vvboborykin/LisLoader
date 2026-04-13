{*******************************************************
* Project: LisLoader
* Unit: Save.CmcoDiagReportMetadataUnit.pas
* Description: данные для обработки запроса на сохранение в СМСО
*
* Created: 13.04.2026 9:58:11
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Save.CmcoDiagReportMetadataUnit;

interface

uses
  System.Classes, System.Generics.Collections, Load.FHIRModel;

type

  /// <summary>TCmcoPropType
  /// информация о типе свойства СМСО
  /// </summary>
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

  /// <summary>TCmcoDiagReportMetadata
  /// данные для обработки запроса на сохранение в СМСО
  /// </summary>
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

implementation

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
