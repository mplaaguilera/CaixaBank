@isTest
private class CC_Transferir_HDT_CCO_Test {

    @TestSetup
    static void setup() {
        User admin = CC_TestDataFactory.insertUserAdmin();

        System.runAs(admin) {
                
            List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

            List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

            HDT_Parametros__c params = new HDT_Parametros__c();
            params.Name = 'HDT_Email_Respuesta_Empleados_New';
            params.HDT_Configuracion_1__c = owa[0].Address;
            params.HDT_Configuracion_2__c = owa[0].Address;
            insert params;

            CC_Settings__c settings = new CC_Settings__c();
            settings.Name = 'CC_Transferencia_Casos_HDT_CCO';
            settings.CC_Activa__c = true;
            settings.CC_Configuracion_1__c = 'Upsert';
            insert settings;

            CC_Servicio_Genesys__c svcEncuesta = new CC_Servicio_Genesys__c();
            svcEncuesta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Servicio_Genesys__c', 'CC_Encuesta');
            svcEncuesta.Name = 'Servicio Encuesta';
            svcEncuesta.CC_Codigo__c = 'TEST_SABIO';
            svcEncuesta.CC_VDN__c = '555555555';
            svcEncuesta.CC_Fecha_Inicio_Salesforce__c = Date.newInstance(2023, 11, 3);
            svcEncuesta.CBK_Negocio__c = 'CC';
            insert svcEncuesta;

            CC_MCC__c tematica = new CC_MCC__c();
            tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            tematica.Name = 'Tematica Prueba';
            tematica.CC_Tipo_Cliente__c = 'Cliente';
            tematica.CC_Codigo_Externo__c = 'TE00-01';
            tematica.CC_Canal_Operativo__c = 'App Imagin';
            insert tematica;

            CC_MCC__c producto = new CC_MCC__c();
            producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            producto.Name = 'Causa Prueba';
            producto.CC_Tipo_Cliente__c = 'Cliente';
            producto.CC_Codigo_Externo__c = 'PR00-01';
            producto.CC_Tematica__c = tematica.Id;
            insert producto;

            CC_MCC__c motivo = new CC_MCC__c();
            motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            motivo.Name = 'Causa Prueba';
            motivo.CC_Tipo_Cliente__c = 'Cliente';
            motivo.CC_Codigo_Externo__c = 'MO00-01';
            motivo.CC_Producto_Servicio__c = producto.Id;
            insert motivo;


            List<Account> cuentas = new List<Account>();

            Account cuenta = new Account(
                Name = 'Cuenta Test direccion territorial',
                CC_Email__c = 'cuenta2@test.com',
                AV_IndicadoresClientes__c = '28',
                CC_Numero_Documento__c = '45720937A',
                AV_Cliente__c = true,
                Phone = '666966666',
                RecordtypeId =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'),
                CC_Numero_Oficina__c = '09917'
            );
            cuentas.add(cuenta);

            Account cuentaImagin = new Account(
                Name = 'Cuenta Test direccion territorial',
                CC_Email__c = 'cuenta2@test.com',
                AV_IndicadoresClientes__c = '28',
                CC_Numero_Documento__c = '45720937A',
                AV_Cliente__c = true,
                Phone = '666966666',
                RecordtypeId =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
                CC_Numero_Oficina__c = '09917'
            );
            cuentas.add(cuentaImagin);

            insert cuentas;

            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            contacto.FirstName = 'Contacto';
            contacto.LastName = 'Contacto Test';
            contacto.AccountId = cuentaImagin.Id;
            insert contacto;

            Case caso = new Case(
                Subject = 'Test Case',
                Origin = 'Teléfono',
                AccountId = cuenta.Id,
                ContactId = contacto.Id,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
                CC_Idioma__c = 'es',
                OS_Telefono__c = '666666666',
                CC_Detalles_Solucion__c = 'Test',
                CC_Canal_Operativo__c = 'Sin canal',
                CC_Detalles_Consulta__c = 'Test',
                Status = 'Activo',
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivo.Id
            );
            insert caso;
            
            CC_Llamada__c llamada = new CC_Llamada__c(
                CC_Asunto__c = 'Test Case', 
                CC_ANI__c = '666666666', 
                CC_Idioma__c = 'es',
                // Relaciones principales
                CC_Cuenta__c = cuenta.Id, 
                CC_Contacto__c = contacto.Id,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Empleado'),
                // Campos de identificación
                CC_Servicio_Genesys__c = svcEncuesta.Id,
                CC_Case_Consulta__c = caso.Id
            );
            insert llamada;

            CC_Lista_Valores__c lovAvisosSobreAgrupadores2 = new CC_Lista_Valores__c();
            lovAvisosSobreAgrupadores2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovAvisosSobreAgrupadores2.CC_Activa__c = true;
            lovAvisosSobreAgrupadores2.Name = 'HDT - Aviso Comunicaciones Informativas';
            insert lovAvisosSobreAgrupadores2;
    
            CC_Lista_Valores__c valorUmbralSiguientesAvisosx = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisosx.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisosx.CC_Activa__c = true;
            valorUmbralSiguientesAvisosx.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
            valorUmbralSiguientesAvisosx.Name = 'Comunicación Informativa de Caso - Umbral de tiempo';
            valorUmbralSiguientesAvisosx.CC_Valor__c = '15';
    
            CC_Lista_Valores__c valorUmbralSiguientesAvisosx1 = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisosx1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisosx1.CC_Activa__c = true;
            valorUmbralSiguientesAvisosx1.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
            valorUmbralSiguientesAvisosx1.Name = 'Comunicación Informativa de Caso - Umbral Envio de Emails';
            valorUmbralSiguientesAvisosx1.CC_Valor__c = '15';
    
            CC_Lista_Valores__c valorUmbralSiguientesAvisosx2 = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisosx2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisosx2.CC_Activa__c = true;
            valorUmbralSiguientesAvisosx2.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
            valorUmbralSiguientesAvisosx2.Name = 'Comunicación Informativa de Caso - Umbral primer aviso';
            valorUmbralSiguientesAvisosx2.CC_Valor__c = '3';
    
            List<CC_Lista_Valores__c> valorUmbralInsertx = new List<CC_Lista_Valores__c>();
            valorUmbralInsertx.add(valorUmbralSiguientesAvisosx);
            valorUmbralInsertx.add(valorUmbralSiguientesAvisosx1);
            valorUmbralInsertx.add(valorUmbralSiguientesAvisosx2);
            
            insert valorUmbralInsertx;
        }
    }

    @isTest
    static void transferEmpleadoTest() {

        Test.startTest();
            
            System.runAs(CC_TestDataFactory.getUserAdmin()) {

                Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
                CC_Llamada__c llamada = [SELECT Id, CC_Asunto__c, CC_ANI__c, CC_Idioma__c, CC_Cuenta__c, CC_Contacto__c, CC_Servicio_Genesys__c FROM CC_Llamada__c WHERE CC_Case_Consulta__c = :caso.Id LIMIT 1];

                CC_Transferir_HDT_CCO transfer = new CC_Transferir_HDT_CCO(caso.Id, CC_TestDataFactory.getUserAdmin().Id, llamada.Id, 'CC');
                transfer.transferEmpleado();

                Case casoHijo = [SELECT Id, Status, Subject, AccountId, ContactId, RecordTypeId, CC_Tipo_Cliente__c, CC_Fecha_Traslado_1N__c FROM Case WHERE CC_CasoRelacionado__c = :caso.Id];
                System.assertEquals(casoHijo.Status, 'Activo');
            }
            
            Test.stopTest();
    }
}