{*******************************************************
* Project: LisLoader
* Unit: Load.PendingOrdersUnit.pas
* Description: параметры запроса списка заказов, ожидающих получения результата
*
* Created: 08.04.2026 15:28:19
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
{*******************************************************
* Project: LisLoader
* Unit: Load.PendingOrdersUnit.pas
* Description: параметры запроса списка заказов, ожидающих получения результата
*
* Created: 08.04.2026 15:27:29
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Load.PendingOrdersUnit;

interface

uses
  System.Classes;

type
  /// <summary>TPendingOrders
  /// параметры запроса списка заказов, ожидающих получения результата
  /// </summary>
  TPendingOrders = class(TObject)
  strict private
    FDays: Integer;
    FLimit: Integer;
    FOrderNumbers: TStringList;
    procedure SetDays(const Value: Integer);
    procedure SetLimit(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>TPendingOrders.Dasys количество дней, за которое нужно выполнить поиск
    /// </summary>
    /// <param name="Value"> (Integer) </param>
    property Days: Integer read FDays write SetDays;
    /// <summary>TPendingOrders.Limit
    /// ограничение на количество получаемых результатов / заказов
    /// </summary>
    /// type:Integer
    property Limit: Integer read FLimit write SetLimit;
    /// <summary>TPendingOrders.OrderNumbers
    /// список номеров заказов, ожидающих результатов
    /// </summary>
    /// type:TStringList
    property OrderNumbers: TStringList read FOrderNumbers;
  end;

implementation

constructor TPendingOrders.Create;
begin
  inherited Create;
  FOrderNumbers := TStringList.Create();
  FDays := 7;
  FLimit := 1000;
end;

destructor TPendingOrders.Destroy;
begin
  FOrderNumbers.Free;
  inherited Destroy;
end;

procedure TPendingOrders.SetDays(const Value: Integer);
begin
  if Value > 0 then
  begin
    FDays := Value;
  end;
end;

procedure TPendingOrders.SetLimit(const Value: Integer);
begin
  if Value > 0 then
  begin
    FLimit := Value;
  end;
end;

end.
