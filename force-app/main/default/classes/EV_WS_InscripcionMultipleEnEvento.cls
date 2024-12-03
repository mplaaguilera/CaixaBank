/**********************************************************************************************************************
 Name:	  EV_WS_InscripcionMultipleEnEvento
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para WS inscripcion multiple de Talks
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		    US297853    	    Daniel Rodriguez	29/03/2023			Init version
	1.1			US586996			Daniel Rodriguez	15/05/2023			Modify version new Architecture with the new object EV_CampaignMemberC__c
	1.2								Mamen Arias			21/02/2024			Add extends CBK_HttpServiceIntegration_Abstract
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_InscripcionMultipleEnEvento/*')
global with sharing class EV_WS_InscripcionMultipleEnEvento extends CBK_HttpServiceIntegration_Abstract {
    
    private static final String CAMPAIGN_MEMBER_NOT_FOUND = 'No se ha encontrado el miembro de campaña. Contacte con el administrador de Salesforce.';
    private static final String CAMPAIGN_NOT_FOUND = 'No se ha encontrado el evento. Contacte con el administrador de Salesforce.';
    private static final String EMAIL_FORM_EMPTY = 'El campo email es obligatorio.';
    private static final String MAX_ACOMP = 'Ha sobrepasado el número máximo de acompañantes';
    private static final String NO_ACOMP = 'El evento no permite acompañantes';
    
    @HttpPost
    global static void inscripcionPortal() {
        String methodName = 'inscripcionPortal';
        RestRequest req = RestContext.request;
        String bodyRequest = req.requestBody.toString();
        EV_LogDebug.printLogDebug(methodName, 'Body request: ' + bodyRequest);

        EV_NoClienteMultipleWrapper.RequestInscripcionBody campBody = (EV_NoClienteMultipleWrapper.RequestInscripcionBody) JSON.deserialize(bodyRequest, EV_NoClienteMultipleWrapper.RequestInscripcionBody.class);
        //Error: Maximo numero acompañantes sobrepasado
        if(campbody.datosFormulario.companion.size() > 3){
            EV_LogDebug.printLogDebug('Companion size', 'Companion size: ' + campbody.datosFormulario.companion.size());
                RestResponse res = RestContext.response; 
                EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
                responseToShow.Description = MAX_ACOMP;
                fillRestResponse(res, responseToShow, 400);
                return;
        }

    
        //Clientes
        if(String.isNotBlank(campBody.IdInvitacion)){
			Campaign camp = [SELECT Id, EV_Acompanante__c, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
			EV_LogDebug.printLogDebug('Entro idInvitacion' , 'invitacion + architecture ' + campBody.IdInvitacion +' '+ camp.EV_NewArchitecture__c);
			if(camp.EV_NewArchitecture__c == false){
				CampaignMember campMember = [SELECT Id, EV_Empresa__c, EV_NumeroDocumento__c, AccountId FROM CampaignMember WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
				EV_LogDebug.printLogDebug('Cliente campMember', String.valueof(campMember));
				//Registrar cliente dado que tiene invitacion
				if(campMember != null && campMember.id != null && camp != null){
                if(camp.EV_Acompanante__c == false && campBody.datosFormulario.companion.size() > 0){
                    RestResponse res = RestContext.response; 
                    EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
                    responseToShow.Description = NO_ACOMP;
                    fillRestResponse(res, responseToShow, 400);
                    return;
                }
					if(campMember.EV_Empresa__c && campMember.EV_NumeroDocumento__c != null) {
						campBody.datosFormulario.NIFEmpresa = campMember.EV_NumeroDocumento__c;
						RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario,campMember.AccountId, camp.EV_NewArchitecture__c );
					} else {
						List<EV_NoClienteMultipleWrapper.companion> companion = campBody.datosFormulario.companion;
						RestResponse res = registroClientes(campMember.Id, camp.Id, campBody.datosFormulario.FormatoDeAsistencia, companion, camp.EV_NewArchitecture__c);
                }
            }else{
                //Error: miembro campaña no encontrado
                RestResponse res = RestContext.response; 
                EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
                responseToShow.Description = CAMPAIGN_MEMBER_NOT_FOUND;
                fillRestResponse(res, responseToShow, 400);
            }      
			}else{
				EV_CampaignMemberC__c campMemberC = [SELECT Id, EV_Empresa__c, EV_NumeroDocumento__c, EV_AccountId__c FROM EV_CampaignMemberC__c WHERE EV_ExternalId__c = :campBody.IdInvitacion LIMIT 1];
				EV_LogDebug.printLogDebug('Cliente campMember', String.valueof(campMemberC));
				//Registrar cliente dado que tiene invitacion
				if(campMemberC != null && campMemberC.id != null && camp != null){
					if(camp.EV_Acompanante__c == false && campBody.datosFormulario.companion.size() > 0){
						RestResponse res = RestContext.response; 
						EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
						responseToShow.Description = NO_ACOMP;
						fillRestResponse(res, responseToShow, 400);
						return;
					}
					if(campMemberC.EV_Empresa__c && campMemberC.EV_NumeroDocumento__c != null) {
						campBody.datosFormulario.NIFEmpresa = campMemberC.EV_NumeroDocumento__c;
						RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario,campMemberC.EV_AccountId__c, camp.EV_NewArchitecture__c );
					} else {
						List<EV_NoClienteMultipleWrapper.companion> companion = campBody.datosFormulario.companion;
						RestResponse res = registroClientes(campMemberC.Id, camp.Id, campBody.datosFormulario.FormatoDeAsistencia, companion, camp.EV_NewArchitecture__c);
					}
				}else{
					//Error: miembro campaña no encontrado
					RestResponse res = RestContext.response; 
					EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
					responseToShow.Description = CAMPAIGN_MEMBER_NOT_FOUND;
					fillRestResponse(res, responseToShow, 400);
				}
			}      
        }
        //No clientes
        else if(String.isNotBlank(campBody.idEvento) && campBody.datosFormulario!=null){
            //Email vacio
            if (String.isBlank(campBody.datosFormulario.Email)){
                RestResponse res = RestContext.response; 
                EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
                responseToShow.Description = EMAIL_FORM_EMPTY;
                fillRestResponse(res, responseToShow, 400);
            }else{
                //Validar que existe la campaña
                Campaign camp = new Campaign();
				camp = [SELECT Id, EV_Acompanante__c, EV_NewArchitecture__c FROM Campaign WHERE EV_ExternalId__c = :campBody.idEvento LIMIT 1];
                EV_LogDebug.printLogDebug('Campaña ', String.valueof(camp));
                if(camp.EV_Acompanante__c == false && campBody.datosFormulario.companion.size() > 0){
                    RestResponse res = RestContext.response; 
                    EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
                    responseToShow.Description = NO_ACOMP;
                    fillRestResponse(res, responseToShow, 400);
                    return;
                }
                if(camp != null){
					RestResponse res = registroNoClientes(camp.Id, campBody.datosFormulario, null, camp.EV_NewArchitecture__c);
                }else{
                    //Campaña no encontrada
                    RestResponse res = RestContext.response; 
                    EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
                    responseToShow.Description = CAMPAIGN_NOT_FOUND;
                    fillRestResponse(res, responseToShow, 400);
                }
            }
        }
        //El ID del evento es vacio o el formulario esta vacio
        else if(String.isBlank(campBody.idEvento) || campBody.datosFormulario==null){
            RestResponse res = RestContext.response; 
            EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
            responseToShow.Description = CAMPAIGN_NOT_FOUND;
            fillRestResponse(res, responseToShow, 400);
        }
    }
    
    /**
     * Fill the REST response
     */
    private static void fillRestResponse(RestResponse res, EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow, Integer statusCode){
        res.headers.put('Content-Type', 'application/json');
        res.responsebody = Blob.valueOf(JSON.serialize(responseToShow));
        res.statusCode = statusCode;
    }
    
    /**
     * Existing clients
     */
	private static RestResponse registroClientes(String idInvitacion, String idCampaign, String formatoDeAsistencia, EV_NoClienteMultipleWrapper.Companion[] companion, Boolean newArchitecture){
        EV_LogDebug.printLogDebug('RegistroClientes', idInvitacion);
        RestResponse res = RestContext.response;
        EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
        List<CampaignMember> lComp = new List<CampaignMember>();
		List<EV_CampaignMemberC__c> lCompC = new List<EV_CampaignMemberC__c>();
		List<String> cMExternal = new List<String>();
		List<String> cMember = new List<String>();
		if(newArchitecture == false){
			CampaignMember campActualizar = [SELECT Id, Status, EV_ExternalId__c, EV_FormatoDeAsistencias__c, Contact.AccountId, AccountId FROM CampaignMember WHERE Id = :IdInvitacion];
        if(campActualizar.Status == 'Registro confirmado' || campActualizar.Status == 'QR enviado'){
            responseToShow.Description = 'Ya se ha inscrito en el evento';
            responseToShow.idInvitacion = campActualizar.EV_ExternalId__c;
            fillRestResponse(res, responseToShow, 202);
        }else{
            if(companion != null){
                if(campActualizar.Contact.AccountId != null){
                    lComp.addAll(createCompanion(companion, idCampaign,campActualizar.Contact.AccountId, null ));
                }else{
                    lComp.addAll(createCompanion(companion, idCampaign,campActualizar.AccountId, null ));
                }
            }
            for(CampaignMember cM : lComp){
                cMember.add(cM.Id);
            }

            campActualizar.Status = 'Registro confirmado';
				campActualizar.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
            update campActualizar;
            responseToShow.Description = 'Registro completado';
            responseToShow.idInvitacion = campActualizar.EV_ExternalId__c;
            if(lComp != null){
					for(CampaignMember cM : [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id in :cMember]){
                    cMExternal.add(cM.EV_ExternalID__c);
                }
                responseToShow.idInvitacionCompanion = cMExternal;
            }
            fillRestResponse(res, responseToShow, 200);
			}
		}else{
			EV_CampaignMemberC__c campCActualizar = [SELECT Id, EV_Status__c, EV_ExternalId__c, EV_FormatoDeAsistencias__c, EV_ContactId__r.AccountId, EV_AccountId__c  FROM EV_CampaignMemberC__c WHERE Id = :IdInvitacion];
			if(campCActualizar.EV_Status__c == 'Registro confirmado' || campCActualizar.EV_Status__c == 'QR enviado'){
				responseToShow.Description = 'Ya se ha inscrito en el evento';
				responseToShow.idInvitacion = campCActualizar.EV_ExternalId__c;
				fillRestResponse(res, responseToShow, 202);
			}else{
				if(companion != null){
					if(campCActualizar.EV_ContactId__r.AccountId != null){
						lCompC.addAll(createCompanionC(companion, idCampaign,campCActualizar.EV_ContactId__r.AccountId, null));
					}else{
						lCompC.addAll(createCompanionC(companion, idCampaign,campCActualizar.EV_AccountId__c, null));
					}
				}
				for(EV_CampaignMemberC__c cM : lCompC){
					cMember.add(cM.Id);
				}

				campCActualizar.EV_Status__c = 'Registro confirmado';
				campCActualizar.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
				update campCActualizar;
				responseToShow.Description = 'Registro completado';
				responseToShow.idInvitacion = campCActualizar.EV_ExternalId__c;
				if(lComp != null){
					for(EV_CampaignMemberC__c cM : [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id in :cMember]){
						cMExternal.add(cM.EV_ExternalID__c);
					}
					responseToShow.idInvitacionCompanion = cMExternal;
				}
				fillRestResponse(res, responseToShow, 200);
			}
        }
        return res;
    }

    /**
     * Clientes no existentes
     */
	private static RestResponse registroNoClientes(String idEvento, EV_NoClienteMultipleWrapper datosFormulario, String accId, Boolean newArchitecture){
		EV_LogDebug.printLogDebug('RegistroNoClientes', idEvento);
		RestResponse res = RestContext.response;
		List<CampaignMember> lComp = new List<CampaignMember>();
		List<EV_CampaignMemberC__c> lCompC = new List<EV_CampaignMemberC__c>();
		List<String> idsCmember = new List<String>();
		List<String> idsCmemberC = new List<String>();
		List<String> cMExternal = new List<String>();
		List<EV_CampaignMemberC__c> listCampMemberCustom = new List<EV_CampaignMemberC__c>();
		List<CampaignMember> listCampMember = new List<CampaignMember>();
		EV_CampaignMemberC__c noClienteCMC = new EV_CampaignMemberC__c();
		CampaignMember noClienteCM = new CampaignMember();
		EV_NoClienteMultipleWrapper.CampaignMemberResponse responseToShow = new EV_NoClienteMultipleWrapper.CampaignMemberResponse();
		Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
		Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		
		if(newArchitecture){
			//Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
			listCampMemberCustom = [SELECT Id, EV_Status__c, EV_NumeroDocumento__c, EV_ExternalId__c, EV_Email__c 
									FROM EV_CampaignMemberC__c 
									WHERE EV_CampaignId__c = :idEvento 
										AND EV_LeadId__c != null 
										AND EV_LeadId__r.RecordType.DeveloperName = 'EV_Evento'
										AND EV_LeadId__r.Email = :datosFormulario.Email
										AND RecordTypeId = : rtCMC
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
        if(String.isNotEmpty(datosFormulario.NIFEmpresa)){     
			EV_CampaignMemberC__c miembroInterlocutorCustom = new EV_CampaignMemberC__c();
			CampaignMember miembroInterlocutor = new CampaignMember();     
			Id rtAccEmpresa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			List<Account> accEmpresa = new List<Account> ([SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = :datosFormulario.NIFEmpresa AND RecordtypeId =:rtAccEmpresa]);
			if(accEmpresa != null && !accEmpresa.isEmpty()){
				if(String.isNotEmpty(accId)){
					accEmpresa[0].Id = accId;
				} 
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
						RecordtypeId = rtCMC,
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
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

				if(datosFormulario.companion != null){
					List<EV_NoClienteMultipleWrapper.companion> companion = datosFormulario.companion;
					if(newArchitecture){
						lCompC.addAll(createCompanionC(companion, idEvento, null, interlocutor.Id));
						for(EV_CampaignMemberC__c cMember : lCompC){
							idsCmemberC.add(cMember.id);
						}
						responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :miembroInterlocutorCustom.Id].EV_ExternalId__c;
						if(idsCmemberC != null){
							for(EV_CampaignMemberC__c cM : [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id IN :idsCmemberC]){
								cMExternal.add(cM.EV_ExternalID__c);
							}
						}
					}else{
						lComp.addAll(createCompanion(companion, idEvento,null, interlocutor.Id ));
						for(CampaignMember cMember : lComp){
							idsCmember.add(cMember.id);
						}
						responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :miembroInterlocutor.Id].EV_ExternalId__c;
						if(idsCmember != null){
							for(CampaignMember cM : [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id IN :idsCmember]){
								cMExternal.add(cM.EV_ExternalID__c);
							}
						}
					}
				   
				} 
				responseToShow.idInvitacionCompanion = cMExternal;
				responseToShow.Description = 'Registro completado';
                fillRestResponse(res, responseToShow, 200);
                return res;

            //Control de error si está vacía la lista
            }else if(accEmpresa == null || accEmpresa.size() < 1){

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
					noClienteCMC = new EV_CampaignMemberC__c(
						EV_CampaignId__c = idEvento,
						EV_Status__c = 'Registro confirmado',
						EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
						RecordtypeId = rtCMC,
						EV_CanalOrigen__c = '003',
						EV_LeadId__c = noClienteNuevo.Id
					);
					insert noClienteCMC;

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
					List<EV_NoClienteMultipleWrapper.companion> companion = datosFormulario.companion;
					if(newArchitecture){
						lCompC.addAll(createCompanionC(companion, idEvento,null, noClienteNuevo.Id));
						for(EV_CampaignMemberC__c cMember : lCompC){
							idsCmemberC.add(cMember.id);
						} 
						responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :noClienteCMC.Id].EV_ExternalId__c;
						if(lCompC != null){
							for(EV_CampaignMemberC__c cM : [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id IN :idsCmemberC]){
								cMExternal.add(cM.EV_ExternalID__c);
							}
						}
					}else{
						lComp.addAll(createCompanion(companion, idEvento,null, noClienteNuevo.Id ));
						for(CampaignMember cMember : lComp){
							idsCmember.add(cMember.id);
						} 
						responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :noClienteCM.Id].EV_ExternalId__c;
						if(lComp != null){
							for(CampaignMember cM : [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id IN :idsCmember]){
								cMExternal.add(cM.EV_ExternalID__c);
							}
						}
					}
				}
  
				responseToShow.Description = 'Registro completado';       
				responseToShow.idInvitacionCompanion = cMExternal;
                fillRestResponse(res, responseToShow, 200);
                return res;
            }
        }
        //Para no cliente, insertamos todos indiscriminadamente. (no se actualiza uno que ya haya)
        else{
            Lead noClienteNuevo = new Lead(
                FirstName = datosFormulario.Nombre,
                LastName = datosFormulario.Apellidos,
                //EV_NumeroDocumento__c = datosFormulario.Documento,
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
				noClienteCMC = new EV_CampaignMemberC__c(
					EV_CampaignId__c = idEvento,
					EV_Status__c = 'Registro confirmado',
					EV_CanalOrigen__c = '003',
					RecordTypeId = rtCMC,
					EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
					EV_LeadId__c = noClienteNuevo.Id
				);
				insert noClienteCMC;
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
				List<EV_NoClienteMultipleWrapper.companion> companion = datosFormulario.companion;
				if(newArchitecture){
					lCompC.addAll(createCompanionC(companion, idEvento,null, noClienteNuevo.Id));
					for(EV_CampaignMemberC__c cMember : lCompC){
						idsCmemberC.add(cMember.id);
					}
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id = :noClienteCMC.Id].EV_ExternalId__c;
					if(lCompC != null){
						for(EV_CampaignMemberC__c cM : [SELECT EV_ExternalId__c FROM EV_CampaignMemberC__c WHERE Id IN :idsCmemberC]){
							cMExternal.add(cM.EV_ExternalID__c);
						}
					}   

				}else{
					lComp.addAll(createCompanion(companion, idEvento,null, noClienteNuevo.Id));
					for(CampaignMember cMember : lComp){
						idsCmember.add(cMember.id);
					}
					responseToShow.idInvitacion = [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id = :noClienteCM.Id].EV_ExternalId__c;
					if(lComp != null){
						for(CampaignMember cM : [SELECT EV_ExternalId__c FROM CampaignMember WHERE Id IN :idsCmember]){
							cMExternal.add(cM.EV_ExternalID__c);
						}
					}
				}
			}

			responseToShow.Description = 'Registro completado';
			responseToShow.idInvitacionCompanion = cMExternal;
			fillRestResponse(res, responseToShow, 200);
		   
		}
		return res;
		
    }

    private static List<CampaignMember> createCompanion(EV_NoClienteMultipleWrapper.Companion[] companionLead, String idEvento, String accId, String lId){
        EV_LogDebug.printLogDebug('CreateCompanion', string.valueOf(companionLead));
        List<Lead> leadComp = new List<Lead>();
        List<CampaignMember> cmComp = new List<CampaignMember>();
        List<Acompanante__c> acom = new List<Acompanante__c>();
        Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
        Id rtAcompananteEventos = Schema.SObjectType.Acompanante__c.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();

        for(EV_NoClienteMultipleWrapper.Companion comp : companionLead){
            if(String.isNotBlank(comp.Nombre)){
                Lead leadCompanion = new Lead(
                    FirstName = comp.Nombre,
                    LastName = comp.Apellidos,
                    EV_NumeroDocumento__c = comp.Documento,
                    EV_Idiomas__c = comp.Idioma,
                    RecordtypeId = rtLeadEvento
                );
                leadComp.add(leadCompanion);
            }
        }
        if(leadComp != null){
            Database.insert(leadComp);
        }

        for(Lead lead :leadComp){
            CampaignMember companionCM = new CampaignMember(
                CampaignId = idEvento,
                Status = 'Registro confirmado',
                EV_FormatoDeAsistencias__c = '001',
                EV_CanalOrigen__c = '003',
                LeadId = lead.Id
            );
            cmComp.add(companionCM);
        }
        if(cmComp != null){
            Database.insert(cmComp);
        }

		for(Lead lead :leadComp){
            Acompanante__c comp = new Acompanante__c();
            comp.RecordtypeId = rtAcompananteEventos;
            comp.EV_LeadAcompanante__c = lead.Id;
            if(accId != null){
                comp.EV_Accionista__c = accId;
            }else{ 
                comp.EV_AccionistaLead__c = lId;
            }
            acom.add(comp);
        }
        if(acom != null){
            Database.insert(acom);
        }

        return cmComp;
    }

	private static List<EV_CampaignMemberC__c> createCompanionC(EV_NoClienteMultipleWrapper.Companion[] companionLead, String idEvento, String accId, String lId){
		EV_LogDebug.printLogDebug('CreateCompanion', string.valueOf(companionLead));
		Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		List<Lead> leadComp = new List<Lead>();
		List<EV_CampaignMemberC__c> cmCompC = new List<EV_CampaignMemberC__c>();
		List<Acompanante__c> acom = new List<Acompanante__c>();
		Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
		Id rtAcompananteEventos = Schema.SObjectType.Acompanante__c.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();

		for(EV_NoClienteMultipleWrapper.Companion comp : companionLead){
			if(String.isNotBlank(comp.Nombre)){
				Lead leadCompanion = new Lead(
					FirstName = comp.Nombre,
					LastName = comp.Apellidos,
					EV_NumeroDocumento__c = comp.Documento,
					EV_Idiomas__c = comp.Idioma,
					RecordtypeId = rtLeadEvento
				);
				leadComp.add(leadCompanion);
			}
		}
		if(leadComp != null){
			Database.insert(leadComp);
		}
		
		for(Lead lead :leadComp){
			EV_CampaignMemberC__c companionCM = new EV_CampaignMemberC__c(
				EV_CampaignId__c = idEvento,
				EV_Status__c = 'Registro confirmado',
				EV_FormatoDeAsistencias__c = '001',
				EV_CanalOrigen__c = '003',
				RecordtypeId = rtCMC,
				EV_LeadId__c = lead.Id
			);
			cmCompC.add(companionCM);
		}
		if(cmCompC != null){
			Database.insert(cmCompC);
		}

		for(Lead lead :leadComp){
			Acompanante__c comp = new Acompanante__c();
			comp.RecordtypeId = rtAcompananteEventos;
			comp.EV_LeadAcompanante__c = lead.Id;
			if(accId != null){
				comp.EV_Accionista__c = accId;
			}else{ 
				comp.EV_AccionistaLead__c = lId;
			}
			acom.add(comp);
		}
		if(acom != null){
			Database.insert(acom);
		}

		return cmCompC;
	}
}