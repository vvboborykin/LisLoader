{*******************************************************
* Project: LisLoader
* Unit: CmcoDataModuleUnit.pas
* Description: модуль данных для загрузки данных из базы СМСО
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}

unit Load.CmcoLoadDataModuleUnit;

interface

uses
  System.SysUtils, System.Classes, Lib.Cmco.BaseCmcoDataModuleUnit, UniProvider,
  MySQLUniProvider, Data.DB, DBAccess, Uni, MemDS,
  Lib.Data.DataSetHelperUnit, Lib.Data.UniConnectionHelperUnit, System.Variants,
  Load.FHIRModel, Load.PendingOrdersUnit, Load.RESTParamsUnit, Lib.Logger.LoggerUnit;

type
  /// <summary>TCmcoDataModule
  /// модуль данных для загрузки данных из базы СМСО
  /// </summary>
  TCmcoLoadDataModule = class(TBaseCmcoDataModule)
    qryPendingOrders: TUniQuery;
    dsPendingOrders: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  protected
    /// <summary>GetCmcoGlobalOption
    /// получить значение глобальной настройки СМСО
    /// </summary>
    /// <param name="AOptionId"> (Integer) идентификатор настройки</param>
    /// <returns>string - значение настройки</returns>
    function GetCmcoGlobalOption(const AOptionId: Integer): string;
    /// <summary>GetAuthGuid
    /// получить GUID авторизации для доступа к ЛИС
    /// </summary>
    /// <returns>string - GUID авторизации</returns>
    function GetAuthGuid: string;
    /// <summary>GetMisGuid
    /// получить GUID МИС для идентификации источника данных
    /// </summary>
    /// <returns>string - GUID МИС</returns>
    function GetMisGuid: string;
    /// <summary>GetLisServerBase
    /// получить базовый URL сервера ЛИС
    /// </summary>
    /// <returns>string - базовый URL ЛИС</returns>
    function GetLisServerBase: string;
  public
    /// <summary>GetRestParams
    /// получить параметры REST запроса для загрузки данных по заказу
    /// </summary>
    /// <param name="AOrderId"> (string) идентификатор заказа</param>
    /// <returns>TRESTParams - параметры REST запроса</returns>
    function GetRestParams: TRESTParams;
    /// <summary>SelectPendingOrders
    /// выбрать заказы, ожидающие загрузки результатов
    /// </summary>
    /// <param name="AOrders"> (TPendingOrders) список для заполнения заказами</param>
    procedure SelectPendingOrders(AOrders: TPendingOrders);
  end;

implementation

uses
  AppStringsUnit, Lib.Options.OptionsStorageUnit;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

const
  SLisServerParamNum = 65;
  SAuthAndMisGuidParamNum = 66;

procedure TCmcoLoadDataModule.DataModuleCreate(Sender: TObject);
begin
  inherited;
  UserId := AppOptionsStorage.LoadIntegerValue('Options', 'UserId', 1);
end;

function TCmcoLoadDataModule.GetAuthGuid: string;
begin
  Result := GetCmcoGlobalOption(SAuthAndMisGuidParamNum);
  Result := Result.Split([';'])[1];
end;

function TCmcoLoadDataModule.GetMisGuid: string;
begin
  Result := GetCmcoGlobalOption(SAuthAndMisGuidParamNum);
  Result := Result.Split([';'])[0];
end;

function TCmcoLoadDataModule.GetLisServerBase: string;
begin
  Result := GetCmcoGlobalOption(SLisServerParamNum);
  Result := Result.Split([';'])[0];
end;

function TCmcoLoadDataModule.GetCmcoGlobalOption(const AOptionId: Integer): string;
begin
  var vSqlText := 'SELECT value FROM GlobalPreferences ' +
    'WHERE code = :Code LIMIT 1';
  Result := VarToStr(conMain.SelectScalar(vSqlText, [AOptionId]));
end;

function TCmcoLoadDataModule.GetRestParams: TRESTParams;
begin
  conMain.Open;
  Result.AuthGuid := GetAuthGuid;
  Result.LisServerBase := GetLisServerBase;
  Result.MisGuid := GetMisGuid;
end;

procedure TCmcoLoadDataModule.SelectPendingOrders(AOrders: TPendingOrders);
begin
  conMain.Open;
  with qryPendingOrders do
  begin
    Close;
    MacroByName('Limit').Value := AOrders.Limit.ToString;
    MacroByName('Days').Value := AOrders.Days.ToString;
    Open;

    ForEachRecord(
      procedure
      begin
        AOrders.OrderNumbers.Add(FieldValues['externalId'])
      end);

    Close;
  end;
end;

end.
