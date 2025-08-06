trigger SAC_Interaccion on SAC_Interaccion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CC_TriggerFactory.createTriggerDispatcher(SAC_Interaccion__c.sObjectType);
    /*if (trigger.isBefore && trigger.isUpdate){
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();

        //Recorremos la lista de interacciones
        for (SAC_Interaccion__c consulta : trigger.new) {
            if(consulta.RecordTypeId == recTypeConsulta){
                listaConsultas.add(consulta);
            }
        }
        if (!listaConsultas.isEmpty()) {   
            SAC_Interaccion.crearThreadId(listaConsultas);
        }
    }*/
}