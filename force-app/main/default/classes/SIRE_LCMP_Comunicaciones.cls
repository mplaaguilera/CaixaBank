/*****************************************************************
 Name:  SIRE_LCMP_Comunicaciones
 Copyright © 2021  CaixaBank

@description   Clase controladora externa del LWC Sir_lwc_Comunicaciones                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR          DATE               Description
    1.0            US313423         Atmira          23/03/2023      	  Created    

*****************************************************************/
public with sharing class SIRE_LCMP_Comunicaciones {

    
    /*****************************************************************
        @description  Realizamos query para buscar todas las comunicaciones para el usuario actual                                              
        @param  Ninguno
        @return List<SIR_Comunicaciones__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US313423         Atmira         23/03/2023      	  Created    
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<CBK_Notification__c> getComunicaciones(){
        if(Contact.SObjectType.getDescribe().isAccessible() && Account.SObjectType.getDescribe().isAccessible() && CBK_Notification__c.SObjectType.getDescribe().isAccessible()){
            Set<Id> setIdCentros = new Set<Id>();
            List<CBK_Notification__c> comunicaciones = new List<CBK_Notification__c>();
            List<Contact> oficinaUsuario = [SELECT AccountId, 
                                        Account.AV_CentroSuperior__c, 
                                        Account.AV_CentroSuperior__r.AV_CentroSuperior__c, 
                                        Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, 
                                        Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, 
                                        Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c                                         
                                        FROM Contact WHERE AV_UsuarioAsociado__c =: UserInfo.getUserId()];
            if(!oficinaUsuario.isEmpty()){
                if(!String.isBlank(oficinaUsuario[0].AccountId)){
                    setIdCentros.add(oficinaUsuario[0].AccountId);                    
                    if(!String.isBlank(oficinaUsuario[0].Account.AV_CentroSuperior__c) ){               
                        setIdCentros.add(oficinaUsuario[0].Account.AV_CentroSuperior__r.Id);                
                        
                        if(!String.isBlank(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__c) ){
                            setIdCentros.add(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__c);
                            
                            if(!String.isBlank(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c) ){
                                setIdCentros.add(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c);
                                
                                if(!String.isBlank(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c) ){
                                    setIdCentros.add(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c);
                                    
                                    if(!String.isBlank(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c) ){
                                        setIdCentros.add(oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c);
                                        
                                        Account centroSuperior = [SELECT AV_CentroSuperior__c FROM Account WHERE Id =: oficinaUsuario[0].Account.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c];
                                        if(centroSuperior != null){
                                            setIdCentros.add(centroSuperior.AV_CentroSuperior__c);
                                        }                            
                                    }
                                }
                            }
                        }
                    }
                    Date hoy = date.TODAY();
                    comunicaciones = [SELECT Account__c, Account__r.Name, Message__c, InitDate__c, FinishDate__c, Title__c                                 
                                        FROM CBK_Notification__c 
                                        WHERE App__c = 'MCs Solution EMP' AND AlertType__c = 'banner'
                                        AND Account__c != '' AND Account__c in :setIdCentros
                                        AND ( (InitDate__c <= :hoy OR InitDate__c = NULL) AND (FinishDate__c >= :hoy OR FinishDate__c = NULL) )
                                        ORDER BY CreatedDate DESC];  
                }
            }           
            return comunicaciones;
        } 
        return null; 
    }

    /*****************************************************************
        @description  Realizamos query para buscar los acciones planificadas para hoy del usuario logueado                                             
        @param  Ninguno
        @return List<SIREC__SIREC_obj_acciones__c>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US424115         Atmira        23/03/2023      	  Created     
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<SIREC__SIREC_obj_acciones__c> getQueryAcciones(String url){
        List<SIREC__SIREC_obj_acciones__c> acciones = new List<SIREC__SIREC_obj_acciones__c>();
        if(SIREC__SIREC_obj_acciones__c.SObjectType.getDescribe().isAccessible()){

            if(url.contains('SIRE_Inicio_FLUJO')){
                        acciones = [SELECT id, Name, SIREC__SIREC_fld_interviniente__c, SIREC__SIREC_fld_interviniente__r.Name, toLabel(SIREC__SIREC_fld_resultado__c), 
                        toLabel(SIREC__SIREC_fld_tipo__c), SIREC__SIREC_fld_proceso__c, SIREC__SIREC_fld_proceso__r.Id, toLabel(SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_estrategia__c), toLabel(SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c), 
                        SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c, SIREC__SIREC_fld_fechaContacto__c
                        FROM SIREC__SIREC_obj_acciones__c 
                        WHERE SIREC__SIREC_fld_responsable__c =: UserInfo.getUserId() 
                        AND SIREC__SIREC_fld_fechaContacto__c =: date.today()
                        AND SIREC__SIREC_fld_proceso__r.RecordType.Name = :SIR_Constantes.PROCESO_RECORDTYPE_NAME_EMP_FLUJO
                        AND RecordType.Name = : SIR_Constantes.ACCION_RECORDTYPE_NAME_AMISTOSO_EMPRESA
                        AND SIREC__SIREC_fld_estado__c = : SIR_Constantes.ACCION_ESTADO_EN_CURSO 
                        ];
            }
        }
        return acciones;
    }

    /*****************************************************************
        @description  Realizamos query para buscar los Reports de IMPA                                            
        @param  Ninguno
        @return List<Report>                                                       
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US424115         Atmira        23/03/2023      	  Created   
        
	*****************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Report> getQueryReports(String url){
        List<Report> informes = new List<Report>();
        if(Report.SObjectType.getDescribe().isAccessible()){

            if(url.contains('SIRE_Inicio_FLUJO')){
                /*informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName =: 'Acciones_Planificadas_PRESOL_Xs4'];*/
                        informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName =: 'SIRE_AccionesPlanificadasImpagados'];
            }/*else{
                informes = [SELECT id, name, DeveloperName  
                        FROM Report 
                        WHERE DeveloperName =: 'SIRE_AccionesPlanificadasImpagados'];

            }*/
        }
        return informes;
    }

}