public with sharing class SEG_Contact_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        if((FeatureManagement.checkPermission('SEG_Operativo'))){

        List<Contact> newListSegmentos = new List<Contact>();
        Id recordTypeContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        for (Contact contacto : (List<Contact>)tp.newList) {
			if(contacto.RecordTypeId == recordTypeContact){
				newListSegmentos.add(contacto);
			}
		}

		if(!newListSegmentos.isEmpty()){
			process(newListSegmentos);
		}
    }
    }
    
    private static void process(List<Contact> listNewObj) { 

        SEG_ContactTriggerHelper.validarDuplicidad(listNewObj);
    }
}