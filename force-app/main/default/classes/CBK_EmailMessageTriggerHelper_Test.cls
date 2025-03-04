@isTest
public class CBK_EmailMessageTriggerHelper_Test {

	private static List<String> psSets = new List<String>{
		'CBK_Framework_Login',
		'CBK_Framework_Admin'
	};

	@testSetup
	static void initialData() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN :psSets]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
    }

	@isTest
	private static void checkEmailsHandlersWithInsert() {
		User testUser = [SELECT Id FROM User WHERE alias = 'user2' AND email='testSEGBI2@acme.com' LIMIT 1];
        
        System.runAs(testUser) {
			Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
			CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
			grupoColab.Name = 'Grupo Colaborador Temporal';
			grupoColab.RecordTypeId = recordTypeGrupoColaborador;
			grupoColab.CC_External__c = 'GC-00001';
			insert grupoColab;

			CC_Grupo_Colaborador__c grupoColab2 = new CC_Grupo_Colaborador__c();
			grupoColab2.Name = 'Grupo Colaborador Temporal';
			grupoColab2.RecordTypeId = recordTypeGrupoColaborador;
			grupoColab2.CC_External__c = 'GC-000012';
			insert grupoColab2;

			Case caso = new Case();
			caso.Origin = 'Chat';
			caso.Description = 'test1';
			caso.CC_Canal_Procedencia__c = 'Web';
			insert caso;

			Case caso2 = new Case();
			caso2.Origin = 'Chat';
			caso2.Description = 'test2';
			caso2.CC_Canal_Procedencia__c = 'Web';
			insert caso2;

			Case caso3 = new Case();
			caso3.Origin = 'Chat';
			caso3.Description = 'test2';
			caso3.CC_Canal_Procedencia__c = 'Web';
			insert caso3;

			Case caso4 = new Case();
			caso4.Origin = 'Chat';
			caso4.Description = 'test2';
			caso4.CC_Canal_Procedencia__c = 'Web';
			insert caso4;

			Task actividad = new Task();
			actividad.WhatId = caso.Id;
			insert actividad;

			Task actividad2 = new Task();
			actividad.WhatId = caso2.Id;
			insert actividad2;

			Task actividad3 = new Task();
			actividad3.WhatId = caso3.Id;
			insert actividad3;

			Task actividad4 = new Task();
			actividad4.WhatId = caso4.Id;
			insert actividad4;

			List<EmailMessage> lstCorreo = new List<EmailMessage> ();

			EmailMessage correo = new EmailMessage();
			correo.ParentId = caso.Id;
			correo.RelatedToId = caso.Id;
			correo.ActivityId = actividad.Id;
			correo.Subject = 'prueba';
			correo.Incoming = true;
			correo.TextBody = 'cuerpo';
			correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
			correo.CC_Procedencia__c = 'Traslado Colaborador';
			correo.CC_Grupo_Colab__c = grupoColab.Name;
			correo.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
			lstCorreo.add(correo);

			EmailMessage correo2 = new EmailMessage();
			correo2.ParentId = caso2.Id;
			correo2.RelatedToId = caso2.Id;
			correo2.ActivityId = actividad2.Id;
			correo2.Subject = 'prueba';
			correo2.Incoming = false;
			correo2.TextBody = 'cuerpo';
			correo2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			correo2.CC_Procedencia__c = 'Traslado Colaborador';
			correo2.CC_Grupo_Colab__c = grupoColab2.Name;
			correo2.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			lstCorreo.add(correo2);

			EmailMessage correo3 = new EmailMessage();
			correo3.ParentId = caso3.Id;
			correo3.RelatedToId = caso3.Id;
			correo3.ActivityId = actividad3.Id;
			correo3.Subject = 'prueba';
			correo3.Incoming = true;
			correo3.TextBody = 'cuerpo';
			correo3.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			correo3.CC_Procedencia__c = 'Traslado Colaborador';
			correo3.CC_Grupo_Colab__c = grupoColab2.Name;
			correo3.ToAddress = 'test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com';
			lstCorreo.add(correo3);

			EmailMessage correo4 = new EmailMessage();
			correo4.ParentId = caso4.Id;
			correo4.RelatedToId = caso4.Id;
			correo4.ActivityId = actividad4.Id;
			correo4.Subject = 'prueba';
			correo4.Incoming = true;
			correo4.TextBody = 'cuerpo';
			correo4.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			correo4.CC_Procedencia__c = 'Traslado Colaborador';
			correo4.CC_Grupo_Colab__c = grupoColab2.Name;
			correo4.ToAddress = correo2.ToAddress + ';' + correo.ToAddress;
			lstCorreo.add(correo4);

			Test.startTest();
			insert lstCorreo;
			Test.stopTest();
		}
	}


	@isTest
	private static void checkEmailsHandlersWithOutInsert() {
		User testUser = [SELECT Id FROM User WHERE alias = 'user2' AND email='testSEGBI2@acme.com' LIMIT 1];
        
        System.runAs(testUser) {
			Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
			CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
			grupoColab.Name = 'Grupo Colaborador Temporal';
			grupoColab.RecordTypeId = recordTypeGrupoColaborador;
			grupoColab.CC_External__c = 'GC-00001';
			insert grupoColab;

			recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
			CC_Grupo_Colaborador__c grupoColab2 = new CC_Grupo_Colaborador__c();
			grupoColab2.Name = 'Grupo Colaborador Temporal';
			grupoColab2.RecordTypeId = recordTypeGrupoColaborador;
			grupoColab2.CC_External__c = 'GC-000012';
			insert grupoColab2;

			Case caso = new Case();
			caso.Origin = 'Chat';
			caso.Description = 'test1';
			caso.CC_Canal_Procedencia__c = 'Web';
			insert caso;

			Case caso2 = new Case();
			caso2.Origin = 'Chat';
			caso2.Description = 'test2';
			caso2.CC_Canal_Procedencia__c = 'Web';
			insert caso2;

			Case caso3 = new Case();
			caso3.Origin = 'Chat';
			caso3.Description = 'test2';
			caso3.CC_Canal_Procedencia__c = 'Web';
			insert caso3;

			Case caso4 = new Case();
			caso4.Origin = 'Chat';
			caso4.Description = 'test2';
			caso4.CC_Canal_Procedencia__c = 'Web';
			insert caso4;

			Task actividad = new Task();
			actividad.WhatId = caso.Id;
			insert actividad;

			Task actividad2 = new Task();
			actividad.WhatId = caso2.Id;
			insert actividad2;

			Task actividad3 = new Task();
			actividad3.WhatId = caso3.Id;
			insert actividad3;

			Task actividad4 = new Task();
			actividad4.WhatId = caso4.Id;
			insert actividad4;

			List<EmailMessage> lstCorreo = new List<EmailMessage> ();

			EmailMessage correo = new EmailMessage();
			correo.ParentId = caso.Id;
			correo.RelatedToId = caso.Id;
			correo.ActivityId = actividad.Id;
			correo.Subject = 'prueba';
			correo.Incoming = true;
			correo.TextBody = 'cuerpo';
			correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
			correo.CC_Procedencia__c = 'Traslado Colaborador';
			correo.CC_Grupo_Colab__c = grupoColab.Name;
			correo.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
			lstCorreo.add(correo);

			EmailMessage correo2 = new EmailMessage();
			correo2.ParentId = caso2.Id;
			correo2.RelatedToId = caso2.Id;
			correo2.ActivityId = actividad2.Id;
			correo2.Subject = 'prueba';
			correo2.Incoming = false;
			correo2.TextBody = 'cuerpo';
			correo2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			correo2.CC_Procedencia__c = 'Traslado Colaborador';
			correo2.CC_Grupo_Colab__c = grupoColab2.Name;
			correo2.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			lstCorreo.add(correo2);

			EmailMessage correo3 = new EmailMessage();
			correo3.ParentId = caso3.Id;
			correo3.RelatedToId = caso3.Id;
			correo3.ActivityId = actividad3.Id;
			correo3.Subject = 'prueba';
			correo3.Incoming = true;
			correo3.TextBody = 'cuerpo';
			correo3.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			correo3.CC_Procedencia__c = 'Traslado Colaborador';
			correo3.CC_Grupo_Colab__c = grupoColab2.Name;
			correo3.ToAddress = 'test@p-18nbt53xompbolkephezu961v8dyxkay8s2tvjsaow1i4i5stv.0q-1vnyua2.cs109.apex.sandbox.salesforce.com';
			lstCorreo.add(correo3);

			EmailMessage correo4 = new EmailMessage();
			correo4.ParentId = caso4.Id;
			correo4.RelatedToId = caso4.Id;
			correo4.ActivityId = actividad4.Id;
			correo4.Subject = 'prueba';
			correo4.Incoming = true;
			correo4.TextBody = 'cuerpo';
			correo4.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt order by CC_Direccion_Correo__c desc] [0].CC_Direccion_Correo__c;
			correo4.CC_Procedencia__c = 'Traslado Colaborador';
			correo4.CC_Grupo_Colab__c = grupoColab2.Name;
			correo4.ToAddress = correo2.ToAddress + ';' + correo.ToAddress;
			lstCorreo.add(correo4);


			Test.startTest();
			//insert lstCorreo;

			CC_TriggerParameters tp = new CC_TriggerParameters();
			tp.newList = lstCorreo;
			CBK_EmailMessageTriggerHelper.filterEmailsHandlers(tp, 'beforeInsert', 'CC_EmailMessage_BI_TRHan');

			Test.stopTest();

		}
	}

	@isTest
	private static void checkEmailAndDomaninMtd() {
		User testUser = [SELECT Id FROM User WHERE alias = 'user2' AND email='testSEGBI2@acme.com' LIMIT 1];
        
        System.runAs(testUser) {
			Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
			CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
			grupoColab.Name = 'Grupo Colaborador Temporal';
			grupoColab.RecordTypeId = recordTypeGrupoColaborador;
			grupoColab.CC_External__c = 'GC-00001';
			insert grupoColab; 

			recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
			CC_Grupo_Colaborador__c grupoColab2 = new CC_Grupo_Colaborador__c();
			grupoColab2.Name = 'Grupo Colaborador Temporal';
			grupoColab2.RecordTypeId = recordTypeGrupoColaborador;
			grupoColab2.CC_External__c = 'GC-000012';
			insert grupoColab2; 

			Case caso = new Case();
			caso.Origin = 'Chat';
			caso.Description = 'test1';
			caso.CC_Canal_Procedencia__c = 'Web';
			insert caso;
			
			Task actividad = new Task();
			actividad.WhatId = caso.Id;
			insert actividad;
			List<EmailMessage> lstCorreo = new List<EmailMessage> ();
			
			//EmailMessage correo = new EmailMessage();
			//correo.ParentId = caso.Id;
			//correo.RelatedToId = caso.Id;
			//correo.ActivityId = actividad.Id;
			//correo.Subject = 'prueba';
			//correo.Incoming = false;
			//correo.TextBody = 'cuerpo';
			//correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
			//correo.CC_Procedencia__c = 'Traslado Colaborador';
			//correo.CC_Grupo_Colab__c = grupoColab.Name;
			//correo.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
			//lstCorreo.add(correo);

			EmailMessage correo2 = new EmailMessage();
			correo2.ParentId = caso.Id;
			correo2.RelatedToId = caso.Id;
			correo2.ActivityId = actividad.Id;
			correo2.Subject = 'prueba';
			correo2.Incoming = false;
			correo2.TextBody = 'cuerpo';
			correo2.FromAddress = 'test@mitestDom.com';
			correo2.CC_Procedencia__c = 'Traslado Colaborador';
			correo2.CC_Grupo_Colab__c = grupoColab.Name;
			correo2.ToAddress = 'test@mitestDom.com';
			lstCorreo.add(correo2);

			EmailMessage correo1 = new EmailMessage();
			correo1.ParentId = caso.Id;
			correo1.RelatedToId = caso.Id;
			correo1.ActivityId = actividad.Id;
			correo1.Subject = 'prueba';
			correo1.Incoming = false;
			correo1.TextBody = 'cuerpo';
			correo1.FromAddress = 'test@mitestDom.com';
			correo1.CcAddress = 'testBlacklist@mitestDom.com';
			correo1.CC_Procedencia__c = 'Traslado Colaborador';
			correo1.CC_Grupo_Colab__c = grupoColab.Name;
			correo1.ToAddress = 'testWhitelist@mitestDom.com';
			lstCorreo.add(correo1);

			EmailMessage correo3 = new EmailMessage();
			correo3.ParentId = caso.Id;
			correo3.RelatedToId = caso.Id;
			correo3.ActivityId = actividad.Id;
			correo3.Subject = 'prueba';
			correo3.Incoming = false;
			correo3.TextBody = 'cuerpo';
			correo3.FromAddress = 'TestEmail@mitestEmail.com';
			correo3.CC_Procedencia__c = 'Traslado Colaborador';
			correo3.CC_Grupo_Colab__c = grupoColab.Name;
			correo3.ToAddress = 'TestEmail@mitestEmail.com';		
			lstCorreo.add(correo3);
			

			Test.startTest();

			CC_TriggerParameters tp = new CC_TriggerParameters();
			tp.newList = lstCorreo;
			CBK_EmailMessageTriggerHelper.checkEmailAndDomain(tp);

			Test.stopTest();
		}
	}

	@isTest
	private static void checkInvalidEmailAttachments() {
        User testUser = [SELECT Id FROM User WHERE alias = 'user2' AND email='testSEGBI2@acme.com' LIMIT 1];
        
        System.runAs(testUser) {
            Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;
    
            Case caso = new Case();
            caso.Origin = 'Chat';
            caso.Description = 'test1';
            caso.CC_Canal_Procedencia__c = 'Web';
            insert caso;
    
            Task actividad = new Task();
            actividad.WhatId = caso.Id;
            insert actividad;
    
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = 'test.script';
            cv.Origin = 'H';
            cv.Title = 'test';
            cv.VersionData = Blob.valueOf('Test file text');
            insert cv;
    
            ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = caso.Id, ContentDocumentId = cVers.ContentDocumentId, ShareType = 'I');
            insert cl;
            
            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { 'test@test.com' });
                mail.setEntityAttachments(new List<Id>{cv.Id});
                mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - CaixaBank' LIMIT 1].Id);
                mail.setSubject('Test Email With Attachment');
                mail.setHtmlBody('Test Email With Attachment');
                mail.setWhatId(caso.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                Assert.fail(
                    'This part of the unit test should not have been reached. Expected that an exception was thrown. Validate why no exception has been thrown.'
                );
            } catch(EmailException e) {
                Assert.isNotNull(e);
                Assert.isNotNull(e.getMessage());
                Assert.isTrue('System.EmailException'.equals(e.getTypeName()), 'Exception message must be invalid attachment error message');
            }
        }
	}

}