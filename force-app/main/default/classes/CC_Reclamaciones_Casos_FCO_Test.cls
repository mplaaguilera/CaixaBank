@isTest
public with sharing class CC_Reclamaciones_Casos_FCO_Test {
    @TestSetup
    static void makeData() {
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank_Empleados'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        PermissionSet psOperadorEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();
        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();

        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        userList.add(usuarioAdmin);

        User operadorEmpleado = new User();
        operadorEmpleado.profileId = profileId;
        operadorEmpleado.UserRoleId = roleCC;
        operadorEmpleado.AV_ExternalID__c = 'U0124112';
        operadorEmpleado.FirstName = 'Operador';
        operadorEmpleado.LastName = 'Operador Empleado';
        operadorEmpleado.Email = 'tuser000@amamama.com';
        operadorEmpleado.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        operadorEmpleado.CompanyName = 'MST';
        operadorEmpleado.Title = 'title';
        operadorEmpleado.Alias = 'alias';
        operadorEmpleado.TimeZoneSidKey = 'Europe/Paris';
        operadorEmpleado.EmailEncodingKey = 'UTF-8';
        operadorEmpleado.LanguageLocaleKey = 'es';
        operadorEmpleado.LocaleSidKey = 'es_ES';
        userList.add(operadorEmpleado);
        insert userList;

        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = psOperadorEmpleado.Id);
        insertPSAssOperadores.add(psaOperadorCliente);

        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);

        Database.insert(insertPSAssOperadores);

        System.runAs(usuarioAdmin) {
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
            Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');

            CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
            );
            insert tematica;
            mccCreado.add(tematica);

            CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
            );        
            insert producto;
            mccCreado.add(producto);
            
            CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
            );
            insert motivo;
            mccCreado.add(motivo);
            
            CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001',
            CC_Desviacion_Media_LV__c = 0,
            CC_Desviacion_Media_SD__c = 0
            );
            insert causa;
            mccCreado.add(causa);

            for(CC_MCC__c record : mccCreado) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operadorEmpleado.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            Case caso = new Case();
            caso.Subject = 'Caso batch';
            caso.Origin = 'Email';
            caso.Status = 'Cerrado';
            caso.CC_Idioma__c = 'es';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.CC_Referencia_Correo_Saliente__c = 'referenciaCaso';
            caso.RecordTypeId = recordTypeCaso;
            insert caso;
		            
            CaseShare caseShare = new CaseShare();
            caseShare.CaseId = caso.Id;
            caseShare.UserOrGroupId = operadorEmpleado.Id;
            caseShare.CaseAccessLevel = 'Edit';
            insert caseShare;

            CC_Settings__c setting = new CC_Settings__c();
            setting.Name = 'CC_FormularioConsultasOperativas';
            setting.CC_Configuracion_1__c = '1';
            insert setting;
            
            Map <String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
            for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                owasMap.put(String.valueOf(owa.Address), owa);
            }
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
          
            String plantilla = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_ConsultasOperativasCanalFormulario_Gestionado_CAS_BOT' LIMIT 1].HtmlValue;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{'test@test.com','test2@test.com'});
            email.setSubject('test');
            email.setPlainTextBody('referenciaCaso');
            email.setWhatId(caso.Id);
            email.setOrgWideEmailAddressId(owasMap.get(emailCorreoEntrante)?.Id);
            email.setHtmlBody(plantilla);
            Messaging.sendEmail(new List<Messaging.Email>{email});			

            // Create an EmailMessage to simulate an email sent through operativas button. 
            EmailMessage emailMsg = new EmailMessage();
            emailMsg.FromName = 'Test Sender';
            emailMsg.ToAddress = 'test@test.com;test2@test.com';
            emailMsg.FromAddress = owaPorDefecto[0].CC_Direccion_Correo__c;
            emailMsg.Subject = 'Test Email Subject';
            emailMsg.HtmlBody = '<h1>This is a test email body.</h1>';
            emailMsg.TextBody = 'This is the plain text email body.';
            emailMsg.MessageDate = DateTime.now();
            emailMsg.Status = '3'; 
            emailMsg.Incoming = false; 
            emailMsg.ParentId = caso.Id; 
            emailMsg.CC_Plantilla__c = 'TestPlantilla'; 
            insert emailMsg;
        }
    }

    @isTest
    public static void executeBatchTest() {
    
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Operador Empleado' LIMIT 1].Id)) {
            //Comprobacion incial previa a la ejecución
            Case casoAct = [
                    SELECT CC_Reclamacion_FCO__c 
                    FROM Case
                    WHERE RecordType.DeveloperName = 'CC_Empleado'
                    ORDER BY CreatedDate
                    LIMIT 1
                ];
            System.assertEquals(false, casoAct.CC_Reclamacion_FCO__c, 'No incializado correctamente');
            //Ejecucion del batch en contexto de test para asegurar que termine de forma sincrona a las siguientes instrucciones
            Test.startTest(); 
                //forzar el now a 5 horas adelante
                CBK_UtilsDate.nowSystem = Datetime.now().addHours(5);
                CC_Reclamaciones_Casos_FCO batch = new CC_Reclamaciones_Casos_FCO();
                batch.templateName = 'TestPlantilla';
                //ejecutar batch
                Database.executeBatch(batch);               
            Test.stopTest();
            //Comprobacion final de que efectivamente se ha realizado el cambio
            Case casoActAfter = [
                    SELECT CC_Reclamacion_FCO__c 
                    FROM Case
                    WHERE RecordType.DeveloperName = 'CC_Empleado'
                    ORDER BY CreatedDate
                    LIMIT 1
            ];
            System.assertEquals(true, casoActAfter.CC_Reclamacion_FCO__c, 'Error en el batch');
        }
        
    }
}