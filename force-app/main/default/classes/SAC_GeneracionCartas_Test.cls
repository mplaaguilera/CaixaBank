@isTest
public with sharing class SAC_GeneracionCartas_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        Database.insert(usuario);

        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('Status', 'SAC_001');

        Case rec1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'testRec2');
        camposRecl2.put('Status', 'SAC_001');

        Case rec2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //Insertamos reclamaciones
        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(rec1);        
        reclamaciones.add(rec2);

        Database.insert(reclamaciones);

        SAC_DocumentoEnvio__c doc = SAC_TestDataFactory.crearDocumentoEnvio(1,rec1)[0];
        doc.SAC_CP__c = '12345';
        doc.SAC_TipoDocumento__c = 'docTest';
        Database.insert(doc);
        
        Blob vd =  blob.valueOf('Unit.Test');
        ContentVersion cv = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = rec1.Id, SAC_StringRedaccion_fileupload__c = 'carta postal docTest');
        Database.insert(cv);
    }

    @isTest
    static void SAC_BuscaCartaPrevia_Test(){
        Case c = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        SAC_DocumentoEnvio__c doc = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_CP__c = '12345'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario) {
            Test.startTest();
            SAC_GeneracionCartas.WrappedInfoCartas myInfo = SAC_GeneracionCartas.SAC_BuscaCartaPrevia(c.Id, 'docTest');
            Test.stopTest();
            
            System.assertEquals(myInfo.idCarta, doc.Id, 'La búsqueda previa ha fallado.');
        }
    }

    @isTest
    static void SAC_BuscaCartaPrevia2_Test(){
        Case c = [SELECT Id FROM Case WHERE Subject = 'testRec2'];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario) {
            Test.startTest();
            SAC_GeneracionCartas.WrappedInfoCartas myInfo = SAC_GeneracionCartas.SAC_BuscaCartaPrevia(c.Id, '');
            Test.stopTest();
            System.assertEquals(myInfo.idCarta, '', 'La búsqueda previa ha fallado.');
        }
    }

    @isTest
    static void adjuntarPDFaCaso2_Test(){
        Case c = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        SAC_DocumentoEnvio__c doc = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_CP__c = '12345'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario) {
            Test.startTest();
            SAC_GeneracionCartas.WrappedInfoCartas myInfo = SAC_GeneracionCartas.SAC_BuscaCartaPrevia(c.Id, 'docTest');
            List<ContentVersion> cvs = [SELECT Id FROM ContentVersion];
            SAC_GeneracionCartas.adjuntarPDFaCaso2(myInfo.urlVF+doc.Id, c.Id, 'docTest');
            List<ContentVersion> cvs2 = [SELECT Id FROM ContentVersion];
            Test.stopTest();
            System.assertNotEquals(cvs, cvs2, 'La modificación de la carta postal ha fallado.');
        }
    }

    @isTest
    static void actualizarDatosEnvio_Test(){
        Case c = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        SAC_DocumentoEnvio__c doc = [SELECT Id, SAC_CP__c FROM SAC_DocumentoEnvio__c WHERE SAC_CP__c = '12345'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario) {
            Test.startTest();
            SAC_GeneracionCartas.actualizarDatosEnvio(doc.Id, 'String direccion', 'String cp', 'String poblacion', 'String provincia', '001');
            SAC_DocumentoEnvio__c doc2 = [SELECT Id, SAC_CP__c FROM SAC_DocumentoEnvio__c WHERE SAC_CP__c = 'String cp'];
            Test.stopTest();
            System.assertEquals(doc.Id, doc2.Id, 'La modificación de la carta postal ha fallado.');
            System.assertNotEquals(doc.SAC_CP__c, doc2.SAC_CP__c, 'La modificación de la carta postal ha fallado.');
        }
    }
}