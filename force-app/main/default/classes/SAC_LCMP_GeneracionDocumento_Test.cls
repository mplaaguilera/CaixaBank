@isTest
public with sharing class SAC_LCMP_GeneracionDocumento_Test {

    @TestSetup
    static void makeData(){
        Test.startTest();
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
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
        Test.stopTest();

        List<Case> listaReclamaciones = new List<Case>();
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuario.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'Alta');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl2.put('OwnerId', usuario.Id);
        camposRecl2.put('CC_Idioma__c', 'eu');
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 
        //Database.insert(listaReclamaciones);  


        List<SAC_DocumentoEnvio__c> listDocumentoEnvio = SAC_TestDataFactory.crearDocumentoEnvio(1, casoReclamacion);
        listDocumentoEnvio[0].SAC_TipoDocumento__c = 'redaccion';
        SAC_DatabaseDML.insertListDML(listDocumentoEnvio, false); 
        //Database.insert(listDocumentoEnvio);  

        List<SAC_DocumentoEnvio__c> listDocumentoEnvio2 = SAC_TestDataFactory.crearDocumentoEnvio(1, casoReclamacion2);
        listDocumentoEnvio2[0].Name = 'TestDocumentoEnvio';
        listDocumentoEnvio2[0].SAC_Documento__c = null;
        listDocumentoEnvio2[0].SAC_TipoDocumento__c = 'redaccion';
        SAC_DatabaseDML.insertListDML(listDocumentoEnvio2, false); 
        //Database.insert(listDocumentoEnvio2);  
		
        List<SAC_DocumentoEnvio__c> listDocumentoEnvio3 = SAC_TestDataFactory.crearDocumentoEnvio(1, casoReclamacion2);
        listDocumentoEnvio3[0].Name = 'TestDocumentoEnvioInadmision';
        listDocumentoEnvio3[0].SAC_Documento__c = null;
        listDocumentoEnvio3[0].SAC_TipoDocumento__c = 'inadmision - prestamo';
        SAC_DatabaseDML.insertListDML(listDocumentoEnvio3, false);
        //Database.insert(listDocumentoEnvio3); 
        
        List<SAC_MaestroTemas__c> listaMaestro = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_TipoAdjuntos');
        listaMaestro[0].SAC_DeveloperName__c = 'RESOLUCION';
        SAC_DatabaseDML.insertListDML(listaMaestro, false);
        //Database.insert(listaMaestro);

        ContentVersion cv = SAC_TestDataFactory.crearContentVersion(casoReclamacion2);
        cv.OwnerId = usuario.Id;
        SAC_DatabaseDML.insertDML(cv, false);
        //Database.insert(cv);
    }

    @isTest
    static void compruebaDocumentoRedaccionTest(){
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        SAC_DocumentoEnvio__c documento;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            documento = SAC_LCMP_GeneracionDocumento.compruebaDocumentoRedaccion(reclamacion.Id);
            Test.stopTest();
        }
        Assert.areNotEqual(documento.id, null, 'El método que comprueba si existen documentos de redaccion ha fallado.');
    }


    @isTest
    static void generarDocumentoRedaccionTest(){
        SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id  FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];

        SAC_DocumentoEnvio__c documentoEnvio2;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_GeneracionDocumento.generarDocumentoRedaccion(documentoEnvio.Id, false);
            SAC_LCMP_GeneracionDocumento.generarDocumentoRedaccion(documentoEnvio.Id, true);
            Test.stopTest();
            documentoEnvio2 = [SELECT Id, SAC_URL__c  FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];
        }

        Assert.areNotEqual(documentoEnvio2.SAC_URL__c, null, 'El método que genera el documento de redaccion ha fallado.');
    }

    @isTest
    static void getRutaTest(){
        String ruta;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        System.runAs(usuarioGeneral){
            Test.startTest();
            ruta = SAC_LCMP_GeneracionDocumento.getRuta();
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
            ruta = SAC_LCMP_GeneracionDocumento.getRutaVS();
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
            imagenInsertada = SAC_LCMP_GeneracionDocumento.insertarimagen(reclamacion.id, '<p><img></img></p>');
            Test.stopTest();
        }
        Assert.areNotEqual(imagenInsertada, null, 'La creación del registro que almacena la imagen ha fallado.');
    }
    @isTest
    static void generarDocumentoInadmision(){
        SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id, SAC_Caso__c FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];
        SAC_DocumentoEnvio__c documentoEnvio2;

        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_GeneracionDocumento.generarDocumentoInadmision(documentoEnvio.SAC_Caso__c);
            Test.stopTest();
            documentoEnvio2 = [SELECT Id, SAC_URL__c  FROM SAC_DocumentoEnvio__c WHERE Name = 'TestDocumentoEnvio' LIMIT 1];
        }

        System.assertEquals(documentoEnvio2 != null, true);
    }
    
    @isTest
    static void getHeaderAndFooterTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];

        Id parametro = [SELECT Id FROM Folder WHERE DeveloperName = 'PlantillasSAC' LIMIT 1].Id;
        Case reclamacion = [SELECT Id, RecordTypeId, SAC_Entidad_Afectada__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        String idReclamacion = reclamacion.Id; 
        SAC_LCMP_GeneracionDocumento.WrapperTemplate infoTemplate; 

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
            infoTemplate = SAC_LCMP_GeneracionDocumento.getHeaderAndFooterMTP('es', reclamacion.RecordTypeId, reclamacion.SAC_Entidad_Afectada__c);
            Assert.areNotEqual(null, infoTemplate, 'Ha fallado la obtención de datos de la plantilla');
            Test.stopTest();
        }
    }
}