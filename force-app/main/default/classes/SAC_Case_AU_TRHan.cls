/*****************************************************************
 * Name: SAC_Case_AU_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el After Update del objeto Case
 * Las clases test que ejecutan esta clase: SAC_Balanceo_Test, SAC_UpdateEstadosPretensiones_test, SAC_ComportamientoSLAs_Test, 
 * SAC_Notificacion_Test, SAC_FutureMethods_Test, SAC_Validaciones_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 2.0            US270297         Marcela Neira  10/09/21     Optimización de los métodos y
 *                                 Esteve  Llaó                revisión del trigger de Case
 * 2.1            US483941         Alex Pérez     24/11/2022   obtener el case desde el trigger de case mediante variable estática
 * 2.2            US866223         Alex Pérez     02/04/2024   fecha asignación TMO     
*****************************************************************/
public without sharing class SAC_Case_AU_TRHan extends CC_TriggerHandlerBase {
    
    public static Boolean procesado = false;
    public static Boolean segundoProcesado = false;
    private static Boolean compruebaPretensiones = false;
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_ParametrizacionSLATME__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    private static final Id RECTYPESLAALTA = mapRTsObjects.get('SAC_ParametrizacionSLATME__c').get('SAC_SLAAlta').getRecordTypeId();
    
    public static list<case> casesList = new list<Case>();
    public static map<id, case> casesMap = new map<id, case>();
    //public static List<SAC_ParametrizacionSLATME__c> parametrizacionAlta = new List<SAC_ParametrizacionSLATME__c>();
    public static map<string, SAC_ParametrizacionSLATME__c> mapParametrizacionAlta = new map<string, SAC_ParametrizacionSLATME__c>();
    
  public override void mainEntry(CC_TriggerParameters tp) {
    process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
  }
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        Set<Id> detalleId = new Set<Id>();
        Set<String> canalProcedencia = new Set<String>();
        //Las reclamaciones que entren deben incluir sus hijos ya que cuando se actualiza un case también salta la actualización de trigger de sus hijos

       
        for (Schema.RecordTypeInfo rt: lstRT){
            if (rt.getDeveloperName().left(4)=='SAC_') {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }
        List<Case> listNewObjSAC= New List<Case>();
        Map<Id, Case> mapNewObjSAC = New Map<Id, Case>();
        for (Case tk: listNewObj){
            
            if((setIdsRt).contains(tk.RecordTypeId)){
                listNewObjSAC.add(tk);
                mapNewObjSAC.put(tk.Id,tk);
                //variable query mileston SLA Alta
               /* if(tk.SEG_Detalle__c != null) {
                    detalleId.add(tk.SEG_Detalle__c);
                    canalProcedencia.add(tk.CC_Canal_Procedencia__c);
                }*/
                
            }
        }
        //caseslist.clear();
        /*caseslist = [SELECT Id, Subject, RecordTypeId, SAC_FechaRecepcion__c, SAC_TipoConsumidor__c, CreatedDate, SAC_Prorrogado__c, isStopped, 
                            SAC_Stopped_Milestone__c, SAC_TiempoSLARegulatorio__c, SAC_Reclamacion__c, SAC_Reclamacion__r.SAC_TipoConsumidor__c, 
                            SAC_FechaVencimientoSLA__c, SEG_Detalle__c, CC_Canal_Procedencia__c
                            FROM Case WHERE Id IN :listNewObjSAC OR SAC_Reclamacion__c IN :listNewObjSAC];*/
        

        
        List<Case> listOldObjSAC= New List<Case>();
        Map<Id, Case> mapOldObjSAC = New Map<Id, Case>();
        for (Case tk: listOldObj){
            if((setIdsRt).contains(tk.RecordTypeId)){
                listOldObjSAC.add(tk);
                mapOldObjSAC.put(tk.Id,tk);
            }
        }
        if (listNewObjSAC.size()!=0) {
            
            for(case casMil : [SELECT Id, Subject, RecordTypeId, SAC_FechaRecepcion__c, SAC_TipoConsumidor__c, CreatedDate, SAC_Prorrogado__c, isStopped, 
                            /*SAC_Stopped_Milestone__c,*/ SAC_TiempoSLARegulatorio__c, SAC_Reclamacion__c, SAC_Reclamacion__r.SAC_TipoConsumidor__c, 
                            SAC_FechaVencimientoSLA__c, SEG_Detalle__c, CC_Canal_Procedencia__c, SAC_TiempoSLALetradoAlta__c, SAC_Reclamacion__r.SAC_TipoSubsanacion__c, SAC_GenialEstado__c,
                            SAC_TiempoParadaSubsanacion__c, SAC_Reclamacion__r.SAC_TiempoParadaSubsanacion__c, SAC_MinutosParadaSubsanacion__c, SAC_Reclamacion__r.SAC_MinutosParadaSubsanacion__c
                            FROM Case WHERE Id IN :listNewObjSAC OR SAC_Reclamacion__c IN :listNewObjSAC]) {
            	casesMap.put(casMil.Id, casMil);
                if(casMil.SEG_Detalle__c != null) {
                    detalleId.add(casMil.SEG_Detalle__c);
                    canalProcedencia.add(casMil.CC_Canal_Procedencia__c);
                }
        	}
            for(SAC_ParametrizacionSLATME__c parAlta : [SELECT id, Name, SAC_Duracion__c, RecordTypeId, SAC_MCC__c, SAC_CanalProcedencia__c 
                                                        FROM SAC_ParametrizacionSLATME__c
                                                        WHERE RecordTypeId = :RECTYPESLAALTA
                                                        AND SAC_MCC__c IN :detalleId
                                                        AND SAC_CanalProcedencia__c IN :canalProcedencia]) {
            
            	MapParametrizacionAlta.put(parAlta.SAC_MCC__c + '|' + parAlta.SAC_CanalProcedencia__c, parAlta);
        	}
            processSAC(listNewObjSAC,mapNewObjSAC,listOldObjSAC,mapOldObjSAC);
        }
    }
    private void processSAC(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        Boolean recalcularSharesReclamaciones = false;
        Boolean recalcularSharesPretensiones = false;
        List<SObject> objetos =new list<SObject>();
        List<Case> listaPretensiones = new List<Case>();
        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaCasos = new List<Case>();
        List<Case> listaBalanceoLetrado = new List<Case>();
        List<Case> listaConsultas = new List<Case>();
        List<case> listNewCaseAsignarCasosAlOwner = new List<case>();
        List<case> listaNewConsultaAsignarCasosAlOwner = new List<case>();        
        List<Case> listaCaseActualizarEstado = new List<Case>();
        List<Case> listaCaseActualizarResolucion = new List<Case>();
        List<Case> listaCaseCalcularImporte = new List<Case>();
        List<Case> listaPretMCC = new List<Case>();
        List<Case> listaOwnersCambiados = new List<Case>();
        List<Case> listaReclaPadreCanalProcedencia = new List<Case>();
        List<Case> listaReclaCambiarEstado = new List<Case>();
        List<Case> listaReclamacionFechaRecepcion = new List<Case>();
        List<Case> listaReclamacionVuelveAlta = new List<Case>();
        List<Case> listaReclamacionEspecial = new List<Case>();
        List<Case> listaPretensionControlarMilestone = new List<Case>();
        List<Case> listaCambioEntidadPrincipal = new List<Case>();
        //List<Case> listaCambioEntidadProductora = new List<Case>();        
        List<Case> listaPretOwnerCola = new List<Case>();
        List<Case> listaRecalcularPreActivas = new List<Case>();
        List<Case> listaCambiarCasoEspecial = new List<Case>();
        List<Case> listaRecPretNegociacion = new List<Case>();
        List<Case> listaRecPretSubsanacion = new List<Case>();    
        List<Case> listaReclamacionSubsanacion = new List<Case>();
        List<Case> listaRecPreFechaResolucion  = new List<Case>(); 
        List<Case> listaReclaRechazadas  = new List<Case>();
        List<Case> listaVueltaDeDerivacion  = new List<Case>(); 
        List<Case> listaReabrirReclamacion  = new List<Case>(); 
        List<Case> listaBorrarMCC = new List<Case>();      
        List<Case> listaReclaDerivacion = new List<Case>(); 
        List<Case> listaReclamacionesConsultasAFinalizar = new List<Case>();
        List<Case> listaPretensionGrupoCambiado = new List<Case>();
        List<Case> listaPretensionesMccCambiado = new List<Case>();
        List<Case> listaCambioResultadoNegociacion = new List<Case>();
        List<Case> listaValidacionPretension = new List<Case>();
        List<Case> listaPretCambioArgumentario = new List<Case>();
        List<Case> listaPretCambioResumenManual = new List<Case>();
        List<Case> listaRecCambioNaturaleza = new List<Case>();
        List<Case> listaActualizarDatosContacto = new List<Case>();
        List<Case> listaModRecCerradas = new List<Case>();
        Set<Id> idsComprobarDespachoRepresentante = new Set<Id>();
        List<Case> listaComprobarDespachoRepresentante = new List<Case>();
        Set<Id> idsCambiaVinculacion = new Set<Id>();
        List<Case> listaReclaCambiaVinculacion = new List<Case>();
        Set<Id> idsAddVinculacion = new Set<Id>();
        List<Case> listaReclaAddVinculacion = new List<Case>();
        Set<Id> idsComplementariasCambiaImporteAbonado = new Set<Id>();
        List<Case> listaComplementariasCambiaImporteAbonado = new List<Case>();
        Set<Id> idsCambiaNaturalezaComplementaria = new Set<Id>();
        List<Case> listaCambiaNaturalezaComplementaria = new List<Case>();

        //List<CC_MCC_Grupo_Colaborador__c> listMccGrupos = new List<CC_MCC_Grupo_Colaborador__c>();
        List<Id> listaIdsCuentas = new List<Id>();        
        List<Id> listaVueltaDeSubsanacion  = new List<Id>(); 
        List<Id> listaIDsReclamacionGlobal = new List<Id>();
        Set<Id> idesReclaGlobal = new Set<Id>();  //Para la Query
        Set<Id> reclIds = new Set<Id> ();
        Set<Id> reclIdsSentidoResolucion = new Set<Id> ();
        Set<Id> setIdesRec = new Set<Id>();
        Set<Id> setIdesRecCheck = new Set<Id>();
        Set<Id> setIdRecPadre = new Set<Id>();
        Set<Id> setIdRecCambioAnalisis = new Set<Id>();
        Set<Id> setIdPreCambioNegociacion = new Set<Id>();
        Set<Id> setReclaSubsanacion = new Set<Id>();
        Set<Id> setChangeGrupoLetrado = new Set<Id>();
        List<Id> listaIdsCambioOwnerReclamacion = new List<Id>();
        List<Id> listaIdsCambiaIdioma = new List<Id>();
        List<Case> listaCasosCambiaIdioma = new List<Case>();
        Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();
        Map<Id, Case> mapaReclamacionesNotificar = new Map<Id, Case>();
        Map<Id, Case> mapaReclamacionesCerradas = new Map<Id, Case>();
        //Map<Id, Case> mapaReclamacionOwnerCambiado = new Map<Id, Case>();  US458927 Se elimina la alerta notificarCambioOwner
        Map<Id, Case> mapaReclamacionEjecucion = new Map<Id, Case>();
        Map<Id, String> mapaCanalProcedencia = new Map<Id, String>();
        Map<Id, String> mapaMCC = new Map<Id, String>();
        //lista de Ids de caso donde hay que revisar la fecha de asignación de su TMO
        list<Id> listaIdCasoFechaAsignTMO = new list<Id>();
        //Lista de pretensiones con el TAE actualizado
        List<Case> listaPretensionesCambiaTAE = new List<Case>();
        //lista de Ids de caso donde hay que cambiarle el owner a sus pretensiones hijas en el alta
        list<Id> listaIdCasoChangeOwnerPreten = new list<Id>();
        Set<Id> setIdReclaOwner = new Set<Id>();
        //Recuperar colas
        List<Group> listaColas = new List<Group>();
        Group cola = new Group();
        Group colaSupervisores = new Group();
        Group colaIA = new Group();
        listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
        if(!listaColas.isEmpty()){
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                    cola = grupoAux;
                }else if(grupoAux.DeveloperName == 'SAC_PteSupervisor'){
                    colaSupervisores = grupoAux;
                }else if(grupoAux.DeveloperName == 'SAC_GenialPdteIA'){
                    colaIA = grupoAux;
                }
            }
        }

        for (case caso : listNewObj) { 
            //Pretensiones 
            if (caso.RecordTypeId == RECTYPEPRETENSION) {
           
                if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.AccountId != null 
                    && mapOldObj.get(caso.Id).OwnerId != colaSupervisores.Id
                    && caso.OwnerId != cola.Id && caso.OwnerId != colaSupervisores.Id ) {
                    listaIdsCuentas.add(caso.AccountId);
                    listNewCaseAsignarCasosAlOwner.add(caso); 
                }
                if (mapOldObj != null && caso.Status != mapOldObj.get(caso.Id).Status) {
                    reclIds.add(caso.SAC_Reclamacion__c);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                    
                    if(caso.Status == 'SAC_009' || mapOldObj.get(caso.Id).Status == 'SAC_009'){//Si se da baja o se deshace la baja recalcular el número de pretensiones activas en la reclamación
                        reclIdsSentidoResolucion.add(caso.SAC_Reclamacion__c);
                        listaRecalcularPreActivas.add(caso);
                        if(mapOldObj.get(caso.Id).Status == 'SAC_009') {
                            listaPretMCC.add(caso);
                        }
                        else {
                            listaBorrarMCC.add(caso);                         
                        }
                        if(caso.SAC_Reclamacion__c != null){
                            listaPretensionesMccCambiado.add(caso);
                            listaIDsReclamacionGlobal.add(caso.SAC_Reclamacion__c);
                        }
                    }
                }
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_Reclamacion__c != mapOldObj.get(caso.Id).SAC_Reclamacion__c){   
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);       
                    listaRecalcularPreActivas.add(caso);  
                }
                if (mapOldObj != null && caso.SAC_SentidoResolucion__c != mapOldObj.get(caso.Id).SAC_SentidoResolucion__c) {
                    reclIdsSentidoResolucion.add(caso.SAC_Reclamacion__c);
                    listaPretCambioArgumentario.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                if (mapOldObj != null && caso.SAC_MotivoSentidoResolucion__c != mapOldObj.get(caso.Id).SAC_MotivoSentidoResolucion__c) {
                    listaPretCambioArgumentario.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                //Actualizar campo Resumen Manual si se modifica el Resumen Manual de sus pretensiones
                if (mapOldObj != null && caso.SAC_ResumenManual__c != mapOldObj.get(caso.Id).SAC_ResumenManual__c) {
                    listaPretCambioResumenManual.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                if ((mapOldObj != null && caso.CC_Importe_Reclamado__c != mapOldObj.get(caso.Id).CC_Importe_Reclamado__c) || 
                    (mapOldObj != null && caso.SAC_Quebranto__c != mapOldObj.get(caso.Id).SAC_Quebranto__c) ||
                    (mapOldObj != null && caso.SAC_Importe_Resuelto__c != mapOldObj.get(caso.Id).SAC_Importe_Resuelto__c) ||
                    (mapOldObj != null && caso.CC_Importe_Abonado__c != mapOldObj.get(caso.Id).CC_Importe_Abonado__c)){
                    setIdesRec.add(caso.SAC_Reclamacion__c);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                if(mapOldObj.containsKey(caso.Id) && (caso.SEG_Detalle__c != mapOldObj.get(caso.Id).SEG_Detalle__c
                  || caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c
                  || caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c
                  || caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c ) ){
                    
                    listaPretMCC.add(caso);

                    if(caso.SAC_Reclamacion__c != null && caso.Status != 'SAC_009'){
                        listaPretensionesMccCambiado.add(caso);
                        listaIDsReclamacionGlobal.add(caso.SAC_Reclamacion__c);
                    }
                    
                }
                if(mapOldObj.containsKey(caso.Id) && caso.CC_Canal_Procedencia__c != mapOldObj.get(caso.Id).CC_Canal_Procedencia__c){           
                    listaReclaPadreCanalProcedencia.add(caso);                    
                } 
                if(caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('005')){
                    listaOwnersCambiados.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                if(mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_009'){
                    listaPretensionControlarMilestone.add(caso);
                }
                 if (mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).SAC_Entidad_Afectada__c != caso.SAC_Entidad_Afectada__c || mapOldObj.get(caso.Id).SAC_EntidadProductora__c != caso.SAC_EntidadProductora__c)) {
                    listaCambioEntidadPrincipal.add(caso);
                    listaPretMCC.add(caso); //Lista para traer sus reclamaciones padres con el select
                }

                //Se almacenan en la siguiente lista las pretensiones cuyo TAE haya cambiado y sean pertensiones principales
                
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TAE__c != caso.SAC_TAE__c && caso.SAC_EsPrincipal__c == true){
                    listaPretensionesCambiaTAE.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__C);   //Almaceno los ids de las reclamaciones que son padre de las pretensiones principales
                    
                }

                // if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_EntidadProductora__c != caso.SAC_EntidadProductora__c) {
                //     //listaCambioEntidadProductora.add(caso);
                //     listaPretMCC.add(caso); //Lista para traer sus reclamaciones padres con el select
                // }
                if (mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) {
                    listaPretOwnerCola.add(caso);
                    setIdRecPadre.add(caso.SAC_Reclamacion__c);
                    recalcularSharesReclamaciones = true;
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SAC_007') { //negociación
                    if (mapOldObj.get(caso.Id).Status == 'SAC_003') { // Negociacion despues de resolución
                        setIdPreCambioNegociacion.add(caso.SAC_Reclamacion__c);
                    }
                    setIdRecPadre.add(caso.SAC_Reclamacion__c);
                    listaRecPretNegociacion.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SAC_006') { //subsanación 
                    listaRecPretSubsanacion.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                    setReclaSubsanacion.add(caso.SAC_Reclamacion__c);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && 
                    mapOldObj.get(caso.Id).Status == 'SAC_006' &&  /*Vuelta de la subsanación*/
                    (caso.Status == 'SAC_001' || caso.Status == 'SAC_002' || caso.Status == 'SAC_003'|| caso.Status == 'SAC_004'|| caso.Status == 'SAC_007')) { 
                    listaVueltaDeSubsanacion.add(caso.SAC_Reclamacion__c);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                if(mapOldObj.get(caso.Id).OS_Fecha_Resolucion__c != caso.OS_Fecha_Resolucion__c){
                    listaRecPreFechaResolucion.add(caso);
                }
                //Si cambia el grupo de la pretensión, hay que buscar su reclamacion padre y cambiarlo del campo SAC_GrupoLetrado__c
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Grupo__c != caso.SEG_Grupo__c) {
                    listaPretensionGrupoCambiado.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                //Si el caso ha cambiado de resultado de negociación
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ResultadoNegociacion__c != caso.SAC_ResultadoNegociacion__c) {
                    listaCambioResultadoNegociacion.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }
                //Validar pretensiones de una reclamcion
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_ValidacionMCC__c != mapOldObj.get(caso.Id).SAC_ValidacionMCC__c){
                    listaValidacionPretension.add(caso);
                    idesReclaGlobal.add(caso.SAC_Reclamacion__c);
                }

                // Si el caso está cerrado y ha sido modificado
                if (mapOldObj.containsKey(caso.Id) && caso.Status == mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado') {
                    listaModRecCerradas.add(caso);
                }

                listaPretensiones.add(caso);
                listaCasos.add(caso);
            //Reclamaciones
            }else if(caso.RecordTypeId == RECTYPERECLAMACION){
                
                if (mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SAC_008') { //Derivación
                    idesReclaGlobal.add(caso.Id);
                    mapaReclamacionesNotificar.put(caso.Id, caso);
                    listaReclaDerivacion.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'SAC_008' || caso.Status == 'Cerrado')) {
                    idesReclaGlobal.add(caso.Id);
                    mapaReclamacionesCerradas.put(caso.id, caso);
                    if(caso.Status == 'Cerrado') {
                        listaReclamacionesConsultasAFinalizar.add(caso);
                    }
                }

                //Si el caso es de naturaleza: Complementaria y se le vincula otro caso, se debe arrastrar su importe abonado a la reclamación a la que se ha vinculado
                //Entra en este al pulsar vincular sin ninguna anteriormente vinculada
               if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).CC_CasoRelacionado__c != caso.CC_CasoRelacionado__c && caso.SAC_Naturaleza__c=='SAC_007' && mapOldObj.get(caso.Id).CC_CasoRelacionado__c == null && caso.CC_CasoRelacionado__c != null){
                    listaReclaAddVinculacion.add(caso);
                    idsAddVinculacion.add(caso.Id);
                }

                //Si el caso es de naturaleza: Complementaria y se le desvincula un caso, hay que eliminar su importe abonado de la reclamación que estaba vinculada
                //Entra en este tanto al pulsar desVincular como al cambiar la reclamación vinculada por otra
                if((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).CC_CasoRelacionado__c != null && caso.SAC_Naturaleza__c=='SAC_007' && mapOldObj.get(caso.Id).CC_CasoRelacionado__c != caso.CC_CasoRelacionado__c)){
                    listaReclaCambiaVinculacion.add(caso);
                    idsCambiaVinculacion.add(caso.Id);
                }

                if(mapOldObj.containsKey(caso.Id) && caso.SAC_Naturaleza__c=='SAC_007' && mapOldObj.get(caso.Id).CC_Importe_Abonado__c != caso.CC_Importe_Abonado__c){
                    idsComplementariasCambiaImporteAbonado.add(caso.Id);
                    listaComplementariasCambiaImporteAbonado.add(caso);
                }

                //Si la naturaleza cambia de compolementaria a otra, o de otra a complementaria, hay que actualizar los importes abonados de su caso relacionado si tiene
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_Naturaleza__c != caso.SAC_Naturaleza__c && (mapOldObj.get(caso.Id).SAC_Naturaleza__c == 'SAC_007' || caso.SAC_Naturaleza__c == 'SAC_007')){
                    idsCambiaNaturalezaComplementaria.add(caso.Id);
                    listaCambiaNaturalezaComplementaria.add(caso);
                }

                if(mapOldObj.containsKey(caso.Id) && caso.CC_Idioma__c != mapOldObj.get(caso.Id).CC_Idioma__c){
                    listaIdsCambiaIdioma.add(caso.Id);
                    listaCasosCambiaIdioma.add(caso);
                }

                //Si se cambia el tipo de representante hay que comprobar si se elimina el despacho representante del Case Extension relacionado
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_TipoDeRepresentante__c != mapOldObj.get(caso.Id).SAC_TipoDeRepresentante__c){
                    idsComprobarDespachoRepresentante.add(caso.Id);
                    listaComprobarDespachoRepresentante.add(caso);
                }

                if(mapOldObj.containsKey(caso.Id) && caso.CC_Canal_Procedencia__c != mapOldObj.get(caso.Id).CC_Canal_Procedencia__c){           
                    listaReclaPadreCanalProcedencia.add(caso);  
                    idesReclaGlobal.add(caso.Id);                  
                } 
                if (mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId
                   && mapOldObj.get(caso.Id).OwnerId != colaSupervisores.Id
                   && caso.AccountId != null && caso.OwnerId != cola.Id && caso.OwnerId != colaSupervisores.Id 
                   && String.isBlank(caso.SAC_CasoRelacionado__c) ){
                        listaIdsCuentas.add(caso.AccountId);
                        listNewCaseAsignarCasosAlOwner.add(caso);
                        recalcularSharesPretensiones = true;
                }
                if (mapOldObj.containsKey(caso.Id) && (caso.Status != mapOldObj.get(caso.Id).Status && (mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002') 
                    || (caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'SAC_005' || caso.Status == 'SAC_006' || caso.status == 'SAC_002' || caso.Status == 'SAC_001' || mapOldObj.get(caso.Id).Status == 'SAC_006')))) {
                        listaReclaCambiarEstado.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && (caso.SAC_FechaRecepcion__c != mapOldObj.get(caso.Id).SAC_FechaRecepcion__c)) {
                    listaReclamacionFechaRecepcion.add(caso); 
                    idesReclaGlobal.add(caso.Id);                   
                }
                if (mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId) { //Si cambia el Owner de la reclamación
                    //mapaReclamacionOwnerCambiado.put(caso.Id, caso); US458927 Se elimina la alerta notificarCambioOwner
                    idesReclaGlobal.add(caso.Id);
                    if(String.valueOf(caso.OwnerId).startsWith('005')){
                        listaOwnersCambiados.add(caso);
                        listaIdsCambioOwnerReclamacion.add(caso.Id);
                        
                    }
                    //ver si el cambio pertenece a alguien que no sea una de las colas de SAC cuando el estado es de alta US866223
                    if(caso.Status == 'SAC_001' && caso.OwnerId != cola.id && caso.OwnerId != colaSupervisores.id && caso.OwnerId != colaIA.id){
                        listaIdCasoFechaAsignTMO.add(caso.Id);
                        if(String.valueOf(caso.OwnerId).startsWith('005') && String.isNotBlank(caso.SAC_GenialEstado__c)){
                            listaIdCasoChangeOwnerPreten.add(caso.Id);
                            setIdReclaOwner.add(caso.OwnerId);
                        }
                    }
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_003' && caso.Status == 'SAC_004') {
                    mapaReclamacionEjecucion.put(caso.Id, caso);
                    idesReclaGlobal.add(caso.Id);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SAC_001') {
                    listaReclamacionVuelveAlta.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002'){
                    listaBalanceoLetrado.add(caso);
                    setIdRecCambioAnalisis.add(caso.Id);
                }
                if ((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002' && String.isNotBlank(caso.SAC_CasoEspecial__c)) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CasoEspecial__c != caso.SAC_CasoEspecial__c && caso.SAC_CasoEspecial__c == 'SAC_Sensible' && caso.Status != 'SAC_004' && caso.Status != 'SAC_001')) {
                    listaReclamacionEspecial.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CasoEspecial__c != caso.SAC_CasoEspecial__c) {
                    listaCambiarCasoEspecial.add(caso);
                    idesReclaGlobal.add(caso.Id);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SAC_007') { //negociación 
                    listaRecPretNegociacion.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SAC_006') { //subsanación 
                    idesReclaGlobal.add(caso.Id);
                    listaRecPretSubsanacion.add(caso);
                    listaReclamacionSubsanacion.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Rechazado') {  
                    listaReclaRechazadas.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && 
                    mapOldObj.get(caso.Id).Status == 'SAC_006' &&  /*Vuelta de la subsanación*/
                    (caso.Status == 'SAC_001' || caso.Status == 'SAC_002' || caso.Status == 'SAC_003'|| caso.Status == 'SAC_004'|| caso.Status == 'SAC_007')) {
                    listaVueltaDeSubsanacion.add(caso.Id); 
                }
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).OS_Fecha_Resolucion__c != caso.OS_Fecha_Resolucion__c){
                    idesReclaGlobal.add(caso.Id);
                    listaRecPreFechaResolucion.add(caso);
                } 
                if(mapOldObj.containsKey(caso.Id) && ((mapOldObj.get(caso.Id).Status == 'SAC_008') && /*Vuelta de  Negociacion*/
                   (caso.Status == 'SAC_001' || caso.Status == 'SAC_002' || caso.Status == 'SAC_003'|| caso.Status == 'SAC_004'|| caso.Status == 'SAC_007'))){    
                   listaVueltaDeDerivacion.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && ((mapOldObj.get(caso.Id).Status == 'Rechazado'  || mapOldObj.get(caso.Id).Status == 'Cerrado' || mapOldObj.get(caso.Id).Status == 'SAC_014') && /*Reabrir reclamacion*/
                   (caso.Status == 'SAC_001' || caso.Status == 'SAC_002' || caso.Status == 'SAC_003'|| caso.Status == 'SAC_004'|| caso.Status == 'SAC_007'))){    
                   listaReabrirReclamacion.add(caso);
                }    
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SAC_014'){
                    listaRecPreFechaResolucion.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && ((mapOldObj != null && caso.OS_Email__c != mapOldObj.get(caso.Id).OS_Email__c) || 
                (mapOldObj != null && caso.CC_Telefono_Contacto__c != mapOldObj.get(caso.Id).CC_Telefono_Contacto__c) ||
                (mapOldObj != null && caso.SAC_DireccionPostalNotificacion__c != mapOldObj.get(caso.Id).SAC_DireccionPostalNotificacion__c))){
                listaActualizarDatosContacto.add(caso);
                idesReclaGlobal.add(caso.Id);  
                }

                if (mapOldObj.containsKey(caso.Id) && caso.Status == mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado') {
                    listaModRecCerradas.add(caso);
                }

                listaReclamaciones.add(caso);
                listaCasos.add(caso);
            }else if(caso.RecordTypeId == RECTYPECONSULTA){
               
                listaConsultas.add(caso);
                listaCasos.add(caso);
                if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.AccountId != null && caso.OwnerId != cola.Id) {
                    listaIdsCuentas.add(caso.AccountId);
                    listaNewConsultaAsignarCasosAlOwner.add(caso); 
                }
                if(caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('005')){
                    listaOwnersCambiados.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_CasoRelacionado__c != Null){
                    setIdesRecCheck.add(caso.CC_CasoRelacionado__c);
                    idesReclaGlobal.add(caso.CC_CasoRelacionado__c);
                }
                if(mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).CC_CasoRelacionado__c) != null && caso.CC_CasoRelacionado__c == Null){
                    setIdesRecCheck.add(mapOldObj.get(caso.Id).CC_CasoRelacionado__c);
                    idesReclaGlobal.add(mapOldObj.get(caso.Id).CC_CasoRelacionado__c);
                }
            }else if(caso.RecordTypeId == RECTYPECONSULTASAC){
           
                listaCasos.add(caso);
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_CasoRelacionado__c != Null){
                    setIdesRecCheck.add(caso.CC_CasoRelacionado__c);
                    idesReclaGlobal.add(caso.CC_CasoRelacionado__c);
                }
                if(mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).CC_CasoRelacionado__c) != null && caso.CC_CasoRelacionado__c == Null){
                    setIdesRecCheck.add(mapOldObj.get(caso.Id).CC_CasoRelacionado__c);
                    idesReclaGlobal.add(mapOldObj.get(caso.Id).CC_CasoRelacionado__c);
                }

                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_Naturaleza__c != caso.SAC_Naturaleza__c && caso.SAC_Naturaleza__c == 'SAC_005'){
                    listaRecCambioNaturaleza.add(caso);
                   
                }

                //Si cambia el grupo letrado de la consulta SAC, el owner letrado tiene que pasar a 'Pte. Asignar'
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_GrupoLetrado__c != caso.SAC_GrupoLetrado__c && mapOldObj.get(caso.Id).SAC_Letrado__c != 'Pte. Asignar') {
                    setChangeGrupoLetrado.add(caso.Id);
                }
            }
        }

        List<Case> listaCasosSelect = [SELECT Id, Subject, SEG_Detalle__c, SAC_Naturaleza__c, SAC_Reclamacion__r.OwnerId, SAC_Reclamacion__r.SEG_Detalle__c, SAC_Reclamacion__r.SEG_Detalle__r.SAC_EndToEnd__c,
                                  OwnerId, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Detalle__c, SAC_TiempoSLALetradoAlta__c, 
                                      SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_Reclamacion__r.SEG_Grupo__r.SAC_EndToEnd__c,
                                      SAC_SentidoResolucion__c, Status, SAC_StatusAuxiliar__c, SAC_Reclamacion__r.SAC_SentidoResolucion__c, CC_Importe_Reclamado__c, CaseNumber, OS_Email__c,CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c,
                                      SAC_Reclamacion__c, RecordTypeId, CC_Canal_Procedencia__c, AccountId, IsClosed, SAC_Reclamacion__r.Status, SAC_Reclamacion__r.SAC_StatusAuxiliar__c, SAC_TiempoSLARegulatorio__c, 
                                      SAC_PretensionPrincipal__c, SAC_Reclamacion__r.SAC_MotivoInadmision__c, CC_CasoRelacionado__c, SAC_Reclamacion__R.SAC_PretensionPrincipal__c,
                                      SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Detalle__r.SAC_EndToEnd__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.CC_MCC_Motivo__c, SEG_Grupo__c,
                                      SAC_Quebranto__c, SAC_TAE__c, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c, SAC_Entidad_Afectada__c, recordType.Name, SAC_EntidadProductora__c, OS_Fecha_Resolucion__c, SAC_Reclamacion__r.CC_CasoRelacionado__c,
                                      SAC_Reclamacion__r.CC_CasoRelacionado__r.SEG_Grupo__c, SAC_Reclamacion__r.CC_CasoRelacionado__r.SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_Reclamacion__r.CC_CasoRelacionado__r.isClosed,
                                      SAC_Reclamacion__r.CC_CasoRelacionado__r.Status, SAC_Reclamacion__r.CC_CasoRelacionado__r.RecordTypeId, SAC_MotivoInadmision__c, Origin, SEG_Detalle__r.SAC_GenerarTaskMisClientes__c, SAC_FechaUltimaAsignacionLetrado__c,
                                      CC_Oficina_Afectada_Lookup__r.CC_Numero_Oficina__c, CC_Oficina_Afectada_Lookup__r.AV_MatriculaResponsable1__r.CC_Matricula__c, CC_MCC_ProdServ__r.Name, SEG_Detalle__r.Name, SAC_MotivoSentidoResolucion__c, SAC_ResumenManual__C,
                                      SAC_RedaccionFinal__c, SAC_FamiliaMotivoBdE__c, SAC_ResultadoNegociacion__c, SEG_Detalle__r.SAC_ImporteDesdeMCC__c, SEG_Detalle__r.SAC_ImporteHastaMCC__c, SEG_Detalle__r.SAC_GrupoLetradoMCC__c,
                                      CC_MCC_Motivo__r.SAC_ImporteDesdeMCC__c, CC_Idioma__c, CC_MCC_Motivo__r.SAC_ImporteHastaMCC__c, CC_MCC_Motivo__r.SAC_GrupoLetradoMCC__c, CC_MCC_ProdServ__r.SAC_ImporteDesdeMCC__c, CC_MCC_ProdServ__r.SAC_ImporteHastaMCC__c,
                                      CC_MCC_ProdServ__r.SAC_GrupoLetradoMCC__c, CC_MCC_Tematica__r.SAC_ImporteDesdeMCC__c, CC_MCC_Tematica__r.SAC_ImporteHastaMCC__c, CC_MCC_Tematica__r.SAC_GrupoLetradoMCC__c, SAC_ValidacionMCC__c,SAC_CheckResumen__c,
                                      SAC_TipoSubsanacion__c, SAC_EsPrincipal__c, SAC_M2P__c, SAC_Reclamacion__r.SAC_M2P__c, CBK_Case_Extension_Id__r.SAC_PretensionCreadaCerrada__c, CBK_Case_Extension_Id__c
                                  FROM Case
                                      WHERE (RecordTypeId  = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION OR RecordTypeId = :RECTYPECONSULTA OR RecordTypeId = :RECTYPECONSULTASAC)
                                       AND (
                                         (RecordTypeId = :RECTYPEPRETENSION AND (SAC_Reclamacion__c IN: idesReclaGlobal OR SAC_Reclamacion__c IN: listaBalanceoLetrado)) 
                                      OR ((RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPECONSULTA ) AND AccountId IN :listaIdsCuentas AND isClosed = false) 
                                      OR (RecordTypeId = :RECTYPERECLAMACION AND SAC_PretensionPrincipal__c IN: listaPretMCC)
                                      OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN: listaReclaCambiarEstado AND Status != 'SAC_009')  
                                      OR ((RecordTypeId = :RECTYPECONSULTA OR RecordTypeId = :RECTYPECONSULTASAC) AND CC_CasoRelacionado__c IN: idesReclaGlobal 
                                            AND (Status != 'SAC_008' OR Status != 'SAC_012' OR Status != 'SAC_013')) 
                                      OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN: listaReclamacionEspecial)
                                      OR (RecordTypeId = :RECTYPERECLAMACION AND (Id IN: setIdRecPadre OR Id IN: idesReclaGlobal OR Id IN: setIdesRec))
                                      OR (RecordTypeId = :RECTYPERECLAMACION AND  Id IN: listaIdsCambiaIdioma)
                                      OR (RecordTypeId = :RECTYPERECLAMACION AND  Id IN: idsComprobarDespachoRepresentante)
                                      OR (RecordTypeId = :RECTYPERECLAMACION AND  (Id IN: idsCambiaVinculacion OR Id IN: idsAddVinculacion OR Id IN: idsComplementariasCambiaImporteAbonado))
                                      )];

        if (procesado && !segundoProcesado) {
            //Añadido metodo para calcular los importes de las pretensiones y añadirlos a la reclamación cuando la ultima acción del caso cierra el estado de la reclamación
            if (!setIdesRec.isEmpty()) {SAC_CaseCalcularImporte.calcular(listaCasosSelect, setIdesRec, mapaDatosCasosActualizar);}
            segundoProcesado = true;
        }
        if(!procesado){            
            if(!listaPretensiones.isEmpty()){
                
                if (!reclIds.isEmpty()) {
                    SAC_CaseActualizarEstado.actualizarEstadoReclamacion(listaCasosSelect, reclIds, mapaDatosCasosActualizar);}    
              
                if (!reclIdsSentidoResolucion.isEmpty()) {
                    SAC_CaseActualizarResolucion.actualizarResolucionReclamacion(listaCasosSelect, reclIdsSentidoResolucion, mapaDatosCasosActualizar);
                    //Con las pretensiones llamamos a la clase SAC_CaseCalcularImporte le pasamos las pretensiones y que calcule el importe de Reclamación Padre cuando damos de baja o deshacemos la baja
                    SAC_CaseCalcularImporte.calcular(listaCasosSelect, reclIdsSentidoResolucion, mapaDatosCasosActualizar);
                } 
                
                if (!listaPretCambioArgumentario.isEmpty()) {SAC_Reclamacion.actualizarArgumentarioResolucion(listaCasosSelect, listaPretCambioArgumentario, mapaDatosCasosActualizar);} 

                if (!listaPretCambioResumenManual.isEmpty()) {
                    SAC_Reclamacion.actualizarResumenManual(listaCasosSelect, listaPretCambioResumenManual, mapaDatosCasosActualizar);
                    SAC_Reclamacion.validarResumenManual(listaCasosSelect, listaPretCambioResumenManual, mapaDatosCasosActualizar);
                } 

                //Con las pretensiones llamamos a la clase SAC_CaseCalcularImporte le pasamos las pretensiones y que calcule el importe de Reclamación Padre
                if (!setIdesRec.isEmpty()) {SAC_CaseCalcularImporte.calcular(listaCasosSelect, setIdesRec, mapaDatosCasosActualizar);}   
                
                //SAC_NotificacionProrrogaAutomatica.notificacionProrrogaAutomatica(listaPretensiones, mapOldObj);
                compruebaPretensiones = true;
                if (!listaPretensionControlarMilestone.isEmpty()) {
                  
                    SAC_ComportamientoSLAs.cerrarMilestoneLetradoAltaBaja(listaPretensionControlarMilestone);
                }
                if (!listaCambioEntidadPrincipal.isEmpty()) {SAC_Reclamacion.entidadAfectadaPrincipal(listaCasosSelect, listaCambioEntidadPrincipal, mapaDatosCasosActualizar);}

                //if (!listaCambioEntidadProductora.isEmpty()) {SAC_Reclamacion.entidadProductoraPrincipal(listaCasosSelect, listaCambioEntidadProductora, mapaDatosCasosActualizar);}
 
                if(!listaRecalcularPreActivas.isEmpty() && !System.isQueueable()){
                    SAC_Pretension.calcularPretensionesActivas(listaRecalcularPreActivas, listaCasosSelect, mapaDatosCasosActualizar);
                    // si se da de baja o se deshace la baja el resumen de la reclamación se tiene que actualizar con lo que ocurra en esta pretension
                    SAC_Reclamacion.actualizarResumenManual(listaCasosSelect, listaRecalcularPreActivas, mapaDatosCasosActualizar); 
                    SAC_Reclamacion.validarResumenManual(listaCasosSelect, listaRecalcularPreActivas, mapaDatosCasosActualizar); 
                }

                if (!listaPretOwnerCola.isEmpty()) {SAC_Pretension.cambioLetrado(listaPretOwnerCola, mapaDatosCasosActualizar, cola);}
  
                if(!setIdPreCambioNegociacion.isEmpty()){ 
                    SAC_CasosEnNegociacion.informarFechaResolucion(setIdPreCambioNegociacion, listaCasosSelect, mapaDatosCasosActualizar);
                    //Si se informa la fecha de resolución se debe cerrar el TMO Global
                    List<Case> listaReclamaNegociacion = SAC_TMOGlobal.filtrarListaSelect(setIdRecPadre, listaCasosSelect);
                    SAC_TMOGlobal.modificarFechaFinal(listaReclamaNegociacion, true);
                }                
                if (!setReclaSubsanacion.isEmpty()) {
                    List<Case> listaReclamaSubsanacion = SAC_TMOGlobal.filtrarListaSelect(setReclaSubsanacion, listaCasosSelect);
                    SAC_TMOGlobal.modificarFechaFinal(listaReclamaSubsanacion, true);
                }

                if(!listaPretensionesCambiaTAE.isEmpty()){
                    SAC_Pretension.actualizarTAE(listaPretensionesCambiaTAE, mapaDatosCasosActualizar, listaCasosSelect);

                }
                //if (!listaBorrarMCC.isEmpty()) {
                    //SAC_Reclamacion.cambioMCCSiBajaPretension(listaCasosSelect, listaBorrarMCC, mapaDatosCasosActualizar);
                    //System.enqueueJob(new SAC_VaciarMCCReclamacion(listaCasosSelect, listaBorrarMCC));
                //}

                if(!listaVueltaDeSubsanacion.isEmpty()){
                    SAC_TMOGlobal.insertarTPEVueltaSubsanacion(listaVueltaDeSubsanacion, listaCasosSelect);
                    SAC_TMOGlobal.modificarFechaFinal(listNewObj, true);
                }
                //Rellena el campo SAC_GrupoLetrado__c de la reclamación padre cuando cambia en la pret
                if (!listaPretensionGrupoCambiado.isEmpty()) {
                    SAC_Reclamacion.informarGrupoLetrado(listaPretensionGrupoCambiado, listaCasosSelect, mapaDatosCasosActualizar);
                }

                if(!listaPretensionesMccCambiado.isEmpty()){
                    SAC_HandlerMethods.comprobarE2ERec(listaPretensionesMccCambiado, listaIDsReclamacionGlobal, false, RECTYPERECLAMACION, RECTYPEPRETENSION);
                }

                if(!listaCambioResultadoNegociacion.isEmpty()){
                    SAC_Reclamacion.comprobarResultadoNegociacion(listaCambioResultadoNegociacion, listaCasosSelect, mapaDatosCasosActualizar); 
                }
                if(!listaValidacionPretension.isEmpty()){
                    SAC_Reclamacion.validarReclamacion(listaValidacionPretension, listaCasosSelect, mapaDatosCasosActualizar);
                }
            }

            //Con las Reclamaciones debemos comprobar que si no tiene adjuntos no se pueda ticar el campo ficheros adjuntos
            if(!listaReclamaciones.isEmpty()){
                SAC_CaseComprobarAdjuntos.comprobar(listaReclamaciones);
                if (!listaBalanceoLetrado.isEmpty()) {
                    SAC_BalanceoLetrado.determinarOwner(listaCasosSelect, listaBalanceoLetrado, mapaDatosCasosActualizar, cola);
                }
                if (!listNewCaseAsignarCasosAlOwner.isEmpty()) { SAC_Balanceo.asignarCasosAlOwner (listaCasosSelect, listNewCaseAsignarCasosAlOwner,listaIdsCuentas, mapaDatosCasosActualizar);}
                
                if (!listaReclaCambiarEstado.isEmpty() && !System.isFuture()) { SAC_UpdateEstadosPretensiones.actualizarEStados(listaCasosSelect, listaReclaCambiarEstado, mapaDatosCasosActualizar);}
                
                if (!listaReclamacionFechaRecepcion.isEmpty()) { 
                    SAC_ComportamientoSLAs.actualizarFechaRecepcionPretensiones(listaCasosSelect, listaReclamacionFechaRecepcion, mapaDatosCasosActualizar);
                    SAC_TMOGlobal.modificarFechaInicial(listaReclamacionFechaRecepcion);
                }

                if (!mapaReclamacionesNotificar.isEmpty()) { SAC_Notificacion.derivacion(mapaReclamacionesNotificar, listaCasosSelect, mapaDatosCasosActualizar); }

                if(!listaIdsCambiaIdioma.isEmpty()){
                    SAC_Reclamacion.actualizarPlantillaLateral(listaCasosSelect, listaCasosCambiaIdioma);
                }

                if(!listaComprobarDespachoRepresentante.isEmpty()){
                    SAC_Reclamacion.comprobarDespachoRepresentante(listaCasosSelect, listaComprobarDespachoRepresentante, mapOldObj);
                }

               if(!listaReclaAddVinculacion.isEmpty()){
                    SAC_Reclamacion.arrastrarImporteReclamacionVinculada(listaCasosSelect, listaReclaAddVinculacion, mapaDatosCasosActualizar);
                }
                if(!listaReclaCambiaVinculacion.isEmpty()){
                    SAC_Reclamacion.actualizarImporteCambioVinculacion(listaCasosSelect, mapOldObj, listaReclaCambiaVinculacion, mapaDatosCasosActualizar);
                }

                if(!listaComplementariasCambiaImporteAbonado.isEmpty()){
                    SAC_Reclamacion.calcularNuevoImporteAbonado(listaCasosSelect, mapOldObj, listaComplementariasCambiaImporteAbonado, mapaDatosCasosActualizar);
                }

                if(!listaCambiaNaturalezaComplementaria.isEmpty()){
                    SAC_Reclamacion.calcularNuevoImporteCambioNaturaleza(listaCambiaNaturalezaComplementaria, mapOldObj, mapaDatosCasosActualizar);
                }


                //US458927 Se elimina la alerta notificarCambioOwner
                //if (!mapaReclamacionOwnerCambiado.isEmpty()) { SAC_Notificacion.notificarCambioOwner(mapaReclamacionOwnerCambiado, listaCasosSelect, mapaDatosCasosActualizar); }

                if (!mapaReclamacionEjecucion.isEmpty()) { SAC_Notificacion.notificarEjecucion(mapaReclamacionEjecucion, listaCasosSelect); }

                if (!listaReclamacionVuelveAlta.isEmpty()) { SAC_Notificacion.notificarVolverAlta(listaReclamacionVuelveAlta); }

                if(!mapaReclamacionesCerradas.isEmpty() && !listaCasosSelect.isEmpty()){ SAC_Reclamacion.devolverConsultasCOPS(mapaReclamacionesCerradas, listaCasosSelect, cola, mapaDatosCasosActualizar);}

                if(!listaReclaPadreCanalProcedencia.isEmpty()){                    
                    Map<Id,Case> mapaQuery = new Map<Id,Case>(listaCasosSelect);
                    for(Id ide : mapNewObj.keySet()){ 
                        if(mapaQuery.containsKey(ide)){
                            mapaQuery.remove(ide);
                        }
                    }
                    mapaDatosCasosActualizar = SAC_Pretension.rellenarProcedencia(mapaQuery.values(), listaReclaPadreCanalProcedencia, mapaDatosCasosActualizar);
                }      

                if (!listaReclamacionEspecial.isEmpty()) {
                    SAC_BalanceoLetrado.balanceoLetradoEspecial(listaReclamacionEspecial, listaCasosSelect, mapaDatosCasosActualizar, cola);
                }
                if (!listaReclamacionesConsultasAFinalizar.isEmpty()) {
                    SAC_Interaccion.finalizarConsultasPendienteRespuesta(listaReclamacionesConsultasAFinalizar);
                }

                if (!listaIdsCambioOwnerReclamacion.isEmpty()) {
                    SAC_FutureMethods.permisosLetrado(listaIdsCambioOwnerReclamacion);
                }

                if(!listaIdCasoFechaAsignTMO.isEmpty()) {
                    //future para casos asign TMO
                    SAC_FutureMethods.fechaAsignacionTMO(datetime.now(), listaIdCasoFechaAsignTMO);
                }

                if (!setIdRecCambioAnalisis.isEmpty()) {
                    SAC_FutureMethods.permisosGestor(setIdRecCambioAnalisis);
                }
                if (!listaCambiarCasoEspecial.isEmpty()) {SAC_Pretension.casoEspecialPretensiones(listaCambiarCasoEspecial, listaCasosSelect, mapaDatosCasosActualizar);}
                if(!listaRecPreFechaResolucion.isEmpty()){SAC_TMOGlobal.modificarFechaFinal(listaRecPreFechaResolucion, false);}
                if(!listaReclaDerivacion.isEmpty()){SAC_TMOGlobal.modificarFechaFinal(listaReclaDerivacion, false);}
                if(!listaReclaRechazadas.isEmpty()){SAC_TMOGlobal.modificarFechaFinal(listaReclaRechazadas, false);} 
                if (!listaReclamacionSubsanacion.isEmpty()) {SAC_TMOGlobal.modificarFechaFinal(listaReclamacionSubsanacion, false);}                
                if(!listaVueltaDeDerivacion.isEmpty()){ 
                    SAC_TMOGlobal.crearNuevoTPE(listaVueltaDeSubsanacion);
                    SAC_TMOGlobal.modificarFechaFinal(listaVueltaDeDerivacion, false);
                } 
                if (!listaReabrirReclamacion.isEmpty()) {SAC_TMOGlobal.modificarFechaFinal(listaReabrirReclamacion, false);} 
                if(!listaVueltaDeSubsanacion.isEmpty()){
                    SAC_TMOGlobal.crearNuevoTPE(listaVueltaDeSubsanacion);
                    SAC_TMOGlobal.modificarFechaFinal(listNewObj, false);
                }
                if(!listaRecPreFechaResolucion.isEmpty()){
                    SAC_Reclamacion.crearTaskMisClientes(listaRecPreFechaResolucion, listaCasosSelect);
                }
                if(!listaIdCasoChangeOwnerPreten.isEmpty()) {
                    //future para cambiar owner a pretensiones hijas
                    SAC_FutureMethods.changeOwnerPretensionesHijas(listaIdCasoChangeOwnerPreten, setIdReclaOwner);
                }

                if(!listaActualizarDatosContacto.isEmpty()){  
                    SAC_Pretension.actualizarDatosContacto(listaCasosSelect, listaActualizarDatosContacto, mapaDatosCasosActualizar);
                }  
            }
                               

            if(!listaConsultas.isEmpty()){
                //SAC_CaseComprobarAdjuntos.comprobar(listaConsultas); Comentado por no utilizar el chek ficheros adjuntos en consultas cops
                if (!listaNewConsultaAsignarCasosAlOwner.isEmpty()) { SAC_Balanceo.asignarCasosAlOwner (listaCasosSelect, listaNewConsultaAsignarCasosAlOwner,listaIdsCuentas, mapaDatosCasosActualizar);}
            }
            if(!listaCasos.isEmpty()){
                if(!listaPretMCC.isEmpty() && !listaCasosSelect.isEmpty()){
                    actualizaMCC(listaPretMCC, listaCasosSelect, mapaDatosCasosActualizar);
                }
                SAC_HandlerMethods.createReclamanteRecord(listaCasos, mapOldObj);
                //SAC_ComportamientoSLAs.updateVacioPretRec(listaCasos, mapNewObj); //Hace un Update a toda la familia de cada caso y comprueba y modifica las pausas de las SLA si es necesario. Se hace todo en un future
                SAC_FutureMethods.gestionMetodosFuturos(listaCasos, mapOldObj);
                //update vacio sustituido por SAC_FutureMethods gestionMetodosFuturos
                if(!setIdesRecCheck.isEmpty()){SAC_Consulta.desmarcarCheckReclamacion(listaCasosSelect, setIdesRecCheck, mapaDatosCasosActualizar);}
                //Lanza schedulable para dentro de 10 días comprobar si sigue en negociación y mandar alerta
                if (!listaRecPretNegociacion.isEmpty()) {
                    SAC_Reclamacion.scheduleAlertaNegociacion(listaRecPretNegociacion);
                }
                //Lanza schedulable para dentro de 10 días comprobar si sigue en subsanación y mandar alerta
                if (!listaRecPretSubsanacion.isEmpty()) {
                    SAC_Reclamacion.scheduleAlertaSubsanacion(listaRecPretSubsanacion);                    
                }
                if(!listaRecCambioNaturaleza.isEmpty()) {
                    SAC_Reclamacion.bajaPretensionesRechazo(listaRecCambioNaturaleza);
                }
                if(!setChangeGrupoLetrado.isEmpty()) {
                    SAC_FutureMethods.eliminarPermisosOwnerLetrado(setChangeGrupoLetrado, mapOldObj);
                }
                if(!listaModRecCerradas.isEmpty()){  
                    SAC_Reclamacion.crearCaseHistoryReclamacionCerrada(mapOldObj, listNewObj);
                }
            }          
            if(!listaOwnersCambiados.isEmpty()){
                actualizaReclamantesAsociados(listaOwnersCambiados);
                //SAC_Pretension.cambiarOwnersPretsHermanas(listaOwnersCambiados, listaCasosSelect, mapaDatosCasosActualizar);
            }      
            procesado = true;                        
        }   

        if (!listaPretOwnerCola.isEmpty()) {SAC_Reclamacion.insertarCaseShare(listaPretOwnerCola, listaCasosSelect);}         

        if(!mapaDatosCasosActualizar.isEmpty()){
            // Database.update(mapaDatosCasosActualizar.values());
            if(recalcularSharesPretensiones){
                SAC_Reclamacion.insertarCaseSharePorReclamacionOPretension(mapaDatosCasosActualizar.values());
            }
            if(recalcularSharesReclamaciones){
                SAC_Reclamacion.insertarCaseSharePorReclamacionOPretension(mapaDatosCasosActualizar.values());
            }
            SAC_DatabaseDML.updateListDML(mapaDatosCasosActualizar.values(), false);
        }
   
    }
 
    public static Map<Id,Case> actualizaMCC (List<Case> listaPretMCC, List<Case> listaCasosSelect,  Map<Id,Case> mapaDatosCasosActualizar){
        //Pasar lista a mapa sin duplicados
        Map<Id,Case> mapaPretMCCCambiado = new Map<Id,Case>();
        for (Case caso : listaPretMCC) {
            if (!mapaPretMCCCambiado.containsKey(caso.Id)) {
                mapaPretMCCCambiado.put(caso.Id, caso);
            }
        }

        for (Case casoSelect : listaCasosSelect) {
            if (casoSelect.RecordTypeId == RECTYPERECLAMACION && mapaPretMCCCambiado.containsKey(casoSelect.SAC_PretensionPrincipal__c)) {
                if(mapaDatosCasosActualizar.containsKey(casoSelect.Id)){
                    mapaDatosCasosActualizar.get(casoSelect.Id).CC_MCC_Tematica__c = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).CC_MCC_Tematica__c;
                    mapaDatosCasosActualizar.get(casoSelect.Id).CC_MCC_ProdServ__c = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).CC_MCC_ProdServ__c;
                    mapaDatosCasosActualizar.get(casoSelect.Id).CC_MCC_Motivo__c   = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).CC_MCC_Motivo__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SEG_Detalle__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SEG_Detalle__c;

                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_Motivo_BDE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_Motivo_BDE__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_FamiliaBdE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_FamiliaBdE__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_ProductoBDE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_ProductoBDE__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_FamiliaMotivoBdE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_FamiliaMotivoBdE__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_DGS__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_DGS__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_Producto2BdE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_Producto2BdE__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_MotivoReclamacion__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_MotivoReclamacion__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_AgrupacionesFamilias__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_AgrupacionesFamilias__c;
                    mapaDatosCasosActualizar.get(casoSelect.id).SAC_ServicioInversion__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_ServicioInversion__c;
                }else{
                    mapaDatosCasosActualizar.put(casoSelect.id, new Case(Id = casoSelect.Id, 
                                                                         CC_MCC_Tematica__c = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).CC_MCC_Tematica__c,
                                                                         CC_MCC_ProdServ__c = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).CC_MCC_ProdServ__c,
                                                                         CC_MCC_Motivo__c   = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).CC_MCC_Motivo__c,
                                                                         SEG_Detalle__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SEG_Detalle__c,
                                                                         SAC_Motivo_BDE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_Motivo_BDE__c,
                                                                         SAC_FamiliaBdE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_FamiliaBdE__c,
                                                                         SAC_ProductoBDE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_ProductoBDE__c,
                                                                         SAC_FamiliaMotivoBdE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_FamiliaMotivoBdE__c,
                                                                         SAC_DGS__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_DGS__c,
                                                                         SAC_Producto2BdE__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_Producto2BdE__c,
                                                                         SAC_MotivoReclamacion__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_MotivoReclamacion__c,
                                                                         SAC_AgrupacionesFamilias__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_AgrupacionesFamilias__c,
                                                                         SAC_ServicioInversion__c     = mapaPretMCCCambiado.get(casoSelect.SAC_PretensionPrincipal__c).SAC_ServicioInversion__c));
                }
            }
        }
        
        return mapaDatosCasosActualizar;    
    }

    public static void actualizaReclamantesAsociados(List<Case> listaOwnersCambiados){

        Set<Id> idsCasos = new Set<Id>();
        Map<Id, Id> mapaCasoOwner = new Map<Id, Id>();

        for(Case caso : listaOwnersCambiados){
            idsCasos.add(caso.Id);
            mapaCasoOwner.put(caso.Id, caso.OwnerId);
        }

        List <SAC_CaseReclamante__c> reclamantes = [SELECT Id, SAC_Case__c from SAC_CaseReclamante__c WHERE SAC_Case__c IN :idsCasos];

        for(SAC_CaseReclamante__c reclamante : reclamantes){
            reclamante.OwnerId = mapaCasoOwner.get(reclamante.SAC_Case__c);
        }

        SAC_DatabaseDML.updateListDML(reclamantes, false);
    }    
}