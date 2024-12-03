public with sharing class CSBD_Llamada {

    public static Opportunity registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {

        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c,CSBD_Empresa_Proveedora__c,CSBD_Familia_Producto__c,CSBD_Producto__c,CSBD_Now_Codigo_Producto__c,CSBD_Canal__c,CSBD_Now_Origen__c
                                                    FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
    
        //Creamos el objeto llamada mapeando diferentes campos

        CC_Llamada__c llamada = new CC_Llamada__c(
            CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante': 'Saliente',
            CC_Agente__c = inputLlamada.usuario,
            CC_Extension__c = inputLlamada.extension,
            CC_ConnId__c = inputLlamada.connId,
            CC_ANI__c = inputLlamada.ani,
            CC_DNIS__c = inputLlamada.dnis,
            CC_Servicio_Genesys__c = servicioGenesys.Id,
            CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
            CC_Asunto__c = inputLlamada.asunto.left(255),
            CC_Datos_Genesys__c = inputLlamada.datos,
            CC_ConnId_Cognitivo__c = inputLlamada.connIdCognitivo,
            CC_NumPerso__c = inputLlamada.numPerso,
            CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
            CC_No_Identificado__c = false,
            CC_Fecha_Inicio__c = System.now(),
            CC_Canal_del_Empleado__c = inputLlamada.canalEmpleado,
            CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
            CC_IdentCliente__c = '0',  //Sin datos ALF
            CC_Campana_Genesys__c = inputLlamada.nombreCampana,
            RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CSBD_Cliente').getRecordTypeId()
        );

        identificarPorNumPerso(llamada, inputLlamada.numPerso);

        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());

        insert llamada;

        //Se mapean los campos requeridos para el objeto oportunidad
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('CSBD_Empresa_Proveedora__c', servicioGenesys.CSBD_Empresa_Proveedora__c); 
        campos.put('CSBD_Familia_Producto__c', servicioGenesys.CSBD_Familia_Producto__c); 
        campos.put('CSBD_Producto__c', servicioGenesys.CSBD_Producto__c); 
        campos.put('CSBD_Telefono_Solicitud__c', llamada.CC_ANI__c);
        campos.put('CSBD_Now_Codigo_Producto__c', servicioGenesys.CSBD_Now_Codigo_Producto__c); 
        campos.put('CSBD_Canal__c', servicioGenesys.CSBD_Canal__c); 
        campos.put('CSBD_Now_Origen__c', servicioGenesys.CSBD_Now_Origen__c); 
        campos.put('CSBD_Estado__c','Activa');
        campos.put('AccountId',llamada.CC_Cuenta__c);
        campos.put('CSBD_Contact__c',llamada.CC_Contacto__c);
        campos.put('CSBD_Idioma_Solicitud__c',inputLlamada.idioma);
        campos.put('OwnerId', UserInfo.getUserId());
        if(llamada.CC_Fecha_Inicio__c.hour() <15){
            campos.put('CSBD_Turno_Contacto__c', 'Mañana');
        }
        else{
            campos.put('CSBD_Turno_Contacto__c', 'Tarde'); 
        }

        //Llamamos al método para crear la oportunidad
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Llamada_Servicio', campos);
            
        //Llamamos al método para crear la actividad
        Id idTask = crearActividad(llamada, oportunidad.Id, 'Llamada entrante', servicioGenesys.Name);
          
        return oportunidad;
    }
    
    public static CC_Llamada__c registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());

        Opportunity oportunidad = [SELECT Name, CSBD_Idioma_Solicitud__c, AccountId, CSBD_Contact__c, RecordTypeId
                                    FROM Opportunity WHERE Id = :inputLlamada.casoId];

        CC_Llamada__c llamada = new CC_Llamada__c(
            recordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CSBD_Cliente').getRecordTypeId(),
            CC_Tipo__c = 'Saliente',
            CC_Agente__c = inputLlamada.usuario,
            CC_Extension__c = inputLlamada.extension,
            CC_ConnId__c = inputLlamada.connId,
            CC_ConnId_Consulta__c = null,
            CC_DNIS__c = inputLlamada.dnis,
            CC_Idioma__c = codigoIdioma(oportunidad.CSBD_Idioma_Solicitud__c),
            CC_Asunto__c = oportunidad.Name,
            CC_Cuenta__c = oportunidad.AccountId,
            CC_Contacto__c = oportunidad.CSBD_Contact__c,
            CC_Fecha_Inicio__c = System.now()
        );
        insert llamada;
        crearActividad(llamada, inputLlamada.casoId, 'Llamada saliente', null);
        return llamada;
    }

    private static void identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) { 
        //Realizamos una búsqueda para informar el contacto y la cuenta
        if (!String.isEmpty(numPerso)) {
            List<Contact> contactos = new List<Contact>();
            Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('NP', numPerso);
            List<Account> cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
            if (cuentas.size() == 1) {
                // Cambio para añadir representantes.
                if (mapaCuentasContactos.containsKey('REPRESENTANTES')) {
                    contactos = (List<Contact>)mapaCuentasContactos.get('REPRESENTANTES');
                    if (contactos.size() == 1) {
                        llamada.CC_Cuenta__c = cuentas[0].Id;
                        llamada.CC_Contacto__c = contactos[0].Id;
                        llamada.CC_IdentCliente__c = '1'; // Alfabético automático
                    }
                } else if (mapaCuentasContactos.containsKey('CONTACTOS')) {
                    contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
                    if (contactos.size() == 1) {
                        llamada.CC_Cuenta__c = cuentas[0].Id;
                        llamada.CC_Contacto__c = contactos[0].Id;
                        llamada.CC_IdentCliente__c = '1'; // Alfabético automático
                    }
                }
            }
        }
    }
    private static Id crearActividad(CC_Llamada__c llamada, Id idOportunidad, String tipoActividad, String detalle) { 
        Task actividad = crearObjetoActividad(llamada.Id, idOportunidad, tipoActividad, detalle);
        actividad.WhoId = llamada.CC_Contacto__c;
        insert actividad;
        return actividad.Id;
    }

    private static Task crearObjetoActividad(Id llamadaId, Id idOportunidad, String tipoActividad, String detalle) {
        CC_Llamada__c llamada = [SELECT Id,CC_Cuenta__c,CC_Contacto__c FROM CC_Llamada__c WHERE Id = :llamadaId];
        Task actividad = new Task(
            Subject = tipoActividad + (detalle != null ? ' (' + detalle + ')' : ''),
            CC_Llamada_Id__c = llamadaId,
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            WhatId = idOportunidad,
            Type = tipoActividad,
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId()
        );
        return actividad;
    }

    public static void finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) { 
        Id recordId = String.valueOf(inputLlamada.llamadaId);
        if(String.valueOf(recordId?.getSobjectType()) == 'Opportunity') {
            List<Task> tarea = [SELECT Id, CC_Llamada_Id__c FROM Task 
                                    WHERE WhatId = :inputLlamada.llamadaId AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'CSBD_Task' AND Status = 'Open' 
                                    ORDER BY CreatedDate DESC LIMIT 1];
            if(!tarea.isEmpty()) {
                inputLlamada.llamadaId = tarea[0].CC_Llamada_Id__c;                 
            }
        }
        String llamadaId = buscarLlamada(inputLlamada);
        finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', tipoCierre != '' ? tipoCierre : 'Llamada finalizada');
    }

    /** Cuando no nos llega el Id de llamada, lo buscamos por connId, usuario y extensión */
    private static String buscarLlamada(CC_Llamada_Input jsonLlamada) { 
        String resultado = jsonLlamada.llamadaId;
        if (String.isEmpty(resultado)) {
            List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c
                                            WHERE CC_ConnId__c = :jsonLlamada.connId AND CC_Agente__c = :jsonLlamada.usuario AND CC_Extension__c = :jsonLlamada.extension AND CC_Fecha_Fin__c = null];
            if (llamadas.size() == 1) {
                resultado = llamadas[0].Id;
            }
        }
        return resultado;
    }
    
    private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) { 
        finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
    }

    private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) { 
        if (!llamadas.isEmpty()) {
            finalizarLlamadas(llamadas, tipoCierre);
            finalizarActividades(llamadas, tipoActividad, tipoCierre);
        }
    }

    private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
        for (CC_Llamada__c llamada : llamadas) {
            llamada.CC_Fecha_Fin__c = System.now();
            llamada.CC_Tipo_Cierre__c = tipoCierre;
        }
        update llamadas;
    }
    
    private static void finalizarLlamadasActividadesAbiertas(Id userId) { //OK
        List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE CC_Fecha_Fin__c = null AND OwnerId = :userId];
        if (!llamadas.isEmpty()) {
            finalizarLlamadas(llamadas, 'Llamada finalizada');
            finalizarActividades(llamadas, 'Llamada%', 'Llamada finalizada');
            finalizarActividades(llamadas, 'Consulta%', 'Consulta cancelada');        
        }
    }

    private static void finalizarActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
        finalizarActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
    }
    
    private static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
        Set<Id> llamadaIds = new Set<Id>();
        for (CC_Llamada__c llamada : llamadas) {
            llamadaIds.add(llamada.Id);
        }
        if (!llamadaIds.isEmpty()) {
            List<Task> actividades = [SELECT Id FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open' AND Type LIKE :tipoActividad
                                        AND RecordTypeId = :Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId()];
            
            if(!actividades.isEmpty()) {
                for (Task actividad : actividades){
                    actividad.CC_Fecha_Fin__c = System.now();
                    actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
                    actividad.Status = 'Completed';
                }
                update actividades;
            }
        }
    }

    public static String getIdiomaOportunidad(Id idOportunidad) {
        return codigoIdioma([SELECT CSBD_Idioma_Solicitud__c FROM Opportunity WHERE Id = :idOportunidad].CSBD_Idioma_Solicitud__c);
    }

    private static String codigoIdioma(String idioma) {
        return 'Inglés'.equals(idioma) ? 'en' : ('Catalán'.equals(idioma) ? 'ca' : 'es');
    }

    private static String obtenerTipoCierre(String tipoCierre) {
        Schema.DescribeFieldResult tipoCierreLlamada = CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe();
		List<Schema.PicklistEntry> tiposCierre = tipoCierreLlamada.getPicklistValues();
        for (Schema.PicklistEntry tipo : tiposCierre) {
            if (tipo.getValue().equals(tipoCierre)) {
                return tipo.getLabel();
            }
        }
		return tipoCierre;        
    }
}