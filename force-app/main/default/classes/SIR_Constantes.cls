/*****************************************************************
 Name:  SIR_Constantes
 Copyright © 2021  CaixaBank
  
Proposito:   Clase Constantes                                                                                                                 
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US Id            Atmira         21/06/2021     	  Created    

*****************************************************************/
public with sharing class SIR_Constantes {

    //////// PROFILE //////// PROFILE //////// PROFILE //////// PROFILE //////// PROFILE //////// PROFILE //////// PROFILE //////// PROFILE //////// PROFILE ////////
    public static final String GESTOR_PROFILE_NAME = 'AV_Usuario_CaixaBank';
    public static final String GESTOR_PROFILE_NAME_EMP = 'CIBE_Gestor';
    public static final String SSMM_PROFILE_NAME = 'API Only';
    //////// ROL //////// ROL //////// ROL //////// ROL //////// ROL
    public static final String GESTOR_ROL_NAME = 'AV_SistematicaComercial';
    public static final String GESTOR_ROL_NAME_EMP = 'CIBE_CIBEmpresas';
    //////// PS //////// PS //////// PS //////// PS //////// PS //////// PS //////// PS //////// PS //////// PS //////// PS 
    public static final String PS_SSMM_NAME = 'SIR_PS_SSMM';
    public static final String PS_GESTOR_NAME = 'SIR_gestorSolutions';
    public static final String PS_GROUP_AV_GESTOR_NAME = 'AV_Gestor';
    //Mis clientes cambiará el PSGroup, en futuras IOP cambiaremos el nombre de la constante y las clases donde se utiliza
    //public static final String PS_GROUP_AV_LECTURA_ANALYTICS = 'AV_Lectura_y_Analytics';
    public static final String PS_GROUP_AV_LECTURA_ANALYTICS = 'AV_Externo';
    public static final String PS_GROUP_AV_EXTERNO = 'AV_Externo';
    public static final String PS_VISIBILIDAD_EMP = 'SIRE_VisibilidadMisClientesSolutions';
    public static final String PS_GESTOR_NAME_EMP = 'SIRE_gestorSolutions';


    //////// CUSTOM PERMISSION //////// CUSTOM PERMISSION //////// CUSTOM PERMISSION //////// CUSTOM PERMISSION //////// CUSTOM PERMISSION //////// CUSTOM PERMISSION 
    public static final String CUSTOM_PERMISSION_MIS_CLIENTES_SOLUCIONES = 'SIR_MisClientesSolutions';


    ///////// WS NAMES ///////// WS NAMES ///////// WS NAMES ///////// WS NAMES ///////// WS NAMES ///////// WS NAMES ///////// WS NAMES ///////// WS NAMES /////////
    public static final String NOMBRE;


    ///////// STRING ///////// STRING ///////// STRING ///////// STRING ///////// STRING ///////// STRING ///////// STRING ///////// STRING ///////// STRING ///////// 
    public final String STRING_MAYUS_S 		 = 'S';
    public final String STRING_MAYUS_N 		 = 'N';
    public final String STRING_TEST   		 = 'TEST';
    public final String STRING_0	   		 = '0';
	public final String STRING_100	   		 = '100';
    public final String STRING_EURO	   		 = ' €';
    public final String STRING_COMILLA_00	 = ',00 €';
    public final String STRING_0_COMA_00	 = '0,00 €';
    public final String STRING_COMA	   		 = ',';
    public final String STRING_NUMBER 		 = 'number';
    public final String STRING_EXPRE_REGU	 = '###,###,##0.00';
    public final String STRING_00001	     = '00001';
    public final String STRING_1    	     = '1';
    public final set<string> GARANTIAREAL          = new Set<String>{'2', '3','4'};
    public final set<string> TIPOPRODUCTOS       = new Set<String>{'PRS', 'CRV','CCR','DOC','CDO','RME','CRO'};
    public final set<string> TIPOPRODUCTOSTARJEAS = new Set<String>{'TCR', 'TCT'};
    public final set<string> TODOSTIPOPRODUCTOS   = new Set<String>{'PRS', 'CRV','CCR','DOC','CDO','RME','CRO','TCR', 'TCT'};
    public static final String TIPOPROCESO_GESTION1_90= 'Impagados 1-90';
    public static final String TIPOPROCESO_PRESOL= 'PRESOL-Preventivo';
    public static final String TIPOPROCESO_FLUJO= 'Flujo';
    public static final String TIPOPROCESO_PREVENTIVO= 'Preventivo';
    public static final String TIPO_TGA= 'Tec. Ges. Act.';
    public static final String TIPO_ANALISTA_RIESGOS = 'Riesgo Emp.';    
    public static final String CIBE_ANALISTA_DE_RIESGO = 'ANALISTA DE RIESGO';
    public static final String CIBE_ANALISTA_SENIOR_DE_RIESGO = 'ANALISTA SENIOR DE RIESGO';
    public static final String DATO_PERSONA= 'PERSONA';
    public static final String DATO_CONTACTADA= 'CONTACTADA';


    ///////// INTEGER ///////// INTEGER ///////// INTEGER ///////// INTEGER ///////// INTEGER ///////// INTEGER ///////// INTEGER ///////// INTEGER ///////// INTEGER 
    public final INTEGER INTEGER_1			= 1;


    //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// ACCION //////// 
    // ACCION RECORDTYPE
    public static final String ACCION_RECORDTYPE_NAME_AMISTOSO = 'Acción Amistoso';
    public static final String ACCION_RECORDTYPE_NAME_AMISTOSO_WORKFLOW = 'Amistoso Workflow';
    public static final String ACCION_RECORDTYPE_NAME_PRESOL = 'Acción Preventivo';
    public static final String ACCION_RECORDTYPE_NAME_AMISTOSO_EMPRESA = 'Acción Amistoso Empresa';

    public static final String ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_WORKFLOW = 'SIREC_rt_accion_amistoso_workflow';
    public static final String ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL = 'SIREC_rt_accion_preventivo'; 
    public static final String ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO = 'SIREC_rt_accion';
    public static final String ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_EMPRESA = 'SIRE_rt_accionesAmistosoEmpresa';
    

    // ACCION CAMPO RESULTADO
    public static final String ACCION_RESULTADO_NO_LOCALIZADO = '15';
    public static final String ACCION_RESULTADO_RECOBRO = '16';
    public static final String ACCION_RESULTADO_COMPROMISO_DE_PAGO = '17';
    public static final String ACCION_RESULTADO_REPLANIFICAR_CONTACTO = '18';
    public static final String ACCION_RESULTADO_NO_COLABORA = '19';
    public static final String ACCION_RESULTADO_REFINANCIACION = '20';
    public static final String ACCION_RESULTADO_SOLUCION_ESTRUCTURAL = '21';
    public static final String ACCION_RESULTADO_NO_COLABORA_CON_ACUERDO_INCUMPLIDO = '24';
    public static final String ACCION_RESULTADO_COMPROMISO_PAGO_INCUMPLIDO = '25';
    public static final String ACCION_RESULTADO_ILOCALIZADO = '26';
    public static final String ACCION_RESULTADO_CON_ACUSE_DE_RECIBO = '22';
    public static final String ACCION_RESULTADO_SIN_ACUSE_DE_RECIBO = '23';
    public static final String ACCION_RESULTADO_INTENTO_DE_CONTACTO = '27';
    // ACCION CAMPO RESULTADO PRESOL
    public static final String ACCION_RESULTADO_NO_DETECT_SOLUCION_VIABLE = '38';
    public static final String ACCION_RESULTADO_NO_IDENTIFICA_DEBILIDAD = '39';
    public static final String ACCION_RESULTADO_SOLUCION_ACUERDO_PAGO = '34';
    public static final String ACCION_RESULTADO_SOLUCION_AMPLI_PLAZO_CARENCIA = '35';
    public static final String ACCION_RESULTADO_SOLUCION_REFINAN_REESTRUCT = '37';
    public static final String ACCION_RESULTADO_SOLUCION_ESTRUCTURAL_24M = '36';
    public static final String ACCION_RESULTADO_SOLUCION_ANALISIS_REALIZADO_EXCLUIDO = '31';
    public static final String ACCION_RESULTADO_SOLUCION_ANALISIS_NO_REALIZADO = '32';
    public static final String ACCION_RESULTADO_SOLUCION_ANALISIS_REALIZADO_NO_EXCLUIDO = '33';    
    public static final String ACCION_RESULTADO_SOLUCION_REFINANCIACION_REESTRUCTURACION = '42';
    public static final String ACCION_RESULTADO_SOLUCION_ESTRUCTURAL_VENTA_DACION = '43';
    public static final String ACCION_RESULTADO_NO_SOLUCION_NO_COLABORA = '44';
    public static final String ACCION_RESULTADO_SEGUIRA_PAGANDO = '45';

	
    // ACCION CAMPO TIPO
    public static final String ACCION_TIPO_LLAMADA_EMITIDA = '01';
    public static final String ACCION_TIPO_LLAMADA_RECIBIDA = '02';
    public static final String ACCION_TIPO_SMS_ENVIADO = '13';
    public static final String ACCION_TIPO_BUROFAX_ENVIADO = '03';
    public static final String ACCION_TIPO_EMAIL_ENVIADO = '04';
    public static final String ACCION_TIPO_EMAIL_RECIBIDO = '05';
    public static final String ACCION_TIPO_VIDEOLLAMADA_EMITIDA = '06';
    public static final String ACCION_TIPO_VIDEOLLAMADA_RECIBIDA = '07';
    public static final String ACCION_TIPO_EMITIDA = '08';
    public static final String ACCION_TIPO_RECIBIDA = '09';
    public static final String ACCION_TIPO_CASA_DEL_CLIENTE = '10';
    public static final String ACCION_TIPO_PETICION_OFICINA = '11';
    public static final String ACCION_TIPO_VOLUNTAD_CLIENTE = '12';
    
    // ACCION CAMPO ESTADO
    public static final String ACCION_ESTADO_EN_CURSO = 'En curso';
    public static final String ACCION_ESTADO_FINALIZADA = 'Finalizada';
    public static final String ACCION_ESTADO_PENDIENTE = 'Pendiente Sincronización';
    public static final String ACCION_ESTADO_ENVIADA = 'Enviada';
    public static final String ACCION_ESTADO_BORRAR = 'Borrar';
   
    //////// PROCESO //////// PROCESO //////// PROCESO //////// PROCESO //////// PROCESO //////// PROCESO //////// PROCESO //////// PROCESO //////// PROCESO ////////
    public static final String PROCESO_OBJECT_API_NAME = 'SIREC__SIREC_obj_proceso__c';
    // PROCESO RECORDTYPE
    public static final String PROCESO_RECORDTYPE_NAME_AMISTOSO = 'Proceso Amistoso';
    public static final String PROCESO_RECORDTYPE_NAME_PRESOL = 'PRESOL';
    public static final String PROCESO_RECORDTYPE_NAME_EMP_FLUJO = 'Flujo';
    public static final String PROCESO_RECORDTYPE_NAME_EMP_PREVENTIVO = 'Preventivo';
    public static final String PROCESO_RECORDTYPE_NAME_EMP_AP_PP = 'Acuerdo Pago - Plan Pago';

    public static final String PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL = 'SIREC_rt_Anticipacion';
    public static final String PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA = 'SIREC_rt_procesoAmistoso';
    public static final String PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO = 'SIRE_RT_Amistoso';
    public static final String PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP = 'SIRE_RT_PREVEMP';
    public static final String PROCESO_RECORDTYPE_DEVELOPER_NAME_AP_PP = 'SIRE_RT_AP_PP';

    // PROCESO
    public static final String PROCESO_CODIGO_PRESOL_WORKFLOW = 'PDM-PRESOLW';    
    public static final String PROCESO_CODIGO_FLUJO_WORKFLOW = 'PDM-FLUEMP';    
    public static final String PROCESO_OBJETIVO_INFORMATIVO = 'SIN GESTION';
    
    // PROCESO CAMPO SITUACION IMPA
    public static final String PROCESO_SITUACION_COMPROMISO_DE_PAGO = 'SF_COMPPAGO';
    public static final String PROCESO_SITUACION_ILOCALIZADO = 'SF_ILOCALI';
    public static final String PROCESO_SITUACION_NO_LOCALIZADO = 'SF_NOLOCALI';
    public static final String PROCESO_SITUACION_NO_RECOBRO = 'SF_NORECOBRO';
    public static final String PROCESO_SITUACION_RECOBRO = 'SF_RECOBRO';
    public static final String PROCESO_SITUACION_REFINANCIACION = 'SF_REFINA';
    public static final String PROCESO_SITUACION_REPLANIFICAR_CONTACTO = 'SF_REPLANCNT';
    public static final String PROCESO_SITUACION_PENDIENTE_INICIO_GESTION = 'SF_INIGEST';
    public static final String PROCESO_SITUACION_FINALIZADO = 'SF_FINALIZ';
    public static final String PROCESO_SITUACION_EN_CURSO_REFINANCIACION = 'SF_CURSOREFI';
    public static final String PROCESO_SITUACION_SOLUCION_ESTRUCTURAL = 'SF_SOLESTR';
    public static final String PROCESO_SITUACION_NO_COLABORA_CON_ACUERDO_INCUMPLIDO = 'SF_NOCOLINC';
    public static final String PROCESO_SITUACION_COMPROMISO_PAGO_INCUMPLIDO = 'SF_COMPAGINC';   
    // PROCESO CAMPO SITUACION PRESOL
    public static final String PROCESO_SITUACION_ANALISIS_PREVIO = 'SF_ANALISPRE';
    public static final String PROCESO_SITUACION_EXCLUIDO = 'SF_EXCLUID';
    public static final String PROCESO_SITUACION_NO_SOL_VIABLE = 'SF_SOLVIABLE';
    public static final String PROCESO_SITUACION_CLI_NO_COLABORA = 'SF_CLINOCLB';
    public static final String PROCESO_SITUACION_CLI_NO_LOCALIZADO = 'SF_CLINOLOC';
    public static final String PROCESO_SITUACION_NO_DEBILIDAD = 'SF_NODEBILID';
    public static final String PROCESO_SITUACION_SOL_ACUERDO_PAGO = 'SF_SOLACUPAG';
    public static final String PROCESO_SITUACION_SOL_AMPLI_CARENCIA = 'SF_AMPLICARE';
    public static final String PROCESO_SITUACION_SOL_REFINAN = 'SF_SOLREFRES';
    public static final String PROCESO_SITUACION_SOL_ESTRUCTURAL = 'SF_SOLESTRUC';
    public static final String PROCESO_SITUACION_PTE_CONTACTAR = 'SF_PTECONTAC';
    public static final String PROCESO_SITUACION_NO_COLABORA = 'SF_NOSNOC';
    public static final String PROCESO_SITUACION_SEGUIRA_PAGANDO = 'SF_SEGPAG';
    public static final String PROCESO_SITUACION_REFINANCIACION_REESTRUCTURACION = 'SF_REFREE';
    public static final String PROCESO_SITUACION_ESTRUCTURAL_VENTA_DACION = 'SF_SOLESTVD';

    // PROCESO CAMPO SITUACION FLUJO
    public static final String PROCESO_SITUACION_SIRE_ACUERDO_PAGO_PENDIENTE = 'FEACPP';
    public static final String PROCESO_SITUACION_SIRE_PENDIENTE_CONTACTACION = 'FEPECO';
    public static final String PROCESO_SITUACION_SIRE_REGULARIZADO = 'FEREGU';
    public static final String PROCESO_SITUACION_SIRE_RECOBRO_INCUMPLIDO = 'FEREIN';
    public static final String PROCESO_SITUACION_SIRE_RECOBRO_PENDIENTE = 'FEPERE';
    public static final String PROCESO_SITUACION_SIRE_NO_COLABORA = 'FENOCO';
    public static final String PROCESO_SITUACION_SIRE_PENDIENTE_INICIO_GESTION = 'FEPEIN';
    public static final String PROCESO_SITUACION_SIRE_PLAN_PAGOS_PENDIENTES= 'FEPPPE';
    public static final String PROCESO_SITUACION_SIRE_ACUERDO_PAGO_INCUMPLIDO = 'FEAPIN';   
    public static final String PROCESO_SITUACION_SIRE_NO_LOCALIZADO = 'FENOLO';
    public static final String PROCESO_SITUACION_SIRE_ILOCALIZADO = 'FEILOC';
    public static final String PROCESO_SITUACION_SIRE_PLAN_PAGOS_INCUMPLIDOS = 'FEPPIN';
    public static final String PROCESO_SITUACION_SIRE_REFINANCIACION = 'FEPPRF';
    public static final String PROCESO_SITUACION_SIRE_PROPUESTO_PASO_STOCK = 'FEPPST';
    public static final String PROCESO_SITUACION_SIRE_PROPUESTA_REFINANCIACION = 'FEPRRE';
    public static final String PROCESO_SITUACION_SIRE_REPLANIFICAR_CONTACTO = 'FERPCT';
    public static final String PROCESO_SITUACION_SIRE_SOLUCION_ESTRUCTURAL = 'FESOES';
    // PROCESO CAMPO SITUACION PREVEMP
    public static final String PROCESO_SITUACION_NO_REQUIERE_ACCION_PREVENTIVA = 'SF_PVNRAP';
    public static final String PROCESO_SITUACION_CON_ACCION_PREVENTIVA = 'SF_PVCAPR';
    public static final String PROCESO_SITUACION_ACCION_RESTRICTIVA_PENDIENTE = 'SF_PVCAP4';
    public static final String PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA = 'SF_PVACAP';

    // PROCESO NAME
    public static final String PROCESO_NAME_REFINANCIACION = 'Proceso de Refinanciación';
    public static final String PROCESO_NAME_REPLANIFICAR_CONTACTO = 'Replanificar Contacto';

    // PROCESO CAMPO ESTRATEGIAS IMPA
    public static final String PROCESO_ESTRATEGIA_E1 = '10001';
    public static final String PROCESO_ESTRATEGIA_E2 = '10002';
    public static final String PROCESO_ESTRATEGIA_E3 = '10003';
    public static final String PROCESO_ESTRATEGIA_E4 = '10004';
    public static final String PROCESO_ESTRATEGIA_E5 = '10005';
    public static final String PROCESO_ESTRATEGIA_E6 = '10006';
    public static final String PROCESO_ESTRATEGIA_E0 = '10000';
    public static final String PROCESO_ESTRATEGIA_E7 = '10007';
    // PROCESO CAMPO ESTRATEGIAS IMPA TO BE
    public static final String PROCESO_ESTRATEGIA_E0_OFI = '30014';
    public static final String PROCESO_ESTRATEGIA_E1_OFI = '30016';
    public static final String PROCESO_ESTRATEGIA_E2_OFI = '30017';
    public static final String PROCESO_ESTRATEGIA_E3_OFI = '30018';
    public static final String PROCESO_ESTRATEGIA_E4_OFI = '30019';
    public static final String PROCESO_ESTRATEGIA_E5_OFI = '30071';
    public static final String PROCESO_ESTRATEGIA_E6_OFI = '30020';
    // PROCESO CAMPO ESTRATEGIAS PRESOL
    public static final String PROCESO_ESTRATEGIA_PRESOL_E1 = '20001';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E2 = '20002';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E3 = '20003';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E4 = '20004';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E5 = '20005';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E6 = '20006';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E7 = '20007';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E8 = '20008';
    public static final String PROCESO_ESTRATEGIA_PRESOL_E9 = '20009';    

    // PROCESO CAMPO AGRUPACION SITUACIONES 
    public static final String PROCESO_PENDIENTE = 'Pendiente';
    public static final String PROCESO_EN_GESTION = 'En Gestión';
    public static final String PROCESO_GESTIONADO = 'Gestionado';
    public static final String PROCESO_FINALIZADO = 'Finalizado';    

    // PROCESO MAPA SITUACIONES IMPA
    public static final Map<String,String> MAPSITUACIONESIMPA = new Map<String,String>{
                                                    ACCION_RESULTADO_NO_LOCALIZADO => PROCESO_SITUACION_NO_LOCALIZADO,
                                                    ACCION_RESULTADO_ILOCALIZADO => PROCESO_SITUACION_ILOCALIZADO,
                                                    ACCION_RESULTADO_RECOBRO => PROCESO_SITUACION_RECOBRO,
                                                    ACCION_RESULTADO_COMPROMISO_DE_PAGO => PROCESO_SITUACION_COMPROMISO_DE_PAGO,
                                                    ACCION_RESULTADO_REPLANIFICAR_CONTACTO => PROCESO_SITUACION_REPLANIFICAR_CONTACTO,
                                                    ACCION_RESULTADO_NO_COLABORA => PROCESO_SITUACION_NO_RECOBRO,
                                                    ACCION_RESULTADO_REFINANCIACION => PROCESO_SITUACION_REFINANCIACION,
                                                    ACCION_RESULTADO_SOLUCION_ESTRUCTURAL => PROCESO_SITUACION_SOLUCION_ESTRUCTURAL,
                                                    ACCION_RESULTADO_NO_COLABORA_CON_ACUERDO_INCUMPLIDO => PROCESO_SITUACION_NO_COLABORA_CON_ACUERDO_INCUMPLIDO,
                                                    ACCION_RESULTADO_COMPROMISO_PAGO_INCUMPLIDO => PROCESO_SITUACION_COMPROMISO_PAGO_INCUMPLIDO,
                                                    ACCION_RESULTADO_CON_ACUSE_DE_RECIBO => PROCESO_SITUACION_REPLANIFICAR_CONTACTO,
                                                    ACCION_RESULTADO_SIN_ACUSE_DE_RECIBO => PROCESO_SITUACION_NO_LOCALIZADO
    };
    // PROCESO MAPA SITUACIONES PRESOL
    public static final Map<String,String> MAPSITUACIONESPRESOL = new Map<String,String>{
                                                    ACCION_RESULTADO_ILOCALIZADO => PROCESO_SITUACION_ILOCALIZADO,                                            
                                                    ACCION_RESULTADO_NO_LOCALIZADO => PROCESO_SITUACION_CLI_NO_LOCALIZADO,
                                                    ACCION_RESULTADO_NO_COLABORA => PROCESO_SITUACION_CLI_NO_COLABORA,
                                                    ACCION_RESULTADO_REPLANIFICAR_CONTACTO => PROCESO_SITUACION_REPLANIFICAR_CONTACTO,
                                                    ACCION_RESULTADO_SOLUCION_ANALISIS_REALIZADO_EXCLUIDO => PROCESO_SITUACION_EXCLUIDO,
                                                    ACCION_RESULTADO_SOLUCION_ANALISIS_NO_REALIZADO => PROCESO_SITUACION_PENDIENTE_INICIO_GESTION,
                                                    ACCION_RESULTADO_SOLUCION_ANALISIS_REALIZADO_NO_EXCLUIDO => PROCESO_SITUACION_ANALISIS_PREVIO,
                                                    ACCION_RESULTADO_NO_DETECT_SOLUCION_VIABLE => PROCESO_SITUACION_NO_SOL_VIABLE,
                                                    ACCION_RESULTADO_NO_IDENTIFICA_DEBILIDAD => PROCESO_SITUACION_NO_DEBILIDAD,
                                                    ACCION_RESULTADO_SOLUCION_ACUERDO_PAGO => PROCESO_SITUACION_SOL_ACUERDO_PAGO,
                                                    ACCION_RESULTADO_SOLUCION_AMPLI_PLAZO_CARENCIA => PROCESO_SITUACION_SOL_AMPLI_CARENCIA,
                                                    ACCION_RESULTADO_SOLUCION_REFINAN_REESTRUCT => PROCESO_SITUACION_SOL_REFINAN,
                                                    ACCION_RESULTADO_SOLUCION_ESTRUCTURAL_24m => PROCESO_SITUACION_SOL_ESTRUCTURAL
                                                };

    // PROCESO OTRAS VARIABLES
    public static final String PROCESO_ESTRATEGIA_E0_NAME = 'Proceso Autocura';
    public static final String PROCESO_ESTRATEGIA_E7_NAME = 'Proceso Pequeño Importe';

    //CODIGOS DE MODULO EN PROCESOS
    public static final String CODIGO_MODULO_PRESOL = 'PRESOL';
    public static final String CODIGO_MODULO_FLUJO = 'FLUJO EMPRESAS';
    
    /////// NEGOCIO //////// NEGOCIO ////////
	public static final String NEGOCIO_IMPA ='IMPA';
	public static final String NEGOCIO_PRESOL ='PRESOL';
	public static final String NEGOCIO_FLUJO ='FLUJO';
	public static final String NEGOCIO_PREVENTIVO ='PREVENTIVO';

	// MAPA DE LOS NEGOCIOS Y SUS RT DE PROCESOS 
	public static final Map<String,String> MAPA_NEGOCIO_RT = new Map<String,String>{
                    NEGOCIO_IMPA => PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA,
                    NEGOCIO_PRESOL => PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL,
                    NEGOCIO_FLUJO => PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO,
                    NEGOCIO_PREVENTIVO => PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP
	};
    
	// LISTA DE LOS NEGOCIOS   
	public static final List<String> LIST_NEGOCIO = new List<String>{NEGOCIO_IMPA,NEGOCIO_PRESOL,NEGOCIO_FLUJO,NEGOCIO_PREVENTIVO};

    //CODIGOS DE TIPO DE GESTION PREVEMP
    public static final String GESTION_NEGOCIO = '1';
    public static final String GESTION_NEGOCIO_RIESGOS = '2';
    public static final String GESTION_RIESGOS = '3';
    
    //CODIGOS DE EMPLEADO GESTION
    public static final String EMPLEADO_GESTION_NEGOCIO = 'NEGOCIO';
    public static final String EMPLEADO_GESTION_RIESGOS = 'RIESGOS';
    
    //////// PROCESO-CONTRATO //////// PROCESO-CONTRATO //////// PROCESO-CONTRATO //////// PROCESO-CONTRATO //////// PROCESO-CONTRATO //////// PROCESO-CONTRATO ////////
    public static final String PROCESOCONTRATO_RECORDTYPE_NAME_PROCESO_CONTRATOS = 'Procesos Contratos';


    //////// PERSONA-ASOCIADA //////// PERSONA-ASOCIADA //////// PERSONA-ASOCIADA //////// PERSONA-ASOCIADA //////// PERSONA-ASOCIADA //////// PERSONA-ASOCIADA ////////
    public static final String PERSONAASOCIADA_RECORDTYPE_NAME_PERSONA_ASOCIADA = 'Persona Asociada';


    //////// INTERVINIENTE-FORMULARIO //////// INTERVINIENTE-FORMULARIO //////// INTERVINIENTE-FORMULARIO //////// INTERVINIENTE-FORMULARIO //////// INTERVINIENTE-FORMULARIO 
    public static final String INTERVINIENTEFORMULARIO_RECORDTYPE_NAME_INFORMACION = 'Información';


    //////// FORMULARIO REFINANCIACION //////// FORMULARIO REFINANCIACION //////// FORMULARIO REFINANCIACION //////// FORMULARIO REFINANCIACION //////// FORMULARIO REFINANCIACION 
    // FORMULARIO RECORDTYPE
    public static final String FORMULARIOREFINANCIACION_RECORDTYPE_NAME_FORMULARIO_REFINANCIACION = 'Formulario de Refinanciación';

    // FORMULARIO CAMPO ESTADO
    public static final String FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_ENVIO = 'Pendiente de enviar';
    public static final String FORMULARIOREFINANCIACION_ESTADO_EN_CURSO = 'En Curso';
    public static final String FORMULARIOREFINANCIACION_CHECK_LIST_REFINANCIACION = 'Check-List de Refinanciación';
    public static final String FORMULARIOREFINANCIACION_ESTADO_ENVIADO = 'Enviado';
    public static final String FORMULARIOREFINANCIACION_ESTADO_PENDIENTE_SINCRONIZACION = 'Pendiente Sincronización';


    //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT //////// ACCOUNT ////////  
    public static final String CLIENTE_RECORDTYPE_DEVELOPERNAME = 'CC_ClientePA';


    //////// CATALOGO //////// CATALOGO //////// CATALOGO //////// CATALOGO //////// CATALOGO //////// CATALOGO //////// CATALOGO //////// CATALOGO //////// CATALOGO 
    public static final String CATALOGO_CNAE = 'CNAE';
    public static final String CATALOGO_CNO = 'CNO';
    public static final String CATALOGO_PREFIJO_SEGMENTO = 'SEGM_SEGMENTO';
    public static final String CATALOGO_PREFIJO_ESTRATEGIA = 'SEGM_ESTRATEGIA'; 
    public static final String CATALOGO_API_MAPEO_ACCIONES_PRESOL = 'API_MAPEO_ACCION_SF_SIREC';
    public static final String CATALOGO_API_MAPEO_ACCIONES_FLUJO  = 'API_MAPEO_ACCION_SF_SIREC_FLUJO';


    //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA //////// TAREA 
    // TAREA VARIABLES
    public static final String TAREA_DAT_FECHA = 'F';
    public static final String TAREA_DAT_NUMERO = 'N';
    public static final String TAREA_DAT_ALFANUMERICO = 'A';
    public static final String TAREA_SEL_SIMPLE = 'S';
    public static final String TAREA_SEL_MULTIPLE = 'M';
    public static final String NOMBRE_METADATA_TYPE_INTERFACE_TAREA = 'Tarea';
    
    // TAREA CAMPO ESTADO
    public static final String TAREA_ESTADO_EN_CURSO = 'En curso';
    public static final String TAREA_ESTADO_FINALIZADA = 'Finalizada';
    public static final String TAREA_ESTADO_PENDIENTE = 'Pendiente Sincronización';
    public static final String TAREA_ESTADO_ENVIADA = 'Enviada';
    public static final String TAREA_ESTADO_BORRAR = 'Borrar';

    // TAREA CODIGO
    public static final String CODIGO_TAREA_SEL = 'SEL';
    public static final String CODIGO_TAREA_DAT = 'DAT';
    public static final String CODIGO_TAREA_CTL = 'CTL';
    public static final String CODIGO_TAREA_OPC = 'OPC';
    public static final String CODIGO_TAREA_BAT = 'BAT';
    public static final String CODIGO_SELECCION_UNICA = 'S';
    public static final String CODIGO_SELECCION_MULTIPLE = 'M';
    public static final String CODIGO_SELECCION_FECHA = 'F';
    public static final String CODIGO_SELECCION_NUMERO = 'N';
    public static final String CODIGO_SELECCION_ALFANUMERICO = 'A';

    // TAREA CODIGOS ESPECIALES
    public static final String CODIGO_PROPUESTA_NEGOCIO = 'SEL-PVN004';
    public static final String CODIGO_PROPUESTA_RIESGO = 'SEL-PVR004';
    public static final String CODIGO_PROPUESTA_CONJUNTA = 'SEL-PVC001';
    public static final String CODIGO_PROPUESTA_CONJUNTA_NEG = 'SEL-PVC001';
    public static final String CODIGO_PROPUESTA_CONJUNTA_RIE = 'SEL-PVC002';
    public static final String CODIGO_PROPUESTA_CONJUNTA_CON = 'SEL-PVC935';
    public static final String CODIGO_PROPUESTA_ORG_RESOLUTOR = 'SEL-PVC930';
    public static final String CODIGO_BAT_AC1 = 'BAT-FEAC99';
    public static final String CODIGO_BAT_AC2 = 'BAT-FEACPP';
    public static final String CODIGO_BAT_PP1 = 'BAT-FEPPP2';
    public static final String CODIGO_BAT_PP2 = 'BAT-FEPPPE';

    //TAREA FUNCION EJE PARA PLAN PAGO/ACUERDO DE PAGO
    public static final String FUNCION_EJE_PLANPAGO = 'PLANPAGO';

    public static final List<String> LISTA_CODIGOS_PROPUESTA = new List<String>{CODIGO_PROPUESTA_NEGOCIO, CODIGO_PROPUESTA_RIESGO, CODIGO_PROPUESTA_CONJUNTA,
                                                                                CODIGO_PROPUESTA_CONJUNTA_NEG,CODIGO_PROPUESTA_CONJUNTA_RIE,CODIGO_PROPUESTA_CONJUNTA_CON,
                                                                                CODIGO_PROPUESTA_ORG_RESOLUTOR};
    
    public static final List<String> LISTA_CODIGOS_BAT_AC_PP = new List<String>{CODIGO_BAT_AC1, CODIGO_BAT_AC2, CODIGO_BAT_PP1, CODIGO_BAT_PP2};
        
    // TAREAS DE SEGUIMIENTO ACUERDO DE PAGO O PLAN DE PAGO 
    public static final String CODIGO_TAREA_CTL_SEGUIMIENTO = 'CTL-SEGUIMIENTO';

    //
    public static final Map<String,String> MAP_CODIGO_ACTIVIDAD_AP_PP = new Map<String,String>{
        'OPC-ACUEPAGO' => 'ACUERDO_DE_PAGO',                                            
        'OPC-PLANPAGO' => 'PLAN_PAGO'
    };
    public static final Map<String,String> MAP_CODIGO_PDM_ACT_AP_PP = new Map<String,String>{
        'OPC-ACUEPAGO' => 'PDM-PLANPAGO',                                            
        'OPC-PLANPAGO' => 'PDM-ACUERDO'
    };

    public static final Map<String,String> MAP_SITUACION_COLECTIVO = new Map<String,String>{
        'SF_PVNRAP' => 'No requiere acción preventiva',                                            
        'SF_PVNRAP' => 'No requiere acción preventiva',    
        'SF_PVCAPR' => 'Con Acción preventiva',
        'SF_PVCAP4' => 'Con acción restrictiva pendiente',        
        'SF_PVACAP' => 'Acción restrictiva aplicada',
        'SF_INIGEST' => ''        
    };

    //////// VARIABLES //////// VARIABLES //////// VARIABLES //////// VARIABLES //////// VARIABLES //////// VARIABLES //////// VARIABLES //////// VARIABLES ////////  
    public final static String CREACION_REGISTRO_CORRECTO = 'CREATE OK';
    public final static String CREACION_REGISTRO_INCORRECTO = 'CREATE KO';
    // IMAGIN
    public final static String IMAGIN_GESTOR_MRID = 'GESTOR_IMAGING_IMAGIN_1';
    
    public static final String APP_RETAIL_DEVELOPERNAME = 'SIR_misClientesSolutions';
    public static final String APP_EMPRESA_DEVELOPERNAME = 'SIRE_MisClientesSolucionesEMP';

    public static final String APP_ACT_MCSOL_PREFIX = '';
    //public static final String APP_ACT_MCSOLEMP_PREFIX = 'SIRE_';
    // Modificar a SIREC_ cuando tengamos el actor de empresas creado y los custom setting duplicados
    public static final String APP_ACT_MCSOLEMP_PREFIX = '';
    
    // EXTERNAL CREDENTIAL PARA ALMACENAR KEY ENCRIPTADO
    public static final String EXT_CRED_KEY_NUMPERSO = 'SIR_KeyNumPerso';
    public static final String EXT_CRED_KEY_PRINCIPAL = 'Key';
    public static final String KEY_NUMPERSO_TEST = 'qC+ktryIjVtl+hUwCq3KuQ==';    
}