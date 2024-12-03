/**********************************************************************************************************************
 Name:      CIBE_AppConstants
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de constantes de la aplicación  
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION        USER_STORY       AUTHOR           DATE                Description
   	1.0            App Constantes   Jose Maria       08/08/2022          Init version
    1.1            US486064         Bea y Ali        01/09/2023          Add value of reports of CIB and EMP, 'COUNT_RESULTS'

***********************************************************************************************************************/
public with sharing class CIBE_AppConstants {

	//API Name of standard and custom objects
	public static final String OBJECT_NAME_OPPORTUNITY     	= 'Opportunity';
	public static final String OBJECT_NAME_ACCOUNT         	= 'Account';
	public static final String OBJECT_NAME_CONTACT         	= 'Contact';
	public static final String OBJECT_NAME_CONTRACT        	= 'Contract';
	public static final String OBJECT_NAME_LEAD            	= 'Lead';
	public static final String OBJECT_NAME_CASE            	= 'Case';
    public static final String OBJECT_NAME_EVENT           	= 'Event';
    public static final String OBJECT_NAME_TASK            	= 'Task';
	public static final String OBJECT_NAME_PROFILE         	= 'Profile';
	public static final String OBJECT_NAME_TAREA_OPOR	   	= 'AV_CustomActivityOpportunity__c';
	public static final String OBJECT_NAME_CARTERA	   		= 'AV_Book__c';
    public static final String OBJECT_NAME_CARTERA_GESTOR	= 'AV_BookManagementMember__c';
	public static final String OBJECT_NAME_CARTERA_CLIENTE	= 'AV_BookMember__c';
    public static final String OBJECT_NAME_ACCACCRELATION	= 'FinServ__AccountAccountRelation__c';
    
    //RecordTypes
    public static final String ACCOUNT_CLIENTE_RT 			= 'CC_Cliente';
    public static final String ACCOUNT_CLIENTE_PA_RT 		= 'CC_ClientePA';
    public static final String ACCOUNT_CENTROCAIXABANK_RT 	= 'CC_CentroCaixabank';
    public static final String ACCOUNT_G_COMERCIAL_RT 		= 'CIBE_GrupoComercial';
    public static final String ACCOUNT_G_ECONOMICO_RT 		= 'CIBE_GrupoEconomico';
    public static final String ACCOUNT_POTENCIAL_RT 		= 'CIBE_Potencial';
    
    public static final String EMPLOYEE_RT					= 'CC_Empleado';
    
    public static final String OPP_INICIATIVA_RT 			= 'CIBE_IniciativaEmpleado';
	public static final String OPP_INICIATIVACIB_RT 		= 'CIBE_IniciativaEmpleadoCIB';
	public static final String OPP_INICIATIVAEMP_RT 		= 'CIBE_IniciativaEmpleadoEMP';
    public static final String OPP_ACCIONCIB_RT 			= 'CIBE_AccionComercialCIB'; 
    public static final String OPP_ACCIONEMP_RT 			= 'CIBE_AccionComercialEMP'; 
    public static final String OPP_ALERTACIB_RT 			= 'CIBE_AlertaComercialCIB'; 
    public static final String OPP_ALERTAEMP_RT 			= 'CIBE_AlertaComercialEMP'; 
    public static final String OPP_SUGERENCIACIB_RT 		= 'CIBE_SugerenciaCIB'; 
    public static final String OPP_SUGERENCIAEMP_RT 		= 'CIBE_SugerenciaEMP';
    public static final String OPP_CENTRALIZADA_RT          = 'CIBE_OportunidadCentralizada';
    
    public static final String EVENT_CLIENTE_RT 			= 'CIBE_EventoCliente';
    public static final String EVENT_GESTOR_RT 				= 'CIBE_EventodelGestor';
    

    public static final String TASK_ALERTACOMERCIAL_CIB_RT	     = 'CIBE_AlertaComercialCIB';
    public static final String TASK_ALERTACOMERCIAL_EMP_RT	     = 'CIBE_AlertaComercialEMP';
    public static final String TASK_ONBOARDING_CIB_RT	       	 = 'CIBE_OnboardingCIB';
    public static final String TASK_ONBOARDING_EMP_RT	       	 = 'CIBE_OnboardingEMP';
    public static final String TASK_PRIORIZADOS_CIB_RT	   		 = 'CIBE_GestionarPriorizadosCIB';
    public static final String TASK_PRIORIZADOS_EMP_RT			 = 'CIBE_GestionarPriorizadosEMP';
	public static final String TASK_OTROS_CIB_RT	        	 = 'CIBE_OtrosCIB';
    public static final String TASK_OTROS_EMP_RT		    	 = 'CIBE_OtrosEMP';
    public static final String TASK_AVISOS_CIB_RT	        	 = 'CIBE_AvisosCIB';
    public static final String TASK_AVISOS_EMP_RT	        	 = 'CIBE_AvisosEMP';
    public static final String TASK_EXPERIENCIACLIENTE_CIB_RT  	 = 'CIBE_ExperienciaClienteCIB';
    public static final String TASK_EXPERIENCIACLIENTE_EMP_RT  	 = 'CIBE_ExperienciaClienteEMP';

    public static final String CONTACT_APODERADO_RT	        	 = 'CIBE_Apoderado';
    public static final String CONTACT_CONTACTO_COMERCIAL_RT	 = 'CIBE_ContactoComercial';

    public static final String HIERARCHY_EMPLOYEE_RT	         = 'CIBE_Employee';
    
    //Event StageNames
    public static final String EVENT_STATUS_PENDIENTE 		= 'Pendiente';

    //Opportunity StageNames
    public static final String OPPORTUNITY_STATUS_POTENCIAL	= 'Potencial';
    public static final String OPPORTUNITY_STATUS_ENCURSO	= 'En curso';
    public static final String OPPORTUNITY_STATUS_PENDFIRMA	= 'CIBE_Pendiente_Firma';
    public static final String OPPORTUNITY_STATUS_CERRPOSI	= 'CIBE_Cerrado positivo';
    public static final String OPPORTUNITY_STATUS_CERRNEGA	= 'Cerrado negativo';
    public static final String OPPORTUNITY_STATUS_VENCIDO	= 'CIBE_Vencido';
    public static final String OPPORTUNITY_STATUS_CONVENTA	= 'Con venta';
    public static final String OPPORTUNITY_STATUS_NOAPTO	= 'No apto';
    public static final String OPPORTUNITY_STATUS_NOINTERE	= 'No interesado';

    //Origenes
    public static final String SALESFORCE_ORIGENAPP   		= 'AV_Salesforce';
	public static final String OUTLOOK_ORIGENAPP   		    = 'AV_Outlook';
    public static final String VIDEOLLAMADA_TIPO   		    = 'VLD';
    
    public static final String SUFFIX_EXTERNALID 	= 'Task-';
    
    /*
	 * PickList Api names
	 */

    public static final String LLAMADA_TLF_TIPO 		= 'LT';
	public static final String VISITA_CENTRO_TIPO  		= 'VC';
    public static final String ENTREVISTA_CENTRO_TIPO  	= 'EC';
	public static final String CITA_OFICINA_TIPO   		= 'CTO';
	public static final String LLAMADA_TIPO 			= 'LMD';
	public static final String CITA_TELEFONICA_TIPO  	= 'CTF';
    public static final String VISITA_TIPO  			= '001';

    //Task Status
    public static final String TASK_STATUS_PENDIENTE 			= 'Open';
	public static final String TASK_STATUS_PENDIENTE_NO_LOCAL 	= 'Pendiente no localizado';
    public static final String GESTIONADO_POSITIVO_ESTADO   	= 'Gestionada positiva';
	public static final String GESTIONADO_NEGATIVA_ESTADO   	= 'Gestionada negativa';
	public static final String CERRADO_ESTADO   				= 'Gestionada positiva';
	public static final String NO_GESTIONADA					= 'No gestionada';
    public static final String GESTIONADO_NO_LOCALIZADO			= 'Gestionado no localizado';


    //Permission Set
    public static final String USER_CIBEOPERATIVAEMP 			= 'CIBE_OperativaEMP';
    public static final String USER_CIBEOPERATIVACIB 			= 'CIBE_OperativaCIB';
    public static final String USER_AV_AVOIDBULKAPI 			= 'AV_AvoidBulkApi';
    public static final String EXTENDEDHOME_LINK                = 'CIBE_ExtendedHomeLink';

    
    //System Exception Errors
    public static final String EXC_VALIDATION  = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    
    //Permissions Set name
    public static final String CIBE_OPERATIVACIB 			= 'CIBE_OperativaCIB';
    public static final String CIBE_OPERATIVAEMP 			= 'CIBE_OperativaEMP';
    public static final String CIBE_GESTORCIB 				= 'CIBE_GestorCIB';
    public static final String CIBE_GESTOREMP 				= 'CIBE_GestorEMP';
    public static final String CIBE_CUSTOMMETADATA			= 'CIBE_CustomMetadata';
    public static final String CIBE_ANALYTICS 				= 'CIBE_Analytics';
    public static final String CIBE_INTEGRACION				= 'CIBE_Integracion';
    public static final String CIBE_ANALYTICSINTEGRACION 	= 'CIBE_AnalyticsIntegration';
    public static final String AV_SSO				        = 'AV_SSO';
    public static final String CIBE_GESTORINTERNO 	        = 'CIBE_GestorInterno';
    public static final String GESTORINTERNO 	            = 'CIBE_GestorCIBEInterno';
    
    //Profile name
    public static final String CIBE_GESTOR = 'CIBE_Gestor';
    
    //UserRole name
    public static final String CIBE_CIBEMPRESAS = 'CIBE_CIBEmpresas';
    public static final String CIBE_ROLECIB = 'CIB';
    public static final String CIBE_ROLEMP = 'EMP';


    //AccountTeamMember role
    public static final String PARTICIPANTE = 'Participante';
    public static final String GESTOR_PRINCIPAL = 'Gestor Principal';
    public static final String CONTACTO_CAIXABANK_RETAIL = 'Contacto Caixabank Retail';

    //Others
    public static final String NONE = 'None';
    public static final String EDIT = 'Edit';
    public static final String READ = 'Read';

    public static final String COUNT_RESULTS = 'expr0';

    //Integration

    public static final String GET = 'GET';
    public static final String POST = 'POST';
    public static final String PATCH = 'PATCH';
    
    public static final String HTTP_STATUS_OK 						= '200';
    public static final String HTTP_STATUS_CREATED					= '201';
    public static final String HTTP_STATUS_ACCEPTED					= '202';
    public static final String HTTP_STATUS_NO_CONTENT				= '204';
    
    //Carteras
    public static final String CARTERA 					= 'AV_Cartera';
    public static final String CARTERA_GESTOR 			= 'AV_CarteraGestor';
    public static final String CARTERA_CLIENTE 			= 'AV_CarteraCliente';
    
    //Opportunity Team Member Access
    public static final String ACC_READ = 'Read';
    public static final String ACC_EDIT = 'Edit';

    //AccountDummy
    public static final String ACC_SINCLIENTE = 'Sin Cliente';

    //CBK Picklist
    public static final String PICK_NEGOCIOS = 'Negocios';
    public static final String PICK_REDES_SEG = 'Redes-Segmentos';
    public static final String PICK_SECTORES_PAI = 'Sectores-Paises';
    public static final String PICK_CENTROS_CAR = 'Centros-Carteras';

    //Reports 

    public static final String CIBE_TAREAS_PROXIMOS_7DIAS_CIB = 'CIBE_TareasProximos7Dias_CIB';
    public static final String CIBE_TAREAS_PROXIMOS_7DIAS_EMP = 'CIBE_TareasProximos7Dias_EMP';
    public static final String CIBE_CLIENTES_GESTIONAR_PRIORIZADOS_CIB = 'CIBE_PriorManageClients';
    public static final String CIBE_CLIENTES_GESTIONAR_PRIORIZADOS_EMP = 'CIBE_PriorManageClientsEMP';
    public static final String CIBE_AVISOS_CIB = 'CIBE_WarningsToManage';
    public static final String CIBE_AVISOS_EMP = 'CIBE_WarningsToManageEMP';
    public static final String CIBE_EVENTOS_HOY = 'CIBE_TodaysAppointments';
    public static final String CIBE_NOTIFICACIONES = 'CIBE_PendingConversation';

    //AV_InOutBound__c picklist values
	
	public static final String INOUTBOUND_ENTRADA = '002';  //Empleado
	public static final String INOUTBOUND_SALIDA = '001';   //Cliente

    //AV_OrigenAct picklist values

    public static final String ORIGEN_ACT_LLAMADAS = 'AV_Llamadas';  
	public static final String ORIGEN_ACT_MURO = 'AV_Muro';   
	public static final String ORIGEN_ACT_STOPGO = 'AV_R2B';   
    public static final String ORIGEN_ACT_ON_BOARDING = 'AV_OnBoarding';  
    public static final String ORIGEN_ACT_OP_PENDIENTE_FIRMA = 'CIBE_OperacionesPendientesFirma';  

}