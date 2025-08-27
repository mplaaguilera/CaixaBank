@isTest
public with sharing class CC_Gestion_Derivar_Tarea_Test {
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

            //Para operativa CSBD
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

            Account cuentaCaixa = new Account();
            cuentaCaixa.LastName = 'Cliente Senior';
            cuentaCaixa.AV_EAPGestor__c = contactoEmple.Id;
            cuentaCaixa.CC_NumPerso__c = '0000015';
            cuentaCaixa.AV_OficinaPrincipal__c = centro.Id;
            cuentaCaixa.RecordtypeId =  rtClientePA;
            cuentaCaixa.CC_Numero_Documento__c = '45729937B';
            cuentaCaixa.AV_Cliente__c = true;
            accounts.add(cuentaCaixa);

            // Account clienteConfidencial = new Account();
            // clienteConfidencial.LastName = 'Cliente Senior';
            // clienteConfidencial.AV_EAPGestor__c = contactoEmple.Id;
            // clienteConfidencial.CC_NumPerso__c = '0000013';
            // clienteConfidencial.AV_IndicadoresClientes__c = '28';
            // clienteConfidencial.AV_OficinaPrincipal__c = centro.Id;
            // clienteConfidencial.RecordtypeId =  rtClientePA;
            // clienteConfidencial.CC_Numero_Documento__c = '46729937A';
            // clienteConfidencial.AV_Confidencial__c = true;
            // accounts.add(clienteConfidencial);

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
            
            // Account oficina1 = new Account(
            // Name = 'Oficina 1',
            // CC_Email__c = 'cuenta@test.com',
            // CC_Numero_Empresa__c = '123',
            // CC_Numero_Oficina_Empresa__c = '000-12345',
            // CC_Numero_Oficina__c = '123',
            // CC_Numero_Documento__c = '45729937A',
            // RecordtypeId =  rtCentroId
            // );
            // insert oficina1;
            
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
            //AV_OficinaPrincipal__c = oficina1.Id,
            CC_Numero_Empresa__c = '123',
            CC_Numero_Oficina_Empresa__c = '000-12348',
            AV_EAPGestor__c = contactoEmple.Id,
            AV_Cliente__c = true,
            CC_Numero_Documento__c = '45729937A',
            RecordtypeId =  rtClientePA
            );
            accounts.add(cuentaNoImagin);
            
            // Account cuentaNoImaginContact = new Account(
            // FirstName = 'cuentaNoImagin con gestor',
            // LastName = 'test',
            // CC_Email__c = 'cuenta@test.com',
            // AV_IndicadoresClientes__c = '26',
            // CC_Numero_Empresa__c = '123',
            // CC_Numero_Oficina__c = '00001',
            // CC_Numero_Oficina_Empresa__c = '000-12342',
            // AV_OficinaPrincipal__c = oficina1.Id,
            // AV_EAPGestor__c = contactoEmple.Id,
            // CC_Numero_Documento__c = '45729937A',
            // AV_Cliente__c = true,
            // RecordtypeId =  rtClientePA
            // );
            // accounts.add(cuentaNoImaginContact);
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

            // CC_MCC__c tematicaCaixaBankNow = new CC_MCC__c(
            // Name = 'CaixaBankNow',
            // RecordTypeId = tematicaId,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Canal_Operativo__c = 'Cajero',
            // CC_Codigo_Externo__c = 'TE-000002'
            // );
            // tematicas.add(tematicaCaixaBankNow);
            // mccCreado.add(tematicaCaixaBankNow);
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

            // CC_MCC__c productoMecanismo = new CC_MCC__c(
            // Name = 'Mecanismo de Firma',
            // RecordTypeId = productoId,
            // CC_Tematica__c = tematicaCaixaBankNow.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'PR-000002'
            // );        
            // productos.add(productoMecanismo);
            // mccCreado.add(productoMecanismo);
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
            
            // CC_MCC__c motivoPrueba = new CC_MCC__c(
            // Name = 'Cambio de Prueba',
            // RecordTypeId = motivoId,
            // CC_Producto_Servicio__c = producto.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000003'
            // );
            // motivos.add(motivoPrueba);
            // mccCreado.add(motivoPrueba);
            
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
            
            // CC_MCC__c motivoCajeros = new CC_MCC__c(
            // Name = 'Cajeros',
            // RecordTypeId = motivoId,
            // CC_Ambito_Tareas_Caixa__c = 'Cajeros',
            // CC_Ambito_Tareas_Imagin__c = 'Cajeros',
            // CC_Producto_Servicio__c = producto.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000007'
            // );
            // motivos.add(motivoCajeros);
            // mccCreado.add(motivoCajeros);
            
            CC_MCC__c motivoFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000008',
            CC_Ambito_Tareas_Caixa__c = 'Caso a Fraude',
            CC_Ambito_Tareas_Imagin__c = 'Caso a Fraude'
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

            // CC_MCC__c motivoActivacionCaixaBank = new CC_MCC__c(
            // Name = 'Activación CaixaBankSign',
            // RecordTypeId = motivoId,
            // CC_Producto_Servicio__c = productoMecanismo.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000011'
            // );
            // motivos.add(motivoActivacionCaixaBank);
            // mccCreado.add(motivoActivacionCaixaBank);

            // CC_MCC__c motivoEnrollment = new CC_MCC__c(
            // Name = 'Enrollment Sign',
            // RecordTypeId = motivoId,
            // //CC_Ambito_Tareas_Caixa__c = 'Enrollment Sign',
            // CC_Ambito_Tareas_Caixa__c = 'Testamentaría',
            // CC_Ambito_Tareas_Imagin__c = 'Testamentaría',
            // CC_Producto_Servicio__c = producto.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000012'
            // );
            // motivos.add(motivoEnrollment);
            // mccCreado.add(motivoEnrollment);

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

            // CC_MCC__c motivoCSBDContratar = new CC_MCC__c(
            // Name = 'CSBD Contratar',
            // RecordTypeId = motivoId,
            // CC_Ambito_Tareas_Caixa__c = 'CSBD Contratar',
            // CC_Ambito_Tareas_Imagin__c = 'CSBD Contratar',
            // CC_Producto_Servicio__c = producto.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000014'
            // );
            // motivos.add(motivoCSBDContratar);
            // mccCreado.add(motivoCSBDContratar);

            // CC_MCC__c motivoCSBDNoContratar = new CC_MCC__c(
            // Name = 'CSBD No Contratar',
            // RecordTypeId = motivoId,
            // CC_Ambito_Tareas_Caixa__c = 'CSBD No Contratar',
            // CC_Producto_Servicio__c = producto.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000015'
            // );
            // motivos.add(motivoCSBDNoContratar);
            // mccCreado.add(motivoCSBDNoContratar);

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

            
            CC_MCC__c motivoCBP = new CC_MCC__c(
            Name = 'CBP',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CBP',
            CC_Ambito_Tareas_Imagin__c = 'CBP',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000018'
            );
            motivos.add(motivoCBP);
            mccCreado.add(motivoCBP);

            // CC_MCC__c motivoDocumentacion = new CC_MCC__c(
            // Name = 'Documentación',
            // RecordTypeId = motivoId,
            // CC_Ambito_Tareas_Caixa__c = 'Documentación',
            // CC_Ambito_Tareas_Imagin__c = 'Documentación',
            // CC_Producto_Servicio__c = producto.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'MO-000018'
            // );
            // motivos.add(motivoDocumentacion);
            // mccCreado.add(motivoDocumentacion);

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

            // CC_MCC__c causaExtranjero = new CC_MCC__c(
            // Name = 'Cliente en el extranjero',
            // RecordTypeId = causaId,
            // CC_Producto_Servicio__c = motivoActivacionCaixaBank.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'CA-000002'
            // );
            // causas.add(causaExtranjero);
            // mccCreado.add(causaExtranjero);
             insert causas;

            // CC_MCC__c solucionFraude = new CC_MCC__c(
            // Name = 'Fraude',
            // RecordTypeId = solucionId,
            // CC_Producto_Servicio__c = causaFraude.Id,
            // CC_Tipo_Cliente__c = 'Cliente',
            // CC_Codigo_Externo__c = 'SO-000001',
            // CC_AmbitoTareas__c = 'Fraude'
            // );
            // soluciones.add(solucionFraude);
            // mccCreado.add(solucionFraude);
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
            
            List <Case> insertCase = new List <Case>();
            

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

            
            //cuentaNoImaginContact
            Case casoNoImaginContact = new Case(   	
            Description = 'casoNoImaginContact',
            Subject = 'casoNoImaginContact',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImagin.Id,
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

            /*Case casoNoImaginTestamentaria = new Case(   	
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
            insertCase.add(casoNoImaginTestamentaria);*/

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

            Case casoCBP = new Case(
                Description = 'casoCBP',
                Subject = 'casoCBP',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaImagin.Id,
                CC_Idioma__c = 'es',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoCBP.Id,
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Código de Buenas Prácticas',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoCBP);

            Case casoColectivoVulnerable = new Case(
                Description = 'casoColectivoVulnerable',
                Subject = 'casoColectivoVulnerable',
                Origin = 'Email',
                Status = 'Activo',
                accountId = cuentaImagin.Id,
                CC_Idioma__c = 'es',
                CC_MCC_Tematica__c = tematica.Id, 
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivoCBP.Id,
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Código de Buenas Prácticas',
                CC_Detalles_Consulta__c = 'Caso de Contact Center',
                RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoColectivoVulnerable);

            insert insertCase;
            
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
            
            CC_Settings__c customSetting6 = new CC_Settings__c();
            customSetting6.Name = 'CC_GruposColaboradoresCBP';
            customSetting6.CC_Activa__c = true;
            customSetting6.CC_Configuracion_1__c = 'CBP Connecta';
            listCustomSetting.add(customSetting6);

            insert listCustomSetting;

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

          /*  Opportunity oportunidad1 = CSBD_Opportunity.crearOportunidad('CSBD_MAC');
            oportunidad1.CSBD_CasoOrigen__c = casoEnrollment.Id;
            update oportunidad1;*/

            Test.stopTest();
        }
    } 

    @isTest
    public static void crearTareaTestCasoImagin() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCGestorNoImagin = [SELECT Id from Case where Subject = 'casoNoImaginGestor' LIMIT 1];
            //Caso gestor no imagin
            Map<String, Object> retorno = CC_Operativa_Oficina_Controller.crearTarea(casoCCGestorNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            System.assert(!retorno.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaTestCasoGestorImagin() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCCGestorNoImagin = [SELECT Id from Case where Subject = 'casoNoImaginGestor' LIMIT 1];
            Account cuentaImagin = [SELECT Id from Account where AV_IndicadoresClientes__c = '28' LIMIT 1];
            //Caso gestor imagin
            casoCCGestorNoImagin.accountId = cuentaImagin.Id;
            upsert casoCCGestorNoImagin;
            CC_Operativa_Oficina_Controller.crearTarea(casoCCGestorNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void crearTareaTestCasoNoImaginGestor() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
  
    @isTest
    public static void crearTareaTestCasoCambiarGestor() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
    
    @isTest
    public static void casoImaginAmbitoOficina() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
            // update cuenta;
            ContentVersion file = new ContentVersion();
            file.PathOnClient = 'test.jpg';
            file.VersionData = Blob.valueOf('Test Content');
            insert file;
            List <String> fileList = new List <String>();
            fileList.add(String.valueOf(file.Id)); 
            Map<String, Object> resultado = CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, fileList, centro.Id, true, true, contacto, null);
            System.assertEquals(true, resultado.get('ambitoVentas'));
            // Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            //System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void casoCaixabankAmbitoVacioConGestor() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id, CC_Numero_Oficina__c, CC_Matricula__c from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Account cuenta = [SELECT Id from Account where FirstName = 'cuentaNoImagin' LIMIT 1];
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
            
    @isTest
    public static void crearTareaTestcasoNoImaginNoClientes() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoNoImaginNoClientes = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoNoImaginNoClientes' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginNoClientes.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
            }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaCasoTestamentariaNoImagin() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Account cuentaNoImagin = [SELECT Id from Account where FirstName = 'cuentaNoImagin' LIMIT 1];

            CC_MCC__c mccMotivoTestamentarias = [
                SELECT 
                    Id, 
                    Name, 
                    CC_Producto_Servicio__c, 
                    CC_Producto_Servicio__r.CC_Tematica__c 
                FROM CC_MCC__c 
                WHERE Name = 'Testamentaria' AND CC_Codigo_Externo__c = 'MO-000010' LIMIT 1
            ];

            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');

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
                CC_MCC_Tematica__c = mccMotivoTestamentarias.CC_Producto_Servicio__r.CC_Tematica__c, 
                CC_MCC_ProdServ__c = mccMotivoTestamentarias.CC_Producto_Servicio__c,
                CC_MCC_Motivo__c = mccMotivoTestamentarias.Id,
                RecordTypeId = recordTypeCaso
            );
            insert casoNoImaginTestamentaria;

            //Case casoNoImaginTestamentaria = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoNoImaginTestamentaria' LIMIT 1];
            
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginTestamentaria.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);

        }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaCasoTestamentariaImagin() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
    
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
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
    public static void casoNoCliente() {
        Test.startTest();
        Case caso = [SELECT Id, OwnerId, Status FROM Case WHERE Subject = 'No cliente' LIMIT 1];
        String asunto = 'Prueba';
        String fechaActividad = date.today().toString();
        String comentarios = 'Prueba';
        Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
        Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
        System.runAs(CC_TestDataFactory.getUserAdmin()) {         
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCrearTareaCasoSinCuenta() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Case caso = new Case(
                Subject = 'Caso sin cuenta',
                Origin = 'Email',
                Status = 'Activo',
                CC_Idioma__c = 'es',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                AccountId = null,
                CC_No_Identificado__c = true
            );
            insert caso;

            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];

            Map<String, Object> params = new Map<String, Object>{
                'recordId' => caso.Id,
                'asunto' => 'Prueba',
                'fechaActividad' => date.today().toString(),
                'comentarios' => 'Prueba',
                'cuentaFicticia' => 'F',
                'oficinaDestino' => centro.Id
            };
            CC_Gestion_Derivar_Tarea tarea = new CC_Gestion_Derivar_Tarea(params);
            tarea.crearTarea();

            // Verificar que se creó la tarea
            Task tareaCreada = [SELECT Id, WhatId, AV_Center__c FROM Task WHERE Subject = 'Prueba' LIMIT 1];
            System.assertNotEquals(null, tareaCreada);

            // Repetir el test
            caso.CC_No_Identificado__c = true;
            update caso;
            params.put('recordId', caso.Id);
            params.put('cuentaFicticia', 'J');
            params.put('oficinaDestino', null);
            tarea = new CC_Gestion_Derivar_Tarea(params);
            // Insertar una cuenta genérica para que la consulta no devuelva null
            Account cuentaGenerica = new Account(
                LastName = 'Cuenta Genérica',
                CC_NumPerso__c = '12345',
                CC_Inactivo__c = false,
                RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA')
            );
            insert cuentaGenerica;
            tarea.crearTarea();
            // Verificar que se creó la tarea
            Task tareaCreada2 = [SELECT Id, WhatId FROM Task WHERE Subject = 'Prueba' AND Id != :tareaCreada.Id LIMIT 1];
            System.assertNotEquals(null, tareaCreada2);
        }
        Test.stopTest();
    }

    @isTest
    public static void crearTareaTestCBP() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoCBP = [SELECT Id, Account.AV_EAPGestor__c from Case where Subject = 'casoCBP' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCBP.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }

        @isTest
    public static void crearTareaTestColectivoVulnerable() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoColectivo = [SELECT Id, Account.AV_EAPGestor__c from Case where Subject = 'casoColectivoVulnerable' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoColectivo.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto, null);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
  
}