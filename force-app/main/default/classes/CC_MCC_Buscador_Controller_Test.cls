@isTest
public with sharing class CC_MCC_Buscador_Controller_Test {

    @isTest
    public static void testQuerySalesforceRecord() {

        Map<String, CC_MCC__c> mccRegistrosCC = altaClasificacionPrueba('Cliente', 'NomTematica1', 'NomProd1', 'NomMotiu1');
        Map<String, CC_MCC__c> mccRegistrosCops = altaClasificacionPrueba('Cliente (COPS)', 'NomTematica2', 'NomProd2', 'NomMotiu2');
        Map<String, CC_MCC__c> mccRegistrosCam = altaClasificacionPrueba('Cliente (CAM)', 'NomTematica3', 'NomProd3', 'NomMotiu3');

        Case casoCC = new Case();
        casoCC.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        casoCC.Subject = 'Caso Test CC';
        insert casoCC;

        Case casoCops = new Case();
        casoCops.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        casoCops.Subject = 'Caso Test Cops';
        casoCops.Origin = 'Email';
        casoCops.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        casoCops.cc_Tipo_Contacto__c = 'Asesoramiento';
        insert casoCops;

        Case casoCam = new Case();
        casoCam.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'AM_Cliente');
        casoCam.Subject = 'Caso Test Cam';
        insert casoCam;

        Case casoSegmentos = new Case();
        casoSegmentos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        casoSegmentos.Subject = 'Caso Test Segmentos';
        insert casoSegmentos;

        Test.startTest();
        //Llamada nueva
        String queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%Prod%\'';
        queryString += ' AND RecordType.DeveloperName = \'CC_Motivo\' AND CC_Activo__c = true';
        List<sObject> resultadosCC = CC_MCC_Buscador_Controller.querySalesforceRecord(casoCC.Id, queryString, 15);
        List<sObject> resultadosCops = CC_MCC_Buscador_Controller.querySalesforceRecord(casoCops.Id, queryString, 15);
        List<sObject> resultadosCam = CC_MCC_Buscador_Controller.querySalesforceRecord(casoCam.Id, queryString, 15);
        List<sObject> resultadosSegmentos = CC_MCC_Buscador_Controller.querySalesforceRecord(casoSegmentos.Id, queryString, 15);

        Test.stopTest();

        System.assertEquals(mccRegistrosCC.get('motivo').Id, resultadosCC[0].Id);
        System.assertEquals(mccRegistrosCops.get('motivoCOPS').Id, resultadosCops[1].Id);
        System.assertEquals(mccRegistrosCam.get('motivoCAM').Id, resultadosCam[2].Id);

    }

    @isTest
    public static void testActualizarCaso() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        caso.Subject = 'Caso Test';
        insert caso;

        Test.startTest();
        CC_MCC_Buscador_Controller.actualizarCaso(caso.Id, motivo.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
        System.assertEquals(motivo.Id, casoQuery.CC_MCC_Motivo__c);
    }

  @isTest
    public static void testActualizarCasoSAC() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

    CC_MCC__c detalle = new CC_MCC__c();
        detalle.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        detalle.Name = 'Detalle';
        detalle.CC_Motivo__c = motivo.Id;
        detalle.CC_Codigo_Externo__c = 'DE-000001';
        insert detalle;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        Test.startTest();
        CC_MCC_Buscador_Controller.actualizarCasoSAC(caso.Id, detalle.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
    }

    public static void testActualizarCasoCOPS() {

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }

        CC_MCC__c tematicaCOPS = new CC_MCC__c();
        tematicaCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaCOPS.CC_Tipo_Cliente__c = 'Cliente(COPS)';
        tematicaCOPS.Name = 'Temática Test OS';
        tematicaCOPS.OS_Departamento__c = 'UAC';
        tematicaCOPS.CC_Codigo_Externo__c = 'TE-000002';
        tematicaCOPS.OS_Horas_SLA__c = '24' ;
        tematicaCOPS.OS_Horario__C = businessHoursId;
        insert tematicaCOPS;

        CC_MCC__c productoServicioCOPS = new CC_MCC__c();
        productoServicioCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicioCOPS.CC_Tipo_Cliente__c = 'Cliente(COPS)';
        productoServicioCOPS.Name = 'Producto/Servicio Test OS';
        productoServicioCOPS.CC_Tematica__c = tematicaCOPS.Id;
        productoServicioCOPS.CC_Codigo_Externo__c = 'PR-000002';
        insert productoServicioCOPS;

        CC_MCC__c motivoCOPS = new CC_MCC__c();
        motivoCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivoCOPS.CC_Tipo_Cliente__c = 'Cliente(COPS)';
        motivoCOPS.Name = 'Motivo';
        motivoCOPS.CC_Producto_Servicio__c = productoServicioCOPS.Id;
        motivoCOPS.CC_Codigo_Externo__c = 'MO-000002';
        insert motivoCOPS;

        Case caso = new Case();
        caso.Subject = 'Caso Test COPS';
        insert caso;

        Test.startTest();
        CC_MCC_Buscador_Controller.actualizarCaso(caso.Id, motivoCOPS.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematicaCOPS.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicioCOPS.Id, casoQuery.CC_MCC_ProdServ__c);
        System.assertEquals(motivoCOPS.Id, casoQuery.CC_MCC_Motivo__c);
        }

    public static void testActualizarCasoCAM() {

        CC_MCC__c tematicaCAM = new CC_MCC__c();
        tematicaCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaCAM.CC_Tipo_Cliente__c = 'Cliente(CAM)';
        tematicaCAM.Name = 'Temática Test CAM';
        tematicaCAM.CC_Codigo_Externo__c = 'TE-000003';
        insert tematicaCAM;

        CC_MCC__c productoServicioCAM = new CC_MCC__c();
        productoServicioCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicioCAM.CC_Tipo_Cliente__c = 'Cliente(CAM)';
        productoServicioCAM.Name = 'Producto/Servicio Test CAM';
        productoServicioCAM.CC_Tematica__c = tematicaCAM.Id;
        productoServicioCAM.CC_Codigo_Externo__c = 'PR-000003';
        insert productoServicioCAM;

        CC_MCC__c motivoCAM = new CC_MCC__c();
        motivoCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivoCAM.CC_Tipo_Cliente__c = 'Cliente(CAM)';
        motivoCAM.Name = 'Motivo';
        motivoCAM.CC_Producto_Servicio__c = productoServicioCAM.Id;
        motivoCAM.CC_Codigo_Externo__c = 'MO-000003';
        insert motivoCAM;

        Case caso = new Case();
        caso.Subject = 'Caso Test CAM';
        insert caso;

        Test.startTest();
        CC_MCC_Buscador_Controller.actualizarCaso(caso.Id, motivoCAM.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematicaCAM.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicioCAM.Id, casoQuery.CC_MCC_ProdServ__c);
        System.assertEquals(motivoCAM.Id, casoQuery.CC_MCC_Motivo__c);
        }


  @isTest
    public static void testActualizarCasoSEG_Detalle() {
        
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Segmentos';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Segmentos';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Segmentos';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

    CC_MCC__c detalle = new CC_MCC__c();
        detalle.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        detalle.CC_Tipo_Cliente__c = 'Segmentos';
        detalle.Name = 'Detalle';
        detalle.CC_Motivo__c = motivo.Id;
        detalle.CC_Codigo_Externo__c = 'DE-000001';
        insert detalle;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        caso.Subject = 'Caso Test';
        insert caso;

        Test.startTest();
        
        //Llamada nueva
        String queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%Prod%\'';
        queryString += ' AND RecordType.DeveloperName = \'CC_Motivo\' AND CC_Activo__c = true';
    List<sObject> resultadosSegmentos = CC_MCC_Buscador_Controller.querySalesforceRecord(caso.Id, queryString, 15);
        
    CC_MCC_Buscador_Controller.actualizarCasoSEG(caso.Id, detalle.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,SEG_Detalle__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
        System.assertEquals(motivo.Id, casoQuery.CC_MCC_Motivo__c);
    System.assertEquals(detalle.Id, casoQuery.SEG_Detalle__c);
    }

  @isTest
    public static void testActualizarCasoServicio() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        caso.Subject = 'Caso Test';
        insert caso;

        Test.startTest();
        
        //Llamada nueva
        String queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%Prod%\'';
        queryString += ' AND RecordType.DeveloperName = \'CC_Motivo\' AND CC_Activo__c = true';
    List<sObject> resultadosSegmentos = CC_MCC_Buscador_Controller.querySalesforceRecord(caso.Id, queryString, 15);
        
    CC_MCC_Buscador_Controller.actualizarCasoSEG(caso.Id, productoServicio.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
    }

    @isTest
    public static void testGetTipificacion() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.Name = 'Motivo Test';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = productoServicio.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        insert caso;

        Test.startTest();
        Case datosCaso = CC_MCC_Buscador_Controller.getTipificacion(caso.Id);
        Test.stopTest();

        System.assertNotEquals(null, datosCaso);

    //El caracter '\u2192' es una flecha a la derecha (→)
        String tipificacion = datosCaso.CC_MCC_Tematica__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_ProdServ__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_Motivo__r.Name;

        System.assertEquals('Temática Test → Producto/Servicio Test → Motivo Test', tipificacion);
    }

        public static void testGetTipificacionCOPS() {

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }

        CC_MCC__c tematicaCOPS = new CC_MCC__c();
        tematicaCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaCOPS.CC_Tipo_Cliente__c = 'Cliente(COPS)';
        tematicaCOPS.Name = 'Temática Test OS';
        tematicaCOPS.OS_Departamento__c = 'UAC';
        tematicaCOPS.CC_Codigo_Externo__c = 'TE-000002';
        tematicaCOPS.OS_Horas_SLA__c = '24' ;
        tematicaCOPS.OS_Horario__C = businessHoursId;
        insert tematicaCOPS;

        CC_MCC__c productoServicioCOPS = new CC_MCC__c();
        productoServicioCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicioCOPS.CC_Tipo_Cliente__c = 'Cliente(COPS)';
        productoServicioCOPS.Name = 'Producto/Servicio Test OS';
        productoServicioCOPS.CC_Tematica__c = tematicaCOPS.Id;
        productoServicioCOPS.CC_Codigo_Externo__c = 'PR-000002';
        insert productoServicioCOPS;

        CC_MCC__c motivoCOPS = new CC_MCC__c();
        motivoCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivoCOPS.CC_Tipo_Cliente__c = 'Cliente(COPS)';
        motivoCOPS.Name = 'Motivo';
        motivoCOPS.CC_Producto_Servicio__c = productoServicioCOPS.Id;
        motivoCOPS.CC_Codigo_Externo__c = 'MO-000002';
        insert motivoCOPS;

        Case caso = new Case();
        caso.Subject = 'Caso Test COPS';
        caso.CC_MCC_Tematica__c = tematicaCOPS.Id;
        caso.CC_MCC_ProdServ__c = productoServicioCOPS.Id;
        caso.CC_MCC_Motivo__c = motivoCOPS.Id;
        insert caso;

        Test.startTest();
        Case datosCaso = CC_MCC_Buscador_Controller.getTipificacion(caso.Id);
        Test.stopTest();

        System.assertNotEquals(null, datosCaso);

    //El caracter '\u2192' es una flecha a la derecha (→)
        String tipificacion = datosCaso.CC_MCC_Tematica__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_ProdServ__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_Motivo__r.Name;

        System.assertEquals('Temática Test COPS → Producto/Servicio Test OS → Motivo Test OS', tipificacion);
    }

    public static void testGetTipificacionCAM() {
        CC_MCC__c tematicaCAM = new CC_MCC__c();
        tematicaCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaCAM.CC_Tipo_Cliente__c = 'Cliente(CAM)';
        tematicaCAM.Name = 'Temática Test CAM';
        tematicaCAM.CC_Codigo_Externo__c = 'TE-000003';
        insert tematicaCAM;

        CC_MCC__c productoServicioCAM = new CC_MCC__c();
        productoServicioCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicioCAM.CC_Tipo_Cliente__c = 'Cliente(CAM)';
        productoServicioCAM.Name = 'Producto/Servicio Test CAM';
        productoServicioCAM.CC_Tematica__c = tematicaCAM.Id;
        productoServicioCAM.CC_Codigo_Externo__c = 'PR-000003';
        insert productoServicioCAM;

        CC_MCC__c motivoCAM = new CC_MCC__c();
        motivoCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivoCAM.CC_Tipo_Cliente__c = 'Cliente(CAM)';
        motivoCAM.Name = 'Motivo';
        motivoCAM.CC_Producto_Servicio__c = productoServicioCAM.Id;
        motivoCAM.CC_Codigo_Externo__c = 'MO-000003';
        insert motivoCAM;

        Case caso = new Case();
        caso.Subject = 'Caso Test CAM';
        caso.CC_MCC_Tematica__c = tematicaCAM.Id;
        caso.CC_MCC_ProdServ__c = productoServicioCAM.Id;
        caso.CC_MCC_Motivo__c = motivoCAM.Id;
        insert caso;

        Test.startTest();
        Case datosCaso = CC_MCC_Buscador_Controller.getTipificacion(caso.Id);
        Test.stopTest();

        System.assertNotEquals(null, datosCaso);

    //El caracter '\u2192' es una flecha a la derecha (→)
        String tipificacion = datosCaso.CC_MCC_Tematica__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_ProdServ__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_Motivo__r.Name;

        System.assertEquals('Temática Test → Producto/Servicio Test → Motivo Test', tipificacion);
    }


    @isTest
    public static void testDatosCaso() {
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        insert caso;

        Test.startTest();
        Case casoQuery = CC_MCC_Buscador_Controller.datosCaso(caso.Id);
        Test.stopTest();

        System.assertEquals(caso.Id, casoQuery.Id);
    }

    private static Map<String, CC_MCC__c> altaClasificacionPrueba(String tipoCliente, String nombreTematica, String nombreProducto, String nombreMotivo)  {

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }

        Map<String, CC_MCC__c> mccRegistros = new Map<String, CC_MCC__c>();

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = tipoCliente;
        tematica.Name = nombreTematica;
        tematica.OS_Departamento__c = 'UAC';
        tematica.CC_Codigo_Externo__c = 'TE-000001-' + nombreTematica;
        tematica.OS_Horas_SLA__c = '24' ;
        tematica.OS_Horario__C = businessHoursId;
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;

        CC_MCC__c tematicaCOPS = new CC_MCC__c();
        tematicaCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaCOPS.CC_Tipo_Cliente__c = tipoCliente;
        tematicaCOPS.Name = nombreTematica;        
        tematicaCOPS.OS_Departamento__c = 'UAC';
        tematicaCOPS.CC_Codigo_Externo__c = 'TE-000002-' + nombreTematica;
        tematicaCOPS.OS_Horas_SLA__c = '24' ;
        tematicaCOPS.OS_Horario__C = businessHoursId;
        tematicaCOPS.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematicaCOPS;

        CC_MCC__c tematicaCAM = new CC_MCC__c();
        tematicaCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematicaCAM.CC_Tipo_Cliente__c = tipoCliente;
        tematicaCAM.Name = nombreTematica;
        tematicaCAM.OS_Departamento__c = 'UAC';
        tematicaCAM.CC_Codigo_Externo__c = 'TE-000003-' + nombreTematica;
        tematicaCAM.OS_Horas_SLA__c = '24' ;
        tematicaCAM.OS_Horario__C = businessHoursId;
        tematicaCAM.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematicaCAM;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = tipoCliente;
        productoServicio.Name = nombreProducto;
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001-' + nombreProducto;
        insert productoServicio;

        CC_MCC__c productoServicioCOPS = new CC_MCC__c();
        productoServicioCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicioCOPS.CC_Tipo_Cliente__c = tipoCliente;
        productoServicioCOPS.Name = nombreProducto;
        productoServicioCOPS.CC_Tematica__c = tematica.Id;
        productoServicioCOPS.CC_Codigo_Externo__c = 'PR-000002-' + nombreProducto;
        insert productoServicioCOPS;

        CC_MCC__c productoServicioCAM = new CC_MCC__c();
        productoServicioCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicioCAM.CC_Tipo_Cliente__c = tipoCliente;
        productoServicioCAM.Name = nombreProducto;
        productoServicioCAM.CC_Tematica__c = tematica.Id;
        productoServicioCAM.CC_Codigo_Externo__c = 'PR-000003-' + nombreProducto;
        insert productoServicioCAM;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = tipoCliente;
        motivo.Name = nombreMotivo;
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001-' + nombreMotivo;
        insert motivo;

        CC_MCC__c motivoCOPS = new CC_MCC__c();
        motivoCOPS.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivoCOPS.CC_Tipo_Cliente__c = tipoCliente;
        motivoCOPS.Name = nombreMotivo;
        motivoCOPS.CC_Producto_Servicio__c = productoServicio.Id;
        motivoCOPS.CC_Codigo_Externo__c = 'MO-000002-' + nombreMotivo;
        insert motivoCOPS;

        CC_MCC__c motivoCAM = new CC_MCC__c();
        motivoCAM.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivoCAM.CC_Tipo_Cliente__c = tipoCliente;
        motivoCAM.Name = nombreMotivo;
        motivoCAM.CC_Producto_Servicio__c = productoServicio.Id;
        motivoCAM.CC_Codigo_Externo__c = 'MO-000003-' + nombreMotivo;
        insert motivoCAM;

        mccRegistros.put('tematica', tematica);
        mccRegistros.put('tematicaCOPS', tematicaCOPS);
        mccRegistros.put('tematicaCAM', tematicaCAM);
        mccRegistros.put('productoServicio', productoServicio);
        mccRegistros.put('productoServicioCOPS', productoServicioCOPS);
        mccRegistros.put('productoServicioCAM', productoServicioCAM);
        mccRegistros.put('motivo', motivo);
        mccRegistros.put('motivoCOPS', motivoCOPS);
        mccRegistros.put('motivoCAM', motivoCAM);

        return mccRegistros;
    }


    @isTest
    public static void getEsPropietarioCasoTest() {
      Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Empleado';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Numero_Documento__c = '60236005V';
    caso.CC_Tipo_Contacto__c = 'Petición de servicio';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        insert caso;

        System.assertEquals(true, CC_MCC_Buscador_Controller.getEsPropietarioCaso(caso.Id));

    }

    @isTest
    public static void formaParteFamiliaTest() {
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'testCase';
        caso.RecordTypeId = recordTypeCaso;
        caso.Status = 'SAC_001';
        insert caso;

        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;

        User usuario2 = new User();
        usuario2.Username = 'usertest49i2342@test.test';
        usuario2.Email = 'emailtest@test.test';  
        usuario2.LastName = 'usuario2 Test';
        usuario2.ProfileId = profileId;
        usuario2.Alias = 'alias2';
        usuario2.TimeZoneSidKey = 'GMT';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.EmailEncodingKey = 'ISO-8859-1';
        usuario2.LanguageLocaleKey = 'en_US';
        usuario2.isActive = true; 
        insert usuario2;

        Test.startTest();
        Boolean resultado = CC_MCC_Buscador_Controller.compruebaPermisoSAC(caso.Id, usuario2.Id);
        Test.stopTest();

        System.assertEquals(resultado, false, 'La comprobación de si el usuario forma parte de la familia ha fallado');
    }

    @isTest
    public static void comprobarUsuarioSACTest() {

        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;

        User usuario2 = new User();
        usuario2.Username = 'usertest49i2342@test.test';
        usuario2.Email = 'emailtest@test.test';  
        usuario2.LastName = 'usuario2 Test';
        usuario2.ProfileId = profileId;
        usuario2.Alias = 'alias2';
        usuario2.TimeZoneSidKey = 'GMT';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.EmailEncodingKey = 'ISO-8859-1';
        usuario2.LanguageLocaleKey = 'en_US';
        usuario2.isActive = true; 
        insert usuario2;


        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Auditor'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario2.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        Boolean resultado;

        
        System.runAs(usuario2){
            Test.startTest();
                resultado = CC_MCC_Buscador_Controller.comprobarUsuarioSAC(usuario2.Id);
            Test.stopTest();
        }
        
        System.assertNotEquals(resultado, false, 'La comprobación de si el usuario tiene el permission set ha fallado');
    }


    /************************************************** Empleado CSI Bankia ***********************************************************/
/*    @isTest
    public static void testActualizarCasoEmpleadoCSIBankia() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'CSI Bankia';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'CSI Bankia';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'CSI Bankia';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.Origin = 'Chat';
        caso.Canal_del_Empleado__c = 'CSI';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        insert caso;

        Test.startTest();
        CC_MCC_Buscador_Controller.actualizarCaso(caso.Id, motivo.Id);
        Test.stopTest();

        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
        System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
        System.assertEquals(motivo.Id, casoQuery.CC_MCC_Motivo__c);
    }

    @isTest
    public static void testGetTipificacionEmpleadoCSIBankia() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'CSI Bankia';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'CSI Bankia';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'CSI Bankia';
        motivo.Name = 'Motivo Test';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = productoServicio.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.Origin = 'Chat';
        caso.Canal_del_Empleado__c = 'CSI';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        insert caso;

        Test.startTest();
        Case datosCaso = CC_MCC_Buscador_Controller.getTipificacion(caso.Id);
        Test.stopTest();

        System.assertNotEquals(null, datosCaso);

    //El caracter '\u2192' es una flecha a la derecha (→)
        String tipificacion = datosCaso.CC_MCC_Tematica__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_ProdServ__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_Motivo__r.Name;

        System.assertEquals('Temática Test → Producto/Servicio Test → Motivo Test', tipificacion);
    }*/
    /***************************************************************************************************************************/
}