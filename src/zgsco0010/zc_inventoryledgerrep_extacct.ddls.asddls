@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '재고수불부(타계정출고 상세) 메인'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_INVENTORYLEDGERREP_EXTACCT 
  with parameters
    P_CostingRunType : ckml_run_type,
    P_FiscalPeriod   : fins_fiscalperiod,
    P_FiscalYear     : fis_gjahr_no_conv
  as select from I_ActlCostgMatlValueChainItem(
                 P_CostingRunType : $parameters.P_CostingRunType,
                 P_FiscalPeriod   : $parameters.P_FiscalPeriod,
                 P_FiscalYear     : $parameters.P_FiscalYear ) as Main
  association [1..1] to ZI_GLMtValuationClass_product as _MasterGL on $projection.Material = _MasterGL.Product 
  association [1..1] to I_ProductText as _ProductText on $projection.Material = _ProductText.Product 
{
     key Main.CostEstimate,
  key Main.CurrencyRole,
  key Main.Ledger,
  key Main.FiscalYearPeriod,
  key Main.MaterialLedgerCategory,
  key Main.ProcessCategory,
  key Main.MatlLdgrDocIsCostingRelevant,
  key Main.ProcurementAlternative,
  key Main.ProductionProcess,
  key Main.MovementType,
  key Main.GLAccount,
  

      $parameters.P_CostingRunType as InputCostingRunType,
      $parameters.P_FiscalPeriod   as InputFiscalPeriod,
      $parameters.P_FiscalYear     as InputFiscalYear,

      _MasterGL.Matvaluationclass as MaterialValuationClass,
      _MasterGL.Matlvaluationclasstext,
      _MasterGL.Glaccount              as GLAccount_Class,
      _MasterGL.Glaccountname          as GLAccountName_Class,
      _ProductText.ProductName     as ProductName,
      
      Main.PriceDeterminationControl,
      Main.ValuationArea,
      Main.Material,
      Main.InventoryValuationType,
      Main.SalesOrder,
      Main.SalesOrderItem,
      Main.InventorySpecialStockType,
      Main.Supplier,
      Main.WBSElementExternalID,
      Main.MaterialLedgerCategoryText,
      Main.ProcessCategoryName,
      Main.GoodsMovementTypeName,
      Main.GLAccountName,
      Main.InventorySpecialStockTypeName,
      Main.TotalVltdStockQuantity,
      Main.ValuationQuantityUnit,
      @Semantics.amount.currencyCode: 'Currency'
      Main.InventoryAmtInDspCrcy,
      Main.InvtryTransacAmtInDisplayCrcy,
      Main.PriceDiffAmtInDisplayCrcy,
      Main.ExchRateDiffAmtInDspCurrency,
      Main.Currency,
      Main.ControllingArea,
      Main.ControllingValuationType,
    
      /* Associations */
      Main._Currency,
      Main._Ledger,
      Main._Plant,
      Main._Product,
      Main._QuantityUnit,
      _MasterGL,
      _ProductText
}
