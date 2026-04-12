object Metadata: TMetadata
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object qryActionType: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT * '
      'FROM ActionType aty'
      'WHERE aty.deleted = 0'
      'AND aty.id = :ActionTypeId')
    Left = 48
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'ActionTypeId'
        Value = nil
      end>
  end
  object dsActionType: TDataSource
    DataSet = qryActionType
    Left = 48
    Top = 80
  end
  object qryPropType: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT *'
      'FROM ActionPropertyType apt'
      'WHERE apt.deleted = 0')
    MasterSource = dsActionType
    MasterFields = 'id'
    DetailFields = 'actionType_id'
    Left = 144
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        Value = nil
      end>
  end
  object dsPropType: TDataSource
    DataSet = qryPropType
    Left = 144
    Top = 80
  end
  object qryUnit: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT *'
      'FROM rbUnit u'
      'WHERE u.code = :Code')
    Left = 224
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Code'
        Value = nil
      end>
  end
  object dsUnit: TDataSource
    DataSet = qryUnit
    Left = 224
    Top = 80
  end
  object qryTest: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT *'
      'FROM rbTest t'
      'WHERE t.code = :Code')
    Left = 296
    Top = 24
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Code'
        Value = nil
      end>
  end
  object dsTest: TDataSource
    DataSet = qryTest
    Left = 296
    Top = 80
  end
  object qryActionLis: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT * '
      'FROM s11.Action_LIS al '
      'WHERE al.diagnosticOrderLIS_id = :RequestUid'
      'AND al.order_id = :OrderId')
    Left = 48
    Top = 152
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'RequestUid'
        Value = nil
      end
      item
        DataType = ftUnknown
        Name = 'OrderId'
        Value = nil
      end>
  end
  object dsActionLis: TDataSource
    DataSet = qryActionLis
    Left = 48
    Top = 208
  end
end
