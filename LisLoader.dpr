program LisLoader;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  Load.FHIRModel in 'Load\Load.FHIRModel.pas',
  Load.RESTClientModuleUnit in 'Load\Load.RESTClientModuleUnit.pas' {RESTClientModule: TDataModule},
  Load.OrderSelectorUnit in 'Load\Load.OrderSelectorUnit.pas',
  Lib.Data.UniDataModuleUnit in '..\Lib\Data\Lib.Data.UniDataModuleUnit.pas' {UniDataModule: TDataModule},
  Lib.Cmco.BaseCmcoDataModuleUnit in '..\Lib\Cmco\Lib.Cmco.BaseCmcoDataModuleUnit.pas' {BaseCmcoDataModule: TDataModule},
  Save.CmcoSaveDataModuleUnit in 'Save\Save.CmcoSaveDataModuleUnit.pas' {CmcoSaveDataModule: TDataModule},
  Lib.Options.IniOptionsStorageUnit in '..\Lib\Options\Lib.Options.IniOptionsStorageUnit.pas',
  Lib.Options.OptionsStorageUnit in '..\Lib\Options\Lib.Options.OptionsStorageUnit.pas',
  Lib.Logger.TextFileLoggerUnit in '..\Lib\Logger\Lib.Logger.TextFileLoggerUnit.pas',
  AppServiceUnit in 'AppServiceUnit.pas',
  Load.OrderLoaderUnit in 'Load\Load.OrderLoaderUnit.pas',
  Save.ResponceProcessorUnit in 'Save\Save.ResponceProcessorUnit.pas',
  RegisterUnit in 'RegisterUnit.pas',
  Load.RESTParamsUnit in 'Load\Load.RESTParamsUnit.pas',
  Load.LisServiceResultUnit in 'Load\Load.LisServiceResultUnit.pas',
  Load.LoadOptionsUnit in 'Load\Load.LoadOptionsUnit.pas',
  Load.PendingOrdersUnit in 'Load\Load.PendingOrdersUnit.pas',
  AppStringsUnit in 'AppStringsUnit.pas',
  Lib.Logger.ConsoleLoggerUnit in '..\Lib\Logger\Lib.Logger.ConsoleLoggerUnit.pas',
  Load.CmcoLoadDataModuleUnit in 'Load\Load.CmcoLoadDataModuleUnit.pas' {CmcoLoadDataModule: TDataModule},
  Save.CmcoActionTypePrepareHelperUnit in 'Save\Save.CmcoActionTypePrepareHelperUnit.pas';

begin
  RegisterImplementations;
  var vApp := TAppService.Create;
  try
    vApp.Run();
    {$IFDEF DEBUG}
    Readln;
    {$ENDIF}
  finally
    vApp.Free;
  end;
end.
