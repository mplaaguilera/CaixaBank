public with sharing class SIR_cls_WS_SIREC{

    public static List<Object> llamar(String body, String destino, string metodo){
        List<Object> response = new List<Object>();
        HttpRequest req;
        HttpResponse res;
        try {
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            mHeaders.put('Accept-Language', 'es');
                        
            req = CBK_HttpServiceIntegration.getRequest(body, destino, metodo, mHeaders);    
            res = CBK_HttpServiceIntegration.callHttpService(req, 'SIR', destino);
                    
            Map<String, Object> desearilazedItem = (Map<String, Object>)JSON.deserializeUntyped(res.getbody());
            Map<String, Object> respuesta= (Map<String, Object>)desearilazedItem.get('respuesta') ;
            Map<String, Object> info = (Map<String, Object>)desearilazedItem.get('info');
            //Las siguientes líne existe porque nos están pasando una lista, habría que ver porque esto es así
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

                CBK_log.error('Error : SIR_cls_WS_SIREC.llamar -  '+ destino + ' el request ' + body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody());                
            }                       
            return response;
            
        } catch (Exception ex) {
            response.add('KO');
            response.add('Se ha producido un error, contacte con el administrador.');
            response.add(res.getStatusCode() + ' - ' +  mapHttpMsg.get(res.getStatusCode()));
            CBK_log.error(ex, 'Error : SIR_cls_WS_SIREC.llamar -  '+ destino + ' con request ' + body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody() + ' ' + ex.getTypeName() + ': ' + ex.getMessage());
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