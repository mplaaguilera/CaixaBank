@isTest
public class CC_EmailMessage_TRDisp_Test {
    
    @TestSetup
    static void setup(){
        User thisUser;

         System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
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
        
        System.runAs ( thisUser ) {
            //Preparación de los datos
            Case caso = new Case();
            caso.Subject = 'Caso Test';
            insert caso;

            List <EmailMessage> listaCorreos = new List <EmailMessage>();
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso.Id;
            correo.Incoming = false;
            correo.CC_Interno__c = true;
            correo.MessageDate = System.now();
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correo.ToAddress = 'to@test.com';
            correo.Subject = 'TestTRDisp';
            correo.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
            correo.Headers = '[{"value": "Teeeeest","name": "X-SFDC-Original-RCPT"}]';
            listaCorreos.add(correo);
            
            insert listaCorreos;
        }
        
        
    }
    
    @isTest
    public static void deleteTest() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (testUser) {
            EmailMessage correo = [SELECT Id FROM EmailMessage WHERE Subject = 'TestTRDisp' LIMIT 1];
            String exceptionMessage = '';

            Test.startTest();
            try{
                delete correo;
            }catch(Exception e){
                exceptionMessage = e.getMessage();
            }
            Test.stopTest();
            
            System.AssertEquals(true, String.isNotBlank(exceptionMessage), 'Debe haber saltado la excepción');
        }
	}
    
    @isTest
    public static void insertTest() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (testUser) {
            String exceptionMessage = '';
            List <Case> caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test' LIMIT 1];
            
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso[0].Id;
            correo.Incoming = false;
            correo.CC_Interno__c = true;
            correo.MessageDate = System.now();
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correo.ToAddress = 'to@test.com';
            correo.Subject = 'TestTRDispInsert';
            correo.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
            correo.Headers = '[{"value": "Teeeeest","name": "X-SFDC-Original-RCPT"}]';
            
            Test.startTest();
            try{
                insert correo;
            }catch(Exception e){
                exceptionMessage = e.getMessage();
            }
            Test.stopTest();
            
            System.AssertEquals(true, String.isNotBlank(exceptionMessage), 'Debe haber saltado la excepción entrando por el EmailException');
	    }
    }

    @isTest
    public static void insertNoExceptionTest() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (testUser) {
            String exceptionMessage = '';
            List <Case> caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test' LIMIT 1];
            
            EmailMessage correo = new EmailMessage();
            correo.ParentId = caso[0].Id;
            correo.Incoming = false;
            correo.CC_Interno__c = true;
            correo.MessageDate = System.now();
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correo.ToAddress = 'to@test.com';
            correo.Subject = 'TestInsertNoException';
            correo.HtmlBody = 'Hola\n#@refTrasladar#\nAdios\n#@refRemitir#';
            correo.Headers = '[{"value": "Teeeeest","name": "X-SFDC-Original-RCPT"}]';
            
            Test.startTest();
            try{
                insert correo;
            }catch(Exception e){
                exceptionMessage = e.getMessage();
            }
            Test.stopTest();
            
            System.AssertEquals(true, String.isBlank(exceptionMessage), 'No debe haber saltado ninguna excepción');
	    }
    }
}