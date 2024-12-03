/* PARA SUBIR COBERTURA AÑADIR CLASES CC_Int_AltaCitaGestor, CC_Int_ObtInfCarterizaCliente y CC_Int_AvailabilitiesGestor */
@isTest
public with sharing class CC_Operativa_Oficina_Controller_Test {
    @TestSetup
    static void makeData() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psAVGestorOp = [SELECT Id FROM PermissionSet WHERE Name = 'AV_GestorOperativa'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        
        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        userList.add(usuarioAdmin);
        
        User operadorCliente = new User();
        operadorCliente.profileId = profileId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = 'U0124112';
        operadorCliente.FirstName = 'Operador';
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser001@amamama.com';
        operadorCliente.Username = 'tuser001@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';
        userList.add(operadorCliente);
        insert userList;
        
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAssOperadores.add(psaOperadorCliente);

        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);

        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psAVGestorOp.Id);
        insertPSAssOperadores.add(psaOperadorAV);

        PermissionSetAssignment psaAdminAV = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psAVGestorOp.Id);
        insertPSAssOperadores.add(psaAdminAV);

        Database.insert(insertPSAssOperadores);
        
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
            insert contactoEmple;

            //Accounts
            List<Account> accounts = new List<Account>();
            
            Account cuentaCliente = new Account();
            cuentaCliente.LastName = 'Cliente Senior';
            cuentaCliente.AV_EAPGestor__c = contactoEmple.Id;
            cuentaCliente.CC_NumPerso__c = '0000012';
            cuentaCliente.AV_IndicadoresClientes__c = '28';
            cuentaCliente.AV_OficinaPrincipal__c = centro.Id;
            cuentaCliente.RecordtypeId =  rtClientePA;
            cuentaCliente.CC_Numero_Documento__c = '45729937A';
            cuentaCliente.AV_Cliente__c = true;
            accounts.add(cuentaCliente);

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
            
            for(Account a : accounts){
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

            Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
            lista.Name = 'Gestor por defecto CC';
            lista.RecordTypeId = recordTypeLista;
            listas.add(lista);
            
            CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
            listaDerivar.Name = 'Textos operativa Derivar';
            listaDerivar.RecordTypeId = recordTypeLista;
            listas.add(listaDerivar);
            insert listas;
            
            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valorExId = new CC_Lista_Valores__c ();
            valorExId.Name = 'ExternalID';
            valorExId.RecordTypeId = recordTypeValor;
            valorExId.CC_Lista__c = lista.Id;
            valorExId.CC_Valor__c ='000000';        
            valores.add(valorExId);
            CC_Lista_Valores__c valorName = new CC_Lista_Valores__c ();
            valorName.Name = 'Nombre';
            valorName.RecordTypeId = recordTypeValor;
            valorName.CC_Lista__c = lista.Id;
            valorName.CC_Valor__c ='Sin Gestor/EAP';
            valores.add(valorName);
            
            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
            valor1.Name = 'Comentario cambio oficina';
            valor1.RecordTypeId = recordTypeValor;
            valor1.CC_Lista__c = listaDerivar.Id;
            valor1.CC_Mensajes_Mostrar__c = 'El cliente [nombre], [apellidos], [dni] solicita el cambio de oficina de la [oficina origen] a la [oficina destino].';
            valores.add(valor1);
            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.Name = 'Comentario cambio gestor';
            valor2.RecordTypeId = recordTypeValor;
            valor2.CC_Lista__c = listaDerivar.Id;
            valor2.CC_Mensajes_Mostrar__c = 'El cliente [nombre], [apellidos], [dni] solicita el cambio de gestor.';
            valores.add(valor2);
            
            CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
            valor3.Name = 'Pregunta traslado colaborador';
            valor3.RecordTypeId = recordTypeValor;
            valor3.CC_Lista__c = listaDerivar.Id;
            valor3.CC_Mensajes_Mostrar__c = '¿La gestión a realizar es una consulta a expensas de recibir respuesta o es derivar al caso a un tercero para su gestión?';
            valores.add(valor3);
            
            CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
            valor4.Name = 'Pregunta cajeros';
            valor4.RecordTypeId = recordTypeValor;
            valor4.CC_Lista__c = listaDerivar.Id;
            valor4.CC_Mensajes_Mostrar__c = '¿El cajero es externalizado?';
            valores.add(valor4);
            
            CC_Lista_Valores__c valor5 = new CC_Lista_Valores__c();
            valor5.Name = 'Pregunta cajero externalizado';
            valor5.RecordTypeId = recordTypeValor;
            valor5.CC_Lista__c = listaDerivar.Id;
            valor5.CC_Mensajes_Mostrar__c = 'Para dar de alta esta reclamación accede en TFC > Diario de operaciones de cajeros , localiza la operación y reclámala. ¿Lo has podido hacer?';
            valores.add(valor5);
            
            CC_Lista_Valores__c valor6 = new CC_Lista_Valores__c();
            valor6.Name = 'Toast cajero externalizado';
            valor6.RecordTypeId = recordTypeValor;
            valor6.CC_Lista__c = listaDerivar.Id;
            valor6.CC_Mensajes_Mostrar__c = 'Esta es una operación en un cajero cuya gestión resolverá la misma Oficina. Por tanto no es necesario avisar a la oficina';
            valores.add(valor6);
            
            CC_Lista_Valores__c valor7 = new CC_Lista_Valores__c();
            valor7.Name = 'Pregunta realizar remitido';
            valor7.RecordTypeId = recordTypeValor;
            valor7.CC_Lista__c = listaDerivar.Id;
            valor7.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
            valores.add(valor7);
            
            CC_Lista_Valores__c valor8 = new CC_Lista_Valores__c();
            valor8.Name = 'Toast remitir';
            valor8.RecordTypeId = recordTypeValor;
            valor8.CC_Lista__c = listaDerivar.Id;
            valor8.CC_Mensajes_Mostrar__c = 'Antes de proseguir, intenta transferir el caso en online.';
            valores.add(valor8);
            
            CC_Lista_Valores__c valor9 = new CC_Lista_Valores__c();
            valor9.Name = 'Url cajeros';
            valor9.RecordTypeId = recordTypeValor;
            valor9.CC_Lista__c = listaDerivar.Id;
            valor9.CC_Mensajes_Mostrar__c = 'https://frmfrm.pro.absiscloud.lacaixa.es/?id=22337';
            valores.add(valor9);
            
            CC_Lista_Valores__c valor10 = new CC_Lista_Valores__c();
            valor10.Name = 'Mensaje imagin oficina';
            valor10.RecordTypeId = recordTypeValor;
            valor10.CC_Lista__c = listaDerivar.Id;
            valor10.CC_Mensajes_Mostrar__c = 'El cliente debe acudir presencialmente a la oficina';
            valores.add(valor10);
            
            CC_Lista_Valores__c valor11 = new CC_Lista_Valores__c();
            valor11.Name = 'Mensaje imagin ventas';
            valor11.RecordTypeId = recordTypeValor;
            valor11.CC_Lista__c = listaDerivar.Id;
            valor11.CC_Mensajes_Mostrar__c = 'En un plazo máximo de 48h se pondrán en contacto con el cliente';
            valores.add(valor11);
            
            CC_Lista_Valores__c valor12 = new CC_Lista_Valores__c();
            valor12.Name = 'Mensaje imagin cambio de oficina';
            valor12.RecordTypeId = recordTypeValor;
            valor12.CC_Lista__c = listaDerivar.Id;
            valor12.CC_Mensajes_Mostrar__c = 'Informar al cliente que hemos derivado su petición a los responsables de organización para su valoración';
            valores.add(valor12);
            
            CC_Lista_Valores__c valor14 = new CC_Lista_Valores__c();
            valor14.Name = 'Mensaje imagin cambio de gestor';
            valor14.RecordTypeId = recordTypeValor;
            valor14.CC_Lista__c = listaDerivar.Id;
            valor14.CC_Mensajes_Mostrar__c = 'En un plazo máximo de 48h se pondrán en contacto con el cliente';
            valores.add(valor14);
            
            CC_Lista_Valores__c valor15 = new CC_Lista_Valores__c();
            valor15.Name = 'Mensaje imagin else';
            valor15.RecordTypeId = recordTypeValor;
            valor15.CC_Lista__c = listaDerivar.Id;
            valor15.CC_Mensajes_Mostrar__c = 'En un plazo máximo de 48h se pondrán en contacto con el cliente';
            valores.add(valor15);
            
            CC_Lista_Valores__c valor16 = new CC_Lista_Valores__c();
            valor16.Name = 'Mensaje caixabank cita tarea gestor';
            valor16.RecordTypeId = recordTypeValor;
            valor16.CC_Lista__c = listaDerivar.Id;
            valor16.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
            valores.add(valor16);
            
            CC_Lista_Valores__c valor17 = new CC_Lista_Valores__c();
            valor17.Name = 'Mensaje caixabank cita tarea gestor else';
            valor17.RecordTypeId = recordTypeValor;
            valor17.CC_Lista__c = listaDerivar.Id;
            valor17.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
            valores.add(valor17);
            
            CC_Lista_Valores__c valor18 = new CC_Lista_Valores__c();
            valor18.Name = 'Mensaje caixabank oficina cliente';
            valor18.RecordTypeId = recordTypeValor;
            valor18.CC_Lista__c = listaDerivar.Id;
            valor18.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
            valores.add(valor18);
            
            CC_Lista_Valores__c valor19 = new CC_Lista_Valores__c();
            valor19.Name = 'Mensaje caixabank oficina cliente else';
            valor19.RecordTypeId = recordTypeValor;
            valor19.CC_Lista__c = listaDerivar.Id;
            valor19.CC_Mensajes_Mostrar__c = 'A la mayor brevedad posible se pondrán en contacto con el cliente';
            valores.add(valor19);
            
            CC_Lista_Valores__c valor20 = new CC_Lista_Valores__c();
            valor20.Name = 'Mensaje caixabank cambio de gestor';
            valor20.RecordTypeId = recordTypeValor;
            valor20.CC_Lista__c = listaDerivar.Id;
            valor20.CC_Mensajes_Mostrar__c = 'Informar al cliente que hemos derivado su petición a los responsables de organización para su valoración';
            valores.add(valor20);
            
            CC_Lista_Valores__c valor21 = new CC_Lista_Valores__c();
            valor21.Name = 'Mensaje caixabank cambio de oficina';
            valor21.RecordTypeId = recordTypeValor;
            valor21.CC_Lista__c = listaDerivar.Id;
            valor21.CC_Mensajes_Mostrar__c = 'Informar al cliente que hemos derivado su petición a los responsables de organización para su valoración';
            valores.add(valor21);
            
            CC_Lista_Valores__c valor22 = new CC_Lista_Valores__c();
            valor22.Name = 'Hub gestion';
            valor22.RecordTypeId = recordTypeValor;
            valor22.CC_Lista__c = listaDerivar.Id;
            valor22.CC_Mensajes_Mostrar__c = '05202';
            valores.add(valor22);
            
            CC_Lista_Valores__c valor23 = new CC_Lista_Valores__c();
            valor23.Name = 'Hub sales';
            valor23.RecordTypeId = recordTypeValor;
            valor23.CC_Lista__c = listaDerivar.Id;
            valor23.CC_Mensajes_Mostrar__c = '04563';
            valores.add(valor23);

            CC_Lista_Valores__c valor24 = new CC_Lista_Valores__c();
            valor24.Name = 'Pregunta Enrollment Sign';
            valor24.RecordTypeId = recordTypeValor;
            valor24.CC_Lista__c = listaDerivar.Id;
            valor24.CC_Mensajes_Mostrar__c = '¿El cliente se encuentra en el extranjero?';
            valores.add(valor24);

            CC_Lista_Valores__c valor25 = new CC_Lista_Valores__c();
            valor25.Name = 'Pregunta realizar remitido	';
            valor25.RecordTypeId = recordTypeValor;
            valor25.CC_Lista__c = listaDerivar.Id;
            valor25.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
            valores.add(valor25);            

            CC_Lista_Valores__c valor26 = new CC_Lista_Valores__c();
            valor26.Name = 'Pregunta CSBD Contratar 2';
            valor26.RecordTypeId = recordTypeValor;
            valor26.CC_Lista__c = listaDerivar.Id;
            valor26.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
            valores.add(valor26);

            CC_Lista_Valores__c valor27 = new CC_Lista_Valores__c();
            valor27.Name = 'Pregunta CSBD Contratar';
            valor27.RecordTypeId = recordTypeValor;
            valor27.CC_Lista__c = listaDerivar.Id;
            valor27.CC_Mensajes_Mostrar__c = '¿Has intentado transferir el caso en online?';
            valores.add(valor27);
            insert valores;

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
            grupoColaboradorMCC.CC_MCC__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Enrollment Sign'].Id;
            grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupo.Id;
            grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';
            insert grupoColaboradorMCC;
            
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
            insertCase.add(casoContratarCSBD);

            Case casoNoContratarCSBD = new Case();
            casoNoContratarCSBD.Subject = 'CSBD No Contratar';
            casoNoContratarCSBD.Origin = 'Email';
            casoNoContratarCSBD.Status = 'Activo';
            casoNoContratarCSBD.accountId = cuentaCliente.Id;
            casoNoContratarCSBD.CC_Idioma__c = 'es';
            casoNoContratarCSBD.CC_MCC_Tematica__c = tematica.Id; 
            casoNoContratarCSBD.CC_MCC_ProdServ__c = producto.Id;
            casoNoContratarCSBD.CC_MCC_Motivo__c = motivoCSBDNoContratar.Id;
            casoNoContratarCSBD.RecordTypeId = recordTypeCaso;
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
        }
    } 

    
    @isTest //Pass
    public static void getDatosTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Case casoImagin = [SELECT Id from Case Where CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c = '28'];
            Map<String, Object> resultadoImagin = CC_Operativa_Oficina_Controller.getDatos(casoImagin.Id);
            System.assertEquals(resultadoImagin.get('mostrarModalCreacionTarea'), true, 'Error en caso Imagin');
            
            Case casoNoImaginOficina = [SELECT Id from Case Where CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c != '28'];
            Map<String, Object> resultadoNoImaginOficina = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginOficina.Id);
            System.assertEquals(resultadoNoImaginOficina.get('cambioOficina'), true, 'Error en caso 2');
            
            Case casoNoImaginGestor = [SELECT Id from Case Where CC_Motivo__c = 'Cambio de Gestor'];
            Map<String, Object> resultadoNoImaginGestor = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginGestor.Id);
            System.assertEquals(resultadoNoImaginGestor.get('mostrarModalCreacionTarea'), true, 'Error en caso 3');
            System.assertEquals(resultadoNoImaginGestor.get('cambioGestor'), true, 'Error en caso 3');
            
            Case casoNoImaginPrueba = [SELECT Id from Case Where CC_Motivo__c = 'Cambio de Prueba'];
            Map<String, Object> resultadoNoImaginPrueba = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginPrueba.Id);
            System.assertEquals(resultadoNoImaginPrueba.get('mostrarModalGestionGestorGenerico'), true, 'Error en caso 4');
                       
            Case casoNoImaginNoClientesPrueba = [SELECT Id from Case Where CC_Motivo__c = 'No clientes' AND  Account.AV_IndicadoresClientes__c != '28'];
            Map<String, Object> resultadoNoImaginPruebaNoCliente = CC_Operativa_Oficina_Controller.getDatos(casoNoImaginNoClientesPrueba.Id);
            System.assertEquals(resultadoNoImaginPruebaNoCliente.get('cambioOficina'), true, 'Error en caso 5');
            
            Case cajeros = [SELECT Id from Case Where Subject = 'Cajeros'];
            Map<String, Object> resultadoCajeros = CC_Operativa_Oficina_Controller.getDatos(cajeros.Id);
            System.assertNotEquals(resultadoCajeros.get('preguntaCajeros'), null, 'Error en caso cajeros');
            
            Case fraude = [SELECT Id from Case Where Subject = 'Fraude'];
            Map<String, Object> resultadoFraude = CC_Operativa_Oficina_Controller.getDatos(fraude.Id);
            System.assertNotEquals(resultadoFraude.get('preguntaRealizarRemitido'), null, 'Error en caso fraude');
            
            Case testamentaria = [SELECT Id from Case Where Subject = 'casoImaginTestamentaria'];
            Map<String, Object> resultadoTestamentaria = CC_Operativa_Oficina_Controller.getDatos(testamentaria.Id);
            System.assertEquals(resultadoTestamentaria.get('mostrarModalDNITestamentaria'), true);

            /*Case enrollment = [SELECT Id from Case Where Subject = 'casoEnrollmentPreguntaSi'];
            Map<String, Object> resultadoEnrollment = CC_Operativa_Oficina_Controller.getDatos(enrollment.Id);
            System.assertEquals(resultadoEnrollment.get('preguntaEnrollment'), '¿El cliente se encuentra en el extranjero?');*/

            /*Case csbdContratar  = [SELECT Id from Case Where Subject = 'CSBD Contratar'];
            Map<String, Object> resultadoCSBDContratar  = CC_Operativa_Oficina_Controller.getDatos(csbdContratar.Id);
            System.assertNotEquals(resultadoCSBDContratar.get('preguntaCSBDContratar'), null, 'Error en caso de CSBD Contratar');

            Case csbdNoContratar = [SELECT Id from Case Where Subject = 'CSBD No Contratar'];
            Map<String, Object> resultadoCSBDNoContratar = CC_Operativa_Oficina_Controller.getDatos(csbdNoContratar.Id);
            System.assertNotEquals(resultadoCSBDNoContratar.get('toastCSBDNoContratar'), null, 'Error en caso de CSBD No Contratar');*/
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentas.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);            
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasImagin.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasImagin.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true , contacto);            
            CC_Operativa_Oficina_Controller.crearTarea(casoCCVentasNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, false, true, null);
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
            Account cuentaImagin = [SELECT Id from Account where AV_IndicadoresClientes__c = '28' LIMIT 1];
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoCCGestorNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            //Caso gestor imagin
            casoCCGestorNoImagin.accountId = cuentaImagin.Id;
            upsert casoCCGestorNoImagin;
            CC_Operativa_Oficina_Controller.crearTarea(casoCCGestorNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void buscarGestoresTest() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1];
        System.runAs(operador) {
            Account oficina = [SELECT Id, Name from Account where Name = 'Centro Caixabank 001' LIMIT 1];
            List<Contact> resultado = CC_Operativa_Oficina_Controller.buscarGestores(oficina.Id.toString());
            System.assert(resultado.size() != 0, true);
        }
        Test.stopTest();
    }
    
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
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null,centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, fileList, centro.Id, true, true, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            CC_Operativa_Oficina_Controller.crearTarea(caso.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, false, contacto);
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
            CC_Operativa_Oficina_Controller.crearTarea(casoCCPruebaNoImagin.Id.toString() , asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);
        }
        Test.stopTest();
    }
            
    @isTest
    public static void crearTareaTestcasoNoImaginNoClientes() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            String asunto = 'Prueba';
            String fechaActividad = date.today().toString();
            String comentarios = 'Prueba';
            Contact contacto = [SELECT Id from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
            Account centro = [SELECT Id from Account where CC_Numero_Oficina_Empresa__c = '000-14141' LIMIT 1];
            Case casoNoImaginNoClientes = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoNoImaginNoClientes' LIMIT 1];
            
            //Caso gestor no imagin
            CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginNoClientes.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);

            Case casoNoImaginNoClientesPrueba = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoImaginPruebaNoClientes' LIMIT 1];
            CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginNoClientesPrueba.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tareaprueba = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tareaprueba.isEmpty(), true);
            }
        Test.stopTest();
    }
    
              
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
            CC_Operativa_Oficina_Controller.crearTarea(casoNoImaginTestamentaria.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tarea.isEmpty(), true);

            Case casoImaginTestamentaria = [SELECT Id, Account.AV_IndicadoresClientes__c from Case where Subject = 'casoImaginTestamentaria' LIMIT 1];

            CC_Operativa_Oficina_Controller.crearTarea(casoImaginTestamentaria.Id.toString(), asunto, fechaActividad, comentarios, null, centro.Id, true, true, contacto);
            Task[] tareaprueba = [SELECT Id FROM Task WHERE Subject = 'Prueba'];
            System.assert(!tareaprueba.isEmpty(), true);
            }
        Test.stopTest();
    }
    /*@isTest
    public static void buscarOficinasTest(){
    Account oficina = [SELECT Id, Name from Account where Name = 'Cliente Senior' LIMIT 1];
    Test.startTest();
    String nombreCuenta = 'Cliente Senior 2';
    
    Account centro = new Account();
    centro.Name = 'Cliente Senior 2';
    centro.CC_Email__c = 'test@test.com';
    centro.CC_Numero_Oficina_Empresa__c = '000-14142';
    centro.CC_Numero_Oficina__c = '14142';
    centro.CC_Tipo_Oficina__c = 'I';
    centro.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
    insert centro;
    
    List<Account> resultado = CC_Operativa_Oficina_Controller.buscarOficinas(centro.Name);
    Test.stopTest();
    System.assert(resultado.size() != 0, true);
    }
    
    @isTest
    public static void buscarGestoresGlobalTest(){
    String nombreGestor = 'Prueba empleado';
    Contact oficina = [SELECT Id, CC_Matricula__c from Contact where CC_Matricula__c = 'U0124112' LIMIT 1];
    Test.startTest();
    
    Account centro = new Account();
    centro.Name = 'Cliente Senior 1';
    centro.CC_Email__c = 'test@test.com';
    centro.CC_Numero_Oficina_Empresa__c = '000-14143';
    centro.CC_Numero_Oficina__c = '14143';
    centro.CC_Tipo_Oficina__c = 'I';
    centro.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
    centro.BillingStreet = 'test';
    centro.BillingCity = 'test';
    insert centro;
    
    Contact contactoEmple = new Contact();
    contactoEmple.LastName = 'Cliente Senior';
    contactoEmple.FirstName = 'Prueba empleado';
    contactoEmple.CC_Inactivo__c = false;
    contactoEmple.Email = 'test@test.com';
    contactoEmple.CC_Matricula__c = 'U0124113';
    contactoEmple.AccountId = centro.Id;
    contactoEmple.AV_DescFuncion__c = 'DIRECCION';
    contactoEmple.RecordtypeId =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
    insert contactoEmple;
    Id [] fixedSearchResults= new Id[1];
    fixedSearchResults[0] = '001x0000003G89h';
    Test.setFixedSearchResults(fixedSearchResults);
    List<Contact> resultado = CC_Operativa_Oficina_Controller.buscarGestoresGlobal(contactoEmple.FirstName);
    Test.stopTest();
    System.assert(resultado.size() != 0, true);
    }*/

    @isTest
    public static void recuperarCampoDerivar(){
        Case caso = [SELECT Id,CC_Derivar__c FROM Case WHERE Subject = 'casoDerivar' LIMIT 1];
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            Boolean campoRecuperado = CC_Operativa_Oficina_Controller.recuperarCampoDerivar(caso.Id);
            System.assertEquals(campoRecuperado, true);
        }
        Test.stopTest();
    }

    @isTest
    public static void dniTestamentaria(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoDNITestamenteria' LIMIT 1];
        Test.startTest();
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
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        Test.startTest();
        Map<String, Object> respuesta = new Map<String, Object>();
        respuesta.put('casoId', caso.Id);
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
                CC_Operativa_Oficina_Controller.devolverCasoCSBD(respuesta);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, true);
        }
        Test.stopTest();
    }

    @isTest
    public static void reabrirCasoCSBD() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        List<String> casosId = new List<String>();
        casosId.add(caso.Id);
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            caso.Status = 'Cerrado';
            update caso;
            CC_Operativa_Oficina_Controller.reabrirCasoCSBD(casosId);
            Case casoCerrado = [SELECT Status FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
            System.assertEquals(casoCerrado.Status, 'Activo');
        }
        Test.stopTest();
    }

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
            System.assertEquals(casoCerrado.Status, 'Cerrado');
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
    public static void  recuperarDatosEntradaFlow() {
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
}