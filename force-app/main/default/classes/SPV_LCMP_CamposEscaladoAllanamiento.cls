public with sharing class SPV_LCMP_CamposEscaladoAllanamiento {
    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECORDTYPEMOTIVO = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_MotivoAllanamientoEscalado').getRecordTypeId();
    private static final Id RECORDTYPEANALISIS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_AnalisisAllanamiento').getRecordTypeId();

    /***********************************************************************************
    * Proposito: Clase wrapper para recoger los valores de las picklist parametrizables
    * ***************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US938802     Sergio Martín    11/06/22        Creación
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
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US938802     Sergio Martín    11/06/22        Creación
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
}