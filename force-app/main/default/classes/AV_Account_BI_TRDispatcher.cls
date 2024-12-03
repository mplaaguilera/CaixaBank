public with sharing class AV_Account_BI_TRDispatcher extends AV_TriggerDispatcher {

    /*private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    
	public override void mainEntry(CC_TriggerParameters tp) {
        List<AV_TriggerDispatcherAssociation__mdt> dispatcherSettings = AV_TriggerDispatcherAssociation__mdt.getAll().values();
        Map<String, List<AV_TriggerDispatcherAssociation__mdt>> handlers = new Map<String, List<AV_TriggerDispatcherAssociation__mdt>>();
        
        for (AV_TriggerDispatcherAssociation__mdt dispatcher : dispatcherSettings) {
            if(String.isNotBlank(dispatcher.AV_Dispatcher__c)) {
                if(!handlers.containsKey(dispatcher.AV_Dispatcher__c)) {
                    handlers.put(dispatcher.AV_Dispatcher__c, new List<AV_TriggerDispatcherAssociation__mdt>{dispatcher});
                } else {
                    handlers.get(dispatcher.AV_Dispatcher__c).add(dispatcher);
                }
            }
        }

        if(handlers.containsKey(CLASS_NAME)) {
            Map<String, List<SObject>> recordsPerHandler = new Map<String, List<SObject>>();
            for (AV_TriggerDispatcherAssociation__mdt dispatcher : handlers.get(CLASS_NAME)) {
                if(!recordsPerHandler.containsKey(dispatcher.AV_TriggerHandler__c)) {
                    recordsPerHandler.put(dispatcher.AV_TriggerHandler__c, new List<SObject>());
                }

                for (SObject obj : tp.newList) {
                    if(String.isNotBlank(dispatcher.AV_FilterField__c)) {
                        if(obj.get(dispatcher.AV_FilterField__c) != null && String.isNotBlank(dispatcher.AV_FieldValues__c)) {
                            boolean add = false;
                            for(String value : dispatcher.AV_FieldValues__c.split(',')) {
                                if(String.valueOf(obj.get(dispatcher.AV_FilterField__c)).contains(value)) {
                                    add = true;
                                }
                            }
                            if(add) {
                                recordsPerHandler.get(dispatcher.AV_TriggerHandler__c).add(obj);
                            }
                        } else if(obj.get(dispatcher.AV_FilterField__c) == null && String.isBlank(dispatcher.AV_FieldValues__c)) {
                            recordsPerHandler.get(dispatcher.AV_TriggerHandler__c).add(obj);
                        }
                    }
                }
            }

            for(String className : recordsPerHandler.keySet()) {
                tp.newList = recordsPerHandler.get(className);
                ((CC_TriggerHandlerBase)Type.forName(className).newInstance()).mainEntry(tp);
            }
        }
	}*/

}