public with sharing class SIR_cls_WS_SIREC{

    public static List<Object> llamar(String body, String destino, string metodo){
        CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
        reqWrapper.body = body;
        reqWrapper.intSetting = destino;
        reqWrapper.method = metodo;

        reqWrapper.mHeaders =  new  Map<String,string>();
        reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
        reqWrapper.mHeaders.put('Accept-Language', 'es');
        reqWrapper.mUriParams = new  Map<String,string>();
        reqWrapper.mQueryParams = new  Map<String,string>();
        return llamar(reqWrapper);
    }
    public static List<Object> llamar(CBK_HttpServiceIntegration.RequestWapper reqWrapper){
        List<Object> response = new List<Object>();
        HttpRequest req;
        HttpResponse res;
        try {
    	      		
            req = CBK_HttpServiceIntegration.getRequest(reqWrapper);              
            res = CBK_HttpServiceIntegration.callHttpService(req, 'SIR', reqWrapper.intSetting);             

            Map<String, Object> desearilazedItem = (Map<String, Object>)JSON.deserializeUntyped(res.getbody());
            Map<String, Object> respuesta= (Map<String, Object>)desearilazedItem.get('respuesta') ;
              
            
            Map<String, Object> info = (Map<String, Object>)desearilazedItem.get('info');
            //La estructura de error llega en un array
            Map<String, Object> error;
            String errormsg = '';
            String descripcionError = '';
            if(desearilazedItem.containsKey('error')){
                List<Object> lstError = (List<Object>)desearilazedItem.get('error');
                error = (Map<String, Object>)lstError.get(0);
                errormsg = ' ' + (String)error.get('codigo') + ' - ' + (String)error.get('mensaje');
                descripcionError =  (String)error.get('mensaje');
            }                        
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                if((Integer)info.get('codigo') == 1){  
                    response.add('OK');
                    response.add(respuesta);             
                }else{        
                    response.add('KO');                    
                    response.add('Se ha producido un error en la sincronización, contacte con el administrador.');
                    response.add('Error: ' + (Integer)info.get('codigo') + ' - ' + (String)info.get('descripcion'));
                }
            }else{      
                response.add('KO');   
                if(res.getStatusCode() == 300){
                   response.add('Inténtelo más tarde.');                    
                   response.add(descripcionError);
                }else{
                   response.add('Se ha producido un error en la sincronización, inténtelo más tarde.');
                   response.add('Error: ' + mapHttpMsg.get(res.getStatusCode()) + errormsg);
                }                

                CBK_log.error('Error : SIR_cls_WS_SIREC.llamar -  '+ reqWrapper.intSetting + ' el request ' + reqWrapper.body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody());                
            }                       
            return response;
            
        } catch (Exception ex) {
            response.add('KO');
            response.add('Se ha producido un error, contacte con el administrador.');
            response.add(res.getStatusCode() + ' - ' +  mapHttpMsg.get(res.getStatusCode()));
            CBK_log.error(ex, 'Error : SIR_cls_WS_SIREC.llamar -  '+ reqWrapper.intSetting + ' con request ' + reqWrapper.body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody() + ' ' + ex.getTypeName() + ': ' + ex.getMessage());
            return response;
        }
    }

    private static Map<Integer, String> mapHttpMsg = new Map<Integer,String>{300 => ' ', 
                                                                            401 => 'No autorizado',
                                                                            403 => 'Prohibido',
                                                                            404 => 'No encontrado',
                                                                            500 => 'Error en el servidor',
                                                                            503 => 'Error en el servidor',
                                                                            504 => 'El tiempo de respuesta ha superado lo permitido'};


}