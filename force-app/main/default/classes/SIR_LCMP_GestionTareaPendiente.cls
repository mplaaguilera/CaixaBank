/*****************************************************************
 Name:  SIR_LCMP_GestionTareaPendiente
 Copyright © 2022  CaixaBank

Proposito:   Clase controladora del LWC Sir_lwc_GestiionTareaPendiente                                                                                                                 

Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         04/05/2022     	 Created    

*****************************************************************/
public with sharing class SIR_LCMP_GestionTareaPendiente {
   
    /**********************************************************************/
    /*    Proposito: llamar a WS para sincronizar la situacion y la tarea */
    /*               pendiente con SIREC                                  */
    /**********************************************************************/
    @AuraEnabled(cacheable=false)    
    // los parametros gestiona y tipoGestor se definen para que el LWC se quede esperando a que esten definidos
    public static List<String> sincronizaProceso(String idProceso){        
         // Llamar al WS para sincronizar el proceso
         List<String> resultadoWS = new List<String>();                    
         resultadoWS = SIR_cls_gestorMotor.procesoInfo(idProceso);                 
         return resultadoWS;
    }

    /******************************************************************/
    /*    Proposito: Consultar la tarea actual del proceso            */
    /**************************************************************** */
    @AuraEnabled(cacheable=true)
    // el parametro sincronizado se define en el lwc una vez se haya ejecutado el metodo sincronizaProceso
    public static List<SIREC__SIREC_obj_proceso__c> getTipoTarea(String idProceso, Boolean sincronizado){
        List<SIREC__SIREC_obj_proceso__c> procesosLst = new List<SIREC__SIREC_obj_proceso__c>();        
            
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){                
            procesosLst = [SELECT id, name, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_masterRecordId__c,
                            SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c,
                            OwnerId, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c, recordType.Name, TYPEOF Owner WHEN User THEN Name, AV_NumeroOficinaEmpresa__c, Profile.Name  ELSE Name, Profile.Name END
                            FROM SIREC__SIREC_obj_proceso__c 
                            WHERE id =: idProceso
                            LIMIT 1];
            if(procesosLst.size() == 0) {
                throw new AuraHandledException('El idProceso : ' + idProceso + ' no existe');
            }
        }

        return procesosLst;
    }
    
    /*****************************************************************
        Proposito: Consultar si la accion relacionada con la tarea 
                   ya ha sido enviada correctamente a SIREC
        Parameters: String
        Returns: Boolean                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         25/10/2022     	  Created    
        
	*****************************************************************/                              
    @AuraEnabled
    public static Boolean accionEnviada(String idTarea) {
        // si existe una accion ya enviada para la tarea consultada la funcion retorna true, sino falso
        return [SELECT ID FROM SIREC__SIREC_obj_acciones__c  WHERE SIREC__SIREC_fld_tarea__c  =: idTarea  AND SIR_accionEnviada__c = true].size()>0;
    }  
    
    /*****************************************************************
        Proposito: Validar si el proceso puede ser gestionado por el usuario conectado
        Parameters: String
        Returns: Boolean                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/06/2023     	  Created    
        
	*****************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static Boolean puedeGestionar(String idProceso){        
        List<SIREC__SIREC_obj_proceso__c> procesosLst = new List<SIREC__SIREC_obj_proceso__c>();  
        if(SIREC__SIREC_obj_proceso__c.SObjectType.getDescribe().isAccessible()){                
            procesosLst = [SELECT id, name, SIREC__SIREC_fld_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c, SIR_EmpleadoPREVEMP__c,
                            SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c, SIR_AnalistaRiesgo__c,
                            OwnerId, SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c, recordType.Name, SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.CC_Numero_Oficina_Empresa__c, 
                            TYPEOF Owner WHEN User THEN Name, AV_NumeroOficinaEmpresa__c, Profile.Name  ELSE Name, Profile.Name END
                            FROM SIREC__SIREC_obj_proceso__c WHERE id =: idProceso and Owner.Type = 'User' LIMIT 1];
            if(procesosLst.size() == 0){
                return false;
             // Si el proceso es Retail y el usuario conectado es el propietario del proceso puede gestionarlo
            } else if(( procesosLst.get(0).recordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO || procesosLst.get(0).recordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL) 
                     && procesosLst.get(0).OwnerId == UserInfo.getUserId()){
                        return true;
            // Si es proceso Preventivo y SIR_EmpleadoPREVEMP__c == 'RIESGOS' solo puede gestionar Analista de Riesgo (Proceso.SIR_AnalistaRiesgo__c)
            } else if ( procesosLst.get(0).recordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO 
                     && procesosLst.get(0).SIR_EmpleadoPREVEMP__c == SIR_Constantes.EMPLEADO_GESTION_RIESGOS
                     && procesosLst.get(0).SIR_AnalistaRiesgo__c == UserInfo.getUserId()){
                        return true;
            // Si es ( Flujo )  o ( PREVEMP && SIR_EmpleadoPREVEMP__c == 'NEGOCIO' ) puede gestionar Gestor o TGA                               
            } else if (procesosLst.get(0).recordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO ||
                      (procesosLst.get(0).recordType.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO && procesosLst.get(0).SIR_EmpleadoPREVEMP__c == SIR_Constantes.EMPLEADO_GESTION_NEGOCIO)){
                       return calcularGestionComun(procesosLst);                      
            } else {
                    return false;
            }                   
      } else {
         return false;
      }
    }  

    /*****************************************************************
        Proposito: Validar si el proceso puede ser gestionado por el usuario conectado, logica comun
        Parameters: String
        Returns: Boolean                                                    
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/06/2023     	  Created    
        
	*****************************************************************/ 
    @AuraEnabled
    public static Boolean calcularGestionComun(List<SIREC__SIREC_obj_proceso__c> procesosLst){ 
        Set<Id> setUserIds = new Set<id>();
        setUserIds.add(procesosLst.get(0).OwnerId);
        setUserIds.add(UserInfo.getUserId());              
        Map<Id,User> mapUsers = new Map<Id, User> ([SELECT AV_NumeroOficinaEmpresa__c, AV_tipoGestor__c FROM User where Id IN :setUserIds]);
        // Si el propietario del proceso es el usuario conectado puede gestionar
        if(procesosLst.get(0).OwnerId == UserInfo.getUserId()){
            return true;
        // Si el propietario del proceso no es tipo API, si el usuario conectado es TGA y la oficina del gestor del proceso y el usuario TGA son la misma, dejamos gestionar            
        } else if(!procesosLst.get(0).owner.Profile.Name.contains('API') && mapUsers.get(UserInfo.getUserId()).AV_tipoGestor__c == SIR_Constantes.TIPO_TGA && 
            mapUsers.get(procesosLst.get(0).OwnerId).AV_NumeroOficinaEmpresa__c == mapUsers.get(UserInfo.getUserId()).AV_NumeroOficinaEmpresa__c){
            return true;
        }            
        // Si el propietario del proceso es API y el usuario conectado es TGA y la oficina del cliente es la misma que la oficina del TGA, dejamos gestionar 
        else if(procesosLst.get(0).owner.Profile.Name.contains('API') && mapUsers.get(UserInfo.getUserId()).AV_tipoGestor__c == SIR_Constantes.TIPO_TGA && 
            procesosLst.get(0).SIREC__SIREC_fld_cliente__r.AV_OficinaPrincipal__r.CC_Numero_Oficina_Empresa__c == mapUsers.get(UserInfo.getUserId()).AV_NumeroOficinaEmpresa__c){
            return true;
        } else {
            return false;
        } 
    }
}