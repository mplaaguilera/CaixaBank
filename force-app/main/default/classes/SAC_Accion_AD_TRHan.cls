public without sharing class SAC_Accion_AD_TRHan  extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private final static Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private final static Id RECTYPEACCIONRESPONDERESC = mapRTsObjects.get('SAC_Accion__c').get('SAC_AccionResponderEsc').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap, (List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
    }

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj, List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {
        List<SAC_Accion__c> listOldObjSAC = new List<SAC_Accion__c>();
        Map<Id, SAC_Accion__c> mapOldObjSAC = new Map<Id, SAC_Accion__c>();

        for (SAC_Accion__c accion : listOldObj) {
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                listOldObjSAC.add(accion);
                mapOldObjSAC.put(accion.Id, accion);
            }
        }

        if (!listOldObjSAC.isEmpty()) {
            processSAC(listNewObj, mapNewObj, listOldObjSAC, mapOldObjSAC);
        }
    }
    
    private void processSAC(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj, List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_Accion__c> listaMaestro = new List<SAC_Accion__c>();
        List<SAC_Accion__c> otraLista = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaGenerica = new List<SAC_Accion__c>();
        map<id, SAC_Accion__c> restarImportesMap = new map<id, SAC_Accion__c>(); 
        //system.debug('Entro al trigger' + listOldObj);
        for(SAC_Accion__c accionIndividual : listOldObj){
            if(accionIndividual.RecordTypeId == RECTYPEMAESTROTAREAS){
                listaMaestro.add(accionIndividual);
                listaGenerica.add(accionIndividual);
            }
            if(accionIndividual.RecordTypeId == RECTYPEOTRASTAREAS){
                otraLista.add(accionIndividual);
                listaGenerica.add(accionIndividual);
            }
            //tareas con importes informados
            if(accionIndividual.SAC_ImporteResuelto__c != null ||
            accionIndividual.SAC_ImporteAbonar__c != null ||
            accionIndividual.SAC_ImpResueltoInteresesLegales__c != null) {
                mapearImportes(accionIndividual, restarImportesMap);
            }
         }
 
         list<case> casosImportes = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Id IN : restarImportesMap.KeySet()];
         //restar importes al eliminar tareas
         for(case casoImp : casosImportes) {
             if(restarImportesMap.get(casoImp.id).SAC_ImporteAbonar__c != null) {
                 casoImp.CC_Importe_Abonado__c -= restarImportesMap.get(casoImp.id).SAC_ImporteAbonar__c;
             }
             if(restarImportesMap.get(casoImp.id).SAC_ImporteResuelto__c != null) {
                 casoImp.SAC_Importe_Resuelto__c -= restarImportesMap.get(casoImp.id).SAC_ImporteResuelto__c;
             }
             if(restarImportesMap.get(casoImp.id).SAC_ImpResueltoInteresesLegales__c != null) {
                 casoImp.CC_Importe_Abonado__c -= restarImportesMap.get(casoImp.id).SAC_ImpResueltoInteresesLegales__c;
             }
            
         }
         update casosImportes;
        
    

    /*
        //lista sobre tareas que pertenecen al maestro creadas por SAC_Administrador
        if(listaMaestro.size() > 0) {

        }

        //lista sobre tareas que han creado usuarios SAC_General
        if(otraLista.size() > 0) {

        }*/
        //listra que engloba todas las tareas creadas para SAC
        if(listaGenerica.size() > 0){
            //system.debug('dentro trigger');
            SAC_AplicaTareasAutomatizadas.automatizarCasoAplicaTareaDel(listaGenerica);
        }
    }
    
     /*****************************************************************
     * Name: SAC_Accion_AD_TRHan
     * Copyright © 2022  CaixaBank
     * 
     * Proposito: meter el acumulado de los 3 importes a restar en el mapa correcto
     * 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US356803        alex perez     23/10/22      Creación
    *****************************************************************/
    public void mapearImportes(SAC_Accion__c tarea, map<Id, SAC_Accion__c> mapImporte) {
 
        id caseId = tarea.SAC_Pretension__c != null ? tarea.SAC_Pretension__c : tarea.SAC_Reclamacion__c;
        SAC_Accion__c tareaImportes;
        if(mapImporte.containsKey(caseId)) {
            tareaImportes = mapImporte.get(caseId);
           //tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteResuelto__c == null ? 
            //tarea.SAC_ImporteResuelto__c : (tareaImportes.SAC_ImporteResuelto__c + tarea.SAC_ImporteResuelto__c);
            tareaImportes.SAC_ImporteAbonar__c = tarea.SAC_ImporteAbonar__c == null ? 
            tarea.SAC_ImporteAbonar__c : (tareaImportes.SAC_ImporteAbonar__c + tarea.SAC_ImporteAbonar__c);
            tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteAbonarCalc__c == null ? 
            tarea.SAC_ImporteAbonarCalc__c : (tareaImportes.SAC_ImporteResuelto__c + tarea.SAC_ImporteAbonarCalc__c);
            //mapImporte.put(caseId, mapImporte.get(caseId) + importe);
        } else {
            tareaImportes = new SAC_Accion__c();
            //tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteResuelto__c != null ? tarea.SAC_ImporteResuelto__c : 0;
            tareaImportes.SAC_ImporteAbonar__c = tarea.SAC_ImporteAbonar__c != null ? tarea.SAC_ImporteAbonar__c : 0;
            tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteAbonarCalc__c != null ? tarea.SAC_ImporteAbonarCalc__c : 0;
        }
        mapImporte.put(caseId, tareaImportes);
    }

}