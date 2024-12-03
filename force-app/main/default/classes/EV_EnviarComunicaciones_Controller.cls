public without sharing class EV_EnviarComunicaciones_Controller {
    
    @auraEnabled
    public static String FinalizarEvento(Id campaignId)
    {
        String resultado = 'OK';
        List<SurveyInvitation> invitacionesNew = new List<SurveyInvitation>();
        List<SurveySubject> subjectsNew = new List<SurveySubject>();
        List<CampaignMember> campaignMemberUPD = new List<CampaignMember>();
        Map<Id, SurveyInvitation> mapMembersWithInvitation = new Map<Id, SurveyInvitation>();
        Map<Id, CampaignMember> mapMembersWithObj = new Map<Id, CampaignMember>();
        
        Campaign campaign = [SELECT Id, Status, EV_Encuesta__c, EV_DiaHora_evento__c, EV_Encuesta_requerida__c, EV_API_Plantilla_Encuesta_Email_ES__c, EV_API_Plantilla_Encuesta_Email_CAT__c                            
                             FROM Campaign
                             WHERE Id = :campaignId LIMIT 1];
        
        List<Network> comunidades = [SELECT Id FROM Network WHERE Name = :System.Label.EV_NombreComunidad LIMIT 1];
        if(campaign.Status != 'En_curso')
        {
            resultado = 'No se puede finalizar una campaña si su estado no es \'En curso\'.';
        }else if(campaign.EV_Encuesta_requerida__c){
            if(campaign.EV_API_Plantilla_Encuesta_Email_ES__c == null || campaign.EV_API_Plantilla_Encuesta_Email_CAT__c == null){
                resultado = 'Se deben definir las plantillas (Catalán y Castellano) del envío de la encuesta antes de finalizar un evento.';
            }else if(campaign.EV_Encuesta__c == null){
                resultado = 'Debe asignar una encuesta a la campaña para poder finalizarla.';
            }else{
                EV_EnviarEncuesta_Batch sendEmailBatch = new EV_EnviarEncuesta_Batch(campaignId, comunidades.get(0).Id);
                Database.executeBatch(sendEmailBatch, 1);  
            }
        }else{
            campaign.Status = 'Finalizada';
            update campaign;
        }
        
        return resultado;
    }
    
}