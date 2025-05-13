@isTest
public with sharing class FRA_Llamada_GC_Test {
   
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
            
    		Test.startTest();
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
            Test.startTest();
    
            Case caso1 = FRA_Llamada_GC.crearCaso(llamada1, servicio, true, false);
            Case caso2 = FRA_Llamada_GC.crearCaso(llamada2, servicio, false, false);
                System.assertEquals(caso1.CC_ContactoRelacionado__c, llamada1.CC_Contacto__c);
                System.assertEquals(caso1.CC_Oficina__c, llamada1.CC_Cuenta__c);   
                System.assertEquals(caso2.ContactId, llamada2.CC_Contacto__c);
                System.assertEquals(caso2.AccountId, llamada2.CC_Cuenta__c);
            }  
            Test.stopTest();   
    }
}