public class SEG_feedbackCognitive implements Queueable, Database.AllowsCallouts{

	private String caseNumber {get; set;}
	private String crName {get; set;}
     
	public SEG_feedbackCognitive(String caseNumber, String crName) 
    {
		this.caseNumber = caseNumber;
		this.crName = crName; 
	}

    public void execute(QueueableContext context) 
    {
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>(); 

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c();   
        oTraza = new CC_TrazaInt__c();
        oTraza.Name = 'Feedback_Cognitive_Segmentos';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;
        
        List<SEG_fbCognitive> lstFeedbacks = new List<SEG_fbCognitive>();
        SEG_fbCognitive sendFeedback = new SEG_fbCognitive();
        sendFeedback.sr = caseNumber;
        sendFeedback.des_category_real  = crName; 
        lstFeedbacks.add(sendFeedback);
        String jsonToCognitive = JSON.serialize(lstFeedbacks);

        // Custom Setting
        String intSetting = 'SEG_fbCognitive';

        try {
            
            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);

            CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
            requestWrp.body = jsonToCognitive;
            requestWrp.intSetting = intSetting;
            requestWrp.method = 'PUT';
            requestWrp.mHeaders = mHeaders;
            requestWrp.mUriParams = null;
            requestWrp.mQueryParams = null;

           HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);

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
    
    public class SEG_fbCognitive 
    {
        public String sr; //2-912076545
        public String des_category_real ; //Categoría real 1
    }

    public List<Datos> datos;

	public class Datos {
		public String sr;
		public String clasificacion;
	}
}