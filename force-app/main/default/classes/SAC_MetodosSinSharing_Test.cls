/*****************************************************************
 * Name: SAC_MetodosSinSharing_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase test de SAC_MetodosSinSharing
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US749927         Alexandre Pérez   24/01/24     Creación
*****************************************************************/
@isTest
public class SAC_MetodosSinSharing_Test {
    
    @TestSetup
    static void makeData(){
    	User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdmin);

        system.runAs(usuarioAdmin){
            Database.insert(permiSetAssi);
            
        }
    }
    
    
	@isTest
    static void testInsert(){
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        //testeamos un confidencial
        list<account> listacc = new list<account>();
        list<sobject> objRes = new list<sobject>();
        
        account acc1 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            firstName='confidencial',
            lastName='Test',
            recordTypeId = clientePArt
        );
        objRes.add((sobject)acc1);
        account acc2 = new account(
            CC_Numero_Documento__c='37548392L',
            AV_NumPerso__c = '123456',
            firstName='confidencial',
            recordTypeId = clientePArt
        );
        objRes.add((sobject)acc2);
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        
        system.runAs(sacUser){
            test.startTest();
        	SAC_MetodosSinSharing.modificarInsertarObjetos(objRes, 'insert');
            test.stopTest();
        }
        //insert acc2; 
        system.assertEquals(1, [SELECT ID FROM ACCOUNT].size());  
    }
    
    @isTest
    static void testUpdate(){
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        //testeamos un confidencial
        list<account> listacc = new list<account>();
        list<sobject> objRes = new list<sobject>();
        
        account acc1 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            lastName='Test',
            recordTypeId = clientePArt
        );
        listacc.add(acc1);
        objRes.add((sobject)acc1);
        account acc2 = new account(
            CC_Numero_Documento__c='37548392L',
            AV_NumPerso__c = '123456',
            lastName='Test2',
            recordTypeId = clientePArt
        );
        listacc.add(acc2);
        objRes.add((sobject)acc2);
        insert listacc;
        acc1.firstname = 'OK';
        acc2.firstName = 'OK';
        acc2.lastName = null;
        
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        
         system.runAs(sacUser){
            test.startTest();
        	SAC_MetodosSinSharing.modificarInsertarObjetos(objRes, 'update');
         }
        //insert acc2;
        system.assertEquals(1, [SELECT ID FROM ACCOUNT where firstName = 'OK'].size());
    }
    
    @isTest
    static void testquery(){
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        account acc1 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            lastName='Test',
            recordTypeId = clientePArt
        );
        insert acc1;
        set<string> acc = new set<string>{'37548393L'};
            
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        list<account> listAcc = new list<Account>();
        system.runAs(sacUser){
            test.startTest();
        	listAcc = SAC_MetodosSinSharing.listaDeClientesPorDoc(acc);
            test.stopTest();
        }
        system.assertEquals(1, listAcc.size());
        
    }

    @isTest
    static void comprobarCaseReclamanteTrue() {
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        Map<String, Object> camposRecl = new Map<String, Object>();
        boolean resultado;
        account acc1 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            lastName='Test',
            recordTypeId = clientePArt
        );
        Database.insert(acc1);
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        //camposRecl.put('ownerId', colaIA.Id);
        camposRecl.put('SAC_GenialEstado__c', 'SAC_001');
        camposRecl.put('Origin', 'Email');
        camposRecl.put('AccountId', acc1.Id);
        //para error en Class.SAC_Utils.comprobarEmailsBlackListAuto
        camposRecl.put('SuppliedEmail', 'test07032024931@test1.com.invalid');
 
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);
        
        system.runAs(sacUser){
            resultado = SAC_MetodosSinSharing.comprobarCaseReclamante(reclamacion.Id);
        }
        system.assert(resultado, 'debería devolver que tiene al menos 1 registro en el case reclamante');

    }
}