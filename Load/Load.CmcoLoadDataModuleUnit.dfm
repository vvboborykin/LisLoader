inherited CmcoLoadDataModule: TCmcoLoadDataModule
  OnCreate = DataModuleCreate
  Width = 952
  inherited conMain: TUniConnection
    EncryptedPassword = '9BFF9DFF8FFF9EFF8CFF8CFF88FF90FF8DFF9BFF'
  end
  object qryPendingOrders: TUniQuery
    Connection = conMain
    SQL.Strings = (
      'SELECT * FROM ('
      
        'SELECT e.client_id, CONCAT_WS('#39' '#39', c.lastName, c.firstName, c.pa' +
        'trName)  AS client_fio, c.birthDate, a.isUrgent, p.externalId'
      'FROM Probe p'
      'JOIN Action a ON p.id = a.probe_id'
      'JOIN Event e ON a.event_id = e.id'
      'JOIN Client c ON e.client_id = c.id'
      'WHERE p.status = 1 AND a.deleted = 0 AND e.deleted = 0'
      'AND a.begDate >= DATE_SUB(CURRENT_DATE(), INTERVAL &Days DAY)'
      'ORDER BY a.isUrgent DESC, a.begDate) b'
      
        'GROUP BY b.client_id, b.client_fio, b.birthDate, b.isUrgent, b.e' +
        'xternalId'
      'ORDER BY b.isUrgent DESC, b.externalId'
      'LIMIT &Limit')
    ReadOnly = True
    Left = 120
    Top = 88
    MacroData = <
      item
        Name = 'Days'
        Value = '7'
      end
      item
        Name = 'Limit'
        Value = '1000'
      end>
  end
  object dsPendingOrders: TDataSource
    DataSet = qryPendingOrders
    Left = 120
    Top = 144
  end
end
