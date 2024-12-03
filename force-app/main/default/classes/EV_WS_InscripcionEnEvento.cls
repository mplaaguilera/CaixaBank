/**********************************************************************************************************************
 Name:	  EV_WS_InscripcionEnEvento
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Web service EV_WS_InscripcionEnEvento de Portal
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US586996			Daniel Rodriguez   08/05/2023			Modify version new Architecture with the new object EV_CampaignMemberC__c 
***********************************************************************************************************************/


@RestResource(urlMapping='/EV_InscripcionEnEvento/*')
global with sharing class EV_WS_InscripcionEnEvento {
 
	private static final String CAMPAIGN_MEMBER_NOT_FOUND = 'No se ha encontrado el miembro de campaña. Contacte con el administrador de Salesforce.';
	private static final String CAMPAIGN_NOT_FOUND = 'No se ha encontrado el evento. Contacte con el administrador de Salesforce.';
	private static final String EMAIL_FORM_EMPTY = 'El campo email es obligatorio.';
	private static final String CONTACT_NOT_FOUND ='No se ha encontrado el contacto';
	
	@HttpPost
	global static void inscripcionPortal() {
		String methodName = 'inscripcionPortal';
		RestRequest req = RestContext.request;
		Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		String bodyRequest = req.requestBody.toString();
		EV_LogDebug.printLogDebug(methodName, 'Body request: ' + bodyRequest);

		EV_NoClienteWrapper.RequestInscripcionBody campBody = (EV_NoClienteWrapper.RequestInscripcionBody) JSON.deserialize(bodyRequest, EV_NoClienteWrapper.RequestInscripcionBody.class);

		//Clientes
		if(String.isNotBlank(campBody.IdInvitacion)){
            
			Campaign camp = [SELECT Id, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
			EV_LogDebug.printLogDebug('Entro idInvitacion' , 'invitacion + architecture ' + campBody.IdInvitacion +' '+ camp.EV_NewArchitecture__c);
			if(camp.EV_NewArchitecture__c == false){
				CampaignMember campMember = [SELECT Id, EV_Empresa__c,EV_NumeroDocumento__c, AccountId FROM CampaignMember WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
				//Registrar cliente dado que tiene invitacion
				if(campMember != null && campMember.id != null && camp != null){
					if(campMember.EV_Empresa__c && campMember.EV_NumeroDocumento__c != null) {
						campBody.datosFormulario.NIFEmpresa = campMember.EV_NumeroDocumento__c;
						RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario,campMember.AccountId, camp.EV_NewArchitecture__c );
					} else {
						RestResponse res = registroClientes(campMember.Id, camp.Id, campBody.datosFormulario.FormatoDeAsistencia, camp.EV_NewArchitecture__c );
					}
				}else{
					//Error: miembro campaña no encontrado
					RestResponse res = RestContext.response; 
					EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
					responseToShow.Description = CAMPAIGN_MEMBER_NOT_FOUND;
					fillRestResponse(res, responseToShow, 205);
				}
			}else{
				EV_CampaignMemberC__c campMemberC = [SELECT Id, EV_Empresa__c,EV_NumeroDocumento__c, EV_AccountId__c FROM EV_CampaignMemberC__c WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
				//Registrar cliente dado que tiene invitacion en nueva arquitectura
				if(campMemberC != null && campMemberC.id != null && camp != null){
					if(campMemberC.EV_Empresa__c && campMemberC.EV_NumeroDocumento__c != null) {
						campBody.datosFormulario.NIFEmpresa = campMemberC.EV_NumeroDocumento__c;
						RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario,campMemberC.EV_AccountId__c, camp.EV_NewArchitecture__c );
					}else{
						RestResponse res = registroClientes(campMemberC.Id, camp.Id, campBody.datosFormulario.FormatoDeAsistencia, camp.EV_NewArchitecture__c );
					}
				}else{
					//Error: miembro campaña no encontrado
					RestResponse res = RestContext.response; 
					EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
					responseToShow.Description = CAMPAIGN_MEMBER_NOT_FOUND;
					fillRestResponse(res, responseToShow, 205);
				}     
		}
	}
		else if(String.isNotBlank(campBody.idEvento) && campBody.numper != null){
			//aqui hay que buscar el contact con el numper para poder generar un campaignMember
			EV_LogDebug.printLogDebug('Entro idEvento y numper' , 'idEvento + numper ' + campBody.idEvento +' '+ campBody.numper);
			Contact conct = [SELECT Id FROM Contact WHERE CC_NumPerso__c = :campBody.numper ];
			Campaign camp = [SELECT Id, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
			if (conct != null) {
				if(camp.EV_NewArchitecture__c){
					//Genero CampaignMember custom
					createClientCMcustom(camp.Id, conct, campBody.datosFormulario.FormatoDeAsistencia );
				}else{
					createClientCM(camp.Id, conct, campBody.datosFormulario.FormatoDeAsistencia );
				}
			} else {
				RestResponse res = RestContext.response; 
				EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
				responseToShow.Description = CONTACT_NOT_FOUND;
				fillRestResponse(res, responseToShow, 205);
			}
		}
		//No clientes
		else if(String.isNotBlank(campBody.idEvento) && campBody.datosFormulario!=null && campBody.numper == null ){
            EV_LogDebug.printLogDebug('Entro idEvento, formulario no null y numper null' , 'idEvento + campBody.datosFormulario + numper ' + campBody.idEvento +' '+campBody.datosFormulario + ' '+ campBody.numper);
			//Email vacio
			if (String.isBlank(campBody.datosFormulario.Email)){
				RestResponse res = RestContext.response; 
				EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
				responseToShow.Description = EMAIL_FORM_EMPTY;
				fillRestResponse(res, responseToShow, 400);
			}else{
				//Validar que existe la campaña
                Campaign camp = new Campaign();
				camp = [SELECT Id, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
                EV_LogDebug.printLogDebug('camp Registro no clientes',String.valueof(camp));
				if(camp != null){
					RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario, null, camp.EV_NewArchitecture__c);
				}else{
					//Campaña no encontrada
					RestResponse res = RestContext.response; 
					EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
					responseToShow.Description = CAMPAIGN_NOT_FOUND;
					fillRestResponse(res, responseToShow, 205);
				}
			}
		}
		//El ID del evento es vacio o el formulario esta vacio
		else if(String.isBlank(campBody.idEvento) || campBody.datosFormulario==null){
            EV_LogDebug.printLogDebug('Entro idEvento vacio o formulario null' , 'idEvento + campBody.datosFormulario ' + campBody.idEvento +' '+campBody.datosFormulario);
			RestResponse res = RestContext.response; 
			EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
			responseToShow.Description = CAMPAIGN_NOT_FOUND;
			fillRestResponse(res, responseToShow, 205);
		}
	}
	
	/**
	 * Fill the REST response
	 */
	private static void fillRestResponse(RestResponse res, EV_NoClienteWrapper.CampaignMemberResponse responseToShow, Integer statusCode){
		res.headers.put('Content-Type', 'application/json');
		res.responsebody = Blob.valueOf(JSON.serialize(responseToShow));
		res.statusCode = statusCode;
	}
	
	/**
	 * Existing clients
	 */
	private static RestResponse registroClientes(String idInvitacion, String idCampaign, String formatoDeAsistencia, Boolean newArchitecture){
        EV_LogDebug.printLogDebug('Entro registroClientes' , 'idInvitacion + idCampaign + FormatoDeAsistencia + newArchitecture ' + idInvitacion +' '+idCampaign + ' '+ formatoDeAsistencia + ' '+ newArchitecture);
		RestResponse res = RestContext.response;
		EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
		if(newArchitecture){
			EV_CampaignMemberC__c campActualizarC = [SELECT Id, EV_Status__c, EV_ExternalId__c, EV_FormatoDeAsistencias__c FROM EV_CampaignMemberC__c WHERE Id = :IdInvitacion];

			if(campActualizarC.EV_Status__c == 'Registro confirmado' || campActualizarC.EV_Status__c == 'QR enviado'){
				responseToShow.Description = 'Ya se ha inscrito en el evento';
				responseToShow.idInvitacion = campActualizarC.EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 202);
			}else{
				campActualizarC.EV_Status__c = 'Registro confirmado';
				campActualizarC.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
				update campActualizarC;
				responseToShow.Description = 'Registro completado';
				responseToShow.idInvitacion = campActualizarC.EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 200);
			}
			return res;
		}else{
			CampaignMember campActualizar = [SELECT Id, Status, EV_ExternalId__c, EV_FormatoDeAsistencias__c FROM CampaignMember WHERE Id = :IdInvitacion];

			if(campActualizar.Status == 'Registro confirmado' || campActualizar.Status == 'QR enviado'){
				responseToShow.Description = 'Ya se ha inscrito en el evento';
				responseToShow.idInvitacion = campActualizar.EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 202);
			}else{
				campActualizar.Status = 'Registro confirmado';
				campActualizar.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
				update campActualizar;
				responseToShow.Description = 'Registro completado';
				responseToShow.idInvitacion = campActualizar.EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 200);
			}
			return res;
		}
	}

	/**
	 * Non-existing clients
	 */
	private static RestResponse registroNoClientes(String idEvento, EV_NoClienteWrapper datosFormulario, String accId, Boolean newArchitecture){
		EV_LogDebug.printLogDebug('Entro registroNoClientes',String.valueof(datosFormulario) + idEvento + accId);
		Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		RestResponse res = RestContext.response;
		EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
		Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
		List<EV_CampaignMemberC__c> listCampMemberCustom = new List<EV_CampaignMemberC__c>();
		List<CampaignMember> listCampMember = new List<CampaignMember>();
		if(newArchitecture){
			//Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
			listCampMemberCustom = [SELECT Id, EV_Status__c, EV_NumeroDocumento__c, EV_ExternalId__c, EV_Email__c 
									FROM EV_CampaignMemberC__c 
									WHERE EV_CampaignId__c = :idEvento 
										AND EV_LeadId__c != null 
										AND EV_LeadId__r.RecordType.DeveloperName = 'EV_Evento'
										AND EV_LeadId__r.Email = :datosFormulario.Email
										AND RecordtypeId = :rtCMC
										AND EV_Status__c != 'Baja del evento'
									LIMIT 50000
									];

		}else{
			//Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
			listCampMember = [SELECT Id, Status, EV_NumeroDocumento__c, EV_ExternalId__c, Email 
							FROM CampaignMember 
							WHERE CampaignId = :idEvento 
								AND LeadId != null 
								AND Lead.RecordType.DeveloperName = 'EV_Evento'
								AND Lead.Email = :datosFormulario.Email
								AND Status != 'Baja del evento'
							LIMIT 50000
							];
		}

		if(listCampMember!=null && !listCampMember.isEmpty()){
			responseToShow.idInvitacion = listCampMember[0].EV_ExternalId__c;
			responseToShow.Description = 'Ya se ha inscrito en el evento';	
			fillRestResponse(res, responseToShow, 202);
			return res;
		}
		if(listCampMemberCustom != null && !listCampMemberCustom.isEmpty()){
			responseToShow.idInvitacion = listCampMemberCustom[0].EV_ExternalId__c;
			responseToShow.Description = 'Ya se ha inscrito en el evento';	
			fillRestResponse(res, responseToShow, 202);
			return res;
		}


		//Controlar si es persona juridica
		if(String.isNotEmpty(datosFormulario.NIFEmpresa) && String.isNotEmpty(datosFormulario.NIFEmpresa)){
			EV_CampaignMemberC__c miembroInterlocutorCustom = new EV_CampaignMemberC__c();
			CampaignMember miembroInterlocutor = new CampaignMember();
			Id rtAccEmpresa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			List<Account> accEmpresa = new List<Account> ([SELECT Id,Name,CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = :datosFormulario.NIFEmpresa AND RecordtypeId =:rtAccEmpresa]);
			
			//Control de empresa
			/*if(accEmpresa != null && accEmpresa.size() > 1){
				responseToShow.Description = 'Existe más de un registro asociado a esta empresa. Consulta con el administrador de Salesforce.';
				fillRestResponse(res, responseToShow, 203);
				return res;
			//La empresa del interlocutor existe
			}else*/
			if(accEmpresa != null && !accEmpresa.isEmpty()){
				if(String.isNotEmpty(accId)) accEmpresa[0].Id = accId;
				Lead interlocutor = new Lead(
					FirstName = datosFormulario.Nombre,
					LastName = datosFormulario.Apellidos,
					//EV_NumeroDocumento__c = datosFormulario.Documento,
					Phone = datosFormulario.Phone,
					EV_Idiomas__c = datosFormulario.Idioma,
					Company = accEmpresa[0].Name,
					EV_Cargo__c = datosFormulario.Cargo,
					EV_NIFEmpresa__c = accEmpresa[0].CC_Numero_Documento__c,
					EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
					RecordtypeId = rtLeadEvento,
					Email = datosFormulario.Email,
					EV_Account__c = accEmpresa[0].Id
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
						RecordtypeId = rtCMC,
						//ContactId = interlocutor.Id
						EV_LeadId__c = interlocutor.Id);
					insert miembroInterlocutorCustom;	

				}else{
					miembroInterlocutor = new CampaignMember(
						CampaignId = idEvento,
						Status = 'Registro confirmado',
						EV_CanalOrigen__c = '002',
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						//ContactId = interlocutor.Id
						LeadId = interlocutor.Id);
					insert miembroInterlocutor;
				}
	
				responseToShow.Description = 'Registro completado';
				if(newArchitecture){
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :miembroInterlocutorCustom.Id].EV_ExternalId__c;
				}else{
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :miembroInterlocutor.Id].EV_ExternalId__c;
				}

				fillRestResponse(res, responseToShow, 200);
				return res;

			//Control de error si está vacía la lista
			}else if(accEmpresa == null || accEmpresa.size() < 1){
				CampaignMember noClienteCM = new CampaignMember();
				EV_CampaignMemberC__c noClienteCMcustom = new EV_CampaignMemberC__c();

				Lead noClienteNuevo = new Lead(
				FirstName = datosFormulario.Nombre,
				LastName = datosFormulario.Apellidos,
				//EV_NumeroDocumento__c = datosFormulario.Documento,
				Phone = datosFormulario.Phone,
				EV_Idiomas__c = datosFormulario.Idioma,
				Company = datosFormulario.NombreEmpresa,
				EV_Cargo__c = datosFormulario.Cargo,
				EV_NIFEmpresa__c = datosFormulario.NIFEmpresa, 
				EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
				RecordtypeId = rtLeadEvento,
				Email = datosFormulario.Email
				);

				if(datosFormulario.ConsentimientoTerceros!=null){
					noClienteNuevo.EV_ConsentimientoTerceros__c = datosFormulario.ConsentimientoTerceros;
				}

				if(datosFormulario.Marketing!=null){
					noClienteNuevo.EV_Marketing__c = datosFormulario.Marketing;
				}


				insert noClienteNuevo;

				if(newArchitecture){
					noClienteCMcustom = new EV_CampaignMemberC__c(
						EV_CampaignId__c = idEvento,
						EV_Status__c = 'Registro confirmado',
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						EV_CanalOrigen__c = '003',
						RecordtypeId = rtCMC,
						EV_LeadId__c = noClienteNuevo.Id);
					insert noClienteCMcustom;
				}else{
					noClienteCM = new CampaignMember(
						CampaignId = idEvento,
						Status = 'Registro confirmado',
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						EV_CanalOrigen__c = '003',
						LeadId = noClienteNuevo.Id);
					insert noClienteCM;
				}

					
				responseToShow.Description = 'Registro completado';
				if(newArchitecture){
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :noClienteCMcustom.Id].EV_ExternalId__c;
				}else{
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :noClienteCM.Id].EV_ExternalId__c;
				}
				
				fillRestResponse(res, responseToShow, 200);
				return res;
			}
		}
		//Para no cliente, insertamos todos indiscriminadamente. (no se actualiza uno que ya haya)
		else{
			EV_CampaignMemberC__c noClienteCMcustom = new EV_CampaignMemberC__c();
			CampaignMember noClienteCM = new CampaignMember();
			
			Lead noClienteNuevo = new Lead(
				FirstName = datosFormulario.Nombre,
				LastName = datosFormulario.Apellidos,
				//EV_NumeroDocumento__c = datosFormulario.Documento,
				Phone = datosFormulario.Phone,
				EV_Idiomas__c = datosFormulario.Idioma,
				EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
				RecordtypeId = rtLeadEvento,
				Email = datosFormulario.Email
			);

			if(datosFormulario.ConsentimientoTerceros!=null){
				noClienteNuevo.EV_ConsentimientoTerceros__c = datosFormulario.ConsentimientoTerceros;
			}
			if(datosFormulario.Marketing!=null){
				noClienteNuevo.EV_Marketing__c = datosFormulario.Marketing;
			}
			insert noClienteNuevo;

			if(newArchitecture){
				noClienteCMcustom = new EV_CampaignMemberC__c(
				EV_CampaignId__c= idEvento,
				EV_Status__c= 'Registro confirmado',
				EV_CanalOrigen__c = '003',
				EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
				RecordtypeId = rtCMC,
				EV_LeadId__c = noClienteNuevo.Id);

				insert noClienteCMcustom;

			}else{
				noClienteCM = new CampaignMember(
				CampaignId = idEvento,
				Status = 'Registro confirmado',
				EV_CanalOrigen__c = '003',
				EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
				LeadId = noClienteNuevo.Id);

				insert noClienteCM;
			}
			
			responseToShow.Description = 'Registro completado';
			if(newArchitecture){
				responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :noClienteCMcustom.Id].EV_ExternalId__c;
			}else{
				responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :noClienteCM.Id].EV_ExternalId__c;
			}

			fillRestResponse(res, responseToShow, 200);
		}

		return res;
	}

	public static CampaignMember createClientCM(String idEvento, Contact conc, String fAsistencias){
        EV_LogDebug.printLogDebug('Entro createClientCM' , 'idEvento + conc + fAsistencias' + idEvento +' '+conc + ' '+ fAsistencias);
		RestResponse res = RestContext.response;
		EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
		
		CampaignMember contactCM = new CampaignMember(
			CampaignId = idEvento,
			Status = 'Registro confirmado',
			EV_CanalOrigen__c = '003',
			ContactId = conc.Id,
			EV_FormatoDeAsistencias__c = fAsistencias
		);
		insert contactCM;
		responseToShow.Description = 'Registro completado';
		responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :contactCM.Id].EV_ExternalId__c;
		fillRestResponse(res, responseToShow, 200);
	
		return contactCM;
	}
	//Creamos CM custom
	public static EV_CampaignMemberC__c createClientCMcustom(String idEvento, Contact conc, String fAsistencias){
        EV_LogDebug.printLogDebug('Entro createClientCMcustom' , 'idEvento + conc + fAsistencias' + idEvento +' '+conc + ' '+ fAsistencias);
		Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		RestResponse res = RestContext.response;
		EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
		
		EV_CampaignMemberC__c contactCM = new EV_CampaignMemberC__c(
			EV_CampaignId__c = idEvento,
			EV_Status__c = 'Registro confirmado',
			EV_CanalOrigen__c = '003',
			EV_ContactId__c = conc.Id,
			RecordtypeId = rtCMC,
			EV_FormatoDeAsistencias__c = fAsistencias
		);
		insert contactCM;
		responseToShow.Description = 'Registro completado';
		responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :contactCM.Id].EV_ExternalId__c;
		fillRestResponse(res, responseToShow, 200);
	
		return contactCM;
	}

}