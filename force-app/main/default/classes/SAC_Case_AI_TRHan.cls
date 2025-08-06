public without sharing class SAC_Case_AI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
	}    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        for (Schema.RecordTypeInfo rt: lstRT){
            if (rt.getDeveloperName().left(4)=='SAC_') {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }
        List<Case> listNewObjSAC= New List<Case>();
        Map<Id, Case> mapNewObjSAC = New Map<Id, Case>();
        for (Case tk: listNewObj){
            if((setIdsRt).contains(tk.RecordTypeId)){
                listNewObjSAC.add(tk);
                mapNewObjSAC.put(tk.Id,tk);
            }
        }
        if (listNewObjSAC.size()!=0) {
            processSAC(listNewObjSAC,mapNewObjSAC);
        }
    }
    private void processSAC(List<Case> listNewObj, Map<Id, Case> mapNewObj){
        
        //Obtener record Type
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Id recTypeConsulta = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();

        List<Case> listaCasos = new List<Case>();
        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();
        List<Case> listaConsultas = new List<Case>();
        List<Case> listaRecPretCons = new List<Case>();
        List<Case> listaRecOrigenEmail = new List<Case>();
        List<Case> listaPretenConPadre = new List<Case>();
        List<Case> listaCasosReglaClasif = new List<Case>();
        List<Case> listaPretensionesCreadasCerradas = new List<Case>();
        List<Id> listaIdsCuentas = new List<Id>();
        List<Id> listaIDsReclamacionGlobal = new List<Id>();
        Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();
        
        for (case caso : listNewObj) {
            if (caso.RecordTypeId == recTypePretension) { 
                listaPretensiones.add(caso); 
                listaCasos.add(caso);
                listaRecPretCons.add(caso);
                if(caso.SAC_Reclamacion__c != null){
                    listaIDsReclamacionGlobal.add(caso.SAC_Reclamacion__c);
                    listaPretenConPadre.add(caso);
                }
                if(caso.Status == 'SAC_003') {
                    listaPretensionesCreadasCerradas.add(caso);
                }
            }
            else if(caso.RecordTypeId == recTypeReclamacion){
                if (caso.AccountId != null) { 
                    listaIdsCuentas.add(caso.AccountId);
                }
                
                if(caso.Origin == 'Email' || caso.Origin == 'SAC_Formulario' || caso.Origin == 'SAC_CartaPostal'  ){  /* || caso.Origin == 'SAC_FormularioOficina' */ 
                    listaRecOrigenEmail.add(caso);
                }

                //Si es una reclamación a la que se le ha puesto una regla de clasificación al insertarse
                if (String.isNotBlank(caso.OS_ReglaUtilizada__c)) {
                    listaCasosReglaClasif.add(caso);
                }
                listaReclamaciones.add(caso);
                listaCasos.add(caso);
                listaRecPretCons.add(caso);
            }
            else if(caso.RecordTypeId == recTypeConsulta){
                //Si es una consulta a la que se le ha puesto una regla de clasificación al insertarse
                if (String.isNotBlank(caso.OS_ReglaUtilizada__c)) {
                    listaCasosReglaClasif.add(caso);
                }
                listaConsultas.add(caso);
                listaRecPretCons.add(caso);
                //listaRecOrigenEmail.add(caso);
            }
        }

        List<Case> listaCasosSelect = new List<Case>();
        listaCasosSelect = [SELECT Id, SAC_Reclamacion__c, Status, RecordTypeId, SEG_Detalle__c,subject, ownerId, AccountId, SEG_Grupo__c, isClosed, CaseNumber,
                            SAC_Letrado__c, Owner.Name
                            FROM Case
                            WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension) AND (
                            (RecordTypeId = :recTypeReclamacion AND isClosed = false  AND AccountId IN :listaIdsCuentas)
                            OR (RecordTypeId = :recTypePretension  AND SAC_Reclamacion__c IN: listaIDsReclamacionGlobal AND Status != 'SAC_009')
                            OR (RecordTypeId = :recTypeReclamacion AND Id IN :listaIDsReclamacionGlobal)
                            )];

        if (!listaReclamaciones.isEmpty()) {
            SAC_Notificacion.notificarCasoCreadoVinculado(listaCasosSelect, listaReclamaciones, listaIdsCuentas);
            SAC_TMOGlobal.insertarTMOs(listaReclamaciones);
        }
        if(!listaPretensiones.isEmpty()){
            SAC_Pretension.insertarPermisosPretension(listaPretensiones);
            if(!listaPretenConPadre.isEmpty() && !System.isQueueable()){ SAC_Pretension.calcularPretensionesActivas(listaPretenConPadre, listaCasosSelect, mapaDatosCasosActualizar);}
            if (!listaPretenConPadre.isEmpty()) {
                SAC_Pretension.informarLetrado(listaPretenConPadre, listaCasosSelect, mapaDatosCasosActualizar);
                SAC_HandlerMethods.comprobarE2ERec(listaPretenConPadre, listaIDsReclamacionGlobal, true, recTypeReclamacion, recTypePretension);
            }
            SAC_TMOGlobal.insertarTMOs(listaPretensiones);
        }
        if(!listaCasos.isEmpty()){
            SAC_HandlerMethods.createReclamanteRecord(listaCasos, null);
        }
        if(!listaConsultas.isEmpty()){
            SAC_HandlerMethods.createReclamanteRecord(listaConsultas, null);
        }
        if (!listaRecPretCons.isEmpty()) {
            SAC_AsignarTMEs.changeSLA(listaRecPretCons);
            SAC_HandlerMethods.creacionCaseExtension(listaRecPretCons);
        }
        //Llamada queueable para poner thread id, cambiar estados del caso cuando traen una regla de clasificación, y enviar el acuse de recibo
        //Añadida la condición '!System.isQueueable()' para evitar el error al copiar reclamaciones con origen email
        if ((!listaRecOrigenEmail.isEmpty() || !listaCasosReglaClasif.isEmpty()) && !System.isQueueable()) {
            DateTime dt = DateTime.now();
            Long dateInMilliseconds = dt.getTime();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
            try {
                System.enqueueJob(new SAC_QueueableCaseAI(listaRecOrigenEmail, listaCasosReglaClasif, mapaDatosCasosActualizar), options);    
            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }    
        }

        if (!listaPretensionesCreadasCerradas.isEmpty()) {
            SAC_HandlerMethods.insertarCaseSharePretensionCerrada(listaPretensionesCreadasCerradas);
        }

        if(!mapaDatosCasosActualizar.isEmpty()){
            update mapaDatosCasosActualizar.values();
        }
        
    }
}