@isTest
public with sharing class FRA_Llamada_GC_Test {
    @TestSetup
	private static void testSetup() {

        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta Test asw vv';
        cuenta.CC_NumPerso__c = '777';
        //cuenta.CC_OficinaGestoraId__c = listaCuentas[3].Id;
        //cuenta.AV_OficinaPrincipal__c = listaCuentas[3].Id;
        //cuenta.AV_EAPGestor__c = listaContactos[3].Id;
        insert cuenta;

        Contact contacto2 = new Contact();
        contacto2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto2.FirstName = 'Contacto mio';
        contacto2.LastName = 'Contacto Test mio';
        contacto2.AccountId = cuenta.Id;
        insert contacto2;

    CC_MCC__c tematica = new CC_MCC__c();
    tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
    tematica.CC_Tipo_Cliente__c = 'Cliente';
    tematica.Name = 'Temática';
    tematica.CC_Codigo_Externo__c = 'T1';
    tematica.CC_Canal_Operativo__c = 'Oficina';
    insert tematica;

    CC_MCC__c producto = new CC_MCC__c();
    producto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
    producto.CC_Tipo_Cliente__c = 'Cliente';
    producto.Name = 'Producto';
    producto.CC_Tematica__c = tematica.Id;
    producto.CC_Codigo_Externo__c = 'P1';
    insert producto;

    CC_MCC__c motivo = new CC_MCC__c();
    motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
    motivo.CC_Tipo_Cliente__c = 'Cliente';
    motivo.Name = 'Motivo';
    motivo.CC_Producto_Servicio__c = producto.Id;
    motivo.CC_Codigo_Externo__c = 'M1';
    insert motivo;

    CC_MCC__c causa = new CC_MCC__c();
    causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
    causa.CC_Tipo_Cliente__c = 'Cliente';
    causa.Name = 'Causa';
    causa.CC_Motivo__c = motivo.Id;
    causa.CC_Codigo_Externo__c = 'C1';
    insert causa;

    CC_MCC__c solucion = new CC_MCC__c();
    solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
    solucion.CC_Tipo_Cliente__c = 'Cliente';
    solucion.Name = 'Solucion';
    solucion.CC_Causa__c = causa.Id;
    solucion.CC_Codigo_Externo__c = 'S1';
    insert solucion;

    Case casoCliente = new Case();
			casoCliente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			casoCliente.Subject = 'Caso cliente Test';

			casoCliente.Origin = 'Phone';
			casoCliente.CC_Canal_Respuesta__c = 'Phone';
			casoCliente.CC_Tipo_Cliente__c = 'Cliente';
			casoCliente.CC_No_Identificado__c = true;
			casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
			casoCliente.CC_MCC_Tematica__c = tematica.Id;
			casoCliente.CC_MCC_ProdServ__c = producto.Id;
			casoCliente.CC_MCC_Motivo__c = motivo.Id;
			casoCliente.CC_MCC_Causa__c = causa.Id;
			casoCliente.CC_MCC_Solucion__c = solucion.Id;
            casoCliente.AccountId = cuenta.Id;
            casoCliente.ContactId = contacto2.Id;
        
        insert casoCliente;

    }
   
	private static CC_Servicio_Genesys__c crearServicio() {
        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(
            Name = 'Fraude Canal Oficina',
            CC_Codigo__c = 'HUB_FRAUCAOFI',
            CC_VDN__c = '1',
            CC_Tipo__C = 'Servicio',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina',
            CC_Canal_de_Entrada__c = 'Telefono',
            CC_Fecha_Inicio_Salesforce__c = date.today(),
            CC_Tipo_Cliente__c = 'Empleado'
        );
        insert servicio;
        return servicio;
    }

    private static Contact crearContacto() {
        
        Account cuenta = new Account (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
            Name = 'Cuenta',
            CC_NumPerso__c = '666'
        );
        insert cuenta;

        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            FirstName = 'Contacto',
            LastName = 'Contacto',
            AccountId = cuenta.Id,
            MobilePhone = '642462269'
        );
        insert contacto;
        return contacto;
    }

    private static Case crearCasoConContacto(String idcont) {
        Contact contacto = [SELECT Id,Account.CC_NumPerso__c,AccountId FROM Contact where Id = :idcont];
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Prueba',
            Origin = 'Phone',
            CC_Canal_Respuesta__c = 'Phone',
            CC_Tipo_Cliente__c = 'Empleado',
            CC_Idioma__c = 'es',
            AccountId = contacto.AccountId,
            ContactId = contacto.Id,
            CC_No_Identificado__c = false,
            CC_Canal_Resolucion__c = 'Teléfono FRAUDE Canal Oficina',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina'
        );           
        insert caso;
        return caso;
    }

    private static Case crearCasoSinContacto() {
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Prueba',
            Origin = 'Phone',
            CC_Idioma__c = 'es',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina'
        );
        insert caso;
        return caso;
    }

    private static CC_Llamada__c crearLlamada() {
        CC_Llamada__c llamada = new CC_Llamada__c (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente'),
            CC_No_Identificado__c = false,
            CC_IdentCliente__c = '0'
        );          
        insert llamada;
        return llamada;
    }

    private static Task crearTarea() {
        Task tarea = new Task (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task'),
            Subject = 'Consulta',
            Status = 'Open',
            Priority = 'Normal'
        );
        insert tarea;
        return tarea;
    }
  
    @isTest 
    public static void testRegistrarLlamadaEntrante() {   
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            
        	crearServicio();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
            Test.startTest();
            Map<String, Object> mapa = FRA_Llamada_GC.registrarLlamadaEntrante(input);
            System.assert(mapa.get('llamada') != null && mapa.get('caso') != null);
    
            Test.stopTest();
        }  
    }
    
    @isTest 
    public static void testRegistrarLlamadaSaliente() {
        
       
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {

            Test.startTest();
            
             Contact contact = crearContacto();
            Case miCase = crearCasoConContacto(contact.Id);
            crearServicio();
            
         
            
            CC_Llamada_Input input1 = new CC_Llamada_Input();
            input1.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input1.dnis = '888999000';
            input1.casoId = miCase.Id;
    
            CC_Llamada_Input input2 = new CC_Llamada_Input();
            input2.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input2.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input2.dnis = '888999000';
            input2.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
    
            CC_Llamada_Input input3 = new CC_Llamada_Input();
            input3.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input3.dnis = '888999000';
            input3.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
            
    		
            Map<String, Object> mapa1 = FRA_Llamada_GC.registrarLlamadaSaliente(input1);
            Map<String, Object> mapa2 = FRA_Llamada_GC.registrarLlamadaSaliente(input2);
            Map<String, Object> mapa3 = FRA_Llamada_GC.registrarLlamadaSaliente(input3);
                System.assert(mapa1.get('llamada') != null);
                System.assert(mapa2.get('llamada') != null);
                System.assert(mapa3.get('llamada') != null);
            }    
            Test.stopTest();  
    }

    @isTest
    public static void testRegistrarConsulta() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamadaInicial = crearLlamada();
            Case caso = crearCasoSinContacto();
            crearServicio();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.salesforceParentId = llamadaInicial.Id;
            input.casoId = caso.Id;
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.idioma = 'Castellano';
            Test.startTest();
            String servicioGen='IMAGING';
            Map<String, Object> mapa = FRA_Llamada_GC.registrarConsulta(input,servicioGen);
                System.assert(mapa.get('llamada') != null && mapa.get('caso') != null);
            }
        	Test.stopTest();      
    }

    @isTest
    public static void testRegistrarblindTransfer() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamadaInicial = crearLlamada();
            Case caso = crearCasoSinContacto();
            crearServicio();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.salesforceParentId = llamadaInicial.Id;
            input.casoId = caso.Id;
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.idioma = 'Castellano';
            String servicioGen='IMAGING';
            
            Test.startTest();
            Map<String, Object> mapa = FRA_Llamada_GC.registrarblindTransfer(input,servicioGen);
                System.assert(mapa.get('llamada') != null && mapa.get('caso') != null);
            }
            Test.stopTest();    
    }

    @isTest
    public static void testBuscarLlamada() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamada = crearLlamada();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.llamadaId = llamada.Id;
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            
    		Test.startTest();
            String resultado = FRA_Llamada_GC.buscarLlamada(input, false);

            System.assert(resultado != null);
    
            Test.stopTest();
        }
    }

    @isTest
    public static void testRegistrarACW() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamada1 = crearLlamada();
            List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();
            llamadas.add(llamada1);
            CC_Llamada_Input input = new CC_Llamada_Input();
    		Test.startTest();
            FRA_Llamada_GC.registrarACW(input);
            FRA_Llamada_GC.finalizarLlamadas(llamadas, 'Llamada finalizada');
            for (CC_Llamada__c llamada : llamadas) {
                System.assert(llamada.CC_Tipo_Cierre__c == 'Llamada finalizada');   
            }
            Test.stopTest();
        }   
    }

    @isTest
    public static void testFinalizarLlamada() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            
			CC_Llamada__c llamada1 = crearLlamada();
        	List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();
            llamadas.add(llamada1);
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.llamadaId = llamada1.Id;
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            
    		Test.startTest();
            FRA_Llamada_GC.finalizarLlamada(input, null);
            FRA_Llamada_GC.finalizarLlamadaActividades(llamada1, 'Llamada entrante', 'Llamada finalizada');
            FRA_Llamada_GC.finalizarLlamadas(llamadas, 'Llamada finalizada');
            for (CC_Llamada__c llamada : llamadas) {
                System.assert(llamada.CC_Tipo_Cierre__c == 'Llamada finalizada');   
            }
    
            Test.stopTest();
        }
    }

    @isTest
    public static void testFinalizarConsulta() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            
			CC_Llamada__c llamada1 = crearLlamada();
        	List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();
            llamadas.add(llamada1);
            CC_Llamada_Input input1 = new CC_Llamada_Input();
            input1.llamadaId = llamada1.Id;
            input1.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
    
            // CC_Llamada_Input input2 = new CC_Llamada_Input();
    		Test.startTest();
            FRA_Llamada_GC.finalizarConsulta(input1, 'Consulta completada');
            FRA_Llamada_GC.finalizarLlamadaActividades(llamada1, 'Consulta%', 'Consulta completada');
            FRA_Llamada_GC.finalizarLlamadas(llamadas, 'Consulta completada');
            for (CC_Llamada__c llamada : llamadas) {
                System.assert(llamada.CC_Tipo_Cierre__c == 'Consulta completada');   
            }
            Boolean finalizaConsulta1 = FRA_Llamada_GC.finalizarConsulta(input1, 'Consulta completada');
            // Boolean finalizaConsulta2 = FRA_Llamada_GC.finalizarConsulta(input2, 'Consulta completada');
    
            Test.stopTest();
        }   
    }

    @isTest
    public static void testFinalizarConsultaExterna() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamadaInicial = crearLlamada();
            List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();
            llamadas.add(llamadaInicial);
            Case caso = crearCasoSinContacto();
            Task tarea = crearTarea();
            tarea.WhatId = caso.Id;
            
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.casoId = caso.Id;
            input.salesforceParentId = llamadaInicial.Id;
            input.llamadaId = llamadaInicial.Id;
			Test.startTest();
            FRA_Llamada_GC.finalizarConsultaExterna(input, 'Llamada finalizada');
            FRA_Llamada_GC.finalizarLlamadaActividades(llamadaInicial, 'Consulta%', 'Llamada finalizada');
            FRA_Llamada_GC.finalizarLlamadas(llamadas, 'Llamada finalizada');
        
            for (CC_Llamada__c llamada : llamadas) {
                System.assert(llamada.CC_Tipo_Cierre__c == 'Llamada finalizada');   
            }
        }
        Test.stopTest(); 
    }

    @isTest
    public static void testIniciarTransferenciaCiega() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamada = crearLlamada();
        	Case caso = crearCasoSinContacto();

        	CC_Llamada_Input input = new CC_Llamada_Input();
        	Test.startTest();

        	FRA_Llamada_GC.iniciarTransferenciaCiega(input, 'Llamada transferida');
        	Id idActividad = FRA_Llamada_GC.crearActividad(llamada.Id, caso.Id, 'Llamada transferencia Ciega', 'Iniciada', 'Llamada transferida');
            	System.assert(idActividad != null);
        	}
        	Test.stopTest();
    }

    @isTest
    public static void testCompletarConsulta() {
        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Llamada__c llamadaCliente = crearLlamada();
        	List<CC_Llamada__c> llamadasClientes = new List<CC_Llamada__c>();
            llamadasClientes.add(llamadaCliente);
            CC_Llamada__c consulta = crearLlamada();
            consulta.CC_ConnId_Consulta__c = 'ef208127-2e21-4086-b016-febfa4c43384';
            consulta.CC_Fecha_Fin__c = null;
            consulta.OwnerId = [SELECT Id FROM User LIMIT 1].Id;
            consulta.KIN_Consulta__c = true;
            consulta.CC_ConnId__c = consulta.CC_ConnId_Consulta__c;
            consulta.CC_Llamada_Padre__c = llamadaCliente.Id;
            Case caso = crearCasoSinContacto();
            consulta.CC_Case_Consulta__c = caso.Id;
            Test.startTest();
    
            String connIdConsulta = consulta.CC_ConnId_Consulta__c;
            Id idNuevoOwner = consulta.OwnerId;
            FRA_Llamada_GC.finalizarActividadesLlamada(consulta, 'Consulta%', 'Consulta completada');
            FRA_Llamada_GC.crearActividad(consulta.Id, consulta.CC_Case_Consulta__c, 'Llamada transferida', 'Fraude Canal Oficina', 'Llamada transferida');
            FRA_Llamada_GC.actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner, 'Teléfono FRAUDE Canal Oficina');
            FRA_Llamada_GC.finalizarLlamadaActividades(llamadaCliente, 'Llamada%', 'Llamada finalizada');
            FRA_Llamada_GC.finalizarLlamadas(llamadasClientes, 'Llamada finalizada');
                for (CC_Llamada__c llamada : llamadasClientes) {
                    System.assert(llamada.CC_Tipo_Cierre__c == 'Llamada finalizada');   
                }
           	Test.stopTest(); 
            }    
              
    }

    @isTest
    public static void testCrearCaso() {
        

        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            Test.startTest();

            CC_Servicio_Genesys__c servicio = crearServicio();
            Contact contacto = crearContacto();
            CC_Llamada__c llamada1 = crearLlamada();
            llamada1.CC_Asunto__c = 'Llamada Entrante';
            llamada1.CC_ANI__c = '642462269';
            llamada1.CC_Idioma__c = 'es';
            llamada1.CC_Contacto__c = contacto.Id;
            llamada1.CC_Cuenta__c = contacto.AccountId;
            CC_Llamada__c llamada2 = crearLlamada();
            llamada2.CC_Asunto__c = 'Llamada Entrante';
            llamada2.CC_ANI__c = '642462269';
            llamada2.CC_Idioma__c = 'es';
            llamada2.CC_Contacto__c = contacto.Id;
            llamada2.CC_Cuenta__c = contacto.AccountId;
            
            Case caso = null;

    
            Case caso1 = FRA_Llamada_GC.crearCaso(llamada1, servicio, true, false,caso);
            Case caso2 = FRA_Llamada_GC.crearCaso(llamada2, servicio, false, false,caso);
                System.assertEquals(caso1.CC_ContactoRelacionado__c, llamada1.CC_Contacto__c);
                System.assertEquals(caso1.CC_Oficina__c, llamada1.CC_Cuenta__c);   
                System.assertEquals(caso2.ContactId, llamada2.CC_Contacto__c);
                System.assertEquals(caso2.AccountId, llamada2.CC_Cuenta__c);
            }  
            Test.stopTest();   
    }

    @isTest
    public static void testCrearCasodesdeCC() {
       
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
       // System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            Case casoEmpleado = new Case();
			casoEmpleado.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			casoEmpleado.Subject = 'Caso empleado Test';
			casoEmpleado.Origin = 'Phone';
			casoEmpleado.CC_Canal_Respuesta__c = 'Phone';
			casoEmpleado.CC_Tipo_Cliente__c = 'Empleado';
			casoEmpleado.CC_No_Identificado__c = true;
			casoEmpleado.CC_Canal_Procedencia__c = 'RRHH';
			casoEmpleado.CC_Canal_Resolucion__c = 'RRHH';

            Test.startTest();

            Case casoContact = [SELECT Id,Subject,CC_Canal_Contacto__c,CC_Idioma__c,CC_Tipo_Contacto__c,Origin,CC_Detalles_Consulta__c,CC_Detalles_Solucion__c,
            CC_ContactoRelacionado__c,CC_Oficina__c,CC_CasoRelacionado__c,Comments,CC_MCC_Tematica__r.Name,Description,CC_MCC_Motivo__c,CC_MCC_Tematica__c,
            CC_MCC_ProdServ__c
            from Case WHERE CC_Canal_Procedencia__c = 'CaixaBankNow' LIMIT 1];

        
            CC_Servicio_Genesys__c servicio = crearServicio();
           Contact contacto = crearContacto();
            //Contact contacto = [SELECT Id from Contact WHERE FirstName = 'Contacto mio' LIMIT 1];

           // Contact contacto = [SELECT Id,AccountId FROM Contact WHERE FirstName = 'Contacto mio'];

            CC_Llamada__c llamada1 = crearLlamada();
            llamada1.CC_Asunto__c = 'Llamada Entrante';
            llamada1.CC_ANI__c = '642462269';
            llamada1.CC_Idioma__c = 'es';
            llamada1.CC_Contacto__c = contacto.Id;
            llamada1.CC_Cuenta__c = contacto.AccountId;
            CC_Llamada__c llamada2 = crearLlamada();
            llamada2.CC_Asunto__c = 'Llamada Entrante';
            llamada2.CC_ANI__c = '642462269';
            llamada2.CC_Idioma__c = 'es';
            llamada2.CC_Contacto__c = contacto.Id;
            llamada2.CC_ConnId_Consulta__c = 'ef208127-2e21-4086-b016-febfa4c43384';
            llamada2.CC_Cuenta__c = contacto.AccountId;
            llamada2.CC_ConnId__c = llamada2.CC_ConnId_Consulta__c;
           
            Case caso = null;

            
            Case caso1 = FRA_Llamada_GC.crearCaso(llamada1, servicio, false, true,casoContact);
           
            //Case caso2 = FRA_Llamada_GC.crearCaso(llamada2, servicio, false, false,caso);
            System.assertEquals(caso1.Subject, 'Caso cliente Test');

            //System.assertEquals(caso1.CC_ContactoRelacionado__c, llamada1.CC_Contacto__c);
               // System.assertEquals(caso1.CC_Oficina__c, llamada1.CC_Cuenta__c);   
               // System.assertEquals(caso2.ContactId, llamada2.CC_Contacto__c);
                //System.assertEquals(caso2.AccountId, llamada2.CC_Cuenta__c);
            }  
            Test.stopTest();   
    }


}