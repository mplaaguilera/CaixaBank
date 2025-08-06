public without sharing class CC_CaseTriggerHelperNoSharing {
    public static void creacionCasoAI(String jsonCasos) {
        List<Case> lstCasos = (List<Case>)JSON.deserialize(jsonCasos, List<Case>.class);
        List<Case> lstCasosUpdt = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.CC_Admin__c) {
                caso.CC_Admin__c = false;
                lstCasosUpdt.add(caso);
            }
        }

        if (!lstCasosUpdt.isEmpty()) {
            update lstCasosUpdt;
        }
    }

    public static void calcularNumAgrupadores(List<Case> lstCasesCC, Map<Id, Case> mapOldObj) {

        List<Id> lstIdsAgrupador = new List<Id>();
        Map<Id, List<Case>> mapaCasosAgrupados = new Map<Id, List<Case>>();
        List<CC_Agrupador__c> agrupadores = new List<CC_Agrupador__c>();


        for(Case caso : lstCasesCC){
            if(caso.CC_Agrupador_Id__c != mapOldObj.get(caso.Id).CC_Agrupador_Id__c){
              if(caso.CC_Agrupador_Id__c != null){
                    lstIdsAgrupador.add(caso.CC_Agrupador_Id__c);
                }
                if(mapOldObj.get(caso.Id).CC_Agrupador_Id__c != null){
                    lstIdsAgrupador.add(mapOldObj.get(caso.Id).CC_Agrupador_Id__c);
                }
            }
        }

        if(!lstIdsAgrupador.isEmpty()){
            List<Case> lstCasos = [SELECT Id, CC_Agrupador_Id__c FROM Case WHERE CC_Agrupador_Id__c IN :lstIdsAgrupador ORDER BY CC_Agrupador_Id__c ];
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
            }
            for (Id idAgrupador : lstIdsAgrupador) {
                CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);
                if(mapaCasosAgrupados.containsKey(idAgrupador)){
                    agrupador.CC_Numero_Casos__c = mapaCasosAgrupados.get(idAgrupador).size();
                }else{
                    agrupador.CC_Numero_Casos__c = 0;
                }
                agrupadores.add(agrupador);
            }
            if (!agrupadores.isEmpty()) {
                String jsonAgrupadores = JSON.serialize(agrupadores);
                actualizarAgrupador(jsonAgrupadores);
            }
        }
    }

    @future
	public static void actualizarAgrupador(String jsonString){

		List<CC_Agrupador__c> lstAgrupador = (List<CC_Agrupador__c>)Json.deserialize(jsonString,List<CC_Agrupador__c>.class);
        Database.update(lstAgrupador);
    }




}