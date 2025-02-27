@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Travel'
@Metadata.allowExtensions: true
define root view entity ZCMG_C_TRAVEL
  as projection on ZCMG_I_TRAVEL
{
  key     TravelId,
          @ObjectModel.text.element: [ 'AgencyName' ]
          AgencyId,
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: [ 'AgencyName' ]
          CustomerId,
          _Customer.LastName as CustomerName,
          BeginDate,
          EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice,
          @Semantics.currencyCode: true
          CurrencyCode,
          Description,
          OverallStatus,
          LastChangedAt,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCMG_CL_VIRT_ELEMT'
  virtual DiscountPrice : /dmo/total_price,
          /* Associations */
          _Agency,
          _Booking : redirected to composition child ZCMG_C_BOOKING,
          _Currency,
          _Customer
}
