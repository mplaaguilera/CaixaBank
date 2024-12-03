/*****************************************************************
 * Name: SAC_LCMP_DesvincularReclamacion
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_DesvincularReclamacion.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US233793         Carlos Solis   15/06/21      Creación
*****************************************************************/
public without sharing class SAC_LCMP_DesvincularReclamacion {
    /*****************************************************************
    * Proposito: Buscar las reclamaciones vinculadas a la reclamación en la que se encuentra el componente
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US233793         Carlos Solis   15/06/21     Creación
    *****************************************************************/
    @AuraEnabled(cacheable = true)
    public static List<Case> reclamacionesVinculadas(Id caseId) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        List<Case> listaCasosRelacionados = new List<Case>();

        listaCasosRelacionados = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE RecordTypeId = :recTypeReclamacion
                                    AND CC_CasoRelacionado__c = :caseId];

        return listaCasosRelacionados;
    }

    /*****************************************************************
    * Proposito: Buscar las Consultas vinculadas a la reclamación en la que se encuentra el componente
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US277103       Marcela Neira    20/10/21     Creación
                                    Daniel Benito   
    *****************************************************************/
    @AuraEnabled(cacheable = true)
    public static List<Case> consultasVinculadas(Id caseId) {
        Id recTypeConsulta = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeConsultaSAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();
        List<Case> listaConsultasRelacionados = new List<Case>();

        listaConsultasRelacionados = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c 
                                    FROM Case WHERE ((RecordTypeId = :recTypeConsulta OR RecordTypeId = :recTypeConsultaSAC)
                                    AND CC_CasoRelacionado__c = :caseId)];

        return listaConsultasRelacionados;
    }

    /*****************************************************************
    * Proposito: Desvincular la reclamación en la que se encuentra el botón 'Desvincular Reclamación' del componente
    * Si la reclamación que se está desvinculando estaba en inadmisión, se vuelve a abrir en estado de alta y se
    * vuelve a abrir su SLA. Devuelve el mensaje succes que se mostrará en el toast del componente lightning
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US233793         Carlos Solis   16/06/21     Creación
    *****************************************************************/
    @AuraEnabled
    public static String desvincularReclamacion(Id caseId) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        String mensajeDesvinculacion = 'Se ha completado la desvinculación de la reclamación';
        List<Case> listaReclamacionesDesvincular = new List<Case>();
        List<Case> listaPretensionesHijas = new List<Case>();
        List<Id> listaIdsCase = new List<Id>();
        List<CaseMilestone> listaCaseMile = new List<CaseMilestone>();

        listaReclamacionesDesvincular = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, Status, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE RecordTypeId = :recTypeReclamacion
                                    AND id = :caseId];

        if (!listaReclamacionesDesvincular.isEmpty()) {
            for (Case caso : listaReclamacionesDesvincular) {
                caso.CC_CasoRelacionado__c = null;
                if (caso.Status == 'SAC_005') { //Inadmisión
                    caso.Status = 'SAC_001';
                    caso.SAC_StatusAuxiliar__c = 'SAC_001';
                    mensajeDesvinculacion = 'Se ha desvinculado la reclamación y se ha vuelto a abrir (Alta)';
                    listaIdsCase.add(caso.Id);
                }
            }
            if (!listaIdsCase.isEmpty()) {
                listaPretensionesHijas = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c IN :listaIdsCase];
                if (!listaPretensionesHijas.isEmpty()) {
                    for (Case pretension : listaPretensionesHijas) {
                        pretension.Status = 'SAC_001';
                        pretension.SAC_StatusAuxiliar__c = 'SAC_001';
                        listaReclamacionesDesvincular.add(pretension);
                        listaIdsCase.add(pretension.Id);
                    }
                }
                listaCaseMile = [SELECT id, CaseId, CompletionDate FROM CaseMilestone WHERE CaseId IN :listaIdsCase];
                if (!listaCaseMile.isEmpty()) {
                    for (CaseMilestone cm : listaCaseMile) {
                        cm.CompletionDate = null;
                    }
                }
            }
            update listaReclamacionesDesvincular;
            if (!listaCaseMile.isEmpty()) {
                update listaCaseMile;
            }
        }
        return mensajeDesvinculacion;
    }

    /*****************************************************************
    * Proposito: Desvincular la Consulta en la que se encuentra el botón 'Desvincular Consulta' del componente
    * Devuelve el mensaje succes que se mostrará en el toast del componente lightning
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US277103       Marcela Neira    20/10/21     Creación
                                    Daniel Benito   
    *****************************************************************/
    @AuraEnabled
    public static String desvincularConsulta(Id caseId) { 

        Id recTypeTareas = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeConsulta = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeConsultaSAC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();

        //CC_Grupo_Colaborador__c cops =[SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c ='DXC Zaragoza' AND RecordTypeId =: recTypeTareas LIMIT 1];        
        //Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        String mensajeDesvinculacion = 'Se ha completado la desvinculación de la Consulta';
        List<Case> listaConsultasDesvincular = new List<Case>();
        List<Id> listaIdsCase = new List<Id>();
        List<CaseMilestone> listaCaseMile = new List<CaseMilestone>();

        listaConsultasDesvincular = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, Status, RecordTypeId, CC_CasoRelacionado__c 
                                    FROM Case 
                                    WHERE (RecordTypeId = :recTypeConsulta OR RecordTypeId = :recTypeConsultaSAC)
                                    AND id = :caseId];

        if (!listaConsultasDesvincular.isEmpty()) {
            for (Case consulta : listaConsultasDesvincular) {
                consulta.CC_CasoRelacionado__c = null; 
                /*Consulta.SEG_Grupo__c = cops.id;
                consulta.OwnerId= cola.id;*/
            }
        } 
        
        update listaConsultasDesvincular;

        return mensajeDesvinculacion;
    }

}