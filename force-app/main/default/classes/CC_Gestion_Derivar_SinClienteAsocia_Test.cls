@isTest
public with sharing class CC_Gestion_Derivar_SinClienteAsocia_Test {
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
    public static void testIdentificarCliente() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear cuenta y contacto
            Account cuentaCliente = [SELECT Id, CC_Numero_Documento__c FROM Account WHERE CC_NumPerso__c = '214622853' LIMIT 1];
            
            String sTipoBusqueda = 'DOC';
            String sBusqueda = cuentaCliente.CC_Numero_Documento__c;
            
            Map<String, Object> resultado = CC_Gestion_Derivar_SinClienteAsociado.identificarCliente(sTipoBusqueda, sBusqueda);
            
            System.assertNotEquals(null, resultado);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testActualizarCasoMGT() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            
            // Actualizar el caso con un nuevo AccountId
            Id cuentaId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '214622853'].Id;
            CC_Gestion_Derivar_SinClienteAsociado.actualizarCasoMGT(caso.Id, cuentaId);
            
            // Verificar que el caso se haya actualizado correctamente
            Case casoActualizado = [SELECT Id, AccountId FROM Case WHERE Id = :caso.Id];
            System.assertEquals(cuentaId, casoActualizado.AccountId);
        }
        Test.stopTest();
    }
    
  @isTest
    public static void testCrearTareaDerivacionesSinCliente() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            // Crear mapa de datos para la tarea
            String recordId = caso.Id;
            String asunto = 'Derivaciones sin cliente asociado';
            Date fechaActividad = Date.newInstance(2023, 10, 1);
            String comentarios = 'Comentarios de prueba';
            String cuentaFicticia = 'F';
            Boolean crearTareaCitaGestor = true;
            List<String> archivos = new List<String>();
            Id oficinaDestino = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '14141'].Id;
            Boolean enviarTareaOficinaCliente = true;
            Contact gestorSeleccionadoBuscador = [SELECT Id FROM Contact WHERE CC_Num_Empleado_Generico__c = '12345'];
            Boolean otpDerivar = true;
            Map<String, Object> resultado = CC_Gestion_Derivar_SinClienteAsociado.crearTareaDerivacionesSinCliente(
                recordId, asunto, fechaActividad.toString(), comentarios, cuentaFicticia, crearTareaCitaGestor, archivos, oficinaDestino, enviarTareaOficinaCliente, gestorSeleccionadoBuscador, otpDerivar
            );
            System.assertNotEquals(null, resultado);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testRecuperarMensaje() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Recuperar mensaje
            String mensaje = CC_Gestion_Derivar_SinClienteAsociado.recuperarMensaje(1);
            
            System.assertNotEquals(null, mensaje);
        }
        Test.stopTest();
    }

    @isTest
    public static void testBuscarTareaSinCliente() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            
            // Verificar que no existe tarea
            Boolean existeTarea = CC_Gestion_Derivar_SinClienteAsociado.buscarTareaSinCliente(caso.Id);
            System.assertEquals(false, existeTarea);
            
            // Crear tarea
            Task tarea = new Task(
                Subject = 'Derivaciones sin cliente asociado',
                WhatId = caso.Id
            );
            insert tarea;
            
            // Verificar que existe tarea
            existeTarea = CC_Gestion_Derivar_SinClienteAsociado.buscarTareaSinCliente(caso.Id);
            System.assertEquals(true, existeTarea);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCasoNoSeIdentifica() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            // Crear caso
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
            
            // Verificar que no existe tarea
            Boolean respuesta = CC_Gestion_Derivar_SinClienteAsociado.casoNoSeIdentifica(caso.Id);
            System.assertEquals(false, respuesta);
        }
        Test.stopTest();
    }
}