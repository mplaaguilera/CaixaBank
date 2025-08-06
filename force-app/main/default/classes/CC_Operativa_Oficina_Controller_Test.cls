/* PARA SUBIR COBERTURA AÑADIR CLASES CC_Int_AltaCitaGestor, CC_Int_ObtInfCarterizaCliente y CC_Int_AvailabilitiesGestor */
@isTest
public with sharing class CC_Operativa_Oficina_Controller_Test {
    @TestSetup
    static void makeData() {
        Map<String, Id> profilesCC = CC_TestDataFactory.getProfiles();
        Map<String, Id> rolesCC = CC_TestDataFactory.getRoles();
        Map<String, Id> psCC = CC_TestDataFactory.getPermissionSet();

        User usuarioAdmin = CC_TestDataFactory.createUserAdmin(profilesCC.get('System Administrator'), rolesCC.get('Contact_Center'));
        User operadorCliente = CC_TestDataFactory.createtUserOperador(profilesCC.get('CC_Usuario_CaixaBank'), rolesCC.get('Contact_Center_sin_acceso_a_Directorio'), 'U0124112');
        List<User> usuarios = new List<User>{usuarioAdmin, operadorCliente};
        insert usuarios;

        PermissionSetAssignment psaAdminAV = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_Cliente'));
        PermissionSetAssignment psaOperadorEmpleado = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_CCO'));
        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('CC_Classes'));
        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('AV_GestorOperativa'));
        PermissionSetAssignment psaOperadorCSBD = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psCC.get('CSBD_PS_Gestor'));
        
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>{
            psaOperadorCliente, 
            psaOperadorEmpleado,
            psaOperadorClasses,
            psaOperadorAV,
            psaOperadorCSBD,
            psaAdminAV
        };    

        insert insertPSAssOperadores;

        //User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();
        //User operadorCliente = CC_TestDataFactory.insertUserOperadorCliente('U0124112');
        
        System.runAs(usuarioAdmin) {
            Test.startTest();
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

            Account parentCSBDDerivacion = new Account();
            parentCSBDDerivacion.Name = 'parentCSBDDerivacion Caixabank 001';
            parentCSBDDerivacion.CC_Email__c = 'test@test.com';
            parentCSBDDerivacion.CC_Numero_Oficina_Empresa__c = '000-14146';
            parentCSBDDerivacion.CC_Numero_Oficina__c = '14146';
            parentCSBDDerivacion.CC_Tipo_Oficina__c = 'I';
            parentCSBDDerivacion.CC_Numero_Empresa__c  = '001';
            parentCSBDDerivacion.RecordtypeId = rtCentroId;
            parentCSBDDerivacion.CC_Derivacion_CSBD__c = true;
            insert parentCSBDDerivacion;

            Account centro = new Account();
            centro.Name = 'Centro Caixabank 001';
            centro.CC_Email__c = 'test@test.com';
            centro.CC_Numero_Oficina_Empresa__c = '000-14141';
            centro.CC_Numero_Oficina__c = '14141';
            centro.CC_Tipo_Oficina__c = 'I';
            centro.CC_Numero_Empresa__c  = '001';
            centro.CC_Tipo_Centro__c = 'OF';
            centro.RecordtypeId = rtCentroId;
            centro.ParentId = parentCSBDDerivacion.Id;
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

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.AV_EAPGestor__c = contactoEmple.Id;
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.AV_OficinaPrincipal__c = centro.Id;
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937B';
            cuentaCaixa.AV_Cliente__c = true;
            accounts.add(cuentaCaixa);

            Account clienteConfidencial = new Account();
            clienteConfidencial.LastName = 'Cliente Senior';
            clienteConfidencial.AV_EAPGestor__c = contactoEmple.Id;
            clienteConfidencial.CC_NumPerso__c = '0000013';
            clienteConfidencial.AV_IndicadoresClientes__c = '28';
            clienteConfidencial.AV_OficinaPrincipal__c = centro.Id;
            clienteConfidencial.RecordtypeId =  rtClientePA;
            clienteConfidencial.CC_Numero_Documento__c = '46729937A';
            clienteConfidencial.AV_Confidencial__c = true;
            accounts.add(clienteConfidencial);

            Account clienteNoCliente = new Account();
            clienteNoCliente.LastName = 'Cliente Senior';
            clienteNoCliente.AV_EAPGestor__c = contactoEmple.Id;
            clienteNoCliente.CC_NumPerso__c = '0000014';
            clienteNoCliente.AV_IndicadoresClientes__c = '28';
            clienteNoCliente.AV_OficinaPrincipal__c = centro.Id;
            clienteNoCliente.RecordtypeId =  rtClientePA;
            clienteNoCliente.CC_Numero_Documento__c = '45724937A';
            clienteNoCliente.AV_Cliente__c = false;
            accounts.add(clienteNoCliente);
            
            Account oficina1 = new Account(
            Name = 'Oficina 1',
            CC_Email__c = 'cuenta@test.com',
            CC_Numero_Empresa__c = '123',
            CC_Numero_Oficina_Empresa__c = '000-12345',
            CC_Numero_Oficina__c = '123',
            CC_Numero_Documento__c = '45729937A',
            RecordtypeId =  rtCentroId
            );
            insert oficina1;
            
            Account cuentaImagin = new Account(
            FirstName = 'Cuenta Test',
            LastName = 'test',
            CC_Email__c = 'cuenta@test.com',
            AV_IndicadoresClientes__c = '28',
            AV_EAPGestor__c = contactoEmple.Id,
            AV_OficinaPrincipal__c = centro.Id,
            CC_Numero_Documento__c = '45729937A',
            AV_Cliente__c = true,
            RecordtypeId =  rtClientePA
            );
            accounts.add(cuentaImagin);

            Account cuentaNoImagin = new Account(
            FirstName = 'cuentaNoImagin',
            LastName = 'test',
            CC_Email__c = 'cuenta@test.com',
            AV_IndicadoresClientes__c = '26',
            AV_OficinaPrincipal__c = oficina1.Id,
            CC_Numero_Empresa__c = '123',
            CC_Numero_Oficina_Empresa__c = '000-12348',
            AV_Cliente__c = true,
            CC_Numero_Documento__c = '45729937A',
            RecordtypeId =  rtClientePA
            );
            accounts.add(cuentaNoImagin);
            
            Account cuentaNoImaginContact = new Account(
            FirstName = 'cuentaNoImagin con gestor',
            LastName = 'test',
            CC_Email__c = 'cuenta@test.com',
            AV_IndicadoresClientes__c = '26',
            CC_Numero_Empresa__c = '123',
            CC_Numero_Oficina__c = '00001',
            CC_Numero_Oficina_Empresa__c = '000-12342',
            AV_OficinaPrincipal__c = oficina1.Id,
            AV_EAPGestor__c = contactoEmple.Id,
            CC_Numero_Documento__c = '45729937A',
            AV_Cliente__c = true,
            RecordtypeId =  rtClientePA
            );
            accounts.add(cuentaNoImaginContact);
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

            Boolean excepcion = false;
            
            try {
                Database.insert(totalPermisosAccount, false);
            } catch(Exception e) {
                excepcion = true;
            }

            try {
                Database.insert(totalPermisosContact, false);
            } catch(Exception e) {
                excepcion = true;
            }

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

            CC_MCC__c tematicaCaixaBankNow = new CC_MCC__c(
            Name = 'CaixaBankNow',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000002'
            );
            tematicas.add(tematicaCaixaBankNow);
            mccCreado.add(tematicaCaixaBankNow);
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

            CC_MCC__c productoMecanismo = new CC_MCC__c(
            Name = 'Mecanismo de Firma',
            RecordTypeId = productoId,
            CC_Tematica__c = tematicaCaixaBankNow.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000002'
            );        
            productos.add(productoMecanismo);
            mccCreado.add(productoMecanismo);
            insert productos;

            CC_MCC__c motivoOficina = new CC_MCC__c(
            Name = 'Cambio de Oficina',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Cambio de Oficina',
            CC_Ambito_Tareas_Imagin__c = 'Cambio de Oficina',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
            );
            motivos.add(motivoOficina);
            mccCreado.add(motivoOficina);
            
            CC_MCC__c motivoGestor = new CC_MCC__c(
            Name = 'Cambio de Gestor',
            CC_Ambito_Tareas_Caixa__c = 'Cambio de Gestor',
            CC_Ambito_Tareas_Imagin__c = 'Cambio de Gestor',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000002'
            );
            motivos.add(motivoGestor);
            mccCreado.add(motivoGestor);
            
            CC_MCC__c motivoPrueba = new CC_MCC__c(
            Name = 'Cambio de Prueba',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000003'
            );
            motivos.add(motivoPrueba);
            mccCreado.add(motivoPrueba);
            
            CC_MCC__c motivoOffice = new CC_MCC__c(
            Name = 'Oficina',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Oficina',
            CC_Ambito_Tareas_Imagin__c = 'Oficina',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000004'
            );
            motivos.add(motivoOffice);
            mccCreado.add(motivoOffice);
            
            CC_MCC__c motivoVentas = new CC_MCC__c(
            Name = 'Ventas',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Ventas',
            CC_Ambito_Tareas_Imagin__c = 'Ventas',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000005'
            );
            motivos.add(motivoVentas);
            mccCreado.add(motivoVentas);
            
            CC_MCC__c motivoVacio = new CC_MCC__c(
            Name = 'Vacio',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000006'
            );
            motivos.add(motivoVacio);
            mccCreado.add(motivoVacio);
            
            CC_MCC__c motivoCajeros = new CC_MCC__c(
            Name = 'Cajeros',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Cajeros',
            CC_Ambito_Tareas_Imagin__c = 'Cajeros',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000007'
            );
            motivos.add(motivoCajeros);
            mccCreado.add(motivoCajeros);
            
            CC_MCC__c motivoFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000008'
            );
            motivos.add(motivoFraude);
            mccCreado.add(motivoFraude);

            CC_MCC__c motivoNoCliente = new CC_MCC__c(
            Name = 'No clientes',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'No clientes',
            CC_Ambito_Tareas_Imagin__c = 'No clientes',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000009'
            );
            motivos.add(motivoNoCliente);
            mccCreado.add(motivoNoCliente);

            CC_MCC__c motivoTestamentaria = new CC_MCC__c(
            Name = 'Testamentaria',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Testamentaría',
            CC_Ambito_Tareas_Imagin__c = 'Testamentaría',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000010'
            );
            motivos.add(motivoTestamentaria);
            mccCreado.add(motivoTestamentaria);

            CC_MCC__c motivoActivacionCaixaBank = new CC_MCC__c(
            Name = 'Activación CaixaBankSign',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = productoMecanismo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000011'
            );
            motivos.add(motivoActivacionCaixaBank);
            mccCreado.add(motivoActivacionCaixaBank);

            CC_MCC__c motivoEnrollment = new CC_MCC__c(
            Name = 'Enrollment Sign',
            RecordTypeId = motivoId,
            //CC_Ambito_Tareas_Caixa__c = 'Enrollment Sign',
            CC_Ambito_Tareas_Caixa__c = 'Testamentaría',
            CC_Ambito_Tareas_Imagin__c = 'Testamentaría',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000012'
            );
            motivos.add(motivoEnrollment);
            mccCreado.add(motivoEnrollment);

            CC_MCC__c motivoCSBD3N = new CC_MCC__c(
            Name = 'CSBD 3N',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CSBD 3N',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000013'
            );
            motivos.add(motivoCSBD3N);
            mccCreado.add(motivoCSBD3N);

            CC_MCC__c motivoCSBDContratar = new CC_MCC__c(
            Name = 'CSBD Contratar',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CSBD Contratar',
            CC_Ambito_Tareas_Imagin__c = 'CSBD Contratar',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000014'
            );
            motivos.add(motivoCSBDContratar);
            mccCreado.add(motivoCSBDContratar);

            CC_MCC__c motivoCSBDNoContratar = new CC_MCC__c(
            Name = 'CSBD No Contratar',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CSBD No Contratar',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000015'
            );
            motivos.add(motivoCSBDNoContratar);
            mccCreado.add(motivoCSBDNoContratar);

            CC_MCC__c motivoHubImagin = new CC_MCC__c(
            Name = 'Hub Imagin',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Imagin__c = 'Hub Imagin',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000016'
            );
            motivos.add(motivoHubImagin);
            mccCreado.add(motivoHubImagin);

            CC_MCC__c motivoOficinaFisica = new CC_MCC__c(
            Name = 'Oficina fisica',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Oficina física',
            CC_Ambito_Tareas_Imagin__c = 'Oficina física',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000017'
            );
            motivos.add(motivoOficinaFisica);
            mccCreado.add(motivoOficinaFisica);

            CC_MCC__c motivoSAC = new CC_MCC__c(
            Name = 'SAC',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'SAC',
            CC_Ambito_Tareas_Imagin__c = 'SAC',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000019',
            CC_Canal_Operativo__c = 'Cajero'
            );
            motivos.add(motivoSAC);
            mccCreado.add(motivoSAC);

            CC_MCC__c motivoDocumentacion = new CC_MCC__c(
                Name = 'Documentación',
                RecordTypeId = motivoId,
                CC_Ambito_Tareas_Caixa__c = 'Documentación',
                CC_Ambito_Tareas_Imagin__c = 'Documentación',
                CC_Producto_Servicio__c = producto.Id,
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'MO-000018'
                );
                motivos.add(motivoDocumentacion);
                mccCreado.add(motivoDocumentacion);

            insert motivos;
            
            CC_MCC__c causaFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivoFraude.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
            );
            causas.add(causaFraude);
            mccCreado.add(causaFraude);

            CC_MCC__c causaExtranjero = new CC_MCC__c(
            Name = 'Cliente en el extranjero',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivoActivacionCaixaBank.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000002'
            );
            causas.add(causaExtranjero);
            mccCreado.add(causaExtranjero);
            insert causas;

            CC_MCC__c solucionFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = solucionId,
            CC_Producto_Servicio__c = causaFraude.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'SO-000001',
            CC_AmbitoTareas__c = 'Fraude'
            );
            soluciones.add(solucionFraude);
            mccCreado.add(solucionFraude);
            insert soluciones;

            for(CC_MCC__c record : mccCreado) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operadorCliente.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            Id recordTypeGrupoColaborador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
            CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
            grupo.RecordTypeId = recordTypeGrupoColaborador;
            grupo.name = '3N de CSBD';
            grupo.OS_Negocio__c = 'CC';
            grupo.CC_Queue_Traslado__c = 'Cola_3N_CSBD';
            insert grupo;

            CC_MCC_Grupo_Colaborador__c grupoColaboradorMCC = new CC_MCC_Grupo_Colaborador__c();
            grupoColaboradorMCC.CC_MCC__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'CSBD 3N' AND RecordType.DeveloperName = 'CC_Motivo' LIMIT 1].Id;
            grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupo.Id;
            grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';
            insert grupoColaboradorMCC;
            
            Test.stopTest();
            
            List <Case> insertCase = new List <Case>();
            
            Case casoFraude = new Case();
            casoFraude.Subject = 'Fraude';
            casoFraude.Origin = 'Email';
            casoFraude.Status = 'Activo';
            casoFraude.accountId = cuentaImagin.Id;
            casoFraude.CC_Idioma__c = 'es';
            casoFraude.CC_MCC_Tematica__c = tematica.Id; 
            casoFraude.CC_MCC_ProdServ__c = producto.Id;
            casoFraude.CC_MCC_Motivo__c = motivoFraude.Id;
            casoFraude.CC_MCC_Causa__c = causaFraude.Id;
            casoFraude.CC_MCC_Solucion__c = solucionFraude.Id;
            casoFraude.RecordTypeId = recordTypeCaso;
            insertCase.add(casoFraude);

            Case casoConfidencial = new Case();
            casoConfidencial.Subject = 'Confidencial';
            casoConfidencial.Origin = 'Email';
            casoConfidencial.Status = 'Activo';
            casoConfidencial.accountId = clienteConfidencial.Id;
            casoConfidencial.CC_Idioma__c = 'es';
            casoConfidencial.CC_MCC_Tematica__c = tematica.Id; 
            casoConfidencial.CC_MCC_ProdServ__c = producto.Id;
            casoConfidencial.CC_MCC_Motivo__c = motivoFraude.Id;
            casoConfidencial.RecordTypeId = recordTypeCaso;
            insertCase.add(casoConfidencial);

            Case casoNoCliente = new Case();
            casoNoCliente.Subject = 'No cliente';
            casoNoCliente.Origin = 'Email';
            casoNoCliente.Status = 'Activo';
            casoNoCliente.accountId = clienteNoCliente.Id;
            casoNoCliente.CC_Idioma__c = 'es';
            casoNoCliente.CC_MCC_Tematica__c = tematica.Id; 
            casoNoCliente.CC_MCC_ProdServ__c = producto.Id;
            casoNoCliente.CC_MCC_Motivo__c = motivoFraude.Id;
            casoNoCliente.RecordTypeId = recordTypeCaso;
            insertCase.add(casoNoCliente);

            Case caso3NCSBD = new Case();
            caso3NCSBD.Subject = '3N DE CSBD';
            caso3NCSBD.Origin = 'Email';
            caso3NCSBD.Status = 'Activo';
            caso3NCSBD.accountId = cuentaCliente.Id;
            caso3NCSBD.CC_Idioma__c = 'es';
            caso3NCSBD.CC_MCC_Tematica__c = tematica.Id; 
            caso3NCSBD.CC_MCC_ProdServ__c = producto.Id;
            caso3NCSBD.CC_MCC_Motivo__c = motivoCSBD3N.Id;
            caso3NCSBD.RecordTypeId = recordTypeCaso;
            insertCase.add(caso3NCSBD);

            Case casoContratarCSBD = new Case();
            casoContratarCSBD.Subject = 'CSBD Contratar';
            casoContratarCSBD.Origin = 'Email';
            casoContratarCSBD.Status = 'Activo';
            casoContratarCSBD.accountId = cuentaCliente.Id;
            casoContratarCSBD.CC_Idioma__c = 'es';
            casoContratarCSBD.CC_MCC_Tematica__c = tematica.Id; 
            casoContratarCSBD.CC_MCC_ProdServ__c = producto.Id;
            casoContratarCSBD.CC_MCC_Motivo__c = motivoCSBDContratar.Id;
            casoContratarCSBD.RecordTypeId = recordTypeCaso;
            casoContratarCSBD.CC_OTP_Valido__c = true;
            insertCase.add(casoContratarCSBD);

            Case casoNoContratarCSBD = new Case();
            casoNoContratarCSBD.Subject = 'CSBD No Contratar';
            casoNoContratarCSBD.Origin = 'Email';
            casoNoContratarCSBD.Status = 'Activo';
            casoNoContratarCSBD.accountId = cuentaCaixa.Id;
            casoNoContratarCSBD.CC_Idioma__c = 'es';
            casoNoContratarCSBD.CC_MCC_Tematica__c = tematica.Id; 
            casoNoContratarCSBD.CC_MCC_ProdServ__c = producto.Id;
            casoNoContratarCSBD.CC_MCC_Motivo__c = motivoCSBDNoContratar.Id;
            casoNoContratarCSBD.RecordTypeId = recordTypeCaso;
            casoNoContratarCSBD.CC_OTP_Valido__c = true;
            insertCase.add(casoNoContratarCSBD);
            
            Case casoCajeros = new Case();
            casoCajeros.Subject = 'Cajeros';
            casoCajeros.Origin = 'Email';
            casoCajeros.Status = 'Activo';
            casoCajeros.accountId = cuentaImagin.Id;
            casoCajeros.CC_Idioma__c = 'es';
            casoCajeros.CC_MCC_Tematica__c = tematica.Id; 
            casoCajeros.CC_MCC_ProdServ__c = producto.Id;
            casoCajeros.CC_MCC_Motivo__c = motivoCajeros.Id;
            casoCajeros.RecordTypeId = recordTypeCaso;
            insertCase.add(casoCajeros);
            
            //Case 1 con account Indicadores cliente = 28
            Case casoImagin = new Case(
            Description = 'casoImagin',
            Subject = 'casoImagin',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoOficina.Id,
            CC_Motivo__c = 'Cambio de Oficina',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImagin);
            
            Case casoCC = new Case();
            casoCC.Subject = 'Caso de Contact Center';
            casoCC.Description = 'Caso de Contact Center';
            casoCC.CC_Idioma__c = 'es';
            casoCC.Origin = 'Email';
            casoCC.CC_Tipo_Contacto__c = 'Consulta';
            casoCC.CC_Canal_Procedencia__c = 'Formulario web';
            casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
            casoCC.Status = 'Activo';
            casoCC.AccountId = cuentaCliente.Id;
            casoCC.RecordTypeId = recordTypeCaso;
            insertCase.add(casoCC);
            
            Case casoImaginVentas = new Case(
            Description = 'casoImaginVentas',
            Subject = 'casoImaginVentas',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoVentas.Id,
            CC_Motivo__c = 'Ventas',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginVentas);
            
            Case casoImaginOffice = new Case(
            Description = 'casoImaginOffice',
            Subject = 'casoImaginOffice',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImaginContact.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoOffice.Id,
            CC_Motivo__c = 'Oficina',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginOffice);
            
            //Case 2 con account Indicadores cliente != 28  y motivo oficina
            Case casoNoImaginOficina = new Case(
            Description = 'casoNoImaginOficina',
            Subject = 'casoNoImaginOficina',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = Tematica.Id, 
            CC_MCC_ProdServ__c = Producto.Id,
            CC_MCC_Motivo__c = motivoOficina.Id,
            CC_Motivo__c = 'Cambio de Oficina',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );            
            insertCase.add(casoNoImaginOficina);
            
            //Case 3 con account Indicadores cliente != 28  y motivo gestor
            Case casoNoImaginGestor = new Case(       	
            Description = 'casoNoImaginGestor',
            Subject = 'casoNoImaginGestor',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = Tematica.Id, 
            CC_MCC_ProdServ__c = Producto.Id,
            CC_MCC_Motivo__c = motivoGestor.Id,
            CC_Motivo__c = 'Cambio de Gestor',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );            
            insertCase.add(casoNoImaginGestor);

            //Case 4 con account Indicadores cliente != 28 y otros motivos
            Case casoNoImaginPrueba = new Case(   	
            Description = 'casoNoImaginPrueba',
            AccountId = cuentaNoImagin.Id,
            Subject = 'casoNoImaginPrueba',
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Motivo__c = 'Cambio de Prueba',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_MCC_Tematica__c = Tematica.Id, 
            CC_MCC_ProdServ__c = Producto.Id,
            CC_MCC_Motivo__c = motivoVentas.Id,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoNoImaginPrueba);
            
            //cuentaNoImaginContact
            Case casoNoImaginContact = new Case(   	
            Description = 'casoNoImaginContact',
            Subject = 'casoNoImaginContact',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImaginContact.Id,
            CC_Idioma__c = 'es',
            CC_Motivo__c = 'Test',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_MCC_Tematica__c = Tematica.Id, 
            CC_MCC_ProdServ__c = Producto.Id,
            CC_MCC_Motivo__c = motivoVentas.Id,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoNoImaginContact);

            //Case 5 con account Indicadores cliente != 28 y No Clientes
            Case casoNoImaginNoClientes = new Case(   	
            Description = 'casoNoImaginNoClientes',
            AccountId = cuentaNoImagin.Id,
            Subject = 'casoNoImaginNoClientes',
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Motivo__c = 'No clientes',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_MCC_Tematica__c = Tematica.Id, 
            CC_MCC_ProdServ__c = Producto.Id,
            CC_MCC_Motivo__c = motivoNoCliente.Id,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoNoImaginNoCLientes);

            Case casoImaginPruebaNoClientes = new Case(
            Description = 'casoImaginPruebaNoClientes',
            Subject = 'casoImaginPruebaNoClientes',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoNoCliente.Id,
            CC_Motivo__c = 'No clientes',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginPruebaNoClientes);

            Case casoNoImaginTestamentaria = new Case(   	
            Description = 'casoNoImaginTestamentaria',
            AccountId = cuentaNoImagin.Id,
            Subject = 'casoNoImaginTestamentaria',
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Motivo__c = 'Testamentaria',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_MCC_Tematica__c = Tematica.Id, 
            CC_MCC_ProdServ__c = Producto.Id,
            CC_MCC_Motivo__c = motivoTestamentaria.Id,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoNoImaginTestamentaria);

            Case casoImaginTestamentaria = new Case(
            Description = 'casoImaginTestamentaria',
            Subject = 'casoImaginTestamentaria',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoTestamentaria.Id,
            CC_Motivo__c = 'Testamentaria',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginTestamentaria);

            Case casoEnrollment = new Case(
            Description = 'casoEnrollmentPreguntaSi',
            Subject = 'casoEnrollmentPreguntaSi',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoEnrollment.Id,
            CC_Motivo__c = 'Enrollment Sign',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoEnrollment);

            Case casoDerivar = new Case(
            Description = 'casoDerivar',
            Subject = 'casoDerivar',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );

            insertCase.add(casoDerivar);

            Case casoDNITestamenteria = new Case(
            Description = 'casoDNITestamenteria',
            Subject = 'casoDNITestamenteria',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
    
            insertCase.add(casoDNITestamenteria);

            Case casoHubImagin = new Case(
                Description = 'casoHubImagin',
                Subject = 'casoHubImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaImagin.Id,
                CC_Idioma__c = 'es',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoHubImagin.Id,
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );

            insertCase.add(casoHubImagin);

            Case casoOficinaFisicaImagin = new Case(
                Description = 'casoOficinaFisicaImagin',
                Subject = 'casoOficinaFisicaImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaImagin.Id,
                CC_Idioma__c = 'es',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoOficinaFisica.Id,
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );

            insertCase.add(casoOficinaFisicaImagin);

            Case casoOficinaFisicaNoImagin = new Case(
                Description = 'casoOficinaFisicaNoImagin',
                Subject = 'casoOficinaFisicaNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoOficinaFisica.Id,
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
    
            insertCase.add(casoOficinaFisicaNoImagin);

            Case casoDocumentacionNoImagin = new Case(
                Description = 'casoDocumentacionNoImagin',
                Subject = 'casoDocumentacionNoImagin',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaCaixa.Id,
                CC_Idioma__c = 'es',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoDocumentacion.Id,
                CC_Canal_Respuesta__c = 'Email',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
    
            insertCase.add(casoDocumentacionNoImagin);

            Case casoDerivarSAC = new Case(
                Description = 'casoDerivarSAC',
                Subject = 'casoDerivarSAC',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoSAC.Id,
                CC_MCC_Causa__c = causaFraude.Id,
                CC_Motivo__c = 'casoDerivarSAC',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                CC_Canal_Operativo__c = 'App CaixaBankPay',
                AccountId = cuentaNoImagin.Id,
                ContactId = contactoEmple.Id,
                RecordTypeId = recordTypeCaso
                );

            insertCase.add(casoDerivarSAC);

            Case casoRecla = new Case();
            casoRecla.Subject = 'Tec';
            casoRecla.Origin = 'Backoffice';
            casoRecla.Status = 'SAC_001';
            casoRecla.SAC_StatusAuxiliar__c = casoRecla.Status;
            casoRecla.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

            insertCase.add(casoRecla);
            insert insertCase;
            
            //Se inserta a parte porque necesita el parentId del casoRecla
            Case casoDevolverSAC = new Case(
                Description = 'casoDevolverSAC',
                Subject = 'casoDevolverSAC',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoSAC.Id,
                CC_MCC_Causa__c = causaFraude.Id,
                CC_Motivo__c = 'casoDevolverSAC',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                CC_Canal_Operativo__c = 'App CaixaBankPay',
                AccountId = cuentaNoImagin.Id,
                ContactId = contactoEmple.Id,
                RecordTypeId = recordTypeCaso,
                parentId = casoRecla.Id
                );

                insert casoDevolverSAC;
            
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
            
            CC_Settings__c  customSetting5 = new CC_Settings__c ();
            customSetting5.Name = 'CC_OcultarModalTrasladarAmbitos';
            customSetting5.CC_Activa__c = true;
            customSetting5.CC_Configuracion_1__c = 'Argos General';
            listCustomSetting.add(customSetting5);
            
            CC_Settings__c  derivacionRemitidosAutomaticos = new CC_Settings__c ();
            derivacionRemitidosAutomaticos.Name = 'CC_DerivacionRemitidosAutomaticos';
            derivacionRemitidosAutomaticos.CC_Activa__c = true;
            derivacionRemitidosAutomaticos.CC_Configuracion_1__c = 'CorreosCash;Monte de Piedad;Gestión reputacional;ICP Postventa;Incidencias oficina';
            listCustomSetting.add(derivacionRemitidosAutomaticos);

            CC_Settings__c  ambitosPrioridadSobreNoClientes = new CC_Settings__c ();
            ambitosPrioridadSobreNoClientes.Name = 'CC_AmbitosPrioridadSobreNoClientes';
            ambitosPrioridadSobreNoClientes.CC_Activa__c = true;
            ambitosPrioridadSobreNoClientes.CC_Configuracion_1__c = 'Testamentaría';
            listCustomSetting.add(ambitosPrioridadSobreNoClientes);

            insert listCustomSetting;

            List<CC_DevolverDerivarSAC__c> listacssac = new List<CC_DevolverDerivarSAC__c>();
            CC_DevolverDerivarSAC__c  cssac = new CC_DevolverDerivarSAC__c ();
            cssac.Name = 'CC_Derivar';
            cssac.CC_Activo__c = true;
            listacssac.add(cssac);

            CC_DevolverDerivarSAC__c  cssac2 = new CC_DevolverDerivarSAC__c ();
            cssac2.Name = 'CC_Devolver';
            cssac2.CC_Activo__c = true;
            listacssac.add(cssac2);
            insert listacssac;

            CBK_IntegrationSetting__c customSettingClienteDigital = new CBK_IntegrationSetting__c();
            customSettingClienteDigital.Name = 'CC_Autenticacion_SAU_No_Traza';
            customSettingClienteDigital.NamedCredential__c = 'callout:API_GWT_TST_CCSF/eChannels/eBranchManagement/customers/id/contracts/validation';
            customSettingClienteDigital.RegistroTrazaIntegracion__c = false;
            insert customSettingClienteDigital;
            
            List<Group> grupos = new List<Group>();

            Group groupTransfer = new Group(Name='Cons Form Buildingcenter', Type='Queue');
            grupos.add(groupTransfer);

            Group groupVideollamada = new Group(Name='Videollamada_Enrollment_Caixabank_Sign', Type='Queue');
            grupos.add(groupVideollamada);

            Group groupCSBD = new Group(Name='Cola_3N_CSBD', Type='Queue');
            grupos.add(groupCSBD);
            insert grupos;

            List<QueuesObject> colas = new List<QueuesObject>();
            QueuesObject queueTransfer = new QueueSObject(QueueID = groupTransfer.id, SObjectType = 'Case');
            colas.add(queueTransfer);
            QueuesObject queueCSBD = new QueueSObject(QueueID = groupCSBD.id, SObjectType = 'Case');
            colas.add(queueCSBD);
            insert colas;

            /*Opportunity oportunidad1 = CSBD_Opportunity.crearOportunidad('CSBD_MAC');
            oportunidad1.CSBD_CasoOrigen__c = casoEnrollment.Id;
            update oportunidad1;*/
            
        }
    } 

    
    @isTest
    public static void getDatosTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
            Case casoImagin = [SELECT Id from Case Where CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c = '28'];
            Map<String, Object> resultadoImagin = CC_Operativa_Oficina_Controller.getDatos(casoImagin.Id, null);
            System.assertEquals(resultadoImagin.get('mostrarModalCreacionTarea'), true, 'Error en caso Imagin');
            
            Case casoNoImaginOficina = [SELECT Id from Case Where CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c != '28'];
            Map<String, Object> resultadoNoImaginOficina = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginOficina.Id, null);
            System.assertEquals(resultadoNoImaginOficina.get('cambioOficina'), true, 'Error en caso 2');
            
            Case casoNoImaginGestor = [SELECT Id from Case Where CC_Motivo__c = 'Cambio de Gestor'];
            Map<String, Object> resultadoNoImaginGestor = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginGestor.Id, null);
            System.assertEquals(resultadoNoImaginGestor.get('mostrarModalCreacionTarea'), true, 'Error en caso 3');
            System.assertEquals(resultadoNoImaginGestor.get('cambioGestor'), true, 'Error en caso 3');
            
            Case casoNoImaginPrueba = [SELECT Id from Case Where CC_Motivo__c = 'Cambio de Prueba'];
            Map<String, Object> resultadoNoImaginPrueba = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginPrueba.Id, null);
            //System.assertEquals(resultadoNoImaginPrueba.get('mostrarModalGestionGestorGenerico'), true, 'Error en caso 4');
                       
            Case casoNoImaginNoClientesPrueba = [SELECT Id from Case Where CC_Motivo__c = 'No clientes' AND  Account.AV_IndicadoresClientes__c != '28'];
            Map<String, Object> resultadoNoImaginPruebaNoCliente = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginNoClientesPrueba.Id, null);
            System.assertEquals(resultadoNoImaginPruebaNoCliente.get('cambioOficina'), true, 'Error en caso 5');
            
            Case cajeros = [SELECT Id from Case Where Subject = 'Cajeros'];
            Map<String, Object> resultadoCajeros = CC_Operativa_Oficina_Controller.getDatos(cajeros.Id, null);
            System.assertNotEquals(resultadoCajeros.get('preguntaCajeros'), null, 'Error en caso cajeros');
            
            // Case fraude = [SELECT Id from Case Where Subject = 'Fraude'];
            // Map<String, Object> resultadoFraude = CC_Operativa_Oficina_Controller.getDatos(fraude.Id, null);
            // System.assertNotEquals(resultadoFraude.get('preguntaRealizarRemitido'), null, 'Error en caso fraude');
            
            // Case testamentaria = [SELECT Id from Case Where Subject = 'casoImaginTestamentaria'];
            // Map<String, Object> resultadoTestamentaria = CC_Operativa_Oficina_Controller.getDatos(testamentaria.Id, null);
            // System.assertEquals(resultadoTestamentaria.get('mostrarModalDNITestamentaria'), true);

            // Case hubImagin = [SELECT Id from Case Where Subject = 'casoHubImagin'];
            // Map<String, Object> resultadoHubImagin = CC_Operativa_Oficina_Controller.getDatos(hubImagin.Id, null);
            // System.assertEquals(resultadoHubImagin.get('hubImagin'), true);

            // Case oficinaFisicaImagin = [SELECT Id from Case Where Subject = 'casoOficinaFisicaImagin'];
            // Map<String, Object> resultadoOficinaFisicaImagin = CC_Operativa_Oficina_Controller.getDatos(oficinaFisicaImagin.Id, null);
            // System.assertEquals(resultadoOficinaFisicaImagin.get('oficinaFisica'), true);

            // Case oficinaFisicaNoImagin = [SELECT Id from Case Where Subject = 'casoOficinaFisicaNoImagin'];
            // Map<String, Object> resultadoficinaFisicaNoImagin = CC_Operativa_Oficina_Controller.getDatos(oficinaFisicaNoImagin.Id, null);
            //System.assertEquals(resultadoficinaFisicaNoImagin.get('hubImagin'), true);

            /*Case enrollment = [SELECT Id from Case Where Subject = 'casoEnrollmentPreguntaSi'];
            Map<String, Object> resultadoEnrollment = CC_Operativa_Oficina_Controller.getDatos(enrollment.Id);
            System.assertEquals(resultadoEnrollment.get('preguntaEnrollment'), '¿El cliente se encuentra en el extranjero?');*/

            // Case csbdContratar  = [SELECT Id, CC_DevolucionCSBD__c from Case Where Subject = 'CSBD Contratar'];
            // Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_SAU(200));
            // Map<String, Object> resultadoCSBDContratar  = CC_Operativa_Oficina_Controller.getDatos(csbdContratar.Id, null);
            // System.assertNotEquals(resultadoCSBDContratar.get('preguntaCSBDContratar'), null, 'Error en caso de CSBD Contratar');

            // Case casoDocumentacionNoImagin  = [SELECT Id, CC_DevolucionCSBD__c from Case Where Subject = 'casoDocumentacionNoImagin'];
            // Map<String, Object> casoDocumentacionNoImaginresult  = CC_Operativa_Oficina_Controller.getDatos(casoDocumentacionNoImagin.Id, null);
            // System.debug(JSON.serialize(casoDocumentacionNoImaginresult));
            // System.assertNotEquals(casoDocumentacionNoImaginresult.get('textoDocumentacionCertificado'), null, 'Error en caso de Documentación');

            // Case csbdNoContratar = [SELECT Id, AccountId, Account.AV_OficinaPrincipal__r.Parent.CC_Derivacion_CSBD__c, Account.AV_OficinaPrincipal__r.ParentId, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, CC_MCC_Motivo__r.CC_Alerta_Imagin__c from Case Where Subject = 'CSBD No Contratar'];
            // Map<String, Object> resultadoCSBDNoContratar = CC_Operativa_Oficina_Controller.getDatos(csbdNoContratar.Id, null);

            // Case casoNoCliente  = [SELECT Id, CC_DevolucionCSBD__c from Case Where Subject = 'No cliente'];
            // Map<String, Object> casoNoClienteResultado  = CC_Operativa_Oficina_Controller.getDatos(casoNoCliente.Id, null);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoImagin() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Case casoCCVentas = [SELECT Id from Case where Subject = 'casoImagin'];
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            //Caso ventas
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentas.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);            
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoImaginVentas() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCVentasImagin = [SELECT Id from Case where Subject = 'casoImaginVentas' LIMIT 1];
            //Caso ventas
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasImagin.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoImaginVentasSinGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Account cuenta = [SELECT Id, AV_EAPGestor__c from Account where FirstName = 'Cuenta Test' LIMIT 1];
            Case casoCCVentasImagin = [SELECT Id from Case where Subject = 'casoImaginVentas' LIMIT 1];
            cuenta.AV_EAPGestor__c = null;
            update cuenta;
            //Caso ventas
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasImagin.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoNoImaginOficina() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCVentasNoImagin = [SELECT Id from Case where Subject = 'casoNoImaginOficina' LIMIT 1];
            //Caso ventas no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true , contacto, null);            
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, false, true, null, false);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCGestorNoImagin = [SELECT Id from Case where Subject = 'casoNoImaginGestor' LIMIT 1];
            // Account cuentaImagin = [SELECT Id from Account where AV_IndicadoresClientes__c = '28' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCGestorNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            //Caso gestor imagin
            // casoCCGestorNoImagin.accountId = cuentaImagin.Id;
            // upsert casoCCGestorNoImagin;
            // CC_Operativa_Oficina_Controller.crearTarea(casoCCGestorNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoNoImaginGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCPruebaNoImagin = [SELECT Id from Case where Subject = 'casoNoImaginContact' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestVentasGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCPruebaNoImagin = [SELECT Id from Case where Subject = 'casoImaginVentas' LIMIT 1];
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    /*@isTest
    public static void crearTareaTestCasoEnrollment() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCPruebaNoImagin = [SELECT Id from Case where Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }*/
    
    @isTest
    public static void crearTareaTestCasoCambiarGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCPruebaNoImagin = [SELECT Id from Case where Subject = 'casoNoImaginGestor' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
 /*   @isTest
    public static void buscarGestoresTest() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1];
        System.runAs(operador) {
            Account oficina = [SELECT Id, Name from Account where Name = 'Centro Caixabank 001' LIMIT 1];
            List<Contact> resultado = CC_Operativa_Oficina_Controller.buscarGestores(oficina.Id.toString());
            System.assert(resultado.size() != 0, true);
        }
        Test.stopTest();
    }*/
    
    @isTest
    public static void getURLNumeroOficinaTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Account url = [SELECT Id from Account where CC_Numero_Oficina__c = '00001' LIMIT 1];
            Map<String, String>resultado = CC_Operativa_Oficina_Controller.getURLNumeroOficina(url.Id);
            System.assert(resultado.size() != 0, true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void casoImaginAmbitoOficina() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case caso = [SELECT Id, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c from Case where Subject = 'casoImagin' LIMIT 1];
            CC_MCC__c mcc = [SELECT Id from CC_MCC__c where Name = 'Oficina' LIMIT 1];
            caso.CC_MCC_Motivo__c = mcc.Id;
            update caso;
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void casoImaginAmbitoVacio() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case caso = [SELECT Id, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c from Case where Subject = 'casoImagin' LIMIT 1];
            CC_MCC__c mcc = [SELECT Id from CC_MCC__c where Name = 'Vacio' LIMIT 1];
            caso.CC_MCC_Motivo__c = mcc.Id;
            update caso;
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null,centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void casoImaginAmbitoVacioSinGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Account cuenta = [SELECT Id, AV_EAPGestor__c from Account where FirstName = 'Cuenta Test' LIMIT 1];
            Case caso = [SELECT Id, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, Account.AV_EAPGestor__c from Case where Subject = 'casoImagin' LIMIT 1];
            CC_MCC__c mcc = [SELECT Id from CC_MCC__c where Name = 'Vacio' LIMIT 1];
            caso.CC_MCC_Motivo__c = mcc.Id;
            cuenta.AV_EAPGestor__c = null;
            update caso;
            update cuenta;
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void casoCaixabankAmbitoVacioSinGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Account cuenta = [SELECT Id from Account where FirstName = 'cuentaNoImagin' LIMIT 1];
            Case caso = [SELECT Id, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, Account.AV_EAPGestor__c from Case where Subject = 'casoImagin' LIMIT 1];
            CC_MCC__c mcc = [SELECT Id from CC_MCC__c where Name = 'Vacio' LIMIT 1];
            caso.CC_MCC_Motivo__c = mcc.Id;
            caso.AccountId = cuenta.Id;
            update caso;
            update cuenta;
            ContentVersion file = new ContentVersion();
            file.PathOnClient = 'test.jpg';
            file.VersionData = Blob.valueOf('Test Content');
            insert file;
            List <String> fileList = new List <String>();
            fileList.add(String.valueOf(file.Id)); 
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, fileList, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void casoCaixabankAmbitoVacioConGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id, CC_Numero_Oficina__c, CC_Matricula__c from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Account cuenta = [SELECT Id from Account where FirstName = 'cuentaNoImagin con gestor' LIMIT 1];
            Case caso = [SELECT Id, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, Account.AV_EAPGestor__c from Case where Subject = 'casoImagin' LIMIT 1];
            CC_MCC__c mcc = [SELECT Id from CC_MCC__c where Name = 'Vacio' LIMIT 1];
            caso.CC_MCC_Motivo__c = mcc.Id;
            caso.AccountId = cuenta.Id;
            update caso;
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, false, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestGestor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCPruebaNoImagin = [SELECT Id, Account.AV_EAPGestor__c from Case where Subject = 'casoNoImaginContact' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
            
    // @isTest
    // public static void crearTareaTestcasoNoImaginNoClientes() {
    //     Test.startTest();
    //     System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
    //         String asunto = 'Prueba';
    //         String fechaActividad = date.today().toString();
    //         String comentarios = 'Prueba';
    //         Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
    //         Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
    //         Case casoNoImaginNoClientes = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoNoImaginNoClientes' LIMIT 1];
            
    //         //Caso gestor no imagin
    //         CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginNoClientes.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
    //         Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
    //         System.assert(!tarea.isEmpty(), true);

    //         Case casoNoImaginNoClientesPrueba = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoImaginPruebaNoClientes' LIMIT 1];
    //         CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginNoClientesPrueba.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
    //         Task[] tareaprueba = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
    //         System.assert(!tareaprueba.isEmpty(), true);
    //         }
    //     Test.stopTest();
    // }
    
              
    @isTest
    public static void crearTareaTestcasoTestamentaria() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoNoImaginTestamentaria = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoNoImaginTestamentaria' LIMIT 1];
            
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginTestamentaria.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);

            Case casoImaginTestamentaria = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoImaginTestamentaria' LIMIT 1];

            CC_Operativa_Oficina_Controller.crearTarea(casoImaginTestamentaria.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tareaprueba = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tareaprueba.isEmpty(), true);
            }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaTestHubImagin() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoHubImagin = [SELECT Id, Account.AV_EAPGestor__c from Case where Subject = 'casoHubImagin' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoHubImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaTestOficinaFisicaNoImagin() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoOficinaFisicaNoImagin = [SELECT Id, Account.AV_EAPGestor__c from Case where Subject = 'casoOficinaFisicaNoImagin' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoOficinaFisicaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaTestOficinaFisicaImagin() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoOficinaFisicaImagin = [SELECT Id, Account.AV_EAPGestor__c from Case where Subject = 'casoOficinaFisicaImagin' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoOficinaFisicaImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
            }
        Test.stopTest();
    }
    @isTest
    public static void buscarOficinasTest(){
   
        List<Account> resultado = new List<Account>();
        Id recordTypeCentro = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
    Test.startTest();
            System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
    
                List<Account> accCentro = [SELECT Id, Name FROM Account WHERE RecordtypeId =: recordTypeCentro];
                Id [] fixedSearchResults= new Id[1];
                fixedSearchResults[0] = accCentro[0].Id;
                Test.setFixedSearchResults(fixedSearchResults);
                resultado = CC_Operativa_Oficina_Controller.buscarOficinas(accCentro[0].Name);
            }
    Test.stopTest();
    System.assert(resultado.size() != 0, true);
    }
    
    
    @isTest
    public static void buscarGestoresGlobalTest(){
        List<Contact> resultado = new List<Contact>();
        Id recordTypeEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
    Test.startTest();
            System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {               
                List<Contact> contactoEmple = [SELECT Id, FirstName FROM Contact WHERE RecordtypeId =: recordTypeEmpleado];
    Id [] fixedSearchResults= new Id[1];
                fixedSearchResults[0] = contactoEmple[0].Id;
    Test.setFixedSearchResults(fixedSearchResults);
                resultado = CC_Operativa_Oficina_Controller.buscarGestoresGlobal(contactoEmple[0].FirstName);
            }
    Test.stopTest();
    System.assert(resultado.size() != 0, true);
    }

    @isTest
    public static void recuperarCampoDerivar(){
        
        Test.startTest();
        Case caso = [SELECT Id,CC_Derivar__c FROM Case WHERE Subject = 'casoDerivar' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Boolean campoRecuperado = CC_Operativa_Oficina_Controller.recuperarCampoDerivar(caso.Id);
            System.assertEquals(campoRecuperado, true);
        }
        Test.stopTest();
    }

    @isTest
    public static void dniTestamentaria(){
        
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoDNITestamenteria' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String dni = '49569856A';
             CC_Operativa_Oficina_Controller.dniTestamentaria(dni,caso.Id);
            Case casoActualizado = [SELECT CC_DNI_Difunto__c FROM Case WHERE Subject = 'casoDNITestamenteria' LIMIT 1];

            System.assertEquals(casoActualizado.CC_DNI_Difunto__c,dni);
        }
        Test.stopTest();
    }

    /*@isTest
    public static void preguntaEnrollmentDatosSi(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            CC_Operativa_Oficina_Controller.preguntaEnrollmentDatosSi(caso.Id);
            CC_Operativa_Oficina_Controller.recuperarDatosEntradaFlow(caso.Id);
            Case casoCerrado = [SELECT Status FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            System.assertEquals(casoCerrado.Status, 'Cerrado');
        }
        Test.stopTest();
    }*/

    @isTest
    public static void devolverCasoCSBD() {
        
        Test.startTest();
        Case caso = [SELECT Id, OwnerId FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        Map<String, Object> respuesta = new Map<String, Object>();
        respuesta.put('casoId', caso.Id);
        Opportunity oportunidadCaso = CSBD_Opportunity.crearOportunidad(
            'CSBD_MAC', 
            new Map<String, Object>
            {
                'CSBD_Resolucion__c' => 'Devolución a contact', 
                'CSBD_CasoOrigen__c' => caso.Id
            }
        );
        //crear tarea
        Task tarea = new Task();
		tarea.Subject = 'Creación oportunidad';
		tarea.Status = 'Completed';
		tarea.Priority = 'Normal';
		tarea.Type = 'Oportunidad CSBD';
		tarea.WhatId = caso.Id;
		tarea.OwnerId = caso.OwnerId;
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();
		insert tarea;
       // CC_Operativa_Oficina_Controller.crearOportunidad(caso.Id);
        respuesta.put('oportunidadId', oportunidadCaso.Id);

        Boolean excepcion = false;
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {

            try {
                CC_Operativa_Oficina_Controller.devolverCasoCSBD(respuesta);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, false);
            /*Case casoCerrado = [SELECT Status FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            System.assertEquals(casoCerrado.Status, 'Cerrado');*/
            try {
                respuesta.put('casoId', '');
                respuesta.put('oportunidadId', '');
                CC_Operativa_Oficina_Controller.devolverCasoCSBD(respuesta);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, true);
        }
        Test.stopTest();
    }

   /* @isTest
    public static void reabrirCasoCSBD() {
       
        Case caso = [SELECT Id, OwnerId, ContactId FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        User operador = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1];
        Map<String, String> casosId = new Map<String, String>();
        casosId.put('casoId', caso.Id);

        Opportunity oportunidadCaso = CSBD_Opportunity.crearOportunidad('CSBD_MAC', new Map<String, Object>{'CSBD_Resolucion__c' => 'Devolución a contact'});
        casosId.put('oportunidadId', oportunidadCaso.Id);
        
        Task tareaOportunidad = new Task();
        tareaOportunidad.Type = 'Oportunidad CSBD';
        tareaOportunidad.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tareaOportunidad.Subject = 'Creación oportunidad';
        tareaOportunidad.Status = 'Completed';
        tareaOportunidad.Priority = 'Normal';
        tareaOportunidad.Description = '';
        tareaOportunidad.WhatId = caso.Id;
        tareaOportunidad.AV_OrigenAct__c = 'Contact Center';
        tareaOportunidad.OwnerId = caso.OwnerId;
        tareaOportunidad.Type = 'Oportunidad CSBD';
        tareaOportunidad.AV_Case__c = caso.Id;
        tareaOportunidad.WhoId = caso.ContactId;
        insert tareaOportunidad;

        // Share opportunity with the user
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityId = oportunidadCaso.Id;
        oppShare.UserOrGroupId = operador.Id;
        oppShare.OpportunityAccessLevel = 'Read';
        insert oppShare;

        Test.startTest();
        System.runAs(operador) {
            CC_Gestion_Derivar_CSBD.reabrirCasoCSBD(casosId);
            Case casoCerrado = [SELECT Status FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            System.assertEquals(casoCerrado.Status, 'Activo');
        }
        Test.stopTest();
    }
*/
    @isTest
    public static void crearOportunidad() {
        Test.startTest();
        Boolean excepcion = false;
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            try {
                CC_Operativa_Oficina_Controller.crearOportunidad(caso.Id);
            } catch (Exception e) {
                excepcion = true;
            }
            try {
                CC_Operativa_Oficina_Controller.crearOportunidad('');
            } catch (Exception e) {
                excepcion = true;
            }
            Case casoCerrado = [SELECT Status FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            System.assertEquals(casoCerrado.Status, 'Activo');
        }
        Test.stopTest();
    }

    @isTest
    public static void comprobarOportunidadExistente(){
        Test.startTest();
        Boolean result = true;
        Boolean excepcion = false;
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        caso.CC_Oportunidad_Creada__c = true;
        update caso;
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            try {
                result = CC_Operativa_Oficina_Controller.comprobarOportunidadExistente(caso.Id);
            } catch (Exception e) {
                excepcion = true;
            }

            System.assertEquals(excepcion, false, 'Ocurrió una excepción');
            System.assertEquals(result, true, 'Fallo en la comprobacion');

            result = CC_Operativa_Oficina_Controller.comprobarOportunidadExistente('');  
            System.assertEquals(result, false, 'Fallo en la comprobacion');
        }
        Test.stopTest();
    }

    /*@isTest
    public static void  realizarTraslado3N() {
        Test.startTest();
        Case caso = [SELECT Id, OwnerId FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            /*Id recordTypeGrupoColaborador = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Tercer_Nivel');
            CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
            grupo.RecordTypeId = recordTypeGrupoColaborador;
            grupo.name = '3N de CSBD';
            grupo.OS_Negocio__c = 'CC';
            grupo.CC_Queue_Traslado__c = 'Cola_3N_CSBD';
            insert grupo;

            CC_MCC_Grupo_Colaborador__c grupoColaboradorMCC = new CC_MCC_Grupo_Colaborador__c();
            grupoColaboradorMCC.CC_MCC__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Enrollment Sign'].Id;
            grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupo.Id;
            grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';
            insert grupoColaboradorMCC;

            CC_Operativa_Oficina_Controller.realizarTraslado3N(caso.Id);
            Case casoNew = [SELECT OwnerId FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            System.assertNotEquals(casoNew.OwnerId, caso.OwnerId, 'Error al cambiar de propietario');
        }
        Test.stopTest();
    }*/

    @isTest
    public static void recuperarDatosEntradaFlow() {
        Test.startTest();
        Boolean excepcion = false;
        Case caso = [SELECT Id, OwnerId FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            try {
                Map<String, Object> resultado = CC_Operativa_Oficina_Controller.recuperarDatosEntradaFlow(caso.Id);
                System.assertEquals(excepcion, false);
            } catch (Exception e) {
                excepcion = true;
            }
            try {
                Map<String, Object> resultado = CC_Operativa_Oficina_Controller.recuperarDatosEntradaFlow('');
                System.assertEquals(excepcion, false);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, true);
        }
        Test.stopTest();
    }

    @isTest
    public static void realizarTraslado3N() {
        Test.startTest();
        Boolean excepcion = false;
        Case caso = [SELECT Id, OwnerId FROM Case WHERE Subject = '3N DE CSBD' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            try {
                CC_Operativa_Oficina_Controller.realizarTraslado3N(caso.Id);
                System.assertEquals(excepcion, false);
            } catch (Exception e) {
                excepcion = true;
            }
            try {
                CC_Operativa_Oficina_Controller.realizarTraslado3N('');
                System.assertEquals(excepcion, false);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, true);
        }
        Test.stopTest();
    }

    @isTest
    public static void crearNuevoCasoDocumentacionTest() {
        Test.startTest();
        Boolean excepcion = false;
        Case caso = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'casoDocumentacionNoImagin' LIMIT 1];
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            try{
                CC_Operativa_Oficina_Controller.crearNuevoCasoDocumentacion(caso.Id);
            }catch(Exception e){
                excepcion = true;
            }         
            //Integer casoCount = [SELECT COUNT() FROM Case WHERE CBK_Case_Extension_Id__r.CC_Documentacion__c = true];
            System.assert(!excepcion, 'Se ha lanzado una exception');
        }
        Test.stopTest();
    }

    @isTest
    public static void casoNoCliente() {
        Test.startTest();
        Case caso = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'No cliente' LIMIT 1];
        String asunto = 'Prueba';
        String fechaActividad = date.today().toString();
        String comentarios = 'Prueba';
        Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
        Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            CC_Operativa_Oficina_Controller.crearNuevoCasoFraude(caso.Id.toString());
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_AltaCitaGestor.RespuestaAltaContacto respuestaAltaCita = new CC_Int_AltaCitaGestor.RespuestaAltaContacto();
            respuestaAltaCita.resultat = 'OK';
            respuestaAltaCita.empleCont = '56530';
            respuestaAltaCita.numCont = '1';
            respuestaAltaCita.txtError = 'OK';
            String respuestaAltaCitaString = JSON.serialize(respuestaAltaCita);
            
            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(respuestaAltaCitaString);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void getAvaibilitiesGestor2(){
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {      
        Case caso = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'No cliente' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        Map<String, String> respuesta = CC_Operativa_Oficina_Controller.altaCitaGestor(caso.Id, '56530', 'Gestor A', '00615', 'asunto', '2022-06-23', '09:30', 'Entrevista');      
        
        System.assertEquals('OK', respuesta.get('resultat'));
        }
        Test.stopTest();
    }

    private class MockHttpResponseExitoEsCliente implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital respuestaClienteDigital = new CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital();
            respuestaClienteDigital.empleado1 = '62433';
            respuestaClienteDigital.gestorOEAP1 = 'E';
            respuestaClienteDigital.oficina1 = '2591';
            respuestaClienteDigital.clienteDigital = 'N';
            respuestaClienteDigital.muroAbierto = 'N';
            respuestaClienteDigital.resultado = 'OK';
            respuestaClienteDigital.pilotoAppNow1 = 'S';
            respuestaClienteDigital.indSexo1 = 'H';

            String bodyClienteDigital = JSON.serialize(respuestaClienteDigital);

            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void esClienteDigital(){
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {          
            Test.startTest();
                Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoEsCliente());
                Map<Object, Object> respuesta = CC_Operativa_Oficina_Controller.esClienteDigital(caso.Id, 'Tarea gestor');      
            Test.stopTest();            
            System.assertEquals('OK', respuesta.get('resultado'));
            System.assertEquals('62433', respuesta.get('empleado1'));
            
        }
    }

    private class MockHttpResponseExitoBackUp implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_AvailabilitiesGestor.Availability disponibilidad = new CC_Int_AvailabilitiesGestor.Availability();
            disponibilidad.employeeId = '23456';
            disponibilidad.dateAvailable = '2022-06-20';
            disponibilidad.startTime = '15:30';
            disponibilidad.endTime ='18:00';
            disponibilidad.branchId = '9945';
            disponibilidad.isManager = 'true';
            disponibilidad.isBackup = 'false';
            disponibilidad.name = 'GESTOR';
            disponibilidad.surname = 'APELLIDO';
            disponibilidad.secondSurname = 'APELLIDO2';
            disponibilidad.branchName ='CAIXA';
            disponibilidad.telework = 'N';
            
            CC_Int_AvailabilitiesGestor.StatusResp respuestaEstado = new CC_Int_AvailabilitiesGestor.StatusResp();
            respuestaEstado.statusCode = '200';
            respuestaEstado.statusMessage = 'OK';
            
            CC_Int_AvailabilitiesGestor.RespuestaAvailabilitiesGestor respuestaAvailabilities = new CC_Int_AvailabilitiesGestor.RespuestaAvailabilitiesGestor();
            respuestaAvailabilities.availabilities.add(disponibilidad);
            respuestaAvailabilities.StatusResponse = respuestaEstado;

            String bodyRequestAvailabilities = JSON.serialize(respuestaAvailabilities);
            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(bodyRequestAvailabilities);
            res.setStatusCode(200);
            return res;
        }
    }

    // @isTest
    // private static void getAvaibilitiesGestor(){
    //     System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
    //     Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];    
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoBackUp());
    //     Map<String, Object> maparespuesta = CC_Operativa_Oficina_Controller.obtenerDisponibilidadesGestor(caso.Id, '23456', '23456','43');
    //     Map<Date,Set<Time>> respuesta = (Map<Date,Set<Time>>)maparespuesta.get('fechasHorasMap');      
    //     Test.stopTest();
    //     String fechaRespuesta;
    //     for(Date fecha: respuesta.keySet()) {
    //         fechaRespuesta = String.valueOf(fecha);
    //     }
    //     System.assertEquals('2022-06-20', fechaRespuesta);
    // }
    // }

    @isTest
    private static void getFechas() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {    
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoBackUp());
        List<OT_Picklist.Item> respuesta = CC_Operativa_Oficina_Controller.obtenerFechasDisponiblidadGestor(caso.Id, '23456', '23456','43');      
        
        System.assertEquals('2022-06-20', respuesta[0].value);
        }
        Test.stopTest();
    }

    @isTest
    private static void getHoras() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {  
            
                Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoBackUp());
                List<OT_Picklist.Item> respuesta = CC_Operativa_Oficina_Controller.obtenerHorasDisponiblidadGestor(caso.Id, '23456', '23456', '43', '2022-06-20');      
            
            System.assertEquals('15:30', respuesta[0].value);
        }
        Test.stopTest();
    }

    // @isTest
    // private static void obtenerGestoresBackup() {
    //     System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {    
    //         Test.startTest();
    //             Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
    //             Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoBackUp());
    //             List<OT_Picklist.Item> respuesta = CC_Operativa_Oficina_Controller.obtenerGestoresBackup(caso.Id, '23456', '23456', '43');      
    //         Test.stopTest();
    //         System.assert(respuesta.isEmpty());
    //     }
    // }

    @isTest
    private static void updateCasoOperativaDerivarTest() {
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {    
            Test.startTest();
                Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
                CC_Operativa_Oficina_Controller.updateCasoOperativaDerivar(caso.Id);
            Test.stopTest();
            Case casoUpd = [SELECT SAC_EnvioParcial__c FROM Case WHERE Id =: caso.Id];
            System.assert(casoUpd.SAC_EnvioParcial__c == true, 'El campo no se ha actualizado correctamente');
        }
    }

    @isTest
    static void derivarSACTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                Case casoDerivarSAC = [SELECT Id, Subject, CC_Idioma__c, Description, AccountId, ContactId, ParentId, CreatedDate FROM Case WHERE Subject = 'casoDerivarSAC'];
                
                CC_Operativa_Oficina_Controller.derivarSAC(casoDerivarSAC, 'test');

                Case casoSAC = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND Subject = :casoDerivarSAC.Subject];
                Case casoResult = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = 'CC_Cliente' AND Subject = 'casoDerivarSAC'];
        
                System.assertEquals(String.isBlank(casoSAC.Id), false, 'No se ha derivado al SAC');
                System.assertEquals(casoResult.Status, 'Cerrado', 'No se ha derivado al SAC');
            Test.stopTest();
        }
    }

    @isTest
    static void devolverSACTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                Case casoRecla = [SELECT Id FROM Case WHERE Subject = 'Tec'];
                Case casoDevolverSAC = [SELECT Id, Subject, CC_Idioma__c, Description, AccountId, ContactId, ParentId, CreatedDate, RecordTypeId FROM Case WHERE Subject = 'casoDevolverSAC'];
                
                CC_Operativa_Oficina_Controller.devolverSAC('test', casoDevolverSAC);

                Case casoResult = [SELECT Id, Status FROM Case WHERE Subject = 'casoDevolverSAC'];
        
                System.assertEquals(casoResult.Status, 'Cerrado', 'No se ha devuelto al SAC');
            Test.stopTest();
        }
    }

    
    @isTest
    static void loguearTrazasAutenticacionSAUTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                Case casoRecla = [SELECT Id FROM Case WHERE Subject = 'Tec'];
                List<String> listaTrazas = new List<String>{'test'};
                CC_Operativa_Oficina_Controller.loguearTrazasAutenticacionSAU( listaTrazas, listaTrazas, casoRecla.Id, 'test');
                List<CC_TrazaInt__c> trazas = [SELECT Id FROM CC_TrazaInt__c WHERE Name = 'CC_Autenticacion_SAU'];
                System.assertEquals(trazas.isEmpty(), false);
            Test.stopTest();
        }
    }

}