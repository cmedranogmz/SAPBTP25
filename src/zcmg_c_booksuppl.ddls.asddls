@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Booking Supplement'
@Metadata.allowExtensions: true
define view entity ZCMG_C_BOOKSUPPL
  as projection on ZCMG_I_BOOKSUPPL
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      @Semantics.currencyCode: true
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Travel  : redirected to ZCMG_C_TRAVEL,
      _Booking : redirected to parent ZCMG_C_BOOKING,
      _Product,
      _SupplementText

}
