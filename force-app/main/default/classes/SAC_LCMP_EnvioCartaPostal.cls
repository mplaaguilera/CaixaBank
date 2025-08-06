public with sharing class SAC_LCMP_EnvioCartaPostal {
    
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    
    @AuraEnabled
    public static WrappedInfo getInfoPostal(String caseId){
        if(!Case.SObjectType.getDescribe().isAccessible()){
            throw new AuraHandledException('No tienes permisos para acceder al registro.');
        }
        Case caso = [SELECT SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE Id =: caseId LIMIT 1];
        if(caso.RecordTypeId == RECTYPEPRETENSION ){ //Se recupera la información del padre
            Case reclamacion = [SELECT Id, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, RecordTypeId FROM Case WHERE Id =: caso.SAC_Reclamacion__c LIMIT 1];
        
            String cuerpo = '';
            SAC_LCMP_EmailRedaccion.DatosEmailWrapper email = SAC_LCMP_EmailRedaccion.obtenerDatosEmail(reclamacion.Id);
            cuerpo = email.cuerpo;
            WrappedInfo myInfo = new WrappedInfo(
                reclamacion.SAC_NombreContacto__c, reclamacion.SAC_DireccionContacto__c, reclamacion.SAC_PoblacionContacto__c, reclamacion.SAC_CodigoPostalContacto__c,
                reclamacion.SAC_ProvinciaContacto__c, reclamacion.SAC_PaisContacto__c, cuerpo
            );
        
            return myInfo;
        }
        else{//Se recupera la información del propio registro
            String cuerpo = '';
            SAC_LCMP_EmailRedaccion.DatosEmailWrapper email = SAC_LCMP_EmailRedaccion.obtenerDatosEmail(caseId);
            cuerpo = email.cuerpo;

            WrappedInfo myInfo = new WrappedInfo(
                caso.SAC_NombreContacto__c, caso.SAC_DireccionContacto__c, caso.SAC_PoblacionContacto__c, caso.SAC_CodigoPostalContacto__c,
                caso.SAC_ProvinciaContacto__c, caso.SAC_PaisContacto__c, cuerpo
            );

            return myInfo;
        }      
    }


    public class WrappedInfo{

        @AuraEnabled public String nombreTitular {get; set;}
        @AuraEnabled public String direccionEnvio {get; set;}
        @AuraEnabled public String poblacion {get; set;}
        @AuraEnabled public String provincia {get; set;}
        @AuraEnabled public String pais {get; set;}
        @AuraEnabled public String codigoPostal {get; set;}
        @AuraEnabled public String cuerpo {get; set;}

        public WrappedInfo(String nombreTitularM, String direccionEnvioM, String poblacionM, String codigoPostalM, String provinciaM, String paisM, String cuerpoM) {
/*****************************************************************
 * Proposito: Método constructor de la clase Wrapper
 *                                                                                        
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200298         Luis Mesa    16/04/21       Creación Método
*****************************************************************/
            nombreTitular = nombreTitularM;
            direccionEnvio = direccionEnvioM;     
            poblacion = poblacionM;   
            codigoPostal = codigoPostalM;
            provincia = provinciaM;
            pais = paisM;
            cuerpo = cuerpoM;
        }
    }
}