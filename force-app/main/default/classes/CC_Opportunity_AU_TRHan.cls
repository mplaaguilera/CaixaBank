public with sharing class CC_Opportunity_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>)tp.oldList, (Map<Id, Opportunity>)tp.oldMap);
    }

    private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
        listNewObj = descartarOportunidadesNoCsbd(listNewObj);
        if(!listNewObj.isEmpty()) {
            desactivarGestorOportunidadCierreOportunidad(listNewObj, mapOldObj); //GESTOR OPORTUNIDAD
            cierreMasivoQuickAction(listNewObj, mapOldObj);
            crearTareaCambioEmpresaProveedora(listNewObj, mapOldObj);
            actualizarPropietarioOportunidadesHijas(listNewObj, mapOldObj);
            cerrarOportunidadesHijas(listNewObj, mapOldObj);
            sincronizarAccountHijas(listNewObj, mapOldObj);
            
            if (!CSBD_Bypass_Trigger.isBypassed('CC_Opportunity_AU_TRHan')) {
                crearActividadesIdentificarCliente(listNewObj, mapOldObj);
            }

            if(FeatureManagement.checkPermission('CSBD_UsuarioPromptsIA')){
                CSBD_EinsteinUtils.comprobarUsoPromptsYResumenCierre(listNewObj, mapOldObj);
            }

            if (!CSBD_Bypass_Trigger.isBypassed('CC_Opportunity_AU_TRHan_Omnichannel')) {
                //No se crea cuando actualiza omnichannel, creamos una desde CSBD_Opportunity.actualizarPropietarioOportunidadOmnichannel()
                crearActividadesReasignacion(listNewObj, mapOldObj);
                System.debug('listNewObj --> ' + listNewObj);
                System.debug('mapOldObj --> ' + mapOldObj);
                desactivarGestorOportunidadCambioPropietarioManual(listNewObj, mapOldObj);
            }
        }
    }

    private static void desactivarGestorOportunidadCambioPropietarioManual(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        Set<Id> oportunidadesIds = new Set<Id>();
        for (Opportunity oportunidad: listNewObj) {
            //CSBD_Alta_omnichannel__c será true siempre que el estado del Gestor Oportunidad no sea inactivo
            if (oportunidad.CSBD_Alta_omnichannel__c && mapOldObj.get(oportunidad.Id).OwnerId != oportunidad.OwnerId) {
                if (mapOldObj.get(oportunidad.Id).OwnerId != oportunidad.OwnerId) {
                    oportunidadesIds.add(oportunidad.Id);
                }
            }
        }
        if (!oportunidadesIds.isEmpty()) {
            CSBD_GestorOportunidad.desactivarGestorOportunidad(oportunidadesIds);
        }
    }

    private static void desactivarGestorOportunidadCierreOportunidad(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        Set<Id> oportunidadesIds = new Set<Id>();
        for (Opportunity oportunidad: listNewObj) {
            if(oportunidad.CSBD_Alta_omnichannel__c) { //Será true siempre que el estado del Gestor Oportunidad no sea inactivo
                if(mapOldObj.get(oportunidad.Id).CSBD_Estado__c != oportunidad.CSBD_Estado__c && (oportunidad.CSBD_Estado__c == 'Cerrada' || oportunidad.CSBD_Estado__c == 'Rechazada' ||
                    oportunidad.CSBD_Estado__c == 'Pendiente Cita' || oportunidad.CSBD_Estado__c == 'Pendiente Interno' || oportunidad.CSBD_Estado__c == 'Pendiente Cliente')) {
                        oportunidadesIds.add(oportunidad.Id);
                }
            }
        }
        if(!oportunidadesIds.isEmpty()) {
            CSBD_GestorOportunidad.desactivarGestorOportunidad(oportunidadesIds);
        }
    }

    private static void crearActividadesReasignacion(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        Set<Id> idOportunidades = new Set<Id>();
        for (Opportunity newOportunidad : listNewObj) {
            if (newOportunidad.OwnerId != mapOldObj.get(newOportunidad.Id).OwnerId) {
                idOportunidades.add(newOportunidad.Id);
            }
        }
        if(!idOportunidades.isEmpty()) {
            CSBD_Activity.crearActividadReasignacion(idOportunidades, 'Reasignación', 'Oportunidad reasignada manualmente.');
        }
    }

    private static void cierreMasivoQuickAction(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        List<Id> idOportunidadesCierreMasivo = new List<Id>();
        String etapaVentas;
        String resolucion;
        for (Opportunity newOportunidad : listNewObj) {
            if (!newOportunidad.IsClosed
            && mapOldObj.get(newOportunidad.Id).CSBD_StageName_QuickAction_Cerrar__c != newOportunidad.CSBD_StageName_QuickAction_Cerrar__c
            && String.isNotBlank(newOportunidad.CSBD_StageName_QuickAction_Cerrar__c)) {
                idOportunidadesCierreMasivo.add(newOportunidad.Id);
                //Se asume que todas tienen la misma etapa y resolución ya que estos campos solo
                //se pueden informar en la quick action "Cerrar" de las listviews de oportunidad
                etapaVentas = newOportunidad.CSBD_StageName_QuickAction_Cerrar__c;
                resolucion = newOportunidad.CSBD_Resolucion_QuickAction_Cerrar__c;
            }
        }
        if (!idOportunidadesCierreMasivo.isEmpty()) {
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('CSBD_StageName_QuickAction_Cerrar__c', '');
            campos.put('CSBD_Resolucion_QuickAction_Cerrar__c', '');
            CSBD_Opportunity.cerrarOportunidad(idOportunidadesCierreMasivo, etapaVentas, resolucion, campos);
        }
    }

    private static void crearTareaCambioEmpresaProveedora(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj){
        Map<Id, Opportunity> idOportunidadMap = new Map<Id, Opportunity>();
        for(Opportunity oportunidad: listNewObj){
            Opportunity oldOportunidad = mapOldObj.get(oportunidad.Id);
            if(oldOportunidad.CSBD_Empresa_Proveedora__c != null && oldOportunidad.CSBD_Empresa_Proveedora__c != oportunidad.CSBD_Empresa_Proveedora__c){
                idOportunidadMap.put(oportunidad.Id, oportunidad);
            }
        }
        if(!idOportunidadMap.isEmpty()) {
            String asunto = 'Cambio empresa proveedora';
            String cuerpo = 'La empresa proveedora de esta oportunidad ha sido cambiada a ';

            List<Task> tareasInsert = CSBD_Activity.crearActividad(idOportunidadMap.keySet(), asunto, 'Completed', asunto, cuerpo);
            for(Task tarea: tareasInsert) {
                tarea.Description = tarea.Description + idOportunidadMap.get(tarea.WhatId).CSBD_Empresa_Proveedora__c;
            }
            Insert tareasInsert;
        }
    }

    //Cuando se actualiza el propietario de una oportunidad se sincroniza con todas sus oportunidades hijas de tipo acción comercial
    private static void actualizarPropietarioOportunidadesHijas(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        Map<Id, Opportunity> idOportunidades = new Map<Id, Opportunity>();
        for (Opportunity oportunidad: listNewObj) {
            if(mapOldObj.get(oportunidad.Id).OwnerId != oportunidad.OwnerId) {
                idOportunidades.put(oportunidad.Id, oportunidad);
            }
        }
        if (!idOportunidades.isEmpty()) {
            CSBD_ProductoOportunidadHija.actualizarPropietarioOportunidadesHijas(idOportunidades);
        }
    }

    //Si cerramos la oportunidad como rechazada o perdida se cierran todas las hijas del tipo acción comercial
    private static void cerrarOportunidadesHijas(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        Map<Id, Opportunity> idOportunidad = new Map<Id, Opportunity>();
        Id idRtOportunidadMac = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_MAC').getRecordTypeId();
        for(Opportunity oportunidad : listNewObj) {
            Opportunity oldOportunidad = mapOldObj.get(oportunidad.Id);
            if(oportunidad.StageName != oldOportunidad.StageName && (oportunidad.StageName == 'Rechazada' || oportunidad.StageName == 'Perdida' )){
                idOportunidad.put(oportunidad.Id, oportunidad);
                //Devolver traslados de oportunidades MAC a CC
                if (oportunidad.RecordTypeId == idRtOportunidadMac && oportunidad.CSBD_Resolucion__c == 'Devolución a contact') {
                    Map<String, Object> devolverCasoCsbdInput = new Map<String, Object>{
                        'casoId' => oportunidad.CSBD_CasoOrigen__c,
                        'oportunidadId' => oportunidad.Id,
                        'mensaje' => '',
                        'error' => false
                    };
                    devolverCasoCsbdFuture(JSON.serialize(devolverCasoCsbdInput));
                }
            }
        }
        if(!idOportunidad.isEmpty()) {
            CSBD_ProductoOportunidadHija.cerrarOportunidadesHijas(idOportunidad);
        }


    }

    @future
    private static void devolverCasoCsbdFuture(String devolverCasoCsbdInput) {
        try {
            CC_Operativa_Oficina_Controller.devolverCasoCSBD((Map<String, Object>)JSON.deserializeUntyped(devolverCasoCsbdInput));
        } catch (Exception e) {
            CBK_Log.error(e);
        }
    }

    private static List<Opportunity> descartarOportunidadesNoCsbd(List<Opportunity> oportunidades) {
        List<Opportunity> oportunidadesCsbd = new List<Opportunity>();
        for (Opportunity oportunidad : oportunidades) {
            if (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oportunidad.RecordTypeId).getDeveloperName().startsWith('CSBD_')) {
                oportunidadesCsbd.add(oportunidad);
            }
        }
        return oportunidadesCsbd;
    }

    private static void sincronizarAccountHijas(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        Set<Id> oportunidadesPadreCambiadas = new Set<Id>();
        Map<Id, Opportunity> newOpportunityValues = new Map<Id, Opportunity>();

        // Identificar oportunidades padre que han cambiado y almacenar temporalmente los valores de newOpportunity
        for (Opportunity newOpportunity : listNewObj) {
            Opportunity oldOpportunity = mapOldObj.get(newOpportunity.Id);
            if (newOpportunity.AccountId != oldOpportunity.AccountId || newOpportunity.CSBD_Contact__c != oldOpportunity.CSBD_Contact__c) {
                oportunidadesPadreCambiadas.add(newOpportunity.Id);
                newOpportunityValues.put(newOpportunity.Id, newOpportunity);
            }
        }

        if (!oportunidadesPadreCambiadas.isEmpty()) {
            // Obtener oportunidades hijas para las oportunidades padre cambiadas
            List<Opportunity> oportunidadesHijas = [SELECT Id, CSBD_Parent_Id__c,AccountId,CSBD_Contact__c
                                                    FROM Opportunity
                                                    WHERE CSBD_Parent_Id__c IN :oportunidadesPadreCambiadas AND RecordType.DeveloperName = 'CSBD_Accion_Comercial' AND isClosed = false];

            // Iterar sobre las oportunidades hijas y actualizar con los valores de newOpportunity
            for (Opportunity oportunidadHija : oportunidadesHijas) {
                Opportunity newOpportunityValue = newOpportunityValues.get(oportunidadHija.CSBD_Parent_Id__c);
                if (newOpportunityValue != null) {
                    oportunidadHija.AccountId = newOpportunityValue.AccountId;
                    oportunidadHija.CSBD_Contact__c = newOpportunityValue.CSBD_Contact__c;
                }
            }

            // Actualizar las oportunidades hijas en la base de datos
            update oportunidadesHijas;
        }
    }

    private static void crearActividadesIdentificarCliente(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        List<Opportunity> oportunidades = new List<Opportunity>();
        for (Opportunity newOportunidad : listNewObj) {
            if (newOportunidad.CSBD_Contact__c != mapOldObj.get(newOportunidad.Id).CSBD_Contact__c 
                && newOportunidad.CSBD_Contact__c != null) {

                oportunidades.add(newOportunidad);
            }
        }

        Map<Id, Contact> contactos = new Map<Id, Contact>([SELECT Name, AV_NumPerso__c FROM Contact WHERE Id IN :CC_MetodosUtiles.listaCampo(oportunidades, 'CSBD_Contact__c')]);

        List<Task> tareas = new List<Task>();
        for(Opportunity opp: oportunidades){
            Contact contacto = contactos.get(opp.CSBD_Contact__c);

            tareas.add(CSBD_Activity.crearActividadReturn(new Task(), opp.Id, 'Identificación del cliente', 'Completed', 'Identificación manual del cliente', 'Identificación manual del cliente ' + contacto.Name + ' - ' + contacto.AV_NumPerso__c, null));
        }

        if(!tareas.isEmpty()) {
            insert tareas;
        }
    }
}