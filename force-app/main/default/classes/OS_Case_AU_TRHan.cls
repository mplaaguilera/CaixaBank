public with sharing class OS_Case_AU_TRHan extends CC_TriggerHandlerBase {
    
    public static map<id, case> casesMap = new map<id, case>();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        //Obtención de RT OS_
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        
        for (Schema.RecordTypeInfo rt: lstRT){
            if (rt.getDeveloperName().left(3)=='OS_') {
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
        
        List<Case> listOldObjCops= New List<Case>();
        Map<Id, Case> mapOldObjCops = New Map<Id, Case>();
        for (Case tk: listOldObj){
            if(((setIdsRt).contains(tk.RecordTypeId))||(tk.RecordTypeId == null)){
                listOldObjCops.add(tk);
                mapOldObjCops.put(tk.Id,tk);                
            }
        }

        if (listNewObjCops.size()!=0) {
            
            for(case casMil : [SELECT Id, Entitlement.Name, CreatedDate, Origin, CC_Canal_Procedencia__c, CC_MCC_Tematica__c, 
            CC_MCC_Tematica__r.OS_Horario__c, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.OS_Horario__c, CC_MCC_Causa__c, 
            CC_MCC_Causa__r.OS_Horas_SLA__c, OS_Cola_Telefonia__c FROM Case WHERE Id In :mapNewObjCops.keySet() ]) {
            	casesMap.put(casMil.Id, casMil);
        	}
        }
        
        if ((mapOldObjCops.size() != 0) ||(listNewObjCops.size() != 0)){
            revisarCambioEstado(mapOldObjCops, listNewObjCops);
            crearActividadCierreCOPS(mapOldObjCops, listNewObjCops);
            crearActividadReasignacionCOPS(mapOldObjCops, listNewObjCops);
            crearActividadReasignacionGruposTrabajoCOPS(mapOldObjCops, listNewObjCops);
            envioCorreoTrasladoRemitidoAutomatico(mapOldObjCops, listNewObjCops);
            gestionarDANDGDT(mapOldObjCops, listNewObjCops);
            envioFeedback(mapOldObjCops, listNewObjCops);
            OS_CaseTriggerHelper.reasignacionDelCaso(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.eliminarSituacion(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.avisoPropietarioNuevoCorreo(listNewObjCops,mapOldObjCops);
            //OS_CaseTriggerHelper.enviarEncuestaCierre(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.scheduleProgramarAlerta(listNewObjCops,mapOldObjCops);   
            OS_CaseTriggerHelper.actualizarAgrupadorAU(listNewObjCops,mapOldObjCops);   
            OS_CaseTriggerHelper.asociaActivoAU(listNewObjCops,mapOldObjCops);   
        }        
    }

    private void envioFeedback(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Id> tematicas = new List<Id>();
        List<String> grupos = new List<String>();
        List<Case> casosCerrados = new List<Case>();
        Map<String, String> mapFeedback = new Map<String, String>();
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).Status != 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Rechazado' && (caso.Status == 'Cerrado' || caso.Status == 'Rechazado')) {
                tematicas.add(caso.CC_MCC_Tematica__c);
                grupos.add(caso.OS_GrupoTrabajo__c);
                casosCerrados.add(caso);
            }
        }
        Map<String, String> mapaTemGroups = new Map<String, String>();
        List<SEG_ClasificacionRapida__c> clasif = [SELECT SEG_Tematica__c, OS_GrupoTrabajo__r.Name, SEG_Nombre_CR_Cognitive__c FROM SEG_ClasificacionRapida__c WHERE SEG_Tematica__c IN :tematicas AND OS_GrupoTrabajo__r.Name IN :grupos AND SEG_Nombre_CR_Cognitive__c!=NULL];

        for(SEG_ClasificacionRapida__c regla : clasif){
            mapaTemGroups.put(String.valueOf(regla.SEG_Tematica__c)+regla.OS_GrupoTrabajo__r.Name, regla.SEG_Nombre_CR_Cognitive__c);
        }

        for(Case casoCerrado :casosCerrados){
            String clave = String.valueof(casoCerrado.CC_MCC_Tematica__c) + casoCerrado.OS_GrupoTrabajo__c;
            if(mapaTemGroups.containsKey(clave)){
                mapFeedback.put(casoCerrado.CaseNumber, mapaTemGroups.get(clave));
            }   
        }
        if(!mapFeedback.isEmpty()){
            //Llamada al método de OS_feedbackCognitive (caso.CaseNumber, mapaTemGroups.get(clave));
            OS_feedbackCognitive fbCognitive = new OS_feedbackCognitive(mapFeedback);
            System.enqueueJob(fbCognitive); 
        }
    }
    
    private void crearActividadCierreCOPS(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Task> tareasCierre = new List<Task>();
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado') {
                Task tareaCierre = new Task();
                tareaCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
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
    
    private void crearActividadReasignacionCOPS(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Id> idsCOPS = new List<Id>();
        
        Boolean crearActividad = false;
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) {
                crearActividad = true;
                idsCops.add(caso.Id);
                break;
            }
        }
        
        if (crearActividad) {
            Map<Id, Case> casos = new Map<Id, Case>([SELECT Owner.Name FROM Case WHERE Id IN :idsCOPS]);
            List<Task> tareasReasignacion = new List<Task>();
            for (Case caso : listNewObj) {
                if (idsCOPS.contains(caso.Id) && mapOldObj.get(caso.Id).OwnerId !=null && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId  
                && casos?.get(caso.Id)?.Owner?.Name != null && !String.valueOf(caso.OwnerId).startsWith('00G')) {
                    ID oldCaseOwner = mapOldObj.get(caso.Id).OwnerId;
                    Case newCase = caso;
                    Task tareaCierre = new Task();
                    tareaCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                    tareaCierre.WhatId = caso.Id;
                    tareaCierre.Type = 'Reasignación';
                    tareaCierre.Subject = 'Reasignación del caso a ' + casos.get(caso.Id).Owner.Name;
                    tareaCierre.ActivityDate = System.today();
                    tareaCierre.CC_Fecha_Inicio__c = System.now();
                    tareaCierre.Status = 'Completed';
                    tareasReasignacion.add(tareaCierre);
                }
            }
            insert tareasReasignacion;
        }
    }
    
    private void crearActividadReasignacionGruposTrabajoCOPS(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Id> idsCOPS = new List<Id>();
        
        Boolean crearActividad = false;
        for (Case caso : listNewObj) {
            if (mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) {
                crearActividad = true;
                idsCops.add(caso.Id);
                break;
            }
        }
        
        if (crearActividad) {
            Map<Id, Case> casos = new Map<Id, Case>([SELECT Owner.Name FROM Case WHERE Id IN :idsCOPS]);
            List<Task> tareasReasignacion = new List<Task>();
            for (Case caso : listNewObj) {
                if (idsCOPS.contains(caso.Id) && mapOldObj.get(caso.Id).OwnerId !=null && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId  
                && casos?.get(caso.Id)?.Owner?.Name != null && String.valueOf(caso.OwnerId).startsWith('00G')) {
                    ID oldCaseOwner = mapOldObj.get(caso.Id).OwnerId;
                    Case newCase = caso;
                    Task tareaCierre = new Task();
                    tareaCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                    tareaCierre.WhatId = caso.Id;
                    tareaCierre.Type = 'Reasignación';
                    tareaCierre.Subject = 'Reasignación del Grupo de Trabajo a ' + casos.get(caso.Id).Owner.Name;
                    tareaCierre.ActivityDate = System.today();
                    tareaCierre.CC_Fecha_Inicio__c = System.now();
                    tareaCierre.Status = 'Completed';
                    tareasReasignacion.add(tareaCierre);
                }
            }
            insert tareasReasignacion;
        }
    }
    
    private static void envioCorreoTrasladoRemitidoAutomatico(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        
        Map<Id, Case> casoIdMotivo = new Map<Id, Case>();
        Map<Id, Id> casoIdMotivoId = new Map<Id, Id>();
        Set<Id> casosIds = new Set<Id>();
        Set<Id> MCCIds = new Set<Id>();
        
        for (Case caso : listNewObj)  {
            if (mapOldObj.get(caso.Id).CC_MCC_Motivo__c != caso.CC_MCC_Motivo__c && caso.CC_MCC_Motivo__c != null)  { 
                casoIdMotivo.put(caso.CC_MCC_Motivo__c, caso);
                casoIdMotivoId.put(caso.Id, caso.CC_MCC_Motivo__c);
            }
        }
        List<Case> casos = new List<Case>();
        if (casoIdMotivo.size() > 0) {
            List<CC_MCC__c> listaMotivos = [SELECT CBK_Traslado_Remitido__c, Id  FROM CC_MCC__c 
                                            WHERE Id IN :casoIdMotivo.keySet()];
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

    private void gestionarDANDGDT(Map<Id, Case> mapOldObj, List<Case> listNewObj){
        Set<Id> casosInformarDANDGDT = new Set<Id>();
        for(Case caso: listNewObj){
            if(caso.AccountId != mapOldObj.get(caso.Id).AccountId){
                if(caso.AccountId != null){
                    casosInformarDANDGDT.add(caso.Id);
                }
            }
        }
        OS_Informar_DAN_DG_DT_Caso.informarCampos(casosInformarDANDGDT);
    }

    /**
    * Revisa si ha habido un cambio de estado en un caso y, si es así, actualiza el estado del caso relacionado en Segmentos
    */
    private void revisarCambioEstado(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Case> casosRelacionadosSegmentos = new List<Case>();
        Set<Id> casosSegmentosRevisar = new Set<Id>();
        Map<Id, Case> mapCasosSeg;
        for (Case caso : listNewObj) {
            // Comprobar si ha habido un cambio de estado en el caso
            if (mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'Cerrado' || caso.Status == 'Rechazado') && caso.SEG_Id_Related_Mail__c != null && caso.CC_CasoRelacionado__c != null) {
                Case caseSeg = new Case(Id = caso.CC_CasoRelacionado__c);
                if (caso.Status == 'Cerrado') {
                    caseSeg.Status = 'Cerrado';
                    caseSeg.SEG_Subestado__c = 'Gestionado por UAFE';
                } else {
                    caseSeg.Status = 'Activo';
                }
                casosRelacionadosSegmentos.add(caseSeg);
                casosSegmentosRevisar.add(caso.CC_CasoRelacionado__c);
            }
        }

        if (!casosSegmentosRevisar.isEmpty() && !casosRelacionadosSegmentos.isEmpty()) {
            
            mapCasosSeg = new Map<Id, Case>([SELECT Id, AccountId, Account.Name, ContactId, CC_MCC_Motivo__c, SEG_N_operaciones_del_caso__c FROM Case WHERE Id IN :casosSegmentosRevisar]); //Añadir los campos de MCC
            List<Contact> listContact = [SELECT Id, AccountId FROM Contact WHERE Email = 'buzon.uafe@uafe.caixabank.com' AND RecordType.DeveloperName = 'CC_Colaborador'];
            List<CC_MCC__c> mccUAFE = SEG_MetodosWithoutSharing.devolverMCCSEG();

            for (Case casoRelacionado : casosRelacionadosSegmentos) {
                if (mapCasosSeg != null && mapCasosSeg.containsKey(casoRelacionado.Id)) {
                    if (mapCasosSeg.get(casoRelacionado.Id).CC_MCC_Motivo__c == null && !mccUAFE.isEmpty()) {
                        casoRelacionado.CC_MCC_Tematica__c = mccUAFE[0]?.CC_Producto_Servicio__r?.CC_Tematica__c;
                        casoRelacionado.CC_MCC_ProdServ__c = mccUAFE[0]?.CC_Producto_Servicio__c;
                        casoRelacionado.CC_MCC_Motivo__c = mccUAFE[0]?.Id;
                    }

                    if ((casoRelacionado.AccountId == null || casoRelacionado.Account?.Name == 'CUENTA PENDIENTE ASOCIAR') && !listContact.isEmpty()) {
                        casoRelacionado.ContactId = listContact[0].Id;
                        casoRelacionado.AccountId = listContact[0].AccountId;
                    }

                    if (mapCasosSeg.get(casoRelacionado.Id).SEG_N_operaciones_del_caso__c == null) {
                        casoRelacionado.SEG_N_operaciones_del_caso__c = 1;
                    }
                }
            }
        }

        if (!casosRelacionadosSegmentos.isEmpty()) {
            CBK_DMLUtility.updateRecords(casosRelacionadosSegmentos);
        }
    }
}