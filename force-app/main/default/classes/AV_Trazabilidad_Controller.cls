/**********************************************************************************************************************
Name:	  AV_Trazabilidad_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente "av_Trazabilidad"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US384281                                            Patricia Solano     14/09/2022		Init version
	1.1         US457343                                            Patricia Solano     27/09/2022	    Modified the method retrieveCustomerTrackings
	1.2         US457343                                            Patricia Solano     25/10/2022	    Added method pageKeyIsNull, new class ResponseResult
																										and modified method retrieveCustomerTrackings
																										to add the description of step
	1.3         US481744                                            Patricia Solano     14/11/2022	    Modified the method retrieveCustomerTrackings to add the process url link
	1.4      	Fix PMD Errors 										Humberto Vilchez 	23/10/2023 		Add WITH SECURITY_ENFORCED to queries
***********************************************************************************************************************/
public with sharing class AV_Trazabilidad_Controller {

	public class Response {
        @AuraEnabled
        public String startPetitionDate;
        @AuraEnabled
        public String endDatePetition;
		@AuraEnabled
        public String closeDatePetition;
        @AuraEnabled
        public String process;
		@AuraEnabled
        public String processUrl;
        @AuraEnabled
        public String ambit;
        @AuraEnabled
        public String step;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String employee;
		@AuraEnabled
        public String manager;
    }

	public class ResponseResult {
		@AuraEnabled
        public String response;
		@AuraEnabled
        public String moreElements;
	}

	/**
	 * Method to start the number of pages if it is null
	 * @param pagekey                  -> Identifies the pagination of elements
     */
	public static String pageKeyIsNull(String pagekey){
		return String.valueOf(pagekey);
	}

	/**
	 * Method to make request to the Api
     * @param tableType                -> Identifies if the process is active 'A' or if it is part of the history 'H'
     * @param recordId                 -> Identifies client Id
	 * @param pagekey                  -> Identifies the pagination of elements
     */
	@AuraEnabled(cacheable=true)
	public static ResponseResult retrieveCustomerTrackings(String tableType, String recordId, String pagekey)  { 
		String methodName = 'retrieveCustomerTrackings';
		String response;
		String moreElements;
		String processUrl = system.label.AV_TrazabilidadUrl;

		if (pagekey == null) {
			pagekey = pageKeyIsNull('1');
		}
	
		if(recordId!= null) {
			Account account = [Select AV_NumPerso__c From Account Where Id =:recordId WITH SECURITY_ENFORCED limit 1];

			if (account != null){
				AV_Trazabilidad_Integration.CustomerResponse data = AV_Trazabilidad_Integration.getCustomerTrackings(tableType, Integer.valueOf(account.AV_NumPerso__c), pagekey);
				AV_Trazabilidad_Integration.CustomerTrackingBodyOutResponse customerData = data.data;
				moreElements = customerData.moreElements;	

				List<Response> customerDataList = new List<Response>();
				if (!customerData.petitionsList.isEmpty()){
					for (AV_Trazabilidad_Integration.PetitionCustomerData sd : customerData.petitionsList) {
						Response sb = new Response();
						sb.startPetitionDate = String.isNotBlank(sd.startPetitionDate)  ? sd.startPetitionDate : null;
						sb.endDatePetition = String.isNotBlank(sd.endDatePetition)  ? sd.endDatePetition : null;
						sb.closeDatePetition = String.isNotBlank(sd.endDatePetition)  ? sd.endDatePetition : null;
						sb.process = String.isNotBlank(sd.processDescriptionCas)  ? sd.processDescriptionCas : 'Proceso';
						sb.processUrl = String.isNotBlank(sd.petitionId)  ? processUrl.replace('{11111}', sd.petitionId) : null;
						sb.processUrl = String.isNotBlank(String.valueOf(sd.processId))  ? sb.processUrl.replace('{22222}', String.valueOf(sd.processId)) : null;
						sb.ambit = String.isNotBlank(sd.scopeDescriptionCas)  ? sd.scopeDescriptionCas : null;
						if (String.isNotBlank(String.valueOf(sd.stepNum))) {
							if (sd.stepList != null) {
								for (AV_Trazabilidad_Integration.StepData listOfSteps : sd.stepList) {
									if(listOfSteps.stepNumber == sd.stepNum && listOfSteps.stepDescriptionCas != null){
										sb.step = listOfSteps.stepDescriptionCas +' ('+sd.stepNum+')';
									} else if (sb.step == null) {
										sb.step = String.valueOf(sd.stepNum);
									}
								}
							} else {
								sb.step = String.valueOf(sd.stepNum);
							}
						}
						sb.state = String.isNotBlank(sd.statusDescriptionCas)  ? sd.statusDescriptionCas : null; 
						sb.employee = String.isNotBlank(sd.employeeId)  ? sd.employeeId : null;
						sb.manager = String.isNotBlank(sd.employeeId)  ? sd.employeeId : null;
						customerDataList.add(sb);
					}
					response = JSON.serialize(customerDataList);
				} 
			}
		}
		ResponseResult result = new ResponseResult();
		result.response = response;
		result.moreElements = moreElements;
		return result;
	}
}