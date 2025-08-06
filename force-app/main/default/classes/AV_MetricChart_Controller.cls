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
	1.8      	Fix PMD Errors 			Humberto Vilchez 	23/10/2023 		Add WITH SECURITY_ENFORCED to queries and fix curly braces in if else
	1.9			Buscador Fase II		Sandra Gómez		29/01/2024		change method getData to add AV_Center__c in query AV_OutstandingOpportunities
	2.0         US839366                Oscar Moreno        28/02/2024      change method getData to add AND (AV_NextEventDate__c > TODAY  OR AV_NextEventDate__c < TODAY) condition in query AV_OutstandingOpportunities
	2.1			PPM100211786			Gonzalo Ávila		24/05/2024		Create method getDataSinGestor to recieve information about the links of the new buttons below the graphs
	2.3			Fix Contador Warning    Luis Fernández      06/06/2024		Added filter to AV_AppConstants.WARNINGS_MANAGE sin gestor querie, to include the center
	2.4 		FIX06080819				Gonzalo Ávila		08/08/2024		Added filter AV_Center__c to query Home Task
	2.5			PPM100492394			Luis Fernández		20/09/2024		Added new propierties to ChartData in order to manage Pool Records and filtered records by Multigestor ownership when current user is a pool user
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
		@AuraEnabled
		public Boolean isPool = false;
		@AuraEnabled
		public String multiGestAlias;
    }

	public class SinGestorData {
		@Auraenabled
		public Integer numRecords;

		@Auraenabled
		public String reportId;

		@Auraenabled
		public Integer numClients;

		@AuraEnabled
		public String idSinGestor;

		@AuraEnabled
		public String centerAssociated;
		
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
				WHERE DeveloperName = :metadataChart  WITH SECURITY_ENFORCED limit 1];
			String queryString = chartConfig.AV_Data__c;
			List<User> userCenter;
			List<User> multiGestorUser;
			String userId = String.valueOf(UserInfo.getUserId());
			String multigestor;
			userCenter = [SELECT AV_NumeroOficinaEmpresa__c,AV_Pool__c FROM USER WHERE Id = :userId];
			if(chartConfig.AV_Data__c.containsIgnoreCase(USER_ID_TAG)){

				List<String> poolReports = new List<String>{
					AV_AppConstants.OUTSTANDING_OPP,
					AV_AppConstants.TASK_CG,
					AV_AppConstants.WARNINGS_MANAGE
				};
				
				if(userCenter[0].AV_Pool__c && poolReports.contains(metadataChart)){
					multigestor = AV_PoolEvents_Controller.getCurrentDT(userCenter[0].AV_NumeroOficinaEmpresa__c);
				}else{
					queryString = chartConfig.AV_Data__c.replaceAll(USER_ID_TAG, userId);
					
				}
				if(metadataChart == AV_AppConstants.OUTSTANDING_OPP) {
					if(userCenter!= null && !userCenter.isEmpty() && userCenter[0].AV_NumeroOficinaEmpresa__c != null) {

						queryString = (multigestor != null) ?
						chartConfig.AV_Data__c.replaceAll('=  \''+USER_ID_TAG+'\'', 'IN (\''+userId+'\',\''+multigestor+'\')')
						:chartConfig.AV_Data__c.replaceAll(USER_ID_TAG, userId);
						
						queryString = queryString + ' AND AV_Center__c = \''+userCenter[0].AV_NumeroOficinaEmpresa__c.substring(4)+'\' AND (AV_NextEventDate__c != TODAY)';
					}
				} else if(metadataChart == AV_AppConstants.TASK_CG) {
					if(userCenter!= null && !userCenter.isEmpty() && userCenter[0].AV_NumeroOficinaEmpresa__c != null) {

						queryString = (multigestor != null) ?
						 chartConfig.AV_Data__c.replaceAll('=\''+USER_ID_TAG+'\'', ' IN (\''+userId+'\',\''+multigestor+'\')')
						:chartConfig.AV_Data__c.replaceAll(USER_ID_TAG, userId);
						String centerFilter = ' AND AV_Center__c = \''+userCenter[0].AV_NumeroOficinaEmpresa__c.substring(4) + '\'';

						if(queryString.contains('GROUP BY')) {
							Integer groupByIndex = queryString.indexOf('GROUP BY');
							queryString = queryString.substring(0, groupByIndex) + centerFilter + ' ' + queryString.substring(groupByIndex);
						}
					}
				}
			}
			ChartData chart = new ChartData();
			if(metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS_SENSIBLEDATA){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.PRIOR_MANAGE_CLIENTS_SENSIBLEDATABANCAPR){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.PENDING_CONVERSATION){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.PENDING_CONVERSATION_BANCAPRIVADA){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.REPORT_TODAYS_APPOINTMENTS){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.TODAYS_APPOINTMENTS_BANCAPRIVADA){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
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
			} else if(metadataChart == AV_AppConstants.OUTSTANDING_OPP){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
				Integer numOpps=0;
				for(AggregateResult notifymeObject : sobjectList){
					numOpps =  (Integer) notifymeObject.get(AV_AppConstants.COUNT_RESULTS);
				}
				List<Integer> numList = new List<Integer>{numOpps};
				chart.numRecordsList = numList;
				chart.numRecords = numOpps;
				
			} else if(metadataChart == AV_AppConstants.TASK_CG){
				List<AggregateResult> sobjectList = capsulateQuery(queryString);
				Integer numExpCliente = 0;
				Integer numIniciativaGestor = 0;
				Integer numOnboarding = 0;
				Integer numAlertaCom = 0;
				for(AggregateResult taskObject : sobjectList){
					if(taskObject.get('DeveloperName') == AV_AppConstants.TASKEXPCLIENT_RT){
						numExpCliente = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
					}else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKINICIATIVA_RT){
						numIniciativaGestor = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
					}else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKONBOARDING_RT){
						numOnboarding = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
					}
					else if(taskObject.get('DeveloperName') == AV_AppConstants.TASKALERTACOM_RT){
						numAlertaCom = (Integer) taskObject.get(AV_AppConstants.COUNT_RESULTS);
					}
				}
				List<Integer> numList = new List<Integer>{ numExpCliente, numIniciativaGestor, numOnboarding, numAlertaCom}; //añado numAlertaCom 
				chart.numRecordsList = numList;
				chart.numRecords = ( numExpCliente + numIniciativaGestor +  numOnboarding + numAlertaCom);  //añado numAlertaCom 
			} else {

					queryString = (multigestor != null) ?
					chartConfig.AV_Data__c.replaceAll('= \''+USER_ID_TAG+'\'', 'IN (\''+userId+'\',\''+multigestor+'\')')
					:chartConfig.AV_Data__c.replaceAll(USER_ID_TAG, userId);

					if((multigestor != null)){
						queryString += ' AND AV_Center__c = \''+userCenter[0].AV_NumeroOficinaEmpresa__c.substring(4)+'\'';
					}
					
				chart.numRecords = capsulateQueryCount(queryString);
			}
			List<String> translationNames = new List<String>{chartConfig.Label};
			Map<String, String> translations = CIBE_TranslationUtilities.getInstance().addTranslationNames(translationNames).queryTranslations().getTranslations();
			chart.title = String.isNotBlank(translations.get(chartConfig.Label)) ? translations.get(chartConfig.Label) : chartConfig.Label;
			String reportToFind = chartConfig.AV_ReportName__c;
			if(!userCenter.isEmpty() && userCenter[0].AV_Pool__c && metadataChart.equals(AV_AppConstants.WARNINGS_MANAGE)){
				List<User> multigest = [SELECT Alias FROM User WHERE Id = :multigestor];
				if(multigest != null && !multigest.isEmpty()){
					chart.isPool = true;
					chart.multiGestAlias = multigest[0].Alias;
					reportToFind = AV_AppConstants.AVISOSAGESTIONARREPORTPOOL;

				}
			}
			List<Report> rep = [Select Id from Report where DeveloperName = :reportToFind WITH SECURITY_ENFORCED];
			if(rep != null && !rep.isEmpty() ) {
				chart.reportId = rep != null ? rep[0].Id : null;
			}
			chart.hasLinkPermission = (FeatureManagement.checkPermission(AV_AppConstants.EXTENDEDHOME_LINK) && chartConfig.AV_Redirect__c);
			return chart;
		}
		return null;
    }

	@AuraEnabled(cacheable=true)
	public static SinGestorData getDataSinGestor(String devName) {
		String queryString;
		String queryClients;
		String userId = String.valueOf(UserInfo.getUserId());
		List<User> userCenter = [SELECT AV_NumeroOficinaEmpresa__c,AV_Pool__c FROM USER WHERE Id = :userId];
		List<User> userSingestor = [SELECT Id FROM User WHERE Alias = 'AV-TF9' WITH SECURITY_ENFORCED LIMIT 1];
		

		SinGestorData sgestdata = new SinGestorData();
		if(userCenter[0].AV_NumeroOficinaEmpresa__c != null){

			String center = (userCenter[0].AV_NumeroOficinaEmpresa__c)?.contains(AV_AppConstants.DASH) 
			? userCenter[0].AV_NumeroOficinaEmpresa__c?.split(AV_AppConstants.DASH)[1] 
			: userCenter[0].AV_NumeroOficinaEmpresa__c;
		sgestdata.centerAssociated = center; 

		AV_ConfiguracionGrafico__mdt chartConfig = [SELECT DeveloperName, AV_Data__c, AV_ReportName__c
			FROM AV_ConfiguracionGrafico__mdt
			WHERE DeveloperName = :devName WITH SECURITY_ENFORCED limit 1];

		queryString = chartConfig.AV_Data__c;

		
		if (devName.equals(AV_AppConstants.TASK_CG)) {
			
			queryString = 'SELECT COUNT() ' + 
			'FROM Task ' + 
			'WHERE Status IN (\'Open\') ' + 
			'AND RecordType.DeveloperName IN (\'AV_AlertaComercial\', \'AV_ExperienciaCliente\', \'AV_Otros\', \'AV_Onboarding\', \'AV_Priorizador\') ' + 
			'AND AV_Center__c = \'' + center + '\'' +
			'AND OwnerId = \'' + userSingestor[0].Id + '\' '+
			'AND AV_ToDelete__c = FALSE';
			
		} else if (devName.equals(AV_AppConstants.OUTSTANDING_OPP)) {
			sgestdata.idSinGestor = userSingestor[0].Id;
			
			queryString = 'SELECT COUNT() ' + 
			'FROM OPPORTUNITY ' + 
			'WHERE OwnerId = \'' + userSingestor[0].Id + '\' ' + 
			'AND AV_Center__c = \'' + center + '\' ' + 
			'AND (( ' + 
			'    (AV_FechaAlta__c <= TODAY ' + 
			'    AND AV_FechaAlta__c >= LAST_N_DAYS:7 ' + 
			'    AND StageName = \'Potencial\' ' + 
			'    AND RecordType.DeveloperName IN (\'AV_AlertaComercial\', \'AV_CallMe\')) ' + 
			'    OR ' + 
			'    (AV_FechaProximoRecordatorio__c <= TODAY ' + 
			'    AND AV_FechaProximoRecordatorio__c >= LAST_N_DAYS:7 ' + 
			'    AND StageName = \'' + AV_AppConstants.OPP_STATUS_ENGESTION + '\' ' + 
			'    AND RecordType.DeveloperName IN (\'AV_AlertaComercial\', \'AV_CallMe\', \'AV_Propuesta\', \'AV_Iniciativa\', \'AV_Sugerencia\')) ' + 
			'    OR ' + 
			'	(( StageName = \'Potencial\' AND AV_PriorityOpportunity__c = true AND RecordType.DeveloperName in (\'AV_AlertaComercial\',\'AV_CallMe\',\'AV_Propuesta\') ))	' +
			') ' + 
			'AND (AV_NextEventDate__c != TODAY))';
					

			queryClients = chartConfig.AV_Data__c;
			queryClients = queryClients.replace('SELECT COUNT(ID)', 'SELECT COUNT_DISTINCT(AccountId)');
			queryClients = queryClients + 
			' AND AV_Center__c = \'' + center + '\'';
			if (queryClients.containsIgnoreCase(USER_ID_TAG)) {
				if(userCenter[0].AV_Pool__c){
					String multigestor = AV_PoolEvents_Controller.getCurrentDT(userCenter[0].AV_NumeroOficinaEmpresa__c);
					if(multigestor != null){

						String regexToReplace = '=  \''+USER_ID_TAG+'\'';
						queryClients = (multigestor != null) ?
						queryClients.replaceAll(regexToReplace, 'IN (\''+userId+'\',\''+multigestor+'\')')
						:queryClients.replaceAll(USER_ID_TAG, userId);
					}
					
				}else{
					queryClients = queryClients.replaceAll(USER_ID_TAG, userId);

				}
			}


			List<AggregateResult> listResult = capsulateQuery(queryClients);
			
			if(!listResult.isEmpty()){
				sgestdata.numClients = (Integer)listResult[0].get('expr0');
			}
		} 
		else if(devName.equals(AV_AppConstants.WARNINGS_MANAGE)){
			queryString = chartConfig.AV_Data__c;
			queryString = queryString.replaceAll(USER_ID_TAG, userSingestor[0].Id);	
			queryString += ' AND AV_Center__c = \''+center+'\''; 
		}
		
		if (!devName.equals(AV_AppConstants.WARNINGS_MANAGE) && queryString.containsIgnoreCase(USER_ID_TAG)) {
			queryString = queryString.replaceAll(USER_ID_TAG, userId);
		}
		
		sgestdata.numRecords = capsulateQueryCount(queryString);
		if (devName.equals(AV_AppConstants.WARNINGS_MANAGE)) {
			List<Report> rep = [Select Id from Report where DeveloperName = 'AV_AvisosAGestionarSinGestor_RT' WITH SECURITY_ENFORCED];
			if(!rep.isEmpty()){
				sgestdata.reportId = rep[0].Id;
			}
		}
	}

		return sgestdata;
	}
	
	/**
	 * @description Method to pass quality clouds
	 */
	private static List<AggregateResult> capsulateQuery(String avQuery) {
		return (List<AggregateResult>) Database.query(avQuery);
	}
	
	/**
	 * @description Method to pass quality clouds
	 */
	private static Integer capsulateQueryCount(String avQuery) {
		return Integer.valueOf(Database.countQuery(avQuery));
	}

}