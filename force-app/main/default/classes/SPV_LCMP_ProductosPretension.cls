/*****************************************************************
 * Name: SPV_LCMP_ProductosPretension
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente spv_ProductosPretension
 * Clase test: SPV_LCMP_ProductosPretension_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US997650      Sergio Martín    26/08/24        Creación
*****************************************************************/

public with sharing class SPV_LCMP_ProductosPretension {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEREC = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRET =mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    

    /**************************************************************************
     * Proposito: Método para recuperar los productos de pretensiones de la reclamación o pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US997650      Sergio Martín    26/08/24        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ProductosPretension getProductosPretensiones(String recordId) {
        List<SAC_ProductCase__c> productos = new List<SAC_ProductCase__c>();
        Case caso = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Case WHERE Id = :recordId LIMIT 1];

        if(caso.RecordTypeId == RECTYPEREC){
            productos = [SELECT Id, SAC_Pretension__c, SAC_Pretension__r.CaseNumber, SAC_Tipo__c, SAC_Descripcion__c, N_Contrato__c, SAC_TaeMaximoAplicado__c, SAC_TaeInicialContrato__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c
                         FROM SAC_ProductCase__c WHERE SAC_Pretension__r.SAC_Reclamacion__c = :recordId];

        }else if(caso.RecordTypeId == RECTYPEPRET){
            productos = [SELECT Id, SAC_Tipo__c, SAC_Descripcion__c, N_Contrato__c, SAC_TaeMaximoAplicado__c, SAC_TaeInicialContrato__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c
                        FROM SAC_ProductCase__c WHERE SAC_Pretension__c = :recordId];      
        }

        if(!productos.isEmpty()){
            ProductosPretension  prodPret = new ProductosPretension(caso.RecordType.DeveloperName, productos);
            return  prodPret;
        }else{
            ProductosPretension  prodPret = new ProductosPretension(caso.RecordType.DeveloperName, productos);
            return  prodPret;
        }
    }

    /**************************************************************************
     * Proposito: Clase wrapper para los productos de pretensiones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US997650      Sergio Martín    26/08/24        Creación
    **************************************************************************/  

    public class ProductosPretension{
        @AuraEnabled public String caso {get; set;}
        @AuraEnabled public List<SAC_ProductCase__c> listaProductos {get; set;}

        public ProductosPretension(String casoC, List<SAC_ProductCase__c> listaProductosC){
            caso = casoC;
            listaProductos = listaProductosC;
        }
    }
}