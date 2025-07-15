@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '입출고타입 기준정보 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: '입출고타입',
        typeNamePlural: '입출고타입',
        title: { type: #STANDARD, value: 'Movementtype' },
        description: { type: #STANDARD, value: 'Movementtypename' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'Movementtype', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_MovementType_Master
  provider contract transactional_query
  as projection on ZI_MovementType_Master
{
      @UI.facet: [
             {
                id: 'Header',
                purpose: #HEADER,
                type: #FIELDGROUP_REFERENCE,
                targetQualifier: 'FIELD_HEADER'
             },
             {
                id: 'Item',
                label: '입출고타입',
                purpose: #STANDARD,
                type: #FIELDGROUP_REFERENCE,
                targetQualifier: 'FIELD_INFO'
             }
            ]

      @UI.hidden: true
  key Id,
      @UI: {
          lineItem: [{ position: 10, label:'입출고타입', importance: #HIGH } ],
          fieldGroup: [
            { position: 10, qualifier: 'FIELD_HEADER', label:'입출고타입' },
            { position: 10, qualifier: 'FIELD_INFO', label:'입출고타입' }
          ],
          selectionField: [{ position: 10 }]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '입출고타입',
        quickInfo: '입출고타입'
      }
      Movementtype,
      @UI: {
          lineItem: [{ position: 20, label:'입출고타입명', importance: #HIGH } ],
          fieldGroup: [
            { position: 20, qualifier: 'FIELD_HEADER', label:'입출고타입명' },
            { position: 20, qualifier: 'FIELD_INFO', label:'입출고타입명' }
          ]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '입출고타입명',
        quickInfo: '입출고타입명'
      }
      Movementtypename,
      /* Associations */
      _History,
      _Ledger
}
where
  DeleteFlag != 'X'
