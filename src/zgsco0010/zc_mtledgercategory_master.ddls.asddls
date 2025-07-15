@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재원장 기준정보 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: '자재원장',
        typeNamePlural: '자재원장',
        title: { type: #STANDARD, value: 'Materialledgercategory' },
        description: { type: #STANDARD, value: 'Materialledgercategorytext' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'Movementtype', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_MTLEDGERCATEGORY_MASTER
  provider contract transactional_query
  as projection on ZI_MtLedgerCategory_Master
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
              label: '자재원장',
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
      @Consumption.valueHelpDefinition: [{
        entity: {
            name : 'ZC_MOVEMENTTYPE_VH',
            element : 'Movementtype'
        },
        additionalBinding: [{
            element: 'Movementtypename',
            localElement: 'Movementtypename',
            usage: #RESULT
        }]
      }]
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
      @UI: {
          lineItem: [{ position: 30, label:'자재원장', importance: #HIGH } ],
          fieldGroup: [
            { position: 30, qualifier: 'FIELD_INFO', label:'자재원장' }
          ],
          selectionField: [{ position: 20 }]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '자재원장',
        quickInfo: '자재원장'
      }
      Materialledgercategory,
      @UI: {
          lineItem: [{ position: 40, label:'자재원장명', importance: #HIGH } ],
          fieldGroup: [
            { position: 40, qualifier: 'FIELD_INFO', label:'자재원장명' }
          ]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '자재원장명',
        quickInfo: '자재원장명'
      }
      Materialledgercategorytext,
      @UI: {
          lineItem: [{ position: 50, label:'상세표시여부', importance: #HIGH } ],
          fieldGroup: [
            { position: 50, qualifier: 'FIELD_INFO', label:'상세표시여부' }
          ]
        }
      @EndUserText : {
        label: '상세표시여부',
        quickInfo: '상세표시여부'
      }
      CheckDetailed,
      /* Associations */
      _History,
      _Movement
}
where
  DeleteFlag != 'X'
