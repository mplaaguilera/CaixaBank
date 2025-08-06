@isTest
public class CC_Notificaciones_Oficina_Test {
    @isTest
    static void notificarCasos() {
        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Comunicacion a Oficina por Cierre de Caso CAS - Informal';
        template1.DeveloperName = 'Comunicacion_Oficina_Cierre_Caso_CAS_Informal';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
                
        Id recordTypeOficinaGestora = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = recordTypeOficinaGestora;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
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
        caso.CC_Canal_Procedencia__c = 'Accionista';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        insert caso;
        
        List<Id> idCases= new List<Id>();
        Idcases.add(caso.Id);
        CC_Notificaciones_Oficina.notificarCasos(Idcases);
        
        List<Case> casos = [Select Id, AccountId From Case where AccountId =: cuenta.Id ];
        System.assertEquals(casos.size() > 0, true, 'No hay casos');
    }
}