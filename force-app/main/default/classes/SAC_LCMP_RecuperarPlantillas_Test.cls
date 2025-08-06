@isTest
public with sharing class SAC_LCMP_RecuperarPlantillas_Test {
    
    @TestSetup
    static void makeData(){
        Test.startTest();
        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);
        //Database.insert(usuarioAdmin); 

        User usuarioGeneral;
        System.runAs(usuarioAdmin) {
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
        Test.stopTest();

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false);
        //Database.insert(reclamacion);

        //Pretensiones
		List<Case> pretensiones = new List<Case>();
		//PRETENSION 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret.put('SAC_RedaccionFinal__c', true);
		camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
		
        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(casoPretension, false);
		//Database.insert(casoPretension);
    }

    @isTest
    static void getRaizTest(){

        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.getRaiz();
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void recuperarPlantillasTest(){

        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.recuperarPlantillas();
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void cambioCarpetaTest(){

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1].Id;

        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.cambioCarpeta(parametro);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void volverHaciaArribaTest(){

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1].Id;

        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.volverHaciaArriba(parametro);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateBodyTest(){
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'test cuerpo'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);
        //Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id;
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.obtenerTemplateBody(idPlantilla, idReclamacion, idReclamacion);
            Assert.areEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateBodyTestException(){
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'test cuerpo'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);
        //Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id;
        String excepcion = 'excepcion';
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.obtenerTemplateBody(idPlantilla, excepcion, idReclamacion);
            Assert.areEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateSubjectTest(){
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);
        //Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id; 
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.obtenerTemplateSubject(idPlantilla, idReclamacion, idReclamacion);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    static void obtenerTemplateSubjectTestException(){
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec' LIMIT 1];

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);
        //Database.insert(e);

        String idPlantilla = e.Id;
        String idReclamacion = reclamacion.Id; 
        String excepcion = 'excepcion';
        
        System.RunAs(usuario){   
            Test.startTest();
            String result = SAC_LCMP_RecuperarPlantillas.obtenerTemplateSubject(idPlantilla, excepcion, idReclamacion);
            Assert.areNotEqual(null, result, 'Obtener la plantilla raiz ha fallado.');
            Test.stopTest();
        }
    }


    @isTest
    static void recuperarDirectorioRaizTest(){
        SAC_LCMP_RecuperarPlantillas.WrapperDirectorioRaiz infoRaiz; 

        Folder parametro = [SELECT Id, developerName FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            infoRaiz = SAC_LCMP_RecuperarPlantillas.recuperarDirectorioRaiz(parametro.developerName);
            Assert.areNotEqual(null, infoRaiz.elementosDirectorio, 'Obtener los datos del directorio raiz ha fallado.');
            Test.stopTest();
        }
    }


    @isTest
    static void obtenerDatosTemplateTest(){
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1].Id;
        Case reclamacion = [SELECT Id, RecordTypeId, SAC_Entidad_Afectada__c FROM Case WHERE Subject = 'testRec' LIMIT 1];
        String idReclamacion = reclamacion.Id; 
        SAC_LCMP_RecuperarPlantillas.WrapperTemplate infoTemplate; 

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);
        //Database.insert(e);

        EnhancedLetterhead letterhead = new EnhancedLetterhead(Name = 'PlantillaSAC', LetterheadFooter = 'Test Footer', LetterheadHeader = 'Test Header');
        SAC_DatabaseDML.insertDML(letterhead, false);
        //Database.insert(letterhead);

        String idPlantilla = e.Id;

        System.RunAs(usuario){   
            Test.startTest();
            infoTemplate = SAC_LCMP_RecuperarPlantillas.obtenerDatosTemplate(idPlantilla, idReclamacion, 'es', reclamacion.RecordTypeId, reclamacion.SAC_Entidad_Afectada__c);
            Assert.areNotEqual(null, infoTemplate, 'Ha fallado la obtención de datos de la plantilla');
            Test.stopTest();
        }
    }


    @isTest
    static void buscarPlantillasTest(){
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Folder carpeta = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec' LIMIT 1];
        String idReclamacion = reclamacion.Id; 
        SAC_LCMP_RecuperarPlantillas.WrapperTemplate infoTemplate; 

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);
        //Database.insert(e);

        System.RunAs(usuario){   
            Test.startTest();
            String plantillas = SAC_LCMP_RecuperarPlantillas.buscarPlantillas('test', e.FolderId, e.Name);
            Assert.areNotEqual(null, plantillas, 'Ha fallado la busqueda de las plantillas');
            Test.stopTest();
        }
    }


    @isTest
    static void validarPretensionesTest(){

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec' LIMIT 1];

        String idReclamacion = reclamacion.Id; 
        
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.RunAs(usuario){   
            Test.startTest();
            Boolean result = SAC_LCMP_RecuperarPlantillas.validarPretensiones(idReclamacion);
            Assert.areNotEqual(false, result, 'Fallo al validar que todas las pretensiones están listas para redacción.');
            Test.stopTest();
        }
    }
}