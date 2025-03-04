@isTest
public with sharing class SAC_LCMP_GetAntecedentes_Test {
    
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];    
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);    
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);  
            //Database.insert(permiSetAssi);
        }

        System.runAs(usuarioGeneral){

            //Cuentas
            Account cuenta = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            cuenta.FirstName = 'test';
            cuenta.LastName = 'Test';
            cuenta.CC_Numero_Documento__c = '123456789';
            SAC_DatabaseDML.insertDML(cuenta, false);
            //Database.insert(cuenta);

            Account cuentaCC = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            cuentaCC.CC_Numero_Documento__c = '123456780';
            cuentaCC.FirstName = 'test';
            cuentaCC.LastName = 'CC';
            SAC_DatabaseDML.insertDML(cuentaCC, false);
            //Database.insert(cuentaCC);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false);
            //Database.insert(reclamacion);

            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'TestRec2');
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');

            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            SAC_DatabaseDML.insertDML(reclamacion2, false);
            //Database.insert(reclamacion2);

            //Reclamacion 3
            Map<String, Object> camposRecl3 = new Map<String, Object>();
            camposRecl3.put('Subject', 'TestRec3');
            camposRecl3.put('Status', 'SAC_001');
            camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposRecl3.put('AccountId', cuentaCC.Id);

            Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
            SAC_DatabaseDML.insertDML(reclamacion3, false);
            //Database.insert(reclamacion3);

            //Reclamacion CC
            Map<String, Object> camposReclCC = new Map<String, Object>();
            camposReclCC.put('Subject', 'TestRec4');
            camposReclCC.put('Status', 'SAC_001');
            camposReclCC.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposReclCC.put('CC_Canal_Resolucion__c', 'Accionista');
            camposReclCC.put('CC_Importe_Reclamado__c', 100);
            camposReclCC.put('CC_Detalles_Solucion__c', 'test');
            camposReclCC.put('CC_Oficina_afectada__c', '1');
            camposReclCC.put('AccountId', cuentaCC.Id);
            camposReclCC.put('RecordTypeId', Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId());

            Case reclamacionCC = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclCC);
            SAC_DatabaseDML.insertDML(reclamacionCC, false);
            //Database.insert(reclamacionCC);

            //Reclamantes
            SAC_CaseReclamante__c reclamantePrin = SAC_TestDataFactory.crearReclamante(true,reclamacion,cuenta.Id);
            SAC_DatabaseDML.insertDML(reclamantePrin, false);
            //Database.insert(reclamantePrin);

            SAC_CaseReclamante__c reclamanteCC = SAC_TestDataFactory.crearReclamante(true,reclamacionCC,cuentaCC.Id);
            SAC_DatabaseDML.insertDML(reclamanteCC, false);
            //Database.insert(reclamanteCC);

            SAC_CaseReclamante__c reclamante2 = SAC_TestDataFactory.crearReclamante(true,reclamacion3,cuentaCC.Id);
            SAC_DatabaseDML.insertDML(reclamante2, false);
            //Database.insert(reclamante2);
        }
        
        CBK_IntegrationSetting__c csAntecedentes = new CBK_IntegrationSetting__c();
        csAntecedentes.Name = 'SAC_Antecedentes';
        csAntecedentes.NamedCredential__c = 'callout:API_GWT_PRO/servicing/servicingIssue/claims/request';
        
        CBK_IntegrationSetting__c csGescon = new CBK_IntegrationSetting__c();
        csGescon.Name = 'SAC_Gescon';
        csGescon.NamedCredential__c = 'callout:API_GWT_PRO/nonITAndNonHREnterpriseServices/legalCompliance/bankruptcyProcs/request/bulk';
        
        CBK_IntegrationSetting__c csProes = new CBK_IntegrationSetting__c();
        csProes.Name = 'SAC_Proesp';
        csProes.NamedCredential__c = 'callout:API_GWT_PRO/nonITAndNonHREnterpriseServices/legalCompliance/specialProcs/request/bulk';
        
        CBK_IntegrationSetting__c csPromo= new CBK_IntegrationSetting__c();
        csPromo.Name = 'SAC_Promor';
        csPromo.NamedCredential__c = 'callout:API_GWT_PRO/corporateServices/legalCompliance/debtClaims/request';
        
        List<CBK_IntegrationSetting__c> lstIntegration = new List<CBK_IntegrationSetting__c>();
        lstIntegration.add(csAntecedentes);
        lstIntegration.add(csGescon);
        lstIntegration.add(csProes);
        lstIntegration.add(csPromo);
        SAC_DatabaseDML.insertListDML(lstIntegration, false);
        //Database.insert(lstIntegration);
    }

    @isTest
    static void obtenerDNIReclamantesTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE LastName = 'Test' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<String> result;

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));

        Test.startTest();
        System.runAs(usuario) {
            result = SAC_LCMP_GetAntecedentes.obtenerDNIReclamantes(reclamacion.Id);
        }
        Test.stopTest();

        System.assertEquals(result[0], cuenta.CC_Numero_Documento__c, 'La obtención de datos ha fallado');
    }

    @isTest
    static void obtenerDNIReclamantes2Test(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<String> result;

        Test.startTest();
        System.runAs(usuario) {
            result = SAC_LCMP_GetAntecedentes.obtenerDNIReclamantes(reclamacion.Id);
        }
        Test.stopTest();

        System.assertEquals(null, result, 'No obtener datos ha fallado');
    }


    @isTest
    static void obtenerDNIReclamantes3Test(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE LastName = 'CC' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<String> result;

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        Test.startTest();
        System.runAs(usuario) {
            result = SAC_LCMP_GetAntecedentes.obtenerDNIReclamantes(reclamacion.Id);
        }
        Test.stopTest();

        System.assertEquals(result[0], cuenta.CC_Numero_Documento__c, 'La obtención de datos ha fallado');
    }

    @isTest
    static void recuperarCaseInfoTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        SAC_LCMP_GetAntecedentes.WrapperInfo resultado;
        
        Test.startTest();
        System.runAs(usuario) {
            resultado = SAC_LCMP_GetAntecedentes.recuperarCaseInfo(reclamacion.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, resultado.caso, 'La obtención de datos del caso ha fallado');
        System.assertNotEquals(null, resultado.esCOPSAJ, 'La obtención de datos del usuario ha fallado');
        System.assertNotEquals(null, resultado.userOwner, 'La obtención de datos del usuario ha fallado');
    }

    @isTest
    static void establecerCheckRevisadosTest(){
        Case reclamacion = [SELECT Id, SAC_Antecedentes_Revisados__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_GetAntecedentes.establecerCheckRevisados(reclamacion.Id, true);
        }
        Test.stopTest();

        Case reclamacionFinal = [SELECT Id, SAC_Antecedentes_Revisados__c FROM Case WHERE Subject = 'TestRec3' LIMIT 1];

        System.assertNotEquals(reclamacion.SAC_Antecedentes_Revisados__c, reclamacionFinal.SAC_Antecedentes_Revisados__c, 'Error al actualizar el campo Antecedentes Revisados');

    }
}