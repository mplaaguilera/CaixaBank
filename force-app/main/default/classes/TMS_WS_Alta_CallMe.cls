@RestResource(urlMapping = '/tms/case/event/alta')
global with sharing class TMS_WS_Alta_CallMe extends CBK_HttpServiceIntegration_Abstract {
    @HttpPost
    global static TMS_WS_Alta_CallMe_DTO.ResponseDTO altaCallme(){
        TMS_WS_Alta_CallMe_DTO.RequestDTO requestTms;
        TMS_WS_Alta_CallMe_DTO.ResponseDTO responseTms;
        try{
            Datetime dtStart = CBK_UtilsDate.nowDT();
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            
            //Registro alta evento
			requestTms = (TMS_WS_Alta_CallMe_DTO.RequestDTO) JSON.deserialize(requestBody, TMS_WS_Alta_CallMe_DTO.RequestDTO.class);

            Event evento= new Event();
            
            Datetime fechaInicio = null;
            Datetime fechaFin = null;

            String numpersoDecimal = CSBD_AppUtilities.formatearNumperso(requestTms.numperSolicitanteCita);
            
            List<Case> expediente = [SELECT Id, CaseNumber, OwnerId, TMS_Numexp__c, ContactId, AccountId, Account.Name FROM Case WHERE TMS_Numexp__c = :requestTms.numExp AND Contact.AV_NumPerso__c = :numpersoDecimal];
            //Comprueba que el caso exista y se haya introducido correctamente
            if(!expediente.isEmpty()){
                evento.WhatId = expediente[0].Id;
                evento.Subject ='Call Me ' + expediente[0].TMS_Numexp__c + ' - ' + expediente[0].Account.Name;
                evento.ownerId= expediente[0].OwnerId;
                //evento.AccountId = expediente[0].AccountId;
                evento.WhoId = expediente[0].ContactId;
                evento.RecordTypeId=Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('TMS_Evento').getRecordTypeId();
                evento.CC_Telefono__c = requestTms.telefonoContacto;
                evento.Description = requestTms.comentario;
                evento.CSBD_Evento_Estado__c = 'Pendiente';
                //Si la hora introducida es menor que la hora actual
                if(dtStart.hour() > Integer.ValueOf(requestTms.horaInicio)){
                    //La hora inicio y la hora fin son para el día siguiente
                    fechaInicio= Datetime.newInstance(dtStart.date().addDays(1),Time.newInstance(Integer.ValueOf(requestTms.horaInicio),0,0,0));
                    if(requestTms.horaFin != null){
                        fechaFin= Datetime.newInstance(dtStart.date().addDays(1),Time.newInstance(Integer.ValueOf(requestTms.horaFin),0,0,0));
                    } else {
                        fechaFin = fechaInicio.addHours(1);
                    } 
                }
                else{
                    fechaInicio= Datetime.newInstance(dtStart.date(),Time.newInstance(Integer.ValueOf(requestTms.horaInicio),0,0,0));
                    if(requestTms.horaFin != null){
                        fechaFin= Datetime.newInstance(dtStart.date(),Time.newInstance(Integer.ValueOf(requestTms.horaFin),0,0,0));
                    } else {
                        fechaFin = fechaInicio.addHours(1);
                    }
                    
                }
                evento.StartDateTime = fechaInicio;
                evento.EndDateTime = fechaFin;
                insert evento;
                List<Event> eventos = [SELECT Id FROM Event WHERE Id = :evento.Id];
                if(!eventos.isEmpty()){
                    responseTms = new TMS_WS_Alta_CallMe_DTO.ResponseDTO();
                    responseTms.estado = 'OK';
        
                    RestResponse res = RestContext.response;
                    res.statusCode = 200;
                    res.addHeader('Content-Type', 'application/json; charset=utf-8');
                    res.responseBody = Blob.valueOf(json.serialize(responseTms));
                    
                    Datetime dtStop = Datetime.now();
                    register(req, res, dtStart, dtStop, '','TMS Alta Event Case');
			        return responseTms;
                }
                else{
                    responseTms = new TMS_WS_Alta_CallMe_DTO.ResponseDTO();
                    responseTms.estado = 'KO';
                    responseTms.mensajeError = 'No se ha introducido el evento correctamente';
        
                    RestResponse res = RestContext.response ;
                    res.statusCode = 200;
                    res.addHeader('Content-Type', 'application/json; charset=utf-8');
                    res.responseBody = Blob.valueOf(json.serialize(responseTms));
			        return responseTms;
                }
            }else{
                
                responseTms = new TMS_WS_Alta_CallMe_DTO.ResponseDTO();
                responseTms.estado = 'KO';
            	responseTms.mensajeError = 'El solicitante no está asociado al expediente proporcionado.';
    
                RestResponse res = RestContext.response ;
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                res.responseBody = Blob.valueOf(json.serialize(responseTms));
			return responseTms;
            }
            

            //Respuesta
            
        }catch(Exception ex){
            CBK_log.error(ex, 'Error WS /tms/case/event/alta ');
            responseTms = new TMS_WS_Alta_CallMe_DTO.ResponseDTO();
            responseTms.estado = 'KO';
            responseTms.mensajeError = ex.getMessage();

            RestResponse res = RestContext.response ;
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json; charset=utf-8');
            res.responseBody = Blob.valueOf(json.serialize(responseTms));
			return responseTms;
        }
    }
}