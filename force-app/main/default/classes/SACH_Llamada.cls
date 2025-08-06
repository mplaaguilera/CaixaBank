public with sharing class SACH_Llamada {

    public static Case registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {

        CC_TrazaInt__c traza = CC_TrazaInt.inicioTraza('TELEFONIA_SACH', 'Genesys', inputLlamada.extension, JSON.serialize(inputLlamada));
        CC_Llamada__c llamada;
        Case caso = new Case();
        try {
            CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c
                                                        FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
            llamada = new CC_Llamada__c(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'SACH_Cliente'),
                CC_Tipo__c = 'Entrante',
                CC_Agente__c = inputLlamada.usuario,
                CC_Extension__c = inputLlamada.extension,
                CC_ConnId__c = inputLlamada.connId,
                CC_ANI__c = inputLlamada.ani,
                CC_DNIS__c = inputLlamada.dnis,
                CC_Servicio_Genesys__c = servicioGenesys.Id,
                CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
                CC_Asunto__c = inputLlamada.asunto.substring(0, inputLlamada.asunto.length() > 255 ? 255 : inputLlamada.asunto.length()),
                CC_Datos_Genesys__c = inputLlamada.datos,
                CC_NumPerso__c = inputLlamada.numPerso,
                CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
                CC_No_Identificado__c = false,
                CC_Fecha_Inicio__c = System.now(),
                CC_Cuenta__c = null,
                CC_Contacto__c = null,
                CC_IdentCliente__c = '0'  //Sin datos ALF
            );
            identificarPorNumPerso(llamada, inputLlamada.numPerso);
            finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
            insert llamada;

            

            if (String.isEmpty(inputLlamada.casoId) && llamada.CC_Cuenta__c != null) {
                Case casoAnteriorCuenta = casoAnteriorCuenta(llamada.CC_Cuenta__c);
                if (casoAnteriorCuenta != null) {
                    SACH_Case_Operativa.vincularLlamada(casoAnteriorCuenta.Id);
                    caso = casoAnteriorCuenta;
                } else {
                    caso = crearVincularCaso(llamada);
                }
            } else { //Si no se identifica el cliente, se crea un caso con la Cuenta y el Contacto como null
                caso = crearVincularCaso(llamada);
            }

            CC_TrazaInt.finTraza(traza, null);
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, null, e.getTypeName(), e.getMessage());
        }
        return caso;
    }

    public static CC_Llamada__c registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());

        Case caso = [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordTypeId FROM Case WHERE Id = :inputLlamada.casoId];

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'SACH_Cliente');
        llamada.CC_Tipo__c = 'Saliente';
        llamada.CC_Agente__c = inputLlamada.usuario;
        llamada.CC_Extension__c = inputLlamada.extension;
        llamada.CC_ConnId__c = inputLlamada.connId;
        llamada.CC_DNIS__c = inputLlamada.dnis;
        llamada.CC_Idioma__c = caso.CC_Idioma__c;
        llamada.CC_Asunto__c = caso.Subject;
        llamada.CC_Cuenta__c = caso.AccountId;
        llamada.CC_Contacto__c = caso.ContactId;
        llamada.CC_No_Identificado__c = caso.CC_No_Identificado__c;
        llamada.CC_Fecha_Inicio__c = System.now();
        //llamada.CC_Servicio_Llamada_Saliente__c = caso.CC_Canal_Resolucion__c;
        llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
        insert llamada;
        crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null);
        return llamada;
    }

    /** Cuando no nos llega el Id de llamada, lo buscamos por connId, usuario y extensión */
    private static String buscarLlamada(CC_Llamada_Input jsonLlamada) {
        String resultado = jsonLlamada.llamadaId;
        if (String.isEmpty(resultado)) {
            List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'SACH_Cliente'
                                            AND CC_ConnId__c = :jsonLlamada.connId AND CC_Agente__c = :jsonLlamada.usuario
                                            AND CC_Extension__c = :jsonLlamada.extension AND CC_Fecha_Fin__c = null];
            if (llamadas.size() == 1) {
                resultado = llamadas[0].Id;
            }
        }
        return resultado;
    }

    public static void finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) {
        Id recordId = String.valueOf(inputLlamada.llamadaId);
        if(String.valueOf(recordId?.getSobjectType()) == 'Case') {
            List<Task> tarea = [SELECT Id, CC_Llamada_Id__c FROM Task 
                                    WHERE WhatId = :inputLlamada.llamadaId AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'SACH_Task' AND Status = 'Open' 
                                    ORDER BY CreatedDate DESC LIMIT 1];
            if(!tarea.isEmpty()) {
                inputLlamada.llamadaId = tarea[0].CC_Llamada_Id__c;                 
            }
        }
        String llamadaId = buscarLlamada(inputLlamada);
        if (String.isNotBlank(llamadaId)) {
            finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', tipoCierre != '' ? tipoCierre : 'Llamada finalizada');
        }
    }

    public static Case crearVincularCaso(CC_Llamada__c llamada) {
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name FROM CC_Servicio_Genesys__c
                                                    WHERE Id = :llamada.CC_Servicio_Genesys__c];
        //Crear caso
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        caso.Subject = llamada.CC_Asunto__c;
        caso.Origin = 'Phone';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.OS_Telefono__c = llamada.CC_ANI__c;
        caso.CC_No_Identificado__c = llamada.CC_No_Identificado__c;
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.CC_Idioma__c = llamada.CC_Idioma__c;
        caso.AccountId = llamada.CC_Cuenta__c;
        caso.ContactId = llamada.CC_Contacto__c;
        caso.CC_IdentCliente__c = llamada.CC_IdentCliente__c;
        insert caso;

        //Vincular caso
        String tipoActividad = llamada.CC_Tipo__c.equals('Saliente') ? 'Llamada saliente' : 'Llamada entrante';
        crearActividadFuture(llamada.Id, caso.Id, tipoActividad, servicioGenesys.Name);

        return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
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
                        llamada.CC_IdentCliente__c = '1'; //Alfabético automático
                    }
                } else if (mapaCuentasContactos.containsKey('CONTACTOS')) {
                    contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
                    if (contactos.size() == 1) {
                        llamada.CC_Cuenta__c = cuentas[0].Id;
                        llamada.CC_Contacto__c = contactos[0].Id;
                        llamada.CC_IdentCliente__c = '1'; //Alfabético automático
                    }
                }
            }
        }
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

    private static void finalizarActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
        finalizarActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
    }

    private static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
        List<Id> llamadaIds = new List<Id>();
        for (CC_Llamada__c llamada : llamadas) {
            llamadaIds.add(llamada.Id);
        }

        if (llamadaIds.size() == 0) {
            return;
        }

        List<Task> actividades = [SELECT Id FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open' AND Type LIKE :tipoActividad
                                    AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task')];

        for (Task actividad : actividades) {
            actividad.CC_Fecha_Fin__c = System.now();
            actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
            actividad.Status = 'Completed';
        }

        if (!actividades.isEmpty()) {
            update actividades;
        }
    }

    //Metodo nuevo para la optimización de código: Nerea Sanchez-Bermejo, Octubre 2021
    private static void finalizarActividadesNew(List<CC_Llamada__c> llamadas) {
        List<Id> llamadaIds = new List<Id>();
        if (!llamadas.isEmpty()) {
            for (CC_Llamada__c llamada : llamadas) {
                llamadaIds.add(llamada.Id);
            }

            if (llamadaIds.size() == 0) {
                return;
            }

            List<Task> actividades = [SELECT Type, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open'
                                        AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task')];

            List<Task> actividadesActualizar = new List<Task>();

            if (!actividades.isEmpty()) {
                for (Task actividad : actividades) {
                    if (actividad.Type.startsWith('Llamada')) {
                        actividad.CC_Fecha_Fin__c = System.now();
                        actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Llamada finalizada');
                        actividad.Status = 'Completed';
                        actividadesActualizar.add(actividad);
                    }
                }
            }
            if (!actividadesActualizar.isEmpty()) {
                update actividadesActualizar;
            }
        }
    }

    private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
        finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
    }

    private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
        for (CC_Llamada__c llamada : llamadas) {
            llamada.CC_Fecha_Fin__c = System.now();
            llamada.CC_Tipo_Cierre__c = tipoCierre;
        }

        if (!llamadas.isEmpty()) {
            update llamadas;
        }
    }

    private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
        if (!llamadas.isEmpty()) {
            finalizarLlamadas(llamadas, tipoCierre);
            finalizarActividades(llamadas, tipoActividad, tipoCierre);
        }
    }

    private static void finalizarLlamadasActividadesAbiertas(Id userId) {
        List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'SACH_Cliente'
                                        AND CC_Fecha_Fin__c = null AND OwnerId = :userId];
        if (llamadas.size() > 0) {
            finalizarLlamadas(llamadas, 'Llamada finalizada');
            finalizarActividadesNew(llamadas);
        }
    }

    private static Task crearObjetoActividad(Id llamadaId, Id casoId, String tipoActividad, String detalle, String tipoCierre) {
        Task actividad = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task'),
            Subject = tipoActividad,
            CC_Llamada_Id__c = llamadaId,
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            WhatId = casoId,
            Type = tipoActividad
        );

        if (tipoCierre != null) {
            actividad.CC_Fecha_Fin__c = System.now();
            actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
            actividad.Status = 'Completed';
        }
        return actividad;
    }

    private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String detalle, String tipoCierre) {
        Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, detalle, tipoCierre);
        insert actividad;
        return actividad.Id;
    }

    private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String telefono) {
        return crearActividad(llamadaId, casoId, tipoActividad, telefono, null);
    }

    @future
    private static void crearActividadFuture(Id llamadaId, Id casoId, String tipoActividad, String telefono) {
        crearActividad(llamadaId, casoId, tipoActividad, telefono, null);
    }

    private static String codigoIdioma(String idioma) {
        return 'Inglés'.equals(idioma) ? 'en' : ('Catalán'.equals(idioma) ? 'ca' : 'es');
    }

    private static void actualizarCaso(Id casoId, Id propietarioId) {
        update new Case(Id = casoId, OwnerId = propietarioId);
    }

    private static Case casoAnteriorCuenta(Id cuentaId) {
        List<Case> casosCuenta = [SELECT Id FROM Case WHERE AccountId = :cuentaId
                                    AND RecordType.DeveloperName = 'SACH_Cliente'
                                    ORDER BY CreatedDate DESC LIMIT 1];
        return casosCuenta.isEmpty() ? null : casosCuenta[0];
    }

    /*
    @InvocableMethod(label='Informar llamada en tarea' description='Informar llamada en tarea')
    public static void informarLlamadaEnCurso(List<Id> idNuevasTareas) {
        List<CC_Llamada__c> llamadas = [SELECT OwnerId, CC_Contacto__c FROM CC_Llamada__c
                                        WHERE CC_Fecha_Fin__c = null AND OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
        if (llamadas.size() > 0) {
            CC_Llamada__c llamada = llamadas[0];
            Id contactoLlamadaId = llamada.CC_Contacto__c;

            Set<Id> casoIds = new Set<Id>();
            List<Task> tareas = [SELECT WhatId FROM Task WHERE Id IN :idNuevasTareas];
            for (Task tarea : tareas) {
                casoIds.add(tarea.WhatId);
            }

            Map<Id, Id> casoContactoMapa = new Map<Id, Id>();
            List<Case> casos = [SELECT ContactId FROM Case WHERE Id IN :casoIds];
            for (Case caso : casos) {
                casoContactoMapa.put(caso.Id, caso.ContactId);
            }

            List<Task> tareasActualizadas = new List<Task>();
            for (Task tarea : tareas) {
                Id contactoTareaId = casoContactoMapa.get(tarea.WhatId);
                if (contactoTareaId != null && contactoLlamadaId != null && contactoTareaId.equals(contactoLlamadaId)) {
                    tarea.CC_Llamada_Id__c = llamada.Id;
                    tareasActualizadas.add(tarea);
                }
            }

            if (tareasActualizadas.size() > 0) {
                update tareasActualizadas;
            }
        }
    }
    */
}