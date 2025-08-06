public with sharing class SAC_LCMP_AcompanyamientoLlamada {

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
      
    @AuraEnabled
    public static ObjWrapper getInfoInit(Id recordId){

        Case c = [SELECT Id, Status, SAC_AcompanyaLlamada__c FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND Id =: recordId];
        Boolean ev = String.isBlank(String.valueof(c.SAC_AcompanyaLlamada__c)) != false ? true : false;
        ObjWrapper result = new ObjWrapper(c, ev);
        return result;

        /*if(!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException( 'Fallo al obtener información para el acuse de recibo mediante carta postal.' ); 
        }
        Boolean result = false;
        Id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Case registroActual = [SELECT Id, CC_MCC_Motivo__c, SEG_Detalle__r.SAC_AcompanyaLlamada__c
                                 FROM Case WHERE RecordTypeId =: rt AND Id =: recordId];

        Set<Id> listaIds = new Set<Id>();
        //listaIds.add(registroActual.CC_MCC_Motivo__c);
        //listaIds.add(registroActual.SEG_Detalle__c);
        //listaIds.add(registroActual.CC_MCC_ProdServ__c);
        //listaIds.add(registroActual.CC_MCC_Tematica__c);
        */
        //List<CC_MCC__c> mccsDelCaso = [SELECT Id /* campoNuevo */ FROM CC_MCC__c WHERE Id IN: listaIds]; 

        /*for(mcc : mccsDelCaso){
            if(mcc.campoNuevo){
                result = true;
            }
        }*/

    }

    public class ObjWrapper{

        @AuraEnabled public Case caso{get; set;}
        @AuraEnabled public Boolean eval{get; set;}
        public ObjWrapper(Case casoM, Boolean evalM){
            this.caso = casoM;
            this.eval = evalM;
        }
    }

    @AuraEnabled
    public static void ejecutarApex(String recordId){
        Case c = [SELECT Id, SAC_AcompanyaLlamada__c, SAC_Reclamacion__c FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND Id =: recordId];
        c.SAC_AcompanyaLlamada__c = system.now();
        if(Schema.sObjectType.Case.isUpdateable()){
            update c;
        }

        /*List<Case> pretensionesFamilia = [SELECT Id, SAC_AcompanyaLlamada__c FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__c =: c.SAC_Reclamacion__c];
        Case padre = [SELECT Id, SAC_AcompanyaLlamada__c FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: c.SAC_Reclamacion__c];
        if(pretensionesFamilia.isEmpty()){
            padre.SAC_AcompanyaLlamada__c = system.now();
            //update padre;
        }
        else{
            Boolean todosLosHermanosTicados = true;
            for(Case pretension : pretensionesFamilia){
                if(String.isBlank(String.valueof(pretension.SAC_AcompanyaLlamada__c))){
                    todosLosHermanosTicados = false;
                }
            }

            if(todosLosHermanosTicados){
                padre.SAC_AcompanyaLlamada__c = system.now();
                //update padre;
            }

        }*/
    }
}