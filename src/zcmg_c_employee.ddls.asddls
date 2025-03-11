@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Employee'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCMG_C_EMPLOYEE
  as projection on ZCMG_I_EMPLOYEE
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
