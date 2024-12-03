/**********************************************************************************************************************
Name:	  CIBE_TestHelper
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase que crea datos para el testing del resto de clases
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY				AUTHOR				DATE				Description
1.0			CIBE_TestHelper			Jose Maria	   		09/06/2022		  	Init version
2.0			US392789				Jose Maria	   		14/10/2022		  	Mejora en los métodos relacionados con carteras
3.0         US523654                Lucía Muñoz         14/02/2023          Nuevos métodos de prueba
4.0         US556905                Lucía Muñoz         23/03/2023          Creados los metodos createPFExperience, createPFCliente, createExperienciaNegocio
5.0         DE74043                 Bea                 14/04/2023          Creados los métodos createTareaOrigenApp y createTareaOrigenAppToday
6.0         US609754                 Lucía Muñoz         28/06/2023          Nuevos métodos createUserSinInsert, createEmployeeSinInsert,createCustomerWithEAPGestor, createTareaExternalIdWithCustomerSinInsert, createTareaExternalIdCustomStatusWithCustomerSinInsert, createEventConClienteEAPGestorSinInsert y 
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_TestHelper {
    
    private static final String MATRICULA_SAMPLE = 'U0009003';
    
    
    public static Integer getRandomValueMatricula(){
        return Math.round(Math.random()*100000);
    }
    
    public static Integer getRandomValue(){
        return Math.round(Math.random()*1000);
    }
    
    public static String getEmail(){
        Integer rand = getRandomValue();
        Integer rand2 = getRandomValue();
        return 'test' + rand + '@test.env' + rand2 + '.es';
    }
    
    public static User createUser(String labelProfile){
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
        System.debug('result: ' + result);
        String username = getEmail();
        Profile p = (Profile)result.get(0);
        System.debug('p: ' + p);
        User u = new User(
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '1111111',
            ProfileId = p.Id,
            UserName = username,
            AV_ExternalID__c = MATRICULA_SAMPLE,
            IsActive = true
        );
        System.debug('u.ProfileId: ' + u.ProfileId);
        insert u;
        return u;
    }

    public static User createUser(String labelProfile, String matricula){
		if (String.isBlank(labelProfile)){
			labelProfile = 'Standard User';
		}
        if (String.isBlank(matricula)){
			matricula = MATRICULA_SAMPLE;
		}
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = getEmail();
		Profile p = (Profile)result.get(0);
		User u = new User(
				Alias = 'tsAlias',
				Email = 'test@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = 'testLastName',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
            	AV_NumeroOficinaEmpresa__c = '001-03044',
				ProfileId = p.Id,
				UserName = username,
				AV_ExternalID__c = matricula
			);
		insert u;
		return u;
	}

    public static User createUserSinInsert(String labelProfile){
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
        String username = getEmail();
        Profile p = (Profile)result.get(0);
        User u = new User(
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '1111111',
            ProfileId = p.Id,
            UserName = username,
            AV_ExternalID__c = MATRICULA_SAMPLE,
            IsActive = true
        );
        return u;
    }
    
    public static Task createTareaOtherExternalID(User user){
		RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}		
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928363';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today()-3;
		insert tarea;
		return tarea;
	}
    public static Task createTareaOrigenApp(User user, RecordType rt){
		
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}		
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
        tarea.AV_OrigenApp__c = ' ';
		tarea.AV_ExternalID__c = '01928363';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today()-1;
        tarea.AV_ToDelete__c = false;
		insert tarea;
		return tarea;
	}
    public static Task createTareaOrigenAppToday(User user, RecordType rt){
		
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}		
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
        tarea.AV_OrigenApp__c = ' ';
		tarea.AV_ExternalID__c = '01928363';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today();
        tarea.AV_ToDelete__c = false;
		insert tarea;
		return tarea;
	}
    public static Account createConfidencialCustomer(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'Name',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123',
            AV_Negocio__c = 'BPA',
            AV_Confidencial__c = true
        );
        insert acc;
        return acc;
    }

	public static Account createCustomerWithEAPGestor(Contact gestor) {
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
		Account acc = new Account(
                Name = 'Test Name',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'CIB'
			);
		if (gestor != null) {
			acc.AV_EAPGestor__c = gestor.Id;
		}
		insert acc;
		return acc;
	}
    
	public static Account createCustomerSinCliente() {
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = CIBE_AppConstants.ACC_SINCLIENTE,
            RecordTypeId = rt.Id,
            AV_NumPerso__c = 'SinCliCIBE',
            AV_Negocio__c = 'BPA',
            AV_InterlocName__c = CIBE_AppConstants.ACC_SINCLIENTE
        );
        insert acc;
		return acc;
	}

    public static Account createCustomerWithNumperson(String numper){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
		Account acc = new Account(
                Name = 'Test Name',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = numper,
				AV_Negocio__c = 'BPA'
			);
		insert acc;
		return acc;
	}
    
    public static Account createCaixaCenter(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account centroCaixa = new Account();
        centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
        centroCaixa.CC_Numero_Oficina_Empresa__c = '';
        centroCaixa.CC_Numero_Oficina__c = '00615';
        centroCaixa.RecordTypeId = rt.Id;
        centroCaixa.CIBE_Negocios__c = '001';
        centroCaixa.CIBE_RedesSegmentos__c = '002';
        centroCaixa.CIBE_CentrosCarteras__c = '003';
        centroCaixa.CIBE_SectoresPaises__c = '004';
        insert centroCaixa;
        return centroCaixa;
    }

    public static Account createCaixaCenter(String name, String numeroOficina){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account centroCaixa = new Account();
        centroCaixa.Name = String.isNotBlank(name) ? name : '00615 STORE DOS DE MAIG-ROSSELLO';
        centroCaixa.CC_Numero_Oficina_Empresa__c = '';
        centroCaixa.CC_Numero_Oficina__c = String.isNotBlank(numeroOficina) ? numeroOficina : '00615';
        centroCaixa.RecordTypeId = rt.Id;
        centroCaixa.CIBE_Negocios__c = '001';
        centroCaixa.CIBE_RedesSegmentos__c = '002';
        centroCaixa.CIBE_CentrosCarteras__c = '003';
        centroCaixa.CIBE_SectoresPaises__c = '004';
        insert centroCaixa;
        return centroCaixa;
    }
    
    public static Contact createEmployee(Account center, User user){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
        Contact employee = new Contact();
        employee.RecordTypeId = rt.Id;
        employee.FirstName = 'Empleado';
        employee.LastName = '1';
        employee.Email = getEmail();
        employee.CC_Idioma__c = 'es';
        employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
        employee.CIBE_Cartera__c = '001';
        employee.CIBE_Sector__c = '001';
        if (center!=null){
            employee.AccountId = center.Id;
        }
        if (user != null){
            employee.AV_UsuarioAsociado__c = user.Id;
        }else{
            employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
        }
        
        insert employee;
        return employee;
    }

    public static Contact createEmployeeSinInsert(Account center, User user){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
        Contact employee = new Contact();
        employee.RecordTypeId = rt.Id;
        employee.FirstName = 'Empleado';
        employee.LastName = '1';
        employee.Email = getEmail();
        employee.CC_Idioma__c = 'es';
        employee.CC_Matricula__c = 'U01' + String.ValueOf(getRandomValueMatricula());
        employee.CIBE_Cartera__c = '001';
        employee.CIBE_Sector__c = '001';
        if (center!=null){
            employee.AccountId = center.Id;
        }
        if (user != null){
            employee.AV_UsuarioAsociado__c = user.Id;
        }else{
            employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
        }
        return employee;
    }

    public static Contact createEmployee(Account center, User user, String matricula){
		RecordType rt = cibe_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = matricula;
        employee.CIBE_Cartera__c = '001';
        employee.CIBE_Sector__c = '001';
		if (center!=null){
			employee.AccountId = center.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		insert employee;
		return employee;
	}
    
    public static Opportunity createOpportunityExternalId(Account acc, Contact empleado, String externalId){
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		if(String.isNotBlank(externalId)){
			opp.AV_ExternalID__c = externalId;
		}
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'En curso';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
        opp.AV_PF__c = prodPF.Id;
		insert opp;
		return opp;
	}
    
    public static Opportunity createOpportunity(Account acc){
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Alerta Comercial';
        opp.StageName = 'En gestión/insistir';
        opp.RecordTypeId = rt.Id;
        opp.CloseDate = System.today() + 5;
        opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
        opp.AV_PF__c = prodPF.Id;
        insert opp;
        return opp;
    }

    public static OpportunityTeamMember createOpportunityTeam(Account acc){
        Opportunity opp = createOpportunity(acc);
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = opp.Id;
        otm.UserId = opp.OwnerId;
        otm.TeamMemberRole = 'Participante';
        otm.OpportunityAccessLevel = 'Read';
        return otm;
    }
    
    public static Opportunity createOpportunityWithEmpleado(Account acc, Contact empleado){
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.AV_ExternalID__c = '00000001';
        opp.Name = 'Alerta Comercial';
        opp.StageName = 'Potencial';
        opp.RecordTypeId = rt.Id;
        opp.CloseDate = System.today() + 5;
        opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
        opp.AV_Gestor__c = empleado.Id;
        opp.AV_PF__c = prodPF.Id;
        insert opp;
        return opp;
    }

    public static Opportunity createOpportunityWithEmpleado(Account acc, Contact empleado, String estado){
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.AV_ExternalID__c = '00000001';
            opp.Name = 'Alerta Comercial';
            opp.StageName = !string.Isblank(estado) ? estado :'Potencial';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_Gestor__c = empleado.Id;
            opp.AV_PF__c = prodPF.Id;
        insert opp;
        return opp;
    }
    
    public static Opportunity createOpportunityWithProductSinInsert(Account acc, Contact empleado, Product2 prodPF, String externalID,Date fechaMod,String status, Recordtype rt){
		//RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPPROPUESTA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		if (externalID!= null) {
			opp.AV_ExternalID__c = externalID;
		} else {
			opp.AV_ExternalID__c = '00000001';
		}
		opp.Name = 'Alerta Comercial';
		if (status != null) {
			opp.StageName = status;
		}else {
			opp.StageName = 'Potencial';
		}
		if (fechaMod!= null) {
			opp.AV_FechaModificacion__c = fechaMod;
		}
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.AV_PF__c = prodPF.Id;
		return opp;
	}
    
    
    public static Account createCustomer(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'Name',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123',
            AV_Negocio__c = 'CIB'
        );
        insert acc;
        return acc;
    }

    public static Account createCustomer2(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'NameTest',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123456',
            AV_Negocio__c = 'BPA',
            CC_Numero_Documento__c = '9446386T'
        );
        insert acc;
        return acc;
    }

    public static Account createCustomer(String numper){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'Name',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = numper,
            AV_Negocio__c = 'CIB'
        );
        insert acc;
        return acc;
    }

    public static Account createCustomer(User owner){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'Name',
            OwnerId = owner.Id,
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123',
            AV_Negocio__c = 'CIB'
        );
        insert acc;
        return acc;
    }
    
    public static Product2 createProduct(Product2 product, String level){
        Product2 prod = new Product2();
        prod.Name = 'Product: ' + getRandomValue();
        prod.AV_Nivel__c = level;
        if(String.isNotBlank(level) && level == '1'){
            prod.AV_ExternalID__c = '50000';
        } else if(String.isNotBlank(level) && level == '10'){
            prod.AV_ExternalID__c = '50001';
        } else if(String.isNotBlank(level) && level == '20'){
            prod.AV_ExternalID__c = '50002';
        } else {
            prod.AV_ExternalID__c = '50003';
        }
        
        if (product!=null){
            prod.AV_NombrePF__c = product.Id;
        }
        prod.AV_Profesional__c = false;
        prod.AV_Activo__c = true;
        insert prod;
        return prod;
    }
    
    public static AV_CustomActivityOpportunity__c createTareaOportunidad(Opportunity opp, String idCabeceraTarea){
        AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
        tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
        tareaOpp.AV_Opportunity__c = opp.Id;
        tareaOpp.AV_Task__c = idCabeceraTarea;
        insert tareaOpp;
        return tareaOpp;
    }
    public static Event createEventWithOpp(User user, Datetime activityDate, Opportunity opp, Account acc){
		RecordType rt = CIBE_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);

		Event event = new Event();
		event.Subject = 'Call';
		event.whatId = acc.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.AV_AssociatedOpportunityId__c = opp.Id;
		event.AV_Tipo__c = 'VC';
		event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
		insert event;
		return event;
	}
    
    public static Event createEvent(User user, Datetime activityDate, Account acc){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        Event event = new Event();
        event.Subject = 'Call';
        event.WhatId = acc.Id;
        if (user!=null){
            event.OwnerId = user.Id;
        }else{
            event.OwnerId = UserInfo.getUserId();
        }
        
        String externalId = '999999';
        AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
            AV_ExternalID__c = externalId,
            AV_ToDelete__c = true
        );
        insert acthead;
        
        String randomExternalId = String.valueof((Math.random() * 10000000));
        event.AV_ExternalID__c = randomExternalId;
        event.RecordTypeId = rt.Id;
        event.DurationInMinutes= 60;
        event.AV_Task__c=acthead.id;
        event.ActivityDateTime = activityDate;
        event.AV_Tipo__c = 'EC';
        event.StartDateTime = activityDate;
        event.EndDateTime = activityDate.addMinutes(60);
        event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
        event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
        event.Description = 'Prueba';
        insert event;
        return event;
    }
    
    public static Event createEventVideocCall(User user, Datetime activityDate, Account acc){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = acc.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.AV_Tipo__c = 'VLD';
		event.StartDateTime = activityDate;
		event.EndDateTime = activityDate.addMinutes(60);
		event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
        event.Description = 'Prueba';
		insert event;
		return event;
	}

    public static Task createTareaExternalId(User user, String externalId){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}		
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}		
		tarea.RecordTypeId = rt.Id;
		insert tarea;
		return tarea;
	}

    public static Event createEventExternalId(User user, Datetime activityDate, String externalId, Account acc){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		if(String.isNotBlank(externalId)){
			event.AV_ExternalID__c = externalId;
		}
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.WhatId = acc.Id;
		insert event;
		return event;
	}
    public static Event createEventActivityDateTime(User user, DateTime activityDate, Account acc){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.WhatId = acc.Id;
        event.CSBD_Evento_Estado__c = 'Pendiente';
		insert event;
		return event;
	}
    public static Task createTareaExternalIdWithCustomer(User user, String externalId, Account acc){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT);
        Task tarea  = new Task();
        tarea.Subject = 'Llamada Saliente';
        if (user!=null){
            tarea.OwnerId = user.Id;
        }else{
            tarea.OwnerId = UserInfo.getUserId();
        }
        tarea.Status = 'Open';
        tarea.Priority = 'Normal';
        if(String.isNotBlank(externalId)){
            tarea.AV_ExternalID__c = externalId;
        }		
        tarea.RecordTypeId = rt.Id;
        if (acc != null) {
            tarea.WhatId = acc.Id;
        }
        insert tarea;
        return tarea;
    }

    public static Task createTareaExternalIdWithCustomerSinInsert(User user, String externalId, Account acc){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT);
        Task tarea  = new Task();
        tarea.Subject = 'Llamada Saliente';
        if (user!=null){
            tarea.OwnerId = user.Id;
        }else{
            tarea.OwnerId = UserInfo.getUserId();
        }
        tarea.Status = 'Open';
        tarea.Priority = 'Normal';
        if(String.isNotBlank(externalId)){
            tarea.AV_ExternalID__c = externalId;
        }		
        tarea.RecordTypeId = rt.Id;
        if (acc != null) {
            tarea.WhatId = acc.Id;
        }
        return tarea;
    }

    public static Task createTareaExternalIdWithCustomerExp(User user, String externalId, Account acc){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT);
        Task tarea  = new Task();
        tarea.Subject = 'Llamada Saliente';
        if (user!=null){
            tarea.OwnerId = user.Id;
        }else{
            tarea.OwnerId = UserInfo.getUserId();
        }
        tarea.Status = 'Open';
        tarea.Priority = 'Normal';
        if(String.isNotBlank(externalId)){
            tarea.AV_ExternalID__c = externalId;
        }		
        tarea.RecordTypeId = rt.Id;
        if (acc != null) {
            tarea.WhatId = acc.Id;
        }
        insert tarea;
        return tarea;
    }
    
    public static Task createTareaExternalIdCustomStatusWithCustomer(User user, String externalId, Account acc, String customStatus){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = customStatus;
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}		
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		insert tarea;
		return tarea;
	}

    public static Task createTareaExternalIdCustomStatusWithCustomerSinInsert(User user, String externalId, Account acc, String customStatus){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		if (user!=null){
			tarea.OwnerId = user.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}
		tarea.Status = customStatus;
		tarea.Priority = 'Normal';
		if(String.isNotBlank(externalId)){
			tarea.AV_ExternalID__c = externalId;
		}		
		tarea.RecordTypeId = rt.Id;
		if (acc != null) {
			tarea.WhatId = acc.Id;
		}
		return tarea;
	}

    public static Event createEventConClienteEAPGestor(User user, Datetime activityDate, Account customer, String gestor){
		RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = customer.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.StartDateTime =activityDate;
		event.EndDateTime =activityDate.addMinutes(60);
		event.AV_Tipo__c = 'VC';
		event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
        event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
		event.AV_CodigoGestorAsignado__c = gestor;
		insert event;
		return event;
	}

    public static Event createEventConClienteEAPGestorSinInsert(User user, Datetime activityDate, Account customer, String gestor){
		RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
		Event event = new Event();
		event.Subject = 'Call';
		event.WhatId = customer.Id;
		if (user!=null){
			event.OwnerId = user.Id;
		}else{
			event.OwnerId = UserInfo.getUserId();
		}
		String randomExternalId = String.valueof((Math.random() * 10000000));
		event.AV_ExternalID__c = randomExternalId;
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes= 60;
		event.ActivityDateTime = activityDate;
		event.StartDateTime =activityDate;
		event.EndDateTime =activityDate.addMinutes(60);
		event.AV_Tipo__c = 'VC';
		event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
        event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
		event.AV_CodigoGestorAsignado__c = gestor;
		return event;
	}

    public static Pricebook2 createPricebook2() {
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		return pb;
	}
    
    public static AV_CustomActivityOpportunity__c createTareaOportunidadExt(Opportunity opp, String extHeaderTask){
        AV_HeaderCustomActivity__c hca = [SELECT Id FROM AV_HeaderCustomActivity__c limit 1];
        return createTareaOportunidad(opp, hca.Id);
    }
    
    public static AccountTeamMember createAccountTeamMember(User empleado, Account cliente){
        AccountTeamMember teamMember  = new AccountTeamMember();
        teamMember.UserId = empleado.Id;
        teamMember.AccountId = cliente.Id;
        teamMember.TeamMemberRole = 'Participante';
        insert teamMember;
        return teamMember;
    }
    
    public static AV_Book__c createPurse(String externalId){
        AV_Book__c book  = new AV_Book__c();
        book.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA, CIBE_AppConstants.CARTERA).Id;
        book.AV_ExternalID__c = externalId;
        book.AV_Activa__c = 'S';
        insert book;
        return book;
    }
    
    public static AV_BookManagementMember__c createBookManagement(Contact empleado, AV_Book__c bk){
        AV_BookManagementMember__c bookMemb  = new AV_BookManagementMember__c();
        bookMemb.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_GESTOR, CIBE_AppConstants.CARTERA_GESTOR).Id;
        bookMemb.AV_EmpleadoGestor__c = empleado.Id;
        bookMemb.AV_Cartera__c = bk.Id;
        insert bookMemb;
        return bookMemb;
    }
    
    public static AV_BookMember__c createBookMember(Account cliente, AV_Book__c bk){
		AV_BookMember__c bookm  = new AV_BookMember__c();
        bookm.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_CLIENTE, CIBE_AppConstants.CARTERA_CLIENTE).Id;
		bookm.AV_Cliente__c = cliente.Id;
		bookm.AV_Cartera__c = bk.Id;
		bookm.AV_CarteraPrincipal__c = true;
		insert bookm;
		return bookm;
	}

    public static Contact createRepresentante(Account cliente, User user, String matricula){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_APODERADO_RT);
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = matricula;
        employee.CIBE_NumPerso__c = matricula;
		if (cliente!=null){
			employee.AccountId = cliente.Id;
		}
		if (user!=null){
			employee.AV_UsuarioAsociado__c = user.Id;
		}else{
			employee.AV_UsuarioAsociado__c = UserInfo.getUserId();
		}
		insert employee;
		return employee;
	}

    public static void activateLogger(){
		AV_ByPass__c byPass = new AV_ByPass__c(
				LogDebug__c=true,
				LogError__c=true,
				LogInfo__c=true,
				LogWarn__c=true
		);
		insert byPass;
	}
    
    public static CIBE_FlowActions__mdt createFlowAction(){
        CIBE_FlowActions__mdt flwAction =new CIBE_FlowActions__mdt(
            Label = 'CIBE_AltaDeActividad',
        	CIBE_FlowName__c = 'CIBE_AltaDeActividad',
            CIBE_Order__c = 1,
            CIBE_Output__c = 'ActivityId',
            CIBE_Setting__c = 'CIBE_Account'
        
        ); 
        
        return flwAction;
    }
    
    public static Event createEventConCliente(User user, Datetime activityDate, Account customer){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        Event event = new Event();
        event.Subject = 'Call';
        event.WhatId = customer.Id;
        if (user!=null){
            event.OwnerId = user.Id;
        }else{
            event.OwnerId = UserInfo.getUserId();
        }
        String randomExternalId = String.valueof((Math.random() * 10000000));
        event.AV_ExternalID__c = randomExternalId;
        event.RecordTypeId = rt.Id;
        event.DurationInMinutes= 60;
        event.ActivityDateTime = activityDate;
        event.StartDateTime =activityDate;
        event.EndDateTime =activityDate.addMinutes(60);
        event.AV_Tipo__c = 'VC';
        event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
        event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP; 
        insert event;
        return event;
    }
    
    
    public static Event createEventConClienteRecurrente(User user, Account customer){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        Event event = new Event();
        event.Subject = 'Test Event 001-A';
		//String randomExternalId = String.valueof((Math.random() * 10000000));
		//event.AV_ExternalID__c = randomExternalId;
        event.WhatId = customer.Id;
        event.RecordTypeId = rt.Id;
        if (user!=null){
            event.OwnerId = user.Id;
        }else{
            event.OwnerId = UserInfo.getUserId();
        }
        event.DurationInMinutes = 60;
        event.ActivityDateTime = System.now();
        event.IsRecurrence = true;
        event.RecurrenceStartDateTime = System.now();
        event.RecurrenceEndDateOnly = System.today()+2;
        event.RecurrenceType = 'RecursEveryWeekday';
        event.RecurrenceDayofWeekMask = 1;
        event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
		event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
		event.AV_Tipo__c = 'VLD';
        
        insert event;
        return event;
    }
    
    //de momento las dos primeras variables pueden ir  null
    //la lista a priori solo necesita estos 3 permisos (CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS)
	public static User loginUser(String profileName, String userRoleDeveloperName, String externalId, List<String> listPermissionSets){    
       	
        if(String.isBlank(profileName)){
            profileName = CIBE_AppConstants.CIBE_GESTOR;
        }
        if(String.isBlank(userRoleDeveloperName)){
            userRoleDeveloperName = CIBE_AppConstants.CIBE_CIBEMPRESAS;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name =:profileName LIMIT 1];
        UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName =:userRoleDeveloperName LIMIT 1];
       	
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
                AV_ExternalID__c = (String.isNotBlank(externalId))?externalId:'U0009003'
            );
        
        insert new List<User>{usrTest};
            
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name =:listPermissionSets];
        for(PermissionSet ps: perSet){
        	PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = usrTest.Id, PermissionSetId = ps.Id);
            permissionSetList.add(pa);
        }
        insert permissionSetList;
                                                                     
        return usrTest;

    }

    public static Account createCaixaCenter2(){
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account centroCaixa = new Account();
        centroCaixa.Name = 'Prueba Test';
        centroCaixa.CC_Numero_Oficina__c = '02615';
        centroCaixa.RecordTypeId = rt.Id;
        insert centroCaixa;
        return centroCaixa;
    }

    public static AV_ProductExperience__c createPFExperience(){
		AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
		prodExp.AV_ExternalID__c = 'BPA004_50003';
		insert prodExp;
		return prodExp;
	}

    public static AV_ProductClient__c createPFCliente(){
		AV_ProductClient__c prodCliente = new AV_ProductClient__c();
		RecordType rt = CIBE_AppUtilities.getRecordType('AV_ProductClient__c', 'AV_ProductoFichaCliente');
		prodCliente.RecordTypeId = rt.Id;
		prodCliente.AV_Activo__c = true;
		prodCliente.AV_TenenciaProducto__c = '1';
		prodCliente.AV_Potencialidad__c = 'S';
		insert prodCliente;
		return prodCliente;
	}

    public static AV_ExperienceBusiness__c createExperienciaNegocio(){
		AV_ExperienceBusiness__c exp = new AV_ExperienceBusiness__c();
		exp.AV_Negocio__c = 'BPA';
		exp.AV_Activo__c = true;
		exp.AV_Orden__c = 1;
		exp.AV_MyBox__c = true;
		exp.AV_CodigoTipoExperiencia__c = '001';
		exp.AV_DescTipoExperiencia__c = 'Día a día';
		exp.AV_ExternalID__c = 'BPA001';
		insert exp;
		return exp;
	}

    public static Lead createLead(){
		RecordType rt = CIBE_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
		Lead le = new Lead();
		le.LastName= 'Last name 1';
		le.FirstName= 'First name 1';
		le.RecordTypeId=rt.Id;
		le.AV_Birthdate__c=Date.newInstance(1968, 12, 9);
		le.AV_IssuingCountry__c='ESP';
		le.AV_CustomerId__c='00000000Z';
		le.AV_CustomerType__c='1';
		le.AV_Requester__c=true;
		le.AV_IsClient__c=false;
		le.AV_PhonePrefix__c='34';
		le.AV_Country__c='ESP';
		le.MobilePhone='000000000';
		insert le;
		return le;
	}

    public static AV_LeadOpportunity__c createLeadOpportunity(Lead le){
		RecordType rt = CIBE_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');
		AV_LeadOpportunity__c leadopp = new AV_LeadOpportunity__c();
		leadopp.AV_CustomerOfferId__c = '0000000';
		leadopp.AV_ExternalId__c = '00dds0df';
		leadopp.AV_PrescriberId__c = 'RASTREATOR COMPARADOR CORREDURIA DE SEGUROS';
		leadopp.AV_Status__c='Nuevo';
		leadopp.AV_StatusLeadOpp__c = 'Potencial';
		leadopp.AV_Lead__c=le.Id;
		leadopp.AV_DueDate__c=Date.newInstance(2070, 01, 01);
		insert leadopp;
		return leadopp;
	}

    public static void insertPermissionSet(String userId, String psLabel){

		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :psLabel];
		insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
	}
    
}