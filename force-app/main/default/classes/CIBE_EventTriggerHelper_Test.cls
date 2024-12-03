/**********************************************************************************************************************
Name:	  CIBE_EventTriggerHelper_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_EventTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Alex Campos			17/08/2022		Init version
2.0			QC        	    Ali 	    		27/04/2023		Errores QC
3.0			US850518        Maria/Lucia 	    17/04/2024		Nuevos metodos updateNextMeetingDateTest, updateNextMeetingDateTest2

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public class CIBE_EventTriggerHelper_Test {
    
    @testSetup
    public static void testSetup() {
        Test.startTest();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor' LIMIT 1];
        UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = 'CIBE_CIBEmpresas' LIMIT 1];
        RecordType rtCliente = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        RecordType rtGestor = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        RecordType rtAccount = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
      

        User usrTest = new User(
            UserRoleId = ur.Id,
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044',
            ProfileId = p.Id,
            UserName = CIBE_TestHelper.getEmail(),
            AV_ExternalID__c = 'U0009003'
        );

        User usrTest2 = new User(
            UserRoleId = ur.Id,
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044',
            ProfileId = p.Id,
            UserName = CIBE_TestHelper.getEmail(),
            AV_ExternalID__c = 'U0009004'
        );
        insert new List<User>{usrTest, usrTest2};
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CIBE_OperativaEMP'];
        insert new PermissionSetAssignment(AssigneeId = usrTest.Id, PermissionSetId = ps.Id);
        
        System.runAs(usrTest) {
           // Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
            Account acc = new Account(
                Name = 'NameTest',
                RecordTypeId = rtAccount.Id,
                AV_NumPerso__c = '123455',
                AV_Negocio__c = 'EMP'
            );
            insert acc;
            RecordType rt = cibe_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
            Contact empleado = new Contact();
            empleado.RecordTypeId = rt.Id;
            empleado.FirstName = 'Empleado';
            empleado.LastName = '1';
            empleado.Email = CIBE_TestHelper.getEmail();
            empleado.CC_Idioma__c = 'es';
            empleado.CC_Matricula__c = usrTest.AV_ExternalId__c;
            empleado.CIBE_Sector__c = '001';
            empleado.CIBE_Cartera__c = '001';
            empleado.AccountId = acc.Id;
            empleado.AV_UsuarioAsociado__c = usrTest.Id;
            empleado.OwnerId = usrTest.Id;

            Contact empleado2 = new Contact();
            empleado2.RecordTypeId = rt.Id;
            empleado2.FirstName = 'Empleado';
            empleado2.LastName = '2';
            empleado2.Email = CIBE_TestHelper.getEmail();
            empleado2.CC_Idioma__c = 'es';
            empleado2.CC_Matricula__c = usrTest2.AV_ExternalId__c;
            empleado2.CIBE_Sector__c = '001';
            empleado2.CIBE_Cartera__c = '002';
            empleado2.AccountId = acc.Id;
            empleado2.AV_UsuarioAsociado__c = usrTest2.Id;
            empleado2.OwnerId = usrTest2.Id;
            insert new List<Contact>{empleado, empleado2};

            empleado2.OwnerId = usrTest.Id;
            update empleado2;
        
        }
        Test.stopTest();

        System.runAs(usrTest) {
            RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account cliente = new Account(
                Name = 'Name',
                RecordTypeId = rtAcc.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'EMP'
            );
            insert cliente;
            Event event1 = new Event();
            event1.AV_ExternalID__c='1';
            event1.Subject = 'Test Event Con External';
            event1.RecordTypeId = rtCliente.Id;
            event1.DurationInMinutes = 60;
            event1.ActivityDateTime = System.today();
            event1.Location = 'Outlook';
            event1.OwnerId = usrTest.Id;
            event1.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event1.Description = 'Prueba texto descripcion 1';
            event1.AV_Tipo__c = 'VC';
            event1.IsRecurrence = false;
            event1.whatId = cliente.Id;
            event1.ActivityDate = System.today().addDays(10);
            
            Event event2 = new Event();
            event2.Subject = 'Test Event Sin External';
            event2.RecordTypeId = rtCliente.Id;
            event2.DurationInMinutes = 60;
            event2.ActivityDateTime = System.now();
            event2.Location = 'Outlook';
            event2.OwnerId = usrTest.Id;
            event2.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event2.Description = 'Prueba texto descripcion 2';
            event2.whatId = cliente.Id;
            
            Event event3 = new Event();
            event3.AV_ExternalID__c='2';
            event3.Subject = 'Test Event';
            event3.RecordTypeId = rtGestor.Id;
            event3.DurationInMinutes = 60;
            event3.ActivityDateTime = System.now();
            event3.Location = 'Outlook';
            event3.OwnerId = usrTest.Id;
            event3.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event3.Description = 'Prueba texto descripcion 3';
            event3.IsRecurrence = false;
            event3.whatId = cliente.Id;
            
            insert new List<Event>{event1, event2, event3};

            Account  acc = [SELECT Id FROM Account WHERE Name  = 'Name'];
            Contact empleado = [SELECT Id FROM Contact WHERE CIBE_Cartera__c = '001'];

            AV_ManagementHistory__c hsitory = new AV_ManagementHistory__c();
            hsitory.AV_ActivityId__c = event1.Id;
            hsitory.OwnerId = usrTest.Id;
            insert hsitory;

            //Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(acc, empleado, event1.AV_ExternalID__c);
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.AV_ExternalID__c = event1.AV_ExternalID__c;
            opp.Name = 'Alerta Comercial';
            opp.StageName = 'En curso';
            opp.RecordTypeId = rtOpp.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_Gestor__c = empleado.Id;
            opp.AV_PF__c = prodPF.Id;
            insert opp;
            List<AV_HeaderCustomActivity__c> listHeaderTask = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :event1.AV_ExternalID__c LIMIT 1];
            AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask[0].id);

            
        }
    }
    
    @isTest
    public static void testHeaderCustomActivity() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            Event event2 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event WHERE Subject = 'Test Event Sin External' LIMIT 1];
            
            System.assert(String.isNotBlank(event1.AV_Task__c));
            System.assert(String.isNotBlank(event2.AV_Task__c));
            System.assert(String.isNotBlank(event1.AV_ExternalID__c));
            System.assert(String.isNotBlank(event2.AV_ExternalID__c));

            AV_HeaderCustomActivity__c header1 = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :event1.AV_ExternalID__c LIMIT 1];
            AV_HeaderCustomActivity__c header2 = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :event2.AV_ExternalID__c LIMIT 1];
            
            System.assert(String.isNotBlank(header1.AV_ExternalID__c));
            System.assert(String.isNotBlank(header2.AV_ExternalID__c));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testCreateCRMTask() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            Event event2 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event WHERE Subject = 'Test Event Sin External' LIMIT 1];
            Event event3 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event WHERE Subject = 'Test Event' LIMIT 1];
            
            CBK_Activity_Extension__c actExt1 = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event1.Id LIMIT 1];
            CBK_Activity_Extension__c actExt2 = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event2.Id LIMIT 1];
            CBK_Activity_Extension__c actExt3 = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event3.Id LIMIT 1];

            System.assert(String.isNotBlank(actExt1.AV_ActivityId__c));
            System.assert(String.isNotBlank(actExt2.AV_ActivityId__c));
            System.assert(String.isNotBlank(actExt3.AV_ActivityId__c));
            System.assert(String.isNotBlank(actExt1.AV_CommentLastModifiedBy__c));
            System.assert(String.isNotBlank(actExt2.AV_CommentLastModifiedBy__c));
            System.assert(String.isNotBlank(actExt3.AV_CommentLastModifiedBy__c));

            event2.Description = 'Prueba texto descripcion 2 ampliada';
            event3.Description = 'Prueba texto descripcion 3 ampliada';
            update new List<Event>{event2, event3};

            CBK_Activity_Extension__c actExt2Ampliado = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event2.Id LIMIT 1];
            CBK_Activity_Extension__c actExt3Ampliado = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event3.Id LIMIT 1];

            System.assert(String.isNotBlank(actExt2Ampliado.AV_ActivityId__c));
            System.assert(String.isNotBlank(actExt3Ampliado.AV_ActivityId__c));
            System.assert(String.isNotBlank(actExt2Ampliado.AV_CommentLastModifiedBy__c));
            System.assert(String.isNotBlank(actExt3Ampliado.AV_CommentLastModifiedBy__c));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testUpdateHeaderCustomActivityExtId() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];

            System.assert(String.isNotBlank(event1.AV_Task__c));
            System.assert(String.isNotBlank(event1.AV_ExternalID__c));

            AV_HeaderCustomActivity__c header1 = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :event1.AV_ExternalID__c LIMIT 1];

            System.assert(String.isNotBlank(header1.AV_ExternalID__c));

            event1.AV_ExternalID__c = '12345';
            update event1;

            AV_HeaderCustomActivity__c header1Cambiado = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :event1.AV_ExternalID__c LIMIT 1];
            System.assertEquals(header1Cambiado.AV_ExternalID__c, '12345');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testChangeOwner() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, Owner.Name FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            User user = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
            User user2 = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c = 'U0009004' LIMIT 1];

            CBK_Activity_Extension__c actExt1 = [SELECT Id, AV_ActivityId__c, CIBE_Sector__c, CIBE_Cartera__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event1.Id LIMIT 1];

            System.assertEquals(actExt1.CIBE_Sector__c, null);
            System.assertEquals(actExt1.CIBE_Cartera__c, null);

            event1.OwnerId = user2.Id;
            update event1;

            CBK_Activity_Extension__c actExt1Cambiado = [SELECT Id, AV_ActivityId__c, CIBE_Sector__c, CIBE_Cartera__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :event1.Id LIMIT 1];
            
            System.assertEquals(actExt1Cambiado.CIBE_Sector__c, '001');
            System.assertEquals(actExt1Cambiado.CIBE_Cartera__c, '002');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testProcessOwnerGestores() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            Event event2 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c FROM Event WHERE Subject = 'Test Event Sin External' LIMIT 1];
            Event event3 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c FROM Event WHERE Subject = 'Test Event' LIMIT 1];

            User user2 = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c = 'U0009004' LIMIT 1];

            Contact contact1 = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_UsuarioAsociado__c = :event1.OwnerId LIMIT 1];
            Contact contact2 = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_UsuarioAsociado__c = :event2.OwnerId LIMIT 1];
            Contact contact3 = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_UsuarioAsociado__c = :event3.OwnerId LIMIT 1];

            System.assertEquals(event1.AV_CodigoGestorAsignado__c, contact1.CC_Matricula__c);

            event1.OwnerId = user2.Id;
            update event1;
        }

            Event event1Cambiado = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            Contact contact1Cambiado = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_UsuarioAsociado__c = :event1Cambiado.OwnerId LIMIT 1];

            System.assertEquals(event1Cambiado.AV_CodigoGestorAsignado__c, contact1Cambiado.CC_Matricula__c);
            Test.stopTest();
        
    }

    @isTest
    public static void insertOrUpdateCodigoGestorAsignadoTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            User user2 = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c = 'U0009004' LIMIT 1];

            event1.OwnerId = user2.Id;
            update event1;
        }

        User runAsUser2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009004' LIMIT 1];
        System.runAs(runAsUser2) {
            Event event1Cambiado = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            
            System.assert(String.isNotBlank(event1Cambiado.AV_CodigoGestorAsignado__c));
            Test.stopTest();
        }
    }

    @isTest
    public static void setMeetingLocationTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Event e = [SELECT Id, Location, AV_BranchPhysicalMeet__c, AV_Tipo__c, RecordTypeId FROM Event WHERE Subject = 'Test Event Con External' AND DurationInMinutes = 60 LIMIT 1];
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
            User u = [SELECT Id, AV_NumeroOficinaEmpresa__c, AV_ExternalID__c FROM User WHERE Alias = 'tsAlias' AND Email = 'test@test.dev' LIMIT 1];
            String branch = '00001';
            Datetime now = System.now();
            Event e2 = new Event(
                Subject = 'Inserted event test',
                OwnerId = u.Id,
                AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
                RecordTypeId = rt.Id,
                DurationInMinutes= 60,
                ActivityDateTime = now,
                AV_Tipo__c = 'VC',
                StartDateTime = now,
                EndDateTime = now.addMinutes(60),
                CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE,
                AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP,
                AV_BranchPhysicalMeet__c = branch
            );
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
            e.AV_Tipo__c = 'VC';
            e.AV_BranchPhysicalMeet__c = branch;
            update e;
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
            insert e2;
            System.assert(e2 != null);
            Test.stopTest();
            }
    }

    @isTest
    public static void updateCentroTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        Test.startTest();
        System.runAs(runAsUser) {
            List<Event> lstEv = new  List<Event>();
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c,AV_Center__C FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            Contact contact1 = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_UsuarioAsociado__c = :event1.OwnerId LIMIT 1];
            User u = [SELECT Id, AV_NumeroOficinaEmpresa__c, AV_ExternalID__c FROM User WHERE Alias = 'tsAlias' AND Email = 'test@test.dev' LIMIT 1];
            lstEv.add(event1);
            map<Id,Event> mapOlds = new map<Id,Event>();
            if(lstEv.size()>0){
                for (Event evt : lstEv) {
                    mapOlds.put(evt.Id,evt);
                }
            }
            CIBE_EventTriggerHelper.updateCentro(lstEv,mapOlds);
            Test.stopTest();
            System.assertEquals(lstEv[0].AV_Center__C, u.AV_NumeroOficinaEmpresa__c.substring(u.AV_NumeroOficinaEmpresa__c.length()-5));
        }
    }

    @isTest
    public static void setConfidentialityTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            Account a = [SELECT Id, AV_Confidencial__c, AV_Empleado__c FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
            a.AV_Confidencial__c = true;    
            update a;
        }
            
        System.runAs(runAsUser) {
            Account a = [SELECT Id, AV_Confidencial__c, AV_Empleado__c FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c, AV_Center__c, CIBE_Confidential__c FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            event1.WhatId = a.Id;
            update event1;
            System.assert(event1.WhatId == a.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getOfficeNumberTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
            String num = CIBE_EventTriggerHelper.getOfficeNumber('1231-12');
            CIBE_EventTriggerHelper.getOfficeNumber('123112');
            String numError = CIBE_EventTriggerHelper.getOfficeNumber('');
            System.assert(num != null);
            System.assert(numError == null);
            Test.stopTest();
        }
    }

    @isTest
    public static void callApiTeamsTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        Test.StartTest();
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AzureTeamToken';
        cs.AV_ExpiresIn__c = 0;
        insert cs;
        System.runAs(runAsUser) {
            Account cliente = [SELECT id FROM Account WHERE AV_NumPerso__c ='123'];
                
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event event = new Event();
            event.Subject = 'Call';
            event.WhatId = cliente.Id;
            event.OwnerId = runAsUser.Id;
    
            String externalId = '999999';
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true
            );
            insert acthead;
            Datetime now = System.now();
            String randomExternalId = String.valueof((Math.random() * 10000000));
            event.AV_ExternalID__c = randomExternalId;
            event.RecordTypeId = rt.Id;
            event.DurationInMinutes= 60;
            event.AV_Task__c=acthead.id;
            event.ActivityDateTime = now;
            event.AV_Tipo__c = CIBE_AppConstants.VIDEOLLAMADA_TIPO;
            event.StartDateTime = now;
            event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            insert event;
            System.assert(event != null);
            System.assert(event.AV_OrigenApp__c == CIBE_AppConstants.SALESFORCE_ORIGENAPP);
        }
        Test.stopTest();
    }

    @isTest
    public static void deleteRecordsRelatedWithEvent(){
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        List<AV_ManagementHistory__c> managementHistoryList = new List<AV_ManagementHistory__c>();
        List<CBK_Activity_Extension__c> eventExtensionList = new List<CBK_Activity_Extension__c>();
        List<AV_CustomActivityOpportunity__c> EventOppList = new List<AV_CustomActivityOpportunity__c>();
        List<AV_HeaderCustomActivity__c> listHeaderEvent = new List<AV_HeaderCustomActivity__c>();
        List<Event> listEvent = new List<Event> ();
        System.runAs(runAsUser) {
            listEvent = [SELECT Id,AV_Task__c,AV_ExternalID__c, OwnerId  FROM Event WHERE  Subject = 'Test Event Con External' ];
            Map<Id, Event> mapIdsEvent = new Map<Id, Event>(listEvent);
            Test.startTest();
            delete listEvent;
            Test.stopTest();
        }
            eventExtensionList = [Select Id From CBK_Activity_Extension__c WHERE AV_ActivityId__c =: listEvent[0].Id ];
            System.assertEquals(true, eventExtensionList.isEmpty());

    }

    @isTest
    public static void updateNextMeetingDateTest() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        
            System.runAs(runAsUser) {
            Test.startTest();
            
            Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c,AV_Center__C FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
            AV_CustomActivityOpportunity__c opp = [SELECT id, AV_Opportunity__c, AV_Task__c, AV_Task__r.Name  from AV_CustomActivityOpportunity__c where AV_Task__c =: event1.AV_Task__c];
            Opportunity oportunidad =[SELECT Id,AV_FechaProximoRecordatorio__c,CIBE_NextMeetingDate__c FROM opportunity WHERE Id =: opp.AV_Opportunity__c];
            event1.StartDateTime=System.now().addDays(2);
            update event1;
            Opportunity oportunidad2 =[SELECT Id,AV_FechaProximoRecordatorio__c,CIBE_NextMeetingDate__c FROM opportunity WHERE Id =: opp.AV_Opportunity__c];
            system.assert(oportunidad.AV_FechaProximoRecordatorio__c != oportunidad2.AV_FechaProximoRecordatorio__c);
            system.assert(oportunidad.CIBE_NextMeetingDate__c != oportunidad2.CIBE_NextMeetingDate__c);


            Test.stopTest();
        }
    }

    @isTest
    public static void updateNextMeetingDateTest2() {
        User runAsUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        System.runAs(runAsUser) {
        Test.startTest();
        
        Event event1 = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId, AV_CodigoGestorAsignado__c,AV_Center__C FROM Event WHERE Subject = 'Test Event Con External' LIMIT 1];
        AV_CustomActivityOpportunity__c opp = [SELECT id, AV_Opportunity__c, AV_Task__c, AV_Task__r.Name  from AV_CustomActivityOpportunity__c where AV_Task__c =: event1.AV_Task__c];
        Opportunity oportunidad =[SELECT Id,AV_FechaProximoRecordatorio__c,CIBE_NextMeetingDate__c FROM opportunity WHERE Id =: opp.AV_Opportunity__c];
        event1.StartDateTime=System.today().addDays(2);
        update event1;
        Opportunity oportunidad2 =[SELECT Id,AV_FechaProximoRecordatorio__c,CIBE_NextMeetingDate__c FROM opportunity WHERE Id =: opp.AV_Opportunity__c];
        system.assert(oportunidad.AV_FechaProximoRecordatorio__c != oportunidad2.AV_FechaProximoRecordatorio__c);
        system.assert(oportunidad.CIBE_NextMeetingDate__c != oportunidad2.CIBE_NextMeetingDate__c);


        Test.stopTest();
        }
    }


    /***********************************************************************************************************/
    @isTest
    public static void deleteRelationsTest(){
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        Test.startTest();

        System.runAs(usuarioG){
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account accTest = new Account(
                Name = 'Test Name 2',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '021',
                AV_Negocio__c = 'EMP'
            );
            insert accTest;
            RecordType rtOppEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Test Event Con External'];
            Opportunity opp1 = [SELECT Id,AV_Comentarios__c, RecordTypeId FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];

            List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp1.Id];
            System.assert(!relacionado.isEmpty());
            delete evento;
            
            Test.stoptest();
            
            List<Event> evnt = [SELECT Id FROM Event WHERE Subject = 'Test Event Con External'];
            List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp1.Id];

            System.assert(evnt.isEmpty());
            System.assert(relacionado2.isEmpty());
        }
    }  
}