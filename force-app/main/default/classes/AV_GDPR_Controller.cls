/**********************************************************************************************************************
Name:	  AV_GDPR_Controller
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC AV_GDPR
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY							   AUTHOR			  DATE				Description
1.0			SF - Integración con API's de GDPR	   David Rufo		  16/09/2020		  Init version
1.1			SF - Integración con API's de GDPR	   David Rufo		  16/09/2020		  Update ID's: app + treatments
1.2			US124270	   						   Eric Vazquez       13/10/2020          Update call API and Fill the new content
1.2			US124270							   Eric Vazquez		  16/10/2020		  Fix call API to save in JSON
1.3			US246780							   Sandra Gómez		  18/08/2021		  Change consentList
1.3			US258114							   Jashanpreet		  27/08/2021		  Flow
1.4			AV_Query IT							   Daniel Rodríguez	  3/02/2022			  Change AV_Query to SOQL for User and Account
1.5												   Vladislav Lityagin 14/03/2023		  Replaced checkTreatments call to checkTreatmentsFw
1.6			PMD Errors							   Humberto Vilchez   26/10/2023		  Add WITH SECURITY_ENFORCED to querys and curly space to else 
1.1         US866754                              Oscar Moreno        25/04/2024          Add  getJsonGDPR  method  
***********************************************************************************************************************/
public with sharing class AV_GDPR_Controller {

	private static final String AV_TREATMENTID_1	= '0040-A';   //Tratamiento Publicidad gestor: 0040-A
	private static final String AV_TREATMENTID_2	= '0040-B';   //Tratamiento publicidad por medios digitales (muro / email / sms): 0040-B
	private static final String AV_APP_CODE		 = 'EVA';
	private static final String YES_ADMIT		   = Label.AV_GDPR_YesAdmit; //Si Admite Publicisad Contacto Gestor
	private static final String NO_ADMIT			= Label.AV_GDPR_NoAdmit; //No Admite Publicidad Contacto Gestor
	private static final String YES_ADMIT_PME		= Label.AV_GDPR_YesAdmit_PME; //Si Admite Publicidad Medios Electrónicos
	private static final String NO_ADMIT_PME		= Label.AV_GDPR_NoAdmit_PME; //No Admite Publicidad Medios Electrónicos
	private static final String NO_INFORM		   = Label.AV_GDPR_Uninformed;
	private static final String AV_ELECTRONIC_MEDIA = Label.AV_GDPR_ConsentId4;
	private static final String AV_CONTACT_MANAGER = Label.AV_GDPR_ConsentId6;
	
    private static final Map<Integer, String> AV_TREATMENT_CODE_DESC = new Map<Integer, String>{
		//1 => Label.AV_GDPR_ConsentId1,	//'Tratamiento de datos'
		//2 => '',
		//3 => Label.AV_GDPR_ConsentId3,	//'Publicidad Telemarketing'
		4 => Label.AV_GDPR_ConsentId4,	  //'Publicidad Medios Electrónicos',
		//5 => Label.AV_GDPR_ConsentId5,	//'Publicidad Postal',
		6 => Label.AV_GDPR_ConsentId6	   //'Publicidad Contacto Gestor',
		//7 => Label.AV_GDPR_ConsentId7,	//'Cesión de datos',
		//8 => Label.AV_GDPR_ConsentId8,	//'Biometría',
		//9 => Label.AV_GDPR_ConsentId9	 //'PSU'
	};

	public class Response {
		@AuraEnabled
		public String severity;
		@AuraEnabled
		public String descError;
		@AuraEnabled
		public List<AV_GDPR_Integration.ConsentsList> listTreatments;

		public Response() {
			listTreatments = new List<AV_GDPR_Integration.ConsentsList>();
			severity = AV_AppConstants.OK;
		}
	}
	
	
	public class Alerta {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String key;
    }

	@AuraEnabled
    public static void getJsonGDPR(String recordId) {
		Account acc = [Select Id, AV_JSONAlertas__c,AV_JSONGDPR__c From Account Where Id = :recordId  limit 1];
		
        if(acc != null && acc.AV_JSONAlertas__c != null){
            List<AV_GDPR_Controller.Alerta> alertas = (List<AV_GDPR_Controller.Alerta>)JSON.deserialize(acc.AV_JSONAlertas__c, List<AV_GDPR_Controller.Alerta>.class);
            List<AV_GDPR_Controller.Alerta> alertasKey21 = new List<AV_GDPR_Controller.Alerta>();
			for(AV_GDPR_Controller.Alerta alerta : alertas){
                if(alerta.key == '21'){
                    alertasKey21.add(alerta);               
                }
            }
            
            if (!alertasKey21.isEmpty()) {
                acc.AV_JSONGDPR__c = JSON.serialize(alertasKey21[0]);                
                Database.update(acc);
            }
        }
       
    }

	
	
	@TestVisible
	private static Response checkGDPRResponse(Response resp, AV_GDPR_Integration.GDPRResponse dataGDPR, boolean checkEmpty){
		String methodName = 'checkGDPRResponse';
		//Validate the response of the API
		if (dataGDPR!=null && !AV_IntegrationConstants.HTTP_STATUS_OK.equalsIgnoreCase(dataGDPR.StatusCode)){
			resp.severity = AV_AppConstants.ERROR;
			String msg = dataGDPR.errorCode + ' - ' + dataGDPR.errorMessage;
			resp.descError = Label.AV_UnknownError + msg;
			AV_LogDebug.printLogDebug(methodName, msg);
		}
		//Fill the content to show in the component
		else if (dataGDPR!=null && dataGDPR.data!=null && dataGDPR.data.consentList!=null && !dataGDPR.data.consentList.isEmpty()){
			dataGDPR.data.consentList.sort();
			Map<Integer, AV_GDPR_Integration.ConsentsList> mapConsents = new Map<Integer, AV_GDPR_Integration.ConsentsList>();
			for(AV_GDPR_Integration.ConsentsList auxTreatment : dataGDPR.data.consentList){
				String consentDesc = AV_TREATMENT_CODE_DESC.get(auxTreatment.consentId); 
				if (String.isNotBlank(consentDesc)){
					auxTreatment.consentDesc = consentDesc;
					if (String.isBlank(auxTreatment.isConsent)){
						auxTreatment.consentContent = NO_INFORM;
					}else if(!Boolean.valueOf(auxTreatment.isConsent)){
						if(auxTreatment.consentDesc == AV_CONTACT_MANAGER){
							auxTreatment.consentContent = 'NO_ADMIT';
						}else if(auxTreatment.consentDesc == AV_ELECTRONIC_MEDIA){
							auxTreatment.consentContent = 'NO_ADMIT_PME';
						}
					}else if(Boolean.valueOf(auxTreatment.isConsent)){
						if(auxTreatment.consentDesc == AV_CONTACT_MANAGER){
							auxTreatment.consentContent = 'YES_ADMIT';
						}else if(auxTreatment.consentDesc == AV_ELECTRONIC_MEDIA){
							auxTreatment.consentContent = 'YES_ADMIT_PME';
						}
					}
					resp.listTreatments.add(auxTreatment);
					mapConsents.put(auxTreatment.consentId, auxTreatment);
				}
			}
			//Check the empty treatments
			if (checkEmpty) {
				for (Integer key : AV_TREATMENT_CODE_DESC.keySet()) {
					AV_GDPR_Integration.ConsentsList auxTreatment = mapConsents.get(key);
					if (auxTreatment == null) {
						auxTreatment = new AV_GDPR_Integration.ConsentsList();
						auxTreatment.consentId = key; 
						auxTreatment.consentDesc = AV_TREATMENT_CODE_DESC.get(key);
						auxTreatment.consentContent = NO_INFORM;
						resp.listTreatments.add(auxTreatment);
					}
				}
			}
			resp.listTreatments.sort();
		}
		return resp;
	}

	@invocableMethod(label='checkGDPR')
	public static List<Boolean> getGDPRForCampaigns(List<List<String>> fields){
        Response res = new Response();

		Response resp = new Response();
			String methodName = 'getTreatments';
			try{
				Account acc = [Select Id, AV_Numperso__c, AV_FechaRefrescoGDPR__c, AV_JSONGDPR__c From Account Where Id = :fields[0][0] WITH SECURITY_ENFORCED limit 1];

				User user = [Select Id, AV_ExternalID__c From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];

				//Customer not found or ID empty
				boolean statusOK = true;
				if (acc==null || String.isBlank(acc.AV_Numperso__c)){
					resp.severity = AV_AppConstants.ERROR;
					String msg = Label.AV_GDPR_ErrorNumper;
					resp.descError = Label.AV_UnknownError + AV_AppConstants.BREAK_LINE + msg;
					AV_LogDebug.printLogDebug(methodName, msg);
					statusOK = false;
				}
				//Employee not found or ID empty
				else if (user==null || String.isBlank(user.AV_ExternalId__c)){
					resp.severity = AV_AppConstants.ERROR;
					String msg = Label.AV_GDPR_ErrorEmployee;
					resp.descError = Label.AV_UnknownError + AV_AppConstants.BREAK_LINE + msg;
					AV_LogDebug.printLogDebug(methodName, msg);
					statusOK = false;
				}
				
				//Validate response API
				if (statusOK){
					String numper = acc.AV_Numperso__c;
					String employeeU01 = user.AV_ExternalId__c;
                    AV_GDPR_Integration.GDPRResponse dataGDPR1 = AV_GDPR_Integration.checkTreatments(AV_TREATMENTID_1, AV_APP_CODE, numper, employeeU01);
                    AV_GDPR_Integration.GDPRResponse dataGDPR2 = AV_GDPR_Integration.checkTreatments(AV_TREATMENTID_2, AV_APP_CODE, numper, employeeU01);
                    resp = checkGDPRResponse(resp, dataGDPR1, false);
                    resp = checkGDPRResponse(resp, dataGDPR2, false);
                    if('200'.equalsIgnoreCase(dataGDPR1.StatusCode) || '200'.equalsIgnoreCase(dataGDPR2.StatusCode)){
                        res =  resp;
                    }
                    AV_LogDebug.printLogDebug(methodName, '********************++++++++++++++++++++++++');
                    AV_LogDebug.printLogDebug(methodName, resp.toString());
				}
			}catch(Exception e){
				AV_LogDebug.printException(methodName, e);
				resp.severity = AV_AppConstants.ERROR;
				resp.descError = Label.AV_UnknownError + AV_AppConstants.BREAK_LINE + e.getMessage();
			}
			if(res != null){
                if(res.listTreatments != null && !res.listTreatments.isEmpty()){
                    for(AV_GDPR_Integration.ConsentsList c : res.listTreatments){
                        if(c.consentDesc == AV_CONTACT_MANAGER && Boolean.valueOf(c.isConsent)){
                            return new List<Boolean>{true};
                        } 
                        else {
							return new List<Boolean>{false};
						}
                    }
                }
			}
		return new List<Boolean>{false};
	}

}