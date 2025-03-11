@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Employee'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
} 
define root view entity ZCMG_I_EMPLOYEE
  as select from zcmg_employee as Employee
{
  key e_number         as ENumber,
      e_name           as EName,
      e_departament    as EDepartament,
      status           as Status,
      job_title        as JobTitle,
      start_date       as StartDate,
      end_date         as EndDate,
      email            as Email,
      m_number         as MNumber,
      m_name           as MName,
      m_departament    as MDepartament,
      create_date_time as CreateDateTime,
      create_uname     as CreateUname,
      last_change_date as LastChangeDate,
      last_change_by   as LastChangeBy
}
