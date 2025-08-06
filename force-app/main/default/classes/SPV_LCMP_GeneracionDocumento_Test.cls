@isTest
public with sharing class SPV_LCMP_GeneracionDocumento_Test {

    @TestSetup
    static void makeData(){
    
        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }

        Test.stopTest();

        //Reclamacion
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        // camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_003');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_003');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        SAC_DocumentoEnvio__c documento = new SAC_DocumentoEnvio__c(
                SAC_Caso__c = casoReclamacion.Id,
                Name = 'TestDocumentoEnvio',
                SAC_Documento__c = null,
                SAC_TipoDocumento__c = 'generacionDocSPV'
        );
        SPV_DatabaseDML.insertDML(documento, false); 
    }

    @isTest
    static void getRutaTest(){
        String ruta;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            ruta = SPV_LCMP_GeneracionDocumento.getRuta();
            Test.stopTest();
        }
        Assert.areNotEqual(ruta, null, 'El método que trae la ruta ha fallado.');
    }

    @isTest
    static void getRutaVSTest(){
        String ruta;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            ruta = SPV_LCMP_GeneracionDocumento.getRutaVS();
            Test.stopTest();
        }
        Assert.areNotEqual(ruta, null, 'El método que trae la ruta ha fallado.');
    }

    @isTest
    static void insertarimagenTest(){
        String imagenInsertada;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            imagenInsertada = SPV_LCMP_GeneracionDocumento.insertarimagen(reclamacion.id, '<p><img></img></p>');
            Test.stopTest();
        }
        Assert.areNotEqual(imagenInsertada, null, 'La creación del registro que almacena la imagen ha fallado.');
    }

    @isTest
    static void generarDocumentoTest(){
        SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];
        SAC_DocumentoEnvio__c documentoEnvio2;
        Case reclamacion = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];


        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        
        System.runAs(usuario){
            Test.startTest();
            SPV_LCMP_GeneracionDocumento.generarDocumento(documentoEnvio.Id, 'Documento de prueba');

            reclamacion.CC_Idioma__c = 'ca';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            SPV_LCMP_GeneracionDocumento.generarDocumento(documentoEnvio.Id, 'Documento de prueba');

            reclamacion.CC_Idioma__c = 'en';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            SPV_LCMP_GeneracionDocumento.generarDocumento(documentoEnvio.Id, 'Documento de prueba');

            reclamacion.CC_Idioma__c = 'va';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            SPV_LCMP_GeneracionDocumento.generarDocumento(documentoEnvio.Id, 'Documento de prueba');

            reclamacion.CC_Idioma__c = 'ga';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            SPV_LCMP_GeneracionDocumento.generarDocumento(documentoEnvio.Id, 'Documento de prueba');

            reclamacion.CC_Idioma__c = 'eu';
            SPV_DatabaseDML.updateDML(reclamacion, true);
            SPV_LCMP_GeneracionDocumento.generarDocumento(documentoEnvio.Id, 'Documento de prueba');
            Test.stopTest();
            documentoEnvio2 = [SELECT Id, SAC_URL__c  FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];
        }

        Assert.areNotEqual(documentoEnvio2.SAC_URL__c, null, 'El método que genera el documento de redaccion ha fallado.');
    }

    @isTest
    static void comprobarDocumentoGuardado(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        SAC_DocumentoEnvio__c documentoEnvio2;
        
        System.runAs(usuario){
            Test.startTest();
            documentoEnvio2 = SPV_LCMP_GeneracionDocumento.comprobarDocumentoGuardado(reclamacion.Id);
            Test.stopTest();
        }

        Assert.areNotEqual(documentoEnvio2.Id, null, 'El método que genera el comprueba el documento de envio ha fallado.');
    }

    @isTest
    static void informacionCasoTest() {
        // Obtener el usuario y el documento creado en TestSetup
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_DocumentoEnvio__c documento = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];
        Case caso = [SELECT Id, CaseNumber, CC_Idioma__c FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            Map<String, Object> resultado = SPV_LCMP_GeneracionDocumento.informacionCaso(documento.Id);
            Test.stopTest();

            System.assertNotEquals(null, resultado, 'El Map devuelto no debe ser null');
            System.assertEquals(caso.CaseNumber, (String) resultado.get('numeroCaso'), 'El número de caso no coincide');
            System.assertEquals(caso.CC_Idioma__c, (String) resultado.get('idioma'), 'El idioma no coincide');
        }
    }
}