/*****************************************************************
 * Name: SPV_LCMP_RecuperarProductosContratos
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente spv_RecuperarProductosContratos
 * Clase test: SPV_LCMP_RecuperarProductosContratos_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US997650      Sergio Martín    28/08/24        Creación
*****************************************************************/
public with sharing class SPV_LCMP_RecuperarProductosContratos {
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEREC = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRET =mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEREESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Reescalado').getRecordTypeId();
    

    /**************************************************************************
     * Proposito: Método para recuperar los productos de pretensiones 
     *              de la reclamación asociada en el escalado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US997650      Sergio Martín    28/08/24        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SAC_ProductCase__c> getProductosContratosReclamacion(String recordId) {
        List<SAC_ProductCase__c> productos = new List<SAC_ProductCase__c>();
        SAC_Interaccion__c escalado = [SELECT Id, SAC_CasoEscalado__c, RecordType.DeveloperName FROM SAC_Interaccion__c WHERE (RecordTypeId =: RECTYPEESCALADO OR RecordTypeId =: RECTYPEREESCALADO) AND Id =:recordId LIMIT 1];

        productos = [SELECT Id, SAC_Pretension__c, SAC_Pretension__r.CaseNumber, SAC_Tipo__c, SAC_Descripcion__c, N_Contrato__c, SAC_TaeMaximoAplicado__c, SAC_TaeInicialContrato__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c
                        FROM SAC_ProductCase__c WHERE SAC_Pretension__r.SAC_Reclamacion__c = :escalado.SAC_CasoEscalado__c];

        return productos;
    }
}