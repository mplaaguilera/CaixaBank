/*****************************************************************
 * Name: SAC_Accion_BU_TRHan
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Trigger Handler para controlar el Before Update del objeto SAC_Accion__c
 *
 * Clases test: SAC_AccionVF_Test
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                                            22/04/21     Creación          
*****************************************************************/
public without sharing class SAC_Accion_BU_TRHan extends CC_TriggerHandlerBase {
    
    private static Set<String> objetos = new Set<String>{'Case','SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private static Id RECTYPEACCIONRESPONDERESC = mapRTsObjects.get('SAC_Accion__c').get('SAC_AccionResponderEsc').getRecordTypeId();    

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap, (List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
	}

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj, List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_Accion__c> listaTareas = new list<SAC_Accion__c>(); 
        List<SAC_Accion__c> tareasParaFinalizarTMEs = new list<SAC_Accion__c>(); 
        List<SAC_Accion__c> tareasFinalizadas = new list<SAC_Accion__c>(); 
        List<SAC_Accion__c> tareasPendientesAsignar = new list<SAC_Accion__c>();
        List<SAC_Accion__c> listaTareasCompletadas = new list<SAC_Accion__c>();
        List<SAC_Accion__c> listaCambioOwner = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaCambioTercero = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaTareasEnviadas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaTareasDevueltas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaValidarImpAbonado = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaValidarImpAbonadoPrete = new List<SAC_Accion__c>();

        List<Task> listaTasks = new List<Task>();
        List<Id> reclamacionesParaCerrar = new List<Id>();
        Set<Id> listaIdsCasosGlobal = new Set<Id>();
        Set<Id> idsRecTarea = new Set<Id>();
        Set<Id> idsPreteTarea = new Set<Id>();
        Map<Id, Case> mapCasosSelect = new Map<Id, Case>();
        List<Case> listaCasosSelect = new List<Case>();
        Set<Id> listIdCasosRelated = new Set<Id>();
        Map<Id, Case> mapCasosRelated = new Map<Id, Case>();
        Map<Id, List<SAC_Accion__c>> reclamacionTareasMap = new Map<Id, List<SAC_Accion__c>>();

        //Recuperar las colas del cache
        List<Group> listaColas = new List<Group>();
        Group cola;
        Group colaSupervisores;
        listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
        if(!listaColas.isEmpty()){
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                    cola = grupoAux;
                }else if(grupoAux.DeveloperName == 'SAC_PteSupervisor'){
                    colaSupervisores = grupoAux;
                }
            }
        }
       
        //Filtrar Record type Acciones
        for (SAC_Accion__c accion : listNewObj) {
            if (accion.RecordTypeId == RECTYPEMAESTROTAREAS || accion.RecordTypeId == RECTYPEOTRASTAREAS || accion.RecordTypeId == RECTYPEACCIONRESPONDERESC) {
                //Guardar reclamaciones y pretensiones de la tarea
                if(String.isNotBlank(accion.SAC_Reclamacion__c)) {
                    listIdCasosRelated.add(accion.SAC_Reclamacion__c);
                }else if(String.isNotBlank(accion.SAC_Pretension__c)) {
                     listIdCasosRelated.add(accion.SAC_Pretension__c);
                }
                //Si es un cambio de propietario 
                if (accion.OwnerId != mapOldObj.get(accion.Id).OwnerId) {
                    listaCambioOwner.add(accion);
                    listaIdsCasosGlobal.add(accion.SAC_Reclamacion__c);
                    if (String.isNotBlank(accion.SAC_Pretension__c)) {
                        listaIdsCasosGlobal.add(accion.SAC_Pretension__c);
                    }
                }
                //Si ha cambiado el maestro de acciones
                if (accion.SAC_MaestroAccionesReclamacion__c != mapOldObj.get(accion.Id).SAC_MaestroAccionesReclamacion__c){
                    listaTareas.add(accion);
                }

                //Se envía si:
                //1- Pasa de Pte. Enviar a Pte- Asignar o En Gestión
                //2- Pasa de Devuelta a Pte- Asignar o En Gestión
                if(accion.SAC_Estado__c != mapOldObj.get(accion.Id).SAC_Estado__c &&
                 (mapOldObj.get(accion.Id).SAC_Estado__c == 'SAC_PendienteEnviar' && (accion.SAC_Estado__c == 'SAC_PendienteAsignar'|| accion.SAC_Estado__c == 'SAC_EnGestion')  ||
                 mapOldObj.get(accion.Id).SAC_Estado__c == 'SAC_Devuelta' && (accion.SAC_Estado__c == 'SAC_PendienteAsignar'|| accion.SAC_Estado__c == 'SAC_EnGestion') ) ){
                    listaTareasEnviadas.add(accion);
                }

                //Si pasa al estado SAC_Devuelta, se está devolviendo a gestor/letrado
                if(mapOldObj.get(accion.Id).SAC_Estado__c != accion.SAC_Estado__c && accion.SAC_Estado__c == 'SAC_Devuelta'){
                    listaTareasDevueltas.add(accion);
                }


                if( accion.SAC_Estado__c != mapOldObj.get(accion.Id).SAC_Estado__c && accion.SAC_Estado__c == 'SAC_PendienteAsignar' ){
                    tareasPendientesAsignar.add(accion);
                }
                if((mapOldObj.get(accion.Id).SAC_Estado__c != accion.SAC_Estado__c) && accion.SAC_Estado__c == 'SAC_Finalizada' || accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta' || accion.SAC_Estado__c == 'SAC_Descartada'){
                    //Finalizar los TME de las tareas
                    tareasParaFinalizarTMEs.add(accion);
                    tareasFinalizadas.add(accion);
                    //Rellenamos el mapa con el id de la reclamación y sus tareas que han pasado a finalizadas, para posteriormente comprobar si es la ultima de las tareas en finalizar para poder cerrar la reclamación.
                    if (!reclamacionTareasMap.containsKey(accion.SAC_Reclamacion__c)) {
                        reclamacionTareasMap.put(accion.SAC_Reclamacion__c, new List<SAC_Accion__c>());
                    }
            
                    reclamacionTareasMap.get(accion.SAC_Reclamacion__c).add(accion);

                    if(accion.SAC_ImporteAbonar__c != null && accion.SAC_ImporteAbonar__c != 0 && (accion.SAC_Estado__c == 'SAC_Finalizada' || accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta')){
                        listaValidarImpAbonado.add(accion);
                        idsRecTarea.add(accion.SAC_Reclamacion__c);
                    }
                }
                //Si cambia el importe a abonar y no es null o 0, se añade a la lista para validar el sentido de resolución de la pretension
                if((mapOldObj.get(accion.Id).SAC_ImporteAbonar__c != accion.SAC_ImporteAbonar__c) && accion.SAC_ImporteAbonar__c != null && accion.SAC_ImporteAbonar__c != 0){
                    listaValidarImpAbonadoPrete.add(accion);
                    idsPreteTarea.add(accion.SAC_Pretension__c);
                }

                //US458927 eliminar notificaciones de tarea finalizada completa y añadir el envío del email al grupo de el caso si este está en pendiente de asignar
                if(/*accion.SAC_Estado__c == 'SAC_Finalizada' || */(mapOldObj.get(accion.Id).SAC_Estado__c != accion.SAC_Estado__c) && (accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta'
                || accion.SAC_Estado__c == 'SAC_Devuelta' || accion.SAC_Estado__c == 'SAC_Descartada')){
                    listaTareasCompletadas.add(accion);
                    listaIdsCasosGlobal.add(accion.SAC_Reclamacion__c);
                    if (String.isNotBlank(accion.SAC_Pretension__c)) {
                        listaIdsCasosGlobal.add(accion.SAC_Pretension__c);
                    }
                }
                if(accion.SAC_FechaVencimientoProrroga__c != mapOldObj.get(accion.Id).SAC_FechaVencimientoProrroga__c){
                    listaTasks.add(SAC_AccionMetodos.prorrogarTarea(mapOldObj.get(accion.Id), accion));
                    //SAC_AccionMetodos.comprobarHoliday(accion);
                }

                //US662800 Si se ha cambiado el valor de la picklist "Tercero" a none, limpiamos el campo "Fecha tentativa"
                if(accion.SAC_Tercero__c != mapOldObj.get(accion.Id).SAC_Tercero__c && accion.SAC_Tercero__c == null){
                    listaCambioTercero.add(accion);
                }
            }
        }

        //Llamada métodos
        //Query a los casos padres de las tareas
        if (!listaIdsCasosGlobal.isEmpty()) {
            mapCasosSelect = getMapIdCaso(listaIdsCasosGlobal);
            listaCasosSelect = mapCasosSelect.Values();
        }
        //Si se ha cambiado el owner, comprobar si el nuevo owner tiene permiso para serlo
        if (!listaCambioOwner.isEmpty()) {
            SAC_AccionMetodos.comprobarNuevoOwner(listaCambioOwner, mapCasosRelated, cola, colaSupervisores, mapOldObj);
        }

        //Si la tarea pasa a estado finalizada o finalizada incompleta y tiene informado el campo SAC_ImporteAbonar__c, tenemos que validar el sentido de resolución de la reclamación
        if(!listaValidarImpAbonado.isEmpty()){
            SAC_AccionMetodos.validarSentidoResReclamacion(listaValidarImpAbonado, idsRecTarea);
        }

        
        //Si la tarea pasa a estado finalizada o finalizada incompleta y tiene informado el campo SAC_ImporteAbonar__c, tenemos que validar el sentido de resolución de la reclamación
        if(!listaValidarImpAbonadoPrete.isEmpty()){
            SAC_AccionMetodos.validarSentidoResPretension(listaValidarImpAbonadoPrete, idsPreteTarea);
        }

        if(!tareasFinalizadas.isEmpty()){
            SAC_AccionMetodos.rellenarFechaEjecucion(tareasFinalizadas); //Rellenar fecha de ejecución cuando se finaliza la tarea
        }
        SAC_CargarDatosMaestro.cargarDatos(listaTareas);
        SAC_AccionMetodos.finalizarTMEs(tareasParaFinalizarTMEs);
        SAC_AccionMetodos.calcularFechaVencimientoInicial(listNewObj);

        //Se establece la fecha de fin de las acciones
        SAC_AccionMetodos.establecerFechaFin(listNewObj, mapNewObj, mapOldObj);

        if (!listaTasks.isEmpty()) {
            insert listaTasks;
        }
        if (!reclamacionTareasMap.isEmpty()) {
            //Comprobar si todas las acciones de la reclamacion se pueden finalizar
            SAC_AccionMetodos.comprobarTareasFinalizadas(reclamacionTareasMap);
        }
        if(! tareasPendientesAsignar.isEmpty()){
            SAC_AccionMetodos.envioGGH(JSON.serialize(tareasPendientesAsignar));
            //SAC_TareasOperativas_Controller.crearThreadId(tareasPendientesAsignar);
        }

        if(!listaTareasEnviadas.isEmpty()){
            SAC_AccionMetodos.establecerFechaEnvio(listaTareasEnviadas);
        }

        if(!listaTareasDevueltas.isEmpty()){
            SAC_AccionMetodos.establecerFechaDevolucion(listaTareasDevueltas);
        }



        if (!listaTareasCompletadas.isEmpty()) {
            SAC_Notificacion.notificarTareasFinalizadas(listaTareasCompletadas, listaCasosSelect, cola);
        }

        if(!listaCambioTercero.isEmpty()){
            SAC_AccionMetodos.actualizarFechaTentativa(listaCambioTercero);
        }

    }

    private map<Id, case> getMapIdCaso (Set<Id> lstCasesId){
        Map<Id, Case> MapIdReclamacionPretension = new Map<Id, Case>( [SELECT Id, OwnerId, SEG_Grupo__c, SEG_Grupo__r.SAC_Email__c FROM Case
        WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION) 
        AND Id IN :lstCasesId]);

        return MapIdReclamacionPretension;
    }
}