{*******************************************************
* Project: LisLoader
* Unit: ResponceProcessorUnit.pas
* Description: сервис обработки полученного ответа ЛИС
*
* Created: 24.03.2026 10:41:50
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Save.ResponceProcessorUnit;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils, Load.FHIRModel,
  Load.RESTClientModuleUnit, Lib.Logger.LoggerUnit, Load.LisServiceResultUnit,
  Save.CmcoSaveDataModuleUnit,  System.Generics.Collections;

type

  /// <summary>TResponceProcessor
  /// сервис обработки полученного ответа ЛИС
  /// </summary>
  TResponceProcessor = class
  strict private
    FBundle: TBundle;
    FCmco: TCmcoSaveDataModule;
    FLisResponce: TLisServiceResult;
    procedure ProcessOrder;
    procedure ProcessBundle;
    function ResponceIsOrder: Boolean;
    function ResponceIsBundle: Boolean;
    function ResourceTypeIs(ATypeName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>TResponceProcessor.ProcessResponce
    /// обработать ответ ЛИС
    /// </summary>
    /// <param name="ALisResponce"> (TLisServiceResult) </param>
    procedure ProcessResponce(ALisResponce: TLisServiceResult); virtual;
  end;

implementation

uses
  System.JSON, AppStringsUnit;



constructor TResponceProcessor.Create;
begin
  inherited Create;
  FCmco := TCmcoSaveDataModule.Create(nil);
  FCmco.conMain.Open;
end;

destructor TResponceProcessor.Destroy;
begin
  FCmco.Free;
  inherited Destroy;
end;

procedure TResponceProcessor.ProcessOrder;
var
  vObj: TJSONObject;
  vValue: string;
begin
  vObj := TJSONObject.Create;
  try
    vObj.ParseJSONValue(FLisResponce.JSON);
    if vObj.TryGetValue<string>(SOrderStatus, vValue) then
    begin
//TODO: process order
    end;
  finally
    vObj.Free;
  end;
end;

procedure TResponceProcessor.ProcessBundle;
begin
  FBundle := TJSONToModelConverter.ParseBundle(FLisResponce.JSON);
  try
    FCmco.SaveBundle(FBundle);
  finally
    FBundle.Free;
  end;
end;

procedure TResponceProcessor.ProcessResponce(ALisResponce: TLisServiceResult);
begin
  FLisResponce := ALisResponce;
  if ResponceIsBundle() then
    ProcessBundle()
  else if ResponceIsOrder() then
    ProcessOrder();
end;

function TResponceProcessor.ResourceTypeIs(ATypeName: string): Boolean;
var
  vObj: TJSONObject;
  vValue: string;
begin
  vObj := vObj.ParseJSONValue(FLisResponce.JSON) as TJSONObject;
  try
    Result := vObj.TryGetValue<string>(SResourceType, vValue) and AnsiSameText(vValue,
      ATypeName);
  finally
    vObj.Free;
  end;
end;

function TResponceProcessor.ResponceIsOrder: Boolean;
begin
  Result := ResourceTypeIs(SOrder);
end;

function TResponceProcessor.ResponceIsBundle: Boolean;
begin
  Result := ResourceTypeIs(SBundle);
end;

end.

