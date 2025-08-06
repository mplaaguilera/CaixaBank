public with sharing class CC_Derecho_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Derecho__c>)tp.newList);
	}

	private void process(List<CC_Derecho__c> derechos) {
        System.debug(':::derechos: ' + derechos);
		List<Id> idsDerechos = new List<Id>();
        for (CC_Derecho__c derecho : derechos) {
            idsDerechos.add(derecho.Id);
        }
        //Procesar los derechos
        if (!idsDerechos.isEmpty()) {
            System.debug(':::idsDerechos: ' + idsDerechos);
            CC_GDPR.altaSolicitud(idsDerechos);
        }
	}

}