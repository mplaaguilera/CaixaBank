public  with sharing class CC_Agrupador_AI_TRHan extends CC_TriggerHandlerBase { 

    private static final Id COMINFORMATIVART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
    private static final Id COMINFORMATIVACAMPANART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
    private static final Id COMINFORMATIVAMARCART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Marca').getRecordTypeId();
    private static final Id INCIDENCIART = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
    private static final Id MASIVACONTROLRT = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Masiva_Control').getRecordTypeId();
    private static final Id SEGUIMIENTORT = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Seguimiento').getRecordTypeId();

    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Agrupador__c>)tp.newList, (Map<Id, CC_Agrupador__c>)tp.newMap);
    }

    private void process(List<CC_Agrupador__c> listNewObj, Map<Id, CC_Agrupador__c> mapNewObj) {

        List<CC_Agrupador__c> listNotificarAgrupador = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> listAgrupadoresActualizar = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> listActAgrupador = new List<CC_Agrupador__c>();
        
        for(CC_Agrupador__c agrupador : listNewObj) {
            /*
            RT = CC_Incidencia
            CC_Publica__c = true
            */
            if(agrupador.RecordTypeId == INCIDENCIART && agrupador.CC_Publica__c){  
                listNotificarAgrupador.add(agrupador);
            }

            /*
            RT != CC_Comunicacion_Informativa && RT != CC_Comunicacion_Informativa_de_Campana
            */
            if(agrupador.RecordTypeId != COMINFORMATIVART && agrupador.RecordTypeId != COMINFORMATIVACAMPANART){
                listActAgrupador.add(agrupador);
            }

            /*
            CC_Numero_Casos__c > 0
            */
            if(agrupador.CC_Numero_Casos__c  > 0) {
                listAgrupadoresActualizar.add(agrupador);
            }
        }

        if(!listNotificarAgrupador.isEmpty()){
            notificarAgrupador(listNotificarAgrupador);
        }

        if(!listActAgrupador.isEmpty()) {
            actualizarAgrupador(listActAgrupador);
        }

        if(!listAgrupadoresActualizar.isEmpty()) {
            agrupadorAviso(listAgrupadoresActualizar, mapNewObj);
        }
    }

    private void notificarAgrupador(List<CC_Agrupador__c> listAgrupadores) {

        List<CC_Notificacion.AgrupadorMensajeInfo> listAgrupadoresNotificar = new List<CC_Notificacion.AgrupadorMensajeInfo>();
        List<CC_Agrupador__c> listAgrupadoresActualizar = new List<CC_Agrupador__c>();
        

        for(CC_Agrupador__c agrupador : listAgrupadores){
            //Generamos la notificacion
            CC_Notificacion.AgrupadorMensajeInfo notificacion = new CC_Notificacion.AgrupadorMensajeInfo();
            notificacion.idAgrupador = agrupador.Id;
            notificacion.mensaje = 'Se ha generado una nueva incidencia pública: ' + agrupador.Name + ' - ' + agrupador.CC_Titulo__c;
            listAgrupadoresNotificar.add(notificacion);
        }
        if(!listAgrupadoresNotificar.isEmpty()){
            //Notificar a los usuarios de que se ha publicado un agrupador
            CC_Notificacion.publicarToastAviso(listAgrupadoresNotificar);
        }
    }

    private void actualizarAgrupador(List<CC_Agrupador__c> listAgrupadores) {

        List<CC_Agrupador__c> listAgrupadoresActualizar = new List<CC_Agrupador__c>();

        for(CC_Agrupador__c agrupador : listAgrupadores){
            //Asignamos el id del agrupador a campo custom ID (Interno)
            CC_Agrupador__c agrupadorActualizar = new CC_Agrupador__c();
            agrupadorActualizar.Id = agrupador.Id;
            agrupadorActualizar.CC_Id__c = agrupador.Id;
            listAgrupadoresActualizar.add(agrupadorActualizar);
        }

        if(!listAgrupadoresActualizar.isEmpty()){
            //Actualizar los agrupadores
            update listAgrupadoresActualizar;
        }
    }

    private void agrupadorAviso(List<CC_Agrupador__c> listAgrupadoresActualizar, Map<Id, CC_Agrupador__c> mapAgrupadoresAntiguos) {
        Set<String> destinatarios = new Set<String>();
        //Invocamos al método de agrupadorAviso
        String tipoNoficicacion = [SELECT Id from CustomNotificationType WHERE DeveloperName = 'CC_Cierre_Maximo' LIMIT 1].Id;
        //Llamar al metodo de aviso de agrupador
        CC_Aviso_Agrupador.publicarEventoDeAviso(listAgrupadoresActualizar);
    }
    /*
    private void asociarCasosAComunicacionInformativa(List<CC_Agrupador__c> listNewObj) {
        List<Case> casosActualizar = new List<Case>();
        Set<Id> setCausas = new Set<Id>();
        Set<Id> setCampana = new Set<Id>();
        Map<Id, Id> mapAgrupadorCausa = new Map<Id, Id>();
        Map<Id, Id> mapAgrupadorCampana = new Map<Id, Id>();
        Id comunicacionInformativaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        Id comunicacionInformativaCampanaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        for (CC_Agrupador__c agrupador : listNewObj) {
            if (agrupador.RecordTypeId == comunicacionInformativaRecordTypeId && agrupador.CC_Tematica_Id__c != null && agrupador.CC_Producto_Servicio__c != null && agrupador.CC_Motivo__c != null && agrupador.CC_Causa__c != null && !setCausas.contains(agrupador.CC_Causa__c) && !mapAgrupadorCausa.containsKey(agrupador.CC_Causa__c)) {
                setCausas.add(agrupador.CC_Causa__c);
                mapAgrupadorCausa.put(agrupador.CC_Causa__c, agrupador.Id);
            } else if (agrupador.RecordTypeId == comunicacionInformativaCampanaRecordTypeId && agrupador.CC_Campana__c != null && !setCampana.contains(agrupador.CC_Campana__c) && !mapAgrupadorCampana.containsKey(agrupador.CC_Campana__c)) {
                setCampana.add(agrupador.CC_Campana__c);
                mapAgrupadorCampana.put(agrupador.CC_Campana__c, agrupador.Id);
            }
        }

        if(!setCausas.isEmpty()){
            for (Case casoConMismaCausa : [SELECT Id, CC_Comunicacion_Informativa__c, CC_MCC_Causa__c, CC_Admin__c FROM Case WHERE CC_MCC_Tematica__c != null AND CC_MCC_ProdServ__c != null AND CC_MCC_Motivo__c != null AND CC_MCC_Causa__c != null AND CC_MCC_Causa__c IN :setCausas AND CreatedDate = TODAY AND Status != 'Rechazado' AND CC_Tipo_Contacto__c != 'Incidencia' AND CC_Agrupador_Id__c = null WITH SECURITY_ENFORCED]) {
                casoConMismaCausa.CC_Comunicacion_Informativa__c = mapAgrupadorCausa.get(casoConMismaCausa.CC_MCC_Causa__c);
                casoConMismaCausa.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCausa);
            }
        }

        if(!setCampana.isEmpty()){
            for (Case casoConMismaCampana : [SELECT Id, CC_Comunicacion_Informativa_Campana__c, CC_Campana__c, CC_Admin__c FROM Case WHERE CC_Campana__c != null AND CC_Campana__c IN :setCampana AND CreatedDate = TODAY AND Status != 'Rechazado' AND CC_Tipo_Contacto__c != 'Incidencia' AND CC_Agrupador_Id__c = null WITH SECURITY_ENFORCED]) {
                casoConMismaCampana.CC_Comunicacion_Informativa_Campana__c = mapAgrupadorCampana.get(casoConMismaCampana.CC_Campana__c);
                casoConMismaCampana.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCampana);
            }
        }

        if(!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa_Campana__c.isUpdateable() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa__c.isUpdateable()){
            update casosActualizar;
        }
        
        List<Case> casosActualizarAux = new List<Case>();
        for (Case casoActualizar : casosActualizar) {
            casoActualizar.CC_Admin__c = false;
            casosActualizarAux.add(casoActualizar);
        }
        update casosActualizarAux;
    }*/
}