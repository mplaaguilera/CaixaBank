public with sharing class SEG_Buscador_OSN {

    @AuraEnabled
    public static SEG_WS_Lista_OSN.Lista_OSN getResultadoListaOSN(String estadoOSN, String numOSN, String numSOE, String numperso, String caseNumber){
        SEG_WS_Lista_OSN.Lista_OSN resultOSN = new SEG_WS_Lista_OSN.Lista_OSN();
        // llamo al WS de SEG_WS_Lista_OSN

        try {
            resultOSN = SEG_WS_Lista_OSN.obtencionListaOSN(estadoOSN, numOSN, numSOE, numperso, caseNumber);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resultOSN;
    }

    @AuraEnabled
    public static SEG_WS_Contactos_OSN.Contactos_OSN getResultadoContactosOSN(String numOSN, String caseNumber){
        SEG_WS_Contactos_OSN.Contactos_OSN resultContactosOSN = new SEG_WS_Contactos_OSN.Contactos_OSN();
        // llamo al WS de SEG_WS_Contactos_OSN

        try {
            resultContactosOSN = SEG_WS_Contactos_OSN.obtencionListaContactosOSN(numOSN,caseNumber);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resultContactosOSN;
    }

    @AuraEnabled
    public static List<Account> getNumperso(String valorBusqueda){

        List<Account> lstCuentas = new List<Account>();

        if (!String.isBlank(valorBusqueda)) {
            List<List<SObject>> searchList = [FIND :valorBusqueda IN ALL FIELDS 
            RETURNING 
            Account (Name, AV_NumPerso__c, CC_Numero_Documento__c, SEG_Oficina_Gestora_Segmentos__c, SEG_Oficina_Gestora_Segmentos__r.Name, AV_OficinaPrincipal__c, AV_OficinaPrincipal__r.Name WHERE RecordType.DeveloperName IN ('CC_Cliente', 'CC_ClienteSEG', 'CC_CentroCaixaBank') AND AV_NumPerso__c != null)
            LIMIT :5];

            if (!searchList.isEmpty() && !searchList[0].isEmpty()) {
                for (List<SObject> lstObj : searchList) {
                    for (SObject objetoSearch : lstObj) {
                        Account cuenta = (Account)objetoSearch;
                        if(!String.IsBlank(cuenta.SEG_Oficina_Gestora_Segmentos__c)){ cuenta.SEG_NotaCentroPlantillasCAT__c = cuenta.SEG_Oficina_Gestora_Segmentos__r.Name; }
                        if(!String.IsBlank(cuenta.AV_OficinaPrincipal__c)){ cuenta.SEG_NotaCentroPlantillasEN__c = cuenta.AV_OficinaPrincipal__r.Name; }
                        lstCuentas.add(cuenta);
                    }
                }
            }
        }

        return lstCuentas;

    }
}