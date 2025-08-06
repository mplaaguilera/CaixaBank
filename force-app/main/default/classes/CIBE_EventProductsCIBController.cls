/**********************************************************************************************************************
 Name:      CIBE_EventProductsCIBController
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente Cibe_EventProductsCIB
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            US743059         Lucia           20/12/2023           Init version
***********************************************************************************************************************/


public with sharing class CIBE_EventProductsCIBController {

    @AuraEnabled(cacheable=true)
    public static List<CIBE_RelaccionadoCita__c>  getProductosCita(String recordId){

        List<CIBE_RelaccionadoCita__c> evento = new List<CIBE_RelaccionadoCita__c>();
        List<Event> associatedEvent = new List<Event>();
        Set<String> eventId = new Set<String>();


        if(Event.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.Event.fields.AV_Task__c.isAccessible()
        ){
            associatedEvent = [SELECT Id, AV_Task__c FROM Event WHERE Id = :recordId];
        }

        if(!associatedEvent.isEmpty()){
            for (Event assEvnt : associatedEvent) {
                eventId.add(assEvnt.AV_Task__c);
            }
        }
       
        if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.CIBE_RelaccionadoCita__c.fields.CIBE_CitaRelaccionada__c.isAccessible() &&
        Schema.SObjectType.CIBE_RelaccionadoCita__c.fields.CIBE_Producto__c.isAccessible() &&
        Schema.SObjectType.CIBE_RelaccionadoCita__c.fields.CIBE_Comentario__c.isAccessible()){

            evento = [SELECT Id, CIBE_Producto__c, CIBE_Producto__r.CIBE_Familia__c, CIBE_Producto__r.Name, CIBE_Comentario__c, CIBE_Producto__r.CIBE_Familia__r.Name FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :eventId AND CIBE_Producto__c != null];
        }

        return evento;

    }


    @AuraEnabled
    public static void createProductCIB(List<Map<String,Object>> takedProducts, String evt){
        Id taskId = [SELECT AV_Task__c FROM Event where id = :evt ][0].AV_Task__c;
        List<CIBE_RelaccionadoCita__c> junctionEventList = new List<CIBE_RelaccionadoCita__c>();
        for(Map<String, Object> prodId: takedProducts){
            CIBE_RelaccionadoCita__c junctionEvent = new CIBE_RelaccionadoCita__c();
            junctionEvent.CIBE_CitaRelaccionada__c = taskId;
            junctionEvent.CIBE_Producto__c = (String) prodId.get('idProducto');
            junctionEvent.CIBE_Comentario__c = (String) prodId.get('comentario');
            junctionEventList.add(junctionEvent);
        }
   
        if(!junctionEventList.isEmpty()){
            insert junctionEventList;
        }
        
    }


    @AuraEnabled
    public static void deleteProductCIB(String recordId){
        List<CIBE_RelaccionadoCita__c> junctionEventList = new List<CIBE_RelaccionadoCita__c>();

        if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isAccessible() &&
        Schema.SObjectType.CIBE_RelaccionadoCita__c.fields.CIBE_CitaRelaccionada__c.isAccessible() &&
        Schema.SObjectType.CIBE_RelaccionadoCita__c.fields.CIBE_Producto__c.isAccessible() &&
        Schema.SObjectType.CIBE_RelaccionadoCita__c.fields.CIBE_Comentario__c.isAccessible()){

            junctionEventList = [SELECT Id FROM CIBE_RelaccionadoCita__c WHERE Id = :recordId];
        }
   
        if(!junctionEventList.isEmpty()){
            delete junctionEventList;
        }
        
    }
    
}