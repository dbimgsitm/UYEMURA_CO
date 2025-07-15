@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입출고타입 기준정보 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MovementType_Master
  as select from ztgsco0020 as Main
  association [*] to ZI_MovementType_Master_H as _History on $projection.Id = _History.Refhead
  association [1..*] to ZI_MtLedgerCategory_Master as _Ledger on $projection.Movementtype = _Ledger.Movementtype
                                                             and $projection.Movementtypename = _Ledger.Movementtypename
{
  key Main.id               as Id,
      Main.movementtype     as Movementtype,
      Main.movementtypename as Movementtypename,
      Main.delete_flag      as DeleteFlag,
      @Semantics.user.createdBy: true
      Main.created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      Main.created_at       as CreatedAt,
      @Semantics.user.lastChangedBy: true
      Main.last_changed_by  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      Main.last_changed_at  as LastChangedAt,

      //Association
      _History,
      _Ledger
}
