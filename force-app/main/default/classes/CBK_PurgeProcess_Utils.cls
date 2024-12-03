/**********************************************************************************************************************
 Name:	  CC_PurgeProcess_TRDisp
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase auxiliar para el framework de purgado que gestiona las planificaciones batch (FW Batch) a partir del custom object CBK_PurgeProcess__c del FW de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	26/11/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_PurgeProcess_Utils {

    public static void generarPlanificaciones(List<CBK_PurgeProcess__c> lstPurgeProcess){
        list<CBK_Framework_Batch__c> lstPlanificaciones = new list<CBK_Framework_Batch__c>();
        list<CBK_Framework_Batch__c> lstPlanificacionesActualizar = new list<CBK_Framework_Batch__c>();
        try{

            map <String,CBK_Framework_Batch__c> mapParamPlanificaciones = CBK_PurgeProcess_Utils.recuperarMapaParamsPlanificacionesInactivas();
            map <String,String> mapProcesoPlanificacionPredecesora = CBK_PurgeProcess_Utils.recuperarMapaDependenciasPlanificaciones(lstPurgeProcess);
            Map<String,String> linkBatchAndPurgeProcess = new Map<String,String>();
            
            
            for (CBK_PurgeProcess__c purgeProcess : lstPurgeProcess){
                system.debug('gen - purgeProcess: ' + purgeProcess);
                if (mapParamPlanificaciones.containsKey('{"idRecordPurgeProcess":"'+purgeProcess.Id+'"}')){
                    CBK_Framework_Batch__c aux = mapParamPlanificaciones.get('{"idRecordPurgeProcess":"'+purgeProcess.Id+'"}');
                    aux.Activo__c = true;
                    aux.LastExec_Sched__c = purgeProcess.CBK_LastExec_Sched__c;
                    aux.Notif__c = purgeProcess.CBK_Notif__c;
                    aux.Email_Notif__c = purgeProcess.CBK_Email_Notif__c;
                    aux.Lunes__c = purgeProcess.CBK_Lunes__c;
                    aux.Martes__c = purgeProcess.CBK_Martes__c;
                    aux.Miercoles__c = purgeProcess.CBK_Miercoles__c;
                    aux.Jueves__c = purgeProcess.CBK_Jueves__c;
                    aux.Viernes__c = purgeProcess.CBK_Viernes__c;
                    aux.Sabado__c = purgeProcess.CBK_Sabado__c;
                    aux.Domingo__c = purgeProcess.CBK_Domingo__c;
                    aux.Periodicidad__c = purgeProcess.CBK_Periodicidad__c;
                    aux.BatchSize__c = purgeProcess.CBK_BatchSize__c;
                    //Borrarmos la siguiente ejecución planificada para que se pueda recalcular con posterioridad la nueva fecha de ejecución 
                    // tras la modificación de los valores asociados a la planificación del proceso batch
                    aux.NextExec__c = null;
                    aux.Dependencia__c = (purgeProcess.CBK_Dependencia__c!=null?(mapProcesoPlanificacionPredecesora.containsKey(purgeProcess.CBK_Dependencia__c)?mapProcesoPlanificacionPredecesora.get(purgeProcess.CBK_Dependencia__c):null):null);
                    if(purgeProcess.CBK_Dependencia__c==null){
                        aux.JobPath__c = aux.name;
                    }
                    aux.Priority__c=purgeProcess.CBK_Priority__c;
                    system.debug('act - aux: ' + aux);
                    lstPlanificacionesActualizar.add(aux);
                }
                else{
                    CBK_Framework_Batch__c planificacion = new CBK_Framework_Batch__c();
    
                    planificacion.Name = 'CBK_PurgeRecordsBatch_' + String.valueof(DateTime.now().getTime());
                    planificacion.Class_Name__c= 'CBK_PurgeRecordsBatch';
                    planificacion.Activo__c = true;
                    planificacion.BatchSize__c = purgeProcess.CBK_BatchSize__c;
                    planificacion.Calc_NextExec__c = 'SCHED';
                    
                    CBK_Framework_Batch_Apex__mdt conf = new CBK_Framework_Batch_Apex__mdt();
                    planificacion.Proyecto__c = CBK_BatchJob_Helper.findProject('CBK_PurgeRecordsBatch',conf);
            
                    planificacion.Notif__c= purgeProcess.CBK_Notif__c;
                    planificacion.Email_Notif__c = purgeProcess.CBK_Email_Notif__c;
        
                    planificacion.LastExec_Sched__c = purgeProcess.CBK_LastExec_Sched__c;
                    planificacion.Lunes__c = purgeProcess.CBK_Lunes__c;
                    planificacion.Martes__c = purgeProcess.CBK_Martes__c;
                    planificacion.Miercoles__c = purgeProcess.CBK_Miercoles__c;
                    planificacion.Jueves__c = purgeProcess.CBK_Jueves__c;
                    planificacion.Viernes__c = purgeProcess.CBK_Viernes__c;
                    planificacion.Sabado__c = purgeProcess.CBK_Sabado__c;
                    planificacion.Domingo__c = purgeProcess.CBK_Domingo__c;
                    planificacion.Periodicidad__c = purgeProcess.CBK_Periodicidad__c;
                    planificacion.Priority__c = 1;
                    planificacion.Tipo__c = 'Periodico';
                    planificacion.Tipo_de_periodicidad__c = 'Dias';
                    planificacion.params__c = '{"idRecordPurgeProcess":"'+purgeProcess.Id+'"}';

                    planificacion.Dependencia__c = (purgeProcess.CBK_Dependencia__c!=null?(mapProcesoPlanificacionPredecesora.containsKey(purgeProcess.CBK_Dependencia__c)?mapProcesoPlanificacionPredecesora.get(purgeProcess.CBK_Dependencia__c):null):null);
                    planificacion.Priority__c=purgeProcess.CBK_Priority__c;
                    system.debug('gen - planificacion: ' + planificacion);
                    lstPlanificaciones.add(planificacion);
                }
            }
            if (!lstPlanificaciones.isEmpty()){
                system.debug('insert - lstPlanificaciones: ' + lstPlanificaciones);
                //insert lstPlanificaciones;

                Set<String> mids = new Set<String>();
                Database.SaveResult[] srList = Database.insert(lstPlanificaciones,false);
                if (srList != null && srList.size() > 0) {
                    for (Database.SaveResult sr : srList) {
                        if (sr.success){
                            mids.add(sr.getId());
                        }
                    }
                    getbatchAndLinkToPurgeProcess(mids);
                }
            }
            if (!lstPlanificacionesActualizar.isEmpty()){
                system.debug('update - lstPlanificacionesActualizar: ' + lstPlanificacionesActualizar);
                update lstPlanificacionesActualizar;
            }

        }
        catch(System.Exception e){
            CBK_Log.error(e);
        }
    }
    public static void actualizarPlanificaciones(List<CBK_PurgeProcess__c> lstPurgeProcess){
        map <String,String> mapProcesoPlanificacionPredecesora = CBK_PurgeProcess_Utils.recuperarMapaDependenciasPlanificaciones(lstPurgeProcess);
            
        try{
            list<CBK_Framework_Batch__c> lstPlanificacionesActualizar = new list<CBK_Framework_Batch__c> ();
            map <String,CBK_Framework_Batch__c> mapParamPlanificaciones = CBK_PurgeProcess_Utils.recuperarMapaParamsPlanificacionesActivas();
            for (CBK_PurgeProcess__c purgeProcess : lstPurgeProcess){
                system.debug('act - purgeProcess: ' + purgeProcess);
                if (mapParamPlanificaciones.containsKey('{"idRecordPurgeProcess":"'+purgeProcess.Id+'"}')){
                    CBK_Framework_Batch__c aux = mapParamPlanificaciones.get('{"idRecordPurgeProcess":"'+purgeProcess.Id+'"}');
                    aux.LastExec_Sched__c = purgeProcess.CBK_LastExec_Sched__c;
                    aux.Notif__c = purgeProcess.CBK_Notif__c;
                    aux.Email_Notif__c = purgeProcess.CBK_Email_Notif__c;
                    aux.Lunes__c = purgeProcess.CBK_Lunes__c;
                    aux.Martes__c = purgeProcess.CBK_Martes__c;
                    aux.Miercoles__c = purgeProcess.CBK_Miercoles__c;
                    aux.Jueves__c = purgeProcess.CBK_Jueves__c;
                    aux.Viernes__c = purgeProcess.CBK_Viernes__c;
                    aux.Sabado__c = purgeProcess.CBK_Sabado__c;
                    aux.Domingo__c = purgeProcess.CBK_Domingo__c;
                    aux.Periodicidad__c = purgeProcess.CBK_Periodicidad__c;
                    aux.BatchSize__c = purgeProcess.CBK_BatchSize__c;
                    //Borrarmos la siguiente ejecución planificada para que se pueda recalcular con posterioridad la nueva fecha de ejecución 
                    // tras la modificación de los valores asociados a la planificación del proceso batch
                    aux.NextExec__c = null;
                    aux.Dependencia__c = (purgeProcess.CBK_Dependencia__c!=null?(mapProcesoPlanificacionPredecesora.containsKey(purgeProcess.CBK_Dependencia__c)?mapProcesoPlanificacionPredecesora.get(purgeProcess.CBK_Dependencia__c):null):null);
                    if(purgeProcess.CBK_Dependencia__c==null){
                        aux.JobPath__c = aux.name;
                    }
                    aux.Priority__c=purgeProcess.CBK_Priority__c;
                    system.debug('act - aux: ' + aux);
                    lstPlanificacionesActualizar.add(aux);
                }
            }
            if (!lstPlanificacionesActualizar.isEmpty()){
                system.debug('update - lstPlanificacionesActualizar: ' + lstPlanificacionesActualizar);
                update lstPlanificacionesActualizar;
            }
        }
        catch(System.Exception e){
            CBK_Log.error(e);
        }
    }
    public static void eliminarPlanificaciones(List<CBK_PurgeProcess__c> lstPurgeProcess) {
        try{
            list<CBK_Framework_Batch__c> lstPlanificacionesDesactivacion = new list<CBK_Framework_Batch__c> ();
            map <String,CBK_Framework_Batch__c> mapParamPlanificaciones = CBK_PurgeProcess_Utils.recuperarMapaParamsPlanificacionesActivas();
            for (CBK_PurgeProcess__c planifEliminar : lstPurgeProcess){
                if (mapParamPlanificaciones.containsKey('{"idRecordPurgeProcess":"'+planifEliminar.Id+'"}')){
                    CBK_Framework_Batch__c aux = mapParamPlanificaciones.get('{"idRecordPurgeProcess":"'+planifEliminar.Id+'"}');
                    aux.Activo__c = false;
                    lstPlanificacionesDesactivacion.add(aux);
                }
            }
            if (!lstPlanificacionesDesactivacion.isEmpty()){
                update lstPlanificacionesDesactivacion;
            }
        }
        catch(System.Exception e){
            CBK_Log.error(e);
        }
    }

    private static map<String,CBK_Framework_Batch__c> recuperarMapaParamsPlanificacionesActivas(){
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        map <String,CBK_Framework_Batch__c> mapParamPlanificaciones = new map <String, CBK_Framework_Batch__c>();
        lstPlanificacionesActivas = [SELECT id,name,params__c FROM CBK_Framework_Batch__c WHERE Class_Name__c ='CBK_PurgeRecordsBatch' AND Activo__c = true];
        for(CBK_Framework_Batch__c planifActiva : lstPlanificacionesActivas){
            mapParamPlanificaciones.put(planifActiva.params__c,planifActiva);
        }
        return mapParamPlanificaciones;
    }
    private static map<String,CBK_Framework_Batch__c> recuperarMapaParamsPlanificacionesInactivas(){
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        map <String,CBK_Framework_Batch__c> mapParamPlanificaciones = new map <String, CBK_Framework_Batch__c>();
        lstPlanificacionesActivas = [SELECT id,name, params__c FROM CBK_Framework_Batch__c WHERE Class_Name__c ='CBK_PurgeRecordsBatch' AND Activo__c = false];
        for(CBK_Framework_Batch__c planifActiva : lstPlanificacionesActivas){
            mapParamPlanificaciones.put(planifActiva.params__c,planifActiva);
        }
        return mapParamPlanificaciones;
    }
    private static map<String,String> recuperarMapaDependenciasPlanificaciones(List<CBK_PurgeProcess__c> lstPurgeProcess){
        map <String,String> mapProcesosPlanificacionesPredecesoras = new map <String, String>();
        Set <String> setParamsPlanifPredecesores = new Set<String>();
        List<CBK_Framework_Batch__c> lstPlanificacionesConParams = new list<CBK_Framework_Batch__c> ();
        map <String,CBK_Framework_Batch__c> mapPlanificacionesPredecesoras = new map <String, CBK_Framework_Batch__c>();
        
        for(CBK_PurgeProcess__c proceso : lstPurgeProcess){
            if (proceso.CBK_Dependencia__c != null){
                setParamsPlanifPredecesores.add('{"idRecordPurgeProcess":"'+proceso.CBK_Dependencia__c+'"}');
            }
        }
        if (!setParamsPlanifPredecesores.isEmpty()){
            lstPlanificacionesConParams = [SELECT id,name,params__c FROM CBK_Framework_Batch__c WHERE Class_Name__c ='CBK_PurgeRecordsBatch'];
            for(CBK_Framework_Batch__c planifParam : lstPlanificacionesConParams){
                if (setParamsPlanifPredecesores.contains(planifParam.params__c)){
                    mapPlanificacionesPredecesoras.put(planifParam.params__c,planifParam);
                }
            }
        }
        for(CBK_PurgeProcess__c procesoDependiente : lstPurgeProcess){
            if (procesoDependiente.CBK_Dependencia__c != null){
                if(mapPlanificacionesPredecesoras.containsKey('{"idRecordPurgeProcess":"'+procesoDependiente.CBK_Dependencia__c+'"}')){
                    mapProcesosPlanificacionesPredecesoras.put(
                        procesoDependiente.CBK_Dependencia__c,
                        mapPlanificacionesPredecesoras.get('{"idRecordPurgeProcess":"'+procesoDependiente.CBK_Dependencia__c+'"}').Id
                    );
                }
            }
        }
        system.debug ('mapProcesosPlanificacionesPredecesoras: ' + mapProcesosPlanificacionesPredecesoras);
        return mapProcesosPlanificacionesPredecesoras;
    }
    public static void recalculoPlanificaciones() {
        CBK_BatchJob.reschedulledJobs();
    }

    private static void getbatchAndLinkToPurgeProcess(Set<String> mids){
        list<CBK_Framework_Batch__c> lstcreados= new list<CBK_Framework_Batch__c> ();
        map <String,CBK_Framework_Batch__c> mapParamPlanificaciones = new map <String, CBK_Framework_Batch__c>();
        lstcreados = [SELECT id,name,params__c FROM CBK_Framework_Batch__c WHERE Id =:mids];
        for(CBK_Framework_Batch__c creado : lstcreados){
            if(String.isNotBlank(creado.params__c)){
                map<String,Object> params = New map<String,Object>();
                params = (Map<String, Object>)JSON.deserializeUntyped(creado.params__c);
                creado.CBK_PurgeProcessId__c = String.valueOf(params.get('idRecordPurgeProcess'));
            }
        }
        if(lstcreados.size() > 0){
            update lstcreados;
        }
    }
}