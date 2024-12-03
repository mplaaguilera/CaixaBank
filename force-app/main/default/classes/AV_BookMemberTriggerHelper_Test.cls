/**********************************************************************************************************************
 Name:	  AV_BookMemberTriggerHelper_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US168560            Eric Vázquez		12/02/2021			Init version
    1.1		    AV_Query IT			Daniel Rodríguez	 3/02/2022			 Change AV_Query to SOQL for User, Account, Contact
	1.2         Fix	        		Daniel Rodríguez	10/03/2022          Fix Error, add custom setting AV_LimitBook
	1.3         Fix              	Vladislav Lityagin  08/03/2023          Fix Quality Clouds errors
    1.4         Fix                 Patricia Villacañas 03/05/2023          Modified to set run as, assertions and user creation

***********************************************************************************************************************/
@isTest
public with sharing class AV_BookMemberTriggerHelper_Test {
    
    @TestSetup
    static void setup(){
        
        System.RunAs (new User(Id = UserInfo.getUserId())){

            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
			userGestor.Email = 'gestor-test@test.com';
            User usrTest = AV_TestHelper.createUserSinInsert(null,'U0112345','AV_SistematicaComercial');

            List<User> userList = new List<User>();
            userList.add(userGestor);
            userList.add(usrTest);
            insert userList;
        }
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];

        System.runAs(userCli){
            User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
            
            Account accTest = AV_TestHelper.createCustomerSinInsert();

            List<Account> accList = new List<Account>();
            accList.add(accTest);
            insert accList;
            
        }

        System.runAs(userGcf){
            Account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];

            User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];

            User usrTest = AV_TestHelper.createUserSinInsert(null,'U0112345','AV_SistematicaComercial');
            User usrTest2 = AV_TestHelper.createUserSinInsert(null,'U01123456','AV_SistematicaComercial');
            Account cenTest = AV_TestHelper.createCaixaCenter();

            List<Contact> contactList = new List<Contact>();
            Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, usrTest);
            Contact conTest2 = AV_TestHelper.createEmployeeSinInsert(cenTest, usrTest2);
            conTest2.FirstName = 'Empleado2';
            contactList.add(conTest);
            contactList.add(conTest2);
            insert contactList;
            String externalId = '50071';
            AV_Book__c purseTest = AV_TestHelper.createPurse(externalId);
            AV_BookMember__c bookMemberTest = AV_TestHelper.createBookMember(accTest, purseTest);
            AV_BookManagementMember__c bookAssigmentTest = AV_TestHelper.createBookManagement(conTest, purseTest);
        }
    }

    

    @isTest
    private static void updateOwnerIdFromClientTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
       
        Test.startTest();
            System.runAs(userGcf){
                Account client = [SELECT Id, Name, AV_EAPGestor__c FROM Account WHERE FirstName = 'FirstName' LIMIT 1];
                //Account client2 = [SELECT Id, Name, AV_EAPGestor__c FROM Account WHERE FirstName = 'FirstName2' LIMIT 1];
                //User user2 = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U01123456' LIMIT 1];
                Contact contact = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado2' LIMIT 1];
                List<AV_Book__c> listBooks = [Select Id, Name From AV_Book__c limit 1];
        
                AV_BookMember__c bookMember = [SELECT Id, Name, AV_Cliente__c FROM AV_BookMember__c LIMIT 1];
                //bookMember.AV_Cliente__c = client2.Id;
        
                AV_BookManagementMember__c bkManagement = [Select Id, Name, AV_EmpleadoGestor__c From AV_BookManagementMember__c limit 1];
                bkManagement.AV_EmpleadoGestor__c = contact.Id;
                update bkManagement;
                
                update bookMember;
            
                Test.stopTest();

                AV_BookManagementMember__c bkManagementNew = [Select Id, Name, AV_EmpleadoGestor__c From AV_BookManagementMember__c limit 1];
                Account clientNew = [SELECT Id, Name, AV_EAPGestor__c FROM Account WHERE FirstName = 'FirstName' LIMIT 1];
                System.assertEquals(bkManagement.AV_EmpleadoGestor__c, clientNew.AV_EAPGestor__c);
            }
    }
}