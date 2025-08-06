/**********************************************************************************************************************
Name:      CIBE_NewEventControllerWO
Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente CIBE_NewEvent, cibe_NewEventReportDetail, cibe_newEventTab
------------------------------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------------------------------
    VERSION        USER_STORY       AUTHOR                  DATE                Description
    1.0                             Alvaro, Lucia                               Init version
    1.1             US774293        Bea, Ali                16/01/2024          Added vinculateTasksToTheNewEvent method
    1.2             US850789        Luis                    30/04/2024          Add updateOpportunityWO vinculate opportunities out of OTeamMember
***********************************************************************************************************************/

public without sharing class CIBE_NewEventControllerWO {
    /**
      * Insert the relations of updated and created opportunities to the created Event
      * @param caosToInsert Pre-made cao object that comes with the opportunity id and the AV_IsMain__c filled
      * @param evtId Created event to relate
      * @return String that is Ok or an error message wheter the insertions are succesful or not
      */
    @AuraEnabled
    // public static String vinculateOpposToTheNewEvent(List<AV_CustomActivityOpportunity__c> caosToInsert,Id evtId, String fechaProxGest, String closeDate){        public static String vinculateOpposToTheNewEvent(List<AV_CustomActivityOpportunity__c> caosToInsert,Id evtId, String fechaProxGest, String closeDate){
    public static String vinculateOpposToTheNewEvent(List<AV_CustomActivityOpportunity__c> caosToInsert,Id evtId){
        String methodName = 'vinculateOpposToTheNewEvent';
        String result = 'OK';
        Map<Id, Event> mapOlds = null;
        List<Event> evntList = [SELECT Id, AV_Task__c, RecordTypeId, ActivityDate, AccountId FROM Event WHERE Id =: evtId  LIMIT 1];
        if(!evntList.isEmpty()){
            for(AV_CustomActivityOpportunity__c cao :caosToInsert){
                cao.AV_Task__c = evntList[0]?.AV_Task__c;
                cao.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            }

            List<Database.SaveResult> srList = Database.insert(caosToInsert,false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < caosToInsert.size(); i++) {
                Database.SaveResult sr = srList[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    msjs.put(caosToInsert[i].Id + '_' + caosToInsert[i].Name, ((String)sr.getErrors()[0].getMessage()));
                    objs.add(caosToInsert[i]);
                    hasError = true;
                    result =  'NOK';
                }
            }
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }

        if(result == 'OK'){
            CIBE_EventTriggerHelper.updateNextMeetingDate(evntList, mapOlds, null);
        }

        return result;
    }

    @AuraEnabled
    public static String vinculateTasksToTheNewEvent(List<CIBE_RelaccionadoCita__c> rcToInsert){
        String methodName = 'vinculateTasksToTheNewEvent';
        String result = 'OK';
        List<Database.SaveResult> srList = Database.insert(rcToInsert,false);
        boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        for (Integer i = 0; i < rcToInsert.size(); i++) {
            Database.SaveResult sr = srList[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(rcToInsert[i].Id + '_' + rcToInsert[i].Name, ((String)sr.getErrors()[0].getMessage()));
                objs.add(rcToInsert[i]);
                hasError = true;
            }
        }
        if(hasError) {
            CBK_Log.error(msjs, objs);
        }
        return result;
    }

    @AuraEnabled
    public static void updateOpportunityWO(List<Opportunity> lstOpp){
        String methodName = 'updateOpportunityWO';

        if(!lstOpp.IsEmpty()){
            for(Opportunity opor: lstOpp){
                if(opor.stageName == CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO){
                    opor.stageName =  CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO;
                }
            }


            List<Database.SaveResult> srList = Database.update(lstOpp,false);
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < lstOpp.size(); i++) {
                Database.SaveResult sr = srList[i];
                if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                    msjs.put(lstOpp[i].Id + '_' + lstOpp[i].Name, ((String)sr.getErrors()[0].getMessage()));
                    objs.add(lstOpp[i]);
                    hasError = true;
                }
            }
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }
    }
}