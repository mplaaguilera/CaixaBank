/*****************************************************************
 * Name: SAC_LCMP_CargarCaractRepresentante
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_CargarCaracteristicasRepresentante
 * Clase test: SAC_LCMP_CargarCaractRepresentante_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US1046168      Raúl Santos         24/10/2024        Creación
*****************************************************************/
public with sharing class SAC_LCMP_CargarCaractRepresentante {

    private static Set<String> objetos = new Set<String>{'CC_Caracteristica__c', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RTREPRESENTANTECARACTERISTICA = mapRTsObjects.get('CC_Caracteristica__c').get('SAC_CaracteristicaRepresentante').getRecordTypeId();
    private final static Id RECTYPEDESPACHOS_MAESTROTEMAS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_DespachoRepresentante').getRecordTypeId();


    @AuraEnabled(cacheable=true)
    public static List<CC_Caracteristica_Detalle__c> getAsignacionesByCaractId(String recordId) {
    
        List<CC_Caracteristica_Detalle__c> listaAsignaciones = [SELECT Id, SAC_Identificador__c FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.RecordTypeId = :RTREPRESENTANTECARACTERISTICA AND CC_Caracteristica__c = :recordId ORDER BY SAC_Identificador__c DESC];

        return listaAsignaciones;
    }

    @AuraEnabled
    public static void eliminarAsignacion(String asignacionId) {
        List<CC_Caracteristica_Detalle__c> asignacionList = [SELECT Id FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.RecordTypeId = :RTREPRESENTANTECARACTERISTICA AND Id = :asignacionId LIMIT 1];

        SAC_DatabaseDML.deleteListDML(asignacionList, true);
    }

    @AuraEnabled
    public static void actualizarAsignacion(String asignacionId, String nuevoValor) {
        List<CC_Caracteristica_Detalle__c> asignacionList = [SELECT Id FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.RecordTypeId = :RTREPRESENTANTECARACTERISTICA AND Id = :asignacionId LIMIT 1];

        if(!asignacionList.isEmpty()){
            asignacionList[0].SAC_Identificador__c = nuevoValor;
            SAC_DatabaseDML.updateListDML(asignacionList, true);
        }        
    }

    @AuraEnabled
    public static void crearAsignacion(String recordId, String identificadorAsignacion) {

        CC_Caracteristica_Detalle__c caracteristica = new CC_Caracteristica_Detalle__c();
        caracteristica.CC_Caracteristica__c = recordId;
        caracteristica.SAC_Identificador__c = identificadorAsignacion;

        SAC_DatabaseDML.insertDML(caracteristica, true);  
    }

    //Los valores que se van a mostrar a modo de picklist serán aquellos nombres de maestro de temas con el RT correspondiente
    @AuraEnabled(cacheable=true)
    public static List<String> obtenerValoresDespachoRepresentante(){

        List<SAC_MaestroTemas__c> listaMaestroTemas = new List<SAC_MaestroTemas__c>();
        List<String> listaNombresDespachos = new List<String>();

        listaMaestroTemas = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEDESPACHOS_MAESTROTEMAS AND SAC_Activo__c = true ORDER BY Name ASC];
        
        if(!listaMaestroTemas.isEmpty()){
            for(SAC_MaestroTemas__c despacho : listaMaestroTemas){
                listaNombresDespachos.add(despacho.Name);
            }
            return listaNombresDespachos;
        }else{
            return new List<String>();
        }

    }
}