{*******************************************************
* Project: LisLoader
* Unit: Load.RESTParamsUnit.pas
* Description: параметры для выполнения REST запросов к ЛИС
*
* Created: 08.04.2026 15:29:06
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Load.RESTParamsUnit;

interface

type
  /// <summary>TRESTParams
  /// параметры для выполнения REST запросов к ЛИС
  /// </summary>
  TRESTParams = record
    /// <summary>AuthGuid
    /// GUID авторизации для доступа к ЛИС
    /// </summary>
    AuthGuid: string;
    /// <summary>LisServerBase
    /// базовый URL сервера ЛИС
    /// </summary>
    LisServerBase: string;
    /// <summary>MisGuid
    /// GUID МИС для идентификации источника/приемника данных
    /// </summary>
    MisGuid: string;
  end;

implementation

end.
