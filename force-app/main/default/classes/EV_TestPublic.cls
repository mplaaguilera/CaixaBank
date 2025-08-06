/**********************************************************************************************************************
 Name: EV_TestPublic
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para la creación de Lead y CampaignMember custom con información de contactos (EV_TestPublic).
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION      USER_STORY	    AUTHOR				DATE			Description
 * 1.0		    US567184	    Carolina Lopez		06/10/2023   	Init Version
 * 1.1          TechSummit      Carolina Lopez      17/05/2024      Add RecordType TechSummit.
***********************************************************************************************************************/
public with sharing class EV_TestPublic {
    private static Id rtEvtV = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
    private static Id rtEvtF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
    private static Id rtEvtH = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoHibrido').getRecordTypeId();
    private static Id rtEvtVTech = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_TechSummitVirtual').getRecordTypeId();
    private static Id rtEvtFTech = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_TechSummitFisico').getRecordTypeId();
    private static Id rtEvtHTech = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_TechSummitHibrido').getRecordTypeId();
    private static Id rtEvtA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_Eventos_Accionistas').getRecordTypeId();
    private static Id rtCMevt = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
    private static Id rtCMevtTech = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosTechSummit').getRecordTypeId();
    private static Id rtCMevtA = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosAccionistas').getRecordTypeId();
    private static Id rtLeadEvt = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_Evento').getRecordTypeId();
    private static Id rtLeadA = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadAccionistas').getRecordTypeId();
    private static Id rtLeadATech = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadTechSummit').getRecordTypeId();

    @invocableMethod(label='getTestPublic')
    public static void createCampaignMemberLead(List<InputParameters> inputParameters) {
        EV_LogDebug.printLogDebug('createCampaignMemberLead', String.valueof(inputParameters));
        List<Lead> lstLead = new List<Lead>();
        List<Contact> selectedContacts = new List<Contact>();
        String xrecordTypeCamp;
        String xrecordId;
        for (InputParameters params : inputParameters) {
            xrecordTypeCamp = params.recordTypeCamp;
            xrecordId = params.recordId;
            selectedContacts = params.lstContact;
        }
        if(xrecordId!= null && xrecordTypeCamp != null && !selectedContacts.isEmpty()){
            EV_LogDebug.printLogDebug('selectedContacts', String.valueof(selectedContacts) + ' xrecordId ' +  String.valueof(xrecordId) + ' xrecordTypeCamp '  + String.valueof(xrecordTypeCamp));
            for(Contact contacto : selectedContacts){
                Lead ld = new Lead();
                if(xrecordTypeCamp == rtEvtV || xrecordTypeCamp == rtEvtF  || xrecordTypeCamp == rtEvtH ){
                    ld.RecordtypeId = rtLeadEvt;
                }else if(xrecordTypeCamp == rtEvtVTech || xrecordTypeCamp == rtEvtFTech  || xrecordTypeCamp == rtEvtHTech ){
                    ld.RecordtypeId = rtLeadATech;
                }
                else if (xrecordTypeCamp == rtEvtA){
                    ld.RecordtypeId = rtLeadA;
                }
                ld.EV_Idiomas__c = contacto.EV_Idiomas__c;
                ld.Email = contacto.Email;
                ld.LastName = contacto.LastName;
                ld.FirstName = contacto.FirstName;
                ld.Phone = contacto.Phone;
                ld.EV_ConsentimientoGeneral__c = true;
                lstLead.add(ld);
            }

            List<EV_CampaignMemberC__c> lstCM = new List<EV_CampaignMemberC__c>();
            Database.SaveResult[] resultLead = Database.insert(lstLead, false);
            for(Database.SaveResult dato : resultLead){
                if(dato.isSuccess()){
                    EV_CampaignMemberC__c cmcus = new EV_CampaignMemberC__c();
                    if(xrecordTypeCamp == rtEvtA){
                        cmcus.RecordTypeId = rtCMevtA;
                    }else if(xrecordTypeCamp == rtEvtV || xrecordTypeCamp == rtEvtF  || xrecordTypeCamp == rtEvtH ){
                        cmcus.RecordTypeId = rtCMevt;
                    }else if(xrecordTypeCamp == rtEvtVTech || xrecordTypeCamp == rtEvtFTech  || xrecordTypeCamp == rtEvtHTech ){
                        cmcus.RecordTypeId = rtCMevtTech;
                    }
                    cmcus.EV_LeadId__c = dato.getId();
                    cmcus.EV_CampaignId__c = xrecordId;
                    cmcus.EV_MiembroPrueba__c = true;
                    lstCM.add(cmcus);
                }else{
                    EV_LogDebug.printLogDebug('Error al insertar registro Lead: ', String.valueof(dato.getErrors()[0].getMessage()));
                }
            }

            Database.SaveResult[] resultCM = Database.insert(lstCM, false);
            for(Database.SaveResult datoCM : resultCM){
                if(!datoCM.isSuccess()){
                    EV_LogDebug.printLogDebug('Error al insertar registro CampaignMember: ', String.valueof(datoCM.getErrors()[0].getMessage()));
                }
            }
        }
    }

    public class InputParameters {
        @InvocableVariable(label='lstContact')
        public List<Contact> lstContact;
        
        @InvocableVariable(label='recordId')
        public String recordId;

        @InvocableVariable(label='recordTypeCamp')
        public String recordTypeCamp;
    }
}