@isTest
public with sharing class OS_Case_TRHan_Test {
    
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
        User usuarioOperador2 = OS_Usuarios.usuarioOperador();
        usuarioOperador2.FirstName = 'OP222';
        usuarioOperador2.OS_Inicio_Vigencia_Agente_Backup__c = System.today().addDays(-1);
        usuarioOperador2.OS_Fin_Vigencia_Agente_Backup__c = System.today().addDays(+1);
        usuarioOperador2.OS_Agente_Backup__c = usuarioOperador.Id;
        usuarioOperador2.OS_Cola_Backup__c = null;
        update usuarioOperador2;

        User usuarioAdmin = OS_Usuarios.usuarioAdmin();
    }

    @isTest
    public static void actualizarTelefonoEmailCasos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBAS CLIENTE';
        cuenta.CC_Numero_Documento__c = '64850344G';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        contacto.RecordTypeId = recordTypeContacto; 
        contacto.Phone = '666444555';
        contacto.Email = 'testCopsBI@test.com';
        insert contacto;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
            caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.Status = 'Activo';
            caso.AccountId = cuenta.Id;
            caso.ContactId = contacto.Id;
            insert caso;
            Test.stopTest();

            // Evaluación del resultado de la prueba
            Case casoActualizado = [SELECT OS_Telefono__c, OS_Email__c FROM Case WHERE Id = :caso.Id];
            if (casoActualizado != null) {
                System.assertNotEquals(null, casoActualizado.OS_Telefono__c, 'Comprobamos no hay telefono asignado.');
                System.assertNotEquals(null, casoActualizado.OS_Email__c, 'Comprobamos no hay mail asignado.');
            }
        }
    }


    @isTest
    public static void enmascararbeforeInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        // Alta de datos para la prueba
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.RecordTypeId = recordTypeCaso;
		caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        
        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            insert caso;
            insert contacto;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Case casoInsertado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
            if (casoInsertado != null) {
                System.assertEquals('Asunto 1234XXXXXXXX5432', casoInsertado.Subject, 'Comprobamos el subject del caso coincide.');
                System.assertEquals('1234XXXXXXXX5432 Descripción', casoInsertado.Description, 'Comprobamos la descripción del caso coincide.');
                System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoInsertado.CC_Detalles_Consulta__c, 'Comprobamos el campo detalle consulta del caso coincide.');
                System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoInsertado.CC_Detalles_Solucion__c, 'Comprobamos el campo detalle solución del caso coincide.');
            }
        }
    }
    
    
    @isTest
    public static void entitlementBeforeInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBAS Entitlement COPS';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        SlaProcess entitlementProcess = [SELECT Id, name, BusinessHoursId FROM SlaProcess WHERE Name = 'Entitlement Process COPS - EFECTIVO'];
        
        Entitlement entitlement = new Entitlement();
		entitlement.name = 'Entitlement COPS - EFECTIVO';
        entitlement.type= 'Phone Support';
        entitlement.AccountId= cuenta.Id;
        entitlement.StartDate= System.today();
        entitlement.EndDate= System.today().addDays(1);
        entitlement.BusinessHoursId = entitlementProcess.BusinessHoursId;
        entitlement.SlaProcessId = entitlementProcess.Id;
        insert entitlement;
      
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Efectivo';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
        mccTematica.OS_Buzon_Salida__c = 'Buzón CCI Holabank';
        mccTematica.OS_Departamento__c = 'UAFE';
        mccTematica.OS_Horario__c = entitlementProcess.BusinessHoursId;
        mccTematica.OS_Horas_SLA__c = '24' ;
        mccTematica.OwnerId = usuarioOperador.Id;
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto COPS';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001';
        mccProducto.OwnerId = usuarioOperador.Id;
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo COPS';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CBK_Traslado_Remitido__c = 'Remitido';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MOC-000001';
        mccMotivo.OwnerId = usuarioOperador.Id;
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
       	CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa COPS';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CAP-000001';
        mccCausa.OS_Horas_SLA__c = '24';
        mccCausa.OwnerId = usuarioOperador.Id;
        insert mccCausa;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Buzón Efectivo COPS';
            caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.Status = 'Activo';
            caso.Status = 'Cerrado';
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            insert caso;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Case[] casoInsertado = [SELECT OS_Fecha_Fin_Entitlement__c, EntitlementId FROM Case WHERE Id = :caso.Id AND OS_Fecha_Fin_Entitlement__c <> null AND EntitlementId <> null];
            
            System.assertNotEquals(null, casoInsertado, 'Comprobamos no hay caso sin entitlement.');
        }
    }
    
    @isTest
    public static void entitlementBeforeUpdate() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBAS Entitlement COPS';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        SlaProcess entitlementProcess = [SELECT Id, name, BusinessHoursId FROM SlaProcess WHERE Name = 'Entitlement Process COPS - EFECTIVO'];
        
        Entitlement entitlement = new Entitlement();
		entitlement.name = 'Entitlement COPS - EFECTIVO';
        entitlement.type= 'Phone Support';
        entitlement.AccountId= cuenta.Id;
        entitlement.StartDate= System.today();
        entitlement.EndDate= System.today().addDays(1);
        entitlement.BusinessHoursId = entitlementProcess.BusinessHoursId;
        entitlement.SlaProcessId = entitlementProcess.Id;
        insert entitlement;
      
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Efectivo';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
        mccTematica.OS_Buzon_Salida__c = 'Buzón CCI Holabank';
        mccTematica.OS_Horario__c = entitlementProcess.BusinessHoursId;
        mccTematica.OS_Departamento__c = 'UAFE';
        mccTematica.OS_Horas_SLA__c = '24';
        mccTematica.OwnerId = usuarioOperador.Id;
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto COPS';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001';
        mccProducto.OwnerId = usuarioOperador.Id;
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo COPS';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CBK_Traslado_Remitido__c = 'Remitido';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MOC-000001';
        mccMotivo.OwnerId = usuarioOperador.Id;
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
       	CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa COPS';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CAP-000001';
        mccCausa.OS_Horas_SLA__c = '24';
        mccCausa.OwnerId = usuarioOperador.Id;
        insert mccCausa;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Efectivo COPS';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        
        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();   
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            update caso;

            insert contacto;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Case[] casoInsertado = [SELECT OS_Fecha_Fin_Entitlement__c, EntitlementId FROM Case WHERE Id = :caso.Id AND OS_Fecha_Fin_Entitlement__c <> null AND EntitlementId <> null];
            
            System.assertNotEquals(null, casoInsertado, 'Comprobamos no hay caso sin entitlement.');
        }
    }
    
    @isTest
    public static void informarCentroManipuladorBeforeInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeGrupoTrabajo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoTrabajo = new CC_Grupo_Colaborador__c();
        grupoTrabajo.Name = 'Grupo Trabajo';
        grupoTrabajo.RecordTypeId = recordTypeGrupoTrabajo;
        grupoTrabajo.OS_GrupoTrabajo__c = 'Buzón Comercio Exterior';
        insert grupoTrabajo;
        
        Id recordTypeCartera = Schema.SObjectType.OS_Cartera__c.getRecordTypeInfosByDeveloperName().get('OS_Centro_Manipulador').getRecordTypeId();
        OS_Cartera__c centroManipulador = new OS_Cartera__c();
        centroManipulador.Name = 'CUENTA CON CENTRO MANIPULADOR';
        centroManipulador.OS_GrupoTrabajo__c = grupoTrabajo.Id;
        centroManipulador.RecordTypeId = recordTypeCartera;
        insert centroManipulador;
        
        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'CUENTA CON CENTRO MANIPULADOR';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.OS_Centro_Manipulador__c = centroManipulador.Id;
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        
        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Buzón Efectivo COPS';
            caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.Status = 'Activo';
            caso.Status = 'Cerrado';
            caso.AccountId = cuenta.Id;
            insert caso;

            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            contacto.Email = 'test@test.com';
            contacto.FirstName = 'Nombre';
            contacto.LastName = 'Apellido';
            insert contacto;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Case casoInsertado = [SELECT OS_Centro_Manipulador__c FROM Case WHERE Id = :caso.Id AND OS_Centro_Manipulador__c <> null];
            
            System.assertNotEquals(null, casoInsertado, 'Comprobamos no hay caso sin centro manipulador.');
        }
    }
    
    @isTest
    public static void informarGrupoTrabajoBeforeInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Group testGroup = new Group(Name='Buzón Comercio Exterior', Type='Queue');
        insert testGroup;

        //Associating queue with group AND to the Case object
        System.runAs (usuarioAdmin) {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        Id recordTypeGrupoTrabajo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoTrabajo = new CC_Grupo_Colaborador__c();
        grupoTrabajo.Name = 'Grupo Trabajo';
        grupoTrabajo.RecordTypeId = recordTypeGrupoTrabajo;
        grupoTrabajo.OS_GrupoTrabajo__c = 'Buzón Comercio Exterior';
        insert grupoTrabajo;     

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        System.runAs (usuarioAdmin) {
            Test.startTest();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
            caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.OwnerId = testGroup.Id;
            insert caso;
            Test.stopTest();

            Case casoInsertado = [SELECT Id, OS_GrupoTrabajo__c FROM Case WHERE Id = :caso.Id];
            if (casoInsertado != null) {
                System.assertNotEquals(null, casoInsertado.OS_GrupoTrabajo__c, 'Comprobamos no hay grupo de trabajo asociado.');
            }
        }
    }    
    
    @isTest
    public static void actualizarGrupoTrabajoBeforeUpdate() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        User usuario1 = new User();
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Operador'].Id;
        usuario1.FirstName = 'first 1';
        usuario1.LastName = 'last1';
        usuario1.Email = 'puser000@amamama.com';
        usuario1.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'TEST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'America/Los_Angeles';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'en_US';
        usuario1.LocaleSidKey = 'en_US';
        insert usuario1;

        Group testGroup = new Group(Name='Buzón Comercio Exterior', Type='Queue');
        insert testGroup;
        
        //Associating queue with group AND to the Case object
        System.runAs (usuarioAdmin) {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        Id recordTypeGrupoTrabajo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoTrabajo = new CC_Grupo_Colaborador__c();
        grupoTrabajo.Name = 'Grupo Trabajo';
        grupoTrabajo.RecordTypeId = recordTypeGrupoTrabajo;
        grupoTrabajo.OS_GrupoTrabajo__c = 'Buzón Comercio Exterior';
        insert grupoTrabajo;     

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.OwnerId = usuarioAdmin.Id;
        insert caso;

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso.OwnerId = testGroup.Id;
            update caso;
            Test.stopTest();

            Case casoActualizado = [SELECT Id, OS_GrupoTrabajo__c FROM Case WHERE Id = :caso.Id];
            if (casoActualizado != null) {
                System.assertNotEquals(null, casoActualizado.OS_GrupoTrabajo__c, 'Comprobamos no hay grupo de trabajo asociado.');
            }
        }
    }
    
    @isTest
    public static void informarCentroManipuladorBeforeUpdate() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        List<OS_Cartera__c> carteras = new List<OS_Cartera__c>();

        OS_Cartera__c centroManipulador1 = new OS_Cartera__c();
        centroManipulador1.Name = 'centro manipulador test';
		centroManipulador1.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Centro_Manipulador');
        carteras.add(centroManipulador1); 
        
        OS_Cartera__c centroManipulador2 = new OS_Cartera__c();
        centroManipulador2.Name = 'centro manipulador test';
		centroManipulador2.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OS_Cartera__c', 'OS_Centro_Manipulador');
        carteras.add(centroManipulador2); 
        insert carteras;
        
        List<Account> cuentas = new List<Account>();
        Account cuenta1 = new Account();
        cuenta1.Name = 'Cuenta CentroCaixabank 1';
        cuenta1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta1.OS_Premium__c = true;
        cuenta1.OS_Centro_Manipulador__c = centroManipulador1.Id;
        cuentas.add(cuenta1);
        
        Account cuenta2 = new Account();
        cuenta2.Name = 'Cuenta CentroCaixabank 2';
        cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta2.OS_Premium__c = true;
        cuenta2.OS_Centro_Manipulador__c = centroManipulador2.Id;
        cuentas.add(cuenta2);
        insert cuentas;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta1.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta2.Id;
        acshare2.UserOrGroupId = usuarioOperador.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);
        insert totalPermisos;
                
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Efectivo COPS';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.AccountId = cuenta1.Id;
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        System.runAs (usuarioOperador) {
            Test.startTest();
            caso.AccountId = cuenta2.Id;
            update caso;
            insert contacto;
            Test.stopTest();

            Case casoActualizado = [SELECT Id, OS_Centro_Manipulador__c FROM Case WHERE Id = :caso.Id];
            if (casoActualizado != null) {
                System.assertNotEquals(null, casoActualizado.OS_Centro_Manipulador__c, 'Comprobamos no hay centro manipulador.');
            }
        }
    }
    
	
    @isTest
    public static void enmascararbeforeUpdate() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        // Alta de datos para la prueba
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        
        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto 1234567898765432';
            caso.Description = '1234 5678 9876 5432 Descripción';
            caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
            update caso;
            insert contacto;
            Test.stopTest();
            
            // Evaluación del resultado de la prueba
            Case casoActualizado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
            if (casoActualizado != null) {
                System.assertEquals('Asunto 1234XXXXXXXX5432', casoActualizado.Subject, 'Comprobamos el asunto del caso coincide.');
                System.assertEquals('1234XXXXXXXX5432 Descripción', casoActualizado.Description, 'Comprobamos la descripción del caso coincide.');
                System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoActualizado.CC_Detalles_Consulta__c, 'Comprobamos el campo detalle consulta del caso coincide.');
                System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoActualizado.CC_Detalles_Solucion__c, 'Comprobamos el campo detalle solución del caso coincide.');
            }
        }
    }

    @isTest
    public static void crearActividadCierreAfterInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Cerrado';

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            insert caso;
            insert contacto;
            Test.stopTest();

            // Evaluación del resultado de la prueba
            System.assertNotEquals(null, [SELECT Id FROM Task WHERE WhatId = :caso.Id], 'Comprobamos no hay caso coincidente.');
        }
    }

    @isTest
    public static void crearActividadCierreAfterUpdate() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id stdBHId;
        BusinessHours[] stdBH = [SELECT Id, Name FROM BusinessHours WHERE Name = 'cops' AND isActive = true];
        stdBHId = stdBH[0].Id;
        if(stdBH.isEmpty()){
            stdBHId = [SELECT Id FROM BusinessHours WHERE isActive = True LIMIT 1].Id;
        }

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica COPS';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
        mccTematica.OS_Horario__C= stdBHId;
        mccTematica.OS_Horas_SLA__c = '24' ;
        mccTematica.OS_Departamento__c = 'UAFE';
        mccTematica.OwnerId = usuarioOperador.Id;
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto COPS';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001';
        mccProducto.OwnerId = usuarioOperador.Id;
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo COPS';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CBK_Traslado_Remitido__c = 'Remitido';
        mccMotivo.CC_Codigo_Externo__c = 'MOC-000001';
        mccMotivo.OwnerId = usuarioOperador.Id;
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
       	CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa COPS';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CAP-000001';
        mccCausa.OS_Horas_SLA__c = '24' ;
        mccCausa.OwnerId = usuarioOperador.Id;
        insert mccCausa;
        
        Id recordTypeIdSol = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
       	CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solución COPS';
        mccSolucion.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = recordTypeIdSol;
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SOC-000001';
        mccSolucion.OwnerId = usuarioOperador.Id;
        insert mccSolucion;


        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBAS CLIENTE';
        cuenta.CC_Numero_Documento__c = '64850344G';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        contacto.RecordTypeId = recordTypeContacto;
        insert contacto;

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.FolderId = usuarioOperador.Id;
        plantilla.Name = 'Prueba de remitido a colaborador automatico';
        plantilla.DeveloperName = 'OS_RemitidoColab_Automatico';
        plantilla.TemplateType = 'Text';
        plantilla.isactive = true;
        System.runAs (usuarioOperador) {
            insert plantilla;
        }
        
        CC_MCC_Plantilla__c plantillaMotivo = new CC_MCC_Plantilla__c();
        plantillaMotivo.CC_MCC_Plantilla_DeveloperName__c = 'OS_RemitidoColab_Automatico';
        plantillaMotivo.CC_MCC__c = mccMotivo.Id;
        insert plantillaMotivo;
        
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colab';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.OS_Negocio__c = 'COPS';
        insert grupoColab;   
        
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c contactoColaborador = new CC_Grupo_Colaborador_Contact__c();
        contactoColaborador.CC_Usuario__c = UserInfo.getUserId();
        contactoColaborador.CC_Grupo_Colaborador__c = grupoColab.Id;
        contactoColaborador.CC_Para_CC__c = 'Para';
		contactoColaborador.CC_Reclamacion_1__c = false;        
		contactoColaborador.CC_Reclamacion_2__c = false;        
		contactoColaborador.CC_Reclamacion_3__c = false;  
        colaboradores.add(contactoColaborador);      
        CC_Grupo_Colaborador_Contact__c contactoColaborador2 = new CC_Grupo_Colaborador_Contact__c();
        contactoColaborador2.CC_Usuario__c = UserInfo.getUserId();
        contactoColaborador2.CC_Grupo_Colaborador__c = grupoColab.Id;
        contactoColaborador2.CC_Para_CC__c = 'CC';
		contactoColaborador2.CC_Reclamacion_1__c = false;        
		contactoColaborador2.CC_Reclamacion_2__c = false;        
		contactoColaborador2.CC_Reclamacion_3__c = false;  
        colaboradores.add(contactoColaborador2);    
        insert colaboradores;
        
        CC_MCC_Grupo_Colaborador__c grupoMotivo = new CC_MCC_Grupo_Colaborador__c();
        grupoMotivo.CC_Grupo_Colaborador__c = grupoColab.Id;
        grupoMotivo.CC_MCC__c = mccMotivo.Id;
        insert grupoMotivo;

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Case caso2 = new Case();
        caso2.RecordTypeId = recordTypeCaso;
		caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso2.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.Status = 'Activo';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.Status = 'Cerrado';
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.CC_Solucion__c = mccSolucion.Id;
        caso2.OwnerId = usuarioOperador.Id;
        insert caso2;

        System.runAs (usuarioOperador) {
            Test.startTest();
            caso.Status = 'Cerrado';
            caso.AccountId = cuenta.Id;
            caso.ContactId = contacto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            caso.CC_Solucion__c = mccSolucion.Id;
            update caso;
            Test.stopTest();

            // Evaluación del resultado de la prueba
            System.assertNotEquals(null, [SELECT Id FROM Task WHERE WhatId = :caso.Id], 'Comprobamos no hay tarea coincidente.');
            System.assertNotEquals(null, [SELECT Id FROM EmailMessage WHERE parentId = :caso.Id], 'Comprobamos no hay email coincidente.');
        }
    }

    @isTest
    public static void crearActividadReasignacionAfterUpdate() {
        User usuarioOperador = [SELECT Id, FirstName, LastName FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.Status = 'Activo';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            caso.OwnerId = usuarioOperador.Id;
            update caso;
            insert contacto;
            Test.stopTest();

            List<Task> tareasReasignacion = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Reasignación'
                                                AND Subject = :('Reasignación del caso a ' + usuarioOperador.FirstName + ' ' + usuarioOperador.LastName)
                                                AND ActivityDate = :System.today() AND Status = 'Completed'];
            // Evaluación del resultado de la prueba

            System.assertNotEquals(null, [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Reasignación'
            AND Subject = :('Reasignación del caso a ' + usuarioOperador.FirstName + ' ' + usuarioOperador.LastName)
            AND ActivityDate = :System.today() AND Status = 'Completed'], 'Comprobamos no hay tarea coincidente.');
        }
    }

    @isTest
    public static void crearActividadReasignacionGrupoTrabajoAfterUpdate() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        User usuario1 = new User();
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Operador'].Id;
        usuario1.FirstName = 'first 1';
        usuario1.LastName = 'last1';
        usuario1.Email = 'puser000@amamama.com';
        usuario1.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'TEST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'America/Los_Angeles';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'en_US';
        usuario1.LocaleSidKey = 'en_US';
        insert usuario1;

        Group testGroup = new Group(Name='Buzón Comercio Exterior', Type='Queue');
        insert testGroup;
        
        //Associating queue with group AND to the Case object
        System.runAs (usuarioAdmin) {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        Id recordTypeGrupoTrabajo = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoTrabajo = new CC_Grupo_Colaborador__c();
        grupoTrabajo.Name = 'Grupo Trabajo';
        grupoTrabajo.RecordTypeId = recordTypeGrupoTrabajo;
        grupoTrabajo.OS_GrupoTrabajo__c = 'Buzón Comercio Exterior';
        insert grupoTrabajo;     

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';

        System.runAs (usuarioOperador) {
            Test.startTest();
            insert caso;
            caso.OwnerId = testGroup.Id;
            update caso;
            Test.stopTest();

            // Evaluación del resultado de la prueba

            System.assertNotEquals(null, [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Reasignación'
            AND Subject = :('Reasignación del Grupo de Trabajo a ' + testGroup.Name)
            AND ActivityDate = :System.today() AND Status = 'Completed'], 'Comprobamos no hay tarea coincidente.');
        }
    }

    @isTest
    public static void informarDepartamentoTelefonoBeforeInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        //telefonos = [SELECT name, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'COPS: Relación DNIS y Canal de procedencia' AND name IN :CanalProcedenciaTelef];
        
        CC_Lista_Valores__c listaDeValores = new CC_Lista_Valores__c();
        listaDeValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaDeValores.name = 'COPS: Relación DNIS y Canal de procedencia';
        insert listaDeValores;

        CC_Lista_Valores__c telefono = new CC_Lista_Valores__c();
        telefono.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        telefono.name = 'Teléfono COPS atención clientes';
        telefono.CC_Valor2__c = 'UAC';
        telefono.CC_Lista__c = listaDeValores.Id;
        insert telefono;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        
        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            insert caso;
            Case caso2 = [SELECT OS_Departamento__c FROM Case WHERE Id =: caso.Id];
            System.assertEquals('UAC', caso2.OS_Departamento__c, 'Comprobamos el departamento del caso es UAC.');
            insert contacto;
            Test.stopTest();
        }
    }

    @isTest
    public static void testBackupCasosReactivados() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];
        User usuarioOperador2 = [SELECT Id, OS_Agente_Backup__c FROM User WHERE FirstName = 'OP222' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Rechazado';
        caso.OwnerId = usuarioOperador2.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            insert contacto;
            Test.stopTest();

            Case querycaso = [SELECT OwnerId FROM Case WHERE Id = :caso.Id];
            System.assertEquals(usuarioOperador2.OS_Agente_Backup__c, querycaso.OwnerId, 'Comprobamos el propietario del caso coincide con el usuario asignado.');
        }
    }
    @isTest
    public static void testBackupCasosReactivadosColas() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Group testGroup = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = '2N CCI Holabank'];

        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso2.Origin = 'Phone';
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.Status = 'Rechazado';
        caso2.OwnerId = usuarioOperador.Id;
        insert caso2;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso2.Status = 'Activo';
            update caso2;
            insert contacto;
            Test.stopTest();

            Case querycaso2 = [SELECT OwnerId FROM Case WHERE Id = :caso2.Id];
            System.assertEquals(testGroup.Id, querycaso2.OwnerId, 'Comprobamos el propietario del caso coincide con el grupo asignado.');
        }
    }

    @isTest
    public static void actualizarTelefonoAccountCaso() {   
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = new Account();
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.CC_Email__c = 'pruebasg@caixabank.com';
        cuenta.Phone = '778855994';
        cuenta.Name = 'Pruebas telefono Cuenta';
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
    	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba telefono';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.AccountId = cuenta.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Buzon_Salida__c= 'bluewolf.copsdev.test@gmail.com';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        
        List<Case> listaCasos = new List<Case>();
        listaCasos.add(caso);
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest(); 
            cuenta.Phone = '666666666';
            update cuenta;
            Test.stopTest();
            Case casoActualizado = [SELECT OS_Account_Phone__c, OS_Account_Mobile__c FROM Case WHERE Id = :caso.Id LIMIT 1];
            
            //System.assertEquals('666666666',casoActualizado.OS_Account_Phone__c, 'Comprobamos el teléfono del caso coincide con el del cliente.');
            System.assertEquals(cuenta.PersonMobilePhone,casoActualizado.OS_Account_Mobile__c, 'Comprobamos el móvil del caso coincide con el del cliente.');
        }
    }
}