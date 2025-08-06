@RestResource(urlMapping = '/tms/case/validation')
global with sharing class TMS_WS_Validation extends CBK_HttpServiceIntegration_Abstract{
    @HttpPost
    global static TMS_WS_Validation_DTO.ResponseDTO validationCallme(){
        TMS_WS_Validation_DTO.RequestDTO requestTms;
        TMS_WS_Validation_DTO.ResponseDTO responseTms;
        try{
            Datetime dtStart = Datetime.now();
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            
			requestTms = (TMS_WS_Validation_DTO.RequestDTO) JSON.deserialize(requestBody, TMS_WS_Validation_DTO.RequestDTO.class);

            String numPerSolicitanteFormat = TMS_MetodosUtiles.formatearNumperso(requestTms.numperSolicitanteCita);
            List<Case> idCaso = [SELECT Id, CaseNumber, OwnerId FROM Case WHERE TMS_Numexp__c = :requestTms.numExp AND Contact.AV_NumPerso__c = :numPerSolicitanteFormat];
            
            if(!idCaso.isEmpty()){
                responseTms = new TMS_WS_Validation_DTO.ResponseDTO();
                responseTms.estado = 'OK';

                RestResponse res = RestContext.response;
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                res.responseBody = Blob.valueOf(json.serialize(responseTms));
                
                Datetime dtStop = Datetime.now();
                register(req, res, dtStart, dtStop, '','TMS Validation Case');
                
                return responseTms;
            
            }else{
                
                responseTms = new TMS_WS_Validation_DTO.ResponseDTO();
                responseTms.estado = 'KO';
            	responseTms.mensajeError = 'No existe un caso con el número introducido';
    
                RestResponse res = RestContext.response ;
                res.statusCode = 200;
                res.addHeader('Content-Type', 'application/json; charset=utf-8');
                res.responseBody = Blob.valueOf(json.serialize(responseTms));
                
                return responseTms;
            }
        }catch(Exception ex){
            CBK_log.error(ex, 'Error WS /tms/case/validation ');
            responseTms = new TMS_WS_Validation_DTO.ResponseDTO();
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