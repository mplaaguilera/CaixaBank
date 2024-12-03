@isTest
public with sharing class SPV_Pretension_Test {
  
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
        Database.upsert(listaMCCs);


        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

           /* PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);*/

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
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
                Database.insert(listaCuentas);
        
                //Reclamacion
                Map<String, Object> camposRecl = new Map<String, Object>();
                camposRecl.put('Subject', 'TestRec');
                camposRecl.put('Origin', 'Otros');
                camposRecl.put('Status', 'SAC_001');
                camposRecl.put('SAC_TipoConsumidor__c', 'No');
                camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
                camposRecl.put('OwnerId', usuarioGeneral.Id);
        
                Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        
                //Reclamacion 2
                Map<String, Object> camposRecl2 = new Map<String, Object>();
                camposRecl2.put('Subject', 'TestRec2');
                camposRecl2.put('Origin', 'Otros');
                camposRecl2.put('Status', 'SAC_001');
                camposRecl2.put('AccountId', listaCuentas[0].Id);
                camposRecl2.put('SAC_TipoConsumidor__c', 'No');
                camposRecl2.put('SAC_Naturaleza__c', 'SAC_004');
                camposRecl2.put('OwnerId', usuarioGeneral.Id);
        
                Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        
                //Reclamacion 3
                Map<String, Object> camposRecl3 = new Map<String, Object>();
                camposRecl3.put('Subject', 'TestRec3');
                camposRecl3.put('Origin', 'Otros');
                camposRecl3.put('Status', 'SAC_001');
                camposRecl3.put('SAC_TipoConsumidor__c', 'No');
                camposRecl3.put('SAC_Naturaleza__c', 'SAC_004');
                camposRecl3.put('OwnerId', usuarioGeneral.Id);
        
                Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        
                //Reclamaciones
                List<Case> reclamaciones = new List<Case>();
                reclamaciones.add(casoReclamacion);
                reclamaciones.add(casoReclamacion2);
                reclamaciones.add(casoReclamacion3);
                Database.insert(reclamaciones);
        
                //Pretension
                Map<String, Object> camposPret = new Map<String, Object>();
                camposPret.put('SuppliedCompany', 'testPret');
                camposPret.put('Origin', 'Otros');
                camposPret.put('Status', 'SAC_001');
                camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
                camposPret.put('OwnerId', usuarioGeneral.Id);
        
                Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        
                //Pretension 2
                Map<String, Object> camposPret2 = new Map<String, Object>();
                camposPret2.put('SEG_Detalle__c', mccDetalle.Id);
                camposPret2.put('Origin', 'Otros');
                camposPret2.put('Status', 'SAC_001');
                camposPret2.put('SAC_Reclamacion__c', casoReclamacion2.Id);
                camposPret2.put('OwnerId', usuarioGeneral.Id);
        
                Case casoPretension2 = SPV_TestDataFactory.crearCaso('Pretension',camposPret2);
        
                //Pretension 3
                Map<String, Object> camposPret3 = new Map<String, Object>();
                camposPret3.put('SuppliedCompany', 'testPretNegocio');
                camposPret3.put('Origin', 'Otros');
                camposPret3.put('Status', 'SAC_001');
                camposPret3.put('SAC_Reclamacion__c', casoReclamacion2.Id);
                camposPret3.put('SEG_Detalle__c', mccDetalle.Id);
                camposPret3.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
                camposPret3.put('SAC_DetalleResultadoNegociacion__c', 'Otros');
                camposPret3.put('CC_Importe_Reclamado__c', 300);
                camposPret3.put('SAC_Importe_Resuelto__c', 100);
                camposPret3.put('SAC_Importe_ResultadoNegociacion__c', 200);
                camposPret3.put('OwnerId', usuarioGeneral.Id);
        
                Case casoPretension3 = SPV_TestDataFactory.crearCaso('Pretension',camposPret3);
        
                //Pretension 4
                Map<String, Object> camposPret4 = new Map<String, Object>();
                camposPret4.put('SuppliedCompany', 'testPretNegocio2');
                camposPret4.put('Origin', 'Otros');
                camposPret4.put('Status', 'SAC_001');
                camposPret4.put('SAC_Reclamacion__c', casoReclamacion2.Id);
                camposPret4.put('SEG_Detalle__c', mccDetalle.Id);
                camposPret4.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
                camposPret4.put('SAC_DetalleResultadoNegociacion__c', 'Otros');
                camposPret4.put('OwnerId', usuarioGeneral.Id);
        
                Case casoPretension4 = SPV_TestDataFactory.crearCaso('Pretension',camposPret4);
        
                   //Pretension 4
                   Map<String, Object> camposPret5 = new Map<String, Object>();
                   camposPret5.put('SuppliedCompany', 'testPretNegocio3');
                   camposPret5.put('Origin', 'Otros');
                   camposPret5.put('Status', 'SAC_001');
                   camposPret5.put('SAC_Reclamacion__c', casoReclamacion3.Id);
                   camposPret5.put('SEG_Detalle__c', mccDetalle.Id);
                   camposPret5.put('SAC_ResultadoNegociacion__c', 'Sin acuerdo');
                   camposPret5.put('SAC_DetalleResultadoNegociacion__c', 'Otros');
                   camposPret5.put('OwnerId', usuarioGeneral.Id);
           
                   Case casoPretension5 = SPV_TestDataFactory.crearCaso('Pretension',camposPret5);

                //Pretensiones
                List<Case> pretensiones = new List<Case>();
                pretensiones.add(casoPretension);
                pretensiones.add(casoPretension2);
                pretensiones.add(casoPretension3);
                pretensiones.add(casoPretension4);
                pretensiones.add(casoPretension5);
                Database.insert(pretensiones);

                //Reclamante
                List<SAC_CaseReclamante__c> reclamantes = new List<SAC_CaseReclamante__c>();
                SAC_CaseReclamante__c reclamante1 = new SAC_CaseReclamante__c();
                reclamante1.put('OwnerId', usuarioGeneral.Id);
                reclamante1.put('SAC_Case__c', casoReclamacion.Id);

                reclamantes.add(reclamante1);
                Database.insert(reclamantes);
    }

    @isTest
    static void cambiarOwnerPretsHermanasTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];


        User usuario2 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];
        Case pretension = [SELECT id, OwnerId FROM Case WHERE SuppliedCompany = 'testPretNegocio'];

        System.runAs(usuario1){
            Test.startTest();
            pretension.OwnerId = usuario2.Id;
            Database.update(pretension);
            Test.stopTest();
        }

        Case pretensionResultado = [SELECT id, OwnerId FROM Case WHERE SuppliedCompany = 'testPretNegocio2'];
        System.assertEquals(usuario2.Id, pretensionResultado.OwnerId, 'No ha cambiado el owner de las pretensiones hermanas');

    }


    @isTest
    static void cambiarOwnerReclamanteTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];


        User usuario2 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];
        Case pretension = [SELECT id, OwnerId FROM Case WHERE SuppliedCompany = 'testPretNegocio'];

        System.runAs(usuario1){
            Test.startTest();
            reclamacion.OwnerId = usuario2.Id;
            Database.update(reclamacion);
            Test.stopTest();
        }

        SAC_CaseReclamante__c reclamanteResultado =  [SELECT Id, OwnerId, SAC_Case__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.id LIMIT 1];
        System.assertEquals(usuario2.Id, reclamanteResultado.OwnerId, 'No ha cambiado el owner de las pretensiones hermanas');

    }



    @isTest
    static void cambioLetradoTest(){
                List<Case> listaPretensiones = [SELECT id, OwnerId, SuppliedCompany FROM CASE WHERE SuppliedCompany = 'testPret' OR SuppliedCompany = 'testPretNegocio' OR SuppliedCompany = 'testPretNegocio3'];
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'SAC_PendienteAsignar' OR DeveloperName = 'SAC_PteSupervisor') LIMIT 1];
        Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];


        List<Case> pretensionesUpdatear = new List<Case>();
        Case pretension1 = new Case();
        Case pretension2 = new Case();
        Case pretension3 = new Case();

        for (Case pret : listaPretensiones) {
            if (pret.SuppliedCompany == 'testPret') {
                pretension1.Id = pret.Id;
                pretensionesUpdatear.add(pretension1);
            }
            if (pret.SuppliedCompany == 'testPretNegocio') {
                pretension2.Id = pret.Id;
                pretensionesUpdatear.add(pretension2);
            }
            if (pret.SuppliedCompany == 'testPretNegocio3') {
                pretension3.Id = pret.Id;
                pretensionesUpdatear.add(pretension3);
            }
        }
        
        User usuario1 = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario1){
            Test.startTest();
            pretension1.OwnerId = usuario1.Id;
            pretension2.OwnerId = cola.Id;
            pretension3.OwnerId = colaSupervisores.Id;
            Database.update(pretensionesUpdatear);
            Test.stopTest();
        }

        List<Case> listaReclamacionResult = [SELECT id, SAC_Letrado__c, Subject FROM Case WHERE subject = 'TestRec' OR subject = 'TestRec2' OR subject= 'TestRec3'];
        Case reclaResult1 = new Case();
        Case reclaResult2 = new Case();
        Case reclaResult3 = new Case();
        for (Case rec : listaReclamacionResult) {
            if (rec.Subject == 'TestRec') {
                reclaResult1 = rec;
            }
            if (rec.Subject == 'TestRec2') {
                reclaResult2 = rec;
            }
            if (rec.Subject == 'TestRec3') {
                reclaResult3 = rec;
            }
        }
        Assert.areEqual('Usuario Test SPV0', reclaResult1.SAC_Letrado__c, 'No se ha podido recuperar el nombre del letrado');
        Assert.areEqual('Pte. Asignar', reclaResult2.SAC_Letrado__c, 'No se ha podido recuperar el nombre del letrado');
        Assert.areEqual('Pte. Supervisor', reclaResult3.SAC_Letrado__c, 'No se ha podido recuperar el nombre del letrado');
    }

}