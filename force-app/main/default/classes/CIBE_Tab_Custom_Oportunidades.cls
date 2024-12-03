/**********************************************************************************************************************
Name:	  CIBE_TabManagementTask_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC cibe_TaskTabs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US409665    	Jose Maria	  	   24/11/2021		Init version copy retail methods 
	
***********************************************************************************************************************/

public with sharing class CIBE_Tab_Custom_Oportunidades {

    // Attributes
    public class Response {
    @AuraEnabled
    public List<WrapperReports> wrapperReports;
    @AuraEnabled
    public List<WrapperTabs> wrapperTabs;
}

    public class WrapperReports {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean header;
    }

    public class WrapperTabs {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String developerName;
        
    }
    

    /**
        * @description: Method to get the list of reports
        * @return: List of reports
    */ 
    @AuraEnabled(cacheable=true)
    public static Response getReportsUniqueName(String userId) {

        //Inicializamos las variables repotsNamesFromMDt,MapReportsNamesFromMDT y responseReports.
        List<String> reportsNamesFromMDT = new List<String>();
        Map<String,Boolean> MapReportsNamesFromMDT = new  Map<String,Boolean>();
        Response response = new Response();

        List<WrapperTabs> responseTabTemporal = new List<WrapperTabs>();
        List<WrapperReports> responseReportTemporal = new List<WrapperReports>();

        //Obtenemos los reportes del MDT.
        User actualUser = [SELECT Id, Name, UserRole.DeveloperName, LanguageLocaleKey FROM User WHERE Id =:userId];

        //Recorremos los reportes del MDT y los añadimos a la lista reportsNamesFromMDT.
        for(CIBE_customOpportunityReports__mdt report : [SELECT CIBE_Perfil__c, CIBE_Nombre_Objeto__c,CIBE_Report_DeveloperName__c,CIBE_Report_Cabecera__c FROM CIBE_customOpportunityReports__mdt WHERE CIBE_Report_DeveloperName__c != null AND CIBE_Nombre_Objeto__c = 'Report']){
            if(report.CIBE_Perfil__c.contains(actualUser.UserRole.DeveloperName)){
                reportsNamesFromMDT.add(report.CIBE_Report_DeveloperName__c);
                MapReportsNamesFromMDT.put(report.CIBE_Report_DeveloperName__c,report.CIBE_Report_Cabecera__c);
            }
        }

        for(CIBE_customOpportunityReports__mdt tab : [SELECT  CIBE_Perfil__c,MasterLabel, CIBE_Nombre_Objeto__c,CIBE_Report_DeveloperName__c,CIBE_Report_Cabecera__c FROM CIBE_customOpportunityReports__mdt WHERE CIBE_Report_DeveloperName__c != null AND CIBE_Nombre_Objeto__c = 'CustomTab']){

            if(tab.CIBE_Perfil__c.contains(actualUser.UserRole.DeveloperName)){
                String tradu =  CIBE_TranslateConfiguration__mdt.getInstance(tab.CIBE_Report_DeveloperName__c+'EN') != null && actualUser.LanguageLocaleKey =='en_US' ? CIBE_TranslateConfiguration__mdt.getInstance(tab.CIBE_Report_DeveloperName__c+'EN').CIBE_Value__c : '';
                WrapperTabs newTab = new WrapperTabs();
                newTab.label = String.isNotBlank(tradu) ? tradu:tab.MasterLabel;
                newTab.developerName = tab.CIBE_Report_DeveloperName__c;
                responseTabTemporal.add(newTab);
            }
        }

        //Obtenemos los reportes de la org.
        List <Report> reportList = [SELECT Id,Name,DeveloperName FROM Report WHERE 
            DeveloperName IN :reportsNamesFromMDT];

        //Recorremos los reportes de la org y los añadimos a la lista responseReports.
        for( Report report : reportList){
            //El limite del campo de la C_MDT es 40.
            String reportName = report.DeveloperName.length() >= 40 ? report.DeveloperName.left(40): report.DeveloperName;
            String tradu =  CIBE_TranslateConfiguration__mdt.getInstance(reportName) != null && actualUser.LanguageLocaleKey =='en_US' ? CIBE_TranslateConfiguration__mdt.getInstance(reportName).CIBE_Value__c : '';
            WrapperReports newReport = new WrapperReports();
            newReport.name = String.isNotBlank(tradu) ? tradu:report.Name;
            newReport.id = report.Id;
            newReport.header = MapReportsNamesFromMDT.get(report.DeveloperName);
            responseReportTemporal.add(newReport);
        }

        response.wrapperTabs = responseTabTemporal;
        response.wrapperReports = responseReportTemporal;


        //Devolvemos la lista responseReports.
        return response;

    }
}