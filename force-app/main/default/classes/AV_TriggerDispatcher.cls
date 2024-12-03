public with sharing abstract class AV_TriggerDispatcher extends CC_TriggerHandlerBase {
    
    public final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));

	public override void mainEntry(CC_TriggerParameters tp) {
        if(String.isBlank(CLASS_NAME)) {
            throw new IllegalArgumentException('El atributo CLASS_NAME debe informarse al instanciar una clase que implementa AV_TriggerDispatcher');
        }

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
            Map<Integer, DispatchedRecord> dispatcheds = new Map<Integer, DispatchedRecord>();
            for(Integer index = 0; index < tp.newList.size(); index++) {
                dispatcheds.put(index, new DispatchedRecord(tp.newList.get(index), false));
            }

            Map<String, List<SObject>> recordsPerHandler = new Map<String, List<SObject>>();
            for (AV_TriggerDispatcherAssociation__mdt dispatcher : handlers.get(CLASS_NAME)) {
                if(!recordsPerHandler.containsKey(dispatcher.AV_TriggerHandler__c)) {
                    recordsPerHandler.put(dispatcher.AV_TriggerHandler__c, new List<SObject>());
                }

                Integer position = 0;
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
                                if(dispatcheds.containsKey(position)) {
                                    recordsPerHandler.get(dispatcher.AV_TriggerHandler__c).add(obj);
                                    dispatcheds.get(position).dispatched = true;
                                }
                            }
                        } else if(obj.get(dispatcher.AV_FilterField__c) == null && String.isBlank(dispatcher.AV_FieldValues__c)) {
                            if(dispatcheds.containsKey(position)) {
                                recordsPerHandler.get(dispatcher.AV_TriggerHandler__c).add(obj);
                                dispatcheds.get(position).dispatched = true;
                            }
                        }
                    }
                    position++;
                }
            }

            for (AV_TriggerDispatcherAssociation__mdt dispatcher : handlers.get(CLASS_NAME)) {
                if(String.isBlank(dispatcher.AV_FieldValues__c)) {
                    for (DispatchedRecord dr : dispatcheds.values()) {
                        if(!dr.dispatched) {
                            recordsPerHandler.get(dispatcher.AV_TriggerHandler__c).add(dr.obj);
                            dr.dispatched = true;
                        }
                    }
                }
            }

            CC_TriggerParameters tpCopy = new CC_TriggerParameters(
                tp.oldList,
                new List<SObject>(tp.newList),
                tp.oldMap,
                tp.newMap,
                Trigger.isBefore,
                Trigger.isAfter,
                Trigger.isDelete,
                Trigger.isInsert,
                Trigger.isUpdate,
                Trigger.isUndelete,
                Trigger.isExecuting
            );

            CBK_Log.debug('Dispatcher: ' + CLASS_NAME);
            for(String className : recordsPerHandler.keySet()) {
                tpCopy.newList = recordsPerHandler.get(className);
                CBK_Log.debug('Records for handler ' + className + ': ' + tpCopy.newList.size());
                ((CC_TriggerHandlerBase)Type.forName(className).newInstance()).mainEntry(tpCopy);
            }
        }
	}

    public class DispatchedRecord {
        public SObject obj;
        public Boolean dispatched;

        public DispatchedRecord(SObject obj, Boolean dispatched) {
            this.obj = obj;
            this.dispatched = dispatched;
        }
    }

}