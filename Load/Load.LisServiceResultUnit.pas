{*******************************************************
* Project: LisLoader
* Unit: Load.LisServiceResultUnit.pas
* Description: результат выполнения запроса к ЛИС
*
* Created: 08.04.2026 15:26:10
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Load.LisServiceResultUnit;

interface

type
  /// <summary>TLisServiceResult
  /// результат выполнения запроса к ЛИС
  /// </summary>
  TLisServiceResult = record
    /// <summary>JSON
    /// данные ответа в формате JSON
    /// </summary>
    JSON: String;
    /// <summary>Error
    /// текст ошибки, если запрос не выполнен
    /// </summary>
    Error: String;
  end;

implementation

end.
