public with sharing class CC_MCC_Plantilla_Asignar {
    @AuraEnabled
    public static List<SDOC__SDTemplate__c> buscarPlantillasSDOC(String formato, String idioma) {
        List<SDOC__SDTemplate__c> plantillas = new List<SDOC__SDTemplate__c>();
        plantillas = [SELECT Id, Name FROM SDOC__SDTemplate__c WHERE SDOC__Template_Format__c =:formato AND SDOC__Language__c =: idioma AND SDOC__Active__c = TRUE ORDER BY Name];
        return plantillas;
    }
    @AuraEnabled
    public static List<Folder> getCarpetas(String carpetaDeveloperName) {
        List<Folder> carpetas = new List<Folder>();

        Id parentId;
        if (carpetaDeveloperName == '' || carpetaDeveloperName == null) {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = 'CC_Operativas' LIMIT 1].Id;
        }
        else {
            parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;
        }

        for (Folder carpeta : [SELECT Name,DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId]) {
            carpetas.add(carpeta);
        }
        
        return carpetas;
    }
    @AuraEnabled
    public static List<EmailTemplate> getPlantillas(Id mccId, String carpeta) {
        List<EmailTemplate> opcionesPlantilla = new List<EmailTemplate>();
        
        List<String> plantillasRegistradas = new List<String>();
        for (CC_MCC_Plantilla__c plantilla : [SELECT CC_MCC_Plantilla_Name__c FROM CC_MCC_Plantilla__c WHERE CC_MCC__c = :mccId]) {
            plantillasRegistradas.add(plantilla.CC_MCC_Plantilla_Name__c);
        }
        Id carpetaId = [SELECT Id FROM Folder WHERE DeveloperName = :carpeta LIMIT 1].Id;
        List<EmailTemplate> plantillas = [SELECT Name,DeveloperName FROM EmailTemplate WHERE FolderId = :carpetaId AND Name NOT IN :plantillasRegistradas ORDER BY Name ASC];
        for (EmailTemplate plantilla : plantillas) {
            opcionesPlantilla.add(plantilla);
        }
        
        return opcionesPlantilla;
    }
    @AuraEnabled
    public static void guardar(CC_MCC_Plantilla__c plantilla){
        insert plantilla;  
        
        //Buscar MCC Plantilla para después asignarle los ids de la plantilla vigilando de no repetir el mismo id
        Boolean first = true;       
        List<CC_MCC__c> mcc = [SELECT Id, CC_Id_SDOC_Plantilla__c, CC_Id_SDOC_Plantilla2__c, CC_Id_SDOC_Plantilla3__c FROM CC_MCC__c WHERE Id = :plantilla.CC_MCC__c LIMIT 1];
        Set<Id> setIdPlantilla = new Set<Id>();
		            
        List<CC_MCC_Plantilla__c> mccPlantillas = [SELECT CC_MCC_Plantilla_Name__c, CC_Id_SDOC_Plantilla__c FROM CC_MCC_Plantilla__c
        WHERE CC_MCC__c = :plantilla.CC_MCC__c AND CC_Id_SDOC_Plantilla__c != ''];
        
        mcc[0].CC_Id_SDOC_Plantilla__c = '';
        mcc[0].CC_Id_SDOC_Plantilla2__c = '';
        mcc[0].CC_Id_SDOC_Plantilla3__c = '';
                    
        for (CC_MCC_Plantilla__c mccPlantilla : mccPlantillas) {
            if(first==true && !setIdPlantilla.contains(mccPlantilla.CC_Id_SDOC_Plantilla__c)){
                mcc[0].CC_Id_SDOC_Plantilla__c = mccPlantilla.CC_Id_SDOC_Plantilla__c;                
                first=false;
                setIdPlantilla.add(mccPlantilla.CC_Id_SDOC_Plantilla__c);
                
            }else if (first==false && !setIdPlantilla.contains(mccPlantilla.CC_Id_SDOC_Plantilla__c)) {
                String idPlantilla1 = '';
                String idPlantilla2 = '';
                String idPlantilla3 = '';

                if(mcc[0].CC_Id_SDOC_Plantilla__c != null || mcc[0].CC_Id_SDOC_Plantilla__c != ''){
                    idPlantilla1 += ',' + mcc[0].CC_Id_SDOC_Plantilla__c;
                }
                if(mcc[0].CC_Id_SDOC_Plantilla2__c != null || mcc[0].CC_Id_SDOC_Plantilla2__c != ''){
                    idPlantilla2 += ',' + mcc[0].CC_Id_SDOC_Plantilla2__c;
                }  
                if(mcc[0].CC_Id_SDOC_Plantilla3__c != null || mcc[0].CC_Id_SDOC_Plantilla3__c != ''){
                    idPlantilla3 += ',' + mcc[0].CC_Id_SDOC_Plantilla3__c;
                }  

                if(idPlantilla1.length() < 234){
                    mcc[0].CC_Id_SDOC_Plantilla__c += ',' + mccPlantilla.CC_Id_SDOC_Plantilla__c;
                }else if(idPlantilla1.length() > 234 && idPlantilla2.length() < 234){
                    mcc[0].CC_Id_SDOC_Plantilla2__c += ',' + mccPlantilla.CC_Id_SDOC_Plantilla__c;
                }else if(idPlantilla2.length() > 234 && idPlantilla3.length() < 234){
                    mcc[0].CC_Id_SDOC_Plantilla3__c += ',' + mccPlantilla.CC_Id_SDOC_Plantilla__c;
                }
                setIdPlantilla.add(mccPlantilla.CC_Id_SDOC_Plantilla__c);
            } 
        }
        
        update mcc;            

    }
    
    @AuraEnabled
    public static String getNegocio(Id recordId) {
        String tipoCliente = [SELECT CC_Tipo_Cliente__c FROM CC_MCC__c WHERE Id = :recordId].CC_Tipo_Cliente__c;
        if (tipoCliente.contains('COPS')) {
            return 'OS';
        }
        else if (tipoCliente.contains('CAM')){
            return 'AM';
        }
        else if (tipoCliente.contains('HDT')){
            return 'HDT';
        }
        else if (tipoCliente.equalsIgnoreCase('CSI Bankia')) {
            return 'CSI_Bankia';
        } else {
            return '';
        }
    }
}