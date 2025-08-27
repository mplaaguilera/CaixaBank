@isTest
public with sharing class CC_Gestion_Derivar_Inicializar_Test {
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
            Test.startTest();
            List<Account> accounts = new List<Account>();

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
            AV_NumPerso__c = '51304694',
            PersonMobilePhone = '666666666',
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

            Account comunidadVecinos = new Account(
            FirstName = 'comunidadVecinos',
            LastName = 'test',
            CC_Email__c = 'cuenta@test.com',
            AV_IndicadoresClientes__c = '26',
            AV_OficinaPrincipal__c = oficina1.Id,
            CC_Numero_Empresa__c = '124',
            CC_Numero_Oficina_Empresa__c = '000-12349',
            AV_Cliente__c = true,
            CC_Numero_Documento__c = 'H45729933437',
            RecordtypeId =  rtClientePA
            );
            accounts.add(comunidadVecinos);


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

            Database.insert(totalPermisosAccount, false);        
            Database.insert(totalPermisosContact, false);           

            //Lista de valores
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

            CC_Lista_Valores__c valor28 = new CC_Lista_Valores__c();
            valor28.Name = 'Pregunta Inversion Argos';
            valor28.RecordTypeId = recordTypeValor;
            valor28.CC_Lista__c = listaDerivar.Id;
            valor28.CC_Mensajes_Mostrar__c = '¿Estaba intentando realizar alguna inversión/compra de criptomonedas?';
            valor28.CC_Valor__c = 'test';
            valores.add(valor28);

            CC_Lista_Valores__c valor29 = new CC_Lista_Valores__c();
            valor29.Name = 'Pregunta WhatsApp Emergencia Argos';
            valor29.RecordTypeId = recordTypeValor;
            valor29.CC_Lista__c = listaDerivar.Id;
            valor29.CC_Mensajes_Mostrar__c = '¿Le ha solicitado la operación algún amigo o familiar por WhatsApp indicando alguna emergencia?';
            valor29.CC_Valor__c = 'test';
            valores.add(valor29);

            CC_Lista_Valores__c valor30 = new CC_Lista_Valores__c();
            valor30.Name = 'Pregunta Contacto Gestor Argos';
            valor30.RecordTypeId = recordTypeValor;
            valor30.CC_Lista__c = listaDerivar.Id;
            valor30.CC_Mensajes_Mostrar__c = '¿Le ha contactado algún gestor de banca y le ha pedido que realice la operativa?';
            valor30.CC_Valor__c = 'test';
            valores.add(valor30);

            CC_Lista_Valores__c valor31 = new CC_Lista_Valores__c();
            valor31.Name = 'Pregunta Factura Argos';
            valor31.RecordTypeId = recordTypeValor;
            valor31.CC_Lista__c = listaDerivar.Id;
            valor31.CC_Mensajes_Mostrar__c = '¿Estaba intentando pagar alguna factura?';
            valor31.CC_Valor__c = 'test';
            valores.add(valor31);

            CC_Lista_Valores__c valor32 = new CC_Lista_Valores__c();
            valor32.Name = 'Pregunta CompraVenta Argos';
            valor32.RecordTypeId = recordTypeValor;
            valor32.CC_Lista__c = listaDerivar.Id;
            valor32.CC_Mensajes_Mostrar__c = '¿Estaba intentando comprar/vender algún producto/viaje?';
            valor32.CC_Valor__c = 'test';
            valores.add(valor32);

            CC_Lista_Valores__c valor33 = new CC_Lista_Valores__c();
            valor33.Name = 'Pregunta Operacion MFA Argos';
            valor33.RecordTypeId = recordTypeValor;
            valor33.CC_Lista__c = listaDerivar.Id;
            valor33.CC_Mensajes_Mostrar__c = 'Pregunta Operacion MFA Argos';
            valor33.CC_Valor__c = 'test';
            valores.add(valor33);

            CC_Lista_Valores__c valor34 = new CC_Lista_Valores__c();
            valor34.Name = 'Pregunta Diario MFA Argos';
            valor34.RecordTypeId = recordTypeValor;
            valor34.CC_Lista__c = listaDerivar.Id;
            valor34.CC_Mensajes_Mostrar__c = 'Pregunta Diario MFA Argos';
            valores.add(valor34);

            CC_Lista_Valores__c valor35 = new CC_Lista_Valores__c();
            valor35.Name = 'Phising/Smishing/Malware 1';
            valor35.RecordTypeId = recordTypeValor;
            valor35.CC_Lista__c = listaDerivar.Id;
            valor35.CC_Mensajes_Mostrar__c = 'Phising/Smishing/Malware 1';
            valores.add(valor35);

            CC_Lista_Valores__c valor36 = new CC_Lista_Valores__c();
            valor36.Name = 'Pregunta Telefono CSBD';
            valor36.RecordTypeId = recordTypeValor;
            valor36.CC_Lista__c = listaDerivar.Id;
            valor36.CC_Mensajes_Mostrar__c = 'Pregunta telefono CSBD';
            valores.add(valor36);

            CC_Lista_Valores__c valor37 = new CC_Lista_Valores__c();
            valor37.Name = 'Toast comunidades vecinos';
            valor37.RecordTypeId = recordTypeValor;
            valor37.CC_Lista__c = listaDerivar.Id;
            valor37.CC_Mensajes_Mostrar__c = 'Si esta consulta hace referencia a bastanteos o incidencias relacionadas con las Comunidades de Propietarios puedes facilitar este buzón al cliente: soporte.ccpp@caixabank.com.';
            valores.add(valor37);

            CC_Lista_Valores__c valor38 = new CC_Lista_Valores__c();
            valor38.Name = 'CashBack 1';
            valor38.RecordTypeId = recordTypeValor;
            valor38.CC_Lista__c = listaDerivar.Id;
            valor38.CC_Mensajes_Mostrar__c = 'Por favor, introduce la siguiente información:';
            valores.add(valor38);

            insert valores;

            //MCC
            List<CC_MCC__c> tematicas = new List<CC_MCC__c>();
            List<CC_MCC__c> productos = new List<CC_MCC__c>();
            List<CC_MCC__c> motivos = new List<CC_MCC__c>();
            List<CC_MCC__c> causas = new List<CC_MCC__c>();
            List<CC_MCC__c> soluciones = new List<CC_MCC__c>();

            CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
            );
            tematicas.add(tematica);

            insert tematicas;

            CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
            );        
            productos.add(producto);

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

            CC_MCC__c motivoFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000008'
            );
            motivos.add(motivoFraude);

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

            CC_MCC__c motivoCSBD3N = new CC_MCC__c(
            Name = 'CSBD 3N',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CSBD 3N',
            CC_Ambito_Tareas_Imagin__c = 'CSBD 3N',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000011'
            );
            motivos.add(motivoCSBD3N);

            CC_MCC__c motivoCSBDNoContratar = new CC_MCC__c(
            Name = 'CSBD No Contratar',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CSBD No Contratar',
            CC_Ambito_Tareas_Imagin__c = 'CSBD No Contratar',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000012'
            );
            motivos.add(motivoCSBDNoContratar);

            CC_MCC__c motivoCSBDContratar = new CC_MCC__c(
            Name = 'CSBD Contratar',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CSBD Contratar',
            CC_Ambito_Tareas_Imagin__c = 'CSBD Contratar',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000013'
            );
            motivos.add(motivoCSBDContratar);

            CC_MCC__c motivoOficinaFisica = new CC_MCC__c(
            Name = 'Oficina física',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Oficina física',
            CC_Ambito_Tareas_Imagin__c = 'Oficina física',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000014'
            );
            motivos.add(motivoOficinaFisica);

            CC_MCC__c motivoDocumentacion = new CC_MCC__c(
            Name = 'Documentación',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Documentación',
            CC_Ambito_Tareas_Imagin__c = 'Documentación',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000015'
            );
            motivos.add(motivoDocumentacion);

            CC_MCC__c motivoOnboarding = new CC_MCC__c(
            Name = 'Onboarding',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Onboarding',
            CC_Ambito_Tareas_Imagin__c = 'Onboarding',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000016'
            );
            motivos.add(motivoOnboarding);

            CC_MCC__c motivoVidacaixa = new CC_MCC__c(
            Name = 'Vidacaixa',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Vidacaixa',
            CC_Ambito_Tareas_Imagin__c = 'Vidacaixa',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000017'
            );
            motivos.add(motivoVidacaixa);

            CC_MCC__c argosXpays = new CC_MCC__c(
            Name = 'Argos Xpays',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Argos Xpays',
            CC_Ambito_Tareas_Imagin__c = 'Argos Xpays',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000018'
            );
            motivos.add(argosXpays);

            CC_MCC__c argosGeneral = new CC_MCC__c(
            Name = 'Argos General',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Argos General',
            CC_Ambito_Tareas_Imagin__c = 'Argos General',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000019'
            );
            motivos.add(argosGeneral);

            CC_MCC__c phising = new CC_MCC__c(
            Name = 'Phising/Smishing/Malware',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Phising/Smishing/Malware',
            CC_Ambito_Tareas_Imagin__c = 'Phising/Smishing/Malware',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000020'
            );
            motivos.add(phising);

            CC_MCC__c correosCash = new CC_MCC__c(
            Name = 'CorreosCash',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CorreosCash',
            CC_Ambito_Tareas_Imagin__c = 'CorreosCash',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000021'
            );
            motivos.add(correosCash);

            CC_MCC__c monteDePiedad = new CC_MCC__c(
            Name = 'Monte de Piedad',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Monte de Piedad',
            CC_Ambito_Tareas_Imagin__c = 'Monte de Piedad',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000022'
            );
            motivos.add(monteDePiedad);

            CC_MCC__c gestionReputacion = new CC_MCC__c(
            Name = 'Gestión de reputación',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Gestión reputacional',
            CC_Ambito_Tareas_Imagin__c = 'Gestión reputacional',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000023'
            );
            motivos.add(gestionReputacion);

            CC_MCC__c icpPostventa = new CC_MCC__c(
            Name = 'ICP Postventa',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'ICP Postventa',
            CC_Ambito_Tareas_Imagin__c = 'ICP Postventa',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000024'
            );
            motivos.add(icpPostventa);

            CC_MCC__c incidenciasOficina = new CC_MCC__c(
            Name = 'Incidencias oficina',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'Incidencias oficina',
            CC_Ambito_Tareas_Imagin__c = 'Incidencias oficina',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000025'
            );
            motivos.add(incidenciasOficina);

            CC_MCC__c sac = new CC_MCC__c(
            Name = 'sac',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'SAC',
            CC_Ambito_Tareas_Imagin__c = 'SAC',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000026'
            );
            motivos.add(sac);

            CC_MCC__c cashBack = new CC_MCC__c(
            Name = 'cashBack',
            RecordTypeId = motivoId,
            CC_Ambito_Tareas_Caixa__c = 'CashBack',
            CC_Ambito_Tareas_Imagin__c = 'CashBack',
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000027'
            );
            motivos.add(cashBack);

            insert motivos;

            //Causas
            CC_MCC__c causaFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivoFraude.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
            );
            causas.add(causaFraude);
            insert causas;
            
            //Soluciones
            CC_MCC__c solucionFraude = new CC_MCC__c(
            Name = 'Fraude',
            RecordTypeId = solucionId,
            CC_Producto_Servicio__c = causaFraude.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'SO-000001',
            CC_AmbitoTareas__c = 'Fraude'
            );
            soluciones.add(solucionFraude);
            insert soluciones;


            for(CC_MCC__c record : [SELECT Id FROM CC_MCC__c]) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operadorCliente.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            //Casos
            List <Case> insertCase = new List <Case>();
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
            
            Case casoImaginCSBD = new Case(
            Description = 'casoImaginCSBD',
            Subject = 'casoImaginCSBD',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoCSBD3N.Id,
            CC_Motivo__c = 'CSBD 3N',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_OTP_Nivel__c = 'Nivel 2',
            CC_Status_Autorizacion__c = 'APPROVED',
            CC_OTP_Valido__c = true,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginCSBD);

            Case casoImaginCSBDNoContratar = new Case(
            Description = 'casoImaginCSBDNoContratar',
            Subject = 'casoImaginCSBDNoContratar',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoCSBDNoContratar.Id,
            CC_Motivo__c = 'CSBD 3N',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_OTP_Nivel__c = 'Nivel 2',
            CC_Status_Autorizacion__c = 'APPROVED',
            CC_OTP_Valido__c = true,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginCSBDNoContratar);

            Case casoImaginCSBDContratar = new Case(
            Description = 'casoImaginCSBDContratar',
            Subject = 'casoImaginCSBDContratar',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoCSBDContratar.Id,
            CC_Motivo__c = 'CSBD 3N',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            CC_OTP_Nivel__c = 'Nivel 2',
            CC_Status_Autorizacion__c = 'APPROVED',
            CC_OTP_Valido__c = true,
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginCSBDContratar);

            Case casoImaginOficinaFisica = new Case(
            Description = 'casoImaginOficinaFisica',
            Subject = 'casoImaginOficinaFisica',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoOficinaFisica.Id,
            CC_Motivo__c = 'Oficina física',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginOficinaFisica);

            Case casoImaginDocumentacion = new Case(
            Description = 'casoImaginDocumentacion',
            Subject = 'casoImaginDocumentacion',
            Origin = 'Phone',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Phone',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoDocumentacion.Id,
            CC_Motivo__c = 'Documentación',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Accionista',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginDocumentacion);

            CBK_Case_Extension__c onboardingExtension = new CBK_Case_Extension__c(
                CC_DerivadoBPO__c = false,
                CC_EmpresaONB__c = 'Empresa',
                CC_EstadoONB__c = 'Estado',
                CC_FechaEstadoONB__c = 'Fecha',
                CC_MotivoCierreONB__c = 'Motivo Cierre',
                CC_SubestadoONB__c = 'Subestado',
                CC_NumSR__c = 'NumSR',
                CC_CodigoONB__c = '100'
            );

            insert onboardingExtension;
            Case casoImaginOnboarding = new Case(
            Description = 'casoImaginOnboarding',
            Subject = 'casoImaginOnboarding',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoOnboarding.Id,
            CC_Motivo__c = 'Onboarding',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CBK_Case_Extension_Id__c = onboardingExtension.Id,
            CC_Status_Autorizacion__c = 'APPROVED',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginOnboarding);

            

            Case casoImaginVidacaixa = new Case(
            Description = 'casoImaginVidacaixa',
            Subject = 'casoImaginVidacaixa',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoVidacaixa.Id,
            CC_Motivo__c = 'Vidacaixa',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginVidacaixa);

            Case casoImaginArgosXpays = new Case(
            Description = 'casoImaginArgosXpays',
            Subject = 'casoImaginArgosXpays',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = argosXpays.Id,
            CC_Motivo__c = 'Vidacaixa',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginArgosXpays);

            Case casoImaginArgosGeneral = new Case(
            Description = 'casoImaginArgosGeneral',
            Subject = 'casoImaginArgosGeneral',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = argosGeneral.Id,
            CC_Motivo__c = 'Vidacaixa',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginArgosGeneral);

            Case casoImaginPhising = new Case(
            Description = 'casoImaginPhising',
            Subject = 'casoImaginPhising',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = phising.Id,
            CC_Motivo__c = 'Vidacaixa',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoImaginPhising);

            Case casoRemitidosCorreosCash = new Case(
            Description = 'casoRemitidosCorreosCash',
            Subject = 'casoRemitidosCorreosCash',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = correosCash.Id,
            CC_Motivo__c = 'CorreosCash',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoRemitidosCorreosCash);

            Case casoRemitidosMonteDePiedad = new Case(
            Description = 'casoRemitidosMonteDePiedad',
            Subject = 'casoRemitidosMonteDePiedad',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = monteDePiedad.Id,
            CC_Motivo__c = 'Monte de Piedad',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoRemitidosMonteDePiedad);
            
            Case casoRemitidosGestionReputacion = new Case(
            Description = 'casoRemitidosGestionReputacion',
            Subject = 'casoRemitidosGestionReputacion',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = gestionReputacion.Id,
            CC_Motivo__c = 'Gestión reputacional',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoRemitidosGestionReputacion);
            
            Case casoRemitidosIcpPostventa = new Case(
            Description = 'casoRemitidosIcpPostventa',
            Subject = 'casoRemitidosIcpPostventa',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = icpPostventa.Id,
            CC_Motivo__c = 'ICP Postventa',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoRemitidosIcpPostventa);
            
            Case casoRemitidosIncidenciasOficina = new Case(
            Description = 'casoRemitidosIncidenciasOficina',
            Subject = 'casoRemitidosIncidenciasOficina',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = incidenciasOficina.Id,
            CC_Motivo__c = 'Incidencias oficina',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoRemitidosIncidenciasOficina);

            Case casoComunidadesVecinos = new Case(
            Description = 'casoComunidadesVecinos',
            Subject = 'casoComunidadesVecinos',
            Origin = 'Email',
            Status = 'Activo',
            accountId = comunidadVecinos.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = incidenciasOficina.Id,
            CC_Motivo__c = 'casoComunidadesVecinos',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoComunidadesVecinos);

            Case casoDerivarSAC = new Case(
            Description = 'casoDerivarSAC',
            Subject = 'casoDerivarSAC',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = sac.Id,
            CC_Motivo__c = 'casoDerivarSAC',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoDerivarSAC);

            Case casoCashBack = new Case(
            Description = 'casoCashBack',
            Subject = 'casoCashBack',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaNoImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id, 
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = cashBack.Id,
            CC_Motivo__c = 'casoCashBack',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
            insertCase.add(casoCashBack);

            insert insertCase;

            List<CC_Settings__c > listCustomSetting = new List<CC_Settings__c >();
            CC_Settings__c  customSetting4 = new CC_Settings__c ();
            customSetting4.Name = 'CC_Configuracion_Cita_Rapida';
            customSetting4.CC_Activa__c = true;
            customSetting4.CC_Configuracion_1__c = 'true';
            customSetting4.CC_Configuracion_2__c = 'TELEMATIC';
            customSetting4.CC_Configuracion_3__c = 'true';
            listCustomSetting.add(customSetting4);

            CC_Settings__c  gruposFraude = new CC_Settings__c ();
            gruposFraude.Name = 'CC_GruposColaboradoresFraude';
            gruposFraude.CC_Activa__c = true;
            gruposFraude.CC_Configuracion_1__c = 'Regularización & Retrocesión por fraude';
            gruposFraude.CC_Configuracion_2__c = '9792-GC-Bizum-Regularización & Retrocesión Bizum: Regularización & Retrocesión p';
            gruposFraude.CC_Configuracion_3__c = 'CYBERFRAUDE';
            gruposFraude.CC_Configuracion_4__c = 'CYBERSOC';
            listCustomSetting.add(gruposFraude);

            CC_Settings__c  telefonoActivoCSBD = new CC_Settings__c ();
            telefonoActivoCSBD.Name = 'CC_TelefonoActivoCSBD';
            telefonoActivoCSBD.CC_Activa__c = true;
            telefonoActivoCSBD.CC_Configuracion_1__c = 'true';
            listCustomSetting.add(telefonoActivoCSBD);

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Autenticacion_SAU';
            customSetting.NamedCredential__c = 'callout:API_GWT_TST_CCSF/eChannels/eBranchManagement/customers/id/contracts/validation';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;

            CC_Settings__c  derivacionRemitidosAutomaticos = new CC_Settings__c ();
            derivacionRemitidosAutomaticos.Name = 'CC_DerivacionRemitidosAutomaticos';
            derivacionRemitidosAutomaticos.CC_Activa__c = true;
            derivacionRemitidosAutomaticos.CC_Configuracion_1__c = 'CorreosCash;Monte de Piedad;Gestión reputacional;ICP Postventa;Incidencias oficina';
            listCustomSetting.add(derivacionRemitidosAutomaticos);

            
            CC_Settings__c  modalParam = new CC_Settings__c ();
            modalParam.Name = 'CC_OcultarModalTrasladarAmbitos';
            modalParam.CC_Activa__c = true;
            modalParam.CC_Configuracion_1__c = 'Argos General';
            listCustomSetting.add(modalParam);

            CC_Settings__c  onboarding = new CC_Settings__c ();
            onboarding.Name = 'CC_CodigosOnboarding';
            onboarding.CC_Activa__c = true;
            onboarding.CC_Configuracion_2__c = '0';
            listCustomSetting.add(onboarding);

            CC_Settings__c  ambitosPrioridadSobreNoClientes = new CC_Settings__c ();
            ambitosPrioridadSobreNoClientes.Name = 'CC_AmbitosPrioridadSobreNoClientes';
            ambitosPrioridadSobreNoClientes.CC_Activa__c = true;
            ambitosPrioridadSobreNoClientes.CC_Configuracion_1__c = 'Testamentaría';
            listCustomSetting.add(ambitosPrioridadSobreNoClientes);

            CC_Settings__c  parametrizacionFiltrosCSBD = new CC_Settings__c ();
            parametrizacionFiltrosCSBD.Name = 'CC_ParametrizacionesCSBD';
            parametrizacionFiltrosCSBD.CC_Activa__c = true;
            parametrizacionFiltrosCSBD.CC_Configuracion_1__c = 'true;true;true';
            parametrizacionFiltrosCSBD.CC_Configuracion_2__c = 'true';
            listCustomSetting.add(parametrizacionFiltrosCSBD);

            CC_DevolverDerivarSAC__c  cssac = new CC_DevolverDerivarSAC__c ();
            cssac.Name = 'CC_Derivar';
            cssac.CC_Activo__c = true;
            insert cssac;

            insert listCustomSetting;
            Test.stopTest();
        }
    }

    @isTest //Pass
    public static void getDatosTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Case casoImagin = [SELECT Id FROM Case WHERE CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c = '28'];

            Map<String, Object> resultadoImagin = CC_Gestion_Derivar_Inicializar.getDatos(casoImagin.Id, null);
            System.assertEquals(resultadoImagin.get('mostrarModalCreacionTarea'), true, 'Error en caso Imagin');
            
            Case casoNoImaginOficina = [SELECT Id FROM Case WHERE CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c != '28'];
            Map<String, Object> resultadoNoImaginOficina = CC_Gestion_Derivar_Inicializar.getDatos(casoNoImaginOficina.Id, null);
            System.assertEquals(resultadoNoImaginOficina.get('cambioOficina'), true, 'Error en caso 2');
            
            Case casoNoImaginGestor = [SELECT Id FROM Case WHERE Subject = 'casoNoImaginGestor'];
            Map<String, Object> resultadoNoImaginGestor = CC_Gestion_Derivar_Inicializar.getDatos(casoNoImaginGestor.Id, null);
            System.assertEquals(resultadoNoImaginGestor.get('mostrarModalCreacionTarea'), true, 'Error en caso 3');
            System.assertEquals(resultadoNoImaginGestor.get('cambioGestor'), true, 'Error en caso 3');
            
            Case casoNoImaginPrueba = [SELECT Id FROM Case WHERE CC_Motivo__c = 'Cambio de Prueba'];
            Map<String, Object> resultadoNoImaginPrueba = CC_Gestion_Derivar_Inicializar.getDatos(casoNoImaginPrueba.Id, true);
            System.assertEquals(resultadoNoImaginPrueba.get('mostrarModalGestionGestorGenerico'), true, 'Error en caso 4');
                       
            Case casoNoImaginNoClientesPrueba = [SELECT Id FROM Case WHERE CC_Motivo__c = 'No clientes' AND  Account.AV_IndicadoresClientes__c != '28'];
            Map<String, Object> resultadoNoImaginPruebaNoCliente = CC_Gestion_Derivar_Inicializar.getDatos(casoNoImaginNoClientesPrueba.Id, null);
            System.assertEquals(resultadoNoImaginPruebaNoCliente.get('cambioOficina'), true, 'Error en caso 5');
            
           
        }
        Test.stopTest();
    }

    @isTest //Pass
    public static void getDatosTest2() {
      Test.startTest();
          System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_SAU(200));
            Case csbd3n = [SELECT Id, Account.AV_NumPerso__c FROM Case WHERE Subject = 'casoImaginCSBD'];
            Map<String, Object> resultadoCSBD = CC_Gestion_Derivar_Inicializar.getDatos(csbd3n.Id, null);
            System.assertEquals(resultadoCSBD.get('ambitoVentas'), true);
          }
      Test.stopTest();
    }

    @isTest //Pass
    public static void getDatosTest3() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_SAU(200));
                Case csbdNoContratar = [SELECT Id FROM Case WHERE Subject = 'casoImaginCSBDNoContratar'];
                Map<String, Object> resultadoCSBDNoContratar = CC_Gestion_Derivar_Inicializar.getDatos(csbdNoContratar.Id, null);
                System.assertEquals(resultadoCSBDNoContratar.get('ambitoVentas'), true);
            }
        Test.stopTest();
    }

    @isTest
    public static void getDatosTest5() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Case casoImagin2 = [SELECT Id FROM Case WHERE CC_Motivo__c LIKE 'Cambio de Oficina' AND Account.AV_IndicadoresClientes__c = '28'];

            Map<String, Object> resultadoImagin = CC_Gestion_Derivar_Inicializar.getDatos(casoImagin2.Id, null);
            System.assertEquals(resultadoImagin.get('mostrarModalCreacionTarea'), true, 'Error en caso Imagin');
            
            Case cajeros = [SELECT Id FROM Case WHERE Subject = 'Cajeros'];
            Map<String, Object> resultadoCajeros = CC_Gestion_Derivar_Inicializar.getDatos(cajeros.Id, null);
            System.assertNotEquals(resultadoCajeros.get('preguntaCajeros'), null, 'Error en caso cajeros');
            
            Case fraude = [SELECT Id FROM Case WHERE Subject = 'Fraude'];
            Map<String, Object> resultadoFraude = CC_Gestion_Derivar_Inicializar.getDatos(fraude.Id, false);
            System.assertNotEquals(resultadoFraude.get('preguntaRealizarRemitido'), 'true', 'Error en caso fraude');
            
            Case testamentaria = [SELECT Id FROM Case WHERE Subject = 'casoImaginTestamentaria'];
            Map<String, Object> resultadoTestamentaria = CC_Gestion_Derivar_Inicializar.getDatos(testamentaria.Id, null);
            System.assertEquals(resultadoTestamentaria.get('mostrarModalDNITestamentaria'), true);

            Case oficinaFisica = [SELECT Id FROM Case WHERE Subject = 'casoImaginOficinaFisica'];
            Map<String, Object> resultadoOficinaFisica = CC_Gestion_Derivar_Inicializar.getDatos(oficinaFisica.Id, null);
            System.assertEquals(resultadoOficinaFisica.get('oficinaFisica'), true);

            Case documentacion = [SELECT Id FROM Case WHERE Subject = 'casoImaginDocumentacion'];
            Map<String, Object> resultadoDocumentacion = CC_Gestion_Derivar_Inicializar.getDatos(documentacion.Id, null);
            System.assertEquals(resultadoDocumentacion.get('hubGestion'), true);

            Case onboarding = [SELECT Id FROM Case WHERE Subject = 'casoImaginOnboarding'];
            Map<String, Object> resultadoOnboarding = CC_Gestion_Derivar_Inicializar.getDatos(onboarding.Id, null);
            System.assertEquals(resultadoOnboarding.get('ambitoMotivo'), 'Onboarding');
        }
        Test.stopTest();
    }

    @isTest //Pass
    public static void getDatosTest4() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
              Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion_SAU(200));
                Case csbd3nContratar = [SELECT Id FROM Case WHERE Subject = 'casoImaginCSBDContratar'];
                Map<String, Object> resultadoCSBDContratar = CC_Gestion_Derivar_Inicializar.getDatos(csbd3nContratar.Id, null);
                System.assertEquals(resultadoCSBDContratar.get('ambitoVentas'), true);

                Case vidacaixa = [SELECT Id FROM Case WHERE Subject = 'casoImaginVidacaixa'];
                Map<String, Object> resultadoVidacaixa = CC_Gestion_Derivar_Inicializar.getDatos(vidacaixa.Id, null);
                System.assertEquals(resultadoVidacaixa.get('realizarRemitido'), true);
            }
        Test.stopTest();
    }

    @isTest
    public static void getDatosArgosXpays() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case argosXpays = [SELECT Id FROM Case WHERE Subject = 'casoImaginArgosXpays'];
                Map<String, Object> resultadoArgosXpays = CC_Gestion_Derivar_Inicializar.getDatos(argosXpays.Id, null);
                String test = '[{"key":"¿Estaba intentando realizar alguna inversión/compra de criptomonedas?","value":"Prueba"}]';
                CC_Gestion_Derivar_Global.rellenarPreguntasArgos(argosXpays.Id, test);
                System.assertNotEquals(resultadoArgosXpays.get('operacionMFAArgos'), null, 'Error en caso ArgosXpays');
                Case argosXpaysAct = [SELECT Id, SAC_Redaccion__c FROM Case WHERE Subject = 'casoImaginArgosXpays'];
                System.assertNotEquals(argosXpaysAct.SAC_Redaccion__c, null, 'Error en caso ArgosXpays');

            }
        Test.stopTest();
    }

    @isTest
    public static void getDatosArgosGeneral() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case argosGeneral = [SELECT Id FROM Case WHERE Subject = 'casoImaginArgosGeneral'];
                Map<String, Object> resultadoArgosGeneral = CC_Gestion_Derivar_Inicializar.getDatos(argosGeneral.Id, null);
                System.assertNotEquals(resultadoArgosGeneral.get('diarioMFAArgos'), null, 'Error en caso ArgosGeneral');
            }
        Test.stopTest();
    }

    @isTest
    public static void getDatosPhising() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case phising = [SELECT Id FROM Case WHERE Subject = 'casoImaginPhising'];
                Map<String, Object> resultadoPhising = CC_Gestion_Derivar_Inicializar.getDatos(phising.Id, null);
                System.assertNotEquals(resultadoPhising.get('PhisingSmishingMalware1'), null, 'Error en caso Phising');
            }
        Test.stopTest();
    }

    @isTest
    public static void getDatosRemitidosAutomaticos() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case remitidosAutomaticosCorreosCash = [SELECT Id FROM Case WHERE Subject = 'casoRemitidosCorreosCash'];
                Map<String, Object> casoRemitidosCorreosCash = CC_Gestion_Derivar_Inicializar.getDatos(remitidosAutomaticosCorreosCash.Id, null);
                System.assertEquals(casoRemitidosCorreosCash.get('realizarRemitido'), true);

                Case remitidosAutomaticosMonteDePiedad = [SELECT Id FROM Case WHERE Subject = 'casoRemitidosMonteDePiedad'];
                Map<String, Object> casoRemitidosMonteDePiedad = CC_Gestion_Derivar_Inicializar.getDatos(remitidosAutomaticosMonteDePiedad.Id, null);
                System.assertEquals(casoRemitidosMonteDePiedad.get('realizarRemitido'), true);

                Case remitidosAutomaticosGestionReputacion = [SELECT Id FROM Case WHERE Subject = 'casoRemitidosGestionReputacion'];
                Map<String, Object> casoRemitidosGestionReputacion = CC_Gestion_Derivar_Inicializar.getDatos(remitidosAutomaticosGestionReputacion.Id, null);
                System.assertEquals(casoRemitidosGestionReputacion.get('realizarRemitido'), true);

                Case remitidosAutomaticosIcpPostventa = [SELECT Id FROM Case WHERE Subject = 'casoRemitidosIcpPostventa'];
                Map<String, Object> casoRemitidosIcpPostventa = CC_Gestion_Derivar_Inicializar.getDatos(remitidosAutomaticosIcpPostventa.Id, null);
                System.assertEquals(casoRemitidosIcpPostventa.get('realizarRemitido'), true);

                Case remitidosAutomaticosIncidenciasOficina = [SELECT Id FROM Case WHERE Subject = 'casoRemitidosIncidenciasOficina'];
                Map<String, Object> casoRemitidosIncidenciasOficina = CC_Gestion_Derivar_Inicializar.getDatos(remitidosAutomaticosIncidenciasOficina.Id, null);
                System.assertEquals(casoRemitidosIncidenciasOficina.get('realizarRemitido'), true);
            }
        Test.stopTest();
    }

    @isTest
    public static void getDatosComunidadesVecinos() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case casoComunidades = [SELECT Id FROM Case WHERE Subject = 'casoComunidadesVecinos'];
                Map<String, Object> derivarComunidades = CC_Gestion_Derivar_Inicializar.getDatos(casoComunidades.Id, null);
                System.assertEquals(derivarComunidades.get('mostrarModalToast'), true);

            }
        Test.stopTest();
    }

    @isTest
    public static void rellenarDatosSACTest() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case caso = [SELECT Id FROM Case WHERE Subject = 'casoDerivarSAC'];
                Map<String, Object> retorno = CC_Gestion_Derivar_Inicializar.getDatos(caso.Id, null);
                System.assertEquals(retorno.get('mostrarDerivarSAC'), true, 'no se ha activado el derivar a sac');
            }
        Test.stopTest();
    }

    @isTest
    public static void rellenarDatosCashback() {
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Case caso = [SELECT Id FROM Case WHERE Subject = 'casoCashback'];
                Map<String, Object> retorno = CC_Gestion_Derivar_Inicializar.getDatos(caso.Id, null);
                System.assertEquals(retorno.get('CashBack1'), 'Por favor, introduce la siguiente información:', 'No se ha recuperado el mensaje');
            }
        Test.stopTest();
    }
}