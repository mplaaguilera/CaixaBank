public with sharing class SAC_MaestroTemasHelper {
    
    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEMARCA = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_Temas').getRecordTypeId();

    /*
    * @description Valida que el valor del campo SAC_OrdenPrelacion__c es único para cada marca
    */
    public static void validarInsertMarca(List<SAC_MaestroTemas__c> listaMarcas){
    
        List<SAC_MaestroTemas__c> listaMarcasExistentes = [SELECT Id, SAC_OrdenPrelacion__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEMARCA AND SAC_OrdenPrelacion__c != null AND SAC_Activo__c = true];

        if(!listaMarcasExistentes.isEmpty()){

            Set<Decimal> ordenPrelacionMarcas = new Set<Decimal>();
            
            for(SAC_MaestroTemas__c marcaExistente : listaMarcasExistentes){
                ordenPrelacionMarcas.add(marcaExistente.SAC_OrdenPrelacion__c);
            }

            for(SAC_MaestroTemas__c marca : listaMarcas){
                if(marca.SAC_OrdenPrelacion__c != null && marca.SAC_Activo__c && ordenPrelacionMarcas.contains(marca.SAC_OrdenPrelacion__c)){
                    marca.addError('Ya existe otra marca con el mismo orden informado.');
                }
            }
        }   
    }
}