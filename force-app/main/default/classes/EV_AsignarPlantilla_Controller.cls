public with sharing class EV_AsignarPlantilla_Controller {
    
    @AuraEnabled
    public static List<Folder> getCarpetas(String carpetaDeveloperName) {
        List<Folder> carpetas = new List<Folder>();

        Id parentId;
        if (carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'EV_EventosMarketing' LIMIT 1].Id;
        }
        else {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
        }

        for (Folder carpeta : [SELECT Name, DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId]) {
            carpetas.add(carpeta);
        }
        return carpetas;
    }
    
    @AuraEnabled
    public static List<EmailTemplate> getPlantillas(String carpeta) {
        List<EmailTemplate> opcionesPlantilla = new List<EmailTemplate>();

        Id carpetaId = [SELECT Id FROM Folder WHERE DeveloperName = :carpeta LIMIT 1].Id;
        List<EmailTemplate> plantillas = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE FolderId = :carpetaId ORDER BY Name ASC];

        for (EmailTemplate plantilla : plantillas) {
            opcionesPlantilla.add(plantilla);
        }
        
        return opcionesPlantilla;
    }
    
    @AuraEnabled
    public static void guardarPlantilla(Id campaignId, String carpeta, String template, String templateDev){
		String templateDeveloperName = 'EV_API_Plantilla';
		String templateName = 'EV_Plantilla';
        
        List<String> parts = carpeta.split('_');
        for(Integer i = 1; i <= parts.size()-1; i++)
        {
            templateDeveloperName += '_' + parts[i];
            templateName += '_' + parts[i];
        }        
        templateDeveloperName += '__c';
        templateName += '__c';
        
        System.debug('templateDeveloperName: '+templateDeveloperName);
        System.debug('templateName: '+templateName);
        
        //Updateamos la campaña dinamicamente
        SObjectType objToken = Schema.getGlobalDescribe().get('Campaign'); 
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        
        sObject campaign = [SELECT Id FROM Campaign WHERE Id = :campaignId];
        if(fields.containsKey(templateDeveloperName))
        {
            campaign.put(templateDeveloperName, templateDev);
        }
        if(fields.containsKey(templateName))
        {
            campaign.put(templateName, template);
        }
        update campaign;
    }
}