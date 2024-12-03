@isTest
public class CC_WS_Solicitudes_Oficina_Test {
    @isTest
    static void CC_WS_Solicitudes_Oficina() {
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
        acc1.CC_Numero_Documento__c='60236005V';

        insert acc1;
        
		Account acc2 = new Account();
		acc2.CC_Tipo_Centro__c = 'OF';
        acc2.ParentId = acc1.Id;
        acc2.CC_Numero_Empresa__c = '001';
        acc2.CC_Numero_Oficina__c = '08548';
        acc2.Name = 'Store Ficticia';
        acc2.CC_Numero_Documento__c='60236005V';
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
        
        
		List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input> oEntrada = new List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input>();
        CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input oDataIn = new CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input();
        oDataIn.Oficina = acc2.CC_Numero_Oficina__c;
        oDataIn.Nif ='';
        oDataIn.Estado = 'Activo';
        oEntrada.add(oDataIn);
        
        CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Output oUtput = CC_WS_Solicitudes_Oficina.searchCase(oEntrada);
        system.assertNotEquals(null, oUtput);
        
                
        Account accnt = new Account();
		accnt.CC_Tipo_Centro__c = 'DT';
        accnt.CC_Numero_Empresa__c = '001';
        accnt.Name = 'DT Ficticia';
        insert accnt;
        
        Account accnt1 = new Account();
		accnt1.CC_Tipo_Centro__c = 'GC';
        accnt1.ParentId = accnt.Id;
        accnt1.CC_Numero_Empresa__c = '001';
        accnt1.CC_Numero_Oficina__c = '11111';
        accnt1.Name = 'GC Ficticia';
        accnt1.CC_Numero_Documento__c='60236005V';

        insert accnt1;
        
		Account accnt2 = new Account();
		accnt2.CC_Tipo_Centro__c = 'OF';
        accnt2.ParentId = accnt1.Id;
        accnt2.CC_Numero_Empresa__c = '001';
        accnt2.CC_Numero_Oficina__c = '08548';
        accnt2.Name = 'Store Ficticia';
        accnt2.CC_Numero_Documento__c='60236005V';
        insert accnt2;
        
        
        Case c2 = new Case();
        c2.Subject = 'Prueba';
        c2.CC_Idioma__c = 'es';
        c2.CC_NumPerso__c = '123456';
        c2.CC_Tipo_Cliente__c = 'Cliente';
        c2.Status = 'Activo';
        c2.Origin = 'Comentarios Stores';
        c2.CC_Numero_Documento__c = '60236005V';
		c2.CC_Tipo_Contacto__c = 'Petición de servicio';
        c2.CC_Canal_Procedencia__c = 'Google Play Store';
        c2.CC_Id_Cognitivo__c = 'HDD_666555666';
        c2.CC_Oficina_Afectada_Lookup__c = accnt2.Id;
        c2.CC_MCC_Motivo__c = mccMotivo.Id;
		c2.CC_MCC_ProdServ__c = mccProducto.Id;
        c2.CC_MCC_Tematica__c = mccTematica.Id;
        insert c2;
        
		oEntrada = new List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input>();
        oDataIn = new CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input();
        oDataIn.Oficina = accnt2.CC_Numero_Oficina__c;
        oDataIn.Nif ='';
        oEntrada.add(oDataIn);
        
       	oUtput = CC_WS_Solicitudes_Oficina.searchCase(oEntrada);
        system.assertNotEquals(null, oUtput);
        
        
        
                
        Account account = new Account();
		account.CC_Tipo_Centro__c = 'DT';
        account.CC_Numero_Empresa__c = '001';
        account.CC_Numero_Oficina__c = '11111';
        account.Name = 'DT Ficticia';
        insert account;
        
        Account account1 = new Account();
		account1.CC_Tipo_Centro__c = 'GC';
        account1.ParentId = account.Id;
        account1.CC_Numero_Empresa__c = '001';
        account1.Name = 'GC Ficticia';
        account1.CC_Numero_Documento__c='60236005V';

        insert account1;
        
		Account account2 = new Account();
		account2.CC_Tipo_Centro__c = 'OF';
        account2.ParentId = account1.Id;
        account2.CC_Numero_Empresa__c = '001';
        account2.CC_Numero_Oficina__c = '08548';
        account2.Name = 'Store Ficticia';
        account2.CC_Numero_Documento__c='60236005V';
        insert account2;
        
        
        Case c3 = new Case();
        c3.Subject = 'Prueba';
        c3.CC_Idioma__c = 'es';
        c3.CC_NumPerso__c = '123456';
        c3.CC_Tipo_Cliente__c = 'Cliente';
        c3.Status = 'Activo';
        c3.Origin = 'Comentarios Stores';
        c3.CC_Numero_Documento__c = '60236005V';
		c3.CC_Tipo_Contacto__c = 'Petición de servicio';
        c3.CC_Canal_Procedencia__c = 'Google Play Store';
        c3.CC_Id_Cognitivo__c = 'HDD_666555666';
        c3.CC_Oficina_Afectada_Lookup__c = account2.Id;
        c3.CC_MCC_Motivo__c = mccMotivo.Id;
		c3.CC_MCC_ProdServ__c = mccProducto.Id;
        c3.CC_MCC_Tematica__c = mccTematica.Id;
        insert c3;
        
		oEntrada = new List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input>();
        oDataIn = new CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input();
        oDataIn.Oficina = account2.CC_Numero_Oficina__c;
        oDataIn.tipoSolicitud = c3.CC_Tipo_Contacto__c;
        oDataIn.motivo ='Personas confidenciales';
        oDataIn.Nif ='60236005V';
        oEntrada.add(oDataIn);
        
       	oUtput = CC_WS_Solicitudes_Oficina.searchCase(oEntrada);
        system.assertNotEquals(null, oUtput);
        
        
        
    }
    
    @isTest
    static void CC_WS_Solicitudes_OficinaNoOficina() {
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
        c1.CC_Oficina_afectada__c = '08548';
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
        
		Account acc = new Account();
		acc.CC_Tipo_Centro__c = 'OF';
        //acc.CC_NumCentroSup_1Niv__c = '11111';
        //acc.CC_NumCentroSup_2Niv__c = '22222';
        acc.CC_Numero_Oficina__c = '08548';
        acc.Name = 'Store Ficticia';
        insert acc;
        
		List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input> oEntrada = new List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input>();
        CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input oDataIn = new CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input();
        oDataIn.Nif = '60236005V';
        oDataIn.NumSR = '00004481';
        oDataIn.Oficina = '';
        oDataIn.fechaDesde = Date.valueOf('2019-07-03');
        oDataIn.fechaHasta = Date.valueOf('2019-07-03');
        oDataIn.tematica = 'Alfabético';
        oDataIn.servicioProd = 'Personas';
        oDataIn.tipoSolicitud = 'Petición de servicio';
        oDataIn.motivo = 'Personas confidenciales';
        oDataIn.estado = 'Activo';
        oEntrada.add(oDataIn);
        
        CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Output oUtput = CC_WS_Solicitudes_Oficina.searchCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
    @isTest
    static void CC_WS_Solicitudes_OficinaNoMCC() {
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
        c1.CC_Oficina_afectada__c = '08548';
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
        
		Account acc = new Account();
		acc.CC_Tipo_Centro__c = 'OF';
        //acc.CC_NumCentroSup_1Niv__c = '11111';
        //acc.CC_NumCentroSup_2Niv__c = '22222';
        acc.CC_Numero_Oficina__c = '08548';
        acc.Name = 'Store Ficticia';
        insert acc;
        
		List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input> oEntrada = new List<CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input>();
        CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input oDataIn = new CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Input();
        oDataIn.Nif = '60236005V';
        oDataIn.NumSR = '00004481';
        oDataIn.Oficina = '08548';
        oDataIn.fechaDesde = Date.valueOf('2019-07-03');
        oDataIn.fechaHasta = Date.valueOf('2019-07-03');
        oDataIn.tematica = 'Alfabético';
        oDataIn.servicioProd = 'Personas';
        oDataIn.tipoSolicitud = 'Petición de servicio';
        oDataIn.motivo = 'Personas confidenciales';
        oDataIn.estado = 'Activo';
        oEntrada.add(oDataIn);
        
        CC_WS_Solicitudes_Oficina.CC_WS_Solicitudes_Oficina_Output oUtput = CC_WS_Solicitudes_Oficina.searchCase(oEntrada);
        system.assertNotEquals(null, oUtput);
    }
}