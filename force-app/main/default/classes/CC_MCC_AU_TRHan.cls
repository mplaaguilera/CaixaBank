public with sharing class CC_MCC_AU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC__c>)tp.newList, (Map<Id, CC_MCC__c>)tp.oldMap);
    }

    private void process(List<CC_MCC__c> listNewObj, Map<Id, CC_MCC__c> mapOldObj) { //Map<Id, CC_MCC__c> mapNewObj

        
		Id rtTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		Id rtProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		Id rtMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		Id rtCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
       
        

        List<CC_MCC__c> lstMCC = new List<CC_MCC__c>();    
        for (CC_MCC__c mcc : listNewObj){            
            
            if(mcc.RecordTypeId == rtTematica || mcc.RecordTypeId == rtProducto || 
            mcc.RecordTypeId == rtMotivo || mcc.RecordTypeId == rtCausa){
                lstMCC.add(mcc);
            }
        }

        if(!lstMCC.isEmpty()){
            autoBajaMCC(lstMCC, mapOldObj, rtTematica, rtProducto, rtMotivo, rtCausa);
        }
    }
    private void autoBajaMCC(List<CC_MCC__c> lstMCC, Map<Id, CC_MCC__c> mapOldObj, String rtTematica, String rtProducto, String rtMotivo, String rtCausa){
        
		List<CC_MCC__c> lstMccUpd = new list<CC_MCC__c>(); 
        for (CC_MCC__c mcc : lstMCC){    
            if (mcc.CC_Activo__c != mapOldObj.get(mcc.Id).CC_Activo__c && !mcc.CC_Activo__c &&
                (mcc.CC_Tipo_Cliente__c == 'Cliente' || mcc.CC_Tipo_Cliente__c == 'Empleado' || mcc.CC_Tipo_Cliente__c == 'Cliente/Empleado')){
                lstMccUpd.add(mcc);
            }
        }
        if (!lstMccUpd.isEmpty()) {
            for(CC_MCC__c mcc :lstMccUpd){
                if(mcc.RecordTypeId == rtTematica){
                    CC_MCC_Automatize_Date.bajaProductos(lstMccUpd);
                }
                if(mcc.RecordTypeId == rtProducto){
                    CC_MCC_Automatize_Date.bajaMotivos(lstMccUpd);
                }
                if(mcc.RecordTypeId == rtMotivo){
                    CC_MCC_Automatize_Date.bajaCausa(lstMccUpd);
                }
                if(mcc.RecordTypeId == rtCausa){
                    CC_MCC_Automatize_Date.bajaSolucion(lstMccUpd);
                }
            }
            
        }
    }
}