public with sharing class CC_MCC_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC__c>)tp.newList, (Map<Id, CC_MCC__c>)tp.oldMap);
    }

    private void process(List<CC_MCC__c> listNewObj, Map<Id, CC_MCC__c> mapOldObj) { //Map<Id, CC_MCC__c> mapNewObj
        Id rtConversionWeb = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_ConvMCCWeb').getRecordTypeId();
        //Actualizar el nombre y la equivalencia del formulario para los registros de tipo ConvMCCWeb
        for(CC_MCC__c mcc : listNewObj){
            if(mcc.RecordTypeId == rtConversionWeb){
                
                mcc.Name = ((mcc.CC_MCCWeb_Origen__c!=null)? mcc.CC_MCCWeb_Origen__c:'')+'-'+((mcc.CC_MCCWeb_Motivo__c!=null)? mcc.CC_MCCWeb_Motivo__c:'')+'-'+((mcc.CC_MCCWeb_Producto__c!=null)? mcc.CC_MCCWeb_Producto__c:'')+'-'+((mcc.CC_MCCWeb_Ambito__c!=null)? mcc.CC_MCCWeb_Ambito__c:'');
                mcc.CC_Equivalencia_Formulario__c = ((mcc.CC_MCCWeb_Origen__c!=null)? mcc.CC_MCCWeb_Origen__c:'')+'-'+((mcc.CC_MCCWeb_Motivo__c!=null)? mcc.CC_MCCWeb_Motivo__c:'')+'-'+((mcc.CC_MCCWeb_Producto__c!=null)? mcc.CC_MCCWeb_Producto__c:'')+'-'+((mcc.CC_MCCWeb_Ambito__c!=null)? mcc.CC_MCCWeb_Ambito__c:'');
            }
        }
    }
}