public with sharing class CC_Aviso_Coordinador_FAX {	
    @InvocableMethod
    public static void publicarToast(List<Case> casos) {      
        
        List<CC_Aviso_Coordinador_Cases_Agrupador__e> avisosCoordinador = new List<CC_Aviso_Coordinador_Cases_Agrupador__e>();
		String tipo = 'warning';
        String mensaje = 'Ha llegado un nuevo caso a la cola Fax (caso NUMERO_CASO)';
        
        for (Case caso : casos) {
            mensaje = mensaje.replace('NUMERO_CASO', caso.CaseNumber);
            avisosCoordinador.add(new CC_Aviso_Coordinador_Cases_Agrupador__e(Mensaje__c = mensaje,  Tipo__c = tipo));
        }
		
        if (!avisosCoordinador.isEmpty()) {
        	EventBus.publish(avisosCoordinador);
        }
    }
}