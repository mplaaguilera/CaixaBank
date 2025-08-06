@isTest
public class CC_NotifContInterAC_Test {
	@isTest
    public static void CC_NotifContInterAC() {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Alfabético';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
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
        
        List<ID> oListCase = new List<ID>();
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
        c1.CC_Canal_Operativo__c = 'App BrokerNow';
        c1.CC_Id_Cognitivo__c = 'HDD_666555666';
        c1.CC_Oficina_afectada__c = '08548';
        c1.CC_MCC_Motivo__c = mccMotivo.Id;
		c1.CC_MCC_ProdServ__c = mccProducto.Id;
        c1.CC_MCC_Tematica__c = mccTematica.Id;
        insert c1;
        
        oListCase.add(c1.Id);
        
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
        Datetime vToday = datetime.now();
        
        CBK_SCH_PendingProcess__c pendingProcess1 = new CBK_SCH_PendingProcess__c();
        pendingProcess1.RecordId__c = c1.Id;
        pendingProcess1.Schedule_Time__c = vToday.addDays(- 1);
        pendingProcess1.ClassName__c = 'CC_NotifContInterAC';
        pendingProcessInsertList.add(pendingProcess1);
        
        Insert pendingProcessInsertList;
        
        Test.startTest();
        CC_NotifContInterAC.gestionarContactoInermedioClienteAC(oListCase);
        
        CC_NotifContInterAC implClass = new CC_NotifContInterAC();
        implClass.lstInfoProcess = pendingProcessInsertList; 
        System.enqueueJob(implClass);
        
        Test.stopTest();

        Case casoPost = [SELECT Id,CC_Notif_Cont_Inter__c FROM Case LIMIT 1];
        System.assertNotEquals(null, casoPost.CC_Notif_Cont_Inter__c, 'No se ha relenado el campo');
    }
}