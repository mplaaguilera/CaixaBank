@isTest
public with sharing class SACH_WS_AltaCasoPromor_2_test {
    @TestSetup
    static void makeData(){
        //Usuario SAC General
		User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);

        Account cuenta = new Account();
        //cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '09000';
        insert cuenta;

        // Insertar RecordTypes para Account y Contact si es necesario o asegurarse de que existen
        Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');

        // Crear y insertar Account de prueba
        Account testAccount = new Account(LastName = 'Test Account',RecordTypeId = rtAccountCliente);
        insert testAccount;
        
        
        // Crear y insertar Contact de prueba
        Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contact', AV_NumPerso__c = '14336032');
        insert testContact;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente'; 
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;
       
        
    }

    @isTest
    static void registrarCasoPromor_Test() {
        
         // Creamos un objeto RestRequest simulado
         RestRequest request = new RestRequest();
         request.requestURI = '/services/apexrest/AltaCasoPromorv1';
         request.httpMethod = 'POST';
      

         // Creamos un objeto de entrada simulado
        SACH_WS_AltaCasoPromor_v1.Input input = new SACH_WS_AltaCasoPromor_v1.Input();
        input.demanda = 'Demanda de prueba';
        input.contrato = 12345;
        input.oficinagestora = '09000';
        input.pacto = 'Pacto cumplido';
        input.numperso = '00DAC020';
        input.comentario1 = 'Comentario 1';
        input.comentario2 = 'Comentario 2';
        input.comentario3 = 'Comentario 3';
        input.comentario4 = 'Comentario 4';

          // Convertimos el objeto de entrada en JSON y lo añadimos al cuerpo de la solicitud
          String requestBody = JSON.serialize(input);
          request.requestBody = Blob.valueOf(requestBody);
         // Establecemos la solicitud simulada en el contexto de REST
         RestContext.request = request;

        Contact contacto1 = [SELECT id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];
        Account testAccount = [SELECT id FROM Account WHERE LastName = 'Test Account' LIMIT 1];

        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];

        Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = idRecordTypeSACH;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto1.Id;
        caso.Subject = 'comprobacionContactoAI';    
       insert caso;

       // Ejecutamos el método de registro del caso
       Test.startTest();
       SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor();
       Test.stopTest();

       // Verificamos los resultados esperados
       System.assertEquals('OK', output.resultado);
       System.assertNotEquals(null, output.caseId);
      


    }

    @isTest
    static void registrarCasoPromor_conCasoAsociado_Test() {

        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
        Contact testContacto = [SELECT id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];
        Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.RecordTypeId = idRecordTypeSACH;
        caso1.AccountId = cuenta.Id;
        caso1.CC_MCC_Solucion__c = 'Aprobado';
        caso1.Status = 'Cerrado';
        caso1.ContactId = testContacto.Id;
        caso1.Subject = 'comprobacionContactoAI';    
       insert caso1;
        
         // Creamos un objeto RestRequest simulado
         RestRequest request = new RestRequest();
         request.requestURI = '/services/apexrest/AltaCasoPromorv1';
         request.httpMethod = 'POST';
      

         // Creamos un objeto de entrada simulado
        SACH_WS_AltaCasoPromor_v1.Input input = new SACH_WS_AltaCasoPromor_v1.Input();
        input.demanda = 'Demanda de prueba';
        input.contrato = 12345;
        input.oficinagestora = '09000';
        input.pacto = 'Pacto cumplido';
        input.numperso = '00DAC020';
        input.comentario1 = 'Comentario 1';
        input.comentario2 = 'Comentario 2';
        input.comentario3 = 'Comentario 3';
        input.comentario4 = 'Comentario 4';

          // Convertimos el objeto de entrada en JSON y lo añadimos al cuerpo de la solicitud
          String requestBody = JSON.serialize(input);
          request.requestBody = Blob.valueOf(requestBody);
         // Establecemos la solicitud simulada en el contexto de REST
         RestContext.request = request;
        /*
        Contact contacto1 = [SELECT id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];
        Account testAccount = [SELECT id FROM Account WHERE LastName = 'Test Account' LIMIT 1];

        

        //Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = idRecordTypeSACH;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto1.Id;
        caso.Subject = 'comprobacionContactoAI';    
       insert caso;*/


       // Ejecutamos el método de registro del caso
       Test.startTest();
       SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor();
       Test.stopTest();

       // Verificamos los resultados esperados
       System.assertEquals('OK', output.resultado);
       System.assertNotEquals(null, output.caseId);
      


    }
}