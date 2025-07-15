@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재원장 기준정보 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MtLedgerCategory_Master
  as select from ztgsco0030 as Main
  association [*] to ZI_MtLedgerCategory_Master_H as _History  on  $projection.Id = _History.Refhead
  association [*] to ZI_MovementType_Master       as _Movement on  $projection.Movementtype     = _Movement.Movementtype
                                                               and $projection.Movementtypename = _Movement.Movementtypename
{
  key Main.id                         as Id,
      Main.movementtype               as Movementtype,
      Main.movementtypename           as Movementtypename,
      Main.materialledgercategory     as Materialledgercategory,
      Main.materialledgercategorytext as Materialledgercategorytext,
      Main.check_detailed             as CheckDetailed,
      Main.delete_flag                as DeleteFlag,
      Main.created_by                 as CreatedBy,
      Main.created_at                 as CreatedAt,
      Main.last_changed_by            as LastChangedBy,
      Main.last_changed_at            as LastChangedAt,
      //Association
      _History,
      _Movement
}
