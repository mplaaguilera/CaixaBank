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
    
    *****************************************************************/

    public static void relacionarProcesoCliente(Map<Id,SIREC__SIREC_obj_personaAsociada__c> mapPersonaAsociada) {
     
        Set<Id> setProcesoId = new Set<Id>();
        Map<Id,SIREC__SIREC_obj_personaAsociada__c> mapPersonaPersonaAsociada = new Map<Id,SIREC__SIREC_obj_personaAsociada__c>();
        Set<Id> setClientesId = new Set<Id>();
        for(SIREC__SIREC_obj_personaAsociada__c personaAsociada : (List<SIREC__SIREC_obj_personaAsociada__c>)mapPersonaAsociada.values()){
            if(personaAsociada.SIREC__SIREC_fld_IndMasRiesgo__c == 'S'){
                setProcesoId.add(personaAsociada.SIREC__SIREC_fld_proceso__c);
                setClientesId.add(personaAsociada.SIREC__SIREC_fld_persona__c);
                mapPersonaPersonaAsociada.put(personaAsociada.SIREC__SIREC_fld_proceso__c,personaAsociada);
            }
        }

        // leer los procesos que llegaron en personaAsociada con indMasRiesgo=S y que ahora no tengan cliente asignado o el ownwer sea SSMM 
        Map<Id, SIREC__SIREC_obj_proceso__c> mapProcesos = new Map<Id, SIREC__SIREC_obj_proceso__c>([SELECT Id, Name, SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_informacionCliente__c
                                                                                                            FROM SIREC__SIREC_obj_proceso__c 
                                                                                                            WHERE Id IN :setProcesoId 
                                                                                                            AND (SIREC__SIREC_fld_cliente__c = '' OR Owner.Profile.Name LIKE 'API%')]);
        //leer sobre Informacion Cliente todos los clientes a asignar
        List<SIREC__SIREC_obj_informacionCliente__c> lstInfoCliente = new List<SIREC__SIREC_obj_informacionCliente__c>([SELECT id, SIREC__SIREC_fld_cliente__c from SIREC__SIREC_obj_informacionCliente__c  WHERE SIREC__SIREC_fld_cliente__c IN :setClientesId]);
        //crear un mapa de id de cliente a Id de informacionCliente
        Map<Id, Id> mapAccount = new Map<Id, Id>();
        for (SIREC__SIREC_obj_informacionCliente__c info : lstInfoCliente){
            mapAccount.put(info.SIREC__SIREC_fld_cliente__c, info.Id);
        }

        if(mapProcesos.keyset().size() > 0){
            //asignar el cliente al proceso utilizando la relacion de personaAsociada 
            for(Id procesoId : mapProcesos.keyset()){                
                Id accountId = mapPersonaPersonaAsociada.get(procesoId).SIREC__SIREC_fld_persona__c;              
                mapProcesos.get(procesoId).SIREC__SIREC_fld_cliente__c = accountId;
                
                //asignar a la lookup de informacion cliente en el proceso 
                mapProcesos.get(procesoId).SIREC__SIREC_fld_informacionCliente__c = mapAccount.get(accountId);
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