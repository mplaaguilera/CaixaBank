@isTest
public class HDT_Caracteristica_Test {
    @isTest static void testSetup() {  
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {


        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;
        
        Account cuentaCentro = new Account();
        cuentaCentro.Name = 'Centro Caixabank 1';
        cuentaCentro.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        insert cuentaCentro;
        
        Account cuentaCliente = new Account();
        cuentaCliente.Name = 'Cliente 1';
        cuentaCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuentaCliente;
              
        Id accountId = cuenta.Id;
        
        Id recordtypecliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Id recordtypeempleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordtypecliente;
        insert contacto; 
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto2';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345560';
        contacto2.AccountId = cuenta.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = recordtypeempleado;
        insert contacto2;       

        Id cId = contacto.Id;
        
        Case caso = new Case();
       	caso.ContactId = contacto.Id;
       	caso.CC_Idioma__c ='es';
        caso.Status = 'Cerrado';
        caso.CC_Canal_Contacto__c = 'Chat';
        caso.CC_Canal_Procedencia__c = 'SmartPhones';
        caso.Reason = 'Helpdesk';
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
        caso.Origin='Chat';
        insert caso;
        
        Case casoCliente = new Case();
       	casoCliente.AccountId = cuentaCliente.Id;
       	casoCliente.CC_Idioma__c ='es';
        casoCliente.Status = 'Cerrado';
        casoCliente.CC_Canal_Contacto__c = 'Chat';
        casoCliente.CC_Canal_Procedencia__c = 'SmartPhones';
        casoCliente.Reason = 'Helpdesk';
        casoCliente.Origin='Chat';
        casoCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
        insert casoCliente;
        
        Case casoCentro = new Case();
       	casoCentro.AccountId = cuentaCentro.Id;
       	casoCentro.CC_Idioma__c ='es';
        casoCentro.Status = 'Cerrado';
        casoCentro.CC_Canal_Contacto__c = 'Chat';
        casoCentro.CC_Canal_Procedencia__c = 'SmartPhones';
        casoCentro.Reason = 'Helpdesk';
        casoCentro.Origin='Chat';
        casoCentro.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
        insert casoCentro;
        
        List<CC_Caracteristica__c> caracteristicas = new List<CC_Caracteristica__c>();
            
        CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c();
        caracteristica1.Name = 'Característica 1';
        caracteristica1.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica1.CC_Prioridad__c = '2 - Media';
        caracteristica1.CC_Avisar_agente__c = true;
        caracteristica1.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        caracteristica1.OS_Negocio__c = 'HDT';
       	caracteristicas.add(caracteristica1);
        //insert caracteristica1;
        //Id caracteristica1Id = caracteristica1.Id;

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
        caracteristica2.Name = 'Característica 2';
        caracteristica2.CC_Descripcion__c = 'Esta es la descripción de la segunda característica y ocupa más de cincuenta caracteres.';
        caracteristica2.CC_Prioridad__c = '1 - Alta';
        caracteristica2.CC_Avisar_agente__c = true;
        caracteristica2.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        caracteristica2.OS_Negocio__c = 'HDT';
        //insert caracteristica2;
        caracteristicas.add(caracteristica2);
        //Id caracteristica2Id = caracteristica2.Id;

        CC_Caracteristica__c caracteristica3 = new CC_Caracteristica__c();
        caracteristica3.Name = 'Característica 3';
        caracteristica3.CC_Descripcion__c = 'Esta es la descripción de la tercera característica y ocupa más de cincuenta caracteres.';
        caracteristica3.CC_Prioridad__c = '3 - Baja';
        caracteristica3.CC_Avisar_agente__c = true;
        caracteristica3.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        caracteristica3.OS_Negocio__c = 'HDT';
        caracteristicas.add(caracteristica3);
        //Id caracteristica3Id = caracteristica3.Id;

        CC_Caracteristica__c caracteristica4 = new CC_Caracteristica__c();
        caracteristica4.Name = 'Característica 4';
        caracteristica4.CC_Descripcion__c = 'Esta es la descripción de la cuarta característica y ocupa más de cincuenta caracteres.';
        caracteristica4.CC_Prioridad__c = '3 - Baja';
        caracteristica4.CC_Avisar_agente__c = false;
        caracteristica4.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        caracteristica4.OS_Negocio__c = 'HDT';
        caracteristicas.add(caracteristica4);
        //Id caracteristica4Id = Caracteristica4.Id;
        
        CC_Caracteristica__c caracteristica5 = new CC_Caracteristica__c();
        caracteristica5.Name = 'Característica 5';
        caracteristica5.CC_Descripcion__c = 'Esta es la descripción de la quinta característica y ocupa más de cincuenta caracteres.';
        caracteristica5.CC_Prioridad__c = '3 - Baja';
        caracteristica5.CC_Avisar_agente__c = true;
        caracteristica5.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        caracteristica5.OS_Negocio__c = 'HDT';
        caracteristicas.add(caracteristica5);
        //Id caracteristica5Id = caracteristica5.Id;
        
            if(!caracteristicas.isEmpty()){
				Database.insert(caracteristicas);
            }     
            
        List <CC_Caracteristica_Detalle__c> caracteristicasDetalle = new List<CC_Caracteristica_Detalle__c>();

		CC_Caracteristica_Detalle__c caracteristicaDetalle1 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle1.CC_Caracteristica__c = caracteristicas.get(0).Id;
        caracteristicaDetalle1.CC_Cliente__c = contacto.Id;
        caracteristicaDetalle1.CC_Empleado__c = contacto2.Id;
        caracteristicaDetalle1.CC_Cuenta__c = cuenta.Id;
		caracteristicasDetalle.add(caracteristicaDetalle1);
        //insert caracteristicaDetalle1;

		CC_Caracteristica_Detalle__c caracteristicaDetalle2 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle2.CC_Caracteristica__c = caracteristicas.get(1).Id;
        caracteristicaDetalle2.CC_Cliente__c = contacto.Id;
        caracteristicaDetalle2.CC_Empleado__c = contacto2.Id;
        caracteristicaDetalle1.CC_Cuenta__c = cuenta.Id;
        caracteristicasDetalle.add(caracteristicaDetalle2);
        //insert caracteristicaDetalle2;

		CC_Caracteristica_Detalle__c caracteristicaDetalle3 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle3.CC_Caracteristica__c = caracteristicas.get(2).Id;
        caracteristicaDetalle3.CC_Cliente__c = contacto.Id;
        caracteristicaDetalle3.CC_Empleado__c = contacto2.Id;
        caracteristicaDetalle1.CC_Cuenta__c = cuenta.Id;
        caracteristicasDetalle.add(caracteristicaDetalle3);
        //insert caracteristicaDetalle3;

		CC_Caracteristica_Detalle__c caracteristicaDetalle4 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle4.CC_Caracteristica__c = caracteristicas.get(3).Id;
        caracteristicaDetalle4.CC_Cliente__c = contacto.Id;
        caracteristicaDetalle4.CC_Empleado__c = contacto2.Id;
        caracteristicaDetalle1.CC_Cuenta__c = cuenta.Id;
        caracteristicasDetalle.add(caracteristicaDetalle4);
        //insert caracteristicaDetalle4;
        
		CC_Caracteristica_Detalle__c caracteristicaDetalle5 = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalle5.CC_Caracteristica__c = caracteristicas.get(4).Id;
        caracteristicaDetalle5.CC_Cliente__c = contacto.Id;
        caracteristicaDetalle5.CC_Empleado__c = contacto2.Id;
        caracteristicaDetalle1.CC_Cuenta__c = cuenta.Id;
        caracteristicasDetalle.add(caracteristicaDetalle5);
        //insert caracteristicaDetalle5;
        
            if(!caracteristicasDetalle.isEmpty()){
				Database.insert(caracteristicasDetalle);
            }  
       
        CC_Caracteristica_Detalle__c caracteristicaDetalleCuentaCentro = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalleCuentaCentro.CC_Caracteristica__c = caracteristica4.Id;
        caracteristicaDetalleCuentaCentro.CC_Centro_CaixaBank__c = cuentaCentro.Id;
        insert caracteristicaDetalleCuentaCentro;  

        
        CC_Caracteristica_Detalle__c caracteristicaDetalleCuentaCliente = new CC_Caracteristica_Detalle__c();
        caracteristicaDetalleCuentaCliente.CC_Caracteristica__c = Caracteristica4.Id;
        caracteristicaDetalleCuentaCliente.CC_Cuenta__c = cuentaCliente.Id;
        insert caracteristicaDetalleCuentaCliente;     
        
        
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
		insert chatVisitor;        
        
        LiveChatTranscript chat = new LiveChatTranscript();
        chat.CaseId = caso.Id;        
        chat.AccountId = cuenta.Id;
        chat.CC_Cerrado_TimeOut__c = false;
        chat.CC_Idioma__c = 'es';
        chat.CC_NumPerso__c = contacto.CC_NumPerso__c;
        chat.CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&#191;C&#243;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }';
        chat.LiveChatVisitorId = chatVisitor.Id;
        insert chat;
        
        
        // INICIO DE TESTS
        List<CC_Caracteristica_Detalle__c> test1 = HDT_Caracteristica.conseguirCaracteristica(CaracteristicaDetalle1.CC_Cliente__c);
        List<CC_Caracteristica_Detalle__c> test1a = HDT_Caracteristica.conseguirCaracteristica(CaracteristicaDetalle1.CC_Empleado__c);
        List<CC_Caracteristica_Detalle__c> test1b = HDT_Caracteristica.conseguirCaracteristica(CaracteristicaDetalle1.CC_Cuenta__c);
            
                // Verificamos que la lista retornada contiene 4 características
                System.assertEquals(5, test1.size());
         

                // Verificamos que las características retornadas están ordenadas por prioridad
                System.assertEquals(Caracteristica2.Id, test1[0].CC_Caracteristica__r.Id);
                System.assertEquals(Caracteristica2.CC_Descripcion__c, test1[0].CC_Caracteristica__r.CC_Descripcion__c);
                System.assertEquals(caracteristica1.Id, test1[1].CC_Caracteristica__r.Id);
                System.assertEquals(caracteristica1.CC_Descripcion__c, test1[1].CC_Caracteristica__r.CC_Descripcion__c);
        
    
        List<String> test2 = HDT_Caracteristica.getAvisosCaracteristicas(chat.Id);
		// Verificamos que la lista retornada contiene 3 avisos
        System.assertEquals(3, test2.size());
        
        List<CC_Caracteristica_Detalle__c> test3 = HDT_Caracteristica.getCaracteristicasConAviso(chat.Id);
        // Verificamos que la lista retornada contiene 4 características
        System.assertEquals(4, test3.size());
        // Verificamos que las características retornadas están ordenadas por prioridad
        System.assertEquals(Caracteristica2.Id, test3[0].CC_Caracteristica__r.Id);
        System.assertEquals(Caracteristica2.CC_Descripcion__c, test1[0].CC_Caracteristica__r.CC_Descripcion__c);
        System.assertEquals(caracteristica1.Id, test3[1].CC_Caracteristica__r.Id);
        System.assertEquals(caracteristica1.CC_Descripcion__c, test1[1].CC_Caracteristica__r.CC_Descripcion__c);
        
        List<Id> listaTest = new List<Id>();
        listaTest.add(caso.Id);
        listaTest.add(casoCentro.Id);
        
        HDT_Caracteristica.RelacionarCaso(listaTest);

        // Paso 3: Verificar los resultados
        List<CC_Caracteristica_Case__c> caracteristicasCreated = [SELECT Id, CC_Case__c, CC_Caracteristica__c FROM CC_Caracteristica_Case__c WHERE CC_Case__c = :caso.Id];
        System.assertEquals(5, caracteristicasCreated.size(), 'Debería haberse creado una característica de caso');
        
        }
    }

    @isTest
    public static void testAddLineBreaks() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
           
        // Arrange
        String originalString = 'This is a string that does not need line breaks.';
        String expectedString = 'This is a string that does not need line breaks.';
        
        // Act
        String result = HDT_Caracteristica.addLineBreaks(originalString);
        
        // Assert
        System.assertEquals(expectedString, result);
        }
    }

    @isTest
    public static void testConseguirCaracteristicaCuenta() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Crear registros de prueba necesarios
        Account cuenta = new Account(Name = 'Mi Cuenta de Prueba', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId());
        insert cuenta;

        Id recordtypecliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();

        CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c();
        caracteristica1.Name = 'Característica 1';
        caracteristica1.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica1.CC_Prioridad__c = '2 - Media';
        caracteristica1.CC_Avisar_agente__c = true;
        caracteristica1.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        insert caracteristica1;
        Id caracteristica1Id = caracteristica1.Id;

         
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = recordtypecliente;
        insert contacto; 

        Case caso = new Case();
        caso.ContactId = contacto.Id;
        contacto.AccountId = cuenta.Id;
        caso.CC_Idioma__c ='es';
         caso.Status = 'Cerrado';
        caso.CC_Canal_Contacto__c = 'Chat';
        caso.CC_Canal_Procedencia__c = 'SmartPhones';
        caso.Reason = 'Helpdesk';
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
        caso.Origin='Chat';
        insert caso;

        // Llamar al método a probar
        List<CC_Caracteristica_Detalle__c> resultado = HDT_Caracteristica.conseguirCaracteristicaCuenta(caso.Id);

        // Verificar resultados
        System.assertEquals(0, resultado.size(), 'Se espera un resultado');
       // CC_Caracteristica_Detalle__c detalle = resultado[0];
       // System.assertEquals('Característica de Prueba', detalle.Name, 'El nombre de la característica no coincide');
        // Puedes realizar más verificaciones aquí según tus necesidades y campos.

        // Probar el escenario sin un caso asociado
        List<CC_Caracteristica_Detalle__c> resultadoSinCaso = HDT_Caracteristica.conseguirCaracteristicaCuenta(null);
        System.assertEquals(0, resultadoSinCaso.size(), 'Se espera una lista vacía sin caso');

        // Probar el escenario sin registro encontrado
        Case casoSinRegistro = new Case();
        insert casoSinRegistro;
        List<CC_Caracteristica_Detalle__c> resultadoSinRegistro = HDT_Caracteristica.conseguirCaracteristicaCuenta(casoSinRegistro.Id);
        System.assertEquals(0, resultadoSinRegistro.size(), 'Se espera una lista vacía sin registro');

        // Puedes seguir añadiendo más casos de prueba según diferentes escenarios.
        }
    }


    /*
    @isTest 
    static void testRelacionarCaso() {
        Id recordtypeempleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Id recordtypecliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();

        // Paso 1: Crear datos de prueba
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testContact;
        
        Case testCase = new Case(ContactId = testContact.Id, Status = 'New', Subject = 'Test Case');
        insert testCase;

        
        
        Contact contacto2 = new Contact();
        contacto2.FirstName = 'Contacto2';
        contacto2.LastName = '02';
        contacto2.CC_NumPerso__c = '12345560';
        contacto2.AccountId = testAccount.Id;
        contacto2.CC_Idioma__c = 'Es';
        contacto2.RecordTypeId = recordtypeempleado;
        insert contacto2;       

        Case testCase2 = new Case(ContactId = contacto2.Id, Status = 'New', Subject = 'Test Case');
        insert testCase2;

        CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c();
        caracteristica1.Name = 'Característica 1';
        caracteristica1.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica1.CC_Prioridad__c = '2 - Media';
        caracteristica1.CC_Avisar_agente__c = true;
        caracteristica1.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        insert caracteristica1;

        CC_Caracteristica_Detalle__c testDetalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica1.Id,
            CC_Cliente__c = testContact.Id
        );
        insert testDetalle;

        CC_Caracteristica_Detalle__c testDetalle2 = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica1.Id,
            CC_Empleado__c = contacto2.Id
        );
        insert testDetalle2;
        
        // Paso 2: Invocar el método RelacionarCaso
        Test.startTest();
        HDT_Caracteristica.RelacionarCaso(new List<Id>{testCase.Id});
        HDT_Caracteristica.RelacionarCaso(new List<Id>{testCase2.Id});
        Test.stopTest();
        
        // Paso 3: Verificar los resultados
        List<CC_Caracteristica_Case__c> caracteristicasCreated = [SELECT Id, CC_Case__c, CC_Caracteristica__c FROM CC_Caracteristica_Case__c WHERE CC_Case__c = :testCase.Id];
        System.assertEquals(1, caracteristicasCreated.size(), 'Debería haberse creado una característica de caso');
    }*/

}