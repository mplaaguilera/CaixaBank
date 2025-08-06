/**********************************************************************************************************************
 Name:	  EV_CampaignWrapperDate
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para comparar y ordenar una lista por el campo EV_DiaHora_evento__c de Campaign
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US602112			Mamen Arias         11/07/2023          Init Version
***********************************************************************************************************************/
public class EV_CampaignWrapperDate implements Comparable {

    public Campaign camp;
    
    public EV_CampaignWrapperDate (Campaign campaign){
        if (campaign == null){
            Exception ex = new NullPointerException();
            ex.setMessage('Campaña no encontrada');
            throw ex;
        }
        camp = campaign;
    }
    
    public Integer compareTo(Object compareTo){
        EV_CampaignWrapperDate compareToCampaign = (EV_CampaignWrapperDate)compareTo;
        
        Integer returnValue = 0;
        
        if (camp.EV_DiaHora_evento__c == compareToCampaign.camp.EV_DiaHora_evento__c){
            returnValue = 0;
        }else if (camp.EV_DiaHora_evento__c > compareToCampaign.camp.EV_DiaHora_evento__c){
            returnValue = 1;
        } else if (camp.EV_DiaHora_evento__c < compareToCampaign.camp.EV_DiaHora_evento__c){
            returnValue = -1;
        }
        
        return returnValue;
    }
}