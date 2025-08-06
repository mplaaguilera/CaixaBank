@isTest
public class CC_Borrado_Datos_Leads_Test {

    @TestSetup
    static void makeData(){

        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'pruebaChat@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);

		insert userList;        
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
    }


    @isTest
    static void blanquearConServicioIMAGIN_LEADS() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Id recordTypeOficinaGestora = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = recordTypeOficinaGestora;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
                
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-100011';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-100011';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-100011';
        insert mccMotivo;        
            
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso lead test';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Phone';
        caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso.CC_Tipo_ChatTranscript__c = 'Agente';
        caso.CC_Numero_Documento__c = '60236005V';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Activo';
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.CC_Oficina_afectada__c = '08548';
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
		caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.ContactId = oContacto.Id;
        caso.AccountId = cuenta.Id;
        insert caso; 
        
        // Servicio Genesys
        Id genesysRecordTypeId = Schema.getGlobalDescribe().get('CC_Servicio_Genesys__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();                        
        CC_Servicio_Genesys__c sGenesys = new CC_Servicio_Genesys__c ();
        sGenesys.Name = 'IMAGIN LEADS';
        sGenesys.CC_Codigo__c = 'IMAGIN_LEADS';
        sGenesys.CC_Tipo_Cliente__c = 'Cliente';
        sGenesys.CC_VDN__c = '1332';
        sGenesys.RecordTypeId = genesysRecordTypeId;
        insert sGenesys;
        
        //Crear llamada
        CC_Llamada__c llamada = new CC_Llamada__c ();
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamada.CC_Servicio_Genesys__c = sGenesys.Id;
        insert llamada;
            
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();                        
        Task task = new Task();
		task.Type = 'Consulta transferida';
        task.status = 'Completed';
        task.Subject = 'Asignar a agente gestor'; 
        task.Priority = 'Normal';
        task.CC_Llamada_Id__c = llamada.Id;
        task.WhatId = caso.Id;
        task.CC_Tipo_Cierre__c = 'Llamada Finalizada';
        task.RecordTypeId = taskRecordTypeId;
        insert task; 
        
        List<Id> Idcases= new List<Id>();
        Idcases.add(caso.Id);
        CC_Borrado_Datos_Leads.borrarDatos(Idcases);        
        System.assertEquals(null, cuenta.CC_NumPerso__c, 'El numPerso no está vacio');
        }

    }
    
    
    @isTest
    static void blanquearConOtroServicio() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Id recordTypeOficinaGestora = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = recordTypeOficinaGestora;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
        
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
                
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-100011';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-100011';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-100011';
        insert mccMotivo;        
            
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso lead test';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Phone';
        caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso.CC_Tipo_ChatTranscript__c = 'Agente';
        caso.CC_Numero_Documento__c = '60236005V';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Activo';
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.CC_Oficina_afectada__c = '08548';
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
		caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.ContactId = oContacto.Id;
        caso.AccountId = cuenta.Id;
        insert caso; 
        
        // Servicio Genesys
        Id genesysRecordTypeId = Schema.getGlobalDescribe().get('CC_Servicio_Genesys__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();                        
        CC_Servicio_Genesys__c sGenesys = new CC_Servicio_Genesys__c ();
        sGenesys.Name = 'IMAGIN PRUEBA';
        sGenesys.CC_Codigo__c = 'PRUEBA';
        sGenesys.CC_Tipo_Cliente__c = 'Cliente';
        sGenesys.CC_VDN__c = '1332';
        sGenesys.RecordTypeId = genesysRecordTypeId;
        insert sGenesys;
        
        //Crear llamada
        CC_Llamada__c llamada = new CC_Llamada__c ();
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamada.CC_Servicio_Genesys__c = sGenesys.Id;
        insert llamada;
            
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();                        
        Task task = new Task();
		task.Type = 'Consulta transferida';
        task.status = 'Completed';
        task.Subject = 'Asignar a agente gestor'; 
        task.Priority = 'Normal';
        task.CC_Llamada_Id__c = llamada.Id;
        task.CC_Tipo_Cierre__c = 'Llamada Finalizada';
        task.WhatId = caso.Id;
        task.RecordTypeId = taskRecordTypeId;
        insert task; 
        
        List<Id> Idcases= new List<Id>();
        Idcases.add(caso.Id);
        CC_Borrado_Datos_Leads.borrarDatos(Idcases);  
        System.assertEquals(null, cuenta.CC_NumPerso__c, 'El numPerso no está vacio');
        }
     
         
    }

	@isTest
    static void blanquearOtroServicioFinalImaginLeads() {

        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Id recordTypeOficinaGestora = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuentaGestora = new Account();
        cuentaGestora.Name = 'Cuenta Test Gestora';
        cuentaGestora.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuentaGestora.RecordTypeId = recordTypeOficinaGestora;
        cuentaGestora.CC_Tipo_Centro__c='OF';
        cuentaGestora.CC_Email__c='test@gmail.com';
        insert cuentaGestora;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_OficinaGestoraId__c=cuentaGestora.Id;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
                
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-100011';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-100011';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-100011';
        insert mccMotivo;        
            
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso lead test';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Phone';
        caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso.CC_Tipo_ChatTranscript__c = 'Agente';
        caso.CC_Numero_Documento__c = '60236005V';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Activo';
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.CC_Oficina_afectada__c = '08548';
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
		caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.ContactId = oContacto.Id;
        caso.AccountId = cuenta.Id;
        insert caso; 
        
        // Servicio Genesys
        Id genesysRecordTypeId = Schema.getGlobalDescribe().get('CC_Servicio_Genesys__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();                        
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();                        
		                 
        CC_Servicio_Genesys__c sGenesys = new CC_Servicio_Genesys__c ();
        sGenesys.Name = 'IMAGIN PRUEBA';
        sGenesys.CC_Codigo__c = 'prueba';
        sGenesys.CC_Tipo_Cliente__c = 'Cliente';
        sGenesys.CC_VDN__c = '1332';
        sGenesys.RecordTypeId = genesysRecordTypeId;
        insert sGenesys;
        
        //Crear llamada
        CC_Llamada__c llamada = new CC_Llamada__c ();
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamada.CC_Servicio_Genesys__c = sGenesys.Id;
        insert llamada;
		
        Task task = new Task();
		task.Type = 'Consulta transferida';
        task.status = 'Completed';
        task.Subject = 'Asignar a agente gestor'; 
        task.Priority = 'Normal';
        task.CC_Llamada_Id__c = llamada.Id;
        task.WhatId = caso.Id;
        task.CC_Tipo_Cierre__c = 'Llamada Finalizada';
        task.RecordTypeId = taskRecordTypeId;
        insert task; 
        
       	CC_Servicio_Genesys__c sGenesys1 = new CC_Servicio_Genesys__c ();
        sGenesys1.Name = 'IMAGIN LEADS';
        sGenesys1.CC_Codigo__c = 'IMAGIN_LEADS';
        sGenesys1.CC_Tipo_Cliente__c = 'Cliente';
        sGenesys1.CC_VDN__c = '1332';
        sGenesys1.RecordTypeId = genesysRecordTypeId;
        insert sGenesys1;
        
        //Crear llamada
        CC_Llamada__c llamada1 = new CC_Llamada__c ();
        llamada1.CC_Tipo__c = 'Entrante';
        llamada1.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamada1.CC_Servicio_Genesys__c = sGenesys1.Id;
        insert llamada1;
            
        Task task1 = new Task();
		task1.Type = 'Consulta transferida';
        task1.status = 'Completed';
        task1.Subject = 'imagin leads'; 
        task1.Priority = 'Normal';
        task1.CC_Llamada_Id__c = llamada1.Id;
        task1.WhatId = caso.Id;
        task1.CC_Tipo_Cierre__c = 'Llamada Finalizada';
        task1.RecordTypeId = taskRecordTypeId;
        insert task1; 
        
        List<Id> Idcases= new List<Id>();
        Idcases.add(caso.Id);
        CC_Borrado_Datos_Leads.borrarDatos(Idcases);   
        System.assertEquals(null, cuenta.CC_NumPerso__c, 'El numPerso no está vacio');
        }
     
    }

    @isTest
    static void blanquearCuentaCliente() {


        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Cliente 4';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;
        
        Id recordTypeCliente = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto 4';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeCliente;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
                

    Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
    CC_MCC__c mccTematica = new CC_MCC__c();
    mccTematica.Name = 'Alfabético';
    mccTematica.CC_Tipo_Cliente__c = 'Cliente';
    mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
    mccTematica.RecordTypeId = recordTypeIdTematica;
    mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
    mccTematica.CC_Codigo_Externo__c = 'TE-100011';
    insert mccTematica;
    
    Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
    CC_MCC__c mccProducto = new CC_MCC__c();
    mccProducto.Name = 'Personas';
    mccProducto.CC_Tipo_Cliente__c = 'Cliente';
    mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
    mccProducto.RecordTypeId = recordTypeIdProducto;
    mccProducto.CC_Tematica__c = mccTematica.Id;
    mccProducto.CC_Codigo_Externo__c = 'PR-100011';
    insert mccProducto; 
    
    Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       CC_MCC__c mccMotivo = new CC_MCC__c();
    mccMotivo.Name = 'Personas confidenciales';
    mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
    mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
    mccMotivo.RecordTypeId = recordTypeIdMotivo;
    mccMotivo.CC_Tematica__c = mccTematica.Id;
    mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
    mccMotivo.CC_Codigo_Externo__c = 'MO-100011';
    insert mccMotivo;     
    
    Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso lead test';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.CC_NumPerso__c = '123456';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.CC_No_Identificado__c = true;
        caso.Origin = 'Email';
        caso.CC_Canal_Operativo__c = 'App BrokerNow';
        caso.CC_Tipo_ChatTranscript__c = 'Agente';
        caso.CC_Numero_Documento__c = '60236005V';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.CC_Oficina_afectada__c = '08548';
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
		caso.CC_MCC_ProdServ__c = mccProducto.Id;   
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.ContactId = oContacto.Id;
        caso.AccountId = cuenta.Id;
        insert caso; 
        
        // Servicio Genesys
        Id genesysRecordTypeId = Schema.getGlobalDescribe().get('CC_Servicio_Genesys__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();                        
        CC_Servicio_Genesys__c sGenesys = new CC_Servicio_Genesys__c ();
        sGenesys.Name = 'IMAGIN PRUEBA';
        sGenesys.CC_Codigo__c = 'IMAGIN_LEADS';
        sGenesys.CC_Tipo_Cliente__c = 'Cliente';
        sGenesys.CC_VDN__c = '1332';
        sGenesys.RecordTypeId = genesysRecordTypeId;
        insert sGenesys;
        
        //Crear llamada
        CC_Llamada__c llamada = new CC_Llamada__c ();
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamada.CC_Servicio_Genesys__c = sGenesys.Id;
        insert llamada;
            
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();                        
        Task task = new Task();
		task.Type = 'Consulta transferida';
        task.status = 'Completed';
        task.Subject = 'Asignar a agente gestor'; 
        task.Priority = 'Normal';
        task.CC_Llamada_Id__c = llamada.Id;
        task.CC_Tipo_Cierre__c = 'llamada finalizada';
        task.WhatId = caso.Id;
        task.RecordTypeId = taskRecordTypeId;
        insert task; 
        
        List<Id> Idcases= new List<Id>();
        Idcases.add(caso.Id);
        CC_Borrado_Datos_Leads.borrarDatos(Idcases);
        System.assertEquals(null, cuenta.CC_NumPerso__c, 'El numPerso no está vacio');

        }


    }
    
    
}