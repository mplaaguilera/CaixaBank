@IsTest
public class CC_Agrupador_Test { 

    static Id crearAgrupador() {
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador.CC_Titulo__c = 'Prueba';
        agrupador.CC_Estado__c = 'Cerrado';
		agrupador.CC_Descripcion__c = 'Prueba TEST';
        agrupador.CC_CanalEntrada__c = 'Twitter';
        agrupador.CC_CanalProcedencia__c = 'ImaginBank';
        agrupador.CC_Fecha_Cierre__c =  Datetime.valueOf(system.now());
        insert agrupador;
        return agrupador.Id;
    }

    class MCC_Collection { Id tematica, productoServicio, motivo, causa, solucion; }
    static MCC_Collection crearMCCs() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.Name = 'App\'s';
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App Imagin';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.Name = 'APP CaixaBank';
        productoServicio.CC_Detalle__c = 'CaixaBank';
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.Name = 'Valoración positiva';
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;


        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        causa.Name = 'Problemas técnicos';
        causa.CC_Tipo_Cliente__c = 'Cliente';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CA-000001';
        insert causa;

        CC_MCC__c solucion = new CC_MCC__c();
        solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.Name = 'Actualizar Sistema';
        solucion.CC_Tipo_Cliente__c = 'Cliente';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'CA-000002';
        insert solucion;

        MCC_Collection result = new MCC_Collection();
        result.tematica = tematica.Id;
        result.productoServicio = productoServicio.Id;
        result.motivo = motivo.Id;
        result.causa = causa.Id;
        result.solucion = solucion.Id;
        return result;
    }

    static Id crearCasoInformado(MCC_Collection mccIds, Id agrupadorId) {
        Account cuenta = new Account();
        cuenta.Name = 'Test Account';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        insert contacto;        

        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Pendiente Incidencia';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Detalles_Consulta__c = 'Información';
        caso.CC_Canal_Operativo__c = 'App Imagin';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_MCC_Tematica__c = mccIds.tematica;
		caso.CC_MCC_ProdServ__c = mccIds.productoServicio;
        caso.CC_MCC_Motivo__c = mccIds.motivo;
        caso.CC_MCC_Causa__c = mccIds.causa;
        caso.CC_MCC_Solucion__c = mccIds.solucion;

        caso.CC_Agrupador_Id__c = agrupadorId;
        insert caso;

        Task tarea = new Task();
        tarea.WhatId = caso.Id;
        tarea.CC_Chat_Cognitivo_Id__c = 'HDD_666555666';
        tarea.Status = 'Open';
        tarea.Subject = 'Incidencia';
        tarea.Type = 'Traslado Incidencia';
        tarea.Agrupador__c = agrupadorId;
        insert tarea;

        return caso.Id;
    }

    static Id crearCasoSinInformar(Id agrupadorId) {
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Pendiente Incidencia';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Agrupador_Id__c = agrupadorId;
        insert caso;

        Task tarea = new Task();
        tarea.WhatId = caso.Id;
        tarea.Type = 'Traslado Incidencia';
        tarea.Status = 'Completed';
        tarea.Subject = 'Traslado a Incidencia';
        tarea.Agrupador__c = agrupadorId;
        insert tarea;

        return caso.Id;
    }

    static void crearListaDeValores() {
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;
        
        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '2';
        CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos.CC_Activa__c = true;
        valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos.CC_Valor__c = '50';
        
        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        valorUmbralInsert.add(valorUmbralPrimerAviso);
        valorUmbralInsert.add(valorUmbralSiguientesAvisos);
    	insert valorUmbralInsert;


    }

    static CC_PlantillaAsociada__c crearPlantillasAgrupador(Id agrupadorId) {
        CC_PlantillaAsociada__c plantillaAgrupador = new CC_PlantillaAsociada__c();
        plantillaAgrupador.CC_Agrupador__c = agrupadorId;
        plantillaAgrupador.CC_Idioma__c = 'es';
        plantillaAgrupador.CC_Tipo_Cliente__c = 'Empleado';
        plantillaAgrupador.CC_CuerpoNotificacion__c = 'Cuerpo email';
        insert plantillaAgrupador;

        return plantillaAgrupador;
    }

	@isTest
    static void cierreAgrupador() {
        Id agrupadorId = crearAgrupador();
        MCC_Collection mccIds = crearMCCs();
        Id casoId = crearCasoInformado(mccIds, agrupadorId);
        CC_PlantillaAsociada__c plantillaAgrupador = crearPlantillasAgrupador(agrupadorId);

        CC_Agrupacion_Casos__c gruposCasos = new CC_Agrupacion_Casos__c();
        gruposCasos.Name = 'Agrupador Casos';
        gruposCasos.CC_Grupos_Casos__c = 5;
        insert gruposCasos;
        
        List<ID> listaAgrupadores = new List<ID>();
        listaAgrupadores.add(agrupadorId);
        Test.startTest();
        CC_Agrupador.cierreAgrupador(listaAgrupadores);
        Test.stopTest();

        Case caso = [SELECT Status FROM Case WHERE Id = :casoId];
        System.assertEquals('Cerrado', caso.Status);
    }

    @isTest
    static void cierreAgrupadorNOK() {
        Id agrupadorId = crearAgrupador();
        Id casoId = crearCasoSinInformar(agrupadorId);

        CC_Agrupacion_Casos__c gruposCasos = new CC_Agrupacion_Casos__c();
        gruposCasos.Name = 'Agrupador Casos';
        gruposCasos.CC_Grupos_Casos__c = 5;
        insert gruposCasos;

        List<ID> listaAgrupadores = new List<ID>();
        listaAgrupadores.add(agrupadorId);
        Test.startTest();
        CC_Agrupador.cierreAgrupador(listaAgrupadores);
        Test.stopTest();

        Case caso = [SELECT Status FROM Case WHERE Id = :casoId];
        System.assertEquals('Pendiente Revisión', caso.Status);
    }

    @isTest
    static void actualizarNumeroCasos() {
        crearListaDeValores();
        Id agrupadorId = crearAgrupador();
        MCC_Collection mccIds = crearMCCs();
        Id casoId = crearCasoInformado(mccIds, agrupadorId);

        List<ID> listaAgrupadores = new List<ID>();
        listaAgrupadores.add(agrupadorId);
        Test.startTest();
        System.debug('Antes de CC_Agrupador.actualizarNumeroCasos');
        CC_Agrupador.actualizarNumeroCasos(listaAgrupadores);
        System.debug('Tras CC_Agrupador.actualizarNumeroCasos');
        Test.stopTest();

        CC_Agrupador__c agrupador = [SELECT CC_Numero_Casos__c FROM CC_Agrupador__c WHERE Id = :agrupadorId];
        System.assertEquals(1, agrupador.CC_Numero_Casos__c);
    }
}