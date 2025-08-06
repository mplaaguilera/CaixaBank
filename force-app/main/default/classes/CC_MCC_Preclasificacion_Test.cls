@isTest
public class CC_MCC_Preclasificacion_Test {
    @testSetup 
    static void setup() {
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
      	Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Account cuentaCentroCaixaBank = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta Centro CaixaBank Test 1',
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuentaCentroCaixaBank;
        
        Contact contacto = new Contact(
            RecordTypeId = empleadoRecordTypeId,
            FirstName = 'Contacto OF',
            LastName = 'Test',
            AccountId = cuentaCentroCaixaBank.Id,
            CC_Idioma__c = 'es',
            Email = 'test@contact.com',
            CC_Cargo__c = 'DIRECCIÓN'
        );
        insert contacto;
        
        Id recordTypeIdEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeIdEmpleado;
        caso.Subject = 'Test_01';
        caso.AccountId = cuentaCentroCaixaBank.Id;
        caso.ContactId = contacto.Id;
        caso.Status = 'New';
        caso.Origin = 'Chat';
        caso.CC_NumPerso__c = '999910559714';
        insert caso;
        //
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;     
               
        Id recordTypeIdConvsCognitivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Cognitivo').getRecordTypeId();
        CC_MCC__c mccConvsCognitivo = new CC_MCC__c();
        mccConvsCognitivo.RecordTypeId = RecordTypeIdConvsCognitivo;
        mccConvsCognitivo.Name ='Ahorro';
        mccConvsCognitivo.CC_Canal_Procedencia_Equivalente__c='Pasivo y Valores';
        mccConvsCognitivo.CC_Equivalencia_Formulario__c = 'MC-Ahorro-AhorroAPlazo';
        mccConvsCognitivo.CC_Espacio_Cognitivo__c='Ahorro';
        mccConvsCognitivo.CC_Categoria_Cognitivo__c='AhorroAPlazo';
        mccConvsCognitivo.CC_Tipo_Cliente__c = 'Empleado';
        mccConvsCognitivo.CC_WebMCCTematica__c= mccTematica.Id;
        mccConvsCognitivo.CC_WebMCCProducto__c= mccProducto.Id;
        mccConvsCognitivo.CC_Codigo_Externo__c = 'CG-000001';
        insert mccConvsCognitivo;
        
        CC_MCC__c mccTematica2 = new CC_MCC__c();
        mccTematica2.Name = 'Ahorro a plazo';
        mccTematica2.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        insert mccTematica2;
        
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Depósito a plazo en divisas';
        mccProducto2.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002';
        insert mccProducto2;  
        
        CC_MCC__c mccConvsCognitivo2 = new CC_MCC__c();
        mccConvsCognitivo2.RecordTypeId = RecordTypeIdConvsCognitivo;
        mccConvsCognitivo2.Name ='Ahorro2';
        mccConvsCognitivo2.CC_Canal_Procedencia_Equivalente__c='Pasivo y Valores';
        mccConvsCognitivo2.CC_Equivalencia_Formulario__c = 'MC-Ahorro2-AhorroAPlazo2';
        mccConvsCognitivo2.CC_Espacio_Cognitivo__c='Ahorro2';
        mccConvsCognitivo2.CC_Categoria_Cognitivo__c='AhorroAPlazo2';
        mccConvsCognitivo2.CC_Tipo_Cliente__c = 'Empleado';
        mccConvsCognitivo2.CC_WebMCCTematica__c= mccTematica2.Id;
        mccConvsCognitivo2.CC_WebMCCProducto__c= mccProducto2.Id;
        mccConvsCognitivo2.CC_Codigo_Externo__c = 'CG-000002';
        insert mccConvsCognitivo2;
        
        //
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('LiveChatTranscript', 'CC_Empleados'),
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            CC_Subject__c = 'Prueba',
            LiveChatVisitorId = visitor.Id,
            CC_Id_Cognitive__c='9001029aa',
            CC_NumPerso__c = '999910559714',
            CC_NumPerso2__c = '999910559714',            
            CC_Espacio__c = 'Ahorro',
            CC_Categoria__c = 'AhorroAPlazo',
            AccountId = cuentaCentroCaixaBank.Id,
            ContactId = contacto.Id,
            CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id
        );
        insert liveChatTranscript;
    }
    
    @isTest 
    static void testPreclasificar() {
        
        List<Id> ids = new List<Id>();
        ids.add([SELECT Id FROM LiveChatTranscript].Id);
            
        Test.startTest();
        LiveChatTranscript chat = [SELECT CaseId ,Id FROM LiveChatTranscript];
        Case caso = [SELECT Id, CC_MCC_Tematica__c FROM Case WHERE Id = :chat.CaseId];
        System.assertEquals(null, caso.CC_MCC_Tematica__c);
        
        //preclasificamos el caso
        CC_MCC_Preclasificacion.preclasificarCasos(ids);
        
        //comprobamos que el caso tenga temàtica.
        caso = [SELECT Id, CC_MCC_Tematica__c FROM Case WHERE Id = :chat.CaseId];
        System.assertNotEquals(null, caso.CC_MCC_Tematica__c);
        
        String tematica = [SELECT Id FROM CC_MCC__c WHERE Name='Ahorro a la vista'].Id;
        
        System.assertEquals(tematica, caso.CC_MCC_Tematica__c);
        
        //reclasificamos el mismo caso
        chat.CC_Espacio__c= 'Ahorro2';
        chat.CC_Categoria__c = 'AhorroAPlazo2';
        update chat;
        
        ids = new List<Id>();
        ids.add([SELECT Id FROM LiveChatTranscript].Id);        
        CC_MCC_Preclasificacion.preclasificarCasos(ids);
        caso = [SELECT Id, CC_MCC_Tematica__c FROM Case WHERE Id = :chat.CaseId];
        System.assertNotEquals(tematica, caso.CC_MCC_Tematica__c);
        Test.stopTest();
        
    }
}