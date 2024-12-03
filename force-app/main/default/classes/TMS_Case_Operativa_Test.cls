@isTest
public class TMS_Case_Operativa_Test {

    @TestSetup
    static void setData() {

        

        User uOs = TMS_Usuarios.usuarioAdmin();
        
        User u = TMS_Usuarios.usuarioLetrado();
		System.runAs(uOs) {
            

            EmailTemplate template1 = new EmailTemplate();
            template1.FolderId = u.Id;
            template1.Name = 'Plantilla TMS';
            template1.Subject = 'esto es una prueba';
            template1.HtmlValue = 'Test';
            template1.DeveloperName = 'TMS_Plantilla_Prueba';
            template1.TemplateType = 'Text';
            insert template1;
    
            List<Case> lstCasos = new List<Case>();
            Id recordTypeCasoTMS = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
    
            Case caso = new Case();
            caso.Subject = 'Caso de prueba TMS';
            caso.recordtypeId= recordTypeCasoTMS;
            caso.Origin = 'SAC_Manual';
            caso.Status = 'TMS_001';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.CC_Buzon_Salida__c = [SELECT TMS_Correo__c FROM TMS_Correo__mdt LIMIT 1].TMS_Correo__c;
            caso.TMS_Numexp__c='87458569878';
            caso.SuppliedEmail='test2@test.com';
            caso.OwnerId=u.Id;
            lstCasos.add(caso);
            
            Case caso2 = new Case();
            caso2.Subject = 'Caso de prueba TMS 2';
            caso2.recordtypeId= recordTypeCasoTMS;
            caso2.Origin = 'SAC_Manual';
            caso2.Status = 'TMS_002';
            caso2.CC_Canal_Procedencia__c = 'Testamentarias';
            caso2.TMS_Numexp__c='11111111111';
            caso2.OwnerId=u.Id;
            lstCasos.add(caso2);
            
            insert lstCasos;
        }
    }
    @isTest
    public static void plantillasTest() {
        User u = [SELECT Id FROM User WHERE Alias = 'LetTMS' AND IsActive=true];

        System.runAs(u){
           
        	Test.startTest();
            List<EmailTemplate> lista = TMS_Case_Operativa.getPlantillasTMS();
            System.assertNotEquals(0, lista.size());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validarCamposTest() {
        User u = [SELECT Id FROM User WHERE Alias = 'LetTMS' AND IsActive=true];

        System.runAs(u){
           
        Test.startTest();

        Case casoTMS = [SELECT Id FROM Case WHERE TMS_Numexp__c='11111111111' LIMIT 1];

        List<String> lstErrores = TMS_Case_Operativa.validarCamposCaso(casoTMS.Id);

        Test.stopTest();
        System.assertEquals(false, lstErrores.isEmpty(), 'Hay errores generado la tarea');
        }
        
    }
    
    @isTest
    public static void prepararCasoTest() {
        
        User u = [SELECT Id FROM User WHERE Alias = 'LetTMS' AND IsActive=true];

        System.runAs(u){

            Test.startTest();
    
            Case casoTMS = [SELECT Id FROM Case WHERE TMS_Numexp__c != '' LIMIT 1];
            EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE '%TMS%' LIMIT 1];
    
            TMS_Case_Operativa.prepararCaso(casoTMS.Id, plantilla.Id, true, 'trasladar');
    
            Test.stopTest();
    
            Case casoTMSpost = [SELECT Id, CC_Buzon_Salida__c FROM Case WHERE CC_Canal_Procedencia__c = 'Testamentarias' LIMIT 1];
            System.assertEquals(true, casoTMSpost.CC_Buzon_Salida__c != null, 'No se ha encontrado un busón de salida');
        }
    }
    
    @isTest
    public static void destinatariosTest() {
        User u = [SELECT Id FROM User WHERE Alias = 'LetTMS' AND IsActive=true];

        System.runAs(u){

        Test.startTest();
        
            Case casoTMS = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'Testamentarias' LIMIT 1];
            
            EmailTemplate plantilla = [SELECT Name, DeveloperName, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName LIKE '%TMS%' LIMIT 1];
            String direccion= [SELECT TMS_Correo__c FROM TMS_Correo__mdt LIMIT 1].TMS_Correo__c;
            
            List<String> direcciones = new List<String>();
            direcciones.add('test@test.com');
            direcciones.add(direccion);
            
            EmailMessage correo = new EmailMessage();
            correo.FromAddress ='test1@test.com';
            correo.ToAddress = direccion;
            correo.parentId = casoTMS.Id;
            correo.Incoming = true;
        	correo.Subject = plantilla.Subject;
        	correo.HtmlBody = plantilla.HtmlValue;
            insert correo;
            
            Map<String, List<String>> mapaDestino = TMS_Case_Operativa.destinatarios(casoTMS.Id);
            
            System.AssertNotEquals(0, mapaDestino.size());
            

            Test.stopTest();    
           /* Date fecha = System.today();
    
            List<String> lstErrores = TMS_Case_Operativa.validarCamposCaso(casoTMS.Id);
    
            System.assertEquals(false, lstErrores.isEmpty(), 'Hay errores generado la tarea');*/
        }
    }
}