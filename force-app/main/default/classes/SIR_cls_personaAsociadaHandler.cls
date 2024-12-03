/*****************************************************************
 Name:  SIR_cls_personaAsociadaHandler
 Copyright © 2021  CaixaBank

@description :   Clase handler para alojar los metodos que se invocan desde SIR_trg_personaAsociada                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244057         atmira         26/07/2021	      Created    

*****************************************************************/

public with sharing class SIR_cls_personaAsociadaHandler {

    /*****************************************************************
    @description : Alinear la relación de Proceso con el cliente y unificar el owner de ambos registros
    Parameters: Map<Id,sObject> mapPersonaAsociada
    Returns: Void                                                     
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244057         atmira         26/07/2021	      Created 
    1.1            US508059         atmira         12/01/2023	      Modificación de la lógica para que tenga cabida el tratamiento de las oficinas IMAGIN    
    *****************************************************************/

    public static void relacionarProcesoCliente(Map<Id,SIREC__SIREC_obj_personaAsociada__c> mapPersonaAsociada) {
        //Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
        Set<Id> setProcesoId = new Set<Id>();
        Map<Id,SIREC__SIREC_obj_personaAsociada__c> mapPersonaPersonaAsociada = new Map<Id,SIREC__SIREC_obj_personaAsociada__c>();
       // Map<Id,Id> mapClienteOwnersId = new Map<Id,Id>();
        Set<Id> setClientesId = new Set<Id>();
     /*  Set<Id> setUserPSAsigGestorImpaId = new Set<Id>();
        Set<Id> setUserPSAsigGestorPresolId = new Set<Id>();
        Set<Id> setUserPSAsigGestorEmpresaId = new Set<Id>();
     */  
        for(SIREC__SIREC_obj_personaAsociada__c personaAsociada : (List<SIREC__SIREC_obj_personaAsociada__c>)mapPersonaAsociada.values()){
            if(personaAsociada.SIREC__SIREC_fld_IndMasRiesgo__c == 'S'){
                setProcesoId.add(personaAsociada.SIREC__SIREC_fld_proceso__c);
                setClientesId.add(personaAsociada.SIREC__SIREC_fld_persona__c);
                mapPersonaPersonaAsociada.put(personaAsociada.SIREC__SIREC_fld_proceso__c,personaAsociada);
            }
        }

      /*  Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id, OwnerId, Owner.Profile.Name, AV_OficinaPrincipal__r.name 
                                                          FROM Account 
                                                          WHERE Id IN : setClientesId AND Owner.IsActive = True]);
        Set<Id> setOwnerIds = new Set<Id>();
        for(Account account : mapAccount.values()){
            setOwnerIds.add(account.OwnerId);
        }
*/
        Map<Id, SIREC__SIREC_obj_proceso__c> mapProcesos = new Map<Id, SIREC__SIREC_obj_proceso__c>([SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_estrategia__c,
                                                                                                            SIREC__SIREC_fld_situacion__c, SIREC__SIREC_fld_fechaInicio__c, OwnerId, recordtypeId, recordtype.Name, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.name
                                                                                                            FROM SIREC__SIREC_obj_proceso__c 
                                                                                                            WHERE Id IN :setProcesoId 
                                                                                                            AND (SIREC__SIREC_fld_cliente__c = '' OR Owner.Profile.Name LIKE 'API%')]);
        /*Id imaginUserId;
        Boolean existeIMAGIN = false;
        for(Account account : mapAccount.values()){
            if(!(String.isEmpty(account.AV_OficinaPrincipal__c)) && account.AV_OficinaPrincipal__r.name.contains('IMAGIN')){
                existeIMAGIN = true;
                break;
            }
        }
        if(existeIMAGIN){
            imaginUserId = [SELECT Id FROM User WHERE AV_ExternalID__c = :SIR_Variables__mdt.getInstance('IMAGINGestor').Valor__c].Id;
            setOwnerIds.add(imaginUserId);
        }
        */
        if(mapProcesos.keyset().size() > 0){
            
           /* Set<Id> setUserPSAsigId = new Set<Id>();
            for( PermissionSetAssignment psAsig : [SELECT Id, PermissionSetId, AssigneeId, PermissionSet.Name, PermissionSetGroup.DeveloperName
                                                    FROM PermissionSetAssignment 
                                                    WHERE AssigneeId IN :setOwnerIds AND
                                                    (PermissionSet.Name = :SIR_Constantes.PS_GESTOR_NAME OR 
                                                    PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_GESTOR_NAME OR 
                                                    PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_EXTERNO OR
                                                    PermissionSet.Name  = :SIR_Constantes.PS_GESTOR_NAME_EMP)]){
                if(psAsig.PermissionSet.Name == SIR_Constantes.PS_GESTOR_NAME_EMP){
                    setUserPSAsigGestorEmpresaId.add(psAsig.AssigneeId);
                }else{
                  setUserPSAsigId.add(psAsig.AssigneeId);  
                }
            }
            
            Set<Id> setEmpresaRTIds = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_EMPRESA_DEVELOPERNAME,SIR_Constantes.PROCESO_OBJECT_API_NAME);
            Set<Id> setRetailRTIds = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_RETAIL_DEVELOPERNAME,SIR_Constantes.PROCESO_OBJECT_API_NAME);
            */
            for(Id procesoId : mapProcesos.keyset()){
                
                mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c = mapPersonaPersonaAsociada.get(procesoId).SIREC__SIREC_fld_persona__c;              
                // Procesos de Retail
             /*   if(mapAccount.containskey(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c)
                    && setUserPSAsigId.contains(mapAccount.get(mapPersonaPersonaAsociada.get(procesoId).SIREC__SIREC_fld_persona__c).OwnerId)                    
                    && setRetailRTIds.contains(mapProcesos.get(procesoId).recordTypeId)){                        
                        if(!(String.isEmpty(mapAccount.get(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c).AV_OficinaPrincipal__c)) 
                            && mapAccount.get(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c).AV_OficinaPrincipal__r.name.contains('IMAGIN')){
                            mapProcesos.get(procesoId).OwnerId = imaginUserId;                            
                        }
                        else{
                            mapProcesos.get(procesoId).OwnerId = mapAccount.get(mapPersonaPersonaAsociada.get(procesoId).SIREC__SIREC_fld_persona__c).OwnerId;
                        }
                } 
                // Procesos de empresas
              	if(mapAccount.containskey(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c) &&
                    String.isNotBlank(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c)
                    && mapAccount.containsKey(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c)
                    && SetEmpresaRTIds.contains(mapProcesos.get(procesoId).recordTypeId)
                    && setUserPSAsigGestorEmpresaId.contains(mapAccount.get(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c).OwnerId)){
                        mapProcesos.get(procesoId).OwnerId = mapAccount.get(mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c).OwnerId;                        
                	}
                */    
            }
            Database.SaveResult[] srList = Database.update(mapProcesos.values(), false);
            for (Integer i = 0; i < mapProcesos.values().size(); i++) {
                Database.SaveResult sr = srList[i];
                SIREC__SIREC_obj_proceso__c origRecord = mapProcesos.values()[i];
                if (!sr.isSuccess()) {
                    for(Database.Error objErr : sr.getErrors()) {
                        mapPersonaAsociada.get(mapPersonaPersonaAsociada.get(origRecord.Id).Id).addError('SIR_cls_personaAsociadaHandler ' + objErr.getStatusCode() + ': ' + objErr.getMessage());
                    }
                } 
            }            
        }             
    }
}