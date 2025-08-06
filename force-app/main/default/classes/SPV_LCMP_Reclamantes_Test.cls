@isTest
public with sharing class SPV_LCMP_Reclamantes_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuarioGeneral.Username = 'userageneral@test.com.testdata';
            SPV_DatabaseDML.insertDML(usuarioGeneral, true);            

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, true);            
        }
        Test.stopTest();
        //Account
        Account cuenta = SPV_TestDataFactory.crearCuentas(1)[0];
        SPV_DatabaseDML.insertDML(cuenta, true);            

        //Contact
        Contact contacto = SPV_TestDataFactory.crearContacto(1, cuenta.Id)[0];
        SPV_DatabaseDML.insertDML(contacto, true);            

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('ContactId', contacto.Id);
        camposRecl.put('OwnerId', usuarioGeneral.id);
        
        Case reclamacion1 = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SPV_DatabaseDML.insertDML(reclamacion1, true);            

        //Reclamantes
        SAC_CaseReclamante__c reclamantePrincipal = SPV_TestDataFactory.crearReclamante(true, reclamacion1, cuenta.Id);
        reclamantePrincipal.SAC_Contact__c = contacto.Id;
    
        SAC_CaseReclamante__c reclamanteSecundario1 = SPV_TestDataFactory.crearReclamante(false, reclamacion1, cuenta.Id);
        reclamanteSecundario1.SAC_Contact__c = contacto.Id;

        SAC_CaseReclamante__c reclamanteSecundario2 = SPV_TestDataFactory.crearReclamante(false, reclamacion1, cuenta.Id);
        reclamanteSecundario2.SAC_Contact__c = contacto.Id;
        
        List<SAC_CaseReclamante__c> listaReclamantes = new List<SAC_CaseReclamante__c>();
        listaReclamantes.add(reclamantePrincipal);
        listaReclamantes.add(reclamanteSecundario1);
        listaReclamantes.add(reclamanteSecundario2);
        SPV_DatabaseDML.insertListDML(listaReclamantes, true);            
    }
    @isTest
    static void recuperarReclamantesTest() {
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        SPV_LCMP_Reclamantes.InfoReclamantesWrapper infoReclamantes;

        System.runAs(usuarioGeneral) {
            Test.startTest();
            infoReclamantes = SPV_LCMP_Reclamantes.recuperarReclamantes(reclamacion.Id);
            Test.stopTest();
        }
        
        Assert.areNotEqual(null, infoReclamantes, 'No se han podido recuperar los reclamantes');
    }
    @isTest
    static void eliminarReclaSecuTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Reclamacion.OwnerId = usuarioGeneral.id;
        SPV_DatabaseDML.updateDML(reclamacion, true);
        
        List<SAC_CaseReclamante__c> listaCaseRecl = [SELECT SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c 
                                                FROM SAC_CaseReclamante__c 
                                                WHERE SAC_Case__c = :reclamacion.Id
                                                AND SAC_ReclamantePrincipal__c = false];

        System.runAs(usuarioGeneral) {
            Test.startTest();
            SPV_LCMP_Reclamantes.eliminarReclaSecu(reclamacion.Id, reclamacion.OwnerId, null, listaCaseRecl[0].Id);
            Test.stopTest();
        }

        List<SAC_CaseReclamante__c> listaCaseReclResult = [SELECT SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c 
                                                    FROM SAC_CaseReclamante__c 
                                                    WHERE SAC_Case__c = :reclamacion.Id
                                                    AND SAC_ReclamantePrincipal__c = false];

        Assert.areEqual(listaCaseRecl.isEmpty(), listaCaseReclResult.isEmpty(), 'No se ha podido eliminar el reclamante secundario');
    }
    @isTest
    static void cambiarReclaPrincipalTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_CaseReclamante__c caseRecl = [SELECT SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c 
                                            FROM SAC_CaseReclamante__c 
                                            WHERE SAC_Case__c = :reclamacion.Id 
                                            AND SAC_ReclamantePrincipal__c = false LIMIT 1];
        System.runAs(usuarioGeneral) {
            Test.startTest();
            SPV_LCMP_Reclamantes.cambiarReclaPrincipal(caseRecl.Id);
            Test.stopTest();
        }

        SAC_CaseReclamante__c caseReclResult = [SELECT SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c 
                                                FROM SAC_CaseReclamante__c 
                                                WHERE Id = :caseRecl.Id LIMIT 1];

        Assert.areEqual(caseRecl.Id, caseReclResult.Id, 'No se ha podido cambiar el reclamante principal');
    }
    @isTest
    static void eliminarTest() {
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_CaseReclamante__c caseRecl = [SELECT SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :reclamacion.Id LIMIT 1];
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            Test.startTest();
            SPV_LCMP_Reclamantes.eliminar(reclamacion.Id, reclamacion.AccountId);
            Test.stopTest();
        }

        List<SAC_CaseReclamante__c> caseReclResult = [SELECT SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE Id = :caseRecl.Id LIMIT 1];

        Boolean borrado = caseReclResult.isEmpty() ? true : false;

        Assert.areEqual(true, borrado, 'No se ha podido eliminar al reclamante');
    }
    @isTest
    static void eliminarYCambiarPrincipalTest() {
        Case reclamacion = [SELECT Id, OwnerId, AccountId FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        SAC_CaseReclamante__c caseRecl2 = [SELECT Id, SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c 
                                            FROM SAC_CaseReclamante__c 
                                            WHERE SAC_Case__c = :reclamacion.Id 
                                            AND SAC_ReclamantePrincipal__c = false LIMIT 1];
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            Test.startTest();
            SPV_LCMP_Reclamantes.eliminarYCambiarPrincipal(reclamacion.Id, reclamacion.AccountId, caseRecl2.Id);
            Test.stopTest();
        }

        Assert.areNotEqual(true, caseRecl2.SAC_ReclamantePrincipal__c, 'No se ha podido eliminar el reclamante principal y cambiar el secundario');
    }
    @isTest
    static void tieneReclamanteSecundarioTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Reclamacion.OwnerId = usuarioGeneral.id;
        SPV_DatabaseDML.updateDML(reclamacion, true);
        Boolean tieneSecundario;
       

        System.runAs(usuarioGeneral) {
            Test.startTest();
            tieneSecundario = SPV_LCMP_Reclamantes.tieneReclamanteSecundario(reclamacion.Id, null, reclamacion.OwnerId);
            Test.stopTest();
        }

        Assert.areEqual(true, tieneSecundario, 'No se ha podido comprobar si el caso tiene reclamantes secundarios');
    }
    
    @isTest
    static void recuperarComunicacionesEmailTest() {
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage WHERE ParentId =:reclamacion.Id];
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            Test.startTest();
            SPV_LCMP_Reclamantes.recuperarComunicacionesEmail(reclamacion.Id);
            Test.stopTest();
        }
            
        List<EmailMessage> emailsV2 = [SELECT Id FROM EmailMessage WHERE ParentId =:reclamacion.Id];
        
        Assert.areEqual(emailsV2.isEmpty(), emails.isEmpty(), 'No se ha encontrado el email');
    }

    @isTest
    static void informarDatosNoAlfTest() {
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_CaseReclamante__c caseRecl1 = [SELECT Id, SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c 
            FROM SAC_CaseReclamante__c 
            WHERE SAC_Case__c = :reclamacion.Id 
            AND SAC_ReclamantePrincipal__c = true LIMIT 1];
        
        User usuarioGeneral = [SELECT id FROM User WHERE Username = 'userageneral@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            Test.startTest();
            SPV_LCMP_Reclamantes.informarDatosNoAlf(reclamacion.Id, caseRecl1.Id, 'tets@email.com', '653463', 'Calle Test, 3232, Poblacion, Provincia, Pais');
            Test.stopTest();
        }
            
        Case reclamacionFinal = [SELECT Id, OwnerId, SAC_ReclamantesConDatosNoAlf__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        
        Assert.areEqual(true, reclamacionFinal.SAC_ReclamantesConDatosNoAlf__c, 'No se ha informado los datos no alfabetizados del cliente');
    }
}