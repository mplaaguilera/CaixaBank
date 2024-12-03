@RestResource(urlMapping='/CC_Encuestas/*')
global without sharing class CC_WS_LimeSurvey_Ret extends CBK_HttpServiceIntegration_Abstract{

    
    global class CC_WS_LimeSurvey_Input {
        global String ticketId {get;set;}
        global String id {get;set;}
        global Datetime fecha {get;set;}
        global List<CC_WS_LimeSurvey_QA> resultadoEncuesta {get;set;}

    }
    
    global class CC_WS_LimeSurvey_Output {
        global String sCodError {get;set;}
        global String sDetalleError {get;set;}
    }
     global class CC_WS_LimeSurvey_QA {
        global String codPregunta {get;set;}
        global String respuesta {get;set;}

     }

    
    private static String validarDatosEntrada (CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input oDatos){
        if (oDatos != null)
        {
            if (String.isBlank(oDatos.ticketId ) || String.isBlank(oDatos.id)){
                return 'KO';
            }
        } else{
            return 'KO';
        }
            
        return 'OK';
    }
    private static CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output crearRespuesta (String codError, String mensaje){
    //Creo el mensaje OK/Error
    CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output oAux = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output ();
            
            oAux.sCodError = codError;
            oAux.sDetalleError = mensaje;

        return oAux;
    }
    private static Map<String,Object> recuperarCasoSegunTipoEncuesta (String tipoEncuesta, String rCaseNum){
        //Recupero el Id de caso dependiendo del Tipo encuesta seteado en el Custom setting
        Boolean esEncuestaChat = false;
        Case nCase = new Case();
        Map<String,Object> tipoCaso = new Map<String,Object>();
        List<CC_Envio_Encuesta__c> rTipoEncuesta=[SELECT CC_Id_Encuesta__c
                                                FROM CC_Envio_Encuesta__c  
                                                WHERE CC_Tipo_Encuesta__c = 'Chat Cognitivo' OR CC_Tipo_Encuesta__c = 'Chat'];
                                            
        for(CC_Envio_Encuesta__c e : rTipoEncuesta){
            if(e.CC_Id_Encuesta__c == tipoEncuesta){
                esEncuestaChat = true;
            }
        }

        if(esEncuestaChat){
            nCase = [SELECT Id FROM Case WHERE (CC_Id_Cognitivo__c = :rCaseNum  OR CaseNumber = :rCaseNum) LIMIT 1];
        }
        else{
            if (rCaseNum.length() > 17){
                nCase.Id = (ID)rCaseNum;
            }else{
                nCase.Id = [SELECT Id FROM Case WHERE CaseNumber = :rCaseNum ].Id;
            }
        }
            
        tipoCaso.put('Caso', nCase);
        tipoCaso.put('tipoEncuesta', tipoEncuesta);
            
        return  tipoCaso;
    }
    private static List<CBK_Resultado_Encuesta__c> crearResultadoEncuesta(Map<String,Object> mapTipoCaso, List<CC_WS_LimeSurvey_QA> resultadoEncuesta, Datetime fecha){
        List<CBK_Resultado_Encuesta__c> resultadoDeEncuesta = new List<CBK_Resultado_Encuesta__c>();
        
        for(CC_WS_LimeSurvey_QA resultado :resultadoEncuesta){
            if(resultado.codPregunta.startsWith('Xs00')||resultado.codPregunta.startsWith('Vs00')){
                CBK_Resultado_Encuesta__c res = new CBK_Resultado_Encuesta__c();
                res.CBK_Case__c =((Case) mapTipoCaso.get('Caso')).Id;
                res.CBK_Pregunta__c = resultado.codPregunta;
                res.CBK_Respuesta__c = resultado.respuesta;
                res.CBK_Fecha_Encuesta__c = fecha;
                res.CBK_Tipo_Encuesta__c = (String) mapTipoCaso.get('tipoEncuesta');
                resultadoDeEncuesta.add(res);
            }
            }
        return resultadoDeEncuesta;
    }
    
    @HttpPut
    global static List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> putRtaLimeServey(List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input> oDataIn){
        List<CBK_Resultado_Encuesta__c> resultadoDeEncuesta = new List<CBK_Resultado_Encuesta__c>();
        List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> oRes = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output>();
        Datetime dtStart = Datetime.now();
        RestRequest req =  RestContext.request;
        RestResponse res = RestContext.response;
        if (oDataIn != null)        {
            req.requestBody = Blob.valueOf(String.valueOf(oDataIn));
            for (CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input oForm : oDataIn){
                String sValido = validarDatosEntrada (oForm);
                if (sValido == 'OK'){
                    try{
                        Map<String,Object> mapTipoCaso = recuperarCasoSegunTipoEncuesta(oDataIn[0].id, oDataIn[0].ticketId);
                       if(oDataIn[0].resultadoEncuesta != null && oDataIn[0].resultadoEncuesta.size()!= 0){
                            resultadoDeEncuesta = crearResultadoEncuesta(mapTipoCaso, oDataIn[0].resultadoEncuesta, oDataIn[0].fecha);
                           oRes.add(crearRespuesta('200', 'Registro Insertado.'));
                           res.statusCode = 200;
                        }else{
                            oRes.add(crearRespuesta('400', 'No se recibieron preguntas y respuestas.'));
                            res.statusCode = 400;
                       }
                }catch (Exception e) {
                    oRes.add(crearRespuesta('404', 'Error al insertar Registros.')); 
                    res.statusCode = 404;
                }
                    
                } else {
                    oRes.add(crearRespuesta('412', 'Datos obligatorios no informados.')); 
                    res.statusCode = 412;
                }
            }
            if(!resultadoDeEncuesta.isEmpty()){
             insert resultadoDeEncuesta;
            }
        }
        //Registramos trazas
        res.responseBody= Blob.valueOf(String.valueOf(oRes));
        Datetime dtEnd = Datetime.now();
        register(req,res,dtStart,dtEnd,'CC_WS_LimeSurvey','CC_WS_LimeSurvey');

        return oRes;
    }

   
}