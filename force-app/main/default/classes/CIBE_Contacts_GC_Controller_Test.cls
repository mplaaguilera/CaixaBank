@isTest
public class CIBE_Contacts_GC_Controller_Test {
	@TestSetup
    static void setup(){
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
		String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
		String rtAccountRelationEco = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
        String rtAccountGrupoComercial = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI,CIBE_AppConstants.CIBE_INTEGRACION};
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        
       Test.startTest();
        
        System.runAs(usrSetup){
             FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
                Name = 'Parent',
                FinServ__InverseRole__c = 'Child',
            	FinServ__CreateInverseRole__c = false,
                OwnerId = usuario.Id
             );
            insert role;
            Account acc = new Account(
                Name = 'Grupo Comercial',
                RecordtypeId = rtAccount,
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1), 
                OwnerId = usuario.Id
            );
            //insert acc;
    
    
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            
            Account accTest = new Account(
                Name = 'Name 2',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '1231',
                AV_Negocio__c = 'CIB',
                AV_Confidencial__c = false,
                OwnerId = usuario.Id
            );
            //insert accTest;
            
            Account accTest2 = new Account(
                Name = 'Name 2',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '1232',
                AV_Negocio__c = 'CIB',
                AV_Interlocutor__c = accTest.Id,
                AV_Confidencial__c = false,
                OwnerId = usuario.Id
            );
            //insert accTest2;
    
            Account accTest3 = new Account(
                Name = 'Name 3',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '1111',
                AV_Negocio__c = 'CIB',
                AV_Interlocutor__c = accTest.Id,
                AV_Confidencial__c = false,
                OwnerId = usuario.Id
            );
            //insert accTest3;
            insert new List<Account>{acc, accTest, accTest2, accTest3};
    
            Contact conTest = CIBE_TestHelper.createEmployeeSinInsert(accTest, usuario);
            conTest.recordtypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT).Id;
            conTest.ownerId = usuario.Id;
            Contact conTest2 = CIBE_TestHelper.createEmployeeSinInsert(accTest2, usuario);
            conTest2.recordtypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT).Id;
            conTest2.ownerId = usuario.Id;
            Contact conTest3 = CIBE_TestHelper.createEmployeeSinInsert(accTest3, usuario);
            conTest3.recordtypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT).Id;
            conTest3.lastname = 'contacto 3';
            conTest3.ownerId = usuario.Id;
                
            insert new List<Contact>{conTest, conTest2, conTest3};
                
            AccountContactRelation accCont = new AccountContactRelation(accountId = accTest.Id, contactId = conTest2.Id);
            AccountContactRelation accCont2 = new AccountContactRelation(accountId = accTest.Id, contactId = conTest3.Id);
            insert new List<AccountContactRelation>{accCont, accCont2}; 
            
            FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accTest.id,
                CIBE_Matriz__c = true,
                FinServ__Role__c = role.id,
                OwnerId = usuario.Id
            );
            FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accTest2.id,
                FinServ__Role__c = role.id,
                OwnerId = usuario.Id
            );
    
            FinServ__AccountAccountRelation__c accR6 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accTest3.id,
                FinServ__Role__c = role.id,
                OwnerId = usuario.Id
            );
            insert new List<FinServ__AccountAccountRelation__c> {accR, accR2, accR6};
            
            AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usuario, accTest);
            AccountTeamMember accTM2 = CIBE_TestHelper.createAccountTeamMember(usuario, accTest2);
            AccountTeamMember accTM3 = CIBE_TestHelper.createAccountTeamMember(usuario, accTest3);
        }
        Test.stopTest();
        
    }
            
    
	@isTest
	public static void getContactsGroupTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc =  [SELECT Id FROM Account  where recordtype.developername  = 'CIBE_GrupoComercial' LIMIT 1];
        List<CIBE_Contacts_GC_Controller.ContactWrapper> reponse ;
        System.runAs(usuario) {
            Test.startTest();
                reponse = CIBE_Contacts_GC_Controller.getContactsGroup(acc.Id, 10);
            Test.stopTest();
        }
        Assert.areNotEqual(reponse, null);
    }
    
    @isTest
	public static void createGroupAndContactTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
         Account acc =  [SELECT Id FROM Account  where recordtype.developername  = 'CIBE_GrupoComercial' LIMIT 1];
        Contact contactAux = new Contact(lastname = 'Contact Aux', email = 'aux@email.com', ownerId=usuario.Id);
        List<Contact> contactList = new List<Contact>{contactAux};
        System.runAs(usuario) {
            Test.startTest();
                CIBE_Contacts_GC_Controller.createGroupAndContact(acc.Id, contactList);
            Test.stopTest();
        }
        List<Contact> response = [Select id from contact];
        Assert.areNotEqual(response.size(), 0);
    }
    
    @isTest
	public static void createOnlyGroupTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc =  [SELECT Id FROM Account  where recordtype.developername  = 'CIBE_GrupoComercial' LIMIT 1];
        Contact con = [SELECT ID FROM CONTACT where lastname = 'contacto 3' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
                CIBE_Contacts_GC_Controller.createOnlyGroup(acc.Id, con.id);
            Test.stopTest();
        }
        List<Contact> response = [Select id from contact];
        Assert.areNotEqual(response.size(), 0);
    }
    
    @isTest
	public static void getMatrizTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc =  [SELECT Id FROM Account  where recordtype.developername  = 'CIBE_GrupoComercial' LIMIT 1];
        String response = '';
        System.runAs(usuario) {
            Test.startTest();
               	response = CIBE_Contacts_GC_Controller.getMatriz(acc.Id);
            Test.stopTest();
        }
        Assert.areNotEqual(response, '');
    }
    
    
    
    @isTest
	public static void deleteContactFromAccountTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc =  [SELECT Id FROM Account  where recordtype.developername  != 'CIBE_GrupoComercial' LIMIT 1];
        Contact con = [SELECT ID FROM CONTACT LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
                CIBE_Contacts_GC_Controller.deleteContactFromAccount(acc.Id, con.Id);
            Test.stopTest();
        }
        List<Contact> response = [Select id from contact];
        Assert.areNotEqual(response.size(), 0);
    }
    
    @isTest
	public static void showAddMemberButtonTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc =  [SELECT Id FROM Account  where recordtype.developername  = 'CIBE_GrupoComercial' LIMIT 1];
        Boolean response = false;
        System.runAs(usuario) {
            Test.startTest();
                response = CIBE_Contacts_GC_Controller.showAddMemberButton(acc.Id);
            Test.stopTest();
        }
        Assert.areNotEqual(response, false);
    }
    
    @isTest
	public static void deleteContactFromGroupTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc =  [SELECT Id FROM Account  where recordtype.developername  = 'CIBE_GrupoComercial' LIMIT 1];
        Contact con = [SELECT ID FROM CONTACT where lastname = 'contacto 3' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
                CIBE_Contacts_GC_Controller.deleteContactFromGroup(acc.Id, con.Id);
            Test.stopTest();
        }
        List<Contact> response = [Select id from contact];
        Assert.areNotEqual(response.size(), 0);
    }   
    
    @isTest
	public static void fillContactWrapperTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Contact con = [SELECT Id, Salutation, FirstName, LastName, accountId, account.name, 
                                                       CIBE_Cargo__c, email, phone, CC_Idioma__c, CIBE_Confidencial__c,
                                                       CIBE_ContactoinfoComercial__c, Description, Recordtype.developername FROM CONTACT LIMIT 1];
        CIBE_Contacts_GC_Controller.ContactWrapper response;
        System.runAs(usuario) {
            Test.startTest();
                
            	response = CIBE_Contacts_GC_Controller.fillContactWrapper(con);
            Test.stopTest();
        }
        Assert.areNotEqual(response, null);
    }   
        
        
}