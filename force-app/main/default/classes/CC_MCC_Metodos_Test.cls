@IsTest
public with sharing class CC_MCC_Metodos_Test {

    @TestSetup
    static void makeData(){
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;

        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        List<User> userList = new List<User>();


        User usuario1 = new User();
        usuario1.ProfileId = profileSupervisor;
        usuario1.FirstName = 'Usuario CC Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'ccTestUseraalsdna@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.UserRoleId = rolId.Id;

        userList.add(usuario1);

        //Usuario CAM
        User responsable = new User();
        responsable.FirstName = 'AMResponsable';
        responsable.LastName = '1';    
        responsable.IsActive = true; 	
        responsable.Alias = 'AMUser';
        responsable.Email = 'usuario_test@test.com';
        responsable.EmailEncodingKey = 'ISO-8859-1';
        responsable.LanguageLocaleKey = 'es';
        responsable.LocaleSidKey = 'es_ES';
        responsable.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CAM'].Id;
        responsable.ProfileId = [SELECT Id FROM Profile WHERE Name = 'AM_Responsable'].Id;
        responsable.TimeZoneSidKey = 'Europe/Madrid';
        responsable.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 

        userList.add(responsable);

        //Usuario SACH
        User sachResponsable = new User();
        sachResponsable.FirstName = 'SACHResponsable';
        sachResponsable.LastName = '1';    
        sachResponsable.IsActive = true; 	
        sachResponsable.Alias = 'SACHuser';
        sachResponsable.Email = 'usuario_test@test.com';
        sachResponsable.EmailEncodingKey = 'ISO-8859-1';
        sachResponsable.LanguageLocaleKey = 'es';
        sachResponsable.LocaleSidKey = 'es_ES';
        sachResponsable.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'SACH'].Id;
        sachResponsable.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SACH_Usuario_CaixaBank'].Id;
        sachResponsable.TimeZoneSidKey = 'Europe/Madrid';
        sachResponsable.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 
        
        userList.add(sachResponsable);
        
        //Usuario FRA
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        //System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuario = new User();
			usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
			usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
            usuario.FirstName = 'Fraude';
            usuario.LastName = 'Prueba';
            usuario.Alias = uniqueName.substring(18, 23);
            usuario.Email = uniqueName + '@test' + orgId + '.org';
            usuario.Username = uniqueName + '@test' + orgId + '.org';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.TimezonesIdKey = 'Europe/Madrid';

            //insert usuario;
            userList.add(usuario);

            insert userList;
        
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Supervisor')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        //}

        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }

    @isTest
    static void generaExternalId() {
        User us = [SELECT Id FROM User WHERE Email = 'ccTestUseraalsdna@kfsb.com' LIMIT 1];
        System.runAs(us) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<Id> listMccs = new List<Id>();

        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.Name = 'Tematica Test';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.OS_Departamento__c = 'UAFE';
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.OS_Departamento__c = 'UAFE';
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'Cliente';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PR-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'Cliente';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'Cliente';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'Cliente';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CA-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'Cliente';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'Cliente';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SO-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'Cliente';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        Test.stopTest();

        System.assertEquals('Cliente', solucion1.CC_Tipo_Cliente__c);

        }

    }

    @isTest
	static void generaExternalIdCOPS() {

        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        System.runAs(usuarioOperador) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<BusinessHours> bhs = [select id from BusinessHours where IsDefault=true];
        
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        List<Id> listMccs = new List<Id>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.Name = 'Tematica Test';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc.CC_Codigo_Externo__c = 'TEC-000001';
        mcc.OS_Departamento__c = 'UAC';
        mcc.OS_Horario__c = bhs.get(0).Id;
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mcc1.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mcc1.OS_Departamento__c = 'UAC';
        mcc1.OS_Horario__c = bhs.get(0).Id;
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CAC-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SOC-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        Test.stopTest();
        
        System.assertEquals('Cliente (COPS)/Empleado (COPS)', solucion1.CC_Tipo_Cliente__c);
        }
        //System.assertEquals('Completed', actividad.Status);
        
    }

    @isTest
	static void generaExternalIdCAM() {

        User us = [SELECT Id FROM User WHERE FirstName = 'AMResponsable' LIMIT 1];

        System.runAs(us) {
        //System.runAs(new User(Id = UserInfo.getUserId())) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        List<Id> listMccs = new List<Id>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.Name = 'Tematica Test';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mcc.CC_Codigo_Externo__c = 'TEA-000001';
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mcc1.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PRA-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOA-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CAA-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SOA-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        Test.stopTest();

        System.assertEquals('Cliente (CAM)/Empleado (CAM)', solucion1.CC_Tipo_Cliente__c);
        }

        //System.assertEquals('Completed', actividad.Status);
    }

    @isTest
	static void generaExternalIdSACH() {

        User us = [SELECT Id FROM User WHERE FirstName = 'SACHResponsable' LIMIT 1];

        System.runAs(us) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        List<Id> listMccs = new List<Id>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.Name = 'Tematica Test';
        mcc.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mcc.CC_Codigo_Externo__c = 'TEH-000001';
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PRH-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOH-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CAH-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SOH-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        Test.stopTest();

        System.assertEquals('Cliente (SACH)', solucion1.CC_Tipo_Cliente__c);
        }

        //System.assertEquals('Completed', actividad.Status);
    }
    
    @isTest
    static void generaExternalIdHDT() {
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        List<Id> listMccs = new List<Id>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.Name = 'Tematica Test';
        mcc.CC_Tipo_Cliente__c = 'HDT Empleado';
        mcc.CC_Codigo_Externo__c = 'TEH-000001';
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Tipo_Cliente__c = 'HDT Empleado';
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'HDT Empleado';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PRH-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'HDT Empleado';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'HDT Empleado';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOH-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'HDT Empleado';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'HDT Empleado';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CAH-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'HDT Empleado';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'HDT Empleado';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SOH-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'HDT Empleado';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        Test.stopTest();

        System.assertEquals('HDT Empleado', solucion1.CC_Tipo_Cliente__c);

        }

        

    }

    @isTest
	static void generaExternalIdCSI() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        List<Id> listMccs = new List<Id>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.Name = 'Tematica Test';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.CC_Tipo_Cliente__c = 'CSI Bankia';
        mcc.CC_Codigo_Externo__c = 'TES-000001';
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Tipo_Cliente__c = 'CSI Bankia';
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'CSI Bankia';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PRS-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'CSI Bankia';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'CSI Bankia';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOS-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'CSI Bankia';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'CSI Bankia';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CAS-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'CSI Bankia';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'CSI Bankia';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SOS-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'CSI Bankia';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        Test.stopTest();
        }

        //System.assertEquals('Completed', actividad.Status);
    }

    @isTest
	static void generaExternalIdFRA() {

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        List<CC_MCC__c> mccInsert = new List<CC_MCC__c>();
        List<Id> listMccs = new List<Id>();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTypeIdTematica;
        mcc.Name = 'Tematica Test';
        mcc.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        mcc.CC_Codigo_Externo__c = 'TEF-000001';
        mccInsert.add(mcc);
        
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordTypeIdTematica;
        mcc1.Name = 'Tematica1 Test';
        mcc1.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        mcc1.CC_Canal_Operativo__c = 'Sin canal';
        mccInsert.add(mcc1);
        listMccs.add(mcc1.Id);
        
        CC_MCC__c producto = new CC_MCC__c();        
        producto.RecordTypeId = recordTypeIdProducto;
        producto.Name = 'Producto Test';
        producto.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        producto.CC_Tematica__c = mcc.Id;
        producto.CC_Codigo_Externo__c = 'PRF-000001';
        mccInsert.add(producto);
        
        CC_MCC__c producto1 = new CC_MCC__c();        
        producto1.RecordTypeId = recordTypeIdProducto;
        producto1.Name = 'Producto Test';
        producto1.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        producto1.CC_Tematica__c = mcc1.Id;
        mccInsert.add(producto1);
        listMccs.add(producto1.Id);
        
        CC_MCC__c motivo = new CC_MCC__c();        
        motivo.RecordTypeId = recordTypeIdMotivo;
        motivo.Name = 'Motivo Test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOF-000001';
        mccInsert.add(motivo);
        
        CC_MCC__c motivo1 = new CC_MCC__c();        
        motivo1.RecordTypeId = recordTypeIdMotivo;
        motivo1.Name = 'Motivo Test';
        motivo1.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        motivo1.CC_Producto_Servicio__c = producto1.Id;
        mccInsert.add(motivo1);
        listMccs.add(motivo1.Id);
        
        CC_MCC__c causa = new CC_MCC__c();        
        causa.RecordTypeId = recordTypeIdCausa;
        causa.Name = 'Causa Test';
        causa.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CAF-000001';
        mccInsert.add(causa);
        
        CC_MCC__c causa1 = new CC_MCC__c();        
        causa1.RecordTypeId = recordTypeIdCausa;
        causa1.Name = 'Causa Test';
        causa1.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        causa1.CC_Motivo__c = motivo1.Id;
        mccInsert.add(causa1);
        listMccs.add(causa1.Id);
        
        CC_MCC__c solucion = new CC_MCC__c();        
        solucion.RecordTypeId = recordTypeIdSolucion;
        solucion.Name = 'Solucion Test';
        solucion.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SOF-000001';
        mccInsert.add(solucion);
        
        CC_MCC__c solucion1 = new CC_MCC__c();        
        solucion1.RecordTypeId = recordTypeIdSolucion;
        solucion1.Name = 'Solucion Test';
        solucion1.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        solucion1.CC_Causa__c = causa1.Id;
        mccInsert.add(solucion1);
        listMccs.add(solucion1.Id);

        insert mccInsert;
        
        Test.startTest();
        CC_MCC_Metodos.generaExternalId(listMccs);
        CC_MCC__c mccTest = [SELECT Id,CC_Codigo_Externo__c FROM CC_MCC__c WHERE Name = 'Tematica1 Test' LIMIT 1];
        assert.areNotEqual(mccTest.CC_Codigo_Externo__c,null);
        Test.stopTest();
        
        }
        //System.assertEquals('Completed', actividad.Status);
    }

    @isTest
    static void obtenerClasificacionEquivalente() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        test.startTest();
        
        Map<String, String> mapaClasificacionEquivalente = CC_MCC_Metodos.obtenerClasificacionEquivalente('Ahorro', 'AhorroAPlazo');

        test.stopTest();
        }
    }
}