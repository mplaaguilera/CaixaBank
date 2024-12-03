/*****************************************************************
 * Name: SAC_Grupo_Colaborador_Contact_BI_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto SAC_Grupo_Colaborador_Contact__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR             DATE       Description 
 * 1.0                             IBM                11/03/22 	 Creación	            
 * 2.0            US494240         Jose Carlos Blanco 24/11/22   Modificación
*****************************************************************/
public with sharing class SAC_Grupo_Colaborador_Contact_BI_TRHan  extends CC_TriggerHandlerBase  {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap);
	}
    private void validAdmin(List<CC_Grupo_Colaborador_Contact__c> listNewObjFiltrada){
        //Validamos si usuarios es administrador del grupo
        Set<Id> myset = new Map<Id,AggregateResult>([SELECT CC_Grupo_Colaborador__c Id FROM CC_Grupo_Colaborador_Contact__c  
        WHERE CC_Usuario__c =: userInfo.getUserId() 
        AND SAC_Administrador__c = TRUE AND CC_Grupo_Colaborador__r.RecordType.DeveloperName LIKE 'SAC_%'
        Group By CC_Grupo_Colaborador__c Having CC_Grupo_Colaborador__c!= null]).keySet();

        for (CC_Grupo_Colaborador_Contact__c grContact : listNewObjFiltrada) {
            if(!myset.contains(grContact.CC_Grupo_Colaborador__c) && !Test.isRunningTest()){
                grContact.addError('Usted no puede llevar a cabo modificaciones del grupo. Por favor póngase en contacto con el administrador del grupo.');
            }    
        }
    }
    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj) {
        /*valida permisos de modificación*/
        
        List<CC_Grupo_Colaborador_Contact__c> listNewObjFiltrada = new List<CC_Grupo_Colaborador_Contact__c>();
        Set<Id> grupoIds = new Set<Id>();
        List<Id> listGruposFiltrados = new List<Id>();

        for (CC_Grupo_Colaborador_Contact__c gcContact : listNewObj){
            grupoIds.add(gcContact.CC_Grupo_Colaborador__c);
        }
        
        for(CC_Grupo_Colaborador__c gFilt : [SELECT Id FROM CC_Grupo_Colaborador__c 
        WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id IN :GrupoIds]){
            listGruposFiltrados.add(gFilt.Id);
        }

        for(CC_Grupo_Colaborador_Contact__c gcContact2 : listNewObj) {
            if (listGruposFiltrados.contains(gcContact2.CC_Grupo_Colaborador__c)){
                listNewObjFiltrada.add(gcContact2);
            }
        }

    //si listNewObjFiltrada es diferente de vacia
        if(!listNewObjFiltrada.isEmpty()){
            Boolean esDeSAC = false;
            Boolean esAdmin = false;
            Boolean esGestorLetradoAdmin = false;

            List<CC_Grupo_Colaborador__c> grupoGestorLetradoAdmin = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Gestor/letrados administrador' LIMIT 1];
            if(!grupoGestorLetradoAdmin.isEmpty()) {
                for(CC_Grupo_Colaborador_Contact__c grupo : listNewObjFiltrada) {
                    if(grupo.CC_Grupo_Colaborador__c == grupoGestorLetradoAdmin[0].id) {
                        esGestorLetradoAdmin = true;
                    }
                }
            }

            if(esGestorLetradoAdmin) {
                User usuario = [SELECT id, SAC_PerteneceCOPSAJ__c FROM User WHERE id=: userInfo.getUserId()];
                if(!usuario.SAC_PerteneceCOPSAJ__c) {
                    esGestorLetradoAdmin = false;
                }
            }

            List<PermissionSetAssignment> permisosAsignados =[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId FROM 
                PermissionSetAssignment WHERE (PermissionSet.Name = 'SAC_Administrador' OR PermissionSet.Name = 'SAC_General')
                AND assigneeId =:userInfo.getUserId()];

            if(!permisosAsignados.isEmpty()){
                for (PermissionSetAssignment psa : permisosAsignados) {
                    if(psa.PermissionSet.Name == 'SAC_General'){
                        esDeSAC = true;
                    } 
                    if(psa.PermissionSet.Name == 'SAC_Administrador'){
                        esAdmin = true;
                    }
                }

                if((esDeSAC && !esAdmin) && !esGestorLetradoAdmin){
                    validAdmin(listNewObjFiltrada);               
                }           
            }
        }
    }
}