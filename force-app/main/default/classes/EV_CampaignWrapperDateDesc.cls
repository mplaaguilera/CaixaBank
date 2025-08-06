/**********************************************************************************************************************
 Name:	  EV_CampaignWrapperDateDesc
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para comparar y ordenar una lista descendiente por el campo EV_DiaHora_evento__c de Campaign
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US602112			Mamen Arias         11/07/2023          Init Version
***********************************************************************************************************************/
public class EV_CampaignWrapperDateDesc implements Comparable {

    public Campaign camp;
    
    public EV_CampaignWrapperDateDesc (Campaign campaign){
        if (campaign == null){
            Exception ex = new NullPointerException();
            ex.setMessage('Campaña no encontrada');
            throw ex;
        }
        camp = campaign;
    }
    
    public Integer compareTo(Object compareTo){
        EV_CampaignWrapperDateDesc compareToCampaign = (EV_CampaignWrapperDateDesc)compareTo;
        
        Integer returnValue = 0;
        
        if (camp.EV_DiaHora_evento__c == compareToCampaign.camp.EV_DiaHora_evento__c){
            returnValue = 0;
        }else if (camp.EV_DiaHora_evento__c > compareToCampaign.camp.EV_DiaHora_evento__c){
            returnValue = -1;
        } else if (camp.EV_DiaHora_evento__c < compareToCampaign.camp.EV_DiaHora_evento__c){
            returnValue = 1;
        }
        
        return returnValue;
    }
}