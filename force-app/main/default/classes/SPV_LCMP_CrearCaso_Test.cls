@isTest
public with sharing class SPV_LCMP_CrearCaso_Test {
    
    @TestSetup
    static void makeData(){
    
        Test.startTest();

        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        List<User> listUsuarios;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
            Database.insert(listUsuarios);
        }

        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion3 = new Map<String, Object>();
        camposReclamacion3.put('Subject', 'TestRecCrearRec3');
        camposReclamacion3.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion3.put('Status', 'SAC_002');
        camposReclamacion3.put('SEG_Subestado__c', 'Negociacion');
        camposReclamacion3.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion3.put('SPV_NumExpediente__c', 'EXP2610TEST');
        camposReclamacion3.put('SAC_Entidad_Afectada__c', 'SAC_002');

        Case casoReclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion3);
        listaReclamaciones.add(casoReclamacion3);
        Database.insert(listaReclamaciones);
    }

    @isTest
    static void comprobarExpDuplicadoTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        String caseNumberStr = '';

        Test.startTest();
        System.runAs(usuario){
            caseNumberStr = SPV_LCMP_CrearCaso.comprobarExpDuplicado('EXP2610TEST', 'SAC_002');
        }

        Assert.areNotEqual('', caseNumberStr, 'Se ha detectado expediente duplicado');

        Test.stopTest();
    }
}