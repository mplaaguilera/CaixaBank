/*****************************************************************
 Name:  SIR_Account_BU_TRHan
 Copyright © 2021  CaixaBank

Proposito:   Clase handler para alojar los metodos que se invocan desde SIR_trg_proceso   

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244057         atmira         03/09/2021	      Created    

*****************************************************************/

public without sharing class SIR_Account_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		updateGestor((Map<Id,Account>)tp.oldMap, (Map<Id, Account>)tp.newMap);
	}

    private void updateGestor(Map<Id,Account> mapOldCliente, Map<Id, Account> mapCliente){
        
        Set<Id> setOwnerIds = new Set<Id>();
        Boolean changeOwner = false;
        for(Account cliente : mapCliente.values()){
            if(cliente.OwnerId != mapOldCliente.get(cliente.Id).OwnerId){
                changeOwner = true;          
                setOwnerIds.add(cliente.OwnerId);      
            }
        }
        if(changeOwner){
            Set<Id> setUserPSAsigId = new Set<Id>();
            Set<Id> setUserPSAsigGestorEmpresaId = new Set<Id>();
            for( PermissionSetAssignment psAsig : [SELECT Id, PermissionSetId, AssigneeId, PermissionSet.Name 
                                                    FROM PermissionSetAssignment 
                                                    WHERE AssigneeId IN :setOwnerIds AND
                                                    (PermissionSet.Name = :SIR_Constantes.PS_GESTOR_NAME 
                                                    OR PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_GESTOR_NAME 
                                                    OR PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_EXTERNO
                                                    OR PermissionSet.Name  = :SIR_Constantes.PS_GESTOR_NAME_EMP)]){
                if(psAsig.PermissionSet.Name == SIR_Constantes.PS_GESTOR_NAME_EMP){
                    setUserPSAsigGestorEmpresaId.add(psAsig.AssigneeId);
                }else{
                  setUserPSAsigId.add(psAsig.AssigneeId);  
                }                
            }
    
            Set<Id> setClienteIds = new Set<Id>();
            Map<Id, Id> mapClienteGestor = new Map<Id, Id>();
            for(Account cliente : mapCliente.values()){
                // si ha cambiado el owner del cliente y el owner tiene el permiso de RETAIL o el de EMPRESAS nos quedamos con el cliente para modificar el owner en el resto de objetos
                if(cliente.OwnerId != mapOldCliente.get(cliente.Id).OwnerId && 
                   (setUserPSAsigId.contains(cliente.OwnerId) || setUserPSAsigGestorEmpresaId.contains(cliente.OwnerId))){
                    setClienteIds.add(cliente.Id);
                    mapClienteGestor.put(cliente.Id, cliente.OwnerId);
                }
            }
            /*
            Se controla el permiso de acceso y de actualización de los objectos que contendrías la lista de Objects, aunque el PMD sigue dando un warning
             */
            List<SObject> lstObjectToUpdate = new List<SObject>();
            try {   
                Set<Id> setEmpresaRTIds = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_EMPRESA_DEVELOPERNAME,SIR_Constantes.PROCESO_OBJECT_API_NAME);
                Set<Id> setRetailRTIds = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_RETAIL_DEVELOPERNAME,SIR_Constantes.PROCESO_OBJECT_API_NAME);
                
                if(setClienteIds.size() > 0 && 
                    Schema.sObjectType.SIREC__SIREC_obj_proceso__c.fields.OwnerId.isUpdateable() &&
                    Schema.sObjectType.SIR_FormularioRefinanciacion__c.fields.OwnerId.isUpdateable()){  

                    List<Id> lstUserIdsDXC =  SIR_cls_Utils.getUsersDXC(); 

                    for(SIREC__SIREC_obj_proceso__c proceso : [SELECT Id, OwnerId, Owner.Name, recordtype.Name, Name, SIREC__SIREC_fld_cliente__c, recordtypeId 
                                                                FROM SIREC__SIREC_obj_proceso__c 
                                                                WHERE SIREC__SIREC_fld_cliente__c IN : setClienteIds and SIREC__SIREC_fld_situacion__c != :SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                                                                AND ownerId not in :lstUserIdsDXC]){
                        if((setUserPSAsigId.contains(mapCliente.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId)
                        && setRetailRTIds.contains(proceso.recordTypeId)) ||
                        ((setUserPSAsigGestorEmpresaId.contains(mapCliente.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId)
                        && setEmpresaRTIds.contains(proceso.recordTypeId)))){
                            proceso.OwnerId = mapClienteGestor.get(proceso.SIREC__SIREC_fld_cliente__c);
                            lstObjectToUpdate.add(proceso);
                        }                           
                    }
                    for(SIR_FormularioRefinanciacion__c formulario : [SELECT Id, OwnerId, SIR_Persona__c, Name FROM SIR_FormularioRefinanciacion__c WHERE SIR_Persona__c IN : setClienteIds]){
                        formulario.OwnerId = mapClienteGestor.get(formulario.SIR_Persona__c);
                        lstObjectToUpdate.add(formulario);
                    }                    
                    if(lstObjectToUpdate.size() > 0 ){
                        update lstObjectToUpdate;
                    }
                }
            }catch (Exception ex) {
                CBK_log.error(ex, 'Error : SIR_Account_BU_TRHan.updateGestor - '+ UserInfo.getName() + ' - '  + ex.getTypeName() + ' : ' + ex.getMessage(), lstObjectToUpdate);
            }
        }
  
    }
}