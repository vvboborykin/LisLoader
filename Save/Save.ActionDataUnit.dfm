object ActionData: TActionData
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object qryAction: TUniQuery
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
  object qryActionProperty: TUniQuery
    SQL.Strings = (
      'SELECT *'
      'FROM ActionProperty ap'
      'WHERE ap.deleted = 0;')
    MasterSource = dsAction
    MasterFields = 'id'
    DetailFields = 'action_id'
    BeforePost = qryActionBeforePost
    Left = 200
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
    Left = 200
    Top = 144
  end
  object qryPropValue: TUniQuery
    SQL.Strings = (
      'SELECT *'
      'FROM &TableName')
    MasterSource = dsActionProperty
    MasterFields = 'id'
    DetailFields = 'id'
    BeforePost = qryActionBeforePost
    Left = 304
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
    Left = 304
    Top = 144
  end
end
