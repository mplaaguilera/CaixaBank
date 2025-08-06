/*****************************************************************
 * Name: SPV_LCMP_InsertarEscalado
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC spv_InsertarEscalado.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US929958     Sergio Martín   30/05/24     Creación Clase
*****************************************************************/
public with sharing class SPV_LCMP_InsertarEscalado {
    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c', 'Case', 'CC_Grupo_Colaborador__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEGRUPOACCIONES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();


    /*****************************************************************
    * Proposito: Comprueba si el usuario que usa el componente es el owner de la
    * reclamación o alguna de sus pretensiones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   31/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean esPropietario(String caseId){
        Boolean esPropietario = false;
        Id idUsuario = UserInfo.getUserId();
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id = :caseId LIMIT 1];
        List<Case> listaPretensionesHijas = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :caseId];

        listaPretensionesHijas.add(reclamacion);
        if (!listaPretensionesHijas.isEmpty()) {
            for (Case caso : listaPretensionesHijas) {
                if (caso.OwnerId == idUsuario) {
                    esPropietario = true;
                }
            }
        }
        return esPropietario;
    }


    /*****************************************************************
    * Proposito: Obtener los grupos que permiten escalados
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   04/06/24        Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<CC_Grupo_Colaborador__c> recogerGruposParaEscalados(Id idCase){ 
        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        //List<CC_Grupo_Colaborador__c> gruposSinNivel3 = new List<CC_Grupo_Colaborador__c>();
        try {
            grupos = [SELECT Id, Name, SAC_DeveloperName__c, SAC_NivelGrupo__c
                                        FROM CC_Grupo_Colaborador__c
                                        WHERE SAC_PermiteEscalado__c = true AND RecordTypeId =: RECTYPEGRUPOACCIONES 
                                        // AND (SAC_NivelGrupo__c = 'SAC_Nivel2'  OR SAC_NivelGrupo__c = 'SAC_Nivel3')
                                        ORDER BY Name];             
            return grupos;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*****************************************************************
    * Proposito: Comprueba si hay algún escalado que esté abierto, para que solo permita abrir un escalado a la vez
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   31/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean hayEscaladosAbiertos(String caseId) {
        Boolean hayEscaladosAbiertos = false;
        List<SAC_Interaccion__c> listaEscalados = [SELECT Id, SAC_CasoEscalado__c, SAC_Estado__c FROM SAC_Interaccion__c 
                                                    WHERE RecordTypeId = :RECTYPEESCALADO
                                                    AND SAC_CasoEscalado__c = :caseId
                                                    AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SPV_PendienteEnviar')];

        if (!listaEscalados.isEmpty()) {
            hayEscaladosAbiertos = true;
        }
        return hayEscaladosAbiertos;
    }


    /*****************************************************************
    * Proposito: Inserta una interacción con el record type SPV_Escalado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929958     Sergio Martín   31/05/24        Creación
    * 1.1             US1276818      Álex Polo    06/06/25        Cambio de campos que se añaden al crear el escalado
    *****************************************************************/
    @AuraEnabled
    public static String insertarEscalado(String caseId, String tipoEscalado, String observacionesTipoEscalado, String propuestaLetrado, String equipoId, String motivoEscalado, String observacionesMotivoEscalado){ 
        // List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, SAC_PermiteEscalado__c, SAC_NivelGrupo__c, SAC_Email__c, SAC_Email2__c, SAC_Email3__c, SAC_DeveloperName__c 
        //             FROM CC_Grupo_Colaborador__c
        //             WHERE //SAC_DeveloperName__c = 'COPS' OR  SAC_DeveloperName__c = 'AJ' OR  SAC_DeveloperName__c = 'FORCADA' OR
        //             Id =:equipoId];
        SAC_Interaccion__c escalado = new SAC_Interaccion__c();
        if(!String.isBlank(equipoId)){

            escalado.RecordTypeId = RECTYPEESCALADO;           
            escalado.SAC_GrupoColaborador__c = equipoId;
            escalado.SAC_CasoEscalado__c = caseId;
            escalado.SAC_Estado__c = 'SPV_PendienteEnviar';
            escalado.SAC_MotivoEscalado__c = motivoEscalado;
            escalado.SPV_TipoEscalado__c = tipoEscalado;

            if(tipoEscalado == 'SPV_Otros'){
                escalado.SPV_ObservacionesTipoEscalado__c = observacionesTipoEscalado;
                escalado.SAC_Propuesta__c = propuestaLetrado;
            }
            if(motivoEscalado == 'SAC_OtrosMotivosEsc'){
                escalado.SPV_ObservacionesMotivoEscalado__c = observacionesMotivoEscalado;
            }

            try {
                SPV_DatabaseDML.insertDML(escalado, true);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }        

        return escalado.id;  
    }


    /*****************************************************************
    * Proposito: Comprobar los campos obligatorios antes de permitir escalar
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US1208220      Álex Polo     14/04/25        Creación
    *****************************************************************/
    @AuraEnabled
    public static String comprobarCamposEscalar(Id caseId){
        String camposSinRellenar = '';
        Integer numCampo = 1;
        Map<String, String> camposAniadidos = new Map<String, String>();    //Mapa para no añadir en la lista de campos pendientes 2 veces el mismo campo
        String pretensionesAllanamiento = '';
        String pretensionesDesistimiento = '';
        String pretensionesNecesitanImporteAllanamiento = '';
        String pretensionesNecesitanImporteDesistimiento = '';
        
        Boolean tieneByPass = SPV_Utils.comprobarTieneBypass();    //Para probar, si nuestro usuario tiene el customPermission byPass, no nos saltarán las validaciones

        if(tieneByPass == false){
            List<Case> listaPretensiones = [SELECT Id, Status, CaseNumber, SAC_Reclamacion__c, SAC_ResumenManual__c ,
                                            CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c, CBK_Case_Extension_Id__r.SPV_EmisionSAC__c, CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c,
                                            CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c, CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c, CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c,
                                            CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c, CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c, CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c, CBK_Case_Extension_Id__r.SPV_InformacionPrecontractual__c,
                                            CBK_Case_Extension_Id__r.SPV_ComunicacionesCambiosCondiciones__c, CBK_Case_Extension_Id__r.SPV_ComunicacionesLEC__c, CBK_Case_Extension_Id__r.SPV_JustificantesOperaciones__c,
                                            CBK_Case_Extension_Id__r.SPV_ComunicacionesOficinaCliente__c, CBK_Case_Extension_Id__r.SPV_AntecedentesCumplimientoResol__c, CBK_Case_Extension_Id__r.SPV_CumplimientoCondicionesPactadas__c,
                                            CBK_Case_Extension_Id__r.SPV_InformeOficina__c, CBK_Case_Extension_Id__r.SPV_MencionarCriterioBdE__c, CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c,
                                            CBK_Case_Extension_Id__r.SPV_Documentacion__c, CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c, CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c, CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c,
                                            CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c, CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c, CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c,
                                            CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionAllanamiento__c, CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionAllanamiento__c, CBK_Case_Extension_Id__r.SPV_NCuentaAbonoAllanamiento__c,
                                            CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c, CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c, CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c,
                                            CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c, CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c, CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionDesistimiento__c,
                                            CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionDesistimiento__c, CBK_Case_Extension_Id__r.SPV_NCuentaAbonoDesistimiento__c


                                            FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: caseId AND Status <> 'SAC_009'];
                                            
            //Almacenar qué pretensiones son de Allanamiento o Desistimiento
            for(Case pret : listaPretensiones){
                if(pret.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c == 'Allanamiento'){
                    if(String.isBlank(pretensionesAllanamiento)){
                        pretensionesAllanamiento = pretensionesAllanamiento + ' ' + pret.CaseNumber;
                    }else{
                        pretensionesAllanamiento = pretensionesAllanamiento + ', ' + pret.CaseNumber;
                    }
                }else if(pret.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c == 'Desistimiento'){
                    if(String.isBlank(pretensionesDesistimiento)){
                        pretensionesDesistimiento = pretensionesDesistimiento + ' ' + pret.CaseNumber;
                    }else{
                        pretensionesDesistimiento = pretensionesDesistimiento + ', ' + pret.CaseNumber;
                    }
                }
            }

            for(Case pretension : listaPretensiones){
                if((pretension.CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c)) && !camposAniadidos.containsKey('SPV_ResumenResolucionSAC__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Resumen resolución SAC (argumentos) ' + '\r\n';

                    camposAniadidos.put('SPV_ResumenResolucionSAC__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c)) && !camposAniadidos.containsKey('SPV_EmisionSAC__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Emisión de respuesta del SAC ' + '\r\n';
                    camposAniadidos.put('SPV_EmisionSAC__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c)) && !camposAniadidos.containsKey('SPV_ResolucionRemitidaEnPlazo__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Resolución remitida en plazo ' + '\r\n';
                    camposAniadidos.put('SPV_ResolucionRemitidaEnPlazo__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c)) && !camposAniadidos.containsKey('SPV_CongruenciaRespuestaSAC__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Congruencia de la respuesta del SAC ' + '\r\n';
                    camposAniadidos.put('SPV_CongruenciaRespuestaSAC__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c)) && !camposAniadidos.containsKey('SPV_CalidadRespuesta__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Calidad de la respuesta ' + '\r\n';
                    camposAniadidos.put('SPV_CalidadRespuesta__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c)) && !camposAniadidos.containsKey('SPV_ReclamacionMalFuncionamiento__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Reclamación D.E.C mal funcionamiento ' + '\r\n';
                    camposAniadidos.put('SPV_ReclamacionMalFuncionamiento__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c)) && !camposAniadidos.containsKey('SPV_ActuacionCumpleBdE__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- La actuación SAC cumple criterios BdE ' + '\r\n';
                    camposAniadidos.put('SPV_ActuacionCumpleBdE__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c)) && !camposAniadidos.containsKey('SPV_DisponeDocumentacion__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Dispone de documentación ' + '\r\n';
                    camposAniadidos.put('SPV_DisponeDocumentacion__c', 'Añadido');
                    numCampo++;
                }
                //Documentación Necesaria Solo obligatorio si el campo Dispone Documentación es NO:
                if((pretension.CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c)) && pretension.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c == 'No' && !camposAniadidos.containsKey('SPV_DocumentacionNecesaria__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Documentación Necesaria (Si el campo Dispone de documentación en la pretensión es "NO") ' + '\r\n';
                    camposAniadidos.put('SPV_DocumentacionNecesaria__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_InformacionPrecontractual__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_InformacionPrecontractual__c)) && !camposAniadidos.containsKey('SPV_InformacionPrecontractual__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Información precontractual ' + '\r\n';
                    camposAniadidos.put('SPV_InformacionPrecontractual__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_ComunicacionesCambiosCondiciones__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ComunicacionesCambiosCondiciones__c)) && !camposAniadidos.containsKey('SPV_ComunicacionesCambiosCondiciones__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Comunicaciones cambios de condiciones ' + '\r\n';
                    camposAniadidos.put('SPV_ComunicacionesCambiosCondiciones__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_ComunicacionesLEC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ComunicacionesLEC__c)) && !camposAniadidos.containsKey('SPV_ComunicacionesLEC__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Comunicaciones con liquidaciones, extractos, recibos ' + '\r\n';
                    camposAniadidos.put('SPV_ComunicacionesLEC__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_JustificantesOperaciones__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_JustificantesOperaciones__c)) && !camposAniadidos.containsKey('SPV_JustificantesOperaciones__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Justificantes de operaciones ' + '\r\n';
                    camposAniadidos.put('SPV_JustificantesOperaciones__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_ComunicacionesOficinaCliente__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ComunicacionesOficinaCliente__c)) && !camposAniadidos.containsKey('SPV_ComunicacionesOficinaCliente__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Comunicaciones entre oficina y cliente ' + '\r\n';
                    camposAniadidos.put('SPV_ComunicacionesOficinaCliente__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_AntecedentesCumplimientoResol__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AntecedentesCumplimientoResol__c)) && !camposAniadidos.containsKey('SPV_AntecedentesCumplimientoResol__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Antecedentes y cumplimiento de resoluciones ' + '\r\n';
                    camposAniadidos.put('SPV_AntecedentesCumplimientoResol__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_CumplimientoCondicionesPactadas__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_CumplimientoCondicionesPactadas__c)) && !camposAniadidos.containsKey('SPV_CumplimientoCondicionesPactadas__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Cumplimiento condiciones pactadas ' + '\r\n';
                    camposAniadidos.put('SPV_CumplimientoCondicionesPactadas__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_InformeOficina__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_InformeOficina__c)) && !camposAniadidos.containsKey('SPV_InformeOficina__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Informe de la oficina ' + '\r\n';
                    camposAniadidos.put('SPV_InformeOficina__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_MencionarCriterioBdE__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_MencionarCriterioBdE__c)) && !camposAniadidos.containsKey('SPV_MencionarCriterioBdE__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Mencionar el criterio BdE ' + '\r\n';
                    camposAniadidos.put('SPV_MencionarCriterioBdE__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c)) && !camposAniadidos.containsKey('SPV_DecisionPretensionLetrado__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Decisión de pretensión Análisis Letrado ' + '\r\n';
                    camposAniadidos.put('SPV_DecisionPretensionLetrado__c', 'Añadido');
                    numCampo++;
                }
                if((pretension.CBK_Case_Extension_Id__r.SPV_Documentacion__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_Documentacion__c)) && !camposAniadidos.containsKey('SPV_Documentacion__c')){
                    camposSinRellenar = camposSinRellenar + numCampo + '- Documentación ' + '\r\n';
                    camposAniadidos.put('SPV_Documentacion__c', 'Añadido');
                    numCampo++;
                }
            }

            if(!String.isBlank(camposSinRellenar)){
                camposSinRellenar = 'Para poder escalar, se deben informar los siguientes campos en todas las pretensiones que sea necesario: ' + '\r\n' + camposSinRellenar;
            }

            //Se añade en otro bucle for porque se necesita que se compruebe después de haber comprobado lo anterior para cada pretensión
            for(Case pretension : listaPretensiones){
                //Obligatorios solo si Decisión de pretensión letrado = Allanamiento
                if(pretension.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c == 'Allanamiento'){

                    if(!camposAniadidos.containsKey('MensajeAllanamiento') && (String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c) || 
                    String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c) || (pretension.CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c == null && (pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c == 'SPV_Pago' || pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c == 'SPV_PagoTarea')) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c) ||
                    String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionAllanamiento__c) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionAllanamiento__c) || pretension.CBK_Case_Extension_Id__r.SPV_NCuentaAbonoAllanamiento__c == null)){
                        camposAniadidos.put('MensajeAllanamiento', 'Añadido');
                        camposSinRellenar = camposSinRellenar + '\r\n' + 'Para las pretensiones: ' + pretensionesAllanamiento +  ', es necesario informar los siguientes campos de allanamiento: ' + '\r\n';
                    }

                    if((pretension.CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_TipoAllanamiento__c)) && !camposAniadidos.containsKey('SPV_TipoAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Tipo Allanamiento ' + '\r\n';
                        camposAniadidos.put('SPV_TipoAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c)) && !camposAniadidos.containsKey('SPV_MotivoAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Motivo de Allanamiento ' + '\r\n';
                        camposAniadidos.put('SPV_MotivoAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c)) && !camposAniadidos.containsKey('SPV_AnalisisAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Análisis Allanamiento ' + '\r\n';
                        camposAniadidos.put('SPV_AnalisisAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c)) && !camposAniadidos.containsKey('SPV_TipoActuacionAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Tipo actuación ' + '\r\n';
                        camposAniadidos.put('SPV_TipoActuacionAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    //Obligatorio si tipo actuación = Pago || Pago + Tarea
                    if((pretension.CBK_Case_Extension_Id__r.SPV_ImporteAllanamientoPropuesto__c == null) && (pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c == 'SPV_Pago' || pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionAllanamiento__c == 'SPV_PagoTarea') /*&& !camposAniadidos.containsKey('SPV_ImporteAllanamientoPropuesto__c')*/){
                        //camposSinRellenar = camposSinRellenar + numCampo + '- Importe Allanamiento Propuesto ' + '\r\n';
                        //camposAniadidos.put('SPV_ImporteAllanamientoPropuesto__c', 'Añadido');
                        //numCampo++;
                        if(String.isBlank(pretensionesNecesitanImporteAllanamiento)){
                            pretensionesNecesitanImporteAllanamiento = pretensionesNecesitanImporteAllanamiento + ' ' + pretension.CaseNumber;
                        }else{
                            pretensionesNecesitanImporteAllanamiento = pretensionesNecesitanImporteAllanamiento + ', ' + pretension.CaseNumber;
                        }
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ImputableAllanamiento__c)) && !camposAniadidos.containsKey('SPV_ImputableAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Imputable Allanamiento ' + '\r\n';
                        camposAniadidos.put('SPV_ImputableAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionAllanamiento__c)) && !camposAniadidos.containsKey('SPV_InstruccionesEjecucionAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Instrucciones de ejecución ' + '\r\n';
                        camposAniadidos.put('SPV_InstruccionesEjecucionAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionAllanamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionAllanamiento__c)) && !camposAniadidos.containsKey('SPV_AcreditacionEjecucionAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Acreditación de la ejecución ' + '\r\n';
                        camposAniadidos.put('SPV_AcreditacionEjecucionAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_NCuentaAbonoAllanamiento__c == null) && !camposAniadidos.containsKey('SPV_NCuentaAbonoAllanamiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Nº Cuenta abono allanamiento ' + '\r\n';
                        camposAniadidos.put('SPV_NCuentaAbonoAllanamiento__c', 'Añadido');
                        numCampo++;
                    }
                }
            }

            if(!String.isBlank(pretensionesNecesitanImporteAllanamiento)){
                camposSinRellenar = camposSinRellenar + numCampo + '- Se debe informar el Importe Allanamiento propuesto en las pretensiones: ' + pretensionesNecesitanImporteAllanamiento + '\r\n';
                numCampo++;
            }

            for(Case pretension : listaPretensiones){
                //Obligatorios solo si Decisión de pretensión letrado = Desistimiento
                if(pretension.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c == 'Desistimiento'){

                    if(!camposAniadidos.containsKey('MensajeDesistimiento') && (String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c) || 
                    String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c) || (pretension.CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c == null && (pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c == 'SPV_Pago' || pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c == 'SPV_PagoTarea')) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c) ||
                    String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionDesistimiento__c) || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionDesistimiento__c) || pretension.CBK_Case_Extension_Id__r.SPV_NCuentaAbonoDesistimiento__c == null)){
                        camposAniadidos.put('MensajeDesistimiento', 'Añadido');
                        camposSinRellenar = camposSinRellenar + '\r\n' + 'Para las pretensiones: ' + pretensionesDesistimiento +  ', es necesario informar los siguientes campos de desistimiento: ' + '\r\n';
                    }

                    if((pretension.CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c)) && !camposAniadidos.containsKey('SPV_MotivoDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Motivo de Desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_MotivoDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c)) && !camposAniadidos.containsKey('SPV_AnalisisDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Análisis Desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_AnalisisDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c)) && !camposAniadidos.containsKey('SPV_TipoActuacionDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Tipo actuación desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_TipoActuacionDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                    //Obligatorio si tipo actuación = Pago || Pago + Tarea
                    if((pretension.CBK_Case_Extension_Id__r.SPV_ImporteDesistimientoPropuesto__c == null) && (pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c == 'SPV_Pago' || pretension.CBK_Case_Extension_Id__r.SPV_TipoActuacionDesistimiento__c == 'SPV_PagoTarea') && !camposAniadidos.containsKey('SPV_ImporteDesistimientoPropuesto__c')){
                        /*camposSinRellenar = camposSinRellenar + numCampo + '- Importe desistimiento propuesto ' + '\r\n';
                        camposAniadidos.put('SPV_ImporteDesistimientoPropuesto__c', 'Añadido');
                        numCampo++;*/
                        if(String.isBlank(pretensionesNecesitanImporteDesistimiento)){
                            pretensionesNecesitanImporteDesistimiento = pretensionesNecesitanImporteDesistimiento + ' ' + pretension.CaseNumber;
                        }else{
                            pretensionesNecesitanImporteDesistimiento = pretensionesNecesitanImporteDesistimiento + ', ' + pretension.CaseNumber;
                        }
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ImputableDesistimiento__c)) && !camposAniadidos.containsKey('SPV_ImputableDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Imputable desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_ImputableDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionDesistimiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_InstruccionesEjecucionDesistimiento__c)) && !camposAniadidos.containsKey('SPV_InstruccionesEjecucionDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Instrucciones de ejecución desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_InstruccionesEjecucionDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionDesistimiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_AcreditacionEjecucionDesistimiento__c)) && !camposAniadidos.containsKey('SPV_AcreditacionEjecucionDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Acreditación de ejecución desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_AcreditacionEjecucionDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                    if((pretension.CBK_Case_Extension_Id__r.SPV_NCuentaAbonoDesistimiento__c == null) && !camposAniadidos.containsKey('SPV_NCuentaAbonoDesistimiento__c')){
                        camposSinRellenar = camposSinRellenar + numCampo + '- Nº Cuenta abono desistimiento ' + '\r\n';
                        camposAniadidos.put('SPV_NCuentaAbonoDesistimiento__c', 'Añadido');
                        numCampo++;
                    }
                }
            }

            if(!String.isBlank(pretensionesNecesitanImporteDesistimiento)){
                camposSinRellenar = camposSinRellenar + numCampo + '- Se debe informar el Importe Desistimiento Propuesto en las pretensiones: ' + pretensionesNecesitanImporteDesistimiento + '\r\n';
                numCampo++;
            }

        }
        return camposSinRellenar;
    }


}