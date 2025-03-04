/*****************************************************************
 * Name: SAC_Pretension_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Pretension
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US242669         Carlos Solis         30/06/21     Creación
 * 1.1            ---              Jose Carlos Blanco   30/08/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_Pretension_Test {
    @TestSetup
    static void makeData(){
        Set<String> objetos = new Set<String>{'CC_MCC__c'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recordTypeIdMCC1 = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdMCC2 = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMCC3 = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdMCCSAC = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c(Name='Tematica', CC_Codigo_Externo__c='a', RecordTypeId=recordTypeIdMCC1, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccServicio = new CC_MCC__c(Name='Servicio', CC_Codigo_Externo__c='b', RecordTypeId=recordTypeIdMCC2, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccMotivo = new CC_MCC__c(Name='Motivo a', CC_Codigo_Externo__c='c', RecordTypeId=recordTypeIdMCC3, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Banca Electrónica', CC_Codigo_Externo__c='d', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');
        
        CC_MCC__c mccTematica2 = new CC_MCC__c(Name='Tematica2', CC_Codigo_Externo__c='a2', RecordTypeId=recordTypeIdMCC1, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccServicio2 = new CC_MCC__c(Name='Servicio2', CC_Codigo_Externo__c='b2', RecordTypeId=recordTypeIdMCC2, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccMotivo2 = new CC_MCC__c(Name='Motivo a2', CC_Codigo_Externo__c='c2', RecordTypeId=recordTypeIdMCC3, CC_Tipo_Cliente__c='SAC');
        CC_MCC__c mccDetalle2 = new CC_MCC__c(Name='Banca Electrónica2', CC_Codigo_Externo__c='d2', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        listaMCCs.add(mccTematica);
        listaMCCs.add(mccServicio);
        listaMCCs.add(mccMotivo);
        listaMCCs.add(mccDetalle);
        
        listaMCCs.add(mccTematica2);
        listaMCCs.add(mccServicio2);
        listaMCCs.add(mccMotivo2);
        listaMCCs.add(mccDetalle2);
        SAC_DatabaseDML.upsertListDML(listaMCCs, false);
        //Database.upsert(listaMCCs);

        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];  
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);
        //Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin) {
            //Usuario SAC Admin
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
            //Database.insert(permiSetAssi);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SAC_DatabaseDML.insertDML(permiSetAssiAdmin, false);
            //Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();
        
        //Accounts
        List <Account> listaCuentas = SAC_TestDataFactory.crearCuentas(2);
        listaCuentas[0].Name = 'Cuenta A';
        listaCuentas[0].Phone = '123456789';
        listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[0].billingStreet  = 'Calle Mayor 55';
        listaCuentas[0].BillingCountry = 'España';
        listaCuentas[0].CC_Numero_Documento__c = '66666666C';

        listaCuentas[1].Name = 'Cuenta B';
        listaCuentas[1].Phone = '123456789';
        listaCuentas[1].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[1].billingStreet  = 'Calle Mayor 55';
        listaCuentas[1].BillingCountry = 'España';
        listaCuentas[1].CC_Numero_Documento__c = '12345678C';
        SAC_DatabaseDML.insertListDML(listaCuentas, false);
        //Database.insert(listaCuentas);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Otros');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('AccountId', listaCuentas[0].Id);
        camposRecl2.put('SAC_TipoConsumidor__c', 'No');
        camposRecl2.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl2.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Otros');
        camposRecl3.put('Status', 'SAC_001');
        camposRecl3.put('SAC_TipoConsumidor__c', 'No');
        camposRecl3.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl3.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('Origin', 'Otros');
        camposRecl4.put('Status', 'SAC_001');
        camposRecl4.put('SAC_TipoConsumidor__c', 'No');
        camposRecl4.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl4.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);
        
        //Reclamaciones
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(casoReclamacion);
        reclamaciones.add(casoReclamacion2);
        reclamaciones.add(casoReclamacion3);
        reclamaciones.add(casoReclamacion4);
        SAC_DatabaseDML.insertListDML(reclamaciones, false);
        //Database.insert(reclamaciones);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'testPret');
        camposPret.put('Origin', 'Otros');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret2.put('Origin', 'Otros');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret2.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);

        //Pretension 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'testPretNegocio');
        camposPret3.put('Origin', 'Otros');
        camposPret3.put('Status', 'SAC_007');
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret3.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret3.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
        camposPret3.put('SAC_DetalleResultadoNegociacion__c', 'Otros');
        camposPret3.put('CC_Importe_Reclamado__c', 300);
        camposPret3.put('SAC_Importe_Resuelto__c', 100);
        camposPret3.put('SAC_Importe_ResultadoNegociacion__c', 200);
        camposPret3.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);

        //Pretension 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'testPretNegocio2');
        camposPret4.put('Origin', 'Otros');
        camposPret4.put('Status', 'SAC_007');
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret4.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret4.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
        camposPret4.put('SAC_DetalleResultadoNegociacion__c', 'Otros');
        camposPret4.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);

        //Pretension 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('SuppliedCompany', 'testPretNegocio3');
        camposPret5.put('Origin', 'Otros');
        camposPret5.put('Status', 'SAC_007');
        camposPret5.put('SAC_Reclamacion__c', casoReclamacion4.Id);
        camposPret5.put('SEG_Detalle__c', mccDetalle.Id);
        camposPret5.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
        camposPret5.put('SAC_DetalleResultadoNegociacion__c', 'Otros');
        camposPret5.put('OwnerId', usuarioGeneral.Id);
        camposPret5.put('SAC_EsPrincipal__c', true);
        camposPret5.put('SAC_TAE__c', 'SAC_21_22');

        Case casoPretension5 = SAC_TestDataFactory.crearCaso('Pretension',camposPret5);

        //Pretensiones
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(casoPretension);
        pretensiones.add(casoPretension2);
        pretensiones.add(casoPretension3);
        pretensiones.add(casoPretension4);
        pretensiones.add(casoPretension5);
        SAC_DatabaseDML.insertListDML(pretensiones, false);
        //Database.insert(pretensiones);

        /*SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Case__c = casoReclamacion2.Id;
		caseRecl1.SAC_Account__c = cuentaB.Id;
		caseRecl1.SAC_Contact__c = null;
		caseRecl1.SAC_ReclamantePrincipal__c = true;
		insert caseRecl1;*/
    }

    /*@isTest
    static void rellenarSubject(){
        Case caso = [SELECT id, subject, CaseNumber FROM Case WHERE subject = 'TestRec' limit 1];

        Test.startTest();
        Case pretension = new Case();
        pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        pretension.SAC_Reclamacion__c = caso.Id;
        insert pretension;
        Test.stopTest();

        Case pret = [SELECT Id, SAC_Reclamacion__c, Subject, CaseNumber FROM Case WHERE SAC_Reclamacion__c = :caso.Id limit 1];
        System.assertEquals(caso.CaseNumber + ' - ' + pret.CaseNumber, pret.Subject, 'No se ha podido rellenar el subject');
    }*/

    @isTest
    static void subjectMCC(){
        Id recordTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        CC_MCC__c mccServicio = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Servicio'];
        CC_MCC__c mccDetalle = [SELECT Id, Name FROM CC_MCC__c WHERE Name = 'Banca Electrónica'];
        Case pretension = [SELECT Id, Status, Origin, RecordTypeId, SEG_Detalle__c FROM Case WHERE RecordTypeId = :recordTypePret AND SuppliedCompany = 'testPret' limit 1];
        pretension.CC_MCC_ProdServ__c = mccServicio.Id;
        pretension.SEG_Detalle__c = mccDetalle.Id;

        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.update(pretension);
            Test.stopTest();
        }

        Case pret = [SELECT Id, Subject, Status, Origin, RecordTypeId, SEG_Detalle__c FROM Case WHERE RecordTypeId = :recordTypePret AND SuppliedCompany = 'testPret' limit 1];
        Assert.areEqual(mccServicio.Name + ' - ' + mccDetalle.Name, pret.Subject, 'No se ha podido cambiar el subject al nombre de los mcc');
    }

    @isTest
    static void marcarPretensionPrincipal(){
        Id recordTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec2' limit 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c FROM Case WHERE RecordTypeId = :recordTypePret AND SAC_Reclamacion__c = :caso.Id limit 1];
        caso.SAC_PretensionPrincipal__c = pretension.id;
        caso.Status = 'SAC_002';
        caso.SAC_StatusAuxiliar__c = 'SAC_002';

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }

        caso = [SELECT Id, Subject, Status, SAC_PretensionPrincipal__c FROM Case WHERE Subject = 'TestRec2' limit 1];
        Assert.areEqual(pretension.Id, caso.SAC_PretensionPrincipal__c, 'No se ha podido asignar la pretension principal');
    }

    @isTest
    static void actualizarTAETest(){
        Id recordTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case caso = [SELECT Id, Subject, SAC_PretensionPrincipal__c  FROM Case WHERE Subject = 'TestRec4' LIMIT 1];
        Case pretension = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c, SAC_TAE__c FROM Case WHERE RecordTypeId = :recordTypePret AND SAC_Reclamacion__c = :caso.Id limit 1];

        List <Case> lista = new List<Case>();
        Test.startTest();
        System.runAs(usuario){

            caso.SAC_PretensionPrincipal__c= pretension.Id;
            pretension.SAC_TAE__c = 'SAC_235_24';
            lista.add(caso);
            lista.add(pretension);
            SAC_DatabaseDML.updateListDML(lista, false);
            //Database.update(lista);
        }

        Case reclamacion2 = [SELECT Id, SAC_TAE__c FROM Case WHERE Subject = 'TestRec4' LIMIT 1];
        Case pretension2 = [SELECT Id, Status, Origin, SAC_Reclamacion__c, RecordTypeId, SEG_Detalle__c, SAC_TAE__c FROM Case WHERE RecordTypeId = :recordTypePret AND SAC_Reclamacion__c = :reclamacion2.Id limit 1];

        Assert.areEqual(pretension2.SAC_TAE__c, reclamacion2.SAC_TAE__c, 'No se ha asignado el TAE correctamente');
    }



    
    @isTest
    static void datosClienteReclamacionTest(){
        Case caso = [SELECT id, subject, Status FROM Case WHERE subject = 'TestRec3' limit 1];
        Account cuenta = [SELECT Id, CC_Numero_Documento__c FROM Account WHERE Name = 'Cuenta A' LIMIT 1];
        caso.AccountId = cuenta.Id;

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }

        caso = [SELECT Id, Subject, Status, SAC_PretensionPrincipal__c, CC_SuppliedNIF__c FROM Case WHERE Subject = 'TestRec3' limit 1];
        Assert.areEqual(cuenta.CC_Numero_Documento__c, caso.CC_SuppliedNIF__c, 'No se ha podido asignar el NIF del reclamante');
    }

    @isTest
    static void rellenarProcedenciaTest(){
        Case pretension = [SELECT Id, CC_Canal_Procedencia__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        pretension.CC_Canal_Procedencia__c = 'Junta Andalucia';
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.update(pretension);
            Test.stopTest();
        }

        Case pretension2 = [SELECT Id, CC_Canal_Procedencia__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Assert.areEqual(pretension.CC_Canal_Procedencia__c, pretension2.CC_Canal_Procedencia__c, 'No se ha podido modificar el canal de procedencia.');
    }
    
    @isTest
    static void rellenarReclamante(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        Case pretension = [SELECT Id, AccountId FROM Case WHERE SAC_Reclamacion__c =: reclamacion.id LIMIT 1];
        pretension.Subject = 'TestRec2 update';
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case pretension2 = [SELECT Id, AccountId FROM Case WHERE SAC_Reclamacion__c =: reclamacion.id LIMIT 1];
        Assert.areEqual(pretension.AccountId, pretension2.AccountId, 'No se ha podido modificar el reclamante de la pretensión');
    }
    
    @isTest
    static void comprobarNegocioAnalisisTest(){
        Case pretension = [SELECT id, Status, SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c FROM CASE WHERE SuppliedCompany = 'testPretNegocio2' LIMIT 1];
		pretension.Status = 'SAC_002';
        pretension.SAC_StatusAuxiliar__c = 'SAC_002';
        pretension.CC_Importe_Reclamado__c = 1.0;
        pretension.SAC_Importe_Resuelto__c = 1.0;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.SaveResult resultado = Database.update(pretension, false);
            Test.stopTest();
            Case pretensionResult = [SELECT id, Status, SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c FROM CASE WHERE SuppliedCompany = 'testPretNegocio2' LIMIT 1];
            Assert.areEqual(pretensionResult.Status, 'SAC_002', 'No se ha podido modificar el estado');
            //Assert.areNotEqual(null, resultado, 'No se ha podido modificar el estado');
        }    
    }
    
    @isTest
    static void rellenarImporteResultadoNegocioTest(){
        Case pretension = [SELECT id, Status, SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c FROM CASE WHERE SuppliedCompany = 'testPretNegocio' LIMIT 1];
        pretension.SAC_Importe_Resuelto__c = 75;
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.update(pretension);
            Test.stopTest();
        }
        
        Case pretension2 = [SELECT id, Status, SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c FROM CASE WHERE SuppliedCompany = 'testPretNegocio' LIMIT 1];
        Assert.areEqual(pretension.SAC_ResultadoNegociacion__c, pretension2.SAC_ResultadoNegociacion__c, 'No se ha rellenado el importe resultado negociación');  
    }
    
    @isTest
    static void rellenarReclamanteConformeTest(){
        Case caso = [SELECT id  FROM CASE WHERE Subject = 'TestRec' LIMIT 1];
        Case pretension = [SELECT id, SAC_ReclamanteConformeNegociacion__c FROM CASE WHERE SuppliedCompany = 'testPret' LIMIT 1];
        caso.SAC_ReclamanteConformeNegociacion__c = true;
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false);
            //Database.update(caso);
            Test.stopTest();
        }
        Case pretension2 = [SELECT id, SAC_ReclamanteConformeNegociacion__c FROM CASE WHERE SuppliedCompany = 'testPret' LIMIT 1];
        Assert.areEqual(pretension2.SAC_ReclamanteConformeNegociacion__c, true , 'No se ha rellenado el campo reclamante conforme');    
    }
    
    @isTest
    static void rellenarCodigosExternosMCCTest(){
        
        CC_MCC__c mcc = [SELECT id FROM CC_MCC__c WHERE Name = 'Banca Electrónica2' LIMIT 1];
        Case pretension = [SELECT id, CC_Codigo_Externo_Tematica__c, CC_Tematica__c FROM CASE WHERE SuppliedCompany = 'testPret' LIMIT 1];
        pretension.SEG_Detalle__c = mcc.id;
        
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            //Database.update(pretension);
            Test.stopTest();
        }
        
        Case pretension2 = [SELECT id, CC_Codigo_Externo_Tematica__c, CC_Tematica__c FROM CASE WHERE SuppliedCompany = 'testPret' LIMIT 1];
        Assert.areEqual(pretension.CC_Codigo_Externo_Tematica__c, null, 'No se ha rellenado el campo codigo externo');
        
    }
    
    @isTest
    static void insertarPermisosPretensionTest(){
        
        Case reclamacion = [SELECT id FROM CASE WHERE Subject = 'TestRec3' LIMIT 1];
        
        Case casoPretensionPermisos = new Case();
        casoPretensionPermisos.SuppliedCompany = 'testPretPermisos';
        casoPretensionPermisos.Origin = 'Otros';
        casoPretensionPermisos.Status = 'SAC_001';
        casoPretensionPermisos.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        casoPretensionPermisos.SAC_Reclamacion__c = reclamacion.id;

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.insertDML(casoPretensionPermisos, false);
            //Database.insert(casoPretensionPermisos);
            Test.stopTest();
        }
        
        Assert.areNotEqual(casoPretensionPermisos.Id, null, 'El insert de la pretension ha fallado');
        
    }

    @isTest
    static void casoEspecialPretensionesTest() {
        Case reclamacion = [SELECT id, SAC_CasoEspecial__c FROM CASE WHERE Subject = 'TestRec2' LIMIT 1];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            reclamacion.SAC_CasoEspecial__c = 'SAC_Presidencia';
            SAC_DatabaseDML.updateDML(reclamacion, false);
            //Database.update(reclamacion);
            Test.stopTest();
        }

        Case pretensionResult = [SELECT id, SAC_CasoEspecial__c FROM Case WHERE SuppliedCompany = 'testPretNegocio2'];
        Assert.areEqual('SAC_Presidencia', pretensionResult.SAC_CasoEspecial__c, 'No se ha podido pasar el valor del caso especial de la reclamación a la pretensión');
    }

    @isTest
    static void cambioLetradoTest() {
        List<Case> listaPretensiones = [SELECT id, OwnerId, SuppliedCompany FROM CASE WHERE SuppliedCompany = 'testPret' OR SuppliedCompany = 'testPretNegocio'];
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'SAC_PendienteAsignar' OR DeveloperName = 'SAC_PteSupervisor') LIMIT 1];

        List<Case> pretensionesUpdatear = new List<Case>();
        Case pretension1 = new Case();
        Case pretension2 = new Case();
        for (Case pret : listaPretensiones) {
            if (pret.SuppliedCompany == 'testPret') {
                pretension1.Id = pret.Id;
                pretensionesUpdatear.add(pretension1);
            }
            if (pret.SuppliedCompany == 'testPretNegocio') {
                pretension2.Id = pret.Id;
                pretensionesUpdatear.add(pretension2);
            }
        }
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            pretension1.OwnerId = usuario.Id;
            pretension2.OwnerId = cola.Id;
            SAC_DatabaseDML.updateListDML(pretensionesUpdatear, false);
            //Database.update(pretensionesUpdatear);
            Test.stopTest();
        }

        List<Case> listaReclamacionResult = [SELECT id, SAC_Letrado__c, Subject FROM Case WHERE subject = 'TestRec' OR subject = 'TestRec2'];
        Case reclaResult1 = new Case();
        Case reclaResult2 = new Case();
        for (Case rec : listaReclamacionResult) {
            if (rec.Subject == 'TestRec') {
                reclaResult1 = rec;
            }
            if (rec.Subject == 'TestRec2') {
                reclaResult2 = rec;
            }
        }
        Assert.areEqual('Usuario Test0', reclaResult1.SAC_Letrado__c, 'No se ha podido recuperar el nombre del letrado');
        Assert.areEqual('Pte. Asignar', reclaResult2.SAC_Letrado__c, 'No se ha podido recuperar el nombre del letrado');
    }

    @isTest
    static void informarLetradoTest() {
        Id recordTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Case reclamacion = [SELECT id, OwnerId, Owner.Name, SuppliedCompany FROM Case WHERE Subject = 'TestRec3'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Case pret = new Case();
            pret.SAC_Reclamacion__c = reclamacion.Id;
            pret.RecordTypeId = recordTypePret;
            SAC_DatabaseDML.insertDML(pret, false);
            //Database.insert(pret);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT id, SAC_Letrado__c, Subject FROM Case WHERE subject = 'TestRec3'];
        
        Assert.areEqual(reclamacion.Owner.Name, reclamacionResult.SAC_Letrado__c, 'No se ha podido recuperar el nombre del letrado');
    }

    @isTest
    static void actualizarDatosContactoTest() {

        Case reclamacion = [SELECT id, OwnerId, Owner.Name, SuppliedCompany, CC_Telefono_Contacto__c, OS_Email__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'TestRec3'];   
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            Case caso = new Case();
            caso.CC_Telefono_Contacto__c = 'Test';
            caso.OS_Email__c = 'Test';
            caso.SAC_DireccionPostalNotificacion__c = 'Test';
            SAC_DatabaseDML.insertDML(caso, false);
            Test.stopTest();
        }

        Case reclamacionResult = [SELECT id, CC_Telefono_Contacto__c, OS_Email__c, SAC_DireccionPostalNotificacion__c FROM Case WHERE subject = 'TestRec3'];
        
        Assert.areEqual(reclamacion.CC_Telefono_Contacto__c, reclamacionResult.CC_Telefono_Contacto__c, 'No se ha actualizado');
    }
    /*
    @isTest
    static void cambiarOwnersPretsHermanasTest() {
        User usuario1 = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        User usuario2 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case pretension = [SELECT id, OwnerId FROM Case WHERE SuppliedCompany = 'testPretNegocio'];
        
        System.runAs(usuario1){
            Test.startTest();
            pretension.OwnerId = usuario2.Id;
            Database.update(pretension);
            Test.stopTest();
        }

        Case pretensionResult = [SELECT id, OwnerId FROM Case WHERE SuppliedCompany = 'testPretNegocio2'];
        System.assertEquals(usuario2.Id, pretensionResult.OwnerId, 'No ha cambiado el owner de las pretensiones hermanas');
    }  */
}