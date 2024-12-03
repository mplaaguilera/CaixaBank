public with sharing class CC_Detector_Idioma {
    //@future(callout=true)
    public static void getIdioma(List<Id> oListRevApp, String entidadAct){
        //String resultado;
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        List<CC_ST_AppReviews__c> oListReview = new List<CC_ST_AppReviews__c>();
        List<CC_ST_AppReviews__c> oListAppReview = new List<CC_ST_AppReviews__c>();
        
        if (entidadAct == 'App Review'){
            oListReview = [SELECT Id, Content__c, CC_Idioma__c
                                                     FROM CC_ST_AppReviews__c 
                                                     WHERE Id IN :oListRevApp];
        }
        CC_TrazaInt__c oTraza;
        String sDescError = '';
        String sDetalleError = '';
        
        String idioma;
        String txtconfianza;
        Decimal confianza;
        
        // Recuperar configuración integración DETIDI.
        CC_InterfaceSettings__mdt oConfig = getConfigDETIDI ('CC_DETIDI');
        for(CC_ST_AppReviews__c Reviews : oListReview){
            try{
                if (oConfig != null){    
                    // Incorporar los datos preconfigurados.
                    if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                        oTraza = new CC_TrazaInt__c();
                        oTraza.Name = 'DETIDI';
                        oTraza.CC_FechaInicio__c = datetime.now();
                    }
                    String texto = Reviews.Content__c;
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(oConfig.CC_EndPoint__c );
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    request.setClientCertificateName(oConfig.CC_Certificado__c);
                    texto = texto.replaceAll('\r\n|\n|\r',' ');
                    texto = texto.replaceAll('"','');
                    texto = texto.replaceAll('[^\\p{L}\\p{N}\\p{P}\\p{Z}]','');
                    request.setBody('{"text":"' + texto + '"}');
                    HttpResponse response = http.send(request);
                    if (oConfig != null){
                        if (oConfig.CC_TrazaEntrada__c){
                            oTraza.CC_MensajeEntrada__c = String.valueOf(request);
                        }
                    }
                    
                    if (response.getStatusCode() == 200) {
                        Object results = (Object) JSON.deserializeUntyped(response.getBody());
                        Map<String, Object> agencymap = (Map<String, Object>)results;
                        idioma=(String)agencymap.get('language');
                        txtconfianza=(String)agencymap.get(idioma);
                        confianza=Decimal.valueOf(txtconfianza.replaceAll('[^.\\d]',''));
                        if (confianza>0.9) {
                            //resultado=idioma;
                            //Actualizar App Review con el idioma
                            CC_ST_AppReviews__c oAppReview = new CC_ST_AppReviews__c();
                            oAppReview.Id = Reviews.Id;
                            if (idioma == 'esp'){
                                oAppReview.CC_Idioma__c = 'es';
                            } else if (idioma == 'cat'){
                                oAppReview.CC_Idioma__c = 'ca';
                            } else if (idioma == 'eng'){
                                oAppReview.CC_Idioma__c = 'en';
                            }
                            
                            oListAppReview.add(oAppReview);
                        }
                    } else {
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = response.getStatusCode() + ':' + response.getBody();
                    }
                    
                }
            }catch(Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }
            
            // Finalizar traza.
            if (oConfig != null){
                if ((oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null){
                    oTraza.CC_FechaFin__c = datetime.now();
                    // No hay mensaje de salida. Solo devuelve 200 - OK.
    
                    if (sDescError != ''){
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalleError;
                    }else{
                        oTraza.CC_FinOK__c = true;
                    }
                }
            }
            
            if (oTraza != null){
                oListTrazas.add(oTraza);
            }
        }
        if (!oListAppReview.isEmpty()){
            Database.SaveResult[] oResultListAppReview = Database.update(oListAppReview, false);
        }

        if (!oListTrazas.isEmpty()){
            Database.SaveResult[] oResultTrazas = Database.insert(oListTrazas, false);
        }      
    }
    
    /*
        Recuperar configuración de la integración.
    */
    static private CC_InterfaceSettings__mdt getConfigDETIDI (String sInterfaz){
        if (sInterfaz == null){
            return null;
        }

        if (sInterfaz == ''){
            return null;
        }

        CC_InterfaceSettings__mdt oInterfaz;

        List<CC_InterfaceSettings__mdt> oConfig = [SELECT Id, CC_EndPoint__c, CC_Certificado__c, CC_TrazaActiva__c, 
                                                   CC_TrazaEntrada__c, CC_Activa__c
                                                   FROM CC_InterfaceSettings__mdt 
                                                   WHERE DeveloperName =: sInterfaz];
        if (oConfig.size()==1){
            if (oConfig[0] != null)
                oInterfaz = oConfig[0];
        }

        return oInterfaz;
    }
}