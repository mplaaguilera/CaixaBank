@isTest
public with sharing class FRA_MCC_Buscador_Controller_Test {
    @testSetup
    public static void testSetup(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuario = new User();
            usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
            usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
            usuario.FirstName = 'Fraude';
            usuario.LastName = 'Prueba';
            usuario.Alias = uniqueName.substring(18, 23);
            usuario.Email = uniqueName + '@test' + orgId + '.org';
            usuario.Username = uniqueName + '@test' + orgId + '.org';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.TimezonesIdKey = 'Europe/Madrid';
            insert usuario;
    
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        }
    }

    @isTest
    public static void testQuerySalesforceRecord() {
        Case casoFRA = new Case();
        casoFRA.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        casoFRA.Subject = 'Caso Test FRA';
        insert casoFRA;

        String queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%Prod%\'';
        queryString += ' AND RecordType.DeveloperName = \'CC_Motivo\' AND CC_Activo__c = true';
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Map<String, CC_MCC__c> mccRegistrosFRA = altaClasificacionPrueba('Cliente (FRA)', 'NomTematica1', 'NomProd1', 'NomMotiu1');
            List<sObject> resultadosCC = FRA_MCC_Buscador_Controller.querySalesforceRecord(casoFRA.Id, queryString, 15);
            System.assertEquals(mccRegistrosFRA.get('motivo').Id, resultadosCC[0].Id);
            Test.stopTest();
        }
    }

    @isTest
    public static void testActualizarCaso() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematica.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        productoServicio.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivo.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        caso.Subject = 'Caso Test';
        insert caso;
        
        FRA_MCC_Buscador_Controller.actualizarCaso(caso.Id, motivo.Id);
        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id]; 
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
            System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
            System.assertEquals(motivo.Id, casoQuery.CC_MCC_Motivo__c);
            Test.stopTest();
        }    
    }

    @isTest
    public static void testGetTipificacion() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematica.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        productoServicio.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivo.CC_Tipo_Cliente__c = 'Cliente (FRA)';
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
      
        Case datosCaso = FRA_MCC_Buscador_Controller.getTipificacion(caso.Id);
        //El caracter '\u2192' es una flecha a la derecha (→)
        String tipificacion = datosCaso.CC_MCC_Tematica__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_ProdServ__r.Name + ' \u2192 '
                            + datosCaso.CC_MCC_Motivo__r.Name;

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            System.assertNotEquals(null, datosCaso);
            System.assertEquals('Temática Test → Producto/Servicio Test → Motivo Test', tipificacion);
            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearActividadRetipificacion() {
        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematica.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        productoServicio.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivo.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;
        
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = productoServicio.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        insert caso;
       
        FRA_MCC_Buscador_Controller.crearActividadRetipificacion(caso.Id, tematica.Name, productoServicio.Name, motivo.Name,'');
        Case casoQuery = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :caso.Id];
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            System.assertEquals(tematica.Id, casoQuery.CC_MCC_Tematica__c);
            System.assertEquals(productoServicio.Id, casoQuery.CC_MCC_ProdServ__c);
            System.assertEquals(motivo.Id, casoQuery.CC_MCC_Motivo__c);
            Test.stopTest();
        }
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
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematica.CC_Tipo_Cliente__c = tipoCliente;
        tematica.Name = nombreTematica;
        tematica.OS_Departamento__c = 'UAC';
        tematica.CC_Codigo_Externo__c = 'TE-000001-' + nombreTematica;
        tematica.OS_Horas_SLA__c = '24' ;
        tematica.OS_Horario__C = businessHoursId;
        insert tematica;

        CC_MCC__c tematicaCOPS = new CC_MCC__c();
        tematicaCOPS.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematicaCOPS.CC_Tipo_Cliente__c = tipoCliente;
        tematicaCOPS.Name = nombreTematica;        
        tematicaCOPS.OS_Departamento__c = 'UAC';
        tematicaCOPS.CC_Codigo_Externo__c = 'TE-000002-' + nombreTematica;
        tematicaCOPS.OS_Horas_SLA__c = '24' ;
        tematicaCOPS.OS_Horario__C = businessHoursId;
        insert tematicaCOPS;

        CC_MCC__c tematicaCAM = new CC_MCC__c();
        tematicaCAM.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematicaCAM.CC_Tipo_Cliente__c = tipoCliente;
        tematicaCAM.Name = nombreTematica;
        tematicaCAM.OS_Departamento__c = 'UAC';
        tematicaCAM.CC_Codigo_Externo__c = 'TE-000003-' + nombreTematica;
        tematicaCAM.OS_Horas_SLA__c = '24' ;
        tematicaCAM.OS_Horario__C = businessHoursId;
        insert tematicaCAM;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        productoServicio.CC_Tipo_Cliente__c = tipoCliente;
        productoServicio.Name = nombreProducto;
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001-' + nombreProducto;
        insert productoServicio;

        CC_MCC__c productoServicioCOPS = new CC_MCC__c();
        productoServicioCOPS.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        productoServicioCOPS.CC_Tipo_Cliente__c = tipoCliente;
        productoServicioCOPS.Name = nombreProducto;
        productoServicioCOPS.CC_Tematica__c = tematica.Id;
        productoServicioCOPS.CC_Codigo_Externo__c = 'PR-000002-' + nombreProducto;
        insert productoServicioCOPS;

        CC_MCC__c productoServicioCAM = new CC_MCC__c();
        productoServicioCAM.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        productoServicioCAM.CC_Tipo_Cliente__c = tipoCliente;
        productoServicioCAM.Name = nombreProducto;
        productoServicioCAM.CC_Tematica__c = tematica.Id;
        productoServicioCAM.CC_Codigo_Externo__c = 'PR-000003-' + nombreProducto;
        insert productoServicioCAM;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivo.CC_Tipo_Cliente__c = tipoCliente;
        motivo.Name = nombreMotivo;
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001-' + nombreMotivo;
        insert motivo;

        CC_MCC__c motivoCOPS = new CC_MCC__c();
        motivoCOPS.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivoCOPS.CC_Tipo_Cliente__c = tipoCliente;
        motivoCOPS.Name = nombreMotivo;
        motivoCOPS.CC_Producto_Servicio__c = productoServicio.Id;
        motivoCOPS.CC_Codigo_Externo__c = 'MO-000002-' + nombreMotivo;
        insert motivoCOPS;

        CC_MCC__c motivoCAM = new CC_MCC__c();
        motivoCAM.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
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
}