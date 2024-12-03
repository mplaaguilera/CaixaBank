/**********************************************************************************************************************
Name:	  AV_MetricChart_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente "av_MetricChart"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
	1.0         Home Custom             Álvaro López        21/10/2020      Init version
	1.1			Fix Performance			Carolina Alonso		21/10/2021		Fix performance in the method getData
	1.2		    AV_Query IT	            Daniel Rodríguez	04/03/2022	    Change AV_Query to SOQL for User, Account, Contact
	1.3         Nueva Home              Elisabeth Rodrígez  21/10/2022      Change getData method and add getNotAssigned method
	1.4			US538800				Sandra Gómez		15/02/2023		Change getData if AV_InOutbound__c
	1.5			US570560				Luis Fernández 		29/03/2023		Added a new attribute (hasLinkPermission) to inner class CharData and new logic to the getData method
	1.6			US555379				Beatriz Ruiz 		14/04/2023		Added Translation System for the charts
	1.7			US719862				Gonzalo Ávila		04/10/2023		Delete methods related to AV_ShowHomeV4 permission (Prio 2.0)
***********************************************************************************************************************/
public with sharing class AV_MetricChart_Controller {

    private static final String USER_ID_TAG = '#userId';


    public class ChartData {
        @AuraEnabled
        public Integer numRecords;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String reportId;
		@AuraEnabled
		public List<Integer> numRecordsList;
		@AuraEnabled
		public Boolean hasLinkPermission;
    }

    /**
	* Method that retrieve de custom metadata type "AV_ConfiguracionGrafico__mdt" data and returns the formated info for the LWC
	* @param metadataChart custom metadata type's developername
	* @return ChartData class with chart data used in LWC
	*/
	@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    @AuraEnabled(cacheable=true)
    public static ChartData getData(String metadataChart) {
		if(!String.isBlank(metadataChart)){
			AV_ConfiguracionGrafico__mdt chartConfig = [SELECT DeveloperName, 
				Label, AV_Data__c,
				AV_ReportName__c,
				AV_TipoGrafico__c,
				AV_Redirect__c 
				FROM AV_ConfiguracionGrafico__mdt
				WHERE DeveloperName = :metadataChart limit 1];
			String queryString = chartConfig.AV_Data__c;
			if(chartConfig.AV_Data__c.containsIgnoreCase(USER_ID_TAG)){
				String userId = String.valueOf(UserInfo.getUserId());
				queryString = chartConfig.AV_Data__c.replaceAll(USER_ID_TAG, userId);
			}

			ChartData chart = new ChartData();

			if(
			   metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS
			|| metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS_SENSIBLEDATA
			|| metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS_SENSIBLEDATABANCAPR
			|| metadataChart == AV_AppConstants.PENDING_CONVERSATION
			|| metadataChart == AV_AppConstants.PENDING_CONVERSATION_BANCAPRIVADA
			|| metadataChart == AV_AppConstants.REPORT_TODAYS_APPOINTMENTS
			|| metadataChart == AV_AppConstants.TODAYS_APPOINTMENTS_BANCAPRIVADA
			){

				List<AggregateResult> sobjectList = Database.query(queryString);
				if(metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS || metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS_SENSIBLEDATA || metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS_SENSIBLEDATABANCAPR ){
					Integer numPriorizador = 0;
					Integer numExpCliente = 0;
					Integer numIniciativaGestor = 0;
					Integer numAlertaComercial = 0;
					Integer numOnboarding = 0;

					for(AggregateResult taskObject : sobjectList){
						if(taskObject.get('DeveloperName') == AV_AppConstants.TASKPRIORIZADOR_RT){
							numPriorizador = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKEXPCLIENT_RT){
							numExpCliente = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKINICIATIVA_RT){
							numIniciativaGestor = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKALERTACOM_RT){
							numAlertaComercial = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKONBOARDING_RT){
							numOnboarding = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
						}
					}

					List<Integer> numList = new List<Integer>{numPriorizador, numExpCliente, numIniciativaGestor, numAlertaComercial, numOnboarding};
					chart.numRecordsList = numList;
					chart.numRecords = (numPriorizador + numExpCliente + numIniciativaGestor + numAlertaComercial + numOnboarding);
				}else if(metadataChart == AV_AppConstants.REPORT_TODAYS_APPOINTMENTS || metadataChart == AV_AppConstants.TODAYS_APPOINTMENTS_BANCAPRIVADA){
					Integer numEntrada = 0;
					Integer numSalida = 0;
					for(AggregateResult activityObject : sobjectList){
						if(activityObject.get('AV_InOutbound__c') == AV_AppConstants.INOUTBOUND_ENTRADA || activityObject.get('AV_InOutbound__c') == AV_AppConstants.INOUTBOUND_ENTRADA_OLD){
							numEntrada = (Integer) activityObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(activityObject.get('AV_InOutbound__c') == AV_AppConstants.INOUTBOUND_SALIDA || activityObject.get('AV_InOutbound__c') == AV_AppConstants.INOUTBOUND_SALIDA_OLD){
							numSalida = (Integer) activityObject.get(AV_AppConstants.COUNT_RESULTS);
						}
					}
					List<Integer> numList = new List<Integer>{numEntrada, numSalida};
					chart.numRecordsList = numList;
					chart.numRecords = (numEntrada + numSalida);
				}else if(metadataChart == AV_AppConstants.PENDING_CONVERSATION || metadataChart == AV_AppConstants.PENDING_CONVERSATION_BANCAPRIVADA){
					Integer numMuro = 0;
					Integer numStopGo = 0;
					Integer numLlamadas = 0;
					for(AggregateResult notifymeObject : sobjectList){
						if(notifymeObject.get('AV_OrigenAct__c') == AV_AppConstants.ORIGEN_ACT_MURO){
							numMuro = (Integer) notifymeObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(notifymeObject.get('AV_OrigenAct__c') == AV_AppConstants.ORIGEN_ACT_R2B){
							numStopGo = (Integer) notifymeObject.get(AV_AppConstants.COUNT_RESULTS);
						}else if(notifymeObject.get('AV_OrigenAct__c') == AV_AppConstants.ORIGEN_ACT_LLAMADAS){
							numLlamadas = (Integer) notifymeObject.get(AV_AppConstants.COUNT_RESULTS);
						}
					}
					List<Integer> numList = new List<Integer>{numMuro, numStopGo, numLlamadas};
					chart.numRecordsList = numList;			
					chart.numRecords = (numMuro + numStopGo + numLlamadas);
				}
			}else{
				chart.numRecords = Database.countQuery(queryString);
			}

			List<String> translationNames = new List<String>{chartConfig.Label};
			
			Map<String, String> translations = CIBE_TranslationUtilities.getInstance()
				.addTranslationNames(translationNames)
				.queryTranslations()
				.getTranslations();

			chart.title = String.isNotBlank(translations.get(chartConfig.Label)) ? translations.get(chartConfig.Label) : chartConfig.Label;
			List<Report> rep = [Select Id from Report where DeveloperName = :chartConfig.AV_ReportName__c];

			if(rep.size() > 0)chart.reportId = rep != null ? rep[0].Id : null;
			chart.hasLinkPermission = (FeatureManagement.checkPermission(AV_AppConstants.EXTENDEDHOME_LINK) && chartConfig.AV_Redirect__c);
			
			return chart;
		}
		return null;
    }
}