/**********************************************************************************************************************
Name:	  AV_TaskDetailValue_Controller
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Bloque tarea para el flow de Nueva tarea si hay que vincular opp
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	  AUTHOR		   	DATE				Description
1.0			App FSC 	  Esperanza Conde  	23/12/2020		  	Init version
***********************************************************************************************************************/
public with sharing class AV_TaskDetailValue_Controller {
    
    public static final String OBJECT_TASK = 'Task';
    public static final String FIELDNAME = 'Priority';
    
    @AuraEnabled
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