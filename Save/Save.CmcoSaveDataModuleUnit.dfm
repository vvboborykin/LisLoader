inherited CmcoSaveDataModule: TCmcoSaveDataModule
  OnCreate = DataModuleCreate
  Width = 952
  inherited conMain: TUniConnection
    EncryptedPassword = '9BFF9DFF8FFF9EFF8CFF8CFF88FF90FF8DFF9BFF'
  end
  object qryActionLis: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT * '
      'FROM s11.Action_LIS al '
      'WHERE al.diagnosticOrderLIS_id = :RequestUid'
      'AND al.order_id = :OrderId')
    Left = 16
    Top = 88
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
    Left = 16
    Top = 144
  end
  object qryAction: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT *'
      'FROM Action a'
      'WHERE a.deleted = 0'
      'AND a.id = :ActionId')
    BeforePost = qryActionBeforePost
    Left = 112
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'ActionId'
        Value = nil
      end>
  end
  object dsAction: TDataSource
    DataSet = qryAction
    Left = 112
    Top = 144
  end
  object qryActionType: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT * '
      'FROM ActionType aty'
      'WHERE aty.deleted = 0'
      'AND aty.id = :ActionTypeId')
    BeforePost = qryActionBeforePost
    Left = 208
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'ActionTypeId'
        Value = nil
      end>
  end
  object dsActionType: TDataSource
    DataSet = qryActionType
    Left = 208
    Top = 144
  end
  object qryPropType: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT *'
      'FROM ActionPropertyType apt'
      'WHERE apt.deleted = 0')
    MasterSource = dsActionType
    MasterFields = 'id'
    DetailFields = 'actionType_id'
    Left = 304
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        Value = nil
      end>
  end
  object dsPropType: TDataSource
    DataSet = qryPropType
    Left = 304
    Top = 144
  end
  object qryUnit: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT *'
      'FROM rbUnit u'
      'WHERE u.code = :Code')
    Left = 384
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Code'
        Value = nil
      end>
  end
  object dsUnit: TDataSource
    DataSet = qryUnit
    Left = 384
    Top = 144
  end
  object qryTest: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT *'
      'FROM rbTest t'
      'WHERE t.code = :Code')
    Left = 456
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'Code'
        Value = nil
      end>
  end
  object dsTest: TDataSource
    DataSet = qryTest
    Left = 456
    Top = 144
  end
  object qryActionProperty: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT *'
      'FROM ActionProperty ap'
      'WHERE ap.deleted = 0;')
    MasterSource = dsAction
    MasterFields = 'id'
    DetailFields = 'action_id'
    BeforePost = qryActionBeforePost
    Left = 544
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        Value = nil
      end>
  end
  object dsActionProperty: TDataSource
    DataSet = qryActionProperty
    Left = 544
    Top = 144
  end
  object qryPropValue: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT *'
      'FROM &TableName')
    MasterSource = dsActionProperty
    MasterFields = 'id'
    DetailFields = 'id'
    Left = 648
    Top = 88
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        Value = nil
      end>
    MacroData = <
      item
        Name = 'TableName'
        Value = 'ActionProperty_String'
      end>
  end
  object dsPropValue: TDataSource
    DataSet = qryPropValue
    Left = 648
    Top = 144
  end
end
