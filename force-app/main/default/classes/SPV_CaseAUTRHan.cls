public with sharing class SPV_CaseAUTRHan extends CC_TriggerHandlerBase{
 
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        //Llamada al método que filtra los casos de SPV
        List<Case> listCasosSPV = SPV_CaseHelper.filtrarCasosSPV(listNewObj);
        List<Case> lstReclamaciones = new List<Case>();
        List<Case> lstPretensiones = new List<Case>();
        Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();

        for(Case caso :listCasosSPV){
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                lstReclamaciones.add(caso);
            }else if(caso.RecordTypeId == RECTYPEPRETENSION){
                lstPretensiones.add(caso);
            }
        }

        if (!listCasosSPV.isEmpty()) {
            SPV_CaseHelper.lanzarAlertas(listCasosSPV, mapOldObj); //Lanzamiento de alertas
        }

        if(!lstReclamaciones.isEmpty()){
            //Si se cambia el account o el contact
            SPV_CaseHelper.createReclamanteRecord(lstReclamaciones, mapOldObj);
            //Si cambia el owner de la reclamación
            SPV_CaseHelper.cambioOwnerReclamacion(listCasosSPV, mapOldObj); //Probar
            //Detectar cambio de estado //Probar
            SPV_CaseHelper.cambioAltaAnalisisReclamacion(listCasosSPV, mapOldObj, mapaDatosCasosActualizar); //Probar
            //Si el SEG_Subestado__c de la reclamación viene Negociación
            SPV_CaseHelper.actualizarEstado(listCasosSPV, mapOldObj);
            // Si se cierra la reclamación
            SPV_CaseHelper.finalizarConsultasReclamacion(listCasosSPV, mapOldObj);
            //Si se actualiza la fecha de recepción de una reclamación, se actualiza la de sus pretensiones
            SPV_CaseHelper.actualizarFechaRecepcionPretensiones(listCasosSPV, mapOldObj);

            SPV_CaseHelper.actualizarIdPretension(lstReclamaciones, mapOldObj, mapaDatosCasosActualizar);

            //Si se actualiza el estado de una reclamación, el estado debe arrastrarse a sus pretensiones activas
            SPV_CaseHelper.arrastrarEstadoReclamacionPretension(listCasosSPV, mapOldObj);

            //Si se actualiza el estado de una reclamación, se deben cerrar los SLA correspondientes
            SPV_CaseHelper.cerrarSLAReclamacion(listCasosSPV, mapOldObj);

            //Si se actualiza la ofician afectada de la reclamacion, añadir un registro del objeto intermedio que relaciona reclaamción-Oficinas Afectadas
            SPV_CaseHelper.addOficinaAfectada(lstReclamaciones, mapOldObj, mapaDatosCasosActualizar);

            //Si se actualiza algún dato del reclamante de una reclamación, se debe actualizar de cada una de sus pretensiones
            SPV_CaseHelper.actualizarDatosReclamantePretensiones(lstReclamaciones, mapOldObj, mapaDatosCasosActualizar);
        }
       
        if(!lstPretensiones.isEmpty()){
            //Si cambia el campo SAC_ResultadoNegociacion__c de la pretensión
            SPV_CaseHelper.comprobarResultadoNegociacion(listCasosSPV, mapOldObj);
            //Si cambia el owner de la pretensión
            SPV_CaseHelper.cambioOwnerPretension(listCasosSPV, mapOldObj, mapaDatosCasosActualizar); //Probar
            //Si cambia la entidad productora de la pretensión principal
            SPV_CaseHelper.actualizarEntidadProductoraReclamacion(listCasosSPV, mapOldObj, mapaDatosCasosActualizar);
            SPV_CaseHelper.calcular(listCasosSPV, mapOldObj, mapaDatosCasosActualizar); //Cuando se actualiza el importe de una pretensión, se calculará el de la reclamación padre
            SPV_CaseHelper.actualizarOwnerPretensionesHermanas(lstPretensiones, mapOldObj, mapaDatosCasosActualizar);     //Cuando se actualiza el owner una pretensión, se actualiza el owner de sus pretensiones hermanas 
            }

        if(!mapaDatosCasosActualizar.isEmpty()){
            SPV_DatabaseDML.updateListDML(mapaDatosCasosActualizar.values(), false);
        }
    }
 
}