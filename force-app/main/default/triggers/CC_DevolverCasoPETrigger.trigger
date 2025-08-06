trigger CC_DevolverCasoPETrigger on CC_DevolverCaso__e (after insert) {

    if(!CC_ByPass__c.getOrgDefaults().CC_TriggerPlatformEventMAC__c) {    
        CC_Operativa_Oficina_Controller.gestionarDevolucionAContact(Trigger.new);
    }   

}