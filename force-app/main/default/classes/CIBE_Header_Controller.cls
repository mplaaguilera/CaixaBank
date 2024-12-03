/**********************************************************************************************************************
Name:	  CIBE_Header_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC CIBE_Header_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR			DATE			Description
1.0			Init    		Alex Campos 	14/06/2022		Init version.
1.1			US463709		Alex Campos		31/10/2022		Se adapta la parte superior del header para que sea configurable.
2.0			US425471		Jose Maria 		21/11/2022		getDateLoad
2.1			US				Luis Martínez	30/06/2023		modificacion getDateLoad recupere dinamicamente los datos.
***********************************************************************************************************************/
public with sharing class CIBE_Header_Controller {

	@AuraEnabled(cacheable=true)
	public static String getName(Id recordId, String fieldName) {
		String filterObject = recordId.getSObjectType().getDescribe().getName();

		List<sObject> results = Database.query('SELECT ' + String.escapeSingleQuotes(fieldName) + ' FROM ' + String.escapeSingleQuotes(filterObject) + ' WHERE Id = :recordId');
		if(!results.isEmpty()) {
			return String.valueOf(results.get(0).get(fieldName));
		}
        return '';
    }

	@AuraEnabled(cacheable=true)
	public static List<Action> getActions(String actionSetting) {
		List<CIBE_FlowActions__mdt> actions = [SELECT Id, Label, CIBE_FlowName__c, CIBE_Output__c, CIBE_Order__c FROM CIBE_FlowActions__mdt WHERE CIBE_Setting__c = :actionSetting ORDER BY CIBE_Order__c ASC];

		if(actions.isEmpty()) {
			throw new IllegalArgumentException('getActions - No se ha encontrado ninguna flow action con ese setting.');
		}

		List<String> translationNames = new List<String>();
		for(CIBE_FlowActions__mdt action : actions) {
			translationNames.add(action.label);
		}

		Map<String, String> translations = CIBE_TranslationUtilities.getInstance()
			.addTranslationNames(translationNames)
			.queryTranslations()
			.getTranslations();

		List<Action> result = new List<Action>();
		for(CIBE_FlowActions__mdt action : actions) {
			Action a = new Action();
			a.id = action.Id;
			a.name = action.CIBE_FlowName__c;
			a.output = action.CIBE_Output__c;
			a.label = String.isNotBlank(translations.get(action.Label)) ? translations.get(action.Label) : action.Label;			
			result.add(a);
		}

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Field> getFields(Id recordId, String fieldSetName) {
		String filterObject = recordId.getSObjectType().getDescribe().getName();
        List<Schema.FieldSetMember> fieldSet = Schema.getGlobalDescribe()
													.get(filterObject)
													.getDescribe()
													.fieldSets
													.getMap()
													.get(fieldSetName)
													.getFields();

		List<Field> result = new List<Field>();
		for(Schema.FieldSetMember f: fieldSet){
			Field field = new Field();
			field.name = f.getFieldPath();
            result.add(field);
        }
		return result;
    }

	public class Field {
		@AuraEnabled public String name;
	}

	public class Action {
		@AuraEnabled public String id;
		@AuraEnabled public String label;
		@AuraEnabled public String name;
		@AuraEnabled public String output;
	}

	
	@AuraEnabled(cacheable=true)
	public static String getDateLoad(Id recordId, String filterObject, String helpField) {
		Account acc;
		List<sObject> sobj;
		String query = 'SELECT ID, '+ String.escapeSingleQuotes(helpField)+' FROM '+String.escapeSingleQuotes(filterObject)+' WHERE ID =:recordId';
		if(
			Schema.Account.SObjectType.getDescribe().isAccessible() &&
			Schema.SObjectType.Account.fields.CIBE_FechaRating_SP__c.isAccessible() 
		) {
			sobj = Database.query(query);
		}
		
		if(filterObject.equalsIgnoreCase(CIBE_AppConstants.OBJECT_NAME_ACCOUNT) && !sobj.isEmpty()){
			acc = (Account) sobj[0];
		}

		if(helpField.equalsIgnoreCase('CIBE_FechaRating_SP__c')&& acc!=null && acc.CIBE_FechaRating_SP__c!=null){
			Integer year = acc.CIBE_FechaRating_SP__c.year();
			Integer month = acc.CIBE_FechaRating_SP__c.month();
			Integer dia = acc.CIBE_FechaRating_SP__c.day();
			return ' '+ String.valueOf(dia)+' / '+ String.valueOf(month) + ' / ' + String.valueOf(year);
		}
		return null;		
    }

}