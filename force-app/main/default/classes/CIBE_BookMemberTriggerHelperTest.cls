/**********************************************************************************************************************
Name:	  CIBE_BookMemberTriggerHelper
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_BookMemberTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Jose Maria			14/10/2022		Init version
1.1                         Bea                 27/01/2023      Test setBookCenter 
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public class CIBE_BookMemberTriggerHelperTest {
    
    @isTest
    public static void  checkTriggerData(){
       List<String> listPermissionsSet = new List <String> {CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User userLog = CIBE_TestHelper.loginUser(null,null,null,listPermissionsSet);
        ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        System.runAs(new User(Id = UserInfo.getUserId())){

            Account centroCaixa = new Account();
            centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
            centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
            centroCaixa.CC_Numero_Oficina__c = '00615';
            centroCaixa.RecordTypeId = recordTypeCentro;
            centroCaixa.OwnerId = userLog.Id;         
            insert centroCaixa;
        }

        User usrTest = [SELECT Id FROM User WHERE Alias = 'tsAlias' AND Profile.Name = 'CIBE_Gestor' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())){

            Account centroCaixa2 = [Select id from Account WHERE CC_Numero_Oficina__c = '00615' AND RecordType.DeveloperName ='CC_CentroCaixaBank' LIMIT 1];
            Contact conTest = CIBE_TestHelper.createEmployee(centroCaixa2, usrTest);
        Account accTest = CIBE_TestHelper.createCustomer(usrTest);

        Test.startTest();

        AV_Book__c purseTest = CIBE_TestHelper.createPurse('50071');
        purseTest.AV_Negocio__c = 'CIB';
        update purseTest;
        
            Assert.isTrue(purseTest != null);

            AV_BookManagementMember__c bookAssigmentTest = CIBE_TestHelper.createBookManagement(conTest, purseTest);
            Assert.isTrue(bookAssigmentTest != null);

            AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(accTest, purseTest);
            Assert.isTrue(bookMemberTest != null);
            Assert.isFalse([SELECT Id FROM AccountTeamMember WHERE AccountId = :accTest.Id].isEmpty());
            bookMemberTest.AV_ToDelete__c = true;
            update bookMemberTest;

            Assert.isTrue([SELECT Id FROM AccountTeamMember WHERE AccountId = :accTest.Id].isEmpty());

            Test.stopTest();
        }
    
	}

    @isTest
    public static void setBookCenterTest(){

        List<String> listPermissionsSet = new List <String> {CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User userLog = CIBE_TestHelper.loginUser(null,null,null,listPermissionsSet);
        ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        System.runAs(new User(Id = UserInfo.getUserId())){

            Account centroCaixa = new Account();
            centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
            centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
            centroCaixa.CC_Numero_Oficina__c = '00615';
            centroCaixa.RecordTypeId = recordTypeCentro;
            centroCaixa.OwnerId = userLog.Id;         
            insert centroCaixa;
        }

        User usrTest = [SELECT Id FROM User WHERE Alias = 'tsAlias' AND Profile.Name = 'CIBE_Gestor' LIMIT 1];
            
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            Account centroCaixa2 = [Select id from Account WHERE CC_Numero_Oficina__c = '00615' AND RecordType.DeveloperName ='CC_CentroCaixaBank' LIMIT 1];
            Contact conTest = CIBE_TestHelper.createEmployee(centroCaixa2, usrTest);
            Account accTest = CIBE_TestHelper.createCustomer(usrTest);
            
            Test.startTest();

            AV_Book__c purseTest = CIBE_TestHelper.createPurse('50071');
            purseTest.AV_Negocio__c = 'CIB';
            purseTest.AV_Centro__c = centroCaixa2.Id;
            update purseTest;
        Assert.isTrue(purseTest != null);

        AV_BookManagementMember__c bookAssigmentTest = CIBE_TestHelper.createBookManagement(conTest, purseTest);
        Assert.isTrue(bookAssigmentTest != null);
       
        AV_BookMember__c bookMemberTest = CIBE_TestHelper.createBookMember(accTest, purseTest);
        Assert.isTrue(bookMemberTest != null);
        
            Account client = [SELECT Id, CIBE_BookCenter__c FROM Account WHERE Id = :accTest.Id LIMIT 1];
            Assert.isNotNull(client.CIBE_BookCenter__c);

        Test.stopTest();
    }
    }
    
}