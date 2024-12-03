//@IsTest
public class CC_WS_Inicio_Hidden_Test {
/*
	@isTest
    static void IniHidden() {
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
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenNoIdioma() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        //oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenNumper() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        //oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenIdCog() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        //oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenUser() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        //oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenOrigen() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        //oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenApp() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        //oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenCateg() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
        CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input oDataIn = new CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input();
        oDataIn.Aplicacion = 'HIDDEN';
        oDataIn.id_Cognitive = 'HDD_666555666';
        oDataIn.User_Agent = 'U0194297';
        oDataIn.Numperso = '12345689';
        oDataIn.Idioma = 'es';
        oDataIn.Asunto = 'Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.Tengo una cliente millonaria y quiere hacer un deposito a plazo fijo.';
        oDataIn.Espacio = 'Ahorro';
        //oDataIn.Categoria = 'AhorroALaVista';
        oDataIn.Origen = 'Empleado';
        oEntrada.add(oDataIn);
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void IniHiddenNoData() {
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
        mccConvWeb.CC_Equivalencia_Formulario__c = 'CHT-Ahorro-AhorroALaVista';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,11);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'CHT';
        mccConvWeb.CC_Espacio_Hidden__c = 'Ahorro';
        mccConvWeb.CC_Categoria_Hidden__c = 'AhorroALaVista';
        insert mccConvWeb;
		
		List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input> oEntrada = new List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Input>();
                
        List<CC_WS_Inicio_Hidden.CC_WS_Inicio_Hidden_Output> oUtput = CC_WS_Inicio_Hidden.createCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
*/
}