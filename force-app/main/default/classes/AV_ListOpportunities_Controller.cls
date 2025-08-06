/**********************************************************************************************************************
Name:	  AV_ListOpportunities_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "av_ListOpportunities"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                              AUTHOR           	DATE			Description
    1.0			Oportunidades vinculadas con las tareas Esperanza Conde  	07/10/2020		Init version
    1.0			Oportunidades vinculadas con las tareas Álvaro López     	07/10/2020		Fix errors
    1.1         FIX IOP Enero                           Álvaro López     	20/01/2021		Order by AV_FechaProximoRecordatorio__c ASC only
	1.2         FIX Bug empty values in "not in"        David Rufo       	20/10/2021		Fix method "retrieveListWithOutTask", remove "En espera" status
    1.3		    Hotfix 22/03                            Daniel Rodríguez 	21/03/2022	    Change AV_Query 
    1.4			Fix				                        Sandra Gómez	 	22/03/2022		Add AV_AppUtilities.setToStringIn
    1.5			US  			                        Víctor Santiago  	13/06/2022      Added attrbs to RecordInfo
	1.6			US504147								Vladislav Lityagin	11/01/2023		Added RecordTypes filter in retrieveListOpp and retrieveListWithOutTask
    1.7			US481572		                        Patricia Solano 	25/01/2023		Modified method retrieveListWithOutTask
    1.8         Fix PMD Errors 		                    Humberto Vilchez    23/10/2023      Add WITH SECURITY_ENFORCED to queries
    1.9         Cambiar lógica para mostrar las opp     Ángel Medina        22/01/2024      Modified method retrieveListOpp
    2.0         PPM100205279                            Luis Fernández      14/05/2024      Added new fields to retrieve in opportuntiees. AV_NoOfrecerHasta__c and AV_PF__r.AV_NewReportsActions__c
***********************************************************************************************************************/
public with sharing class AV_ListOpportunities_Controller {

    /**
     * Retrieve the list opp's related with the task or event
     */
    @AuraEnabled
    public static List<OppTaskResponse> retrieveListOpp(String recordInfoJson){
        RecordInfo recordInfo = (RecordInfo)JSON.deserialize(recordInfoJson, RecordInfo.class);
        
        //Obtengo el registro Tarea-Oportunidad asociado
        List<AV_CustomActivityOpportunity__c> listTareaOpp;
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,Boolean> mapMain = new Map<Id, Boolean>();

       
        if(recordInfo != null && String.isNotBlank(recordInfo.taskHeader)) {
            listTareaOpp = [SELECT AV_IsMain__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :recordInfo.taskHeader AND RecordType.DeveloperName =:AV_AppConstants.TAREA_OPOR_RT WITH SECURITY_ENFORCED ORDER BY AV_IsMain__c DESC];
            for(AV_CustomActivityOpportunity__c tareaOpp : listTareaOpp){
                opportunityIds.add(tareaOpp.AV_Opportunity__c);
                mapMain.put(tareaOpp.AV_Opportunity__c, tareaOpp.AV_IsMain__c);
            }
        }
       
        List<OppTaskResponse> listOppTaskRes = new List<OppTaskResponse>();
        if(opportunityIds != null && !opportunityIds.isEmpty()){
            List<Opportunity> listOpp = [SELECT Id, AV_PEA__c, AV_PF__c, AV_LicensePlate__c, Name, AV_Product__c, AV_ProductName__c, AV_Gestor__c,AV_Gestor__r.Name, RecordTypeId,RecordType.Name, AV_Potencial__c, StageName , AV_Valor1__c, 
            AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Entidad__c , Amount,
            AV_TipoInteres__c, AV_Comentarios__c, AV_Tenencia__c,AV_IncludeInPrioritizingCustomers__c,AV_FechaActivacion__c,AV_Resolucion__c, AV_ByProduct__c, AV_MarginEuro__c, AV_AmountEuro__c,AV_FechaVencimiento__c,
            CloseDate, AV_Cuota__c, AV_FechaProximoRecordatorio__c,RecordType.DeveloperName,AV_PF__r.AV_NewReportActions__c,AV_NoOfrecerHasta__c
            FROM Opportunity WHERE Id IN :opportunityIds WITH SECURITY_ENFORCED];
           
            for(Opportunity opp : listOpp){
                OppTaskResponse oppTaskRes = new OppTaskResponse();
                oppTaskRes.opp = opp;
                oppTaskRes.isMain = mapMain.get(opp.Id);
                if(oppTaskRes.isMain && listOppTaskRes.size() > 0){
                    listOppTaskRes.add(0,oppTaskRes); 
                }else{
                    listOppTaskRes.add(oppTaskRes); 
                }
            }
        }
       return listOppTaskRes;
    }



    /**
     * Retrieve the list of the opp's no related with task or event but is related with the customer
     */
    @AuraEnabled
    public static List<OppResponse> retrieveListWithOutTask(String recordInfoJson){
		String methodName = 'retrieveListWithOutTask';
        List<Opportunity> listOpp;
        Set<String> setStatusOpen = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION};
        RecordInfo recordInfo = (RecordInfo)JSON.deserialize(recordInfoJson, RecordInfo.class);
        List<String> listStatusOpen = AV_AppUtilities.getListFromSet(setStatusOpen);
        List<AV_CustomActivityOpportunity__c> listTareaOpp = new List<AV_CustomActivityOpportunity__c>();
        //Obtengo la lista Tarea-Oportunidad asociado para conseguir las opp vinculadas
        if(recordInfo != null) {
            Set<String> setOpp = new Set<String>();
            String listOppId = '';
            if (recordInfo.taskHeader != null) {
                listTareaOpp = [SELECT AV_Opportunity__c From AV_CustomActivityOpportunity__c WHERE AV_Task__c = :recordInfo.taskHeader WITH SECURITY_ENFORCED];
            } else {
                CBK_Log.debug(methodName, 'La tarea '+recordInfo.activityId+' no tiene cabecera-tarea informada el día '+System.now());
            }
            
            if(!listTareaOpp.isEmpty()){
                for(AV_CustomActivityOpportunity__c tareaOpp : listTareaOpp){
                    setOpp.add(tareaOpp.AV_Opportunity__c);
                } 

            }

            if(setOpp != null && !setOpp.isEmpty()) {
                listOppId = AV_AppUtilities.setToStringIn(setOpp); 
            }                   
            //Get the opp's no related
            if(recordInfo.accountId != null){
                String queryAll = '';
                String queryWhere = '';
                String queryOpp = '';
                Set<String> setRTs = new Set<String>{AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPPROPUESTA_RT,AV_AppConstants.OPPSUGERENCIA_RT,AV_AppConstants.OPPLLAMADA_RT};
                List<String> listRTs = AV_AppUtilities.getListFromSet(setRTs);
                queryOpp = 'SELECT Id, Name, AV_PF__c, AV_PF__r.Name, AV_Gestor__c, AV_Gestor__r.Name, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c,'+
                'AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c,AV_IncludeInPrioritizingCustomers__c,'+
                'AV_FechaActivacion__c, AV_MarginEuro__c, AV_AmountEuro__c, AV_ByProduct__c,AV_PF__r.AV_NewReportActions__c,AV_NoOfrecerHasta__c FROM Opportunity ';
                queryWhere = ' WHERE AccountId = \''+ recordInfo.accountId +'\' AND StageName in '+ listStatusOpen +' AND RecordType.DeveloperName IN '+listRTs;                         
                
                if (setOpp!=null && !setOpp.isEmpty()){
                    queryWhere = queryWhere + 'AND Id NOT IN '+ listOppId;
                }
                queryAll = queryOpp + queryWhere + ' ORDER BY AV_FechaProximoRecordatorio__c ASC';
                AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + queryAll);
		        listOpp = database.query(queryAll);
            }
        }                                  
        if(listOpp != null && !listOpp.isEmpty()){
            List<OppResponse> listOppRes = new List<OppResponse>();
            for(Opportunity opp : listOpp) {
                OppResponse oppRes = new OppResponse();
                oppRes.opp = opp;
                listOppRes.add(oppRes);
            }
            return listOppRes;
        } else {
            return null;
        }
    }

    /**
     * Get the picklist values for the field "StageName" from custom metadata
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getStatusValues(String objectName, String fieldName) {
        AV_PicklistListValuesByRecordType__mdt picklistValues = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_ListSalesProcess__c, AV_ObjectLabel__c, AV_RecordTypeLabel__c 
        From AV_PicklistListValuesByRecordType__mdt where AV_RecordTypeLabel__c = 'Component' and AV_ObjectLabel__c = :objectName WITH SECURITY_ENFORCED limit 1];
		
		List<String> pickValues = new List<String>();
		pickValues = picklistValues.AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		// loop to Schema picklist 
        for(String val:pickValues){
			for(Schema.PicklistEntry pickListVal : ple){
				if (val == String.valueOf(pickListVal.getValue())) {
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 
                        									 'value' => String.valueOf(pickListVal.getValue())});
				}
			}
        }
        return listPicklist;
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordInfo(String recordId, String objectName) {
        RecordInfo recordInfo;
        switch on objectName {
            when 'Task' {
                Task tsk = [Select Id, AV_Task__c, AccountId, ActivityDate, Status From Task where Id = :recordId WITH SECURITY_ENFORCED limit 1];
                recordInfo = new RecordInfo();
                recordInfo.taskHeader = tsk.AV_Task__c;
                recordInfo.accountId = tsk.AccountId;
                recordInfo.activityId = tsk.Id;
                recordInfo.activityDate = tsk.ActivityDate;
                recordInfo.status = tsk.Status;
            }
            when 'Event' {
                Event evt = [Select Id, AV_Task__c, AccountId From Event Where Id = :recordId WITH SECURITY_ENFORCED limit 1];
                recordInfo = new RecordInfo();
                recordInfo.taskHeader = evt.AV_Task__c;
                recordInfo.accountId = evt.AccountId;
                recordInfo.activityId = evt.Id;
            }
        }
        if(recordInfo != null) {
            return JSON.serialize(recordInfo);
        } else {
            return null;
        }
    }

    public class RecordInfo {
        @AuraEnabled
        public String taskHeader;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String activityId;
        @AuraEnabled
        public Date activityDate;
        @AuraEnabled
        public String status;
    }

    public class OppResponse {
        @AuraEnabled
        public Opportunity opp;
    }

    public class OppTaskResponse {
        @AuraEnabled
        public Opportunity opp;
        @AuraEnabled
        public Boolean isMain;
    }


}