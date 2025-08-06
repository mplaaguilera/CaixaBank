public without sharing class SAC_Asignacion_Plantillas {


    @AuraEnabled
    public static List<EmailTemplate> getPlantillas(String carpeta) {
        List<EmailTemplate> opcionesPlantilla = new List<EmailTemplate>();
        
        List<EmailTemplate> plantillas = [SELECT Id, Name, DeveloperName FROM EmailTemplate where Folder.DeveloperName  = :carpeta ORDER BY Name ASC];
        for (EmailTemplate plantilla : plantillas) { opcionesPlantilla.add(plantilla); }
        
        return opcionesPlantilla;
    }
}