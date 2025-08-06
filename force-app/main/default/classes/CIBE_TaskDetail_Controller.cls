/**********************************************************************************************************************
Name:	  CIBE_TaskDetail_Controller
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Obtiene los labels de la picklist prioridad del activity extension
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	  AUTHOR		   	DATE				Description
1.0			App FSC 	  Alex Campos  	    26/10/2022		  	Init version
***********************************************************************************************************************/
public with sharing class CIBE_TaskDetail_Controller {
    
    public static final String OBJECT_TASK = 'Task';
    public static final String FIELDNAME = 'Priority';
    
    @AuraEnabled(cacheable=true)
    public static String getValueLabel(String priority){
        Map<String,String> apiLabelValueMap = new Map<String,String>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(OBJECT_TASK) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(FIELDNAME).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            apiLabelValueMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }  

        return apiLabelValueMap.get(priority);
    }
}