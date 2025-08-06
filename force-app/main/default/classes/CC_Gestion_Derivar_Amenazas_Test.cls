@isTest
private class CC_Gestion_Derivar_Amenazas_Test {

    @testSetup
    static void setup() {

        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');

        System.runAs(admin){

            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');

            //Numero centro riesgo reputacional	16987	 
            //Nombre centro riesgo reputacional	Riesgo Reputacional Andalucia	 
            //Numero direccion territorial	09917	 
            //Nombre direccion territorial	Territorial Andalucia

            //Account con gestion reputacional = 09917 - ANDALUCIA
            Account centro = new Account();
            centro.Name = 'Centro Caixabank 001';
            centro.CC_Email__c = 'test@test.com';
            centro.CC_Numero_Oficina_Empresa__c = '000-14141';
            centro.CC_Tipo_Oficina__c = 'I';
            centro.CC_Numero_Empresa__c  = '001';
            centro.CC_Tipo_Centro__c = 'OF';
            centro.CC_Numero_Oficina__c = '16987';
            centro.RecordtypeId = rtCentroId;
            insert centro;

            Account centroDireccionTerritorial = new Account();
            centroDireccionTerritorial.Name = 'Centro Caixabank 002';
            centroDireccionTerritorial.CC_Email__c = 'test@test.com';
            centroDireccionTerritorial.CC_Tipo_Oficina__c = 'I';
            centroDireccionTerritorial.CC_Tipo_Centro__c = 'OF';
            centroDireccionTerritorial.CC_Numero_Oficina__c = '09917';
            centroDireccionTerritorial.RecordtypeId = rtCentroId;
            insert centroDireccionTerritorial;

            Id recordTypeGrupoColaborador =  Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

            CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
            grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
            grupoColaborador.Name = 'Amenazas empleados';
            grupoColaborador.OS_Negocio__c = 'CC';
            insert grupoColaborador;

            // Crear contactos en bulk
            List<Contact> contactos = new List<Contact>{
                new Contact(
                    LastName = 'Contacto empleado',
                    FirstName = 'Prueba empleado',
                    CC_Inactivo__c = false,
                    Email = 'test@test.com',
                    CC_Matricula__c = 'U0124112',
                    AccountId = centro.Id,
                    AV_DescFuncion__c = 'DIRECCION',
                    RecordtypeId = rtEmpleado,
                    CC_Num_Empleado_Generico__c = '12345'
                ),
                new Contact(
                    LastName = 'Contacto empleado',
                    FirstName = 'Prueba empleado',
                    CC_Inactivo__c = false,
                    Email = 'test2@test.com',
                    CC_Matricula__c = 'U0124113',
                    AccountId = centro.Id,
                    AV_DescFuncion__c = 'DIRECCION',
                    RecordtypeId = rtEmpleado,
                    CC_Num_Empleado_Generico__c = '12945'
                )
            };
            insert contactos;
            
            // Crear relación grupo-colaborador
            CC_Grupo_Colaborador_Contact__c contacto = new CC_Grupo_Colaborador_Contact__c(
                CC_Grupo_Colaborador__c = grupoColaborador.Id,
                CC_Contacto__c = contactos[0].Id
            );
            insert contacto;


            Account cuentaImagin1 = new Account(
                FirstName = 'Cuenta Test',
                LastName = 'test',
                CC_Email__c = 'cuenta@test.com',
                AV_IndicadoresClientes__c = '28',
                CC_Numero_Documento__c = '45729937A',
                AV_Cliente__c = true,
                AV_NumPerso__c = '214622853',
                PersonMobilePhone = '666666666',
                RecordtypeId =  rtClientePA,
                CC_Numero_Oficina__c = '09917'
                );
            insert cuentaImagin1;

            //Account con direccion territorial = 16987 - ANDALUCIA
            Account cuentaImagin = new Account(
                FirstName = 'Cuenta Test direccion territorial',
                LastName = 'test',
                CC_Email__c = 'cuenta2@test.com',
                AV_IndicadoresClientes__c = '28',
                CC_Numero_Documento__c = '45720937A',
                AV_Cliente__c = true,
                PersonMobilePhone = '666966666',
                RecordtypeId =  rtClientePA,
                CC_Numero_Oficina__c = '09917',
                CC_Direccion_Territorial__c = centroDireccionTerritorial.Id
                );
            insert cuentaImagin;

            //Caso de prueba
            Case testCase = new Case(
                Subject='Test Case',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                OwnerId = operador.Id,
                AccountId = cuentaImagin.Id,
                Status = 'Activo'
            );
            insert testCase;

            // Obtener datos de configuración en una sola query
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;

            // Crear lista de valores en bulk
            Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');

            CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c(
                Name = 'Textos operativa Derivar',
                RecordTypeId = recordTypeLista
            );
            insert listaDerivar;

            // Crear valores en una sola operación
            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>{
                new CC_Lista_Valores__c(
                    Name = 'Nombre Plantilla Amenazas Empleados',
                    RecordTypeId = recordTypeValor,
                    CC_Lista__c = listaDerivar.Id,
                    CC_Mensajes_Mostrar__c = 'Amenazas empleados'
                ),
                new CC_Lista_Valores__c(
                    Name = 'Nombre Plantilla Amenazas Suicidios',
                    RecordTypeId = recordTypeValor,
                    CC_Lista__c = listaDerivar.Id,
                    CC_Mensajes_Mostrar__c = 'Amenazas Suicidios'
                ),
                new CC_Lista_Valores__c(
                    Name = 'OWA activa amenazas',
                    RecordTypeId = recordTypeValor,
                    CC_Lista__c = listaDerivar.Id,
                    CC_Mensajes_Mostrar__c = emailCorreoEntrante
                )
            };
            insert valores;

            // Crear Account Share y Contact Share para el operador
            List<AccountShare> accountShares = new List<AccountShare>();
            List<ContactShare> contactShares = new List<ContactShare>();
            
            // Configurar Account Shares
            for(Account acc : new List<Account>{centro, centroDireccionTerritorial, cuentaImagin1, cuentaImagin}) {
                accountShares.add(new AccountShare(
                    AccountId = acc.Id,
                    UserOrGroupId = operador.Id,
                    AccountAccessLevel = 'Read',
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'Read',
                    ContactAccessLevel = 'Read'
                ));
            }
            
            // Configurar Contact Shares
            for(Contact con : contactos) {
                contactShares.add(new ContactShare(
                    ContactId = con.Id,
                    UserOrGroupId = operador.Id,
                    ContactAccessLevel = 'Read'
                ));
            }
            
            insert accountShares;
            insert contactShares;

            // Crear Group Share para CC_Grupo_Colaborador__c
            List<CC_Grupo_Colaborador__Share> grupoShares = new List<CC_Grupo_Colaborador__Share>();
            
            CC_Grupo_Colaborador__Share grupoShare = new CC_Grupo_Colaborador__Share(
                ParentId = grupoColaborador.Id,
                UserOrGroupId = operador.Id,
                AccessLevel = 'Read',
                RowCause = 'Manual'
            );
            grupoShares.add(grupoShare);
            
            insert grupoShares;
        }
    }

    @isTest
    static void testEmailAmenazas() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            // Obtener datos en una sola query
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
            
            // Obtener caso y verificar
            Case caso = [SELECT Id FROM Case WHERE Subject='Test Case' LIMIT 1];
            System.assertNotEquals(null, caso.Id, 'El caso debe existir');
            
            // Parámetros de prueba
            Map<String, String> params = new Map<String, String>{
                '[Motivo amenaza]' => 'Test',
                '[Detalles amenaza]' => 'Test',
                '[Oficina amenazada]' => 'Test',
                '[Empleado amenazado]' => 'Test'
            };
            
            // Ejecutar método
            CC_Gestion_Derivar_Amenazas.operativasEmail(
                caso.Id, 
                true, // tipo = true para amenazas empleados
                'Amenazas empleados', 
                'Amenazas empleados', 
                params, 
                null, 
                emailCorreoEntrante
            );
            System.debug('params: ' + params);
            // Verificaciones básicas
            System.assertEquals(5, params.size(), 'Debe tener 5 parámetros configurados');
        }
        Test.stopTest();
    }

    @isTest
    static void testEmailAmenazasSuicidios() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            // Obtener datos en una sola query
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
            
            // Obtener caso y verificar
            Case caso = [SELECT Id FROM Case WHERE Subject='Test Case' LIMIT 1];
            System.assertNotEquals(null, caso.Id, 'El caso debe existir');
            
            // Parámetros de prueba
            Map<String, String> params = new Map<String, String>{
                '[Motivo amenaza]' => 'Test',
                '[Detalles amenaza]' => 'Test',
                '[Oficina amenazada]' => 'Test',
                '[Empleado amenazado]' => 'Test'
            };
            
            // Ejecutar método
            CC_Gestion_Derivar_Amenazas.operativasEmail(
                caso.Id, 
                false, // tipo = false para amenazas suicidios
                'Amenazas empleados', 
                'Amenazas empleados', 
                params, 
                null, 
                emailCorreoEntrante
            );
            System.debug('params: ' + params);
            // Verificaciones básicas
            System.assertEquals(4, params.size(), 'Debe tener 4 parámetros configurados');
        }
        Test.stopTest();
    }

    @isTest
    static void testObtenerDestinatariosRiesgoReputacional() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            // Ejecutar método directamente
            String[] destinatarios = CC_Gestion_Derivar_Amenazas.obtenerDestinatariosRiesgoReputacional('09917');
            
            // Verificaciones básicas
            System.assertNotEquals(null, destinatarios, 'Los destinatarios no deben ser nulos');
            System.assertNotEquals(0, destinatarios.size(), 'Debe haber al menos un destinatario');
            
            // Verificar formato de email
            for (String email : destinatarios) {
                System.assert(email.contains('@'), 'El email debe contener @');
            }
        }
        Test.stopTest();
    }
}