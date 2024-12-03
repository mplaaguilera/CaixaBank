public with sharing class CC_Administracion_Lista_Blanca_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Administracion_Lista_Blanca__c>)tp.newList, (Map<Id, CC_Administracion_Lista_Blanca__c>)tp.newMap);
    }

    private void process(List<CC_Administracion_Lista_Blanca__c> listNewObj, Map<Id, CC_Administracion_Lista_Blanca__c> mapNewObj) {

        //Lógica negocio COPS
        List<CC_Administracion_Lista_Blanca__c> listaAdministracionBlancaCOPS = filtrarRegistrosCOPS(listNewObj);
        if(!listaAdministracionBlancaCOPS.isEmpty()) {
            validarRegistrosCOPS(listaAdministracionBlancaCOPS);
        }

    }

    private void validarRegistrosCOPS(List<CC_Administracion_Lista_Blanca__c> listaAdministracionBlancaCOPS) {
        
        List<CC_Lista_Valores__c> dominiosRegistringidosLista = [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'COPS: dominios correos salientes restringidos' AND CC_Activa__c = true];
        Set<String> dominiosRestringidosSet = new Set<String>();
        for(CC_Lista_Valores__c dominio: dominiosRegistringidosLista) {
            dominiosRestringidosSet.add(dominio.Name);
        }
        for(CC_Administracion_Lista_Blanca__c registroListaAdmin: listaAdministracionBlancaCOPS) {
            if(dominiosRestringidosSet.contains(registroListaAdmin.Name)) {
                registroListaAdmin.addError('El dominio indicado no está permitido para la Lista Blanca del negocio COPS.');
            }
        }
    }

    private List<CC_Administracion_Lista_Blanca__c> filtrarRegistrosCOPS(List<CC_Administracion_Lista_Blanca__c> listNewObj) {
        
        List<CC_Administracion_Lista_Blanca__c> listaAdministracionBlancaCOPS = new List<CC_Administracion_Lista_Blanca__c>();
        
        for(CC_Administracion_Lista_Blanca__c registroListaAdmin: listNewObj) {
            if(registroListaAdmin.CBK_Negocio__c == 'COPS') {
                listaAdministracionBlancaCOPS.add(registroListaAdmin);
            }
        }
        return listaAdministracionBlancaCOPS;
    }
}