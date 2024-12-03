public class CBK_Log {
    

    //FUNCIÓN DEBUG:
    //CBK_Log.debug(<OPCIONAL> String contextId,
    //				String message o  Map<String,String> message,
    //			    <OPCIONAL> List<Object> values, 
    //			    <OPCIONAL> LoggingLevel level);
    			    
    //* contextId : Identidicador único para relacionar trazas de una ejecución. Por defecto UserInfo.getUserId() + '-' + timestamp()
    //* message : Mensaje de log (String o Map)
    //	   En formato Map --> new Map<String, String>{'msg' => 'XXX', 'cod' => 'CODXXX', 'type' => 'YYYY'}  
    //* values : List<Object> de información adicional a incorporar
    //* level : Nivel de traza (Default LoggingLevel.DEBUG)

    //FUNCIÓN ERROR:
    //CBK_Log.error(<OPCIONAL> String contextId,
    //				<OPCIONAL> Exception err,
    //				<OPCIONAL> String message o  Map<String,String> message,
    //				<OPCIONAL> Map<String,String> message,
    //				<OPCIONAL>  List<Object> values);
    				
    //* contextId : Identidicador único para relacionar trazas de una ejecución. Por defecto UserInfo.getUserId() + '-' + timestamp()
    //* err : Excepción. Opcional si viene informado el valor message.
    //* message : Texto de error  (String o Map). Opcional si se informa err, en cuyo caso se informará con err.getMessage()
	//	   En formato Map --> new Map<String, String>{'msg' => 'XXX', 'cod' => 'CODXXX', 'type' => 'YYYY'}  
    //* values : List<Object> de información adicional a incorporar

        

    public class LogConf {
        Boolean logViaEvents;
        Boolean DEBUG=false;
        Boolean INFO=false;
        Boolean WARN=false;
        Boolean ERROR=true;    
        Integer SNAPSHOT_EXECUTION_LIMIT=10000;    
    }
    private static final LogConf LOG_CONFIG = LogConfig();
    private static final Boolean LOG_VIA_EVENTS = LOG_CONFIG.logViaEvents;

	private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
	private static final String CLASSNAME = CBK_Log.class.getName();
	private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
	private static final String THIS_CONTEXT =UserInfo.getUserId() + '-' + timestamp();
    private static String disabledSnapshotLimitsFlagKey;
    private static Integer consultasLimites = 0;

    private static list<CBK_Log__c> lstErroresaGuardar = New list<CBK_Log__c>();
    private static list<CBK_LogEvent__e> lstErroresaGuardarDebug = New list<CBK_LogEvent__e>();
    
    private static list<Messaging.SingleEmailMessage> lstmailGeneral = New list<Messaging.SingleEmailMessage>();
    private static OrgWideEmailAddress[] owea;  
    private static List<CBK_Framework_Login__mdt> fwLogin; 

    @TestVisible
	private static CBK_LogEvent__e currentEvent = null;
    

    // DEBUG
	public static void debug(String message) {
		debug(null,message,new List<Object>(),LoggingLevel.DEBUG);
	}
    
    public static void debug(String message, List<Object> values) {
		debug(null,message,values,LoggingLevel.DEBUG);
	}

	public static void debug(String contextId,String message) {
		debug(contextId,message, new List<Object>(),LoggingLevel.DEBUG);
	}

	public static void debug(String contextId,String message, List<Object> values) {
		debug(contextId,message, values,LoggingLevel.DEBUG);
	}    
    
	public static void debug(String message,LoggingLevel level) {
		debug(null,message,new List<Object>(),level);
	}
    
    public static void debug(String message, List<Object> values,LoggingLevel level) {
		debug(null,message,values,level);
	}

	public static void debug(String contextId,String message,LoggingLevel level) {
		debug(contextId,message, new List<Object>(),level);
	}

	public static void debug(String contextId,String message, List<Object> values,LoggingLevel level) {
		emit(contextId,level, null,message, values,false, new Messaging.InboundEmail());
	}  


    // DEBUG CON MAP
	public static void debug(map<String,String> message) {
		debug(null,JSON.serialize(message),new List<Object>(),LoggingLevel.DEBUG);
	}
    
    public static void debug(map<String,String> message, List<Object> values) {
		debug(null,JSON.serialize(message),values,LoggingLevel.DEBUG);
	}

	public static void debug(String contextId,map<String,String> message) {
		debug(contextId,JSON.serialize(message), new List<Object>(),LoggingLevel.DEBUG);
	}

	public static void debug(String contextId,map<String,String> message, List<Object> values) {
		debug(contextId,JSON.serialize(message), values,LoggingLevel.DEBUG);
	}    
    
	public static void debug(map<String,String> message,LoggingLevel level) {
		debug(null,JSON.serialize(message),new List<Object>(),level);
	}
    
    public static void debug(map<String,String> message, List<Object> values,LoggingLevel level) {
		debug(null,JSON.serialize(message),values,level);
	}

	public static void debug(String contextId,map<String,String> message,LoggingLevel level) {
		debug(contextId,JSON.serialize(message), new List<Object>(),level);
	}

	public static void debug(String contextId,map<String,String> message, List<Object> values,LoggingLevel level) {
        emit(contextId,level, null,JSON.serialize(message), values,false, new Messaging.InboundEmail());
	}  
    

    // ERROR (exception)   
	public static void error(Exception err) {
		error(null,err,err.getMessage(), new List<Object>());
	}
    
    public static void error(Exception err,List<Object> values) {
		error(null,err,err.getMessage(), values);
	}
    
    public static void error(String contextId,Exception err) {
		error(contextId, err,err.getMessage(), new List<Object>());
	}
    
    public static void error(String contextId,Exception err,List<Object> values) {
		error(contextId,err,err.getMessage(),  values);
	}
    
    //ERROR (error Text)
	public static void error(String message) {
		error(null,null,message, new List<Object>());
	}

	public static void error(String message, List<Object> values) {
		error(null,null,message, values);
	}

	public static void error(String contextId,String message) {
		error(contextId,null,message, new List<Object>());
	}

	public static void error(String contextId,String message, List<Object> values) {
		error(contextId,null,message, values);
	}
    

    //ERROR (error Text (Map))
	public static void error(Map<String,String> message) {
		error(null,null,JSON.serialize(message), new List<Object>());
	}

	public static void error(Map<String,String> message, List<Object> values) {
		error(null,null,JSON.serialize(message), values);
	}

	public static void error(String contextId,Map<String,String> message) {
		error(contextId,null,JSON.serialize(message), new List<Object>());
	}

	public static void error(String contextId,Map<String,String> message, List<Object> values) {
		error(contextId,null,JSON.serialize(message), values);
	}
    
    //ERROR (Exception + error Text(MAP))    
 	public static void error(Exception err,Map<String,String> message) {
		error(null,err,JSON.serialize(message), new List<Object>());
	}

	public static void error(Exception err,Map<String,String>  message, List<Object> values) {
		error(null,err,JSON.serialize(message), values);
	}

	public static void error(String contextId,Exception err,Map<String,String>  message) {
		error(contextId,err,JSON.serialize(message), new List<Object>());
	}

	public static void error(String contextId,Exception err, Map<String,String>  message, List<Object> values) {
		error(contextId,err,JSON.serialize(message),values);
	}
    
	//ERROR (Exception + error Text)    
 	public static void error(Exception err,String message) {
		error(null,err,message, new List<Object>());
	}

	public static void error(Exception err,String message, List<Object> values) {
		error(null,err,message, values);
	}

	public static void error(String contextId,Exception err,String message) {
		error(contextId,err,message, new List<Object>());
	}

	public static void error(String contextId,Exception err,String message, List<Object> values) {
		emit(contextId,LoggingLevel.ERROR, err,message, values,false, new Messaging.InboundEmail());
	}
    
    //LOG With Messaging.InboundEmail 
    // public static void error(Exception err, String message, Messaging.InboundEmail email) {
    //     error(null, err, err?.getMessage(), new List<Object>(), email);
    // }
    public static void error(Exception err, String message, Messaging.InboundEmail email) {
        error(null, err, message, new List<Object>(), email);
    }
            
    public static void error(String contextId,Exception err,String message, List<Object> values, Messaging.InboundEmail email) {
		emit(contextId,LoggingLevel.ERROR, err,message, values,false, email);
    } 

    public static void saveError(String contextId,Exception err,String message, List<Object> values){
        createLogWithoutevent(contextId, LoggingLevel.ERROR, err, message, values, null, true,null);
	}

    public static void saveError(String contextId,Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields){
        createLogWithoutevent(contextId, LoggingLevel.ERROR, err, message, values, mapOptionalFields,true,null);
	}

    public static void saveError(String contextId,Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields,String estado){
        createLogWithoutevent(contextId, LoggingLevel.ERROR, err, message, values, mapOptionalFields,true,estado);
	}

    //Nueva Funcionalidad para guardar una lista de errores antes de guardarla.
    public static void addDebug(CBK_Log_Debug_Builder.DebugProcessConfig builder){       
        emitDebug(builder);
	}
     //Nueva Funcionalidad para guardar una lista de errores antes de guardarla.
     public static void insertDMLDebug(){

         //Comprobamos que haya habido algún error para hacer el insert de los errores
         if(!lstErroresaGuardarDebug.isEmpty()){
            Database.SaveResult[] resltPub = EventBus.publish(lstErroresaGuardarDebug);
        }
	}

    // METODO DE ENVIO A EVENTO O SYSTEM.DEBUG
	private static void emitDebug(CBK_Log_Debug_Builder.DebugProcessConfig myInstance){

        boolean trace;
        LoggingLevel level = myInstance.getlevel();
        boolean force = myInstance.getforce();
        Exception err = myInstance.geterr();
        Map<String, String> message = myInstance.getmessage();
        String contextId = myInstance.getcontextId();
        List<Object> values = myInstance.getvalues();
        Messaging.InboundEmail email = myInstance.getemail();
        String category = myInstance.getCategory();

        switch on level.name() {
            when 'INFO'  { trace= LOG_CONFIG.INFO; }	
            when 'WARN'  { trace= LOG_CONFIG.WARN; }
    		when 'ERROR' { trace= LOG_CONFIG.ERROR; }
            when 'DEBUG' { trace= LOG_CONFIG.DEBUG; }
    		when else    { trace= LOG_CONFIG.DEBUG; }
        }
        
        if (trace || force || (Test.isRunningTest())){

            String stacktrace='';
            String errType='';
            if (err==null) {
                stacktrace = new DmlException().getStackTraceString();
            } else {
                stacktrace = err.getStackTraceString();
                if (stacktrace?.left(32000)=='()'){
                    stacktrace = new DmlException().getStackTraceString();
                }
                errType = err.getTypeName();
            }
            if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
                currentEvent = new CBK_LogEvent__e();
                currentEvent.txt_User__c = UserInfo.getUserId();
                currentEvent.txt_Message__c = JSON.serialize(message)?.left(2000);
                currentEvent.txt_ErrType__c = String.isNotBlank(errType) ? errType.left(30) : '';
                currentEvent.txt_Level__c = level.name();
                currentEvent.txt_Context__c = ((contextId == null) ? THIS_CONTEXT : '' + myInstance).left(80);
                currentEvent.txt_stacktrace__c = stacktrace?.left(32000);
                currentEvent.txt_Detail__c = String.join(values,'@Det@')?.left(32000);
                currentEvent.CBK_sfdcMessageId__c = email?.messageId?.left(255);
                currentEvent.CBK_MessageException__c =  err?.getMessage()?.left(32500);
                currentEvent.CBK_Category__c = category?.left(255);
                currentEvent = (CBK_LogEvent__e) CBK_Log.getApexLimits(currentEvent);

                //Sustituimos la insercion por una lista
                lstErroresaGuardarDebug.add(currentEvent); 
                System.debug(level,message);
            } else {
                System.debug(level,message);
            }
        }
	}

    //Nueva Funcionalidad para guardar una lista de errores antes de guardarla.
    public static void addError(String contextId,Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields){
        // Le pasamos false al ultimo paramtero para que no guarde en la base de datos el registro
        createLogWithoutevent(contextId, LoggingLevel.ERROR, err, message, values, mapOptionalFields,false,null);
	}

    //Nueva Funcionalidad para guardar una lista de errores antes de guardarla.
    public static void insertDML(){
        //Comprobamos que haya habido algún error para hacer el insert de los errores
        if(!lstErroresaGuardar.isEmpty()){
            //Insertamos los registros de la lista guardada anteriormente
            Database.SaveResult[] srList = Database.insert(lstErroresaGuardar,false);

            //Llamamos al metodo para guardar los detalles de los registros y le decimos que se inserten.
            generaDetallesdeErrores(srList);
        }
	}


    
    // METODO DE ENVIO A EVENTO O SYSTEM.DEBUG
	private static void emit(String contextId, LoggingLevel level, Exception err, String message,List<Object> values,boolean force, Messaging.InboundEmail email) {
        boolean trace;
        switch on level.name() {
            when 'INFO'  { trace= LOG_CONFIG.INFO; }	
            when 'WARN'  { trace= LOG_CONFIG.WARN; }
    		when 'ERROR' { trace= LOG_CONFIG.ERROR; }
            when 'DEBUG' { trace= LOG_CONFIG.DEBUG; }
    		when else    { trace= LOG_CONFIG.DEBUG; }
        }
        
        if (trace || force || (Test.isRunningTest())){
            //String messageDetail = String.format(message, cast(values));

            String stacktrace='';
            String errType='';
            if (err==null) {
                stacktrace = new DmlException().getStackTraceString();
            } else {
                stacktrace = err.getStackTraceString();
                if (stacktrace?.left(32000)=='()'){
                    stacktrace = new DmlException().getStackTraceString();
                }
                errType = err.getTypeName();
            }
            if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
                currentEvent = new CBK_LogEvent__e();
                currentEvent.txt_User__c = UserInfo.getUserId();
                currentEvent.txt_Message__c = message?.left(2000);
                currentEvent.txt_ErrType__c = String.isNotBlank(errType) ? errType.left(30) : '';
                currentEvent.txt_Level__c = level.name();
                currentEvent.txt_Context__c = ((contextId == null) ? THIS_CONTEXT : '' + contextId).left(80);
                currentEvent.txt_stacktrace__c = stacktrace?.left(32000);
                currentEvent.txt_Detail__c = String.join(values,'@Det@')?.left(32000);
                currentEvent.CBK_sfdcMessageId__c = email?.messageId?.left(255);
                currentEvent.CBK_MessageException__c =  err?.getMessage()?.left(32500);
                currentEvent = (CBK_LogEvent__e) getApexLimits(currentEvent);
                Database.SaveResult resltPub = EventBus.publish(currentEvent);
                System.debug(level,message);
            } else {
                System.debug(level,message);
            }
        }
	}

	public static void auditemail(Messaging.InboundEmail email) {
        String stacktrace = new DmlException().getStackTraceString();
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId();
        if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
            currentEvent = new CBK_LogEvent__e();
            currentEvent.CBK_sfdcRecordType__c = recordTypeId;
            currentEvent.txt_User__c = UserInfo.getUserId();
            currentEvent.txt_Message__c = email?.subject?.left(2000);
            currentEvent.txt_Level__c = 'INFO';
            currentEvent.txt_Context__c = (string)THIS_CONTEXT?.left(80);
            currentEvent.txt_stacktrace__c = stacktrace?.left(32000);
            currentEvent.txt_FromAddress__c = email?.fromAddress?.left(255);
            currentEvent.txt_ToAddress__c = '';
            if (email?.toAddresses!=null){
                string.join(email.toAddresses,';')?.left(255);
            }
            
            if  (email?.headers!=null){
                for (Messaging.InboundEmail.Header header : email.headers) {
                    if (header.name == 'X-SFDC-Original-RCPT') {
                        currentEvent.txt_ToAddress__c = header.value?.left(255); 
                    } 
                }
            }
            currentEvent = (CBK_LogEvent__e) getApexLimits(currentEvent);
            EventBus.publish(currentEvent);
            System.debug(LoggingLevel.INFO ,email.subject);
        } else {
            System.debug(LoggingLevel.INFO,email.subject);
        }
    }
    
    public static void auditemailResult(ResultWrapper InputResult, Messaging.InboundEmail email) {
        String stacktrace = new DmlException().getStackTraceString();
        Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        Map<String, String> mapHeaders = new Map<String,String>();
		if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
			currentEvent = new CBK_LogEvent__e();
            currentEvent.CBK_sfdcRecordType__c = recordTypeId;
			currentEvent.txt_User__c = UserInfo.getUserId();
			currentEvent.txt_Message__c = email?.subject?.left(2000);
			currentEvent.txt_Level__c = 'INFO';
			currentEvent.txt_Context__c = (string)THIS_CONTEXT?.left(80);
			currentEvent.txt_stacktrace__c = stacktrace?.left(32000);
			currentEvent.txt_FromAddress__c = email?.fromAddress?.left(255);
			currentEvent.txt_ToAddress__c = '';
			
			currentEvent.CBK_sfdcMessageId__c = email?.messageId?.left(255);
			currentEvent.CBK_sfdcReplyTo__c =  email?.inReplyTo?.left(255);
            currentEvent.CBK_sfdcType__c = 'Resultado';

            currentEvent.CBK_sfdcEmailMessageId__c = String.isNotBlank(InputResult.EmailMessageId) ? InputResult.EmailMessageId : '';
            currentEvent.CBK_sfdcCaseId__c = String.isNotBlank(InputResult.CaseId) ? InputResult.CaseId : '';
            currentEvent.CBK_sfdcResultStatus__c  = String.isNotBlank(InputResult.Status) ? InputResult.Status : '';
            currentEvent.CBK_sfdcResultDetail__c = String.isNotBlank(InputResult.Detail) ? InputResult.Detail.left(255) : '';
           
		   // currentEvent
			if (email?.toAddresses!=null){
				string.join(email.toAddresses,';')?.left(255);
			}
			
			if  (email?.headers!=null){
				for (Messaging.InboundEmail.Header header : email.headers) {
                    mapHeaders.put(header.name, header.value?.left(255));
				}
			}

            if(!mapHeaders.isEmpty()){
                currentEvent.txt_ToAddress__c = mapHeaders.get('X-SFDC-Original-RCPT')?.left(255); 
                currentEvent.CBK_hdReturnPath__c = mapHeaders.get('Return-Path')?.left(255);
                currentEvent.CBK_hdResentMessageId__c = mapHeaders.get('Resent-Message-Id')?.left(255);
                currentEvent.CBK_hdTo__c = mapHeaders.get('To')?.left(255);
                currentEvent.CBK_hdMessageID__c = mapHeaders.get('Message-ID')?.left(255);
                currentEvent.CBK_hdExchangeInboxRulesLoop__c = mapHeaders.get('X-MS-Exchange-Inbox-Rules-Loop')?.left(255);
                currentEvent.CBK_hdResentFrom__c = mapHeaders.get('Resent-From')?.left(255);
                currentEvent.CBK_hdExchangeParentMessageId__c = mapHeaders.get('x-ms-exchange-parent-message-id')?.left(255);
                currentEvent.CBK_hdSFDCOriginalRCPT__c = mapHeaders.get('X-SFDC-Original-RCPT')?.left(255);
                currentEvent.CBK_hdMSHasAttach__c = mapHeaders.get('X-MS-Has-Attach')?.left(255);
                currentEvent.CBK_hdDeliveredTo__c = mapHeaders.get('Delivered-To')?.left(255);
                currentEvent.CBK_hdReference__c = mapHeaders.get('Reference')?.left(255);
                currentEvent.CBK_hdInReplyTo__c = mapHeaders.get('In-Reply-To')?.left(255);
            }
            currentEvent = (CBK_LogEvent__e) getApexLimits(currentEvent);
			EventBus.publish(currentEvent);
			System.debug(LoggingLevel.INFO ,email.subject);
		} else {
			System.debug(LoggingLevel.INFO,email.subject);
		}
    }

    public static void auditemail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		String stacktrace = new DmlException().getStackTraceString();
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        Map<String, String> mapHeaders = new Map<String,String>();
		if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
			currentEvent = new CBK_LogEvent__e();
            currentEvent.CBK_sfdcRecordType__c = recordTypeId;
			currentEvent.txt_User__c = UserInfo.getUserId();
			currentEvent.txt_Message__c = email?.subject?.left(2000);
			currentEvent.txt_Level__c = 'INFO';
			currentEvent.txt_Context__c = (string)THIS_CONTEXT?.left(80);
			currentEvent.txt_stacktrace__c = stacktrace?.left(32000);
			currentEvent.txt_FromAddress__c = email?.fromAddress?.left(255);
			currentEvent.txt_ToAddress__c = '';
			
			currentEvent.CBK_sfdcMessageId__c = email.messageId;
			currentEvent.CBK_sfdcReplyTo__c =  email.inReplyTo;
			currentEvent.CBK_sfdcToAddress__c = envelope.toAddress;
			currentEvent.CBK_sfdcFromAdress__c = envelope.fromAddress;
            currentEvent.CBK_sfdcType__c = 'Entrada';
			

		   // currentEvent
			if (email?.toAddresses!=null){
				string.join(email.toAddresses,';')?.left(255);
			}
			
			if  (email?.headers!=null){
				for (Messaging.InboundEmail.Header header : email.headers) {
                    mapHeaders.put(header.name, header.value?.left(255));
				}
			}

            if(!mapHeaders.isEmpty()){
                currentEvent.txt_ToAddress__c = mapHeaders.get('X-SFDC-Original-RCPT')?.left(255); 
                currentEvent.CBK_hdReturnPath__c = mapHeaders.get('Return-Path')?.left(255);
                currentEvent.CBK_hdResentMessageId__c = mapHeaders.get('Resent-Message-Id')?.left(255);
                currentEvent.CBK_hdTo__c = mapHeaders.get('To')?.left(255);
                currentEvent.CBK_hdMessageID__c = mapHeaders.get('Message-ID')?.left(255);
                currentEvent.CBK_hdExchangeInboxRulesLoop__c = mapHeaders.get('X-MS-Exchange-Inbox-Rules-Loop')?.left(255);
                currentEvent.CBK_hdResentFrom__c = mapHeaders.get('Resent-From')?.left(255);
                currentEvent.CBK_hdExchangeParentMessageId__c = mapHeaders.get('x-ms-exchange-parent-message-id')?.left(255);
                currentEvent.CBK_hdSFDCOriginalRCPT__c = mapHeaders.get('X-SFDC-Original-RCPT')?.left(255);
                currentEvent.CBK_hdMSHasAttach__c = mapHeaders.get('X-MS-Has-Attach')?.left(255);
                currentEvent.CBK_hdDeliveredTo__c = mapHeaders.get('Delivered-To')?.left(255);
                currentEvent.CBK_hdReference__c = mapHeaders.get('Reference')?.left(255);
                currentEvent.CBK_hdInReplyTo__c = mapHeaders.get('In-Reply-To')?.left(255);
            }
            currentEvent = (CBK_LogEvent__e) getApexLimits(currentEvent);
			EventBus.publish(currentEvent);
			System.debug(LoggingLevel.INFO ,email.subject);
		} else {
			System.debug(LoggingLevel.INFO,email.subject);
		}
	}

	private static List<String> cast(List<Object> values) {
		List<String> result = new List<String>();
		for(Object value : values) {
			result.add('' + value);
		}
		return result;
	}

	public static String timestamp() {
		return String.valueof(DateTime.now().getTime());
            //System.now().formatGmt('HH:mm:ss.SSS');
	}


    //Configuración del nivel de traza por custom settings

	private static LogConf LogConfig() {
		AdminSettings__c  settings = AdminSettings__c.getInstance();
        LogConf conf =New LogConf();
        conf.logViaEvents =(settings == null) ? false :  settings.LogViaEvents__c;
        conf.DEBUG =(settings == null) ? false :  settings.LogDEBUG__c;
        conf.INFO =(settings == null) ? false :  settings.LogINFO__c;
        conf.WARN =(settings == null) ? false :  settings.LogWARN__c;
        conf.ERROR =(settings == null) ? false :  settings.LogERROR__C;
        if(settings?.CBK_SnapshotExecutionLimit__c != null){
            conf.SNAPSHOT_EXECUTION_LIMIT = Integer.valueOf(settings.CBK_SnapshotExecutionLimit__c);
        }
        
        return conf;
	}

    
    ///FUNCIONES INVOCADAS POR TRIGGER    


	//Parseo del stacktrace para obtener origen del error (Clase-método-línea)
    public static void populateLocation(CBK_Log__c logEvent) {

		List<String> stacktrace = New List<String>();

        Matcher matcher;
        
        //Consulta en el error ya que trae stacktrace de la línea de error
        if (logEvent.Log_Level__c=='ERROR'){
            stacktrace = logEvent.Log_Message__c?.split('\n');
            if (stacktrace!=null) { 
                for(String line : stacktrace) {
                    system.debug(line);
                    matcher = STACK_LINE.matcher(line);
                    if(line.startsWith('Class.') && matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                        logEvent.Apex_Class__c = matcher.group(1).left(40);
                        logEvent.Apex_Method__c = prettyMethod(matcher.group(2)).left(40);
                        logEvent.num_Line__c = Integer.valueOf(matcher.group(4));
                        return;
                    } 
                }
            }
		}

        //Consulta en el mensaje ya que trae stacktrace de la línea de que ha invocado al log
        String stackTrace_New='';
        if (logEvent.Apex_Class__c==null){
            stacktrace = logEvent.Apex_Stack_Trace__c?.split('\n');
        	
            //Se limpia para eliminar las referencias a la clase de Log
			if (stacktrace!=null) { 
                limpiezaStack(stacktrace);
                logEvent.Apex_Stack_Trace__c = string.join(stacktrace,'\n');
                for(String line : stacktrace) {
                    matcher = STACK_LINE.matcher(line);
                    if(matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                        logEvent.Apex_Class__c = matcher.group(1).left(40);
                        logEvent.Apex_Method__c = prettyMethod(matcher.group(2)).left(40);
                        logEvent.num_Line__c = Integer.valueOf(matcher.group(4));
                        return;
                    } 
                }
            }
		}
	}
    


    public static Messaging.SingleEmailMessage enviomail(CBK_Log__c EvtLog,Id fromaddress,string StrtoAddresses) {
        list<string> toAddresses =StrtoAddresses.split(',');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(fromaddress);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Error: ' + EvtLog.Log_Message__c);
        mail.setBccSender(false);
        mail.setUseSignature(false);


        mail.setHtmlBody('<b> Proyecto: </b>' + EvtLog.Project__c +
                         '<p><b> Clase: </b>' + EvtLog.Apex_Class__c +
                         '<p><b> Método: </b>' + EvtLog.Apex_Method__c +
                         '<p><b> Error : </b>' + EvtLog.Log_Message__c +
                         '<p><b> Apex Stack Trace : </b>' + EvtLog.Apex_Stack_Trace__c?.replace('Class.','<p>Class.').replace('AnonymousBlock','<p>AnonymousBlock') +'<p>');         
        
        return mail;   
    }


    //Limpieza del stacktrace para dejar solo las referencias a Clases

    public static void limpiezaStack(List<String> stacktrace){
        for (Integer i = (stacktrace.size()-1) ; i>= 0 ; i--)
        {
            if(stacktrace.get(i).startsWith('Class.' + CLASSNAME + '.')) {
                stacktrace.remove(i);
            }
            if(stacktrace.get(i).startsWith('Class.System')) {
                stacktrace.remove(i);
            }            
        }
    }
    
	private static String prettyMethod(String method) {
		String result = (method == null) ? 'anonymous' : method;
        result = (method == null) ? 'anonymous' : method;
		return (result.contains('init')) ? 'ctor' : result;
	}

    
    public static void deserializeMsg(CBK_Log__c logEvent){
        Map<String,String> mapname = (Map<String,String>)JSON.deserialize(logEvent.Log_Message__c, Map<String,String>.class);
        for(string id: mapname.keyset()){
            if  (id.toLowerCase() == 'msg')  { logEvent.Log_Message__c = mapname.get(id); }
            if ((id.toLowerCase() == 'cod')  && (mapname.get(id) != '' )) { logEvent.Error_Code__c  = mapname.get(id); }            
            if ((id.toLowerCase() == 'type') && (mapname.get(id) != '' )) { logEvent.Error_Type__c  = mapname.get(id); }            
        }
    }

    public static void createLogWithoutevent(String contextId, LoggingLevel level, Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields, Boolean insertarErrores,String estado){
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId();
        String stacktrace='';
        String errType='';

        if (owea == null){
            owea = [select Id from OrgWideEmailAddress where DisplayName = 'Framework de Login'];
        }

        if (fwLogin == null){
            fwLogin = [select label,proyecto__c, Email_Notif__c, Notif__c from CBK_Framework_Login__mdt];
        }
        
        if (err==null) {
            stacktrace = new DmlException().getStackTraceString();
        } else {
            stacktrace = err.getStackTraceString();
            if (stacktrace?.left(32000)=='()'){
                stacktrace = new DmlException().getStackTraceString();
            }
            errType = err.getTypeName();
        }

        CBK_Log__c EvtLog = New CBK_Log__c();
        EvtLog.RecordTypeId = recordTypeId;
        EvtLog.OwnerId = UserInfo.getUserId();
        EvtLog.Transaction_ID__c=((contextId == null) ? THIS_CONTEXT : '' + contextId).left(80);
        EvtLog.Log_Level__c = level.name();
        EvtLog.Log_Message__c = message?.left(2000);
        EvtLog.Log_Message_Ext__c = message?.left(32000);
        EvtLog.Error_Code__c='';
        EvtLog.Error_Type__c = (errType != NULL) ? (errType +'').left(30) : '';
        EvtLog.Apex_Stack_Trace__c= (stacktrace)?.left(32000);
        EvtLog.createdBy__c =  UserInfo.getUserId();
        EvtLog.Detail__c =  String.join(values,'@Det@')?.left(32000);
        EvtLog.CBK_MessageException__c =  err?.getMessage()?.left(32500);
        EvtLog.createdDate__c = System.now();
        EvtLog.systemModstamp__c = System.now();
        EvtLog.state__c = estado;
        //insertar llamada a limites

        if (mapOptionalFields != null) {
            Set<String> logFields = Schema.SObjectType.CBK_Log__c.fields.getMap().keySet();
            for (String keyMapField : mapOptionalFields.keyset()) {
                if (logFields.contains(keyMapField.toLowerCase())) {
                    EvtLog.put(keyMapField, mapOptionalFields.get(keyMapField));
                }
            }
        }
        populateLocation(EvtLog);
        if (EvtLog.Log_Message__c.left(1)=='{') {
            deserializeMsg(EvtLog);
        }

        String emailNotif;
        Boolean notif;    
        CBK_Framework_Login__mdt conf;
        List<CBK_Log__c> lstLog = New List<CBK_Log__c>();
        Map<String,CBK_Framework_Login__mdt> mapPrj = New Map<String,CBK_Framework_Login__mdt>();
            
        //Configuración de traza por clases o prefijos   
        for (CBK_Framework_Login__mdt prj : fwLogin) {
            mapPrj.put(prj.label, prj);
        }

        emailNotif='';
        notif=false;
        system.debug(EvtLog.Apex_Class__c);
        conf=mapPrj.get(EvtLog.Apex_Class__c);
        if (conf != null){
            EvtLog.Project__c = conf.proyecto__c;
            emailNotif = conf.Email_Notif__c;
            notif = conf.Notif__c;
        } else if (EvtLog.Apex_Class__c?.indexOf('_')>0) {
            conf=mapPrj.get(EvtLog.Apex_Class__c.substring(0,EvtLog.Apex_Class__c.indexOf('_')+1)+'*');
            if (conf != null){
                EvtLog.Project__c = conf.proyecto__c;
                emailNotif = conf.Email_Notif__c;
                notif = conf.Notif__c;
            }
        }
        lstLog.add(EvtLog);
        
        //Notificaciones por mail
        if (notif && (EvtLog.Log_Level__c=='ERROR') && ( owea.size() > 0 ) && (emailNotif!='')) {
            lstmailGeneral.add(enviomail(EvtLog,owea.get(0).Id,emailNotif));

        }
        EvtLog = (CBK_Log__c) getApexLimits(EvtLog);

        if (insertarErrores) {
            Database.SaveResult[] srList = Database.insert(lstLog,false);
            generaDetallesdeErrores(srList);
        }else {
            lstErroresaGuardar.add(EvtLog);
        }
    }

    //Nueva funcion para reutilizar codigo - IOP julio
    public static void generaDetallesdeErrores(Database.SaveResult[] srList){

            List<CBK_Log_Detail__c> lstLogDetail = New List<CBK_Log_Detail__c>();
            Set<String> sId = new Set<String>();
            map<String, CBK_Log__c> mLogsWithDetails =  new map<String, CBK_Log__c>();
            if ( srList != null && srList.size() > 0) {
                for (Database.SaveResult sr : srList) {
                    if (sr.success){
                        sId.add(sr.getId());
                    }
                }
            }
            List<CBK_Log__c> lstlogs = [SELECT Id,Detail__c FROM CBK_Log__c WHERE Id IN :sId];
            if (lstlogs != null && lstlogs.size() > 0) {
                for(CBK_Log__c log : lstlogs){
                    if (!mLogsWithDetails.containsKey(log.Id)){
                        mLogsWithDetails.put(log.Id, log);
                    }
                }
            }      
            List<String> lstDetail =  new List<String>();
            for (CBK_Log__c log : mLogsWithDetails.values()){
                try{
                    lstDetail = String.isNotBlank(log.Detail__c) ? log.Detail__c.split('@Det@') : new List<String>();               
                    for (String det: lstDetail){
                        CBK_Log_Detail__c EvtLogDetail = New CBK_Log_Detail__c();
                        EvtLogDetail.Framework_Logging__c = mLogsWithDetails.containsKey(log.Id)  ?  mLogsWithDetails.get(log.Id).Id : null;
                        EvtLogDetail.Detail__c=det;
                        lstLogDetail.add(EvtLogDetail);   
                    }
                }catch(Exception e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            } 
            Database.insert(lstLogDetail,false);
            // Send the email you have created.
        for (Messaging.SingleEmailMessage msg : lstmailGeneral){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
        }	
    }

    public static void enableSnapshotLimitsLog(String key){
        if(disabledSnapshotLimitsFlagKey.equalsIgnoreCase(key)){
            disabledSnapshotLimitsFlagKey = null;
        }
    }
    public static void disableSnapshotLimitsLog(String key){
        if(String.isEmpty(disabledSnapshotLimitsFlagKey)){
            disabledSnapshotLimitsFlagKey = key;
        }
    }

    public static SObject getApexLimits(SObject log){
        if(String.isEmpty(disabledSnapshotLimitsFlagKey) && consultasLimites < LOG_CONFIG.SNAPSHOT_EXECUTION_LIMIT) {
            log.put('CBK_AggregateQueries__c',Limits.getAggregateQueries());
            log.put('CBK_LimitAggregateQueries__c',Limits.getLimitAggregateQueries());
            log.put('CBK_AsyncCalls__c',Limits.getAsyncCalls());
            log.put('CBK_LimitAsyncCalls__c',Limits.getLimitAsyncCalls());
            log.put('CBK_Callouts__c', Limits.getCallouts());
            log.put('CBK_LimitCallouts__c', Limits.getLimitCallouts());
            log.put('CBK_CpuTime__c', Limits.getCpuTime());
            log.put('CBK_LimitCpuTime__c', Limits.getLimitCpuTime());
            log.put('CBK_DMLRows__c', Limits.getDMLRows());
            log.put('CBK_LimitDMLRows__c', Limits.getLimitDMLRows());
            log.put('CBK_DMLStatements__c', Limits.getDMLStatements());
            log.put('CBK_LimitDMLStatements__c', Limits.getLimitDMLStatements());
            log.put('CBK_EmailInvocations__c', Limits.getEmailInvocations());
            log.put('CBK_LimitEmailInvocations__c', Limits.getLimitEmailInvocations());
            log.put('CBK_FutureCalls__c', Limits.getFutureCalls());
            log.put('CBK_LimitFutureCalls__c', Limits.getLimitFutureCalls());
            log.put('CBK_HeapSize__c', Limits.getHeapSize());
            log.put('CBK_LimitHeapSize__c', Limits.getLimitHeapSize());
            log.put('CBK_MobilePushApexCalls__c', Limits.getMobilePushApexCalls());
            log.put('CBK_LimitMobilePushApexCalls__c', Limits.getLimitMobilePushApexCalls());
            log.put('CBK_PublishImmediateDML__c', Limits.getPublishImmediateDML());
            log.put('CBK_LimitPublishImmediateDML__c', Limits.getLimitPublishImmediateDML());
            log.put('CBK_Queries__c', Limits.getQueries());
            log.put('CBK_LimitQueries__c', Limits.getLimitQueries());
            log.put('CBK_QueryLocatorRows__c', Limits.getQueryLocatorRows());
            log.put('CBK_LimitQueryLocatorRows__c', Limits.getLimitQueryLocatorRows());
            log.put('CBK_QueryRows__c', Limits.getQueryRows());
            log.put('CBK_LimitQueryRows__c', Limits.getLimitQueryRows());
            log.put('CBK_QueueableJobs__c', Limits.getQueueableJobs());
            log.put('CBK_LimitQueueableJobs__c', Limits.getLimitQueueableJobs());
            log.put('CBK_SoslQueries__c', Limits.getSoslQueries());
            log.put('CBK_LimitSoslQueries__c', Limits.getLimitSoslQueries());
            consultasLimites++;
        }
        return log;
    }

    public class ResultWrapper{
		public String Status { get; set; }
		public string Detail { get; set; }
		public String EmailMessageId { get; set; }
        public String CaseId { get; set; }
    }
}