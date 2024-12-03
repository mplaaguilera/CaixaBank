/**********************************************************************************************************************
 Name:	  EV_WS_InscripcionEnEvento
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
@Description: Clase para Web service EV_WS_InscripcionEnEvento de Portal
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US586996			Daniel Rodriguez   08/05/2023			Modify version new Architecture with the new object EV_CampaignMemberC__c
	1.1		    US737264            Carolina Lopez	   02/01/2024			Optimize the service, include new response, validations and remove getDescribe().
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_InscripcionEnEvento/*')
global with sharing class EV_WS_InscripcionEnEvento extends CBK_HttpServiceIntegration_Abstract {
	private static Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
    private static Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
	private static Id rtAccEmpresa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
	
	@HttpPost
	global static void inscripcionPortal() {
		String methodName = 'inscripcionPortal';
		List<Campaign> lstCamp = new List<Campaign>();
		RestRequest req = RestContext.request;
		String bodyRequest = req.requestBody.toString();
		String cleanedRequestBody = bodyRequest.replaceAll('\\s', '');
		EV_LogDebug.printLogDebug(methodName, 'Body request: ' + bodyRequest);

		if(cleanedRequestBody.trim() == '{}'){
			RestResponse res = RestContext.response;
			res.headers.put('Content-Type', 'application/json');
            res.responsebody = Blob.valueOf(Label.EV_NotBodyInscription); 
            res.statusCode = 400; 
        	returnResponse(res);
        }else{ 
			EV_NoClienteWrapper.RequestInscripcionBody campBody = (EV_NoClienteWrapper.RequestInscripcionBody) JSON.deserialize(bodyRequest, EV_NoClienteWrapper.RequestInscripcionBody.class);
			if(Schema.SObjectType.Campaign.isAccessible()) {
				lstCamp = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalId__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
			}
			if(!lstCamp.isEmpty()) {
				if(campBody.datosFormulario != null){
					if(String.isNotBlank(campBody.IdInvitacion)) {//Clientes
						if(lstCamp[0].EV_NewArchitecture__c == false){//Antigua arquitectura
							List<CampaignMember> lstCampMember = new List<CampaignMember>();
							
							if(Schema.SObjectType.CampaignMember.isAccessible()) {
								lstCampMember = [SELECT Id, EV_Empresa__c,EV_NumeroDocumento__c, AccountId FROM CampaignMember WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
							}

							if(!lstCampMember.isEmpty()) {//Registrar cliente dado que tiene invitacion
								if(lstCampMember.get(0).EV_Empresa__c && String.isNotBlank(lstCampMember.get(0).EV_NumeroDocumento__c)) {
									campBody.datosFormulario.NIFEmpresa = lstCampMember.get(0).EV_NumeroDocumento__c;
									registroNoClientes(lstCamp.get(0).Id, campBody.datosFormulario, lstCampMember.get(0).AccountId, lstCamp.get(0).EV_NewArchitecture__c);
								} else {
									registroClientes(lstCampMember.get(0).Id, lstCamp.get(0).Id, campBody.datosFormulario.FormatoDeAsistencia, lstCamp.get(0).EV_NewArchitecture__c);
								}
							}else{
								RestResponse res = RestContext.response;
								fillRestResponse(res, Label.EV_CampaignMemberNotFound, null, 404);
							}
						}else{//Nueva arquitectura
							List<EV_CampaignMemberC__c> lstCampMemberC = new List<EV_CampaignMemberC__c>();
							if(Schema.SObjectType.EV_CampaignMemberC__c.isAccessible()) {
								lstCampMemberC = [SELECT Id, EV_Empresa__c,EV_NumeroDocumento__c, EV_AccountId__c FROM EV_CampaignMemberC__c WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
							}

							if(!lstCampMemberC.isEmpty()){//Registrar cliente dado que tiene invitacion en nueva arquitectura
								if(lstCampMemberC.get(0).EV_Empresa__c && String.isNotBlank(lstCampMemberC.get(0).EV_NumeroDocumento__c)) {
									campBody.datosFormulario.NIFEmpresa = lstCampMemberC.get(0).EV_NumeroDocumento__c;
									registroNoClientes(lstCamp.get(0).Id, campBody.datosFormulario,lstCampMemberC.get(0).EV_AccountId__c, lstCamp.get(0).EV_NewArchitecture__c );
								}else{
									registroClientes(lstCampMemberC.get(0).Id, lstCamp.get(0).Id, campBody.datosFormulario.FormatoDeAsistencia, lstCamp.get(0).EV_NewArchitecture__c);
								}
							}else{//Error: miembro campaña no encontrado
								RestResponse res = RestContext.response;
								fillRestResponse(res, Label.EV_CampaignMemberNotFound, null, 404);
							}    
						}
					}else if(String.isNotBlank(campBody.idEvento) && campBody.numper != null){//aqui hay que buscar el contact con el numper para poder generar un campaignMember
						EV_LogDebug.printLogDebug('Entro idEvento y numper' , 'idEvento + numper ' + campBody.idEvento +' '+ campBody.numper);
						List<Contact> lstConct = new List<Contact>();
						if(Schema.SObjectType.Contact.isAccessible()) {
							lstConct = [SELECT Id FROM Contact WHERE CC_NumPerso__c = :campBody.numper LIMIT 1];
						}

						if (!lstConct.isEmpty()) {
							if(lstCamp.get(0).EV_NewArchitecture__c){//Genero CampaignMember custom
								createClientCMcustom(lstCamp.get(0).Id, lstConct.get(0), campBody.datosFormulario.FormatoDeAsistencia);
							}else{
								createClientCM(lstCamp.get(0).Id, lstConct.get(0), campBody.datosFormulario.FormatoDeAsistencia);
							}
						}else {
							RestResponse res = RestContext.response;
							fillRestResponse(res, Label.EV_ContactNotFound, null , 404);
						}
					}else if(String.isNotBlank(campBody.idEvento) && campBody.numper == null){//No clientes
						EV_LogDebug.printLogDebug('Entro idEvento, formulario no null y numper null' , 'idEvento + campBody.datosFormulario + numper ' + campBody.idEvento +' '+campBody.datosFormulario + ' '+ campBody.numper);
						if (String.isBlank(campBody.datosFormulario.Email)){//Email vacio
							RestResponse res = RestContext.response;
							fillRestResponse(res, Label.EV_EmailFormEmpty, null, 400);
						}else{//Validar que existe la campaña
							EV_LogDebug.printLogDebug('camp Registro no clientes',String.valueof(lstCamp.get(0).Id));
							registroNoClientes(lstCamp.get(0).Id, campBody.datosFormulario, null, lstCamp.get(0).EV_NewArchitecture__c);
						}
					} 
				}
			}else{
				RestResponse res = RestContext.response;
				fillRestResponse(res, Label.EV_CampaignNotFound, null, 404);
			} 
		}
	}

	private static RestResponse returnResponse(RestResponse response) { 
        return response;        
    }
	/**
	 * Fill the REST response
	 */
	private static void fillRestResponse(RestResponse res, String fDescription, String fExternalId, Integer fstatusCode){
		EV_NoClienteWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteWrapper.CampaignMemberResponse();
		responseToShow.description = fDescription;
		if(fExternalId != null){
			responseToShow.idInvitacion = fExternalId;
		}
		res.headers.put('Content-Type', 'application/json');
		res.responsebody = Blob.valueOf(JSON.serialize(responseToShow));
		res.statusCode = fstatusCode;
	}
	/**
	 * Existing clients
	 */
	private static RestResponse registroClientes(String idInvitacion, String idCampaign, String formatoDeAsistencia, Boolean newArchitecture){
        EV_LogDebug.printLogDebug('Entro registroClientes' , 'idInvitacion + idCampaign + FormatoDeAsistencia + newArchitecture ' + idInvitacion +' '+idCampaign + ' '+ formatoDeAsistencia + ' '+ newArchitecture);
		RestResponse res = RestContext.response;
		if(newArchitecture){
			list<EV_CampaignMemberC__c> lstCampActualizarC = new list<EV_CampaignMemberC__c>();
			if(Schema.SObjectType.EV_CampaignMemberC__c.isAccessible()) {
				lstCampActualizarC = [SELECT Id, EV_Status__c, EV_ExternalId__c, EV_CampaignId__r.Name, EV_CampaignId__r.EV_ExternalId__c, EV_CampaignId__c,  EV_FormatoDeAsistencias__c FROM EV_CampaignMemberC__c WHERE Id = :IdInvitacion];
			}
			if(!lstCampActualizarC.isEmpty()){
				if(lstCampActualizarC[0].EV_Status__c == Label.EV_RecordConformed || lstCampActualizarC[0].EV_Status__c == Label.EV_QRSend){
					fillRestResponse(res, Label.EV_RecordFound, lstCampActualizarC[0].EV_ExternalId__c, 202);
					returnResponse(res);
				}else{
					lstCampActualizarC[0].EV_Status__c = Label.EV_RecordConformed;
                    lstCampActualizarC[0].EV_FormatoDeAsistencias__c = formatoDeAsistencia;
					Database.SaveResult[] resultCampMemC = Database.update(lstCampActualizarC, false);
					Map<String, String> msjsCMC = new Map<String, String>();
					if(resultCampMemC[0].isSuccess()){
						String externalId = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :lstCampActualizarC[0].Id].EV_ExternalId__c;
						fillRestResponse(res,  Label.EV_RecordCompleted, externalId, 200);
						returnResponse(res);
					}
					if(!resultCampMemC[0].isSuccess()) {
						fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''),null, 500);
                        msjsCMC.put('500', resultCampMemC[0].getErrors()[0].getMessage());
						returnResponse(res);
					}
					if(!msjsCMC.isEmpty()){                    
						CBK_Log.error(msjsCMC);                    
					}
				}
				return res;
			}
		}else{
			list<CampaignMember> lstCampActualizar = new list<CampaignMember>();
			if(Schema.SObjectType.CampaignMember.isAccessible()) {
				lstCampActualizar = [SELECT Id, Status, EV_ExternalId__c, EV_FormatoDeAsistencias__c FROM CampaignMember WHERE Id = :IdInvitacion];
			}
			if(!lstCampActualizar.isEmpty()){
				if(lstCampActualizar[0].Status == Label.EV_RecordConformed || lstCampActualizar[0].Status == Label.EV_QRSend){
					fillRestResponse(res, Label.EV_RecordFound,lstCampActualizar[0].EV_ExternalId__c,  202);
					returnResponse(res);
				}else{
					lstCampActualizar[0].Status = Label.EV_RecordConformed;
                    lstCampActualizar[0].EV_FormatoDeAsistencias__c = formatoDeAsistencia;
					Database.SaveResult[] resultCampMem = Database.update(lstCampActualizar, false);
					Map<String, String> msjsCM = new Map<String, String>();
					if(resultCampMem[0].isSuccess()){
						String externalId = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :lstCampActualizar[0].Id].EV_ExternalId__c;
						fillRestResponse(res,Label.EV_RecordCompleted, externalId , 200);
						returnResponse(res);
                    }	
                    if(!resultCampMem[0].isSuccess()) {
						fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''),null, 500);
						msjsCM.put('500', resultCampMem[0].getErrors()[0].getMessage());
						returnResponse(res);
                    }
					if(!msjsCM.isEmpty()){                    
						CBK_Log.error(msjsCM);                    
					}
				}
			}
		}
		return res;
	}

	/**
	 * Non-existing clients
	 */
	private static RestResponse registroNoClientes(String idEvento, EV_NoClienteWrapper datosFormulario, String accId, Boolean newArchitecture){
		EV_LogDebug.printLogDebug('Entro registroNoClientes',String.valueof(datosFormulario) + idEvento + accId);
		RestResponse res = RestContext.response;
		List<EV_CampaignMemberC__c> listCampMemberCustom = new List<EV_CampaignMemberC__c>();
		List<CampaignMember> listCampMember = new List<CampaignMember>();
		if(newArchitecture){//Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
			if(Schema.SObjectType.EV_CampaignMemberC__c.isAccessible()) {
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
			}
		}else{//Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
			if(Schema.SObjectType.CampaignMember.isAccessible()) {
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
		}

		if((listCampMember!=null && !listCampMember.isEmpty()) || (listCampMemberCustom != null && !listCampMemberCustom.isEmpty())){
			fillRestResponse(res, Label.EV_RecordFound, (!listCampMember.isEmpty() ? listCampMember[0].EV_ExternalId__c : listCampMemberCustom[0].EV_ExternalId__c), 202);
			EV_LogDebug.printLogDebug('Entro EV_RecordFound', String.valueof(res));
			return res;
		}
		List<EV_CampaignMemberC__c> miembroInterlocutorCustom = new List<EV_CampaignMemberC__c> ();
		List<CampaignMember> miembroInterlocutor = new List<CampaignMember>();
		List<Lead> interlocutor = new List<Lead> ();
		List<Account> accEmpresa = new List<Account>();
		if(Schema.SObjectType.Account.isAccessible()) {
			if(datosFormulario.NIFEmpresa != null && !String.isBlank(datosFormulario.NIFEmpresa)){
                accEmpresa = [SELECT Id,Name,CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = :datosFormulario.NIFEmpresa AND RecordtypeId =:rtAccEmpresa LIMIT 10000];
            }
		}

		if(String.isNotEmpty(accId)) accEmpresa[0].Id = accId;
		interlocutor.add(new Lead(
			FirstName = datosFormulario.Nombre,
			LastName = datosFormulario.Apellidos,
			Phone = datosFormulario.Phone,
			EV_Idiomas__c = datosFormulario.Idioma,
			Company = (!accEmpresa.isEmpty() ? accEmpresa[0].Name : datosFormulario.NombreEmpresa),
			EV_Cargo__c = datosFormulario.Cargo,
			EV_NIFEmpresa__c = (!accEmpresa.isEmpty() ? accEmpresa[0].CC_Numero_Documento__c : datosFormulario.NIFEmpresa),
			EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
			RecordtypeId = rtLeadEvento,
			Email = datosFormulario.Email,
			EV_Account__c = (!accEmpresa.isEmpty() ? accEmpresa[0].Id : null),
			EV_ConsentimientoTerceros__c = (datosFormulario.ConsentimientoTerceros!=null ? datosFormulario.ConsentimientoTerceros : false),
			EV_Marketing__c = (datosFormulario.Marketing!=null ? datosFormulario.Marketing : false)
			));

			Database.SaveResult[] resultLead = Database.insert(interlocutor);
			Map<String, String> msjs = new Map<String, String>();
			if(resultLead[0].isSuccess()){      
				if(newArchitecture){
					EV_LogDebug.printLogDebug('Entro lead miembroInterlocutorCustom ',  String.valueof(resultLead));
					miembroInterlocutorCustom.add(new EV_CampaignMemberC__c(
						EV_CampaignId__c = idEvento,
						EV_Status__c = Label.EV_RecordConformed,
						EV_CanalOrigen__c = (String.isNotEmpty(datosFormulario.NIFEmpresa) ? '002' : '003'),
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						RecordtypeId = rtCMC,
						EV_LeadId__c = resultLead[0].getId()));
				}else{
					EV_LogDebug.printLogDebug('Entro lead miembroInterlocutor ',  String.valueof(resultLead));
					miembroInterlocutor.add(new CampaignMember(
						CampaignId = idEvento,
						Status = Label.EV_RecordConformed,
						EV_CanalOrigen__c = (String.isNotEmpty(datosFormulario.NIFEmpresa) ? '002' : '003'),
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						LeadId = resultLead[0].getId()));
				}
			}
			if(!resultLead[0].isSuccess()) {
				EV_LogDebug.printLogDebug('Entro lead error',  String.valueof(resultLead));
				fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''), null, 500);
				msjs.put('500', resultLead[0].getErrors()[0].getMessage());
				return res;
			}
			if(!msjs.isEmpty()){
				CBK_Log.error(msjs);
			}

			if(!miembroInterlocutor.isEmpty()){
				Database.SaveResult[] resultC = Database.insert(miembroInterlocutor, false);
				Map<String, String> msjsC = new Map<String, String>();
				if(resultC[0].isSuccess()){
					EV_LogDebug.printLogDebug('Entro miembro estandar' ,  String.valueof(resultC));
					String externalId = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :miembroInterlocutor[0].Id].EV_ExternalId__c;
					fillRestResponse(res,Label.EV_RecordCompleted, externalId , 200);
					return res;
				}
				if(!resultC[0].isSuccess()) {
					EV_LogDebug.printLogDebug('Entro error estandar',  String.valueof(resultC));
					fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''),null, 500);
					msjsC.put('500', resultC[0].getErrors()[0].getMessage());
					return res;
				}
				if(!msjsC.isEmpty()){                
					CBK_Log.error(msjsC);                
				}
			}else if(!miembroInterlocutorCustom.isEmpty()){
				Database.SaveResult[] result = Database.insert(miembroInterlocutorCustom, false);
				Map<String, String> msjsCM = new Map<String, String>();
				if(result[0].isSuccess()){
					EV_LogDebug.printLogDebug('Entro miembro' ,  String.valueof(result));
					String externalId = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :miembroInterlocutorCustom[0].Id].EV_ExternalId__c;
					fillRestResponse(res,Label.EV_RecordCompleted, externalId , 200);
					return res;
				}
				if(!result[0].isSuccess()) {
					EV_LogDebug.printLogDebug('Entro error',  String.valueof(result));
					fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''),null, 500);
					msjsCM.put('500', result[0].getErrors()[0].getMessage());
					return res;
				}
				if(!msjsCM.isEmpty()){                
					CBK_Log.error(msjsCM);                
				}
			}
		return res;
	}

	public static CampaignMember createClientCM(String idEvento, Contact conc, String fAsistencias){
        EV_LogDebug.printLogDebug('Entro createClientCM' , 'idEvento + conc + fAsistencias' + idEvento +' '+conc + ' '+ fAsistencias);
		RestResponse res = RestContext.response;
		List<CampaignMember> contactCM = new List<CampaignMember>();
		contactCM.add(new CampaignMember(
			CampaignId = idEvento,
			Status = Label.EV_RecordConformed,
			EV_CanalOrigen__c = '003',
			ContactId = conc.Id,
			EV_FormatoDeAsistencias__c = fAsistencias
		));
		Database.SaveResult[] resultCM = Database.insert(contactCM, false);
		Map<String, String> msjsCM = new Map<String, String>();
		if(resultCM[0].isSuccess()){
			String externalId = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :contactCM[0].Id].EV_ExternalId__c;
			fillRestResponse(res,Label.EV_RecordCompleted, externalId , 200);
			returnResponse(res);
		}
		if(!resultCM[0].isSuccess()) {
			fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''),null, 500);
			msjsCM.put('500', resultCM[0].getErrors()[0].getMessage());
			returnResponse(res);
		}
		if(!msjsCM.isEmpty()){
			CBK_Log.error(msjsCM);
		}
		return contactCM[0];
	}
	//Creamos CM custom
	public static EV_CampaignMemberC__c createClientCMcustom(String idEvento, Contact conc, String fAsistencias){
        EV_LogDebug.printLogDebug('Entro createClientCMcustom' , 'idEvento + conc + fAsistencias' + idEvento +' '+conc + ' '+ fAsistencias);
		RestResponse res = RestContext.response;
		List<EV_CampaignMemberC__c> contactCMC = new List<EV_CampaignMemberC__c>();
		contactCMC.add(new EV_CampaignMemberC__c(
			EV_CampaignId__c = idEvento,
			EV_Status__c = Label.EV_RecordConformed,
			EV_CanalOrigen__c = '003',
			EV_ContactId__c = conc.Id,
			RecordtypeId = rtCMC,
			EV_FormatoDeAsistencias__c = fAsistencias
		));
		Database.SaveResult[] resultCMC = Database.insert(contactCMC, false);
		Map<String, String> msjsCMC = new Map<String, String>();
		if(resultCMC[0].isSuccess()){
			String externalId = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :contactCMC[0].Id].EV_ExternalId__c;
			fillRestResponse(res,Label.EV_RecordCompleted, externalId , 200);
			returnResponse(res);
		}
		if(!resultCMC[0].isSuccess()) {
			fillRestResponse(res,Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , ''), null, 500);
			msjsCMC.put('500', resultCMC[0].getErrors()[0].getMessage());
			returnResponse(res);
		}
		if(!msjsCMC.isEmpty()){
			CBK_Log.error(msjsCMC);
		}
		return contactCMC[0];
	}
}