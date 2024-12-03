@isTest
public with sharing class SAC_LCMP_FichaDocumentoEnvio_Test {

    @TestSetup
    static void makeData(){      

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            Account acc = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            Database.insert(acc);
            

            List<Case> reclamaciones = new List<Case>();
            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'testRec');
            camposRecl1.put('AccountId', acc.Id);
            camposRecl1.put('Status', 'SAC_003');
    
            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
            reclamaciones.add(reclamacion1);
            
            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testRec2');
            camposRecl2.put('AccountId', acc.Id);
            camposRecl2.put('Status', 'SAC_003');
    
            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            reclamaciones.add(reclamacion2);

            Database.insert(reclamaciones);

            //ContentVersion
            ContentVersion cv = SAC_TestDataFactory.crearContentVersion(reclamacion1);
            Database.insert(cv);


            List<SAC_DocumentoEnvio__c> documentosEnvio = new List<SAC_DocumentoEnvio__c>();
            //Documento 1
            SAC_DocumentoEnvio__c docEnv = SAC_TestDataFactory.crearDocumentoEnvio(1, reclamacion1)[0];
            docEnv.SAC_TipoDocumento__c = 'redacción';
            docEnv.SAC_Direccion__c = 'direccionTest';
            docEnv.SAC_Documento__c = cv.Id;
            documentosEnvio.add(docEnv);

            //Documento 2
            SAC_DocumentoEnvio__c docEnv2 = SAC_TestDataFactory.crearDocumentoEnvio(1, reclamacion2)[0];
            docEnv2.SAC_TipoDocumento__c = 'redacción';
            docEnv2.SAC_Direccion__c = 'direccionTest2';
            documentosEnvio.add(docEnv2);
            
            Database.insert(documentosEnvio);
        }
    }

    @isTest
    static void recuperarDocumentoTest(){
        Case reclamacion1 = [SELECT Id FROM Case WHERE Subject = 'testRec'];
        SAC_DocumentoEnvio__c doc = [SELECT Id, SAC_Documento__c  FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: reclamacion1.Id];
        String resultado;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_FichaDocumentoEnvio.recuperarDocumento(doc.Id);
            Test.stopTest();

            System.assertEquals(resultado, doc.SAC_Documento__c, 'La búsqueda de información ha fallado.');
        }
    }
    
    @isTest
    static void recuperarDocumentoTest2(){
        Case reclamacion2 = [SELECT Id FROM Case WHERE Subject = 'testRec2'];
        SAC_DocumentoEnvio__c doc = [SELECT Id, SAC_Documento__c  FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: reclamacion2.Id];
        String resultado;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_FichaDocumentoEnvio.recuperarDocumento(doc.Id);
            Test.stopTest();

            System.assertEquals(resultado, doc.SAC_Documento__c, 'La búsqueda de información ha fallado.');
        }
    }
}