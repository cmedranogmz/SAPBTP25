@AbapCatalog.sqlViewName: 'ZCMGV_BRANDS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Brands'
@Metadata.ignorePropagatedAnnotations: true
define view ZCMG_BRANDS
  as select from zcmg_rent_brands
{
  key marca as Marca,
      @UI.hidden: true
      url   as Imagen
}
