@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입출고타입 기준정보 History View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MovementType_Master_H
  as select from ztgsco0020h as History
  association [0..*] to ZI_MovementType_Master as _Main on $projection.Refhead = _Main.Id
{
  key History.id               as Id,
      History.refhead          as Refhead,
      History.action           as Action,
      History.movementtype     as Movementtype,
      History.movementtypename as Movementtypename,
      History.delete_flag      as DeleteFlag,
      @Semantics.user.createdBy: true
      History.created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      History.created_at       as CreatedAt,
      @Semantics.user.lastChangedBy: true
      History.last_changed_by  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      History.last_changed_at  as LastChangedAt,

      //Association
      _Main
}
