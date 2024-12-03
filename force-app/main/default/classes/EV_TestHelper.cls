/**********************************************************************************************************************
 Name:    EV_TestHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase que crea datos para el testing del resto de clases de eventos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY              AUTHOR              DATE                Description
	1.0         EV_TestHelper           Jorge Centella      10/09/2020          Init version
	1.1         US464719                Mamen Arias         22/11/2022          Add methods createCampaignMemberLeadAccionista() and createCampaignAccionista()
	1.2         US508567                Daniel Rodriguez    05/01/2023          Add methods createChildCampaignFisicaWithSurvey and createCampaignMemberContactFisicaSurvey
	1.3         US499350                Daniel Rodriguez    19/91/2023          Modify method createParentCampaignVirtual
	1.4         US297853                Daniel Rodriguez    29/03/2023          Add method createWrapperJSONInscripcionMultipleEvento
	1.5			US584499				Mamen Arias			26/04/2023			Add methods createCampaignMemberCustomContact, createCampaignMemberCustomContactFisicaSurvey, createCampaignMemberCustomContactEmpresa, 
																				createCampaignMemberCustomLead(Boolean, Boolean), createCampaignMemberCustomLead, createCampaignMemberCustomLeadAccionista, createCMStagingCustom,
																				createChildCampaignFisicaCMCustom, createChildCampaignVirtualCMCustom, createUserTest
	1.6 		US587001				Daniel Rodriguez	23/05/2023			Modify createChildCampaignVirtual(Account center, Campaign campParent) insert of parentid
	1.7			US587006				Mamen Arias			07/06/2023			Add method createWrapperJSONServicesGCF
	1.8         US622078				Carolina Lopez		08/06/2023			Add method createWrapperJSONInscripcionMultiple
	1.9			US586998				Daniel Rodriguez	07/06/2023 			Modify method createCampaignMemberCustomContact
	1.10		US587006				Mamen Arias			08/06/2023			Modify methods createCampaignMemberCustomContactFisicaSurvey, createCampaignMemberCustomContactEmpresa, createCampaignMemberCustomLead
	1.11		US587006				Mamen Arias			20/06/2023			Modify methods createChildCampaignFisicaCMCustom, createChildCampaignVirtualCMCustom (add EV_NewArchitecture__c)
	1.12        US622078				Carolina Lopez		07/07/2023			Add method createParentCampaignTechSummit
	1.13		US602112				Mamen Arias			11/07/2023			Add method createWrapperJSONServicesPortal
	1.14        US661500				Carolina Lopez		25/07/2023			Modify method createWrapperJSONInscripcionMultiple
	1.15        US680535				Humberto Vilchez	01/08/2023			Add createCampaignMemberLeadCampaign for create Campaign Member with custom Lead and Campaign
	1.16	    US680535				Carolina Lopez		18/08/2023			Add methods createCampaignMemberLeadCampaignTechSummit and createCampaignTechSummit
	1.17 		US680535				Carolina Lopez		24/08/2023			Add methods createParentCampaignHibrido, createCentroObjetivo and createTraslationEvt.
	1.18		US704873				Carolina Lopez		13/09/2023			Add method	createCaixaCenterAltaMasiva
	1.19		US585725				Carolina Lopez		21/09/2023			Modify method createTraslationEvt for field validation EV_Claim__c
	1.20		US633077				Mamen Arias			05/10/2023			Modify method createTraduccionesDeEvento for field validation EV_Claim__c
	1.21		US567184				Carolina Lopez		11/10/2023			Add method createEmployeeTestPublic.
***********************************************************************************************************************/
@isTest
public with sharing class EV_TestHelper {

	private static final String MATRICULA_SAMPLE = 'U0009003';
	public static Integer getRandomValue(){
		return Math.round(Math.random()*1000);
	}
	public static String getEmail(){
		Integer rand = getRandomValue();
		Integer rand2 = getRandomValue();
		return 'test' + rand + '@test.env' + rand2 + '.es';
	}

	/*public static Campaign createCampaignCatalogo(){
		if (String.isBlank(labelProfile)){
			labelProfile = 'Standard User';
		}
		
		insert u;
		return u;

	}*/

	public static Contact createContactAux(String lastName){
		Contact contactAux;
		if(lastName != null){
			contactAux = new Contact(LastName = lastName, CC_Numero_Documento__c = '48133877Y', CC_Sexo__c = 'V');
		}else{
			contactAux = new Contact(LastName = 'TestContact', CC_Numero_Documento__c = '48133877Y', CC_Sexo__c = 'V');
		}
		insert contactAux;
		return contactAux;
	}

	public static Contact createEmployee(Account center){
		RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado'); 
		Contact employee = new Contact();
		employee.RecordTypeId = rt.Id;
		employee.FirstName = 'Empleado';
		employee.LastName = '1';
		employee.Email = getEmail();
		employee.CC_Idioma__c = 'es';
		employee.CC_Matricula__c = MATRICULA_SAMPLE;
		if (center!=null){
			employee.AccountId = center.Id;
		}
		insert employee;
		return employee;
	}

	public static List<Contact> createEmployeeTestPublic(){
		RecordType rt = AV_AppUtilities.getRecordType('Contact', 'EV_TestPublic'); 
		List<Contact> lstContact = new List<Contact>();
		lstContact.add(new Contact(
			RecordTypeId = rt.Id,
			FirstName = 'Empleado',
			LastName = '1',
			Email = getEmail(),
			EV_Idiomas__c = '001',
			Phone = '607047934',
			EV_ConsentimientoGeneral__c = true
		));
		lstContact.add(new Contact(
			RecordTypeId = rt.Id,
			FirstName = 'Adolfo',
			LastName = '2',
			Email = getEmail(),
			EV_Idiomas__c = '002',
			Phone = '607047900',
			EV_ConsentimientoGeneral__c = true
		));
		insert lstContact;
		return lstContact;
	}

	public static Lead createLeadAux(String lastName){
		Id rtEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
		Lead leadAux;
		if(lastName != null){
			leadAux = new Lead(firstname = 'Test', lastname = lastName, phone = '123456789', email = 'test@prueba.com', status = 'New', RecordtypeId = rtEvento, EV_Idiomas__c = '001', EV_NumeroDocumento__c = '57956279I', EV_Marketing__c = true, EV_ConsentimientoGeneral__c = true, EV_ConsentimientoTerceros__c = true);
		}else{
			leadAux = new Lead(firstname = 'Test', lastname = 'Lead', phone = '123456789', email = 'test@prueba.com', status = 'New', RecordtypeId = rtEvento, EV_Idiomas__c = '001', EV_NumeroDocumento__c = '57956279I', EV_Marketing__c = true, EV_ConsentimientoGeneral__c = true, EV_ConsentimientoTerceros__c = true);
		}
		insert leadAux;
		return leadAux;
	}

	public static Account createCustomer(){
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				CC_Numero_Documento__c = '48133877Y',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA'
			);
		insert acc;
		return acc;
	}

	public static Contact createContactInterlocutorEmpresa(String lastName){
		RecordType rt = AV_AppUtilities.getRecordType('Contact', 'EV_InterlocutorEmpresa');
		Contact contactAux;
		if(lastName != null){
			contactAux = new Contact(LastName = lastName, CC_Numero_Documento__c = '48133877Y', RecordtypeId = rt.Id);
		}else{
			contactAux = new Contact(LastName = 'TestContact', CC_Numero_Documento__c = '48133877Y', RecordtypeId = rt.Id);
		}
		insert contactAux;
		return contactAux;
	}
	

	public static Account createEmpresa(){
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_Cliente');
		Account acc = new Account(
				Name = 'Test',
				CC_Numero_Documento__c = '48133877Y',
				RecordTypeId = rt.Id,
				//AV_NumPerso__c = String.valueOf(Integer.valueof((Math.random() * 1000))),
				AV_Negocio__c = 'BPA'
			);
		insert acc;
		return acc;
	}

	public static Account createEmpresas(){
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_Cliente');
		List<Account> lstAccounts = new List<Account>();
		Account acc = new Account(
				Name = 'Test',
				CC_Numero_Documento__c = '48133877Y',
				RecordTypeId = rt.Id
			);
			lstAccounts.add(acc);
		Account acc2 = new Account(
			Name = 'Prueba2',
			CC_Numero_Documento__c = '48133877Y',
			RecordTypeId = rt.Id
		);
		lstAccounts.add(acc2);

		insert lstAccounts;
		return acc;
	}

	public static Account createCaixaCenter(){
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_CentroCaixaBank');
		Account centroCaixa = new Account();
		centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
		centroCaixa.CC_Numero_Oficina_Empresa__c = '00615';
		centroCaixa.CC_Numero_Oficina__c = '00615';
		centroCaixa.RecordTypeId = rt.Id;
		insert centroCaixa;
		return centroCaixa;
	}

	public static Account createCaixaCenterAltaMasiva(String name){
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_CentroCaixaBank');
		List<Account> lstAccount = new List<Account>();
		lstAccount.add(new Account(
			Name = '09016 - SIG - TOTAL RED TERRITORIAL',
			CC_Numero_Oficina_Empresa__c = '001-09016',
			CC_Numero_Oficina__c = '00695',
			AV_TipoCentroSuperior__c = 'TE',
			AV_TipoEstructura__c = '02',
			RecordTypeId = rt.Id
		));
		lstAccount.add(new Account(
			Name = name,
			CC_Numero_Oficina_Empresa__c = '00795',
			CC_Numero_Oficina__c = '00795',
			RecordTypeId = rt.Id
		));
		lstAccount.add(new Account(
			Name = name,
			CC_Numero_Oficina_Empresa__c = '00595',
			CC_Numero_Oficina__c = '00595',
			RecordTypeId = rt.Id
		));
		lstAccount.add(new Account(
			Name = name,
			CC_Numero_Oficina_Empresa__c = '00095',
			CC_Numero_Oficina__c = '00095',
			RecordTypeId = rt.Id
		));
		insert lstAccount;
		Account centroCaixa001 = new Account(
			Name = name,
			CC_Numero_Oficina_Empresa__c = '00605',
			CC_Numero_Oficina__c = '00605',
			RecordTypeId = rt.Id,
			AV_CentroSuperior__c = lstAccount[3].Id
		);
		insert centroCaixa001;
		lstAccount[3].AV_CentroSuperior__c = lstAccount[2].Id;
		lstAccount[2].AV_CentroSuperior__c = lstAccount[1].Id;
		lstAccount[1].AV_CentroSuperior__c = lstAccount[0].Id; 

		update lstAccount;
		return centroCaixa001;
	}

	
	public static Campaign createCampaignAccionista(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_Eventos_Accionistas').getRecordTypeId();

		Campaign campAccionista = new Campaign(
			Name = 'TestCampaignAccionista',
			EV_ExternalId__c = '789132456',
			RecordTypeId = rtEvento,
			EV_ProgramaDeEventos__c = '012',
			EV_TipoEvento__c = '001',
			EV_Categoria__c = '001',
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00),
			Ev_Notification__c = '001',
			Status = '009',
			EV_Cartera__c = 'BPA'
		);

		insert campAccionista;
		return campAccionista;
	}

	public static Campaign createChildCampaignVirtual(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			EV_ExternalId__c = '234567890',
			RecordTypeId = rtEvento,
			StartDate = Date.today(),
			EV_DiaHora_evento__c = datetime.now().addhours(1),
			EV_HoraInicio__c = Time.newInstance(20, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(22, 00, 00, 00),
			EV_ChatEvento__c = true,
			EV_URLDelEventoVirtual__c = 'test.prueba.com',
			EV_URLImagenVideo__c = 'test.prueba.com',
			EV_URLChatVirtual__c = 'test.prueba.com',
			EV_NumeroDePlazas__c = 100,
			Ev_Notification__c = '001',
			Status = '009',
			EV_Cartera__c = 'BPA',
			CampaignMemberRecordTypeId = rtEventoMember
		); 
		insert campVirtual;
		return campVirtual;
	}

	public static Campaign createChildCampaignVirtualCMCustom(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			EV_ExternalId__c = '234567890',
			RecordTypeId = rtEvento,
			StartDate = Date.today(),
			EV_DiaHora_evento__c = datetime.now().addhours(1),
			EV_HoraInicio__c = Time.newInstance(20, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(22, 00, 00, 00),
			EV_ChatEvento__c = true,
			EV_URLDelEventoVirtual__c = 'test.prueba.com',
			EV_URLImagenVideo__c = 'test.prueba.com',
			EV_URLChatVirtual__c = 'test.prueba.com',
			EV_NumeroDePlazas__c = 100,
			Ev_Notification__c = '001',
			Status = '009',
			EV_Cartera__c = 'BPA',
            EV_NewArchitecture__c = true
			//CampaignMemberRecordTypeId = rtEventoMember
		);
		insert campVirtual;
		return campVirtual;
	}

	public static Campaign createChildCampaignVirtual(Account center, Campaign campParent){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		
		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			EV_ExternalId__c = '1234567890',
			RecordTypeId = rtEvento,
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(23, 00, 00, 00),
			EV_HoraFin__c = Time.newInstance(23, 30, 00, 00),
			EV_ChatEvento__c = true,
			EV_URLDelEventoVirtual__c = 'test.prueba.com',
			EV_URLChatVirtual__c = 'test.prueba.com',
			EV_URLImagenVideo__c = 'test.prueba.com',
			EV_NumeroDePlazas__c = 100,
			Ev_Notification__c = '001',
			Status = '009',
			CampaignMemberRecordTypeId = rtEventoMember,
			EV_Cartera__c = 'BPA'
		); 
		if (center!=null){
			campVirtual.EV_CentroOrganizador__c= center.Id;
		}		
		
		if (campParent != null) {
			campVirtual.ParentId = campParent.Id;
			List<EV_TraduccionDeEvento__c> traducciones = createTraduccionesDeEvento(campParent.Id);
            insert campVirtual;
		}else{
            insert campVirtual;
			List<EV_TraduccionDeEvento__c> traducciones = createTraduccionesDeEvento(campVirtual.Id);
		}
		return campVirtual;
	}

	public static EV_NoClienteWrapper.RequestInscripcionBodyMultiple createWrapperJSONInscripcionMultiple(List<String> idEvento, String idInvitacion, Boolean personaJuridica){
		EV_NoClienteWrapper.RequestInscripcionBodyMultiple wrapperJSON = new EV_NoClienteWrapper.RequestInscripcionBodyMultiple();
		List<String> lstEvt = new List<String>();
		if(personaJuridica){
			EV_NoClienteWrapper wrappernoCliente = new EV_NoClienteWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.NombreEmpresa = 'TestEmpresa';
			wrappernoCliente.NIFEmpresa = '48133877Y';
			wrappernoCliente.Cargo = 'Director General';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			if(!idEvento.isEmpty()){
				for(String cm : idEvento){
					lstEvt.add(cm);
				}
			}
			wrapperJSON.lstIdEvento = lstEvt;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}else{
			EV_NoClienteWrapper wrappernoCliente = new EV_NoClienteWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			if(!idEvento.isEmpty()){
				for(String cm : idEvento){
					lstEvt.add(cm);
				}
			}
			wrapperJSON.lstIdEvento = lstEvt;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}
		return wrapperJSON;
	}

	public static EV_NoClienteWrapper.RequestInscripcionBody createWrapperJSONInscripcion(String idEvento, String idInvitacion, Boolean personaJuridica){
		EV_NoClienteWrapper.RequestInscripcionBody wrapperJSON = new EV_NoClienteWrapper.RequestInscripcionBody();
		if(personaJuridica){
			EV_NoClienteWrapper wrappernoCliente = new EV_NoClienteWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.NombreEmpresa = 'TestEmpresa';
			wrappernoCliente.NIFEmpresa = '48133877Y';
			wrappernoCliente.Cargo = 'Director General';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			wrapperJSON.idEvento = idEvento;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}else{
			EV_NoClienteWrapper wrappernoCliente = new EV_NoClienteWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			wrapperJSON.idEvento = idEvento;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}
		return wrapperJSON;
	}

	public static EV_AccionistaClienteWrapper.RequestInscripcionBody createWrapperJSONInscripcionAccionista(String idEvento, String idInvitacion, Boolean personaJuridica){
		EV_AccionistaClienteWrapper.RequestInscripcionBody wrapperJSON = new EV_AccionistaClienteWrapper.RequestInscripcionBody();
		if(personaJuridica){
			EV_AccionistaClienteWrapper wrappernoCliente = new EV_AccionistaClienteWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.NombreEmpresa = 'TestEmpresa';
			wrappernoCliente.NIFEmpresa = '48133877Y';
			wrappernoCliente.Cargo = 'Director General';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			EV_AccionistaClienteWrapper.Companion comp = new EV_AccionistaClienteWrapper.Companion();
			comp.Nombre = 'Cliente';
			comp.Apellidos = 'Acompañante';
			comp.Documento = '87654321G';
			wrappernoCliente.companion = comp;
			wrapperJSON.idEvento = idEvento;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}else{
			EV_AccionistaClienteWrapper wrappernoCliente = new EV_AccionistaClienteWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			EV_AccionistaClienteWrapper.Companion comp = new EV_AccionistaClienteWrapper.Companion();
			comp.Nombre = 'Cliente';
			comp.Apellidos = 'Acompañante';
			comp.Documento = '87654321G';
			wrappernoCliente.companion = comp;
			wrapperJSON.idEvento = idEvento;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}
		return wrapperJSON;
	}

	public static EV_NoClienteMultipleWrapper.RequestInscripcionBody createWrapperJSONInscripcionMultipleEvento(String idEvento, String idInvitacion, Boolean personaJuridica){
		EV_NoClienteMultipleWrapper.RequestInscripcionBody wrapperJSON = new EV_NoClienteMultipleWrapper.RequestInscripcionBody();
		Integer i = 0;
		List<EV_NoClienteMultipleWrapper.Companion> comp = new List<EV_NoClienteMultipleWrapper.Companion>();
		if(personaJuridica){
			EV_NoClienteMultipleWrapper wrappernoCliente = new EV_NoClienteMultipleWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.NombreEmpresa = 'TestEmpresa';
			wrappernoCliente.NIFEmpresa = '48133877Y';
			wrappernoCliente.Cargo = 'Director General';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			for(i= 0; i< 3; i++){
				EV_NoClienteMultipleWrapper.Companion c = new EV_NoClienteMultipleWrapper.Companion();
				c.Nombre = 'Cliente '+ i;
				c.Apellidos = 'Acompañante '+ i;
				c.Documento = '87654321'+ i +'G';
				comp.add(c);
			}
			wrappernoCliente.companion = comp;
			wrapperJSON.idEvento = idEvento;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}else{
			EV_NoClienteMultipleWrapper wrappernoCliente = new EV_NoClienteMultipleWrapper();
			wrappernoCliente.Nombre = 'TestNoCliente';
			wrappernoCliente.Apellidos = 'No Cliente';
			wrappernoCliente.Documento = '12345678H';
			wrappernoCliente.Phone = '123456789';
			wrappernoCliente.Idioma = '002';
			wrappernoCliente.ConsentimientoTerceros = true;
			wrappernoCliente.Marketing = true;
			wrappernoCliente.ConsentimientoGeneral = true;
			wrappernoCliente.Email = 'testnocliente@test.com';
			for(i= 0; i< 3; i++){
				EV_NoClienteMultipleWrapper.Companion c = new EV_NoClienteMultipleWrapper.Companion();
				c.Nombre = 'Cliente '+ i;
				c.Apellidos = 'Acompañante '+ i;
				c.Documento = '87654321'+ i +'G';
				comp.add(c);
			}
			wrappernoCliente.companion = comp;
			wrapperJSON.idEvento = idEvento;
			wrapperJSON.idInvitacion = idInvitacion;
			wrapperJSON.datosFormulario = wrappernoCliente;
		}
		return wrapperJSON;
	}

	public static EV_WS_GetEvents.RequestServicesGCFBody createWrapperJSONServicesGCF(String servicio, String numperso, List<String> idioma, String numOficina, String externalIdCampaign, String externalIdCM, Date fecha){
		EV_WS_GetEvents.RequestServicesGCFBody wrapperServices = new EV_WS_GetEvents.RequestServicesGCFBody();
		if (servicio.equals('list-by-client') || servicio.equals('past-list-by-client') || servicio.equals('future-registered-list-by-client') || servicio.equals('future-interested-list-by-client') 
			|| servicio.equals('future-list-by-client') || servicio.equals('pass-and-future-list-by-client')){
			wrapperServices.servicio = servicio;
			wrapperServices.numperso = numperso;
			wrapperServices.idioma = idioma;
		} else if (servicio.equals('list-by-office') || servicio.equals('inprogress-list-by-office')){
			wrapperServices.servicio = servicio;
			wrapperServices.numOficina = numOficina;
			wrapperServices.idioma = idioma;
		} else if (servicio.equals('client-and-event-list-by-date')){
			wrapperServices.servicio = servicio;
			wrapperServices.fecha = fecha;
		} else if (servicio.equals('detail-list-by-externalid-and-language')){
			wrapperServices.servicio = servicio;
			wrapperServices.externalIdCampaign = externalIdCampaign;
			wrapperServices.idioma = idioma;
		} else if (servicio.equals('detail-by-externalid')){
			wrapperServices.servicio = servicio;
			wrapperServices.externalIdCM = externalIdCM;
			wrapperServices.idioma = idioma;
		} else if (servicio.equals('detail-by-externalid-and-client')){
			wrapperServices.servicio = servicio;
			wrapperServices.externalIdCampaign = externalIdCampaign;
			wrapperServices.numperso = numperso;
			wrapperServices.idioma = idioma;
		} else if (servicio.equals('registered-client-list-by-externalid')){
			wrapperServices.servicio = servicio;
			wrapperServices.externalIdCampaign = externalIdCampaign;
        } else if (servicio.equals('client-by-externalid') || servicio.equals('client-unsubscribed-event')){
			wrapperServices.servicio = servicio;
            wrapperServices.externalIdCM = externalIdCM;
        }

		return wrapperServices;
	}
    
    public static EV_WS_GetEventsPortal.RequestServicesPortalBody createWrapperJSONServicesPortal(String servicio, String numperso, String idioma){
		EV_WS_GetEventsPortal.RequestServicesPortalBody wrapperServices = new EV_WS_GetEventsPortal.RequestServicesPortalBody();
		if (servicio.equals('slider-home-events-by-client') || servicio.equals('future-events-by-client') || servicio.equals('past-events-by-client') || 
           servicio.equals('most-viewed-events-by-client')){
			wrapperServices.servicio = servicio;
			wrapperServices.numperso = numperso;
			wrapperServices.idioma = idioma;
		}

		return wrapperServices;
	}

	public static Campaign createChildCampaignFisica(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_ExternalId__c = '123456789',
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00),
			Ev_Notification__c = '001',
			CampaignMemberRecordTypeId = rtEventoMember
		); 
		insert campVirtual;
		return campVirtual;
	}

	public static Campaign createChildCampaignFisicaCMCustom(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_ExternalId__c = '123456789',
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00),
			EV_Notification__c = '001',
            EV_NewArchitecture__c = true
		); 
		insert campVirtual;
		return campVirtual;
	}

	@isTest (SeeAllData=true)
	public static Campaign createChildCampaignFisicaWithSurvey(){
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
		Id rtEventoMember = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		
		//Survey surv = [SELECT Id FROM Survey LIMIT 1];
		Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_ExternalId__c = '123456789',
			StartDate = Date.today(),
			EV_Encuesta__c = surv.id,
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00),
			Ev_Notification__c = '001',
			CampaignMemberRecordTypeId = rtEventoMember
		); 
		insert campVirtual;
		System.runAs(user)
		{ 
		System.assertEquals('TestCampaign', campVirtual.Name);
		}
		return campVirtual;
	}


	public static List<EV_TraduccionDeEvento__c> createTraslationEvt(Campaign camp){
		List<EV_TraduccionDeEvento__c> lstTra = new List<EV_TraduccionDeEvento__c>();
		lstTra.add(new EV_TraduccionDeEvento__c(
                EV_Descripcion__c = 'testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest',
                EV_Claim__c ='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest',
                EV_Idioma__c = '002',
                EV_Evento__c = camp.Id,
                Name = 'test',
                EV_URLImagenInvitacion__c = 'test',
                EV_SinopsisInvitacion__c = 'test'
            ));
			lstTra.add(new EV_TraduccionDeEvento__c(
                EV_Descripcion__c = 'testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest',
                EV_Claim__c ='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest',
                EV_Idioma__c = '001',
                EV_Evento__c = camp.Id,
                Name = 'test',
                EV_URLImagenInvitacion__c = 'test',
                EV_SinopsisInvitacion__c = 'test'
            ));
		insert lstTra;
		return lstTra;
	}

	public static Centro_Objetivo__c createCentroObjetivo(Account cuenta, Campaign camp){
		Centro_Objetivo__c centro =  new Centro_Objetivo__c(
			EV_Centro__c = cuenta.Id, 
			EV_Campaign__c = camp.Id
		);
		insert centro; 
		return centro;
	} 

	public static Campaign createParentCampaignHibrido(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_CatalogoEventoHibrido').getRecordTypeId();

		Campaign campHibrido = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_Cartera__c= 'BPA',
			EV_Provincia__c = 'BARCELONA',
			EV_HoraInicio__c = Time.newInstance(14, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(15, 30, 00, 00), 
			EV_DiaHora_evento__c = datetime.now().addhours(1),
			StartDate = date.today()
		); 
		insert campHibrido;
		return campHibrido;
	}
	
	public static Campaign createParentCampaignFisica(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_CatalogoEventoFisico').getRecordTypeId();

		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento
		); 
		insert campVirtual;
		return campVirtual;
	}

	public static Campaign createParentCampaignVirtual(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_CatalogoEventoVirtual').getRecordTypeId();

		Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_Cartera__c= 'BPA',
			EV_NumeroDePlazas__c = 100,
			EV_DiaHora_evento__c = datetime.now().addhours(1),
			EV_HoraInicio__c = Time.newInstance(14, 30, 00, 00),
			StartDate = date.today(),
			EV_HoraFin__c = Time.newInstance(15, 30, 00, 00)
		); 
		insert campVirtual;
		return campVirtual;
	}
    
    public static Campaign createCampaignTechSummit(boolean xvirtual, boolean xfisico){
		Id rtTech = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
		Campaign cTech = new Campaign();
		cTech.Name = 'TestCampaign';
		cTech.EV_TechSummit__c = true;
		cTech.EV_NewArchitecture__c = true;
		cTech.EV_Cartera__c= 'BPA';
		cTech.EV_Notification__c = '001';
		cTech.EV_NumeroDePlazas__c = 100;
		cTech.EV_DiaHora_evento__c = datetime.now().addhours(1);
		cTech.EV_HoraInicio__c = Time.newInstance(14, 30, 00, 00);
		cTech.StartDate = date.today();
		cTech.EV_HoraFin__c = Time.newInstance(15, 30, 00, 00);

		if(xvirtual == true){
			cTech.RecordTypeId = rtTech;
		}else {
			cTech.RecordTypeId = rtEvento;
		}

		insert cTech;
		return cTech;
	}

    public static Campaign createParentCampaignTechSummit(){
		Id rtTech = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();

		Campaign cTech = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtTech,
			EV_TechSummit__c = true,
            EV_NewArchitecture__c = true,
			EV_Cartera__c= 'BPA',
            EV_Notification__c = '001',
			EV_NumeroDePlazas__c = 100,
			EV_DiaHora_evento__c = datetime.now().addhours(1),
			EV_HoraInicio__c = Time.newInstance(14, 30, 00, 00),
			StartDate = date.today(),
			EV_HoraFin__c = Time.newInstance(15, 30, 00, 00)
		); 
		insert cTech;
		return cTech;
	}

	public static List<EV_TraduccionDeEvento__c> createTraduccionesDeEvento(Id idEvento){
		List<EV_TraduccionDeEvento__c> lstTraducciones = new List<EV_TraduccionDeEvento__c>();

		EV_TraduccionDeEvento__c trad1 = new EV_TraduccionDeEvento__c(
			Name = 'TestCampaign',
			EV_Idioma__c = '001',
			EV_Evento__c = idEvento, 
			EV_Descripcion__c = 'Muy lejos, más allá de las montañas de palabras, alejados de los países de las vocales y las consonantes, viven los textos simulados. Viven aislados en casas de letras, en la costa de la semántica, un gran océano de lenguas. Un riachuelo llamado Pons',
			EV_URLImagenEsperaStreaming__c = 'test.prueba.com',
			EV_URLVideoTeaser__c = 'test.prueba.com',
			EV_Claim__c ='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest'
		); 
		lstTraducciones.add(trad1);

		EV_TraduccionDeEvento__c trad2 = new EV_TraduccionDeEvento__c(
			Name = 'TestCampaign',
			EV_Evento__c = idEvento, 
			EV_Idioma__c = '002',
			EV_Descripcion__c = 'Muy lejos, más allá de las montañas de palabras, alejados de los países de las vocales y las consonantes, viven los textos simulados. Viven aislados en casas de letras, en la costa de la semántica, un gran océano de lenguas. Un riachuelo llamado Pons',
			EV_URLImagenEsperaStreaming__c = 'test.prueba.com',
			EV_URLVideoTeaser__c = 'test.prueba.com',
			EV_Claim__c ='testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest'
		);
		lstTraducciones.add(trad2);

		insert lstTraducciones;
		return lstTraducciones;
	}

	public static CampaignMember createCampaignMemberContact(Boolean campaignFisica, Boolean campaignVirtual){
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		CampaignMember campMember = new CampaignMember();
		if(campaignFisica == true && campaignVirtual == false){
			campMember.ContactId = createContactAux('TestContact').Id;
			campMember.CampaignId = createChildCampaignFisica().Id;
			campMember.EV_ExternalId__c = '123456789';
			campMember.status = 'Pendiente';
			
		}else if(campaignVirtual == true && campaignFisica == false){
			campMember.ContactId = createContactAux('TestContact').Id;
			campMember.CampaignId = createChildCampaignVirtual().Id;
			campMember.EV_ExternalId__c = '123456789';
			campMember.status = 'Pendiente';
			
		}
		
		insert campMember;
		return campMember;
	}
    

	public static EV_CampaignMemberC__c createCampaignMemberCustomContact(Boolean campaignFisica, Boolean campaignVirtual){
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		
		if(campaignFisica == true && campaignVirtual == false){
            campMember.RecordTypeId = rtEvento;
			campMember.EV_ContactId__c = createContactAux('TestContact').Id;
			campMember.EV_CampaignId__c = createChildCampaignFisicaCMCustom().Id;
			campMember.EV_ExternalID__c = '123456789';
			campMember.EV_Status__c = 'Pendiente';
		}else if(campaignVirtual == true && campaignFisica == false){
            campMember.RecordTypeId = rtEvento;
			campMember.EV_ContactId__c = createContactAux('TestContact').Id;
			campMember.EV_CampaignId__c = createChildCampaignVirtualCMCustom().Id;
			campMember.EV_ExternalID__c = '123456789';
			campMember.EV_Status__c = 'Pendiente';
		}
		
		insert campMember;
		return campMember;
	}
	
	public static CampaignMember createCampaignMemberContactFisicaSurvey(String status){
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		CampaignMember campMember = new CampaignMember();
		campMember.ContactId = createContactAux('TestContact').Id;
		campMember.CampaignId = createChildCampaignFisicaWithSurvey().Id;
		campMember.EV_ExternalId__c = '123456789';
		campMember.status = Status;
		insert campMember;
		return campMember;
	}

	public static EV_CampaignMemberC__c createCampaignMemberCustomContactFisicaSurvey(String status){
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		campMember.RecordTypeId = rtEvento;
		campMember.EV_ContactId__c = createContactAux('TestContact').Id;
		campMember.EV_CampaignId__c = createChildCampaignFisicaWithSurvey().Id;
		campMember.EV_ExternalID__c = '123456789';
		campMember.EV_Status__c = Status;
		insert campMember;
		return campMember;
	}

	public static EV_CampaignMemberC__c createCampaignMemberLeadCampaign(String leadId, String campaignId, String status){
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		campMember.RecordTypeId = rtEvento;
		campMember.EV_LeadId__c = leadId;
		campMember.EV_CampaignId__c = campaignId;
		campMember.EV_ExternalID__c = '123456789';
		campMember.EV_Status__c = Status;
		insert campMember;
		return campMember;
	}

	public static CampaignMember createCampaignMemberContactEmpresa(Boolean campaignFisica, Boolean campaignVirtual){
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		CampaignMember campMember = new CampaignMember();
		if(campaignFisica == true && campaignVirtual == false){
			campMember.ContactId = createContactAux('TestContact').Id;
			campMember.CampaignId = createChildCampaignFisica().Id;
			campMember.EV_ExternalId__c = '123456789';
			campMember.status = 'Pendiente';
			campMember.EV_Empresa__c = false;
			
		}else if(campaignVirtual == true && campaignFisica == false){
			campMember.ContactId = createContactAux('TestContact').Id;
			campMember.CampaignId = createChildCampaignVirtual().Id;
			campMember.EV_ExternalId__c = '123456789';
			campMember.status = 'Pendiente';
			campMember.EV_Empresa__c = false;
		}
		
		insert campMember;
		return campMember;
	}

	public static EV_CampaignMemberC__c createCampaignMemberCustomContactEmpresa(Boolean campaignFisica, Boolean campaignVirtual){
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		if(campaignFisica == true && campaignVirtual == false){
			campMember.RecordTypeId = rtEvento;
			campMember.EV_ContactId__c = createContactAux('TestContact').Id;
			campMember.EV_CampaignId__c = createChildCampaignFisicaCMCustom().Id;
			campMember.EV_ExternalID__c = '123456789';
			campMember.EV_Status__c = 'Pendiente';
			campMember.EV_Empresa__c = false;
			
		}else if(campaignVirtual == true && campaignFisica == false){
			campMember.RecordTypeId = rtEvento;
			campMember.EV_ContactId__c = createContactAux('TestContact').Id;
			campMember.EV_CampaignId__c = createChildCampaignVirtualCMCustom().Id;
			campMember.EV_ExternalID__c = '123456789';
			campMember.EV_Status__c = 'Pendiente';
			campMember.EV_Empresa__c = false;
		}
		
		insert campMember;
		return campMember;
	}

	public static CampaignMember createCampaignMemberLead(Boolean campaignFisica, Boolean campaignVirtual){
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		CampaignMember campMember = new CampaignMember();
		if(campaignFisica == true && campaignVirtual == false){
			campMember.LeadId = createLeadAux('TestLead').Id;
			campMember.CampaignId = createChildCampaignFisica().Id;
			campMember.EV_ExternalId__c = '123456789';
			
		}else if(campaignVirtual == true && campaignFisica == false){
			campMember.LeadId = createLeadAux('TestLead').Id;
			campMember.CampaignId = createChildCampaignVirtual().Id;
			campMember.EV_ExternalId__c = '123456789';
		}
		
		insert campMember;
		return campMember;
	}

	public static EV_CampaignMemberC__c createCampaignMemberCustomLead(Boolean campaignFisica, Boolean campaignVirtual){
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		if(campaignFisica == true && campaignVirtual == false){
			campMember.RecordTypeId = rtEvento;
			campMember.EV_LeadId__c = createLeadAux('TestLead').Id;
			campMember.EV_CampaignId__c = createChildCampaignFisicaCMCustom().Id;
			campMember.EV_ExternalID__c = '123456789';
			
		}else if(campaignVirtual == true && campaignFisica == false){
			campMember.RecordTypeId = rtEvento;
			campMember.EV_LeadId__c = createLeadAux('TestLead').Id;
			campMember.EV_CampaignId__c = createChildCampaignVirtualCMCustom().Id;
			campMember.EV_ExternalID__c = '123456789';
		}
		
		insert campMember;
		return campMember;
	}
	
	public static CampaignMember createCampaignMemberLead(){
		Id rtEventoL = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
		Lead l = new Lead(
			FirstName = 'Test',
			LastName = 'Prueba q',
			Phone = '123456789',
			Email = 'testnocliente@test.com',
			Status = 'New',
			RecordtypeId = rtEventoL,
			EV_Idiomas__c = '001',
			EV_NumeroDocumento__c = '57956279I',
			EV_ConsentimientoGeneral__c = false
		);
		insert l;
		CampaignMember campMember = new CampaignMember();
		campMember.LeadId =l.Id;
		campMember.CampaignId = createChildCampaignVirtual().Id;
		campMember.EV_ExternalId__c = '123456789';
		
		insert campMember;
		return campMember;
	}

	public static EV_CampaignMemberC__c createCampaignMemberLeadCampaignTechSummit(String leadId, String campaignId, String status){
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		campMember.RecordTypeId = rtEvento;
		campMember.EV_LeadId__c = leadId;
		campMember.EV_CampaignId__c = campaignId;
		campMember.EV_Status__c = Status;
		insert campMember;
		return campMember;
	}


	public static EV_CampaignMemberC__c createCampaignMemberCustomLead(){
		Id rtEventoL = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
		Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		Lead l = new Lead(
			FirstName = 'Test',
			LastName = 'Prueba q',
			Phone = '123456789',
			Email = 'testnocliente@test.com',
			Status = 'New',
			RecordtypeId = rtEventoL,
			EV_Idiomas__c = '001',
			EV_NumeroDocumento__c = '57956279I',
			EV_ConsentimientoGeneral__c = false
		);
		insert l;
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		campMember.RecordTypeId = rtEvento;
		campMember.EV_LeadId__c = l.Id;
		campMember.EV_CampaignId__c = createChildCampaignVirtualCMCustom().Id;
		campMember.EV_ExternalID__c = '123456789';

		insert campMember;
		return campMember;
   }

	public static CampaignMember createCampaignMemberLeadAccionista(){
		Id rtEventoL = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadAccionistas').getRecordTypeId();
		Lead l = new Lead(
			FirstName = 'Test',
			LastName = 'Prueba accionista',
			Phone = '123456789',
			Email = 'testleadaccionista@test.com',
			Status = 'New',
			RecordtypeId = rtEventoL,
			EV_Idiomas__c = '001',
			EV_NumeroDocumento__c = '84255961F',
			EV_ConsentimientoGeneral__c = false
		);
		insert l;
		CampaignMember campMember = new CampaignMember();
		campMember.LeadId =l.Id;
		campMember.CampaignId = createCampaignAccionista().Id;
		campMember.EV_ExternalId__c = '123789456';
	   
		insert campMember;
		return campMember;
   	}

   	public static EV_CampaignMemberC__c createCampaignMemberCustomLeadAccionista(){
		Id rtAccionistaLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadAccionistas').getRecordTypeId();
		Id rtAccionista = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosAccionistas').getRecordTypeId();
		Lead l = new Lead(
			FirstName = 'Test',
			LastName = 'Prueba accionista',
			Phone = '123456789',
			Email = 'testleadaccionista@test.com',
			Status = 'New',
			RecordtypeId = rtAccionistaLead,
			EV_Idiomas__c = '001',
			EV_NumeroDocumento__c = '84255961F',
			EV_ConsentimientoGeneral__c = false
		);
		insert l;

		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		campMember.EV_LeadId__c =l.Id;
		campMember.EV_CampaignId__c = createCampaignAccionista().Id;
		campMember.EV_ExternalID__c = '123789456';
		campMember.RecordTypeId = rtAccionista;
		insert campMember;
		return campMember;
	}

	public static List<EV_VariablePublicoOjetivo__c> createVariablePublicoObjetivo(Map<String, EV_MappingCriterioPO__mdt> mapMC){
		List<EV_VariablePublicoOjetivo__c> listVariablePO = new List<EV_VariablePublicoOjetivo__c>();
		for(EV_MappingCriterioPO__mdt wrapper: mapMC.values()) {
			EV_VariablePublicoOjetivo__c variablePO = new EV_VariablePublicoOjetivo__c();
			variablePO.Name = wrapper.Label;
			variablePO.EV_CategoriaVariable__c = 'General';
			variablePO.EV_TipoVariable__c = 'Numérico';
			variablePO.EV_VariableAdobeCampaign__c = wrapper.Label;
			listVariablePO.add(variablePO);
		}

		insert listVariablePO;
		return listVariablePO;
	}

	public static List<EV_CriterioPublicoObjetivo__c> createPublicObjetivo(Id idEvento, List<EV_VariablePublicoOjetivo__c> lstVariablePO){
		List<EV_CriterioPublicoObjetivo__c> lstCriterioPublicoObjetivo = new List<EV_CriterioPublicoObjetivo__c>();
		for(EV_VariablePublicoOjetivo__c varPO: lstVariablePO){
			EV_CriterioPublicoObjetivo__c criterioPO = new EV_CriterioPublicoObjetivo__c();
			if (varPO.Name.contains('DT')||varPO.Name.contains('DAN')||varPO.Name.contains('OFICINA') ) {
				criterioPO.EV_ValorCriterio__c = '00046, 00056';
			}else {
				criterioPO.EV_ValorCriterio__c = '1';
			}
			criterioPO.EV_Evento__c = idEvento;
			criterioPO.EV_Activo__c = true;
			
			criterioPO.EV_VariablePublicoObjetivo__c = varPO.Id;
			lstCriterioPublicoObjetivo.add(criterioPO);
		}
		
		insert lstCriterioPublicoObjetivo;
		return lstCriterioPublicoObjetivo;
	}

	public static EV_CriterioPublicoObjetivoAdobeCampaign__c createCriterioPOAdobeCampaign(Id idEvento){
		EV_CriterioPublicoObjetivoAdobeCampaign__c criterioPOAdobeCampaign = new EV_CriterioPublicoObjetivoAdobeCampaign__c();
		criterioPOAdobeCampaign.Name = 'PO2';
		criterioPOAdobeCampaign.EV_Evento__c = idEvento;
		 
		insert criterioPOAdobeCampaign;
		return criterioPOAdobeCampaign;
	}

	public static EV_CustomOptions__c createCustomOptions(){
		EV_CustomOptions__c lstCustomOptions = new EV_CustomOptions__c();
		lstCustomOptions.Name = 'Catalan';
		lstCustomOptions.EV_PicklistName__c = 'optionsIdioma';
		lstCustomOptions.EV_Value__c = '1';

		insert lstCustomOptions;
		return lstCustomOptions;
	}

	public static User createUser(String labelProfile){
		if (String.isBlank(labelProfile)){
			labelProfile = 'EV_Eventos';
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
				ProfileId = p.Id,
				UserName = username,
				AV_ExternalID__c = MATRICULA_SAMPLE,
				EmployeeNumber = MATRICULA_SAMPLE,
				IsActive= true
			);
		
		insert u;
		return u;
	}

	public static User createUserPartner(String labelProfile, Account center){
		UserRole userrole = [Select Id, DeveloperName, Name From UserRole Where Name = 'Eventos' Limit 1];

		User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];

		adminUser.UserRoleId = userrole.Id;
		update adminUser;
		User u = new User();
		System.runAs(adminUser){
			List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
			String username = getEmail();
			Profile p = (Profile)result.get(0);
			
					u.Alias = 'tsAlias';
					u.Email = 'test@test.dev';
					u.EmailEncodingKey = 'UTF-8';
					u.LastName = 'testLastName';
					u.LanguageLocaleKey = 'es';
					u.LocaleSidKey = 'es';
					u.TimeZoneSidKey = 'Europe/Berlin';
					u.ProfileId = p.Id;
					u.UserName = username;
					u.AV_ExternalID__c = 'U0126585';
					u.EmployeeNumber = 'U0126585';
					u.IsActive= true;
				
			if (labelProfile == 'Partner Portal Community Profile') {
				u.ContactId = createEmployee(center).Id;
			}
			insert u;
		}
		
		return u;
	}

	public static User createUserTest (String psGroup, String profile, String role){
		User userTest;
		Profile userProfile = [SELECT Id FROM Profile WHERE Name = :profile LIMIT 1];
		UserRole userRole = [SELECT Id FROM UserRole WHERE Name = :role LIMIT 1];
		String username = getEmail();
		System.runAs (new User(Id = UserInfo.getUserId())){
			userTest = new User(
				LastName = 'userTest',
				Email = 'test@test.com',
				Username = username,
				Alias = 'test',
				ProfileId = userProfile.Id,
				UserRoleId = userRole.Id,
				EmailEncodingKey = 'ISO-8859-1',
				TimeZoneSidKey = 'Europe/Paris',
				LocaleSidKey = 'es_ES',
				LanguageLocaleKey = 'en_US',
				isActive = true
			);
		}
		insert userTest;

		List<PermissionSetAssignment> listNewPermissions = new List<PermissionSetAssignment>();
		for (PermissionSetGroupComponent unitPermission : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName = :psGroup]){
			PermissionSetAssignment newPermission = new PermissionSetAssignment();
			newPermission.PermissionSetId = unitPermission.PermissionSetId;
			newPermission.AssigneeId = userTest.Id;
			listNewPermissions.add(newPermission);
		}

		if (!listNewPermissions.isEmpty()){
			insert listNewPermissions;
		}

		return userTest;
	}

	public static EV_CampaingMemeberStaging__c createCMStaging(CampaignMember cm) {

		EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c(
			EV_ExternalId__c = cm.EV_ExternalId__c,
			EV_CampaignMemberId__c = cm.id,
			EV_ContadorCheckInVirtual__c = 1,
			EV_Origen__c = 'Push',
			EV_Numperso__c ='123456789',
			EV_Canal__c = 'I',
			EV_Status__c = 'Reprocess' 
		);

		insert cms;
		return cms; 
	}

	public static EV_CampaingMemeberStaging__c createCMStagingCustom(EV_CampaignMemberC__c cm) {

		EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c(
			EV_ExternalId__c = cm.EV_ExternalID__c,
			EV_CampaignMemberId__c = cm.Id,
			EV_ContadorCheckInVirtual__c = 1,
			EV_Origen__c = 'Push',
			EV_Numperso__c ='123456789',
			EV_Canal__c = 'I',
			EV_Status__c = 'Reprocess' 
		);

		insert cms;
		return cms; 
	}

	public static void activateLogger() {
		AV_ByPass__c byPass = new AV_ByPass__c(
			LogDebug__c=true,
			LogError__c=true,
			LogInfo__c=true,
			LogWarn__c=true
		);
		insert byPass;
	}

	public static void activateLoggerEV(){
		EV_ByPass__c byPass = new EV_ByPass__c(
				EV_LogDebug__c=true,
				EV_LogError__c=true,
				EV_LogInfo__c=true,
				EV_LogWarn__c=true
		);
		insert byPass;
	}
}