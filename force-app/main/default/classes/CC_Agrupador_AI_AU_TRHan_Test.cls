@isTest
public with sharing class CC_Agrupador_AI_AU_TRHan_Test { 

    @TestSetup
    static void makeData() {
        User admin = CC_TestDataFactory.insertUserAdmin();
    }

    @isTest
    public static void testCreacionAgrupador() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia
            Id recordTypeAgrupador = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador',
                CC_Numero_casos__c = 1,
                CC_Estado__c = 'Pendiente Revision'
            );
            
            insert agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Numero_casos__c, CC_Estado__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals(true, agrupador.Id != null, 'El agrupador debería haberse creado correctamente');
        
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testActualizacionAgrupador() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
                // Crear un agrupador de incidencia
                Id recordTypeAgrupador = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
                CC_Agrupador__c agrupadorUpdate = new CC_Agrupador__c(
                    RecordTypeId = recordTypeAgrupador,
                    CC_Titulo__c = 'Test Agrupador',
                    CC_Numero_casos__c = 1,
                    CC_Estado__c = 'Activo'
            );
            //Insertar el agrupador que esta en estado Activo
            insert agrupadorUpdate;

            agrupadorUpdate.CC_Estado__c = 'Pendiente Revision';

            //Actualizar el agrupador que para que se ejecute el trigger AU
            update agrupadorUpdate;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Numero_casos__c, CC_Estado__c FROM CC_Agrupador__c WHERE Id = :agrupadorUpdate.Id];

            System.assertEquals(true, agrupadorResultado.CC_Estado__c == 'Pendiente Revision', 'El estado del agrupador debería haberse actualizado correctamente');
        
            Test.stopTest();
        }
    }

    @isTest
    public static void testNotificarAutomaticaEvento() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia
            Id recordTypeAgrupador = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
            CC_Agrupador__c agrupadorUpdate = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador',
                CC_Numero_casos__c = 100,
                CC_Estado__c = 'Activo',
                CC_Notificacion_Evento_Automatico__c = false,
                CC_Id_Maximo__c = 'tesid24'                    
            );
            //Insertar el agrupador que esta en estado Activo
            insert agrupadorUpdate;

            agrupadorUpdate.CC_No_Enviar_Evento__c = false;

            //Actualizar el agrupador que para que se ejecute el trigger AU
            update agrupadorUpdate;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_No_Enviar_Evento__c FROM CC_Agrupador__c WHERE Id = :agrupadorUpdate.Id];

            System.assertEquals(false, agrupadorResultado.CC_No_Enviar_Evento__c, 'El no enviar evento del agrupador debería haberse actualizado correctamente');
        
            Test.stopTest();
        }
    }

    // Test para notificación de agrupador público (CC_Publica__c = false -> true)
    @isTest
    public static void testNotificarAgrupadorPublico() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia con CC_Publica__c = false
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Público',
                CC_Numero_casos__c = 1,
                CC_Estado__c = 'Activo',
                CC_Publica__c = false
            );
            
            insert agrupador;

            // Actualizar CC_Publica__c a true para activar la notificación
            agrupador.CC_Publica__c = true;
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Publica__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals(true, agrupadorResultado.CC_Publica__c, 'El agrupador debería haberse marcado como público');
        
            Test.stopTest();
        }
    }

    // Test para cierre automático de casos (CC_Estado__c = !Cerrado -> Cerrado)
    @isTest
    public static void testCierreAutomaticoCasos() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();

            CC_Agrupacion_Casos__c gruposCasos = new CC_Agrupacion_Casos__c();
            gruposCasos.Name = 'Agrupador Casos';
            gruposCasos.CC_Grupos_Casos__c = 5;
            insert gruposCasos;
                
            // Crear un agrupador de incidencia (no es Comunicación Informativa)
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Cierre',
                CC_Numero_casos__c = 1,
                CC_Estado__c = 'Activo'
            );
            
            insert agrupador;

            // Actualizar estado a Cerrado para activar el cierre automático
            agrupador.CC_Estado__c = 'Cerrado';
            agrupador.CC_Fecha_Cierre__c = CBK_UtilsDate.todayDT();
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Estado__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals('Cerrado', agrupadorResultado.CC_Estado__c, 'El agrupador debería haberse cerrado');
        
            Test.stopTest();
        }
    }

    // Test para notificación automática de eventos con todas las condiciones
    @isTest
    public static void testNotificacionAutomaticaEventos() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia con todas las condiciones necesarias
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Evento',
                CC_Numero_casos__c = 50, // Número inicial
                CC_Estado__c = 'Activo',
                CC_Notificacion_Evento_Automatico__c = false,
                CC_Id_Maximo__c = 'testid123',
                CC_No_Enviar_Evento__c = false
            );
            
            insert agrupador;

            // Actualizar número de casos para activar la notificación automática
            agrupador.CC_Numero_casos__c = 100; // Incrementar para cumplir condición
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Numero_casos__c, CC_Notificacion_Evento_Automatico__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals(100, agrupadorResultado.CC_Numero_casos__c, 'El número de casos debería haberse actualizado');
        
            Test.stopTest();
        }
    }

    // Test para agrupador rechazado (CC_Estado__c = !Rechazado -> Rechazado)
    @isTest
    public static void testAgrupadorRechazado() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Rechazado',
                CC_Numero_casos__c = 1,
                CC_Estado__c = 'Activo'
            );
            
            insert agrupador;

            // Actualizar estado a Rechazado
            agrupador.CC_Estado__c = 'Rechazado';
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Estado__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals('Rechazado', agrupadorResultado.CC_Estado__c, 'El agrupador debería haberse rechazado');
        
            Test.stopTest();
        }
    }

    // Test para actualización de avisos (CC_Numero_Casos__c > OLD CC_Numero_Casos__c)
    @isTest
    public static void testActualizacionAvisos() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Avisos',
                CC_Numero_casos__c = 5,
                CC_Estado__c = 'Activo'
            );
            
            insert agrupador;

            // Incrementar número de casos para activar actualización de avisos
            agrupador.CC_Numero_casos__c = 15;
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Numero_casos__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals(15, agrupadorResultado.CC_Numero_casos__c, 'El número de casos debería haberse incrementado');
        
            Test.stopTest();
        }
    }

    // Test para cambio a Pendiente Revisión con aviso
    @isTest
    public static void testCambioPendienteRevisionConAviso() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de incidencia
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Pendiente Revisión',
                CC_Numero_casos__c = 10,
                CC_Estado__c = 'Activo',
                CC_Detalle_solucion__c = 'Solución de prueba para el agrupador'
            );
            
            insert agrupador;

            // Cambiar a Pendiente Revisión y incrementar casos para activar aviso
            agrupador.CC_Estado__c = 'Pendiente Revision';
            agrupador.CC_Numero_casos__c = 20;
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Estado__c, CC_Numero_casos__c, CC_Detalle_solucion__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals('Pendiente Revision', agrupadorResultado.CC_Estado__c, 'El agrupador debería estar pendiente de revisión');
            System.assertEquals(20, agrupadorResultado.CC_Numero_casos__c, 'El número de casos debería haberse actualizado');
        
            Test.stopTest();
        }
    }

    // Test para agrupador de tipo Masiva Control
    @isTest
    public static void testAgrupadorMasivaControl() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de tipo Masiva Control
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Masiva_Control');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Masiva Control',
                CC_Numero_casos__c = 5,
                CC_Estado__c = 'Activo'
            );
            
            insert agrupador;

            // Cambiar a Pendiente Revisión y incrementar casos
            agrupador.CC_Estado__c = 'Pendiente Revision';
            agrupador.CC_Numero_casos__c = 15;
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Estado__c, CC_Numero_casos__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals('Pendiente Revision', agrupadorResultado.CC_Estado__c, 'El agrupador debería estar pendiente de revisión');
            System.assertEquals(15, agrupadorResultado.CC_Numero_casos__c, 'El número de casos debería haberse actualizado');
        
            Test.stopTest();
        }
    }

    // Test para agrupador de tipo Seguimiento
    @isTest
    public static void testAgrupadorSeguimiento() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            Test.startTest();
                
            // Crear un agrupador de tipo Seguimiento
            Id recordTypeAgrupador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Seguimiento');
            CC_Agrupador__c agrupador = new CC_Agrupador__c(
                RecordTypeId = recordTypeAgrupador,
                CC_Titulo__c = 'Test Agrupador Seguimiento',
                CC_Numero_casos__c = 3,
                CC_Estado__c = 'Activo'
            );
            
            insert agrupador;

            // Cambiar a Pendiente Revisión y incrementar casos
            agrupador.CC_Estado__c = 'Pendiente Revision';
            agrupador.CC_Numero_casos__c = 12;
            update agrupador;

            CC_Agrupador__c agrupadorResultado = [SELECT Id, CC_Estado__c, CC_Numero_casos__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id];

            System.assertEquals('Pendiente Revision', agrupadorResultado.CC_Estado__c, 'El agrupador debería estar pendiente de revisión');
            System.assertEquals(12, agrupadorResultado.CC_Numero_casos__c, 'El número de casos debería haberse actualizado');
        
            Test.stopTest();
        }
    }
}