public with sharing class CC_Agrupador_Numero_Casos {

    @InvocableMethod
    public static void CC_Agrupador_Numero_Casos(List<Id> idsAgrupador) {

        Map<Id, List<Case>> mapaCasosAgrupados = new Map<Id, List<Case>>();
        List<CC_Agrupador__c> agrupadores = new List<CC_Agrupador__c>();
        List<Case> lstCasos = [SELECT Id, CC_Agrupador_Id__c FROM Case WHERE CC_Agrupador_Id__c IN :idsAgrupador WITH SECURITY_ENFORCED ORDER BY CC_Agrupador_Id__c ];
        if (!lstCasos.isEmpty()) {
            for (Case casoAgrupado : lstCasos) {
                if(mapaCasosAgrupados.containsKey(casoAgrupado.CC_Agrupador_Id__c)) {
                    List<Case> lstCasosAgrupados = mapaCasosAgrupados.get(casoAgrupado.CC_Agrupador_Id__c);
                    lstCasosAgrupados.add(casoAgrupado);
                    mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c,lstCasosAgrupados);
                } else {
                    mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c, new List<Case> {casoAgrupado});
                }
            }
            for (Id idAgrupador : idsAgrupador) {
                if(mapaCasosAgrupados.containsKey(idAgrupador)){
                    CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);
                    agrupador.CC_Numero_Casos__c = mapaCasosAgrupados.get(idAgrupador).size();
                    agrupadores.add(agrupador);
                }
            }
        }

        if (!agrupadores.isEmpty() && Schema.sObjectType.CC_Agrupador__c.fields.CC_Numero_Casos__c.isUpdateable()) {
            Database.update(agrupadores);
        }
    }
}