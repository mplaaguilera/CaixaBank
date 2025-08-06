/*****************************************************************************************
 * Name: CIBE_OpportunityEmail
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Lanzar un email de aviso con los cambios producidos en una oportunidad. 
 * 
 * -------
 * VERSION        USER_STORY         AUTHOR           DATE            Description
 * 1.0            US615974           Ali              30/10/2023      Init Version
 * 1.1            FIX                Luis             04/04/2024      Se limita para CIB
 * 1.2            PPM100538662       Lucía            22/10/2024      New methods sendEmailComitePrecio, getEmailSindicaciones, getEmailALM, emailRequerimiento
 * 
******************************************************************************************/
public with sharing class CIBE_OpportunityEmail {

    public static User user = CIBE_AppUtilities.getUserInfo();
    private static CIBE_AppUtilities.SearchRT rtINICIATIVACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtINICIATIVAEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtSUGERENCIACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtSUGERENCIAEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtALERTACOMERCIALCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtALERTACOMERCIALEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtACCIONCOMERCIALCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT);
    private static CIBE_AppUtilities.SearchRT rtACCIONCOMERCIALEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONEMP_RT);
    
    private static CIBE_AppUtilities.SearchRT rtTASKINICIATIVACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtTASKINICIATIVAEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
    
    private static Set<Id> setRtOppCIB   = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVACIB, rtSUGERENCIACIB, rtALERTACOMERCIALCIB, rtACCIONCOMERCIALCIB});
    private static Set<Id> setRtOppEMP   = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVAEMP, rtSUGERENCIAEMP, rtALERTACOMERCIALEMP, rtACCIONCOMERCIALEMP});

    /**    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		

        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

	/* @description	       metodo que se encarga de mandar un emailTemplate cuando cambia la confidencialidad de la oportunidad
	* @param  listNews     list of new Opportunity records
	* @param  mapOldObj    map with old Opportunity records
	*/
	public static void emailConfidential(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds){

        Set<Id> opportunityIds = new Set<Id>(); 
        if(listNews.size()==1){
            for(Opportunity opp : listNews) {
                if(mapOlds.get(opp.Id).AV_ClienteConfidencial__c != opp.AV_ClienteConfidencial__c && setRtOppCIB.contains(opp.recordTypeId)) {
                    opportunityIds.add(opp.Id);
                }
            }
            if(!opportunityIds.isEmpty()){
            Map<String, Opportunity> oportunidadesPorIdiomaYConfidencialidad = new Map<String, Opportunity>();
            List<Opportunity> newOpportunityList = [SELECT ID, Name, Account.Name, StageName, AV_ClienteConfidencial__c, Owner.Name,
                                                    OwnerId, Owner.LanguageLocaleKey, Owner.email
                                                    FROM Opportunity WHERE Id IN :opportunityIds ];    
            for(Opportunity opp2 : newOpportunityList){
                oportunidadesPorIdiomaYConfidencialidad.put(opp2.Id, opp2);
            }
            
            Map<String, List<OpportunityTeamMember>> oppTMPorIdiomaYConfidencialidad = new Map<String, List<OpportunityTeamMember>>();
            if(Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()) {
                for(OpportunityTeamMember opportunityTM : [SELECT Id, OpportunityId, Opportunity.OwnerId, UserId, User.LanguageLocaleKey, 
                                                            Opportunity.AV_ClienteConfidencial__c, User.email
                                                            FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIds]) {
                        if(!oppTMPorIdiomaYConfidencialidad.containsKey(opportunityTM.OpportunityId)){
                            oppTMPorIdiomaYConfidencialidad.put(opportunityTM.OpportunityId, new List<OpportunityTeamMember>{opportunityTM});
                        }
                        if(oppTMPorIdiomaYConfidencialidad.containsKey(opportunityTM.OpportunityId)){
                            oppTMPorIdiomaYConfidencialidad.get(opportunityTM.OpportunityId).add(opportunityTM);
                        }                                                         
                }
            }
    
            for(String oppId : oportunidadesPorIdiomaYConfidencialidad.keySet()){
                Set<Id> setUserConfiEsp = new Set<Id>();
                Set<Id> setUserNoConfiEsp = new Set<Id>();
                Set<Id> setUserConfiIngles = new Set<Id>();
                Set<Id> setUserNoConfiIngles = new Set<Id>();
                if(oportunidadesPorIdiomaYConfidencialidad.get(oppId).OwnerId != user.Id){
                    if( !oportunidadesPorIdiomaYConfidencialidad.get(oppId).Owner.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                        if(oportunidadesPorIdiomaYConfidencialidad.get(oppId).Owner.LanguageLocaleKey == 'es'){
                            if(oportunidadesPorIdiomaYConfidencialidad.get(oppId).AV_ClienteConfidencial__c){
                                setUserConfiEsp.add(oportunidadesPorIdiomaYConfidencialidad.get(oppId).OwnerId);
                            }else{
                                setUserNoConfiEsp.add(oportunidadesPorIdiomaYConfidencialidad.get(oppId).OwnerId);
                            }
                        }else{
                            if(oportunidadesPorIdiomaYConfidencialidad.get(oppId).AV_ClienteConfidencial__c){
                                setUserConfiIngles.add(oportunidadesPorIdiomaYConfidencialidad.get(oppId).OwnerId);
                            }else{
                                setUserNoConfiIngles.add(oportunidadesPorIdiomaYConfidencialidad.get(oppId).OwnerId);
                            }
                        } 
                    }
                }
                
                if(oppTMPorIdiomaYConfidencialidad.containsKey(oppId)){                
                    for(OpportunityTeamMember oppTM: oppTMPorIdiomaYConfidencialidad.get(oppId)){
                        if(oppTM.UserId != user.Id ){
                            if(!oppTM.User.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                                if( oppTM.User.LanguageLocaleKey == 'es'){
                                    if(oppTM.Opportunity.AV_ClienteConfidencial__c){ 
                                        setUserConfiEsp.add(oppTM.UserId);
                                    }else{
                                        setUserNoConfiEsp.add(oppTM.UserId);
                                    }
                                }else{
                                    if(oppTM.Opportunity.AV_ClienteConfidencial__c){
                                        setUserConfiIngles.add(oppTM.UserId);
                                    }else{
                                        setUserNoConfiIngles.add(oppTM.UserId);
                                    }
                                }
                            }
                        }
                    }
                }

                if(!setUserConfiEsp.isEmpty()){
                    massEmailMessageOpp(setUserConfiEsp, 'CIBE_OppNotificacionConfidencial_es', oportunidadesPorIdiomaYConfidencialidad.get(oppId));
                }
                if(!setUserNoConfiEsp.isEmpty()){
                    massEmailMessageOpp(setUserNoConfiEsp, 'CIBE_OppNotificacionNoConfidencial_es', oportunidadesPorIdiomaYConfidencialidad.get(oppId));
                }
                if(!setUserConfiIngles.isEmpty()){
                    massEmailMessageOpp(setUserConfiIngles, 'CIBE_OppNotificacionConfidencial_en', oportunidadesPorIdiomaYConfidencialidad.get(oppId));
                }
                if(!setUserNoConfiIngles.isEmpty()){
                    massEmailMessageOpp(setUserNoConfiIngles, 'CIBE_OppNotificacionNoConfidencial_en', oportunidadesPorIdiomaYConfidencialidad.get(oppId));
                }
            }
        }
    }	
}	

    /**
	* @description	       metodo que se encarga de mandar un emailTemplate cuando cambia el estado de la oportunidad
	* @param  listNews     list of new Opportunity records
	* @param  mapOldObj    map with old Opportunity records
	*/
	public static void emailStageName(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds){

        Set<Id> opportunityIds = new Set<Id>();          
        for(Opportunity opp : listNews) {
            if(mapOlds.get(opp.Id).StageName != opp.StageName && setRtOppCIB.contains(opp.RecordtypeId)){
                opportunityIds.add(opp.Id);
            }
        }

        if(!opportunityIds.isEmpty()){
            Map<String, Opportunity> oppUpdateStageName = new Map<String, Opportunity>();
            List<Opportunity> newOpportunityList = [SELECT ID, StageName, OwnerId, Owner.LanguageLocaleKey, Name, Account.Name, Owner.email
                                                    FROM Opportunity WHERE Id IN :opportunityIds ];  

            for(Opportunity opp2 : newOpportunityList){
                oppUpdateStageName.put(opp2.Id, opp2);
            }
        
            Map<String, List<OpportunityTeamMember>> oppTMUpdateStageName = new Map<String, List<OpportunityTeamMember>>();
            if(Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()) {
                for(OpportunityTeamMember opportunityTM : [SELECT Id, OpportunityId, Opportunity.OwnerId, UserId, User.LanguageLocaleKey, Opportunity.AV_ClienteConfidencial__c , User.email
                                                            FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIds]) {                                
                        if(!oppTMUpdateStageName.containsKey(opportunityTM.OpportunityId)){
                            oppTMUpdateStageName.put(opportunityTM.OpportunityId, new List<OpportunityTeamMember>{opportunityTM});
                        }
                        if(oppTMUpdateStageName.containsKey(opportunityTM.OpportunityId)){
                            oppTMUpdateStageName.get(opportunityTM.OpportunityId).add(opportunityTM);
                        }                                                
                }
            }
            
            for(String oppId : oppUpdateStageName.keySet()){
                Set<Id> setUserES = new Set<Id>();
                Set<Id> setUserENUS = new Set<Id>();
                if(oppUpdateStageName.get(oppId).OwnerId != user.Id){
                    if( !oppUpdateStageName.get(oppId).Owner.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                        if(oppUpdateStageName.get(oppId).Owner.LanguageLocaleKey == 'es'){
                            setUserES.add(oppUpdateStageName.get(oppId).OwnerId);
                        }else{
                            setUserENUS.add(oppUpdateStageName.get(oppId).OwnerId);
                        }
                    }
                }
                if(oppTMUpdateStageName.containsKey(oppId)){                
                    for(OpportunityTeamMember oppTM: oppTMUpdateStageName.get(oppId)){
                        if(oppTM.UserId != user.Id){
                            if( !oppTM.User.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                                if(oppTM.User.LanguageLocaleKey == 'es'){
                                    setUserES.add(oppTM.UserId);
                                }
                                else{
                                    setUserENUS.add(oppTM.UserId);
                                }
                            }
                        }
                    }
                }

                if(!setUserES.isEmpty()){
                    massEmailMessageOpp(setUserES, 'CIBE_OppNotificacionCambioEstado_es', oppUpdateStageName.get(oppId));
                }
                if(!setUserENUS.isEmpty()){
                    massEmailMessageOpp(setUserENUS, 'CIBE_OppNotificacionCambioEstado_en', oppUpdateStageName.get(oppId));
                }
            }  
        }
    }

    /**
	* @description	       metodo que se encarga de mandar un emailTemplate cuando cambia el owner de la oportunidad
	* @param  listNews     list of new Opportunity records
	* @param  mapOldObj    map with old Opportunity records
	*/
	public static void emailoppOwnerChange(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds){
        Set<Id> opportunityId = new Set<Id>();
        for(Opportunity opp : listNews) {
            if(mapOlds.get(opp.Id).OwnerId != opp.OwnerId && setRtOppCIB.contains(opp.RecordtypeId)) {
                opportunityId.add(opp.Id);
            }
        }
        if(!opportunityId.isEmpty()){
                    
            List<Opportunity> newOpportunityList = [SELECT ID, OwnerId, Owner.LanguageLocaleKey, Name, Account.Name, StageName, Owner.email 
                                                    FROM Opportunity WHERE Id IN :opportunityId ];  
            
            for(Opportunity opp2 : newOpportunityList){
                Set<Id> setUserES = new Set<Id>();
                if(opp2.OwnerId != user.Id){
                    if( !opp2.Owner.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                        setUserES.add(opp2.OwnerId);
                        if(opp2.Owner.LanguageLocaleKey == 'es'){
                            massEmailMessageOpp(setUserES, 'CIBE_OppNotificacionInsertOppTM_es', opp2);
                        }else{
                            massEmailMessageOpp(setUserES, 'CIBE_OppNotificacionInsertOppTM_en', opp2);
                        }
                    }
                }               
            }   
        }
    }

    /**
	* @description	       metodo que se encarga de mandar un emailTemplate cuando se añade un oppTM a la oportunidad
	* @param  listNews     list of new Opportunity records
	*/
	public static void emailAddOppTM(List<OpportunityTeamMember> listNews){
        List<OpportunityTeamMember> newOppTMList = [SELECT ID, Opportunity.Name, Opportunity.OwnerId, Opportunity.Owner.LanguageLocaleKey, UserId, User.LanguageLocaleKey, Opportunity.Account.Name, Opportunity.AccountId, User.email
                                                    FROM OpportunityTeamMember WHERE OpportunityId =:listNews[0].OpportunityId AND UserId = :listNews[0].UserId AND Opportunity.recordTypeId IN:setRtOppCIB ];     
        
        for(OpportunityTeamMember oppTM : newOppTMList){
            if(oppTM.UserId != user.Id){
                if( !oppTM.User.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                    if(oppTM.User.LanguageLocaleKey == 'es'){
                        massEmailMessageOppTM('CIBE_OppNotificacionInsertOppTM_es', oppTM);
                    }else{
                        massEmailMessageOppTM('CIBE_OppNotificacionInsertOppTM_en', oppTM);
                    }   
                }
            }               
        }
	}

            /**
	* @description	       metodo que se encarga de mandar un emailTemplate cuando se elimina un oppTM a la oportunidad
	* @param  listNews     list of new Opportunity records
	*/
	public static void emailDeleteOppTM(List<OpportunityTeamMember> listNews){
        List<OpportunityTeamMember> newOppTMList = [SELECT ID, Opportunity.Name, Opportunity.OwnerId, Opportunity.Owner.LanguageLocaleKey, UserId, User.LanguageLocaleKey, Opportunity.Account.Name, Opportunity.AccountId, User.email 
                                                FROM OpportunityTeamMember WHERE OpportunityId =:listNews[0].OpportunityId AND UserId = :listNews[0].UserId AND Opportunity.recordTypeId IN:setRtOppCIB];     
        
        for(OpportunityTeamMember otm : newOppTMList){
            if(otm.UserId != user.Id){
                if( !otm.User.email.containsIgnoreCase(CIBE_AppConstants.CBK_TECH) ){
                    if(otm.User.LanguageLocaleKey == 'es'){
                        massEmailMessageOppTM('CIBE_OppNotificacionDeleteOppTM_es', otm);
                    }else{
                        massEmailMessageOppTM('CIBE_OppNotificacionDeleteOppTM_en',  otm);
                    }            
                }
            }                  
        }
	}

    /**
	* @description	       
	* @param  setUsers              lista de usuarios que reciben el email     
    * @param  templateDevName       plantilla de email que va a usar
    * @param  oppList               oportunidades 
	*/
    public static void massEmailMessageOpp(Set<Id> setUsers, String templateDevName, Opportunity oportunidad){
        Map<String, String> msjsError = new Map<String, String>();
        List<User> lstUsers = new List<User>();
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        EmailTemplate emtem = new EmailTemplate();
        String bodyHTMLCustom;
        String bodyCustom;
        String subjectCustom;
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage> ();
        String address = CIBE_DataMapping__mdt.getInstance('CIBE_EmailNotificaciones').CIBE_Value__c;
        if(!setUsers.isEmpty() && oportunidad != null){
            try{
                owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :address  LIMIT 1];
                emtem = [SELECT Id,HtmlValue,Subject,Body FROM EmailTemplate  WHERE DeveloperName =:templateDevName LIMIT 1];
                lstUsers = [SELECT Id,name,Email  FROM User  WHERE Id =:setUsers AND isActive = TRUE];
                String dominio = Url.getOrgDomainUrl().toExternalForm();
                for(User u : lstUsers){
                    bodyHTMLCustom = emtem.HtmlValue;
                    bodyHTMLCustom = bodyHTMLCustom.replace('XXX',String.valueOf(u.name));
                    bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.Account}',String.valueOf(oportunidad.Account.Name));
                    bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.Name}','<a href="'+dominio+'/lightning/r/Opportunity/'+String.valueOf(oportunidad.Id)+'/view">'+String.valueOf(oportunidad.Name)+'</a>');
                    if(bodyHTMLCustom.containsIgnoreCase('{!Opportunity.StageName}')){
                        List<CIBE_TranslateConfiguration__mdt> translations = CIBE_TranslateConfiguration__mdt.getAll().values();
                        Boolean idioma = templateDevName.containsIgnoreCase('_es');
                        for(CIBE_TranslateConfiguration__mdt translation : translations) {
                            if(String.isNotBlank(translation.CIBE_TranslationName__c) && translation.CIBE_TranslationName__c.equalsIgnoreCase(oportunidad.StageName) && idioma && translation.CIBE_Language__c.equalsIgnoreCase('es')) {
                                bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.StageName}',translation.CIBE_Value__c);
                            }else if(String.isNotBlank(translation.CIBE_TranslationName__c) && translation.CIBE_TranslationName__c.equalsIgnoreCase(oportunidad.StageName) && !idioma && translation.CIBE_Language__c.equalsIgnoreCase('en_US')){
                                bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.StageName}',translation.CIBE_Value__c);
                            }
                        }
                    }

                    subjectCustom = emtem.Subject;
                    subjectCustom = emtem.Subject.replace('{!Opportunity.Name}',String.valueOf(oportunidad.name));
                    bodyHTMLCustom = bodyHTMLCustom.replaceAll(']]>','');
                    bodyHTMLCustom = bodyHTMLCustom.replace('[','');
                    bodyHTMLCustom = bodyHTMLCustom.replace(']','');
                    bodyHTMLCustom = bodyHTMLCustom.replaceAll('<!CDATA','');
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setOrgWideEmailAddressId(owea.Id);
                        email.setTemplateId(emtem.Id);
                        email.setOptOutPolicy('SEND');
                        email.setTargetObjectId(u.id);
                        email.setTreatBodiesAsTemplate(true);
                        email.setSubject(subjectCustom);
                        email.setHtmlBody(bodyHTMLCustom);
                        email.setPlainTextBody(bodyHTMLCustom);
                        email.setTreatTargetObjectAsRecipient(true);
                        email.setSaveAsActivity(false);
                    lstEmail.add(email);
                }
            }catch(Exception e) {
                CBK_Log.error(e+ ' '+ oportunidad + ' sin OWA');
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstEmail,false);
            for (Messaging.SendEmailResult result : results) {

                if (!result.isSuccess()) {
                    String errorMessage = 'Error al enviar el correo electrónico: ';
                    for (Messaging.SendEmailError error : result.getErrors()) {
                        errorMessage += error.getMessage() + '\n';
                        msjsError.put(error.getMessage(), String.valueof(error));
                    }
                    CBK_Log.error(msjsError);
                }
            }
        }
    }

    /**
	* @description	       
	* @param  templateDevName       lista de usuarios que reciben el email     
    * @param  oppTM                 oppportunityTeamMember 
	*/
    public static void massEmailMessageOppTM(String templateDevName, OpportunityTeamMember oppTM){
        Map<String, String> msjsError = new Map<String, String>();
        List<User> lstUsers = new List<User>();
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        EmailTemplate emtem = new EmailTemplate();
        String bodyHTMLCustom;
        String bodyCustom;
        String subjectCustom;
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage> ();
        String address = CIBE_DataMapping__mdt.getInstance('CIBE_EmailNotificaciones').CIBE_Value__c;
        if(oppTM != null && address != null){
            try{
                owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :address  LIMIT 1];
                emtem = [SELECT Id,HtmlValue,Subject,Body FROM EmailTemplate  WHERE DeveloperName =:templateDevName LIMIT 1];
                lstUsers = [SELECT Id,name,Email  FROM User  WHERE Id =:oppTM.UserId AND isActive = TRUE];
                String dominio = Url.getOrgDomainUrl().toExternalForm();
                for(User u : lstUsers){
                    //HTML
                    bodyHTMLCustom = emtem.HtmlValue;
                    bodyHTMLCustom = bodyHTMLCustom.replace('XXX',String.valueOf(u.name));
                    bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.Account}',String.valueOf(oppTM.Opportunity.Account.Name));
                    bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.Name}','<a href="'+dominio+'/lightning/r/Opportunity/'+String.valueOf(oppTM.Opportunity.Id)+'/view">'+String.valueOf(oppTM.Opportunity.Name)+'</a>');

                    //Subject
                    subjectCustom = emtem.Subject;
                    subjectCustom = emtem.Subject.replace('{!Opportunity.Name}',String.valueOf(oppTM.Opportunity.Account.Name));

                    bodyHTMLCustom = bodyHTMLCustom.replaceAll(']]>','');
                    bodyHTMLCustom = bodyHTMLCustom.replace('[','');
                    bodyHTMLCustom = bodyHTMLCustom.replace(']','');
                    bodyHTMLCustom = bodyHTMLCustom.replaceAll('<!CDATA','');
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                        email.setOrgWideEmailAddressId(owea.Id);
                        email.setTemplateId(emtem.Id);
                        email.setOptOutPolicy('SEND');
                        email.setTargetObjectId(u.id);
                        email.setTreatBodiesAsTemplate(true);
                        email.setSubject(subjectCustom);
                        email.setHtmlBody(bodyHTMLCustom);
                        email.setPlainTextBody(bodyHTMLCustom);
                        email.setTreatTargetObjectAsRecipient(true);
                        email.setSaveAsActivity(false);
                    lstEmail.add(email);
                }
            }catch(Exception e) {
                CBK_Log.error(e+ ' '+ oppTM + ' sin OWA');
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstEmail,false);
            for (Messaging.SendEmailResult result : results) {

                if (!result.isSuccess()) {
                    String errorMessage = 'Error al enviar el correo electrónico: ';
                    if (result.getErrors() != null && !result.getErrors().isEmpty()) {
                        for (Messaging.SendEmailError error : result.getErrors()) {
                            errorMessage += error.getMessage() + '\n';
                            msjsError.put(error.getMessage(), String.valueof(error));
                        }
                    }
                    CBK_Log.error(msjsError);
                }
            }
        }
    }


    public static void emailRequerimiento(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds){
        String idioma = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()].LanguageLocaleKey;
        Set<Id> opportunityIdsRA = new Set<Id>();
        Set<Id> opportunityIdsNRA = new Set<Id>(); 
        String addressSyndicate =  CIBE_DataMapping__mdt.getInstance('CIBE_EmailSyndicateSales').CIBE_Value__c;
        String addressALM = CIBE_DataMapping__mdt.getInstance('CIBE_EmailALM').CIBE_Value__c; 
        String addressChief = CIBE_DataMapping__mdt.getInstance('CIBE_EmailChief').CIBE_Value__c; 
        String correo;        
        for(Opportunity opp : listNews) {
            if(mapOlds.get(opp.Id).CIBE_LoanSyndicateSales__c != opp.CIBE_LoanSyndicateSales__c && opp.CIBE_LoanSyndicateSales__c && setRtOppCIB.contains(opp.RecordtypeId) && addressSyndicate != null){
                opportunityIdsRA.add(opp.Id);
                correo = addressSyndicate; 
            }


            if(mapOlds.get(opp.Id).CIBE_ALM__c != opp.CIBE_ALM__c && opp.CIBE_ALM__c && setRtOppCIB.contains(opp.RecordtypeId) && addressALM != null){
                opportunityIdsRA.add(opp.Id);
                correo = addressALM;
            }

            if(mapOlds.get(opp.Id).CIBE_ChiefOperationsOfficer__c != opp.CIBE_ChiefOperationsOfficer__c && opp.CIBE_ChiefOperationsOfficer__c && setRtOppCIB.contains(opp.RecordtypeId) && addressChief != null){
                opportunityIdsRA.add(opp.Id);
                correo = addressChief;
            }

            if(mapOlds.get(opp.Id).CIBE_LoanSyndicateSales__c != opp.CIBE_LoanSyndicateSales__c && !opp.CIBE_LoanSyndicateSales__c && setRtOppCIB.contains(opp.RecordtypeId) && addressSyndicate != null){
                opportunityIdsNRA.add(opp.Id);
                correo = addressSyndicate;
            }

            if(mapOlds.get(opp.Id).CIBE_ALM__c != opp.CIBE_ALM__c && !opp.CIBE_ALM__c && setRtOppCIB.contains(opp.RecordtypeId) && addressALM != null){
                opportunityIdsNRA.add(opp.Id);
                correo = addressALM;
            }
            
            if(mapOlds.get(opp.Id).CIBE_ChiefOperationsOfficer__c != opp.CIBE_ChiefOperationsOfficer__c && !opp.CIBE_ChiefOperationsOfficer__c && setRtOppCIB.contains(opp.RecordtypeId) && addressChief != null){
                opportunityIdsNRA.add(opp.Id);
                correo = addressChief;
            }
        }
        if(!opportunityIdsRA.isEmpty() && correo != null){
            List<Opportunity> newOpportunityList = [SELECT ID, CIBE_LoanSyndicateSales__c, OwnerId, Owner.LanguageLocaleKey, Name, Account.Name, Owner.email
            FROM Opportunity WHERE Id IN :opportunityIdsRA ];  

            for(Opportunity opp2 : newOpportunityList){
                if(idioma == 'es'){
                    sendEmailComitePrecio('CIBE_OppNotificacionRequerimentoActuacion_es', opp2.Id, correo);
                }else if(idioma == 'en_US'){
                    sendEmailComitePrecio('CIBE_OppNotificacionRequerimentoActuacion_en', opp2.Id, correo);

                }
            }
        }

        if(!opportunityIdsNRA.isEmpty() && correo != null){
            List<Opportunity> newOpportunityList2 = [SELECT Id, CIBE_LoanSyndicateSales__c, CIBE_ALM__c, CIBE_ChiefOperationsOfficer__c,  OwnerId, Owner.LanguageLocaleKey, Name, Account.Name, Owner.email
            FROM Opportunity WHERE Id IN :opportunityIdsNRA ];

            if(!newOpportunityList2.isEmpty()){
                for(Opportunity oppNRA : newOpportunityList2){
                    if(idioma == 'es'){
                        sendEmailComitePrecio('CIBE_OppNotificacionNoRequerimentoActuacion_es', oppNRA.Id, correo);
                    }else if(idioma == 'en_US'){
                        sendEmailComitePrecio('CIBE_OppNotificacionNoRequerimentoActuacion_en', oppNRA.Id, correo);

                    }
                }
            }
        }
    }

    @AuraEnabled
    public static void sendEmailComitePrecio( String templateDevName, String oportunidad, String correo){
        Map<String, String> msjsError = new Map<String, String>();
        List<User> lstUsers = new List<User>();
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        EmailTemplate emtem = new EmailTemplate();
        String bodyHTMLCustom;
        String bodyCustom;
        String subjectCustom;
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage> ();
        String address = CIBE_DataMapping__mdt.getInstance('CIBE_EmailNotificaciones').CIBE_Value__c;
        Opportunity opp = [SELECT Id, Name, Account.Name  FROM Opportunity WHERE Id = :oportunidad];

        if(templateDevName != null && correo != null && address != null && opp != null){
            try{
                String[] toAddresses = new String[] {correo};   
                owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :address  LIMIT 1];
                emtem = [SELECT Id,HtmlValue,Subject,Body FROM EmailTemplate  WHERE DeveloperName =:templateDevName LIMIT 1];
                String dominio = Url.getOrgDomainUrl().toExternalForm();
                bodyHTMLCustom = emtem.HtmlValue;
                bodyHTMLCustom = bodyHTMLCustom.replace('{!Opportunity.Name}','<a href="'+dominio+'/lightning/r/Opportunity/'+String.valueOf(opp.Id)+'/view">'+String.valueOf(opp.Name)+'</a>');
               

                subjectCustom = emtem.Subject;
                subjectCustom = emtem.Subject.replace('{!Opportunity.Name}',String.valueOf(opp.name)).replace('{!Opportunity.Account}',String.valueOf(opp.Account.Name));
                bodyHTMLCustom = bodyHTMLCustom.replaceAll(']]>','');
                bodyHTMLCustom = bodyHTMLCustom.replace('[','');
                bodyHTMLCustom = bodyHTMLCustom.replace(']','');
                bodyHTMLCustom = bodyHTMLCustom.replaceAll('<!CDATA','');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(owea.Id);
                    email.setTemplateId(emtem.Id);
                    email.setOptOutPolicy('SEND');
                    email.setToAddresses(toAddresses);
                    email.setTreatBodiesAsTemplate(true);
                    email.setSubject(subjectCustom);
                    email.setHtmlBody(bodyHTMLCustom);
                    email.setPlainTextBody(bodyHTMLCustom);
                    email.setTreatTargetObjectAsRecipient(true);
                    email.setSaveAsActivity(false);
                lstEmail.add(email);
                
            }catch(Exception e) {
                CBK_Log.error(e+ ' '+ opp + ' sin OWA');
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstEmail,false);
            for (Messaging.SendEmailResult result : results) {

                if (!result.isSuccess()) {
                    String errorMessage = 'Error al enviar el correo electrónico: ';
                    for (Messaging.SendEmailError error : result.getErrors()) {
                        errorMessage += error.getMessage() + '\n';
                        msjsError.put(error.getMessage(), String.valueof(error));
                    }
                    CBK_Log.error(msjsError);
                }
            }
        }
    }


    @AuraEnabled(cacheable=true)
    public static string getEmailSindicaciones(String label){
        String value = [SELECT Id, CIBE_Value__c  from CIBE_DataMapping__mdt where Label = :label].CIBE_Value__c;
        return  value;
    }

    @AuraEnabled(cacheable=true)
    public static string getEmailALM(String label){
        String value = [SELECT Id, CIBE_Value__c  from CIBE_DataMapping__mdt where Label = :label].CIBE_Value__c;
        return  value;
    }

    @AuraEnabled(cacheable=true)
    public static string getLanguage(){
        String value = [SELECT Id, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()].LanguageLocaleKey;
        return  value;
    }

}