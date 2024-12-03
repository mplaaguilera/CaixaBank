@isTest
public class EV_Campaign_Trigger_Test {
    
    static final String ESTADO = 'Nuevo';
    
    @isTest 
    static void testValidarMemberStatus_AfterInsert() 
    {        
        //Creamos la nueva campaña
        Id rtCampaign = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
        Campaign newCampaign = new Campaign(Name = 'CampaignTest',
                                            isActive = true,
                                            StartDate = Date.today().addDays(-5),
                                            EndDate = Date.today(),
                                            EV_DiaHora_evento__c = Datetime.now(),
                                            EV_Notification__c = '001',
                                           RecordtypeId = rtCampaign);
        									
        insert newCampaign;
        
        //Validamos el resultado
        Boolean todosEstadosCreados = true;    
        Set<String> setMemberStatus = new Set<String>();
        for(CampaignMemberStatus campaignMemberStatusList : [SELECT Id, CampaignId, Label, 
                                                             SortOrder, IsDefault, HasResponded 
                                                             FROM CampaignMemberStatus
                                                             WHERE CampaignId = :newCampaign.Id])
        {
            setMemberStatus.add(campaignMemberStatusList.Label);
        }
        
        for(EV_CampaignStatus__mdt statusCMT : [SELECT DeveloperName, Label, Orden__c, Por_defecto__c, Respondido__c 
                                             FROM EV_CampaignStatus__mdt
                                             ORDER BY Orden__c ASC])
        {
            if(!setMemberStatus.contains(statusCMT.Label))
            {
            	todosEstadosCreados = false;        
            }
        }
        System.assert(todosEstadosCreados);
    }
	
}