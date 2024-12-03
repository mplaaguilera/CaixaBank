/**********************************************************************************************************************
Name:	  CIBE_MetricChart_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente "cibe_MetricChart"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
	1.0         US486064             	Ali y Bea         	01/09/2023      Init version

***********************************************************************************************************************/
public with sharing class CIBE_MetricChart_Controller {

    private static final String USER_ID_TAG = '#userId';
	public static final String PERMISSION_SET_NAME = 'CIBE_ShowHomeV4';


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
			// Parte CIB
			// if(
			// 	metadataChart == CIBE_AppConstants.CIBE_TAREAS_PROXIMOS_7DIAS_CIB
			// || metadataChart == CIBE_AppConstants.CIBE_AVISOS_CIB
			// || metadataChart == CIBE_AppConstants.CIBE_CLIENTES_GESTIONAR_PRIORIZADOS_CIB
			// || metadataChart == CIBE_AppConstants.CIBE_EVENTOS_HOY
			// ){

			// 	List<AggregateResult> sobjectList = Database.query(queryString);
				
			// 	if(metadataChart == CIBE_AppConstants.CIBE_CLIENTES_GESTIONAR_PRIORIZADOS_CIB){

			// 		//Clientes priorizados

			// 		Integer numRtPriorizadosCIB = 0;
			// 		Integer numRtExpClienteCIB = 0;
			// 		Integer numRtIniciativaCIB = 0;
			// 		Integer numRtAlertaCIB = 0;
			// 		Integer numRtOnboardingCIB = 0;
			// 		for(AggregateResult taskObject : sobjectList){

			// 			if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT){
			// 				numRtPriorizadosCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT){
			// 				numRtExpClienteCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_OTROS_CIB_RT){
			// 				numRtIniciativaCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);					
			// 			}if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT){
			// 				numRtAlertaCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_ONBOARDING_CIB_RT){
			// 				numRtOnboardingCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}
			// 		}
					
			// 		List<Integer> numList = new List<Integer>{numRtPriorizadosCIB, numRtExpClienteCIB, numRtIniciativaCIB, numRtAlertaCIB, numRtOnboardingCIB};
			// 		chart.numRecordsList = numList;
			// 		chart.numRecords = (numRtPriorizadosCIB + numRtExpClienteCIB + numRtIniciativaCIB + numRtAlertaCIB  +  numRtOnboardingCIB );
			// 	}
			// 	else if(metadataChart == CIBE_AppConstants.CIBE_TAREAS_PROXIMOS_7DIAS_CIB){
			// 		//Tareas proximos 7 días

			// 		Integer numRtIniciativaCIB = 0;
			// 		for(AggregateResult taskObject : sobjectList){
						
			// 			if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_OTROS_CIB_RT){
			// 				numRtIniciativaCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);					
			// 			}
			// 		}
					
			// 		List<Integer> numList = new List<Integer>{numRtIniciativaCIB};
			// 		chart.numRecordsList = numList;
			// 		chart.numRecords = (numRtIniciativaCIB);

			// 	}
			// 	// Avisos de hoy
			// 	else if(metadataChart == CIBE_AppConstants.CIBE_AVISOS_CIB){

			// 		Integer avisosCIB = 0;
			// 		for(AggregateResult taskObject : sobjectList){
			// 			if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_AVISOS_CIB_RT){
			// 				avisosCIB = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}
			// 		}
					
			// 		List<Integer> numList = new List<Integer>{avisosCIB};
			// 		chart.numRecordsList = numList;
			// 		chart.numRecords = (avisosCIB);
					
			// 	}else if(metadataChart == CIBE_AppConstants.CIBE_EVENTOS_HOY ){

			// 		Integer numEventosHoyCliente = 0;
			// 		Integer numEventosHoyGestor = 0;
			// 		for(AggregateResult activityObject : sobjectList){
			// 			if(activityObject.get('AV_InOutbound__c') == '001'){
			// 				numEventosHoyCliente = (Integer) activityObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}if(activityObject.get('AV_InOutbound__c') == '002'){
			// 				numEventosHoyGestor = (Integer) activityObject.get(CIBE_AppConstants.COUNT_RESULTS);
			// 			}
			// 		}
			// 		List<Integer> numList = new List<Integer>{numEventosHoyCliente,numEventosHoyGestor};
			// 		chart.numRecordsList = numList;
			// 		chart.numRecords = (numEventosHoyCliente+numEventosHoyGestor);

			// 	}
			// } 
			// Parte EMP añadir en la linea de abajo "else if" cuando se agregue la parte de CIB
			if(
				metadataChart == CIBE_AppConstants.CIBE_TAREAS_PROXIMOS_7DIAS_EMP
			|| metadataChart == CIBE_AppConstants.CIBE_AVISOS_EMP
			|| metadataChart == CIBE_AppConstants.CIBE_CLIENTES_GESTIONAR_PRIORIZADOS_EMP
			|| metadataChart == CIBE_AppConstants.CIBE_EVENTOS_HOY
			|| metadataChart == CIBE_AppConstants.CIBE_NOTIFICACIONES
			){
				List<AggregateResult> sobjectList = Database.query(queryString);
		
				if(metadataChart == CIBE_AppConstants.CIBE_CLIENTES_GESTIONAR_PRIORIZADOS_EMP){
					

					//Clientes priorizados
					Integer numRtAlertaEMP = 0;
					// Integer numRtIniciativaEMP = 0;
					Integer numRtPriorizadosEMP = 0;
					Integer numRtOnboardingEMP = 0;
					Integer numRtExpClienteEMP = 0;
					for(AggregateResult taskObject : sobjectList){

						if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT){
							numRtPriorizadosEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT){
							numRtExpClienteEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);					
						}
						// if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_OTROS_EMP_RT){
						// 	numRtIniciativaEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
						// }
						if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT){
							numRtAlertaEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_ONBOARDING_EMP_RT){
							numRtOnboardingEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}
					}
					
					List<Integer> numList = new List<Integer>{ numRtPriorizadosEMP, numRtExpClienteEMP, numRtAlertaEMP, numRtOnboardingEMP};
					chart.numRecordsList = numList;
					chart.numRecords = (numRtPriorizadosEMP + numRtExpClienteEMP + numRtAlertaEMP +   numRtOnboardingEMP );
				}
				else if(metadataChart == CIBE_AppConstants.CIBE_TAREAS_PROXIMOS_7DIAS_EMP){
					
					//Tareas proximos 7 días
					Integer numRtIniciativaEMP = 0;
					
					for(AggregateResult taskObject : sobjectList){

						if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_OTROS_EMP_RT){
							numRtIniciativaEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);					
						}
					}
					
					List<Integer> numList = new List<Integer>{numRtIniciativaEMP};
					chart.numRecordsList = numList;
					chart.numRecords = (numRtIniciativaEMP);

				}
				// Avisos de hoy
				else if(metadataChart == CIBE_AppConstants.CIBE_AVISOS_EMP){

					Integer avisosEMP = 0;
					for(AggregateResult taskObject : sobjectList){
						if(taskObject.get('DeveloperName') == CIBE_AppConstants.TASK_AVISOS_EMP_RT){
							avisosEMP = (Integer) taskObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}
					}
					
					List<Integer> numList = new List<Integer>{avisosEMP};
					chart.numRecordsList = numList;
					chart.numRecords = (avisosEMP);
					
				}else if(metadataChart == CIBE_AppConstants.CIBE_EVENTOS_HOY ){

					Integer numEventosHoyCliente = 0;
					Integer numEventosHoyGestor = 0;
					for(AggregateResult activityObject : sobjectList){
						if(activityObject.get('AV_InOutbound__c') == '001'){
							numEventosHoyCliente = (Integer) activityObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}if(activityObject.get('AV_InOutbound__c') == '002'){
							numEventosHoyGestor = (Integer) activityObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}
					}
					List<Integer> numList = new List<Integer>{numEventosHoyCliente,numEventosHoyGestor};
					chart.numRecordsList = numList;
					chart.numRecords = (numEventosHoyCliente+numEventosHoyGestor);

				}
				else if(metadataChart == CIBE_AppConstants.CIBE_NOTIFICACIONES ){

					Integer numLlamadas = 0;
					Integer numMuro = 0;
					Integer numStopGo = 0;
					Integer numOpPendienteFirma = 0;
					for(AggregateResult notifymeObject : sobjectList){
						if(notifymeObject.get('AV_OrigenAct__c') == CIBE_AppConstants.ORIGEN_ACT_LLAMADAS){
							numLlamadas = (Integer) notifymeObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}else if(notifymeObject.get('AV_OrigenAct__c') == CIBE_AppConstants.ORIGEN_ACT_MURO){
							numMuro = (Integer) notifymeObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}else if(notifymeObject.get('AV_OrigenAct__c') == CIBE_AppConstants.ORIGEN_ACT_STOPGO){
							numStopGo = (Integer) notifymeObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}else if(notifymeObject.get('AV_OrigenAct__c') == CIBE_AppConstants.ORIGEN_ACT_OP_PENDIENTE_FIRMA){
							numOpPendienteFirma = (Integer) notifymeObject.get(CIBE_AppConstants.COUNT_RESULTS);
						}
					}
					List<Integer> numList = new List<Integer>{numLlamadas, numMuro, numStopGo, numOpPendienteFirma};
					chart.numRecordsList = numList;		
					chart.numRecords = (numLlamadas + numMuro + numStopGo + numOpPendienteFirma);
				}
			}
			else{
				chart.numRecords = Database.countQuery(queryString);
			}

			List<String> translationNames = new List<String>{chartConfig.Label};
			Map<String, String> translations = CIBE_TranslationUtilities.getInstance()
				.addTranslationNames(translationNames)
				.queryTranslations()
				.getTranslations();

			chart.title = String.isNotBlank(translations.get(chartConfig.Label)) ? translations.get(chartConfig.Label) : chartConfig.Label;
			List<Report> rep = [SELECT Id FROM Report WHERE DeveloperName = :chartConfig.AV_ReportName__c];
			if(rep.size() > 0)chart.reportId = rep != null ? rep[0].Id : null;
			chart.hasLinkPermission = (FeatureManagement.checkPermission(CIBE_AppConstants.EXTENDEDHOME_LINK) && chartConfig.AV_Redirect__c);
			return chart;
		}
		return null;
    }

	@AuraEnabled(cacheable=true)
	public static Boolean userHasPermissionSet() {
		String userId = UserInfo.getUserId();

		List<PermissionSetAssignment> permissionSetAssignments = [
			SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Name 
			FROM PermissionSetAssignment 
			WHERE AssigneeId = :userId AND PermissionSet.Name = :PERMISSION_SET_NAME
		];

		if (!permissionSetAssignments.isEmpty()) {
		   // El usuario tiene asignado el Permission Set
			return true;
		} else {
		   // El usuario no tiene asignado el Permission Set
			return false;
	}
		}
	

}