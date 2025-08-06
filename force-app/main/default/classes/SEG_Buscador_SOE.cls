public with sharing class SEG_Buscador_SOE {
    @AuraEnabled
    public static SEG_WS_Lista_SOE.Lista_SOE getResultadoListaSOE(String nombreAcreditada, String nif, String numeroSOE){
        SEG_WS_Lista_SOE.Lista_SOE resultSOE = new SEG_WS_Lista_SOE.Lista_SOE();
        // llamo al WS de SEG_WS_Lista_SOE

        try {
            resultSOE = SEG_WS_Lista_SOE.obtencionListaSOE(nombreAcreditada, nif, numeroSOE);
            System.debug('entrando');
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
        System.debug('resultSOE ---> ' + resultSOE);
        return resultSOE;
    }
    
    @AuraEnabled
    public static SEG_WS_Contactos_SOE.Contactos_SOE getResultadoContactosSOE(String numSOE, String caseNumber){
        SEG_WS_Contactos_SOE.Contactos_SOE resultContactosSOE = new SEG_WS_Contactos_SOE.Contactos_SOE();
        // llamo al WS de SEG_WS_Contactos_SOE

        try {
            resultContactosSOE = SEG_WS_Contactos_SOE.obtencionListaContactosSOE(numSOE,caseNumber);
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());    }
        System.debug('resultContactosSOE ---> ' + resultContactosSOE);
        return resultContactosSOE;
    }
    
}