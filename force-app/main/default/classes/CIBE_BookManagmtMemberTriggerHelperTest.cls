/**********************************************************************************************************************
Name:	  CIBE_BookManagementMemberTriggerHelper
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_BookManagementMemberTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Jose Maria			14/10/2022		Init version

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public class CIBE_BookManagmtMemberTriggerHelperTest {
    
     @TestSetup
	static void setup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
    }
    
    @isTest
    public static void  getAllRTTest(){
        System.runAs(new User(Id = UserInfo.getUserId())){
            Set<Id> listId = CIBE_BookManagementMemberTriggerHelper.getAllRT();
            System.assert(!listId.isEmpty());
        }
    }
    
    @isTest
    public static void  checkGeneralRTTest() {
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
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centroCaixa2 = [Select id from Account WHERE CC_Numero_Oficina__c = '00615' AND RecordType.DeveloperName ='CC_CentroCaixaBank' LIMIT 1];
            Contact conTest = CIBE_TestHelper.createEmployee(centroCaixa2, usrTest);   
            
            Test.startTest();
            AV_Book__c purseTest = CIBE_TestHelper.createPurse('50071');
            purseTest.AV_Negocio__c = 'CIB';
            purseTest.AV_Centro__c = centroCaixa2.Id;
            update purseTest;
            Assert.isTrue(purseTest != null);
            
            List<AV_BookManagementMember__c> listValues = new List<AV_BookManagementMember__c>();
            AV_BookManagementMember__c bookAssigmentTest = CIBE_TestHelper.createBookManagement(conTest, purseTest);
            
            Assert.isTrue(bookAssigmentTest != null);
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void  updateOwnerIdFromClientTest() {
    	User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true limit 1];
        
        Account center = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00001'];
        Contact employee = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U0000001'];
        User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name = :CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
            UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = :CIBE_AppConstants.CIBE_CIBEMPRESAS LIMIT 1];
            User user = new User(
                ProfileId = p.Id,
                UserRoleId = ur.Id,
                UserName = 'U0000002' + '@test.dev',
                LastName = 'U0000002' + '_LastName',
                Alias = 'U0000002'.abbreviate(8),
                Email = 'U0000002' + '@test.dev',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '001-' + '00001',
                AV_ExternalID__c = 'U0000002'
            );
            insert user;
        }
        
        User user2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000002'];
        RecordType rtEmployee = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
        Contact gestor2 = new Contact();
        gestor2.RecordTypeId = rtEmployee.Id;
        gestor2.AccountId = center.Id;
        gestor2.AV_UsuarioAsociado__c = user2.Id;
        gestor2.FirstName = 'Employee 2';
        gestor2.LastName = 'U0000002';
        gestor2.Email = 'U0000002' + '@test.dev';
        gestor2.CC_Idioma__c = 'es';
        gestor2.CC_Matricula__c = 'U0000002';
        gestor2.OwnerId = userCli.Id;
        insert gestor2;
        
        Contact employee2 = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U0000002'];
        
        System.runAs(userCli) {
            Account customer = CIBE_TestHelper.createCustomerWithEAPGestor(employee);
            
            AV_Book__c book = new AV_Book__c();
            book.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA, CIBE_AppConstants.CARTERA).Id;
            book.AV_ExternalID__c = '000CIB000';
            book.AV_Centro__c = center.Id;
            book.AV_Negocio__c = 'CIB';
            book.AV_Activa__c = 'S';
            insert book;
            
            AV_BookMember__c bookMember = new AV_BookMember__c();
            bookMember.AV_ExternalID__c = '0000278108701423CIB008';
            bookMember.AV_Activa__c = 'S';
            bookMember.AV_Cartera__c = book.Id;
            bookMember.AV_Cliente__c = customer.Id;
            bookMember.AV_CarteraPrincipal__c = true;
            insert bookMember;
                        
            Test.startTest();
            AV_BookManagementMember__c bookMgmtMember = new AV_BookManagementMember__c();
            bookMgmtMember.AV_ExternalID__c = '00379CIB003';
            bookMgmtMember.AV_Cartera__c = book.Id;
            bookMgmtMember.AV_EmpleadoGestor__c = employee.Id;
            insert bookMgmtMember;
            
            bookMgmtMember.AV_EmpleadoGestor__c = gestor2.Id;
            update bookMgmtMember;
            Assert.isTrue(bookMgmtMember != null);
            Test.stopTest();
        }        
        
    }
}