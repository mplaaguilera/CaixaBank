@isTest
private class CC_Gestion_Derivar_Amenazas_Test {

    @testSetup
    static void setup() {

        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');

        System.runAs(admin){
            // Crear todas las cuentas en una sola operación
            
            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            List<Account> allAccounts = new List<Account>();
            
            // Centro principal
            Account centro = new Account(
                Name = 'Centro Caixabank 001',
                CC_Email__c = 'test@test.com',
                CC_Numero_Oficina_Empresa__c = '000-14141',
                CC_Tipo_Oficina__c = 'I',
                CC_Numero_Empresa__c = '001',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '16987',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centro);

            // Jerarquía de centros (niveles 6-10)
            Account centroNivel10 = new Account(
                Name = 'Centro Nivel 10',
                CC_Email__c = 'test10@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'DT',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel10);

            Account centroNivel9 = new Account(
                Name = 'Centro Nivel 9',
                CC_Email__c = 'test9@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'DT',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel9);

            Account centroNivel8 = new Account(
                Name = 'Centro Nivel 8',
                CC_Email__c = 'test8@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel8);

            Account centroNivel7 = new Account(
                Name = 'Centro Nivel 7',
                CC_Email__c = 'test7@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel7);
            
            Account centroNivel6 = new Account(
                Name = 'Centro Nivel 6',
                CC_Email__c = 'test6@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel6);

            // Jerarquía de centros (niveles 1-5)
            Account centroNivel5 = new Account(
                Name = 'Centro Nivel 5',
                CC_Email__c = 'test5@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel5);

            Account centroNivel4 = new Account(
                Name = 'Centro Nivel 4',
                CC_Email__c = 'test4@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel4);

            Account centroNivel3 = new Account(
                Name = 'Centro Nivel 3',
                CC_Email__c = 'test3@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel3);

            Account centroNivel2 = new Account(
                Name = 'Centro Nivel 2',
                CC_Email__c = 'test2@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel2);

            Account centroNivel1 = new Account(
                Name = 'Centro Nivel 1',
                CC_Email__c = 'test1@test.com',
                CC_Tipo_Oficina__c = 'I',
                CC_Tipo_Centro__c = 'OF',
                CC_Numero_Oficina__c = '09917',
                RecordtypeId = rtCentroId
            );
            allAccounts.add(centroNivel1);

            // Cuentas de cliente
            Account cuentaImagin1 = new Account(
                FirstName = 'Cuenta Test',
                LastName = 'test',
                CC_Email__c = 'cuenta@test.com',
                AV_IndicadoresClientes__c = '28',
                CC_Numero_Documento__c = '45729937A',
                AV_Cliente__c = true,
                AV_NumPerso__c = '214622853',
                PersonMobilePhone = '666666666',
                RecordtypeId = rtClientePA,
                CC_Numero_Oficina__c = '09917'
            );
            allAccounts.add(cuentaImagin1);

            Account cuentaImagin = new Account(
                FirstName = 'Cuenta Test direccion territorial',
                LastName = 'test',
                CC_Email__c = 'cuenta2@test.com',
                AV_IndicadoresClientes__c = '28',
                CC_Numero_Documento__c = '45720937A',
                AV_Cliente__c = true,
                PersonMobilePhone = '666966666',
                RecordtypeId = rtClientePA,
                CC_Numero_Oficina__c = '09917'
            );
            allAccounts.add(cuentaImagin);

            // Insertar todas las cuentas
            insert allAccounts;

            // Establecer jerarquía
            centroNivel1.ParentId = centroNivel2.Id;
            centroNivel2.ParentId = centroNivel3.Id;
            centroNivel3.ParentId = centroNivel4.Id;
            centroNivel4.ParentId = centroNivel5.Id;
            centroNivel5.ParentId = centroNivel6.Id;
            centroNivel6.ParentId = centroNivel7.Id;
            centroNivel7.ParentId = centroNivel8.Id;
            centroNivel8.ParentId = centroNivel9.Id;
            centroNivel9.ParentId = centroNivel10.Id;
            cuentaImagin.AV_OficinaPrincipal__c = centroNivel1.Id;
            
            update new List<Account>{centroNivel1, centroNivel2, centroNivel3, centroNivel4, centroNivel5, centroNivel6, centroNivel7, centroNivel8, centroNivel9, centroNivel10, cuentaImagin};

            // Crear grupo colaborador
            CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c(
                RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId(),
                Name = 'Amenazas empleados',
                OS_Negocio__c = 'CC'
            );
            insert grupoColaborador;

            // Crear contactos
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

            // Crear caso
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

            // Obtener configuración OWA
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [
                SELECT CC_Direccion_Correo__c 
                FROM CC_Buzones_Por_Defecto__mdt 
                WHERE CC_Canal_Procedencia__c = 'Por defecto' 
                AND CC_Idioma__c = 'Castellano' 
                AND CC_Activo__c = true 
                LIMIT 1
            ];
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

            // Crear todos los shares en una sola operación
            List<SObject> allShares = new List<SObject>();
            
            // Account Shares
            for(Account acc : allAccounts) {
                allShares.add(new AccountShare(
                    AccountId = acc.Id,
                    UserOrGroupId = operador.Id,
                    AccountAccessLevel = 'Read',
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'Read',
                    ContactAccessLevel = 'Read'
                ));
            }
            
            // Contact Shares
            for(Contact con : contactos) {
                allShares.add(new ContactShare(
                    ContactId = con.Id,
                    UserOrGroupId = operador.Id,
                    ContactAccessLevel = 'Read'
                ));
            }
            
            // Grupo Share
            allShares.add(new CC_Grupo_Colaborador__Share(
                ParentId = grupoColaborador.Id,
                UserOrGroupId = operador.Id,
                AccessLevel = 'Read',
                RowCause = 'Manual'
            ));
            
            insert allShares;
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

}