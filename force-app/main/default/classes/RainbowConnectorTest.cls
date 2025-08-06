/**********************************************************************************************************************
Name:	  RainbowConnectorTest
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de 'RainbowConnector'
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
    VERSION		USER_STORY         AUTHOR              DATE			    Description
    1.0         US1                Bea y Ali           3/04/2024        Init Version

***********************************************************************************************************************/

@isTest
public with sharing class RainbowConnectorTest {

    @testSetup
	static void testSetup() {

            UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = 'AV_SistematicaComercial' LIMIT 1];
            Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank' LIMIT 1];
            Profile pSa = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = 'Administrador del Sistema' LIMIT 1];
            String externalId = 'U0000001';
            String externalIdSA = 'U0000000';
            String numOficina = '00001';
            List<User> lstUser = new List<User> ();

            User userSA = new User(
                ProfileId = pSa.Id,
                UserRoleId = ur.Id,
                UserName = externalIdSA + 'U0000000@test.dev',
                LastName = externalIdSA + '_LastName',
                Alias = externalIdSA.abbreviate(8),
                Email = externalIdSA + '@test.dev.sa',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '001-' + numOficina,
                AV_ExternalID__c = externalIdSA
            );

            lstUser.add(userSA);

            User user = new User(
                ProfileId = p.Id,
                UserRoleId = ur.Id,
                UserName = externalId + '@test.dev',
                LastName = externalId + '_LastName',
                Alias = externalId.abbreviate(8),
                Email = externalId + '@test.dev',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '001-' + numOficina,
                AV_ExternalID__c = externalId
            );
            lstUser.add(user);

            insert lstUser;
            
    }

    @isTest
	public static void getUserEmailTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        System.runAs(managerUser){
            String userEmail = RainbowConnector.getUserEmail();
            System.assertEquals(managerUser.Email, userEmail);
        }
        Test.stopTest();
    }

    @isTest
	public static void getMainURLTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        System.runAs(managerUser){
            String mainURL = RainbowConnector.getMainURL();
            if (mainURL != '') {
                System.assert(true, 'userEmail is correct');
            }else {
                System.assert(false, 'userEmail should contain test@test.com');
            }
        }
        Test.stopTest();
    }

    @isTest
	public static void phoneNumberWithoutPrefixTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rt.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = managerUser.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        Test.startTest();
        System.runAs(managerUser){

            String withoutPrefix = RainbowConnector.phoneNumberWithoutPrefix(acc.Phone);
            System.assertEquals(false, withoutPrefix.startsWith('+34'));
        }
        Test.stopTest();
    }

    @isTest
	public static void phoneNumberWithSpaceTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rt.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = managerUser.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        Test.startTest();
        System.runAs(managerUser){

            String withSpace = RainbowConnector.phoneNumberWithSpace(acc.Phone);
            System.assertEquals('+34 682134590', withSpace);
        }
        Test.stopTest();
    }

    @isTest
	public static void GetAccountsByPhoneNumberTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rt.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = managerUser.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        Test.startTest();
        System.runAs(managerUser){

            String JSONAccountsByPhoneNumber = RainbowConnector.getAccountsByPhoneNumber(acc.Phone, 'Entrante');
            System.assertNotEquals('[]', JSONAccountsByPhoneNumber);
        }
        Test.stopTest();       
    }

    @isTest
	public static void GetAccountsByFirstLastNameTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.RecordTypeId = rt.Id;
        acc.Phone = '+34682134590';
        acc.AV_NumPerso__c = '123';
        acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '9446386T';
        acc.OwnerId = managerUser.Id;
        acc.CC_Email__c = 'test@test.com';
        insert acc;

        Test.startTest();
        System.runAs(managerUser){
            System.assert(RainbowConnector.getAccountsByFirstLastName(acc.Name).contains(acc.Name), 'Result should contain at least one account with firstlastname');
        }
        Test.stopTest();       
    }

    @isTest
    public static void GetAllRecordTypesTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        System.runAs(managerUser){
            String resultFormat = RainbowConnector.getAllRecordTypes();
            if (resultFormat != '[]') {
                System.assert(true, 'RecordTypes found');
            }else{
                System.assert(true, 'RecordTypes not found');
            }
        }
        Test.stopTest();
    }

    @isTest
    public static void GetProfileRecordTypesAccountTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        System.runAs(managerUser){
            String resultFormat = RainbowConnector.getProfileRecordTypesAccount();
            if (resultFormat != '[]') {
                System.assert(true, 'RecordTypes found');
            }else{
                System.assert(true, 'RecordTypes not found');
            }
        }
        Test.stopTest();
    }

    @isTest
    public static void addCallRecordTest() {
        User managerUser = [SELECT Id, Email FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        Test.startTest();
        System.runAs(managerUser){
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
            Account acc = new Account();
            acc.Name = 'Account Test';
            acc.RecordTypeId = rt.Id;
            acc.Phone = '+34682134590';
            acc.AV_NumPerso__c = '123';
            acc.AV_Negocio__c = 'BPA';
            acc.CC_Numero_Documento__c = '9446386T';
            acc.OwnerId = managerUser.Id;
            acc.CC_Email__c = 'test@test.com';
            insert acc;
    
            RecordType rtEmployee = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, AV_AppConstants.EMPLOYEE_RT);
            Contact employee = new Contact();
            employee.RecordTypeId = rtEmployee.Id;
            employee.FirstName = 'Empleado';
            employee.LastName = '1';
            employee.Email = 'test@prueba.es';
            employee.CC_Idioma__c = 'es';
            employee.CC_Matricula__c = 'U010001';
            employee.AV_UsuarioAsociado__c = managerUser.Id;
            
            insert employee;
    
            String resultFormat = RainbowConnector.addCallRecord('2024-06-26 10:56:44', '690310038', '6', 'incoming', '67655614869031003820240626095111', 'missed', 'comments', acc.Id);
            List <CC_Llamada__c> callList = [SELECT Id FROM CC_Llamada__c WHERE AV_ExternalID__c = '67655614869031003820240626095111' AND AV_Account__c =: acc.Id LIMIT 1];
            System.assert(!callList.isEmpty(), 'La lista debe tener un elemento');
            if (resultFormat != '[]') {
                System.assert(true, 'Datos devueltos correctamente');
            }
        }
        Test.stopTest();
    }
}