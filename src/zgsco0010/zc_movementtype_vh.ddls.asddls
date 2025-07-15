@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입출고타입 기준정보 ValueHelp View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_MOVEMENTTYPE_VH
  as select from ZI_MovementType_Master
{
      @UI.hidden: true
  key Id,
      @EndUserText : {
        label: '입출고타입',
        quickInfo: '입출고타입'
      }
      Movementtype,
      @EndUserText : {
        label: '입출고타입명',
        quickInfo: '입출고타입명'
      }
      Movementtypename
}
where
  DeleteFlag != 'X'
