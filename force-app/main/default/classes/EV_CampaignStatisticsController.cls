/**********************************************************************************************************************
 Name:	  EV_CampaignStatisticsController
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controller para obtener los totales de las campañas.
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION	USER_STORY	AUTHOR				DATE			Description
 * 1.0		        	Carolina Lopez		01/03/2024   	Init Version
 * 1.1                  Carolina Lopez      09/07/2024      Include the fields EV_AsistioEnDiferido and EV_NumberOfAccounts.
***********************************************************************************************************************/
public with sharing class EV_CampaignStatisticsController {
    @AuraEnabled
    public static Campaign getCampaignStatistics(String recordId) {

        Campaign cmp = [SELECT Id, recordtypeId, RecordType.DeveloperName, EV_AsistioEnDiferido__c, EV_NewArchitecture__c, EV_TotalInscritos__c, EV_TotalAsistentes__c, EV_asistentesFisicos__c, EV_TotalMiembros__c, NumberOfLeads, NumberOfContacts,
        EV_inscritosVirtuales__c, EV_asistentesVirtuales__c,EV_inscritosFisicos__c, EV_inscritosFisicosVirtuales__c, EV_TotalInscritosC__c,EV_TotalAsistentesC__c, EV_TotalRegistrosConfirmadosC__c, EV_AsistentesFisicosC__c, EV_InscritosVirtualesC__c,
        EV_AsistentesVirtualesC__c, EV_InscritosFisicosC__c, EV_inscritosFisicosVirtualesC__c, EV_NumberOfContacts__c, EV_NumberOfLeads__c, EV_NumberOfAccounts__c FROM Campaign WHERE id =:recordId WITH SECURITY_ENFORCED];

        return cmp; 
    }
}