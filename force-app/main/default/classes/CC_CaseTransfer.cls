public with sharing class CC_CaseTransfer {
    
    public class TransferResult  {
        @AuraEnabled public Boolean isSuccess {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public Id newCaseId {get; set;} // Por si se quiere devolver el ID del nuevo caso

         public TransferResult(Boolean isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }

         public TransferResult(Boolean isSuccess, String message, Id newCaseId) {
            this.isSuccess = isSuccess;
            this.message = message;
            this.newCaseId = newCaseId;
        }
}

    @AuraEnabled
    public static TransferResult transferCaseToHDT(Id caseId) {
        // Iniciar un Savepoint para poder hacer rollback si algo falla
        Savepoint sp = Database.setSavepoint();

        if (caseId == null) {
            return new TransferResult(false, 'Error en la trasferencia del caso a HDT: El caso no puede ser null.');
        }

        try {
            // Obtener los datos del caso original, incluyendo campos necesarios para la transferencia
            Case originalCase = [
                SELECT Id, CaseNumber, Status, Subject, Description, OwnerId,
                       CC_Detalles_Solucion__c, ContactId, AccountId, CC_Idioma__c, 
                       Origin, CC_Canal_Procedencia__c, CC_Canal_Operativo__c, 
                       CC_MCC_Causa__c, CC_MCC_Solucion__c, CC_No_Identificado__c, 
                       RecordTypeId
                FROM Case 
                WHERE Id = :caseId 
                LIMIT 1
            ];

            // Validaciones previas a la transferencia
            if (originalCase.Status != 'Activo' && originalCase.Status != 'Pendiente Incidencia' && originalCase.Status != 'Pendiente Colaborador') {
                return new TransferResult(false, 'El caso debe estar en estado Activo, Pendiente Incidencia o Pendiente Colaborador para ser transferido.');
            }

            List<ContentDocumentLink> originalCaseCdl = [
                SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :originalCase.Id
            ];

            CC_Settings__c colasDeTransferencia = CC_Settings__c.getValues('CC_Colas_Transferencia_HDT_CCO');
            if (colasDeTransferencia == null) {
                return new TransferResult(false, 'No se encontró la configuración de colas de transferencia.');
            }

            String colaHDT = colasDeTransferencia.CC_Configuracion_1__c;
            String colaCCO = colasDeTransferencia.CC_Configuracion_2__c;
    
            // Determinar el RecordType del caso destino y la cola destino
            Id hdtRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Id ccoRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(); 

            Id targetRecordTypeId;
            Id targetQueueName;

            if (originalCase.RecordTypeId == ccoRecordTypeId) {
                targetRecordTypeId = hdtRecordTypeId;
                targetQueueName = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :colaHDT LIMIT 1].Id;
            } else if (originalCase.RecordTypeId == hdtRecordTypeId) {
                targetRecordTypeId = ccoRecordTypeId;
                targetQueueName = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :colaCCO LIMIT 1].Id;
            } else {
                return new TransferResult(false, 'No se pudo determinar el tipo de transferencia (CCO a HDT o HDT a CCO) basado en el tipo de registro actual del caso.');
            }

            // Crear el nuevo caso sin CC_Admin__c inicialmente
            Case newCase = new Case(
                RecordTypeId = targetRecordTypeId,
                Subject = originalCase.Subject != null ? 'Transferencia (' + originalCase.CaseNumber + '): ' + originalCase.Subject : 'Transferencia de Caso (' + originalCase.CaseNumber + ')',
                Description = originalCase.Description,
                CC_Detalles_Solucion__c = originalCase.CC_Detalles_Solucion__c, 
                ContactId = originalCase.ContactId,
                AccountId = originalCase.AccountId,
                CC_Idioma__c = originalCase.CC_Idioma__c,
                Origin = originalCase.Origin,
                CC_Canal_Procedencia__c = originalCase.CC_Canal_Procedencia__c,
                CC_Canal_Operativo__c = originalCase.CC_Canal_Operativo__c,
                CC_No_Identificado__c = originalCase.CC_No_Identificado__c,
                Status = 'Activo', 
                CC_CasoRelacionado__c = originalCase.Id, 
                CC_Admin__c = true,
                OwnerId = targetQueueName
            );
            insert newCase;
            
            //  Vincular el caso origen al caso destino y cerrarlo
            originalCase.CC_CasoRelacionado__c = newCase.Id;
            originalCase.Status = 'Cerrado';
            originalCase.CC_CierreAutomaticoCSBD__c = true;
            originalCase.CC_Admin__c = true;
            update originalCase;

            //  Transferir ficheros adjuntos (ContentDocumentLink) al nuevo caso
            List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();
            for (ContentDocumentLink cdl : originalCaseCdl) {
                newCdlList.add(new ContentDocumentLink(
                    ContentDocumentId = cdl.ContentDocumentId,
                    LinkedEntityId = newCase.Id, // Vincula el archivo al nuevo caso
                    ShareType = 'V', // V = Viewer (read-only), C = Collaborator (read/write), I = Inferred
                    Visibility = 'AllUsers' // Asegura que sea visible
                ));
            }
            if (!newCdlList.isEmpty()) {
                insert newCdlList;
            }

            return new TransferResult(true, 'Caso ' + originalCase.CaseNumber + ' transferido exitosamente. Nuevo caso creado: ' + newCase.CaseNumber, newCase.Id);

        } catch (Exception e) {
            Database.rollback(sp); // Revertir todas las operaciones si algo falla
            String errorMsg = 'Fallo al transferir el caso: ' + e.getMessage();
            if (Test.isRunningTest()) {
                errorMsg += ' at line ' + e.getLineNumber();
            }
            errorMsg += ' | Stack: ' + e.getStackTraceString();
            return new TransferResult(false, errorMsg);
        }
    }

    public static void devolverCasoHDT_CCO(Map<String, Object> respuesta, String origen) {     
        String casoIdString = (String)respuesta.get('casoId');
        String motivo = (String)respuesta.get('motivo');
        if(!String.isEmpty(casoIdString)) {
            //Publicar el platform event para que la transacción salga por el usuario integración
            CC_DevolverCaso__e devolverCasoEvent = new CC_DevolverCaso__e();
            devolverCasoEvent.CC_CasoId__c = casoIdString; 
            devolverCasoEvent.CC_Origen__c = origen;
            devolverCasoEvent.CC_resolucion3N__c = motivo;
            Database.SaveResult sr = EventBus.publish(devolverCasoEvent);  
        } else {
            CC_CustomException.throwAuraException('Error en el proceso de devolución, no se recibió ningún id de caso');
        }
    }

    
    public static void reabrirCasosHDTCCO(Map<String, String> respuesta) {
        List<Case> casosAbrir =  new List<Case>();
        List<Task> tareasUpdate =  new List<Task>();

        String casoIdString = (String)respuesta.get('casoId');
        String motivo = (String)respuesta.get('motivo');
        String origen = (String)respuesta.get('origen');
        
        if(casoIdString != null && casoIdString != ''){
            List<Case> casoTarea = [SELECT Id,CC_Resolucion__c, Status FROM Case Where Id = :casoIdString LIMIT 1];
            Task tareaRechazo = new Task(
                WhatId = casoIdString,
                Description = 'El caso fue rechazado por ' + origen + '. Motivo: ' + motivo,
                Status = 'Completed',
                Type = 'Caso Rechazado en ' + origen,
                Subject = 'Caso Rechazado en ' + origen
            );
            casoTarea[0].Status = 'Activo';
            casoTarea[0].CC_Resolucion__c = motivo;

            insert tareaRechazo;
            update casoTarea;
        } 
    }

    //llamado desde el Oficina Operativa Controller
    public static void reabrirCasosHDTCCO(Map<String,CC_DevolverCaso__e> reabrirEvents) {
        Map<String, String> resultado = new Map<String, String>();
        for(String origen : reabrirEvents.keySet()){
            if(String.isNotBlank(reabrirEvents.get(origen).CC_CasoId__c)) {
                resultado.put('casoId', reabrirEvents.get(origen).CC_CasoId__c);    
                resultado.put('motivo', reabrirEvents.get(origen).CC_resolucion3N__c);
                resultado.put('origen', origen);
            }
        }
        if(resultado.size() > 0){
            reabrirCasosHDTCCO(resultado);
        }
    }
}