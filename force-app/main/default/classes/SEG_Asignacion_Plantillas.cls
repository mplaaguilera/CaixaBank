public with sharing class SEG_Asignacion_Plantillas {
    
    @TestVisible
    private class GetPlantillasRetorno {
        @AuraEnabled
        public List<EmailTemplate> plantillas;
        @AuraEnabled
        public SEG_Plantilla__c plantillaSeg;
    }

    @AuraEnabled
    public static GetPlantillasRetorno getPlantillas(Id idPlantillaSeg) {
        GetPlantillasRetorno retorno = new GetPlantillasRetorno();
        retorno.plantillas = [SELECT Folder.DeveloperName, DeveloperName, Name FROM EmailTemplate
                                WHERE Folder.DeveloperName IN ('SEG_Castellano', 'SEG_Catala', 'SEG_Ingles', 'SEG_Euskera', 'SEG_Gallego')
                                ORDER BY Name ASC];
        retorno.plantillaSeg = [SELECT SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c,
                                SEG_PlantillaInglesID__c, SEG_PlantillaEuskeraID__c,
                                SEG_PlantillaGalegoID__c FROM SEG_Plantilla__c
                                WHERE Id = :idPlantillaSeg];
        return retorno;
    }

    @AuraEnabled
    public static void asociarPlantillas(Id idPlantillaSeg, Map<String, String> datosPlantillas) {
        try {
            SEG_Plantilla__c plantillaSeg = new SEG_Plantilla__c(Id = idPlantillaSeg);
            plantillaSeg.SEG_PlantillaCastellanoID__c = datosPlantillas.get('SEG_PlantillaCastellanoID__c');
            plantillaSeg.SEG_PlantillaCastellano__c = datosPlantillas.get('SEG_PlantillaCastellano__c');
            plantillaSeg.SEG_PlantillaCatalanID__c = datosPlantillas.get('SEG_PlantillaCatalanID__c');
            plantillaSeg.SEG_PlantillaCatalan__c = datosPlantillas.get('SEG_PlantillaCatalan__c');
            plantillaSeg.SEG_PlantillaInglesID__c = datosPlantillas.get('SEG_PlantillaInglesID__c');
            plantillaSeg.SEG_PlantillaIngles__c = datosPlantillas.get('SEG_PlantillaIngles__c');
            plantillaSeg.SEG_PlantillaEuskeraID__c = datosPlantillas.get('SEG_PlantillaEuskeraID__c');
            plantillaSeg.SEG_PlantillaEuskera__c = datosPlantillas.get('SEG_PlantillaEuskera__c');
            plantillaSeg.SEG_PlantillaGalegoID__c = datosPlantillas.get('SEG_PlantillaGalegoID__c');
            plantillaSeg.SEG_PlantillaGalego__c = datosPlantillas.get('SEG_PlantillaGalego__c');
            update plantillaSeg;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}