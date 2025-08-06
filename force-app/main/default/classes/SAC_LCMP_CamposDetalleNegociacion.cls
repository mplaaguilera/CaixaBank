public with sharing class SAC_LCMP_CamposDetalleNegociacion {
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'SAC_MaestroAccionesReclamacion__c', 'SAC_MaestroTemas__c', 'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    /*****************************************************************
    * Proposito: Recuperar los campos de la negociación de las pretensiones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US486141     Sergio Martín     10/07/25        Creación
    *****************************************************************/
    /**
	 * @description  Recuperar los campos de la negociación de las pretensiones
	 * @param casoId
	 */
    @AuraEnabled(cacheable=true)
    public static List <Case> getNegociacionesPretension(String casoId) {
        List<Case> pretensionesCaso = new List<Case>();
          
        try{
            pretensionesCaso = [SELECT Id, CaseNumber, SAC_ResultadoNegociacion__c, CC_Importe_Reclamado__c, SAC_DetalleResultadoNegociacion__c, SAC_Importe_Resuelto__c, SAC_Motivoresultadonegociacion__c, SAC_TipoInteresContrato__c, SAC_Observaciones__c, SAC_TipoInteresNegociado__c FROM Case WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_Reclamacion__r.SAC_CasoNegociado__c = true AND SAC_Reclamacion__c =: casoId AND SAC_NegociacionFinalizada__c = true];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return pretensionesCaso;
    }    
}