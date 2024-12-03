/*****************************************************************
 * Name: SAC_LCMP_HomeOficina_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_HomeOficina
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            		           IBM                  14/03/22     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	23/01/23	 Modificación (agregada assertion)
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_HomeOficina_Test {

    @TestSetup
    static void makeData(){
        
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdmin);

        List<Account> cuentasOficina;

        System.runAs(usuarioAdmin){
            cuentasOficina = SAC_TestDataFactory.crearCuentasOficina(2);
            Database.insert(cuentasOficina);
            
            Contact contacto = SAC_TestDataFactory.crearContacto(1, cuentasOficina[1].Id )[0];
            contacto.av_usuarioasociado__c = usuarioGeneral.Id;
            Database.insert(contacto);

            List<Account> cuentas = SAC_TestDataFactory.crearCuentas(3);
            for(integer i = 0; i<cuentas.size(); i++){
                cuentas[i].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
            }
            Database.insert(cuentas);
            cuentas[0].CC_OficinaGestoraId__c = cuentas[1].Id;
            cuentas[0].CC_Numero_Documento__c = '82972082L';
            Database.update(cuentas);

            Id idUsuario = UserInfo.getUserId();
            List <AccountShare> listaAccountShare = new List <AccountShare>(); 
            AccountShare acshare = new AccountShare(); 
            acshare.AccountId = cuentas[1].Id;
            acshare.UserOrGroupId = idUsuario; 
            acshare.AccountAccessLevel = 'Read'; 
            acshare.OpportunityAccessLevel = 'None'; 
            acshare.CaseAccessLevel = 'Read'; 
            listaAccountShare.add(acshare); 
            Database.insert(listaAccountShare, false);

            
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'testRec');
            camposRecl.put('Origin', 'Otros');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('AccountId', cuentas[0].Id);
            camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_005');
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
            Database.insert(casoReclamacion);


            List<SAC_Accion__c> tarea = SAC_TestDataFactory.crearTareas(1, casoReclamacion, false);
            tarea[0].SAC_Descripcion__c = 'Test'; 
            tarea[0].SAC_Oficina__c = cuentasOficina[1].id;
            Database.insert(tarea);

            Map<String, Object> camposInteraccion = new Map<String, Object>();
            camposInteraccion.put('SAC_Titulo__c', 'interaccion');
            camposInteraccion.put('SAC_Oficina__c', cuentasOficina[1].Id);
            camposInteraccion.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            camposInteraccion.put('SAC_Reclamacion__c', casoReclamacion.Id);
            SAC_Interaccion__c interaccion = SAC_TestDataFactory.crearInteraccion('Consulta', camposInteraccion);
            Database.insert(interaccion);
        }       
    }

    @isTest
    static void getCasesTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Id cuentaId = [SELECT Id FROM Account WHERE Name = 'cuentaTest0'].Id;

        String oficina = '';
        String tipoBusquedaOficina = '';

        System.runAs(usuarioGeneral){
            Test.startTest();
                List<Case> result = SAC_LCMP_HomeOficina.getCases(cuentaId, oficina, tipoBusquedaOficina, '', '', null, null);

                System.assertEquals(reclamacion.Subject, result[0].Subject, 'Obtener los casos ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void getCasesTest2(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Subject, CaseNumber, CC_SuppliedNIF__c, SAC_NombreContacto__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        String tipoBusquedaId = 'idCaso';
        String tipoBusquedaNif = 'nif';
        String tipoBusquedaCliente = 'nombreCliente';

        System.runAs(usuarioGeneral){
            Test.startTest();
                List<Case> resultId = SAC_LCMP_HomeOficina.getCases('', '','',tipoBusquedaId,reclamacion.CaseNumber, null, null);
                List<Case> resultNif = SAC_LCMP_HomeOficina.getCases('', '','',tipoBusquedaNif,reclamacion.CC_SuppliedNIF__c, null, null);
                List<Case> resultCliente = SAC_LCMP_HomeOficina.getCases('', '','',tipoBusquedaCliente,reclamacion.SAC_NombreContacto__c, null, null);

                System.assertNotEquals(0, resultId.size(), 'Obtener los casos por idCaso ha fallado.');
                System.assertNotEquals(0, resultNif.size(), 'Obtener los casos por NIF ha fallado.');
                System.assertNotEquals(0, resultCliente.size(), 'Obtener los casos por nombreCliente ha fallado.');
            Test.stopTest();
        }    
    }

    @isTest
    static void getCasesTest3(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Account cuentaId = [SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];
        String oficina = cuentaId.CC_OficinaGestoraId__c;

        String tipoBusquedaOficina1 = 'ambas';
        String tipoBusquedaOficina2 = 'gestora';
        String tipoBusquedaOficina3 = 'afectada';
        String tipoBusquedaRecepcion = 'fechaRecep';
        Date fechaDesde = system.now().addDays(-1).date();
        Date fechaHasta = system.now().addDays(1).date();

        System.runAs(usuarioGeneral){
            Test.startTest();
                List<Case> result1 = SAC_LCMP_HomeOficina.getCases(cuentaId.Id, oficina, tipoBusquedaOficina1,'','',null,null);
                List<Case> result2 = SAC_LCMP_HomeOficina.getCases(cuentaId.Id, oficina, tipoBusquedaOficina2,'','',null,null);
                List<Case> result3 = SAC_LCMP_HomeOficina.getCases(cuentaId.Id, oficina, tipoBusquedaOficina2,'','',null,null);
                List<Case> resultPorRec = SAC_LCMP_HomeOficina.getCases('', '', '', tipoBusquedaRecepcion, '', fechaDesde, fechaHasta);

                System.assertNotEquals(0, result1.size(), 'Obtener los casos por oficina gestora y afectada ha fallado.');
                System.assertNotEquals(0, result2.size(), 'Obtener los casos por oficina gestora ha fallado.');
                System.assertNotEquals(0, result3.size(), 'Obtener los casos por oficina afectada ha fallado.');
                System.assertNotEquals(0, resultPorRec.size(), 'Obtener los casos por fecha recepción ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void getActionOfficeTest(){

        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        SAC_Accion__c tarea = [SELECT id, Name, SAC_Descripcion__c, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Estado__c = 'SAC_PendienteEnviar' LIMIT 1];

        String tipoBusquedaIdTarea = 'idTarea';
        String tipoBusquedaAsunto = 'asunto';
        String tipoBusquedaEstado = 'estado';
        
        System.runAs(usuarioGeneral){
            Test.startTest();
                List<SAC_Accion__c> resultPorId = SAC_LCMP_HomeOficina.getActionOffice(tipoBusquedaIdTarea,tarea.Name,null,null);
                List<SAC_Accion__c> resultPorAsunto = SAC_LCMP_HomeOficina.getActionOffice(tipoBusquedaAsunto,tarea.SAC_Descripcion__c,null,null);
                List<SAC_Accion__c> resultPorEstado = SAC_LCMP_HomeOficina.getActionOffice(tipoBusquedaEstado,tarea.SAC_Estado__c,null,null);

                System.assertNotEquals(0, resultPorId.size(),'Obtener las tareas por id ha fallado.');
                System.assertNotEquals(0, resultPorAsunto.size(),'Obtener las tareas por asunto ha fallado.');
                System.assertNotEquals(0, resultPorEstado.size(),'Obtener las tareas por estado ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void getActionOfficeTest2(){

        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        List<SAC_Accion__c> result = new List<SAC_Accion__c>();
    
        String tipoBusqueda = 'fechaCreacion';
        Date fechaDesde = system.now().addDays(-1).date();
        Date fechaHasta = system.now().addDays(1).date();
        
        
        System.runAs(usuarioGeneral){
            Test.startTest();
                result = SAC_LCMP_HomeOficina.getActionOffice(tipoBusqueda,'',fechaDesde,fechaHasta);
            Test.stopTest();

            System.assertNotEquals(0,result.size(),  'Obtener las acciones ha fallado.');
        }
    }

    @isTest
    static void getConsultaOfficeTest(){
        
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        SAC_Interaccion__c interaccion = [SELECT id, Name, SAC_Titulo__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Estado__c = 'SAC_PendienteRespuesta' LIMIT 1];

        String tipoBusquedaIdConsulta = 'idConsulta';
        String tipoBusquedaAsunto = 'asunto';
        String tipoBusquedaEstado = 'estado';
        
        System.runAs(usuarioGeneral){
            Test.startTest();
                List<SAC_Interaccion__c> resultPorId = SAC_LCMP_HomeOficina.getConsultaOffice(tipoBusquedaIdConsulta,interaccion.Name,null,null);
                List<SAC_Interaccion__c> resultPorAsunto = SAC_LCMP_HomeOficina.getConsultaOffice(tipoBusquedaAsunto,interaccion.SAC_Titulo__c,null,null);
                List<SAC_Interaccion__c> resultPorEstado = SAC_LCMP_HomeOficina.getConsultaOffice(tipoBusquedaEstado,interaccion.SAC_Estado__c,null,null);

                System.assertNotEquals(0, resultPorId.size(),'Obtener las interacciones por id ha fallado.');
                System.assertNotEquals(0, resultPorAsunto.size(),'Obtener las interacciones por asunto ha fallado.');
                System.assertNotEquals(0, resultPorEstado.size(),'Obtener las interacciones por estado ha fallado.');
            Test.stopTest();
        }      
    }

    @isTest
    static void getConsultaOfficeTest2(){
        
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        List<SAC_Interaccion__c> result = new List<SAC_Interaccion__c>();
    
        String tipoBusqueda = 'fechaCreacion';
        Date fechaDesde = system.now().addDays(-1).date();
        Date fechaHasta = system.now().addDays(1).date();
        
        System.runAs(usuarioGeneral){
            Test.startTest();
                result = SAC_LCMP_HomeOficina.getConsultaOffice(tipoBusqueda,'',fechaDesde,fechaHasta);
            Test.stopTest();

            System.assertNotEquals(0,result.size(),  'Obtener las interacciones ha fallado.');
        }       
    }

    @isTest
    static void getConsultaOfficeTest3(){
        
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        SAC_Interaccion__c interaccion = [SELECT id, SAC_Reclamacion__c FROM SAC_Interaccion__c WHERE SAC_Estado__c = 'SAC_PendienteRespuesta' LIMIT 1];
    
        String tipoBusqueda = 'porDefecto';
        
        System.runAs(usuarioGeneral){
            Test.startTest();
                List<SAC_Interaccion__c> result1 = SAC_LCMP_HomeOficina.getConsultaOffice(tipoBusqueda,'',null,null);
                List<SAC_Interaccion__c> result2 = SAC_LCMP_HomeOficina.getConsultaOffice(tipoBusqueda,interaccion.SAC_Reclamacion__c,null,null);

                System.assertNotEquals(0,result1.size(),  'Obtener las interacciones pendientes ha fallado.');
                System.assertNotEquals(0,result2.size(),  'Obtener las interacciones pendientes ha fallado.');
            Test.stopTest(); 
        }       
    }

    @isTest
    static void getOfficesTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Account acc = [SELECT Name FROM Account WHERE Name = 'cuentaTest Oficina0' LIMIT 1];

        String nombreOficina = acc.Name;
        List<Account> result = new List<Account>();

        System.runAs(usuarioGeneral){
            Test.startTest();
                result = SAC_LCMP_HomeOficina.getOffices(nombreOficina);
            Test.stopTest();
        }

        System.assertNotEquals(null, result, 'Obtener la oficina indicada ha fallado.');
    }

    @isTest
    static void shareAccionTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case rec = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        SAC_Accion__c accion = [SELECT Id FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: rec.Id Limit 1];
        List<SAC_Accion__Share> accionesShare = [SELECT Id FROM SAC_Accion__Share];

        System.runAs(usuarioGeneral){
            Test.startTest();
                SAC_LCMP_HomeOficina.ShareAccion(accion.Id);
            Test.stopTest();
        }
        List<SAC_Accion__Share> accionesShare2 = [SELECT Id FROM SAC_Accion__Share];

        System.assertNotEquals(accionesShare.size(), accionesShare2.size(), 'Anidar las acciones ha fallado.');
    }

    @isTest
    static void getExternalCasesTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'cuentaTest2' LIMIT 1];
        acc.CC_Numero_Documento__c = '82972082L';
        Database.update(acc);
        
        CBK_IntegrationSetting__c csAntecedentes = new CBK_IntegrationSetting__c();
        csAntecedentes.Name = 'SAC_Antecedentes';
        csAntecedentes.NamedCredential__c = 'callout:API_GWT_PRO/servicing/servicingIssue/claims/request';
        Database.insert(csAntecedentes);
        
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        List<SAC_WS_Antecedentes_RP.ClaimWrapper> result = new List<SAC_WS_Antecedentes_RP.ClaimWrapper>();

        System.runAs(usuarioGeneral){
            Test.startTest();
                result = SAC_LCMP_HomeOficina.getExternalCases(acc.Id);
            Test.stopTest();
        }

        System.assertNotEquals(null, result, 'Obtener casos externos ha fallado');
    }

    @isTest
    static void getCaseRecordTypeIdTest(){
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Id idReclamacionRT ;

        System.runAs(usuarioGeneral){
            Test.startTest();
                idReclamacionRT = SAC_LCMP_HomeOficina.getCaseRecordTypeId();
            Test.stopTest();
        }

        System.assertNotEquals(null, idReclamacionRT, 'No se ha podido recuperar la id del record type');
    }

    // @isTest
    // static void modificarPermisosAccountTest() {
    //     Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest1'];
    //     User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
    //     List <AccountShare> listaAccountShare = [SELECT Id, AccountId, UserOrGroupId, CaseAccessLevel FROM AccountShare WHERE AccountId = :cuenta.Id AND UserOrGroupId = :usuarioAdmin.id];
        
        
    //     System.runAs(usuarioAdmin) {
    //         Test.startTest();
    //         SAC_LCMP_HomeOficina.modificarPermisosAccount(cuenta.Id);   
    //         Test.stopTest();
    //     }
        
    //     List <AccountShare> listaAccountShareNew = [SELECT Id, AccountId, UserOrGroupId, CaseAccessLevel FROM AccountShare WHERE AccountId = :cuenta.Id AND UserOrGroupId = :usuarioAdmin.id];
    //     System.assertNotEquals(listaAccountShare[0].CaseAccessLevel, listaAccountShareNew[0].CaseAccessLevel, 'No se han actualizado los permisos.');
    // }

    @isTest
    static void modificarPermisosReadAccountTest() {
        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest2' LIMIT 1];

        List <AccountShare> listaAccountShare = [SELECT Id, AccountId, UserOrGroupId, CaseAccessLevel, Account.Name FROM AccountShare  WHERE AccountId = :cuenta.Id AND UserOrGroupId = :usuarioAdmin.id];

        System.runAs(usuarioAdmin){
            Test.startTest();
                SAC_LCMP_HomeOficina.modificarPermisosReadAccount(cuenta.Id);
            Test.stopTest();
        }
        List <AccountShare> listaAccountShareNew = [SELECT Id, AccountId, UserOrGroupId, CaseAccessLevel FROM AccountShare WHERE AccountId = :cuenta.Id AND UserOrGroupId = :usuarioAdmin.id];

        System.assertNotEquals(null, listaAccountShareNew[0].CaseAccessLevel, 'No se han actualizado los permisos.');
    }

    @isTest
    static void shareInteraccionTest() {
        SAC_Interaccion__c interaccion = [SELECT id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'interaccion' LIMIT 1];
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        List<SAC_Interaccion__Share> interaccionShare = [SELECT Id FROM SAC_Interaccion__Share];

        System.RunAs(usuarioGeneral){
            Test.startTest();
                SAC_LCMP_HomeOficina.ShareInteraccion(interaccion.Id);
            Test.stopTest();
        }
        List<SAC_Interaccion__Share> interaccionShareNew = [SELECT Id FROM SAC_Interaccion__Share];

        System.assertNotEquals(interaccionShare.size(), interaccionShareNew.size(), 'Anidar las interacciones ha fallado.');
    }

    @isTest
    static void getEstadosTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        String objetoConsulta = 'consulta'; 
        String objetoTarea = 'tarea';
        List<SAC_LCMP_HomeOficina.PicklistValue> picklistConsulta = new List<SAC_LCMP_HomeOficina.PicklistValue>();
        List<SAC_LCMP_HomeOficina.PicklistValue> picklistTarea = new List<SAC_LCMP_HomeOficina.PicklistValue>();

        System.RunAs(usuarioGeneral){
            Test.startTest();
            picklistConsulta = SAC_LCMP_HomeOficina.getEstados(objetoConsulta);  
            picklistTarea = SAC_LCMP_HomeOficina.getEstados(objetoTarea);                      
            Test.stopTest();
        }
        System.assertNotEquals(0, picklistConsulta.size(), 'No se ha podido recuperar los valores de la picklist del objeto Interaccion');
        System.assertNotEquals(0, picklistTarea.size(), 'No se ha podido recuperar los valores de la picklist del objeto Accion');  
    }

}