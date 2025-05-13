public with sharing class CC_Gestion_Derivar_Documentacion {

    public static void crearNuevoCasoDocumentacion(String recordId) {
   
     if(recordId != null) {
            Case casoOrigen = [SELECT CaseNumber, ContactId, AccountId, OwnerId, RecordTypeId, Status, Origin, Subject, Description, CC_Canal_Contacto__c, CC_Canal_Procedencia__c, CC_Idioma__c, CC_Tipo_Cliente__c, CC_Canal_Operativo__c, CC_Canal_Respuesta__c, CC_CasoRelacionado__c, CC_Cola_Procedencia__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, CC_MCC_Causa__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Solucion__c, CC_MCC_Tematica__c, CC_Tipo_Contacto__c, CC_Canal_Resolucion__c, CC_CierreAutomaticoCSBD__c, CC_DevolucionCSBD__c FROM Case WHERE Id = :recordId LIMIT 1];
            List<Task> tareasOrigen = [SELECT RecordTypeId, Type, Subject, Description, Status, Priority, CC_Tipo_Cierre__c, OwnerId, CC_Nombre_Empresa__c, ActivityDate, WhatId, WhoId, CC_Procesos_Aceptados__c FROM Task WHERE WhatId = :casoOrigen.Id];
            List<EmailMessage> emailsOrigen = [SELECT MessageDate, CC_Procedencia__c, CC_Grupo_Colab__c, CC_Interno__c, CC_Segunda_Oficina__c, Status, CC_Plantilla__c, FromAddress, FromName, ToAddress, Subject, HtmlBody, TextBody FROM EmailMessage WHERE ParentId = :casoOrigen.Id];
            Case nuevoCaso;
            List<Task> nuevasTareas = new List<Task>();
            List<EmailMessage> nuevosEmailMessages = new List<EmailMessage>();
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();

            try{
                nuevoCaso = casoOrigen.clone(false, true);
                nuevoCaso.CC_CasoRelacionado__c = casoOrigen.Id;
                nuevoCaso.Origin = 'Email';
                nuevoCaso.CC_Canal_Procedencia__c = 'Atención al Cliente';
                nuevoCaso.CC_DevolucionCSBD__c = true; // Este campo ahora indica el flag de documentación
                nuevoCaso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Inbound_Email_AC' LIMIT 1].Id;
                insert nuevoCaso;

                List<CBK_Case_Extension__c> lstExtension = [SELECT Id FROM CBK_Case_Extension__c WHERE Case_Id__c = :casoOrigen.Id LIMIT 1];
                if (!lstExtension.isEmpty()) {
                    caseExtension = lstExtension[0];
                    caseExtension.CC_Documentacion__c = true; // Este campo indica si ya se ha clonado el caso
                    update caseExtension;
                } else {
                    caseExtension.Case_Id__c = casoOrigen.Id;
                    caseExtension.CC_Documentacion__c = true; // Este campo indica si ya se ha clonado el caso
                    insert caseExtension;
                }
                
                for (Task tarea : tareasOrigen) {
                    Task nuevaTarea = tarea.clone(false, false);
                    nuevaTarea.WhatId = nuevoCaso.Id;
                    nuevasTareas.add(nuevaTarea);
                }

                for (EmailMessage em : emailsOrigen) {
                    EmailMessage nuevoEmail = em.clone(false, false);
                    nuevoEmail.ParentId = nuevoCaso.Id;
                    nuevosEmailMessages.add(nuevoEmail);
                }

                if (!nuevasTareas.isEmpty()) {
                    insert nuevasTareas;
                }

                if (!nuevosEmailMessages.isEmpty()) {
                    insert nuevosEmailMessages;
                }
            } catch(Exception ex) {
                CBK_Log.error('CC_Operativa_Oficina_Controller insert nuevo caso', ex.getMessage());
            }
            if(nuevoCaso.Id != null) {
                try{
                    // casoOrigen.Status = 'Cerrado';
                    casoOrigen.CC_CierreAutomaticoCSBD__c = true;
                    casoOrigen.CC_CasoRelacionado__c = nuevoCaso.Id;
                    casoOrigen.CBK_Case_Extension_Id__c = caseExtension.Id;
                    // casoOrigen.CC_DevolucionCSBD__c = true; // Este campo ahora indica el flag de documentación
                    update casoOrigen;
                } catch(Exception ex) {
                    CBK_Log.error('CC_Operativa_Oficina_Controller update Caso Origen', ex.getMessage());
                } 
            }         
          
        } else {
           CC_CustomException.throwCustomException('Error en el proceso de creación de caso, no se recibió ningún id de caso');
        }
    }


}