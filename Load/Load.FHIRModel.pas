{*******************************************************
* Project: LisLoader
* Unit: FHIRModel.pas
* Description: Модель данных получаемых из ЛИС
*
* Created: 20.03.2026 10:38:06
* Copyright (C) 2026 Боборыкин В.В. (bpost@yandex.ru)
*******************************************************}
unit Load.FHIRModel;

interface

uses
  System.Classes, System.JSON, System.Generics.Collections,
  System.SysUtils, Lib.Logger.LoggerUnit, System.RegularExpressions;

type
  TBundle = class;

  /// <summary>
  ///   Представляет элемент кодирования в ресурсах FHIR
  /// </summary>
  /// <remarks>
  ///   Используется для представления кодированных значений с их системой, кодом, отображением и версией.
  ///   Обычно используется в кодах наблюдений, типах образцов и т.д.
  /// </remarks>
  TCoding = class
  private
    FCode: string;
    FDisplay: string;
    FSystem: string;
    FVersion: string;
  public
    /// <summary>Значение кода из системы кодирования</summary>
    property Code: string read FCode write FCode;
    /// <summary>Человеко-читаемое представление кода</summary>
    property Display: string read FDisplay write FDisplay;
    /// <summary>URI/OID идентифицирующий систему кодирования</summary>
    property System: string read FSystem write FSystem;
    /// <summary>Версия системы кодирования</summary>
    property Version: string read FVersion write FVersion;

    /// <summary>Загружает данные кодирования из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля кодирования</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные кодирования в JSON объект</summary>
    /// <returns>JSON представление кодирования</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет элемент идентификатора в ресурсах FHIR
  /// </summary>
  /// <remarks>
  ///   Используется для различных идентификаторов: ID контейнеров образцов, ID практикующих врачей и т.д.
  /// </remarks>
  TIdentifier = class
  private
    FValue: string;
    FSystem: string;
    FAssignerDisplay: string;
    FTypeText: string;
  public
    /// <summary>Значение идентификатора</summary>
    property Value: string read FValue write FValue;
    /// <summary>Система идентификации (OID, URI)</summary>
    property System: string read FSystem write FSystem;
    /// <summary>Отображаемое имя назначившего идентификатор</summary>
    property AssignerDisplay: string read FAssignerDisplay write FAssignerDisplay;
    /// <summary>Текстовое описание типа идентификатора</summary>
    property TypeText: string read FTypeText write FTypeText;

    /// <summary>Загружает данные идентификатора из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля идентификатора</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные идентификатора в JSON объект</summary>
    /// <returns>JSON представление идентификатора</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет ссылку на другой ресурс FHIR
  /// </summary>
  /// <remarks>
  ///   Используется для ссылок на пациента, практикующего врача, организацию и т.д.
  /// </remarks>
  TReference = class
  private
    FReference: string;
    FDisplay: string;
  public
    /// <summary>Ссылка на ресурс (URI или UUID)</summary>
    property Reference: string read FReference write FReference;
    /// <summary>Человеко-читаемое отображение ссылки</summary>
    property Display: string read FDisplay write FDisplay;

    /// <summary>Загружает данные ссылки из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля ссылки</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные ссылки в JSON объект</summary>
    /// <returns>JSON представление ссылки</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет количественное значение с единицами измерения
  /// </summary>
  /// <remarks>
  ///   Используется для результатов наблюдений с числовыми значениями
  /// </remarks>
  TQuantity = class
  private
    FCode: string;
    FValue: Double;
    FUnit: string;
  public
    /// <summary>Код единицы измерения</summary>
    property Code: string read FCode write FCode;
    /// <summary>Числовое значение</summary>
    property Value: Double read FValue write FValue;
    /// <summary>Единица измерения (текст)</summary>
    property Unit_: string read FUnit write FUnit;

    /// <summary>Загружает данные количества из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля количества</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные количества в JSON объект</summary>
    /// <returns>JSON представление количества</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет границу референсного интервала
  /// </summary>
  /// <remarks>
  ///   Используется для верхней или нижней границы референсных значений
  /// </remarks>
  TRangeBound = class
  private
    FCode: string;
    FValue: Double;
  public
    /// <summary>Код единицы измерения границы</summary>
    property Code: string read FCode write FCode;
    /// <summary>Числовое значение границы</summary>
    property Value: Double read FValue write FValue;

    /// <summary>Загружает данные границы из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля границы</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные границы в JSON объект</summary>
    /// <returns>JSON представление границы</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет референсный интервал для наблюдения
  /// </summary>
  /// <remarks>
  ///   Содержит верхнюю и нижнюю границы нормы для лабораторных показателей
  /// </remarks>
  TReferenceRange = class
  private
    FHigh: TRangeBound;
    FLow: TRangeBound;
    FText: string;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Верхняя граница референсного интервала</summary>
    property High: TRangeBound read FHigh write FHigh;
    /// <summary>Нижняя граница референсного интервала</summary>
    property Low: TRangeBound read FLow write FLow;
    /// <summary>Текстовое представление референсного интервала</summary>
    property Text: string read FText write FText;

    /// <summary>Загружает данные референсного интервала из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля интервала</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные интервала в JSON объект</summary>
    /// <returns>JSON представление референсного интервала</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет HTTP запрос для транзакции FHIR
  /// </summary>
  /// <remarks>
  ///   Используется в пакетах для указания метода и URL при создании ресурсов
  /// </remarks>
  TRequest = class
  private
    FUrl: string;
    FMethod: string;
  public
    /// <summary>URL ресурса для запроса</summary>
    property Url: string read FUrl write FUrl;
    /// <summary>HTTP метод (POST, PUT, GET и т.д.)</summary>
    property Method: string read FMethod write FMethod;

    /// <summary>Загружает данные запроса из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля запроса</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные запроса в JSON объект</summary>
    /// <returns>JSON представление запроса</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет имя человека (практикующего врача, пациента)
  /// </summary>
  /// <remarks>
  ///   Содержит массивы для имени, отчества и фамилии
  /// </remarks>
  TName = class
  private
    FGiven: TArray<string>;
    FFamily: TArray<string>;
  public
    /// <summary>Массив частей имени (обычно имя и отчество)</summary>
    property Given: TArray<string> read FGiven write FGiven;
    /// <summary>Массив частей фамилии</summary>
    property Family: TArray<string> read FFamily write FFamily;

    /// <summary>Загружает данные имени из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля имени</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные имени в JSON объект</summary>
    /// <returns>JSON представление имени</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет специализацию практикующего врача
  /// </summary>
  TSpecialty = class
  private
    FCoding: TCoding;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Кодированная информация о специализации</summary>
    property Coding: TCoding read FCoding write FCoding;

    /// <summary>Загружает данные специализации из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля специализации</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные специализации в JSON объект</summary>
    /// <returns>JSON представление специализации</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет роль практикующего врача в организации
  /// </summary>
  TPractitionerRole = class
  private
    FManagingOrganization: TReference;
    FRole: TCoding;
    FSpecialty: TList<TSpecialty>;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Ссылка на управляющую организацию</summary>
    property ManagingOrganization: TReference read FManagingOrganization write FManagingOrganization;
    /// <summary>Кодированная информация о роли</summary>
    property Role: TCoding read FRole write FRole;
    /// <summary>Список специализаций врача</summary>
    property Specialty: TList<TSpecialty> read FSpecialty;

    /// <summary>Загружает данные роли из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля роли</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные роли в JSON объект</summary>
    /// <returns>JSON представление роли</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет контейнер для образца (пробирку, контейнер для мочи и т.д.)
  /// </summary>
  TSpecimenContainer = class
  private
    FIdentifier: TList<TIdentifier>;
    FTypeCoding: TCoding;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Список идентификаторов контейнера</summary>
    property Identifier: TList<TIdentifier> read FIdentifier;
    /// <summary>Кодированная информация о типе контейнера</summary>
    property TypeCoding: TCoding read FTypeCoding write FTypeCoding;

    /// <summary>Загружает данные контейнера из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля контейнера</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные контейнера в JSON объект</summary>
    /// <returns>JSON представление контейнера</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет информацию о сборе образца
  /// </summary>
  TSpecimenCollection = class
  private
    FCollectedDateTime: string;
  public
    /// <summary>Дата и время сбора образца</summary>
    property CollectedDateTime: string read FCollectedDateTime write FCollectedDateTime;

    /// <summary>Загружает данные о сборе из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля сбора</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные о сборе в JSON объект</summary>
    /// <returns>JSON представление информации о сборе</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет ресурс FHIR типа Specimen (образец)
  /// </summary>
  TSpecimen = class
  private
    FResourceType: string;
    FTypeCoding: TCoding;
    FContainer: TList<TSpecimenContainer>;
    FCollection: TSpecimenCollection;
    FSubject: TReference;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Тип ресурса FHIR (всегда "Specimen")</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Кодированная информация о типе образца</summary>
    property TypeCoding: TCoding read FTypeCoding write FTypeCoding;
    /// <summary>Список контейнеров с образцом</summary>
    property Container: TList<TSpecimenContainer> read FContainer;
    /// <summary>Информация о сборе образца</summary>
    property Collection: TSpecimenCollection read FCollection write FCollection;
    /// <summary>Ссылка на субъект (пациента)</summary>
    property Subject: TReference read FSubject write FSubject;

    /// <summary>Загружает данные образца из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля образца</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные образца в JSON объект</summary>
    /// <returns>JSON представление образца</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет значение наблюдения, которое может быть количественным или строковым
  /// </summary>
  TObservationValue = class
  private
    FValueQuantity: TQuantity;
    FValueString: string;
    FValueType: string; // 'quantity' или 'string'
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Количественное значение (если тип "quantity")</summary>
    property ValueQuantity: TQuantity read FValueQuantity write FValueQuantity;
    /// <summary>Строковое значение (если тип "string")</summary>
    property ValueString: string read FValueString write FValueString;
    /// <summary>Тип значения: 'quantity' или 'string'</summary>
    property ValueType: string read FValueType write FValueType;

    /// <summary>Загружает значение наблюдения из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поле valueQuantity или valueString</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует значение наблюдения в JSON объект</summary>
    /// <returns>JSON представление значения</returns>
    function ToJSON: TJSONObject;
    /// <summary>Возвращает строковое представление значения</summary>
    function ToString: string; override;
  end;

  /// <summary>
  ///   Представляет ресурс FHIR типа Observation (наблюдение/лабораторный показатель)
  /// </summary>
  TObservation = class
  private
    FResourceType: string;
    FStatus: string;
    FCodeCoding: TCoding;
    FInterpretationCode: string;
    FIssued: string;
    FReferenceRange: TList<TReferenceRange>;
    FValue: TObservationValue;
    FPerformer: TList<TReference>;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Тип ресурса FHIR (всегда "Observation")</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Статус наблюдения (final, preliminary и т.д.)</summary>
    property Status: string read FStatus write FStatus;
    /// <summary>Кодированная информация о типе наблюдения</summary>
    property CodeCoding: TCoding read FCodeCoding write FCodeCoding;
    /// <summary>Код интерпретации (N - норма, A - отклонение и т.д.)</summary>
    property InterpretationCode: string read FInterpretationCode write FInterpretationCode;
    /// <summary>Дата и время выдачи результата</summary>
    property Issued: string read FIssued write FIssued;
    /// <summary>Список референсных интервалов</summary>
    property ReferenceRange: TList<TReferenceRange> read FReferenceRange;
    /// <summary>Значение наблюдения (количественное или строковое)</summary>
    property Value: TObservationValue read FValue write FValue;
    /// <summary>Список исполнителей наблюдения</summary>
    property Performer: TList<TReference> read FPerformer;

    function GetErrors: string;
    /// <summary>Загружает данные наблюдения из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля наблюдения</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные наблюдения в JSON объект</summary>
    /// <returns>JSON представление наблюдения</returns>
    function ToJSON: TJSONObject;
    /// <summary>Возвращает строковое представление наблюдения</summary>
    function ToString: String; override;
  end;

  /// <summary>
  ///   Представляет ресурс FHIR типа DiagnosticReport (диагностический отчет)
  /// </summary>
  TDiagnosticReport = class
  private
    FResourceType: string;
    FStatus: string;
    FCodeCoding: TCoding;
    FIssued: string;
    FSpecimen: TList<TReference>;
    FRequest: TList<TReference>;
    FPerformer: TReference;
    FResult: TList<TReference>;
    FEffectiveDateTime: string;
    FSubject: TReference;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Тип ресурса FHIR (всегда "DiagnosticReport")</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Статус отчета</summary>
    property Status: string read FStatus write FStatus;
    /// <summary>Кодированная информация о типе отчета</summary>
    property CodeCoding: TCoding read FCodeCoding write FCodeCoding;
    /// <summary>Дата и время выдачи отчета</summary>
    property Issued: string read FIssued write FIssued;
    /// <summary>Список ссылок на образцы</summary>
    property Specimen: TList<TReference> read FSpecimen;
    /// <summary>Список ссылок на заказы</summary>
    property Request: TList<TReference> read FRequest;
    /// <summary>Ссылка на исполнителя</summary>
    property Performer: TReference read FPerformer write FPerformer;
    /// <summary>Список ссылок на результаты (наблюдения)</summary>
    property Result: TList<TReference> read FResult;
    /// <summary>Дата и время действительности отчета</summary>
    property EffectiveDateTime: string read FEffectiveDateTime write FEffectiveDateTime;
    /// <summary>Ссылка на субъект (пациента)</summary>
    property Subject: TReference read FSubject write FSubject;

    /// <summary>Возвращает строковое представление отчета</summary>
    function ToString: String; override;
    /// <summary>Загружает данные отчета из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля отчета</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные отчета в JSON объект</summary>
    /// <returns>JSON представление отчета</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет ресурс FHIR типа Practitioner (практикующий врач)
  /// </summary>
  TPractitioner = class
  private
    FResourceType: string;
    FName: TName;
    FGender: string;
    FBirthDate: string;
    FPractitionerRole: TList<TPractitionerRole>;
    FIdentifier: TList<TIdentifier>;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Тип ресурса FHIR (всегда "Practitioner")</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Имя практикующего врача</summary>
    property Name: TName read FName write FName;
    /// <summary>Пол</summary>
    property Gender: string read FGender write FGender;
    /// <summary>Дата рождения</summary>
    property BirthDate: string read FBirthDate write FBirthDate;
    /// <summary>Список ролей практикующего врача</summary>
    property PractitionerRole: TList<TPractitionerRole> read FPractitionerRole;
    /// <summary>Список идентификаторов</summary>
    property Identifier: TList<TIdentifier> read FIdentifier;

    /// <summary>Загружает данные практикующего врача из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля практикующего врача</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные практикующего врача в JSON объект</summary>
    /// <returns>JSON представление практикующего врача</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет ресурс FHIR типа OrderResponse (ответ на заказ)
  /// </summary>
  TOrderResponse = class
  private
    FResourceType: string;
    FWho: TReference;
    FRequest: TReference;
    FFulfillment: TList<TReference>;
    FDate: string;
    FIdentifier: TList<TIdentifier>;
    FOrderStatus: string;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Тип ресурса FHIR (всегда "OrderResponse")</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Кто выполнил заказ</summary>
    property Who: TReference read FWho write FWho;
    /// <summary>Ссылка на исходный заказ</summary>
    property Request: TReference read FRequest write FRequest;
    /// <summary>Список ссылок на выполненные отчеты</summary>
    property Fulfillment: TList<TReference> read FFulfillment;
    /// <summary>Дата ответа</summary>
    property Date: string read FDate write FDate;
    /// <summary>Список идентификаторов ответа</summary>
    property Identifier: TList<TIdentifier> read FIdentifier;
    /// <summary>Статус заказа</summary>
    property OrderStatus: string read FOrderStatus write FOrderStatus;

    /// <summary>Загружает данные ответа на заказ из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля ответа</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    function OrderId: string;
    /// <summary>Преобразует данные ответа в JSON объект</summary>
    /// <returns>JSON представление ответа на заказ</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет запись в пакете FHIR
  /// </summary>
  /// <remarks>
  ///   Содержит ресурс и информацию о запросе для транзакции
  /// </remarks>
  TEntry = class
  strict private
    FBundle: TBundle;
    procedure SetBundle(const Value: TBundle);
  private
    FResource: TObject;
    FResourceType: string;
    FRequest: TRequest;
    FFullUrl: string;
  public
    constructor Create;
    destructor Destroy; override;

    property Bundle: TBundle read FBundle write SetBundle;
    /// <summary>Ресурс FHIR (может быть разных типов)</summary>
    property Resource: TObject read FResource write FResource;
    /// <summary>Тип ресурса</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Информация о запросе для транзакции</summary>
    property Request: TRequest read FRequest write FRequest;
    /// <summary>Полный URL ресурса в пакете</summary>
    property FullUrl: string read FFullUrl write FFullUrl;

    /// <summary>Загружает данные записи из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля записи</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные записи в JSON объект</summary>
    /// <returns>JSON представление записи</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет профиль в метаданных ресурса
  /// </summary>
  TProfile = class
  private
    FProfile: string;
  public
    /// <summary>Ссылка на структуру профиля</summary>
    property Profile: string read FProfile write FProfile;

    /// <summary>Загружает данные профиля из JSON массива</summary>
    /// <param name="AJSON">JSON массив, содержащий профиль</param>
    procedure LoadFromJSON(AJSON: TJSONArray);
    /// <summary>Преобразует данные профиля в JSON массив</summary>
    /// <returns>JSON представление профиля</returns>
    function ToJSON: TJSONArray;
  end;

  /// <summary>
  ///   Представляет метаданные ресурса FHIR
  /// </summary>
  TMeta = class
  private
    FProfile: TProfile;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Профиль ресурса</summary>
    property Profile: TProfile read FProfile write FProfile;

    /// <summary>Загружает метаданные из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий метаданные</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует метаданные в JSON объект</summary>
    /// <returns>JSON представление метаданных</returns>
    function ToJSON: TJSONObject;
  end;

  /// <summary>
  ///   Представляет пакет ресурсов FHIR (Bundle) для транзакции
  /// </summary>
  /// <remarks>
  ///   Корневой объект, содержащий коллекцию ресурсов для одной транзакции
  /// </remarks>
  TBundle = class
  private
    FResourceType: string;
    FType: string;
    FEntry: TList<TEntry>;
    FMeta: TMeta;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Тип ресурса FHIR (всегда "Bundle")</summary>
    property ResourceType: string read FResourceType write FResourceType;
    /// <summary>Тип пакета (например "transaction")</summary>
    property &Type: string read FType write FType;
    /// <summary>Список записей в пакете</summary>
    property Entry: TList<TEntry> read FEntry;
    /// <summary>Метаданные пакета</summary>
    property Meta: TMeta read FMeta write FMeta;

    function IsValid: Boolean;
    /// <summary>Загружает данные пакета из JSON объекта</summary>
    /// <param name="AJSON">JSON объект, содержащий поля пакета</param>
    procedure LoadFromJSON(AJSON: TJSONObject);
    /// <summary>Преобразует данные пакета в JSON объект</summary>
    /// <returns>JSON представление пакета</returns>
    function ToJSON: TJSONObject;
    function TryFindEntryByFullUrl(AFullUrl: string; out AResult: TEntry): Boolean;
    function TryFindResourceByFullUrl<T: class>(AFullUrl: string; out AResult: T):
        Boolean; overload;
    function TryFindFirstResource<T: class>(out AResult: T): Boolean; overload;
    function FindResources<T: class>: TArray<T>;
  end;

  /// <summary>
  ///   Класс-преобразователь для парсинга JSON в объектную модель FHIR
  /// </summary>
  TJSONToModelConverter = class
  public
    /// <summary>Парсит JSON строку в объект TBundle</summary>
    /// <param name="AJSONString">JSON строка, содержащая пакет FHIR</param>
    /// <returns>Объект TBundle или nil в случае ошибки</returns>
    class function ParseBundle(const AJSONString: string): TBundle; overload;
    /// <summary>Парсит JSON объект в объект TBundle</summary>
    /// <param name="AJSONObject">JSON объект, содержащий пакет FHIR</param>
    /// <returns>Объект TBundle</returns>
    class function ParseBundle(AJSONObject: TJSONObject): TBundle; overload;
  end;

  function TryFHIRStrToDateTime(AFHIRStr: String; out AResult: TDateTime):
      Boolean;

implementation

  function TryFHIRStrToDateTime(AFHIRStr: String; out AResult: TDateTime):
      Boolean;
  var
    vDay: Integer;
    vHour: Integer;
    vMinute: Integer;
    vMonth: Integer;
    vSecond: Integer;
    vYear: Integer;
  begin
    AResult := MinDateTime;
    var match := TRegEx.Match(AFHIRStr, '(\d{4})\-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})');
    if match.Success then
    begin
      vYear := match.Groups[1].Value.ToInteger;
      vMonth := match.Groups[2].Value.ToInteger;
      vDay := match.Groups[3].Value.ToInteger;
      vHour := match.Groups[4].Value.ToInteger;
      vMinute := match.Groups[5].Value.ToInteger;
      vSecond := match.Groups[5].Value.ToInteger;
      AResult := EncodeDate(vYear, vMonth, vDay) +
        EncodeTime(vHour, vMinute, vSecond, 0);
    end;
    Result := AResult <> MinDateTime;
  end;

{ TCoding }

procedure TCoding.LoadFromJSON(AJSON: TJSONObject);
begin
  if AJSON = nil then Exit;

  FCode := AJSON.GetValue<string>('code', '');
  FDisplay := AJSON.GetValue<string>('display', '');
  FSystem := AJSON.GetValue<string>('system', '');
  FVersion := AJSON.GetValue<string>('version', '');
end;

function TCoding.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('code', FCode);
  Result.AddPair('display', FDisplay);
  Result.AddPair('system', FSystem);
  if FVersion <> '' then
    Result.AddPair('version', FVersion);
end;

{ TIdentifier }

procedure TIdentifier.LoadFromJSON(AJSON: TJSONObject);
var
  AssignerObj: TJSONObject;
  TypeObj: TJSONObject;
begin
  if AJSON = nil then Exit;

  FValue := AJSON.GetValue<string>('value', '');
  FSystem := AJSON.GetValue<string>('system', '');

  if AJSON.TryGetValue<TJSONObject>('assigner', AssignerObj) then
    FAssignerDisplay := AssignerObj.GetValue<string>('display', '');

  if AJSON.TryGetValue<TJSONObject>('type', TypeObj) then
    FTypeText := TypeObj.GetValue<string>('text', '');
end;

function TIdentifier.ToJSON: TJSONObject;
var
  AssignerObj: TJSONObject;
  TypeObj: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('value', FValue);
  if FSystem <> '' then
    Result.AddPair('system', FSystem);

  if FAssignerDisplay <> '' then
  begin
    AssignerObj := TJSONObject.Create;
    AssignerObj.AddPair('display', FAssignerDisplay);
    Result.AddPair('assigner', AssignerObj);
  end;

  if FTypeText <> '' then
  begin
    TypeObj := TJSONObject.Create;
    TypeObj.AddPair('text', FTypeText);
    Result.AddPair('type', TypeObj);
  end;
end;

{ TReference }

procedure TReference.LoadFromJSON(AJSON: TJSONObject);
begin
  if AJSON = nil then Exit;

  FReference := AJSON.GetValue<string>('reference', '');
  FDisplay := AJSON.GetValue<string>('display', '');
end;

function TReference.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('reference', FReference);
  if FDisplay <> '' then
    Result.AddPair('display', FDisplay);
end;

{ TQuantity }

procedure TQuantity.LoadFromJSON(AJSON: TJSONObject);
begin
  if AJSON = nil then Exit;

  FCode := AJSON.GetValue<string>('code', '');
  FValue := AJSON.GetValue<Double>('value', 0);
  FUnit := AJSON.GetValue<string>('unit', '');
end;

function TQuantity.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('code', FCode);
  Result.AddPair('value', TJSONNumber.Create(FValue));
  if FUnit <> '' then
    Result.AddPair('unit', FUnit);
end;

{ TRangeBound }

procedure TRangeBound.LoadFromJSON(AJSON: TJSONObject);
begin
  if AJSON = nil then Exit;

  FCode := AJSON.GetValue<string>('code', '');
  FValue := AJSON.GetValue<Double>('value', 0);
end;

function TRangeBound.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('code', FCode);
  Result.AddPair('value', TJSONNumber.Create(FValue));
end;

{ TReferenceRange }

constructor TReferenceRange.Create;
begin
  FHigh := TRangeBound.Create;
  FLow := TRangeBound.Create;
end;

destructor TReferenceRange.Destroy;
begin
  FHigh.Free;
  FLow.Free;
  inherited;
end;

procedure TReferenceRange.LoadFromJSON(AJSON: TJSONObject);
var
  HighObj, LowObj: TJSONObject;
begin
  if AJSON = nil then Exit;

  if AJSON.TryGetValue<TJSONObject>('high', HighObj) then
    FHigh.LoadFromJSON(HighObj);

  if AJSON.TryGetValue<TJSONObject>('low', LowObj) then
    FLow.LoadFromJSON(LowObj);

  FText := AJSON.GetValue<string>('text', '');
end;

function TReferenceRange.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if (FHigh.Value <> 0) or (FHigh.Code <> '') then
    Result.AddPair('high', FHigh.ToJSON);
  if (FLow.Value <> 0) or (FLow.Code <> '') then
    Result.AddPair('low', FLow.ToJSON);
  if FText <> '' then
    Result.AddPair('text', FText);
end;

{ TRequest }

procedure TRequest.LoadFromJSON(AJSON: TJSONObject);
begin
  if AJSON = nil then Exit;

  FUrl := AJSON.GetValue<string>('url', '');
  FMethod := AJSON.GetValue<string>('method', '');
end;

function TRequest.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('url', FUrl);
  Result.AddPair('method', FMethod);
end;

{ TName }

procedure TName.LoadFromJSON(AJSON: TJSONObject);
var
  GivenArray, FamilyArray: TJSONArray;
  i: Integer;
begin
  if AJSON = nil then Exit;

  if AJSON.TryGetValue<TJSONArray>('given', GivenArray) then
  begin
    SetLength(FGiven, GivenArray.Count);
    for i := 0 to GivenArray.Count - 1 do
      FGiven[i] := GivenArray.Items[i].Value;
  end;

  if AJSON.TryGetValue<TJSONArray>('family', FamilyArray) then
  begin
    SetLength(FFamily, FamilyArray.Count);
    for i := 0 to FamilyArray.Count - 1 do
      FFamily[i] := FamilyArray.Items[i].Value;
  end;
end;

function TName.ToJSON: TJSONObject;
var
  GivenArray, FamilyArray: TJSONArray;
  i: Integer;
begin
  Result := TJSONObject.Create;

  GivenArray := TJSONArray.Create;
  for i := 0 to Length(FGiven) - 1 do
    GivenArray.Add(FGiven[i]);
  Result.AddPair('given', GivenArray);

  FamilyArray := TJSONArray.Create;
  for i := 0 to Length(FFamily) - 1 do
    FamilyArray.Add(FFamily[i]);
  Result.AddPair('family', FamilyArray);
end;

{ TSpecialty }

constructor TSpecialty.Create;
begin
  FCoding := TCoding.Create;
end;

destructor TSpecialty.Destroy;
begin
  FCoding.Free;
  inherited;
end;

procedure TSpecialty.LoadFromJSON(AJSON: TJSONObject);
var
  CodingArray: TJSONArray;
begin
  if AJSON = nil then Exit;

  if AJSON.TryGetValue<TJSONArray>('coding', CodingArray) and (CodingArray.Count > 0) then
    FCoding.LoadFromJSON(CodingArray.Items[0] as TJSONObject);
end;

function TSpecialty.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('coding', TJSONArray.Create.Add(FCoding.ToJSON));
end;

{ TPractitionerRole }

constructor TPractitionerRole.Create;
begin
  FManagingOrganization := TReference.Create;
  FRole := TCoding.Create;
  FSpecialty := TList<TSpecialty>.Create;
end;

destructor TPractitionerRole.Destroy;
var
  Specialty: TSpecialty;
begin
  FManagingOrganization.Free;
  FRole.Free;
  for Specialty in FSpecialty do
    Specialty.Free;
  FSpecialty.Free;
  inherited;
end;

procedure TPractitionerRole.LoadFromJSON(AJSON: TJSONObject);
var
  OrgObj: TJSONObject;
  RoleObj: TJSONObject;
  SpecialtyArray: TJSONArray;
  CodingArray: TJSONArray;
  i: Integer;
  Specialty: TSpecialty;
begin
  if AJSON = nil then Exit;

  if AJSON.TryGetValue<TJSONObject>('managingOrganization', OrgObj) then
    FManagingOrganization.LoadFromJSON(OrgObj);

  if AJSON.TryGetValue<TJSONObject>('role', RoleObj) then
  begin
    if RoleObj.TryGetValue<TJSONArray>('coding', CodingArray) and (CodingArray.Count > 0) then
      FRole.LoadFromJSON(CodingArray.Items[0] as TJSONObject);
  end;

  if AJSON.TryGetValue<TJSONArray>('specialty', SpecialtyArray) then
  begin
    for i := 0 to SpecialtyArray.Count - 1 do
    begin
      Specialty := TSpecialty.Create;
      Specialty.LoadFromJSON(SpecialtyArray.Items[i] as TJSONObject);
      FSpecialty.Add(Specialty);
    end;
  end;
end;

function TPractitionerRole.ToJSON: TJSONObject;
var
  RoleObj: TJSONObject;
  SpecialtyArray: TJSONArray;
  Specialty: TSpecialty;
begin
  Result := TJSONObject.Create;
  Result.AddPair('managingOrganization', FManagingOrganization.ToJSON);

  RoleObj := TJSONObject.Create;
  RoleObj.AddPair('coding', TJSONArray.Create.Add(FRole.ToJSON));
  Result.AddPair('role', RoleObj);

  SpecialtyArray := TJSONArray.Create;
  for Specialty in FSpecialty do
    SpecialtyArray.Add(Specialty.ToJSON);
  Result.AddPair('specialty', SpecialtyArray);
end;

{ TSpecimenContainer }

constructor TSpecimenContainer.Create;
begin
  FIdentifier := TList<TIdentifier>.Create;
  FTypeCoding := TCoding.Create;
end;

destructor TSpecimenContainer.Destroy;
var
  Ident: TIdentifier;
begin
  for Ident in FIdentifier do
    Ident.Free;
  FIdentifier.Free;
  FTypeCoding.Free;
  inherited;
end;

procedure TSpecimenContainer.LoadFromJSON(AJSON: TJSONObject);
var
  IdentArray: TJSONArray;
  TypeObj: TJSONObject;
  CodingArray: TJSONArray;
  i: Integer;
  Identifier: TIdentifier;
begin
  if AJSON = nil then Exit;

  if AJSON.TryGetValue<TJSONArray>('identifier', IdentArray) then
  begin
    for i := 0 to IdentArray.Count - 1 do
    begin
      Identifier := TIdentifier.Create;
      Identifier.LoadFromJSON(IdentArray.Items[i] as TJSONObject);
      FIdentifier.Add(Identifier);
    end;
  end;

  if AJSON.TryGetValue<TJSONObject>('type', TypeObj) then
  begin
    if TypeObj.TryGetValue<TJSONArray>('coding', CodingArray) and (CodingArray.Count > 0) then
      FTypeCoding.LoadFromJSON(CodingArray.Items[0] as TJSONObject);
  end;
end;

function TSpecimenContainer.ToJSON: TJSONObject;
var
  IdentArray: TJSONArray;
  TypeObj: TJSONObject;
  Identifier: TIdentifier;
begin
  Result := TJSONObject.Create;

  IdentArray := TJSONArray.Create;
  for Identifier in FIdentifier do
    IdentArray.Add(Identifier.ToJSON);
  Result.AddPair('identifier', IdentArray);

  TypeObj := TJSONObject.Create;
  TypeObj.AddPair('coding', TJSONArray.Create.Add(FTypeCoding.ToJSON));
  Result.AddPair('type', TypeObj);
end;

{ TSpecimenCollection }

procedure TSpecimenCollection.LoadFromJSON(AJSON: TJSONObject);
begin
  if AJSON = nil then Exit;

  FCollectedDateTime := AJSON.GetValue<string>('collectedDateTime', '');
end;

function TSpecimenCollection.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('collectedDateTime', FCollectedDateTime);
end;

{ TSpecimen }

constructor TSpecimen.Create;
begin
  FResourceType := 'Specimen';
  FTypeCoding := TCoding.Create;
  FContainer := TList<TSpecimenContainer>.Create;
  FCollection := TSpecimenCollection.Create;
  FSubject := TReference.Create;
end;

destructor TSpecimen.Destroy;
var
  Container: TSpecimenContainer;
begin
  FTypeCoding.Free;
  for Container in FContainer do
    Container.Free;
  FContainer.Free;
  FCollection.Free;
  FSubject.Free;
  inherited;
end;

procedure TSpecimen.LoadFromJSON(AJSON: TJSONObject);
var
  TypeObj: TJSONObject;
  CodingArray: TJSONArray;
  ContainerArray: TJSONArray;
  CollectionObj: TJSONObject;
  SubjectObj: TJSONObject;
  i: Integer;
  Container: TSpecimenContainer;
begin
  if AJSON = nil then Exit;

  FResourceType := AJSON.GetValue<string>('resourceType', '');

  if AJSON.TryGetValue<TJSONObject>('type', TypeObj) then
  begin
    if TypeObj.TryGetValue<TJSONArray>('coding', CodingArray) and (CodingArray.Count > 0) then
      FTypeCoding.LoadFromJSON(CodingArray.Items[0] as TJSONObject);
  end;

  if AJSON.TryGetValue<TJSONArray>('container', ContainerArray) then
  begin
    for i := 0 to ContainerArray.Count - 1 do
    begin
      Container := TSpecimenContainer.Create;
      Container.LoadFromJSON(ContainerArray.Items[i] as TJSONObject);
      FContainer.Add(Container);
    end;
  end;

  if AJSON.TryGetValue<TJSONObject>('collection', CollectionObj) then
    FCollection.LoadFromJSON(CollectionObj);

  if AJSON.TryGetValue<TJSONObject>('subject', SubjectObj) then
    FSubject.LoadFromJSON(SubjectObj);
end;

function TSpecimen.ToJSON: TJSONObject;
var
  TypeObj: TJSONObject;
  ContainerArray: TJSONArray;
  Container: TSpecimenContainer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', FResourceType);

  TypeObj := TJSONObject.Create;
  TypeObj.AddPair('coding', TJSONArray.Create.Add(FTypeCoding.ToJSON));
  Result.AddPair('type', TypeObj);

  ContainerArray := TJSONArray.Create;
  for Container in FContainer do
    ContainerArray.Add(Container.ToJSON);
  Result.AddPair('container', ContainerArray);

  Result.AddPair('collection', FCollection.ToJSON);
  Result.AddPair('subject', FSubject.ToJSON);
end;

{ TObservationValue }

constructor TObservationValue.Create;
begin
  FValueQuantity := TQuantity.Create;
  FValueType := '';
end;

destructor TObservationValue.Destroy;
begin
  FValueQuantity.Free;
  inherited;
end;

procedure TObservationValue.LoadFromJSON(AJSON: TJSONObject);
var
  ValuePair: TJSONValue;
begin
  if AJSON = nil then Exit;

  // Проверяем наличие valueQuantity
  ValuePair := AJSON.FindValue('valueQuantity');
  if Assigned(ValuePair) and (ValuePair is TJSONObject) then
  begin
    FValueQuantity.LoadFromJSON(ValuePair as TJSONObject);
    FValueType := 'quantity';
    Exit;
  end;

  // Проверяем наличие valueString
  ValuePair := AJSON.FindValue('valueString');
  if Assigned(ValuePair) and (ValuePair is TJSONString) then
  begin
    FValueString := (ValuePair as TJSONString).Value;
    FValueType := 'string';
  end;
end;

function TObservationValue.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;

  if FValueType = 'quantity' then
    Result.AddPair('valueQuantity', FValueQuantity.ToJSON)
  else if FValueType = 'string' then
    Result.AddPair('valueString', FValueString);
end;

function TObservationValue.ToString: string;
begin
  if FValueType = 'quantity' then
    Result := FloatToStr(FValueQuantity.Value) + ' ' + FValueQuantity.Unit_
  else if FValueType = 'string' then
    Result := FValueString
  else
    Result := '';
end;

{ TObservation }

constructor TObservation.Create;
begin
  FResourceType := 'Observation';
  FCodeCoding := TCoding.Create;
  FReferenceRange := TList<TReferenceRange>.Create;
  FValue := TObservationValue.Create;
  FPerformer := TList<TReference>.Create;
end;

destructor TObservation.Destroy;
var
  Range: TReferenceRange;
  Perf: TReference;
begin
  FCodeCoding.Free;
  for Range in FReferenceRange do
    Range.Free;
  FReferenceRange.Free;
  FValue.Free;
  for Perf in FPerformer do
    Perf.Free;
  FPerformer.Free;
  inherited;
end;

function TObservation.GetErrors: string;
begin
  var vErrors := TStringList.Create;
  try
    if CodeCoding = nil then
      vErrors.Add('Для не задан элемент код')
    else
    begin
      if CodeCoding.Code = '' then
        vErrors.Add('Для не задан код теста');

      if CodeCoding.Display = '' then
        vErrors.Add('Для параметра не задано наименование');
    end;

    if Value = nil then
      vErrors.Add('Для параметра не задано величина (определенное лабораторией значение)');





    Result := vErrors.Text;
  finally
    vErrors.Free;
  end;
end;

procedure TObservation.LoadFromJSON(AJSON: TJSONObject);
var
  CodeObj: TJSONObject;
  CodingArray: TJSONArray;
  InterpretationObj: TJSONObject;
  RangeArray: TJSONArray;
  PerfArray: TJSONArray;
  i: Integer;
  Range: TReferenceRange;
  Perf: TReference;
begin
  if AJSON = nil then Exit;

  FResourceType := AJSON.GetValue<string>('resourceType', '');
  FStatus := AJSON.GetValue<string>('status', '');

  if AJSON.TryGetValue<TJSONObject>('code', CodeObj) then
  begin
    if CodeObj.TryGetValue<TJSONArray>('coding', CodingArray) and (CodingArray.Count > 0) then
      FCodeCoding.LoadFromJSON(CodingArray.Items[0] as TJSONObject);
  end;

  if AJSON.TryGetValue<TJSONObject>('interpretation', InterpretationObj) then
  begin
    if InterpretationObj.TryGetValue<TJSONArray>('coding', CodingArray) and
       (CodingArray.Count > 0) then
      FInterpretationCode := (CodingArray.Items[0] as TJSONObject).GetValue<string>('code', '');
  end;

  FIssued := AJSON.GetValue<string>('issued', '');

  if AJSON.TryGetValue<TJSONArray>('referenceRange', RangeArray) then
  begin
    for i := 0 to RangeArray.Count - 1 do
    begin
      Range := TReferenceRange.Create;
      Range.LoadFromJSON(RangeArray.Items[i] as TJSONObject);
      FReferenceRange.Add(Range);
    end;
  end;

  FValue.LoadFromJSON(AJSON);

  if AJSON.TryGetValue<TJSONArray>('performer', PerfArray) then
  begin
    for i := 0 to PerfArray.Count - 1 do
    begin
      Perf := TReference.Create;
      Perf.LoadFromJSON(PerfArray.Items[i] as TJSONObject);
      FPerformer.Add(Perf);
    end;
  end;
end;

function TObservation.ToJSON: TJSONObject;
var
  CodeObj: TJSONObject;
  CodeArray: TJSONArray;
  InterpretationObj: TJSONObject;
  RangeArray: TJSONArray;
  PerfArray: TJSONArray;
  Range: TReferenceRange;
  Perf: TReference;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', FResourceType);
  Result.AddPair('status', FStatus);

  CodeArray := TJSONArray.Create;
  CodeObj := TJSONObject.Create;
  CodeObj.AddPair('coding', TJSONArray.Create.Add(FCodeCoding.ToJSON));
  CodeArray.Add(CodeObj);
  Result.AddPair('code', CodeArray);

  if FInterpretationCode <> '' then
  begin
    InterpretationObj := TJSONObject.Create;
    InterpretationObj.AddPair('coding', TJSONArray.Create.Add(
      TJSONObject.Create.AddPair('code', FInterpretationCode)
    ));
    Result.AddPair('interpretation', InterpretationObj);
  end;

  Result.AddPair('issued', FIssued);

  if FReferenceRange.Count > 0 then
  begin
    RangeArray := TJSONArray.Create;
    for Range in FReferenceRange do
      RangeArray.Add(Range.ToJSON);
    Result.AddPair('referenceRange', RangeArray);
  end;

  // Добавляем значение через TObservationValue
  if Assigned(FValue) and (FValue.ValueType <> '') then
  begin
    if FValue.ValueType = 'quantity' then
      Result.AddPair('valueQuantity', FValue.ValueQuantity.ToJSON)
    else if FValue.ValueType = 'string' then
      Result.AddPair('valueString', FValue.ValueString);
  end;

  PerfArray := TJSONArray.Create;
  for Perf in FPerformer do
    PerfArray.Add(Perf.ToJSON);
  Result.AddPair('performer', PerfArray);
end;

function TObservation.ToString: String;
begin
  Result := CodeCoding.Display + ': ' + Value.ToString;
end;

{ TDiagnosticReport }

constructor TDiagnosticReport.Create;
begin
  FResourceType := 'DiagnosticReport';
  FCodeCoding := TCoding.Create;
  FSpecimen := TList<TReference>.Create;
  FRequest := TList<TReference>.Create;
  FPerformer := TReference.Create;
  FResult := TList<TReference>.Create;
  FSubject := TReference.Create;
end;

destructor TDiagnosticReport.Destroy;
var
  Ref: TReference;
begin
  FCodeCoding.Free;
  for Ref in FSpecimen do
    Ref.Free;
  FSpecimen.Free;
  for Ref in FRequest do
    Ref.Free;
  FRequest.Free;
  FPerformer.Free;
  for Ref in FResult do
    Ref.Free;
  FResult.Free;
  FSubject.Free;
  inherited;
end;

function TDiagnosticReport.ToString: String;
begin
  Result := CodeCoding.Display;
end;

procedure TDiagnosticReport.LoadFromJSON(AJSON: TJSONObject);
var
  CodeObj: TJSONObject;
  CodingArray: TJSONArray;
  SpecArray: TJSONArray;
  ReqArray: TJSONArray;
  PerfObj: TJSONObject;
  ResArray: TJSONArray;
  SubjObj: TJSONObject;
  i: Integer;
  Ref: TReference;
begin
  if AJSON = nil then Exit;

  FResourceType := AJSON.GetValue<string>('resourceType', '');
  FStatus := AJSON.GetValue<string>('status', '');

  if AJSON.TryGetValue<TJSONObject>('code', CodeObj) then
  begin
    if CodeObj.TryGetValue<TJSONArray>('coding', CodingArray) and (CodingArray.Count > 0) then
      FCodeCoding.LoadFromJSON(CodingArray.Items[0] as TJSONObject);
  end;

  FIssued := AJSON.GetValue<string>('issued', '');

  if AJSON.TryGetValue<TJSONArray>('specimen', SpecArray) then
  begin
    for i := 0 to SpecArray.Count - 1 do
    begin
      Ref := TReference.Create;
      Ref.LoadFromJSON(SpecArray.Items[i] as TJSONObject);
      FSpecimen.Add(Ref);
    end;
  end;

  if AJSON.TryGetValue<TJSONArray>('request', ReqArray) then
  begin
    for i := 0 to ReqArray.Count - 1 do
    begin
      Ref := TReference.Create;
      Ref.LoadFromJSON(ReqArray.Items[i] as TJSONObject);
      FRequest.Add(Ref);
    end;
  end;

  if AJSON.TryGetValue<TJSONObject>('performer', PerfObj) then
    FPerformer.LoadFromJSON(PerfObj);

  if AJSON.TryGetValue<TJSONArray>('result', ResArray) then
  begin
    for i := 0 to ResArray.Count - 1 do
    begin
      Ref := TReference.Create;
      Ref.LoadFromJSON(ResArray.Items[i] as TJSONObject);
      FResult.Add(Ref);
    end;
  end;

  FEffectiveDateTime := AJSON.GetValue<string>('effectiveDateTime', '');

  if AJSON.TryGetValue<TJSONObject>('subject', SubjObj) then
    FSubject.LoadFromJSON(SubjObj);
end;

function TDiagnosticReport.ToJSON: TJSONObject;
var
  CodeObj: TJSONObject;
  CodeArray: TJSONArray;
  SpecArray: TJSONArray;
  ReqArray: TJSONArray;
  ResArray: TJSONArray;
  Ref: TReference;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', FResourceType);
  Result.AddPair('status', FStatus);

  CodeArray := TJSONArray.Create;
  CodeObj := TJSONObject.Create;
  CodeObj.AddPair('coding', TJSONArray.Create.Add(FCodeCoding.ToJSON));
  CodeArray.Add(CodeObj);
  Result.AddPair('code', CodeArray);

  Result.AddPair('issued', FIssued);

  SpecArray := TJSONArray.Create;
  for Ref in FSpecimen do
    SpecArray.Add(Ref.ToJSON);
  Result.AddPair('specimen', SpecArray);

  ReqArray := TJSONArray.Create;
  for Ref in FRequest do
    ReqArray.Add(Ref.ToJSON);
  Result.AddPair('request', ReqArray);

  Result.AddPair('performer', FPerformer.ToJSON);

  ResArray := TJSONArray.Create;
  for Ref in FResult do
    ResArray.Add(Ref.ToJSON);
  Result.AddPair('result', ResArray);

  Result.AddPair('effectiveDateTime', FEffectiveDateTime);
  Result.AddPair('subject', FSubject.ToJSON);
end;

{ TPractitioner }

constructor TPractitioner.Create;
begin
  FResourceType := 'Practitioner';
  FName := TName.Create;
  FPractitionerRole := TList<TPractitionerRole>.Create;
  FIdentifier := TList<TIdentifier>.Create;
end;

destructor TPractitioner.Destroy;
var
  Role: TPractitionerRole;
  Ident: TIdentifier;
begin
  FName.Free;
  for Role in FPractitionerRole do
    Role.Free;
  FPractitionerRole.Free;
  for Ident in FIdentifier do
    Ident.Free;
  FIdentifier.Free;
  inherited;
end;

procedure TPractitioner.LoadFromJSON(AJSON: TJSONObject);
var
  NameObj: TJSONObject;
  RoleArray: TJSONArray;
  IdentArray: TJSONArray;
  i: Integer;
  Role: TPractitionerRole;
  Ident: TIdentifier;
begin
  if AJSON = nil then Exit;

  FResourceType := AJSON.GetValue<string>('resourceType', '');

  if AJSON.TryGetValue<TJSONObject>('name', NameObj) then
    FName.LoadFromJSON(NameObj);

  FGender := AJSON.GetValue<string>('gender', '');
  FBirthDate := AJSON.GetValue<string>('birthDate', '');

  if AJSON.TryGetValue<TJSONArray>('practitionerRole', RoleArray) then
  begin
    for i := 0 to RoleArray.Count - 1 do
    begin
      Role := TPractitionerRole.Create;
      Role.LoadFromJSON(RoleArray.Items[i] as TJSONObject);
      FPractitionerRole.Add(Role);
    end;
  end;

  if AJSON.TryGetValue<TJSONArray>('identifier', IdentArray) then
  begin
    for i := 0 to IdentArray.Count - 1 do
    begin
      Ident := TIdentifier.Create;
      Ident.LoadFromJSON(IdentArray.Items[i] as TJSONObject);
      FIdentifier.Add(Ident);
    end;
  end;
end;

function TPractitioner.ToJSON: TJSONObject;
var
  RoleArray: TJSONArray;
  IdentArray: TJSONArray;
  Role: TPractitionerRole;
  Ident: TIdentifier;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', FResourceType);
  Result.AddPair('name', FName.ToJSON);
  if FGender <> '' then
    Result.AddPair('gender', FGender);
  if FBirthDate <> '' then
    Result.AddPair('birthDate', FBirthDate);

  RoleArray := TJSONArray.Create;
  for Role in FPractitionerRole do
    RoleArray.Add(Role.ToJSON);
  Result.AddPair('practitionerRole', RoleArray);

  IdentArray := TJSONArray.Create;
  for Ident in FIdentifier do
    IdentArray.Add(Ident.ToJSON);
  Result.AddPair('identifier', IdentArray);
end;

{ TOrderResponse }

constructor TOrderResponse.Create;
begin
  FResourceType := 'OrderResponse';
  FWho := TReference.Create;
  FRequest := TReference.Create;
  FFulfillment := TList<TReference>.Create;
  FIdentifier := TList<TIdentifier>.Create;
end;

destructor TOrderResponse.Destroy;
var
  Ref: TReference;
  Ident: TIdentifier;
begin
  FWho.Free;
  FRequest.Free;
  for Ref in FFulfillment do
    Ref.Free;
  FFulfillment.Free;
  for Ident in FIdentifier do
    Ident.Free;
  FIdentifier.Free;
  inherited;
end;

procedure TOrderResponse.LoadFromJSON(AJSON: TJSONObject);
var
  WhoObj: TJSONObject;
  RequestObj: TJSONObject;
  FulfillArray: TJSONArray;
  IdentArray: TJSONArray;
  i: Integer;
  Ref: TReference;
  Ident: TIdentifier;
begin
  if AJSON = nil then Exit;

  FResourceType := AJSON.GetValue<string>('resourceType', '');

  if AJSON.TryGetValue<TJSONObject>('who', WhoObj) then
    FWho.LoadFromJSON(WhoObj);

  if AJSON.TryGetValue<TJSONObject>('request', RequestObj) then
    FRequest.LoadFromJSON(RequestObj);

  if AJSON.TryGetValue<TJSONArray>('fulfillment', FulfillArray) then
  begin
    for i := 0 to FulfillArray.Count - 1 do
    begin
      Ref := TReference.Create;
      Ref.LoadFromJSON(FulfillArray.Items[i] as TJSONObject);
      FFulfillment.Add(Ref);
    end;
  end;

  FDate := AJSON.GetValue<string>('date', '');

  if AJSON.TryGetValue<TJSONArray>('identifier', IdentArray) then
  begin
    for i := 0 to IdentArray.Count - 1 do
    begin
      Ident := TIdentifier.Create;
      Ident.LoadFromJSON(IdentArray.Items[i] as TJSONObject);
      FIdentifier.Add(Ident);
    end;
  end;

  FOrderStatus := AJSON.GetValue<string>('orderStatus', '');
end;

function TOrderResponse.OrderId: string;
begin
  Result := '';
  if Identifier.Count > 0 then
    Result := Identifier[0].Value;
end;

function TOrderResponse.ToJSON: TJSONObject;
var
  FulfillArray: TJSONArray;
  IdentArray: TJSONArray;
  Ref: TReference;
  Ident: TIdentifier;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', FResourceType);
  Result.AddPair('who', FWho.ToJSON);
  Result.AddPair('request', FRequest.ToJSON);

  FulfillArray := TJSONArray.Create;
  for Ref in FFulfillment do
    FulfillArray.Add(Ref.ToJSON);
  Result.AddPair('fulfillment', FulfillArray);

  Result.AddPair('date', FDate);

  IdentArray := TJSONArray.Create;
  for Ident in FIdentifier do
    IdentArray.Add(Ident.ToJSON);
  Result.AddPair('identifier', IdentArray);

  Result.AddPair('orderStatus', FOrderStatus);
end;

{ TEntry }

constructor TEntry.Create;
begin
  FRequest := TRequest.Create;
end;

destructor TEntry.Destroy;
begin
  FRequest.Free;
  if Assigned(FResource) then
    FResource.Free;
  inherited;
end;

procedure TEntry.LoadFromJSON(AJSON: TJSONObject);
var
  ResourceObj: TJSONObject;
  RequestObj: TJSONObject;
  ResType: string;
begin
  if AJSON = nil then Exit;

  FFullUrl := AJSON.GetValue<string>('fullUrl', '');

  if AJSON.TryGetValue<TJSONObject>('resource', ResourceObj) then
  begin
    ResType := ResourceObj.GetValue<string>('resourceType', '');
    FResourceType := ResType;

    if ResType = 'Specimen' then
    begin
      FResource := TSpecimen.Create;
      TSpecimen(FResource).LoadFromJSON(ResourceObj);
    end
    else if ResType = 'Observation' then
    begin
      FResource := TObservation.Create;
      TObservation(FResource).LoadFromJSON(ResourceObj);
    end
    else if ResType = 'DiagnosticReport' then
    begin
      FResource := TDiagnosticReport.Create;
      TDiagnosticReport(FResource).LoadFromJSON(ResourceObj);
    end
    else if ResType = 'Practitioner' then
    begin
      FResource := TPractitioner.Create;
      TPractitioner(FResource).LoadFromJSON(ResourceObj);
    end
    else if ResType = 'OrderResponse' then
    begin
      FResource := TOrderResponse.Create;
      TOrderResponse(FResource).LoadFromJSON(ResourceObj);
    end;
  end;

  if AJSON.TryGetValue<TJSONObject>('request', RequestObj) then
    FRequest.LoadFromJSON(RequestObj);
end;

procedure TEntry.SetBundle(const Value: TBundle);
begin
  FBundle := Value;
end;

function TEntry.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('fullUrl', FFullUrl);

  if Assigned(FResource) then
  begin
    if FResource is TSpecimen then
      Result.AddPair('resource', TSpecimen(FResource).ToJSON)
    else if FResource is TObservation then
      Result.AddPair('resource', TObservation(FResource).ToJSON)
    else if FResource is TDiagnosticReport then
      Result.AddPair('resource', TDiagnosticReport(FResource).ToJSON)
    else if FResource is TPractitioner then
      Result.AddPair('resource', TPractitioner(FResource).ToJSON)
    else if FResource is TOrderResponse then
      Result.AddPair('resource', TOrderResponse(FResource).ToJSON);
  end;

  Result.AddPair('request', FRequest.ToJSON);
end;

{ TProfile }

procedure TProfile.LoadFromJSON(AJSON: TJSONArray);
begin
  if (AJSON <> nil) and (AJSON.Count > 0) then
    FProfile := AJSON.Items[0].Value;
end;

function TProfile.ToJSON: TJSONArray;
begin
  Result := TJSONArray.Create;
  Result.Add(FProfile);
end;

{ TMeta }

constructor TMeta.Create;
begin
  FProfile := TProfile.Create;
end;

destructor TMeta.Destroy;
begin
  FProfile.Free;
  inherited;
end;

procedure TMeta.LoadFromJSON(AJSON: TJSONObject);
var
  ProfileArray: TJSONArray;
begin
  if AJSON = nil then Exit;

  if AJSON.TryGetValue<TJSONArray>('profile', ProfileArray) then
    FProfile.LoadFromJSON(ProfileArray);
end;

function TMeta.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('profile', FProfile.ToJSON);
end;

{ TBundle }

constructor TBundle.Create;
begin
  FResourceType := 'Bundle';
  FEntry := TList<TEntry>.Create;
  FMeta := TMeta.Create;
end;

destructor TBundle.Destroy;
var
  Entry: TEntry;
begin
  for Entry in FEntry do
    Entry.Free;
  FEntry.Free;
  FMeta.Free;
  inherited;
end;

function TBundle.FindResources<T>: TArray<T>;
begin
  Result := nil;
  for var vEntry in Entry do
  begin
    if (vEntry.Resource is T) then
    begin
      Result := Result + [vEntry.Resource as T];
    end;
  end;
end;

function TBundle.IsValid: Boolean;
var
  vOrderResponce: TOrderResponse;
begin
  Result := TryFindResourceByFullUrl<TOrderResponse>('', vOrderResponce);
  Result := Result and (vOrderResponce.OrderStatus = 'completed');
end;

procedure TBundle.LoadFromJSON(AJSON: TJSONObject);
var
  EntryArray: TJSONArray;
  i: Integer;
  EntryObj: TJSONObject;
  MetaObj: TJSONObject;
  Entry: TEntry;
begin
  if AJSON = nil then Exit;

  FResourceType := AJSON.GetValue<string>('resourceType', '');
  FType := AJSON.GetValue<string>('type', '');

  if AJSON.TryGetValue<TJSONArray>('entry', EntryArray) then
  begin
    for i := 0 to EntryArray.Count - 1 do
    begin
      EntryObj := EntryArray.Items[i] as TJSONObject;
      Entry := TEntry.Create;
      Entry.LoadFromJSON(EntryObj);
      Entry.Bundle := Self;
      FEntry.Add(Entry);
    end;
  end;

  if AJSON.TryGetValue<TJSONObject>('meta', MetaObj) then
    FMeta.LoadFromJSON(MetaObj);
end;

function TBundle.ToJSON: TJSONObject;
var
  EntryArray: TJSONArray;
  Entry: TEntry;
begin
  Result := TJSONObject.Create;
  Result.AddPair('resourceType', FResourceType);
  Result.AddPair('type', FType);

  EntryArray := TJSONArray.Create;
  for Entry in FEntry do
    EntryArray.Add(Entry.ToJSON);
  Result.AddPair('entry', EntryArray);

  Result.AddPair('meta', FMeta.ToJSON);
end;

function TBundle.TryFindEntryByFullUrl(AFullUrl: string; out AResult: TEntry):
    Boolean;
begin
  AResult := nil;
  if AFullUrl <> '' then
  begin
    for var vEntry in Entry do
    begin
      if AnsiSameText(vEntry.FullUrl, AFullUrl) then
      begin
        AResult := vEntry;
        Break;
      end;
    end;
  end;
  Result := AResult <> nil;
end;

function TBundle.TryFindFirstResource<T>(out AResult: T): Boolean;
begin
  Result := TryFindResourceByFullUrl<T>('', AResult);
end;

function TBundle.TryFindResourceByFullUrl<T>(AFullUrl: string; out AResult: T):
    Boolean;
begin
  AResult := nil;
  for var vEntry in Entry do
  begin
    if ((AFullUrl = '') or AnsiSameText(vEntry.FullUrl, AFullUrl))
      and (vEntry.Resource is T) then
    begin
      AResult := vEntry.Resource as T;
      Break;
    end;
  end;
  Result := AResult <> nil;
end;

{ TJSONToModelConverter }

class function TJSONToModelConverter.ParseBundle(const AJSONString: string): TBundle;
var
  JSONObject: TJSONObject;
begin
  Result := nil;
  JSONObject := TJSONObject.ParseJSONValue(AJSONString) as TJSONObject;
  try
    if Assigned(JSONObject) then
      Result := ParseBundle(JSONObject);
  finally
    JSONObject.Free;
  end;
end;

class function TJSONToModelConverter.ParseBundle(AJSONObject: TJSONObject): TBundle;
begin
  Result := TBundle.Create;
  try
    Result.LoadFromJSON(AJSONObject);
  except
    Result.Free;
    raise;
  end;
end;

end.
