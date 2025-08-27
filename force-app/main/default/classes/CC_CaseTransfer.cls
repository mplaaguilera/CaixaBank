public with sharing class CC_CaseTransfer {
    
    public static final Id HDT_RECORD_TYPE_ID = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
    public static final Id CCO_RECORD_TYPE_ID = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
    public static final Id HDT_TASK_RECORD_TYPE_ID = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
    public static final Id CCO_TASK_RECORD_TYPE_ID = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');

    public class TransferResult {
        @AuraEnabled public Boolean isSuccess {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public Id newCaseId {get; set;}

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

        Savepoint sp = Database.setSavepoint();

        if (caseId == null) {
            return new TransferResult(false, 'Error en la transferencia del caso: El caso no puede ser null.');
        }
        //try {

            Case originalCase = getCase(caseId);
            if (originalCase == null) {
                return new TransferResult(false, 'El caso debe estar en estado Activo, Pendiente Incidencia o Pendiente Colaborador para ser transferido.');
            }
            List<Task> tareasExistentes = getTareasExistentes(originalCase);
            Boolean transferTaskResult = transferTask(originalCase, tareasExistentes);
            if(transferTaskResult){
                return new TransferResult(false, 'Este caso ya ha sido transferido.');
            }
            CC_Settings__c colasDeTransferencia = CC_Settings__c.getValues('CC_Colas_Transferencia_HDT_CCO');
            if (colasDeTransferencia == null) {
                return new TransferResult(false, 'No se encontró la configuración de colas de transferencia.');
            }

            String colaHDT = colasDeTransferencia.CC_Configuracion_1__c;
            String colaCCO = colasDeTransferencia.CC_Configuracion_2__c;
    
            Id targetRecordTypeId = originalCase.RecordTypeId == CCO_RECORD_TYPE_ID ? HDT_RECORD_TYPE_ID : CCO_RECORD_TYPE_ID;
            String colaTarget = originalCase.RecordTypeId == CCO_RECORD_TYPE_ID ? colaHDT : colaCCO;
            
            Group targetQueue = getTargetQueue(colaTarget);
            if (targetQueue == null) {
                return new TransferResult(false, 'No se encontró la cola de destino configurada.');
            }

            Case newCase = createNewCase(originalCase, targetRecordTypeId);
            insert newCase;

            originalCase.CC_CasoRelacionado__c = newCase.Id;
            originalCase.Status = 'Cerrado';
            originalCase.CC_CierreAutomaticoCSBD__c = true;

            newCase.OwnerId = targetQueue.Id;
            newCase.CC_Detalles_Consulta__c = originalCase.CC_Detalles_Consulta__c + ' - ' + newCase.CC_Detalles_Consulta__c;
            List<Case> updateCases = new List<Case>{originalCase, newCase};
            update updateCases;

            insertContentDocumentLink(originalCase.Id, newCase.Id);
            clonarTareas(originalCase, newCase);
            

            return new TransferResult(true, 'Caso ' + originalCase.CaseNumber + ' transferido exitosamente.');

        /*} catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = 'Fallo al transferir el caso: ' + e.getMessage();
            if (Test.isRunningTest()) {
                errorMsg += ' at line ' + e.getLineNumber();
            }
            errorMsg += ' | Stack: ' + e.getStackTraceString();
            return new TransferResult(false, errorMsg);
        }*/
    }

    private static Case getCase(Id caseId) {
        List<Case> cases = [
            SELECT Id, CaseNumber, Status, Subject, Description, OwnerId,
                   CC_Detalles_Solucion__c, CC_Detalles_Consulta__c, ContactId, AccountId, CC_Idioma__c, 
                   Origin, CC_Canal_Procedencia__c, CC_Canal_Operativo__c, 
                   CC_MCC_Causa__c, CC_MCC_Solucion__c, CC_No_Identificado__c, 
                   RecordTypeId,
                   (SELECT Id, Subject, Status, Priority, WhatId, OwnerId, Type, Description, AV_Case__c, RecordTypeId FROM Tasks)
            FROM Case 
            WHERE Id = :caseId AND Status IN ('Activo', 'Pendiente Incidencia', 'Pendiente Colaborador')
                  AND CC_CasoRelacionado__c = null
            LIMIT 1
        ];
        
        return cases.isEmpty() ? null : cases[0];
    }

    private static Case createNewCase(Case originalCase, Id targetRecordTypeId) {
        String subject = originalCase.Subject != null ? 
            'Transferencia (' + originalCase.CaseNumber + '): ' + originalCase.Subject : 
            'Transferencia de Caso (' + originalCase.CaseNumber + ')';

        return new Case(
            RecordTypeId = targetRecordTypeId,
            Subject = subject,
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
            CC_CasoRelacionado__c = originalCase.Id
        );
    }
    
    private static Group getTargetQueue(String colaTarget) {
        List<Group> colas = [
            SELECT Id, DeveloperName 
            FROM Group 
            WHERE Type = 'Queue' AND DeveloperName = :colaTarget 
            LIMIT 1
        ];
        
        return colas.isEmpty() ? null : colas[0];
    }

    @future
    public static void insertContentDocumentLink(Id caseId, Id newCaseId) {
        List<ContentDocumentLink> originalCaseCdl = [
            SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseId
        ];

        List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : originalCaseCdl) {
            newCdlList.add(new ContentDocumentLink(
                ContentDocumentId = cdl.ContentDocumentId,
                LinkedEntityId = newCaseId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }
        
        if (!newCdlList.isEmpty()) {
            insert newCdlList;
        }
    }

    private static List<Task> getTareasExistentes(Case caso) {
        List<Task> tareas = caso.Tasks;
        return tareas;
    }

    public static Boolean transferTask(Case caso, List<Task> tareasExistentes) {
        CC_Settings__c settings = CC_Settings__c.getValues('CC_Transferencia_Casos_HDT_CCO');
        Boolean existeTarea = false;
        for(Task tarea : tareasExistentes) {
            if(tarea.Type == 'Transferencia de caso') {
                existeTarea = true;
                break;
            }
        }
        
        if (settings.CC_Activa__c && existeTarea) {
            return true;
        }
        if (!settings.CC_Activa__c || !existeTarea) {
            Task tarea = (settings.CC_Configuracion_1__c == 'Upsert' && existeTarea) 
                ? tareasExistentes[0] : new Task();
            
            Map<String, Object> fields = new Map<String, Object>{
                'Subject' => 'Transferencia de caso ' + caso.CaseNumber, 
                'Status' => 'Completed',
                'Priority' => 'Normal',
                'WhatId' => caso.Id,
                'OwnerId' => caso.OwnerId,			
                'Type' => 'Transferencia de caso',
                'Description' => 'Transferencia de caso ' + caso.CaseNumber,
                'AV_Case__c' => caso.Id,
                'RecordTypeId' => caso.RecordTypeId == CCO_RECORD_TYPE_ID ? HDT_TASK_RECORD_TYPE_ID : CCO_TASK_RECORD_TYPE_ID
            };	
            tarea = (caso.RecordTypeId == CCO_RECORD_TYPE_ID) 
                ? CC_Activity.getActividad(tarea, fields) 
                : HDT_Activity.crearTarea('HDT_Task', fields);
            upsert tarea;
            return false;
        }
        
        return true;
    }

    public static void devolverCasoHDTCCO(Map<String, Map<String, String>> respuesta, String origen) {
        List<CC_DevolverCaso__e> eventosParaPublicar = new List<CC_DevolverCaso__e>();
        for(String key : respuesta.keySet()) {

            Map<String, String> caso = respuesta.get(key);
            String casoIdString = caso.get('casoId');
            String motivo = caso.get('motivo');
            
            if(!String.isEmpty(casoIdString)) {
                CC_DevolverCaso__e devolverCasoEvent = new CC_DevolverCaso__e();
                devolverCasoEvent.CC_CasoId__c = casoIdString; 
                devolverCasoEvent.CC_Origen__c = origen;
                devolverCasoEvent.CC_resolucion3N__c = motivo;
                eventosParaPublicar.add(devolverCasoEvent);
            }
        }
        if(!eventosParaPublicar.isEmpty()) {
            List<Database.SaveResult> resultados = EventBus.publish(eventosParaPublicar); 
        } else {
            CC_CustomException.throwAuraException('Error en el proceso de devolución, no se recibió ningún id de caso válido');
        }
    }

    public static void reabrirCasosHDTCCO(Map<String, String> respuesta) {

        String casoIdString = (String)respuesta.get('casoId');
        String motivo = (String)respuesta.get('motivo');
        String origen = (String)respuesta.get('origen');

        CC_Settings__c colasDeTransferencia = CC_Settings__c.getValues('CC_Colas_Transferencia_HDT_CCO');

        if (colasDeTransferencia == null) {
            return;
        }

        String colaHDT = colasDeTransferencia.CC_Configuracion_1__c;
        String colaCCO = colasDeTransferencia.CC_Configuracion_2__c;
        String colaTarget = origen == 'HDT' ? colaCCO : colaHDT;
        
        Group targetQueue = getTargetQueue(colaTarget);
        
        if(casoIdString != null && casoIdString != ''){
            List<Case> casoTarea = [
                SELECT Id, CC_Resolucion__c, Status 
                FROM Case 
                WHERE Id = :casoIdString 
                LIMIT 1
            ];
            
            Task tareaRechazo = new Task(
                WhatId = casoIdString,
                Description = 'El caso fue rechazado por ' + origen + '. Motivo: ' + motivo,
                Status = 'Completed',
                Type = 'Caso Rechazado en ' + origen,
                Subject = 'Caso Rechazado en ' + origen
            );
            
            casoTarea[0].Status = 'Activo';
            casoTarea[0].CC_Resolucion__c = motivo;
            casoTarea[0].OwnerId = targetQueue.Id;

            insert tareaRechazo;
            update casoTarea;
        } 
    }

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

    public static void clonarTareas(Case casoOriginal, Case casoNuevo) {
        clonarTareasFuture(casoOriginal.Id, casoNuevo.Id, casoNuevo.RecordTypeId);
    }
    
    @future
    public static void clonarTareasFuture(Id casoOriginalId, Id casoNuevoId, Id recordTypeIdCasoNuevo) {
        try {
            
            if(casoOriginalId == null || casoNuevoId == null) {
                CBK_Log.error('No se encontraron los casos para clonar tareas');
                return;
            }
            
            Id recordTypeTarea;
            if(recordTypeIdCasoNuevo == HDT_RECORD_TYPE_ID) {
                recordTypeTarea = HDT_TASK_RECORD_TYPE_ID;
            } else if(recordTypeIdCasoNuevo == CCO_RECORD_TYPE_ID) {
                recordTypeTarea = CCO_TASK_RECORD_TYPE_ID;
            }

            List<Task> tareasOriginales = [
                SELECT Id, Subject, Description, Priority, Status, Type, ActivityDate
                FROM Task 
                WHERE WhatId = :casoOriginalId
            ];

            if(!tareasOriginales.isEmpty() && recordTypeTarea != null) {
                List<Task> tareasClonadas = new List<Task>();
                
                for(Task tareaOriginal : tareasOriginales) {
                    Task tareaClonada = tareaOriginal.clone(false, true, false, false);
                    tareaClonada.WhatId = casoNuevoId;
                    tareaClonada.RecordTypeId = recordTypeTarea;
                    tareasClonadas.add(tareaClonada);
                }
                
                insert tareasClonadas;
            }
        } catch(Exception e) {
            CBK_Log.error('Error al clonar tareas: ' + e.getMessage());
        }
    }


}