/*****************************************************************
 * Name: SAC_Grupo_Colaborador_BU_TRHan
 * Copyright © 2019  CaixaBank
 *  
 * Proposito: Trigger Handler para controlar el Before Update del objeto CC_Grupo_Colaborador__c
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213183         Carlos Solis   13/05/21     Creación
 * 1.1            DE51351         Marcela Neira   06/09/21     Modificación (Que los grupos solo los pueda modificar un
 *                                                             usuario que tenga el permission set SAC_Administrador o es System Administrator)
 * 1.2            US304889         Marcela Neira  04/05/2022   Modificación para que el campo SAC_DeveloperName__c sea único.
*****************************************************************/
public with sharing class SAC_Grupo_Colaborador_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Grupo_Colaborador__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador__c>)tp.newMap, (List<CC_Grupo_Colaborador__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador__c>)tp.oldMap);
	}

    private void process(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapNewObj, List<CC_Grupo_Colaborador__c> listOldObj, Map<Id, CC_Grupo_Colaborador__c> mapOldObj) {
        //Obtener record Type
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeTareas =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeLetrados =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();

        Boolean puedeModificar = false;
        Id idUsuario =UserInfo.getUserId();
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> listaGruposSAC = new List<CC_Grupo_Colaborador__c>();

        List<PermissionSetAssignment> permisosAsignados =[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId 
                                                   FROM PermissionSetAssignment where assigneeId =:idUsuario];
        List<User> listaUsuario =[SELECT id, user.profile.name FROM user  WHERE user.profile.name like '%admin%' AND ID =: idUsuario];

        for(PermissionSetAssignment psa : permisosAsignados){
            if(psa.PermissionSet.Name=='SAC_Administrador' || !listaUsuario.isEmpty()){
                puedeModificar = true;
            }
        }        

        for (CC_Grupo_Colaborador__c grupo : listNewObj) {
            if((grupo.RecordTypeId == recTypeProveedores || grupo.RecordTypeId == recTypeTareas || grupo.RecordTypeId == recTypeLetrados) && !puedeModificar){
                grupo.addError('No tiene suficientes privilegios para hacer modificaciones');
            }    
            if(grupo.RecordTypeId == recTypeProveedores && puedeModificar) {
                listaGrupos.add(grupo);
            }
            if((grupo.RecordTypeId == recTypeProveedores || grupo.RecordTypeId == recTypeTareas || grupo.RecordTypeId == recTypeLetrados) && puedeModificar){
                listaGruposSAC.add(grupo);
            }
        }
        
        //Si la lista con los grupos no está vacia, trabajamos con nuestros métodos
        if (!listaGrupos.isEmpty()) {
            SAC_PorcentajesGrupoColaborador.comprobarPorcentajeUpdate(listaGrupos); //Comprueba que la suma del porcentaje de todos los grupos sea igual a 100
        }
        if(!listaGruposSAC.isEmpty()){
            SAC_GrupoColaboradorMetodos.validarDeveloperName(listaGruposSAC, mapOldObj);
        }
        
    }

}