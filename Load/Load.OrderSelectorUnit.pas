{*******************************************************
* Project: LisLoader
* Unit: OrderSelectorUnit.pas
* Description: селектор заказов для загрузки
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}

unit Load.OrderSelectorUnit;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  Load.PendingOrdersUnit;

type
  /// <summary>TOrderSelector
  /// класс для выбора заказов, требующих загрузки результатов
  /// </summary>
  TOrderSelector = class(TObject)
  strict private
    /// <summary>TryGetOrdersFromCommandLine
    /// попытаться получить список заказов из командной строки
    /// </summary>
    /// <param name="AOrders"> (TPendingOrders) список для заполнения заказами</param>
    /// <returns>Boolean - True если заказы получены из командной строки, иначе False</returns>
    function TryGetOrdersFromCommandLine(AOrders: TPendingOrders): Boolean;
  public
    /// <summary>SelectPendingOrders
    /// выбрать заказы, ожидающие загрузки
    /// </summary>
    /// <param name="AOrders"> (TPendingOrders) список для заполнения заказами</param>
    procedure SelectPendingOrders(AOrders: TPendingOrders);
  end;

implementation

uses
  Lib.CommandLineParserUnit, System.RegularExpressions,
  Load.CmcoLoadDataModuleUnit;

procedure TOrderSelector.SelectPendingOrders(AOrders: TPendingOrders);
begin
  var vCmcoData := TCmcoLoadDataModule.Create(nil);
  try
    if not TryGetOrdersFromCommandLine(AOrders) then
      vCmcoData.SelectPendingOrders(AOrders);
  finally
    vCmcoData.Free;
  end;
end;

function TOrderSelector.TryGetOrdersFromCommandLine(AOrders: TPendingOrders):
  Boolean;
begin
  var vCount := ParamCount;
  var vVal := ParamStr(1);
  if vCount > 0 then
  begin
    with CommandLineParser do
    begin
      var vOrders := GetParameterValue('ORDERS', '');
      var vMatches := TRegEx.Matches(vOrders, '\d+');
      for var vMatch in vMatches do
      begin
        AOrders.OrderNumbers.Add(vMatch.Value);
      end;
    end;
  end;

  Result := AOrders.OrderNumbers.Count > 0;
end;

end.
