@isTest
public class SEG_Queueable_UpdtCase_Test {
    @TestSetup
    public static void SEG_Queueable_UpdtCase_Test() {
        Id recordTypeCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		List<Case> listCase = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Caso de prueba mcc 1';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior'; 
        caso.Status = 'Planificado';
        caso.SEG_Fecha_planificaci_n__c = datetime.now();
        listCase.add(caso);
        
        Insert listCase;    
        
        // Creación cuentas a tratar.  

		Account cuentaSEG = new Account();
        cuentaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG.Name = 'test segmentos';
        cuentaSEG.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG.CC_Numero_Documento__c = '111111114';
        insert cuentaSEG;

        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG.FirstName = 'Yaiza';
        contactoSEG.LastName = 'Contacto 2';
        contactoSEG.Email = 'testasdas@test.com';
        contactoSEG.AccountId = cuentaSEG.Id;
        insert contactoSEG;
    }
    @isTest
    public static void workTest() {
        String uniqueUserName = 'testBatchUser' + DateTime.now().getTime() + '@caixabankcc.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'testB', Email='testBatchUser@caixabankcc.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        insert u;
                         
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='SEG_Administrador' LIMIT 1];
        PermissionSetAssignment psa =  new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
		insert psa;

        // Traemos la cuenta y el contacto
        Contact contacto = [SELECT id FROM Contact LIMIT 1];
        Account cuenta = [SELECT id FROM Account LIMIT 1];

		
        System.runAs(u) {
            test.startTest();
            List<Case> lstCasos = [SELECT Id FROM Case LIMIT 200];
            
            List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
            Datetime vToday = datetime.now();
        
            for(Case caso: lstCasos){
                CBK_SCH_PendingProcess__c pendingProcess1 = new CBK_SCH_PendingProcess__c();
                pendingProcess1.RecordId__c = caso.Id;
                pendingProcess1.Schedule_Time__c = vToday.addDays(- 1);
                pendingProcess1.Param1__c = cuenta.id;
                pendingProcess1.Param2__c = contacto.id;
                pendingProcess1.ClassName__c = 'SEG_Queueable_UpdtCase';
                pendingProcessInsertList.add(pendingProcess1);
            }            
            Insert pendingProcessInsertList;
            
            SEG_Queueable_UpdtCase implClass = new SEG_Queueable_UpdtCase();
            implClass.lstInfoProcess = pendingProcessInsertList; 
            System.enqueueJob(implClass);
        
            test.stopTest();

            Case casoPost = [SELECT Id, AccountId, ContactId FROM Case where Subject = 'Caso de prueba mcc 1' LIMIT 1];
            System.assertEquals(casoPost.AccountId, cuenta.id, 'Cuenta no coincide');
            System.assertEquals(casoPost.ContactId, contacto.id, 'Contacto no coincide'); 
        }
    }
}