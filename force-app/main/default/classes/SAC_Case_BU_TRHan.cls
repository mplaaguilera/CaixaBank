/*****************************************************************
 * Name: SAC_Case_BU_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Update del objeto Case
 * 
 * Clases test: SAC_Case_BU_TRHan_Test, SAC_Pretension_Test, SAC_Validaciones_Test, SAC_Balanceo_Test, SAC_Reclamacion_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200213         Carlos Solis   22/04/21     Creación
 * 1.1            US200298         Luis Mesa      23/04/21     Adición Método actualizarCasoRelacionado
 * 2.0            US270297         Marcela Neira  10/09/21     Optimización de los métodos y
 *                                 Esteve  Llaó                revisión del trigger de Case           
*****************************************************************/
public without sharing class SAC_Case_BU_TRHan extends CC_TriggerHandlerBase {

    private static Boolean procesado = false;
    private static Boolean segundoProcesado = false;
    private static Boolean compruebaPretensiones = false;
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        Schema.DescribeSObjectResult recordType = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = recordType.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
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
            }
        }
        List<Case> listOldObjSAC= New List<Case>();
        Map<Id, Case> mapOldObjSAC = New Map<Id, Case>();
        for (Case tk: listOldObj){
            if((setIdsRt).contains(tk.RecordTypeId)){
                listOldObjSAC.add(tk);
                mapOldObjSAC.put(tk.Id,tk);
            }
        }
        if (listNewObjSAC.size()!=0) {
            processSAC(listNewObjSAC,mapNewObjSAC,listOldObjSAC,mapOldObjSAC);
        }
    }
    private void processSAC(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {
        //Recuperar las colas del cache
        List<Group> listaColas = new List<Group>();
        Group cola;
        Group colaSupervisores;
        listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
        if(!listaColas.isEmpty()){
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                    cola = grupoAux;
                }else if(grupoAux.DeveloperName == 'SAC_PteSupervisor'){
                    colaSupervisores = grupoAux;
                }
            }
        }

        //Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        //Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
        List<SObject> objetos =new list<SObject>();        
        List<Id> listaIdsRec = new List<Id>();
        List<Id> listaIdsCuentas = new List<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();
        List<Case> listaConsulta = new List<Case>();
        List<Case> listaConsultaSAC = new List<Case>();
        List<Case> listaReclaAnalisis = new List<Case>();         
        List<Case> listNewCaseCambiarOwner = new List<Case>();
        List<Case> reclamacionesVSentidoResolucion = new List<Case>();
        List<Case> listaRecPret = new List<Case>();
        List<Case> listaRecPretCons = new List<Case>();
        list<case> listaResultCasos = new list<case>(); 
        list<case> listaReclamacionesParaBalanceo = new list<case>();
        List<Case> listaReclamacionesPretensionesOwner = new List<Case>();  
        List<Case> listaReclamacionesPretensionesOwnerOld = new List<Case>();        
        List<Case> listaReclaPretConsul = new List<Case>();  
        List<Case> listaRecCambioPretPrincipal = new List<Case>();
        List<Case> listaRecRepresentanteValido = new List<Case>();
        List<Case> listaCaseAccALF = new List<Case>();
        List<Case> listaCambioOwner = new List<Case>();
        List<Case> listaCambioOwnerPretension = new List<Case>();
        List<Case> listaCambioOwnerReclamacion = new List<Case>();
        List<Case> listaSetCanalRespuesta = new List<Case>();
        List<Case> listaPretMCC = new List<Case>();
        List<Case> listaCasosMCC = new List<Case>();
        List<Id> listaTematicaMCC = new List<Id>();
        List<Case> listaCambioDeAccount = new List<Case>();
        List<Case> listaReclamacionRechazo = new List<Case>();
        List<Case> listaReclamacionRechazoPretensiones = new List<Case>();
        List<Case> listaReclamacionMotivoOtro = new List<Case>();
        List<Case> listaReclamacionMotivoRechazo = new List<Case>();
        List<Case> listaReclamacionComments = new List<Case>();
        List<Case> listaContactoPostal = new List<Case>();
        List<Case> listaPretensionesImporte = new List<Case>();
        List<Case> listaPretensionNegocioAnalisis = new List<Case>();
        List<Case> reclamanteConforme = new List<Case>();
        List<Case> listaRechazoAltaErronea = new List<Case>();
        List<Case> listaPretensionesCambioEst = new List<Case>();
        List<Case> listaRecPretAlertasSLA = new List<Case>();
        List<Case> listaCasosSubsanaNegocia = new List<Case>();
        List<Case> listaCasoNegociacion = new List<Case>();
        List<Case> listaCasoDerivacion = new List<Case>();
        List<Case> listaCasoEjecucion = new List<Case>();
        List<Case> listaCambioEstado = new List<Case>();
        List<Case> listaBalanceoLetrado = new List<Case>();
        List<Case> listaCambioCliente = new List<Case>();
        List<Case> listaCasosSubsanacion = new List<Case>();
        List<Case> listaCasoGenialDerivacion = new List<Case>();
        List<Case> listaValidarIdioma = new List<Case>();
        Map<Id, Case> mapaBuscarPretensiones = new Map<Id,Case>();
        List<SAC_Accion__Share> listaShareAccionesInsertar = new List<SAC_Accion__Share>();   
        List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
        Set<Id> idesReclaGlobal = new Set<Id>(); 
        Set<Id> setIdesCambioPretPrincipal = new Set<Id>();
        Set<Id> setIdsPadres = new Set<Id>();
        

           
        for (case caso : listNewObj) { 
            if (caso.RecordTypeId == RECTYPERECLAMACION) {
                listaReclamaciones.add(caso);
                listaRecPretCons.add(caso);
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SAC_002') {
                    listaIdsRec.add(caso.Id);
                    idesReclaGlobal.add(caso.Id);
                    listaReclaAnalisis.add(caso);
                    setIdesCambioPretPrincipal.add(caso.Id);
                }
                if(mapOldObj.containsKey(caso.Id) && (caso.SEG_Detalle__c != mapOldObj.get(caso.Id).SEG_Detalle__c
                  || caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c
                  || caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c
                  || caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c ) ){
                    listaCasosMCC.add(caso);
                    listaTematicaMCC.add(caso.SEG_Detalle__c);
                }

                if(mapOldObj.containsKey(caso.Id) && caso.SAC_MotivoRechazo__c != mapOldObj.get(caso.Id).SAC_MotivoRechazo__c && caso.SAC_MotivoRechazo__c	== 'Rechazada por vinculacion') {
                    listaReclamacionMotivoRechazo.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_MotivoRechazo__c != mapOldObj.get(caso.Id).SAC_MotivoRechazo__c && caso.SAC_MotivoRechazo__c == 'Otros') {
                    listaReclamacionMotivoOtro.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_MotivoRechazo__c != mapOldObj.get(caso.Id).SAC_MotivoRechazo__c && caso.SAC_MotivoRechazo__c == 'SAC_AltaErronea') {
                    listaRechazoAltaErronea.add(caso);
                    idesReclaGlobal.add(caso.Id);
                }
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Rechazado') {
                    listaReclamacionRechazo.add(caso);
                    listaReclamacionComments.add(caso);
                    caso.SAC_NPretensionesActivas__c = 0;
                }
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'Rechazado' && caso.CC_Rechazar_Reabrir_Caso__c)) {
                    listaReclamacionRechazoPretensiones.add(caso);
                }

               

                if(mapOldObj.containsKey(caso.id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId) {
                    listaReclamacionesPretensionesOwner.add(caso);
                    listaCambioOwner.add(caso);
                    listaCambioOwnerReclamacion.add(caso);
                    idesReclaGlobal.add(caso.Id);
                }
                if(mapOldObj.containsKey(caso.Id) && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.AccountId != null && String.isBlank(caso.SAC_CasoRelacionado__c)) {
                    listaIdsCuentas.add(caso.AccountId);
                    listNewCaseCambiarOwner.add(caso);
                    listaCambioDeAccount.add(caso);
                } 
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_SentidoResolucion__c != mapOldObj.get(caso.Id).SAC_SentidoResolucion__c && caso.SAC_SentidoResolucion__c != 'SAC_004'){
                    reclamacionesVSentidoResolucion.add(caso);
                    idesReclaGlobal.add(caso.Id);
                } 
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_ReclamanteConformeNegociacion__c != mapOldObj.get(caso.Id).SAC_ReclamanteConformeNegociacion__c && caso.SAC_ReclamanteConformeNegociacion__c == true){
                    reclamanteConforme.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_Naturaleza__c != mapOldObj.get(caso.Id).SAC_Naturaleza__c && caso.SAC_Naturaleza__c == 'SAC_005'){ 
                    mapaBuscarPretensiones.put(caso.id, caso);
                    idesReclaGlobal.add(caso.Id);
                } 
                if(mapOldObj.containsKey(caso.Id) && (String.isBlank(caso.CC_SuppliedID__c) || (!String.isBlank(caso.CC_SuppliedID__c) && !caso.CC_SuppliedID__c.contains(caso.Id)))){
                    listaReclaPretConsul.add(caso);
                }
                
                //if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PretensionPrincipal__c != caso.SAC_PretensionPrincipal__c && caso.Status == mapOldObj.get(caso.Id).Status) {
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PretensionPrincipal__c != caso.SAC_PretensionPrincipal__c) {
                    setIdesCambioPretPrincipal.add(caso.SAC_PretensionPrincipal__c);
                    listaRecCambioPretPrincipal.add(caso);
                    //listaTematicaMCC.add(caso.SEG_Detalle__c);
                }

                if((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionContacto__c != caso.SAC_DireccionContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalContacto__c != caso.SAC_CodigoPostalContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionContacto__c != caso.SAC_PoblacionContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaContacto__c != caso.SAC_ProvinciaContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisContacto__c != caso.SAC_PaisContacto__c) 
                    ) {
                        listaContactoPostal.add(caso);
                    }
                if ((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_EmailRepresentante__c != caso.SAC_EmailRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionPostal__c != caso.SAC_DireccionPostal__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_UsarDatos__c != caso.SAC_UsarDatos__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NombreRepresentante__c != caso.SAC_NombreRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeRepresentante__c != caso.SAC_TipoDeRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeDocumento__c != caso.SAC_TipoDeDocumento__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DespachoRepresentante__c != caso.SAC_DespachoRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NumeroDelDocumento__c != caso.SAC_NumeroDelDocumento__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TelefonoRepresentante__c != caso.SAC_TelefonoRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionRepresentante__c != caso.SAC_DireccionRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalRepresentante__c != caso.SAC_CodigoPostalRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionRepresentante__c != caso.SAC_PoblacionRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaRepresentante__c != caso.SAC_ProvinciaRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisRepresentante__c != caso.SAC_PaisRepresentante__c) 
                    ) {
                        listaRecRepresentanteValido.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).AccountId != caso.AccountId && caso.SAC_UsarDatos__c) {
                    listaCaseAccALF.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                    listaSetCanalRespuesta.add(caso);
                    listaCambioCliente.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).OS_Email__c != caso.OS_Email__c || 
                    mapOldObj.get(caso.Id).SAC_DireccionContacto__c != caso.SAC_DireccionContacto__c ||
                    mapOldObj.get(caso.Id).SAC_CodigoPostalContacto__c != caso.SAC_CodigoPostalContacto__c ||
                    mapOldObj.get(caso.Id).SAC_PoblacionContacto__c != caso.SAC_PoblacionContacto__c ||
                    mapOldObj.get(caso.Id).SAC_ProvinciaContacto__c != caso.SAC_ProvinciaContacto__c ||
                    mapOldObj.get(caso.Id).SAC_PaisContacto__c != caso.SAC_PaisContacto__c
                )){
                    listaSetCanalRespuesta.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).OS_SLA_Completado__c != caso.OS_SLA_Completado__c) {
                    listaRecPretAlertasSLA.add(caso);
                    idesReclaGlobal.add(caso.Id);
                    setIdsPadres.add(caso.Id);
                }

                //Marcar el check de notificación sin leer y actualizar fecha la notificación se envia en el AU
                /*if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_003' && caso.Status == 'SAC_004') {
                    caso.SAC_NotificacionSinLeer__c = true;
                    caso.OS_Alerta_Fecha__c = system.now();
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SAC_001') {
                    caso.SAC_NotificacionSinLeer__c = true;
                    caso.OS_Alerta_Fecha__c = system.now();
                }*/

                //Si el status pasa a subsanación o negociación
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'SAC_006' || caso.Status == 'SAC_007')) {
                    listaCasosSubsanaNegocia.add(caso);
                    if(caso.Status == 'SAC_006') {
                        listaCasosSubsanacion.add(caso);
                    }
                }
                //Si el caso pasa a estado negociación y no habia estado nunca en estado negociación (el check caso negociado no esta marcado)
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'SAC_007' && !caso.SAC_CasoNegociado__c)) {
                    listaCasoNegociacion.add(caso);
                }

                //Si el caso ha cambiado de estado o fecha resolución
                if ((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status) || (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).OS_Fecha_Resolucion__c != caso.OS_Fecha_Resolucion__c)) {
                    listaCambioEstado.add(caso);
                    idesReclaGlobal.add(caso.Id);
                }

                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002'){
                    listaBalanceoLetrado.add(caso);
                }
                //Hacemos Bypass para calcular el SAC_FechaVencimientoSLA__c de forma custom evitando SAC_MilestoneTimeCalculator en la derivación de casos IA 
                /*if(mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_008' && String.isNotBlank(caso.SAC_GenialEstado__c)) || (caso.Status == 'SAC_001' && caso.SAC_GenialEstado__c == 'SAC_003')){                 
                    listaCasoGenialDerivacion.add(caso);
                }*/

                if(caso.SAC_GenialEstado__c != null && (mapOldObj.get(caso.Id).SAC_TipoConsumidor__c != caso.SAC_TipoConsumidor__c ||
                mapOldObj.get(caso.Id).SAC_FechaRecepcion__c != caso.SAC_FechaRecepcion__c || mapOldObj.get(caso.Id).SAC_TiempoSLARegulatorio__c != caso.SAC_TiempoSLARegulatorio__c)){
                    listaCasoGenialDerivacion.add(caso);
                }

                //Si el caso pasa a derivación
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SAC_008') {
                    listaCasoDerivacion.add(caso);
                }

                //Si el caso pasa a ejecución
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SAC_004') {
                    listaCasoEjecucion.add(caso);
                }

                //Si el caso sale de alta sin tener el campo idioma informado
                if(mapOldObj.containsKey(caso.Id) && caso.Status != 'Rechazado' && caso.Status != mapOldObj.get(caso.Id).Status && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.CC_Idioma__c == null) {
                    listaValidarIdioma.add(caso);
                }

                listaRecPret.add(caso);
            }
            else if(caso.RecordTypeId == RECTYPEPRETENSION){
                listaPretensiones.add(caso);
                listaRecPret.add(caso);
                listaRecPretCons.add(caso);

                if(mapOldObj.containsKey(caso.id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId) {
                    listaReclamacionesPretensionesOwner.add(caso);
                    listaCambioOwner.add(caso);
                    listaCambioOwnerPretension.add(caso);
                    setIdsPadres.add(caso.SAC_Reclamacion__c);
                }
                if(mapOldObj.containsKey(caso.id) && mapOldObj.get(caso.id).Status == 'SAC_007' && (caso.CC_Importe_Reclamado__c != mapOldObj.get(caso.Id).CC_Importe_Reclamado__c 
                || caso.SAC_Importe_Resuelto__c != mapOldObj.get(caso.Id).SAC_Importe_Resuelto__c)) {
                    listaPretensionesImporte.add(caso);
                }
                if(mapOldObj.containsKey(caso.id) && caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'SAC_002' || caso.Status == 'SAC_003' || caso.Status == 'Cerrado') && mapOldObj.get(caso.Id).Status == 'SAC_007'){
                    listaPretensionNegocioAnalisis.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && (mapOldObj.get(caso.Id).Status == 'SAC_002' || mapOldObj.get(caso.Id).Status == 'SAC_006') && 
                    caso.Status != 'SAC_001' && caso.Status != 'SAC_002') {
                    listaPretensionesCambioEst.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && (String.isBlank(caso.CC_SuppliedID__c) || (!String.isBlank(caso.CC_SuppliedID__c) && !caso.CC_SuppliedID__c.contains(caso.Id)))){
                    listaReclaPretConsul.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && (caso.SEG_Detalle__c != mapOldObj.get(caso.Id).SEG_Detalle__c
                  || caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c
                  || caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c
                  || caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c ) ){
                    listaPretMCC.add(caso);
                    listaCasosMCC.add(caso);
                    listaTematicaMCC.add(caso.SEG_Detalle__c);
                }
                if (mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).SAC_Entidad_Afectada__c != caso.SAC_Entidad_Afectada__c || mapOldObj.get(caso.Id).SAC_EntidadProductora__c != caso.SAC_EntidadProductora__c)) {
                    setIdsPadres.add(caso.SAC_Reclamacion__c);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).OS_SLA_Completado__c != caso.OS_SLA_Completado__c) {
                    listaRecPretAlertasSLA.add(caso);
                }
                //Si el caso pasa a estar en subsanación o negociación
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'SAC_006' || caso.Status == 'SAC_007')) {
                    listaCasosSubsanaNegocia.add(caso);
                    if(caso.Status == 'SAC_006') {
                        listaCasosSubsanacion.add(caso);
                        setIdsPadres.add(caso.SAC_Reclamacion__c);
                    }
                }
                //Si el caso pasa a estado negociación y no habia estado nunca en estado negociación (el check caso negociado no esta marcado)
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && (caso.Status == 'SAC_007' && !caso.SAC_CasoNegociado__c)) {
                    listaCasoNegociacion.add(caso);
                }
                //Si el caso ha cambiado de estado
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status) {
                    listaCambioEstado.add(caso);
                    setIdsPadres.add(caso.SAC_Reclamacion__c);
                }

                //Si el caso sale de alta sin tener el campo idioma informado
                if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.CC_Idioma__c == null ) {
                    listaValidarIdioma.add(caso);
                }
            }
            else if(caso.RecordTypeId == RECTYPECONSULTA){
                if(mapOldObj.containsKey(caso.Id) && caso.SAC_Naturaleza__c != mapOldObj.get(caso.Id).SAC_Naturaleza__c && caso.SAC_Naturaleza__c == 'SAC_004'){
                    caso.recordTypeId = RECTYPERECLAMACION;
                    caso.Status = 'SAC_001';
                    caso.SAC_StatusAuxiliar__c = 'SAC_001';
                    listaReclamacionesParaBalanceo.add(caso);
                    if (caso.AccountId != null) { 
                        listaIdsCuentas.add(caso.AccountId);
                    }
                } 
                if(mapOldObj.containsKey(caso.Id) && (String.isBlank(caso.CC_SuppliedID__c) || (!String.isBlank(caso.CC_SuppliedID__c) && !caso.CC_SuppliedID__c.contains(caso.Id)))){
                    listaReclaPretConsul.add(caso);
                }
                /*US543563 Posibilidad en consultas cops de  traspasar al gestor de una reclamación abierta.*/
                // if(mapOldObj.containsKey(caso.Id) && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.AccountId != null) {
                //     listaIdsCuentas.add(caso.AccountId);
                //     listNewCaseCambiarOwner.add(caso);
                // }
                if ((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_EmailRepresentante__c != caso.SAC_EmailRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionPostal__c != caso.SAC_DireccionPostal__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_UsarDatos__c != caso.SAC_UsarDatos__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NombreRepresentante__c != caso.SAC_NombreRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeRepresentante__c != caso.SAC_TipoDeRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeDocumento__c != caso.SAC_TipoDeDocumento__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DespachoRepresentante__c != caso.SAC_DespachoRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NumeroDelDocumento__c != caso.SAC_NumeroDelDocumento__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionRepresentante__c != caso.SAC_DireccionRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalRepresentante__c != caso.SAC_CodigoPostalRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionRepresentante__c != caso.SAC_PoblacionRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaRepresentante__c != caso.SAC_ProvinciaRepresentante__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisRepresentante__c != caso.SAC_PaisRepresentante__c) 
                    ) {
                        listaRecRepresentanteValido.add(caso);
                }
                if((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionContacto__c != caso.SAC_DireccionContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalContacto__c != caso.SAC_CodigoPostalContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionContacto__c != caso.SAC_PoblacionContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaContacto__c != caso.SAC_ProvinciaContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisContacto__c != caso.SAC_PaisContacto__c) 
                    ) {
                        listaContactoPostal.add(caso);
                    }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).AccountId != caso.AccountId && caso.SAC_UsarDatos__c) {
                    listaCaseAccALF.add(caso);
                }
                if (mapOldObj.containsKey(caso.id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId) {
                    listaCambioOwner.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).OS_Email__c != caso.OS_Email__c || mapOldObj.get(caso.Id).SAC_DireccionPostal__c != caso.SAC_DireccionPostal__c)){
                    listaSetCanalRespuesta.add(caso);
                }
                //Si el caso ha cambiado de estado
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status) {
                    listaCambioEstado.add(caso);
                }
                listaConsulta.add(caso);   
                listaRecPret.add(caso);
                listaRecPretCons.add(caso);
            }else if(caso.RecordTypeId == RECTYPECONSULTASAC){
                listaConsultaSAC.add(caso);
                listaRecPretCons.add(caso);
                if ((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_EmailRepresentante__c != caso.SAC_EmailRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionPostal__c != caso.SAC_DireccionPostal__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_UsarDatos__c != caso.SAC_UsarDatos__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NombreRepresentante__c != caso.SAC_NombreRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeRepresentante__c != caso.SAC_TipoDeRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeDocumento__c != caso.SAC_TipoDeDocumento__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DespachoRepresentante__c != caso.SAC_DespachoRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NumeroDelDocumento__c != caso.SAC_NumeroDelDocumento__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TelefonoRepresentante__c != caso.SAC_TelefonoRepresentante__c ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionRepresentante__c != caso.SAC_DireccionRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalRepresentante__c != caso.SAC_CodigoPostalRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionRepresentante__c != caso.SAC_PoblacionRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaRepresentante__c != caso.SAC_ProvinciaRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisRepresentante__c != caso.SAC_PaisRepresentante__c)
                )) {
                        listaRecRepresentanteValido.add(caso);
                }
                if((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionContacto__c != caso.SAC_DireccionContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalContacto__c != caso.SAC_CodigoPostalContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionContacto__c != caso.SAC_PoblacionContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaContacto__c != caso.SAC_ProvinciaContacto__c) ||
                    (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisContacto__c != caso.SAC_PaisContacto__c) 
                    ) {
                        listaContactoPostal.add(caso);
                    }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).AccountId != caso.AccountId && caso.SAC_UsarDatos__c) {
                    listaCaseAccALF.add(caso);
                }
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                    listaRecRepresentanteValido.add(caso);
                }
                if(mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).OS_Email__c != caso.OS_Email__c || mapOldObj.get(caso.Id).SAC_DireccionPostal__c != caso.SAC_DireccionPostal__c)){
                   listaSetCanalRespuesta.add(caso);
                }
                //Si el caso ha cambiado de estado
                if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status) {
                    listaCambioEstado.add(caso);
                }
            }

        }   

        List<Case> listaCasos = new List<Case>();
        listaCasos = [SELECT Id, SAC_Reclamacion__c, Status, RecordTypeId, SEG_Detalle__c,subject, ownerId, AccountId, SEG_Grupo__c, 
                        isClosed, SAC_TiempoSLALetradoAlta__c, SAC_SentidoResolucion__c, CC_Canal_Procedencia__c, CC_MCC_Tematica__c,
                        CC_MCC_ProdServ__c, CC_MCC_Motivo__c, Account.PersonEmail, Account.BillingStreet, Account.BillingPostalCode, 
                        Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.Phone, Account.PersonMobilePhone,
                        Account.Name, SEG_Detalle__r.SAC_esGGH__c, SAC_ImpReclamadoGestoria__c, SAC_ImpReclamadoInteresesLegales__c, SAC_TAE__c,
                        SAC_ImpReclamadoNotaria__c, SAC_ImpReclamadoRegistros__c, SAC_ImpReclamadoTasacion__c, CaseNumber, SAC_Entidad_Afectada__c,
                        SAC_MotivoVXC__c, SAC_Negocio__c, SAC_TipoContingenciaPrestacion__c, SAC_Reclamacion__r.ownerId, SAC_Motivo_BDE__c,
                        SAC_FamiliaBdE__c, SAC_ProductoBDE__c, SAC_DGS__c, SAC_Producto2BdE__c, SAC_MotivoReclamacion__c, SAC_AgrupacionesFamilias__c,
                        SAC_ServicioInversion__c, SAC_EntidadProductora__c, OS_Fecha_Resolucion__c, SEG_Grupo__r.SAC_Email__c, SAC_CasoNegociado__c, SAC_FamiliaMotivoBdE__c, SAC_DetenidoHasta__c
                        FROM Case 
                        WHERE (RecordTypeId= :RECTYPEPRETENSION OR RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPECONSULTA OR RecordTypeId = :RECTYPECONSULTASAC) 
                        AND ( (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN :idesReclaGlobal)          
                        OR (RecordTypeId = :RECTYPERECLAMACION  AND AccountId IN :listaIdsCuentas AND isClosed = false )
                        OR (RecordTypeId = :RECTYPEPRETENSION AND (SAC_Reclamacion__c IN :setIdesCambioPretPrincipal OR Id IN :setIdesCambioPretPrincipal))
                        OR ((RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPECONSULTA OR RecordTypeId = :RECTYPECONSULTASAC) AND Id IN :listaRecRepresentanteValido)
                        OR (RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsPadres)
                        )];

        if (!procesado) {
            if (!listaReclamaciones.isEmpty()) {
                SAC_AdministrarUsuarios.comprobarOwner(listaReclamaciones, mapOldObj, cola, colaSupervisores); //Actualizar el owner del caso   
                actualizarFechaRecepcion(listaReclamaciones, mapOldObj); //Actualizar Milestone a fecha recepcion proyecto SAC
                if(!listaIdsCuentas.isEmpty()){
                    SAC_Balanceo.asignarOwnerCaso(listaCasos, listNewCaseCambiarOwner, listaIdsCuentas);
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 1 ' + caso.Id);}
                }
                if(!reclamanteConforme.isEmpty()){
                    SAC_Pretension.rellenarReclamanteConforme(reclamanteConforme);//Rellenar el reclamante conforme para la negociación de las pretensiones
                }
                if(!listaIdsRec.isEmpty()){
                    SAC_Pretension.marcarPretensionPrincipal(listaReclamaciones, listaCasos, listaIdsRec, listaRecCambioPretPrincipal); //En caso de Unipretensión, la pretension se marca como principal automáticamente (al pasar a estado Análisis)
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 2 ' + caso.Id);}
                    SAC_Validaciones.validarMCC(listaReclamaciones, mapOldObj, listaCasos, listaReclaAnalisis); //Valida si las pretensiones tienen el MCC informado antes de pasar a Análisis
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 3 ' + caso.Id);}
                    SAC_Validaciones.validarPretensionPrincipal(listaReclamaciones, mapOldObj, listaCasos, listaIdsRec); //Si la reclamación es multipretensión, valida que la pretensión principal esté informada                
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 4 ' + caso.Id);}
                    SAC_Validaciones.validarImportesReclamados(listaReclamaciones, listaCasos, listaReclaAnalisis);// Valida si las pretensiones que son de GGH tienen los importes reclamados informados
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 5 ' + caso.Id);}
                    SAC_Validaciones.validarCuentaInformada(listaReclaAnalisis);// Valida si existe un AccountId en la reclamación a la hora de pasar a Análisis
                }
                if(!listaReclamacionRechazo.isEmpty()) {
                    SAC_Validaciones.validarAltaAnalisisRechazar(listaReclamacionRechazo, mapOldObj);
                    SAC_Reclamacion.cerrarTareas(listaReclamacionRechazo);
                }
                if(!listaReclamacionMotivoRechazo.isEmpty()){SAC_Validaciones.comprobarReclamacionesVinculadas(listaReclamacionMotivoRechazo);}
                if(!listaRechazoAltaErronea.isEmpty()){ 
                    SAC_Validaciones.comprobarReclamAltaErronea(listaRechazoAltaErronea, listaCasos); 
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 6 ' + caso.Id);}
                }

                if(!listaReclamacionMotivoOtro.isEmpty()){SAC_Validaciones.validarComentarioRechazo(listaReclamacionMotivoOtro, mapOldObj);}
                if(!listaReclamacionComments.isEmpty()){SAC_Reclamacion.guardarComentariosRechazo(listaReclamacionComments, mapOldObj);}
                if(!listaTematicaMCC.isEmpty()){
                    SAC_Pretension.rellenarCodigosExternosMCC(listaCasosMCC, listaTematicaMCC); //Rellena los campos con los códigos externos que tiene el mcc.
                }
                
                //Se ha hecho para evitar que al actualizar en una pretension el sentido de resolucion, saltar el error de que el padre no tiene hijas con sentido de resolucion.
                if (!compruebaPretensiones && !reclamacionesVSentidoResolucion.isEmpty()) {
                   SAC_Validaciones.validarSentidoResolucion(listaCasos, reclamacionesVSentidoResolucion); //Si se cambia en la reclamación el sentido de resolución, debe tener valor también en las pretensiones hijas ese campo
                   //for(Case caso: listaCasos) { System.debug('Buscando el caso 7 ' + caso.Id);}
                }                              

                
                if (!listaRecCambioPretPrincipal.isEmpty()) { 
                    actualizarMCCPretPrincipal(listaRecCambioPretPrincipal, listaCasos); 
                    //SAC_Reclamacion.actualizarTAE(listaReclamacionesCambiaPretPrincipal, listaCasos);
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 8 ' + caso.Id);}
                }
                if (!listaRecRepresentanteValido.isEmpty()) {
                    SAC_LCMP_RepresentanteValido.camposRepresentanteValido(listaRecRepresentanteValido, listaCasos);
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 9 ' + caso.Id);}
                    SAC_SeleccionDireccionRespuesta.setCanalRespuesta(listaRecRepresentanteValido);
                }
                if (!listaCaseAccALF.isEmpty()) { SAC_LCMP_RepresentanteValido.usarDatosDeAlf(listaCaseAccALF); }
                if (!mapaBuscarPretensiones.isEmpty()){ 
                    if(!listaCasos.isEmpty()){
                        for (Case pretensionAux : listaCasos) {
                            if(pretensionAux.RecordTypeId == RECTYPEPRETENSION){
                                //if(mapaBuscarPretensiones.containsKey(pretensionAux.SAC_Reclamacion__c) && pretensionAux.Status != 'SAC_009'){
                                    //listaReclamacionRechazoPretensiones.add(mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c)); //Dar de baja las pretensiones cuando se cambia la naturaleza a consulta
                                    //mapaBuscarPretensiones.get((pretensionAux.SAC_Reclamacion__c)).SAC_Naturaleza__c.addError('No puede cambiar la naturaleza si tiene pretensiones relacionadas.');
                                //}//else{
                                mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c).recordTypeId = RECTYPECONSULTASAC;
                                mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c).Status='SAC_010';
                                mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c).SAC_StatusAuxiliar__c = 'SAC_010';
                                mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c).OwnerId=cola.id;
                                if (String.isNotBlank(mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c).CC_CasoRelacionado__c)) {
                                    mapaBuscarPretensiones.get(pretensionAux.SAC_Reclamacion__c).CC_CasoRelacionado__c = null;   
                                }
                                //}
                            }
                        }
                    }else{
                        for(Id key : mapaBuscarPretensiones.keySet()){ 
                            mapaBuscarPretensiones.get(key).recordTypeId = RECTYPECONSULTASAC;
                            mapaBuscarPretensiones.get(key).Status='SAC_010';
                            mapaBuscarPretensiones.get(key).SAC_StatusAuxiliar__c = 'SAC_010';
                            mapaBuscarPretensiones.get(key).OwnerId=cola.id;
                            if (String.isNotBlank(mapaBuscarPretensiones.get(key).CC_CasoRelacionado__c)) {
                                mapaBuscarPretensiones.get(key).CC_CasoRelacionado__c = null;
                            }
                        }
                    }  
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 10 ' + caso.Id);}                  
                }

                if(!listaReclamacionRechazoPretensiones.isEmpty()){
                    SAC_Reclamacion.bajaPretensionesRechazo(listaReclamacionRechazoPretensiones); //Dar de baja las pretensiones cuando se rechaza la reclamación desde la quick action de la list view
                }

                if (!listaCambioDeAccount.isEmpty()) {
                    SAC_Reclamacion.recuperarGestorCliente(listaCambioDeAccount); 
                }

                if(!listaContactoPostal.isEmpty()){
                    SAC_Reclamacion.informarDireccionPostar(listaContactoPostal);
                }

                if (!listaCambioOwnerReclamacion.isEmpty()) {
                    SAC_Reclamacion.modificarPermisoGestor(listaCambioOwnerReclamacion, listaCasos, mapOldObj);
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 11 ' + caso.Id);}
                }

                if(!listaBalanceoLetrado.isEmpty()){
                    SAC_Reclamacion.informarFechaUltimaActualizacion(listaBalanceoLetrado);
                }

                if (!listaCambioCliente.isEmpty()) {
                    SAC_Reclamacion.informarEsCliente(listaCambioCliente);
                }

                if(!listaCasoDerivacion.isEmpty()){
                    SAC_Reclamacion.informarFechaDerivacion(listaCasoDerivacion);
                }

                if(!listaCasoEjecucion.isEmpty()){
                    SAC_Reclamacion.informarFechaEjecucion(listaCasoEjecucion);
                }

                if(!listaCasosSubsanacion.isEmpty()) {
                    SAC_Reclamacion.informarDetenidoDesde(listaCasosSubsanacion);
                }
                if (!listaCasoGenialDerivacion.isEmpty()) {
                    for (Case caso : listaCasoGenialDerivacion) {
                        Datetime fechaVencimiento = SAC_GenialUtils.calculateMilestoneTriggerTime(caso);
                        if (fechaVencimiento != null) {
                            caso.SAC_FechaVencimientoSLA__c = fechaVencimiento;
                        }
                    }
                }
               
                if(!listaValidarIdioma.isEmpty()) {
                    SAC_Validaciones.validarIdiomaInformado(listaValidarIdioma, mapOldObj);
                }

                if (!listaSetCanalRespuesta.isEmpty()){SAC_SeleccionDireccionRespuesta.setCanalRespuesta(listaSetCanalRespuesta);} // DEJAR SIEMPRE ESTA LINEA EN LA ULTIMA POSICION DENTRO DEL IF
            }
            if((!listaPretensiones.isEmpty()) ||
                (!listaPretensiones.isEmpty() && procesado && !compruebaPretensiones)){
                //listaCaseMilestoneUpdatear.addAll(SAC_ComportamientoSLAs.finyReinicioSLAs(listaPretensiones, mapOldObj));
                SAC_Pretension.subjectMCC(listaPretensiones, mapOldObj); //Rellena el subject de la pretensión con el MCC nivel 2 y 4
                SAC_AdministrarUsuarios.comprobarOwner(listaPretensiones, mapOldObj, cola, colaSupervisores); //Actualizar el owner del caso
                SAC_Validaciones.validarCheckTareas(listaPretensiones, mapOldObj); // Validacion sobre el campo 'SAC_NoAplicaTareas__c'
                SAC_Validaciones.validarListoParaEnviar(listaPretensiones, mapOldObj); // Validaciones antes de ticar el checkbox 'Listo para Redaccion Final' (SAC_RedaccionFinal__c)
                SAC_Validaciones.validarCamposEntidadPret(listaPretensionesCambioEst); //Valida si las pretensiones tienen la entidad Vidacaixa que tengan informados los campos de Motivo VXC, Motivo VXC y Tipo contingencia/prestación

                if(!listaPretMCC.isEmpty()){
                    SAC_Pretension.rellenarEsPSD2(listaPretMCC); //Rellena el campo EsPSD2 de la pretensión
                }

                if(!listaTematicaMCC.isEmpty()){
                    SAC_Pretension.rellenarCodigosExternosMCC(listaCasosMCC, listaTematicaMCC); //Rellena los campos con los códigos externos que tiene el mcc.
                }

                if(!listaPretensionesImporte.isEmpty()){
                    SAC_Pretension.rellenarImporteResultadoNegocio(listaPretensionesImporte, mapOldObj); //Rellenar el campo SAC_Importe_ResultadoNegociacion
                }

                if(!listaPretensionNegocioAnalisis.isEmpty()){
                    SAC_Pretension.comprobarNegocioAnalisis(listaPretensionNegocioAnalisis, mapOldObj); //Comprobar que una pretensión en estado de negociación tiene los campos rellenos para volver al estado de análisis.
                }  
                if(!listaCasosSubsanacion.isEmpty()) {
                    SAC_Reclamacion.informarDetenidoDesde(listaCasosSubsanacion);
                }

                if(!listaValidarIdioma.isEmpty()) {
                    SAC_Validaciones.validarIdiomaInformado(listaValidarIdioma, mapOldObj);
                }
            
                compruebaPretensiones = true;
            }       
            if(!listaRecPretAlertasSLA.isEmpty()){                
                //SAC_AsignarTMEs.modificarTiemposPretension(listaRecPret, mapOldObj, listOldObj);
                SAC_Notificacion.comprobar(listaRecPretAlertasSLA, listaCasos, cola); //Comprueba si tiene que enviar alguna alerta (update picklist de casos)
                //for(Case caso: listaCasos) { System.debug('Buscando el caso 13 ' + caso.Id);}
            } 
            // if (!listaCasosSubsanaNegocia.isEmpty()) {
            //     SAC_Reclamacion.guardarUsuario(listaCasosSubsanaNegocia);
            // }
            procesado = true; 
            if(!listaConsulta.isEmpty()){
                SAC_AdministrarUsuarios.comprobarOwner(listaConsulta, mapOldObj, cola, colaSupervisores);
                //listaCaseMilestoneUpdatear.addAll(SAC_ComportamientoSLAs.finyReinicioSLAs(listaConsulta, mapOldObj));  //Añadir parada de SLA en el RT SAC_Consulta
                actualizarFechaRecepcion(listaConsulta, mapOldObj); //Actualizar Milestone a fecha recepcion proyecto SAC
                SAC_Case_BI_TRHan.asignarEntitlement(listaReclamacionesParaBalanceo);
                /*US543563 Posibilidad en consultas cops de  traspasar al gestor de una reclamación abierta.*/
               // if(!listaIdsCuentas.isEmpty()){SAC_Balanceo.asignarOwnerCaso(listaCasos, listNewCaseCambiarOwner, listaIdsCuentas);}
                if (!listaRecRepresentanteValido.isEmpty()) {
                    SAC_LCMP_RepresentanteValido.camposRepresentanteValido(listaRecRepresentanteValido, listaCasos);
                    //for(Case caso: listaCasos) { System.debug('Buscando el caso 14 ' + caso.Id);}
                    SAC_SeleccionDireccionRespuesta.setCanalRespuesta(listaRecRepresentanteValido);
                }
                if (!listaCaseAccALF.isEmpty()) {SAC_LCMP_RepresentanteValido.usarDatosDeAlf(listaCaseAccALF);}
                if(!listaContactoPostal.isEmpty()){
                    SAC_Reclamacion.informarDireccionPostar(listaContactoPostal);
                }
            } 
            if(!listaConsultaSAC.isEmpty()){
                actualizarFechaRecepcion(listaConsultaSAC, mapOldObj); //Actualizar Milestone a fecha recepcion proyecto SAC
                if (!listaRecRepresentanteValido.isEmpty()) {
                    SAC_LCMP_RepresentanteValido.camposRepresentanteValido(listaRecRepresentanteValido, listaCasos);
                    // for(Case caso: listaCasos) { System.debug('Buscando el caso 15 ' + caso.Id);}
                    SAC_SeleccionDireccionRespuesta.setCanalRespuesta(listaRecRepresentanteValido);
                }
                if (!listaCaseAccALF.isEmpty()) { SAC_LCMP_RepresentanteValido.usarDatosDeAlf(listaCaseAccALF); }
                if(!listaContactoPostal.isEmpty()){
                    SAC_Reclamacion.informarDireccionPostar(listaContactoPostal);
                }
            } 
            if(!listaReclamacionesParaBalanceo.isEmpty()){ //Este if solo se ejecuta cuando en la actualización ha habido cambio de naturaleza a consulta
                //Código referente al balanceo
                List<Case> casosSinReclamacionAnterior = SAC_Balanceo.asignarOwnerCaso(listaCasos, listaReclamacionesParaBalanceo, listaIdsCuentas); //Comprueba si hay alguna reclamacion abierta con el mismo AccountID y le asigna el mismo caseOwnerId. Devuelve una lista con los que no tienen esa coincidencia.
                SAC_Balanceo.balanceoGrupos(casosSinReclamacionAnterior, cola); //Asigna un grupo al caso siguiendo los porcentajes de asignacion de los grupos. Se le pasa por parametro la lista con los casos que no ha podido asignar el anterior metodo.
                // for(Case caso: listaCasos) { System.debug('Buscando el caso 16 ' + caso.Id);}
            } 
            if(!listaReclamacionesPretensionesOwner.isEmpty()){
               listaShareAccionesInsertar.addAll(SAC_Accion_PermisoPropietario.permisosAccionPropietario(listaReclamacionesPretensionesOwner, mapOldObj)); //Comprueba que el owner de una reclamacion/pretensión ha cambiado para asignarle permisos de edición a las acciones de la misma reclamación/pretensión y borra los pedrmisos al anterior propietario.
            }             
            if(!listaReclaPretConsul.isEmpty()){
                crearThreadId(listaReclaPretConsul);
            }
        } 

        /*if(!segundoProcesado && procesado && !listaReclamaciones.isEmpty()){
            listaCaseMilestoneUpdatear.addAll(SAC_ComportamientoSLAs.finyReinicioSLAs(listaReclamaciones, mapOldObj));
            segundoProcesado=true;
        }*/
        
        if (!listaRecPretCons.isEmpty()) {
            SAC_Pretension.datosClienteReclamacion(listaRecPretCons, mapOldObj); //Rellena el campo NIF de la reclamación con el NIF de la Account asociada
        }

        if (!listaCasosSubsanaNegocia.isEmpty()) {
            SAC_Reclamacion.guardarUsuario(listaCasosSubsanaNegocia);
        }
        
        if(!listaShareAccionesInsertar.isEmpty()){
            objetos.addAll(listaShareAccionesInsertar);
        }

        if (!listaCambioOwner.isEmpty()) {
            SAC_Notificacion.notiAntiguoPropietario(listaCambioOwner, mapOldObj, cola); //Cuando el owner cambia, notifica del cambio al antiguo owner
        }

        if(!listaRecPret.isEmpty()){
            SAC_AsignarTMEs.modificarTiemposPretension(listaRecPret, mapOldObj, listOldObj);
        }

        if (!listaCambioOwnerPretension.isEmpty()) {
            SAC_Reclamacion.modificarPermisoLetrado(listaCambioOwnerPretension, listaCasos, mapOldObj);
            //for(Case caso: listaCasos) { System.debug('Buscando el caso 17 ' + caso.Id);}
        }

        //Método para completar y reanudar SLA (CaseMilestones)
        if (!listaCambioEstado.isEmpty()) {
            listaCaseMilestoneUpdatear.addAll(SAC_ComportamientoSLAs.finyReinicioSLAs(listaCambioEstado, mapOldObj, listaCasos));
        }

        //Se añaden los case milestone a updatear a objetos
        if(!listaCaseMilestoneUpdatear.isempty()){            
            objetos.addAll(listaCaseMilestoneUpdatear);
        }

        if (!listaCasoNegociacion.isEmpty()) {
            marcarCasoNegociado(listaCasoNegociacion); //Debe ejecutarse despues del método finyReinicioSLAs
        }

        if(!listaCasosSubsanacion.isEmpty()) {
            SAC_Reclamacion.informarDetenidoDesde(listaCasosSubsanacion);
        }

        Database.upsert(objetos,false);
    }

    /*****************************************************************
     * Proposito: Método para actualizar la fecha de recepción del caso y así actualizar el inicio de la cuenta atrás del milestone
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200213         Carlos Solis   16/04/21     Creación
    *****************************************************************/
    public static void actualizarFechaRecepcion(List<Case> listNewCase, Map<Id, Case> mapOldCase) {
        for (case newCase : listNewCase) {
            if (mapOldCase.containsKey(newCase.Id) && newCase.SAC_FechaRecepcion__c != mapOldCase.get(newCase.Id).SAC_FechaRecepcion__c) {
                newCase.SlaStartDate = newCase.SAC_FechaRecepcion__c;
            }
        }
    }
     /*****************************************************************
     * Proposito: Método para actualizar las variables de procesamiento, unicamente en las clases test.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            NaN              Luis Mesa      10/06/21     Creación
    *****************************************************************/
    public static void actualizarVariablesControl(){
        if(Test.isRunningTest()){
            procesado = false;
            compruebaPretensiones = false;
        }
    }
      /*****************************************************************
     * Proposito: Método para asignar un ThreadId al caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200213      Marcela Neira   08/11/21       Creación
    *****************************************************************/

    public static void crearThreadId(List<Case> casos) {
        for (Case caso : casos) {
            String threadId;
            String casoID = caso.Id; 
            threadId = ('ref:_'+ UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + casoID + ':ref');
            caso.CC_SuppliedID__c = threadId;
        }
    }

     /*****************************************************************
     * Proposito: Cambiar el MCC cuando cambia la pretension principal y asignar el MCC de esta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200213         Carlos Solis   17/11/21     Creación
     * 1.1            US421835         Raúl y Sergio  27/09/2022   Modificación
     *****************************************************************/
    public static void actualizarMCCPretPrincipal(List<Case> listaRecCambioPretPrincipal, List<Case> listaCasos) {
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>(listaRecCambioPretPrincipal);
        for (Case casoSelect : listaCasos) {
            if (casoSelect.RecordTypeId == RECTYPEPRETENSION && String.isNotBlank(casoSelect.SAC_Reclamacion__c) && mapaReclamaciones.containsKey(casoSelect.SAC_Reclamacion__c) && casoSelect.Status != 'SAC_009') {
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).CC_MCC_Tematica__c = casoSelect.CC_MCC_Tematica__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).CC_MCC_ProdServ__c = casoSelect.CC_MCC_ProdServ__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).CC_MCC_Motivo__c   = casoSelect.CC_MCC_Motivo__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SEG_Detalle__c     = casoSelect.SEG_Detalle__c;

                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_Motivo_BDE__c = casoSelect.SAC_Motivo_BDE__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_FamiliaBdE__c = casoSelect.SAC_FamiliaBdE__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_ProductoBDE__c = casoSelect.SAC_ProductoBDE__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_FamiliaMotivoBdE__c = casoSelect.SAC_FamiliaMotivoBdE__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_DGS__c = casoSelect.SAC_DGS__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_Producto2BdE__c = casoSelect.SAC_Producto2BdE__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_MotivoReclamacion__c = casoSelect.SAC_MotivoReclamacion__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_AgrupacionesFamilias__c = casoSelect.SAC_AgrupacionesFamilias__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_ServicioInversion__c = casoSelect.SAC_ServicioInversion__c;   
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_Entidad_Afectada__c = casoSelect.SAC_Entidad_Afectada__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_EntidadProductora__c = casoSelect.SAC_EntidadProductora__c;
                mapaReclamaciones.get(casoSelect.SAC_Reclamacion__c).SAC_TAE__c = casoSelect.SAC_TAE__c;
            
        }
    }
}

    /*****************************************************************
     * Proposito: Marcar el check SAC_CasoNegociado__c cuando un caso pasa a estado negociación, con
     * el propósito de controlar el cierre y la apertura del sla regulatorio. (se debe completar el sla regulatorio cuando
     * el caso pasa a estado negociación, y no se debe volver a abrir o volver a completar cuando se sale y se vuelve a entrar en el)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US501943         CS             11/01/23     Creación
     *****************************************************************/
    public static void marcarCasoNegociado(List<Case> listaCasoNegociacion) {
        for (Case caso : listaCasoNegociacion) {
            caso.SAC_CasoNegociado__c = true;
        }
    }
}