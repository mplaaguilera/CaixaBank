public with sharing class SPV_LCMP_PaginaDetallesPretension {
    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECORDTYPEMOTIVO = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_MotivoAllanamientoEscalado').getRecordTypeId();
    private static final Id RECORDTYPEANALISIS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_AnalisisAllanamiento').getRecordTypeId();


    /*****************************************************************
    * Proposito: Updatear los objetos que vienen de la página de detalles
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0            US1126342     Sergio Martín     05/05/25        Creación
    *****************************************************************/
    /**
	 * @description    Updatear los objetos que vienen de la página de detalles
	 * @param recordsToUpdate
	 */
    @AuraEnabled
    public static void updateRecordsForm(List<SObject> recordsToUpdate) {
        if (recordsToUpdate == null || recordsToUpdate.isEmpty()) {
            throw new AuraHandledException('No se recibieron registros para actualizar.');
        }

        try {
            SPV_DatabaseDML.updateListDML(recordsToUpdate, false);
        } catch (DmlException e) {
            throw new AuraHandledException('Error al actualizar los registros: ' + e.getMessage());
        }
    }

    /***********************************************************************************
    * Proposito: Clase wrapper para recoger los valores de las picklist parametrizables
    * ***************************************************************
    * Historial
    * -------
    * VERSION         USER_STORY       AUTHOR           DATE         Description
    * 1.0             US1208202     Sergio Martín    28/04/22        Creación
    ***********************************************************************************/
    public class PicklistWrapper{

        @AuraEnabled public List<String> valoresMotivo{get; set;}
        @AuraEnabled public List<String> valoresAnalisis{get; set;}
        
        public PicklistWrapper(List<String> mivaloresMotivo, List<String> mivaloresAnalisis){
            this.valoresMotivo = mivaloresMotivo;
            this.valoresAnalisis = mivaloresAnalisis;
        }
    }


    /***********************************************************************************
    * Proposito: Clase wrapper para recoger los valores de las picklist parametrizables
    * ***************************************************************
    * Historial
    * -------
    * VERSION         USER_STORY       AUTHOR          DATE         Description
    * 1.0             US1208202     Sergio Martín    28/04/22        Creación
    ***********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static PicklistWrapper obtenerValoresPicklist(){
        List<String> listValoresAnalisis = new List<String>();
        List<String> listValoresMotivo = new List<String>();
        List<SAC_MaestroTemas__c> listValoresPicklist = [SELECT Name, RecordTypeId FROM SAC_MaestroTemas__c WHERE (RecordTypeId =: RECORDTYPEANALISIS OR RecordTypeId =: RECORDTYPEMOTIVO) AND SAC_Activo__c = true ORDER BY Name ASC];
        for(SAC_MaestroTemas__c valor : listValoresPicklist) {
            if(valor.RecordTypeId == RECORDTYPEANALISIS) {
                listValoresAnalisis.add(valor.name);
            } else if(valor.RecordTypeId == RECORDTYPEMOTIVO) {
                listValoresMotivo.add(valor.name);
            }
        }
        PicklistWrapper valoresPicklist = new PicklistWrapper(listValoresMotivo, listValoresAnalisis);
        return valoresPicklist;    
    }


    /***********************************************************************************
    * Proposito: Clase para updatear el case extension de la pretension
    * *********************************************************************************
    * Historial
    * -------
    * VERSION         USER_STORY       AUTHOR          DATE         Description
    * 1.0             US1208202     Sergio Martín    28/04/22        Creación
    ***********************************************************************************/
    @AuraEnabled
    public static void updatearCaseExtension(String id, String motivoAllanamiento, String motivoDesistimiento, String analisisAllanamiento, String analisisDesistimiento){
        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
        caseExtension.Id = id;
        if(String.isNotBlank(motivoAllanamiento)) { caseExtension.SPV_MotivoAllanamiento__c = motivoAllanamiento; }
        if(String.isNotBlank(motivoDesistimiento)) { caseExtension.SPV_MotivoDesistimiento__c = motivoDesistimiento; }
        if(String.isNotBlank(analisisAllanamiento)) { caseExtension.SPV_AnalisisAllanamiento__c = analisisAllanamiento; }
        if(String.isNotBlank(analisisDesistimiento)) { caseExtension.SPV_AnalisisDesistimiento__c = analisisDesistimiento; }
        SPV_DatabaseDML.updateDML(caseExtension, false);
    }

}