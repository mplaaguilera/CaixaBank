@isTest
public class SEG_LimpiezaContactosCPA_Batch_Test {
    @testSetup
    static void testSetup(){

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;

            User thisUser = new User(
                alias = 'user2', 
                email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', 
                lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = perfil.Id, 
                userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

        //Se generan 200 contactos de prueba que deberán ser eliminados por el batch
        List<Account> lstAccount = new list<Account>();
        List<Contact> lstContact = new list<Contact>();
        Id aRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        Id cRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        for (Integer i = 0; i < 200; i++) {
            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = aRT;
            cuentaSEG1.Name = 'CUENTA PENDIENTE ASOCIAR';		
            lstAccount.add(cuentaSEG1);
        }
        
        insert lstAccount;
        
        for (Account cuenta : lstAccount) {
            Contact contactSEG1 = new Contact();
            contactSEG1.RecordTypeId = cRT;
            contactSEG1.LastName = 'Contacto CPA Borrar';	
            contactSEG1.email='pruebas@test.com';	
            contactSEG1.AccountId = cuenta.Id;
            lstContact.add(contactSEG1);
        }
        
        insert lstContact;
    }

    @isTest
	public static void limpiezaContactos(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];
        System.runAs ( usuarioTest ) {
            Test.startTest();
            Id batchJobId = Database.executeBatch(new SEG_LimpiezaContactosCPA_Batch(), 200);
            Test.stopTest();
            List<Contact> cntRestantes = [SELECT Id FROM Contact WHERE CreatedDate = TODAY and Account.Name ='CUENTA PENDIENTE ASOCIAR' and Account.RecordType.DeveloperName ='CC_ClienteSEG' and Email != null];
            System.assertEquals(true, cntRestantes.isEmpty(), 'No se han eliminado todos los contactos.');
        }
    }
}