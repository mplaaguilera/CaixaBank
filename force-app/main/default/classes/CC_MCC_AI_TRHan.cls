public with sharing class CC_MCC_AI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC__c>)tp.newList, (Map<Id, CC_MCC__c>)tp.oldMap);
    }

    private void process(List<CC_MCC__c> listNewObj, Map<Id, CC_MCC__c> mapOldObj) { //Map<Id, CC_MCC__c> mapNewObj

        Id rtConversionWeb = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_ConvMCCWeb').getRecordTypeId();
        Id rtTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id rtProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id rtMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id rtCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id rtSolucion = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();


        List<CC_MCC__c> lstMCCWeb = new List<CC_MCC__c>();
        List<CC_MCC__c> lstNoWeb = new List<CC_MCC__c>();
        for (CC_MCC__c mcc : listNewObj){            
            
            if(mcc.RecordTypeId == rtConversionWeb){
                lstMCCWeb.add(mcc);
            }else if(mcc.RecordTypeId == rtTematica || mcc.RecordTypeId == rtProducto || mcc.RecordTypeId == rtMotivo || mcc.RecordTypeId == rtCausa || mcc.RecordTypeId == rtSolucion){
                lstNoWeb.add(mcc);
            }

        }

        if(!lstMCCWeb.isEmpty()){
            calcularReferenciaConvWeb(lstMCCWeb, mapOldObj);
        }

        if(!lstNoWeb.isEmpty()){
            generarExternalId(lstNoWeb, mapOldObj);
        }
    }

    private void calcularReferenciaConvWeb(List<CC_MCC__c> lstMCCWeb, Map<Id, CC_MCC__c> mapOldObj){
        List<CC_MCC__c> lstMccUpd = new List<CC_MCC__c>();
        for(CC_MCC__c mcc : lstMCCWeb){
                CC_MCC__c mccUpd = new CC_MCC__c(
                    Id = mcc.Id,
                    Name = mcc.CC_MCCWeb_Origen__c+'-'+mcc.CC_MCCWeb_Motivo__c+'-'+mcc.CC_MCCWeb_Producto__c+'-'+mcc.CC_MCCWeb_Ambito__c,
                    CC_Equivalencia_Formulario__c = mcc.CC_MCCWeb_Origen__c+'-'+mcc.CC_MCCWeb_Motivo__c+'-'+mcc.CC_MCCWeb_Producto__c+'-'+mcc.CC_MCCWeb_Ambito__c
                );
                lstMccUpd.add(mccUpd);
        }
        
        if(!lstMccUpd.isEmpty()){
            update lstMccUpd;
        }
    }
    
    private void generarExternalId(List<CC_MCC__c> lstNoWeb, Map<Id, CC_MCC__c> mapOldObj){
        List<Id> listaIds = new List<Id>();
        for(CC_MCC__c mcc : lstNoWeb){
            if(mcc.CC_Codigo_Externo__c == null && mcc.CC_Tipo_Cliente__c != 'Segmentos'){
                listaIds.add(mcc.Id);
            }
        }
        if(!listaIds.isEmpty()){
            CC_MCC_Metodos.generaExternalId(listaIds);
        }
    }

}