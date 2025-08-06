public class OS_feedbackCognitive implements Queueable, Database.AllowsCallouts{
    
    private Map<String, String> mapCaseName {get; set;}
     
	public OS_feedbackCognitive(Map<String, String> mapCaseName) 
    {
        this.mapCaseName = mapCaseName;
	}

    public void execute(QueueableContext context) 
    {
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        

        for(String caseNumber : mapCaseName.keySet()){
            String sDescError = '';
            String sDetalleError = '';
            CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
            
            oTraza.Name = 'Feedback_Cognitive_COPS';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_Identificador__c = caseNumber;

            SEG_fbCognitive sendFeedback = new SEG_fbCognitive();
            sendFeedback.sr = caseNumber;
            sendFeedback.des_category_real = mapCaseName.get(caseNumber);  
            String jsonToCognitive = JSON.serialize(sendFeedback);

            String intSetting = 'OS_fbCognitive'; //Nombre del name credential *************

            try {
                // Crear HEADER 
                Map<String,string> mHeaders =  new  Map<String,string>();  
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8'); 

                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = '[' + jsonToCognitive + ']';
                requestWrp.intSetting = intSetting;
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);

                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
                oTraza.CC_MensajeEntrada__c = String.valueOf(requestWrp.body);
                
                if (response.getStatusCode() == 200) {
                    OS_receiveFromCognitive results = new OS_receiveFromCognitive();
                    oTraza.CC_MensajeSalida__c = response.getBody(); oTraza.CC_FechaFin__c = datetime.now(); oTraza.CC_FinOK__c = true;
                    oListTrazas.add(oTraza);          
                } else {
                    sDescError = 'Error comunicaciones.';
                    sDetalleError = response.getStatusCode() + ':' + response.getBody(); oTraza.CC_FechaFin__c = datetime.now(); oTraza.CC_FinOK__c = false; oTraza.CC_TipoError__c = sDescError; oTraza.CC_DetalleError__c = sDetalleError;
                    oListTrazas.add(oTraza);
                }
            } catch (Exception e) {
                sDescError = 'Exception: Error comunicaciones.';
                sDetalleError = e.getMessage();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
                oListTrazas.add(oTraza);
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