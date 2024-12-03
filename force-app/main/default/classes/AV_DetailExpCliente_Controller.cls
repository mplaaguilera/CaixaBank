/**********************************************************************************************************************
Name:     AV_DetailExpCliente_Controller
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for LWC av_DetailExpCliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE            Description
1.0         US284842            Víctor Santiago     20/06/2022      Init version

***********************************************************************************************************************/
public with sharing class AV_DetailExpCliente_Controller {

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
    }

    @AuraEnabled
    public static String retrieveData(String numPerso) {
        String response;
        if (String.isBlank(numPerso)) {
            return null;
        }
        AV_CustomersSurveys_Integration.SurveyResponse data = AV_CustomersSurveys_Integration.getSurveyId(numPerso);
        if (!'200'.equals(data.statusCode)) {
            return null;
        }
        AV_CustomersSurveys_Integration.SurveyListData surveysData = data.data;
        if (!surveysData.Surveys.isEmpty()) {
            List<SurveyBundle> surveyDataList = new List<SurveyBundle>();
            for (AV_CustomersSurveys_Integration.SurveyData sd : surveysData.Surveys) {
                SurveyBundle sb = new SurveyBundle();
                sb.momento = String.isNotBlank(sd.description) ? sd.description : null;
                sb.momentoDate = String.isNotBlank(sd.invitationDate) ? sd.invitationDate : null;
                sb.valoracion = String.isNotBlank(sd.rating) ? sd.rating : null;
                sb.center = sd.branchCheckinId != null ? sd.branchCheckinId : null;
                sb.status = String.isNotBlank(sd.procedureStateDescription) ? sd.procedureStateDescription : null;
                sb.managementDate = String.isNotBlank(sd.procedureDate) ? sd.procedureDate : null;
                sb.secondSurvey = String.isNotBlank(sd.secondRating) ? sd.secondRating : null;
                surveyDataList.add(sb);
            }
            response = JSON.serialize(surveyDataList);
        }
        return response;
    }

}