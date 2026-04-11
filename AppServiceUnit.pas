{*******************************************************
* Project: LisLoader
* Unit: AppServiceUnit.pas
* Description: главный сервис приложения для загрузки заказов
*
* Created: 22.03.2026 8:23:56
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}

unit AppServiceUnit;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  System.Threading, Generics.Collections, System.DateUtils,
  Lib.Logger.ConsoleLoggerUnit, Lib.Logger.LoggerUnit,
  Load.LoadOptionsUnit, Load.PendingOrdersUnit;

type
  /// <summary>TAppService
  /// основной сервис приложения, управляющий процессом загрузки заказов
  /// </summary>
  TAppService = class(TObject)
  strict private
    FLoadTaskList: TList<ITask>;
    FThreadCreateTime: TDateTime;
    FWorkTask: ITask;
    /// <summary>CreateAndStartLoadingThread
    /// создать и запустить поток загрузки заказа
    /// </summary>
    /// <param name="AOrderId"> (string) идентификатор заказа</param>
    procedure CreateAndStartLoadingThread(AOrderId: string);
    /// <summary>DeleteCompletedThreads
    /// удалить завершенные потоки из списка
    /// </summary>
    procedure DeleteCompletedThreads;
    /// <summary>GetLoadOptions
    /// получить параметры загрузки из настроек
    /// </summary>
    /// <returns>TLoadOptions - параметры загрузки</returns>
    function GetLoadOptions: TLoadOptions;
    /// <summary>LoadOrders
    /// загрузить список заказов
    /// </summary>
    /// <param name="AOrders"> (TPendingOrders) список заказов для загрузки</param>
    procedure LoadOrders(AOrders: TPendingOrders);
    /// <summary>SelectPendingOrders
    /// выбрать заказы, ожидающие загрузки
    /// </summary>
    /// <returns>TPendingOrders - список заказов для загрузки</returns>
    function SelectPendingOrders: TPendingOrders;
    /// <summary>StartOrderLoading
    /// начать загрузку конкретного заказа
    /// </summary>
    /// <param name="AOrderId"> (string) идентификатор заказа</param>
    /// <param name="AOptions"> (TLoadOptions) параметры загрузки</param>
    procedure StartOrderLoading(AOrderId: string; AOptions: TLoadOptions);
    /// <summary>WaitForCreateTime
    /// ожидать заданную задержку между созданием потоков
    /// </summary>
    /// <param name="AOptions"> (TLoadOptions) параметры загрузки</param>
    procedure WaitForCreateTime(AOptions: TLoadOptions);
    /// <summary>WaitForAllLoadingThreads
    /// ожидать завершения всех потоков загрузки
    /// </summary>
    procedure WaitForAllLoadingThreads;
  private
    /// <summary>WaitForThreadCount
    /// ожидать, пока количество активных потоков не станет меньше максимального
    /// </summary>
    /// <param name="AOptions"> (TLoadOptions) параметры загрузки</param>
    procedure WaitForThreadCount(AOptions: TLoadOptions);
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Run
    /// запустить основной процесс загрузки заказов
    /// </summary>
    procedure Run(WorkTask: ITask = nil);
  end;

implementation

uses
  Lib.Logger.TextFileLoggerUnit, Lib.Options.IniOptionsStorageUnit,
  Lib.Options.OptionsStorageUnit, Load.OrderLoaderUnit, Load.OrderSelectorUnit, Load.LisServiceResultUnit, Save.ResponceProcessorUnit;

const
  SDefaultThreadCreateDelayMillisec = 200;
  SDefaultMaxThreadCount = 3;

resourcestring
  SLoadingCompleted = 'Загрузка закончена';
  SLoadingError = 'Ошибка загрузки %s';
  SLoadingIsCancelled = 'Загрузка прервана';
  SLoadingStarted = 'Начата загрузка результатов анализов';
  SLoadOptions = 'LoadOptions';

constructor TAppService.Create;
begin
  inherited Create;
  FLoadTaskList := TList<ITask>.Create();
end;

destructor TAppService.Destroy;
begin
  FLoadTaskList.Free;
  inherited Destroy;
end;

procedure TAppService.CreateAndStartLoadingThread(AOrderId: string);
var
  vTask: ITask;
begin
  FThreadCreateTime := Now;
  vTask := TTask.Create(
    procedure
    begin
      vTask.CheckCanceled;
      var vLoader := TOrderLoader.Create;
      try
        var vLoadResult: TLisServiceResult;
        if vLoader.LoadOrder(AOrderId, vTask, vLoadResult) then
        begin
          var vSaveProcessor := TResponceProcessor.Create;
          try
            vSaveProcessor.ProcessResponce(vLoadResult);
          finally
            vSaveProcessor.Free;
          end;
        end;
      finally
        vLoader.Free;
      end;
    end);
  FLoadTaskList.Add(vTask);
  vTask.Start;
end;

procedure TAppService.DeleteCompletedThreads;
begin
  var I := 0;
  while I < FLoadTaskList.Count do
  begin
    if FLoadTaskList[I].Status in [TTaskStatus.Completed, TTaskStatus.Exception,
      TTaskStatus.Canceled] then
    begin
      FLoadTaskList.Delete(I);
      Dec(I);
    end;
    Inc(I);
  end;
end;

function TAppService.GetLoadOptions: TLoadOptions;
begin
  Result.MaxThreadCount := AppOptionsStorage.LoadIntegerValue(SLoadOptions,
    'MaxThreadCount', SDefaultMaxThreadCount);
  Result.ThreadCreateDelay := AppOptionsStorage.LoadIntegerValue(SLoadOptions,
    'ThreadCreateDelay', SDefaultThreadCreateDelayMillisec);
end;

procedure TAppService.LoadOrders(AOrders: TPendingOrders);
begin
  var vLoadOptions := GetLoadOptions();
  try
    with AOrders.OrderNumbers do
    begin
      while Count > 0 do
      begin
        if FWorkTask <> nil then
          FWorkTask.CheckCanceled;
        StartOrderLoading(Strings[0], vLoadOptions);
        Delete(0);
      end;
    end;
  except
    on E: EOperationCancelled do
      Logger.Error(SLoadingIsCancelled);
    on E: Exception do
      Logger.Error(SLoadingError, [E.Message]);
  end;
  WaitForAllLoadingThreads();
end;

procedure TAppService.Run(WorkTask: ITask = nil);
begin
  FWorkTask := WorkTask;
  Logger.Info(string.Create('-', 80));
  Logger.Info(SLoadingStarted);
  var vOrders := SelectPendingOrders();
  try
    LoadOrders(vOrders);
  finally
    vOrders.Free;
  end;
  Logger.Info(SLoadingCompleted);
end;

function TAppService.SelectPendingOrders: TPendingOrders;
begin
  var vSelector := TOrderSelector.Create;
  try
    Result := TPendingOrders.Create;
    vSelector.SelectPendingOrders(Result);
  finally
    vSelector.Free;
  end;
end;

procedure TAppService.StartOrderLoading(AOrderId: string; AOptions: TLoadOptions);
begin
  WaitForThreadCount(AOptions);
  WaitForCreateTime(AOptions);
  CreateAndStartLoadingThread(AOrderId);
end;

procedure TAppService.WaitForCreateTime(AOptions: TLoadOptions);
begin
  if MilliSecondsBetween(Now, FThreadCreateTime) < AOptions.ThreadCreateDelay
    then
    Sleep(50);
end;

procedure TAppService.WaitForAllLoadingThreads;
begin
  while FLoadTaskList.Count > 0 do
  begin
    DeleteCompletedThreads();
    Sleep(50);
  end;
end;

procedure TAppService.WaitForThreadCount(AOptions: TLoadOptions);
begin
  DeleteCompletedThreads;
  while (FLoadTaskList.Count >= AOptions.MaxThreadCount) and (AOptions.MaxThreadCount
    > 0) do
  begin
    Sleep(50);
    DeleteCompletedThreads;
  end;
end;

end.

