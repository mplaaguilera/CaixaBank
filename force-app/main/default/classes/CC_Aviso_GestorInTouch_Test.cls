@isTest
public class CC_Aviso_GestorInTouch_Test {
	@isTest
    public static void enviarEmailAlta(){
        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Comunicacion a Oficina por Alta de Caso CAS - Informal';
        template1.DeveloperName = 'Comunicacion_Gestor_Intouch_Alta_Caso_CAS_Informal';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
    	       
        Id recordTypeOficinaGestor = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuentaGestorIntouch = new Account();
        cuentaGestorIntouch.Name = 'Cuenta Test Gestora';
        cuentaGestorIntouch.RecordTypeId = recordTypeOficinaGestor;
        cuentaGestorIntouch.CC_Tipo_Centro__c='OF';
        cuentaGestorIntouch.CC_Email__c='test@gmail.com';
        insert cuentaGestorIntouch;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_Centro_Gestor_InTouch__c=cuentaGestorIntouch.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.RecordTypeId = recordTypeCliente;
        insert oContacto;
        
       
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = oContacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        insert caso;
        
        List<Id> idsCasos = new List<Id>();
		idsCasos.add(caso.Id);
        
        
        Test.startTest();
		CC_Aviso_Alta_GestorInTouch.avisoGestor(idsCasos);
        Test.stopTest();
        
        
        
        
        List<Case> casos = [Select Id, AccountId From Case where AccountId =: cuenta.Id];
		System.assert(casos.size() > 0);
    }
    @isTest
    public static void enviarEmailCierre(){
        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Comunicacion a Oficina por Cierre de Caso CAS - Informal';
        template1.DeveloperName = 'Comunicacion_Gestor_Intouch_Cierre_Caso_CAS_Informal';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
    	       
        Id recordTypeOficinaGestor = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuentaGestorIntouch = new Account();
        cuentaGestorIntouch.Name = 'Cuenta Test Gestora';
        cuentaGestorIntouch.RecordTypeId = recordTypeOficinaGestor;
        cuentaGestorIntouch.CC_Tipo_Centro__c='OF';
        cuentaGestorIntouch.CC_Email__c='test@gmail.com';
        insert cuentaGestorIntouch;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_Centro_Gestor_InTouch__c=cuentaGestorIntouch.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.RecordTypeId = recordTypeCliente;
        insert oContacto;
        
       
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = oContacto.Id;
        caso.Status = 'Cerrado';
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        insert caso;
        
        List<Id> idsCasos = new List<Id>();
		idsCasos.add(caso.Id);
        
        
        Test.startTest();
		CC_Aviso_Cierre_GestorInTouch.avisoGestor(idsCasos);
        Test.stopTest();
        
        
        List<Case> casos = [Select Id, AccountId From Case where AccountId =: cuenta.Id];
		System.assert(casos.size() > 0);
    }
}