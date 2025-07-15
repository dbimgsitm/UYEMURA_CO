@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '타계정출고 이동유형 기준정보 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ExternalAccountTransferOut
  as select from ztgsco0040 as Main
  association [*] to ZI_ExternalAccountTransferOutH as _History on $projection.Id = _History.Refhead
{
  key Main.id                  as Id,
      Main.goodsmovementtype   as Goodsmovementtype,
      Main.externalaccountname as Externalaccountname,
      Main.delete_flag         as DeleteFlag,
      Main.created_by          as CreatedBy,
      Main.created_at          as CreatedAt,
      Main.last_changed_by     as LastChangedBy,
      Main.last_changed_at     as LastChangedAt,
      //Association
      _History
}
