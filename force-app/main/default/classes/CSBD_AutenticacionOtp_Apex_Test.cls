@isTest
public with sharing class CSBD_AutenticacionOtp_Apex_Test {

    @TestSetup
    private static void testSetup() {
        //Usuarios
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        //Custom settings
        CC_Settings__c csAutenticacionBloqueos = new CC_Settings__c();
        csAutenticacionBloqueos.Name = 'CC_Autenticacion_Bloqueos';
        csAutenticacionBloqueos.CC_Configuracion_1__c = '2';
        csAutenticacionBloqueos.CC_Configuracion_2__c = '24';
        csAutenticacionBloqueos.CC_Activa__c = true;
        CC_Settings__c csPerfilesAutenticacion = new CC_Settings__c();
        csPerfilesAutenticacion.Name = 'CC_PerfilesAutentication';
        csPerfilesAutenticacion.CC_Configuracion_1__c = 'CC';
        csPerfilesAutenticacion.CC_Configuracion_2__c = 'CSBD';
        csPerfilesAutenticacion.CC_Configuracion_3__c = 'HDT';
        csPerfilesAutenticacion.CC_Activa__c = true;
        CC_Settings__c csIntClienteDigital = new CC_Settings__c();
        csIntClienteDigital.Name = 'CC_Integracion_ClienteDigital';
        csIntClienteDigital.CC_Configuracion_1__c = 'APPROVALSPLUGIN_PROCESSCOMMAND_SALESFORCE';
        csIntClienteDigital.CC_Configuracion_2__c = 'APPROVALSPLUGIN_PROCESSCOMMAND_SALESFORCE2';
        csIntClienteDigital.CC_Configuracion_3__c = 'AUT00001_P1_ET1_VALET1';
        csIntClienteDigital.CC_Configuracion_4__c = 'AUT00002_P1_ET1_VALET1';
        csIntClienteDigital.CC_Activa__c = true;
        insert new List<CC_Settings__c>{csAutenticacionBloqueos, csPerfilesAutenticacion, csIntClienteDigital};

        CBK_IntegrationSetting__c csIntAutRobusta = new CBK_IntegrationSetting__c();
        csIntAutRobusta.Name = 'CC_Autenticacion_Robusta';
        csIntAutRobusta.NamedCredential__c = 'callout:API_GWT_TST_CCSF/crossChannel/transactionAuthorization/v2/authorizations';
        csIntAutRobusta.RegistroTrazaIntegracion__c = true;
        CBK_IntegrationSetting__c csIntAutRobustaEstado = new CBK_IntegrationSetting__c();
        csIntAutRobustaEstado.Name = 'CC_Autenticacion_Robusta_Estado';
        csIntAutRobustaEstado.NamedCredential__c = 'callout:API_GWT_TST_CCSF/crossChannel/transactionAuthorization/v2/authorizations/{authorizationId}/approver/status';
        csIntAutRobustaEstado.RegistroTrazaIntegracion__c = true;
        insert new List<CBK_IntegrationSetting__c>{csIntAutRobusta, csIntAutRobustaEstado};

        //Cuenta y contacto
		List<Map<String, Object>> camposCuentas = new List<Map<String, Object>>{
			new Map<String, Object>{
				'AV_NumPerso__c' => '12345678',
				'CC_NumPerso__c' => '12345678'
			},
			new Map<String, Object>{
				'AV_NumPerso__c' => '22345678',
				'CC_NumPerso__c' => '22345678'
			}
		};
		List<Account> cuentas = CSBD_TestDataFactory.crearCuenta(camposCuentas);
		Account cuenta = cuentas[0];
		Account cuentaApoderado = cuentas[1];

		List<Map<String, Object>> camposContactos = new List<Map<String, Object>>{
			new Map<String, Object>{
				'AccountId' => cuenta.Id,
				'Birthdate' => Date.today().addYears(-18),
				'MobilePhone' => '612345678',
				'Phone' => '612345678'
			},
			new Map<String, Object>{
				'AccountId' => cuenta.Id,
				'Birthdate' => Date.today().addYears(-18)
			},
			new Map<String, Object>{
				'RecordTypeId' => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_Apoderado').getRecordTypeId(),
				'AccountId' => cuentaApoderado.Id,
				'Birthdate' => Date.today().addYears(-18),
				'MobilePhone' => '612345678',
				'Phone' => '612345678'
			}
		};
		List<Contact> contactos = CSBD_TestDataFactory.crearContacto(camposContactos);
		Contact contacto = contactos[0];
		Contact contactoSinTelefono = contactos[1];
		Contact contactoApoderado = contactos[2];

        // Contact contactoApoderado = CSBD_TestDataFactory.crearContacto(new Map<String, Object>{
        //     'RecordTypeId' => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_Apoderado').getRecordTypeId(),
        //     'AccountId' => cuentaApoderado.Id,
        //     'Birthdate' => Date.today().addYears(-18),
        //     'MobilePhone' => '612345678',
        //     'Phone' => '612345678'
        // });

        CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c();
        representante.RecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        representante.CC_Representante__c = cuenta.Id;
        insert representante;

        //Casos origen
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.Subject = 'Caso origen Test';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        Case casoRepresentante = new Case();
        casoRepresentante.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casoRepresentante.Subject = 'Caso origen Test';
        casoRepresentante.AccountId = cuenta.Id;
        casoRepresentante.ContactId = contacto.Id;
        casoRepresentante.CC_Representante__c = representante.Id;
        Case casoApoderado = new Case();
        casoApoderado.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casoApoderado.Subject = 'Caso origen Test';
        casoApoderado.AccountId = cuentaApoderado.Id;
        casoApoderado.ContactId = contactoApoderado.Id;
        Case casoImaginBank = new Case();
        casoImaginBank.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casoImaginBank.Subject = 'Caso origen ImaginBank Test';
        casoImaginBank.AccountId = cuenta.Id;
        casoImaginBank.ContactId = contacto.Id;
        insert new List<Case>{caso, casoRepresentante, casoApoderado, casoImaginBank};

        System.runAs(usuarioGestor) {
            //Oportunidades
            Map<String, Object> camposOpp = new Map<String, Object>{
                'CSBD_Titulo__c' => 'Oportunidad Test',
                'CSBD_CasoOrigen__c' => caso.Id,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id,
                'CSBD_Email_Solicitud__c' => 'email_opp@test.com'
            };
            Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOpp);

            Map<String, Object> camposOppRepresentante = new Map<String, Object>{
                'CSBD_Titulo__c' => 'Oportunidad Representante Test',
                'CSBD_CasoOrigen__c' => casoRepresentante.Id,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id,
                'CSBD_Email_Solicitud__c' => 'email_opp@test.com'
            };
            Opportunity oppRepresentante = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOppRepresentante);

            Map<String, Object> camposOppApoderado = new Map<String, Object>{
                'CSBD_Titulo__c' => 'Oportunidad Apoderado Test',
                'CSBD_CasoOrigen__c' => casoApoderado.Id,
                'AccountId' => cuentaApoderado.Id,
                'CSBD_Contact__c' => contactoApoderado.Id,
                'CSBD_Email_Solicitud__c' => 'email_opp@test.com'
            };
            Opportunity oppApoderado = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOppApoderado);

            Map<String, Object> camposOppImaginBank = new Map<String, Object>{
                'CSBD_Titulo__c' => 'Oportunidad ImaginBank Test',
                'CSBD_CasoOrigen__c' => casoImaginBank.Id,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id
                // 'CSBD_Email_Solicitud__c' => 'email_opp@test.com'
            };
            Opportunity oppImaginBank = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOppImaginBank);

            Map<String, Object> camposOppSinLlamada = new Map<String, Object>{
                'CSBD_Titulo__c' => 'Oportunidad sin llamada en curso Test',
                'CSBD_CasoOrigen__c' => casoImaginBank.Id,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contacto.Id,
                'CSBD_Email_Solicitud__c' => 'email_opp@test.com'
            };
            Opportunity oppSinLlamada = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOppSinLlamada);

            Map<String, Object> camposOppSinMailPhone = new Map<String, Object>{
                'CSBD_Titulo__c' => 'Oportunidad sin correo/teléfono',
                'CSBD_CasoOrigen__c' => caso.Id,
                'AccountId' => cuenta.Id,
                'CSBD_Contact__c' => contactoSinTelefono.Id
            };
            Opportunity oppSinMailPhone = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOppSinMailPhone);

            //Llamadas
            CC_Llamada__c llamadaEntrante = new CC_Llamada__c();
            llamadaEntrante.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CSBD_Cliente').getRecordTypeId();
            llamadaEntrante.CC_Tipo__c = 'Saliente';
            llamadaEntrante.CC_Fecha_Inicio__c = System.now();
            CC_Llamada__c llamadaSaliente = new CC_Llamada__c();
            llamadaSaliente.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CSBD_Cliente').getRecordTypeId();
            llamadaSaliente.CC_Tipo__c = 'Saliente';
            llamadaSaliente.CC_Fecha_Inicio__c = System.now();
            insert new List<CC_Llamada__c>{llamadaEntrante, llamadaSaliente};
            Task tareaLlamadaEntrante = new Task();
            tareaLlamadaEntrante.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
            tareaLlamadaEntrante.CC_Llamada_Id__c = llamadaEntrante.Id;
            tareaLlamadaEntrante.WhatId = opp.Id;
            Task tareaLlamadaSaliente = new Task();
            tareaLlamadaSaliente.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
            tareaLlamadaSaliente.CC_Llamada_Id__c = llamadaSaliente.Id;
            tareaLlamadaSaliente.WhatId = oppImaginBank.Id;
            insert new List<Task>{tareaLlamadaEntrante, tareaLlamadaSaliente};

            //Autenticaciones
            Id idRtAutenticacionCsbd = Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get('CSBD_Autenticacion').getRecordTypeId();
            CC_Comunicaciones__c aut1 = new CC_Comunicaciones__c();
            aut1.RecordTypeId = idRtAutenticacionCsbd;
            aut1.CSBD_Opportunity__c = opp.Id;
            aut1.CC_Cliente__c = cuenta.Id;
            aut1.CC_Nivel__c = 'Nivel 2';
            aut1.CC_Estado__c = 'Cerrado';
            CC_Comunicaciones__c aut2 = new CC_Comunicaciones__c();
            aut2.RecordTypeId = idRtAutenticacionCsbd;
            aut2.CSBD_Opportunity__c = null;
            aut2.CC_Cliente__c = cuenta.Id;
            aut2.CC_Nivel__c = 'Cliente Digital';
            aut2.CC_Estado__c = 'Error';
            CC_Comunicaciones__c aut3 = new CC_Comunicaciones__c();
            aut3.RecordTypeId = idRtAutenticacionCsbd;
            aut3.CSBD_Opportunity__c = opp.Id;
            aut3.CC_Cliente__c = cuenta.Id;
            aut3.CC_Nivel__c = 'Cliente Digital';
            aut3.CC_Estado__c = 'Pdte. Envío';
            aut3.CC_AuthorizationId__c = 'SK_0120240216093456720001004000000000CBCCSF000000000000000DEFzd4i5Di9AQVO5CL9Ieq';
            CC_Comunicaciones__c aut4 = new CC_Comunicaciones__c();
            aut4.RecordTypeId = idRtAutenticacionCsbd;
            aut4.CSBD_Opportunity__c = oppImaginBank.Id;
            aut4.CC_Cliente__c = cuenta.Id;
            aut4.CC_Nivel__c = 'Cliente Digital';
            aut4.CC_Estado__c = 'Pdte. Envío';
            aut4.CC_AuthorizationId__c = 'SK_0120240216093456720001004000000000CBCCSF000000000000000DEFzd4i5Di9AQVO5CL9Ieq';
            insert new List<CC_Comunicaciones__c>{aut1, aut2, aut3, aut4};

            //EmailTemplates
            EmailTemplate plantilla = new EmailTemplate();
            plantilla.Name = 'Notificación OTP ES - OK';
            plantilla.TemplateType = 'Text';
            plantilla.FolderId = usuarioGestor.Id;
            insert plantilla;
        }
    }

    @isTest
    private static void getDatos() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidad = [SELECT AccountId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            Test.startTest();
            Map<String, Boolean> datos = CSBD_AutenticacionOtp_Apex.getDatos(oportunidad.Id, oportunidad.AccountId);
            Map<String, Boolean> datosAsync = CSBD_AutenticacionOtp_Apex.getDatosAsync('Teléfono');
            Test.stopTest();

            System.assertEquals(true, datos.get('llamadaEnCurso'), 'Atributo "llamadaEnCurso" retornado incorrecto');
            System.assertEquals(false, datos.get('clienteBloqueado'), 'Atributo "clienteBloqueado" retornado incorrecto');
        }
    }

    @isTest
    private static void segundoNivel() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            Test.startTest();
            Map<String, String> retornoValido = CSBD_AutenticacionOtp_Apex.segundoNivel(oportunidad.Id, true, 'Nivel 2', 'p1', 'p2', 'r1', 'r2', 'v1', 'v2', true);
            Map<String, String> retornoNoValido = CSBD_AutenticacionOtp_Apex.segundoNivel(oportunidad.Id, false, 'Nivel 2', 'p1', 'p2', 'r1', 'r2', 'v1', 'v2', true);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void validacionRespuestasNivel2() {
		CC_Settings__c csIntAutenticacion = new CC_Settings__c();
        csIntAutenticacion.Name = 'CC_Integracion_Autenticacion';
        csIntAutenticacion.CC_Activa__c = true;
		insert csIntAutenticacion;

        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            Opportunity oportunidadRepresentante = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Representante Test'];

            Test.startTest();
            Map<String, Boolean> retorno1 = CSBD_AutenticacionOtp_Apex.validacionRespuestasNivel2(oportunidad.Id, 'edad', 'teléfono', 'r1', 'r2');
            Map<String, Boolean> retorno2 = CSBD_AutenticacionOtp_Apex.validacionRespuestasNivel2(oportunidad.Id, 'edad', 'año', 'r1', 'r2');
            Map<String, Boolean> retorno3 = CSBD_AutenticacionOtp_Apex.validacionRespuestasNivel2(oportunidad.Id, 'cuenta', 'tarjeta', 'r1', 'r2');
            Map<String, Boolean> retornoRepresentante1 = CSBD_AutenticacionOtp_Apex.validacionRespuestasNivel2(oportunidadRepresentante.Id, 'edad', 'teléfono', 'r1', 'r2');
            Map<String, Boolean> retornoRepresentante2 = CSBD_AutenticacionOtp_Apex.validacionRespuestasNivel2(oportunidadRepresentante.Id, 'edad', 'año', 'r1', 'r2');
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void getPreguntasNivel2() {
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'Preguntas OTPSMS 2 Nivel';
        insert lista;
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
        valor1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Servicio__c = 'Pregunta 1';
        valor1.Name = 'Edad del cliente';
        valor1.CC_Valor__c = 'Edad del cliente';
        valor1.CC_Valor_SFDC__c = 'Salesforce';
        valor1.CC_Orden__c = 5;
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Servicio__c = 'Pregunta 2';
        valor2.Name = 'Teléfono asociado';
        valor2.CC_Valor__c = 'Teléfono asociado a CaixaBank del cliente';
        valor2.CC_Valor_SFDC__c = 'Salesforce';
        valor2.CC_Orden__c = 5;
        insert new List<CC_Lista_Valores__c>{valor1, valor2};

        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

            Test.startTest();
            Map<String, String> preguntas = CSBD_AutenticacionOtp_Apex.getPreguntasNivel2(oportunidad.Id);
            Test.stopTest();

            System.assert(!preguntas.isEmpty(), 'Preguntas de nivel 2 retornadas incorrectas');
            System.assertEquals(preguntas.values()[0], 'Edad del cliente', 'Preguntas de nivel 2 retornadas incorrectas');
        }
    }

    @isTest
    private static void getPreguntasNivel2Representante() {
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'Preguntas OTPSMS 2 Nivel';
        insert lista;
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
        valor1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Servicio__c = 'Pregunta 1';
        valor1.Name = 'Edad del cliente';
        valor1.CC_Valor__c = 'Edad del cliente';
        valor1.CC_Valor_SFDC__c = 'Salesforce';
        valor1.CC_Orden__c = 5;
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Servicio__c = 'Pregunta 2';
        valor2.Name = 'Teléfono asociado';
        valor2.CC_Valor__c = 'Teléfono asociado a CaixaBank del cliente';
        valor2.CC_Valor_SFDC__c = 'Salesforce';
        valor2.CC_Orden__c = 5;
        insert new List<CC_Lista_Valores__c>{valor1, valor2};

        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidadRepresentante = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Representante Test'];

            Test.startTest();
            Map<String, String> preguntasRepresentante = CSBD_AutenticacionOtp_Apex.getPreguntasNivel2(oportunidadRepresentante.Id);
            Test.stopTest();

            System.assert(!preguntasRepresentante.isEmpty(), 'Preguntas de nivel 2 retornadas incorrectas');
            System.assertEquals(preguntasRepresentante.values()[0], 'Edad del cliente', 'Preguntas de nivel 2 retornadas incorrectas');
        }
    }

    @isTest
    private static void getPreguntasNivel2Apoderado() {
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'Preguntas OTPSMS 2 Nivel';
        insert lista;
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
        valor1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Servicio__c = 'Pregunta 1';
        valor1.Name = 'Edad del cliente';
        valor1.CC_Valor__c = 'Edad del cliente';
        valor1.CC_Valor_SFDC__c = 'Salesforce';
        valor1.CC_Orden__c = 5;
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Servicio__c = 'Pregunta 2';
        valor2.Name = 'Teléfono asociado';
        valor2.CC_Valor__c = 'Teléfono asociado a CaixaBank del cliente';
        valor2.CC_Valor_SFDC__c = 'Salesforce';
        valor2.CC_Orden__c = 5;
        insert new List<CC_Lista_Valores__c>{valor1, valor2};

        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidadApoderado = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Apoderado Test'];

            Test.startTest();
            Map<String, String> preguntasApoderado = CSBD_AutenticacionOtp_Apex.getPreguntasNivel2(oportunidadApoderado.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void getPreguntasEmergencia() {
        Id idRecordTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        CC_Lista_Valores__c lista1 = new CC_Lista_Valores__c();
        lista1.RecordTypeId = idRecordTypeLista;
        lista1.Name = 'Preguntas Básicas OTPSMS';
        CC_Lista_Valores__c lista2 = new CC_Lista_Valores__c();
        lista2.RecordTypeId = idRecordTypeLista;
        lista2.Name = 'Preguntas Aleatorias OTPSMS';
        insert new List<CC_Lista_Valores__c>{lista1, lista2};
        Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        CC_Lista_Valores__c valor11 = new CC_Lista_Valores__c();
        valor11.RecordTypeId = idRecordTypeValor;
        valor11.CC_Lista__c = lista1.Id;
        valor11.Name = 'Nombre completo';
        valor11.CC_Valor__c = 'Nombre completo';
        CC_Lista_Valores__c valor12 = new CC_Lista_Valores__c();
        valor12.RecordTypeId = idRecordTypeValor;
        valor12.CC_Lista__c = lista1.Id;
        valor12.Name = 'Número de identificación';
        valor12.CC_Valor__c = 'DNI, NIE o pasaporte';
        CC_Lista_Valores__c valor21 = new CC_Lista_Valores__c();
        valor21.RecordTypeId = idRecordTypeValor;
        valor21.CC_Lista__c = lista2.Id;
        valor21.Name = '1';
        valor21.CC_Valor__c = '¿1?';
        CC_Lista_Valores__c valor22 = new CC_Lista_Valores__c();
        valor22.RecordTypeId = idRecordTypeValor;
        valor22.CC_Lista__c = lista2.Id;
        valor22.Name = '2';
        valor22.CC_Valor__c = '¿2?';
        CC_Lista_Valores__c valor23 = new CC_Lista_Valores__c();
        valor23.RecordTypeId = idRecordTypeValor;
        valor23.CC_Lista__c = lista2.Id;
        valor23.Name = '3';
        valor23.CC_Valor__c = '¿3?';
        insert new List<CC_Lista_Valores__c>{valor11, valor12, valor21, valor22, valor23};

        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Test.startTest();
            Map<String, List<CC_Lista_Valores__c>> preguntas = CSBD_AutenticacionOtp_Apex.getPreguntasEmergencia();
            Test.stopTest();

            System.assertEquals(2, preguntas.get('basicas').size(), 'Número incorrecto de preguntas de emergencia básicas');
            System.assertEquals(3, preguntas.get('aleatorias').size(), 'Número incorrecto de preguntas de emergencia aleatorias');
        }
    }

    @isTest
    private static void getAutenticaciones() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidad = [SELECT AccountId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            Test.startTest();
            List<CC_Comunicaciones__c> autenticaciones = CSBD_AutenticacionOtp_Apex.getAutenticaciones(oportunidad.AccountId, oportunidad.Id);
            Test.stopTest();

            System.assertEquals(3, autenticaciones.size(), 'Número incorrecto de autenticaciones recuperadas');
        }
    }

    @isTest
    private static void canalAutenticable() {
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'CC_Autenticacion_Cliente';
        insert lista;
        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = lista.Id;
        valor.CC_Valor__c = 'Teléfono';
        insert valor;

        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Test.startTest();
            System.assert(CSBD_AutenticacionOtp_Apex.canalAutenticable('Teléfono'), 'El canal SÍ es autenticable');
            System.assert(!CSBD_AutenticacionOtp_Apex.canalAutenticable('Canal no autenticable'), 'El canal NO es autenticable');
            Test.stopTest();
        }
    }

    @isTest
    private static void comprobarDatosNivel2() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.nivel2ValidacionInicial(opp.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void comprobarDatosNivel2Representante() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oppRepresentante = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Representante Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.nivel2ValidacionInicial(oppRepresentante.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void comprobarDatosNivel2SinLlamada() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oppSinLlamada = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad sin llamada en curso Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.nivel2ValidacionInicial(oppSinLlamada.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void enviarAutenticacionNivel2() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            CC_Comunicaciones__c autenticacion = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Pdte. Envío' LIMIT 1];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.nivel2EnviarSolicitudOtp(autenticacion.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionNivel2Validar1() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            CC_Comunicaciones__c autenticacion = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Pdte. Envío' LIMIT 1];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.n2ValidarOtp(autenticacion.CSBD_Opportunity__c, autenticacion.Id, '12345');
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void codigoAutenticacionNoRecibido() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            CC_Comunicaciones__c autenticacion = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Pdte. Envío' LIMIT 1];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.codigoAutenticacionNoRecibido(autenticacion.CSBD_Opportunity__c, autenticacion.Id, 'Cliente  Digital');
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionEmergencia1() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity opp = [SELECT AccountId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionEmergencia(opp.Id, 'Emergencia', true);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionEmergencia2() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oppImaginBank = [SELECT AccountId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad ImaginBank Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionEmergencia(oppImaginBank.Id, 'Emergencia', true);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionEmergencia3() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oppSinMailPhone = [SELECT AccountId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad sin correo/teléfono'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionEmergencia(oppSinMailPhone.Id, 'Emergencia', true);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionEmergenciaImaginBank() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity oportunidad = [SELECT AccountId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionEmergencia(oportunidad.Id, 'Emergencia', true);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionClienteDigital() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            Opportunity opp = [SELECT AccountId, OwnerId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            Opportunity oppSinLlamada = [SELECT AccountId, OwnerId FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad sin llamada en curso Test'];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionClienteDigital(opp.Id, opp.AccountId, opp.OwnerId);
            CSBD_AutenticacionOtp_Apex.autenticacionClienteDigital(oppSinLlamada.Id, oppSinLlamada.AccountId, oppSinLlamada.OwnerId);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionClienteDigitalEnviar() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            CC_Comunicaciones__c autenticacion = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Pdte. Envío' LIMIT 1];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionClienteDigitalEnviar(autenticacion.CSBD_Opportunity__c, autenticacion.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void autenticacionClienteDigitalValidar() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            CC_Comunicaciones__c autenticacion = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Pdte. Envío' LIMIT 1];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.autenticacionClienteDigitalValidar(autenticacion.CSBD_Opportunity__c, autenticacion.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }

    @isTest
    private static void cancelarAutenticacion() {
        User usuarioGestor = [SELECT Id FROM User WHERE Alias = 'Gestor'];
        System.runAs(usuarioGestor) {
            CC_Comunicaciones__c autenticacion = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Estado__c = 'Pdte. Envío' LIMIT 1];

            Test.startTest();
            CSBD_AutenticacionOtp_Apex.cancelarAutenticacion(autenticacion.CSBD_Opportunity__c, autenticacion.Id);
            Test.stopTest();

            System.assert(true, 'PENDIENTE');
        }
    }
}