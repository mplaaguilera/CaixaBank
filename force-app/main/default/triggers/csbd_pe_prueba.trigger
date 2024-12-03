trigger csbd_pe_prueba on CSBD_MAC_Test__e(after insert) {

    List<CSBD_MAC_Test__e> registrosNew = Trigger.new;
    for (CSBD_MAC_Test__e registroNew : registrosNew) {
        CSBD_WS_AltaOportunidad.altaOportunidadMacEvento(registroNew.CSBD_Campo_Test__c);
    }
}