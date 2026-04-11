{*******************************************************
* Project: LisLoader
* Unit: Load.LoadOptionsUnit.pas
* Description: параметры загрузки данных из ЛИС
*
* Created: 08.04.2026 15:25:52
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Load.LoadOptionsUnit;

interface

type
  /// <summary>TLoadOptions
  /// параметры загрузки данных из ЛИС
  /// </summary>
  TLoadOptions = record
    /// <summary>MaxThreadCount
    /// максимальное количество параллельных потоков загрузки
    /// </summary>
    MaxThreadCount: Integer;
    /// <summary>ThreadCreateDelay
    /// задержка между созданием потоков (мс)
    /// </summary>
    ThreadCreateDelay: Integer;
  end;

implementation

end.
