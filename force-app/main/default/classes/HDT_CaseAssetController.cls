public with sharing class HDT_CaseAssetController {
    @AuraEnabled(cacheable=true)
    public static Boolean isAssetActive(Id caseId) {

        // Conjunto para almacenar los AssetIds relacionados con los casos que se van a modificar
        Set<Id> assetIds = new Set<Id>();
        Boolean esInactivo = false;

        // Obtener el caso según el ID proporcionado
        List<Case> lstCasos = [SELECT Id, AssetId FROM case WHERE Id = :caseId LIMIT 1];

        if (!lstCasos.isEmpty()) {
            if (lstCasos[0].AssetId != null) {
                assetIds.add(lstCasos[0].AssetId);
            }
        }

        // Si hay activos relacionados, hacemos una consulta a la base de datos
        if (!assetIds.isEmpty()) {
            // Obtenemos los activos correspondientes con su campo Inactivo__c
            Map<Id, Asset> assetMap = new Map<Id, Asset>([
                SELECT Id, CC_Inactivo__c 
                FROM Asset 
                WHERE Id IN :assetIds
            ]);

            // Recorremos de nuevo los casos actualizados
            for (Case c : lstCasos) {
                if (c.AssetId != null) {
                    Asset relatedAsset = assetMap.get(c.AssetId);

                    // Si el activo está inactivo, lanzamos un error
                    if (relatedAsset != null && relatedAsset.CC_Inactivo__c == true) {
                        esInactivo = true;
                    }else{
                        esInactivo =  false;                        
                    }
                }
            }
        }
        return esInactivo; 
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isSegundoAssetActive(Id caseId) {

         // Conjunto para almacenar los AssetIds relacionados con los casos que se van a modificar
         Set<Id> assetIds = new Set<Id>();
         Boolean esInactivo = false;
 
         // Obtener el caso según el ID proporcionado
         List<Case> lstCasos = [SELECT Id, HDT_Activo_Secundario__c FROM case WHERE Id = :caseId LIMIT 1];
 
         if (!lstCasos.isEmpty()) {
             if (lstCasos[0].HDT_Activo_Secundario__c != null) {
                 assetIds.add(lstCasos[0].HDT_Activo_Secundario__c);
             }
         }
 
         // Si hay activos relacionados, hacemos una consulta a la base de datos
         if (!assetIds.isEmpty()) {
             // Obtenemos los activos correspondientes con su campo Inactivo__c
             Map<Id, Asset> assetMap = new Map<Id, Asset>([
                 SELECT Id, CC_Inactivo__c 
                 FROM Asset 
                 WHERE Id IN :assetIds
             ]);
 
             // Recorremos de nuevo los casos actualizados
             for (Case c : lstCasos) {
                 if (c.HDT_Activo_Secundario__c != null) {
                     Asset relatedAsset = assetMap.get(c.HDT_Activo_Secundario__c);
 
                     // Si el activo está inactivo, lanzamos un error
                     if (relatedAsset != null && relatedAsset.CC_Inactivo__c == true) {
                         esInactivo = true;
                     }else{
                         esInactivo =  false;                        
                     }
                 }
             }
         }
         return esInactivo; 
        }

        @AuraEnabled
        public static CC_Lista_Valores__c mensajeValidacionPreguntas(String validacion) {
            CC_Lista_Valores__c valorValidacion = null;
            if(!String.isEmpty(validacion)){
                valorValidacion = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT_Mensajes_Parametrizables_Empleados' AND CC_Valor2__c = :validacion LIMIT 1];
            }
            return valorValidacion;
        }

        @AuraEnabled
        public static Boolean validaCambioActivoSecundario(Id caseId) {
            Boolean existeCambio = false;

            // Obtener el caso según el ID proporcionado
            List<Case> lstCasos = [SELECT Id, AssetId, HDT_Activo_Secundario__c FROM case WHERE Id = :caseId LIMIT 1];
            if (!lstCasos.isEmpty()) {
                if (lstCasos[0].HDT_Activo_Secundario__c != null) {
                    existeCambio = true;
                }else {
                    existeCambio = false;
                }
            }

            return existeCambio;
        }

}