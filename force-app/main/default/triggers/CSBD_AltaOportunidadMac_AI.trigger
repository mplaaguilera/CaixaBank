trigger CSBD_AltaOportunidadMac_AI on CSBD_AltaOportunidadMac__e (after insert) {

    if (!CSBD_Bypass__c.getOrgDefaults().CSBD_TriggerPlatformEventMac__c) {
        for (CSBD_AltaOportunidadMac__e evento : Trigger.new) {
            CSBD_WS_AltaOportunidad.altaOportunidadMacEvento(evento.CSBD_CaseId__c);
        }
    }
}