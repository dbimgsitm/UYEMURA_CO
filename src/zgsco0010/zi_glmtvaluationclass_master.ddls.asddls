@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'G/L 평가클래스 기준정보 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_GLMtValuationClass_Master
  as select from ztgsco0010 as Main
  association [*] to ZI_GLMtValuationClass_Master_H as _History on $projection.Id = _History.Refhead
{
  key id                     as Id,
      matvaluationclass      as Matvaluationclass,
      matlvaluationclasstext as Matlvaluationclasstext,
      glaccount              as Glaccount,
      glaccountname          as Glaccountname,
      delete_flag            as DeleteFlag,
      @Semantics.user.createdBy: true
      created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,

      //Association
      _History
}
