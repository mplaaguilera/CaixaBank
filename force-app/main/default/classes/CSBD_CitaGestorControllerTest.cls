@IsTest
private class CSBD_CitaGestorControllerTest {

    @TestSetup
    static void setup() {
        // Crear Integration Settings
        List<CBK_IntegrationSetting__c> integrationSettings = new List<CBK_IntegrationSetting__c>();
        
        CBK_IntegrationSetting__c settingLegoAltaCita = new CBK_IntegrationSetting__c();
        settingLegoAltaCita.Name = 'CSBD_Lego_AltaCita';
        settingLegoAltaCita.NamedCredential__c = 'callout:CSBD_Lego_Named_Credentials/altaCita';
        integrationSettings.add(settingLegoAltaCita);

        CBK_IntegrationSetting__c settingLegoDisponibilidad = new CBK_IntegrationSetting__c();
        settingLegoDisponibilidad.Name = 'CSBD_Lego_DisponibilidadCitas';
        settingLegoDisponibilidad.NamedCredential__c = 'callout:CSBD_Lego_Named_Credentials/disponibilidad';
        integrationSettings.add(settingLegoDisponibilidad);

        CBK_IntegrationSetting__c settingAVEAltaCita = new CBK_IntegrationSetting__c();
        settingAVEAltaCita.Name = 'CSBD_AVE_AltaCita';
        settingAVEAltaCita.NamedCredential__c = 'callout:CSBD_AVE_Named_Credentials/altaCita';
        integrationSettings.add(settingAVEAltaCita);

        CBK_IntegrationSetting__c settingAVEDisponibilidad = new CBK_IntegrationSetting__c();
        settingAVEDisponibilidad.Name = 'CSBD_AVE_DisponibilidadCita';
        settingAVEDisponibilidad.NamedCredential__c = 'callout:CSBD_AVE_Named_Credentials/disponibilidad';
        integrationSettings.add(settingAVEDisponibilidad);

        CBK_IntegrationSetting__c settingAVECaracteriza = new CBK_IntegrationSetting__c();
        settingAVECaracteriza.Name = 'CSBD_AVE_CaracterizaCliente';
        settingAVECaracteriza.NamedCredential__c = 'callout:CSBD_AVE_Named_Credentials/caracteriza';
        integrationSettings.add(settingAVECaracteriza);

        insert integrationSettings;

        // Crear Custom Setting de Cita Gestor
        CSBD_CitaGestorSetting__c citaGestorSetting = new CSBD_CitaGestorSetting__c();
        citaGestorSetting.Name = 'Default';
        citaGestorSetting.CSBD_Device_LEGO__c = 'CC';
        citaGestorSetting.CSBD_ReservationType_LEGO__c = 'RESERVA';
        citaGestorSetting.CSBD_Header_LEGO__c = false;
        citaGestorSetting.CSBD_DiasDesde_AVE__c = 0;
        citaGestorSetting.CSBD_DiasHasta_AVE__c = 30;
        citaGestorSetting.CSBD_TipoCita_Lego__c = '{"43":"Cita presencial","44":"Cita telefónica"}';
        citaGestorSetting.CSBD_TiposCita_AVE__c = '{"42":"CONSULTA","43":"PRESENCIAL"}';
        citaGestorSetting.CSBD_OficinasNoPresenciales_AVE__c = '001,002';
        insert citaGestorSetting;

        // Crear datos de prueba
        
    }

    @IsTest
    static void testObtenerConfiguraciones() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Test.startTest();
                Map<String, Object> configuraciones = CSBD_CitaGestorController.obtenerConfiguraciones(false);
            Test.stopTest();

            System.assertNotEquals(null, configuraciones, 'Las configuraciones no deberían ser nulas');
            System.assertEquals('42', configuraciones.get('tipoCitaDefault'), 'El tipo de cita por defecto debería ser 42');
            System.assertNotEquals(null, configuraciones.get('tiposCita'), 'Debería existir un mapa de tipos de cita');
            System.assertNotEquals(null, configuraciones.get('oficinasNoPresenciales'), 'Debería existir la lista de oficinas no presenciales');
        }
    }

    @IsTest
    static void testObtenerDisponibilidadLEGOSuccess() {
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        Map<String, SObject> empleadoOficina;
        Account cuentaCliente;
        System.runAs(usuarioAdministrador) {
            empleadoOficina = CSBD_TestDataFactory.crearEmpleadoOficina('001');
            Map<String, Object> camposCliente = new Map<String, Object>();    
            camposCliente.put('AV_EAPGestor__c', empleadoOficina.get('empleado').Id);
            camposCliente.put('AV_OfficeManager__c', empleadoOficina.get('oficina').Id);
            camposCliente.put('AV_NumPerso__c', '123456');
            cuentaCliente = CSBD_TestDataFactory.crearCuenta(camposCliente);
        }

        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            //Crear oficina y gestor           

            Map<String, Object> camposOportunidad = new Map<String, Object>();
            camposOportunidad.put('AccountId', cuentaCliente.Id);
            camposOportunidad.put('StageName', 'Solicitud');
            Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposOportunidad);

            Map<String, Object> params = new Map<String, Object>();
            params.put('statusCode', 200);
            params.put('status', 'OK');
            params.put('tipoIntegracion', 'CSBD_Lego_Disponibilidad');
            params.put('tipoRespuesta', 'OK');
            params.put('multipleCallout', false);
            
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(params));   

            Test.startTest();
                Map<String, Object> resultado = CSBD_CitaGestorController.obtenerDisponibilidad(opp.Id, true, '43');
            Test.stopTest();

            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('disponibilidadPorFecha'), 'Debería existir disponibilidad por fecha');
        }
    }

    @IsTest
    static void testObtenerDisponibilidadAVESuccess() {
        User usuarioAdministrador  = CSBD_TestDataFactory.usuarioAdministrador();
        Map<String, SObject> empleadoOficina;
        Account cuentaCliente;
        System.runAs(usuarioAdministrador) {
            //Empleado y Oficina
            empleadoOficina = CSBD_TestDataFactory.crearEmpleadoOficina('001');
            Map<String, Object> camposCliente = new Map<String, Object>();    
            camposCliente.put('AV_EAPGestor__c', empleadoOficina.get('empleado').Id);
            camposCliente.put('AV_NumPerso__c', '123456');
            cuentaCliente = CSBD_TestDataFactory.crearCuenta(camposCliente);
        }

        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            //Crear oficina y gestor
            Map<String, Object> camposOportunidad = new Map<String, Object>();
            camposOportunidad.put('AccountId', cuentaCliente.Id);
            camposOportunidad.put('StageName', 'Solicitud');
            Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposOportunidad);
            
            Map<String, Object> params = new Map<String, Object>();
            params.put('statusCode', 200);
            params.put('status', 'OK');
            params.put('tipoIntegracion', 'MultipleCallouts');
            params.put('tipoRespuesta', 'OK');
            params.put('multipleCallout', true);
            
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(params));
            //Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(200, 'OK', 'CSBD_AVE_Disponibilidad', 'OK'));

            Test.startTest();
                Map<String, Object> resultado = CSBD_CitaGestorController.obtenerDisponibilidad(opp.Id, false, '42');
            Test.stopTest();

            System.assertEquals('U0157434', resultado.get('matricula'), 'Deberia devolverl la matricula del gestor AVE');
            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('disponibilidadPorFecha'), 'Debería existir disponibilidad por fecha');
        }
    }   

    @IsTest
    static void testAltaCitaGestorLEGOSuccess() {
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        Map<String, SObject> empleadoOficina;
        Account cuentaCliente;
        System.runAs(usuarioAdministrador) {
            empleadoOficina = CSBD_TestDataFactory.crearEmpleadoOficina('001');
            Map<String, Object> camposCliente = new Map<String, Object>();    
            camposCliente.put('AV_EAPGestor__c', empleadoOficina.get('empleado').Id);
            camposCliente.put('AV_OfficeManager__c', empleadoOficina.get('oficina').Id);
            camposCliente.put('AV_NumPerso__c', '123456');
            cuentaCliente = CSBD_TestDataFactory.crearCuenta(camposCliente);
        }

        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> camposOportunidad = new Map<String, Object>();
            camposOportunidad.put('AccountId', cuentaCliente.Id);
            camposOportunidad.put('StageName', 'Solicitud');
            Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposOportunidad);

            Map<String, Object> params = new Map<String, Object>();
            params.put('statusCode', 200);
            params.put('status', 'OK');
            params.put('tipoIntegracion', 'CSBD_Lego_AltaCita');
            params.put('tipoRespuesta', 'OK');
            params.put('multipleCallout', false);
            
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(params));

            Map<String, Object> paramsAltaCita = new Map<String, Object>{
                'recordId' => opp.Id,
                'numOficina' => '001',
                'fechaSeleccionada' => '2025-05-21',
                'franjaSeleccionada' => '09:00-09:30',
                'asunto' => 'Test Cita',
                'tipoCita' => '43',
                'numPer' => '123456'
            };

            Test.startTest();
                Map<String, Object> resultado = CSBD_CitaGestorController.altaCitaGestorLEGO(paramsAltaCita);
            Test.stopTest();

            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            
            // Verificar que se creó la tarea
            List<Task> tareas = [SELECT Id, Subject, Status, Description FROM Task WHERE WhatId = :opp.Id];
            System.assertEquals(tareas.isEmpty(), false, 'Debería haberse creado una tarea');
            System.assertEquals(tareas[0].Subject.contains('Cita en la oficina'), true, 'El asunto de la tarea debería ser correcto');
        }
    }

    @IsTest
    static void testAltaCitaGestorAVESuccess() {
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        Map<String, SObject> empleadoOficina;
        Account cuentaCliente;
        System.runAs(usuarioAdministrador) {
            empleadoOficina = CSBD_TestDataFactory.crearEmpleadoOficina('001');
            Map<String, Object> camposCliente = new Map<String, Object>();    
            camposCliente.put('AV_EAPGestor__c', empleadoOficina.get('empleado').Id);
            camposCliente.put('AV_NumPerso__c', '123456');
            cuentaCliente = CSBD_TestDataFactory.crearCuenta(camposCliente);
        }

        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> camposOportunidad = new Map<String, Object>();
            camposOportunidad.put('AccountId', cuentaCliente.Id);
            camposOportunidad.put('StageName', 'Solicitud');
            Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposOportunidad);

            Map<String, Object> params = new Map<String, Object>();
            params.put('statusCode', 200);
            params.put('status', 'OK');
            params.put('tipoIntegracion', 'CSBD_AVE_AltaCita');
            params.put('tipoRespuesta', 'OK');
            params.put('multipleCallout', false);
            
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(params));

            Map<String, Object> paramsAltaCita = new Map<String, Object>{
                'recordId' => opp.Id,
                'gestorMatricula' => 'U0157434',
                'fecContacto' => '2025-05-21',
                'horaIni' => '09:00',
                'asunto' => 'Test Cita AVE',
                'medio' => '42',
                'centroEx' => '001',
                'numperso' => '123456'
            };

            Test.startTest();
                Map<String, Object> resultado = CSBD_CitaGestorController.altaCitaGestorAVE(paramsAltaCita);
            Test.stopTest();

            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            
            // Verificar que se creó la tarea
            List<Task> tareas = [SELECT Id, Subject, Status, Description FROM Task WHERE WhatId = :opp.Id];
            System.assertEquals(tareas.isEmpty(), false, 'Debería haberse creado una tarea');
            System.assertEquals('Cita con gestor AVE', tareas[0].Subject, 'El asunto de la tarea debería ser correcto');
        }
    }

}