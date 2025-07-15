@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '타계정출고 이동유형 기준정보 Projection View'
@Search.searchable: true
@UI: {
    headerInfo: {
        typeName: '타계정출고 이동유형',
        typeNamePlural: '타계정출고 이동유형',
        title: { type: #STANDARD, value: 'Goodsmovementtype' },
        description: { type: #STANDARD, value: 'Externalaccountname' }
    },
    presentationVariant: [{
     sortOrder: [{ by: 'Goodsmovementtype', direction: #ASC }],
     visualizations: [{type: #AS_LINEITEM}]
    }]
}
define root view entity ZC_ExternalAccountTransferOut  
  provider contract transactional_query
  as projection on ZI_ExternalAccountTransferOut
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
            label: '타계정출고 이동유형',
            purpose: #STANDARD,
            type: #FIELDGROUP_REFERENCE,
            targetQualifier: 'FIELD_INFO'
         }
        ]

      @UI.hidden: true
  key Id,
      @UI: {
          lineItem: [{ position: 10, label:'이동유형', importance: #HIGH } ],
          fieldGroup: [
            { position: 10, qualifier: 'FIELD_HEADER', label:'이동유형' },
            { position: 10, qualifier: 'FIELD_INFO', label:'이동유형' }
          ],
          selectionField: [{ position: 10 }]
        }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '이동유형',
        quickInfo: '이동유형'
      }
      Goodsmovementtype,
      @UI: {
          lineItem: [{ position: 20, label:'이동유형명', importance: #HIGH } ],
          fieldGroup: [
            { position: 20, qualifier: 'FIELD_INFO', label:'이동유형명' }
          ]
       }
      @Search: {
        defaultSearchElement: true,
        fuzzinessThreshold: 0.7,
        ranking: #HIGH
      }
      @EndUserText : {
        label: '이동유형명',
        quickInfo: '이동유형명'
      }
      Externalaccountname,
      /* Associations */
      _History
}
where
  DeleteFlag != 'X'
