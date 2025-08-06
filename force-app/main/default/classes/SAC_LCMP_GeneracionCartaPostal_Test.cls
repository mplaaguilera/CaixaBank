@isTest
public with sharing class SAC_LCMP_GeneracionCartaPostal_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'userAdmintest000@test.com';
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);     
        //Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';  
            usuario.UserRoleId = uRole.id;    
            SAC_DatabaseDML.insertDML(usuario, false);   
            //Database.insert(usuario);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);  
            //Database.insert(permiSetAssi);
        }

         //RECLAMACION 1
         Map<String, Object> camposRecl = new Map<String, Object>();
         camposRecl.put('Subject', 'TestRec');
         camposRecl.put('Origin', 'Backoffice');
         camposRecl.put('Status', 'Alta');
         camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
         camposRecl.put('OwnerId', usuario.Id);
         
         Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
 
          //Reclamacion 1
          Map<String, Object> camposRecl1 = new Map<String, Object>();
          camposRecl1.put('Subject', 'testRec1');
          camposRecl1.put('Status', 'SAC_001');
          camposRecl1.put('SAC_DireccionContacto__c', 'test');
          camposRecl1.put('SAC_CodigoPostalContacto__c', 'test');
          camposRecl1.put('SAC_PoblacionContacto__c', 'test');
          camposRecl1.put('SAC_ProvinciaContacto__c', 'test');
          camposRecl1.put('SAC_PaisContacto__c', 'test');
          camposRecl1.put('SAC_NombreContacto__c', 'test');
 
 
  
          Case rec1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
  
          //Reclamacion 2
          Map<String, Object> camposRecl2 = new Map<String, Object>();
          camposRecl2.put('Subject', 'testRec2');
          camposRecl2.put('Status', 'SAC_001');
  
          Case rec2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
  
          //Insertamos reclamaciones
          List<Case> reclamaciones = new List<Case>();
          reclamaciones.add(rec1);        
          reclamaciones.add(rec2);
          reclamaciones.add(casoReclamacion);
  
          SAC_DatabaseDML.insertListDML(reclamaciones, true);
          //Database.insert(reclamaciones);
  
          SAC_DocumentoEnvio__c doc = SAC_TestDataFactory.crearDocumentoEnvio(1,rec1)[0];
          doc.SAC_CP__c = '12345';
          doc.SAC_TipoDocumento__c = 'docTest';
          SAC_DatabaseDML.insertDML(doc, false);
          //Database.insert(doc);
          
          Blob vd =  blob.valueOf('Unit.Test');
          ContentVersion cv = new ContentVersion(VersionData = vd, PathOnClient = 'SampleTitle.pdf' , Title = 'tituloTest', FirstPublishLocationId = rec1.Id, SAC_StringRedaccion_fileupload__c = 'carta postal docTest');
          SAC_DatabaseDML.insertDML(cv, false);
          //Database.insert(cv);


        Test.stopTest();

       

    }

    @isTest
    static void compruebaCartaPreviaTest(){
        SAC_DocumentoEnvio__c doc = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_CP__c = '12345'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'userAdmintest000@test.com' AND isActive = true Limit 1];
        System.runAs(usuario) {
            Case c = [SELECT Id FROM Case WHERE Subject = 'testRec1' Limit 1];

            Test.startTest();
            SAC_LCMP_GeneracionCartaPostal.WrappedInfoCartas myInfo = SAC_LCMP_GeneracionCartaPostal.compruebaCartaPrevia(c.Id, 'docTest');
            SAC_LCMP_GeneracionCartaPostal.WrappedInfoCartas myInfo2 = SAC_LCMP_GeneracionCartaPostal.compruebaCartaPrevia(c.Id, '');

            Test.stopTest();
            
            System.assertEquals(myInfo.idCarta, doc.Id, 'La búsqueda previa ha fallado.');
        }
    }
    
    @isTest
    static void getRutaTest(){
        String ruta;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            ruta = SAC_LCMP_GeneracionCartaPostal.getRuta();
            Test.stopTest();
        }
        Assert.areNotEqual(ruta, null, 'El método que trae la ruta ha fallado.');
    }

    @isTest
    static void getRutaVSTest(){
        String ruta;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            ruta = SAC_LCMP_GeneracionCartaPostal.getRutaVS();
            Test.stopTest();
        }
        Assert.areNotEqual(ruta, null, 'El método que trae la ruta ha fallado.');
    }


    @isTest
    static void insertarimagenTest(){
        String imagenInsertada;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        System.runAs(usuarioGeneral){
            Test.startTest();
            imagenInsertada = SAC_LCMP_GeneracionCartaPostal.insertarimagen(reclamacion.id, '<p><img></img></p>');
            Test.stopTest();
        }
        Assert.areNotEqual(imagenInsertada, null, 'La creación del registro que almacena la imagen ha fallado.');
    }

    @isTest
    static void getHeaderAndFooterTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1].Id;
        Case reclamacion = [SELECT Id, RecordTypeId, SAC_Entidad_Afectada__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        String idReclamacion = reclamacion.Id; 
        SAC_LCMP_GeneracionCartaPostal.WrapperTemplate infoTemplate; 

        EmailTemplate e = new EmailTemplate(
            developerName = 'paraClasetest', 
            FolderId = usuario.id, 
            TemplateType= 'Text', 
            Name = 'test',
            HtmlValue = 'cuerpo prueba',
            Subject = 'test'
        ); 
    
        SAC_DatabaseDML.insertDML(e, false);

        EnhancedLetterhead letterhead = new EnhancedLetterhead(Name = 'PlantillaSAC', LetterheadFooter = 'Test Footer', LetterheadHeader = 'Test Header');
        SAC_DatabaseDML.insertDML(letterhead, false);

        String idPlantilla = e.Id;

        System.RunAs(usuario){   
            Test.startTest();
            infoTemplate = SAC_LCMP_GeneracionCartaPostal.getHeaderAndFooterMTP('es', reclamacion.RecordTypeId, reclamacion.SAC_Entidad_Afectada__c);
            Assert.areNotEqual(null, infoTemplate, 'Ha fallado la obtención de datos de la plantilla');
            Test.stopTest();
        }
    }
}