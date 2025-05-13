/**
*   @description OS_Detector_Idioma
*/
public with sharing class OS_Detector_Idioma
{
    /**
     *  @description clase que lanza ws contra cognitive para detectar idioma
     *  @return void
     */
    @future(callout=true)
    public static void setIdiomaCaso(List<Id> casoId, String fromAddress, String buzon, String nombreBuzon, String eBody, Boolean isAcuse)
    {
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        //recuperamos la info del caso
        List<Case> listCase = new List<Case>();
        listCase = [select id, Casenumber, Description,ContactId,Contact.CC_Idioma__c,Contact.Account.AV_Idioma__c, CC_Canal_Procedencia__c from Case where id in:casoId];
        for(Case caso:listCase)
        {
            string cuerpoAnalisis;
            if(String.isBlank(caso.Description))
            {
                cuerpoAnalisis='';
            }
            else {
                if(caso.Description.length()>=150)
                {
                    cuerpoAnalisis=caso.Description.substring(0, 150);
                }
                else {
                    cuerpoAnalisis=caso.Description;
                } 
            }
            
            
            cuerpoAnalisis=cuerpoAnalisis.replaceAll('\r\n|\n|\r',' ');
            OS_DETIDI__mdt paramDETIDI = getParamtersDETIDI();

            CC_TrazaInt__c oTraza;
            String sDescError = '';
            String sDetalleError = '';
            
            String idioma;
            String txtconfianza;
            Decimal confianza;

            String intSetting = 'OS_DETIDI';

            try{

                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'DETIDI_Cops';
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_Identificador__c = caso.Casenumber;

                // Crear HEADER 
                Map<String,string> mHeaders =  new  Map<String,string>();  
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8'); 

                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = '{"text":"' + cuerpoAnalisis + '"}';
                requestWrp.intSetting = intSetting;
                requestWrp.method = 'POST';
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);

                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);

                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'DETIDI_Cops';
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_MensajeEntrada__c = String.valueOf(request);
                oTraza.CBK_Body__c = requestWrp.body;


                if (response.getStatusCode() == 200) {
                    oTraza.CC_MensajeSalida__c = response.getBody();
                    Object results = (Object) JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> agencymap = (Map<String, Object>)results;
                    txtconfianza=(String)agencymap.get((String)agencymap.get('language'));
                    confianza=Decimal.valueOf(txtconfianza.replaceAll('[^.\\d]',''));
                    
                    if (confianza>paramDETIDI.OS_Sensibilidad__c) {
                        idioma=(String)agencymap.get('language');
                        if(idioma=='cat')
                        {
                            idioma='ca';
                        }
                        if(idioma=='esp')
                        {
                            idioma='es';
                        }
                        if(idioma=='eng')
                        {
                            idioma='en';
                        }
                    }                        
                    
                }else {
                    sDescError = 'Error comunicaciones.';
                    sDetalleError = response.getStatusCode() + ':' + response.getBody();
                }
            }catch(Exception e) {
                // Error comunicaciones.
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
            }
            
            oTraza.CC_FechaFin__c = datetime.now();
            // No hay mensaje de salida. Solo devuelve 200 - OK.
            if (sDescError != ''){
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }else{
                oTraza.CC_FinOK__c = true;
            }

            if (oTraza != null){
                oListTrazas.add(oTraza);
            } 

            if(idioma!='no confiable')
            {
                caso.CC_Idioma__c=idioma;
            }

            //ES por defecto
            if(caso.CC_Idioma__c == null) 
            {
                caso.CC_Idioma__c = 'es';
            }
        }
        if (!oListTrazas.isEmpty()){
            Database.SaveResult[] oResultTrazas = Database.insert(oListTrazas, false);
        }
        if(!listCase.isEmpty())
        {
            update listCase;
        }
        
        if(isAcuse)
        {
           
            OS_Acuse_Recibo.enviarAcuse(listCase[0], fromAddress, buzon, nombreBuzon, eBody);   
        } 
    }
    
    static private OS_DETIDI__mdt getParamtersDETIDI()
    {
        OS_DETIDI__mdt parameter;
        List<OS_DETIDI__mdt> oConfig = [SELECT Id, OS_Sensibilidad__c, OS_WS_Activo__c FROM OS_DETIDI__mdt WHERE DeveloperName = 'Parametros'];
        if (oConfig.size()==1){
            parameter = oConfig[0];
        }
        return parameter;
    }
}