/**********************************************************************************************************************
 Name:      AV_AppConstants
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de constantes de la aplicación
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION        USER_STORY       AUTHOR           DATE                Description
   	1.0            App FSC          David Rufo       11/02/2020          Init version
   	1.1            App FSC          Jashanpreet      22/10/2020          Added constants for picklist api names and RT
   	1.2            App FSC          Álvaro López     03/02/2021          Added opportunity and task status api names
	1.3            App FSC          David Rufo     	 12/05/2021          Added opportunity status api names + new object names
	1.4			   App FSC			Víctor Santiago	 08/06/2021			 Added TASKCPENDIENTE_RT
	1.4			   App FSC			Víctor Santiago	 14/06/2021			 Added OBJECT_NAME_TAREA_OPOR and  TAREA_OPOR_RT
	1.5			   US457715			Eduardo González 19/10/2022			 Added OPP_STATUS_CERRNEG
    1.6            US466765         Patricia Solano  14/12/2022		     Added OPPLLAMADA_RT
	1.7			   US464558			Luis Fernández 	 28/12/2022			 Added BIGDOT constant
	1.8			   US326386		    Luis Fernández 	 30/01/2023			 Added AV_Iniciador__c, AV_Purpose__c and AV_Chanel picklist values
	1.9			   FIX			    Luis Fernández 	 30/01/2023			 Added User Function values constants
	2.0			   Fix interlocutionGroup		     09/02/2023			 Added group Interlocutor RecordType
	2.1			   US538800			Sandra Gómez	 15/02/2023			 Change value PURPOSE_GESTION_OPERATIVA,PURPOSE_GESTION_COMERCIAL,CHANEL_MC,INOUTBOUND_ENTRADA and INOUTBOUND_SALIDA and add INOUTBOUND_ENTRADA_OLD and INOUTBOUND_SALIDA_OLD 
	2.2            US564620         Oscar Moreno     29/03/2023          Added PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS and PS_CAMBIO_GESTOR_PROCESOS
	2.3			   US610044		    Luis Fernández	 19/06/2023			 Added new OFT constant for task type
	2.3			   Fix				Sandra Gómez	 17/08/2023			 Add new value OPP_ORIGEN_BACK_REPORT, OPP_ORIGEN_CHECK_ON_OFF, Activity Type and status Event and change REPRESENTANTE_RT and add BACK_REPORT_NEW_OPP_ORIGENAPP
	2.4            US609339         Oscar Moreno     16/10/2023          Add CONTACT_REPRESENT_RT

***********************************************************************************************************************/
public with sharing class AV_AppConstants {

	/**
	 * API Name of profile
	*/
	public static final String AV_PROFILE = 'AV_Usuario_CaixaBank';
	public static final String AV_PROFILE_APIONLY = 'API Only';
	public static final String AV_ALIAS_AVTF9 = 'AV-TF9';

	/**
	 * API Name of standard and custom objects
	 */
	public static final String OBJECT_NAME_OPPORTUNITY     = 'Opportunity';
	public static final String OBJECT_NAME_ACCOUNT         = 'Account';
	public static final String OBJECT_NAME_CONTACT         = 'Contact';
	public static final String OBJECT_NAME_CONTRACT        = 'Contract';
	public static final String OBJECT_NAME_LEAD            = 'Lead';
    public static final String OBJECT_NAME_LEADOPP         = 'AV_LeadOpportunity__c';
	public static final String OBJECT_NAME_CASE            = 'Case';
    public static final String OBJECT_NAME_EVENT           = 'Event';
    public static final String OBJECT_NAME_TASK            = 'Task';
	public static final String OBJECT_NAME_PROFILE         = 'Profile';
	public static final String OBJECT_NAME_TAREA_OPOR	   = 'AV_CustomActivityOpportunity__c';
	public static final String OBJECT_NAME_PRODUCT 		   = 'Product2';
	public static final String OBJECT_NAME_USER 		   = 'User';


	/*
	 * API Name for fields
	 */
	public static final String FIELD_NAME_ID                = 'Id';
	public static final String FIELD_NAME_NAME              = 'NAME';

	public static final String RETAIL_PREFIX 				= 'AV_';
	public static final String FIELD_NAME_CUSTOM            = '__c';
	public static final String FIELD_NAME_CUSTOM_METADATA   = '__mdt';

	/**
	* NUMBERS
	*/
	public static final String ZERO          = '0';
	public static final String ONE           = '1';
	public static final String TWO           = '2';

	/**
	 * Colors
	 */
	public static final String RED      = 'red';
	public static final String GREEN    = 'green';
	public static final String YELLOW   = 'yellow';

	/**
	 * Type of message: error, info, warning, debug,...
	 */
	public static final String OK         = 'ok';
	public static final String SUCCESS    = 'success';
	public static final String CONFIRM    = 'confirm';
	public static final String ERROR      = 'error';
	public static final String INFO       = 'info';
	public static final String WARN       = 'warning';
	public static final String DEBUG      = 'debug';

	/**
	 * TAGS HTML
	 */
	public static final String HTML_BREAKLINE   = '<br/>';

	/**
	 * Other Constants
	 */
	public static final Integer INT_MIN_VALUE               = -2147483647;
	public static final Integer INT_MAX_VALUE               = 2147483647;

	public static final String FORMAT_DATE_DDMMYYYY         = 'dd/MM/yyyy';
	public static final String FORMAT_DATE_FULL             = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';

	public static final String CONST_DEFAULT                = 'default';
	public static final String CONST_NA                     = 'N/A';
	public static final String COUNT_RESULTS				= 'expr0';

	public static final String BREAK_LINE   = '\r\n';
	public static final String EMPTY        = '';
	public static final String WHITESPACE   = ' ';
	public static final String DOT          = '.';
	public static final String COMMA        = ',';
	public static final String SEMICOLON    = ';';
	public static final String COLON        = ':';
	public static final String QUOTE        = '"';
	public static final String SIMPLE_QUOTE = '\'';
	public static final String UNDERSCORE   = '_';
	public static final String DASH         = '-';
	public static final String AMPERSAND    = '&';
	public static final String ASTERISK     = '*';
	public static final String BRACKET_OPEN = '(';
	public static final String BRACKET_CLOSE= ')';
	public static final String BRACE_OPEN   = '{';
	public static final String BRACE_CLOSE  = '}';
	public static final String SQUARE_BRACKET_OPEN  = '[';
	public static final String SQUARE_BRACKET_CLOSE = ']';
	public static final String SLASH        = '/';
	public static final String SLASH_INVERTER = '\\';
	public static final String EQUAL        = '=';
	public static final String QUESTION     = '?';
	public static final String ADMIRATION   = '!';
	public static final String PIPE         = '|';
	public static final String GREATER_THAN = '>';
	public static final String LESS_THAN    = '<';
	public static final String PLUS         = '+';
	public static final String NUMBER_SIGN  = '#';
	public static final String BIGDOT       = '•';
    public static final String AV_PREFIX    = 'AV_%';
	public static final String ALL_CENTER = 'TODOS - CENTRO';
	public static final String SINGESTOR_EAP_CENTRO = 'Sin Gestor / Eap - CENTRO';
	public static final String ALL_MANAGER = 'TODAS - GESTOR';


	/*
	 * System Exception Types
	 */
	public static final String EXC_VALIDATION  = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';

	/*
	 * RecordType Names
	 */
	public static final String OPPTASK_RT  		= 'AV_TareaOpportunidad';
	
    public static final String TASKINICIATIVA_RT  = 'AV_Otros';
    public static final String TASKALERTACOM_RT	  = 'AV_AlertaComercial';
    public static final String TASKAVISOS_RT	  = 'AV_MorosidadNormativa';
    public static final String TASKCONTACTGCF_RT  = 'AV_ContactosGCF';
    public static final String TASKEXPCLIENT_RT	  = 'AV_ExperienciaCliente';
    public static final String TASKONBOARDING_RT  = 'AV_Onboarding';
    public static final String TASKPRIORIZADOR_RT = 'AV_Priorizador';
	public static final String TASKCPENDIENTE_RT  = 'AV_ConversacionPendiente';
    
    public static final String EVENTCLIENTE_RT  = 'AV_EventosConCliente';
	public static final String EVENTGESTOR_RT  	= 'AV_EventosGestorA';
	
    public static final String OPPINICIATIVA_RT = 'AV_Iniciativa';
    
    public static final String OPPALERTACOM_RT 	= 'AV_AlertaComercial';
    public static final String OPPPROPUESTA_RT 	= 'AV_Propuesta';
    public static final String OPPSUGERENCIA_RT	= 'AV_Sugerencia';
	public static final String OPPLLAMADA_RT	= 'AV_CallMe';

	public static final String CSBD_ACCIONCOM_RT = 'CSBD_Accion_Comercial';
	public static final String CSBD_CHAT_RT = 'CSBD_Chat';
	public static final String CSBD_CMB_RT = 'CSBD_CMB';
	public static final String CSBD_CMN_RT = 'CSBD_CMN';
	public static final String CSBD_COMPRAESTRELLA_RT = 'CSBD_Compra_Estrella';
	public static final String CSBD_DESTISTIMIENTO_RT = 'CSBD_Desistimiento';
	public static final String CSBD_DESISTIMIENTPAI_RT = 'CSBD_DesistimientoPAI';
	public static final String CSBD_HIPOTECA_RT = 'CSBD_Hipoteca';
	public static final String CSBD_PRESTAMO_RT = 'CSBD_Prestamo';
	public static final String CSBD_RENTING_RT = 'CSBD_Renting';
	public static final String CSBD_TPV_RT = 'CSBD_TPV';

	public static final Set<String> CSBD_RTS_SET = new Set<String>{

											CSBD_ACCIONCOM_RT,
											CSBD_CHAT_RT,
											CSBD_CMB_RT,
											CSBD_CMN_RT,
											CSBD_COMPRAESTRELLA_RT,
											CSBD_DESTISTIMIENTO_RT,
											CSBD_DESISTIMIENTPAI_RT,
											CSBD_HIPOTECA_RT,
											CSBD_PRESTAMO_RT,
											CSBD_RENTING_RT,
											CSBD_TPV_RT


	};
    
    public static final String ACCOUNT_PA_RT 	= 'CC_ClientePA';
    public static final String ACCOUNT_ENT_RT 	= 'CC_Cliente';
    public static final String ACCOUNT_CTO_RT 	= 'CC_CentroCaixaBank';
    public static final String EMPLOYEE_RT 		= 'CC_Empleado';
    public static final String REPRESENTANTE_RT	= 'CIBE_Apoderado';
    public static final String CONTACT_REPRESENT_RT	= 'CC_Representante';
    
	public static final String TAREA_OPOR_RT = 'AV_TareaOpportunidad';

	public static final String LEAD_PPHH_RT = 'AV_PlataformasHipotecarias';
    public static final String CSBD_FORM_INTOUCH_RT = 'CSBD_Formulario_Intouch';

	public static final string PRODUCT_PF_RT = 'AV_PF';
	public static final string PRODUCT_PRODCUTO_RT = 'AV_Producto';
	public static final string ORIGEN_ACT_MURO = 'AV_Muro';
	public static final string ORIGEN_ACT_R2B = 'AV_R2B';
	public static final string ORIGEN_ACT_LLAMADAS = 'AV_Llamadas';

	

	 /*
	 * PickList Api names
	 */

	public static final String CITA_OFICINA_TIPO   		= 'CTO';
	public static final String CITA_OTRA_OFICINA_CAIXABANK = 'CTOOC';
	public static final String VISITA_TIPO  			= '001';
	public static final String CITA_TELEFONICA_TIPO  	= 'CTF';
	public static final String VIDEOLLAMADA_TIPO   		= 'VLD';
	public static final String LLAMADA_TIPO 			= 'LMD';
	public static final String TASKOFFICETYPE   		= 'OFT';
	public static final String SALESFORCE_ORIGENAPP   	= 'AV_Salesforce';
	public static final String OUTLOOK_ORIGENAPP   		= 'AV_Outlook';
	
    //Opportunity StageNames
	public static final String OPP_STATUS_POTENCIAL 	= 'Potencial';
	public static final String OPP_STATUS_ENGESTION 	= 'En gestión/insistir';
    public static final String OPP_STATUS_ENESPERA 		= 'En espera';
    public static final String OPP_STATUS_CERRPOST 		= 'Cerrado positivo';
    public static final String OPP_STATUS_CERRNEG		= 'Cerrado negativo';
    public static final String OPP_STATUS_NOINTERE 		= 'No interesado';
    public static final String OPP_STATUS_NOAPTO 		= 'No apto';
    public static final String OPP_STATUS_CONVENTA 		= 'Con venta';
    public static final String OPP_STATUS_VENCIDO 		= 'Vencido';

	//Opportunity Resolucion
	public static final String OPP_RESOLUTION_OTROS		= 'O';
	public static final String OPP_RESOLUTION_VD 		= 'VD';

	//Event Status
	public static final String EVENT_STATUS_PENDIENTE 			= 'Pendiente';
	public static final String EVENT_STATUS_CANCELADO 			= 'Cancelado';
	public static final String EVENT_STATUS_CERRADO 			= 'Gestionada Positiva';
	
	//Task Status
    public static final String TASK_STATUS_PENDIENTE 			= 'Open';
	public static final String TASK_STATUS_PENDIENTE_NO_LOCAL 	= 'Pendiente no localizado';
    public static final String GESTIONADO_POSITIVO_ESTADO   	= 'Gestionada positiva';
	public static final String GESTIONADO_NEGATIVA_ESTADO   	= 'Gestionada negativa';
	public static final String CERRADO_ESTADO   				= 'Gestionada positiva';
	public static final String NO_GESTIONADA					= 'No gestionada';
    public static final String GESTIONADO_NO_LOCALIZADO			= 'Gestionado no localizado';

	//Lead Opportunity Stages
	public static final String LEADOPP_STAGE_POTENCIAL 			= 'Potencial';
	public static final String LEADOPP_STAGE_GESTION 			= 'En gestión/insistir';
	public static final String LEADOPP_STAGE_POSITIVA 			= 'Cerrada Positiva';
	public static final String LEADOPP_STAGE_NEGATIVA 			= 'Cerrada Negativa';
	public static final String LEADOPP_STAGE_VENTA 				= 'Con venta';
	public static final String LEADOPP_STAGE_NO_APTO 			= 'No apto';
	public static final String LEADOPP_STAGE_VENCIDA 			= 'Vencida';

	//Lead Opportunity Status
	public static final String LEADOPP_STATUS_ACEPTADO  		= '01'; //Aceptado
	public static final String LEADOPP_STATUS_RECHAZADO			= '02'; //Rechazado
	public static final String LEADOPP_STATUS_NUEVO 			= 'Nuevo';
	public static final String LEADOPP_STATUS_ENVIADA 			= 'Enviada oferta comercial';
	public static final String LEADOPP_STATUS_ACTIVO 			= 'Activo';
	public static final String LEADOPP_STATUS_CERRADO 			= 'Cerrado';
    public static final String LEADOPP_STATUS_RECHAZADOTXT 		= 'Rechazado';

	//Lead Opportunity Estado envío of. comercial
	public static final String LEADOPP_OFFER_STATUS_SENT 		= '1';//Sent

	//Application Name
	public static final String BROWSER = 'Browser';
    
    //Opportunity stage
    public static final String OPP_STAGE_SALES 					= 'Con Venta';
    public static final String OPP_STAGE_NOT_INTERESTED 		= 'No interesado';
	public static final String STATUS_CANCELLED 			    = 'Cancelado';
	public static final String STATUS_CANCELLED_UPPERCASE		= 'CANCELADO';

	//Opportunity origen app
	public static final String OPP_ORIGEN_SF_REPORT 			= 'AV_SalesforceReport';
	public static final String CLIENT_REPORT_ORIGENAPP			= 'AV_SalesforceClientReport';
	public static final String OPP_ORIGEN_BACK_REPORT 			= 'AV_BackReport';
	public static final String OPP_ORIGEN_CHECK_ON_OFF 			= 'AV_SalesforceTaskOpp';
	public static final String BACK_REPORT_NEW_OPP_ORIGENAPP 	= 'AV_BackReportNewOpp';

	public static final String TODAYS_TASKS = 'AV_Home_Gestor_Tareas_para_Hoy';
	public static final String PENDING_TASKS = 'AV_HomeGestorTareasPendientes';
	public static final String TODAYS_APPOINTMENTS = 'AV_Home_Gestor_Citas_de_Hoy';
	public static final String YESTERDAYS_APPOINTMENTS = 'AV_HomeGestorCitasDeAyerNoCerradas';
	public static final String EXTENDEDHOME_LINK = 'AV_ExtendedHomeLink';

	public static final String TODAYS_TASKS_TITLE = 'Tareas para Hoy';
	public static final String PENDING_TASKS_TITLE = 'Tareas pendientes últimos 3 días';
	public static final String TODAYS_APPOINTMENTS_TITLE = 'Citas de hoy';
	public static final String YESTERDAYS_APPOINTMENTS_TITLE = 'Citas de ayer no cerradas';

	//Activity AV_Purpose__c , AV_Channel__c and AV_InOutBound__c picklist values
	
	public static final String PURPOSE_GESTION_OPERATIVA = '002';
	public static final String PURPOSE_GESTION_COMERCIAL = '001';
	public static final String CHANEL_MC = '002';
	public static final String INOUTBOUND_ENTRADA = '002';
	public static final String INOUTBOUND_SALIDA = '001';
	public static final String INOUTBOUND_ENTRADA_OLD = 'Entrada';
	public static final String INOUTBOUND_SALIDA_OLD = 'Salida';


	//User Functions

	public static final String FUNCION_DT = 'DT';
	public static final String FUNCION_DC = 'DC';
	public static final String FUNCION_DAN = 'DAN';
	public static final String FUNCION_GESTOR = 'Gestor';
	public static final String FUNCION_OFICINA = 'Oficina';
	public static final String FUNCION_SSCC = 'SSCC';

	
	public static final String INTERLOC_GROUP_RT = 'AV_GrupoInterlocutor';
	public static final String BOOKMANAGEMENT_RT = 'AV_CarterGestor';

	//Permission sets

	public static final String PS_GESTOR = 'AV_Gestor';
	public static final String PS_EXTERNO = 'AV_Externo';
	public static final String PS_LECTURA_Y_ANALITICS = 'AV_Lectura_y_Analytics';
	public static final String PS_CUSTOMERINTOUCH = 'AV_CustomerIntouchOnboarding';
	public static final String PS_BANKTELLER = 'AV_BankTeller';
	public static final String PS_VISIBILIDAD_MIS_CLIENTES_SOLUTIONS = 'SIR_PS_VisibilidadMisClientesSolutions';
	public static final String PS_GESTORESCRITURA = 'AV_GestorEscritura';
	public static final String PS_GESTORLECTURA = 'AV_GestorLectura';
	public static final String PS_GESTOROPERATIVA = 'AV_GestorOperativa';
	public static final String PS_GESTORTABS = 'AV_Gestor_Tabs';
	public static final String PS_GESTOROPERATIVAESCRITURA = 'AV_GestorOperativaEscritura';
	public static final String PS_ORGANIZADOREVENTOS = 'EV_OrganizadorEventos';

	public static final String PS_CAMBIO_GESTOR_PROCESOS = 'SIR_CambioGestorProcesos';
	 

	//Notifications 
	public static final String TASKNOTIFICATION =  'AV_NewTaskNotification';

	//OfficePermission RecordType

	public static final String PERMISSION_RT = 'AV_Permiso';

	public static final String PS_PRIVATEBANKING = 'AV_PrivateBanking'; 

	public static final String BPRROL = 'BPR';

	//Reports
	public static final String 	PRIOR_MANAGE_CLIENTS = 'AV_PriorManageClients';
	public static final String 	PRIOR_MANAGE_CLIENTS_SENSIBLEDATA = 'AV_PriorManageClientsSensibleData';
	public static final String 	PRIOR_MANAGE_CLIENTS_SENSIBLEDATABANCAPR = 'AV_PriorManageClientsSensibleDataBancaPr';
	public static final String 	PENDING_CONVERSATION = 'AV_PendingConversation';
	public static final String 	PENDING_CONVERSATION_BANCAPRIVADA = 'AV_PendingConversationBancaPrivada';
	public static final String 	REPORT_TODAYS_APPOINTMENTS = 'AV_TodaysAppointments';
	public static final String 	TODAYS_APPOINTMENTS_BANCAPRIVADA = 'AV_TodaysAppointmentsBancaPrivada';
	//Boolean
	public static final String NOT_SELECTED = 'N';

	//Opportunity Fields

	public static final String OPPO_POTENCIAL_FIELD = 'AV_Potencial__c';

	//Activity Type
	public static final String ACT_TYPE_MURO = '030';
	public static final String ACT_TYPE_EMAIL_SMS = 'ESE';
	public static final String ACT_TYPE_TASK_OFFI = 'OFT';

	//Icons 

	public static final String ICON_ACCOUNT = 'standard:account';
	public static final String ICON_USER = 'standard:user';
	public static final String ICON_CONTACT = 'standard:contact';
}