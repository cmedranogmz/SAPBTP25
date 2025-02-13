@AbapCatalog.sqlViewName: 'ZCMGV_RENTING'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vista Intermecia  - Renting'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view ZCMG_I_RENTING
  as select from ZCMG_CARS as Cars
  association [1]    to ZCMG_REM_DAYS     as _RemDays     on Cars.Matricula = _RemDays.Matricula
  association [0..*] to ZCMG_BRANDS       as _Brands      on Cars.Marca = _Brands.Marca
  association [0..*] to ZCMG_DET_CUSTOMER as _DetCustomer on Cars.Matricula = _DetCustomer.Matricula
{
  key Matricula,
      Marca,
      Modelo,
      Color,
      Motor,
      Potencia,
      Unidad,
      Combustible,
      Consumo,
      FechaFabricacion,
      Puertas,
      Precio,
      Moneda,
      Alquilado,
      Desde,
      Hasta,
      case
      when _RemDays.Dias <= 0               then 0
      when _RemDays.Dias between 1 and 30   then 1
      when _RemDays.Dias between 31 and 100 then 2
      when _RemDays.Dias > 100              then 3
      end as TiempoRenta,
      case
      when _RemDays.Dias <= 0               then 'New'
      when _RemDays.Dias between 1 and 30   then 'Error'
      when _RemDays.Dias between 31 and 100 then 'In progress'
      when _RemDays.Dias > 100              then 'Delivered'
      else 'New'
      end as Estado,
      _Brands.Imagen,
      _DetCustomer

}
