/**********************************************************************************************************************
Name:     CIBE_DetailExpCliente_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for LWC cibe_DetailExpCliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE            Description
1.0         US738544            Borja Lavesiera     02/01/2024      Init version

***********************************************************************************************************************/
public with sharing class CIBE_DetailExpCliente_Controller {

    public class SurveyBundle {
        @AuraEnabled
        public String momento;
        @AuraEnabled
        public String momentoDate;
        @AuraEnabled
        public String valoracion;
        @AuraEnabled
        public Integer center;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String managementDate;
        @AuraEnabled
        public String secondSurvey;
        @AuraEnabled
        public String taskId;
        @AuraEnabled
        public Integer surveyValue;
        @AuraEnabled
        public Id recordId;
    }
    
    @AuraEnabled
    public static String retrieveData(String numPerso, Id recordId) {
        String response;
        if (String.isBlank(numPerso)) {
            return null;
        }
        CIBE_CustomersSurveys_Integration.SurveyResponse data = CIBE_CustomersSurveys_Integration.getSurveyData(numPerso);
        if (data == null || data.statusCode != 200) {
            return null;
        }
        CIBE_CustomersSurveys_Integration.SurveyListData surveysData = data.data;
        if (!surveysData.Surveys.isEmpty()) {
            List<SurveyBundle> surveyDataList = new List<SurveyBundle>();
            for (CIBE_CustomersSurveys_Integration.SurveyData sd : surveysData.Surveys) {
                SurveyBundle sb = new SurveyBundle();
                String taskId = '';             
                sb.momento = String.isNotBlank(sd.description) ? sd.description : null;
                sb.momentoDate = String.isNotBlank(sd.invitationDate) ? sd.invitationDate : null;
                sb.valoracion = String.isNotBlank(sd.rating) ? sd.rating : null;
                sb.center = sd.branchCheckinId != null ? sd.branchCheckinId : null;
                sb.managementDate = String.isNotBlank(sd.procedureDate) ? sd.procedureDate : null;
                sb.secondSurvey = String.isNotBlank(sd.secondRating) ? sd.secondRating : null;
                sb.surveyValue = sd.surveyId != null ? sd.surveyId : null;
                Map<String, String> taskInfo = findTaskIdAndStatusBySurveyValue(sb.surveyValue, recordId);
                sb.taskId = taskInfo.get('Id');
                // sb.status = taskInfo.get('Status');
                sb.status =  String.isNotBlank(sd.procedureStateDescription ) ? sd.procedureStateDescription  : null;
                surveyDataList.add(sb);
            }
            response = JSON.serialize(surveyDataList);
        }
        return response;
    }
    private static Map<String, String> findTaskIdAndStatusBySurveyValue(Integer surveyValue, Id recordId) {
        Map<String, String> result = new Map<String, String>();
        
        if (surveyValue!= null && recordId != null) {
            try {
                RecordTypeInfo taskRecordTypeInfo = Task.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CIBE_ExperienciaClienteEMP');
                
                if (taskRecordTypeInfo != null) {
                    Id recTypeEmpId = taskRecordTypeInfo.getRecordTypeId();

                    Task taskRecord = [SELECT Id, Status FROM Task WHERE AV_SurveyValue__c = :surveyValue AND AccountId = :recordId AND RecordTypeId = :recTypeEmpId LIMIT 1];
                    
                    if (taskRecord != null) {
                        result.put('Id', taskRecord.Id);
                        result.put('Status', taskRecord.Status);
                    }
                }
            } catch (Exception e) {
                string sError = 'Error al consultar la tarea asociada a la encuesta';
                cbk_log.error(e);
            }
        }
        
        return result;
    }
}