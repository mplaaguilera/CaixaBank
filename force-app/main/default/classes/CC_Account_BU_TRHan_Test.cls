@isTest
public class CC_Account_BU_TRHan_Test {

    @TestSetup
    public static void crearDatosPrueba() {
        String uniqueUserNameCops = 'copsstandarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile pOs = [SELECT Id FROM Profile WHERE Name='OS_Responsable'];
        UserRole rolOs = [SELECT Id FROM UserRole WHERE Name = 'COPS'];

        User uOs = new User(Alias = 'standt', Email='copsstandarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='TestingCops', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = pOs.Id, UserRoleId = rolOs.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserNameCops);
        
        insert uOs;

        PermissionSet psOs = [SELECT Id FROM PermissionSet WHERE Name = 'OS_PS_Responsable'];
        insert new PermissionSetAssignment(AssigneeId = uOs.Id, PermissionSetId = psOs.Id);
        
        System.runAs(uOs) {
            // The following code runs as user 'u'
            Account cuenta = new Account();
            cuenta.Name = 'Cuenta03';
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'OS_Buzon_Account');
            insert cuenta; 

        }
    }
    
    @isTest
    public static void encryptNumperso_beforeUpdate() {
        // Alta de datos para la prueba
        Account acc = new Account();
		acc.FirstName = 'Prueba';
        acc.LastName = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        acc.CC_Numero_Documento__c = '45855598S';
        
        // Ejecución de la prueba
        Test.startTest();
        insert acc;
        
        acc.CC_NumPerso__c = '533752';
        update acc;
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Account accInsertado = [SELECT CC_Numperso_HEX__c FROM Account WHERE Id = :acc.Id];
        if (accInsertado != null) {
            System.assertNotEquals(accInsertado.CC_Numperso_HEX__c, null);
        }
    }
    
    @isTest
    static void evitarDuplicadosCOPS_Test(){


        User u = [SELECT Id FROM User WHERE Email = 'copsstandarduser@testorg.com'];

        System.runAs(u) {
            // The following code runs as user 'u'

            Id copsBuzonRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Account').getRecordTypeId();
            Account cuenta2 = new Account ();
            cuenta2.recordtypeId = copsBuzonRT;
            cuenta2.Name = 'cnt2';
            cuenta2.CC_Email__c = 'testCOPS2@test.com';
            
            insert cuenta2;
            
            try{           
                
            	cuenta2.CC_Email__c = 'testCOPS@test.com';
                update cuenta2;

            } catch (Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe una Cuenta con el mismo Email.')?true:false;
                System.AssertEquals(true, expectedExceptionThrown);
            }
            

            
        }

    }
}