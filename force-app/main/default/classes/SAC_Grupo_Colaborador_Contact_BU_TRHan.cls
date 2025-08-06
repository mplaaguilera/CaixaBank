public without sharing class SAC_Grupo_Colaborador_Contact_BU_TRHan extends CC_TriggerHandlerBase{
 /*********************************************************************************************************
 * Name: SAC_Grupo_Colaborador_Contact_BU_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Update del objeto SAC_Grupo_Colaborador_Contact__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0            US233800              Luis Mesa            21/06/21         Creación
 * 2.0            US494240              Jose Carlos Blanco   28/11/22         Modificación
**********************************************************************************************************/
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
	}

    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeLetrados =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
        Id recTypeAcciones =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        
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
        if(!listNewObjFiltrada.isEmpty()){
            Boolean esDeSAC = false;
            Boolean esAdmin = false;
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

                if(esDeSAC && !esAdmin){
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
                
                List<CC_Grupo_Colaborador_Contact__c> listadoRelacionado = new List<CC_Grupo_Colaborador_Contact__c>();

                List<CC_Grupo_Colaborador__c> listaFiltro = [SELECT Id, RecordTypeId
                    FROM CC_Grupo_Colaborador__c 
                    WHERE RecordTypeId =: recTypeAcciones 
                        OR RecordTypeId  =: recTypeLetrados 
                        OR RecordTypeId =: recTypeProveedores];


                Map<Id, List<CC_Grupo_Colaborador_Contact__c>> mapColabGrupo = new Map<Id, List<CC_Grupo_Colaborador_Contact__c>>();


                for(CC_Grupo_Colaborador__c gcc : listaFiltro){
                    List<CC_Grupo_Colaborador_Contact__c> listaVacia = new List<CC_Grupo_Colaborador_Contact__c>();
                    mapColabGrupo.put(gcc.Id, listaVacia);            
                }

                for(CC_Grupo_Colaborador_Contact__c colab : listNewObjFiltrada){
                    if(mapColabGrupo.containsKey(colab.CC_Grupo_Colaborador__c)){
                            listadoRelacionado.add(colab);
                    }
                }

                if(!listadoRelacionado.isEmpty()){
                    SAC_AdministrarUsuarios.asignarAdministradores(listadoRelacionado, mapOldObj);
                }
            }
        }
    }
}