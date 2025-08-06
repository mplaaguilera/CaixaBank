@RestResource(urlMapping = '/tms/case/upd')
global with sharing class TMS_WS_Udp_Case extends CBK_HttpServiceIntegration_Abstract{

    @HttpPost
    global static TMS_WS_Udp_Case_DTO.ResponseDTO updateCase(){
        TMS_WS_Udp_Case_DTO.RequestDTO requestTms;
        TMS_WS_Udp_Case_DTO.ResponseDTO responseTms;

        try{
            Datetime dtStart = Datetime.now();
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            
            requestTms = (TMS_WS_Udp_Case_DTO.RequestDTO) JSON.deserialize(requestBody,  TMS_WS_Udp_Case_DTO.RequestDTO.class);
            responseTms = new TMS_WS_Udp_Case_DTO.ResponseDTO();

			List<Case> expedientes = [SELECT CaseNumber, TMS_Numexp__c, OwnerId, CC_Cliente_Afectado_Lookup__c, AccountId,
										TMS_Gestoria__c, Status, CC_Telefono_Contacto__c, TMS_Telefono_Internacional__c, SuppliedEmail
										FROM Case WHERE TMS_Numexp__c = :requestTms.numExp LIMIT 1];

            List<User> ownerCaso = new List<User>();

            if(requestTms.letrado != '' && requestTms.letrado != null){
				ownerCaso = [SELECT Id FROM User WHERE EmployeeNumber = :requestTms.letrado AND IsActive = TRUE LIMIT 1];
            }
            
			if (!expedientes.isEmpty()) {
				Case expediente = expedientes[0];
                //Comprobamos si se cambia el Heredero
                Contact nuevoHeredero = TMS_MetodosUtiles.identificarNUMPERSO(requestTms.numperHeredero);
                
				if (expediente.AccountId != nuevoHeredero?.AccountId) {
					expediente.AccountId = nuevoHeredero?.AccountId;
					expediente.ContactId = nuevoHeredero?.Id;
					expediente.CC_Telefono_Contacto__c = requestTms.phoneHeredero;
					expediente.TMS_Telefono_Internacional__c = requestTms.phoneInternacionalHeredero;
					expediente.SuppliedEmail = requestTms.emailHeredero;
                }
                //Comprobamos si se cambia la Gestoría
				if (expediente.TMS_Gestoria__c != requestTms.gestoria) {
					expediente.TMS_Gestoria__c = requestTms.gestoria;
                    if(!ownerCaso.isEmpty()){
						expediente.OwnerId = ownerCaso[0].Id;
                    }
                }
                //Comprobamos si solo cambia el letrado
				else if (!ownerCaso.isEmpty() && expediente.OwnerId != ownerCaso[0].Id) {
					expediente.OwnerId = ownerCaso[0].Id;
                }
                //Comprobamos si se cambia el télefono del heredero
				if(expediente.CC_Telefono_Contacto__c != requestTMS.phoneHeredero){
					expediente.CC_Telefono_Contacto__c = requestTMS.phoneHeredero;
                }
                //Comprobamos si se cambia el teléfono internacional del heredero
				if(expediente.TMS_Telefono_Internacional__c != requestTMS.phoneInternacionalHeredero){
					expediente.TMS_Telefono_Internacional__c = requestTMS.phoneInternacionalHeredero;
                }
                //Comprobamos si se cambia el difunto
				if(expediente.CC_Cliente_Afectado_Lookup__c == null){
					expediente.CC_Cliente_Afectado_Lookup__c = TMS_MetodosUtiles.identificarNUMPERSO(requestTms.numperDifunto)?.AccountId;
                }
                
                //Comprobamos si se cambia el email del heredero
				if(expediente.SuppliedEmail != requestTMS.emailHeredero){
					expediente.SuppliedEmail = requestTMS.emailHeredero;
                }

                //Comprobamos si cambia el estado
				if (expediente.Status != requestTms.estado || expediente.Status == 'TMS_001' || expediente.Status == 'TMS_002' || expediente.Status == 'TMS_003') {
					List<Task> tareaRevision = [SELECT Id FROM Task WHERE RecordType.DeveloperName = 'TMS_Tarea' AND Type = 'Automática'
												AND Subject = 'Revisión Rechazo' AND WhatId = :expediente.Id ORDER BY CreatedDate DESC LIMIT 1];

					if (!tareaRevision.isEmpty() || expediente.Status != requestTms.estado) {
						List<Task> tareas = [SELECT Status FROM Task WHERE RecordType.DeveloperName = 'TMS_Tarea' AND WhatId = :expediente.Id AND IsClosed = FALSE];
                        if(!tareas.isEmpty()){
                            for(Task tarea: tareas){
                                tarea.Status='Rechazada';
                            }
                            
							try {
								update tareas;
							} catch (DmlException errorDml) {
								CBK_Log.error(errorDml, 'TMS_WS_Udp_Case: Error al actualizar tareas con with sharing. Se reintentará con without sharing. ' + tareas);
								tareas = TMS_WS_Upd_Case_Aux.updateTasksWithoutSharing(tareas);
                        }
						}

                    	List<CaseStatus> estadoAntiguo =new List<CaseStatus>();
                            if(requestTms.estado == 'TMS_004'){                 
							estadoAntiguo = [SELECT MasterLabel FROM CaseStatus WHERE ApiName = :expediente.Status LIMIT 1];
                            }
                        //Se crean las tareas correspondientes al cambio de estado
                        if(requestTms.estado != 'TMS_006'){ 
							List<CaseStatus> estadoNuevo = [SELECT MasterLabel FROM CaseStatus WHERE ApiName = :requestTms.estado LIMIT 1];
                            if(!estadoNuevo.isEmpty()){
								List<CC_Lista_Valores__c> nombreActividad = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'TMS - Creación de tareas automáticas'
																				AND CC_Activa__c = true AND Name = :estadoNuevo[0].MasterLabel];
                                List<Task> nuevasActividades = new List<Task>();
                                if(!nombreActividad.isEmpty()){
                                    for (CC_Lista_Valores__c nombre : nombreActividad) {
                                        Task nuevaActividad = new Task();
										nuevaActividad.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
                                        nuevaActividad.Subject = nombre.CC_Valor__c;
                                        nuevaActividad.Status = 'Open';
										nuevaActividad.WhatId = expediente.Id;
										nuevaActividad.CC_Consulta__c = expediente.TMS_Numexp__c;
                                        if(requestTms.estado == 'TMS_004'){ 
                                            nuevaActividad.CC_Categoria__c  = estadoAntiguo[0].MasterLabel;
                                        }else{
                                            nuevaActividad.CC_Categoria__c  = estadoNuevo[0].MasterLabel;
                                        }
										nuevaActividad.OwnerId = expediente.OwnerId;
                                        nuevaActividad.Type = 'Automática';
                                        nuevasActividades.add(nuevaActividad);
                                    }
                                    insert nuevasActividades;
                                }
                            }
                        }
                    }
                    //Se rechazan las tareas abiertas al cambiar de estado del caso
                    if(requestTms.estado != 'TMS_004'){
						expediente.Status = requestTms.estado;
                    } 
                }

                update expediente;
				responseTms.caseId = expediente.Id;

			} else {
                //No existe un caso con el número de expediente. Se crea uno nuevo
                Case casoNuevo = new Case();
                casoNuevo.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
                casoNuevo.Status = requestTms.estado;
                casoNuevo.Origin = 'Backend';
                casoNuevo.Subject = requestTms.numExp;
                casoNuevo.CC_Canal_Procedencia__c = 'Testamentarias';
                casoNuevo.CC_Tipo_Contacto__c = 'Gestión expediente';
                casoNuevo.CC_Cliente_Afectado_Lookup__c = TMS_MetodosUtiles.identificarNUMPERSO(requestTms.numperDifunto)?.AccountId; 
                Contact heredero = TMS_MetodosUtiles.identificarNUMPERSO(requestTms.numperHeredero);
                casoNuevo.AccountId = heredero?.AccountId;
                casoNuevo.ContactId = heredero?.Id;
                casoNuevo.TMS_Numexp__c = requestTms.numExp;
                casoNuevo.TMS_Gestoria__c = requestTms.gestoria;
                if(!ownerCaso.isEmpty()){
                    casoNuevo.OwnerId = ownerCaso[0].Id;
                } else {
                    List<Schema.PicklistEntry> picklistEntries = Schema.SObjectType.Case.fields.TMS_Gestoria__c.getPicklistValues();
                    Group queue;
					for (Group cola : [SELECT Name FROM Group WHERE Type = 'Queue' AND DeveloperName LIKE 'TMS_%']) {
                        for(Schema.PicklistEntry sp : picklistEntries){
                            if(sp.getLabel().contains(cola.Name) && String.valueof(sp.getValue()) == String.valueof(requestTms.gestoria)){
                                queue=cola;
								break;
                            }
						}
                    }
                    casoNuevo.OwnerId = queue.Id;
                    
                }
                casoNuevo.CC_Telefono_Contacto__c = requestTms.phoneHeredero;
                casoNuevo.TMS_Telefono_Internacional__c = requestTms.phoneInternacionalHeredero;
                casoNuevo.SuppliedEmail = requestTms.emailHeredero;
                
                insert casoNuevo;

                responseTMS.caseId = casoNuevo.Id;
            }
            
            responseTms.estado = 'OK';
            RestResponse res = RestContext.response ;
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json; charset=utf-8');
			res.responseBody = Blob.valueOf(JSON.serialize(responseTms));
            
            Datetime dtStop = Datetime.now();
            register(req, res, dtStart, dtStop, '','TMS Update Case');
            return responseTms;

        }catch(Exception ex){
            CBK_log.error(ex, 'Error WS /tms/case/upd ');
            responseTms = new TMS_WS_Udp_Case_DTO.ResponseDTO();
            responseTms.caseId = null;
            responseTms.estado = 'KO';
            responseTms.mensajeError = ex.getMessage();

            RestResponse res = RestContext.response ;
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json; charset=utf-8');
			res.responseBody = Blob.valueOf(JSON.serialize(responseTms));
            return responseTms;
        }
    }
}