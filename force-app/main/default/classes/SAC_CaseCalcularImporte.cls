/*****************************************************************
 * Name: SAC_CaseCalcularImporte
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Calcular el importe de la Reclamación (Caso padre)
 * sumando todas sus pretensiones (Casos Hijos)
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213187       Marcela Neira   04/05/21       Creación
*****************************************************************/

public without sharing class SAC_CaseCalcularImporte {

    /************************************************************************************************************
     * Proposito:  Quedarse con el Ides de la Reclamaciones para formar un mapa
     *
     * Parameters: Lista de Casos Nueva y Lista de casos vieja
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                   S213187     Marcela Neira          05/05/2021         Creación
     * *********************************************************************************************************/

    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

    public static void calcular(List<Case> listaCasosSelect, Set<Id> setIdesRec, Map<Id,Case> mapaDatosCasosActualizar) {

        if (setIdesRec == null) {
            setIdesRec = new Set<Id>();
        }

        Map<Id, List<Case>> mapListPretensiones = new Map<Id, List<Case>> ();
		List<Case> listReclaUpdatear = new List<Case> ();

        for (Id ide : setIdesRec) {
            mapListPretensiones.put(ide, new List<Case>());
        }

		for (Case csPre : listaCasosSelect) {
            if(csPre.RecordTypeId == RECTYPEPRETENSION){
                if (mapListPretensiones.containsKey(csPre.SAC_Reclamacion__c)) {
                    mapListPretensiones.get(csPre.SAC_Reclamacion__c).add(csPre);
                }
            }
		}

        if(!mapListPretensiones.isEmpty()){
            listReclaUpdatear = calcularImporte(mapListPretensiones);
        }

        for (Case caso : listReclaUpdatear) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).CC_Importe_Reclamado__c = caso.CC_Importe_Reclamado__c;
                mapaDatosCasosActualizar.get(caso.id).CC_Importe_Abonado__c = caso.CC_Importe_Abonado__c;
            }else{
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        }

    }
    /************************************************************************************************************
     * Proposito:  Con el Set de Ides hacer una consulta de todas sus pretensiones para luego sumar los importes
     *              y rellenar el importe de la Reclamación padre
     *
     * Parameters: Set de ides
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                   S213187     Marcela Neira          05/05/2021         Creación
     * 1.1                   US356803    Alex Perez             25/10/2022         añadir a los sumatorios las tareas directas en la reclamacion
     * *********************************************************************************************************/

    public static List<Case> calcularImporte(Map<Id,List<Case>> mapListPretensiones){

        Map<Id, Decimal> mapaReclImporteParaActualizar = new Map<Id, Decimal>();
        Map<Id, Decimal> mapaReclQuebrantoParaActualizar = new Map<Id, Decimal>();
        Map<Id, Decimal> mapaReclImporteResueltoParaActualizar = new Map<Id, Decimal>();
        Map<Id, Decimal> mapaReclImporteAbonadoParaActualizar = new Map<Id, Decimal>();
        Map<Id, Case> mapaReclaUpdatear = new Map<Id, Case>();
        List<Case> listaReclaUpdatear = new List<Case>();

        //NEW sumatorios tareas
        //Decimal importeResueltoTotal = 0;
        //Decimal importeAbonadoTotal = 0;
        map<id, list<decimal>> importeTareasMap = importeTareasDirectas(mapListPretensiones.keySet());

        for(Id key : mapListPretensiones.keySet()){
            //Metemos dentro del Mapa los importes de las pretensiones, si es 0 o null no sumaremos
            Decimal importe = 0;
            Decimal importeResuelto = 0;
            Decimal importeAbonado = 0;

            for(Case pretension: mapListPretensiones.get(key)){
                if((pretension.CC_Importe_Reclamado__c != null)/* && (pretension.CC_Importe_Reclamado__c !=0 )*/){
                    if(!mapaReclImporteParaActualizar.containsKey(key)){
                        mapaReclImporteParaActualizar.put(key, 0);
                    }
                    if(mapaReclImporteParaActualizar.containsKey(key)){
                        importe = mapaReclImporteParaActualizar.get(key);
                        importe += pretension.CC_Importe_Reclamado__c;
                        mapaReclImporteParaActualizar.put(key, importe.setScale(2, RoundingMode.HALF_UP));
                    }
                }
            }

            //Calculo importe resuelto
                //Metemos dentro del Mapa los importes de las pretensiones, si es 0 o null no sumaremos
                //

            for(Case pretension: mapListPretensiones.get(key)){

                Decimal importeTarea = pretension.SAC_Importe_Resuelto__c == null ? 0 : pretension.SAC_Importe_Resuelto__c;
                if(mapaReclImporteResueltoParaActualizar.containsKey(key)){
                    importeTarea = mapaReclImporteResueltoParaActualizar.get(key);
                }
                importeResuelto += importeTarea;
            }

            //Calculo importe abonado
            //O o null se tiene que tener en cuenta para poner el valor a 0 si en todas las pretensiones se ha cambiado a null o a 0
            for(Case pretension: mapListPretensiones.get(key)){
                Decimal importeTarea = pretension.CC_Importe_Abonado__c == null ? 0 : pretension.CC_Importe_Abonado__c;
                if(mapaReclImporteAbonadoParaActualizar.containsKey(key)){
                    importeTarea = mapaReclImporteAbonadoParaActualizar.get(key);
                }
                importeAbonado += importeTarea;
            }

            //añadir al resuelto y el abonado el importe de sus tareas directas
            if(importeTareasMap.containsKey(key)){
                importeResuelto += importeTareasMap.get(key)[0];
                importeAbonado += importeTareasMap.get(key)[1];
            }
            mapaReclImporteResueltoParaActualizar.put(key, importeResuelto.setScale(2, RoundingMode.HALF_UP));
            mapaReclImporteAbonadoParaActualizar.put(key, importeAbonado.setScale(2, RoundingMode.HALF_UP));

            //Calculo quebranto -- Añadido
            Decimal importe2 = 0;
            for(Case pretension: mapListPretensiones.get(key)){
                if((pretension.SAC_Quebranto__c != null) && (pretension.SAC_Quebranto__c !=0 )){
                    if(!mapaReclQuebrantoParaActualizar.containsKey(key)){
                        mapaReclQuebrantoParaActualizar.put(key, 0);
                    }
                    if(mapaReclQuebrantoParaActualizar.containsKey(key)){
                        importe2 = mapaReclQuebrantoParaActualizar.get(key);
                        importe2 += pretension.SAC_Quebranto__c;
                        mapaReclQuebrantoParaActualizar.put(key, importe2.setScale(2, RoundingMode.HALF_UP));
                    }
                }
            }
        }

        for(Id ide : mapaReclImporteParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).CC_Importe_Reclamado__c = mapaReclImporteParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.CC_Importe_Reclamado__c = mapaReclImporteParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Calculo importe resuelto
        for(Id ide : mapaReclImporteResueltoParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).SAC_Importe_Resuelto__c = mapaReclImporteResueltoParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.SAC_Importe_Resuelto__c = mapaReclImporteResueltoParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Calculo importe abonado
        for(Id ide : mapaReclImporteAbonadoParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).CC_Importe_Abonado__c = mapaReclImporteAbonadoParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.CC_Importe_Abonado__c = mapaReclImporteAbonadoParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Calculo quebranto -- Añadido
        for(Id ide : mapaReclQuebrantoParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).SAC_Quebranto__c = mapaReclQuebrantoParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.SAC_Quebranto__c = mapaReclQuebrantoParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Pasar las reclamaciones a actualizar del mapa a una lista
        for (Id ideMapaActualizar : mapaReclaUpdatear.keySet()) {
            listaReclaUpdatear.add(mapaReclaUpdatear.get(ideMapaActualizar));
        }

        return listaReclaUpdatear;
    }

     /************************************************************************************************************
     * Proposito:  sacar los sumatorios de las tareas que están directamente asociadas a la reclamación(no están
     * asociadas a ninguna de sus pretensiones)
     *
     * Parameters: Set de ides
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                  US356803    Alex Perez             25/10/2022              Creación
     * *********************************************************************************************************/

    public static map<id, list<decimal>> importeTareasDirectas(set<Id> recId) {
        list<SAC_Accion__c> listaTareas = [SELECT Id, SAC_ImporteResuelto__c, SAC_ImporteAbonar__c, SAC_ImpResueltoInteresesLegales__c,
                                            SAC_Reclamacion__c
                                            FROM SAC_Accion__c WHERE SAC_Reclamacion__c IN : recId AND SAC_Pretension__c = null];
        map<id, list<decimal>> importeTareasMap = new map<id, list<decimal>>();
        for(SAC_Accion__c acc : listaTareas) {
            if(!importeTareasMap.containsKey(acc.SAC_Reclamacion__c)){
                list<decimal> importes = new list<decimal>();
                importes.add(0);
                importes.add(0);
                importeTareasMap.put(acc.SAC_Reclamacion__c, importes);
            }

            if(acc.SAC_ImporteResuelto__c != null) {
                importeTareasMap.get(acc.SAC_Reclamacion__c)[0] += acc.SAC_ImporteResuelto__c;
            }
            if(acc.SAC_ImporteAbonar__c != null) {
                importeTareasMap.get(acc.SAC_Reclamacion__c)[1] += acc.SAC_ImporteAbonar__c;
            }
            if(acc.SAC_ImpResueltoInteresesLegales__c != null) {
                importeTareasMap.get(acc.SAC_Reclamacion__c)[1] += acc.SAC_ImpResueltoInteresesLegales__c;
            }
        }
        return importeTareasMap;
    }
}