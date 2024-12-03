public with sharing class SEG_feedbackCogFFEE implements Queueable, Database.AllowsCallouts{
     private String caseNumber {get; set;}
	private String crName {get; set;}
     
	public SEG_feedbackCogFFEE(String caseNumber, String crName) 
    {
		this.caseNumber = caseNumber;
		this.crName = crName; 
	}

    public void execute(QueueableContext context) 
    {

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();   
        oTraza = new CC_TrazaInt__c();
        oTraza.Name = 'Feedback_Cognitive_Segmentos';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;
        
        List<SEG_fbCognitiveFFEE> lstFeedbacks = new List<SEG_fbCognitiveFFEE>();
        SEG_fbCognitiveFFEE sendFeedback = new SEG_fbCognitiveFFEE();
        sendFeedback.pkCodSr = caseNumber;
        sendFeedback.des_category_real  = crName; 
        lstFeedbacks.add(sendFeedback);
        String jsonToCognitive = JSON.serialize(lstFeedbacks);

        // Custom Setting
        String intSetting = 'SEG_fbCognitive_FFEE';

        try {
            
            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);

            CBK_HttpServiceIntegration.RequestWapper rqwpr = new CBK_HttpServiceIntegration.RequestWapper();
            rqwpr.body = jsonToCognitive;
            rqwpr.intSetting = intSetting;
            rqwpr.method = 'PUT';
            rqwpr.mHeaders = mHeaders;
            rqwpr.mUriParams = null;
            rqwpr.mQueryParams = null;

            
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(rqwpr);
            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);

            if (response.getStatusCode() == 200) {
                oTraza.CC_MensajeSalida__c = response.getBody();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = true;        
            }else{
                oTraza.CC_MensajeSalida__c = response.getBody();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
            }
        } catch (Exception e) {
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            oTraza.CC_TipoError__c = 'Error comunicaciones.';
            oTraza.CC_DetalleError__c = e.getMessage();
        }
        insert(oTraza);
    }
    
    public class SEG_fbCognitiveFFEE 
    {
        public String pkCodSr; //2-912076545
        public String des_category_real ; //Categoría real 1
    }
}