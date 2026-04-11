unit AppStringsUnit;

interface

const
  SBundle = 'Bundle';
  SOrder = 'Order';
  SResourceType = 'resourceType';
  SOrderStatus = 'orderStatus';
  SCompleted = 'completed';
  SCancelled = 'cancelled';
  SRejected = 'rejected';
  SPending = 'pending';
  SFinal = 'final';

resourcestring
  SOrderResponseNotFound = 'В ответе заказа %s не найден элемент OrderResponse';
  SOrderIsCompleted = 'Заказ %s исполнен';
  SOrderIsCancelled = 'Заказ %s отменен';
  SOrderIsRejected = 'Заказ %s отказан';
  SOrderIsPending = 'Заказ %s в стадии исполнения';


implementation

end.
