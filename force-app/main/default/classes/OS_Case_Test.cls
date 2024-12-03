@isTest
public class OS_Case_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.FolderId = usuarioOperador.Id;
        plantilla.Name = 'Prueba de traslado remitido automatico';
        plantilla.DeveloperName = 'OS_TrasColab_Automatico';
        plantilla.TemplateType = 'Text';
        plantilla.isactive = true;
        System.runAs (usuarioOperador) {
            insert plantilla;
        }
    }

    @isTest
    public static void duplicarCaso() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Duplicar Caso';
        caso1.Status = 'Activo';
        caso1.Origin = 'Phone';
        caso1.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso1.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso1.OwnerId = usuarioOperador.Id;
        insert caso1;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        List<Task> tareas = new List<Task>();
        for (Integer x = 0; x < 2; x++) {
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            tarea.WhatId = caso1.Id;
            tarea.Type = 'Automática';
            tarea.Status = 'Completed';
            tarea.Subject = 'Prueba' + x;
            tarea.Description = 'Esto es una prueba';
            tarea.ActivityDate = System.today();
            tareas.add(tarea);
        }
        insert tareas;

        String fromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;

        EmailMessage msgEmail = new EmailMessage();
        msgEmail.ParentId = caso1.Id;
        msgEmail.ActivityId = tareas[0].Id;
        msgEmail.CC_Grupo_Colab__c = 'Grupo';
        msgEmail.ToAddress = 'to@test.com';
        msgEmail.FromAddress = fromAddress;
        msgEmail.Subject = 'Correo Test';
        msgEmail.HtmlBody = 'Correo Test\n#@' + CC_EmailMessage.generarReferenciaCorreoSaliente() + '#\nFin';
        insert msgEmail;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Case casoHijo = OS_Case.duplicarCaso(caso1);
            insert contacto;
            Test.stopTest();

            //Probar que se ha insertado el caso
            System.assertNotEquals(null, casoHijo.Id, 'Los campos no coinciden');

            //Probar que se ha creado la actividad de caso duplicado
            System.assert([SELECT Count() FROM Task WHERE WhatId = :casoHijo.Id AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')] == 4, 'Los campos no coinciden');
        }
    }

    @isTest
    public static void accionesCambioCanalProcedencia() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba cambiar cola Procedencia';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case.accionesCambioCanalProcedencia(caso.Id, 'Buzón Service Desk');
            insert contacto;
            Test.stopTest();

            System.assertEquals(1, [SELECT Count() FROM Task WHERE WhatId = :caso.Id AND Type = 'Canal de procedencia modificado'], 'Los campos no coinciden');
        }
    }
    
    @isTest
    public static void reapertura() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
                
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Cerrado';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Case casoActualizado = OS_Case.reapertura(caso.Id);
            Test.stopTest();
            System.assertEquals('Activo', casoActualizado.Status, 'Los campos no coinciden');
        }
    }
    
    @isTest
    public static void trasladoColaboradorAutomatico() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        EmailTemplate plantilla = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'OS_TrasColab_Automatico'];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta;   
        
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        List<Contact> listContacto = new List<Contact>();
        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Contact contacto1 = new Contact();
        contacto1.RecordTypeId = recordTypeContacto;
        contacto1.Email = 'servicio.factoring@caixabank.com';
        contacto1.LastName = 'Pruebas1';
        contacto1.AccountId = cuenta.Id;
        listContacto.add(contacto1);
		
		Contact contacto2 = new Contact();
        contacto2.RecordTypeId = recordTypeContacto;
        contacto2.Email = 'servicio.bastanteo@caixabank.com';
        contacto2.LastName = 'Pruebas2';
        contacto2.AccountId = cuenta.Id;
        listContacto.add(contacto2);
        insert listContacto;
        
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
 
        CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaborador.name='Servicio bastanteo';
        grupoColaborador.OS_Negocio__c = 'COPS';
        grupoColaborador.OwnerId = usuarioOperador.Id;
        insert grupoColaborador;
        
        List<CC_Grupo_Colaborador_Contact__c> listcolaborador = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c colaborador1 = new CC_Grupo_Colaborador_Contact__c();
        colaborador1.CC_Contacto__c = contacto1.Id;
        colaborador1.CC_Grupo_Colaborador__c=grupoColaborador.Id;
        colaborador1.CC_Para_CC__c = 'Para';
        listcolaborador.add(colaborador1);
        
        CC_Grupo_Colaborador_Contact__c colaborador2 = new CC_Grupo_Colaborador_Contact__c();
        colaborador2.CC_Contacto__c = contacto2.Id;
        colaborador2.CC_Grupo_Colaborador__c=grupoColaborador.Id;
        colaborador2.CC_Para_CC__c = 'CC';
        listcolaborador.add(colaborador2);    
		insert listcolaborador;        
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'KYC Renewal';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.OS_Departamento__c = 'UAFE';
        mccTematica.OwnerId = usuarioOperador.Id;
        mccTematica.OS_Buzon_Salida__c = [SELECT DISPLAYNAME FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón KYC Renewal' LIMIT 1].DISPLAYNAME;
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'producto de prueba';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'motivo de prueba';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_Buzon_Salida__c = [SELECT Address FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón KYC Renewal' LIMIT 1].Address;
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        //ADJUNTOS
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
        
        insert listCVs;         

        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentVersion testContent2 = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv2.Id];
       
        Set<Id> listContentLink = new Set<Id>();
        //ContentDocumentLink contentLink = new ContentDocumentLink();
        //contentlink.LinkedEntityId = caso.Id;
        //contentlink.ShareType = 'V';
        //contentlink.ContentDocumentId = testcontent.ContentDocumentId;
		//listContentLink.add(contentLink);
                
        //ContentDocumentLink contentLink2 = new ContentDocumentLink();
        //contentLink2.LinkedEntityId = caso.Id;
        //contentLink2.ShareType = 'V';
        //contentLink2.ContentDocumentId = testcontent2.ContentDocumentId;
		//listContentLink.add(contentLink2);
        listContentLink.add(cv.Id);
        
        //insert listContentLink;

        System.runAs (usuarioOperador) {
            Test.startTest();       
            OS_Case.trasladoColaboradorAutomatico(caso.Id, grupoColaborador.Id, plantilla.Id, 'body', 'asunto', listContentLink);   
            insert contacto;   
            Test.stopTest();
            
            
            System.assertEquals('Pendiente Colaborador', [SELECT Id, Status FROM Case WHERE Id = :caso.Id LIMIT 1].Status, 'Los campos no coinciden');
        }
    }
    
    @isTest
    public static void actualizarTelefonoEmailCaso() {   
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'pruebasg@caixabank.com';
        contacto.Phone = '778855994';
        contacto.LastName = 'Pruebas telefono Contacto';
        insert contacto;

    	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.ContactId = contacto.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
       // caso.CC_Buzon_Salida__c= 'bluewolf.copsdev.test@gmail.com';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = recordTypeCaso;
        caso2.Subject = 'Prueba reapertura2';
        caso2.Status = 'Activo';
        caso2.Origin = 'Email';
        caso2.ContactId = null;
        caso2.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso2.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.CC_Buzon_Salida__c= 'bluewolf.copsdev.test2@gmail.com';
        caso2.OwnerId = usuarioOperador.Id;
        insert caso2;

        List<Case> listaCasos = new List<Case>();
        listaCasos.add(caso);
        listaCasos.add(caso2);

        System.runAs (usuarioOperador) {
            Test.startTest();       
            OS_Case.actualizarTelefonoEmailCaso(listaCasos);  
            Test.stopTest();

            List<String> casosParaQuery = new List<String>();
            casosParaQuery.add(caso.Subject);
            casosParaQuery.add(caso2.Subject);

            List<Case> newCaso = [SELECT OS_Telefono__c,OS_Email__c FROM Case Where Subject IN :casosParaQuery];
            
            System.assertNotEquals(null, newCaso[0].OS_Telefono__c, 'Los campos no coinciden');
            System.assertNotEquals(null, newCaso[0].OS_Email__c, 'Los campos no coinciden');
                    
            System.assertEquals(null, newCaso[1].OS_Telefono__c, 'Los campos no coinciden');
            System.assertEquals(null, newCaso[1].OS_Email__c, 'Los campos no coinciden');  
        }
    }
    
    @isTest
    public static void responderCerrar() {  
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'pruebasg@caixabank.com';
        contacto.Phone = '778855994';
        contacto.LastName = 'Pruebas telefono Contacto';

    	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.ContactId = contacto.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Buzon_Salida__c= 'bluewolf.copsdev.test@gmail.com';

        System.runAs (usuarioOperador) {
            Test.startTest();
            caso = OS_Case.responderCerrar(caso);
            insert contacto;
            Test.stopTest();
            
            System.assertEquals('Cerrado', caso.Status, 'Los campos no coinciden');
        }
    }
    
    @isTest
    public static void crearActividadRetipificacion() {  
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

    	Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'pruebasg@caixabank.com';
        contacto.Phone = '778855994';
        contacto.LastName = 'Pruebas telefono Contacto';

    	Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.ContactId = contacto.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Buzon_Salida__c= 'bluewolf.copsdev.test@gmail.com';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;
        	
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case.crearActividadRetipificacion(caso.Id,'Tematica anterior','Producto anterior','Motivo anterior');
            insert contacto;
            Test.stopTest();

            System.assertEquals('Activo', caso.Status, 'Los campos no coinciden');
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

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

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
        insert caso;

        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = recordTypeCaso;
        caso2.Subject = 'Prueba telefono';
        caso2.Status = 'Activo';
        caso2.Origin = 'Email';
        caso2.AccountId = null;
        caso2.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso2.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.CC_Buzon_Salida__c= 'bluewolf.copsdev.test@gmail.com';
        caso2.OwnerId = usuarioOperador.Id;
        insert caso2;

        System.runAs (usuarioOperador) {
            Test.startTest(); 
            List<Case> listaCasos = new List<Case>();
            listaCasos.add(caso); 
            listaCasos.add(caso2);     
            insert contacto;
            Test.stopTest();
            Case casoActualizado = [SELECT OS_Account_Phone__c, OS_Account_Mobile__c FROM Case WHERE Id = :caso.Id LIMIT 1];
            Case casoActualizado2 = [SELECT OS_Account_Phone__c, OS_Account_Mobile__c FROM Case WHERE Id = :caso2.Id LIMIT 1];
            
            System.assertEquals(cuenta.Phone,casoActualizado.OS_Account_Phone__c, 'Los campos no coinciden');
            System.assertEquals(cuenta.PersonMobilePhone,casoActualizado.OS_Account_Mobile__c, 'Los campos no coinciden');
            System.assertEquals(null,casoActualizado2.OS_Account_Phone__c, 'Los campos no coinciden');
            System.assertEquals(null,casoActualizado2.OS_Account_Mobile__c, 'Los campos no coinciden');
        }
    } 
 
    @isTest
    public static void envioCorreoTrasladoRemitidoAutomatico(){
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        EmailTemplate plantilla = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'OS_TrasColab_Automatico'];

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta;       

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
        
        List<Contact> listContacto = new List<Contact>();
        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Contact contacto1 = new Contact();
        contacto1.RecordTypeId = recordTypeContacto;
        contacto1.Email = 'servicio.factoring@caixabank.com';
        contacto1.LastName = 'Pruebas1';
        contacto1.AccountId = cuenta.Id;
        listContacto.add(contacto1);
		
		Contact contacto2 = new Contact();
        contacto2.RecordTypeId = recordTypeContacto;
        contacto2.Email = 'servicio.bastanteo@caixabank.com';
        contacto2.LastName = 'Pruebas2';
        contacto2.AccountId = cuenta.Id;
        listContacto.add(contacto2);
        insert listContacto;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
                
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
 
        CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaborador.name='Servicio bastanteo';
        grupoColaborador.OS_Negocio__c = 'COPS';
        grupoColaborador.OwnerId = usuarioOperador.Id;
        insert grupoColaborador;
        
        List<CC_Grupo_Colaborador_Contact__c> listcolaborador = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c colaborador1 = new CC_Grupo_Colaborador_Contact__c();
        colaborador1.CC_Contacto__c = contacto1.Id;
        colaborador1.CC_Grupo_Colaborador__c=grupoColaborador.Id;
        colaborador1.CC_Para_CC__c = 'Para';
        listcolaborador.add(colaborador1);

        CC_Grupo_Colaborador_Contact__c colaborador2 = new CC_Grupo_Colaborador_Contact__c();
        colaborador2.CC_Contacto__c = contacto2.Id;
        colaborador2.CC_Grupo_Colaborador__c=grupoColaborador.Id;
        colaborador2.CC_Para_CC__c = 'CC';
        listcolaborador.add(colaborador2);    
		insert listcolaborador;        
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'KYC Renewal';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.OS_Departamento__c = 'UAFE';
        mccTematica.OS_Buzon_Salida__c = [SELECT DISPLAYNAME FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón KYC Renewal' LIMIT 1].DISPLAYNAME;
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'producto de prueba';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'motivo de prueba';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_Buzon_Salida__c = [SELECT Address FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón KYC Renewal' LIMIT 1].Address;
        caso.OwnerId = usuarioOperador.Id;
        insert caso;

        Map<Id,Id> idMotivoGrup = new Map<Id,Id>();


        CC_MCC_Grupo_Colaborador__c grupoColaboradorMCC = new CC_MCC_Grupo_Colaborador__c();

        grupoColaboradorMCC.CC_MCC__c = mccMotivo.Id;

        grupoColaboradorMCC.CC_Grupo_Colaborador__c = grupoColaborador.Id;

        grupoColaboradorMCC.Name = 'Grupo Colaborador MCC';

        insert grupoColaboradorMCC;

        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(

            CC_MCC__c = mccMotivo.Id,

            CC_MCC_Plantilla_Name__c = plantilla.Name,

            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName

        );

        insert mccPlantilla;

        Task actividadCorreo = new Task();
        actividadCorreo.WhatId = caso.Id;
        insert actividadCorreo;
        
        String fromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;

        EmailMessage msgEmail = new EmailMessage();
        msgEmail.ParentId = caso.Id;
        msgEmail.ActivityId = actividadCorreo.Id;
        msgEmail.CC_Grupo_Colab__c = 'Grupo';
        msgEmail.ToAddress = 'to@test.com';
        msgEmail.FromAddress = fromAddress;
        msgEmail.Subject = 'Correo Test';
        msgEmail.HtmlBody = 'Correo Test\n#@' + CC_EmailMessage.generarReferenciaCorreoSaliente() + '#\nFin';
        insert msgEmail;

        //ADJUNTOS
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
        
        insert listCVs;   
        
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink contentDoc = new ContentDocumentLink();
        contentDoc.LinkedEntityId = caso.Id;
        contentDoc.ContentDocumentId = testcontent.ContentDocumentId;
        insert contentDoc;

        Set<Id> idCaso = new Set<Id>();
        idCaso.add(caso.Id);

        Set<Id> idMcc = new Set<Id>();
        idMcc.add(mccMotivo.Id);

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Case.envioCorreoTrasladoRemitidoAutomatico(idCaso,idMcc);  
            insert contacto; 
            Test.stopTest();

            Case updateCaso = [SELECT Id, CC_Ultima_Interaccion__c FROM Case WHERE Subject = 'Prueba reapertura' LIMIT 1];

            System.assertEquals('Traslado pendiente', updateCaso.CC_Ultima_Interaccion__c, 'Los campos no coinciden');
        }
    }
    
}