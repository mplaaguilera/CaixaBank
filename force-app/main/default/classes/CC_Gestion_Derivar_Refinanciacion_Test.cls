@isTest
public with sharing class CC_Gestion_Derivar_Refinanciacion_Test {
    @TestSetup
    static void makeData() {
        
        Map<String, User> usuarios = CC_TestDataFactory.insertUserAdminOperador('U0124112');
        User usuarioAdmin = usuarios.get('admin');
        User operadorCliente = usuarios.get('operador');
        System.runAs(usuarioAdmin) {

            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
            Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            Id solucionId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            Id rtCentroId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');

            List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
            List<ContactShare> totalPermisosContact = new List<ContactShare>();

            Account centro = new Account();
            centro.Name = 'Centro Caixabank 001';
            centro.CC_Email__c = 'test@test.com';
            centro.CC_Numero_Oficina_Empresa__c = '000-14141';
            centro.CC_Numero_Oficina__c = '14141';
            centro.CC_Tipo_Oficina__c = 'I';
            centro.CC_Numero_Empresa__c  = '001';
            centro.CC_Tipo_Centro__c = 'OF';
            centro.RecordtypeId = rtCentroId;
            insert centro;

            Contact contactoEmple = new Contact();
            contactoEmple.LastName = 'Contacto empleado';
            contactoEmple.FirstName = 'Prueba empleado';
            contactoEmple.CC_Inactivo__c = false;
            contactoEmple.Email = 'test@test.com';
            contactoEmple.CC_Matricula__c = 'U0124112';
            contactoEmple.AccountId = centro.Id;
            contactoEmple.AV_DescFuncion__c = 'DIRECCION';
            contactoEmple.AccountId = centro.Id;
            contactoEmple.RecordtypeId =  rtEmpleado;
            contactoEmple.CC_Num_Empleado_Generico__c = '12345';
            contactoEmple.AV_Pool__c = true;
            insert contactoEmple;

            //Para operativa CSBD

            Test.startTest();
            //Accounts
            List<Account> accounts = new List<Account>();
            
            Account cuentaCliente = new Account();
            cuentaCliente.LastName = 'Cliente Senior';
            cuentaCliente.AV_EAPGestor__c = contactoEmple.Id;
            cuentaCliente.CC_NumPerso__c = '214622853';
            cuentaCliente.AV_NumPerso__c = '214622853';
            cuentaCliente.AV_IndicadoresClientes__c = '28';
            cuentaCliente.AV_OficinaPrincipal__c = centro.Id;
            cuentaCliente.RecordtypeId =  rtClientePA;
            cuentaCliente.CC_Numero_Documento__c = '45729937A';
            cuentaCliente.AV_Cliente__c = true;
            accounts.add(cuentaCliente);

            
            insert accounts;
            
            for(Account a : [SELECT Id FROM Account]) {
                AccountShare acshare = new AccountShare();
                acshare.AccountId = a.Id;
                acshare.UserOrGroupId = operadorCliente.Id;
                acshare.AccountAccessLevel = 'Edit';
                acshare.OpportunityAccessLevel = 'Edit';
                acshare.CaseAccessLevel = 'Edit';
                totalPermisosAccount.add(acshare);
            }

            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = contactoEmple.Id;
            contactShare.UserOrGroupId = operadorCliente.Id;
            contactShare.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare);
            
            Database.insert(totalPermisosAccount, false);
            
            Database.insert(totalPermisosContact, false);
            
            CC_TestDataFactory.insertarLOVDerivar();
            
            List<CC_MCC__c> tematicas = new List<CC_MCC__c>();
            List<CC_MCC__c> productos = new List<CC_MCC__c>();
            List<CC_MCC__c> motivos = new List<CC_MCC__c>();
            List<CC_MCC__c> causas = new List<CC_MCC__c>();
            List<CC_MCC__c> soluciones = new List<CC_MCC__c>();
            List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();
            
            CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
            );
            tematicas.add(tematica);
            mccCreado.add(tematica);

            insert tematicas;

            CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
            );        
            productos.add(producto);
            mccCreado.add(producto);


            insert productos;

            CC_MCC__c motivoOficina = new CC_MCC__c(
            Name = 'Cambio de Oficina',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Desistir',
            CC_Ambito_Tareas_Imagin__c = 'Desistir',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
            );
            motivos.add(motivoOficina);
            mccCreado.add(motivoOficina);

            insert motivos;
            
            Case caso = new Case(
                Subject = 'Test Case',
                Origin = 'Phone',
                Status = 'Activo',
                RecordTypeId = recordTypeCaso,
                AccountId = cuentaCliente.Id,
                ContactId = contactoEmple.Id,
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoOficina.Id
            );

            insert caso;

            for(CC_MCC__c record : mccCreado) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operadorCliente.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            Id recordTypeLoV = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');

            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c(
                RecordTypeId =  recordTypeLoV,
                Name = 'Textos operativa Derivar '
            );
            insert listaValores;

            CC_Lista_Valores__c valor = new CC_Lista_Valores__c(
                RecordTypeId =  recordTypeValor,
                CC_Lista__c = listaValores.Id,
                Name = 'Texto tarea AV Pool = False',
                CC_Mensajes_Mostrar__c = 'El cliente titular del contrato o contratos [[[xxxxxxxxxxx]]] en situación de morosidad solicita de la entidad que se estudie posible refinanciación de la deuda para facilitarle el cumplimiento de sus obligaciones de pago.'
            );

            insert valor;
            
            CC_TestDataFactory.insertarLOVDerivar();

            List<CC_Settings__c > listCustomSetting= new List<CC_Settings__c >();
            CC_Settings__c  customSetting = new CC_Settings__c ();
            customSetting.Name = 'CC_HubGestion';
            customSetting.CC_Activa__c = true;
            customSetting.CC_Configuracion_1__c = 'test';
            listCustomSetting.add(customSetting);
            
            CC_Settings__c  customSetting2 = new CC_Settings__c ();
            customSetting2.Name = 'CC_HubSales';
            customSetting2.CC_Activa__c = true;
            customSetting2.CC_Configuracion_1__c = 'test';
            listCustomSetting.add(customSetting2);

            CC_Settings__c  customSetting4 = new CC_Settings__c ();
            customSetting4.Name = 'CC_Configuracion_Cita_Rapida';
            customSetting4.CC_Activa__c = true;
            customSetting4.CC_Configuracion_1__c = 'true';
            customSetting4.CC_Configuracion_2__c = 'TELEMATIC';
            customSetting4.CC_Configuracion_3__c = 'true';
            listCustomSetting.add(customSetting4);

            CC_Settings__c  customSetting5 = new CC_Settings__c ();
            customSetting5.Name = 'CC_OcultarModalTrasladarAmbitos';
            customSetting5.CC_Activa__c = true;
            customSetting5.CC_Configuracion_1__c = 'Argos General';
            listCustomSetting.add(customSetting5);
            
            CC_Settings__c  customSetting3 = new CC_Settings__c ();
            customSetting3.Name = 'CC_OperativaOficina';
            customSetting3.CC_Activa__c = true;
            customSetting3.CC_Configuracion_1__c = 'test';
            customSetting3.CC_Configuracion_2__c = 'test';
            customSetting3.CC_Configuracion_3__c = 'test';
            customSetting3.CC_Configuracion_4__c = 'test';
            customSetting3.CC_Configuracion_6__c = 'test';
            customSetting3.CC_Configuracion_7__c = 'test';
            customSetting3.CC_Configuracion_8__c = 'test';
            customSetting3.CC_Configuracion_9__c = 'test';
            customSetting3.CC_Configuracion_10__c = 'test';
            customSetting3.CC_Configuracion_11__c = 'test';
            customSetting3.CC_Configuracion_12__c = 'test';
            customSetting3.CC_Configuracion_13__c = 'test';
            customSetting3.CC_Configuracion_14__c = 'test';
            listCustomSetting.add(customSetting3);            
            insert listCustomSetting;

            
            Test.stopTest();
        }
    } 


        @isTest
    public static void guardarContratosTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso y extensión de caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];

            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Case_Id__c = caso.Id,
                CC_Numeros_Contratos__c = '12345'
            );
            insert caseExtension;

            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            update caso;

            String numerosContratos = '67890';
            CC_Gestion_Derivar_Refinanciacion.guardarContratos(caso.Id, numerosContratos);
            CBK_Case_Extension__c caseExtensionUpdated = [SELECT CC_Numeros_Contratos__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :caso.Id];
            System.assertEquals(numerosContratos, caseExtensionUpdated.CC_Numeros_Contratos__c);
        }
        Test.stopTest();
    }

    @isTest
    public static void guardarContratosSinCaseExtansionTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso y extensión de caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];

            String numerosContratos = '67890';
            CC_Gestion_Derivar_Refinanciacion.guardarContratos(caso.Id, numerosContratos);
            CBK_Case_Extension__c caseExtensionUpdated = [SELECT CC_Numeros_Contratos__c FROM CBK_Case_Extension__c WHERE Case_Id__c = :caso.Id];
            System.assertEquals(numerosContratos, caseExtensionUpdated.CC_Numeros_Contratos__c);
        }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaMGTTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso y extensión de caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Case_Id__c = caso.Id,
                CC_Numeros_Contratos__c = '12345'
            );  
            insert caseExtension;
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            update caso;
            String numerosContratos = '67890';
            Map<String, Object> resultado = CC_Gestion_Derivar_Refinanciacion.crearTareaMGT(caso.Id, 'Test Asunto', '2023-10-01T12:00:00Z', 'Test Comentarios', true, null, true, null, true);
            System.assertNotEquals(resultado.get('mensaje'), null);
        }
        Test.stopTest();
    }

    @isTest
    public static void enviarRespuestaAutomaticaTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Case_Id__c = caso.Id,
                CC_Numeros_Contratos__c = '12345'
            );  
            insert caseExtension;
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            update caso;

            CC_Gestion_Derivar_Refinanciacion.enviarRespuestaAutomatica(caso.Id);
            // Verificar que se envió el correo electrónico
            List <Task> tarea = [SELECT Id, Subject FROM Task WHERE WhatId = :caso.Id AND Subject LIKE 'Email: Respuesta al caso%' LIMIT 1];
            System.assertEquals(tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void obtenerPlantillaEmailTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            List<EmailTemplate> plantilla = CC_Gestion_Derivar_Refinanciacion.obtenerPlantillaEmail('es');
            System.assertNotEquals(null, plantilla);
        }
        Test.stopTest();
    }

    @isTest
    public static void procesarOriginTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso
            Case caso = new Case(
                Subject = 'Test Case',
                Origin = 'Phone',
                Status = 'Activo'
            );
            insert caso;

            String resultado = CC_Gestion_Derivar_Refinanciacion.procesarOrigin(caso.Id);
            System.assertNotEquals(null, resultado);
        }
        Test.stopTest();
    }
}