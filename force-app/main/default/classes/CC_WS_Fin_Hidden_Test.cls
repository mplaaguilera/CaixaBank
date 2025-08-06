//@IsTest
public class CC_WS_Fin_Hidden_Test {
/*
	@isTest
    static void FinHiddenNoCase() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'HDD-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
		List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oEntrada = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oDataIn = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input();
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.accionHidden = 'NO SOPORTADO';
        oDataIn.Nickname = 'Rosalia';
        oDataIn.TranscriptConversation = 'TranscripcionChat';
        oEntrada.add(oDataIn);
        
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oUtput = CC_WS_Fin_Hidden.closeCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void FinHiddenCaso() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'HDD-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
        Task oTask = new Task();
        oTask.WhatId = c1.Id;
        oTask.CC_Chat_Cognitivo_Id__c = 'HDD_666555666';
        oTask.Status = 'Open';
        oTask.Subject = 'Conversación ChatBot - Hidden';
        insert oTask;
        
		List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oEntrada = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oDataIn = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input();
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.accionHidden = 'NO SOPORTADO';
        oDataIn.Nickname = 'Rosalia';
        oDataIn.TranscriptConversation = '{\"user\":\"13619528\",\"startTime\":\"2019-08-21T05:55:19.134Z\",\"duration\":1566366919134,\"iterations\":4,\"reformulations\":1,\"areas\":[\"NeoApp\"],\"userQuery\":[\"a ver me puedes poner con\",\"hablar con un gestor\"],\"conversationUnits\":[{\"type\":60,\"text\":\"1\",\"timestamp\":\"2019-08-21T05:55:19.134Z\"},{\"type\":1,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:19.134Z\",\"auto\":false},{\"type\":5,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:19.134Z\"}],\"revision\":\"NO\",\"centro\":\"00000\",\"badClassifications\":[],\"agents\":[\"WATSON\"],\"aplicacionOrigen\":\"\",\"conversationID\":\"13619528_100069719\",\"currentID\":100069719,\"aplicacionCorpus\":\"NeoAPP\",\"idioma\":\"es\",\"idiomasDetectados\":[\"es\",\"es\"],\"errors\":[],\"datos\":[{\"userTextOriginal\":\"a ver me puedes poner con\",\"userTextObfuscate\":\"a ver me puedes poner con\",\"identifiedObjects\":[]},{\"userTextOriginal\":\"hablar con un gestor\",\"userTextObfuscate\":\"hablar con un gestor\",\"identifiedObjects\":[]}],\"prioritaria\":\"NO\"}';
        oEntrada.add(oDataIn);
        
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oUtput = CC_WS_Fin_Hidden.closeCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void FinHiddenNoId() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'HDD-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
		List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oEntrada = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oDataIn = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input();
        //oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.accionHidden = 'NO SOPORTADO';
        oDataIn.Nickname = 'Rosalia';
        oDataIn.TranscriptConversation = 'TranscripcionChat';
        oEntrada.add(oDataIn);
        
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oUtput = CC_WS_Fin_Hidden.closeCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void FinHiddenNoAcc() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'HDD-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
		List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oEntrada = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oDataIn = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input();
        oDataIn.id_Cognitive = 'HDD_666555666';
        //oDataIn.accionHidden = 'NO SOPORTADO';
        oDataIn.Nickname = 'Rosalia';
        oDataIn.TranscriptConversation = 'TranscripcionChat';
        oEntrada.add(oDataIn);
        
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oUtput = CC_WS_Fin_Hidden.closeCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void FinHiddenNoNick() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'HDD-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
		List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oEntrada = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
        CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input oDataIn = new CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input();
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.accionHidden = 'NO SOPORTADO';
        //oDataIn.Nickname = 'Rosalia';
        oDataIn.TranscriptConversation = 'TranscripcionChat';
        oEntrada.add(oDataIn);
        
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oUtput = CC_WS_Fin_Hidden.closeCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void FinHiddenNoData() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Conversion_MCC_Chat').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'HDD-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
		List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input> oEntrada = new List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Input>();
                
        List<CC_WS_Fin_Hidden.CC_WS_Fin_Hidden_Output> oUtput = CC_WS_Fin_Hidden.closeCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
*/
}