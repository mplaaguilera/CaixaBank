/**********************************************************************************************************************
 Name:	  EV_WS_InscripcionEnEventoAccionista
 Copyright © 2022  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para WS inscripcion multiple de Accionistas
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0																		Init version
	1.1		    US297853    	    Daniel Rodriguez	29/03/2023			Se añade el RT de Acompañante para Accionistas
	1.2.		US586996			Mamen Arias			12/05/2023			Modify version new Architecture with the new object EV_CampaignMemberC__c
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_InscripcionEnEventoAccionista/*')
global with sharing class EV_WS_InscripcionEnEventoAccionista {
 
	private static final String CAMPAIGN_MEMBER_NOT_FOUND = 'No se ha encontrado el miembro de campaña. Contacte con el administrador de Salesforce.';
	private static final String CAMPAIGN_NOT_FOUND = 'No se ha encontrado el evento. Contacte con el administrador de Salesforce.';
	private static final String EMAIL_FORM_EMPTY = 'El campo email es obligatorio.';
	
	@HttpPost
	global static void inscripcionPortal() {
		String methodName = 'inscripcionPortal';
		RestRequest req = RestContext.request;
		
		String bodyRequest = req.requestBody.toString();
		EV_LogDebug.printLogDebug(methodName, 'Body request: ' + bodyRequest);

		EV_AccionistaClienteWrapper.RequestInscripcionBody campBody = (EV_AccionistaClienteWrapper.RequestInscripcionBody) JSON.deserialize(bodyRequest, EV_AccionistaClienteWrapper.RequestInscripcionBody.class);
 
		//Clientes
		if(String.isNotBlank(campBody.IdInvitacion)){
			Campaign camp = [SELECT Id, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
			
			if (camp.EV_NewArchitecture__c){
				EV_CampaignMemberC__c campMemberCustom = [SELECT Id, EV_Empresa__c, EV_NumeroDocumento__c, EV_AccountId__c FROM EV_CampaignMemberC__c WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
				//Registrar cliente dado que tiene invitacion en nueva arquitectura
				if(campMemberCustom != null && camp != null){
					if(campMemberCustom.EV_Empresa__c && campMemberCustom.EV_NumeroDocumento__c != null) {
						campBody.datosFormulario.NIFEmpresa = campMemberCustom.EV_NumeroDocumento__c;
						RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario, campMemberCustom.EV_AccountId__c, camp.EV_NewArchitecture__c);
				} else {
						RestResponse res = registroClientes(campMemberCustom.Id, camp.Id, campBody.datosFormulario.FormatoDeAsistencia, campBody.datosFormulario.companion, camp.EV_NewArchitecture__c);
				}
			}else{
				//Error: miembro campaña no encontrado
				RestResponse res = RestContext.response; 
				EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();
				responseToShow.Description = CAMPAIGN_MEMBER_NOT_FOUND;
				fillRestResponse(res, responseToShow, 205);
			}      
			}else{
				CampaignMember campMember = [SELECT Id, EV_Empresa__c, EV_NumeroDocumento__c, AccountId FROM CampaignMember WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
				//Registrar cliente dado que tiene invitacion
				if(campMember != null && camp != null){
					if(campMember.EV_Empresa__c && campMember.EV_NumeroDocumento__c != null) {
						campBody.datosFormulario.NIFEmpresa = campMember.EV_NumeroDocumento__c;
						RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario, campMember.AccountId, camp.EV_NewArchitecture__c);
					} else {
						RestResponse res = registroClientes(campMember.Id, camp.Id, campBody.datosFormulario.FormatoDeAsistencia, campBody.datosFormulario.companion, camp.EV_NewArchitecture__c);
					}
				}else{
					//Error: miembro campaña no encontrado
					RestResponse res = RestContext.response;
					EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();
					responseToShow.Description = CAMPAIGN_MEMBER_NOT_FOUND;
					fillRestResponse(res, responseToShow, 205);
				}
			}
		}
		//No clientes
		else if(String.isNotBlank(campBody.idEvento) && campBody.datosFormulario!=null){
			//Email vacio
			if (String.isBlank(campBody.datosFormulario.Email)){
				RestResponse res = RestContext.response; 
				EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();
				responseToShow.Description = EMAIL_FORM_EMPTY;
				fillRestResponse(res, responseToShow, 400);
			}else{
				//Validar que existe la campaña
                Campaign camp = new Campaign();
				camp = [SELECT Id, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
				if(camp != null){
					RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario, null, camp.EV_NewArchitecture__c);
				}else{
					//Campaña no encontrada
					RestResponse res = RestContext.response; 
					EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();
					responseToShow.Description = CAMPAIGN_NOT_FOUND;
					fillRestResponse(res, responseToShow, 205);
				}
			}
		}
		//El ID del evento es vacio o el formulario esta vacio
		else if(String.isBlank(campBody.idEvento) || campBody.datosFormulario==null){
			RestResponse res = RestContext.response; 
			EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();
			responseToShow.Description = CAMPAIGN_NOT_FOUND;
			fillRestResponse(res, responseToShow, 205);
		}
	}
	
	/**
	 * Fill the REST response
	 */
	private static void fillRestResponse(RestResponse res, EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow, Integer statusCode){
		res.headers.put('Content-Type', 'application/json');
		res.responsebody = Blob.valueOf(JSON.serialize(responseToShow));
		res.statusCode = statusCode;
	}
	
	/**
	 * Existing clients
	 */
	private static RestResponse registroClientes(String idInvitacion, String idCampaign, String formatoDeAsistencia, EV_AccionistaClienteWrapper.Companion companion, Boolean newArchitecture){
		RestResponse res = RestContext.response;
		EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();

		if (newArchitecture){
			EV_CampaignMemberC__c lCompC;
			EV_CampaignMemberC__c campActualizarC = [SELECT Id, EV_Status__c, EV_ExternalId__c, EV_FormatoDeAsistencias__c, EV_ContactId__r.AccountId FROM EV_CampaignMemberC__c WHERE Id = :idInvitacion];
			if(campActualizarC.EV_Status__c == 'Registro confirmado' || campActualizarC.EV_Status__c == 'QR enviado'){
				responseToShow.Description = 'Ya se ha inscrito en el evento';
				responseToShow.idInvitacion = campActualizarC.EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 202);
			}else{
				if(companion != null){
					if(String.isNotBlank(companion.Nombre)){
						lCompC= createCompanionCustom(companion, idCampaign, campActualizarC.EV_ContactId__r.AccountId, null);
					}  
				}
				campActualizarC.EV_Status__c = 'Registro confirmado';
				campActualizarC.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
				update campActualizarC;
				responseToShow.Description = 'Registro completado';
				responseToShow.idInvitacion = campActualizarC.EV_ExternalId__c;
				if(lCompC != null) {
					responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :lCompC.Id].EV_ExternalId__c;
				}
				fillRestResponse(res, responseToShow, 200);
			}
			return res;
		}else{
		CampaignMember lComp;
			CampaignMember campActualizar = [SELECT Id, Status, EV_ExternalId__c, EV_FormatoDeAsistencias__c,Contact.AccountId FROM CampaignMember WHERE Id = :idInvitacion];
		if(campActualizar.Status == 'Registro confirmado' || campActualizar.Status == 'QR enviado'){
			responseToShow.Description = 'Ya se ha inscrito en el evento';
			responseToShow.idInvitacion = campActualizar.EV_ExternalId__c;
			fillRestResponse(res, responseToShow, 202);
		}else{
			if(companion != null){
				if(String.isNotBlank(companion.Nombre)){
					lComp= createCompanion(companion, idCampaign,campActualizar.Contact.AccountId, null );
				}  
			}
			campActualizar.Status = 'Registro confirmado';
				campActualizar.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
			update campActualizar;
			responseToShow.Description = 'Registro completado';
			responseToShow.idInvitacion = campActualizar.EV_ExternalId__c;
				if(lComp != null){
					responseToShow.idInvitacionCompanion = [Select EV_ExternalId__c from CampaignMember where Id = :lComp.Id].EV_ExternalId__c;
				}
			fillRestResponse(res, responseToShow, 200);
		}
		return res;
	}
	}

	/**
	 * Non-existing clients
	 */
	private static RestResponse registroNoClientes(String idEvento, EV_AccionistaClienteWrapper datosFormulario, String accId, Boolean newArchitecture){
		RestResponse res = RestContext.response;
		CampaignMember lComp;
		EV_CampaignMemberC__c lCompCustom;
		EV_AccionistaClienteWrapper.CampaignMemberResponse responseToShow = new EV_AccionistaClienteWrapper.CampaignMemberResponse();
		Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadAccionistas').getRecordTypeId();
		List<CampaignMember> listCampMember = new List<CampaignMember>();
		List<EV_CampaignMemberC__c> listcampMemberCustom = new List<EV_CampaignMemberC__c>();
		CampaignMember noClienteCM = new CampaignMember();
		EV_CampaignMemberC__c noClienteCMCustom = new EV_CampaignMemberC__c();
		
		//Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
		if (newArchitecture){
			listcampMemberCustom = [SELECT Id, EV_Status__c, EV_NumeroDocumento__c, EV_ExternalId__c, EV_Email__c FROM EV_CampaignMemberC__c
								WHERE EV_CampaignId__c = :idEvento AND EV_LeadId__c != null AND EV_LeadId__r.RecordType.DeveloperName = 'EV_LeadAccionistas'
								AND EV_LeadId__r.Email = :datosFormulario.Email AND EV_Status__c != 'Baja del evento' LIMIT 50000];

			if(listcampMemberCustom!=null && !listcampMemberCustom.isEmpty()){
				responseToShow.Description = 'Ya se ha inscrito en el evento';
				responseToShow.idInvitacion = listcampMemberCustom[0].EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 202);
				return res;
			}
		}else{
			listCampMember = [SELECT Id, Status, EV_NumeroDocumento__c, EV_ExternalId__c, Email FROM CampaignMember
								WHERE CampaignId = :idEvento AND LeadId != null AND Lead.RecordType.DeveloperName = 'EV_LeadAccionistas'
								AND Lead.Email = :datosFormulario.Email AND Status != 'Baja del evento' LIMIT 50000];

		if(listCampMember!=null && !listCampMember.isEmpty()){
			responseToShow.Description = 'Ya se ha inscrito en el evento';
			responseToShow.idInvitacion = listCampMember[0].EV_ExternalId__c;	
			fillRestResponse(res, responseToShow, 202);
			return res;
		}
		}

		//Controlar si es persona juridica
		if(String.isNotEmpty(datosFormulario.NIFEmpresa)){
			Id rtAccEmpresa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			List<Account> accEmpresa = new List<Account> ([SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = :datosFormulario.NIFEmpresa AND RecordtypeId =:rtAccEmpresa]);
			CampaignMember miembroInterlocutor = new CampaignMember();
			EV_CampaignMemberC__c miembroInterlocutorCustom = new EV_CampaignMemberC__c();
			//Control de empresa
			/*if(accEmpresa != null && accEmpresa.size() > 1){
				responseToShow.Description = 'Existe más de un registro asociado a esta empresa. Consulta con el administrador de Salesforce.';
				fillRestResponse(res, responseToShow, 203);
				return res;
			//La empresa del interlocutor existe
			}else*/
			if(accEmpresa != null && !accEmpresa.isEmpty()){
				if(String.isNotEmpty(accId)){
					accEmpresa[0].Id = accId;
				}

				Lead interlocutor = new Lead(
					FirstName = datosFormulario.Nombre,
					LastName = datosFormulario.Apellidos,
					EV_NumeroDocumento__c = datosFormulario.Documento,
					Phone = datosFormulario.Phone,
					EV_Idiomas__c = datosFormulario.Idioma,
					Company = accEmpresa[0].Name,
					EV_Cargo__c = datosFormulario.Cargo,
					EV_NIFEmpresa__c = accEmpresa[0].CC_Numero_Documento__c,
					EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
					RecordtypeId = rtLeadEvento,
					Email = datosFormulario.Email,
					EV_Account__c = accEmpresa[0].Id,
					EV_Provincia__c = datosFormulario.Provincia
					);

					if(datosFormulario.ConsentimientoTerceros!=null){
						interlocutor.EV_ConsentimientoTerceros__c = datosFormulario.ConsentimientoTerceros;
					}

					if(datosFormulario.Marketing!=null){
						interlocutor.EV_Marketing__c = datosFormulario.Marketing;
					}

					insert interlocutor;

				if(newArchitecture){
					miembroInterlocutorCustom = new EV_CampaignMemberC__c(
						EV_CampaignId__c = idEvento,
						EV_Status__c = 'Registro confirmado',
						EV_CanalOrigen__c = '002',
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						//ContactId = interlocutor.Id
						EV_LeadId__c = interlocutor.Id
					);
	
					insert miembroInterlocutorCustom;
				}else{
					miembroInterlocutor = new CampaignMember(
					CampaignId = idEvento,
					Status = 'Registro confirmado',
					EV_CanalOrigen__c = '002',
					EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
					//ContactId = interlocutor.Id
					LeadId = interlocutor.Id
				);

				insert miembroInterlocutor;
				}
				
				if(datosFormulario.companion != null){
					if(String.isNotBlank(datosFormulario.companion.Nombre)){
						if (newArchitecture){
							lCompCustom = createCompanionCustom(datosFormulario.companion, idEvento, null, interlocutor.Id);
						}else{
						lComp= createCompanion(datosFormulario.companion, idEvento,null, interlocutor.Id );
					}  
						
					}  
				}
					
				responseToShow.Description = 'Registro completado';

				if (newArchitecture){
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :miembroInterlocutorCustom.Id].EV_ExternalId__c;
					if(lCompCustom != null){
						responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :lCompCustom.Id].EV_ExternalId__c;
					}
				}else{
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :miembroInterlocutor.Id].EV_ExternalId__c;
					if(lComp != null){
						responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :lComp.Id].EV_ExternalId__c;
					}
				}

				fillRestResponse(res, responseToShow, 200);
				return res;

			//Control de error si está vacía la lista
			}else if(accEmpresa == null || accEmpresa.size() < 1){
				Lead noClienteNuevo = new Lead(
				FirstName = datosFormulario.Nombre,
				LastName = datosFormulario.Apellidos,
				EV_NumeroDocumento__c = datosFormulario.Documento,
				Phone = datosFormulario.Phone,
				EV_Idiomas__c = datosFormulario.Idioma,
				Company = datosFormulario.NombreEmpresa,
				EV_Cargo__c = datosFormulario.Cargo,
				EV_NIFEmpresa__c = datosFormulario.NIFEmpresa, 
				EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
				RecordtypeId = rtLeadEvento,
				Email = datosFormulario.Email,
				EV_Provincia__c = datosFormulario.Provincia
				);

				if(datosFormulario.ConsentimientoTerceros!=null){
					noClienteNuevo.EV_ConsentimientoTerceros__c = datosFormulario.ConsentimientoTerceros;
				}

				if(datosFormulario.Marketing!=null){
					noClienteNuevo.EV_Marketing__c = datosFormulario.Marketing;
				}

				insert noClienteNuevo;

				if(newArchitecture){
					noClienteCMCustom = new EV_CampaignMemberC__c(
						EV_CampaignId__c = idEvento,
						EV_Status__c = 'Registro confirmado',
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						EV_CanalOrigen__c = '003',
						EV_LeadId__c = noClienteNuevo.Id
					);
					insert noClienteCMCustom;
				}else{
					noClienteCM = new CampaignMember(
					CampaignId = idEvento,
					Status = 'Registro confirmado',
					EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
					EV_CanalOrigen__c = '003',
					LeadId = noClienteNuevo.Id
				);
				insert noClienteCM;
				}

				if(datosFormulario.companion != null){
					if(String.isNotBlank(datosFormulario.companion.Nombre)){
						if(newArchitecture){
							lCompCustom= createCompanionCustom(datosFormulario.companion, idEvento,null, noClienteNuevo.Id);
						}else{
						lComp= createCompanion(datosFormulario.companion, idEvento,null, noClienteNuevo.Id );
					}  
				}
				}
					
				responseToShow.Description = 'Registro completado';
				if(newArchitecture){
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :noClienteCMCustom.Id].EV_ExternalId__c;
					if(lCompCustom != null){
						responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :lCompCustom.Id].EV_ExternalId__c;	
					}
				}else{
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :noClienteCM.Id].EV_ExternalId__c;
					if(lComp != null){
						responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :lComp.Id].EV_ExternalId__c;
					}
				}
				
				fillRestResponse(res, responseToShow, 200);
				return res;
			}
		}
		//Para no cliente, insertamos todos indiscriminadamente. (no se actualiza uno que ya haya)
		else{
			Lead noClienteNuevo = new Lead(
				FirstName = datosFormulario.Nombre,
				LastName = datosFormulario.Apellidos,
				EV_NumeroDocumento__c = datosFormulario.Documento,
				Phone = datosFormulario.Phone,
				EV_Idiomas__c = datosFormulario.Idioma,
				EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
				RecordtypeId = rtLeadEvento,
				Email = datosFormulario.Email,
				EV_Provincia__c = datosFormulario.Provincia
			);

			if(datosFormulario.ConsentimientoTerceros!=null){
				noClienteNuevo.EV_ConsentimientoTerceros__c = datosFormulario.ConsentimientoTerceros;
			}

			if(datosFormulario.Marketing!=null){
				noClienteNuevo.EV_Marketing__c = datosFormulario.Marketing;
			}

			insert noClienteNuevo;

			if(newArchitecture){
				noClienteCMCustom = new EV_CampaignMemberC__c(
					EV_CampaignId__c = idEvento,
					EV_Status__c = 'Registro confirmado',
					EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
					EV_CanalOrigen__c = '003',
					EV_LeadId__c = noClienteNuevo.Id
				);
				insert noClienteCMCustom;
			}else{
				noClienteCM = new CampaignMember(
				CampaignId = idEvento,
				Status = 'Registro confirmado',
				EV_CanalOrigen__c = '003',
				EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
				LeadId = noClienteNuevo.Id
			);

			insert noClienteCM;
			}
			
			if(datosFormulario.companion != null){
				if(String.isNotBlank(datosFormulario.companion.Nombre)){
					if(newArchitecture){
						lCompCustom = createCompanionCustom(datosFormulario.companion, idEvento, null, noClienteNuevo.Id);
					}else{
					lComp= createCompanion(datosFormulario.companion, idEvento,null, noClienteNuevo.Id );
				}  
			}
			}

			responseToShow.Description = 'Registro completado';
			if(newArchitecture){
				responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :noClienteCMCustom.Id].EV_ExternalId__c;
				if(lCompCustom != null){
					responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :lCompCustom.Id].EV_ExternalId__c;
				}
			}else{
				responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :noClienteCM.Id].EV_ExternalId__c;
				if(lComp != null){
					responseToShow.idInvitacionCompanion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :lComp.Id].EV_ExternalId__c;
				}
			}

			fillRestResponse(res, responseToShow, 200);
		}

		return res;
	}

	/*global static void sendConfirmationEmail() {

	}*/

	private static CampaignMember createCompanion(EV_AccionistaClienteWrapper.Companion companionLead, String idEvento, String accId, String lId){
		Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadAccionistas').getRecordTypeId();
		Id rtAcompananteAccionistas = Schema.SObjectType.Acompanante__c.getRecordTypeInfosByDeveloperName().get('EV_Accionistas').getRecordTypeId();
		Lead leadCompanion = new Lead(
			FirstName = companionLead.Nombre,
			LastName = companionLead.Apellidos,
			EV_NumeroDocumento__c = companionLead.Documento,
			RecordtypeId = rtLeadEvento,
			EV_Idiomas__c = companionLead.Idioma
		);
		Database.insert(leadCompanion);
		CampaignMember companionCM = new CampaignMember(
			CampaignId = idEvento,
			Status = 'Registro confirmado',
			EV_FormatoDeAsistencias__c = '001',
			EV_CanalOrigen__c = '003',
			LeadId = leadCompanion.Id
		);
		Database.insert(companionCM);
		Acompanante__c comp = new Acompanante__c();
		comp.EV_LeadAcompanante__c = leadCompanion.Id;
		comp.RecordTypeId = rtAcompananteAccionistas;
		if(accId != null){
			comp.EV_Accionista__c = accId;
		}else{
			comp.EV_AccionistaLead__c = lId;
		}
		Database.insert(comp);
		return companionCM;
	}

	private static EV_CampaignMemberC__c createCompanionCustom(EV_AccionistaClienteWrapper.Companion companionLead, String idEvento, String accId, String lId){
		Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadAccionistas').getRecordTypeId();
		Id rtAcompananteAccionistas = Schema.SObjectType.Acompanante__c.getRecordTypeInfosByDeveloperName().get('EV_Accionistas').getRecordTypeId();
		Lead leadCompanion = new Lead(
			FirstName = companionLead.Nombre,
			LastName = companionLead.Apellidos,
			EV_NumeroDocumento__c = companionLead.Documento,
			RecordtypeId = rtLeadEvento,
			EV_Idiomas__c = companionLead.Idioma
		);
		Database.insert(leadCompanion);
		EV_CampaignMemberC__c companionCM = new EV_CampaignMemberC__c(
			EV_CampaignId__c = idEvento,
			EV_Status__c = 'Registro confirmado',
			EV_FormatoDeAsistencias__c = '001',
			EV_CanalOrigen__c = '003',
			EV_LeadId__c = leadCompanion.Id
		);
		Database.insert(companionCM);
		Acompanante__c comp = new Acompanante__c();
		comp.EV_LeadAcompanante__c = leadCompanion.Id;
		comp.RecordTypeId = rtAcompananteAccionistas;
		if(accId != null){
			comp.EV_Accionista__c = accId;
		}else{
			comp.EV_AccionistaLead__c = lId;
		}
		Database.insert(comp);
		return companionCM;
	}
}