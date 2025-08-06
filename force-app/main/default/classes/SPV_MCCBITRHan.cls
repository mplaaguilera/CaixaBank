/*****************************************************************
* Name: SPV_MCCBITRHan
* Copyright © 2021  CaixaBank
* 
* Proposito: Trigger Handler para controlar el Before Insert del objeto CC_MCC__c
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0                  		 	Iria ANPC   	 20/11/24      Creación
*****************************************************************/

public with sharing class SPV_MCCBITRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_MCC__c>)tp.newList);
    }
    
    private void process(List<CC_MCC__c> listNewObj) { 
        List<CC_MCC__c> lstMCC = new List<CC_MCC__c>();
        
        for (CC_MCC__c mcc : listNewObj){
            if(mcc.CC_Tipo_Cliente__c == 'SAC'){
                lstMCC.add(mcc);
            }
        }
        if(!lstMCC.isEmpty()){
            //SPV_MCCHelper.checkExistingMCC(lstMCC);
        }
    }    
}