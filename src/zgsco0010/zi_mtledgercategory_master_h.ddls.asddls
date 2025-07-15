@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재원장 기준정보 History View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MtLedgerCategory_Master_H
  as select from ztgsco0030h as History
  association [0..*] to ZI_MtLedgerCategory_Master as _Main on $projection.Refhead = _Main.Id
{
  key History.id                         as Id,
      History.refhead                    as Refhead,
      History.action                     as Action,
      History.movementtype               as Movementtype,
      History.movementtypename           as Movementtypename,
      History.materialledgercategory     as Materialledgercategory,
      History.materialledgercategorytext as Materialledgercategorytext,
      History.check_detailed             as CheckDetailed,
      History.delete_flag                as DeleteFlag,
      History.created_by                 as CreatedBy,
      History.created_at                 as CreatedAt,
      History.last_changed_by            as LastChangedBy,
      History.last_changed_at            as LastChangedAt,

      //Association
      _Main
}
