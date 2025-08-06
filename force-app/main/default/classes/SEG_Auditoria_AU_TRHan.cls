public with sharing class SEG_Auditoria_AU_TRHan extends CC_TriggerHandlerBase{
    /**
    * @description   Método principal del trigger
    * param tp -> Contexto del trigger.
    */ 
    public override void mainEntry(CC_TriggerParameters tp) {
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId();
        List<SEG_Auditoria__c> segAuditorias = new List<SEG_Auditoria__c>();

        for(SEG_Auditoria__c aud : (List<SEG_Auditoria__c>)tp.newList){
            if(aud.RecordTypeId == recordTypeSEG){
                segAuditorias.add(aud);
            }
        }

        if(segAuditorias.size()>0){
            process(segAuditorias, (Map<ID, SEG_Auditoria__c>)tp.newMap,(List<SEG_Auditoria__c>)tp.oldList, (Map<Id, SEG_Auditoria__c>)tp.oldMap);
        }
    }
    private void process(List<SEG_Auditoria__c> listObj, Map<ID, SEG_Auditoria__c> mapObj,List<SEG_Auditoria__c> listOldObj, Map<ID, SEG_Auditoria__c> mapOldObj)
    {
        List<Id> procesarAud = new List<Id>();
        for (SEG_Auditoria__c auditId : listObj)
        {

            if (String.isNotBlank(mapObj.get(auditId.Id).SEG_Resultado__c))
            {
                procesarAud.add(auditId.Id);
            }
        }
        if(procesarAud.size()>0)
        {
            procesarEstadosAuditoriaManual(listObj);                                                       		
        }
    }
    
    private void procesarEstadosAuditoriaManual (List<SEG_Auditoria__c> listNewObj){
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId();
        Set<Id> casId = New Set<Id>();
        List<Task> listadoTareasInsertar = new List<Task>();
        for(SEG_Auditoria__c audits:listNewObj)
        {
            casId.add(audits.SEG_NumeroSR__c);
        }
        
        //Map<Id, Case> caseMap = new Map<Id,Case>([SELECT Id,Account.CC_Numero_Documento__c FROM Case WHERE Id IN :casId]);
        List<Case> caseLst = new List<Case>([SELECT Id,Account.CC_Numero_Documento__c,Status,SEG_Subestado__c,CC_Detalles_Consulta__c FROM Case WHERE Id IN :casId]);
        /*System.debug('TRIGGER AU AUDITORIAS CASIDSET :' + casId);
        System.debug('Trigger auditorias caseLst: ' + caseLst);
        for(SEG_Auditoria__c auditorias:listNewObj)
        {

        }*/

        // Recuperar el grupo BO para las activaciones del caso.
        Id grupoBO = SEG_MetodosComunes.recuperarGrupoBO();

        // Tratamiento de los casos en base al estado de las auditorías.
        List<FeedItem> listadoFeeds = new List<FeedItem>();
        List<Case> listadoCaseUpdate = new List<Case>();
        Boolean auditoriaOK = false;
        Boolean auditoriaNOK = false;
        Boolean auditoriaPAK = false;
        Boolean auditoriaOtros = false;
        String caseAuditoriaId = '';
        Case actualizarCaso = new Case();
        Map<Id, ResultadoAuditorias> caseAuditMap = new Map<Id, ResultadoAuditorias>();

        for (AggregateResult aggregateResult : [SELECT SEG_NumeroSR__c, SEG_Resultado__c, COUNT(Id)
                                                FROM SEG_Auditoria__c 
                                                WHERE SEG_NumeroSR__c IN :caseLst
                                                AND RecordTypeId = : recordTypeSEG
                                                GROUP BY SEG_NumeroSR__c, SEG_Resultado__c])
        {
            //Boolean auditoriaOK = false;
            //Boolean auditoriaNOK = false;
            //Boolean auditoriaPAK = false;
            caseAuditoriaId = String.valueOf(aggregateResult.get('SEG_NumeroSR__c'));

            // Preparar el objeto caso para actualizar.
            //Case actualizarCaso = new Case();
            actualizarCaso.Id = caseAuditoriaId;

            // Calcular estado auditorías.
            auditoriaOK = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) == 'OK') ? true : auditoriaOK;
            auditoriaNOK = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) == 'NOK') ? true : auditoriaNOK;
            auditoriaPAK = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) == 'PAK') ? true : auditoriaPAK;
            auditoriaOtros = (String.valueOf(aggregateResult.get('SEG_Resultado__c')) != 'PAK' && String.valueOf(aggregateResult.get('SEG_Resultado__c')) != 'NOK' && String.valueOf(aggregateResult.get('SEG_Resultado__c')) != 'OK') ? true : auditoriaOtros;

            ResultadoAuditorias wb = new ResultadoAuditorias();
            wb.boolAuditoriaOK = auditoriaOK;
            wb.boolAuditoriaNOK = auditoriaNOK;
            wb.boolAuditoriaPAK = auditoriaPAK;
            wb.boolAuditoriaOtros = auditoriaOtros;
            caseAuditMap.put(caseAuditoriaId, wb);
            
        }
        String grupoRev = Label.SEG_Grupo_revisi_n_Macro;
        List<CC_Grupo_Colaborador__c> grColabList = new List<CC_Grupo_Colaborador__c>([SELECT Id, Name  FROM CC_Grupo_Colaborador__c where Name =: grupoRev]);

        if(!caseAuditMap.isEmpty()){

            for(Id caseSR : caseAuditMap.keySet()) {
                if (caseAuditMap.get(caseSR).boolAuditoriaOK == true && caseAuditMap.get(caseSR).boolAuditoriaNOK == false && caseAuditMap.get(caseSR).boolAuditoriaPAK == false && caseAuditMap.get(caseSR).boolAuditoriaOtros == false)
                {
                    // Si todas las auditorias son OK.
                    actualizarCaso.Status = 'Cerrado';
                    actualizarCaso.SEG_Subestado__c = null;
                    actualizarCaso.CC_Detalles_Consulta__c = 'Caso cerrado';
                    listadoCaseUpdate.add(actualizarCaso);
        
                    SEG_Case_Operativas_Controller.postOnChatterObject (caseSR, 'Cierre del caso Usuario manera manual AUP', 'Cambio manual Ficha Auditoria', null, listadoFeeds);
        
                }else if (caseAuditMap.get(caseSR).boolAuditoriaNOK == true || caseAuditMap.get(caseSR).boolAuditoriaPAK == true)
                {
                    Id grupoRevId;
                    if(!grColabList.isEmpty()){
                        for(CC_Grupo_Colaborador__c grupcol : grColabList){
                            grupoRevId = grupcol.Id;
                            system.debug('Auditorías grupo revisión '+ grupcol);
                        }
                    }
                    // Si alguna de las auditorias es NOK o PAK.
                    actualizarCaso.Status = 'Activo';
                    actualizarCaso.SEG_Subestado__c = null;
                    If(grupoRevId != null){
                        actualizarCaso.SEG_Grupo__c = grupoRevId;
                    }
        
                    // Si estamos en contexto de Robotics, asignar al grupo BO. 
                    if (FeatureManagement.checkPermission('SEG_CrearAuditoriaSinOwnerCaso'))
                    {
                        actualizarCaso.OwnerId = grupoBO;
                    }
                    listadoCaseUpdate.add(actualizarCaso);
        
                    String textoTarea = 'Activación del caso de manera manual. Resultado auditoria: ' + ((auditoriaNOK == true) ? 'NOK' : 'PAK');
                    textoTarea = textoTarea + '\nDetalle: error';
                    SEG_Case_Operativas_Controller.postOnChatterObject (caseAuditoriaId, textoTarea, 'Cambio manual Ficha Auditoria', null, listadoFeeds);
                }  
            }
        }

        if (!listadoFeeds.isEmpty())
        {
            insert listadoFeeds;
        }

        if (!listadoCaseUpdate.isEmpty())
        {
            update listadoCaseUpdate;
        }        
    }
    public class ResultadoAuditorias{
        private boolean boolAuditoriaOK;
        private boolean boolAuditoriaNOK;
        private boolean boolAuditoriaPAK;
        private boolean boolAuditoriaOtros;
    }
}