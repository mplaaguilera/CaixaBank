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
        Datetime d = System.today();
        String formattedDate = d.day() + '-' + d.month()  + '-' + d.year();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'custom', 
            Name = 'test',
            HtmlValue = 'test cuerpo (FECHAACTUAL)'
        ); 
    
        SPV_DatabaseDML.insertDML(e, true);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id;
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SPV_LCMP_RecuperarPlantillas.obtenerTemplateBody(idPlantilla, idReclamacion, idReclamacion);
            Assert.areEqual('test cuerpo ' + formattedDate, result, 'Obtener la plantilla raiz ha fallado.');
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
            TemplateType= 'custom', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SPV_DatabaseDML.insertDML(e, true);

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
            TemplateType= 'custom', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SPV_DatabaseDML.insertDML(e, true);

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

    @isTest
    static void recuperarDirectorioRaizTest(){
        SPV_LCMP_RecuperarPlantillas.WrapperDirectorioRaiz infoRaiz; 

        Folder parametro = [SELECT Id, developerName FROM Folder WHERE DeveloperName = 'PlantillasSPV' LIMIT 1];

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            infoRaiz = SPV_LCMP_RecuperarPlantillas.recuperarDirectorioRaiz(parametro.developerName);
            Assert.areNotEqual(null, infoRaiz.elementosDirectorio, 'Obtener los datos del directorio raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void buscarPlantillasTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];

        Folder carpeta = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName = 'PlantillasSPV' LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        String idReclamacion = reclamacion.Id; 
        SPV_LCMP_RecuperarPlantillas.WrapperTemplate infoTemplate; 

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'custom', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SPV_DatabaseDML.insertDML(e, true);

        System.RunAs(usuario){   
            Test.startTest();
            String plantillas = SPV_LCMP_RecuperarPlantillas.buscarPlantillas('test', e.FolderId, e.Name);
            Assert.areNotEqual(null, plantillas, 'Ha fallado la busqueda de las plantillas');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerDatosTemplateTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSPV' LIMIT 1].Id;
        Case reclamacion = [SELECT Id, RecordTypeId FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        String idReclamacion = reclamacion.Id; 
        SPV_LCMP_RecuperarPlantillas.WrapperTemplate infoTemplate; 

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest3', 
            FolderId = usuario.id, 
            TemplateType= 'custom',
            Name = 'test',
            HtmlValue = 'cuerpo prueba (FECHAACTUAL)',
            Subject = 'test'
        ); 
    
        SPV_DatabaseDML.insertDML(e, false);
        
        EnhancedLetterhead letterhead = new EnhancedLetterhead(Name = 'PlantillaSPV', LetterheadFooter = 'Test Footer', LetterheadHeader = 'Test Header');
        SPV_DatabaseDML.insertDML(letterhead, false);

        String idPlantilla = e.Id;

        System.RunAs(usuario){   
            Test.startTest();
            infoTemplate = SPV_LCMP_RecuperarPlantillas.obtenerDatosTemplate(idPlantilla, idReclamacion, 'es', reclamacion.RecordTypeId);
            Assert.areNotEqual(null, infoTemplate, 'Ha fallado la obtención de datos de la plantilla');
            Test.stopTest();
        }
    }
}