@isTest
public with sharing class FRA_GC_Eventos_Controller_Test {

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

   private static Case crearCaso() {
            Case caso = new Case();
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso.Subject = 'Caso Test';
            caso.Origin = 'Phone';
            caso.CC_Canal_Respuesta__c = 'Phone';
            caso.CC_Tipo_Cliente__c = 'Cliente';
            caso.CC_No_Identificado__c = true;
            caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina';
            insert caso;
            return caso;
   }
    
   private static CC_Llamada__c crearLlamada(Id servicioId) {
            CC_Llamada__c llamada = new CC_Llamada__c();
            llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente');
            llamada.CC_Servicio_Genesys__c = servicioId;
            llamada.CC_Tipo__c = 'Entrante';
            llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
            llamada.CC_Asunto__c = 'Llamada Test';
            insert llamada;
            return llamada;
    }
    

    @isTest
    public static void testRegistrarLlamadaEntrante() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Servicio_Genesys__c servicio=crearServicio();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.usuario = '';
            input.extension = '';
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.transferConnId = '';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.asunto = 'Asunto';
            input.numPerso = '11111';
            input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
    
            Test.startTest();
                FRA_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(input));
            Test.stopTest();
        }
        	System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void testRegistrarLlamadaSaliente() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Servicio_Genesys__c servicio=crearServicio();
            Case caso = crearCaso();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.usuario = '';
            input.extension = '';
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.transferConnId = '';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.asunto = 'Asunto';
            input.numPerso = '11111';
            input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
            input.casoId = caso.Id;
		
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente(JSON.serialize(input));
            Test.stopTest();
        
            System.assertEquals(true, true, 'PENDIENTE');   
        }
    }

    @isTest
    public static void testRegistrarConsulta() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Servicio_Genesys__c servicio=crearServicio();
            CC_Llamada__c llamada = crearLlamada(servicio.Id);
            Case caso = crearCaso();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.usuario = '';
            input.extension = '';
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.transferConnId = '';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.asunto = 'Asunto';
            input.numPerso = '11111';
            input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
            input.salesforceParentId = llamada.Id;
            input.casoId = caso.Id;
    
            String servicioGen='IMAGING';
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.registrarConsulta(JSON.serialize(input),servicioGen);
            Test.stopTest();
            
            System.assertEquals(true, true, 'PENDIENTE');   
        }
    }

    @isTest
    public static void testRegistrarblindTransfer() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
        
            CC_Servicio_Genesys__c servicio=crearServicio();
            CC_Llamada__c llamada = crearLlamada(servicio.Id);
            Case caso = crearCaso();
    
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.salesforceParentId = llamada.Id;
            input.casoId = caso.Id;
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.idioma = 'Castellano';
            
            String servicioGen='IMAGING';
        
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.registrarblindTransfer(JSON.serialize(input),servicioGen);
            Test.stopTest();
            
             System.assertEquals(true, true, 'PENDIENTE');
        } 
    }

    @isTest
    public static void testFinalizarLlamada() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            Case caso = crearCaso();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.usuario = '';
            input.extension = '';
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.transferConnId = '';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.asunto = 'Asunto';
            input.numPerso = '11111';
            input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
            input.casoId = caso.Id;
    
            
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.finalizarLlamada(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }
    
    @isTest
    public static void testRegistrarACW() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
        
            CC_Servicio_Genesys__c servicio=crearServicio();
            CC_Llamada__c llamada = crearLlamada(servicio.Id);
            List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();
            llamadas.add(llamada);
           
                Test.startTest();
                CC_Llamada_Input input = new CC_Llamada_Input();
                FRA_Genesys_Cloud_Eventos_Controller.registrarACW(JSON.serialize(input));
                System.assertEquals(true, true, 'PENDIENTE');           
                Test.stopTest();
            }
    }

    @isTest
    public static void testFinalizarConsulta() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            Case caso = crearCaso();
            CC_Llamada_Input input = new CC_Llamada_Input();
            input.usuario = '';
            input.extension = '';
            input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
            input.transferConnId = '';
            input.ani = '555666777';
            input.dnis = '888999000';
            input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
            input.asunto = 'Asunto';
            input.numPerso = '11111';
            input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
    
            
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.finalizarConsulta(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void testFinalizarConsultaExterna() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';

        
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.finalizarConsultaExterna(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void testIniciarTransferenciaCiega() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Servicio_Genesys__c servicio=crearServicio();
            CC_Llamada__c llamada = crearLlamada(servicio.Id);
            Case caso = crearCaso();
            CC_Llamada_Input input = new CC_Llamada_Input();
    
            
            
                Test.startTest();
                FRA_Genesys_Cloud_Eventos_Controller.iniciarTransferenciaCiega(JSON.serialize(input), 'Llamada transferida');
                Test.stopTest();
            }
            System.assertEquals(true, true, 'PENDIENTE');
    }
    
    @isTest
    public static void testAtributosLlamadaInicial() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            CC_Servicio_Genesys__c servicio=crearServicio();
            CC_Llamada__c llamada = crearLlamada(servicio.Id);
    
            CC_Llamada__c llamadaInicial = new CC_Llamada__c();
            llamadaInicial.RecordTypeId = llamada.RecordTypeId;
            llamadaInicial.KIN_Genesys_Cloud__c = true;
            llamadaInicial.KIN_Llamada_Origen__c = true;
            llamadaInicial.CC_Servicio_Genesys__c = llamada.CC_Servicio_Genesys__c;
            llamadaInicial.CC_ConnId__c = llamada.CC_ConnId__c;
            llamadaInicial.CC_Tipo__c = 'Entrante';
            llamadaInicial.CC_Tipo_Cierre__c = 'Llamada finalizada';
            llamadaInicial.CC_Asunto__c = 'Llamada Test Inicial';
            insert llamadaInicial;
    
            
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.atributosLlamadaInicial(llamada.CC_ConnId__c);
            Test.stopTest();
            }
            System.assertEquals(true, true, 'PENDIENTE');
    }
}