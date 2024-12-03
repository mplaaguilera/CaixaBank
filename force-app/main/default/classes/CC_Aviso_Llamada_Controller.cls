public with sharing class CC_Aviso_Llamada_Controller {
    @AuraEnabled
    public static Boolean verificarSiTieneCasos(String idAccount){
        //Recupero el periodo de tiempo establecido el la lista de valores
        List<CC_Lista_Valores__c> periodoDeTiempoVariable = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE name = 'CC Horas Fraude' LIMIT 1]; 
        DateTime  dt = System.now();
        DateTime fechaParaQuery;
        if (!periodoDeTiempoVariable.isEmpty()) {
            fechaParaQuery = dt.addMinutes(-(Integer.valueOf(periodoDeTiempoVariable[0].CC_Valor__c)* 60));
        }
        //Comprobamos que el campo idAccount no este vacio
        if (String.isNotBlank(idAccount)) {
            //Me traigo los casos de esa cuenta y que este dentro del rango horario
            List<Case> listaCasos = [SELECT Id, CC_MCC_Motivo__r.CC_Susceptible_de_Fraude__c, CC_MCC_Tematica__r.CC_Susceptible_de_Fraude__c, CC_MCC_ProdServ__r.CC_Susceptible_de_Fraude__c FROM Case WHERE AccountId = :idAccount AND CreatedDate >= :fechaParaQuery];
            //Recorro los casos y verifico si alguno tiene ese check marcado 
            if (!listaCasos.isEmpty()) {
                for (Case caso : listaCasos) {
                    if (caso.CC_MCC_Motivo__r.CC_Susceptible_de_Fraude__c || caso.CC_MCC_Tematica__r.CC_Susceptible_de_Fraude__c|| caso.CC_MCC_ProdServ__r.CC_Susceptible_de_Fraude__c ) {
                        return true;
                    }
                }   
            }
        }
        return false;
    }
}