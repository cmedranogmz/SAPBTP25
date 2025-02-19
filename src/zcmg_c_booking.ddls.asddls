@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking'
@Metadata.allowExtensions: true
define view entity ZCMG_C_BOOKING
  as projection on ZCMG_I_BOOKING
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      BookingStatus,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Travel            : redirected to parent ZCMG_C_TRAVEL,
      _BookingSupplement : redirected to composition child ZCMG_C_BOOKSUPPL,
      _Carrier,
      _Connection,
      _Customer
}
