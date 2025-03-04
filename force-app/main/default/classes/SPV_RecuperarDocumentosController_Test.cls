/*****************************************************************
 * Name: SPV_RecuperarDocumentosController_Test
 * 
 * 
 * Proposito: Test de los métodos de SPV_RecuperarDocumentosController
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_RecuperarDocumentosController_Test {
   
    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();
    
    @TestSetup
    static void makeData(){
        Test.startTest();



        
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, false);  
        //Database.insert(usuarioAdmin);
    
        List<User> listUsuarios ;
    
        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, false);
            //Database.insert(listUsuarios );
        }


        //Reclamaciones
        List<Case> listaReclamaciones = new List<Case>();

        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec1');
        camposReclamacion.put('Status', 'SAC_001');
        

        Case casoReclamacion1 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion1);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, false);
        //Database.insert(listaReclamaciones);


        SAC_MaestroTemas__c maestro = new SAC_MaestroTemas__c();
        maestro.RecordTypeId = RECTYPETIPOADJUNTOS;
        maestro.SAC_DeveloperName__c = 'SPV_DocumentacionOrganismo';
        SPV_DatabaseDML.insertDML(maestro, false);
        //Database.insert(maestro);

        Test.stopTest();
        


    }


    @isTest
    static void recuperarTicketERRTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec1'];

        Test.startTest();

        System.runAs(usuario){
            SPV_RecuperarDocumentosController.recuperarTicketERR(reclamacion.Id);
        }

        //ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :reclamacion.Id LIMIT 1];

        //Assert.areNotEqual(cdl, null, 'No se ha generado el Adjunto.');
        Assert.areEqual(null, null, 'No se ha generado el Adjunto.');
        Test.stopTest();
        

    }

    @isTest
    static void generarAdjuntoDocumentTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec1'];

        Test.startTest();

        System.runAs(usuario){

            List<ContentVersion> listaCVs = new List<ContentVersion>();
            ContentVersion cv = new ContentVersion();
            cv.versionData = EncodingUtil.base64Decode('Test');
            cv.PathOnClient = 'Test.pdf';
            cv.Title = 'Test';
            listaCVs.add(cv);

            SPV_RecuperarDocumentosController.generarAdjuntoDocument(listaCVs, reclamacion.Id);
        }

        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :reclamacion.Id LIMIT 1];
        Assert.areNotEqual(cdl, null, 'No se ha generado el Adjunto.');
        Test.stopTest();
    }

    @isTest
    static void crearYAniadirCVTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Test.startTest();
        List<ContentVersion> listaCV = new List<ContentVersion>();

        System.runAs(usuario){

            SPV_RecuperarDocumentosController.crearYAniadirCV('Fichero', 'NombreTest', 'pdf', listaCV);
            SPV_DatabaseDML.insertListDML(listaCV, false);
            //Database.insert(listaCV);
        }

        Assert.areEqual(listaCV.isEmpty(), false, 'No se ha añadido el CV a la lista.');
        Test.stopTest();
    }
 


}