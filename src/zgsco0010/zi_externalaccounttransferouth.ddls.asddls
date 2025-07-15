@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '타계정출고 이동유형 기준정보 History View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ExternalAccountTransferOutH
  as select from ztgsco0040h as History
  association [0..*] to ZI_ExternalAccountTransferOut as _Main on $projection.Refhead = _Main.Id
{
  key History.id                  as Id,
      History.refhead             as Refhead,
      History.action              as Action,
      History.goodsmovementtype   as Goodsmovementtype,
      History.externalaccountname as Externalaccountname,
      History.delete_flag         as DeleteFlag,
      History.created_by          as CreatedBy,
      History.created_at          as CreatedAt,
      History.last_changed_by     as LastChangedBy,
      History.last_changed_at     as LastChangedAt,
      //Association
      _Main
}
