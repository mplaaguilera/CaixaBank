@isTest
public class SEG_Email_Launcher_Controller_Test {
	@TestSetup
    static void crearDatosPrueba(){
        Account cuenta = new Account();
        cuenta.Name = 'CuentaTest';
        insert cuenta;

        //Creamos un caso para relacionarlo a email
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        caso.Subject = 'Caso SEG_Email_Launcher_Controller_Test';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.AccountId = cuenta.id;
        insert caso;
        
        list<EmailMessage>  lstEmailPrueba = New list<EmailMessage>();
        
        //Creamos un email para obtener en querys
        EmailMessage emailPrueba = new EmailMessage();
        emailPrueba.FromName = 'Paco Pil';
        emailPrueba.subject = 'Caso SEG_Email_Launcher_Controller_Test';
        emailPrueba.HtmlBody = 'EmailMessage Body';
        emailPrueba.fromAddress = null;
        //insert emailPrueba;
		lstEmailPrueba.add(emailPrueba);
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE LocalPart LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;
        
        EmailMessage emailPrueba1 = new EmailMessage();
        emailPrueba1.FromName = 'Atun';
        emailPrueba1.subject = 'Test';
        emailPrueba1.HtmlBody = 'test';
        emailPrueba1.ParentId = caso.Id;
        emailPrueba1.fromAddress = 'tesasdasdt@mail.com';
        emailPrueba1.RelatedToId = caso.id;
        emailPrueba1.incoming = true;
        emailPrueba1.CcAddress ='pericopalotes@mail.com; avemariacuandoserasmia@t.com; tesasdasdt@mail.com';
        emailPrueba1.BccAddress ='pericopalotes@mail.com; avemariacuandoserasmia@t.com; tesasdasdt@mail.com';
        emailPrueba1.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        //insert emailPrueba1;
		lstEmailPrueba.add(emailPrueba1);

        EmailMessage emailPrueba2 = new EmailMessage();
        emailPrueba2.FromName = 'Atun2';
        emailPrueba2.subject = 'Test2';
        emailPrueba2.HtmlBody = 'test2';
        emailPrueba2.ParentId = caso.Id;
        emailPrueba2.fromAddress = 'tesasdasdt@mail.com';
        emailPrueba2.RelatedToId = caso.id;
        emailPrueba2.incoming = false;
        emailPrueba2.CcAddress ='pericopalotes@mail.com; avemariacuandoserasmia@t.com; tesasdasdt@mail.com';
        emailPrueba2.BccAddress ='pericopalotes@mail.com; avemariacuandoserasmia@t.com; tesasdasdt@mail.com';
        //insert emailPrueba2;
		lstEmailPrueba.add(emailPrueba2);
        insert lstEmailPrueba;

        
        //Crear Contact
        Contact contacto = new Contact();
        contacto.lastname = 'prueba';
        contacto.Email =null;
        insert contacto;

        Contact contacto1 = new Contact();
        contacto1.lastname = 'prueba';
        contacto1.Email ='tesasdasdt@mail.com';
        contacto1.AccountId = cuenta.id;
        insert contacto1;
        
        Contact contacto2 = new Contact();
        contacto2.lastname = 'prueba';
        contacto2.Email ='test@mail.com';
        contacto2.AccountId = cuenta.id;
        insert contacto2;

        CC_Canal_Com__c canalCom = new CC_Canal_Com__c();
        canalCom.CC_CuentaId__c = cuenta.id;
        canalCom.CC_ContactoId__c = contacto1.id;
        canalCom.CC_Email__c = 'emailTest1234@viewsiguiente.com';
        insert canalCom;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com', 
                    emailencodingkey='UTF-8', lastname='Smith', 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles', 
                    username='testSEGBI@acme.com');
            insert thisUser;
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Supervisor'];
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();

            PermissionSetAssignment psAssign = new PermissionSetAssignment();
            psAssign.AssigneeId = thisUser.id;
            psAssign.PermissionSetId = ps.Id;
            listPermissionSetAssignment.add(psAssign);

            PermissionSetAssignment psAssign2 = new PermissionSetAssignment();
            psAssign2.AssigneeId = thisUser.id;
            psAssign2.PermissionSetId = ps2.Id;
            listPermissionSetAssignment.add(psAssign2);

            insert listPermissionSetAssignment;
        }
    }
    @isTest
    public static void initComponent() {
        List<Case> casos = [SELECT Id FROM Case LIMIT 1];
        Id caseId = casos[0].Id;

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_Email_Launcher_Controller.WrapperInit result =  SEG_Email_Launcher_Controller.initComponent(caseId);             
            Test.stopTest();
            System.assertnotEquals(result, null, 'No se ha obtenido resultado');    
        }    
    }
    
    @isTest
    public static void getResponderParaTest() {
        List<Case> casos = [SELECT Id FROM Case LIMIT 1];
        Id caseId = casos[0].Id;
        List<Contact> contacto = [SELECT id, Email FROM contact WHERE Email ='tesasdasdt@mail.com' LIMIT 1];
        String email = contacto[0].Email;

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            SEG_Email_Launcher_Controller.ListadoEmailsWrapper listadoAuxiliar = SEG_Email_Launcher_Controller.getResponderPara(email, caseId); 
            Test.stopTest();
            System.assertnotEquals(listadoAuxiliar, null, 'No se ha obtenido resultado');     
        }   
    }

    @isTest
    public static void getResponderMultipleCcTest() {
        List<Case> casos = [SELECT Id FROM Case Limit 1];
        Id caseId = casos[0].Id;
        String email = 'test@mail.com';
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            List<String> lstCC = SEG_Email_Launcher_Controller.getResponderMultipleCc(caseId, email); 
            Test.stopTest();
            System.assertnotEquals(lstCC, null, 'No se ha obtenido resultado');   
        }   
    }

    @isTest
    public static void getResponderMultipleCcoTest() {
        List<Case> casos = [SELECT Id FROM Case Limit 1];
        Id caseId = casos[0].Id;
        String email = 'test@mail.com';

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            List<String> lstCC = SEG_Email_Launcher_Controller.getResponderMultipleCco(caseId, email);
            Test.stopTest();
            System.assertnotEquals(lstCC, null, 'No se ha obtenido resultado');   
        }
    }

    @isTest
    public static void recuperarEmailTest() {
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage Limit 1];
        List<Case> casos = [SELECT Id FROM Case Limit 1];
        String caseId = casos[0].Id;
        String emailId = emails[0].Id;

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Case caso = SEG_Email_Launcher_Controller.recuperarCaso(caseId);
            String[] dates = SEG_Email_Launcher_Controller.recuperarFechaEmails(caseId);
            EmailMessage retrieveEmail = SEG_Email_Launcher_Controller.mostrarEmail(emailId,caseId);
            EmailMessage recentEmail = SEG_Email_Launcher_Controller.mostrarEmailReciente(caseId);
            EmailMessage[] emailList = SEG_Email_Launcher_Controller.recuperarEmails(caseId);
            Test.stopTest();
            System.assertnotEquals(caso, null, 'No se ha obtenido resultado');   
            System.assertnotEquals(dates, null, 'No se ha obtenido resultado');   
            System.assertnotEquals(retrieveEmail, null, 'No se ha obtenido resultado');   
            System.assertnotEquals(recentEmail, null, 'No se ha obtenido resultado');   
            System.assertnotEquals(emailList, null, 'No se ha obtenido resultado');   
        }
    }

    public @IsTest
    static void getFilesEmail(){
        List<EmailMessage> emails = [SELECT Id FROM EmailMessage Limit 1];
        List<Case> casos = [SELECT Id FROM Case Limit 1];
        String caseId = casos[0].Id;
        String emailId = emails[0].Id;
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                List<ContentVersion> returnList = SEG_Email_Launcher_Controller.getFilesEmail(emailId);
                List<ContentVersion> returnListRecent = SEG_Email_Launcher_Controller.getFilesEmailReciente(caseId);        
            Test.stopTest();
            System.assertnotEquals(returnList, null, 'No se ha obtenido resultado');   
            System.assertnotEquals(returnListRecent, null, 'No se ha obtenido resultado');   
        }
    }
    public @IsTest
    static void mostrarContact(){
        EmailMessage email = [SELECT id,fromAddress FROM EmailMessage LIMIT 1];
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                Contact returnContact = SEG_Email_Launcher_Controller.mostrarContact(email);
            Test.stopTest();
            System.assertnotEquals(returnContact, null, 'No se ha obtenido resultado');   
        }
    }    
    public @IsTest
    static void casoIdioma(){
        Case caso = [SELECT id,CC_Idioma__c FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                String getIdiomaCaso = SEG_Email_Launcher_Controller.defaultIdioma(caso.id);
            Test.stopTest();     
            System.assertnotEquals(getIdiomaCaso, null, 'No se ha obtenido resultado');   
        }
    }
    
    public @IsTest
    static void getPropietario(){
        Case caso = [SELECT id, OwnerId FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                Boolean esPropietario = SEG_Email_Launcher_Controller.esPropietario(caso.id);
            Test.stopTest();
            System.assertnotEquals(esPropietario, false, 'No se ha obtenido resultado');
        }      
    }

    public @IsTest
    static void mostrarEmailRecienteTest(){
        Case caso = [SELECT id, OwnerId FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            EmailMessage newMessage = SEG_Email_Launcher_Controller.mostrarEmailReciente(caso.id);
            Test.stopTest();  
            System.assertnotEquals(newMessage, null, 'No se ha obtenido resultado');
        }
    }
    
    public @IsTest
    static void getFilesEmailRecienteTest(){
        Case caso = [SELECT id, OwnerId FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            List<ContentVersion> listaFicheros = SEG_Email_Launcher_Controller.getFilesEmailReciente(caso.id);
            Test.stopTest();
            System.assertnotEquals(listaFicheros, null, 'No se ha obtenido resultado'); 
        }
    }
    
    public @IsTest
    static void getDynamicUrlTest(){
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            String url = SEG_Email_Launcher_Controller.getDynamicUrl();
            Test.stopTest();
            System.assertnotEquals(url, null, 'No se ha obtenido resultado'); 
        }
    }
     
    public @IsTest
    static void controlarContactTest(){
        Case caso = [SELECT id FROM Case LIMIT 1];
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Boolean isDisabled = SEG_Email_Launcher_Controller.controlarContactyOrgZona(caso.Id);
            Test.stopTest();
            System.assertnotEquals(isDisabled, false, 'No se ha obtenido resultado'); 
        }
    }
}