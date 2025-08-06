public with sharing class CC_Gestion_Derivar_CSBD {
    public static Map<String, Object> crearOportunidad(String recordId) {
        Map<String, Object> retorno = new Map<String, Object>();
        Case caso = [SELECT id, OwnerId, ContactId, CC_Oportunidad_creada__c, Contact.AccountId,
        CC_Numero_Documento__c, Account.CC_Numero_Documento__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_Producto_Servicio__c,
        CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c, CBK_Case_Extension_Id__r.CC_Oportunidad_Vinculada__c
        FROM Case 
        WHERE Id = :recordId 
        LIMIT 1];
        CC_Lista_Valores__c listaValorOportunidadTarea = [SELECT Id, CC_Activa__c, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Texto oportunidad tarea existente' LIMIT 1];
        
        if(!String.isEmpty(recordId)) {
            try {                            
                Boolean oppExistentes = comprobarOportunidadExistente(recordId);          
                Boolean oppTareasCitas = CC_Activity.identificarTareasCitasExistentes(caso, listaValorOportunidadTarea);   //US1156943 - Botón "Derivar" - No permitir crear oportunidad con citas y tareas en el caso
                Map<String, Object> tareasRellamadas = identificarTareasRellamadasExistentes(caso); //US1076730 - Derivación CSBD - Rellamada cliente
                // Map<String, Object> oppSimilares = identificarOportunidadesSimilares(caso); //US1076730 - Derivación CSBD - Rellamada cliente
                
                // if(!oppExistentes && !(Boolean)oppSimilares.get('oportunidadSiExiste') && !oppTareasCitas && !(Boolean)tareasRellamadas.get('tareasRellamadas')) {                
                if(!oppExistentes && !oppTareasCitas && !(Boolean)tareasRellamadas.get('tareasRellamadas')) {                
                    retorno.put('validacionCrearOportunidad', true);
                } else {
                    if (oppExistentes) {
                        CC_CustomException.throwCustomException('Existe una oportunidad relacionada al caso.');
                    } else if(oppTareasCitas) {
                        retorno.put('oppTareasCitas', true);
                        retorno.put('mensajeOppTareas', listaValorOportunidadTarea.CC_Mensajes_Mostrar__c);
                    } else if((Boolean)tareasRellamadas.get('tareasRellamadas')) {
                        retorno.put('tareasRellamadas', true);
                        retorno.put('mensajeTareasRellamadas', tareasRellamadas.get('mensaje'));
                    }
                    // else if((Boolean)oppSimilares.get('oportunidadSiExiste')){
                    //     retorno = oppSimilares;
                    // }
                }              
            } catch (Exception e) {
                throw new AuraHandledException('Error en el proceso de creacion de oportunidad ' + e.getMessage());
            }
        }
        return retorno;
    }

    @AuraEnabled
    public static Map<String, Object> crearOportunidadCSBD(String recordId){
        Case caso = [
            SELECT Id, OwnerId, ContactId, Contact.AccountId, CC_Oportunidad_creada__c,
            CC_Numero_Documento__c, Account.CC_Numero_Documento__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_Producto_Servicio__c,
            CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c, CBK_Case_Extension_Id__r.CC_Oportunidad_Vinculada__c
            FROM Case 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        Map<String, Object> retorno = new Map<String, Object>();
        Map<String, Object> oppSimilares = identificarOportunidadesSimilares(caso);
        if ((Boolean)oppSimilares.get('oportunidadSiExiste')) {
            retorno = oppSimilares;
        } else {
            Map<String, Object> retornoCSBD = CSBD_WS_AltaOportunidad.altaOportunidadMac(recordId);                    
            if(retornoCSBD.get('success') == true) {
                retorno.put('oppCreada', retornoCSBD.get('success'));
                Id recordTypeTareaCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
                caso.CC_Oportunidad_creada__c = true;
                update caso;
                CC_Activity.crearActividadOportunidad(recordId, caso); 
            }
        }
        return retorno;
    }

    public static Boolean comprobarOportunidadExistente(String recordId) {
        try {
            List<Case> opCreada = [SELECT Id, CC_Oportunidad_creada__c, CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c FROM Case WHERE Id = :recordId LIMIT 1];
            if(!opCreada.isEmpty() && (opCreada[0].CC_Oportunidad_creada__c || opCreada[0].CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c != null)) {            
                return opCreada[0].CC_Oportunidad_creada__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }

    public static void devolverCasoCSBD(Map<String, Object> respuesta) {
        String casoIdString = (String)respuesta.get('casoId');
        String casoOportunidadString = (String)respuesta.get('oportunidadId');

        if(!String.isEmpty(casoIdString) && !String.isEmpty(casoOportunidadString)) {
            //Publicar el platform event para que la transacción salga por el usuario integración
            CC_DevolverCaso__e devolverCasoEvent = new CC_DevolverCaso__e();
            devolverCasoEvent.CC_CasoId__c = casoIdString; 
            devolverCasoEvent.CC_resolucion3N__c = casoOportunidadString;
            Database.SaveResult sr = EventBus.publish(devolverCasoEvent);  
        } else {
            CC_CustomException.throwAuraException('Error en el proceso de devolución, no se recibió ningún id de caso');
        }
    }
    
    public static void reabrirCasoCSBD(Map<String, String> respuesta) {
        List<Case> casosAbrir =  new List<Case>();
        String casoIdString = (String)respuesta.get('casoId');
        String casoOportunidadString = (String)respuesta.get('oportunidadId');
        List <Opportunity> oportunityList = [SELECT Id, CSBD_Motivo_Devolucion__c FROM Opportunity WHERE Id = :casoOportunidadString];
        if(casoIdString != null && casoIdString != ''){
            List<Case> casoTarea = [SELECT Id,CC_Resolucion__c, Status FROM Case Where Id = :casoIdString LIMIT 1];
            Task tareaRechazo = new Task(
                WhatId = casoIdString,
                Description = 'La oportunidad fue rechazada por CSBD. Motivo: ' + oportunityList[0].CSBD_Motivo_Devolucion__c,
                Status = 'Completed',
                Type = 'Oportunidad rechazada',
                Subject = 'Oportunidad rechazada'        
            );

            casoTarea[0].Status = 'Activo';
            casoTarea[0].CC_Resolucion__c = oportunityList[0].CSBD_Motivo_Devolucion__c;
            insert tareaRechazo;
            update casoTarea;
        }
        // for(Case casoTarea : [
        //     SELECT Id, 
        //         CC_Resolucion__c,
        //         (
        //             SELECT OwnerId
        //             FROM Tasks
        //             WHERE Type = 'Oportunidad CSBD' 
        //             ORDER BY CreatedDate DESC
        //             LIMIT 1
        //         )
        //     FROM Case 
        //     WHERE Id = :casoIdString
        // ]){
        //     if(casoTarea.Tasks.size()> 0){               
        //         casoTarea.CC_Resolucion__c = oportunityList[0].CSBD_Motivo_Devolucion__c;
        //         casoTarea.OwnerId = casoTarea.Tasks[0].OwnerId;
        //         casoTarea.Status = 'Activo';
        //         casosAbrir.add(casoTarea);
        //     }     
        // }     
      
        // if(casosAbrir.size() > 0 ) {
        //     update casosAbrir;
        //     Task tarea = [SELECT Id, Description, Status, OwnerId FROM TASK WHERE Id = :casosAbrir[0].Tasks[0].Id];
        //     tarea.Description = oportunityList[0].CSBD_Motivo_Devolucion__c;
        //     tarea.Status = 'Rechazada';
        //     update tarea;
        // }   
    }

    //llamado desde el trigger de Platform Event
    public static void reabrirCasoCSBD(List<CC_DevolverCaso__e> reabrirEvents) {
        Map<String, String> resultado = new Map<String, String>();
        for(CC_DevolverCaso__e reabrirEvent : reabrirEvents){
            if(String.isNotBlank(reabrirEvent.CC_CasoId__c) && String.isNotBlank(reabrirEvent.CC_Resolucion3N__c)) {
                resultado.put('casoId', reabrirEvent.CC_CasoId__c);
                resultado.put('oportunidadId', reabrirEvent.CC_Resolucion3N__c);
            }
        }
        if(resultado.size() > 0){
            reabrirCasoCSBD(resultado);
        }
    }

    public static Boolean comprobarOportunidadExistente(Case caso){
       return (
            !caso.CC_Oportunidad_creada__c && 
            caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c == null
        );
    }

    //US1076730 - Derivación CSBD - Rellamada cliente
    public static Map<String, Object> identificarOportunidadesSimilares(Case caso){
        //CC_Settings__c setting = CC_Settings__c.getValues('CC_OportunidadCreada72h');
        Map<String, Object> respuesta = new Map<String, Object>();
        try {
            // Verificar si ya existe una oportunidad creada para el caso actual
            if ((caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c == null) || caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Vinculada__c) {
                List<Opportunity> oportunidadList = buscarOportunidadesExistentes(caso);    
                if (!oportunidadList.isEmpty()) {
                    Opportunity oportunidad = oportunidadList[0];
                    // Acceder a las propiedades de la oportunidad
                    // WHERE Id = :caso.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c LIMIT 1];
                    if (oportunidad.IsClosed == true && oportunidad.StageName == 'Formalizada') {
                        CC_Lista_Valores__c listaValor = [SELECT Id, CC_Mensajes_Mostrar__c 
                        FROM CC_Lista_Valores__c 
                        WHERE Name = 'Oportunidad formalizada'
                        LIMIT 1];
                        String mensajeParametrizable = '';
                        if (listaValor != null) {
                            mensajeParametrizable = listaValor.CC_Mensajes_Mostrar__c;
                        }
                        String message = mensajeParametrizable + '\n\nOPORTUNIDAD ' + oportunidad.Name + ' FORMALIZADA:'  + '\n\nDESCRIPCIÓN: ' 
                        + oportunidad.Description + '\n\nFEEDBACK DEL CLIENTE: ' + oportunidad.CSBD_FeedbackCliente__c;

                        List<Task> tareasExistentes = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Consulta oportunidad formalizada' LIMIT 1];
                        if (tareasExistentes.isEmpty()) {
                            Task tareaCC = CC_Activity.crearTareaRellamadaCC(caso, '', 'Consulta oportunidad formalizada');
                        }
                        respuesta.put('oportunidadSiExiste', true);
                        respuesta.put('mensaje', message);
                        respuesta.put('tipo', 'Formalizada');
                        vincularOportunidad(caso, oportunidad);
                    } else if (oportunidad.IsClosed == false) {
                        CC_Lista_Valores__c listaValor2 = [SELECT Id, CC_Mensajes_Mostrar__c 
                        FROM CC_Lista_Valores__c 
                        WHERE Name = 'Oportunidad en curso contexto'
                        LIMIT 1];
                        String mensajeParametrizable2 = '';
                        if (listaValor2 != null) {
                            mensajeParametrizable2 = listaValor2.CC_Mensajes_Mostrar__c;
                        }
                        String message = mensajeParametrizable2 + '\n\nOPORTUNIDAD ' + oportunidad.Name + ' EN CURSO.';
                        respuesta.put('oportunidadSiExiste', true);
                        respuesta.put('mensaje', message);
                        respuesta.put('tipo', 'En curso');
                        vincularOportunidad(caso, oportunidad);          
                    }
                } else {
                    respuesta.put('oportunidadSiExiste', false);
                } 
            }
            if (respuesta.isEmpty()) {
                respuesta.put('oportunidadSiExiste', false);
            }
            return respuesta;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // US1267186: Derivación CSBD - Vinculación de oportunidades al caso en rellamada cliente
    private static void vincularOportunidad(Case caso, Opportunity oportunidad) {
        CBK_Case_Extension__c caseExtension = caso.CBK_Case_Extension_Id__c != null 
            ? [SELECT Id FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c]
            : new CBK_Case_Extension__c(Case_Id__c = caso.Id);
        caseExtension.CC_Oportunidad_Vinculada__c = true;
        caseExtension.CC_Oportunidad_Relacionada_Lookup__c = oportunidad.CSBD_CasoOrigen__r.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c;
        upsert caseExtension;
        if (caso.CBK_Case_Extension_Id__c == null) {
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            update caso;
        }
    }

    @AuraEnabled
    public static void crearTareasRellamada(String recordId, String descriptionTask) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('El recordId no puede ser nulo');
        }
        //else
        Case caso = [SELECT id, OwnerId, ContactId, CC_Oportunidad_creada__c, Contact.AccountId,
            CC_Numero_Documento__c, Account.CC_Numero_Documento__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_Producto_Servicio__c,
            CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c,
            CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__r.OwnerId
            FROM Case 
            WHERE Id = :recordId 
            LIMIT 1];

        List<Opportunity> oportunidadList = buscarOportunidadesExistentes(caso);

        //List<Opportunity> oportunidadList = (List<Opportunity>) Database.query(query);
        if (!oportunidadList.isEmpty()) {
            Opportunity oportunidad = oportunidadList[0];

            // Crear tarea relacionada con la oportunidad del CSBD
            String description =  descriptionTask;
            Id oportunidadId = oportunidadList[0].Id;
            if (oportunidadId != null) {
                Task tareaOportunidad = CC_Activity.crearTareaRellamadaCSBD(
                    oportunidad, 
                    caso,
                    description);
                Task tareaCC = CC_Activity.crearTareaRellamadaCC(caso, description, 'Consulta oportunidad en curso');
            } 
        }    
    }

    public static Integer getOportunidadCreadaNDays() {
        CC_Settings__c setting = CC_Settings__c.getValues('CC_OportunidadCreadaNDays');
        return setting != null ? Integer.valueOf(setting.CC_Configuracion_5__c) : 3;
    }

    public static Boolean getValidarProductoServicio() {
        CC_Settings__c setting = CC_Settings__c.getValues('CC_ValidarProductoServicio');
        return setting != null ? setting.CC_Activa__c : false;
    }
    


    public static Map<String, Object> identificarTareasRellamadasExistentes(Case caso){
        Map<String, Object> respuesta = new Map<String, Object>();
        respuesta.put('tareasRellamadas', false);
        List<Task> tareasRellamadas = [
            SELECT Id  
            FROM Task 
            WHERE 
                (WhatId = :caso.Id AND Type = 'Consulta oportunidad en curso') OR  //Tareas en Case
                (AV_Case__c = :caso.Id AND Type = 'Rellamada CC') //Tareas en Opportunity
        ];     
        if (!tareasRellamadas.isEmpty()) {
            respuesta.put('tareasRellamadas', true);
            CC_Lista_Valores__c listaValor = [SELECT Id, CC_Mensajes_Mostrar__c 
                FROM CC_Lista_Valores__c 
                WHERE Name = 'Oportunidad en curso'
                LIMIT 1];
            String mensajeParametrizable = '';              
            if (listaValor != null) {
                mensajeParametrizable = listaValor.CC_Mensajes_Mostrar__c;
            }
            respuesta.put('mensaje', mensajeParametrizable);
        }  
        return respuesta; 
    }

    public static List<Opportunity> buscarOportunidadesExistentes(Case caso){

        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE Id = :caso.AccountId];

        Contact contact = [SELECT Id, CC_Numero_Documento__c FROM Contact WHERE Id = :cuenta.PersonContactId];

        Map<String, Object> bindParams = new Map<String, Object>{
            'dias' => (Integer)getOportunidadCreadaNDays(),
            'numeroDocumento' => contact.CC_Numero_Documento__c,
            'tematica' => caso.CC_MCC_Tematica__c
        };       
        String query = 'SELECT Id, OwnerId, CSBD_Contact__c, Name, StageName, IsClosed, Description, CSBD_FeedbackCliente__c, CSBD_CasoOrigen__c, CSBD_CasoOrigen__r.CBK_Case_Extension_Id__r.CC_Oportunidad_Relacionada_Lookup__c ' +
            'FROM Opportunity ' +
            'WHERE CreatedDate = LAST_N_DAYS:' + bindParams.get('dias')  + //queryWithBinds does not support binding for LAST_N_DAYS
            'AND RecordType.DeveloperName = \'CSBD_MAC\' ' +
            'AND CSBD_CasoOrigen__c != null ' +
            'AND CSBD_Contact__r.CC_Numero_Documento__c =:numeroDocumento ' +
            'AND CSBD_CasoOrigen__r.CC_MCC_Tematica__c =:tematica ';
        if (getValidarProductoServicio()) {
            query += ' AND CSBD_CasoOrigen__r.CC_Producto_Servicio__c  =:productoServicio ';
            bindParams.put('productoServicio', caso.CC_Producto_Servicio__c);
        }
        query += ' ORDER BY CreatedDate DESC LIMIT 1';      
        // Ejecutar la consulta utilizando Database.queryWithBinds con accessLevel
        List<Opportunity> results = Database.queryWithBinds(query, bindParams, AccessLevel.USER_MODE);
        return results;
    }

    @AuraEnabled
    public static void crearTareaRellamadaCSBD(String recordId) {
        List<CBK_Case_Extension__c> caseExtensions = [SELECT CC_CrearOportunidadTrigger__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :recordId LIMIT 1];
        if (!caseExtensions.isEmpty()) {
            caseExtensions[0].CC_CrearOportunidadTrigger__c = true;
            update caseExtensions;
        }
    }
}