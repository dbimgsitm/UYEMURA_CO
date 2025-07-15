@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'G/L 평가클래스 기준정보 Hisotry View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_GLMtValuationClass_Master_H
  as select from ztgsco0010h as Hisotry
  association [0..*] to ZI_GLMtValuationClass_Master as _Main on $projection.Refhead = _Main.Id  
{
  key Hisotry.id                     as Id,
      Hisotry.refhead                as Refhead,
      Hisotry.action                 as Action,
      Hisotry.matvaluationclass      as Matvaluationclass,
      Hisotry.matlvaluationclasstext as Matlvaluationclasstext,
      Hisotry.glaccount              as Glaccount,
      Hisotry.glaccountname          as Glaccountname,
      Hisotry.delete_flag            as DeleteFlag,
      @Semantics.user.createdBy: true
      Hisotry.created_by             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      Hisotry.created_at             as CreatedAt,
      @Semantics.user.lastChangedBy: true
      Hisotry.last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      Hisotry.last_changed_at        as LastChangedAt,

      //Association
      _Main
}
