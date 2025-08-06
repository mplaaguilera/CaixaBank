@isTest
public class OS_NoCliente_Borrar_Batch_Schedule_Test {
	@isTest static void testNoCliente() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
		insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        insert mccMotivo;

        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa 1';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
		insert mccCausa;
        
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion 1';
        mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
		insert mccSolucion;
        
        Id recordTypeCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        
        Case caso = new Case();
        caso.Subject='Caso no cliente';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Canal_Resolucion__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c='Formación';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        caso.CC_En_Tercer_Nivel__c=true;
        caso.Status='Cerrado';
        caso.CC_Tipo_Cliente__c = 'No Cliente'; 
        caso.OwnerId = usuarioOperador.Id;       
        insert caso;
        
        CC_Llamada__c llamada = new CC_Llamada__c();
        insert llamada;
        
        Task actCaso = new Task();
        actCaso.Status = 'Completed';
        actCaso.WhatId = caso.id;
        actCaso.Type = 'Llamada entrante';
        actCaso.CC_Llamada_Id__c = llamada.id;
        insert actCaso;

        System.runAs (usuarioOperador) {
            Test.startTest();
            SchedulableContext sc = null;
            OS_NoCliente_Borrar_Batch_Schedule tsc = new OS_NoCliente_Borrar_Batch_Schedule();
            tsc.execute(sc);
            Test.stopTest();
            
            Case casoUpdate = [Select Description from Case where id = :caso.Id limit 1];
            
            system.assertEquals('No cliente: Información borrada', casoUpdate.Description, 'Comprobación de la descripción del caso.');
        }
    }
}