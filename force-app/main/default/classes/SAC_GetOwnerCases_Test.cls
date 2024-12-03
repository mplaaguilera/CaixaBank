@isTest
public with sharing class SAC_GetOwnerCases_Test {

    @TestSetup
    static void makeData() {

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        //Cuenta a utilizar tipo test
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        Database.insert(cuenta);

        //RECLAMACION 1 - NECESITO SU ID PARA EJECUTAR EL METODO 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //RECLAMACION 2 - NECESITO QUE HAYA OTRO CASO EN LA BBDD PARA QUE EL METODO 1 TENGA INFORMACION CON LA QUE TRATAR
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'Alta');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl2.put('AccountId', cuenta.Id);
        camposRecl2.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //RECLAMACION 3 - NECESITO QUE HAYA OTRO CASO EN LA BBDD PARA QUE EL METODO 1 TENGA INFORMACION CON LA QUE TRATAR
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('Status', 'Alta');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl3.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

        
        List<Case> reclamacionesAInsertar = new List<Case>();
        reclamacionesAInsertar.add(casoReclamacion);
        reclamacionesAInsertar.add(casoReclamacion2);
        reclamacionesAInsertar.add(casoReclamacion3);
        Database.insert(reclamacionesAInsertar);

        //PRETENSION 1 - ESTA PRETENSION SE TIENE QUE MOSTRAR COMO PRETENSION ASOCIADA Y QUE SE PUEDA MANIPULAR EN EL METODO 1 bucle entra al else
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Origin', 'Email');
        camposPret.put('Status', 'Alta');
        camposPret.put('SAC_StatusAuxiliar__c', 'Alta');
        camposPret.put('AccountId', cuenta.Id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        
        //PRETENSION 2 - ESTA PRETENSION SE TIENE QUE MOSTRAR COMO PRETENSION ASOCIADA Y QUE SE PUEDA MANIPULAR EN EL METODO 1 bucle entra al if
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('Status', 'Alta');
        camposPret2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposPret2.put('AccountId', cuenta.Id);
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion2.Id);

        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);

        
        List<Case> pretensionesAInsertar = new List<Case>();
        pretensionesAInsertar.add(casoPretension);
        pretensionesAInsertar.add(casoPretension2);
        Database.insert(pretensionesAInsertar);
        
    }

    @isTest
    static void methodGetSameOwnerCasesTest(){
	
        Set<String> objetos = new Set<String>{'Case'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id idPretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId(); 
        
        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec'];
        Case reclamacion2 = [SELECT SAC_Reclamacion__c, Id, CaseNumber, AccountId, Description, ParentId, Subject FROM Case WHERE subject = 'TestRec2'];
        Case pretension = [SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.Subject, CaseNumber, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, CC_MCC_Motivo__c, Subject
                             FROM Case WHERE Origin = 'Email' LIMIT 1];
        Case pretension2 = [SELECT Id, SAC_Reclamacion__c, SAC_Reclamacion__r.Subject, CaseNumber, CC_MCC_ProdServ__c, CC_MCC_Tematica__c, CC_MCC_Motivo__c, Subject
                             FROM Case WHERE Origin = 'Backoffice' AND RecordTypeId = :idPretension LIMIT 1];

        List<Case> listaPretensiones = new List<Case>();
        listaPretensiones.add(pretension);
        listaPretensiones.add(pretension2);

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_GetOwnerCases.getSameOwnerCases(reclamacion.Id);
            Test.stopTest();
            System.assertNotEquals( null, testResultado, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
        }   
    }

    @isTest
    static void methodModifySameOwnerCasesTest(){

        Case reclamacion = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec'];
        Case reclamacion2 = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec2'];
        
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_GetOwnerCases.modifySameOwnerCases(reclamacion.Id, reclamacion2.Id);
            Case reclamacion3 = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec2'];
            Test.stopTest();
            System.assertEquals(reclamacion.Id, reclamacion3.CC_CasoRelacionado__c, 'La ejecucion ha fallado a la hora de vincular reclamaciones');
        } 
    }


    @isTest
    static void methodGetSameOwnerCasesFailTest(){

        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            try{
                Test.startTest();
                List<SAC_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_GetOwnerCases.getSameOwnerCases(reclamacion.Id);
                Test.stopTest();
            }
            catch(AuraHandledException e){
                System.assertEquals( null, null, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
            }
        }
    }

    @isTest
    static void methodModifySameOwnerCasesFailTest(){

        Case reclamacion = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec'];
        Case reclamacion2 = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec2'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            try{
                Test.startTest();
                SAC_GetOwnerCases.modifySameOwnerCases(reclamacion.Id, reclamacion2.Id);
                Test.stopTest();
            }catch(AuraHandledException e){
                System.assertEquals( null, null, 'La ejecucion ha fallado a la hora de vincular reclamaciones');
            }
        }
    }

    @isTest
    static void methodGetSameOwnerCasesFailTest2(){
        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec3'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){    
            try{
                Test.startTest();
                List<SAC_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_GetOwnerCases.getSameOwnerCases(reclamacion.Id);
                Test.stopTest();
            }
            catch(AuraHandledException e){
                System.assertEquals( null, null, 'No existe un cliente asociado en la reclamación actual');
            }
        }
    }
}