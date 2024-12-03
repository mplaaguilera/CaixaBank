public with sharing class CBK_BorrarDatosSandbox implements Schedulable {

    public static void borrarDatosSandbox(Boolean notificarFin) {
        Boolean isSandBox = [SELECT IsSandbox FROM Organization].IsSandbox;
        if (isSandBox) { //Solo borra si NO es la Org de producción
            borrarTrazas();
            borrarOportunidades();
            borrarLlamadas();
            borrarChats();
            borrarCasosTareas();
            borrarOtros();
        } else {
            CBK_Log.debug('¡¡INVOCACIÓN A CBK_BorrarDatosSandbox.borrarDatosSandbox() EN PRODUCCIÓN!!');
        }
    }

    public static void borrarDatosSandbox() {
        borrarDatosSandbox(false);
    }

    public void execute(SchedulableContext sc) {
        borrarDatosSandbox();
    }

    @future @TestVisible
    private static void borrarTrazas() {
        //Conserva solo los 4000 registros más recientes dentro de los creados en los últimos 5 días
        Database.delete([SELECT Id FROM CBK_Log__c WHERE LastModifiedDate < LAST_N_DAYS:5], false);
        Database.delete([SELECT Id FROM CBK_Log__c ORDER BY CreatedDate ASC LIMIT :Math.max(0, [SELECT COUNT() FROM CBK_Log__c] - 4000)], false);

        Database.delete([SELECT Id FROM CC_TrazaInt__c WHERE LastModifiedDate < LAST_N_DAYS:5], false);
        Database.delete([SELECT Id FROM CC_TrazaInt__c ORDER BY CreatedDate ASC LIMIT :Math.max(0, [SELECT COUNT() FROM CC_TrazaInt__c] - 4000)], false);
    }

    @future @TestVisible
    private static void borrarOportunidades() {
        Database.delete([SELECT Id FROM Opportunity WHERE LastModifiedDate < LAST_N_DAYS:7], false);
        Database.delete([SELECT Id FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = NULL OR CSBD_Oportunidad__r.LastModifiedDate < LAST_N_DAYS:7], false);
    }

    @future @TestVisible
    private static void borrarLlamadas() {
        Database.delete([SELECT Id FROM CC_Llamada__c WHERE LastModifiedDate < LAST_N_DAYS:7], false);
    }

    @future @TestVisible
    private static void borrarChats() {
        Database.delete([SELECT Id FROM LiveChatTranscript WHERE LastModifiedDate < LAST_N_DAYS:7], false);
    }

    @future @TestVisible
    private static void borrarCasosTareas() {
        Database.delete([SELECT Id FROM CC_Marca_Case__c WHERE CC_Case__c = NULL OR CC_Case__r.LastModifiedDate < LAST_N_DAYS:7], false);
        Database.delete([SELECT Id FROM SAC_Marca_Case__c WHERE SAC_Case__c = NULL OR SAC_Case__r.LastModifiedDate < LAST_N_DAYS:7], false);
        Database.delete([SELECT Id FROM SEG_Marcasdeuncaso__c WHERE SEG_Caso__c = NULL OR SEG_Caso__r.LastModifiedDate < LAST_N_DAYS:7], false);
        Database.delete([SELECT Id FROM CBK_CaseHistory__c WHERE CBK_CaseId__c = NULL OR CBK_CaseId__r.LastModifiedDate < LAST_N_DAYS:7], false);
        Database.delete([SELECT Id FROM Task WHERE WhatId = NULL OR LastModifiedDate < LAST_N_DAYS:7 ORDER BY LastModifiedDate ASC LIMIT 4000], false);
        Database.delete([SELECT Id FROM Case WHERE LastModifiedDate < LAST_N_DAYS:7 ORDER BY LastModifiedDate ASC LIMIT 4000], false);
    }

    @future @TestVisible
    private static void borrarOtros() {
        Database.delete([SELECT Id FROM EmailMessage WHERE LastModifiedDate < LAST_N_DAYS:7], false);
        Database.delete([SELECT Id FROM SAC_Antecedentes__c WHERE LastModifiedDate < LAST_N_DAYS:5], false);
        Database.delete([SELECT Id FROM SAC_AdjuntoAntecedente__c WHERE SAC_Antecedente__r.LastModifiedDate < LAST_N_DAYS:5], false);
        Database.delete([SELECT Id FROM SAC_TMECaso__c WHERE LastModifiedDate < LAST_N_DAYS:5], false);
        Database.delete([SELECT Id FROM CBK_SCH_PendingProcess__c WHERE Schedule_Time__c < LAST_N_DAYS:5], false);
    }

    @TestVisible
    private static Messaging.SendEmailResult notificarFin() {
        String sandboxName = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName().toUpperCase();

        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
        correo.setToAddresses(new List<String>{UserInfo.getUserEmail()});
        correo.setSubject('Borrado de datos de sandbox ' + sandboxName + ' finalizado');
        correo.setHtmlBody('Borrado de datos de sandbox ' + sandboxName + ' finalizado a las ' + Datetime.now().format('HH:mm:ss'));
        return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo})[0];
    }
}