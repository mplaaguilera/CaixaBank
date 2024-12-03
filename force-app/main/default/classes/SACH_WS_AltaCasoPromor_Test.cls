@isTest
public with sharing class SACH_WS_AltaCasoPromor_Test {
    @testSetup
    static void data(){
      
      Account cuentaClientePA = new Account();
      cuentaClientePA.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
      cuentaClientePA.LastName = 'Cuenta Prueba ClientePA';
      cuentaClientePA.CC_Numero_Oficina_Empresa__c = '222-22223';
      cuentaClientePA.CC_Numero_Oficina__c = '222';
      insert cuentaClientePA;

      Contact contacto = new Contact();
      contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
      contacto.FirstName = 'Test';
      contacto.LastName = 'Contacto Prueba';
      //contacto.CC_NumPerso__c = '14336033';
      contacto.AV_NumPerso__c = '14336033';
      contacto.CC_Idioma__c = 'ca';
      contacto.Email = 'correo@gmail.com';
      contacto.Phone = '973242323';
      insert contacto;


          //Usuario SAC General
		    User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
        Database.insert(usuarioGeneral);

        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        //Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		    mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        //Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente'; 
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;

       
        Id recordTypeISolu =  Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Suspensión actuaciones por instrucción del SACH (715)';
        mccSolucion.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = recordTypeISolu;
        //mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
		    insert mccSolucion;

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

        SACH_Parametros__c params2 = new SACH_Parametros__c();
        params2.Name = 'Solucion_705';
        params2.SACH_Parametro_1__c = 'Petición autorización solicitud subasta al SACH en análisis (705)';
        insert params2;

        SACH_Parametros__c params3 = new SACH_Parametros__c();
        params3.Name = 'Solucion_715';
        params3.SACH_Parametro_1__c = 'Suspensión actuaciones por instrucción del SACH (715)';
        insert params3;
    }


    @isTest
    static void registrarCasoPromorTest() {

        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){


        Account cuenta = new Account();
        //cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '00256';
        cuenta.CC_Numero_Empresa__c = '001';
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
        request.requestURI = '/services/apexrest/AltaCasoPromor';
        request.httpMethod = 'POST';
        
        // Crear una instancia de RestResponse
        RestResponse res = new RestResponse();
        // Establecer valores en la instancia de RestResponse
        res.statusCode = 200;
        res.responseBody = Blob.valueOf('{"message": "Success"}');
        res.addHeader('Content-Type', 'application/json');

        List<SACH_WS_AltaCasoPromor.Input> inputsAccepted = new List<SACH_WS_AltaCasoPromor.Input>();

        // Creamos un objeto de entrada simulado
        SACH_WS_AltaCasoPromor.Input input = new SACH_WS_AltaCasoPromor.Input();
        input.demanda = 'Demanda de prueba';
        input.iddemanda = '1234567890';
        input.contrato = 12345;
        input.oficinagestora = '001-00256';
        input.pacto = '299';
        input.numperso = '14336032';
        
        // Crear la lista de actividades
        List<SACH_WS_AltaCasoPromor.Actividad> actividades = new List<SACH_WS_AltaCasoPromor.Actividad>();

         // Crear una actividad de ejemplo
         SACH_WS_AltaCasoPromor.Actividad actividad = new SACH_WS_AltaCasoPromor.Actividad();
         actividad.codactividad = '58';
         actividad.comentarios = 'Prueba';
            
          // Crear la lista de adjuntos para la actividad
        List<SACH_WS_AltaCasoPromor.Adjunto> adjuntos = new List<SACH_WS_AltaCasoPromor.Adjunto>();

          // Crear adjuntos de ejemplo y añadirlos a la lista
          SACH_WS_AltaCasoPromor.Adjunto adjunto1 = new SACH_WS_AltaCasoPromor.Adjunto();
          adjunto1.nombreadjunto = 'prueba nombre adjunto1a';
          adjunto1.tipodocumento = 'tipodedocumento prueba1a';
          adjunto1.iddocumento = '123456789';
          adjuntos.add(adjunto1);

          SACH_WS_AltaCasoPromor.Adjunto adjunto2 = new SACH_WS_AltaCasoPromor.Adjunto();
          adjunto2.nombreadjunto = 'prueba nombre adjunto2a';
          adjunto2.tipodocumento = 'tipodedocumento prueba2a';
          adjunto2.iddocumento = '000000000';
          adjuntos.add(adjunto2);

          SACH_WS_AltaCasoPromor.Adjunto adjunto3 = new SACH_WS_AltaCasoPromor.Adjunto();
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
          
          Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
       Contact contactonuevo = [SELECT AV_NumPerso__c,Id,CC_NumPerso__c,RecordTypeId FROM Contact WHERE AccountId = :cuentaB.Id];
        //contactonuevo.AV_NumPerso__c = '25345561';
        //contactonuevo.RecordTypeId = rtContactCliente;
        //update contactonuevo;

         // Crear y insertar Contact de prueba
         //Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contacto nuevo', AV_NumPerso__c = '25345561');
         //insert testContact;
        
         /*
         Case caso = new Case();
         caso.RecordTypeId = idRecordTypeSACH;
         caso.ContactId = contactonuevo.Id;
         caso.Subject = 'comprobacionContactoAI';   
        insert caso;*/

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
        SACH_WS_AltaCasoPromor.Output output = SACH_WS_AltaCasoPromor.registrarCasoPromor();
        Test.stopTest();

        // Verificamos los resultados esperados
        System.assertEquals('OK', output.resultado);
        System.assertNotEquals(null, output.caseId);

        }
    }

    @isTest
    static void registrarCasoPromorconCasoAsociadoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

          Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
          Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contactdsfsdf', AV_NumPerso__c = '14336037');
          insert testContact;
  
          Account cuenta = new Account();
          cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
          cuenta.Name = 'account temp';
          cuenta.CC_Numero_Oficina__c = '00256';
          cuenta.CC_Numero_Empresa__c = '001';
          insert cuenta;
        
         // Creamos un objeto RestRequest simulado
         RestRequest request = new RestRequest();
         request.requestURI = '/services/apexrest/AltaCasoPromor';
         request.httpMethod = 'POST';
      

        SACH_WS_AltaCasoPromor.Adjunto adjunto1 = new SACH_WS_AltaCasoPromor.Adjunto();
        adjunto1.iddocumento = '1111';
        adjunto1.nombreadjunto = 'Prueba 1';
        adjunto1.tipodocumento = 'Tipo 1';

        SACH_WS_AltaCasoPromor.Actividad actividad1 = new SACH_WS_AltaCasoPromor.Actividad();
        actividad1.codactividad = '700';
        actividad1.comentarios = 'Comentario1';
        actividad1.adjuntos = new List<SACH_WS_AltaCasoPromor.Adjunto>{adjunto1};

        // Creamos un objeto de entrada simulado
        SACH_WS_AltaCasoPromor.Input input = new SACH_WS_AltaCasoPromor.Input();
        input.demanda = 'Demanda de prueba';
        input.iddemanda = '1234567890';
        input.contrato = 12345;
        input.oficinagestora = '001-00256';
        input.pacto = '299';
        input.numperso = '14336037';
        input.actividades = new List<SACH_WS_AltaCasoPromor.Actividad>{actividad1};
        
        //casoAntiguo = [SELECT Status, CC_MCC_Solucion__c FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];

       

        Contact contactoIdentificado = SACH_Identificacion_Auto.identificarNUMPERSOsinCodificar(input.numperso);
        system.debug('El contacto que nos traemos es : ' + contactoIdentificado);
          
        Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.RecordTypeId = idRecordTypeSACH;
        //caso1.AccountId = cuenta.Id;
        caso1.Status = 'Cerrado';
        caso1.ContactId = contactoIdentificado.Id;
        caso1.Subject = 'comprobacionContactoAI';    
       insert caso1;


       String numeroEmpresa = input.oficinagestora.substring(0, 3);
       String numeroOficina = input.oficinagestora.substring(input.oficinagestora.length() - 5);
        Id idOficinaGestora;
        List<Account> oficinasGestoras = [SELECT Id FROM Account WHERE CC_Numero_Empresa__c =:numeroEmpresa AND CC_Numero_Oficina__c = :numeroOficina  AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
	
			  //List<Account> oficinasGestoras = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = :input.oficinagestora AND RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
			  if (!oficinasGestoras.isEmpty()) {
				  idOficinaGestora = oficinasGestoras[0].Id;
			  }


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
        //Output output;
        case casoExistente = [SELECT Status, CC_MCC_Solucion__c FROM Case WHERE RecordType.DeveloperName = 'SACH_Cliente' AND ContactId = :contactoIdentificado.Id LIMIT 1];
        system.debug('El caso se ha creado correctamente : ' + casoExistente);

        //Ejecutamos la función principal del proceso del Web Service
        //SACH_WS_AltaCasoPromor.gestionPeticionPromor(input, output,peticionRest,caso1,contactoIdentificado,idOficinaGestora);
			
        SACH_WS_AltaCasoPromor.Output output = SACH_WS_AltaCasoPromor.registrarCasoPromor();
        Test.stopTest();

        // Verificamos los resultados esperados
       System.assertEquals('OK', output.resultado);
        }
    }

    @isTest
    static void resgistrarcaso() {
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

          Id rtContactCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
          Contact testContact = new Contact(RecordTypeId = rtContactCliente, LastName = 'Test Contactdsfsdf', AV_NumPerso__c = '14336038');
          insert testContact;
  
          Account cuenta = new Account();
          cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
          cuenta.Name = 'account temp';
          cuenta.CC_Numero_Oficina__c = '00256';
          cuenta.CC_Numero_Empresa__c = '001';
          insert cuenta;
        
          CC_MCC__c mccSolucion = [SELECT Id FROM CC_MCC__c WHERE Name = 'Suspensión actuaciones por instrucción del SACH (715)'];

        Id idRecordTypeSACH = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.RecordTypeId = idRecordTypeSACH;
        caso1.CC_MCC_Solucion__c = mccSolucion.Id; 
        //caso1.AccountId = cuenta.Id;
        caso1.Status = 'Pendiente Colaborador';
        caso1.ContactId = testContact.Id;
        caso1.Subject = 'comprobacionContactoAI';    
       insert caso1;

         // Creamos un objeto RestRequest simulado
         RestRequest request = new RestRequest();
         request.requestURI = '/services/apexrest/AltaCasoPromor';
         request.httpMethod = 'POST';
      

        SACH_WS_AltaCasoPromor.Adjunto adjunto1 = new SACH_WS_AltaCasoPromor.Adjunto();
        adjunto1.iddocumento = '1111';
        adjunto1.nombreadjunto = 'Prueba 1';
        adjunto1.tipodocumento = 'Tipo 1';

        SACH_WS_AltaCasoPromor.Actividad actividad1 = new SACH_WS_AltaCasoPromor.Actividad();
        actividad1.codactividad = '700';
        actividad1.comentarios = 'Comentario1';
        actividad1.adjuntos = new List<SACH_WS_AltaCasoPromor.Adjunto>{adjunto1};

        // Creamos un objeto de entrada simulado
        SACH_WS_AltaCasoPromor.Input input = new SACH_WS_AltaCasoPromor.Input();
        input.demanda = 'Demanda de prueba';
        input.iddemanda = '1234567890';
        input.contrato = 12345;
        input.oficinagestora = '001-00256';
        input.pacto = '299';
        input.numperso = '14336038';
        input.actividades = new List<SACH_WS_AltaCasoPromor.Actividad>{actividad1};
        
        Contact contactoIdentificado2 = SACH_Identificacion_Auto.identificarNUMPERSOsinCodificar(input.numperso);
        
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
        //Test.setCreatedDate(caso1.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 18, 0, 0));
        Test.startTest();
        SACH_WS_AltaCasoPromor.Output output = SACH_WS_AltaCasoPromor.registrarCasoPromor();
        Test.stopTest();

        // Verificamos los resultados esperados
       System.assertEquals('OK', output.resultado);
        }
    }

}