@isTest
public with sharing class SAC_LCMP_PretensionesRelacionTest {
    @TestSetup
    static void makeData(){
    User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
    usuario.Username = 'ustestesteo@test.com';      
    


    Database.insert(usuario);

     //RECLAMACION 1
     Map<String, Object> camposRecl = new Map<String, Object>();
     camposRecl.put('Subject', 'TestRec');
     camposRecl.put('Origin', 'Backoffice');
     camposRecl.put('Status', 'Alta');
     camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
     camposRecl.put('OwnerId', usuario.Id);
     
     Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
     Database.insert(casoReclamacion);

     //PRETENSION 1
     Map<String, Object> camposPrete = new Map<String, Object>();
     camposPrete.put('SuppliedCompany', 'TestPrete');
     camposPrete.put('SAC_Reclamacion__c', casoReclamacion.Id);
     camposPrete.put('SAC_ValidacionMCC__c', false);


     Case casoPrete = SAC_TestDataFactory.crearCaso('Pretension', camposPrete);
     Database.insert(casoPrete);

    }

    @isTest
    static void getPretensiones_Test(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'TestRec' limit 1];
        List<Case> result = new List<Case>();


        System.RunAs(usuario){
          result = SAC_LCMP_PretensionesRelacionController.getPretensiones(caso.id);
        }
        Test.stopTest();
        Assert.areNotEqual(null, result, 'No se ha podido cargar la lista');


    }
    @isTest 
    static void validarPretension_Test(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case prete = [SELECT id, SAC_Reclamacion__c, SAC_ValidacionMCC__c FROM Case WHERE SuppliedCompany = 'TestPrete' limit 1];


        System.RunAs(usuario){
        SAC_LCMP_PretensionesRelacionController.validarPretension(prete.id, true);
        SAC_LCMP_PretensionesRelacionController.validarPretension(prete.id, false);

        }
        Test.stopTest();

        Case result = [SELECT id FROM Case WHERE SuppliedCompany = 'TestPrete' limit 1];
        Assert.areNotEqual(null, result, 'No se ha podido cargar la lista');

    }


}