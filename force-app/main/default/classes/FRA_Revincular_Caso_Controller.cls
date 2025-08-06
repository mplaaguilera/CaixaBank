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
        try {
            Case masterCase = [SELECT Id, CaseNumber, FRA_Id_Expediente_CGF__c FROM Case WHERE Id = :masterCaseId];
            Case mergeCase = [SELECT Id, CaseNumber, FRA_Id_Expediente_CGF__c FROM Case WHERE Id = :mergeCaseId];
            String resultado;

            //Buscamos las tareas completadas asociadas al caso origen para asociarlas al caso destino 
            List<Task> listaTareasCerradas = [SELECT Type FROM Task WHERE WhatId = :mergeCase.Id
                                                WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
            if (!listaTareasCerradas.isEmpty()) {
                for (Task tarea : listaTareasCerradas) {
                    tarea.WhatId = masterCase.Id;
                }
                if (!Schema.sObjectType.Task.fields.WhatId.isUpdateable()) {
                    return null;
                }
                Database.update(listaTareasCerradas, false);
            }

            //Buscamos las Alertas CGF asociadas al caso origen para asociarlas al caso destino
            Boolean updateCaso = false;
            List<FRA_Alerta_CGF__c> listaAlertasCGF = [SELECT Id, FRA_Caso_Relacionado__c FROM FRA_Alerta_CGF__c WHERE FRA_Caso_Relacionado__c = :mergeCase.Id WITH SECURITY_ENFORCED];
            if (!listaAlertasCGF.isEmpty()) {
                for (FRA_Alerta_CGF__c alerta : listaAlertasCGF) {
                    alerta.FRA_Caso_Relacionado__c = masterCase.Id;
                }
                if (!Schema.sObjectType.FRA_Alerta_CGF__c.fields.FRA_Caso_Relacionado__c.isUpdateable()) {
                    return null;
                }
                Database.update(listaAlertasCGF, false);

                if (String.valueOf(masterCase.FRA_Id_Expediente_CGF__c) == null) {
                    masterCase.FRA_Id_Expediente_CGF__c = mergeCase.FRA_Id_Expediente_CGF__c;
                    updateCaso = true;
                }
            }

            resultado = 'Ok';
		
            //Tarea para el mastercase
            Task task = new Task();
            task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
            task.Type = 'Fusionado'; 
            task.Subject = 'Fusión de caso';
            task.ActivityDate = System.today();
            task.Status = 'Completed';
            task.WhatId = masterCase.Id;
            task.Description = 'Fusión del caso ' + mergeCase.CaseNumber + ' con el caso ' + masterCase.CaseNumber;
            insert task;
    
            Database.delete(mergeCase, false);

            if (updateCaso) {
                Database.update(masterCase, false);
            }
    
            CBK_log.debug('Fin FRA_Revincular_Caso_Controller - mergeCase');
            return resultado; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}