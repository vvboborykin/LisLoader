{*******************************************************
* Project: LisLoader
* Unit: RegisterUnit.pas
* Description: регистрация реализаций интерфейсов в контейнере зависимостей
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}

unit RegisterUnit;

interface

uses
  Lib.Logger.LoggerUnit, Lib.Logger.ConsoleLoggerUnit;

/// <summary>RegisterImplementations
/// зарегистрировать реализации интерфейсов в контейнере внедрения зависимостей
/// </summary>
procedure RegisterImplementations;

implementation

uses
  Lib.DiContainerUnit, Lib.Options.IniOptionsStorageUnit;

procedure RegisterImplementations;
begin
  RegisterIniOptionsStorages;
  RegisterConsoleLogger;
end;

end.

