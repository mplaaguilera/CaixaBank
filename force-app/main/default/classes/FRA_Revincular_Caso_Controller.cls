public with sharing class FRA_Revincular_Caso_Controller {

    @AuraEnabled
    public static Map<String, Object> getCaso(Id recordId) {
        CBK_log.debug('Inicio FRA_Revincular_Caso_Controller - getCaso (recordId: ' + recordId + ')');
        Map<String, Object> retorno = new Map<String, Object>();

        Boolean operativaHabilitada = false;
        Boolean esRecTypeCC = false;
        String mensaje = 'Este caso no puede ser asociado a otro.';

        Case caso = [SELECT CaseNumber, ContactId, RecordType.DeveloperName, CC_ContactoRelacionado__c, CC_Canal_Procedencia__c, Subject, Description, OwnerId, Origin
                    FROM Case WHERE Id = :recordId];

        if (caso.CC_ContactoRelacionado__c == null) {
            caso.CC_ContactoRelacionado__c = caso.ContactId;
        }
        //Saber si es recordType de FRA
        esRecTypeCC = caso.RecordType.DeveloperName.startsWith('FRA_');
      
        if (caso.RecordType.DeveloperName == 'FRA_Cliente') {
            operativaHabilitada = true;
        }
        
        if (String.valueOf(caso.OwnerId).startsWith('00G')) {
            operativaHabilitada = false;
            mensaje = 'Para poder fusionar este caso acepte primero su propiedad.';
        }

        retorno.put('CASOSCONTACTO', getCasosContacto(caso.CC_ContactoRelacionado__c, caso.Id));
        retorno.put('CASO', caso);
        retorno.put('HABILITADO', operativaHabilitada);
        retorno.put('MENSAJE', mensaje);
        retorno.put('RECORDTYPECC', esRecTypeCC);
        
        CBK_log.debug('Fin FRA_Revincular_Caso_Controller - getCaso');
        return retorno;
    }

    @AuraEnabled
    public static List<Case> getCasosContacto(String contactId, String recordId) {
        CBK_log.debug('Inicio FRA_Revincular_Caso_Controller - getCasosContacto (contactId: ' + contactId + ', recordId: ' + recordId + ')');
        List<Case> casosContacto = new List<Case>();
        if (String.isNotBlank(contactId)) {
            return [SELECT CaseNumber, Subject, Description, CreatedDate FROM Case
                    WHERE ContactId = :contactId AND Id != :recordId ORDER BY CreatedDate DESC LIMIT 20];
        }
        CBK_log.debug('Fin FRA_Revincular_Caso_Controller - getCasosContacto');
        return casosContacto;
    }

    @AuraEnabled
    public static String mergeCase(Id masterCaseId, Id mergeCaseId) {
        CBK_log.debug('Inicio FRA_Revincular_Caso_Controller - mergeCase (masterCaseId: ' + masterCaseId + ', mergeCaseId: ' + mergeCaseId + ')');
        CBK_Log.error('Prueba error');
        try {
            Case masterCase = [SELECT CC_Ultima_Interaccion__c, Status, CC_Fecha_Ultima_Interaccion__c, CC_Canal_Procedencia__c,
                                      Origin, CC_MailTelfNotif__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c
                                FROM Case WHERE Id = :masterCaseId];

            Case mergeCase = [SELECT CC_Ultima_Interaccion__c, Status, CC_Fecha_Ultima_Interaccion__c, CC_Canal_Procedencia__c,
                                     Origin, CC_MailTelfNotif__c, CreatedDate, RecordType.DeveloperName
                                FROM Case WHERE Id = :mergeCaseId];

            String resultado;

            //Clonado previo de tareas cerradas --> Workarround para el Merge
            Id recordtypeIdTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
            List<Task> mergeClosedTasklst = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap().keySet()), ',') + ' FROM Task WHERE WhatId = :mergeCaseId AND RecordTypeId = :recordtypeIdTask');
            List<Task> masterClosedTasklst = new List<Task>();
            
            //Recuperamos los IDs de las tareas a hacer merge/eliminar
            Set<Id> mergeClosedTasklstIds = (new Map<Id,Task>(mergeClosedTasklst)).keySet();               
            
            for (Task tk: mergeClosedTasklst) {
                Task newRecord = tk.clone(false);
                newRecord.WhatId = masterCaseId;
                masterClosedTasklst.add(newRecord);
            }
            
            //Update para poder realizar el delete
            update mergeClosedTasklst;
            delete mergeClosedTasklst; 
           
            CC_Activity.crearActividades(masterClosedTasklst, 'FRA_Task');

            merge masterCase mergeCase;
            resultado = 'Ok';
		
            //Tarea para el mastercase
            Task task = new Task();
            task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
            task.Type = 'Fusionado'; 
            task.Subject = 'Fusión de caso';
            task.ActivityDate = System.today();
            task.Status = 'Completed';
            task.WhatId = masterCase.Id;
            insert task;
    
            CBK_log.debug('Fin FRA_Revincular_Caso_Controller - mergeCase');
            return resultado; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}