/**********************************************************************************************************************
Name:	  AV_DetailOppTask_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "av_DetailOppTask"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY										AUTHOR			    DATE			Description
    1.0			Oportunidades vinculadas con las tareas			Álvaro López        09/10/2020		Init version
    1.1			Oportunidades vinculadas a un evento			Álvaro López        11/11/2020		Error management and deleteOpp method
    1.2			Oportunidades vinculadas a un evento			Álvaro López        18/11/2020		Remove deleteOpp method
    1.3			Palabras prohibidas								Álvaro López        26/11/2020		Added validateForbWords method
	1.4			Unlink error									David Rufo			20/09/2021		Change owner before unlink task-opp
***********************************************************************************************************************/
public with sharing class AV_DetailOppTask_Controller {

	/**
	* Method that update the opp-task main check
	*
	* @param oppTask AV_CustomActivityOpportunity__c record to update
	* @return void
	*/
	@AuraEnabled
	public static void updateMainRecord(AV_CustomActivityOpportunity__c oppTask) {
		Set<String> setOppTaskFields = new Set<String>{'Id', 'AV_IsMain__c'};
		List<AV_CustomActivityOpportunity__c> listOppTask  = [Select Id, AV_IsMain__c from AV_CustomActivityOpportunity__c where (Id = :oppTask.Id or AV_IsMain__c = true) and AV_Task__c = :oppTask.AV_Task__c];
		/*List<AV_CustomActivityOpportunity__c> listOppTask = new AV_Query('AV_CustomActivityOpportunity__c')
										.selectFields(setOppTaskFields)
										.addCondition(
											AV_Query.doOr(
												AV_Query.conditionEq('Id', oppTask.Id),
												AV_Query.conditionEq('AV_IsMain__c', true)
											)
										)
										.addConditionEq('AV_Task__c', oppTask.AV_Task__c)
										.run();*/
		List<AV_CustomActivityOpportunity__c> listToUpd = new List<AV_CustomActivityOpportunity__c>();                                 
		for(AV_CustomActivityOpportunity__c optyTask : listOppTask) {
			if(optyTask.Id == oppTask.Id) {
				optyTask.AV_IsMain__c = true;
			} else if(optyTask.AV_IsMain__c == true) {
				optyTask.AV_IsMain__c = false;
			}
			listToUpd.add(optyTask);
		}
		Database.update(listToUpd, false);
	}

	/**
	* Method that delete the opp-task record when user unlink the oppoportunity from task
	*
	* @param AV_CustomActivityOpportunity__c record to delete
	* @return void
	*/
	@AuraEnabled
	public static void unlinkOpp(AV_CustomActivityOpportunity__c oppTask) {
        String methodName = 'unlinkOpp';
        
        //Change the owner
        User user = AV_AppUtilities.getUserInfo();
        AV_CustomActivityOpportunity__c oppTask2 = new AV_CustomActivityOpportunity__c(Id=oppTask.Id, OwnerId=user.Id);
        Database.update(oppTask2, false); AV_LogDebug.printLogDebug(methodName, 'oppTask: ' + oppTask2);
		
        //Delete data
        Database.DeleteResult deleteResult = Database.delete(oppTask2, false);
        List<Database.DeleteResult> listDeleteResult = new List<Database.DeleteResult>();
        listDeleteResult.add(deleteResult); AV_AppUtilities.displayErrors(methodName, listDeleteResult);
	}

	/**
	* Method that validates the forbidden words introduced in the opptask form (Entity and Commentary fields)
	*
	* @param listValues List of string values to validate
	* @return String message
	*/
	@AuraEnabled
	public static String validateForbWords(List<String> listValues) {
		try{
			Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = AV_ForbiddenWords.fetchForbiddenWords();
			String result = '';
			List<CBK_ForbiddenWord__c> listFW = new List<CBK_ForbiddenWord__c>();
			for(String val : listValues) {
				result += val != null ? (AV_ForbiddenWords.transformWords(val) + ' ') : '';
			}
			
			if(String.isNotBlank(result) && mapForbiddenWords != null && !mapForbiddenWords.values().isEmpty()){
				listFW = AV_ForbiddenWords.validateExpr(result, mapForbiddenWords);
			}
			if(!listFW.isEmpty()) {
				String forbiddenWords = '';
				String warningMessage = Label.AV_ForbiddenWordsMessage1 + ' ';
				//Loop for building message
				for(Integer i=0; i<listFW.size(); i++) {
					if(String.isNotBlank(listFW[i].CBK_TIPAVI__c)) {
						if(listFW[i].CBK_TIPAVI__c.equalsIgnoreCase('E')) {
							if(i < listFW.size()-1) {
								forbiddenWords += listFW[i].CBK_EXPRES__c + ', ';
							} else {
								forbiddenWords += listFW[i].CBK_EXPRES__c;
							}
						} else if(listFW[i].CBK_TIPAVI__c.equalsIgnoreCase('A')) {
							if(i < listFW.size()-1) {
								warningMessage += listFW[i].CBK_EXPRES__c + ', ';
							} else {
								warningMessage += listFW[i].CBK_EXPRES__c + Label.AV_ForbiddenWordsMessage2;
							}
						}
					}
				}
				FBMessage fbm = new FBMessage();
				if(String.isNotBlank(forbiddenWords)) {
					fbm.type = 'E';
					fbm.message = Label.AV_ForbiddenWordsErrorMessage + ' ' + forbiddenWords;
				} else if(String.isBlank(forbiddenWords) && String.isNotBlank(warningMessage)) {
					fbm.type = 'A';
					fbm.message = warningMessage;
				}
				return JSON.serialize(fbm);
			}
		} catch(Exception exc) {
			return 'KO';
		}
		return 'OK';
	}

	public class FBMessage {
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String message;
	}
}