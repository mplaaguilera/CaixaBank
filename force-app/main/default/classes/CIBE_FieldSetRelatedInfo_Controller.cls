/**********************************************************************************************************************
Name:	  CIBE_FieldSetRelatedInfo_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC CIBE_FieldSetRelatedInfo
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR			    DATE			Description
1.0			Init    		Borja Lavesiera 	23/10/2023	    Init version.
***********************************************************************************************************************/
public with sharing class CIBE_FieldSetRelatedInfo_Controller {


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
			system.debug('$$GetfieldPath' +f.getFieldPath());
            result.add(field);
			
        }
		
		return result;
    }
    @AuraEnabled(cacheable=true)
	public static List<Field> getPhoneField(Id recordId, String fieldSetName, String phoneFieldInput) {
		String filterObject = recordId.getSObjectType().getDescribe().getName();
        List<Schema.FieldSetMember> fieldSet = Schema.getGlobalDescribe()
													.get(filterObject)
													.getDescribe()
													.fieldSets
													.getMap()
													.get(fieldSetName)
													.getFields();
		List<Field> result = new List<Field>();
		for (Schema.FieldSetMember fsm : fieldSet) {
            if (fsm.getFieldPath() == phoneFieldInput) {
                Field field = new Field();
                field.name = phoneFieldInput;
                field.label = fsm.getLabel();
                result.add(field);
                break;
            }
        }

		return result;
	}
	@AuraEnabled(cacheable=true)
	public static Object getFieldValue(String objectApiName, String fieldSetName, String fieldName, Id recordId) {
        List<Schema.FieldSetMember> fieldSetMembers = Schema.SObjectType.Account.fieldSets.getMap().get(fieldSetName).getFields();
        String dynamicQuery = 'SELECT ';
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            dynamicQuery += fsm.getFieldPath() + ', ';
        }
        dynamicQuery += 'Id FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';

        SObject record;
        try {
            record = Database.query(String.escapeSingleQuotes(dynamicQuery));
        } catch (Exception e) {
            return null;
        }
        Object fieldValue = record.get(fieldName);
		String stringValue = (String)fieldValue;
        return stringValue;
    }
	public class Field {
		@AuraEnabled public String name;
		@AuraEnabled public String label;
	}
}