@isTest
public with sharing class SACH_WS_AltaCasoPromor_v1_test {

    @testSetup
    static void data(){
          //Usuario SAC General
		User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);

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

         // Insertar RecordTypes para Account y Contact si es necesario o asegurarse de que existen
         Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
         Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
 
         // Crear y insertar Account de prueba
         Account testAccount = new Account(LastName = 'Test Account',RecordTypeId = rtAccountCliente);
         insert testAccount;
         
         // Crear y insertar Contact de prueba
         Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contact', AV_NumPerso__c = '14336032');
         insert testContact;

         SACH_Parametros__c params = new SACH_Parametros__c();
        params.Name = 'SACH_Promor';
        params.SACH_Parametro_1__c = 'https://google.com';
        insert params;
    }


    @isTest
    static void registrarCasoPromor_Test() {

        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){


        Account cuenta = new Account();
        //cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '00256';
        insert cuenta;

        Id clientePAId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        Id clienteId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Account cuentaA = new Account();
        cuentaA.RecordTypeId = rtAccountCliente;
        cuentaA.LastName = 'Cuenta personal test A';
        insert cuentaA;

        Id rtAccountCliente2 = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        Account cuentaB = new Account();
        cuentaB.RecordTypeId = rtAccountCliente2;
        cuentaB.Name = 'Cuenta personal test B';
        insert cuentaB;

        Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
       
        Contact contacto1 = new Contact();
        contacto1.RecordTypeId = rtContactCliente;
        contacto1.AccountId = cuentaB.Id;
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '14336032';
        //contacto1.AV_NumPerso__c = '25345561';
        contacto1.CC_Idioma__c = 'ca';
        contacto1.Email = 'correo@gmail.com';
        contacto1.Phone = '973242323';
        insert contacto1;

        // Creamos un objeto RestRequest simulado
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/AltaCasoPromorv1';
        request.httpMethod = 'POST';
        
        // Crear una instancia de RestResponse
        RestResponse res = new RestResponse();
        // Establecer valores en la instancia de RestResponse
        res.statusCode = 200;
        res.responseBody = Blob.valueOf('{"message": "Success"}');
        res.addHeader('Content-Type', 'application/json');

        List<SACH_WS_AltaCasoPromor_v1.Input> inputsAccepted = new List<SACH_WS_AltaCasoPromor_v1.Input>();

        // Creamos un objeto de entrada simulado
        SACH_WS_AltaCasoPromor_v1.Input input = new SACH_WS_AltaCasoPromor_v1.Input();
        input.demanda = 'Demanda de prueba';
        input.iddemanda = '1234567890';
        input.contrato = 12345;
        input.oficinagestora = '00256';
        input.pacto = '299';
        input.numperso = '00DAC020';
        
        // Crear la lista de actividades
        List<SACH_WS_AltaCasoPromor_v1.Actividad> actividades = new List<SACH_WS_AltaCasoPromor_v1.Actividad>();

         // Crear una actividad de ejemplo
         SACH_WS_AltaCasoPromor_v1.Actividad actividad = new SACH_WS_AltaCasoPromor_v1.Actividad();
         actividad.codactividad = '58';
         actividad.comentarios = 'Prueba';
            
          // Crear la lista de adjuntos para la actividad
        List<SACH_WS_AltaCasoPromor_v1.Adjunto> adjuntos = new List<SACH_WS_AltaCasoPromor_v1.Adjunto>();

          // Crear adjuntos de ejemplo y añadirlos a la lista
          SACH_WS_AltaCasoPromor_v1.Adjunto adjunto1 = new SACH_WS_AltaCasoPromor_v1.Adjunto();
          adjunto1.nombreadjunto = 'prueba nombre adjunto1a';
          adjunto1.tipodocumento = 'tipodedocumento prueba1a';
          adjunto1.iddocumento = '123456789';
          adjuntos.add(adjunto1);

          SACH_WS_AltaCasoPromor_v1.Adjunto adjunto2 = new SACH_WS_AltaCasoPromor_v1.Adjunto();
          adjunto2.nombreadjunto = 'prueba nombre adjunto2a';
          adjunto2.tipodocumento = 'tipodedocumento prueba2a';
          adjunto2.iddocumento = '000000000';
          adjuntos.add(adjunto2);

          SACH_WS_AltaCasoPromor_v1.Adjunto adjunto3 = new SACH_WS_AltaCasoPromor_v1.Adjunto();
        adjunto3.nombreadjunto = 'prueba nombre adjunto3a';
        adjunto3.tipodocumento = 'tipodedocumento prueba3a';
        adjunto3.iddocumento = '111111111';
        adjuntos.add(adjunto3);

        // Asignar la lista de adjuntos a la actividad
        actividad.adjuntos = adjuntos;

         // Añadir la actividad a la lista de actividades
         actividades.add(actividad);

         // Asignar la lista de actividades al input
        input.actividades = actividades;
        inputsAccepted.add(input);


        /*
        input.comentario1 = 'Comentario 1';
        input.comentario2 = 'Comentario 2';
        input.comentario3 = 'Comentario 3';
        input.comentario4 = 'Comentario 4';*/

          // Creamos un número de persona ficticio
          
          Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
       Contact contactonuevo = [SELECT AV_NumPerso__c,Id,CC_NumPerso__c,RecordTypeId FROM Contact WHERE AccountId = :cuentaB.Id];
        //contactonuevo.AV_NumPerso__c = '25345561';
        //contactonuevo.RecordTypeId = rtContactCliente;
        //update contactonuevo;

         // Crear y insertar Contact de prueba
         //Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contacto nuevo', AV_NumPerso__c = '25345561');
         //insert testContact;
        
         Case caso = new Case();
         caso.RecordTypeId = idRecordTypeSACH;
         caso.ContactId = contactonuevo.Id;
         caso.Subject = 'comprobacionContactoAI';    
        insert caso;

        // Convertimos el objeto de entrada en JSON y lo añadimos al cuerpo de la solicitud
        String requestBody = JSON.serialize(input);
        request.requestBody = Blob.valueOf(requestBody);
        

         // Asignar la instancia de RestResponse al contexto de la llamada REST
         RestContext.response = res;

        // Establecemos la solicitud simulada en el contexto de REST
        RestContext.request = request;
        //insert inputsAccepted;

        // Ejecutamos el método de registro del caso
        Test.startTest();
            //SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor(input);
            SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor();
        Test.stopTest();

        // Verificamos los resultados esperados
        System.assertEquals('OK', output.resultado);
        System.assertNotEquals(null, output.caseId);

        }
    }

    /*

    @isTest
    static void registrarCasoPromor2_Test() {

        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){


        Account cuenta = new Account();
        //cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '09000';
        insert cuenta;

        Id clientePAId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        Id clienteId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Id rtAccountCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Account cuentaA = new Account();
        cuentaA.RecordTypeId = rtAccountCliente;
        cuentaA.LastName = 'Cuenta personal test A';
        insert cuentaA;

        Id rtAccountCliente2 = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        Account cuentaB = new Account();
        cuentaB.RecordTypeId = rtAccountCliente2;
        cuentaB.Name = 'Cuenta personal test B';
        insert cuentaB;

        Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
       
        Contact contacto1 = new Contact();
        contacto1.RecordTypeId = rtContactCliente;
        contacto1.AccountId = cuentaB.Id;
        contacto1.FirstName = 'Contacto';
        contacto1.LastName = '01';
        contacto1.CC_NumPerso__c = '14336032';
        //contacto1.AV_NumPerso__c = '25345561';
        contacto1.CC_Idioma__c = 'ca';
        contacto1.Email = 'correo@gmail.com';
        contacto1.Phone = '973242323';
        insert contacto1;

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
        input.numperso = '12345677';
        /*
        input.comentario1 = 'Comentario 1';
        input.comentario2 = 'Comentario 2';
        input.comentario3 = 'Comentario 3';
        input.comentario4 = 'Comentario 4';

          // Creamos un número de persona ficticio
          
          Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
       Contact contactonuevo = [SELECT AV_NumPerso__c,Id,CC_NumPerso__c,RecordTypeId FROM Contact WHERE AccountId = :cuentaB.Id];
        //contactonuevo.AV_NumPerso__c = '25345561';
        //contactonuevo.RecordTypeId = rtContactCliente;
        //update contactonuevo;

         // Crear y insertar Contact de prueba
         //Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contacto nuevo', AV_NumPerso__c = '25345561');
         //insert testContact;
        
         Case caso = new Case();
         caso.RecordTypeId = idRecordTypeSACH;
         caso.ContactId = contactonuevo.Id;
         caso.Subject = 'comprobacionContactoAI';    
        insert caso;

        // Convertimos el objeto de entrada en JSON y lo añadimos al cuerpo de la solicitud
        String requestBody = JSON.serialize(input);
        request.requestBody = Blob.valueOf(requestBody);

        // Establecemos la solicitud simulada en el contexto de REST
        RestContext.request = request;

        // Ejecutamos el método de registro del caso
        Test.startTest();
            SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor(input);
        Test.stopTest();

        // Verificamos los resultados esperados
        System.assertEquals('KO', output.resultado);
        System.assertNotEquals(null, output.caseId);
        }
    }*/

    @isTest
    static void registrarCasoPromor_conCasoAsociado_Test() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

          Account cuenta = new Account();
          //cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
          cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
          cuenta.Name = 'account temp';
          cuenta.CC_Numero_Oficina__c = '00256';
          insert cuenta;


        Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        //Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE recordType.developerName = 'CC_ClientePA'];
         // Crear y insertar Contact de prueba
         Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contactdsfsdf', AV_NumPerso__c = '14336033');
         insert testContact;
        
        Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.RecordTypeId = idRecordTypeSACH;
        //caso1.AccountId = cuenta.Id;
        caso1.Status = 'Cerrado';
        caso1.ContactId = testContact.Id;
        caso1.Subject = 'comprobacionContactoAI';    
       insert caso1;

       Contact contactoIdentificado = SACH_Identificacion_Auto.identificarNUMPERSO('00DAC021');
	   List<Case> lstcasos = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];
	

       Case casoo = [SELECT Id FROM Case WHERE RecordTypeId = :idRecordTypeSACH];
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
        input.numperso = '00DAC021';
        /*
        input.comentario1 = 'Comentario 1';
        input.comentario2 = 'Comentario 2';
        input.comentario3 = 'Comentario 3';
        input.comentario4 = 'Comentario 4';*/

          // Convertimos el objeto de entrada en JSON y lo añadimos al cuerpo de la solicitud
          String requestBody = JSON.serialize(input);
          request.requestBody = Blob.valueOf(requestBody);
         
          // Establecemos la solicitud simulada en el contexto de REST
         RestContext.request = request;
          
         // Crear una instancia de RestResponse
        RestResponse res = new RestResponse();
        // Establecer valores en la instancia de RestResponse
        res.statusCode = 200;
        res.responseBody = Blob.valueOf('{"message": "Success"}');
        res.addHeader('Content-Type', 'application/json');
        RestContext.response = res;


       // Ejecutamos el método de registro del caso
       Test.startTest();
        //SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor(input);
        SACH_WS_AltaCasoPromor_v1.Output output = SACH_WS_AltaCasoPromor_v1.registrarCasoPromor();
       Test.stopTest();

       // Verificamos los resultados esperados
       System.assertEquals('KO', output.resultado);
       System.assertNotEquals(null, output.caseId);
        }
    }
}