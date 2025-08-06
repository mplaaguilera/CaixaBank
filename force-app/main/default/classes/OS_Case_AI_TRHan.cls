public with sharing class OS_Case_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {        
        
        //Obtención de RT OS_
        Schema.DescribeSObjectResult tipoRegistro = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = tipoRegistro.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        
        for (Schema.RecordTypeInfo rt: lstRT){
            String prefijo = '';
            prefijo = rt.getDeveloperName().left(3);
            if ((prefijo=='OS_')) {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }
        List<Case> listNewObjCops= New List<Case>();
        Map<Id, Case> mapNewObjCops = New Map<Id, Case>();
        for (Case tk: listNewObj){
            if(((setIdsRt).contains(tk.RecordTypeId))||(tk.RecordTypeId == null)){
                listNewObjCops.add(tk);
                mapNewObjCops.put(tk.Id,tk);                
            }
        }
        if ((listNewObjCops.size() != 0)){
            crearActividadCierre(listNewObjCops);
            envioCorreoTrasladoRemitidoAutomatico(listNewObjCops);
            //gestionarDANDGDT(listNewObjCops);
            completarMilestonesCasoManual(listNewObjCops); 
            //OS_CaseTriggerHelper.creacionCaso_AI(JSON.serialize(listNewObjCops)); 
            //OS_CaseTriggerHelper.filtroAcuseReciboValija_AI(listNewObjCops);
        }        
    }

    private void crearActividadCierre(List<Case> listNewObj) {
        List<Task> tareasCierre = new List<Task>();
        for (Case caso : listNewObj) {
            if (caso.Status == 'Cerrado') {
                Id tareaRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                Task tareaCierre = new Task();
                tareaCierre.RecordTypeId = tareaRecordType;
                tareaCierre.WhatId = caso.Id;
                tareaCierre.Type = 'Cerrado';
                tareaCierre.Subject = 'Cerrado';
                tareaCierre.ActivityDate = System.today();
                tareaCierre.CC_Fecha_Inicio__c = System.now();
                tareaCierre.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c != null ? caso.CC_Detalles_Consulta__c.left(255) : null;
                tareaCierre.CC_Detalles_Solucion__c = caso.CC_Detalles_Solucion__c != null ? caso.CC_Detalles_Solucion__c.left(255) : null;
                tareaCierre.Status = 'Completed';
                tareasCierre.add(tareaCierre);
            }
        }
        insert tareasCierre;
    }
    
    private static void envioCorreoTrasladoRemitidoAutomatico(List<Case> listNewObj) {        
        
        //Traslado a colaborador automático
        //En BI se detecta que el caso tiene un MCC que debe trasladarse a colaborador automáticamente. Estos campos llegan informados y se llama al future
        Map<Id, Case> casoIdMotivo = new Map<Id, Case>();
        Map<Id, Id> casoIdMotivoId = new Map<Id, Id>();
        Set<Id> casosIds = new Set<Id>();
        Set<Id> MCCIds = new Set<Id>();
        
        for (Case caso : listNewObj)  {
            if (caso.CC_MCC_Motivo__c != null)  { 
                casoIdMotivo.put(caso.CC_MCC_Motivo__c, caso);
                casoIdMotivoId.put(caso.Id, caso.CC_MCC_Motivo__c);
            }
        }
        List<Case> casos = new List<Case>();
        if (casoIdMotivo.size() > 0) {
            List<CC_MCC__c> listaMotivos = new List<CC_MCC__c>();
            listaMotivos = [SELECT CBK_Traslado_Remitido__c, Id  FROM CC_MCC__c WHERE Id IN :casoIdMotivo.keySet()];
            for (CC_MCC__c motivo : listaMotivos) {
                if (motivo.CBK_Traslado_Remitido__c != null) {
                    casos.add(casoIdMotivo.get(motivo.Id));
                    casosIds.add(casoIdMotivo.get(motivo.Id).Id);
                    MCCIds.add(casoIdMotivo.get(motivo.Id).CC_MCC_Motivo__c);
                }
            } 
            if (!casos.isEmpty()) {
                //Pasamos este método a @future
                OS_Case.envioCorreoTrasladoRemitidoAutomatico(casosIds, MCCIds);
            }
        }
    }

    private void completarMilestonesCasoManual(List<Case> listNewObj) {
        //Canales de procedencia a cerrar el caso si el owner es usuario en creación
        List<String> procedenciasCierreTomaPropiedad = OS_Milestone.listadoCanalesProcedencias('procedenciasCierreTomaPropiedad');
        Set<Id> casesId = new Set<Id>();

        for (Case caso : listNewObj) {
            //Cierro SLAS de casos si en su creación el owner es un user
            //También se cierra si el caso se crea con estado Cerrado/Rechazado
            if(procedenciasCierreTomaPropiedad.contains(caso.CC_Canal_Procedencia__c) && 
               (String.valueOf(caso.OwnerId).startsWith('005')) || (caso.Status == 'Cerrado' || caso.Status == 'Rechazado')) {
                casesId.add(caso.Id);
            }
            
        }
        if(!casesId.isEmpty()) {
            OS_Case.completarMilestonesCasoManual(casesId);
        }

    }
}