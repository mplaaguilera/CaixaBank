/*****************************************************************
 Name:  SIR_cls_procesoHandler
 Copyright © 2021  CaixaBank

 Proposito:   Clase handler para alojar los metodos que se invocan desde SIR_cls_proceso                                                                                                                    

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244057         atmira         01/09/2021	      Created    

*****************************************************************/

public with sharing class SIR_cls_procesoHandler {

    /*****************************************************************
     Name:  tratarCamposInsert
    Copyright © 2021  CaixaBank
    
    Proposito:   Informa el campo SIR_FechaInicioEstrategia__c la situación SIREC y 
                 quita el pipe en las alertas. Este método se llama al insertar un nuevo proceso                                                                                                            
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291340         atmira         28/08/2024	      Created    

    *****************************************************************/

    public static void tratarCamposInsert(List<SIREC__SIREC_obj_proceso__c> lstNewProcesos){
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){ 
            for (SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos) {
                proceso.SIR_FechaInicioEstrategia__c = proceso.SIREC__SIREC_fld_fechaInicio__c;
                proceso.SIR_fld_Situacion_SF__c = proceso.SIREC__SIREC_fld_situacion__c;

                if(String.isNotBlank(proceso.SIR_DescripcionesAlertas__c)){            
                   proceso.SIR_DescripcionesAlertas__c = proceso.SIR_DescripcionesAlertas__c.replace('|',' \n ').trim();            
                }
            }
        }
    }

    /*****************************************************************
     Name:  tratarCamposUpdate
    Copyright © 2021  CaixaBank
    
    Proposito:   Si ha cambiado la estrategia informa el campo SIR_FechaInicioEstrategia__c Y 
                 quita el pipe en las alertas. Este método se llama en el before del update
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291340         atmira         26/08/2024	      Created    

    *****************************************************************/
    public static void tratarCamposUpdate(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, List<SIREC__SIREC_obj_proceso__c> lstNewProcesos){
        if (Schema.sObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){ 
            for (SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos) {

                // si ha cambiado la estrategia actualizamos fecha inicio estategia
                if(proceso.SIREC__SIREC_fld_estrategia__c != mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_estrategia__c){
                    proceso.SIR_FechaInicioEstrategia__c = Date.today();
                }

                // Si ha cambiado la alerta quita los pipes si los hubiera
                if(proceso.SIR_DescripcionesAlertas__c != mapOldProcesos.get(proceso.Id).SIR_DescripcionesAlertas__c && String.isNotBlank(proceso.SIR_DescripcionesAlertas__c)){            
                    proceso.SIR_DescripcionesAlertas__c = proceso.SIR_DescripcionesAlertas__c.replace('|',' \n ').trim();                               
                }
            }
        }
    }

    /*****************************************************************
     Name:  finalizarProcesoRefi
    Copyright © 2021  CaixaBank
    
    Proposito:   Metodo que copia el estado de de un proceso de refinamiento derivado de otro creado desde SIREC                                                                                                                    
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US244057         atmira         01/09/2021	      Created    

    *****************************************************************/
    public static void finalizarProcesoRefi(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, Map<Id,SIREC__SIREC_obj_proceso__c> mapNewProcesos) {
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isUpdateable()){  
            Set<Id> setClientIds = new Set<Id>();
            Map<Id,SIREC__SIREC_obj_proceso__c> mapProcesos = new Map<Id,SIREC__SIREC_obj_proceso__c>();
            for(SIREC__SIREC_obj_proceso__c proceso : mapNewProcesos.values()){
                if( mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_fechaBaja__c != proceso.SIREC__SIREC_fld_fechaBaja__c && 
                    proceso.SIREC__SIREC_fld_fechaBaja__c != null) {
                        setClientIds.add(proceso.SIREC__SIREC_fld_cliente__c); 
                    }
                    mapProcesos.put(proceso.SIREC__SIREC_fld_cliente__c,proceso);
            }
            if(!setClientIds.isEmpty()){
                List<SIREC__SIREC_obj_proceso__c> lstProcesosForUpdate = [SELECT Id,  SIREC__SIREC_fld_fechaBaja__c, SIREC__SIREC_fld_motivoBaja__c, SIREC__SIREC_fld_cliente__c, SIR_fld_Situacion_SF__c
                                                                            FROM SIREC__SIREC_obj_proceso__c
                                                                            WHERE SIREC__SIREC_fld_cliente__c IN : setClientIds 
                                                                                    AND Name = :SIR_Constantes.PROCESO_NAME_REFINANCIACION
                                                                                    AND SIREC__SIREC_fld_fechaBaja__c = null
                                                                                    AND Id NOT IN :mapNewProcesos.keyset()];
                for(SIREC__SIREC_obj_proceso__c proceso : lstProcesosForUpdate){
                    proceso.SIREC__SIREC_fld_fechaBaja__c = mapNewProcesos.get(mapProcesos.get(proceso.SIREC__SIREC_fld_cliente__c).Id).SIREC__SIREC_fld_fechaBaja__c;
                    proceso.SIREC__SIREC_fld_motivosBaja__c = mapNewProcesos.get(mapProcesos.get(proceso.SIREC__SIREC_fld_cliente__c).Id).SIREC__SIREC_fld_motivosBaja__c;
                    proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
                    proceso.SIREC__SIREC_fld_situacion__c  = SIR_Constantes.PROCESO_SITUACION_FINALIZADO;
                }
                if(!lstProcesosForUpdate.isEmpty()){
                    update lstProcesosForUpdate;
                }
            }
        
        }
    }

   /*****************************************************************
    Name:  crearHistoricoProcesoInsert
    Copyright © 2021  CaixaBank
    
    Proposito:  Crear un registro en el objeto Historico Proceso                                                                                                                    
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291340         atmira         25/01/2022	      Created    

    *****************************************************************/
    public static List<SIR_HistoricoProceso__c> crearHistoricoProcesoInsert(list<SIREC__SIREC_obj_proceso__c> listNewProcesos) {
        
        List<SIR_HistoricoProceso__c> listHistoricoProceso = new List<SIR_HistoricoProceso__c>();  
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.SIR_HistoricoProceso__c.isCreateable()){          
           
            for(SIREC__SIREC_obj_proceso__c proceso : listNewProcesos){   
                if(proceso.Name != SIR_Constantes.PROCESO_NAME_REFINANCIACION){
                    SIR_HistoricoProceso__c historicoProceso = new SIR_HistoricoProceso__c();
                    historicoProceso.SIR_Proceso__c = proceso.Id;
                    historicoProceso.SIR_Cliente__c = proceso.SIREC__SIREC_fld_cliente__c;
                    historicoProceso.SIR_Tipo__c = 'Estrategia';
                    historicoProceso.SIR_CodigoEstrategia__c = proceso.SIREC__SIREC_fld_estrategia__c;
                    historicoProceso.SIR_Estrategia__c = proceso.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                  						
                    for (Schema.PicklistEntry f : Schema.sObjectType.SIREC__SIREC_obj_proceso__c.fields.SIREC__SIREC_fld_situacion__c.getPicklistValues()){
                        if(f.getValue() == proceso.SIREC__SIREC_fld_situacion__c){
                            historicoProceso.SIR_Situacion__c = f.getLabel();  
                        }
                    }
                    historicoProceso.SIR_FechaSituacion__c = proceso.SIREC__SIREC_fld_fechaSituacion__c;
                    historicoProceso.SIR_FechaInicioEstrategia__c = proceso.SIREC__SIREC_fld_fechaInicio__c;
                    listHistoricoProceso.add(historicoProceso);
                }    
            }
        }
        return listHistoricoProceso ; 
    }



    /*****************************************************************
     Name:  crearHistoricoProceso
    Copyright © 2021  CaixaBank
    
    Proposito:   Crear un registro en el objeto Historico Proceso                                                                                                                    
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291340         atmira         16/11/2021	      Created    
        1.1            US375758         atmira         05/05/2022         No se debe crear registro en histórico para procesos con recordType PRESOL (SIREC_rt_Anticipacion)
        1.2            US375758         atmira         29/12/2022         No se debe crear registro en histórico para procesos con objetivo del proceso(SIR_ObjetivoProceso__c) = 'Objetivo Informativo'
        1.3            USXXXXXX         atmira         29/12/2022         No se debe crear registro en histórico para procesos con recordType PREVEMP (SIRE_RT_PREVEMP)
	*****************************************************************/
        public static void crearHistoricoProceso(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, list<SIREC__SIREC_obj_proceso__c> listNewProcesos) {
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.SIR_HistoricoProceso__c.isCreateable()){ 
            Set<Id> procesosEstrategiaCambiada = new Set<Id>();
            List<SIR_HistoricoProceso__c> listHistoricoProceso = new List<SIR_HistoricoProceso__c>();
            List<SIR_HistoricoProceso__c> listHistoricoProcesoUpdate = new List<SIR_HistoricoProceso__c>();
            List<SIREC__SIREC_obj_proceso__c> lstInsertProcesoHistorico = new List<SIREC__SIREC_obj_proceso__c>();
            
            Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            Set<Id> setRtIds = new Set<Id>();
            setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
            setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId());
            setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_AP_PP).getRecordTypeId());
            for(SIREC__SIREC_obj_proceso__c proceso : listNewProcesos){
                if(!setRtIds.contains(proceso.RecordTypeId) && proceso.SIR_ObjetivoProceso__c != SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO){
                    if(mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_cliente__c == null && proceso.SIREC__SIREC_fld_cliente__c != null){
                        lstInsertProcesoHistorico.add(proceso);
                    }
                    else if(mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_estrategia__c != proceso.SIREC__SIREC_fld_estrategia__c && proceso.Name != SIR_Constantes.PROCESO_NAME_REFINANCIACION){
                        procesosEstrategiaCambiada.add(proceso.Id);
                    }    
                } 
            }
            if(!lstInsertProcesoHistorico.isEmpty()){
                listHistoricoProceso.addall(crearHistoricoProcesoInsert(lstInsertProcesoHistorico));
            }
            if(!procesosEstrategiaCambiada.isEmpty()){
                List<SIR_HistoricoProceso__c> historicoProcesosSF = [SELECT SIR_FechaFinEstrategia__c, SIR_Proceso__c, SIR_Situacion__c, SIR_FechaSituacion__c
                                                                     FROM SIR_HistoricoProceso__c 
                                                                     WHERE SIR_Proceso__c IN :procesosEstrategiaCambiada
                                                                     ORDER BY CreatedDate DESC];
                
                Set<String> idProcesos = new Set<String>();
                for(SIREC__SIREC_obj_proceso__c proceso : listNewProcesos){
                    // Informamos la fecha Fin del ultimo registro Historico
                    if(!historicoProcesosSF.isEmpty()){
                        for(SIR_HistoricoProceso__c historicoSF: historicoProcesosSF){
                            if(historicoSF.SIR_proceso__c == proceso.Id && !idProcesos.contains(proceso.Id)){                                
                                historicoSF.SIR_FechaFinEstrategia__c = proceso.SIR_FechaInicioEstrategia__c;
                                for (Schema.PicklistEntry f : Schema.sObjectType.SIREC__SIREC_obj_proceso__c.fields.SIREC__SIREC_fld_situacion__c.getPicklistValues()){
                                    if(f.getValue() == mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_situacion__c){
                                        historicoSF.SIR_Situacion__c = f.getLabel();
                                    }
                                }
                                historicoSF.SIR_FechaSituacion__c = mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_fechaSituacion__c;                                
                                listHistoricoProcesoUpdate.add(historicoSF);
                                idProcesos.add(proceso.Id);
                            }
                        }
                    }

                    if(mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_estrategia__c != proceso.SIREC__SIREC_fld_estrategia__c){
                        SIR_HistoricoProceso__c historicoProceso = new SIR_HistoricoProceso__c();
                        historicoProceso.SIR_Proceso__c = proceso.Id;
                        historicoProceso.SIR_Cliente__c = proceso.SIREC__SIREC_fld_cliente__c;
                        historicoProceso.SIR_Tipo__c = 'Estrategia';
                        historicoProceso.SIR_CodigoEstrategia__c = proceso.SIREC__SIREC_fld_estrategia__c;
                        historicoProceso.SIR_Estrategia__c = proceso.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
              					
                        for (Schema.PicklistEntry f : Schema.sObjectType.SIREC__SIREC_obj_proceso__c.fields.SIREC__SIREC_fld_situacion__c.getPicklistValues()){
                            if(f.getValue() == proceso.SIREC__SIREC_fld_situacion__c){
                                historicoProceso.SIR_Situacion__c = f.getLabel();
                            }
                        }
                        historicoProceso.SIR_FechaSituacion__c = proceso.SIREC__SIREC_fld_fechaSituacion__c; 
                        historicoProceso.SIR_FechaInicioEstrategia__c = proceso.SIR_FechaInicioEstrategia__c; 
                        listHistoricoProceso.add(historicoProceso);
                    } 
                }
            } 
            
            if(!listHistoricoProceso.isEmpty()){
                insert listHistoricoProceso;
            }

            if(!listHistoricoProcesoUpdate.isEmpty()){
                update listHistoricoProcesoUpdate;
             }
        }
    }

    /*****************************************************************
     Name:  setEstrategiaEnProcRefi
    Copyright © 2021  CaixaBank
    
    Proposito:   Si el proceso no es de Refinanciación, que si el cliente tiene un proceso de refinanciación sin finalizar ( no tiene informada la fecha de baja ) le modifique la Estrategia con la misma del Proceso que se está actualizando                                                                                                             
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US291340         atmira         125/11/2021	      Created    

    *****************************************************************/
    public static void setEstrategiaEnProcRefi(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, List<SIREC__SIREC_obj_proceso__c> lstNewProcesos){
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() && Schema.SObjectType.SIR_HistoricoProceso__c.isCreateable()){
            Set<Id> setProcId = new Set<Id>();
            Map<Id,SIREC__SIREC_obj_proceso__c> mapClientes = new Map<Id,SIREC__SIREC_obj_proceso__c>();
            for(SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos){
                if(proceso.SIREC__SIREC_fld_estrategia__c != mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_estrategia__c 
                    && proceso.Name != SIR_Constantes.PROCESO_NAME_REFINANCIACION
                    && proceso.SIREC__SIREC_fld_fechaBaja__c == null){
                        setProcId.add(proceso.Id);
                        mapClientes.put(proceso.SIREC__SIREC_fld_cliente__c, proceso);
                    }
                
            }
            if(!setProcId.isEmpty()){
                List<SIREC__SIREC_obj_proceso__c> lstProcesos = [SELECT Id, SIREC__SIREC_fld_estrategia__c, SIREC__SIREC_fld_estrategiaCatalogo__c, SIREC__SIREC_fld_cliente__c 
                                                                    FROM SIREC__SIREC_obj_proceso__c 
                                                                    WHERE SIREC__SIREC_fld_cliente__c IN :mapClientes.keyset() 
                                                                    AND Name = :SIR_Constantes.PROCESO_NAME_REFINANCIACION
                                                                    AND SIREC__SIREC_fld_fechaBaja__c = null
                                                                    AND Id NOT IN :mapOldProcesos.keyset()];
                for(SIREC__SIREC_obj_proceso__c proceso : lstProcesos){
                    proceso.SIREC__SIREC_fld_estrategia__c = mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).SIREC__SIREC_fld_estrategia__c;
                    proceso.SIREC__SIREC_fld_estrategiaCatalogo__c = mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).SIREC__SIREC_fld_estrategiaCatalogo__c;
                }
                if(!lstProcesos.isEmpty()){
                    update lstProcesos;
                }
            }
            
        }
        
    }

    /*****************************************************************
     Name:  setProcessOwner
    Copyright © 2021  CaixaBank
    
    Proposito:   Trasladar los procesos que estén asignados al usuario de integración al nuevo owner si este tiene permiso sobre el objeto Proceso                                                                                                              
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            USXXXXX          atmira         22/02/2022	      Created    
        1.1            USXXXXX          atmira         28/04/2023	      Se añade el control de la asignación de procesos Empresa 

    *****************************************************************/
    public static void setProcessOwner(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, Map<Id, SIREC__SIREC_obj_proceso__c>  mapNewProcesos){
        
        Set<Id> setUserPSAsigGestorId = new Set<Id>();
        Set<Id> setUserPSAsigSSMMId = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setAccountIdsPREVEMP = new Set<Id>();
        Set<Id> setUserPSAsigGestorEmpresaId = new Set<Id>();
        Set<Id> setOwnerIds = new Set<Id>();
        Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
        Id rtPrevemp = mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId();  

        for(SIREC__SIREC_obj_proceso__c proceso : mapNewProcesos.values()){
            if(String.isNotBlank(proceso.SIREC__SIREC_fld_cliente__c) 
            && (mapOldProcesos.get(proceso.Id).OwnerId == proceso.OwnerId)){
                setAccountIds.add(proceso.SIREC__SIREC_fld_cliente__c);
                setOwnerIds.add(proceso.OwnerId);
                setOwnerIds.add(mapOldProcesos.get(proceso.Id).OwnerId);
            }
            if(proceso.recordTypeId == rtPrevemp 
            && proceso.SIR_AccionActual__c == true 
            && proceso.SIR_TipoGestionPREVEMP__c != SIR_Constantes.GESTION_NEGOCIO 
            && proceso.SIR_AnalistaRiesgo__c == null){
                setAccountIdsPREVEMP.add(proceso.SIREC__SIREC_fld_cliente__c);
            } 
        }
        if(setOwnerIds.size()>0){

            Map<Id,Account> mapClientes = new Map<Id,Account>([SELECT Id,OwnerId, Owner.Profile.Name, AV_OficinaPrincipal__c, AV_OficinaPrincipal__r.name 
                                            FROM Account 
                                    WHERE Id IN : setAccountIds AND Owner.IsActive = True]);
            for(Account cliente : mapClientes.values()){
                setOwnerIds.add(cliente.OwnerId);
            }           

            //buscar los user de analista de riesgo dentro de AccountTeamMember para los clientes de los procesos PREVEMP. Si hay varios analistas de riesgos para el mismo cliente nos quedamos con uno 
            List<AggregateResult> lstAccountTeamMember = new List<AggregateResult>([SELECT AccountId,MIN(UserId) Analista
                                                                                            FROM AccountTeamMember 
                                                                                            WHERE AccountId IN : setAccountIdsPREVEMP AND User.IsActive = True 
                                                                                              AND (User.AV_tipoGestor__c  = :SIR_Constantes.TIPO_ANALISTA_RIESGOS
                                                                                                OR User.CIBE_FuncionEmpleado__c = :SIR_Constantes.CIBE_ANALISTA_DE_RIESGO
                                                                                                OR User.CIBE_FuncionEmpleado__c = :SIR_Constantes.CIBE_ANALISTA_SENIOR_DE_RIESGO)
                                                                                            GROUP BY AccountId]);
            Map<Id,Id> mapAccountTeamMember= new Map<Id,Id>();                                                                                        
            for(AggregateResult team : lstAccountTeamMember){
                 setOwnerIds.add((String)team.get('Analista'));           
                 mapAccountTeamMember.put((String)team.get('AccountId'),(String)team.get('Analista'));
            }

           // Id imaginUserId;
           // Boolean existeIMAGIN = false;

          /*  for(Account account : mapClientes.values()){
                if(!(String.isEmpty(account.AV_OficinaPrincipal__c)) && account.AV_OficinaPrincipal__r.name.contains('IMAGIN')){
                    existeIMAGIN = true;
                    break;
                }
            }
            if(existeIMAGIN){
                imaginUserId = [SELECT Id FROM User WHERE AV_ExternalID__c = :SIR_Variables__mdt.getInstance('IMAGINGestor').Valor__c].Id;
                setOwnerIds.add(imaginUserId);
            }*/
            for( PermissionSetAssignment psAsig : [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId, PermissionSetGroup.DeveloperName, Assignee.Profile.Name
                                        FROM PermissionSetAssignment 
                                        WHERE (PermissionSet.Name = :SIR_Constantes.PS_GESTOR_NAME
                                        OR Assignee.Profile.Name LIKE 'API%'
                                        OR PermissionSetGroup.DeveloperName = :SIR_Constantes.PS_GROUP_AV_GESTOR_NAME 
                                        OR PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_EXTERNO
                                        OR PermissionSet.Name = :SIR_Constantes.PS_GESTOR_NAME_EMP)
                                        AND AssigneeId IN :setOwnerIds]){
                if(psAsig.PermissionSet.Name == SIR_Constantes.PS_GESTOR_NAME ||
                    psAsig.PermissionSetGroup.DeveloperName == SIR_Constantes.PS_GROUP_AV_GESTOR_NAME || 
                    psAsig.PermissionSetGroup.DeveloperName == SIR_Constantes.PS_GROUP_AV_EXTERNO){
                        setUserPSAsigGestorId.add(psAsig.AssigneeId);
                    }
                if(psAsig.PermissionSet.Name == SIR_Constantes.PS_GESTOR_NAME_EMP){
                    setUserPSAsigGestorEmpresaId.add(psAsig.AssigneeId);
                }
                if(psAsig.Assignee.Profile.Name.contains('API')){
                    setUserPSAsigSSMMId.add(psAsig.AssigneeId);
                }
            }
			Set<Id> setEmpresaRTIds = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_EMPRESA_DEVELOPERNAME,SIR_Constantes.PROCESO_OBJECT_API_NAME);
            Set<Id> setRetailRTIds = SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_RETAIL_DEVELOPERNAME,SIR_Constantes.PROCESO_OBJECT_API_NAME);           

            for(SIREC__SIREC_obj_proceso__c proceso : mapNewProcesos.values()){
                
             /*   Boolean asgnarImagin = existeIMAGIN  
                    && mapClientes.containsKey(proceso.SIREC__SIREC_fld_cliente__c)
                    && setUserPSAsigSSMMId.contains(proceso.ownerId)
                    && !(String.isEmpty(mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).AV_OficinaPrincipal__c))
                    && mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).AV_OficinaPrincipal__r.Name.contains('IMAGIN');
            */
                if(proceso.SIR_fld_Situacion_SF__c != SIR_Constantes.PROCESO_SITUACION_FINALIZADO 
                   && String.isNotBlank(proceso.SIREC__SIREC_fld_cliente__c)
                   && setUserPSAsigSSMMId.contains(mapOldProcesos.get(proceso.Id).OwnerId) 
                   && mapClientes.containsKey(proceso.SIREC__SIREC_fld_cliente__c)
                   && setRetailRTIds.contains(proceso.recordTypeId)
            //       && (setUserPSAsigGestorId.contains(mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId) || asgnarImagin)){
              //         proceso.OwnerId = asgnarImagin ? imaginUserId : mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId;
                   && setUserPSAsigGestorId.contains(mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId) ){
                        proceso.OwnerId = mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId;
                   }                 
                   
                   //Controlamos los registros de empresas                 
                if(proceso.SIR_fld_Situacion_SF__c != SIR_Constantes.PROCESO_SITUACION_FINALIZADO 
                   && String.isNotBlank(proceso.SIREC__SIREC_fld_cliente__c)
                   && setUserPSAsigSSMMId.contains(mapOldProcesos.get(proceso.Id).OwnerId)
                   && mapClientes.containsKey(proceso.SIREC__SIREC_fld_cliente__c)
                   && setEmpresaRTIds.contains(proceso.recordTypeId)
                   && setUserPSAsigGestorEmpresaId.contains(mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId)){
                       proceso.OwnerId = mapClientes.get(proceso.SIREC__SIREC_fld_cliente__c).OwnerId;
                   }

                //Si el proceso es PREVEMP y cumple las condiciones asignar el analista de riesgo
                if(proceso.recordTypeId == rtPrevemp 
                   && proceso.SIR_AccionActual__c == true 
                   && proceso.SIR_TipoGestionPREVEMP__c != SIR_Constantes.GESTION_NEGOCIO 
                   && proceso.SIR_AnalistaRiesgo__c == null
                   && String.isNotBlank(proceso.SIREC__SIREC_fld_cliente__c)
                   && String.isBlank(proceso.SIR_AnalistaRiesgo__c)
                   && setUserPSAsigGestorEmpresaId.contains(mapAccountTeamMember.get(proceso.SIREC__SIREC_fld_cliente__c))){                                                          
                    proceso.SIR_AnalistaRiesgo__c = mapAccountTeamMember.get(proceso.SIREC__SIREC_fld_cliente__c);
                }    
            }
        }     
    }

    /*****************************************************************
     Name:  setSituacionSF
    Copyright © 2022 CaixaBank
    
    Proposito:   Informa el campo SIR_fld_Situacion_SF__c con el último valor de Situacion del proceso antes de finalizar
                 y actualizar el campo SIR_AccionActual__c a false cuando se finaliza el proceso                                                                                                            
    
    Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             atmira         07/06/2022	      Created    
		1.1            USXXXXX          atmira         28/04/2023	      Se añade que el comportamiento sea igual para PREVEMP
        1.2            USXXXXX          atmira         11/10/2023	      Se añade el cambio de situación para PREVEMP
        1.3            USXXXXX          atmira         13/11/2023	      Se añade una condición para que la Situacion_SF se quede con la situación anterior a Finalizarse.
    *****************************************************************/
    public static void setSituacionSF(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, List<SIREC__SIREC_obj_proceso__c> lstNewProcesos){
		Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
        Set<Id> setRtIds = new Set<Id>();
        Set<Id> setRtIdsPrevemp = new Set<Id>();
        setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
        setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId());
        setRtIdsPrevemp.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId());
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            for (SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos) {

                //Mantener situaciones finalistas o gestionadas de PRESOL y PREVEMP cuando viene la baja del proceso en la interfaz de baja.
                if(setRtIds.contains(proceso.RecordTypeId)
                && ((proceso.SIREC__SIREC_fld_situacion__c != mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_situacion__c
                && proceso.SIREC__SIREC_fld_situacion__c == SIR_Constantes.PROCESO_SITUACION_FINALIZADO)
                || (proceso.SIR_fld_Situacion_SF__c == SIR_Constantes.PROCESO_SITUACION_FINALIZADO
				&&  proceso.SIREC__SIREC_fld_situacion__c == SIR_Constantes.PROCESO_SITUACION_FINALIZADO)))
                {
                    proceso.SIR_fld_Situacion_SF__c = mapOldProcesos.get(proceso.Id).SIR_fld_Situacion_SF__c;
                }

                //Igualar la situación SF de Preventivo cuando el batch de SIREC cambia la situación. Porque en la interfaz de procesos no viene incluida la situación SF.
                if(setRtIdsPrevemp.contains(proceso.RecordTypeId)
                && mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_situacion__c != proceso.SIREC__SIREC_fld_situacion__c 
                && proceso.SIREC__SIREC_fld_situacion__c != proceso.SIR_fld_situacion_SF__c
                && proceso.SIREC__SIREC_fld_situacion__c != SIR_Constantes.PROCESO_SITUACION_FINALIZADO
                ){
                    proceso.SIR_fld_situacion_SF__c = proceso.SIREC__SIREC_fld_situacion__c;
                }

                // IOP FEB24 En caso de que el Proceso venga como finalizado, quitar la relacion con Tarea, para luego el proceso de purga pueda borrar
                if(proceso.SIREC__SIREC_fld_situacion__c != mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_situacion__c && 
                  proceso.SIREC__SIREC_fld_situacion__c == SIR_Constantes.PROCESO_SITUACION_FINALIZADO){
                    proceso.SIR_AccionActual__c = false;
                    proceso.SIREC__SIREC_fld_tarea__c = null;
                    proceso.SIREC__SIREC_fld_tareaOPCPendiente__c = null;
                }
            }
        }
    }

    /*****************************************************************
     Name:  setTareaCliente
    Copyright © 2022  CaixaBank
    
    Proposito:   Cuando se actualice un proceso se ha de actualizar las tareas relacionadas                                                                                                          
    
    Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             atmira         20/03/2023	      Created    

    *****************************************************************/
    public static void setTareaCliente(Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos, List<SIREC__SIREC_obj_proceso__c> lstNewProcesos){
        Map<Id,SIREC__SIREC_obj_proceso__c> mapProcesos = new Map<Id,SIREC__SIREC_obj_proceso__c>();
        for(SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos){
            if(proceso.SIREC__SIREC_fld_cliente__c != mapOldProcesos.get(proceso.Id).SIREC__SIREC_fld_cliente__c){
                mapProcesos.put(proceso.Id, proceso);
            }
        }
        
        if(!lstNewProcesos.isEmpty()){
            List<SIREC__SIREC_obj_tarea__c> lstTareas = [SELECT Id, SIR_Cliente__c, SIREC__SIREC_fld_proceso__c FROM SIREC__SIREC_obj_tarea__c WHERE SIREC__SIREC_fld_proceso__c IN :mapProcesos.keyset()];
            for(SIREC__SIREC_obj_tarea__c tarea :lstTareas){
                tarea.SIR_Cliente__c = mapProcesos.get(tarea.SIREC__SIREC_fld_proceso__c).SIREC__SIREC_fld_cliente__c;
            }
            try{
                
                update lstTareas;
            }catch(Exception ex){
                CBK_log.error(ex, 'Error : SIR_cls_tareaHandler - updateTareaProceso -  ' + ex.getTypeName() + ': ' + ex.getMessage(), lstNewProcesos);
            }
        }
    }

    /*****************************************************************
     Name:  setMatricula
    Copyright © 2022  CaixaBank
    
    Proposito:   Cuando se actualice un proceso se ha de actualizar las tareas relacionadas                                                                                                          
    
    Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             atmira         20/03/2023	      Created    

    *****************************************************************/
    public static void setMatricula(List<SIREC__SIREC_obj_proceso__c> lstNewProcesos, Map<Id, SIREC__SIREC_obj_proceso__c> mapOldProcesos){
        
        Set<Id> setOwnerids = new Set<Id>();
        for(SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos){
            if(proceso.ownerId != mapOldProcesos.get(proceso.Id).ownerId){
                setOwnerids.add(proceso.ownerId);
            }
        }
        
        if(!setOwnerids.isEmpty()){
            Map<Id,User> mapUsers = new Map<Id,User>([SELECT Id, EmployeeNumber, Profile.Name FROM User WHERE Id IN:setOwnerids]);
            for(SIREC__SIREC_obj_proceso__c proceso : lstNewProcesos){
                proceso.SIR_MatriculaGestor__c = (setOwnerids.contains(proceso.OwnerId) && !mapUsers.get(proceso.ownerId).Profile.Name.contains('API')) ? mapUsers.get(proceso.ownerId).EmployeeNumber : 'U0100000';
                if(proceso.SIR_MatriculaGestor__c != null && proceso.SIR_MatriculaGestor__c.length() > 8){
                    proceso.SIR_MatriculaGestor__c = proceso.SIR_MatriculaGestor__c.substring(0,8);
                }
            }
        }
    }

}