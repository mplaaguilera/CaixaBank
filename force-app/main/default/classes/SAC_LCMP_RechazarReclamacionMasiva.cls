/*****************************************************************************************
 * Name: SAC_LCMP_RechazarReclamacionMasiva
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador para poder rechazar tareas desde la list view
 * LWC asociado: sac_RechazarReclamacionMasiva
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE          Description
 * 1.0             DE71399       Sergio Martín    23/02/2023       Creación 
******************************************************************************************/
public without sharing class SAC_LCMP_RechazarReclamacionMasiva {

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

    /*************************************************************************
     * Proposito: Rechazar los casos seleccionados en las list view
     * ***********************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0             DE71399       Sergio Martín    23/02/2023       Creación     
    *************************************************************************/
    @AuraEnabled
    public static string rechazarCasos(String motivo, String recordId, String mensaje) {
        List<String> lstRecordsId = recordId.split(',');
        String result;

        List<Case> casosRechazar = new List<Case>();
        List<Case> casosSeleccionados = new List<Case>();
        List<Id> listaCasosId = new List<id>();
        Boolean esCopsAj = esCopsAj();

        if(esCopsAj) {
            // Recuperar la lista de casos de los que se han seleccionado
            if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'No tienes permisos para realizar esta acción.' ); }
            casosSeleccionados = [SELECT Id, status, SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c, CC_Rechazar_Reabrir_Caso__c FROM Case WHERE Id IN :lstRecordsId AND RecordTypeId =: RECTYPERECLAMACION];

            if(!casosSeleccionados.isEmpty()) {
                for(Case caso : casosSeleccionados) {
                    casosRechazar.add(caso);
                    listaCasosId.add(caso.Id);
                }
            }  
        } else {
            List<Id> lstGruposId = obtenerGruposAdmin();
            if(lstGruposId.size() == 0) {
                result =  'KO';
                return result;
            }

            // Recuperar la lista de casos de los que se han seleccionado que pertencen a los grupos del usuario
            if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'No tienes permisos para realizar esta acción.' ); }
            casosSeleccionados = [SELECT Id, status, SAC_StatusAuxiliar__c, SAC_MotivoRechazo__c, CC_Rechazar_Reabrir_Caso__c FROM Case WHERE Id IN :lstRecordsId AND SEG_Grupo__c IN :lstGruposId AND RecordTypeId =: RECTYPERECLAMACION];
            if(!casosSeleccionados.isEmpty()) {
                for(Case caso : casosSeleccionados) {
                    casosRechazar.add(caso);
                    listaCasosId.add(caso.Id);
                }
            }  
        }

        List<Case> casosActualizar = new List<Case>();

        // Comprobar que hay reclamaciones que tienen permiso para ser rechazadas
        if (casosRechazar.size() == 0 || lstRecordsId.size() != listaCasosId.size()) {
            result =  'KO';
            return result;
        } else {
            // Se recorren los casos a actualizar y se actualizan los campos
            for(Case caso : casosRechazar) {
                caso.Status = 'Rechazado';
                caso.SAC_StatusAuxiliar__c = 'Rechazado';
                caso.SAC_MotivoRechazo__c = motivo;
                if(caso.CC_Rechazar_Reabrir_Caso__c) {
                    caso.CC_Rechazar_Reabrir_Caso__c = false;
                }
                casosActualizar.add(caso); 
            }

            // Se recuperan las pretensiones de los casos a actualizar
            List<Case> pretensionesCasos = [SELECT Id FROM  Case WHERE SAC_Reclamacion__c IN :listaCasosId];
            if(!pretensionesCasos.isEmpty()) {
                for(Case pretensionCasos : pretensionesCasos) {
                    pretensionCasos.Status = 'SAC_009';
                    pretensionCasos.SAC_StatusAuxiliar__c = 'SAC_009';
                    casosActualizar.add(pretensionCasos);
                }
            }

            // Se updatean las reclamaciones y sus pretensiones
            if(Case.SObjectType.getDescribe().isUpdateable() && !casosActualizar.isEmpty()) {
                Database.SaveResult[] lstResp = Database.update(casosActualizar, false);
                for(Database.SaveResult res : lstResp) {
                    if (res.success) {
                        result = 'OK';

                        // Si hay un mensaje se llama a la función insertarComentario para crear los post de chatter
                        if(mensaje != '' && mensaje != null) {
                            insertarComentario(listaCasosId, mensaje);
                        }
                    }else{
                        CBK_Log.error('Error Rechazar reclamaciones masivas < 10 - Update KO - Response: ' + json.serialize(res.getErrors()));
                        for(Database.Error err : res.getErrors()) {
                            CBK_Log.error('Ha ocurrido el siguiente error: ');                    
                            CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                            return err.getMessage();
                        }
                    }
                }
            }
        }
        
        return result;
    }



    /***********************************************************************************************
     * Proposito: Obtener los grupos a los que pertenece como administrador y si pertenece a COPS/AJ
     * *********************************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0             DE71399       Sergio Martín    27/02/2023       Creación     
    ************************************************************************************************/
    public static List<Id> obtenerGruposAdmin() {
        // Sacar la lista de grupos en los que pertenece el usuario como admin y si pertenece a cops o AJ
        List<Id> lstGruposId = new List<Id>();
        if(!Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new AuraHandledException( 'No tienes permisos para realizar esta acción.' ); }
        List <CC_Grupo_Colaborador_Contact__c> gruposAdmin = [SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId() AND SAC_Administrador__c = true];
        if(!gruposAdmin.isEmpty()) {
            for(CC_Grupo_Colaborador_Contact__c grupo : gruposAdmin){
                lstGruposId.add(grupo.CC_Grupo_Colaborador__c);
            }
        }

        return lstGruposId;
    }


    /***********************************************************************************************
     * Proposito: Obtener si el usuario pertenece a COPS o AJ
     * *********************************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0             DE71399       Sergio Martín    28/02/2023       Creación     
    ************************************************************************************************/
    public static Boolean esCopsAj() {
        // Sacar si el usuario pertenece a COPS o AJ
        if(!Schema.sObjectType.User.isAccessible()){ throw new AuraHandledException( 'No tienes permisos para realizar esta acción.' ); }
        User usuarioActual = [SELECT Id, SAC_PerteneceCOPSAJ__c  FROM User WHERE Id =: UserInfo.getUserId()];
        return usuarioActual.SAC_PerteneceCOPSAJ__c;
    }




    /*****************************************************************************
     * Proposito: Método para insertar un post en el chatter del caso 
     * ***************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             DE71399       Sergio Martín    27/02/2023     Creación   
    *****************************************************************************/
    @AuraEnabled
    public static void insertarComentario(List<Id> lstRecord, String mensaje){
        List<FeedItem> lstChatterPost = new List<FeedItem>();
        if(Schema.sObjectType.FeedItem.isCreateable()){
            for(Id caso : lstRecord) {
                lstChatterPost.add(new FeedItem(ParentId = caso, Body = mensaje));
            }
            Database.insert(lstChatterPost);
        }         
    }    
}