public with sharing class CC_Transferir_HDT_CCO {

    private static final String NEGOCIO_CC = 'CC';
    private static final String NEGOCIO_HDT = 'HDT';
    private static final String CANAL_TELEFONO = 'Telefono';
    private static final String ORIGEN_PHONE = 'Phone';
    private static final String STATUS_ACTIVO = 'Activo';
    private static final String STATUS_CERRADO = 'Cerrado';
    private static final String CANAL_RESPUESTA_PHONE = 'Phone';
    private static final String TIPO_CLIENTE_EMPLEADO = 'Empleado';
    private static final String TIPO_CLIENTE_EMPLEADO_HDT = 'Empleado';
    public static final String RECORD_TYPE_CC_EMPLEADO = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
    public static final String RECORD_TYPE_HDT_EMPLEADO = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
    public static final Id HDT_TASK_RECORD_TYPE_ID = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
    public static final Id CCO_TASK_RECORD_TYPE_ID = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');

    private Id casoId;
    private Id nuevoOwnerId;
    private Id llamadaId;
    private CC_Llamada__c llamada;
    private Case casoPadre;
    private Case casoHijo;
    private String telefonoCaso;
    private String negocio;
    
    public CC_Transferir_HDT_CCO(Id casoId, Id nuevoOwnerId, CC_Llamada__c llamada, String negocio) {
        this.casoId = casoId;
        this.nuevoOwnerId = nuevoOwnerId;
        this.llamada = llamada;
        this.negocio = negocio;
    }

    public CC_Transferir_HDT_CCO(Id casoId, Id nuevoOwnerId, Id llamadaId, String negocio) {
        this.casoId = casoId;
        this.nuevoOwnerId = nuevoOwnerId;
        this.llamadaId = llamadaId;
        this.negocio = negocio;
    }

    public Case transferEmpleado() {
        Savepoint sp = Database.setSavepoint();
        List<Case> casosUpsert = new List<Case>();
        
        try {
            if (this.llamada == null) {
                this.llamada = getLlamada(this.llamadaId);            
            }
            
            this.casoPadre = validateAndGetParentCase(this.casoId, this.nuevoOwnerId, this.llamada.Id);
            
            transferTask(this.casoPadre, this.llamada, null);
            
            String telefonoCaso = determineTelefonoCaso(this.llamada);
            
            this.casoHijo = createChildCase(this.llamada, this.casoPadre, telefonoCaso);
            
            if (this.casoHijo != null) {
                insert this.casoHijo;
                CC_CaseTransfer.insertContentDocumentLink(this.casoPadre.Id, this.casoHijo.Id);
            }

            List<Task> tasksToUpdate = new List<Task>();
            if(!this.casoPadre.Tasks.isEmpty()) {
                for(Task task : this.casoPadre.Tasks) {
                    if(task.Status == 'Open') {
                        task.Status = 'Completed';
                        tasksToUpdate.add(task);
                    }
                }
            }

            if(!tasksToUpdate.isEmpty()) {
                update tasksToUpdate;
            }
            
            this.casoPadre.Status = STATUS_CERRADO;
            this.casoPadre.CC_CasoRelacionado__c = this.casoHijo.Id;
            this.casoPadre.CC_CierreAutomaticoCSBD__c = true;
            
            this.casoPadre.OwnerId = this.nuevoOwnerId;
            
            casosUpsert.add(this.casoPadre);
            casosUpsert.add(this.casoHijo);
            
            upsert casosUpsert;
            
            return this.casoHijo;

        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static Case validateAndGetParentCase(Id casoId, Id nuevoOwnerId, Id llamadaId) {
        if (casoId == null || nuevoOwnerId == null || llamadaId == null) {
            throw new AuraHandledException('Error: Parámetros obligatorios no proporcionados');
        }
        List<Case> casosPadre = [
            SELECT Id, RecordTypeId, CC_Idioma__c, OwnerId, OS_Telefono__c, Subject, CaseNumber, 
                   Description, CC_Detalles_Solucion__c, CC_Detalles_Consulta__c, CC_Canal_Operativo__c, 
                   Status, AccountId, ContactId, Account.Phone, Account.PersonMobilePhone, 
                   CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
                   (SELECT Id, Subject, Status, Priority, WhatId, OwnerId, Type, Description, AV_Case__c, RecordTypeId FROM Tasks)
            FROM Case 
            WHERE Id = :casoId 
            LIMIT 1
        ];

        return casosPadre.isEmpty() ? null : casosPadre[0];
    }

    private static CC_Llamada__c getLlamada(Id llamadaId) {
        List<CC_Llamada__c> llamadas = [
            SELECT Id, CC_Asunto__c, CC_ANI__c, CC_Idioma__c, CC_Cuenta__c, CC_Contacto__c, CC_Representante__c,
                   CC_IdentCliente__c, CC_Canal_del_Empleado__c, CC_Id_Cognitivo__c, CC_Status_Autorizacion__c,
                   CC_Sentimiento__c, CC_Respuesta_Asistente__c, CC_Cuenta__r.Phone, CC_Cuenta__r.PersonMobilePhone,
                   CC_Servicio_Genesys__r.CC_Canal_Procedencia__c, CC_Servicio_Genesys__r.CC_Canal_de_Entrada__c,
                   CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Servicio_Genesys__r.CC_Grupo__c, CC_Servicio_Genesys__r.CC_Tipo__c,
                   CC_Servicio_Genesys__r.CBK_Negocio__c
            FROM CC_Llamada__c 
            WHERE Id = :llamadaId
            LIMIT 1
        ];
        
        return llamadas.isEmpty() ? null : llamadas[0];
    }
    
    private static String determineTelefonoCaso(CC_Llamada__c llamada) {
        if (llamada.CC_Cuenta__c != null) {
            if (llamada.CC_Cuenta__r.PersonMobilePhone != null) {
                return llamada.CC_Cuenta__r.PersonMobilePhone;
            } else if (llamada.CC_Cuenta__r.Phone != null) {
                return llamada.CC_Cuenta__r.Phone;
            }
        }
        return llamada.CC_ANI__c;
    }

    private Case createChildCase(CC_Llamada__c llamada, Case casoPadre, String telefonoCaso) {
        if(llamada == null || casoPadre == null || telefonoCaso == null) {
            return null;
        }
        Case caso = new Case(
            Subject = llamada.CC_Asunto__c + ' - Caso transferido desde ' + (llamada.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c == TIPO_CLIENTE_EMPLEADO ? NEGOCIO_CC : NEGOCIO_HDT),
            Origin = llamada.CC_Servicio_Genesys__r.CC_Canal_de_Entrada__c == CANAL_TELEFONO ? ORIGEN_PHONE : String.isBlank(llamada.CC_Servicio_Genesys__r.CC_Canal_de_Entrada__c) ? ORIGEN_PHONE : llamada.CC_Servicio_Genesys__r.CC_Canal_de_Entrada__c,
            Status = STATUS_ACTIVO,
            CC_Canal_Respuesta__c = CANAL_RESPUESTA_PHONE,
            CC_Telefono_Contacto__c = llamada.CC_ANI__c,
            CC_Idioma__c = llamada.CC_Idioma__c,
            AccountId = casoPadre.AccountId,
            ContactId = casoPadre.ContactId,
            Canal_del_Empleado__c = llamada.CC_Canal_del_Empleado__c,
            CC_Canal_Procedencia__c = llamada.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c,
            CC_Canal_Operativo__c = casoPadre.CC_Canal_Operativo__c,
            CC_CasoRelacionado__c = casoPadre.Id,
            Description = casoPadre.Description,
            CC_Detalles_Consulta__c = casoPadre.CC_Detalles_Consulta__c,
            CC_Detalles_Solucion__c = casoPadre.CC_Detalles_Solucion__c
        );
        
        if (this.negocio == NEGOCIO_HDT) {
            caso.RecordTypeId = RECORD_TYPE_CC_EMPLEADO;
            caso.CC_Tipo_Cliente__c = TIPO_CLIENTE_EMPLEADO;
            caso.CC_Fecha_Traslado_1N__c = DateTime.now();
        } else if(this.negocio == NEGOCIO_CC) {
            caso.RecordTypeId = RECORD_TYPE_HDT_EMPLEADO;
            caso.CC_Tipo_Cliente__c = TIPO_CLIENTE_EMPLEADO_HDT;
            caso.CC_Fecha_Traslado_1N__c = DateTime.now();
        }
        return caso;
    }

    /*public static void transferCaseColasNoSalesforce(Id casoId, Id nuevoOwnerId, CC_Llamada__c llamada) {
        List<Case> casos = [SELECT Id, OwnerId, Status FROM Case WHERE Id = :casoId];
        if (casos.isEmpty()) {
            throw new AuraHandledException('Error: Caso no encontrado');
        }

        Case caso = casos[0];
        caso.Status = STATUS_CERRADO;
        update caso;

        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, Name, OwnerId FROM CC_Grupo_Colaborador__c WHERE Name = :llamada.CC_Servicio_Genesys__r.CC_Grupo__c];
        transferTask(caso, llamada, grupos[0]);
        List<String> gruposCol = new List<String>();
        for(CC_Grupo_Colaborador__c grupo : grupos){
            gruposCol.add(grupo.Name);
        }
        
        Map<String, List<String>> emails = CC_Gestion_Derivar_Emails_Auto.sendEmailGrupoCol(gruposCol);

        String[] para = emails.get('Para') != null ? emails.get('Para') : new List<String>();
        String[] cc = emails.get('CC') != null ? emails.get('CC') : new List<String>();

        if(Test.isRunningTest()) {
            CC_Gestion_Derivar_Emails_Auto.createEmail(caso, para, cc, null, 'CC_Transferencia_Casos_HDT_CCO', llamada.CC_Servicio_Genesys__r.CC_Grupo__c, null, CC_Settings__c.getValues('CC_OWA_Por_Defecto_Email_Automatico').CC_Configuracion_1__c);
        }
    }*/

    public static void transferTask(Case casoPadre, CC_Llamada__c llamada, CC_Grupo_Colaborador__c grupo) {
        Task tarea = new Task();

        Map<String, Object> fields = new Map<String, Object>{
            'Subject' => 'Transferencia de caso ' + casoPadre.CaseNumber, 
            'Status' => 'Completed',
            'Priority' => 'Normal',
            'WhatId' => casoPadre.Id,
            'OwnerId' => casoPadre.OwnerId,			
            'Type' => 'Transferencia de caso',
            'Description' => 'Transferencia de caso ' + casoPadre.CaseNumber,
            'AV_Case__c' => casoPadre.Id,
            'CC_Llamada_Id__c' => llamada.Id,
            'RecordTypeId' => casoPadre.RecordTypeId == RECORD_TYPE_CC_EMPLEADO ? HDT_TASK_RECORD_TYPE_ID : CCO_TASK_RECORD_TYPE_ID,
            'CC_Grupo_Colaborador_Id__c' => grupo != null ? grupo.Id : null
        };	

        tarea = (casoPadre.RecordTypeId == RECORD_TYPE_CC_EMPLEADO) 
            ? CC_Activity.getActividad(tarea, fields) 
            : HDT_Activity.crearTarea('HDT_Task', fields);
        
        insert tarea;
    }
}