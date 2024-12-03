/**********************************************************************************************************************
Name:	  CIBE_OpportunityComite
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el lwc CIBE_OpportunityComite
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
    1.0			PPM100275631    Lucía	  	    31/07/2024		Init version
    1.1			PPM100538662    Lucía	  	    22/10/2024		delete method updateEquipoRelacionado, new methods updateALM, updateLoanSyndicateSalesCheckBox, updateALMCheckBox, updateChiefCheckBox, getOpportunity

***********************************************************************************************************************/
public with sharing class CIBE_OpportunityComite {
    

    @AuraEnabled
    public static String updateEquipoSindicaciones(List<String> recordId, String equipoSindicaciones, String negocioV, String redesV, Boolean listado){
        String result = 'OK';

        List<Opportunity> oppUpdate = new List<Opportunity>();

        List<Opportunity> opp = [SELECT Id, CIBE_SyndicationTeamOpinion__c FROM Opportunity WHERE Id IN :recordId ];
        Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];


        List<CBK_PicklistValues__c> negocio = [SELECT Id FROM CBK_PicklistValues__c WHERE Name = :negocioV ];
        List<CBK_PicklistValues__c> redes = [SELECT Id FROM CBK_PicklistValues__c WHERE Name = :redesV];


        if(!negocio.isEmpty() || !redes.isEmpty()){
            List<CIBE_hierarchy__c> lstHier  =  [SELECT  CIBE_Contact__c, CIBE_Negocios__c ,CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c
                                                FROM CIBE_hierarchy__c 
                                                WHERE CIBE_Contact__c =:cont.Id  AND Recordtype.developername = : CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT LIMIT 1];
        
            
            
            if(!lstHier.isEmpty()){
                if(!negocio.isEmpty() && !redes.isEmpty() && equipoSindicaciones != null){

                    if(lstHier[0].CIBE_Negocios__c == negocio[0].Id && lstHier[0].CIBE_RedesSegmentos__c == redes[0].Id){
                            for (Opportunity oppU : opp) {
                                oppU.CIBE_SyndicationTeamOpinion__c = equipoSindicaciones;
                                oppU.CIBE_SyndicationTeamEmployee__c = cont.Id;
                                oppU.CIBE_DateSyndicationTeam__c = System.today();
                                if(listado){
                                    oppU.CIBE_LoanSyndicateSales__c = true;
                                }
                                oppUpdate.add(oppU);
                        }                         
                    }else{
                        result = 'NOK';
                    }
    
                    if(result == 'OK' && !oppUpdate.isEmpty()){
                        List<Database.SaveResult> listResult = Database.update(oppUpdate, false);
    
                        Map<String, String> msjs = new Map<String, String>();
                        boolean hasError = false;
                        List<Object> objs = new List<Object>();
                        for (Integer i = 0; i < oppUpdate.size(); i++) {
                            Database.SaveResult dr = listResult[i];
                            if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                                msjs.put(oppUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                                objs.add(oppUpdate[i]);
                                hasError = true;
                            }
                        }
                        
                        if(hasError) {
                            CBK_Log.error(msjs, objs);
                            for (String message : msjs.values()) {
                                result = message;
                            } 
                        } 
                    }
                }else{
                    result = 'NOK';
                }
            }else{
                result = 'NOK';
            }
                
        }else{
            result = 'NOK';
        }
        
        return result;
        


    }

    @AuraEnabled
    public static String updateCreditoPortfolio(List<String> recordId, String creditoPortfolio, String negocioV, String redesV){
        String result = 'OK';

        List<Opportunity> oppUpdate = new List<Opportunity>();

        List<Opportunity> opp = [SELECT Id, CIBE_CreditPortAnalystReview__c, LastModifiedDate FROM Opportunity WHERE Id IN :recordId];
        Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];

        List<CBK_PicklistValues__c> negocio = [SELECT Id FROM CBK_PicklistValues__c WHERE  Name = :negocioV ];
        List<CBK_PicklistValues__c> redes = [SELECT Id FROM CBK_PicklistValues__c WHERE Name = :redesV];


        if(!negocio.isEmpty() || !redes.isEmpty()){
            List<CIBE_hierarchy__c> lstHier  =  [SELECT  CIBE_Contact__c, CIBE_Negocios__c ,CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c
                                                FROM CIBE_hierarchy__c 
                                                WHERE CIBE_Contact__c =:cont.Id  AND Recordtype.developername = : CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT];
        
            
            if(!lstHier.isEmpty()){
                if(!negocio.isEmpty() ||!redes.isEmpty() || creditoPortfolio != null){

                    if(lstHier[0].CIBE_Negocios__c == negocio[0].Id && lstHier[0].CIBE_RedesSegmentos__c == redes[0].Id){
                        for (Opportunity oppU : opp) {
                            oppU.CIBE_CreditPortAnalystReview__c = creditoPortfolio;
                            oppU.CIBE_CredPortAnalystEmployee__c = cont.Id;
                            oppU.CIBE_DateAnalystTeam__c = System.today();
                            oppUpdate.add(oppU);
                        }
                    }else{
                        result = 'NOK';
                    }

                    if(result == 'OK' && !oppUpdate.isEmpty()){
                        List<Database.SaveResult> listResult = Database.update(oppUpdate, false);

                        Map<String, String> msjs = new Map<String, String>();
                        boolean hasError = false;
                        List<Object> objs = new List<Object>();
                        for (Integer i = 0; i < oppUpdate.size(); i++) {
                            Database.SaveResult dr = listResult[i];
                            if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                                msjs.put(oppUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                                objs.add(oppUpdate[i]);
                                hasError = true;
                            }
                        }
                        
                        if(hasError) {
                            CBK_Log.error(msjs, objs);
                            for (String message : msjs.values()) {
                                result = message;
                            }   
                        } 
                    }
                }else{
                    result = 'NOK';
                }
            }else{
                result = 'NOK';
            }
            
                
        }else{
            result = 'NOK';
        }

        return result;
    }

    @AuraEnabled
    public static String updateALM(List<String> recordId, String valueALM, String commentALM, String negocioV, String redesV, Boolean listado){
        String result = 'OK';

        List<Opportunity> oppUpdate = new List<Opportunity>();

        List<Opportunity> opp = [SELECT Id, CIBE_DicALM__c, CIBE_DicALMComment__c, CIBE_DicALMEmployee__c, CIBE_DateALM__c FROM Opportunity WHERE Id IN :recordId];
        Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];

        List<CBK_PicklistValues__c> negocio = [SELECT Id FROM CBK_PicklistValues__c WHERE  Name = :negocioV ];
        List<CBK_PicklistValues__c> redes = [SELECT Id FROM CBK_PicklistValues__c WHERE Name = :redesV];


        if(!negocio.isEmpty() || !redes.isEmpty()){
            List<CIBE_hierarchy__c> lstHier  =  [SELECT  CIBE_Contact__c, CIBE_Negocios__c ,CIBE_CentrosCarteras__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c
                                                FROM CIBE_hierarchy__c 
                                                WHERE CIBE_Contact__c =:cont.Id  AND Recordtype.developername = : CIBE_AppConstants.HIERARCHY_EMPLOYEE_RT];
        
            if(!lstHier.isEmpty()){
                if(lstHier != null && !negocio.isEmpty() && !redes.isEmpty() && (valueALM != null || commentALM != null)){

                    if(lstHier[0].CIBE_Negocios__c == negocio[0].Id && lstHier[0].CIBE_RedesSegmentos__c == redes[0].Id){
                        
                        for (Opportunity oppU : opp) {
                            if(listado){
                                oppU.CIBE_ALM__c = true;
                            }
                                oppU.CIBE_DicALM__c = valueALM;
                                oppU.CIBE_DicALMComment__c = commentALM;
                                oppU.CIBE_DateALM__c = System.today();
                                oppU.CIBE_DicALMEmployee__c = cont.Id;
                                oppUpdate.add(oppU);
                        }
                    }else{
                        result = 'NOK';
                    }
    
                    if(result == 'OK' && !oppUpdate.isEmpty()){
                        List<Database.SaveResult> listResult = Database.update(oppUpdate, false);
    
                        Map<String, String> msjs = new Map<String, String>();
                        boolean hasError = false;
                        List<Object> objs = new List<Object>();
                        for (Integer i = 0; i < oppUpdate.size(); i++) {
                            Database.SaveResult dr = listResult[i];
                            if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                                msjs.put(oppUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                                objs.add(oppUpdate[i]);
                                hasError = true;
                            }
                        }
                        
                        if(hasError) {
                            CBK_Log.error(msjs, objs);
                            for (String message : msjs.values()) {
                                result = message;
                            }   
                        } 
                    }
                }else{
                    result = 'NOK';
                }
            }else{
                result = 'NOK';
            }
                
        }else{
            result = 'NOK';
        }

        return result;
    }



    @AuraEnabled
    public static String updateLoanSyndicateSalesCheckBox(String recordId, Boolean loanSyndicateSales){
        String result = 'OK';
        List<Opportunity> oppUpdate = new List<Opportunity>();
        if(loanSyndicateSales != null){
            List<Opportunity> oppList = [SELECT Id, CIBE_LoanSyndicateSales__c FROM Opportunity WHERE Id = :recordId];
            if(!oppList.isEmpty()){
                for (Opportunity opp : oppList) {
                    if(!loanSyndicateSales){
                        opp.CIBE_DateSyndicationTeam__c = null;
                        opp.CIBE_SyndicationTeamEmployee__c = null;
                        opp.CIBE_SyndicationTeamOpinion__c = null;
                    }
                    opp.CIBE_LoanSyndicateSales__c = loanSyndicateSales;
                    oppUpdate.add(opp);
                }
            }
        }

        if(!oppUpdate.isEmpty()){
            List<Database.SaveResult> listResult = Database.update(oppUpdate, false);

            Map<String, String> msjs = new Map<String, String>();
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            for (Integer i = 0; i < oppUpdate.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(oppUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(oppUpdate[i]);
                    hasError = true;
                    result = ((String)dr.getErrors()[0].getMessage());
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs); 
            } 
        }


        return result;

    }


    @AuraEnabled
    public static String updateALMCheckBox(String recordId, Boolean alm){
        String result = 'OK';
        List<Opportunity> oppUpdate = new List<Opportunity>();
        if(alm != null){
            List<Opportunity> oppList = [SELECT Id, CIBE_ALM__c FROM Opportunity WHERE Id = :recordId];
            if(!oppList.isEmpty()){
                for (Opportunity opp : oppList) {
                    opp.CIBE_ALM__c = alm;

                    if(!alm){
                        opp.CIBE_DateALM__c = null;
                        opp.CIBE_DicALM__c = null;
                        opp.CIBE_DicALMComment__c = null;
                        opp.CIBE_DicALMEmployee__c = null;
                    }
                    oppUpdate.add(opp);
                }
            }
        }         

        if(!oppUpdate.isEmpty()){
            
            List<Database.SaveResult> listResult = Database.update(oppUpdate, false);

            Map<String, String> msjs = new Map<String, String>();
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            for (Integer i = 0; i < oppUpdate.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(oppUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(oppUpdate[i]);
                    hasError = true;
                    result = ((String)dr.getErrors()[0].getMessage());
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs); 
            } 
        }

        return result;
    }


    @AuraEnabled
    public static String updateChiefCheckBox(String recordId, Boolean chiefOperations){
        String result = 'OK';
        List<Opportunity> oppUpdate = new List<Opportunity>();
        if(chiefOperations != null){
            List<Opportunity> oppList = [SELECT Id, CIBE_ChiefOperationsOfficer__c FROM Opportunity WHERE Id = :recordId];
            if(!oppList.isEmpty()){
                for (Opportunity opp : oppList) {
                    opp.CIBE_ChiefOperationsOfficer__c = chiefOperations;
                    oppUpdate.add(opp);
                }
            }
        }

        if(!oppUpdate.isEmpty()){
            
            List<Database.SaveResult> listResult = Database.update(oppUpdate, false);

            Map<String, String> msjs = new Map<String, String>();
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            for (Integer i = 0; i < oppUpdate.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(oppUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(oppUpdate[i]);
                    hasError = true;
                    result = ((String)dr.getErrors()[0].getMessage());
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs); 
            } 
        }

        return result;
    }


    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunity(String recordId){
        List<Opportunity> opp = [SELECT Id, CIBE_SyndicationTeamOpinion__c, CIBE_DicALM__c, CIBE_DicALMComment__c, CIBE_CreditPortAnalystReview__c, CIBE_ALM__c, CIBE_ChiefOperationsOfficer__c, CIBE_LoanSyndicateSales__c FROM Opportunity WHERE Id = :recordId];
        return opp;
    }

}