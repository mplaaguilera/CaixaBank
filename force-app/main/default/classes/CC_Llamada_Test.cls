@isTest
public class CC_Llamada_Test {

    public static CC_Servicio_Genesys__c crearServicio1() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Servicio 1',
			CC_Codigo__c = 'S1',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'CaixaBankNow',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today(),
            CC_Tipo_Cliente__c = 'Cliente');
        insert servicio;
        return servicio;
    }

    public static CC_Servicio_Genesys__c crearServicio2() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Servicio 2',
			CC_Codigo__c = 'S2',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Tercer nivel',
			CC_Canal_Procedencia__c = 'ImaginBank',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today(),
            CC_Tipo_Cliente__c = 'Cliente');
        insert servicio;
        return servicio;
    }

    public static CC_Servicio_Genesys__c crearServicio3() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Servicio 3',
			CC_Codigo__c = 'S3',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'CaixaBankNow',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
            CC_Tipo_Cliente__c = 'Cliente');
        insert servicio;
        return servicio;
    }

    public static CC_Servicio_Genesys__c crearServicioDespliegues() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Despliegues',
			CC_Codigo__c = 'INC_TEC_DESPLIEGUES',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'Incidencias Técnicas',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
            CC_Tipo_Cliente__c = 'Empleado');
        insert servicio;
        return servicio;
    }
    public static CC_Servicio_Genesys__c crearServicioDespliegues2() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Despliegues2',
			CC_Codigo__c = 'INC_TEC_DESPLIEGUES2',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'Incidencias Técnicas',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
            CC_Tipo_Cliente__c = 'Empleado');
        insert servicio;
        return servicio;
    }


    public static CC_Servicio_Genesys__c crearServicioDesbordeCSI() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Desborde CSI',
			CC_Codigo__c = 'CSI_HDT_DESBORDE',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'Incidencias Técnicas',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
            CC_Tipo_Cliente__c = 'Empleado');
        insert servicio;
        return servicio;
    }

    public static CC_Servicio_Genesys__c crearServicioEmpleado() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Servicio 4',
			CC_Codigo__c = 'S4',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'Activo',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
            CC_Tipo_Cliente__c = 'Empleado');
        insert servicio;
        return servicio;
    }

    public static CC_Servicio_Genesys__c crearServicioEncuesta() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Encuesta',
			CC_Codigo__c = 'ENCUESTA',
            CC_VDN__c = '4444446',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(-3),
            recordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Encuesta').getRecordTypeId());
        insert servicio;
        return servicio;
    }

    public static Case crearCaso() {
        Case caso = new Case(Subject = 'Prueba',
            Origin = 'Phone',
            CC_Canal_Respuesta__c = 'Phone',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_No_Identificado__c = true,
            CC_Canal_Procedencia__c = 'CaixaBankNow');
		insert caso;
		return caso;
    }

    public static Task crearActividadManual(String subject, Id llamadaId, Id casoId) {
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
		Task actividad = new Task(
            Subject = subject,
            CC_Llamada_Id__c = llamadaId,
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            WhatId = casoId,
            RecordTypeId = taskRecordTypeId,
            Type = 'Actividad manual',
            CC_validacion_tarea_manual__c = true
        );
        insert actividad;
		return actividad;
    }

    public static CC_MCC__c crearTematica() {
        Id recordTypeTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c tematica = new CC_MCC__c();
  		tematica.RecordTypeId = recordTypeTematica;
        tematica.CC_Tipo_Cliente__c = 'Cliente';
		tematica.Name = 'Temática';
        tematica.CC_Codigo_Externo__c = 'T1';
        tematica.CC_Canal_Operativo__c = 'Oficina';
        insert tematica;
		return tematica;
    }

    public static CC_MCC__c crearProducto(Id tematicaId) {
        Id recordTypeProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c producto = new CC_MCC__c();
  		producto.RecordTypeId = recordTypeProducto;
        producto.CC_Tipo_Cliente__c = 'Cliente';
		producto.Name = 'Producto';
        producto.CC_Tematica__c = tematicaId;
        producto.CC_Codigo_Externo__c = 'P1';
        insert producto;
		return producto;
    }

    public static CC_MCC__c crearMotivo(Id productoId) {
        Id recordTypeMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c motivo = new CC_MCC__c();
  		motivo.RecordTypeId = recordTypeMotivo;
        motivo.CC_Tipo_Cliente__c = 'Cliente';
		motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoId;
        motivo.CC_Codigo_Externo__c = 'M1';
        insert motivo;
		return motivo;
    }

    public static CC_MCC__c crearCausa(Id motivoId) {
        Id recordTypeCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c causa = new CC_MCC__c();
  		causa.RecordTypeId = recordTypeCausa;
        causa.CC_Tipo_Cliente__c = 'Cliente';
		causa.Name = 'Causa';
        causa.CC_Motivo__c = motivoId;
        causa.CC_Codigo_Externo__c = 'C1';
        insert causa;
		return causa;
    }

    public static CC_MCC__c crearSolucion(Id causaId) {
        Id recordTypeSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        CC_MCC__c solucion = new CC_MCC__c();
  		solucion.RecordTypeId = recordTypeSolucion;
        solucion.CC_Tipo_Cliente__c = 'Cliente';
		solucion.Name = 'Solucion';
        solucion.CC_Causa__c = causaId;
        solucion.CC_Codigo_Externo__c = 'S1';
        insert solucion;
		return solucion;
    }

    public static Case cerrarCaso(Case caso) {
        CC_MCC__c tematica = CC_Llamada_Test.crearTematica();
        CC_MCC__c producto = CC_Llamada_Test.crearProducto(tematica.Id);
        CC_MCC__c motivo = CC_Llamada_Test.crearMotivo(producto.Id);
        CC_MCC__c causa = CC_Llamada_Test.crearCausa(motivo.Id);
        CC_MCC__c solucion = CC_Llamada_Test.crearSolucion(causa.Id);
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_MCC_Causa__c = causa.Id;
        caso.CC_MCC_Solucion__c = solucion.Id;
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Operativo__c = 'Sin canal';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.Status = 'Cerrado';
        update caso;
        return caso;
    }

    public static Contact crearContacto() {
		Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id recordTypeOficina = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Account oficinaGestora = new Account(RecordTypeId = recordTypeOficina, Name = 'Cuenta oficina gestora', CC_Tipo_Centro__c = 'OF',  CC_Email__c = 'test@test.com',  CC_Numero_Oficina__c = '222', CC_Numero_Oficina_Empresa__c = '222-22222');
        insert oficinaGestora;
        Account cuenta = new Account(RecordTypeId = recordTypeCuenta, Name = 'Cuenta', CC_NumPerso__c = '666', CC_OficinaGestoraId__c = oficinaGestora.Id, AV_OficinaPrincipal__c = oficinaGestora.Id);
        insert cuenta;

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact contacto = new Contact(RecordTypeId = recordTypeContacto, FirstName = 'Contacto', LastName='Contacto', AccountId = cuenta.Id);
        insert contacto;
        return contacto;
    }

    public static List<Contact> crearContactos() {
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Account> listaCuentas = new List<Account>();
        listaCuentas.add(new Account(RecordTypeId = recordTypeCuenta, Name = 'Cuenta 1', CC_NumPerso__c = '123'));
        listaCuentas.add(new Account(RecordTypeId = recordTypeCuenta, Name = 'Cuenta 2', CC_NumPerso__c = '456'));
        insert listaCuentas;

        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Contact> listaContactos = new List<Contact>();
        listaContactos.add(new Contact(RecordTypeId = recordTypeEmpleado, FirstName = 'Empleado',  LastName = 'PorId'));
        listaContactos.add(new Contact(RecordTypeId = recordTypeEmpleado, FirstName = 'Empleado',  LastName = 'PorTelefono'));
        listaContactos.add(new Contact(RecordTypeId = recordTypeCliente,  FirstName = 'Contacto1', LastName = 'Contacto1', AccountId = listaCuentas[0].Id));
        listaContactos.add(new Contact(RecordTypeId = recordTypeCliente,  FirstName = 'Contacto2', LastName = 'Contacto2', AccountId = listaCuentas[1].Id));
        insert listaContactos;

        Id recordTypeCanalComunicacion = Schema.getGlobalDescribe().get('CC_Canal_Com__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        List<CC_Canal_Com__c> listaCanalesComunicacion = new List<CC_Canal_Com__c>();
        listaCanalesComunicacion.add(new CC_Canal_Com__c(CC_Telefono__c = '690112233', CC_ContactoId__c = listaContactos[0].Id, CC_Clase_Com__c = '1', RecordTypeId = recordTypeCanalComunicacion));
        listaCanalesComunicacion.add(new CC_Canal_Com__c(CC_Telefono__c = '690998877', CC_ContactoId__c = listaContactos[1].Id, CC_Clase_Com__c = '1', RecordTypeId = recordTypeCanalComunicacion));
        listaCanalesComunicacion.add(new CC_Canal_Com__c(CC_Telefono__c = '977112233', CC_ContactoId__c = listaContactos[2].Id, CC_Clase_Com__c = '1', RecordTypeId = recordTypeCanalComunicacion));
        listaCanalesComunicacion.add(new CC_Canal_Com__c(CC_Telefono__c = '977998877', CC_ContactoId__c = listaContactos[3].Id, CC_Clase_Com__c = '1', RecordTypeId = recordTypeCanalComunicacion));
        insert listaCanalesComunicacion;

        listaCuentas[0].AV_EAPGestor__c = listaContactos[0].Id;
        update listaCuentas[0];

        return listaContactos;
    }

    public static CC_Llamada__c obtenerLlamada(Id id) {
        return [SELECT CC_Cuenta__r.AV_OficinaPrincipal__c, CC_Cuenta__r.CC_OficinaGestoraId__c,  CC_Servicio_Genesys__c, CC_Asunto__c, CC_Idioma__c, CC_ANI__c, CC_No_Identificado__c, CC_Cuenta__c, CC_Contacto__c, CC_Tipo__c, CC_ConnId__c, CC_ConnId_Consulta__c, CC_Id_Cognitivo__c, CC_Canal_del_Empleado__c, CC_IdentCliente__c, CC_Status_Autorizacion__c, CC_Perfil__c FROM CC_Llamada__c WHERE Id = :id AND CC_Fecha_Fin__c = null];
    }

    public static String obtenerJsonLlamada(String servicio, String llamadaId, String casoId, String numPerso) {
        return obtenerJsonLlamada(servicio, llamadaId, casoId, numPerso, '666666666');
    }
    public static String obtenerJsonLlamada(String servicio, String llamadaId, String casoId, String numPerso, String ani) {
        return
        '{ "usuario": "1218",' +
        '  "extension": "1118",' +
        '  "connId": "12345678",' +
        '  "ani": "' + ani +'",' +
        '  "dnis": "666666666",' +
        '  "servicio": "' + servicio + '",' +
        '  "asunto": "Asunto",' +
        '  "numPerso": "' + numPerso + '",' +
        '  "idioma": "Castellano",' +
        '  "datos": "Datos",' +
        '  "connIdCognitivo": "87654321",' +
        '  "casoId": "' + casoId + '",' +
        '  "salesforceParentId": null,' +
        '  "statusAuto": "APPROVED",' +
        '  "perfil": "EMPLEADOS",' +
        '  "llamadaId": "' + llamadaId + '"}';
    }
    public static String obtenerJsonConsulta(String servicio, String llamadaId, String casoId, String salesforceParentId) {
        return
        '{ "usuario": "1219",' +
        '  "extension": "1119",' +
        '  "llamadaId": "' + llamadaId + '",' +
        '  "connId": "12348765",' +
        '  "ani": "666666666",' +
        '  "dnis": "666666666",' +
        '  "servicio": "' + servicio + '",' +
        '  "idioma": "Castellano",' +
        '  "salesforceParentId": "' + salesforceParentId + '",' +
        '  "casoId": "' + casoId + '"}';
    }
    public static String obtenerJsonConsultaExterna(String casoId, String salesforceParentId, String empleadoId, String empleadoTelefono) {
        return
        '{ "usuario": "1219",' +
        '  "extension": "1119",' +
        '  "connId": "12348765",' +
        '  "empleadoId": "' + empleadoId + '",' +
        '  "empleadoTelefono": "' + empleadoTelefono + '",' +
        '  "salesforceParentId": "' + salesforceParentId + '",' +
        '  "casoId": "' + casoId + '"}';
    }

    // Obtiene el perfil de "System Administrator" independientemente del idioma de salesforce
    public static Id obtenerPerfilAdministrador() {
        // Explicación de la query: Al crear el entorno, el único perfil por defecto
        // con estas 2 propiedades es el perfil de System Administrator
        // Si ordenamos los perfiles por fecha de creación nos sale el primero
        return [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1].Id;
    }


    public static User obtenerAgente1(Id profileId) {
        User agente = new User();
        agente.FirstName = 'Agente';
        agente.LastName = 'Uno';
        agente.Alias='AUno';
        agente.Email = 'agente2@invalid.com';
        agente.Username= 'agente1@caixa.com';
        agente.ProfileId = profileId;
        agente.EmailEncodingkey='UTF-8';
        agente.LanguageLocaleKey='en_US';
        agente.LocalesIdKey='en_US';
        agente.TimezonesIdKey='Europe/Berlin';
        insert agente;
        return agente;
    }

    public static User obtenerAgente2(Id profileId) {
        User agente = new User();
        agente.FirstName = 'Agente';
        agente.LastName = 'Dos';
        agente.Alias='ADos';
        agente.Email = 'agente2@invalid.com';
        agente.Username= 'agente2@caixa.com';
        agente.ProfileId = profileId;
        agente.EmailEncodingkey='UTF-8';
        agente.LanguageLocaleKey='en_US';
        agente.LocalesIdKey='en_US';
        agente.TimezonesIdKey='Europe/Berlin';
        insert agente;
        return agente;
    }

    /***************************** EMPLEADOS CSI *****************************/
    public static CC_Servicio_Genesys__c crearServicioEmpleadoCSI() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Servicio 5',
        CC_Codigo__c = 'S5',
            CC_VDN__c = '4444444',
        CC_Tipo__C = 'Empleado',
        CC_Canal_Procedencia__c = 'CCO CSI',
        CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
            CC_Tipo_Cliente__c = 'CSI Bankia');
        insert servicio;
        return servicio;
    }

    public static Case crearCasoEmpleadoCSI() {
        Id recordTypeCasoCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();

        Case caso = new Case(Subject = 'Prueba',
            Origin = 'Email',
            CC_Canal_Respuesta__c = 'Email',
            Canal_del_Empleado__c = 'CSI',
            CC_Canal_Procedencia__c = 'CCO CSI',
            recordTypeId = recordTypeCasoCSIBankia);
        insert caso;
        return caso;
    }
    /*************************************************************************/

    @isTest static void cogerColgar() {

        CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];

        Test.startTest();
        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        CC_Llamada__c llamada = obtenerLlamada(llamadaId);

        System.assert(llamada != null);

        //Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
        Case caso1 = CC_Llamada.crearVincularCaso(llamada);
        jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, llamadaId, caso1.Id, contacto.Account.CC_NumPerso__c);
        String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
        System.assertEquals(llamada.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
        Test.stopTest();
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId=:caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);
        CC_Llamada_Test.cerrarCaso(caso1);
        caso1 = [SELECT Id FROM Case WHERE Id = :caso1.Id AND Status = 'Cerrado'];
        System.assert(caso1 != null);

        //Creamos otro caso manualmente
        Case caso2 = CC_Llamada.crearVincularCaso(llamada);
        CC_Llamada_Test.crearActividadManual('Reclamación a cliente', llamada.Id, caso2.Id);
        Boolean excepcion = false;
        try {
            CC_Llamada_Test.cerrarCaso(caso2);
        }
        catch (Exception e) {
            excepcion = true;
        }
        System.assert(excepcion);

        //Colgamos la llamada

        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');

        actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
        llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
    }

    @isTest static void cogerEncuesta() {

        CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];

        Test.startTest();
        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, llamadaId, '', contacto.Account.CC_NumPerso__c);
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);

        System.assert(llamada != null);

        //Creamos caso manualmente
        Case caso1 = CC_Llamada.crearVincularCaso(llamada);
        System.assert(caso1 != null);

        //Creamos otro caso manualmente
        Case caso2 = CC_Llamada.crearVincularCaso(llamada);
        System.assert(caso2 != null);

        //Realizamos una encuesta
        CC_OpenCTI.registrarEncuesta(jsonLlamada);
        Test.stopTest();

        //Comprobamos que en ambos casos se ha creado la actividad de encuesta
        Task actividadEncuestaCaso1 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.id AND WhatId = :caso1.id AND Type = 'Encuesta' AND Status = 'Completed' ];
        System.assert(actividadEncuestaCaso1 != null);
        Task actividadEncuestaCaso2 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.id AND WhatId = :caso2.id AND Type = 'Encuesta' AND Status = 'Completed' ];
        System.assert(actividadEncuestaCaso2 != null);
    }

    private static void testSetup(){
        List<CC_Servicio_Genesys__c> servicios = new List<CC_Servicio_Genesys__c>();
        CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c(Name = 'Servicio 1',
			CC_Codigo__c = 'S1',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Servicio',
			CC_Canal_Procedencia__c = 'CaixaBankNow',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today(),
            CC_Tipo_Cliente__c = 'Cliente');
            servicios.add(s1);

            CC_Servicio_Genesys__c s2 = new CC_Servicio_Genesys__c(Name = 'Servicio 2',
			CC_Codigo__c = 'S2',
            CC_VDN__c = '4444444',
			CC_Tipo__C = 'Tercer nivel',
			CC_Canal_Procedencia__c = 'ImaginBank',
			CC_Prefijo__c = '0',
            CC_Fecha_Inicio_Salesforce__c = date.today(),
            CC_Tipo_Cliente__c = 'Cliente');
            servicios.add(s2);

            CC_Servicio_Genesys__c s3 = new CC_Servicio_Genesys__c(Name = 'Servicio 3',
                CC_Codigo__c = 'S3',
                CC_VDN__c = '4444444',
                CC_Tipo__C = 'Servicio',
                CC_Canal_Procedencia__c = 'CaixaBankNow',
                CC_Prefijo__c = '0',
                CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
                CC_Tipo_Cliente__c = 'Cliente');
                servicios.add(s3);

        insert servicios;

        Id perfilAdministradorId = obtenerPerfilAdministrador();


        List<User> agentes = new List<User>();

        User agenteCancelarConsulta = new User();
        agenteCancelarConsulta.FirstName = 'Agente';
        agenteCancelarConsulta.LastName = 'Uno';
        agenteCancelarConsulta.Alias='AUno';
        agenteCancelarConsulta.Email = 'agente2@invalid.com';
        agenteCancelarConsulta.Username= 'agente1@caixa.com';
        agenteCancelarConsulta.ProfileId = perfilAdministradorId;
        agenteCancelarConsulta.EmailEncodingkey='UTF-8';
        agenteCancelarConsulta.LanguageLocaleKey='en_US';
        agenteCancelarConsulta.LocalesIdKey='en_US';
        agenteCancelarConsulta.TimezonesIdKey='Europe/Berlin';
        agentes.add(agenteCancelarConsulta);



        User agenteCompletarConsulta = new User();
        agenteCompletarConsulta.FirstName = 'Automated';
        agenteCompletarConsulta.LastName = 'Process';
        agenteCompletarConsulta.Alias='ADos';
        agenteCompletarConsulta.Email = 'agente2@invalid.com';
        agenteCompletarConsulta.Username= 'agente2@caixa.com';
        agenteCompletarConsulta.ProfileId = perfilAdministradorId;
        agenteCompletarConsulta.EmailEncodingkey='UTF-8';
        agenteCompletarConsulta.LanguageLocaleKey='en_US';
        agenteCompletarConsulta.LocalesIdKey='en_US';
        agenteCompletarConsulta.TimezonesIdKey='Europe/Berlin';
        //agenteCompletarConsulta.UserRoleId = '00E3Y000002HoEPUA0';
        agentes.add(agenteCompletarConsulta);

        insert agentes;
    }

    @isTest
    static void cogerConsultarCancelar() {
        testSetup();

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada('s1', null, '', '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        //creamos caso manualmente
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);
        Case caso = CC_Llamada.crearVincularCaso(llamada);

        caso.CC_Detalles_Consulta__c = 'Segunda consulta del test';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        update caso;

        jsonLlamada = obtenerJsonLlamada('s1', llamadaId, caso.Id, '');

        Test.startTest();

        System.RunAs([SELECT Id FROM User WHERE Username = 'agente1@caixa.com'][0]) {
            //Realizamos una consulta
            String jsonCancelarConsulta = obtenerJsonConsulta('s2', '', caso.Id, llamadaId);
            Id consultaCanceladaId = CC_OpenCTI.registrarConsulta(jsonCancelarConsulta);


            //Cancelamos la consulta
            CC_OpenCTI.cancelarConsulta(jsonCancelarConsulta);
            CC_Llamada__c consulta = [SELECT id,CC_Fecha_Fin__c,CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE id = :consultaCanceladaId];
            Task actividad = [SELECT id,CC_Fecha_Fin__c,Status FROM Task WHERE CC_Llamada_Id__c = :consulta.Id];
            System.assertNotEquals(consulta.CC_Fecha_Fin__c, null, 'Consulta sin fecha de fin');
            System.assertEquals(consulta.CC_Tipo_Cierre__c, 'Consulta cancelada', 'Consulta sin el tipo de cierre correcto');
            System.assertNotEquals(actividad.CC_Fecha_Fin__c, null, 'Consulta sin fecha de fin');
            System.assertEquals(actividad.Status, 'Completed', 'Consulta sin el tipo de cierre correcto');
        }
        Test.stopTest();
    }

    @isTest
    static void cogerConsultarCompletarColgar() {
        testSetup();

        User agenteCompletarConsulta = [SELECT Id FROM User WHERE Username = 'agente2@caixa.com'][0];
        UserRole rol = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        agenteCompletarConsulta.UserRoleId = rol.Id;

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada('s1', null, '', '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        //creamos caso manualmente
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);
        Case caso = CC_Llamada.crearVincularCaso(llamada);

        caso.CC_Detalles_Consulta__c = 'Segunda consulta del test';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        update caso;

        jsonLlamada = obtenerJsonLlamada('s1', llamadaId, caso.Id, '');

        Test.startTest();

        String jsonCompletarConsulta;
        CC_Llamada__c consultaCompletada;

        System.RunAs(agenteCompletarConsulta) {
            //Realizamos una consulta
            jsonCompletarConsulta = obtenerJsonConsulta('s2', '', caso.Id, llamadaId);
            Id consultaCompletadaId = CC_OpenCTI.registrarConsulta(jsonCompletarConsulta);
            jsonCompletarConsulta = obtenerJsonConsulta('s2', consultaCompletadaId, caso.Id, llamadaId);
            consultaCompletada = [SELECT Id FROM CC_Llamada__c WHERE Id = :consultaCompletadaId AND CC_Fecha_Fin__c = NULL];
            Task actividadCompletada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :consultaCompletada.Id AND Type = 'Consulta a tercer nivel' AND Status = 'Open' LIMIT 1];

            //Completamos la consulta
            CC_OpenCTI.completarConsulta(jsonCompletarConsulta);
            Integer n = 0;
            for (Task t : [SELECT Type, Status, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c = :consultaCompletada.Id
                            AND Type IN ('Consulta a tercer nivel', 'Llamada transferida', 'Traslado Tercer Nivel')]) {
                if (t.Type == 'Consulta a tercer nivel' && t.Status == 'Completed' && t.CC_Tipo_Cierre__c == 'Consulta transferida') {
                    n++;
                } else if (t.Type == 'Llamada transferida' && t.Status == 'Open') {
                    n++;
                } else if (t.Type == 'Traslado Tercer Nivel' && t.Status == 'Open') {
                    n++;
                }
            }
            System.assertEquals(3, n, 'Actividades incorrectas');

            caso = [SELECT OwnerId, CC_Owner_Anterior__c FROM Case WHERE Id = :caso.Id AND Status = 'Activo' AND CC_En_Tercer_Nivel__c = true];
            System.assertNotEquals(null, caso.CC_Owner_Anterior__c, 'El owner anterior no esta vacio');
            System.assertNotEquals(caso.OwnerId, caso.CC_Owner_Anterior__c, 'El owner actual y el anterior no coinciden');

            //La llamada original finaliza
            CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Consulta completada');

            //Colgamos la llamada
            CC_OpenCTI.finalizarLlamada(jsonCompletarConsulta, 'Llamada finalizada');

            System.debug('+++ Test Queries: ' + Limits.getQueries());
            System.debug('+++ Test DMLs: ' + Limits.getDMLStatements());
        }
        Test.stopTest();

        System.debug('+++Queries: ' + Limits.getQueries());
        System.debug('+++DMLs: ' + Limits.getDMLStatements());

    }

    @isTest static void llamarSalienteColgar() {
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        Case caso = CC_Llamada_Test.crearCaso();

        //Realizar la llamada saliente
        String jsonLlamada = obtenerJsonLlamada(null, null, caso.Id, null);
        Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(null, llamadaId, caso.Id, null);
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaId AND CC_Fecha_Fin__c = NULL];
        System.assert(llamada != null);
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);
        Test.startTest();
        //Colgamos la llamada
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
        llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
        Test.stopTest();
        System.debug('Queries: ' + Limits.getQueries());
    }

    @isTest static void cogerConsultaExternaColgar() {
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();
        Case caso = crearCaso();

        Id perfilAdministradorId = obtenerPerfilAdministrador();
        User agenteConsulta  = obtenerAgente1(perfilAdministradorId);

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, '', caso.Id, '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, llamadaId, caso.Id, '');
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);
        Test.startTest();
        System.runAs(agenteConsulta) {
            //Recibimos una consulta
            String jsonConsulta = obtenerJsonConsulta(s3.CC_Codigo__c, '', caso.Id, '');
            Id consultaCanceladaId = CC_OpenCTI.registrarConsulta(jsonConsulta);
            jsonConsulta = obtenerJsonConsulta(s3.CC_Codigo__c, consultaCanceladaId, caso.Id, '');
            CC_Llamada__c consultaCancelada = obtenerLlamada(consultaCanceladaId);
            System.assert(consultaCancelada != null);

            //Cancelamos la consulta
            CC_OpenCTI.cancelarConsulta(jsonConsulta);
            consultaCancelada = [SELECT Id FROM CC_Llamada__c WHERE Id = :consultaCancelada.Id AND CC_Fecha_Fin__c != NULL AND CC_Tipo_Cierre__c = 'Consulta cancelada'];
            System.assert(consultaCancelada != null);
        }
        Test.stopTest();
    }

    @isTest static void llamadaServicioGenesysDesplieguesTest() {
        CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicioDespliegues();
        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];


        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, llamadaId, '', contacto.Account.CC_NumPerso__c);
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);


        System.assertEquals('Despliegues' , [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamadaId].CC_Canal_del_Empleado__c);
        System.assert(llamada != null);

        //Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
        Test.startTest();
        Case caso1 = CC_Llamada.crearVincularCaso(llamada);
        Test.stopTest();
        String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
        System.assertEquals(llamada.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId=:caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);
        caso1 = [SELECT Id, Canal_del_Empleado__c FROM Case WHERE Id = :caso1.Id];
        System.assert(caso1 != null);
        System.assertEquals('Despliegues' , caso1.Canal_del_Empleado__c);
    }
    @isTest static void llamadaServicioGenesysDespliegues2Test() {
        CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicioDespliegues2();
        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];
        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, llamadaId, '', contacto.Account.CC_NumPerso__c);
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);

        System.assertEquals('Despliegues2' , [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamadaId].CC_Canal_del_Empleado__c);
        System.assert(llamada != null);

        //Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
        Test.startTest();
        Case caso1 = CC_Llamada.crearVincularCaso(llamada);
        Test.stopTest();
        String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
        System.assertEquals(llamada.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId=:caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);
        caso1 = [SELECT Id, Canal_del_Empleado__c FROM Case WHERE Id = :caso1.Id];
        System.assert(caso1 != null);
        System.assertEquals('Despliegues2' , caso1.Canal_del_Empleado__c);
    }

    @isTest static void cerrarLlamadasAbiertas() {
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);

        //Creamos caso manualmente
        Test.startTest();
        CC_Llamada.crearVincularCaso(llamada);
        Test.stopTest();
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);

        //<...y por lo que sea no la finalizamos...>

        //Entra otra llamada


        Id otraLlamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
        llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);

    }

    @isTest static void cogerConsultarExternaCancelarColgar() {
        testSetup();


        Id perfilAdministradorId = obtenerPerfilAdministrador();
        User agenteConsulta = [SELECT Id FROM User WHERE Username = 'agente1@caixa.com' LIMIT 1];

        //Entra la llamada y creamos caso manualmente
        String jsonLlamada = obtenerJsonLlamada('S1', '', '', '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        Case caso = CC_Llamada.crearVincularCaso(llamada);
        jsonLlamada = obtenerJsonLlamada('S1', llamadaId, caso.Id, '');

        System.runAs(agenteConsulta) {
            //Realizamos una consulta a un servicio externo y cancelamos la consulta
            String jsonConsulta = obtenerJsonConsulta('S3', '', caso.Id, llamadaId);
            Test.startTest();
            CC_OpenCTI.finalizarConsultaExterna(jsonConsulta, 'Consulta cancelada');
            Test.stopTest();
            Task actividadCancelada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Type = 'Consulta externa' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Consulta atendida' LIMIT 1];
            System.assert(actividadCancelada != null);
        }

        //Colgamos la llamada
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
         llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);

    }

    @isTest static void registrarLlamadasEmpleados() {
        CC_Servicio_Genesys__c servicio = crearServicioEmpleado();

        List<Account> listaCuentas = new List<Account>();
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
    listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId,Name = 'Cuenta Centro CaixaBank Test 1',CC_Tipo_Centro__c = 'OF'));
    listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId,Name = 'Cuenta Centro CaixaBank Test 2',CC_Tipo_Centro__c = 'OF'));
    listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId,Name = 'Cuenta Centro CaixaBank Test 3',CC_Tipo_Centro__c = 'OF'));
        insert listaCuentas;

        List<Contact> listaContactos = new List<Contact>();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto1 OF',LastName = 'Test',CC_Idioma__c = 'es',
                           Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[0].Id));
        listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto2 OF',LastName = 'Test',CC_Idioma__c = 'es',
                           Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[1].Id));
        listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto3 OF',LastName = 'Test',CC_Idioma__c = 'es',
                           Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[2].Id));
        insert listaContactos;

        List<CC_Canal_Com__c> listaCanales = new List<CC_Canal_Com__c>();
    Id recordTypeTelefono = Schema.getGlobalDescribe().get('CC_Canal_Com__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001122', CC_ContactoId__c=listaContactos[0].Id, CC_CuentaId__c=listaCuentas[0].Id, RecordTypeId = recordTypeTelefono));
        listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001133', CC_ContactoId__c=listaContactos[1].Id, CC_CuentaId__c=listaCuentas[1].Id, RecordTypeId = recordTypeTelefono));
        listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001133', CC_ContactoId__c=listaContactos[2].Id, CC_CuentaId__c=listaCuentas[2].Id, RecordTypeId = recordTypeTelefono));
        insert listaCanales;
        Test.startTest();
        String jsonLlamadaTelefonoUnico     = obtenerJsonLlamada(servicio.CC_Codigo__c, '', '', '666', '666001122');
        CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaTelefonoUnico);
        String jsonLlamadaTelefonoDuplicado = obtenerJsonLlamada(servicio.CC_Codigo__c, '', '', '777', '666001133');
        CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaTelefonoDuplicado);

        List<CC_Llamada__c> listaLlamadas = [SELECT CC_Cuenta__c, CC_Contacto__c FROM CC_Llamada__c ORDER BY CC_DNIS__c ASC];
        // Primera llamada deberia funcionar, porque solo hay un empleado con ese numero de telefono
        System.assertEquals(listaContactos[0].Id, listaLlamadas[0].CC_Contacto__c);
        System.assertEquals(listaCuentas[0].Id, listaLlamadas[0].CC_Cuenta__c);
        // Segunda llamada deberia fallar, porque hay dos empleados con el mismo numero de telefono
        System.assertEquals(null, listaLlamadas[1].CC_Contacto__c);
        System.assertEquals(null, listaLlamadas[1].CC_Cuenta__c);
        Test.stopTest();
    }

    private class MockHttpResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {

            System.assertEquals('https://PASOfile-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3', req.getEndpoint());
          System.assertEquals('GET', req.getMethod());
            System.assertEquals('keep-alive', req.getHeader('Connection'));

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);

            return res;
        }
    }

    @isTest static void obtenerGrabacion() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        String response = CC_Llamada.obtenerGrabacion('baia', 'baia', 'baia');
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

        @isTest static void obtenerUrl() {

        Test.startTest();
        String response = CC_Llamada.obtenerUrl('2020-03-18', '123456789', '1118');
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    @isTest static void cogerConsultaEmpleadosColgar() {
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();
        List<Contact> listaContactos = crearContactos();
        Case caso = crearCaso();

        //Widget de telefonía recupera los metadatos de configuración de telefonía
        String configuracionTelefoniaJson = CC_OpenCTI.obtenerConfiguracionTelefonia();
        List<CC_Llamada_Input> configuracionTelefonia =  (List<CC_Llamada_Input>)JSON.deserialize(configuracionTelefoniaJson, List<CC_Llamada_Input>.class);
        System.assert(configuracionTelefonia.size() > 0);

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, '', caso.Id, '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, llamadaId, caso.Id, '');
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);

        //El usuario informa la cuenta en la llamada
        llamada.CC_Cuenta__c = listaContactos[2].AccountId;
        update llamada;
        Test.startTest();
        // Widget recupera el nombre del empleado gestor de la llamada para mostrarselo como opción al usuario
        Contact empleadoGestor = CC_OpenCTI.obtenerEmpleadoGestor(llamada.Id);
        System.assertEquals(empleadoGestor.Id, listaContactos[0].Id);

        //Consulta externa al empleado gestor de la cuenta de la llamada
        String jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, empleadoGestor.Id, empleadoGestor.Canales_Comunicacion__r[0].CC_Telefono__c);
        CC_OpenCTI.finalizarConsultaExterna(jsonConsultaExterna, 'Consulta cancelada');
        List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta atendida' AND CC_Empleado_Gestor__c = :empleadoGestor.Id];
        System.assertEquals(1, listaTareas.size());

        //Consulta externa a un número de teléfono que conseguimos identificar
        jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, '', '690998877');
        CC_OpenCTI.finalizarConsultaExterna(jsonConsultaExterna, 'Consulta cancelada');
        listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta atendida' AND CC_Empleado_Gestor__c = :listaContactos[1].Id];
        System.assertEquals(1, listaTareas.size());

        //Consulta externa a un número de teléfono que NO conseguimos identificar
        jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, '', '690111000');
        CC_OpenCTI.finalizarConsultaExterna(jsonConsultaExterna, 'Consulta cancelada');
        listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta atendida' AND CC_Empleado_Gestor__c = null];
        System.assertEquals(1, listaTareas.size());

        //Colgamos la llamada
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
         llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
        Test.stopTest();
    }

    @isTest static void cogerConsultaNoAtendidaEmpleados() {
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();
        List<Contact> listaContactos = crearContactos();
        Case caso = crearCaso();

        Test.startTest();
        //Widget de telefonía recupera los metadatos de configuración de telefonía
        String configuracionTelefoniaJson = CC_OpenCTI.obtenerConfiguracionTelefonia();
        List<CC_Llamada_Input> configuracionTelefonia =  (List<CC_Llamada_Input>)JSON.deserialize(configuracionTelefoniaJson, List<CC_Llamada_Input>.class);
        System.assert(configuracionTelefonia.size() > 0);

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, '', caso.Id, '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, llamadaId, caso.Id, '');
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);

        //Consulta externa a un número de teléfono que conseguimos identificar
        String jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, '', '690998877');
        CC_OpenCTI.registrarConsultaNoAtendida(jsonLlamada, jsonConsultaExterna);
        List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = :listaContactos[1].Id];
        System.assertEquals(1, listaTareas.size());

        //Consulta externa a un número de teléfono que NO conseguimos identificar
        jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, '', '690111000');
        CC_OpenCTI.registrarConsultaNoAtendida(jsonLlamada, jsonConsultaExterna);
        listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = null];
        System.assertEquals(1, listaTareas.size());

        //Colgamos la llamada
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
         llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
        Test.stopTest();
    }

    @isTest static void cogerConsultaEmpleadoCompletar() {
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();
        List<Contact> listaContactos = crearContactos();
        Case caso = crearCaso();

        //Widget de telefonía recupera los metadatos de configuración de telefonía
        String configuracionTelefoniaJson = CC_OpenCTI.obtenerConfiguracionTelefonia();
        List<CC_Llamada_Input> configuracionTelefonia =  (List<CC_Llamada_Input>)JSON.deserialize(configuracionTelefoniaJson, List<CC_Llamada_Input>.class);
        System.assert(configuracionTelefonia.size() > 0);

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, '', caso.Id, '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, llamadaId, caso.Id, '');
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);

        //El usuario informa la cuenta en la llamada
        llamada.CC_Cuenta__c = listaContactos[2].AccountId;
        update llamada;
        Test.startTest();
        // Widget recupera el nombre del empleado gestor de la llamada para mostrarselo como opción al usuario
        Contact empleadoGestor = CC_OpenCTI.obtenerEmpleadoGestor(llamada.Id);
        System.assertEquals(empleadoGestor.Id, listaContactos[0].Id);

        //Consulta externa al empleado gestor de la cuenta de la llamada
        String jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, listaContactos[0].Id, '690112233');
        CC_OpenCTI.finalizarConsultaExterna(jsonConsultaExterna, 'Consulta completada');
        List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta transferida' AND CC_Empleado_Gestor__c = :listaContactos[0].Id];
        System.assertEquals(1, listaTareas.size());

        //Se cuelga la llamada al transferir al completar la consulta
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
         llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
        Test.stopTest();
    }

    @isTest
    static void obtenerPrefijo() {
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();

        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);
        Case caso = CC_Llamada.crearVincularCaso(llamada);
        Test.startTest();
      String prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Cliente nacional', caso.Id);
        System.assert(prefijo != null);
        Test.stopTest();
    }

    @isTest
    public static void testRecuperarDatosCaso() {

        Contact testContacto = new Contact();
        testContacto.FirstName = 'José María';
        testContacto.LastName = 'Martín Bernal';
        insert testContacto;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = testContacto.Id;
        insert caso;
        Test.startTest();
        Case resultadoLLamada = CC_OpenCTI.obtenerCaso(caso.Id);

        System.assertEquals('Caso Test', resultadoLLamada.Subject);
        System.assertEquals('José María Martín Bernal', resultadoLLamada.Contact.Name);
        Test.stopTest();
    }

    @isTest
    public static void test() {
        Id userId = UserInfo.getUserId();
        CC_Usuario_Genesys__c usuarioGen = new CC_Usuario_Genesys__c(
            CC_User__c = userId,
            Name = 'LOGINTEST',
            CC_DN__c = '1234',
            CC_Acceso__c = 'Teléfono;Chat'
        );
        insert usuarioGen;
        Test.startTest();
        CC_Usuario_Genesys__c datosUsuarioGen = CC_OpenCTI.obtenerUsuarioGenesys();
        System.assertEquals(userId, datosUsuarioGen.CC_User__c);
        System.assertEquals('LOGINTEST', datosUsuarioGen.Name);
        System.assertEquals('1234', datosUsuarioGen.CC_DN__c);
        System.assertEquals('Teléfono;Chat', datosUsuarioGen.CC_Acceso__c);
        Test.stopTest();
    }

    @isTest
  public static void getServicioGenesys() {
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();

        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);
        Case caso = CC_Llamada.crearVincularCaso(llamada);
        Test.startTest();
    CC_Servicio_Genesys__c servicio = CC_OpenCTI.obtenerServicioGenesys('S1');
        System.assert(servicio != null);

        servicio = CC_OpenCTI.obtenerServicioGenesysDesdeCaso(caso.Id);
        System.assert(servicio != null);

        String prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Cliente nacional', caso.Id);
        System.assert(prefijo != null);
        prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Cliente internacional', caso.Id);
        System.assert(prefijo != null);
        prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Empleado nacional', caso.Id);
        System.assert(prefijo != null);
        prefijo = CC_OpenCTI.obtenerPrefijo('666666666', 'Empleado internacional', caso.Id);
        System.assert(prefijo != null);
        prefijo = CC_OpenCTI.obtenerPrefijo('66666', 'Empleado nacional', caso.Id);
        System.assert(prefijo != null);
        Test.stopTest();
    }

    @isTest
    public static void obtenerEstadoOmnichannel(){
        Test.startTest();
        ServicePresenceStatus presenceStatus = CC_OpenCTI.obtenerEstadoOmnichannel('Disponible');
        System.assert(presenceStatus != null);
        Test.stopTest();
    }

    @isTest static void finalizarConsulta() {
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();
        List<Contact> listaContactos = crearContactos();
        Case caso = crearCaso();

        //Widget de telefonía recupera los metadatos de configuración de telefonía
        String configuracionTelefoniaJson = CC_OpenCTI.obtenerConfiguracionTelefonia();
        List<CC_Llamada_Input> configuracionTelefonia =  (List<CC_Llamada_Input>)JSON.deserialize(configuracionTelefoniaJson, List<CC_Llamada_Input>.class);
        System.assert(configuracionTelefonia.size() > 0);

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, '', caso.Id, '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, llamadaId, caso.Id, '');
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);

        //El usuario informa la cuenta en la llamada
        llamada.CC_Cuenta__c = listaContactos[2].AccountId;
        update llamada;
        Test.startTest();
        // Widget recupera el nombre del empleado gestor de la llamada para mostrarselo como opción al usuario
        Contact empleadoGestor = CC_OpenCTI.obtenerEmpleadoGestor(llamada.Id);
        System.assertEquals(empleadoGestor.Id, listaContactos[0].Id);

        //Consulta externa al empleado gestor de la cuenta de la llamada
        String jsonConsultaExterna = obtenerJsonConsulta(caso.Id, llamadaId, listaContactos[0].Id, '690112233');
        CC_OpenCTI.finalizarConsulta(jsonConsultaExterna, 'Consulta completada');
        Test.stopTest();
    }


    /*@isTest
    public static void enviarInteraccion(){
        String presenceStatus = CC_OpenCTI.enviarInteraccion('Disponible');
    }  */

    /***************************** EMPLEADOS CSI BANKIA ***************************************************/

    @isTest static void registrarLlamadasEmpleadosCSI() {
        CC_Servicio_Genesys__c servicio = crearServicioEmpleadoCSI();

        List<Account> listaCuentas = new List<Account>();
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
    listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId,Name = 'Cuenta Centro CaixaBank Test 1',CC_Tipo_Centro__c = 'OF'));
    listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId,Name = 'Cuenta Centro CaixaBank Test 2',CC_Tipo_Centro__c = 'OF'));
    listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId,Name = 'Cuenta Centro CaixaBank Test 3',CC_Tipo_Centro__c = 'OF'));
        insert listaCuentas;

        List<Contact> listaContactos = new List<Contact>();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto1 OF',LastName = 'Test',CC_Idioma__c = 'es',
                           Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[0].Id));
        listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto2 OF',LastName = 'Test',CC_Idioma__c = 'es',
                           Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[1].Id));
        listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto3 OF',LastName = 'Test',CC_Idioma__c = 'es',
                           Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[2].Id));
        insert listaContactos;

        List<CC_Canal_Com__c> listaCanales = new List<CC_Canal_Com__c>();
    Id recordTypeTelefono = Schema.getGlobalDescribe().get('CC_Canal_Com__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001122', CC_ContactoId__c=listaContactos[0].Id, CC_CuentaId__c=listaCuentas[0].Id, RecordTypeId = recordTypeTelefono));
        listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001133', CC_ContactoId__c=listaContactos[1].Id, CC_CuentaId__c=listaCuentas[1].Id, RecordTypeId = recordTypeTelefono));
        listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001133', CC_ContactoId__c=listaContactos[2].Id, CC_CuentaId__c=listaCuentas[2].Id, RecordTypeId = recordTypeTelefono));
        insert listaCanales;
        Test.startTest();
        String jsonLlamadaTelefonoUnico     = obtenerJsonLlamada(servicio.CC_Codigo__c, '', '', '666', '666001122');
        CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaTelefonoUnico);
        String jsonLlamadaTelefonoDuplicado = obtenerJsonLlamada(servicio.CC_Codigo__c, '', '', '777', '666001133');
        CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaTelefonoDuplicado);

        List<CC_Llamada__c> listaLlamadas = [SELECT CC_Cuenta__c, CC_Contacto__c FROM CC_Llamada__c ORDER BY CC_DNIS__c ASC];

        // Primera llamada deberia funcionar, porque solo hay un empleado con ese numero de telefono
        System.assertEquals(listaContactos[0].Id, listaLlamadas[0].CC_Contacto__c);
        System.assertEquals(listaCuentas[0].Id, listaLlamadas[0].CC_Cuenta__c);
        // Segunda llamada deberia fallar, porque hay dos empleados con el mismo numero de telefono
        System.assertEquals(null, listaLlamadas[1].CC_Contacto__c);
        System.assertEquals(null, listaLlamadas[1].CC_Cuenta__c);

        Id recordTypeCasoEmpleadoCSI = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
        List<Case> casosList = [SELECT Id, RecordType.DeveloperName, ContactId FROM Case WHERE RecordTypeId = : recordTypeCasoEmpleadoCSI];
        System.assertEquals(listaContactos[0].Id, casosList[0].ContactId);
        System.assertEquals('CC_CSI_Bankia', casosList[0].RecordType.DeveloperName, 'El recordType del caso es CC_CSI_Bankia');
        //System.assertEquals(1, casosList.size(), 'Se ha creado un caso con todas las llamadas');
        Test.stopTest();
    }

     @isTest static void interaccionTest() {
        Test.startTest();
        CC_OpenCTI.CC_InteraccionInput a = New CC_OpenCTI.CC_InteraccionInput();
        string externalId = a.externalId;
        string interactionId=a.interactionId;
        string ticketId=a.ticketId;
        string proxyClientId=a.proxyClientId;
        string medio=a.medio;
        string usuario=a.usuario;
        string extension=a.extension;
        string workItemId=a.workItemId;
        string pendingServiceRoutingId=a.pendingServiceRoutingId;
        System.assertEquals(externalId, a.externalId, 'No se ha realizado correctamente la asignación de campos');
        Test.stopTest();
    }




    @isTest static void llamadaServicioGenesysDesbordeTest() {
        CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicioDesbordeCSI();
        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];

        Test.startTest();
        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, llamadaId, '', contacto.Account.CC_NumPerso__c);
        CC_Llamada__c llamada = obtenerLlamada(llamadaId);

        System.assertEquals('CSI' , [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamadaId].CC_Canal_del_Empleado__c);
        System.assert(llamada != null);

        //Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
        Case caso1 = CC_Llamada.crearVincularCaso(llamada);



        String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
        System.assertEquals(llamada.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
        Test.stopTest();
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId=:caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);
        caso1 = [SELECT Id, Canal_del_Empleado__c FROM Case WHERE Id = :caso1.Id];
        System.assert(caso1 != null);
        System.assertEquals('CSI' , caso1.Canal_del_Empleado__c);
    }

    @isTest
  public static void registrarEncuestaLlamadaSaliente() {
        CC_Servicio_Genesys__c servicioEncuesta = CC_Llamada_Test.crearServicioEncuesta();
        CC_Servicio_Genesys__c servicio = CC_Llamada_Test.crearServicio1();
        servicio.CC_Encuesta__c = servicioEncuesta.Id;
        update servicio;

        Case caso = CC_Llamada_Test.crearCaso();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, null, caso.Id, null);
        Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);
        jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, llamadaId, caso.Id, null);

        Test.startTest();
        CC_OpenCTI.registrarEncuesta(jsonLlamada);
        Test.stopTest();

        List<CC_Llamada__c> llamadaSaliente = [SELECT Id, CC_Encuesta__c FROM CC_Llamada__c WHERE Id =: llamadaId];
        System.assertEquals(1, llamadaSaliente.size());
        System.assertEquals(servicioEncuesta.Id, llamadaSaliente[0].CC_Encuesta__c);

        List<Task> tareaRegistroEncuesta = [SELECT Id, Type, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c =: llamadaId AND Type = 'Encuesta'];
        System.assertEquals(1, tareaRegistroEncuesta.size());
        System.assertEquals('Encuesta', tareaRegistroEncuesta[0].Type);
        System.assertEquals('Encuesta enviada', tareaRegistroEncuesta[0].CC_Tipo_Cierre__c);
    }
    @isTest
	public static void informarLlamadaEnCursoTest() {

        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];

        Case caso = new Case(
        	ContactId = contacto.Id
        );
		insert caso;

        Task tarea = new Task(
          WhatId = caso.Id
        );
        insert tarea;

        List<Id> idNuevasTareas = new List<Id>();
        idNuevasTareas.add(tarea.id);

        Test.startTest();
        CC_Llamada.informarLlamadaEnCurso(idNuevasTareas);
        Test.stopTest();

         List<Task> tareaActualizada = [SELECT WhatId FROM Task WHERE Id IN :idNuevasTareas];
         System.assertEquals(tareaActualizada[0].Id, tarea.id);
    }

     @isTest static void finalizarLlamadaTest() {
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        Case caso = CC_Llamada_Test.crearCaso();

        //Realizar la llamada saliente
        String jsonLlamada = obtenerJsonLlamada(null, null, caso.Id, null);
        Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(null, llamadaId, caso.Id, null);
         jsonLlamada = jsonLlamada.replace(llamadaId, '');
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaId AND CC_Fecha_Fin__c = NULL];
        System.assert(llamada != null);
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Open' LIMIT 1];
        System.assert(actividad != null);
        Test.startTest();
        //Colgamos la llamada
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
       	llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
        Test.stopTest();
    }

     @isTest
    	static void finalizarConsultaExternaExceptionTest() {
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();

        Id perfilAdministradorId = obtenerPerfilAdministrador();
        User agenteConsulta  = obtenerAgente1(perfilAdministradorId);

        //Entra la llamada y creamos caso manualmente
        String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);

        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        Case caso = CC_Llamada.crearVincularCaso(llamada);
		jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, llamadaId, caso.Id, '');
        System.runAs(agenteConsulta) {
            //Realizamos una consulta a un servicio externo y cancelamos la consulta
            String jsonConsulta = obtenerJsonConsulta(s3.CC_Codigo__c, '', caso.Id, llamadaId);
             jsonConsulta = jsonConsulta.replace(s3.CC_Codigo__c, '');
            Test.startTest();

            try{
           	 CC_OpenCTI.finalizarConsultaExterna(jsonConsulta, 'Consulta cancelada');
            }catch (Exception e) {
                System.assertEquals(e.getMessage(),'No se puede finalizar una consulta externa sin servicio/empleado.' );
            }
             Test.stopTest();
           // Task actividadCancelada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Type = 'Consulta externa' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Consulta atendida' LIMIT 1];
            //System.assert(actividadCancelada != null);
        }
     }

    @isTest static void registrarConsultaNoAtendidaExceptionTest() {
        CC_Servicio_Genesys__c s3 = CC_Llamada_Test.crearServicio3();
        List<Contact> listaContactos = crearContactos();
        Case caso = crearCaso();
        Test.startTest();
        //Widget de telefonía recupera los metadatos de configuración de telefonía
        String configuracionTelefoniaJson = CC_OpenCTI.obtenerConfiguracionTelefonia();
        List<CC_Llamada_Input> configuracionTelefonia =  (List<CC_Llamada_Input>)JSON.deserialize(configuracionTelefoniaJson, List<CC_Llamada_Input>.class);
        System.assert(configuracionTelefonia.size() > 0);

        //Entra la llamada
        String jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, '', caso.Id, '');
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        jsonLlamada = obtenerJsonLlamada(s3.CC_Codigo__c, llamadaId, caso.Id, '');

        CC_Llamada__c llamada = obtenerLlamada(llamadaId);
        System.assert(llamada != null);

        //Consulta externa a un número de teléfono que conseguimos identificar
        String jsonConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaId, '', '690998877');
        CC_OpenCTI.registrarConsultaNoAtendida( jsonConsultaExterna, jsonLlamada);
        List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = :listaContactos[1].Id];
        System.assertEquals(0, listaTareas.size());

        //Colgamos la llamada
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada finalizada');
        Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(actividad != null);
       	llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
        System.assert(llamada != null);
        Test.stopTest();
    }


}