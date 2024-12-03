public class OS_feedbackCognitive implements Queueable, Database.AllowsCallouts{
    
    private Map<String, String> mapCaseName {get; set;}
     
	public OS_feedbackCognitive(Map<String, String> mapCaseName) 
    {
        this.mapCaseName = mapCaseName;
	}

    public void execute(QueueableContext context) 
    {
        CC_InterfaceSettings__mdt oConfig = OS_cognitiveCR.getConfig ('OS_fbCognitive');
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        

        for(String caseNumber : mapCaseName.keySet()){
            String sDescError = '';
            String sDetalleError = '';
            CC_TrazaInt__c oTraza;

            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest())
            {   
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'Feedback_Cognitive_COPS';
                oTraza.CC_FechaInicio__c = datetime.now();
            }
            SEG_fbCognitive sendFeedback = new SEG_fbCognitive();
            sendFeedback.sr = caseNumber;
            sendFeedback.des_category_real = mapCaseName.get(caseNumber);  
            String jsonToCognitive = JSON.serialize(sendFeedback);

            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(oConfig.CC_EndPoint__c );
                request.setMethod('PUT');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setClientCertificateName(oConfig.CC_Certificado__c);
                request.setBody('[' + jsonToCognitive + ']');
                
                if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                    oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);
                }
                
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    OS_receiveFromCognitive results = new OS_receiveFromCognitive();
                    
                    if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                        oTraza.CC_MensajeSalida__c = response.getBody();
                        oTraza.CC_FechaFin__c = datetime.now();
                        oTraza.CC_FinOK__c = true;
                        oListTrazas.add(oTraza);
                    }              
                }
                else {
                    if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                        sDescError = 'Error comunicaciones.';
                        sDetalleError = response.getStatusCode() + ':' + response.getBody();
                        oTraza.CC_FechaFin__c = datetime.now();
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = sDescError;
                        oTraza.CC_DetalleError__c = sDetalleError;
                        oListTrazas.add(oTraza);
                    }
                }
            } catch (Exception e) {
                
                if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                    sDescError = 'Exception: Error comunicaciones.';
                    sDetalleError = e.getMessage();
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                    oListTrazas.add(oTraza);
                }       
            }
        }
        insert oListTrazas;
    }
    
    public class SEG_fbCognitive 
    {
        public String sr; //2-912076545
        public String des_category_real; //Categoría real 1
    }
}