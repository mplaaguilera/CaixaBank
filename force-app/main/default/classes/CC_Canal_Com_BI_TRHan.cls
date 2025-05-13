public with sharing class CC_Canal_Com_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<CC_Canal_Com__c>)tp.newList, (Map<Id, CC_Canal_Com__c>)tp.newMap);
	}

	private void process(List<CC_Canal_Com__c> listNewObj, Map<Id, CC_Canal_Com__c> mapNewObj) {
        asignarTelefonoCampoIndexado(listNewObj, mapNewObj);
	}

    private void asignarTelefonoCampoIndexado(List<CC_Canal_Com__c> listNewObj, Map<Id, CC_Canal_Com__c> mapNewObj) {
        for (CC_Canal_Com__c canalCom : listNewObj) {
            if (canalCom.CC_Telefono__c != null) {
                canalCom.CC_TelefonoIDX__c = canalCom.CC_Telefono__c;
            }
        }
    }
}