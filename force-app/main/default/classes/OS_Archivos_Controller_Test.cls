@isTest
public class OS_Archivos_Controller_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }
    
	@isTest
    public static void recuperarCampos() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;       
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'account temp';
        insert cuenta;
        
        Id RecordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeCliente;
        insert contacto; 
        
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
		mccTematica.OS_Buzon_Salida__c = 'Buzón Comercio Exterior';
        mccTematica.OS_Departamento__c = 'UAC';
        mccTematica.OS_Horas_SLA__c = '24' ;
        mccTematica.OS_Horario__C = businessHoursId;
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert mccProducto; 
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = mccTematica.Id;
        motivo.CC_Producto_Servicio__c = mccProducto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
      
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso listview Correos electronicos';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.OwnerId = usuarioOperador.Id;
        insert caso;
        
        //Actividad correo
        /*Task actividadCorreo1 = new Task();
        actividadCorreo1.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
        actividadCorreo1.Type = 'Traslado Colaborador';
        actividadCorreo1.WhatId = caso.Id;
        actividadCorreo1.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo1;*/
        
        EmailMessage correo1 = new EmailMessage();
        correo1.Subject = 'Prueba de envío de correo';
        correo1.status = '3'; // email was sent 
        correo1.CC_Grupo_Colab__c = 'Grupo';
        correo1.CC_Procedencia__c = 'Traslado Colaborador';
        correo1.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DEVELOPERNAME = 'OS_Buzon_Comercio_Exterior' LIMIT 1].CC_Direccion_Correo__c;
        correo1.ToAddress = 'prueba@ibm.com';
        correo1.Incoming = false;
        correo1.ParentId = caso.Id;
        correo1.RelatedToId = caso.Id;
        
		
        List<String> cuerpoCorreo1 = new List<String>();
        cuerpoCorreo1.add('<html>');
        cuerpoCorreo1.add('Cuerpo del correo');
        cuerpoCorreo1.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoCorreo1.add('</html>');
        correo1.HtmlBody = String.join(cuerpoCorreo1, '<br/>');
        insert correo1;
        
        /*
        Task actividadCorreo2 = new Task();
        actividadCorreo2.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
        actividadCorreo2.Type = 'Traslado Colaborador';
        actividadCorreo2.WhatId = caso.Id;
        actividadCorreo2.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo2;
        
        EmailMessage correo2 = new EmailMessage();
        correo2.Subject = 'Prueba de correo 2';
        correo2.status = '2'; 
        correo2.ActivityId = actividadCorreo2.Id;
        correo2.CC_Grupo_Colab__c = 'Grupo';
        correo2.CC_Procedencia__c = 'Traslado Colaborador';
        correo2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DEVELOPERNAME = 'OS_Buzon_Comercio_Exterior' LIMIT 1].CC_Direccion_Correo__c;
        correo2.ToAddress = 'prueba@ibm.com';
        correo2.Incoming = true;
        correo2.ParentId = caso.Id;
        correo2.RelatedToId = caso.Id;
        

        List<String> cuerpoCorreo2 = new List<String>();
        cuerpoCorreo2.add('<html>');
        cuerpoCorreo2.add('Cuerpo del correo');
        cuerpoCorreo2.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoCorreo2.add('</html>');
        correo2.HtmlBody = String.join(cuerpoCorreo2, '<br/>');
        insert correo2;*/
        
        
        //Adjuntos:
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

        List<ContentVersion> listCVs = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content pdf';
        cv.PathOnClient = 'Test_Pdf.pdf';
        cv.VersionData = beforeblob;
        listCVs.add(cv);
        
        ContentVersion cv2 = new ContentVersion();
        cv2.title = 'test content image';
        cv2.PathOnClient = 'Test_Image.jpg';
        cv2.VersionData = beforeblob;
        listCVs.add(cv2);
        
        ContentVersion cv3 = new ContentVersion();
        cv3.title = 'test content doc';
        cv3.PathOnClient = 'Test_Doc.doc';
        cv3.VersionData = beforeblob;
        listCVs.add(cv3);
        
        ContentVersion cv4 = new ContentVersion();
        cv4.title = 'test content ppt';
        cv4.PathOnClient = 'Test_PPT.ppt';
        cv4.VersionData = beforeblob;
        listCVs.add(cv4);
        
        ContentVersion cv5 = new ContentVersion();
        cv5.title = 'test content excel';
        cv5.PathOnClient = 'Test_Excel.xls';
        cv5.VersionData = beforeblob;
        listCVs.add(cv5);
        
        ContentVersion cv6 = new ContentVersion();
        cv6.title = 'test content unknown';
        cv6.PathOnClient = 'Test_unknown.test';
        cv6.VersionData = beforeblob;
        listCVs.add(cv6);
        insert listCVs;    
        
        List<Id> listaIdsCv = new List<Id>();
        listaIdsCv.add(cv.Id);
        listaIdsCv.add(cv2.Id);
        listaIdsCv.add(cv3.Id);
        listaIdsCv.add(cv4.Id);
        listaIdsCv.add(cv5.Id);
        listaIdsCv.add(cv6.Id);
        
        Map<Id,Id> mapIdContentVersion = new Map<Id,Id>();
        List<ContentVersion> testContentList = [SELECT Id, ContentDocumentId FROM ContentVersion where Id IN :listaIdsCv];
        for (ContentVersion contentVersion : testContentList) {
            mapIdContentVersion.put(contentVersion.Id, contentVersion.ContentDocumentId);
        }

        List<ContentDocumentLink> listContentLink = new List<ContentDocumentLink>();
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentlink.LinkedEntityId = correo1.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = mapIdContentVersion.get(cv.Id);
		listContentLink.add(contentLink);
                
        ContentDocumentLink contentLink2 = new ContentDocumentLink();
        contentLink2.LinkedEntityId = correo1.Id;
        contentLink2.ShareType = 'V';
        contentlink2.ContentDocumentId = mapIdContentVersion.get(cv2.Id);
		listContentLink.add(contentLink2);
                
        ContentDocumentLink contentLink3 = new ContentDocumentLink();
        contentLink3.LinkedEntityId = correo1.Id;
        contentLink3.ShareType = 'V';
        contentlink3.ContentDocumentId = mapIdContentVersion.get(cv3.Id);
		listContentLink.add(contentLink3);
                
        ContentDocumentLink contentLink4 = new ContentDocumentLink();
        contentLink4.LinkedEntityId = correo1.Id;
        contentLink4.ShareType = 'V';
        contentlink4.ContentDocumentId = mapIdContentVersion.get(cv4.Id);
		listContentLink.add(contentLink4);
        
        
		ContentDocumentLink contentLink5 = new ContentDocumentLink();
        contentLink5.LinkedEntityId = correo1.Id;
        contentLink5.ShareType = 'V';
        contentlink5.ContentDocumentId = mapIdContentVersion.get(cv5.Id);
		listContentLink.add(contentLink5);

		ContentDocumentLink contentLink6 = new ContentDocumentLink();
        contentLink6.LinkedEntityId = caso.Id;
        contentLink6.ShareType = 'V';
        contentlink6.ContentDocumentId = mapIdContentVersion.get(cv6.Id);
		listContentLink.add(contentLink6);        
        insert listContentLink;

        System.runAs (usuarioOperador) {
            Test.startTest();
            List<OS_Archivos_Controller.Archivo> archivos = OS_Archivos_Controller.recuperarCampos(caso.Id, 'ultimaModificacion', 'asc', new List<String>{'all'});
            List<OS_Archivos_Controller.Archivo> archivos2 = OS_Archivos_Controller.recuperarCampos(caso.Id, 'tamano', 'desc', new List<String>{'xls'});
            List<OS_Archivos_Controller.Archivo> archivos3 = OS_Archivos_Controller.recuperarCampos(caso.Id, 'urlPropietario', 'desc', new List<String>{'pdf'});
            List<OS_Archivos_Controller.Archivo> archivos4 = OS_Archivos_Controller.recuperarCampos(caso.Id, 'urlOrigen', 'asc',new List<String>{'all'});
            List<OS_Archivos_Controller.Archivo> archivos5 = OS_Archivos_Controller.recuperarCampos(caso.Id, 'urlTitulo', 'asc',new List<String>{'all'});
            List<OS_Archivos_Controller.Archivo> archivos6 = OS_Archivos_Controller.recuperarCampos(caso.Id, 'remitente', 'desc',new List<String>{'all'});
            List<OS_Archivos_Controller.Archivo> archivos7 = OS_Archivos_Controller.recuperarCampos(caso.Id, 'remitente', 'asc',new List<String>{'all'});
            Test.stopTest();
        
            System.assertEquals(6, archivos.size());
            System.assertNotEquals(null, archivos);        
            System.assertEquals('test content doc', archivos5[0].titulo);
            System.assertEquals('test content unknown', archivos5[5].titulo);
            System.assertEquals('test content pdf', archivos6[0].titulo);
            System.assertEquals('test content unknown', archivos6[5].titulo); 
        }   
    }
}