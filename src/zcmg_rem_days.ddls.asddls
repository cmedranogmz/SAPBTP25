@AbapCatalog.sqlViewName: 'ZCMGV_REM_DAYS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Remaining days'
@Metadata.ignorePropagatedAnnotations: true
define view ZCMG_REM_DAYS
  as select from zcmg_rent_cars
{
  key matricula as Matricula,
      marca     as Marca,
      case
      when alq_hasta <> ''
      then dats_days_between( cast($session.system_date as abap.dats ), alq_hasta )
      end       as Dias
}
