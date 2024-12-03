@isTest
public class OS_Llamada_Test {
	
    @testSetup
    public static void testSetup() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        } 

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.name = 'CCI Holabank';
        tematica.OS_Departamento__c = 'UAC';
        tematica.OS_Horario__c = businessHoursId;
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;
        
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        grupo.name = 'Grupo CCI Holabank';
        grupo.OS_GrupoTrabajo__c = 'CCI Holabank';
        grupo.OS_Tematica__c = tematica.Id;
        insert grupo;
        
        List<OS_Cartera__c> carteras = new List<OS_Cartera__c>();
        OS_Cartera__c cartera = new OS_Cartera__c();
        cartera.RecordTypeId = Schema.getGlobalDescribe().get('OS_Cartera__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cartera').getRecordTypeId();
        cartera.OS_Cola_Telefonia__c = 'Cola de prueba';
        cartera.Name = 'Prueba';
       // carteras.add(cartera);
        insert cartera;
        
        OS_Cartera__c colaTelefonia = new OS_Cartera__c();
        colaTelefonia.RecordTypeId = Schema.getGlobalDescribe().get('OS_Cartera__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cola_Telefonia').getRecordTypeId();
        colaTelefonia.Name = '12345';
        colaTelefonia.OS_GrupoTrabajo_ColaTelefonia__c = grupo.Id;
        //carteras.add(colaTelefonia);
        insert colaTelefonia;
        //insert carteras;

        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.OS_Cartera__c = cartera.Id;
        cuenta.name = 'Cuenta de prueba';
        insert cuenta;
        
		Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.Email = 'llamada@pruebas.com';
        contacto.LastName = 'Pruebas LLamada';
        contacto.Phone = '666555777';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        //Lista de valores para clasificación automática
        CC_Lista_Valores__c relacionDnisCanalProcedencia = new CC_Lista_Valores__c();
        relacionDnisCanalProcedencia.Name = 'COPS: Relación DNIS y Canal de procedencia';
        relacionDnisCanalProcedencia.CC_Activa__c = true;
        relacionDnisCanalProcedencia.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert relacionDnisCanalProcedencia;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.Name = 'Teléfono UAFE';
        valor.CC_Activa__c = true;
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = relacionDnisCanalProcedencia.Id;
        valor.CC_Valor__c = '960290350';
        valores.add(valor);
        
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.Name = 'Teléfono CC Confirming';
        valor2.CC_Activa__c = true;
        valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor2.CC_Lista__c = relacionDnisCanalProcedencia.Id;
        valor2.CC_Valor__c = '931228139';
        valores.add(valor2);
        
        CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
        valor3.Name = 'Teléfono CCI HOLABANK';
        valor3.CC_Activa__c = true;
        valor3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor3.CC_Lista__c = relacionDnisCanalProcedencia.Id;
        valor3.CC_Valor__c = '777555888';
        valores.add(valor3);
		insert valores;
    }
    
	@isTest
    public static void obtenerPrefijo() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        OS_Llamada.Input mensaje = new OS_Llamada.Input();
        mensaje.usuario = 'u0190347';
        mensaje.connId = 'connId01';
        mensaje.ani = '666555444';
        mensaje.dnis = '';
        mensaje.multiParametros = 'tipoCliente=cliente';
        mensaje.nombreFicheroGrabacion = 'PENDENT';

        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        insert contacto;

        System.runAs (usuarioOperador) {       
            Test.startTest();
            String prefijo = OS_Llamada.openCTI_obtenerPrefijo(mensaje);
            Test.stopTest();        
            System.assertEquals('',prefijo, 'Comprobación del prefijo.');
        }
        
    }  
    
    @isTest
    public static void registrarFinalizarConsulta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        insert contacto;

        System.runAs (usuarioOperador) {       
            Test.startTest();
            //Llamada entrante
            OS_Llamada.Input mensajeRegistrarLlamada = new OS_Llamada.Input();
            mensajeRegistrarLlamada.usuario = 'u0190345';
            mensajeRegistrarLlamada.connId = 'connId01';
            mensajeRegistrarLlamada.ani = '666555777';
            mensajeRegistrarLlamada.dnis = '960290350';
            mensajeRegistrarLlamada.multiParametros = 'tipoCliente=cliente&cola=12345';
            mensajeRegistrarLlamada.nombreFicheroGrabacion = 'PENDENT';
            OS_Llamada.openCTI_registrarLlamadaEntrante(mensajeRegistrarLlamada);

            //Llamada entrante2
            OS_Llamada.Input mensajeRegistrarLlamada2 = new OS_Llamada.Input();
            mensajeRegistrarLlamada2.usuario = 'u0190345';
            mensajeRegistrarLlamada2.connId = 'connId01';
            mensajeRegistrarLlamada2.ani = '666555777';
            mensajeRegistrarLlamada2.dnis = '666555445';
            mensajeRegistrarLlamada2.multiParametros = 'tipoCliente=cliente';
            mensajeRegistrarLlamada2.nombreFicheroGrabacion = 'PENDENT';
            OS_Llamada.openCTI_registrarLlamadaEntrante(mensajeRegistrarLlamada2);
            
            //Inicio consulta
            OS_Llamada.Input mensajeRegistrarConsulta = new OS_Llamada.Input();
            mensajeRegistrarConsulta.usuario = 'u0190347';
            mensajeRegistrarConsulta.connId = 'connId01';
            mensajeRegistrarConsulta.ani = '666555445';
            mensajeRegistrarConsulta.dnis = '666555446';
            mensajeRegistrarConsulta.multiParametros = 'tipoCliente=cliente';
            mensajeRegistrarConsulta.nombreFicheroGrabacion = 'PENDENT';
            String consulta = OS_Llamada.openCTI_registrarConsulta(mensajeRegistrarConsulta);
                    
            //Finalizar consulta
            OS_Llamada.Input mensajeFinalizarConsulta = new OS_Llamada.Input();
            mensajeFinalizarConsulta.usuario = 'u0190347';
            mensajeFinalizarConsulta.connId = 'connId01';
            mensajeFinalizarConsulta.ani = '666555444';
            mensajeFinalizarConsulta.dnis = '';
            mensajeFinalizarConsulta.multiParametros = 'tipoCliente=cliente';
            mensajeFinalizarConsulta.nombreFicheroGrabacion = 'PENDENT';
            OS_Llamada.openCTI_finalizarConsulta(mensajeFinalizarConsulta);
            Test.stopTest();

            CC_Llamada__c llamada = [SELECT CC_Fecha_Fin__c, CC_ConnId__c, CC_ConnId_Consulta__c, CC_Tipo__c FROM CC_Llamada__c
                                        WHERE CC_ConnId_Consulta__c = 'connId01'];
            
            System.assert(llamada.CC_Fecha_Fin__c != null, 'Tiene fecha de fin asignada.');
        }
    }
    
    @isTest
    public static void transferirLlamada() { 
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        CC_Lista_Valores__c[] listaDNIS = [SELECT Id FROM CC_Lista_Valores__c WHERE Name ='COPS: Relación DNIS y Canal de procedencia'];
        CC_Lista_Valores__c[] valoresListaDNIS = [SELECT Id,CC_Valor__c,CC_Lista__c,Name,CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__c =: listaDNIS[0].Id];
        
        //Llamada entrante
        OS_Llamada.Input mensajeRegistrarLlamada = new OS_Llamada.Input();
        mensajeRegistrarLlamada.usuario = 'u0190345';
        mensajeRegistrarLlamada.connId = 'connId01';
        mensajeRegistrarLlamada.ani = '666555777';
        mensajeRegistrarLlamada.dnis = '666555445';
        mensajeRegistrarLlamada.multiParametros = 'tipoCliente=cliente';
        mensajeRegistrarLlamada.nombreFicheroGrabacion = 'PENDENT';
        
        //Creación de la llamada entrante inicial
        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente');
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Agente__c = mensajeRegistrarLlamada.usuario.toUpperCase();
        llamada.CC_ANI__c = mensajeRegistrarLlamada.ani;
        llamada.CC_DNIS__c = mensajeRegistrarLlamada.dnis;
        llamada.CC_Fecha_Inicio__c = System.now();
        llamada.CC_Fecha_Fin__c = null;
        llamada.CC_ConnId__c = mensajeRegistrarLlamada.connId;
        llamada.OS_Nombre_Fichero_Grabacion__c = mensajeRegistrarLlamada.nombreFicheroGrabacion;
        insert llamada;

        //Creación de la llamada destino consulta
        CC_Llamada__c llamada2 = new CC_Llamada__c();
        llamada2.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente');
        llamada2.CC_Tipo__c = 'Entrante';
        llamada2.CC_Agente__c = mensajeRegistrarLlamada.usuario.toUpperCase();
        llamada2.CC_ANI__c = mensajeRegistrarLlamada.ani;
        llamada2.CC_DNIS__c = mensajeRegistrarLlamada.dnis;
        llamada2.CC_Fecha_Inicio__c = System.now();
        llamada2.CC_Fecha_Fin__c = null;
        llamada2.CC_ConnId_Consulta__c = mensajeRegistrarLlamada.connId;
        llamada2.OS_Nombre_Fichero_Grabacion__c = mensajeRegistrarLlamada.nombreFicheroGrabacion;
        insert llamada2;

        //Creación del caso vinculada a la llamada inicial
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject='caso de llamada';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Canal_Resolucion__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c  = 'Asesoramiento';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        //Creación de la tarea vinculada a la llamada inicial
        Task tarea = new Task();
        tarea.CC_Llamada_Id__c = llamada.Id;
        tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();
        tarea.WhatId = caso.Id;
        tarea.OwnerId = usuarioOperador.Id;
        insert tarea;

        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        insert contacto;

        System.runAs (usuarioOperador) {       
            Test.startTest();        
            OS_Llamada.openCTI_transferirLlamada(mensajeRegistrarLlamada);
            
            CC_Llamada__c llamadaOrigen = [SELECT CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE CC_ConnId__c = 'connId01' ORDER BY CreatedDate ASC LIMIT 1];
            Task tareaOrigen = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaOrigen.Id ORDER BY CreatedDate ASC LIMIT 1];
            Case casoOrigen = [SELECT Id, Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :tareaOrigen.WhatId];
            Task tareaNueva = [SELECT Id, Status FROM Task WHERE WhatId = :casoOrigen.Id AND Type = 'Llamada transferida'];
            Test.stopTest();    

            System.assertEquals('Llamada transferida', llamadaOrigen.CC_Tipo_Cierre__c, 'Comprobación del tipo de llamada.');
            System.assertEquals('Completed', tareaNueva.Status, 'Comprobación del estado completado.');
        }
    }
    


    /* PENDIENTE FINALIZACION DESARROLLO TRANSFERS COPS
    @isTest
    public static void transferirLlamada() {
        
        OS_Llamada.Input mensaje = new OS_Llamada.Input();
        mensaje.usuario = 'u0190347';
        mensaje.connId = 'connId01';
        mensaje.ani = '666555444';
        mensaje.dnis = '';
        mensaje.multiParametros = 'tipoCliente=cliente';
        mensaje.nombreFicheroGrabacion = 'PENDENT';
        
		Test.startTest();
		CC_Llamada__c llamada = OS_Llamada.transferirLlamada(mensaje);
		Test.stopTest();        
        System.assertNotEquals(null, llamada);
        
    }
    */
    
    @isTest
    public static void registrarLlamadaSaliente() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case casoLlamada = new Case();
        casoLlamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        casoLlamada.Subject='caso de llamada';
        casoLlamada.Origin = 'Email';
        casoLlamada.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        casoLlamada.CC_Canal_Resolucion__c = 'Buzón CCI Holabank';
        casoLlamada.CC_Tipo_Contacto__c  = 'Asesoramiento';
        insert casoLlamada;
        
        OS_Llamada.Input mensaje = new OS_Llamada.Input();
        mensaje.usuario = 'u0190348';
        mensaje.connId = 'connId01';
        mensaje.ani = 'TANT SE VAL';
        mensaje.dnis = '650399855';
        mensaje.multiParametros = 'tipoCliente=cliente';
        mensaje.nombreFicheroGrabacion = 'PENDENT';
        mensaje.casoId = casoLlamada.Id;
        mensaje.transfDestino = '';
        mensaje.servicio = ''; 

        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        insert contacto;

        System.runAs (usuarioOperador) {       
            Test.startTest();
            CC_Llamada__c llamadaSaliente = OS_Llamada.openCTI_registrarLlamadaSaliente(mensaje);
            OS_Llamada.openCTI_finalizarLlamada(mensaje);

            Test.stopTest();
            
            System.assertEquals('Completed', [SELECT Status FROM Task WHERE WhatId = :casoLlamada.Id AND Type = 'Llamada saliente' AND CC_Llamada_Id__c = :llamadaSaliente.Id].Status, 'Comprobación del estado completado.');
            System.assertEquals('Llamada finalizada', [SELECT CC_Tipo_Cierre__c, CC_ConnId__c FROM CC_Llamada__c WHERE CC_ConnId__c = :mensaje.connId].CC_Tipo_Cierre__c, 'Comprobación del tipo de cierre.');
        }
    }

    @isTest
    public static void crearCaso() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'OS_Cliente');
        llamada.CC_ConnId__c = 'connId01';
        llamada.CC_DNIS__c = '931228139';
        llamada.CC_ANI__c = '666555445';
        llamada.CC_Agente__c = 'U0123456';
        llamada.CC_Fecha_Inicio__c = System.now();
        llamada.OS_Cola__c = '12345';
        llamada.CC_Tipo__c = 'Entrante';
        insert llamada;

        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        insert contacto;

        System.runAs (usuarioOperador) {       
            Test.startTest();
            Case caso = OS_Llamada.crearCaso(llamada);
            Test.stopTest();

            System.assert(caso != null, 'Comprobamos que exista caso.');
        }
    }
    
    @isTest
    public static void registrarLlamadaEntranteEmpleado() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Account').getRecordTypeId();
        cuenta.Name = 'CUENTA BUZON COPS';
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Buzon_Contact').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        //Llamada entrante
        OS_Llamada.Input llamadaEntrante = new OS_Llamada.Input();
        llamadaEntrante.usuario = 'u0190345';
        llamadaEntrante.connId = 'connId03';
        llamadaEntrante.ani = '650399855';
        llamadaEntrante.dnis = '960290350';
        llamadaEntrante.multiParametros = 'tipoCliente=empleado&cola=12345';
        llamadaEntrante.nombreFicheroGrabacion = 'PENDENT';

        System.runAs (usuarioOperador) {       
            Test.startTest();
            OS_Llamada.Output_RegistrarLlamadaEntrante output = OS_Llamada.openCTI_registrarLlamadaEntrante(llamadaEntrante);
            Test.stopTest();

            System.debug(output);
            System.assertNotEquals(null, output, 'Comprobación del mensaje de salida null');
        }
    }
    
    @isTest
    public static void registrarLlamadaEntranteCliente() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'CUENTA BUZON COPS';
        insert cuenta;
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(); 
        contacto.Phone = '650399855';
        contacto.LastName = 'PRUEBAS BUZON COPS';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        //Llamada entrante
        OS_Llamada.Input llamadaEntrante = new OS_Llamada.Input();
        llamadaEntrante.usuario = 'u0190345';
        llamadaEntrante.connId = 'connId04';
        llamadaEntrante.ani = '650399855';
        llamadaEntrante.dnis = '960290350';
        llamadaEntrante.multiParametros = 'tipoCliente=cliente&cola=12345';
        llamadaEntrante.nombreFicheroGrabacion = 'PENDENT';

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Llamada.Output_RegistrarLlamadaEntrante output = OS_Llamada.openCTI_registrarLlamadaEntrante(llamadaEntrante);
            Test.stopTest();

            System.debug(output);
            System.assertNotEquals(null, output, 'Comprobación del mensaje de salida null');
        }
    }
}