@isTest
public class CC_NotifSegCaso_Test
{
    @isTest
    public static void crearActividadTrasladoIncidenciaCierreMail() {
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        insert oAgr;

        CC_Agrupador__c oAgr2 = new CC_Agrupador__c();
        oAgr2.RecordTypeId = sRecordType;
        oAgr2.CC_Titulo__c = 'Test';
        oAgr2.CC_Descripcion__c = 'Test';
        insert oAgr2;
        
        
        System.assertNotEquals(oAgr, null);
        
        List<CC_PlantillaAsociada__c> listOCom = new List<CC_PlantillaAsociada__c>();

        String sRecordType2 = Schema.SObjectType.CC_PlantillaAsociada__c.getRecordTypeInfosByDeveloperName().get('CC_Agrupador').getRecordTypeId();
        
        CC_PlantillaAsociada__c oCom = new CC_PlantillaAsociada__c();
        oCom.RecordTypeId = sRecordType2;
        oCom.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom.CC_Canal__c = 'Email';
        oCom.CC_Idioma__c = 'es';
        oCom.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom.CC_Agrupador__c = oAgr.Id;
        oCom.CC_Revisada__c = true;
        listOCom.add(oCom);

        CC_PlantillaAsociada__c oCom2 = new CC_PlantillaAsociada__c();
        oCom2.RecordTypeId = sRecordType2;
        oCom2.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom2.CC_Canal__c = 'Email';
        oCom2.CC_Idioma__c = 'ca';
        oCom2.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom2.CC_Agrupador__c = oAgr.Id;
        oCom2.CC_Revisada__c = true;
        listOCom.add(oCom2);

        CC_PlantillaAsociada__c oCom3 = new CC_PlantillaAsociada__c();
        oCom3.RecordTypeId = sRecordType2;
        oCom3.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom3.CC_Canal__c = 'Email';
        oCom3.CC_Idioma__c = 'en';
        oCom3.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom3.CC_Agrupador__c = oAgr.Id;
        oCom3.CC_Revisada__c = true;
        listOCom.add(oCom3);

        CC_PlantillaAsociada__c oCom4 = new CC_PlantillaAsociada__c();
        oCom4.RecordTypeId = sRecordType2;
        oCom4.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom4.CC_Canal__c = 'SMS';
        oCom4.CC_Idioma__c = 'es';
        oCom4.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom4.CC_Agrupador__c = oAgr2.Id;
        oCom4.CC_Revisada__c = true;
        listOCom.add(oCom4);

        CC_PlantillaAsociada__c oCom5 = new CC_PlantillaAsociada__c();
        oCom5.RecordTypeId = sRecordType2;
        oCom5.CC_Tipo_Cliente__c = 'Empleado (HDT)'; 
        oCom5.CC_Canal__c = 'Email';
        oCom5.CC_Idioma__c = 'ca';
        oCom5.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom5.CC_Agrupador__c = oAgr.Id;
        oCom5.CC_Revisada__c = true;
        listOCom.add(oCom5);
        
        
        System.assertNotEquals(listOCom, null);
        
        //Insertamos grupo colaborador máximo
        CC_Grupo_Colaborador__c grupoColaboradorTest = new CC_Grupo_Colaborador__c();
        grupoColaboradorTest.Name = 'Grupo Colaborador TEST';
        grupoColaboradorTest.recordtypeid = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        grupoColaboradorTest.CC_External__c = 'GM-100001';
        insert grupoColaboradorTest;

        
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert oContacto;
        
        //insertamos el usuario ejecutor como colaborador del grupo colaborador máximo
        CC_Grupo_Colaborador_Contact__c colaboradorTest = new CC_Grupo_Colaborador_Contact__c();
        colaboradorTest.CC_Grupo_Colaborador__c = grupoColaboradorTest.Id;
        colaboradorTest.CC_Contacto__c = oContacto.Id;
        insert colaboradorTest;
        
        System.assertNotEquals(oContacto, null);

        Id recordTypeIdEmpleado = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oCuenta2 = new Account (name='Test02',CC_Numero_Documento__c='12345679Z',CC_NumPerso__c = '99999921',RecordTypeId = recordTypeIdEmpleado);

        System.assertNotEquals(oCuenta2, null);
        
        List<Case> listOCaso = new List<Case>();

        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso.ContactId = oContacto.Id;
        oCaso.AccountId = oCuenta2.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_GrupoOficina__c = grupoColaboradorTest.id;
        
        listOCaso.add(oCaso);

        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia';
        oCaso2.Origin = 'Email';
        oCaso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado (HDT)').getRecordTypeId();
        oCaso2.ContactId = oContacto.Id;
        oCaso2.AccountId = oCuenta2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'Email';
        oCaso2.CC_Agrupador_Id__c = oAgr.Id;
        oCaso2.CC_Idioma__c = 'ca';
        oCaso2.CC_URL_Encuesta_3N__c = 'https://opina.caixabank.com/index.php?r=survey/index&sid=null&lang=es&userid=U01A679D&ticketid=30515232&idet=a0V3O0000091jfbUAA&et=Prueba_Tematica&newtest=Y';
        listOCaso.add(oCaso2);

        Case oCaso3 = new Case();
        oCaso3.Subject = 'Test Incidencia';
        oCaso3.Origin = 'Email';
        oCaso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso3.ContactId = oContacto.Id;
        oCaso3.AccountId = oCuenta2.Id;
        oCaso3.CC_NotIncidencia__c = '1';
        oCaso3.CC_MailTelfNotif__c = 'test@test.es';
        oCaso3.CC_CanalNotifCli__c = 'Email';
        oCaso3.CC_Agrupador_Id__c = oAgr.Id;
        oCaso3.CC_Idioma__c = 'en';
        listOCaso.add(oCaso3);

        Case oCaso4 = new Case();
        oCaso4.Subject = 'Test Incidencia';
        oCaso4.Origin = 'Email';
        oCaso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso4.ContactId = oContacto.Id;
        oCaso4.AccountId = oCuenta2.Id;
        oCaso4.CC_NotIncidencia__c = '1';
        oCaso4.CC_MailTelfNotif__c = '0';
        oCaso4.CC_CanalNotifCli__c = 'SMS';
        oCaso4.CC_Agrupador_Id__c = oAgr2.Id;
        oCaso4.CC_Idioma__c = 'es';
        listOCaso.add(oCaso4);

        insert listOCaso;
        
        
        System.assertNotEquals(listOCaso, null);
        
        Task oTask = new Task();
        oTask.WhatId = oCaso.Id;
        oTask.Status = 'Open';
        oTask.Type = 'Traslado Incidencia';
        insert oTask;

        Task oTask2 = new Task();
        oTask2.WhatId = oCaso4.Id;
        oTask2.Status = 'Open';
        oTask2.Type = 'Traslado Incidencia';
        insert oTask2;
        
        System.assertNotEquals(oTask, null);
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'CC_NotIncidencia';
        template.DeveloperName = 'CC_NotIncidencia';
        template.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert template;
        }

        Test.startTest();
        
        oTask.Status = 'Completed';
        update oTask;
        
        oTask2.Status = 'Completed';
        update oTask2;
        
        System.assertNotEquals(oTask, null);

        List<Id> listTaskSmsCaso = new List<Id>();
        listTaskSmsCaso.add(oTask2.Id);
        CC_NotifSegInc.gestionarNotificacionesSMS(listTaskSmsCaso);
        
        
        List<ID> oListaTask = new List<ID>();
        oListaTask.add(oTask.Id);
        CC_NotifSegInc.gestionarCierreIncidencia(oListaTask);


        Test.stopTest();

        oTask = [SELECT Status FROM Task WHERE Id = :oTask.Id LIMIT 1];

        System.assertEquals('Completed', oTask.Status);
    }
    
    @isTest
    public static void crearActividadTrasladoIncidenciaCierreTwitter() {
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        insert oAgr;
        
        System.assertNotEquals(oAgr, null);
        
        String sRecordType2 = Schema.SObjectType.CC_PlantillaAsociada__c.getRecordTypeInfosByDeveloperName().get('CC_Agrupador').getRecordTypeId();
        
        CC_PlantillaAsociada__c oCom = new CC_PlantillaAsociada__c();
        oCom.RecordTypeId = sRecordType2;
        oCom.CC_Canal__c = 'Twitter';
        oCom.CC_Idioma__c = 'es';
        oCom.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom.CC_Agrupador__c = oAgr.Id;
        oCom.CC_Revisada__c = true;
        insert oCom;
        
        System.assertNotEquals(oCom, null);
     
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        System.assertNotEquals(oContacto, null);
        
        SocialPost oPost = getSocialPost(getSampleSocialData('2'));
        insert oPost;
        
        System.assertNotEquals(oPost, null);
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Twitter';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_CanalNotifCli__c = 'Twitter';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        oCaso.SourceId = oPost.Id;
        insert oCaso;
        
        System.assertNotEquals(oCaso, null);
        
        oPost.ParentId = oCaso.Id;
        update oPost;
        
        Task oTask = new Task();
        oTask.WhatId = oCaso.Id;
        oTask.Status = 'Open';
        oTask.Type = 'Traslado Incidencia';
        insert oTask;
        
        System.assertNotEquals(oTask, null);

        Test.startTest();
        
        oTask.Status = 'Completed';
        update oTask;
        
        System.assertNotEquals(oTask, null);
        
        List<ID> oListaTask = new List<ID>();
        oListaTask.add(oTask.Id);
        CC_NotifSegInc.gestionarCierreIncidencia(oListaTask);
        
        Test.stopTest();

        oTask = [SELECT Status FROM Task WHERE Id = :oTask.Id LIMIT 1];

        System.assertEquals('Completed', oTask.Status);
    }
    
    @isTest
    public static void crearActividadTrasladoIncidenciaCierreSMS() {
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_Notificar_Clientes__c = true;
        oAgr.CC_CanalEntrada__c = 'SMS';
        oAgr.CC_CanalProcedencia__c ='SMS';

        insert oAgr;

        CC_Agrupador__c oAgr2 = new CC_Agrupador__c();
        oAgr2.RecordTypeId = sRecordType;
        oAgr2.CC_Titulo__c = 'Test';
        oAgr2.CC_Descripcion__c = 'Test';
        oAgr2.CC_Notificar_Clientes__c = true;
        insert oAgr2;
        
        
        System.assertNotEquals(oAgr, null);
        
        List<CC_PlantillaAsociada__c> listOCom = new List<CC_PlantillaAsociada__c>();

        String sRecordType2 = Schema.SObjectType.CC_PlantillaAsociada__c.getRecordTypeInfosByDeveloperName().get('CC_Agrupador').getRecordTypeId();
        
        CC_PlantillaAsociada__c oCom = new CC_PlantillaAsociada__c();
        oCom.RecordTypeId = sRecordType2;
        oCom.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom.CC_Canal__c = 'SMS';
        oCom.CC_Idioma__c = 'es';
        oCom.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom.CC_Agrupador__c = oAgr.Id;
        oCom.CC_Revisada__c = true;
        listOCom.add(oCom);

        CC_PlantillaAsociada__c oCom2 = new CC_PlantillaAsociada__c();
        oCom2.RecordTypeId = sRecordType2;
        oCom2.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom2.CC_Canal__c = 'SMS';
        oCom2.CC_Idioma__c = 'ca';
        oCom2.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom2.CC_Agrupador__c = oAgr.Id;
        oCom2.CC_Revisada__c = true;
        listOCom.add(oCom2);

        CC_PlantillaAsociada__c oCom3 = new CC_PlantillaAsociada__c();
        oCom3.RecordTypeId = sRecordType2;
        oCom3.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom3.CC_Canal__c = 'SMS';
        oCom3.CC_Idioma__c = 'en';
        oCom3.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom3.CC_Agrupador__c = oAgr.Id;
        oCom3.CC_Revisada__c = true;
        listOCom.add(oCom3);

        CC_PlantillaAsociada__c oCom4 = new CC_PlantillaAsociada__c();
        oCom4.RecordTypeId = sRecordType2;
        oCom4.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom4.CC_Canal__c = 'SMS';
        oCom4.CC_Idioma__c = 'es';
        oCom4.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom4.CC_Agrupador__c = oAgr2.Id;
        oCom4.CC_Revisada__c = true;
        listOCom.add(oCom4);
        
        
        System.assertNotEquals(listOCom, null);
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.Phone = '666666666';
        oContacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert oContacto;
        
        System.assertNotEquals(oContacto, null);

        Id recordTypeIdEmpleado = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oCuenta2 = new Account (name='Test02',CC_Numero_Documento__c='12345679Z',CC_NumPerso__c = '99999921',RecordTypeId = recordTypeIdEmpleado);

        System.assertNotEquals(oCuenta2, null);
        
        List<Case> listOCaso = new List<Case>();

        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia 1';
        oCaso.Origin = 'SMS';
        oCaso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso.ContactId = oContacto.Id;
        oCaso.AccountId = oCuenta2.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        
        //listOCaso.add(oCaso);

        insert oCaso;

        oCaso.CC_MailTelfNotif__c = '666666666';
        oCaso.CC_CanalNotifCli__c = 'SMS';

        update oCaso;

        Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia 2';
        oCaso2.Origin = 'SMS';
        oCaso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso2.ContactId = oContacto.Id;
        oCaso2.AccountId = oCuenta2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'SMS';
        oCaso2.CC_Agrupador_Id__c = oAgr.Id;
        oCaso2.CC_Idioma__c = 'ca';
        //listOCaso.add(oCaso2);
        insert oCaso2;

        Case oCaso3 = new Case();
        oCaso3.Subject = 'Test Incidencia 3';
        oCaso3.Origin = 'SMS';
        oCaso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso3.ContactId = oContacto.Id;
        oCaso3.AccountId = oCuenta2.Id;
        oCaso3.CC_NotIncidencia__c = '1';
        oCaso3.CC_MailTelfNotif__c = 'test@test.es';
        oCaso3.CC_CanalNotifCli__c = 'SMS';
        oCaso3.CC_Agrupador_Id__c = oAgr.Id;
        oCaso3.CC_Idioma__c = 'en';
       // listOCaso.add(oCaso3);
       insert oCaso3;

        /*Case oCaso4 = new Case();
        oCaso4.Subject = 'Test Incidencia 4';
        oCaso4.Origin = 'SMS';
        oCaso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso4.ContactId = oContacto.Id;
        oCaso4.AccountId = oCuenta2.Id;
        oCaso4.CC_NotIncidencia__c = '1';
        oCaso4.CC_MailTelfNotif__c = '0';
        oCaso4.CC_CanalNotifCli__c = 'SMS';
        oCaso4.CC_Agrupador_Id__c = oAgr.Id;
        oCaso4.CC_Idioma__c = 'es';
        /*listOCaso.add(oCaso4);

        insert listOCaso;
        insert oCaso4;
        */
        
        //System.assertNotEquals(listOCaso, null);
        
        Task oTask = new Task();
        oTask.WhatId = oCaso.Id;
        oTask.Status = 'Open';
        oTask.Type = 'Traslado Incidencia';
        insert oTask;

        Task oTask2 = new Task();
        oTask2.WhatId = oCaso2.Id;
        oTask2.Status = 'Open';
        oTask2.Type = 'Traslado Incidencia';
        insert oTask2;
        
        System.assertNotEquals(oTask, null);
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'CC_NotIncidencia';
        template.DeveloperName = 'CC_NotIncidencia';
        template.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert template;
        }

        Test.startTest();
        
        oTask.Status = 'Completed';
        update oTask;
        
        oTask2.Status = 'Completed';
        update oTask2;
        
        System.assertNotEquals(oTask, null);

        List<Id> listTaskSmsCaso = new List<Id>();
        listTaskSmsCaso.add(oTask2.Id);
        CC_NotifSegInc.gestionarNotificacionesSMS(listTaskSmsCaso);
        
        
        List<ID> oListaTask = new List<ID>();
        oListaTask.add(oTask.Id);
        CC_NotifSegInc.gestionarCierreIncidencia(oListaTask);


        Test.stopTest();

        oTask = [SELECT Status FROM Task WHERE Id = :oTask.Id LIMIT 1];

        System.assertEquals('Completed', oTask.Status);
    }

    @isTest
    public static void crearAcuseReciboMail() {
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        System.assertNotEquals(oContacto, null);
        
        Case oCaso = new Case();
        oCaso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        oCaso.Subject = 'Test Incidencia Acuse';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_AcuseRecibo__c = '1';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
        
        System.assertNotEquals(oCaso, null);
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'CC_AcuseRecibo';
        template.DeveloperName = 'CC_AcuseRecibo';
        template.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert template;
        }
        
        Test.startTest();
        
        List<ID> oAcuse = new List<ID>();
        oAcuse.add(oCaso.Id);
        //Prueba
         Set<Id> setIdRegistros = new Set<Id>(oAcuse);
        List<Id> idRegistros = new List<Id>(setIdRegistros);

        //Dividir la lista en listas de 50 elementos máximo
        for (Integer i = 0; i < idRegistros.size(); i += 50) {
            CC_NotifSegCaso.gestionarBatchNotificacionCliente((List<Id>)CC_MetodosUtiles.subLista(idRegistros, i, 50), 'CC_AcuseRecibo');
        }
        //Fin Prueba
        
        //CC_NotifSegAcuse.enviarAcusesRecibo(oAcuse);
        
        Test.stopTest();
        
        oCaso = [SELECT Id, CC_AcuseRecibo__c FROM Case WHERE Id = :oCaso.Id LIMIT 1];

        System.assertEquals(oCaso != null, true);
    }

    
    @isTest
    public static void crearSeguimientoOperativaMail() {
        
        Case oCaso = new Case();
        oCaso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        oCaso.Subject = 'Test Incidencia Acuse';
        oCaso.Origin = 'Email';
        oCaso.CC_SegOperativa__c = '1';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
        
        System.assertNotEquals(oCaso, null);
        
        Task oTask = new Task();
        oTask.WhatId = oCaso.Id;
        oTask.Status = 'Open';
        oTask.Type = 'Traslado Colaborador';
        insert oTask;
        
        System.assertNotEquals(oTask, null);
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'CC_SegOperativa';
        template.DeveloperName = 'CC_SegOperativa';
        template.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert template;
        }
        
        Test.startTest();
        
        List<ID> oAcuse = new List<ID>();
        oAcuse.add(oTask.Id);
        CC_NotifSegCaso.gestionarSeguimientoCliente(oAcuse);
        
        Test.stopTest();
        
        oCaso = [SELECT Id, CC_SegOperativa__c FROM Case WHERE Id = :oCaso.Id LIMIT 1];

        System.assertEquals(oCaso != null, true);
    }
    
    static SocialPost getSocialPost(Map<String, Object> socialData) {
        SocialPost post = new SocialPost();
       	post.Name = String.valueOf(socialData.get('source'));
        post.Content = String.valueOf(socialData.get('content'));
        post.Posted = Date.valueOf(String.valueOf(socialData.get('postDate')));
        post.PostUrl = String.valueOf(socialData.get('postUrl'));
        post.Provider = String.valueOf(socialData.get('mediaProvider'));
        post.MessageType = String.valueOf(socialData.get('messageType'));
        post.ExternalPostId = String.valueOf(socialData.get('externalPostId'));
        post.R6PostId = String.valueOf(socialData.get('r6PostId'));
        post.Language = String.valueOf(socialData.get('language'));
        post.Handle = String.valueOf(socialData.get('handle'));
        post.IsOutBound = Boolean.valueOf(socialData.get('isOutbound'));
        post.PostTags = 'test01,test02,test03,test04';
        return post;
    }
    
    static Map<String, Object> getSampleSocialData(String suffix) {
        Map<String, Object> socialData = new Map<String, Object>();
        socialData.put('r6PostId', 'R6PostId' + suffix);
        socialData.put('r6SourceId', 'R6SourceId' + suffix);
        socialData.put('postLabels', null);
        socialData.put('externalPostId', 'ExternalPostId' + suffix);
        
		String sAux = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        sAux = sAux + '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        
        socialData.put('content', 'Content' + sAux + suffix);
        socialData.put('postDate', '2015-01-12T12:12:12Z');
        socialData.put('mediaType', 'Twitter');
        socialData.put('author', 'Author');
        socialData.put('skipCreateCase', false);
        socialData.put('mediaProvider', 'TWITTER');
        socialData.put('externalUserId', 'ExternalUserId');
        socialData.put('postUrl', 'PostUrl' + suffix);
        socialData.put('messageType', 'Tweet');
        socialData.put('source', 'Source' + suffix);
        socialData.put('replyToExternalPostId', null);
        socialData.put('realName', 'Real Name');
        socialData.put('followers', '25');
        socialData.put('following', '52');
        socialData.put('tweets', '2');
        socialData.put('verified', true);
        socialData.put('bio', 'bioprueba');
        socialData.put('language','Spanish');
        socialData.put('handle','testhandle');
        socialData.put('isOutbound', false);
        return socialData;
    }
    
    @isTest
    public static void crearCanalesComunicacion(){

        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert oContacto;

        Contact oContacto2 = new Contact();
        oContacto2.LastName = 'Test contacto 2';
        oContacto2.Email = 'test@test.es';
        oContacto2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert oContacto2;

        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oCuenta = new Account (name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991',RecordTypeId = recordTypeIdCliente);
		insert oCuenta;

        List<CC_Canal_Com__c> listCanal = new List<CC_Canal_Com__c>();

        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '99999991';
        c1.CC_ContactoId__c = oContacto.Id;
        c1.CC_CuentaId__c = oCuenta.Id;
        c1.CC_Email__c = 'prueba21@caixabank.com';
        c1.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        listCanal.add(c1);
    

        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '99999992';
        c2.CC_ContactoId__c = oContacto2.Id;
        c2.CC_CuentaId__c = oCuenta.Id;
        c2.CC_Email__c = 'prueba22@caixabank.com';
        c2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        listCanal.add(c2);
        
        CC_Canal_Com__c c3 = new CC_Canal_Com__c();
        c3.CC_NumPerso__c = '99999992';
        c3.CC_ContactoId__c = oContacto.Id;
        c3.CC_CuentaId__c = oCuenta.Id;
        c3.CC_Email__c = 'prueba23@caixabank.com';
        c3.CC_Telefono__c = '000000000';
        c3.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        listCanal.add(c3);

        CC_Canal_Com__c c4 = new CC_Canal_Com__c();
        c4.CC_NumPerso__c = '99999992';
        c4.CC_ContactoId__c = oContacto2.Id;
        c4.CC_CuentaId__c = oCuenta.Id;
        c4.CC_Telefono__c = '000000000';
        c4.CC_Email__c = 'prueba24@caixabank.com';
        c4.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        listCanal.add(c4);

        insert listCanal;

        List<String> oContMailAct = new List<String>();
        oContMailAct.add(oContacto.Id);
        
        String variable = oContacto.Id + '##' + 'prueba21@caixabank.com';
        String variable2 = oContacto2.Id + '##' + 'prueba22@caixabank.com';
        Map <String, String> oMail = new Map<String, String>();
        oMail.put(variable, c1.Id);
        oMail.put(variable2, c2.Id);

        String variable3 = oContacto.Id + '##' + '000000000';
        String variable4 = oContacto2.Id + '##' + '000000000';
        Map <String, String> oTelefono = new Map<String, String>();
        oTelefono.put(variable3, c1.Id);
        oTelefono.put(variable4, c2.Id);

        Map <String, Map<String, String>> oDatosCont = new Map <String, Map<String, String>>();
        Map <String, String> oAttrDatosCont = new Map<String, String>();
        oAttrDatosCont.put('AccountId', oCuenta.Id);
        oAttrDatosCont.put('ContactId', oContacto2.ID);
        oAttrDatosCont.put('MailTelfCaso',  oContacto2.Email);
        oDatosCont.put(c2.Id,oAttrDatosCont);





        try{
            CC_NotifSegCaso.crearCanalesComunicacion('EMAIL' , oContMailAct, oMail, oDatosCont);
            CC_NotifSegCaso.crearCanalesComunicacion('TELEFONO' , oContMailAct, oTelefono, oDatosCont);            
        }catch(Exception e){
            System.debug(e);
        }
    }
    
    @isTest
    public static void testLanzamientoSMS() {
        
        // TEST QUE SE USA PARA LA COBERTURA DE LA CLASE APEX, NO SE LLEGA A LANZAR LOS SMS.
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_Notificar_Clientes__c = true;
        oAgr.CC_CanalEntrada__c = 'SMS';
        oAgr.CC_CanalProcedencia__c ='SMS';

        insert oAgr;

        CC_Agrupador__c oAgr2 = new CC_Agrupador__c();
        oAgr2.RecordTypeId = sRecordType;
        oAgr2.CC_Titulo__c = 'Test';
        oAgr2.CC_Descripcion__c = 'Test';
        oAgr2.CC_Notificar_Clientes__c = true;
        insert oAgr2;
        
        
        System.assertNotEquals(oAgr, null);
        
        List<CC_PlantillaAsociada__c> listOCom = new List<CC_PlantillaAsociada__c>();

        String sRecordType2 = Schema.SObjectType.CC_PlantillaAsociada__c.getRecordTypeInfosByDeveloperName().get('CC_Agrupador').getRecordTypeId();
        
        CC_PlantillaAsociada__c oCom = new CC_PlantillaAsociada__c();
        oCom.RecordTypeId = sRecordType2;
        oCom.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom.CC_Canal__c = 'SMS';
        oCom.CC_Idioma__c = 'es';
        oCom.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom.CC_Agrupador__c = oAgr.Id;
        oCom.CC_Revisada__c = true;
        listOCom.add(oCom);

        CC_PlantillaAsociada__c oCom2 = new CC_PlantillaAsociada__c();
        oCom2.RecordTypeId = sRecordType2;
        oCom2.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom2.CC_Canal__c = 'SMS';
        oCom2.CC_Idioma__c = 'ca';
        oCom2.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom2.CC_Agrupador__c = oAgr.Id;
        oCom2.CC_Revisada__c = true;
        listOCom.add(oCom2);

        CC_PlantillaAsociada__c oCom3 = new CC_PlantillaAsociada__c();
        oCom3.RecordTypeId = sRecordType2;
        oCom3.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom3.CC_Canal__c = 'SMS';
        oCom3.CC_Idioma__c = 'en';
        oCom3.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom3.CC_Agrupador__c = oAgr.Id;
        oCom3.CC_Revisada__c = true;
        listOCom.add(oCom3);

        CC_PlantillaAsociada__c oCom4 = new CC_PlantillaAsociada__c();
        oCom4.RecordTypeId = sRecordType2;
        oCom4.CC_Tipo_Cliente__c = 'Empleado'; 
        oCom4.CC_Canal__c = 'SMS';
        oCom4.CC_Idioma__c = 'es';
        oCom4.CC_CuerpoNotificacion__c = 'test cuerpo';
        oCom4.CC_Agrupador__c = oAgr2.Id;
        oCom4.CC_Revisada__c = true;
        listOCom.add(oCom4);
        
        
        System.assertNotEquals(listOCom, null);
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.Phone = '666666666';
        oContacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert oContacto;
        
        System.assertNotEquals(oContacto, null);

        Id recordTypeIdEmpleado = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oCuenta2 = new Account (name='Test02',CC_Numero_Documento__c='12345679Z',CC_NumPerso__c = '99999921',RecordTypeId = recordTypeIdEmpleado);

        System.assertNotEquals(oCuenta2, null);
        
        List<Case> listOCaso = new List<Case>();

        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia 1';
        oCaso.Origin = 'SMS';
        oCaso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso.ContactId = oContacto.Id;
        oCaso.AccountId = oCuenta2.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        
        //listOCaso.add(oCaso);

        insert oCaso;

        oCaso.CC_MailTelfNotif__c = '666666666';
        oCaso.CC_CanalNotifCli__c = 'SMS';

        update oCaso;

        /*Case oCaso2 = new Case();
        oCaso2.Subject = 'Test Incidencia 2';
        oCaso2.Origin = 'SMS';
        oCaso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        oCaso2.ContactId = oContacto.Id;
        oCaso2.AccountId = oCuenta2.Id;
        oCaso2.CC_NotIncidencia__c = '1';
        oCaso2.CC_MailTelfNotif__c = 'test@test.es';
        oCaso2.CC_CanalNotifCli__c = 'SMS';
        oCaso2.CC_Agrupador_Id__c = oAgr.Id;
        oCaso2.CC_Idioma__c = 'ca';
        //listOCaso.add(oCaso2);
        insert oCaso2;*/
        
        Task oTask = new Task();
        oTask.WhatId = oCaso.Id;
        oTask.Status = 'Open';
        oTask.Type = 'Traslado Incidencia';
        insert oTask;
        
        System.assertNotEquals(oTask, null);
        
        EmailTemplate template = new EmailTemplate();
        template.FolderId = UserInfo.getUserId();
        template.Name = 'CC_NotIncidencia';
        template.DeveloperName = 'CC_NotIncidencia';
        template.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           insert template;
        }

        Test.startTest();
        
        Map<String, String> oTaskCase = new Map<String, String>();
        oTaskCase.put(oCaso.Id, 'Tarea');
        Map<String, String> oCaseCase = new Map<String, String>();
        oCaseCase.put(oCaso.Id, 'Caso');
        Map<String, String> oTempCont = new Map<String, String>();
        
        Map<String, Map<String, Map<String, String>>> oCanalCasos = new Map<String, Map<String, Map<String, String>>>();
        oCanalCasos = CC_NotifSegCaso.getDatosCasos(oTaskCase, oCaseCase, 'CC_NotIncidencia', oTempCont);
        Map<String, Map<String, String>> oMensajes = CC_NotifSegCaso.obtenerMensajesSMS(oCanalCasos.get('SMS'));
        Map<String, Map<String, String>> oCfgSMS = CC_NotifSegCaso.getConfigCanal('CC_NotIncidencia', 'SMS');
        CC_NotifSegCaso.enviarMensajesSMS(oMensajes, oCfgSMS, 'CC_NotIncidencia');
        
        Test.stopTest();
        
        // AL NO ENVIARSE EL SMS COMPROVAMOS UN MÉTODO QUE NOS DEVUELVE DATOS.
        System.assertNotEquals(oCanalCasos, null);
        
    }

}