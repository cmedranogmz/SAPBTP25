@AbapCatalog.sqlViewName: 'ZCMGV_DET_CUSTOM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Details Cuscomer'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view ZCMG_DET_CUSTOMER
  as select from zcmg_rent_custom
{
  key doc_id    as ID,
  key matricula as Matricula,
      nombres   as Nombre,
      apellidos as Apellido,
      email     as Correo,
      cntr_type as TipoContrato
}
