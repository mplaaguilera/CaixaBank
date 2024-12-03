public with sharing class CC_Grupo_Colaborador_Plantilla {
    @AuraEnabled
    public static List<EmailTemplate> getPlantillas(Id grupoId, String carpetaOperativa) {
        List<EmailTemplate> opcionesPlantilla = new List<EmailTemplate>();
        String carpeta = carpetaOperativa + '_es';

        Id parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpeta LIMIT 1].Id;
        
        List<String> plantillasRegistradas = new List<String>();
        for (CC_Grupo_Colaborador_Plantilla__c plantilla : [SELECT CC_Plantilla_Name__c FROM CC_Grupo_Colaborador_Plantilla__c WHERE CC_Grupo_Colaborador__c = :grupoId]) {
            plantillasRegistradas.add(plantilla.CC_Plantilla_Name__c);
        }

        List<EmailTemplate> plantillas = [SELECT Name,DeveloperName FROM EmailTemplate WHERE FolderId = :parentId AND Name NOT IN :plantillasRegistradas ORDER BY Name ASC];
        for (EmailTemplate plantilla : plantillas) {
            opcionesPlantilla.add(plantilla);
        }
        
        return opcionesPlantilla;
    }
    @AuraEnabled
    public static List<Folder> getOperativas(String grupo) {        
        List<CC_Grupo_Colaborador__c> grupoColaborador = [SELECT OS_Negocio__c FROM CC_Grupo_Colaborador__c WHERE Id = :grupo];

        Id parentId;
        String carpetaNegocio = '';
        List<Folder> carpetas = new List<Folder>();

        if (grupoColaborador.size() > 0 && grupoColaborador[0].OS_Negocio__c == 'COPS') {
            carpetaNegocio = 'OS_Operativas';
            
        }else if (grupoColaborador.size() > 0 && grupoColaborador[0].OS_Negocio__c == 'CSI_Bankia') {
            carpetaNegocio = 'CC_Operativas_CSI_Bankia';
            
        }else if (grupoColaborador.size() > 0 && grupoColaborador[0].OS_Negocio__c == 'CAM') {
            carpetaNegocio = 'AM_Operativas';
            
        }else if (grupoColaborador.size() > 0 && grupoColaborador[0].OS_Negocio__c == 'HDT') {
            carpetaNegocio = 'HDT_Operativas';
        
        }
        else if (grupoColaborador.size() > 0 && grupoColaborador[0].OS_Negocio__c == 'SACH') { 
            carpetaNegocio = 'SACH_Operativas';  
        }       
        else if (grupoColaborador.size() > 0 && grupoColaborador[0].OS_Negocio__c == 'GRR') { 
           carpetaNegocio = 'GRR_Operativas';  
        }     
        else {
            carpetaNegocio = 'CC_Operativas';            
        }
        
        List<Folder> listadoCarpetas = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaNegocio LIMIT 1];
        parentId = listadoCarpetas[0].Id;
        carpetas = [SELECT Name,DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId AND (DeveloperName like '%Trasladar%' OR DeveloperName like '%Remitir%')];
        
        return carpetas;
    }
    @AuraEnabled
    public static void guardar(CC_Grupo_Colaborador_Plantilla__c plantilla){
        insert plantilla;        
    }
}