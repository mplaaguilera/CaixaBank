@isTest
private class HDT_EmailMessage_AI_TRHan_Test {
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Account cuenta1 = new Account();
        cuenta1.Name = 'Cuenta01';
        cuenta1.recordtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta1;  

        Account cuenta2 = new Account(); 
        cuenta2.Name = 'Cuenta02';
        cuenta2.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta2;

        List<AccountShare> totalPermisos = new List<AccountShare>();
        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta1.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = cuenta2.Id;
        acshare2.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        totalPermisos.add(acshare2);
        insert totalPermisos;

        List<String> developerNamesPlantillas = new List<String>{'CC_ConsultasOperativasCanalFormulario_Traslado_CAT','CC_ConsultasOperativasCanalFormulario_Traslado_CAS'};
        List<EmailTemplate> plantillas = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName IN :developerNamesPlantillas];
        List<EmailTemplate> plantillasAInsertar = new List<EmailTemplate>();
        if (plantillas.isEmpty()) {

            EmailTemplate plantilla1CAS= new EmailTemplate();
            plantilla1CAS.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.HTMLValue= 'hola prueba 2';
            plantilla1CAS.Subject = 'plantilla1CAS';
            plantilla1CAS.FolderId = UserInfo.getUserId();
            plantilla1CAS.TemplateType = 'Text';
            plantilla1CAS.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAS);


            EmailTemplate plantilla1CAT= new EmailTemplate();
            plantilla1CAT.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.HTMLValue= 'hola prueba 2';
            plantilla1CAT.Subject = 'plantilla1CAT';
            plantilla1CAT.FolderId = UserInfo.getUserId();
            plantilla1CAT.TemplateType = 'Text';
            plantilla1CAT.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAT);

        insert plantillasAInsertar;
            
        }

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;

    }


    @isTest
    public static void trasladoColaboradorSaliente() {       
        System.runAs(new User(Id = UserInfo.getUserId())) {

            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;


            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            caso.CC_Referencia_Correo_Saliente__c = '#@1234567890#';
            insert caso;

            

                Test.startTest();


                Task actividadCorreo = new Task();
                actividadCorreo.Type = 'Traslado Colaborador';
                actividadCorreo.WhatId = caso.Id;
                actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
                actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
                insert actividadCorreo;

                EmailMessage correo = new EmailMessage();
                correo.Subject = 'Prueba de envío de correo';
                correo.ActivityId = actividadCorreo.Id;
                correo.CC_Grupo_Colab__c = grupoColab.Name;
                correo.CC_Procedencia__c = 'Traslado Colaborador';
                correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
                correo.ToAddress = 'prueba@ibm.com';
                correo.Incoming = false;
                correo.ParentId = caso.Id;
                correo.RelatedToId = caso.Id;
                //correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

                List<String> cuerpo = new List<String>();
                cuerpo.add('<html>');
                cuerpo.add('Cuerpo del correo');
                cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
                cuerpo.add('</html>');
                correo.HtmlBody = String.join(cuerpo, '<br/>');
                insert correo;



                Test.stopTest();

                System.assert(correo.Id != null);
        }
    }

    @isTest
    public static void trasladoColaboradorEntrante() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
        
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            caso.CC_En_Tercer_Nivel__c = true;
            caso.CC_Grupo_3N__c = '3N de CaixaBank Now';
            insert caso;

            //Correo origen crear las dos task en una lista
            List<Task> tareas = new List<Task>();
            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Traslado Colaborador';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            tareas.add(actividadCorreoOrigen);

            Task reasignacion = new Task();
            reasignacion.Type = 'Reasignación';
            reasignacion.WhatId = caso.Id;
            reasignacion.Status = 'Completed';
            reasignacion.Subject = 'Reasignación del caso a 3N de CaixaBank Now';
            reasignacion.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            tareas.add(reasignacion);
            insert tareas;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = false;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;


            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen;

           
                Test.startTest();

                Task actividadCorreo = new Task();
                insert actividadCorreo;

                EmailMessage correo = new EmailMessage();
                correo.Status = '1';
                correo.Subject = 'Prueba de envío de correo';
                correo.ActivityId = actividadCorreo.Id;
                correo.CC_Grupo_Colab__c = grupoColab.Name;
                correo.CC_Procedencia__c = 'Traslado Colaborador';
                correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
                correo.ToAddress = 'prueba@ibm.com';
                correo.Incoming = true;
                correo.ParentId = caso.Id;
                correo.RelatedToId = caso.Id;
                correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

                List<String> cuerpo = new List<String>();
                cuerpo.add('<html>');
                cuerpo.add('Cuerpo del correo');
                cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
                cuerpo.add('</html>');
                correo.HtmlBody = String.join(cuerpo, '<br/>');
                insert correo;

                Test.stopTest();

                System.assert(correo.Id != null);
        }
        
    }

    @isTest
    public static void trasladoColaboradorEntranteCasoNoIndra() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Case caso = new Case();
            caso.Subject = 'Caso temporal';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Atención al cliente';
            caso.CC_Canal_Resolucion__c = 'Atención al Cliente';
            caso.CC_Cola_Procedencia__c = 'CC_Inbound_Email_AC';
            caso.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            insert caso;

            caso.Status = 'Pendiente Colaborador';
            update caso;

            //Correo origen
            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Traslado Colaborador';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = false;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;


            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen;

            
                Test.startTest();

                Task actividadCorreo = new Task();
                insert actividadCorreo;

                EmailMessage correo = new EmailMessage();
                correo.Status = '1';
                correo.Subject = 'Prueba de envío de correo';
                correo.ActivityId = actividadCorreo.Id;
                correo.CC_Grupo_Colab__c = grupoColab.Name;
                correo.CC_Procedencia__c = 'Traslado Colaborador';
                correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
                correo.ToAddress = 'prueba@ibm.com';
                correo.Incoming = true;
                correo.ParentId = caso.Id;
                correo.RelatedToId = caso.Id;
                correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';


                List<String> cuerpo = new List<String>();
                cuerpo.add('<html>');
                cuerpo.add('Cuerpo del correo');
                cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
                cuerpo.add('</html>');
                correo.HtmlBody = String.join(cuerpo, '<br/>');
                insert correo;

                Test.stopTest();

                System.assert(correo.Id != null);
            
        }
    }

    @isTest
    public static void remitirColaboradorSaliente() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Remitir Colaborador';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;


            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Remitir Colaborador';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = false;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();

                System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            
        }
    }

    @isTest
    public static void responderClienteSalienteTest() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Responder Cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = null;
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;


            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = false;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();


                System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            
        }
    }

    @isTest
    public static void remitirColaboradorEntrante() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Remitir Colaborador';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Remitir Colaborador';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';


            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();

                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            }
        }
    }

    @isTest
    public static void solicitudInformacionSaliente() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.Name = 'Plazo Genérico';
            lista.CC_Valor__c = '1';
            insert lista;

            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.RecordTypeId = recordTypeCaso;
            caso.Subject = 'Caso temporal';
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Solicitud Información';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;

            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Solicitud Informacion';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';


            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

            
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();

                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
        }
    }

    @isTest
    public static void solicitudInformacionEntrante() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
        
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.Name = 'Plazo Genérico';
            lista.CC_Valor__c = '1';
            insert lista;

            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Subject = 'Caso temporal';
            caso.Status = 'Pendiente Cliente';
            caso.CC_En_Tercer_Nivel__c = true;
            caso.CC_Grupo_3N__c = '3N de CaixaBank Now';
            caso.CC_Inicio_Pendiente_Cliente__c = System.now();
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreoOrigen.Type = 'Solicitud Información';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';

            Task reasignacion = new Task();
            reasignacion.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            reasignacion.Type = 'Reasignación';
            reasignacion.WhatId = caso.Id;
            reasignacion.Status = 'Completed';
            reasignacion.Subject = 'Reasignación del caso a 3N de CaixaBank Now';

            insert new List<Task>{actividadCorreoOrigen, reasignacion};

            List<EmailServicesAddress> emailServicesList = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress
                                                            WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue = new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue = emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Solicitud Información';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

            List<String> cuerpoOrigen = new List<String>{
                '<html>',
                'Cuerpo del correo',
                '<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>',
                '</html>'
            };
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');     
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();

                //System.assertEquals(3, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
        }
    }


    @isTest
    public static void  respuestaCliente() {

        System.runAs(new User(Id = UserInfo.getUserId())) {

            List<Case> casos = new List<Case>();

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso temporal';
            caso.Status = 'Cerrado';
            caso.RecordTypeId = recordTypeCaso;
            insert caso;

            Casos.add(caso);

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Responder a cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
           
                Test.startTest();
                HDT_EmailMessage_AI_TRHan.respuestaCliente(correoOrigen, casos);
                insert correoOrigen;
                Test.stopTest();

                //System.assertEquals(3, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            
        }
    }

    @isTest
    public static void  respuestaEmpleadoForm() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
            List<CC_Lista_Valores__c> val = new List <CC_Lista_Valores__c>();

            CC_Lista_Valores__c respuestaEmp = new CC_Lista_Valores__c();
            respuestaEmp.Name = 'CC_Respuesta_a_empleado_form';
            respuestaEmp.CC_Activa__c = true;
            respuestaEmp.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            lista.add(respuestaEmp);
            insert lista;

            CC_Lista_Valores__c val1 = new CC_Lista_Valores__c();
            val1.Name = 'Activo';
            val1.CC_Activa__c = true;
            val1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            val1.CC_Lista__c = respuestaEmp.Id;
            val1.CC_Valor_SFDC__c = 'CC_Cons_Form_Activo';
            val.add(val1);
            insert val;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso temporal';
            caso.Status = 'Cerrado';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'Activo';
            caso.Origin = 'Email';
            insert caso;

            caso.CC_Canal_Resolucion__c = 'Activo';
            Database.update(caso);

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Responder a cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'].CC_Direccion_Correo__c;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();
                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            }
        }
    }
    @isTest
    public static void  respuestaEmpleadoChat() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
            List<CC_Lista_Valores__c> val = new List <CC_Lista_Valores__c>();

            CC_Lista_Valores__c respuestaEmp = new CC_Lista_Valores__c();
            respuestaEmp.Name = 'CC_Respuesta_a_empleado';
            respuestaEmp.CC_Activa__c = true;
            respuestaEmp.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            lista.add(respuestaEmp);
            insert lista;

            CC_Lista_Valores__c val1 = new CC_Lista_Valores__c();
            val1.Name = 'Activo';
            val1.CC_Activa__c = true;
            val1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            val1.CC_Lista__c = respuestaEmp.Id;
            val1.CC_Valor_SFDC__c = 'CC_Cons_Form_Activo';
            val.add(val1);
            insert val;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso temporal';
            caso.Status = 'Cerrado';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Canal_Procedencia__c = 'Activo';
            caso.CC_Canal_Resolucion__c = 'Activo';
            caso.Origin = 'Chat';
            insert caso;

            caso.CC_Canal_Resolucion__c = 'Activo';
            Database.update(caso);

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Responder a cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'].CC_Direccion_Correo__c;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

           
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();
                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            
        }
    }

   
    @isTest
    public static void  respuestaAccionista() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso temporal';
            caso.Status = 'Cerrado';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Canal_Procedencia__c = 'Accionista';
            caso.CC_Canal_Resolucion__c = 'Activo';
            caso.Origin = 'Email';
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Responder a cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            insert actividadCorreoOrigen;
            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE '%HDT_Email%' LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }
            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = 'hola';
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();

                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
            
        }
    }
    @isTest
    public static void  respuestaClienteCSIBankia() {

        System.runAs(new User(Id = UserInfo.getUserId())) {

            OrgWideEmailAddress fromEmail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia' LIMIT 1];
            fromEmail.Address = 'prueba@ibm.com';


            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'CCO CSI';
            caso.Subject = 'Caso temporal';
            caso.Status = 'Cerrado';
            caso.RecordTypeId = recordTypeCaso;
            caso.Origin = 'Email';
            insert caso;

            Id recordTypeTarea = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.RecordTypeId = recordTypeTarea;
            actividadCorreoOrigen.Type = 'Responder a cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreoOrigen;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'HDT_EmailService') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;
            } else {
                headerValueStr = 'Prueba@IBM';
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Default_CSI_Bankia_ESP'].CC_Direccion_Correo__c;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

            
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();

                List<EmailMessage> emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id];
                //  System.AssertEquals(2, emailList.size());
                emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id AND FromAddress =: fromEmail.Address];

                System.AssertEquals(1, emailList.size());
            
        }
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoEsCli() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.Email ='jorge.andres.argente.guillen@ibm.com';
            contacto.RecordTypeId = recordTypeCliente;
            insert contacto;
            Id cId = contacto.Id;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';
            caso.Subject = 'Caso temporal';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'es';
            caso.Origin = 'Email';
            caso.CC_Canal_Resolucion__c = 'Postventa CompraEstrella';
            caso.ContactId = cId;

            insert caso;

            Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;



            EmailMessage correo = new EmailMessage();
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correo.ToAddress = 'pruebatraslado@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;


            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');


                Test.startTest();
                insert correo;
                Test.stopTest();

                Case casoId = [SELECT Id FROM Case LIMIT 1];
                List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
                System.AssertEquals(2, cantidadDeEmails.size());

        }
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoEsEmp() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.Email ='jorge.andres.argente.guillen@ibm.com';
            contacto.RecordTypeId = recordTypeCliente;
            insert contacto;
            Id cId = contacto.Id;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';
            caso.Subject = 'Caso temporal';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'es';
            caso.Origin = 'Email';
            caso.CC_Canal_Resolucion__c = 'Soporte Empleados CompraEstrella';
            caso.ContactId = cId;

            insert caso;

            Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;



            EmailMessage correo = new EmailMessage();
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correo.ToAddress = 'pruebatraslado@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;


            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');

                Test.startTest();
                insert correo;
                Test.stopTest();

                Case casoId = [SELECT Id FROM Case LIMIT 1];
                List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
                System.AssertEquals(2, cantidadDeEmails.size());
        }
    }

    /*@isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoCaCli() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.Email ='jorge.andres.argente.guillen@ibm.com';
            contacto.RecordTypeId = recordTypeCliente;
            insert contacto;
            Id cId = contacto.Id;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';
            caso.Subject = 'Caso temporal';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'ca';
            caso.Origin = 'Email';
            caso.CC_Canal_Resolucion__c = 'Postventa CompraEstrella';
            caso.ContactId = cId;

            insert caso;

            Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;



            EmailMessage correo = new EmailMessage();
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c;
            correo.ToAddress = 'pruebatraslado@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;


            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');

            System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()){
                Test.startTest();
                insert correo;
                Test.stopTest();

                Case casoId = [SELECT Id FROM Case LIMIT 1];
                List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
                System.AssertEquals(2, cantidadDeEmails.size());
            }
        }
    }*/

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoCaEmp() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.Email ='jorge.andres.argente.guillen@ibm.com';
            contacto.RecordTypeId = recordTypeCliente;
            insert contacto;
            Id cId = contacto.Id;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';
            caso.Subject = 'Caso temporal';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'ca';
            caso.Origin = 'Email';
            caso.CC_Canal_Resolucion__c = 'Soporte Empleados CompraEstrella';
            caso.ContactId = cId;

            insert caso;

            Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;



            EmailMessage correo = new EmailMessage();
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correo.ToAddress = 'pruebatraslado@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;


            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');

                Test.startTest();
                insert correo;
                Test.stopTest();

                Case casoId = [SELECT Id FROM Case LIMIT 1];
                List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
                System.AssertEquals(2, cantidadDeEmails.size());
        }
    }
    @isTest
    public static void trasladoColaboradorCorreoAutoFormularioConsultasOperativas() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;

            Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.Email ='test@test.com';
            contacto.RecordTypeId = recordTypeEmpleado;
            insert contacto;

            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.Subject = 'Caso Formulario Consultas Operativas';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'es';
            caso.Origin = 'Email';
            caso.CC_MailTelfNotif__c ='test@test.com';
            caso.CC_Canal_Resolucion__c = 'Activo';
            caso.ContactId = contacto.Id;
            insert caso;

            Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;



            EmailMessage correo = new EmailMessage();
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correo.ToAddress = 'pruebatraslado@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;


            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');

            
                Test.startTest();
                insert correo;
                Test.stopTest();

                System.assertEquals(2, [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id].size());
            
        }

    }

    @IsTest
    static void testEnvioSolicitudInfo() {
        // Crear datos de prueba
       

        System.runAs(new User(Id = UserInfo.getUserId())) {
            
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'Plazo genérico empleados';
        lista.CC_Valor__c = '48';
        insert lista;


             Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.Email ='test@test.com';
            contacto.RecordTypeId = recordTypeEmpleado;
            insert contacto;

            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;   

        List<Case> casos = new List<Case>();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Incidencias Técnicas';
            caso.Subject = 'Caso Formulario Consultas Operativas';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'es';
            caso.Origin = 'Chat';
            caso.CC_MailTelfNotif__c ='test@test.com';
            caso.CC_Canal_Resolucion__c = 'Incidencias Técnicas';
            caso.ContactId = contacto.Id;
            insert caso;

        casos.add(caso);

        List<Task> actividadesTraslado = new List<Task>();
        Task actividadCorreo = new Task();
            actividadCorreo.Type = 'Traslado Colaborador';
            actividadCorreo.WhatId = caso.Id;
            actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreo;
        
            actividadesTraslado.add(actividadCorreo);

            EmailMessage correo = new EmailMessage();
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Solicitud Informacion';
            correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'HDT_Buzon'].CC_Direccion_Correo__c;
            correo.ToAddress = 'prueba@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.TextBody = 'EMAILENTRADA';
            correo.RelatedToId = caso.Id;
            insert correo;

        // Realizar la llamada a la función
        
        HDT_EmailMessage_AI_TRHan.envioSolicitudInfo(correo, casos, actividadesTraslado);
        

        // Realizar las afirmaciones (assertions) para verificar el resultado
        // Asegurarse de que la función haya realizado los cambios esperados
        // y que los datos se hayan guardado correctamente en Salesforce
        // Por ejemplo:
        System.assertEquals('Activo', casos[0].Status);
        //System.assertEquals(/* valor esperado */, casos[0].CC_Fecha_Cierre_SolInf__c);
        // ...

        // Asegurarse de que se haya agregado la actividad de traslado
        System.assertEquals(2, actividadesTraslado.size());
        //System.assertEquals(/* valor esperado */, actividadesTraslado[0].Type);
        //System.assertEquals(/* valor esperado */, actividadesTraslado[0].Subject);
        // ...

        // Asegurarse de que se haya llamado al método CC_Trazabilidad_Methods.altaAviso
        // y verificar los parámetros pasados al método
        // Por ejemplo:
        // System.assertEquals(/* valor esperado */, parámetro1);
        // System.assertEquals(/* valor esperado */, parámetro2);
        // ...
        }
    }

    @isTest
    static void testEnviarCorreoAutomaticoTrasladoFormularioConsultasOperativas() {
        System.runAs(new User(Id = UserInfo.getUserId())){
            // Crear datos de prueba necesarios
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.Email ='test@test.com';
        contacto.RecordTypeId = recordTypeEmpleado;
        insert contacto;


            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
           
            Case caso = new Case();
            caso.CC_Canal_Procedencia__c = 'Incidencias Técnicas';
            caso.Subject = 'Caso Formulario Consultas Operativas';
            caso.Status = 'Activo';
            caso.RecordTypeId = recordTypeCaso;
            caso.CC_Idioma__c = 'es';
            caso.Origin = 'Chat';
            caso.CC_MailTelfNotif__c ='test@test.com';
            caso.CC_Canal_Resolucion__c = 'Incidencias Técnicas';
            caso.ContactId = contacto.Id;
            insert caso;
        
        // Realizar la llamada al método que se va a probar
        Test.startTest();
        HDT_EmailMessage_AI_TRHan.enviarCorreoAutomaticoTrasladoFormularioConsultasOperativas(caso);
        Test.stopTest();
        
        // Verificar los resultados
        // Aquí puedes incluir aserciones para verificar si se enviaron los correos correctamente
        // También puedes verificar si se generaron registros de actividad u otros efectos esperados
        
        // Ejemplo de aserción
        Integer expectedEmailCount = 0; // Cantidad esperada de correos enviados
        Integer actualEmailCount = [SELECT COUNT() FROM EmailMessage]; // Consulta para obtener la cantidad real de correos enviados
        //System.assertEquals(expectedEmailCount, actualEmailCount, 'La cantidad de correos enviados no coincide');
        
        // Puedes agregar más aserciones según las necesidades de tu caso de prueba
        }
        
    }

    @isTest
    public static void respuestaCliente1() {

        System.runAs(new User(Id = UserInfo.getUserId())){
            User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

            List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'HDT_%'];

            Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta01' LIMIT 1];     
            
            Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
            
            Contact contacto = new Contact();
            contacto.FirstName = 'Contacto';
            contacto.LastName = '01';
            contacto.CC_NumPerso__c = '12345569';
            contacto.AccountId = cuenta.Id;
            contacto.CC_Idioma__c = 'Es';
            contacto.RecordTypeId = recordTypeCliente;
            insert contacto;
            
            Id cId = contacto.Id;
            
            List<Case> Casos = new   List<Case>();

            Case oCaso = new Case();
            oCaso.Subject = 'Test Incidencia';
            oCaso.Origin = 'Chat';
            oCaso.Status = 'Pendiente Colaborador';
            oCaso.ContactId = cId;
            oCaso.CC_NotIncidencia__c = '1';
            oCaso.CC_MailTelfNotif__c = 'test@test.es';
            oCaso.CC_CanalNotifCli__c = 'Email';
            oCaso.CC_Idioma__c = 'es';
            oCaso.CC_Canal_Procedencia__c = 'Incidencias Técnicas';
            oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
            oCaso.CC_Cola_Procedencia__c = 'OS_Servicio_Firma';
            oCaso.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            insert oCaso;

            Case oCaso2 = new Case();
            oCaso2.Subject = 'Test Incidencia Prueba2';
            oCaso2.Origin = 'Chat';
            oCaso2.Status = 'Pendiente Alerta';
            oCaso2.ContactId = cId;
            oCaso2.CC_NotIncidencia__c = '1';
            oCaso2.CC_MailTelfNotif__c = 'test@test.es';
            oCaso2.CC_CanalNotifCli__c = 'Email';
            oCaso2.CC_Idioma__c = 'es';
            oCaso2.CC_Canal_Procedencia__c = 'Incidencias Técnicas';
            oCaso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso2.CC_Detalles_Solucion__c = 'Detalles Solución';
            oCaso2.OS_Alerta_Fecha__c = System.now();
            oCaso2.RecordTypeId  = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            insert oCaso2;
            
            Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Ahorro a la vista';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
            mccTematica.OS_Departamento__c = 'UAC';
            mccTematica.CC_Canal_Operativo__c = 'Sin canal';
            insert mccTematica;
            
            List<BusinessHours> bhs = [select id from BusinessHours where IsDefault=true];
            
            Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Cuenta corriente';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
            mccProducto.OS_Horario__c = bhs.get(0).Id;
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

            oCaso2.CC_MCC_Tematica__c = mccTematica.Id;
            oCaso2.CC_MCC_ProdServ__c = mccProducto.Id;
            oCaso2.CC_MCC_Motivo__c = mccMotivo.Id;
            update oCaso2;
            
            Casos.add(oCaso);
            Casos.add(oCaso2);
            

            //Actividad de solicitud de información
            Task actividadResponderCliente = new Task();
            actividadResponderCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            actividadResponderCliente.WhatId = oCaso.Id;
            actividadResponderCliente.Type = 'Remitir Colaborador';
            actividadResponderCliente.Subject = 'Remitir Colaborador';
            actividadResponderCliente.Status = 'Completed';
            actividadResponderCliente.CC_Referencia_Correo_Saliente__c = 'refRemitir';
            insert actividadResponderCliente;

            Task actividadResponderCliente2 = new Task();
            actividadResponderCliente2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            actividadResponderCliente2.WhatId = oCaso2.Id;
            actividadResponderCliente2.Type = 'Remitir Colaborador';
            actividadResponderCliente2.Subject = 'Remitir Colaborador';
            actividadResponderCliente2.Status = 'Completed';
            actividadResponderCliente2.CC_Referencia_Correo_Saliente__c = 'refRemitir';
            insert actividadResponderCliente2;
            
            // create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            env.fromAddress = 'ac@email.com';
            env.toAddress = 'ac@email.com';
            
            // setup the data for the email
            email.subject = 'Create Contact';
            email.fromAddress = 'ac@email.com';
            email.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
            email.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
            
            // add an Binary attachment
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            // add an Text atatchment
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

            // create a new email and envelope object
            Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
            env2.fromAddress = 'ac@email.com';
            env2.toAddress = 'ac@email.com';
            
            // setup the data for the email
            email2.subject = 'Create Contact';
            email2.fromAddress = 'ac@email.com';
            email2.plainTextBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
            email2.htmlBody = 'Hola\n#@refRemitir#\nAdios\n#@2019120425226698#';
            
            // add an Binary attachment
            Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
            attachment2.body = blob.valueOf('my attachment text');
            attachment2.fileName = 'textfileone.txt';
            attachment2.mimeTypeSubType = 'text/plain';
            email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment2 };
            
            // add an Text atatchment
            Messaging.InboundEmail.TextAttachment attachmenttext2 = new Messaging.InboundEmail.TextAttachment();
            attachmenttext2.body = 'my attachment text';
            attachmenttext2.fileName = 'textfiletwo3.txt';
            attachmenttext2.mimeTypeSubType = 'texttwo/plain';
            email2.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext2 };
            
        
                Test.startTest();
            // HDT_EmailMessage_AI_TRHan.respuestaCliente(email, Casos);

                //HDT_EmailMessage_AI_TRHan.respuestaCliente(email, actividadResponderCliente.WhatId,'','', colasTotalesCOPS, oCaso);
                //HDT_EmailMessage_AI_TRHan.respuestaCliente(email2, actividadResponderCliente2.WhatId,'','', colasTotalesCOPS, oCaso2);
                Test.stopTest();
                
                Case updatedCase = [SELECT Id,CC_Ultima_Interaccion__c FROM Case Where Id =: oCaso.Id];
                Case updatedCase2 = [SELECT Id,Status FROM Case Where Id =: oCaso2.Id];

                System.assertEquals('Nuevo', updatedCase.CC_Ultima_Interaccion__c, 'Comprobamos la última interacción ha sido una respuesta a cliente.');
                System.assertEquals('Pendiente Alerta', updatedCase2.Status, 'Estatus cambiado incorrectamente');   
        }     
        
    }
}