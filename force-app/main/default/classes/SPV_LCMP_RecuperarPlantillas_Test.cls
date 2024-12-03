/*****************************************************************
 * Name: SPV_LCMP_RecuperarPlantillas_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_RecuperarPlantillas
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_RecuperarPlantillas_Test {
    
    @TestSetup
    static void makeData(){
    
        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            Database.insert(listUsuarios );
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
        Database.insert(listaReclamaciones);
    }

    @isTest
    static void getRaizTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.getRaiz();
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void recuperarPlantillasTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.recuperarPlantillas();
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void cambioCarpetaTest(){

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSPV' LIMIT 1].Id;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.cambioCarpeta(parametro);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void volverHaciaArribaTest(){

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSPV' LIMIT 1].Id;

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.volverHaciaArriba(parametro);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateBodyTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'test cuerpo'
        ); 
    
        Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id;
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.obtenerTemplateBody(idPlantilla, idReclamacion, idReclamacion);
            Assert.areEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateSubjectTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id; 
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.obtenerTemplateSubject(idPlantilla, idReclamacion, idReclamacion);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateSubjectTestException(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id; 
        String excepcion = 'excepcion';
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.obtenerTemplateSubject(idPlantilla, excepcion, idReclamacion);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }
}