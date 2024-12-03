public with sharing class OS_Case_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
    }
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {

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
        for (Case caso: listNewObj){
            if(((setIdsRt).contains(caso.RecordTypeId))||(caso.RecordTypeId == null)){
                listNewObjCops.add(caso);
                mapNewObjCops.put(caso.Id,caso);                
            }
        }
        if (listNewObjCops.size() != 0){
            OS_CaseTriggerHelper.personAccountBI(listNewObjCops); 
            OS_CaseTriggerHelper.identificarClienteAlfBI(listNewObjCops);
            OS_CaseTriggerHelper.creacionCaso_BI(listNewObjCops);
            OS_CaseTriggerHelper.seInformaCanalRespuestaBI(listNewObjCops);
            OS_CaseTriggerHelper.causaInformadoBI(listNewObjCops);
            OS_CaseTriggerHelper.solucionInformadoBI(listNewObjCops);
            OS_CaseTriggerHelper.informarOficinaAfectadaBI(listNewObjCops);
            OS_CaseTriggerHelper.tematicaInformadoBI(listNewObjCops);
            OS_CaseTriggerHelper.productoInformadoBI(listNewObjCops);
            OS_CaseTriggerHelper.motivoInformadoBI(listNewObjCops);


            enmascararPANs(listNewObjCops); //Se enmascaran los PANs de tarjeta de crédito en caso de haberlos
            informarCampos(listNewObjCops);
            actualizarTelefonoEmailCasos(listNewObjCops);
            informarEntitlement(listNewObjCops);
            informarGrupoTrabajo(listNewObjCops);
            informarCentroManipulador(listNewObjCops);
            informarBuzonSalidaCaso(listNewObjCops);
            camposTrasladoRemitidoAutomatico(listNewObjCops);
            informarDepartamento(listNewObjCops);
            actualizarTelefonoAccountCasosCOPS(listNewObjCops);
        }
    }
    
    private void actualizarTelefonoEmailCasos(List<Case> listNewObj) {
        //Si es un caso de COPS y ha cambiado el contacto, se actualizan los campos "Teléfono del caso" y "Email del caso"
        List<Case> listCasos = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.ContactId != null) {
                listCasos.add(caso);
            }
        }
        if(!listCasos.isEmpty()){
            OS_Case.actualizarTelefonoEmailCaso(listCasos);
        }
    }
    
    private void enmascararPANs(List<Case> listNewObj) {
        for (Case caso : listNewObj) {
            
            // Se establece un patrón para el PAN
            String panRegex = '[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}';
            Pattern myPattern = Pattern.compile(panRegex);
            
            // Campo "Asunto"
            if (!String.isEmpty(caso.Subject)) {
                Matcher asuntoMatcher = myPattern.matcher(caso.Subject);
                
                while (asuntoMatcher.find()) {

                    Integer indexIncio = caso.Subject.indexOf(asuntoMatcher.group());
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();

                    if((indexIncio == 0 || indexIncio > 0 && !caso.Subject.split('').get(indexIncio-1).isNumeric()) && (caso.Subject.split('').size() <= indexFinal || !caso.Subject.split('').get(indexFinal).isNumeric())){
                        String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                        caso.Subject = caso.Subject.replace(asuntoMatcher.group(), encryptedPan);
                    }
                }            
            }
            // Campo "Descripción"
            if (!String.isEmpty(caso.Description)) {
                Matcher asuntoMatcher = myPattern.matcher(caso.Description);
                
                while (asuntoMatcher.find()) {

                    Integer indexIncio = caso.Description.indexOf(asuntoMatcher.group());
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();

                    if((indexIncio == 0 || indexIncio > 0 && !caso.Description.split('').get(indexIncio-1).isNumeric()) && (caso.Description.split('').size() <= indexFinal || !caso.Description.split('').get(indexFinal).isNumeric())){
                        String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                        caso.Description = caso.Description.replace(asuntoMatcher.group(), encryptedPan);
                    }
                }            
            }            
            
            // Campo "Detalle Consulta"
            if (!String.isEmpty(caso.CC_Detalles_Consulta__c)) {
                Matcher asuntoMatcher = myPattern.matcher(caso.CC_Detalles_Consulta__c);
                
                while (asuntoMatcher.find()) {
                    
                    Integer indexIncio = caso.CC_Detalles_Consulta__c.indexOf(asuntoMatcher.group());
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    
                    if((indexIncio == 0 || indexIncio > 0 && !caso.CC_Detalles_Consulta__c.split('').get(indexIncio-1).isNumeric()) && (caso.CC_Detalles_Consulta__c.split('').size() <= indexFinal || !caso.CC_Detalles_Consulta__c.split('').get(indexFinal).isNumeric())){
                        String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                        caso.CC_Detalles_Consulta__c = caso.CC_Detalles_Consulta__c.replace(asuntoMatcher.group(), encryptedPan);
                    }   
                }            
            }
            // Campo "Detalle Solución"
            if (!String.isEmpty(caso.CC_Detalles_Solucion__c)) {
                Matcher asuntoMatcher = myPattern.matcher(caso.CC_Detalles_Solucion__c);
                
                while (asuntoMatcher.find()) {
                    
                    Integer indexIncio = caso.CC_Detalles_Solucion__c.indexOf(asuntoMatcher.group());
                    Integer indexFinal = indexIncio + asuntoMatcher.group().length();
                    
                    if((indexIncio == 0 || indexIncio > 0 && !caso.CC_Detalles_Solucion__c.split('').get(indexIncio-1).isNumeric()) && (caso.CC_Detalles_Solucion__c.split('').size() <= indexFinal || !caso.CC_Detalles_Solucion__c.split('').get(indexFinal).isNumeric())){
                        String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                        caso.CC_Detalles_Solucion__c = caso.CC_Detalles_Solucion__c.replace(asuntoMatcher.group(), encryptedPan);
                    }
                }            
            }
        }
    }
    
    private void informarCampos(List<Case> listNewObj) {
        
        for (Case caso : listNewObj) {
            //Se informa el canal de resolución con el valor del canal de procedencia
            caso.CC_Canal_Resolucion__c = caso.CC_Canal_Procedencia__c;
        }
    }
    
    private void informarEntitlement(List<Case> listNewObj) {
        //PROCEDENCIAS cuyo SLA se cierra en la toma de posesión
        List<String> procedenciasBosEmail = OS_Milestone.listadoCanalesProcedencias('procedenciasBosEmail');
        List<String> procedenciasGocEmail = OS_Milestone.listadoCanalesProcedencias('procedenciasGocEmail');
        List<String> procedenciasUaiEmail = OS_Milestone.listadoCanalesProcedencias('procedenciasUaiEmail');
        List<String> procedenciasCierreTomaPropiedad = OS_Milestone.listadoCanalesProcedencias('procedenciasCierreTomaPropiedad');
  
        //PROCEDENCIAS cuyo SLA se cierra en el cierre del caso
        List<String> procedenciasHolabank = OS_Milestone.listadoCanalesProcedencias('procedenciasHolabank');
        List<String> procedenciasEfectivo = OS_Milestone.listadoCanalesProcedencias('procedenciasEfectivo');
        List<String> procedenciasUafe = OS_Milestone.listadoCanalesProcedencias('procedenciasUafe');
        List<String> procedenciasCierreCaso = OS_Milestone.listadoCanalesProcedencias('procedenciasCierreCaso');
     
        //LISTA TOTAL DE PROCEDENCIAS
        List<String> procedenciasTotales = OS_Milestone.listadoCanalesProcedencias('procedenciasTotales');

        List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA = [SELECT Name, CC_Valor__c, CC_Lista__r.Name FROM CC_Lista_Valores__c WHERE 
            (CC_Lista__r.Name = 'COPS: SLA Relación colas telefonía y canal de procedencia email' OR CC_Lista__r.Name = 'COPS: Horas SLA para servicios UAFE')
             AND CC_Activa__c = true];             
             
        String canalProcedenciaCaso;
        Set<Id> casosInformarEntitlement = new Set<Id>();
        Set<Id> casoMCCIds = new Set<Id>();
        
        for(Case caso : listNewObj) {

            canalProcedenciaCaso = (String)OS_Milestone.calculoCanalProcedenciaEmail(procedenciasTotales, caso, listaBuzonesEmailColasTlfSLA).get('canalProcedenciaCaso');

            if((caso.Origin == 'Email' && procedenciasCierreTomaPropiedad.contains(canalProcedenciaCaso)) || procedenciasCierreCaso.contains(canalProcedenciaCaso)){
                    casosInformarEntitlement.add(caso.Id);
                    //Si es holabank o efectivo y tiene temática o producto guardamos los ids del MCC para sacar las BH
                    if((procedenciasEfectivo.contains(canalProcedenciaCaso) || procedenciasHolabank.contains(canalProcedenciaCaso)) && (caso.CC_MCC_Tematica__c != null || caso.CC_MCC_ProdServ__c != null)) {                        
                        if(caso.CC_MCC_Tematica__c != null ){
                            casoMCCIds.add(caso.CC_MCC_Tematica__c);
                        } 
                        if(caso.CC_MCC_ProdServ__c != null ) {
                            casoMCCIds.add(caso.CC_MCC_ProdServ__c);
                        } 
                        if(caso.CC_MCC_Causa__c != null ) {
                            casoMCCIds.add(caso.CC_MCC_Causa__c);
                        } 
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
            Map<String,Id> mapEntitlement = new Map<String,Id>();
            List<Entitlement> entitlements = [SELECT Name FROM Entitlement];
            for (Entitlement entitlement : entitlements) {
                mapEntitlement.put(entitlement.name, entitlement.Id);
            }    
            //Business Hours
            List<BusinessHours> businessHoursList = [SELECT Id, name, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime FROM BusinessHours];
            Map<Id,BusinessHours> mapBusinessHour = new Map<Id,BusinessHours>();   
            
            Datetime fechaLimiteResolucion;  
            
            for (Case caso: listNewObj) {
                if(casosInformarEntitlement.contains(caso.Id)) {
                    canalProcedenciaCaso = (String)OS_Milestone.calculoCanalProcedenciaEmail(procedenciasTotales, caso, listaBuzonesEmailColasTlfSLA).get('canalProcedenciaCaso');

                    Map<String, Object> camposCalculoMilestone = OS_Milestone.calculoParametrosMilestone(caso, businessHoursList, listaBuzonesEmailColasTlfSLA, businessHoursMCC);
                    mapBusinessHour = (Map<Id,BusinessHours>)camposCalculoMilestone.get('mapBusinessHour');
                    fechaLimiteResolucion = (Datetime)camposCalculoMilestone.get('fechaLimiteResolucion');
    
                    Id idBusinessHours;
                    BusinessHours businessHour;
                    Id entitlementCops;
                    
                    if (procedenciasUaiEmail.contains(canalProcedenciaCaso)) {
                        //CASO UAI
                        entitlementCops = mapEntitlement.get('Entitlement COPS');  
                    }
                    else if (procedenciasGocEmail.contains(canalProcedenciaCaso)) {
                        //CASO GOC
                        entitlementCops = mapEntitlement.get('Entitlement COPS - GOC');   
                    } 
                    else if (procedenciasBosEmail.contains(canalProcedenciaCaso)) {
                        //CASO BOS
                        entitlementCops = mapEntitlement.get('Entitlement COPS - BOS');  
                    } 
                    else if (procedenciasEfectivo.contains(canalProcedenciaCaso) || procedenciasHolabank.contains(canalProcedenciaCaso)) { 
                        idBusinessHours = (Id)camposCalculoMilestone.get('idBusinessHours');
                        businessHour = mapBusinessHour.get(idBusinessHours);
                        String horas = (String)camposCalculoMilestone.get('horas'); //caso.CC_MCC_Causa__r.OS_Horas_SLA__c 

                        if (businessHour != null && idBusinessHours != null && horas != null && horas != ''){
                            for (String entitlementName: mapEntitlement.keySet()) {
                                if (entitlementName.contains(businessHour.name)) {
                                    entitlementCops = mapEntitlement.get(entitlementName);
                                    break;
                                }
                            } 
                        }
                    }
                    else if(procedenciasUafe.contains(canalProcedenciaCaso)) {
                        //Informar entitlements NUEVO UAFE -- El nombre del entitlement contendrá el canal de procedencia email
                        for (String entitlementName: mapEntitlement.keySet()) {
                            if(entitlementName.contains(canalProcedenciaCaso)) {
                                entitlementCops = mapEntitlement.get(entitlementName);
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
    
    private void informarGrupoTrabajo(List<Case> listNewObj) {
        Boolean informarGT = false;
        
        Map<Id,Id> mapPropietarioCaso = new Map<Id,Id>();
        Map<Id,String> mapColasCaso = new Map<Id,String>();
        List<String> colas = new List<String>();
        
        for (Case caso : listNewObj) {
            if (caso.OwnerId !=null && String.valueOf(caso.OwnerId).startsWith('00G')) {
                colas.add(caso.OwnerId);
                mapPropietarioCaso.put(caso.OwnerId,caso.Id);
                informarGT = true;
            }
        }
        if (informarGT){
            List<Group> queues = new List<Group>();
            queues = [SELECT id, name FROM Group WHERE Type = 'Queue' AND Id IN :colas];
            colas.clear();
            
            for (Group cola : queues){
                colas.add(cola.Name);
                mapColasCaso.put(mapPropietarioCaso.get(cola.Id),cola.Name);
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
    
    private void informarCentroManipulador(List<Case> listNewObj) {
        Boolean informarCentro = false;
        
        Map<Id,Id> mapIdCasoAccountId = new Map<Id,Id>();
        for (Case caso : listNewObj) {
            if (caso.AccountId !=null && caso.CC_Canal_Procedencia__c == 'Buzón Efectivo COPS'  && caso.OS_ViaClasificacion__c != 'Regla Clasificación' && caso.OS_ReglaUtilizada__c == null) {
                mapIdCasoAccountId.put(caso.Id,caso.AccountId);
                informarCentro = true;
            }
        }
        if (informarCentro) {
            Map<Id,String> mapCuentaCentroManipulador = new Map<Id,String>();
            List<Account> cuentas = new List<Account>();
            cuentas = [SELECT ID, OS_Centro_Manipulador__c FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' AND OS_Centro_Manipulador__c <> null AND Id IN :mapIdCasoAccountId.values()];
            if (!cuentas.isEmpty()){
                for (Account cuenta : cuentas) {
                    mapCuentaCentroManipulador.put(cuenta.Id, cuenta.OS_Centro_Manipulador__c);
                }
                Map<Id,String> mapCentroManipuladorGrupo = new Map<Id,String>();
                Map<String,Id> mapGrupoCola = new Map<String,Id>();
                List<Group> queues= new List<Group>();
                List<OS_Cartera__c> centros = [SELECT Id, Name, OS_GrupoTrabajo__c, OS_GrupoTrabajo__r.OS_GrupoTrabajo__c FROM OS_Cartera__c 
                                                WHERE RecordType.DeveloperName = 'OS_Centro_Manipulador' 
                                                AND Id IN :mapCuentaCentroManipulador.values()
                                                AND OS_Activo__c = true];
                
                if (!centros.isEmpty()){
                    for (OS_Cartera__c centro : centros) {
                        mapCentroManipuladorGrupo.put(centro.Id, centro.OS_GrupoTrabajo__r.OS_GrupoTrabajo__c);
                    }
                    queues = [SELECT id, name FROM Group WHERE Type = 'Queue' AND NAME IN :mapCentroManipuladorGrupo.values()];
                    if (!queues.isEmpty()) {
                        for (Group cola : queues) {
                            mapGrupoCola.put(cola.name.toLowerCase(), cola.Id);
                        }
                    }
                }
                for (Case caso : listNewObj) {
                    caso.OS_Centro_Manipulador__c = mapCuentaCentroManipulador.get(mapIdCasoAccountId.get(caso.Id));
                    if (!queues.isEmpty()) {
                        System.debug( 'id' +mapGrupoCola.get(mapCentroManipuladorGrupo.get(mapCuentaCentroManipulador.get(mapIdCasoAccountId.get(caso.Id))).toLowerCase()));
                        caso.OwnerId = mapGrupoCola.get(mapCentroManipuladorGrupo.get(mapCuentaCentroManipulador.get(mapIdCasoAccountId.get(caso.Id))).toLowerCase());
                    }
                    if (!centros.isEmpty()){
                        caso.OS_GrupoTrabajo__c = mapCentroManipuladorGrupo.get(mapCuentaCentroManipulador.get(mapIdCasoAccountId.get(caso.Id)));
                    }
                }
            }
        }
    }
    
    private static void camposTrasladoRemitidoAutomatico(List<Case> listNewObj) {
        //Detectamos si el caso tiene un MCC que deba producir un traslado a colaborador automático
        Map<Id, Case> casoIdMotivo = new Map<Id, Case>();
        Map<Id, Id> casoIdMotivoId = new Map<Id, Id>();
        Map<Id, String> motivoTraslado = new Map<Id, String>();
        List<Case> casos = new List<Case>();
        
        for (Case caso : listNewObj)  {
            if (caso.CC_MCC_Motivo__c != null)  { 
                casoIdMotivo.put(caso.CC_MCC_Motivo__c, caso);
                casoIdMotivoId.put(caso.Id, caso.CC_MCC_Motivo__c);
            }
        }
        if (casoIdMotivo.size() > 0) {
            List<CC_MCC__c> listaMotivos = [SELECT CBK_Traslado_Remitido__c, Id  FROM CC_MCC__c WHERE Id IN :casoIdMotivo.keySet()];
            for (CC_MCC__c motivo : listaMotivos) {
                if (motivo.CBK_Traslado_Remitido__c != null) {
                    casos.add(casoIdMotivo.get(motivo.Id));
                    motivoTraslado.put(motivo.Id, motivo.CBK_Traslado_Remitido__c);
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
                        caso.CC_Grupo_Colaborador__c = idMotivoGrupo.get(casoIdMotivoId.get(caso.Id));
                    }
                }
            }
        }
    }

    private void informarDepartamento(List<Case> listNewObjCops) {
        Boolean informarD = false;
        Boolean informarDTelef = false;

        Map<String,String> MapDepartamento = new Map<String,String>();
        Map<String,String> MapDepartamentoTelef = new Map<String,String>();
        List<String> CanalProcedencia = new List<String>();
        List<String> CanalProcedenciaTelef = new List<String>();

        for (Case caso : listNewObjCops) {       
            if (caso.Origin == 'Email' || caso.Origin == 'Agenda de Riesgos' || caso.Origin == 'Valija Digital' && caso.CC_Canal_Procedencia__C != null ) {
                CanalProcedencia.add(caso.CC_Canal_Procedencia__c);
                informarD = true;
            } 
            if (caso.Origin == 'Phone' && caso.CC_Canal_Procedencia__C != null ) {
                CanalProcedenciaTelef.add(caso.CC_Canal_Procedencia__c);
                informarDTelef = true;
            }   
        }
        if (informarD){     //con Canal de Entrada = 'Email', 'Agenda de Riesgos' o 'Valija Digital'
            List<CC_Buzones_Por_Defecto__mdt> buzones = new List<CC_Buzones_Por_Defecto__mdt>();
            buzones = [SELECT CC_Canal_Procedencia__c, OS_Departamento__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c IN :CanalProcedencia];
            CanalProcedencia.clear();
                for (CC_Buzones_Por_Defecto__mdt departamento : buzones) {
                    MapDepartamento.put(departamento.CC_Canal_Procedencia__c,departamento.OS_Departamento__c);
                }
                for (Case caso : listNewObjCops) {
                    if (caso.Origin == 'Email' || caso.Origin == 'Agenda de Riesgos' || caso.Origin == 'Valija Digital' && caso.CC_Canal_Procedencia__C != null ) {
                        caso.OS_Departamento__c = MapDepartamento.get(caso.CC_Canal_Procedencia__c);
                }
            }
        }
        if (informarDTelef){     //con Canal de Entrada = 'Teléfono'
            List<CC_Lista_Valores__c> telefonos = new List<CC_Lista_Valores__c>();
            telefonos = [SELECT name, CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'COPS: Relación DNIS y Canal de procedencia' AND name IN :CanalProcedenciaTelef];
            CanalProcedenciaTelef.clear();

                for (CC_Lista_Valores__c departamento : telefonos) {
                    MapDepartamentoTelef.put(departamento.name,departamento.CC_Valor2__c);
                }
                for (Case caso : listNewObjCops) {
                    if (caso.Origin == 'Phone' && caso.CC_Canal_Procedencia__C != null ) {
                        caso.OS_Departamento__c = MapDepartamentoTelef.get(caso.CC_Canal_Procedencia__c);
                }
            }
        }
    }
    private void actualizarTelefonoAccountCasosCOPS(List<Case> listNewObj) {
        //Si es un caso de COPS y ha cambiado la Cuenta, se actualizan los campos "Account Phone" y "Account Mobile"
        List<Case> listCasos = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.AccountId != null) {
                listCasos.add(caso);
            }
        }
        if(!listCasos.isEmpty()){
            OS_Case.actualizarTelefonosAccount(listCasos);
        }
    }
    private void informarBuzonSalidaCaso(List<Case> listNewObj){
        Boolean tematicaExistente = false;
        Set<String> canalProcedenciaCasos = new Set<String>();
        List<Case> casosConTematica = new List<Case>();
        List<Case> casosSinTematica = new List<Case>();
        
        //Si el caso tiene temática - buscamos el buzón de salida correspondiente || Si no, pasamos a buscar el del metadato
        for(Case caso: listNewObj){
            if(caso.CC_MCC_Tematica__c != null){
                tematicaExistente = true;
                casosConTematica.add(caso);
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
}