/**********************************************************************************************************************
 Name:	  EV_CampaignWrapperTotalAsis
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para comparar y ordenar una lista descendiente por el campo EV_TotalAsistentes__c y EV_TotalAsistentesC__c de Campaign
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US602112			Mamen Arias         11/07/2023          Init Version
***********************************************************************************************************************/
public class EV_CampaignWrapperTotalAsis implements Comparable {
    
        public Campaign camp;
    
    public EV_CampaignWrapperTotalAsis (Campaign campaign){
        if (campaign == null){
            Exception ex = new NullPointerException();
            ex.setMessage('Campaña no encontrada');
            throw ex;
        }
        camp = campaign;
    }
    
    public Integer compareTo(Object compareTo){
        EV_CampaignWrapperTotalAsis other = (EV_CampaignWrapperTotalAsis)compareTo;

        Integer suma = Integer.valueOf((camp.EV_TotalAsistentes__c != null ? camp.EV_TotalAsistentes__c : 0) + (camp.EV_TotalAsistentesC__c != null ? camp.EV_TotalAsistentesC__c : 0));
        Integer suma2 = Integer.valueOf((other.camp.EV_TotalAsistentes__c != null ? other.camp.EV_TotalAsistentes__c : 0) + (other.camp.EV_TotalAsistentesC__c != null ? other.camp.EV_TotalAsistentesC__c : 0));
        
        if (suma < suma2){
            return 1;
        } else if (suma > suma2){
            return -1;
        }
        
        return 0;
    }
}