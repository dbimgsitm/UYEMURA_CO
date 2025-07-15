@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'G/L 평가클래스 기준정보 + 자재 View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_GLMtValuationClass_product
  as select from ZI_GLMtValuationClass_Master as Main
  association [0..*] to I_ProductValuationBasic as _Product on $projection.Matvaluationclass = _Product.ValuationClass
{
  key Main.Id,
      Main.Matvaluationclass,
      Main.Matlvaluationclasstext,
      Main.Glaccount,
      Main.Glaccountname,

      _Product.Product,
      _Product.ValuationClass,

      Main.DeleteFlag,
      Main.CreatedBy,
      Main.CreatedAt,
      Main.LastChangedBy,
      Main.LastChangedAt,
      /* Associations */
      Main._History,

      _Product
}
