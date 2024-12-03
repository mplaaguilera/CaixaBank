public with sharing class OS_Buzon_Salida {

    @InvocableMethod
    public static void actualizarBuzonSalida(List<Id> idCasos) {

        //Se prepara mapa con la relación entre los nombres y las direcciones de los buzones
        Map<String, String> mapaBuzones = new Map<String, String>();
        for (OrgWideEmailAddress buzon : [SELECT DisplayName, Address FROM OrgWideEmailAddress]) {
            mapaBuzones.put(buzon.DisplayName, buzon.Address);
        }

        //Se recuperan las temáticas de los casos
        List<Case> casos = [SELECT CC_MCC_Tematica__c FROM Case WHERE Id IN :idCasos];
        List<Id> idTematicas = CC_MetodosUtiles.listaCampo(casos, 'CC_MCC_Tematica__c');

        //Para cada caso, el buzón de salida es la dirección del buzón que indica su temática
        Map<Id, CC_MCC__c> tematicas = new Map<Id, CC_MCC__c>([SELECT OS_Buzon_Salida__c FROM CC_MCC__c WHERE Id IN :idTematicas]);

        for (Case caso : casos) {
            CC_MCC__c tematica = tematicas.get(caso.CC_MCC_Tematica__c);
            if (tematica != null) {
                mapaBuzones.get(tematica.OS_Buzon_Salida__c);


                caso.CC_Buzon_Salida__c = mapaBuzones.get(tematica.OS_Buzon_Salida__c);
            }
        }
        update casos;
    }
}