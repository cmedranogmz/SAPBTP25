@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - HCM'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCMG_C_HCM
  as projection on ZCMG_I_HCM
{
//      @ObjectModel.text.element: [ 'EmployeeName' ]
  key ENumber      as EmployeeNumber,
      EName        as EmployeeName,
      EDepartament as EmployeeDepartament,
      Status       as EmployeeStatus,
      JobTitle,
      StartDate,
      EndDate,
      Email,
//      @ObjectModel.text.element: [ 'ManagerName' ]
      MNumber      as ManagerNumber,
      MName        as ManagerName,
      MDepartament as ManagerDepartament,
      CreateDateTime,
      @Semantics.user.createdBy: true
      CreateUname,
      LastChangeDate,
      @Semantics.user.lastChangedBy: true
      LastChangeBy

}
