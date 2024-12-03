@isTest
public class CC_WS_Detalle_Oficina_Test {
    @isTest
    static void CC_WS_Detalle_OficinaVacio() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
         Account acc = new Account();
		acc.CC_Tipo_Centro__c = 'DT';
        acc.CC_Numero_Empresa__c = '001';
        acc.CC_Numero_Oficina__c = '22222';
        acc.Name = 'DT Ficticia';
        insert acc;
        
        Account acc1 = new Account();
		acc1.CC_Tipo_Centro__c = 'GC';
        acc1.ParentId = acc.Id;
        acc1.CC_Numero_Empresa__c = '001';
        acc1.CC_Numero_Oficina__c = '11111';
        acc1.Name = 'GC Ficticia';
        insert acc1;
        
		Account acc2 = new Account();
		acc2.CC_Tipo_Centro__c = 'OF';
        acc2.ParentId = acc1.Id;
        acc2.CC_Numero_Empresa__c = '001';
        acc2.CC_Numero_Oficina__c = '08548';
        acc2.Name = 'Store Ficticia';
        insert acc2;
        
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Numero_Documento__c = '60236005V';
		c1.CC_Tipo_Contacto__c = 'Petición de servicio';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_Oficina_Afectada_Lookup__c = acc2.Id;
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
        
               
        Case oCase = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
		List<CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input> oEntrada = new List<CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input>();
        CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input oDataIn = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input();
        oDataIn.numSR = '';
        oEntrada.add(oDataIn);
        
        CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oUtput = CC_WS_Detalle_Oficina.searchDetailCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    
    @isTest
    static void CC_WS_Detalle_Oficina() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Personas';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Personas confidenciales';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
          
        Account acc = new Account();
		acc.CC_Tipo_Centro__c = 'DT';
        acc.CC_Numero_Empresa__c = '001';
        acc.CC_Numero_Oficina__c = '22222';
        acc.Name = 'DT Ficticia';
        insert acc;
        
        Account acc1 = new Account();
		acc1.CC_Tipo_Centro__c = 'GC';
        acc1.ParentId = acc.Id;
        acc1.CC_Numero_Empresa__c = '001';
        acc1.CC_Numero_Oficina__c = '11111';
        acc1.Name = 'GC Ficticia';
        insert acc1;
        
		Account acc2 = new Account();
		acc2.CC_Tipo_Centro__c = 'OF';
        acc2.ParentId = acc1.Id;
        acc2.CC_Numero_Empresa__c = '001';
        acc2.CC_Numero_Oficina__c = '08548';
        acc2.Name = 'Store Ficticia';
        insert acc2;
        
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Numero_Documento__c = '60236005V';
		c1.CC_Tipo_Contacto__c = 'Petición de servicio';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_Oficina_Afectada_Lookup__c = acc2.Id;
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
      
        
        Case oCase = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
		List<CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input> oEntrada = new List<CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input>();
        CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input oDataIn = new CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Input();
        oDataIn.numSR = oCase.CaseNumber;
        oEntrada.add(oDataIn);
        
        CC_WS_Detalle_Oficina.CC_WS_Detalle_Oficina_Output oUtput = CC_WS_Detalle_Oficina.searchDetailCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
}