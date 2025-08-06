public with sharing class OS_Case_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

        //Obtención de RT OS_
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        for (Schema.RecordTypeInfo rt: lstRT){
            if (rt.getDeveloperName().left(3)=='OS_') {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }
        List<Case> listNewObjCops= New List<Case>();
        Map<Id, Case> mapNewObjCops = New Map<Id, Case>();
        Boolean casoCambiaEstado = false;
        for (Case caso: listNewObj){
            if(((setIdsRt).contains(caso.RecordTypeId))||(caso.RecordTypeId == null)){
                listNewObjCops.add(caso);
                mapNewObjCops.put(caso.Id,caso);                
            }
            if(!casoCambiaEstado && caso.Status != mapOldObj.get(caso.Id).Status) {
                //Con que sea una vez true ya ejecutamos la query
                casoCambiaEstado = true;
            }
        }
        List<Case> listOldObjCops= New List<Case>();
        Map<Id, Case> mapOldObjCops = New Map<Id, Case>();
        for (Case caso: listOldObj){
            if(((setIdsRt).contains(caso.RecordTypeId))||(caso.RecordTypeId == null)){
                listOldObjCops.add(caso);
                mapOldObjCops.put(caso.Id,caso);                
            }
        }
        if ((mapOldObjCops.size() != 0) ||(listNewObjCops.size() != 0)){
            //Queries comunes            
            //Si el caso cambia de estado necesitamos listaBuzonesEmailColasTlfSLA
            List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA = new List<CC_Lista_Valores__c>();
            if(casoCambiaEstado) {
                listaBuzonesEmailColasTlfSLA = [SELECT Name, CC_Valor__c, CC_Lista__r.Name FROM CC_Lista_Valores__c WHERE 
                                                    (CC_Lista__r.Name = 'COPS: SLA Relación colas telefonía y canal de procedencia email' OR CC_Lista__r.Name = 'COPS: Horas SLA para servicios UAFE')
                                                    AND CC_Activa__c = true];  
            }

            enmascararPANs(mapOldObjCops, listNewObjCops); // Se enmascaran los PANs de tarjeta de crédito en caso de detectarse
            validarCierreCasoCOPS(mapOldObjCops, listNewObjCops);
            actualizarTelefonoEmailCasosCOPS(listNewObjCops, mapOldObjCops);
            noIdentificaCliente(listNewObjCops, mapOldObjCops);
            actualizarGrupoTrabajo(listNewObjCops, mapOldObjCops);
            actualizarCentroManipulador(listNewObjCops, mapOldObjCops);
            informarBuzonSalidaCaso(mapOldObjCops, listNewObjCops);
            camposTrasladoRemitidoAutomatico(mapOldObjCops, listNewObjCops);
            gestionarDANDGDT(mapOldObjCops, listNewObjCops);
            reasignarCasoBackup(mapOldObjCops, listNewObjCops);
            actualizarTelefonosAccountCasosCOPS(mapOldObjCops, listNewObjCops);
            informarEntitlementHolabankEfectivo(listNewObjCops, mapOldObjCops);
            pausarReanudarMilestones(listNewObjCops, mapOldObjCops, listaBuzonesEmailColasTlfSLA);
            actualizarFechaFilSLAReanudarMilestone(listNewObjCops, mapOldObjCops);
            completarMilestones(listNewObjCops, mapOldObjCops, listaBuzonesEmailColasTlfSLA);
            actualizarPropietarioAnterior(listNewObjCops, mapOldObjCops);
            actualizarGrupoTrabajoTransferLlamada(listNewObjCops, mapOldObjCops);
            restringirCambioPropietarioGT(listNewObjCops, mapOldObjCops);
            OS_CaseTriggerHelper.personAccountBU(listNewObjCops,mapOldObjCops);  
            OS_CaseTriggerHelper.identificarClienteAlfBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.identificarCambioClienteAlfBU(listNewObjCops,mapOldObjCops);  
            OS_CaseTriggerHelper.blanqueoAccountBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.seInformaCanalRespuestaBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.empleadoCuentaBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.asociaActivoBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.tematicaInformadoBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.productoInformadoBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.motivoInformadoBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.informarOficinaAfectadaDetalleBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.informarOficinaAfectadaBU(listNewObjCops,mapOldObjCops);
            OS_CaseTriggerHelper.actualizarColaProcedenciaBU(listNewObjCops,mapOldObjCops);     
            OS_CaseTriggerHelper.causaInformadoBU(listNewObjCops,mapOldObjCops);            
            OS_CaseTriggerHelper.solucionInformadoBU(listNewObjCops,mapOldObjCops);            
        }
    }

    private void noIdentificaCliente(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        for(Case caso: listNewObj) {
            if(caso.CC_No_Identificado__c && ((caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.AccountId != null) || (caso.ContactId != mapOldObj.get(caso.Id).ContactId && caso.ContactId != null))) {
                caso.CC_No_Identificado__c = false;
            }
        }
    }
    
    private void actualizarTelefonoEmailCasosCOPS(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        //Si es un caso de COPS y ha cambiado el contacto, se actualizan los campos "Teléfono del caso" y "Email del caso"
        List<Case> listCasos = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.ContactId != mapOldObj.get(caso.Id).ContactId) {
                listCasos.add(caso);
            }
        }
        if(!listCasos.isEmpty()){
            OS_Case.actualizarTelefonoEmailCaso(listCasos);
        }
    }

    private void actualizarTelefonosAccountCasosCOPS(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        //Si es un caso de COPS y ha cambiado la cuenta, se actualizan los campos "Account Phone" y "Account Mobile"
        List<Case> listCasos = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.AccountId != mapOldObj.get(caso.Id).AccountId) {
                listCasos.add(caso);
            }
        }
        if(!listCasos.isEmpty()){
            OS_Case.actualizarTelefonosAccount(listCasos);
        }
    }
    
    private void enmascararPANs(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            // Se establece un patrón para el PAN
            String panRegex = '[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}';
            Pattern myPattern = Pattern.compile(panRegex);
            // Campo "Asunto"
            if (!String.isEmpty(caso.Subject) && caso.Subject != mapOldObj.get(caso.Id).Subject) {
                Integer lognitudCampo = caso.Subject.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.Subject);
                
                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio = caso.Subject.indexOf(asuntoMatcher.group()) != null ? caso.Subject.indexOf(asuntoMatcher.group()): 0;
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;
                    
                    if (lognitudCampo != caso.Subject.length()) {
                        resta = lognitudCampo - caso.Subject.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.Subject.length();
                        
                    }   
                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.Subject.split('').get(indexIncio-1).isNumeric();
                    }  
                    Boolean caracterDetras = (indexFinal == caso.Subject.length()) ? false : caso.Subject.split('').get(indexFinal).isNumeric();
                    
                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.Subject = caso.Subject.replace(asuntoMatcher.group(), encryptedPan);
                }            
            } 
            
            // Campo "Descripción"
            if (!String.isEmpty(caso.Description) && caso.Description != mapOldObj.get(caso.Id).Description) {
                Integer lognitudCampo = caso.Description.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.Description);
                
                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio = caso.Description.indexOf(asuntoMatcher.group()) != null ? caso.Description.indexOf(asuntoMatcher.group()): 0;
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;
                    
                    if (lognitudCampo != caso.Description.length()) {
                        resta = lognitudCampo - caso.Description.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.Description.length();
                        
                    }    
                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.Description.split('').get(indexIncio-1).isNumeric();
                    }  
                    Boolean caracterDetras = (indexFinal == caso.Description.length()) ? false : caso.Description.split('').get(indexFinal).isNumeric();
                    
                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.Description = caso.Description.replace(asuntoMatcher.group(), encryptedPan);
                }            
            } 
            
            // Campo "Detalle Consulta"
            if (!String.isEmpty(caso.CC_Detalles_Consulta__c) && caso.CC_Detalles_Consulta__c != mapOldObj.get(caso.Id).CC_Detalles_Consulta__c) {
                Integer lognitudCampo = caso.CC_Detalles_Consulta__c.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.CC_Detalles_Consulta__c);
                
                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio = caso.CC_Detalles_Consulta__c.indexOf(asuntoMatcher.group()) != null ? caso.CC_Detalles_Consulta__c.indexOf(asuntoMatcher.group()): 0;
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;
                    
                    if (lognitudCampo != caso.CC_Detalles_Consulta__c.length()) {
                        resta = lognitudCampo - caso.CC_Detalles_Consulta__c.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.CC_Detalles_Consulta__c.length();
                        
                    } 
                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.CC_Detalles_Consulta__c.split('').get(indexIncio-1).isNumeric();
                    }  
                    Boolean caracterDetras = (indexFinal == caso.CC_Detalles_Consulta__c.length()) ? false : caso.CC_Detalles_Consulta__c.split('').get(indexFinal).isNumeric();
                    
                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c.replace(asuntoMatcher.group(), encryptedPan);
                }            
            }
            
            // Campo "Detalle Solución"
            if (!String.isEmpty(caso.CC_Detalles_Solucion__c) && caso.CC_Detalles_Solucion__c != mapOldObj.get(caso.Id).CC_Detalles_Solucion__c) {
                Integer lognitudCampo = caso.CC_Detalles_Solucion__c.length();
                Matcher asuntoMatcher = myPattern.matcher(caso.CC_Detalles_Solucion__c);
                
                while (asuntoMatcher.find()) {
                    String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                    Integer indexIncio = caso.CC_Detalles_Solucion__c.indexOf(asuntoMatcher.group()) != null ? caso.CC_Detalles_Solucion__c.indexOf(asuntoMatcher.group()): 0;
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    Integer resta = 0;
                    
                    if (lognitudCampo != caso.CC_Detalles_Solucion__c.length()) {
                        resta = lognitudCampo - caso.CC_Detalles_Solucion__c.length();
                        indexIncio = indexIncio-resta;
                        indexFinal = indexFinal-resta;
                        lognitudCampo = caso.CC_Detalles_Solucion__c.length();
                        
                    }    
                    Boolean caracterDelante = false;
                    if(indexIncio -1 > 0){
                        caracterDelante = (indexIncio == 0) ? false : caso.CC_Detalles_Solucion__c.split('').get(indexIncio-1).isNumeric();
                    }  
                    Boolean caracterDetras = (indexFinal == caso.CC_Detalles_Solucion__c.length()) ? false : caso.CC_Detalles_Solucion__c.split('').get(indexFinal).isNumeric();
                    
                    //Hay que mirar el inicio y el final de cada patón para ver si hay un numérico.
                    if (caracterDetras || caracterDelante){
                        encryptedPan = asuntoMatcher.group();
                    }
                    caso.CC_Detalles_Solucion__c = caso.CC_Detalles_Solucion__c.replace(asuntoMatcher.group(), encryptedPan);
                }            
            }
            
        }
    }
    
    private static void validarCierreCasoCOPS(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        //Para los casos que nos llegan como parámetro
        
        Map<Id, Case> casoIdCaso = new Map<Id, Case>();
        for (Case caso : listNewObj)  {
            if (mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.Status == 'Cerrado')  { 
                casoIdCaso.put(caso.Id, caso);
            }
        }
        if (casoIdCaso.size() > 0) {
            //Buscamos los tipos de actividad excluidos de la validación
            List<String> actividadesExcluidas = new List<String>();
            for (CC_Actividad_Cerrar_Caso__mdt actividad : [SELECT MasterLabel FROM CC_Actividad_Cerrar_Caso__mdt]) {
                actividadesExcluidas.add(actividad.MasterLabel);
            }
            
            //Damos error para los casos con actividades abiertas (no excluidas)
            List<Task> actividades = [SELECT Id, WhatId, Type, Status, Subject, CC_Tipo_Cierre__c FROM Task WHERE WhatId IN :casoIdCaso.keySet()
            AND Type NOT IN :actividadesExcluidas AND recordType.DeveloperName = 'OS_Task'];
            
            
            for (Task actividad : actividades) {
                if(actividad.Status == 'Open'){
                    casoIdCaso.get(actividad.WhatId).addError('Existen actividades pendientes que deben completarse antes de cerrar el caso.');
                }
            }
        }
    }
    
    private void actualizarGrupoTrabajo(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        Map<Id,String> mapColasCaso = new Map<Id,String>();
        List<String> colas = new List<String>();
        List<Id> idCasos = new List<Id>();
        Boolean informarGT = false;
        
        for (Case caso : listNewObj) {
            if (caso.OwnerId !=null && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId && String.valueOf(caso.OwnerId).startsWith('00G')) {
                colas.add(caso.OwnerId);
                idCasos.add(caso.id);
                informarGT = true;
            }
        }
        if (informarGT){
            List<Group> queues = [SELECT id, name FROM Group WHERE Type = 'Queue' AND Id IN :colas];
            colas.clear();
            
            for (Group cola : queues){
                colas.add(cola.Name);
                for (Case caso : listNewObj)
                {
                    if(cola.id == caso.ownerId)
                    {
                        mapColasCaso.put(caso.id,cola.Name);
                    }
                }
            }
            
            if (!colas.isEmpty()) {
                Map<String,String> mapColasGrupo = new Map<String,String>();
                
                List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, Name, OS_GrupoTrabajo__c FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'OS_GrupoTrabajo' AND OS_GrupoTrabajo__c = :colas];
                if (!grupos.isEmpty()) {
                    for (CC_Grupo_Colaborador__c grupo : grupos) {//la cola solo puede estar vinculada a un grupo de trabajo, por lo que ahora mismo no filtra por eso.
                        mapColasGrupo.put(grupo.OS_GrupoTrabajo__c, grupo.Name);                    
                    }
                    for (Case caso : listNewObj) {
                        caso.OS_GrupoTrabajo__c = mapColasGrupo.get(mapColasCaso.get(caso.Id));
                    }  
                }
            }
        }
    }
    
    private void actualizarCentroManipulador(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        Map<Id,Id> mapIdCasoAccountId = new Map<Id,Id>();
        for (Case caso : listNewObj) {
            if (caso.AccountId !=null && caso.CC_Canal_Procedencia__c == 'Buzón Efectivo COPS' && mapOldObj.get(caso.Id).AccountId != caso.AccountId && caso.OS_ViaClasificacion__c != 'Regla Clasificación' && caso.OS_ReglaUtilizada__c == null) {
                mapIdCasoAccountId.put(caso.Id,caso.AccountId);
            }
        }
        if (!mapIdCasoAccountId.isEmpty()) {
            Map<Id,String> mapCuentaCentroManipulador = new Map<Id,String>();
            List<Account> cuentas = [SELECT ID, OS_Centro_Manipulador__c FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' AND OS_Centro_Manipulador__c <> null AND Id IN :mapIdCasoAccountId.values()];
            if (!cuentas.isEmpty()){
                for (Account cuenta : cuentas) {
                    mapCuentaCentroManipulador.put(cuenta.Id, cuenta.OS_Centro_Manipulador__c);
                }
                for (Case caso : listNewObj) {
                    caso.OS_Centro_Manipulador__c = mapCuentaCentroManipulador.get(mapIdCasoAccountId.get(caso.Id));
                }
            }
        }
    }
    private void informarEntitlementHolabankEfectivo(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        //PROCEDENCIAS
        List<String> procedenciasHolabank = OS_Milestone.listadoCanalesProcedencias('procedenciasHolabank');
        List<String> procedenciasEfectivo = OS_Milestone.listadoCanalesProcedencias('procedenciasEfectivo');  
        
        Id entitlementCops;   
        Set<Id> casosInformarEntitlement = new Set<Id>();
        Set<Id> casoMCCIds = new Set<Id>();
        
        for (Case caso : listNewObj) {
            if ((mapOldObj.get(caso.Id).CC_MCC_Tematica__c != caso.CC_MCC_Tematica__c || mapOldObj.get(caso.Id).CC_MCC_Causa__c != caso.CC_MCC_Causa__c)
            && caso.CC_MCC_Tematica__c != null && caso.CC_MCC_Causa__c != null
            && (procedenciasHolabank.contains(caso.CC_Canal_Procedencia__c) || procedenciasEfectivo.contains(caso.CC_Canal_Procedencia__c))) {                 
                casosInformarEntitlement.add(caso.Id);
                casoMCCIds.add(caso.CC_MCC_Tematica__c);
                casoMCCIds.add(caso.CC_MCC_Causa__c);

                if(caso.CC_MCC_ProdServ__c != null ) {
                    casoMCCIds.add(caso.CC_MCC_ProdServ__c);
                } 
            }
        }

        if (!casosInformarEntitlement.isEmpty()) {
            //MCCs
            List<CC_MCC__c> businessHoursMCC = new List<CC_MCC__c>();
            if(!casoMCCIds.isEmpty()) {
                businessHoursMCC = [SELECT Id, OS_Horario__c, OS_Horas_SLA__c FROM CC_MCC__c WHERE Id =: casoMCCIds AND CC_Tipo_Cliente__c LIKE '%COPS%'
                                    AND (((Recordtype.DeveloperName = 'CC_Tematica' OR Recordtype.DeveloperName = 'CC_Producto_Servicio') AND OS_Horario__c != null ) 
                                        OR (Recordtype.DeveloperName = 'CC_Causa' AND OS_Horas_SLA__c != null)
                                        )];
            }
            //Entitlements
            List<Entitlement> entitlements = [SELECT Name FROM Entitlement];
            Map<String,Id> mapEntitlement = new Map<String,Id>();
            for (Entitlement entitlement : entitlements) {
                mapEntitlement.put(entitlement.name, entitlement.Id);
            }  

            List<BusinessHours> businessHoursList = [SELECT Id, name, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime FROM BusinessHours];

            for (Case caso : listNewObj) {
                if (casosInformarEntitlement.contains(caso.Id)) {
                    Map<String, Object> camposCalculoMilestone = OS_Milestone.calculoParametrosMilestone(caso, businessHoursList, businessHoursMCC);
                    Map<Id,BusinessHours> mapBusinessHour = (Map<Id,BusinessHours>)camposCalculoMilestone.get('mapBusinessHour');
                    Datetime fechaLimiteResolucion = (Datetime)camposCalculoMilestone.get('fechaLimiteResolucion');
                    Id idBusinessHours = (Id)camposCalculoMilestone.get('idBusinessHours');
                    BusinessHours businessHour = mapBusinessHour.get(idBusinessHours);
                    String horas = (String)camposCalculoMilestone.get('horas'); //caso.CC_MCC_Causa__r.OS_Horas_SLA__c 
                        
                    if (businessHour != null && idBusinessHours != null && horas != null && horas != ''){
                        for (String key: mapEntitlement.keySet()) {
                            String entitlementName = key;
                            if (key.contains(businessHour.name)) {
                                entitlementCops = mapEntitlement.get(key);
                                break;
                            }
                        } 
                    }
                    caso.EntitlementId = entitlementCops;  
                    caso.OS_Fecha_Fin_Entitlement__c = fechaLimiteResolucion;  
                }  
            }   
        } 
    }

    private void pausarReanudarMilestones(List<Case> listNewObj, Map<Id, Case> mapOldObj, List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA) {
        List<String> procedenciasCierreCaso = OS_Milestone.listadoCanalesProcedencias('procedenciasCierreCaso');
        List<String> procedenciasUafe = OS_Milestone.listadoCanalesProcedencias('procedenciasUafe');
        List<Case> casosIncumplimientosUAFE = new List<Case>();
        String canalProcedenciaCaso;
        
        for (Case caso : listNewObj){
            if(caso.Status != mapOldObj.get(caso.Id).Status) {
                canalProcedenciaCaso = (String)OS_Milestone.calculoCanalProcedenciaEmail(procedenciasCierreCaso, caso, listaBuzonesEmailColasTlfSLA).get('canalProcedenciaCaso');
                if(canalProcedenciaCaso != null && procedenciasCierreCaso.contains(canalProcedenciaCaso)) {
                    //UAFE, Efectivo y Holabank se paran en Pendiente Colaborador, Pendiente Cliente y Pendiente Alerta
                    if((caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Alerta') && procedenciasCierreCaso.contains(canalProcedenciaCaso) && caso.IsStopped == false) {
                        caso.IsStopped = true;
                    }
                    //Las tres se reactivan en Activo
                    if(caso.Status == 'Activo' && caso.IsStopped == true) {
                        caso.IsStopped = false;
                    }
                    //Contador inclumplimientos para UAFE
                    if(caso.Status == 'Activo' && (mapOldObj.get(caso.Id).Status == 'Cerrado' ||  mapOldObj.get(caso.Id).Status =='Rechazado') && procedenciasUafe.contains(canalProcedenciaCaso)) {
                        casosIncumplimientosUAFE.add(caso);
                    }
                }
            }
        }

        if(!casosIncumplimientosUAFE.isEmpty()) {
            List<BusinessHours> businessHoursList = [SELECT Id, name, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime FROM BusinessHours];
            for(Case caso: casosIncumplimientosUAFE) {
                Map<String, Object> camposCalculoMilestone = OS_Milestone.calculoParametrosMilestone(caso, businessHoursList, listaBuzonesEmailColasTlfSLA);
                caso.OS_Fecha_Fin_Entitlement__c = (Datetime)camposCalculoMilestone.get('fechaLimiteResolucion');

                if(caso.OS_SLA_Completado__c != 'Completed') {
                    caso.IsStopped = false;
                    if(caso.OS_Incumplimientos_SLA_Reapertura__c == null) {
                        caso.OS_Incumplimientos_SLA_Reapertura__c = 0;
                    }
                    caso.OS_Incumplimientos_SLA_Reapertura__c += 1;
                }
            }
        }
    }

    private void actualizarFechaFilSLAReanudarMilestone(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        Set<Id> caseIds = new Set<Id>();
        for (Case caso : listNewObj) {
            if(caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Activo' && caso.IsStopped == false && mapOldObj.get(caso.Id).IsStopped == true) {
                caseIds.add(caso.Id);
            }
        }
        //@future para actualizar la Fecha de fin de SLA tras la reapetura de un caso cuyos Milestones estaban parados
        if(!caseIds.isEmpty()) {
            OS_Case.actualizarFechaFinSLAMilestone(caseIds);
        }
    }

    private void completarMilestones(List<Case> listNewObj, Map<Id, Case> mapOldObj, List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA) {
        //PROCEDENCIAS
        //Cerrar en toma de propiedad de caso
        List<String> procedenciasCierreTomaPropiedad = OS_Milestone.listadoCanalesProcedencias('procedenciasCierreTomaPropiedad');
        //Cerrar cuando se cierra/rechaza el caso
        List<String> procedenciasCierreCaso = OS_Milestone.listadoCanalesProcedencias('procedenciasCierreCaso');         
             
        String canalProcedenciaCaso;
        
        //Casos a cerrar milestones
        Set<Id> casesId = new Set<Id>();

        for (Case caso : listNewObj) {
            //Cierro SLAS de casos en toma de propiedad del caso -- 20/7/23: o si se cierra 
            if( (mapOldObj.get(caso.Id).OwnerId != caso.OwnerId && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('00G') && String.valueOf(caso.OwnerId).startsWith('005')) 
                || (mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'Cerrado' || caso.Status == 'Rechazado')) ) {
                    if(procedenciasCierreTomaPropiedad.contains(caso.CC_Canal_Procedencia__c)) {
                    casesId.add(caso.Id);
                    }
            }
            //Cierro SLA en cierre/rechazo del caso de las procedencias que no cierran SLA en toma de propiedad
            if(mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'Cerrado' || caso.Status == 'Rechazado') && !procedenciasCierreTomaPropiedad.contains(caso.CC_Canal_Procedencia__c)) {
                canalProcedenciaCaso = (String)OS_Milestone.calculoCanalProcedenciaEmail(procedenciasCierreCaso, caso, listaBuzonesEmailColasTlfSLA).get('canalProcedenciaCaso');
                if(procedenciasCierreCaso.contains(canalProcedenciaCaso)) {
                    casesId.add(caso.Id);
                }
            }
            //Reapertura SLAs
            if(mapOldObj.get(caso.Id).Status != caso.Status && 
            (caso.Status != 'Cerrado' && caso.Status != 'Rechazado') &&
            (mapOldObj.get(caso.Id).Status == 'Cerrado' || mapOldObj.get(caso.Id).Status == 'Rechazado')){
                caso.OS_SLA_Completado__c = '';
            }
        }
        if(!casesId.isEmpty()) {
            //Casos actualizar campo OS_SLA_Completado__c
            Set<Id> casosSLACompletado = new Set<Id>();
            Set<Id> casosSLAIncumplen = new Set<Id>();
            //Completa los milestones abiertos de los casos indicados
            List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, TargetDate, CaseId FROM CaseMilestone WHERE CaseId IN :casesId AND CompletionDate = null];
            if(!milestonesEnCurso.isEmpty()) {
                for(CaseMilestone milestone : milestonesEnCurso) {
                    milestone.CompletionDate = System.now();
                    //cumplen SLA
                    if(milestone.CompletionDate <= milestone.TargetDate) {
                        casosSLACompletado.add(milestone.CaseId);
                    }
                    //no lo cumplen
                    else{
                        casosSLAIncumplen.add(milestone.CaseId);
                    }
                }
                Update milestonesEnCurso;
                
                if(!casosSLACompletado.isEmpty()) {
                    for(Case caso : listNewObj) {
                        if(casosSLACompletado.contains(caso.Id)) {
                            caso.OS_SLA_Completado__c = 'Completed';
                        }
                    }
                } 
                if (!casosSLAIncumplen.isEmpty()) {
                    for(Case caso : listNewObj) {
                        if(casosSLAIncumplen.contains(caso.Id)) {
                            caso.OS_SLA_Completado__c = 'Violated';
                        }
                    }
                }
            }  
        }            
    }
    
    private void actualizarPropietarioAnterior(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        for (Case caso : listNewObj) {
            if(caso.OwnerId != mapOldOBj.get(caso.Id).OwnerId && String.valueOf(mapOldOBj.get(caso.Id).OwnerId).startsWith('005')) {
                caso.CC_Owner_Anterior__c = mapOldOBj.get(caso.Id).OwnerId;
            }
        }
    }
    
    private void informarBuzonSalidaCaso(Map<Id, Case> mapOldObj, List<Case> listNewObj){
        Boolean tematicaExistente = false;
        Set<String> canalProcedenciaCasos = new Set<String>();
        List<Case> casosConTematica = new List<Case>();
        List<Case> casosSinTematica = new List<Case>();
        
        //Si el caso tiene temática - buscamos el buzón de salida correspondiente || Si no, pasamos a buscar el del metadato
        for(Case caso: listNewObj){
            if(caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c){
                if(caso.CC_MCC_Tematica__c != null){
                    tematicaExistente = true;
                    casosConTematica.add(caso);
                }
            }
        }
        //El caso tiene temática
        if(tematicaExistente){   
            //Se prepara mapa con la relación entre los nombres y las direcciones de los buzones
            Map<String, String> mapaBuzones = new Map<String, String>();
            for (OrgWideEmailAddress buzon : [SELECT DisplayName, Address FROM OrgWideEmailAddress]) {
                mapaBuzones.put(buzon.DisplayName, buzon.Address);
            }
            //Se recuperan las temáticas de los casos
            List<Id> idTematicas = CC_MetodosUtiles.listaCampo(casosConTematica, 'CC_MCC_Tematica__c');

            //Para cada caso, el buzón de salida es la dirección del buzón que indica su temática
            Map<Id, CC_MCC__c> tematicas = new Map<Id, CC_MCC__c>([SELECT OS_Buzon_Salida__c FROM CC_MCC__c WHERE Id IN :idTematicas]);
            
            for (Case caso : casosConTematica) {
                if(tematicas.containsKey(caso.CC_MCC_Tematica__c)){
                    CC_MCC__c tematica = tematicas.get(caso.CC_MCC_Tematica__c);
                    if (mapaBuzones.containsKey(tematica.OS_Buzon_Salida__c)) {
                        caso.CC_Buzon_Salida__c = mapaBuzones.get(tematica.OS_Buzon_Salida__c);
                    }
                    else {
                        caso.CC_Buzon_Salida__c = null;
                    }
                }
                //Si el Buzón de salida no se informa a través de la temática, se informa el del metadato
                if(caso.CC_Buzon_Salida__c == null){
                    tematicaExistente = false;
                    canalProcedenciaCasos.add(caso.CC_Canal_Procedencia__c);
                    casosSinTematica.add(caso);
                }
            }       
        }    
        //Informamos el buzón de salida a través del metadato
        if(!tematicaExistente){
            Map<String, String> canalProcedenciaBuzonSalidaMap = new Map<String, String>();
            List<OS_Correo__mdt> buzonSalidaList = [SELECT OS_Canal_Procedencia__c, OS_Correo__c FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c = :canalProcedenciaCasos];
            for(OS_Correo__mdt correoMdt: buzonSalidaList){
                canalProcedenciaBuzonSalidaMap.put(correoMdt.OS_Canal_Procedencia__c, correoMdt.OS_Correo__c);
            }
            for(Case caso: casosSinTematica){
                if(canalProcedenciaBuzonSalidaMap.containsKey(caso.CC_Canal_Procedencia__c)){
                    caso.CC_Buzon_Salida__c = canalProcedenciaBuzonSalidaMap.get(caso.CC_Canal_Procedencia__c);
                }
            }
        }
    } 
    
    private static void camposTrasladoRemitidoAutomatico(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        
        Map<Id, Case> casoIdMotivo = new Map<Id, Case>();
        Map<Id, Id> casoIdMotivoId = new Map<Id, Id>();
        Map<Id, String> motivoTraslado = new Map<Id, String>();
        
        for (Case caso : listNewObj)  {
            if (mapOldObj.get(caso.Id).CC_MCC_Motivo__c != caso.CC_MCC_Motivo__c && caso.CC_MCC_Motivo__c != null)  { 
                casoIdMotivo.put(caso.CC_MCC_Motivo__c, caso);
                casoIdMotivoId.put(caso.Id, caso.CC_MCC_Motivo__c);
            }
        }
        Set<Id> idCasos = new Set<Id>();
        List<Case> casos = new List<Case>();
        if (casoIdMotivo.size() > 0) {
            List<CC_MCC__c> listaMotivos = [SELECT CBK_Traslado_Remitido__c, Id  FROM CC_MCC__c WHERE Id IN :casoIdMotivo.keySet()];
            for (CC_MCC__c motivo : listaMotivos) {
                if (motivo.CBK_Traslado_Remitido__c != null) {
                    casos.add(casoIdMotivo.get(motivo.Id));
                    motivoTraslado.put(motivo.Id, motivo.CBK_Traslado_Remitido__c);
                    idCasos.add(casoIdMotivo.get(motivo.Id).Id);
                }
            }
            if (!casos.isEmpty()) {
                List<CC_MCC_Grupo_Colaborador__c> listaMotivosGrupos = [SELECT CC_Grupo_Colaborador__r.Name, CC_Grupo_Colaborador__c, CC_MCC__c  FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c IN :casoIdMotivo.keySet()];                               
                List<CC_MCC_Plantilla__c> listaMotivosPlantilla = [SELECT CC_MCC__c, CC_MCC_Plantilla_DeveloperName__c  FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN :casoIdMotivo.keySet()];
                
                if (!listaMotivosGrupos.isEmpty() && !listaMotivosPlantilla.isEmpty()){
                    
                    Map<Id, String> idMotivoGrupo = new Map<Id, String>();
                    for (CC_MCC_Grupo_Colaborador__c grupoMotivo : listaMotivosGrupos) {
                        idMotivoGrupo.put(grupoMotivo.CC_MCC__c, grupoMotivo.CC_Grupo_Colaborador__r.Name);
                    }
                    for (Case caso : casos) {
                        caso.OS_Cerrado_Operativa__c = motivoTraslado.get(caso.CC_MCC_Motivo__c) == 'Remitido' && caso.AccountId != null 
                        && caso.ContactId != null && caso.CC_MCC_Causa__c != null && caso.CC_MCC_Solucion__c != null ? true:false;
                        
                        caso.CBK_Traslado_Remitido__c = motivoTraslado.get(caso.CC_MCC_Motivo__c);
                        caso.CC_Ultima_Operativa_Correo__c = motivoTraslado.get(caso.CC_MCC_Motivo__c) == 'Remitido' ? 'remitir':'trasladar';
                        caso.CC_Grupo_Colaborador__c = idMotivoGrupo.get(casoIdMotivoId.get(caso.Id));
                        //Se calcula en OS_Case: caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id);        
                    }
                }
            }
        }
    }

    private void gestionarDANDGDT(Map<Id, Case> mapOldObj, List<Case> listNewObj){
        List<Case> casosInformarDANDGDT = new  List<Case>();
        List<Case> casosdesInformarDANDGDT = new  List<Case>();
        for(Case caso: listNewObj){
            if(caso.AccountId != mapOldObj.get(caso.Id).AccountId){
                if (caso.AccountId != null) {
                    casosInformarDANDGDT.add(caso);
                } else {
                    casosdesInformarDANDGDT.add(caso);
                }
                
            }
        }

        if(!casosInformarDANDGDT.isEmpty()){
            OS_Informar_DAN_DG_DT_Caso.informarCamposBeforeTrigger(casosInformarDANDGDT);
        }

        if(!casosdesInformarDANDGDT.isEmpty()){
            OS_Informar_DAN_DG_DT_Caso.desinformarCampos(casosdesInformarDANDGDT);
        }
    }


    private void reasignarCasoBackup(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        
        Set<Id> setIdUser = new Set<Id>(); 
        List<Case> listCases = new List<Case>();

        for (Case newCaso: listNewObj){    
            String propietario = string.valueOf(newCaso.ownerId);
            //Casos reactivados
            if ((mapOldObj.get(newCaso.Id).Status == 'Cerrado' || mapOldObj.get(newCaso.Id).Status == 'Rechazado') && newCaso.Status == 'Activo'){
                if(propietario.subString(0,3)=='005'){
                    setIdUser.add(newCaso.OwnerId);
                    listCases.add(newCaso);
                }
            }      
            //Casos que cambian de owner
            else if(mapOldObj.get(newCaso.Id).OwnerId != newCaso.OwnerId && propietario.subString(0,3)=='005') {
                setIdUser.add(newCaso.OwnerId);
                listCases.add(newCaso);
            }
        }
        if (!setIdUser.isEmpty()){
            OS_CaseTriggerHelper.actualizarOwnerBackup(setIdUser, listCases);
        }
    }

    private void actualizarGrupoTrabajoTransferLlamada(List<Case> listNewObj, Map<Id, Case> mapOldObj){
        Map<Id, Task> mapaIdTarea = new Map<Id, Task>();
        List<Task> tareas = new List<Task>();
        List<String> consultas = new List<String>();
        List<OS_Cartera__c> carteras = new List<OS_Cartera__c>();
        Map<String, String> mapaCarteraGrupo = new Map<String, String>();
        Set<Id> casosId = new Set<Id>();

        for(Case caso : listNewObj){
            if(caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.Origin == 'Phone'){
                casosId.add(caso.Id);
            }
        }

        if(!casosId.isEmpty()){
            tareas = [SELECT Id, WhatId, CC_Consulta__c FROM Task WHERE WhatId IN :casosId AND (Type = 'Llamada transferida' OR Type = 'Consulta') ORDER BY CreatedDate ASC];

            for(Task tarea : tareas){
                if(String.isNotEmpty(tarea.CC_Consulta__c)){
                    mapaIdTarea.put(tarea.WhatId, tarea);
                }
                
                if(!consultas.contains(tarea.CC_Consulta__c)){
                    consultas.add(tarea.CC_Consulta__c);
                }
            }

            carteras = [SELECT Id, Name, OS_GrupoTrabajo_ColaTelefonia__r.Name FROM OS_Cartera__c WHERE Name IN :consultas AND RecordType.Name = 'Cola Telefonía'];

            for(OS_Cartera__c cartera : carteras){
                mapaCarteraGrupo.put(cartera.Name, cartera.OS_GrupoTrabajo_ColaTelefonia__r.Name);
            }

            for(Case caso : listNewObj){
                if(caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.Origin == 'Phone' && mapaIdTarea.containsKey(caso.Id)){
                    caso.OS_GrupoTrabajo__c = mapaCarteraGrupo.get(mapaIdTarea.get(caso.Id).CC_Consulta__c);
                }
            }
        }
        
    }

    private void restringirCambioPropietarioGT(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        //Método para comprobar que cuando se cambia de propietario (siempre y cuando no sea a una cola), el nuevo owner pertenece al Grupo de Trabajo del caso
        Set<String> gruposTrabajo = new Set<String>();
        Set<Case> casos = new Set<Case>();
        Map<String, List<Id>> mapaColabGT = new Map<String, List<Id>>();

        for (Case caso : listNewObj){
            if(caso.OwnerId != mapOldOBj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('005')){
                gruposTrabajo.add(caso.OS_GrupoTrabajo__c);
                casos.add(caso);
            }
        }

        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__r.Name FROM CC_Grupo_Colaborador_Contact__c 
                                                                    WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'OS_GrupoTrabajo'
                                                                    AND CC_Grupo_Colaborador__r.Name IN : gruposTrabajo];
                                                                
        for(CC_Grupo_Colaborador_Contact__c colaborador : listaColaboradores){
            if(mapaColabGT.containsKey(colaborador.CC_Grupo_Colaborador__r.Name)){
                mapaColabGT.get(colaborador.CC_Grupo_Colaborador__r.Name).add(colaborador.CC_Usuario__c);
            }
            else{
                mapaColabGT.put(colaborador.CC_Grupo_Colaborador__r.Name, new List<Id> {colaborador.CC_Usuario__c});
            }
        }
        
        for(Case casoActualizado : casos){
            if(mapaColabGT.containsKey(casoActualizado.OS_GrupoTrabajo__c)){
                if(!mapaColabGT.get(casoActualizado.OS_GrupoTrabajo__c).contains(casoActualizado.OwnerId)){
                    casoActualizado.addError('No se puede asignar un propietario que no pertenezca al Grupo de Trabajo del caso');
                }
            }
            
        }
    }
}