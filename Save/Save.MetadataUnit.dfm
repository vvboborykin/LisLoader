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
    Left = 104
    Top = 40
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'ActionTypeId'
        Value = nil
      end>
  end
  object dsActionType: TDataSource
    DataSet = qryActionType
    Left = 104
    Top = 96
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
    Left = 200
    Top = 40
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        Value = nil
      end>
  end
  object dsPropType: TDataSource
    DataSet = qryPropType
    Left = 200
    Top = 96
  end
  object qryUnit: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT *'
      'FROM rbUnit u'
      'WHERE u.code = :Code')
    Left = 280
    Top = 40
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Code'
        Value = nil
      end>
  end
  object dsUnit: TDataSource
    DataSet = qryUnit
    Left = 280
    Top = 96
  end
  object qryTest: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT *'
      'FROM rbTest t'
      'WHERE t.code = :Code')
    Left = 352
    Top = 40
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Code'
        Value = nil
      end>
  end
  object dsTest: TDataSource
    DataSet = qryTest
    Left = 352
    Top = 96
  end
  object qryActionLis: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT * '
      'FROM s11.Action_LIS al '
      'WHERE al.diagnosticOrderLIS_id = :RequestUid'
      'AND al.order_id = :OrderId')
    Left = 104
    Top = 168
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
    Left = 104
    Top = 224
  end
  object qryAction: TUniQuery
    Connection = CmcoSaveDataModule.conMain
    SQL.Strings = (
      'SELECT *'
      'FROM Action a'
      'WHERE a.deleted = 0'
      'AND a.id = :ActionId')
    Left = 200
    Top = 168
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'ActionId'
        Value = nil
      end>
  end
  object dsAction: TDataSource
    DataSet = qryAction
    Left = 200
    Top = 224
  end
end
