@isTest
    public class CC_Aviso_Llamada_Controller_Test {
    
   @TestSetup
    static void setData() {
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        Id accountId = cuenta.Id;
        
        Id RecordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Cliente';
        oCaso.ContactId = cId;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert oCaso;
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        oCaso.CC_MCC_Tematica__c = mccTematica.Id;
        oCaso.CC_MCC_ProdServ__c = mccProducto.Id;
        oCaso.CC_MCC_Motivo__c = mccMotivo.Id;
        update oCaso;
        
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'Errores Terminal Financiero';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert a1;
        
        
        CC_Lista_Valores__c a2 = new CC_Lista_Valores__c();
        a2.Name = 'CC Horas Fraude';
        a2.CC_Activa__c = true;
        a2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        a2.CC_Lista__c = a1.Id;
        a2.CC_Valor__c = '24';
        insert a2;
        

        
    }
    //Test para ver si tiene casos con mcc con el checkbox CC_Susceptible_de_Fraude__c en true
        @isTest
    public static void verificarSiTieneCasosTrueTest() {

        Test.startTest();

        Account a = [SELECT Id FROM Account LIMIT 1];
    
        CC_MCC__c mccMotivo = [SELECT Id, CC_Susceptible_de_Fraude__c FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Motivo' LIMIT 1];
        mccMotivo.CC_Susceptible_de_Fraude__c = true;
        update mccMotivo;

        Boolean tieneCasos = CC_Aviso_Llamada_Controller.verificarSiTieneCasos(a.Id);

        Test.stopTest();
        System.assertEquals(true, tieneCasos, 'La cuenta tiene casos con el flag activo');
    }
        //Test para ver si tiene casos con mcc con el checkbox CC_Susceptible_de_Fraude__c en false
         @isTest
    public static void verificarSiTieneCasosFalseTest() {

        Test.startTest();

        Account a = [SELECT Id FROM Account LIMIT 1];

        Boolean tieneCasos = CC_Aviso_Llamada_Controller.verificarSiTieneCasos(a.Id);

        Test.stopTest();
        System.assertEquals(false, tieneCasos, 'La cuenta NO tiene casos con el flag activo');
    }
        
            @isTest
    public static void verificarNoLlegaCuentaTest() {

        Test.startTest();

        Boolean tieneCasos = CC_Aviso_Llamada_Controller.verificarSiTieneCasos(null);

        Test.stopTest();
        System.assertEquals(false, tieneCasos, 'No llega la cuenta');
    }

    }