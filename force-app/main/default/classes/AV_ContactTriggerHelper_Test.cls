/**********************************************************************************************************************
 Name:	  AV_ContactTriggerHelper_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de los Triggers de Contact.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US208429        Víctor Santiago		29/04/2021			Init version
    1.1			AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User, Account, Contact
    1.2			FIX				Patricia Villacañas	24/05/2023			Modified to set run as
    1.2			US586011		Luis Fernández  	07/06/2023			Added 'BPR' AV_Rol__c to contact test in order to give covertry to processBPRRol method
    1.3			US590740		Lucía Muñoz     	13/06/2023			New methods updateContactMatriculaInvalidTest, updateContactMatriculaInvalidTestUsuarioAsociado
    1.4         PPM100492394    Ángel Medina        17/09/2024          New methods employeeExistsTest and isPoolContactTest
***********************************************************************************************************************/
@isTest
public class AV_ContactTriggerHelper_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
            AV_TestHelper.activateLogger();
            Account centro = AV_TestHelper.createCaixaCenter();
            User u = AV_TestHelper.createUser('Standard User');
            Contact c = AV_TestHelper.createEmployee(centro, u);
            c.CC_Matricula__c = 'U01XYZ01';
            c.AV_JobLevels__c = '100';
            c.AV_Rol__c = 'BPR';
            Database.update(c);

            User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
            u1.AV_ExternalID__c = 'U01XYZ01';
            Database.update(u1);
        }
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_JOBLEVEL','OK'));
    }

    @isTest
    public static void updateUserFuncionTest() {
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];

        Account centroEmpl = [Select Id, AV_TipoCentro__c From Account Where Name = '00615 STORE DOS DE MAIG-ROSSELLO' limit 1];
        List<Contact> listNewObj= [Select Id, AV_JobLevels__c, AV_TipoCentro__c, RecordTypeId, AV_UsuarioAsociado__c, AccountId, AV_DescFuncion__c,AV_EmpleadoIntouch__C, AV_TipoGestor__c, CIBE_Manager__c,AV_CodFuncion__c From Contact Where CC_Matricula__c = 'U01XYZ01'];
        Map<Id, Contact> mapOldObj = new Map<Id, Contact> {
            listNewObj.get(0).Id => listNewObj.get(0)
        };
        
        Contact updated = listNewObj.get(0);
        updated.AV_JobLevels__c = '120';
        listNewObj.set(0, updated);

        Test.startTest();
        System.runAs(userCli){
            AV_ContactTriggerHelper.updateUserFuncion(listNewObj, mapOldObj);
        }
       
        Test.stopTest();
        User updatedUser  = [Select Id, AV_Funcion__c From User Where AV_ExternalID__c = 'U0009003' AND Email = 'test@test.dev'];
        System.assertEquals(true, 'SSCC'.equals(updatedUser.AV_Funcion__c), 'AV_Funcion__c not updated');
    }

    @isTest
    public static void updateContactMatriculaInvalidTest(){
        User usuario = [SELECT Id FROM User WHERE UserName LIKE 'gcf-integration@cc-caixabank.com%'];
        RecordType rtContact = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
        Test.startTest();
        Contact employee = new Contact();
            employee.RecordTypeId = rtContact.Id;
            employee.FirstName = 'Empleado Test';
            employee.LastName = '1';
            employee.CC_Idioma__c = 'es';
            employee.CC_Inactivo__c = false;
            employee.CC_Matricula__c = 'U01234_Invalid';
        insert employee;

        System.runAs(usuario){
            Contact c = [SELECT Id, LastName, CC_Inactivo__c FROM Contact WHERE FirstName = 'Empleado Test' AND LastName = '1'];
            c.LastName = '12';
            update c;
            Test.stopTest();
            System.assertEquals(true, c.CC_Inactivo__c);
        }
    }

    @isTest
    public static void updateContactMatriculaInvalidTestUsuarioAsociado(){
        User usuario = [SELECT Id FROM User WHERE UserName LIKE 'gcf-integration@cc-caixabank.com%'];
        RecordType rtContact = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
        Test.startTest();
        User userTest = CIBE_TestHelper.createUser('CIBE_Gestor');

        System.runAs(usuario){
            Contact employee = new Contact();
            employee.RecordTypeId = rtContact.Id;
            employee.FirstName = 'Empleado Test 2';
            employee.LastName = '1';
            employee.CC_Idioma__c = 'es';
            employee.CC_Inactivo__c = false;
            employee.CC_Matricula__c = 'U01234_Invalid';
            employee.AV_UsuarioAsociado__c = userTest.Id;
            insert employee;
            
            Contact c = [SELECT Id, CC_Inactivo__c, AV_UsuarioAsociado__c FROM Contact WHERE Id =: employee.Id];
            Test.stopTest();
            User u = [SELECT Id, isActive FROM User WHERE Id =: userTest.Id];
            System.assertEquals(true, c.CC_Inactivo__c);
            System.assertEquals(null, c.AV_UsuarioAsociado__c);
            System.assertEquals(false, u.isActive);
        }
    }
    
    @isTest
    public static void migrateApoderadoTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE UserName LIKE 'gcf-integration@cc-caixabank.com%'];
        RecordType apoderadoRT = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_CONTACT, 'CIBE_Apoderado');
        User userTest = CIBE_TestHelper.createUser('CIBE_Gestor');

        System.runAs(usuario){
            Contact employee = new Contact();
            employee.RecordTypeId = apoderadoRT.Id;
            employee.FirstName = 'Empleado Test 2';
            employee.LastName = '1';
            employee.CC_Idioma__c = 'es';
            employee.CC_Inactivo__c = false;
            employee.CC_Matricula__c = 'U01234_Invalid';
            employee.AV_UsuarioAsociado__c = userTest.Id;
            employee.CIBE_Telefono1__c = '676767672';
            employee.CIBE_CategoriaTelefono1__c = '2';
            employee.CIBE_TipoTelefono1__c = '001';
            insert employee;
            Test.stopTest();
            Contact c = [SELECT Phone FROM Contact WHERE Id =: employee.Id];
            System.assertEquals(String.valueOf(employee.CIBE_Telefono1__c), c.Phone);
        }
    }

    @isTest
    public static void employeeExistsTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<Contact> contacts = [SELECT Id, CC_Matricula__c, AV_UsuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U01XYZ01' LIMIT 1];
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c  = 'U01XYZ01' LIMIT 1];
        Test.startTest();
            System.runAS(userGcf){
                AV_ContactTriggerHelper.employeeExists(contacts);
            }
        Test.stopTest();
        Contact updatedContact = [SELECT Id, AV_UsuarioAsociado__c, CC_Matricula__c FROM Contact WHERE CC_Matricula__c = 'U01XYZ01' LIMIT 1];
        System.assertEquals(user.Id, updatedContact.AV_UsuarioAsociado__c);
    }

    @isTest
    public static void isPoolContactTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        List<Contact> contacts = [SELECT Id, CC_Matricula__c, AV_UsuarioAsociado__c, AV_Pool__c, Account.CC_Numero_Oficina_Empresa__c FROM Contact WHERE CC_Matricula__c = 'U01XYZ01' LIMIT 1];
        User user = [SELECT Id, AV_Pool__c, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c  = 'U01XYZ01' LIMIT 1];
        Test.startTest();
        System.runAS(userGcf){
            AV_ContactTriggerHelper.isPoolContact(contacts, null);
        }
        Test.stopTest();
        Contact updatedContact = [SELECT Id, AV_UsuarioAsociado__c, CC_Matricula__c, AV_Pool__c, Account.CC_Numero_Oficina_Empresa__c FROM Contact WHERE CC_Matricula__c = 'U01XYZ01' LIMIT 1];
        System.assertEquals(user.AV_Pool__c, updatedContact.AV_Pool__c);
        System.assertEquals(user.AV_NumeroOficinaEmpresa__c, updatedContact.Account.CC_Numero_Oficina_Empresa__c);
    }
}