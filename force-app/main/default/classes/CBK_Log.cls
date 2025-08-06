/**
 * @description Framework de procesos de LOG
 */
public with sharing class CBK_Log {

    private static final LogConf LOG_CONFIG = logConfig();
    private static final Boolean LOG_VIA_EVENTS = LOG_CONFIG.logViaEvents;
	private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
	private static final String CLASSNAME = CBK_Log.class.getName();
	private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
	private static final String THIS_CONTEXT = UserInfo.getUserId() + '-' + timestamp();

    private static Id recordTypeIdCBKLogApexLog = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId(); 
    private static String disabledSnapshotLimitsFlagKey;
    private static Integer consultasLimites = 0;
    public static list<CBK_Log__c> lstErroresLogaGuardar = new list<CBK_Log__c>();
    public static list<CBK_LogEvent__e> lstErroresEventaGuardar = new List<CBK_LogEvent__e>();
    private static list<Messaging.SingleEmailMessage> lstmailGeneral = new List<Messaging.SingleEmailMessage>();
    private static OrgWideEmailAddress[] owea{
        set;
        private get{
            if(owea == null){
                owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Framework de Login'];
            }
            return owea;
        }
    } 
    private static List<CBK_Framework_Login__mdt> fwLogin; 
    private static Map<String, String> mapCamposLogEvent = new Map<String, String>{
        'RecordTypeId' => 'CBK_sfdcRecordType__c',
        'OwnerId' => 'txt_User__c',
        'Transaction_ID__c' => 'txt_Context__c',
        'Log_Level__c' => 'txt_Level__c',
        'Log_Message__c' => 'txt_Message__c',
        'Log_Message_Ext__c' => 'txt_Message__c',
        'Error_Code__c' => 'CBK_Error_Code__c',
        'Error_Type__c' => 'txt_ErrType__c',
        'Apex_Stack_Trace__c' => 'txt_stacktrace__c',
        'createdBy__c' => 'txt_User__c',
        'FromAddress__c' => 'txt_FromAddress__c',
        'ToAddress__c' => 'txt_ToAddress__c',
        'subject__c' => 'txt_Message__c',
        'Detail__c' => 'txt_Detail__c',
        'CBK_hdReturnPath__c' => 'CBK_hdReturnPath__c',
        'CBK_hdResentMessageId__c' => 'CBK_hdResentMessageId__c',
        'state__c' => 'CBK_State__c',
        'systemModstamp__c' => 'CBK_SystemModstamp__c',
        'createdDate__c' => 'CBK_CreatedDate__c',
        'Apex_Class__c' => 'CBK_ApexClass__c',
        'Apex_Method__c' => 'CBK_ApexMethod__c',
        'num_Line__c' => 'CBK_LineNumber__c',
        'Project__c' => 'CBK_Project__c'
    };
    private static Set<String> setPicklistValuesCategory;
    
    @TestVisible
	private static CBK_LogEvent__e currentEvent = null;
    
    // DEBUG

    /**
     * @description Emit a Log Event  DEBUG
     * @param message  : Log Message 
     */
	public static void debug(String message) {
        new DebugProcessConfigBuilder()
        .setMessage(message)
        .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event  DEBUG
     * @param message  : Log Message 
     * @param values   : Log Values 
     */
    public static void debug(String message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setValues(values)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event  DEBUG
     * @param contextId : Log ContextId
     * @param message   : Log Message 
     */
	public static void debug(String contextId,String message) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setContextId(contextId)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event  DEBUG
     * @param contextId : Log ContextId
     * @param message   : Log Message 
     * @param values    : Log Values 
     */
	public static void debug(String contextId,String message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setContextId(contextId)
            .setValues(values)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}    
    
    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message 
     * @param level    : Log Level 
     */
	public static void debug(String message,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setLevel(level)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message
     * @param values   : Log Values 
     * @param level    : Log Level 
     */
    public static void debug(String message, List<Object> values,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setLevel(level)
            .setValues(values)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event DEBUG
     * @param message   : Log Message
     * @param contextId : Log ContextId
     * @param level     : Log Level 
     */
	public static void debug(String contextId,String message,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setContextId(contextId)
            .setLevel(level)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event DEBUG
     * @param message   : Log Message
     * @param contextId : Log ContextId
     * @param values    : Log Values 
     * @param level     : Log Level 
     */
	public static void debug(String contextId,String message, List<Object> values,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setContextId(contextId)
            .setLevel(level)
            .setValues(values)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}  


    // DEBUG CON MAP

    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param values   : Log Values 
     * @param level    : Log Level 
     */
	public static void debug(map<String,String> message) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param values   : Log Values
     */
    public static void debug(map<String,String> message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setValues(values)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param contextId : Log ContextId
     */
	public static void debug(String contextId,map<String,String> message) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setContextId(contextId)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param contextId : Log ContextId
     * @param values   : Log Values
     */
	public static void debug(String contextId,map<String,String> message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setContextId(contextId)
            .setValues(values)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}    
    
    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param level    : Log Level 
     */
	public static void debug(map<String,String> message,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setLevel(level)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param values   : Log Values
     * @param level    : Log Level 
     */
    public static void debug(map<String,String> message, List<Object> values,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setValues(values)
            .setLevel(level)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param contextId : Log ContextId
     * @param level    : Log Level 
     */
	public static void debug(String contextId,map<String,String> message,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setContextId(contextId)
            .setLevel(level)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event DEBUG
     * @param message  : Log Message from a MAP
     * @param contextId : Log ContextId
     * @param values   : Log Values
     * @param level    : Log Level 
     */
	public static void debug(String contextId,map<String,String> message, List<Object> values,LoggingLevel level) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setContextId(contextId)
            .setValues(values)
            .setLevel(level)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}  


    // ERROR (Exception)

    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     */
	public static void error(Exception err) {
        new DebugProcessConfigBuilder()
            .setMessage(err.getMessage())
            .setErr(err)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param values   : Log Values
     */
    public static void error(Exception err,List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(err.getMessage())
            .setErr(err)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param contextId : Log ContextId
     */
    public static void error(String contextId,Exception err) {
        new DebugProcessConfigBuilder()
            .setMessage(err.getMessage())
            .setContextId(contextId)
            .setErr(err)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param contextId : Log ContextId
     * @param values   : Log Values
     */
    public static void error(String contextId,Exception err,List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(err.getMessage())
            .setContextId(contextId)
            .setErr(err)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    //ERROR (error Text)

    /**
     * @description Emit a Log Event ERROR
     * @param message   : Exception message
     */
	public static void error(String message) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(String message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param message   : Exception message
     * @param contextId : Log ContextId
     */
	public static void error(String contextId,String message) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setContextId(contextId)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param message   : Exception message
     * @param contextId : Log ContextId
     * @param values   : Log Values
     */
	public static void error(String contextId,String message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    

    //ERROR (error Text (Map))

    /**
     * @description Emit a Log Event ERROR
     * @param message   : Exception message
     */
	public static void error(Map<String,String> message) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(Map<String,String> message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param message   : Exception message
     */
	public static void error(String contextId,Map<String,String> message) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setContextId(contextId)    
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(String contextId,Map<String,String> message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    //ERROR (Exception + error Text(MAP))  
    
    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param message   : Exception message
     */
 	public static void error(Exception err,Map<String,String> message) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setErr(err)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(Exception err,Map<String,String>  message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setErr(err)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     */
	public static void error(String contextId,Exception err,Map<String,String>  message) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setErr(err)
            .setContextId(contextId)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(String contextId,Exception err, Map<String,String>  message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(JSON.serialize(message))
            .setErr(err)
            .setValues(values)
            .setContextId(contextId)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
	//ERROR (Exception + error Text)

    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param message   : Exception message
     */
 	public static void error(Exception err,String message) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(Exception err,String message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     */
	public static void error(String contextId,Exception err,String message) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}

    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     */
	public static void error(String contextId,Exception err,String message, List<Object> values) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
	}
    
    //LOG With Messaging.InboundEmail 

    /**
     * @description Emit a Log Event ERROR
     * @param err       : Exception
     * @param message   : Exception message
     * @param email     : Messaging.InboundEmail
     */
    public static void error(Exception err, String message, Messaging.InboundEmail email) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setEmail(email)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
    }
         
    /**
     * @description Emit a Log Event ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     * @param email     : Messaging.InboundEmail
     */
    public static void error(String contextId,Exception err,String message, List<Object> values, Messaging.InboundEmail email) {
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setValues(values)
            .setEmail(email)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertPlatformEvent();
    } 

    /**
     * @description save ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     */
    public static void saveError(String contextId,Exception err,String message, List<Object> values){
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .addLog();

        CBK_Log.insertDML();
	}

    /**
     * @description save ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     * @param mapOptionalFields : optional fields
     */
    public static void saveError(String contextId,Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields){
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .setMapOptionalFields(mapOptionalFields)
            .addLog();
            
        CBK_Log.insertDML();
	}

    /**
     * @description save ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     * @param mapOptionalFields : optional fields
     * @param estado : state
     */
    public static void saveError(String contextId,Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields,String estado){
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .setMapOptionalFields(mapOptionalFields)
            .setState(estado)
            .addLog();
            
            CBK_Log.insertDML();
	}

    /**
     * @description add ERROR
     * @param contextId : Log ContextId
     * @param err       : Exception
     * @param message   : Exception message
     * @param values   : Log Values
     * @param mapOptionalFields : optional fields
     */
    public static void addError(String contextId,Exception err,String message, List<Object> values, Map<String,String> mapOptionalFields){
        // Le pasamos false al ultimo paramtero para que no guarde en la base de datos el registro
        new DebugProcessConfigBuilder()
            .setMessage(message)
            .setErr(err)
            .setContextId(contextId)
            .setValues(values)
            .setLevel(LoggingLevel.ERROR)
            .setMapOptionalFields(mapOptionalFields)
            .addLog();
    }

    /**
     * @description Insert the list of Plateform Event to the Event BUS
     */
    public static void insertPlatformEvent(){
        if(!lstErroresEventaGuardar.isEmpty() && (LOG_VIA_EVENTS || Test.isRunningTest())){
            Database.SaveResult[] resltPub = EventBus.publish(lstErroresEventaGuardar);
            lstErroresEventaGuardar.clear();
        }
	}

    /**
     * @description Insert the list of Event Object Record to the DB
     */
    public static void insertDML(){
        //Se mira si hay entradas de CBK_LogEvent__e a pasar a CBK_Log__c
        if(!lstErroresEventaGuardar.isEmpty()){
            for(CBK_LogEvent__e e : lstErroresEventaGuardar){
                //Se crea el CBK_Log__c a partir del CBK_LogEvent__e
                CBK_Log__c log = CBK_Log.generateLogFromEvent(e);
                lstErroresLogaGuardar.add(log);
            }
        }

        //Se procesan los CBK_Log__c
        if(!lstErroresLogaGuardar.isEmpty()){
            Database.SaveResult[] resltIns = Database.insert(lstErroresLogaGuardar,false);
            generaDetallesdeErrores(resltIns);
            lstErroresLogaGuardar.clear();
        }
	}
    
    /**
     * @description Methode to Emit a Event (or System DEBUG) from an Audit Email 
     * @param email     : Inbound Email
     */
	public static void auditemail(Messaging.InboundEmail email) {
        if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
            String stacktrace = new DmlException().getStackTraceString();
            Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId();

            // populate ToAddress
            String txtToAddress = '';
            if (email?.toAddresses != null){
                txtToAddress = String.join(email.toAddresses,';');
            }
            if  (email?.headers != null){
                for (Messaging.InboundEmail.Header header : email.headers) {
                    if (header.name == 'X-SFDC-Original-RCPT') {
                        txtToAddress = header.value; 
                    } 
                }
            }

            DebugProcessConfigBuilder myBuilder = new DebugProcessConfigBuilder()
                .setEmail(email)
                .setRecordTypeId(recordTypeId)
                .setTxtUser(UserInfo.getUserId())
                .setMessage(email?.subject)
                .setLevel(LoggingLevel.INFO)
                .setContextId((string)THIS_CONTEXT)
                .setTxtStacktrace(stacktrace)
                .setTxtFromAddress(email?.fromAddress)
                .setTxtToAddress(txtToAddress)
                .setForce(true);
            myBuilder.addLog();

            CBK_Log.insertPlatformEvent();

            //Se busca si existen entradas de CBK_Log de RT 'CBK_AutditEmail' a invalidar
            invalidarLogPerdido(email?.messageId);

            System.debug(myBuilder.getLevel(), myBuilder.getMessage());
        } else {
            System.debug(LoggingLevel.INFO, email?.subject);
        }
    }

    /**
     * @description Methode to Emit a Event (or System DEBUG) from an Audit Email and Envelope
     * @param email        : Inbound Email
     * @param envelope     : Inbound Envelope
     */
    public static void auditemail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
            Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
            Map<String, String> mapHeaders = new Map<String,String>();

            // populate ToAddress
            String txtToAddress = '';
            if (email?.toAddresses != null){
                txtToAddress = String.join(email.toAddresses,';');
            }

            DebugProcessConfigBuilder myBuilder = new DebugProcessConfigBuilder()
                .setRecordTypeId(recordTypeId)
                .setTxtUser(UserInfo.getUserId())
                .setMessage(email?.subject)
                .setLevel(LoggingLevel.INFO)
                .setContextId((string)THIS_CONTEXT)
                .setTxtStacktrace(new DmlException().getStackTraceString())
                .setTxtFromAddress(email?.fromAddress)
                .setTxtToAddress(txtToAddress)
                .setSfdcMessageId(email?.messageId)
                .setSfdcReplyTo(email?.inReplyTo)
                .setSfdcToAddress(envelope.toAddress)
                .setSfdcFromAddress(envelope.fromAddress)
                .setSfdcType('Entrada')
                .setForce(true);
            if  (email?.headers != null){
                for (Messaging.InboundEmail.Header header : email.headers) {
                    mapHeaders.put(header.name, header.value?.left(255));
                }
            }

            if(!mapHeaders.isEmpty()){
                myBuilder.setTxtToAddress(mapHeaders.get('X-SFDC-Original-RCPT'))
                    .setHdReturnPath(mapHeaders.get('Return-Path'))
                    .setHdResentMessageId(mapHeaders.get('Resent-Message-Id'))
                    .setHdTo(mapHeaders.get('To'))
                    .setHdMessageID(mapHeaders.get('Message-ID'))
                    .setHdExchangeInboxRulesLoop(mapHeaders.get('X-MS-Exchange-Inbox-Rules-Loop'))
                    .setHdResentFrom(mapHeaders.get('Resent-From'))
                    .setHdExchangeParentMessageId(mapHeaders.get('x-ms-exchange-parent-message-id'))
                    .setHdSFDCOriginalRCPT(mapHeaders.get('X-SFDC-Original-RCPT'))
                    .setHdMSHasAttach(mapHeaders.get('X-MS-Has-Attach'))
                    .setHdDeliveredTo(mapHeaders.get('Delivered-To'))
                    .setHdReference(mapHeaders.get('Reference'))
                    .setHdInReplyTo(mapHeaders.get('In-Reply-To'));
            }

            myBuilder.addLog();
            CBK_Log.insertPlatformEvent();

            //Se busca si existen entradas de CBK_Log de RT 'CBK_AutditEmail' a invalidar
            invalidarLogPerdido(email?.messageId);

			System.debug(myBuilder.getLevel(), myBuilder.getMessage());
        } else {
            System.debug(LoggingLevel.INFO, email?.subject);
        }
	}

    /**
     * @description Methode to Emit a Event (or System DEBUG) from an Audit Email and Envelope
     * @param email        : Inbound Email
     * @param inputResult  : Result Wrapper
     */
    public static void auditemailResult(ResultWrapper inputResult, Messaging.InboundEmail email) {
		if((LOG_VIA_EVENTS) || (Test.isRunningTest())){
            Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
            Map<String, String> mapHeaders = new Map<String,String>();

            // populate ToAddress
            String txtToAddress = '';
            if (email?.toAddresses != null){
                txtToAddress = String.join(email.toAddresses,';');
            }

            DebugProcessConfigBuilder myBuilder = new DebugProcessConfigBuilder()
                .setRecordTypeId(recordTypeId)
                .setTxtUser(UserInfo.getUserId())
                .setMessage(email?.subject)
                .setLevel(LoggingLevel.INFO)
                .setContextId((string)THIS_CONTEXT)
                .setTxtStacktrace(new DmlException().getStackTraceString())
                .setTxtFromAddress(email?.fromAddress)
                .setTxtToAddress(txtToAddress)
                .setSfdcMessageId(email?.messageId)
                .setSfdcReplyTo(email?.inReplyTo)
                .setSfdcType('Resultado')
                .setSfdcEmailMessageId(String.isNotBlank(inputResult.EmailMessageId) ? inputResult.EmailMessageId : '')
                .setSfdcCaseId(String.isNotBlank(inputResult.CaseId) ? inputResult.CaseId : '')
                .setSfdcResultStatus(String.isNotBlank(inputResult.Status) ? inputResult.Status : '')
                .setSfdcResultDetail(String.isNotBlank(inputResult.Detail) ? inputResult.Detail : '')
                .setForce(true);
            if  (email?.headers != null){
                for (Messaging.InboundEmail.Header header : email.headers) {
                    mapHeaders.put(header.name, header.value?.left(255));
                }
            }

            if(!mapHeaders.isEmpty()){
                myBuilder.setTxtToAddress(mapHeaders.get('X-SFDC-Original-RCPT'))
                    .setHdReturnPath(mapHeaders.get('Return-Path'))
                    .setHdResentMessageId(mapHeaders.get('Resent-Message-Id'))
                    .setHdTo(mapHeaders.get('To'))
                    .setHdMessageID(mapHeaders.get('Message-ID'))
                    .setHdExchangeInboxRulesLoop(mapHeaders.get('X-MS-Exchange-Inbox-Rules-Loop'))
                    .setHdResentFrom(mapHeaders.get('Resent-From'))
                    .setHdExchangeParentMessageId(mapHeaders.get('x-ms-exchange-parent-message-id'))
                    .setHdSFDCOriginalRCPT(mapHeaders.get('X-SFDC-Original-RCPT'))
                    .setHdMSHasAttach(mapHeaders.get('X-MS-Has-Attach'))
                    .setHdDeliveredTo(mapHeaders.get('Delivered-To'))
                    .setHdReference(mapHeaders.get('Reference'))
                    .setHdInReplyTo(mapHeaders.get('In-Reply-To'));
            }

            myBuilder.addLog();
            CBK_Log.insertPlatformEvent();

            //Se busca si existen entradas de CBK_Log de RT 'CBK_AutditEmail' a invalidar
            invalidarLogPerdido(email?.messageId);

			System.debug(myBuilder.getLevel(), myBuilder.getMessage());
        } else {
            System.debug(LoggingLevel.INFO, email?.subject);
        }
    }

    /**
     * @description generate errors detail records
     * @param srList         : SaveResult List
     */
    public static void generaDetallesdeErrores(Database.SaveResult[] srList){

        List<CBK_Log_Detail__c> lstLogDetail = new List<CBK_Log_Detail__c>();
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
                    CBK_Log_Detail__c evtLogDetail = new CBK_Log_Detail__c();
                    evtLogDetail.Framework_Logging__c = mLogsWithDetails.containsKey(log.Id) ? mLogsWithDetails.get(log.Id).Id : null;
                    evtLogDetail.Detail__c = det;
                    lstLogDetail.add(evtLogDetail);   
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

    /**
     * @description Methode to get current Time
     * @return Text of timestamp
     */
	public static String timestamp() {
		return String.valueof(DateTime.now().getTime());
	}

    /**
     * @description Configuración del nivel de traza por custom settings
     * @return Log Config
     */
	private static LogConf logConfig() {
		AdminSettings__c  settings = AdminSettings__c.getInstance();
        LogConf conf = new LogConf();
        conf.logViaEvents =(settings == null) ? false :  settings.LogViaEvents__c;
        conf.debug =(settings == null) ? false :  settings.LogDEBUG__c;
        conf.info =(settings == null) ? false :  settings.LogINFO__c;
        conf.warn =(settings == null) ? false :  settings.LogWARN__c;
        conf.error =(settings == null) ? false :  settings.LogERROR__C;
        if(settings?.CBK_SnapshotExecutionLimit__c != null){
            conf.snapshotExecutionLimit = Integer.valueOf(settings.CBK_SnapshotExecutionLimit__c);
        }
        
        return conf;
	}

    
    // FUNCIONES INVOCADAS POR TRIGGER    
    /**
     * @description Parseo del stacktrace para obtener origen del error (Clase-método-línea)
     * @param logEvent  : CBK_LogEvent__e
     * @return logEvent
     * 
     */
    public static CBK_LogEvent__e populateLocation(CBK_LogEvent__e logEvent) {

		List<String> stacktrace = new List<String>();
        Matcher matcher;
        
        //Consulta en el error ya que trae stacktrace de la línea de error
        if (logEvent.txt_Level__c == 'ERROR'){
            stacktrace = logEvent.txt_Message__c?.split('\n');
            if (stacktrace != null) { 
                for(String line : stacktrace) {
                    matcher = STACK_LINE.matcher(line);
                    if(line.startsWith('Class.') && matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                        logEvent.CBK_ApexClass__c = matcher.group(1).left(40);
                        logEvent.CBK_ApexMethod__c = prettyMethod(matcher.group(2)).left(40);
                        logEvent.CBK_LineNumber__c = Integer.valueOf(matcher.group(4));
                        return logEvent;
                    } 
                }
            }
		}

        //Consulta en el mensaje ya que trae stacktrace de la línea de que ha invocado al log
        if (logEvent.CBK_ApexClass__c == null){
            stacktrace = logEvent.txt_stacktrace__c?.split('\n');
        	
            //Se limpia para eliminar las referencias a la clase de Log
			if (stacktrace != null) { 
                limpiezaStack(stacktrace);
                logEvent.txt_stacktrace__c = string.join(stacktrace,'\n');
                for(String line : stacktrace) {
                    matcher = STACK_LINE.matcher(line);
                    if(matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                        logEvent.CBK_ApexClass__c = matcher.group(1).left(40);
                        logEvent.CBK_ApexMethod__c = prettyMethod(matcher.group(2)).left(40);
                        logEvent.CBK_LineNumber__c = Integer.valueOf(matcher.group(4));
                        return logEvent;
                    } 
                }
            }
		}

        return logEvent;
	}

    /**
     * @description Methode to send an email
     * @param evtLog            : record of CBK_Log__c
     * @param fromaddress       : Id of the address
     * @param strtoAddresses    : String of the addresses
     * @return The Single Email Message
     */
    public static Messaging.SingleEmailMessage enviomail(CBK_Log__c evtLog,Id fromaddress,String strtoAddresses) {
        list<string> toAddresses = strtoAddresses.split(',');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(fromaddress);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Error: ' + evtLog.Log_Message__c);
        mail.setBccSender(false);
        mail.setUseSignature(false);


        mail.setHtmlBody('<b> Proyecto: </b>' + evtLog.Project__c +
                         '<p><b> Clase: </b>' + evtLog.Apex_Class__c +
                         '<p><b> Método: </b>' + evtLog.Apex_Method__c +
                         '<p><b> Error : </b>' + evtLog.Log_Message__c +
                         '<p><b> Apex Stack Trace : </b>' + evtLog.Apex_Stack_Trace__c?.replace('Class.','<p>Class.').replace('AnonymousBlock','<p>AnonymousBlock') +'<p>');         
        
        return mail;   
    }

    /**
     * @description Methode to send an email
     * @param evtLog            : record of CBK_LogEvent__e
     * @param fromaddress       : Id of the address
     * @param strtoAddresses    : String of the addresses
     * @return The Single Email Message
     */
    public static Messaging.SingleEmailMessage enviomail(CBK_LogEvent__e evtLog,Id fromaddress,String strtoAddresses) {
        list<string> toAddresses = strtoAddresses.split(',');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(fromaddress);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Error: ' + evtLog.txt_Message__c);
        mail.setBccSender(false);
        mail.setUseSignature(false);


        mail.setHtmlBody('<b> Proyecto: </b>' + evtLog.CBK_Project__c +
                         '<p><b> Clase: </b>' + evtLog.CBK_ApexClass__c +
                         '<p><b> Método: </b>' + evtLog.CBK_ApexMethod__c +
                         '<p><b> Error : </b>' + evtLog.txt_Message__c +
                         '<p><b> Apex Stack Trace : </b>' + evtLog.txt_stacktrace__c?.replace('Class.','<p>Class.').replace('AnonymousBlock','<p>AnonymousBlock') +'<p>');         
        
        return mail;   
    }

    /**
     * @description Limpieza del stacktrace para dejar solo las referencias a Clases
     * @param stacktrace    : list of stacktrace to be cleaned
     */
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
    
    /**
     * @description Limpieza del stacktrace para dejar solo las referencias a Clases
     * @param method    : Apex Method to be prettify
     * @return prettified Apex Method
     */
	private static String prettyMethod(String method) {
		String result = (method == null) ? 'anonymous' : method;
		return (result.contains('init')) ? 'ctor' : result;
	}

    private static void invalidarLogPerdido(String sMessageIdentifier){
        //Se buscan las entradas de CBK_Log existentes de RT 'CBK_AutditEmail' y tipo 'Perdido' que tengan el check de válido a true
        Id sRecordTypeIdAutditEmail = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        List<CBK_Log__c> listLogsPerdidos = [SELECT Id, CBK_Valido__c
                                             FROM CBK_Log__c
                                             WHERE CBK_sfdcMessageId__c = :sMessageIdentifier
                                             AND RecordTypeId = :sRecordTypeIdAutditEmail
                                             AND CBK_sfdcType__c = 'Perdido'
                                             AND CBK_Valido__c = true];
        if(!listLogsPerdidos.isEmpty()){
            for(CBK_Log__c oLogPerdido : listLogsPerdidos){
                oLogPerdido.CBK_Valido__c = false;
            }
        }
        //Se actualizan las entradas
        Database.update(listLogsPerdidos,false);
    }

    /**
     * @description Deserialize the log message
     * @param logEvent    : record of CBK_Log__c
     * @return prettified Apex Method
     */
    public static CBK_Log__c deserializeMsg(CBK_Log__c logEvent){
        Map<String,String> mapname = (Map<String,String>)JSON.deserialize(logEvent.Log_Message__c, Map<String,String>.class);
        for(string id: mapname.keyset()){
            if  (id.toLowerCase() == 'msg')  { logEvent.Log_Message__c = mapname.get(id); }
            if ((id.toLowerCase() == 'cod')  && (mapname.get(id) != '' )) { logEvent.Error_Code__c  = mapname.get(id); }            
            if ((id.toLowerCase() == 'type') && (mapname.get(id) != '' )) { logEvent.Error_Type__c  = mapname.get(id); }            
        }
        return logEvent;
    }

    /**
     * @description Deserialize the log message
     * @param logEvent    : record of CBK_LogEvent__e
     * @return prettified Apex Method
     */
    public static CBK_LogEvent__e deserializeMsg(CBK_LogEvent__e logEvent){
        Map<String,String> mapname = (Map<String,String>)JSON.deserialize(logEvent.txt_Message__c, Map<String,String>.class);
        for(string id: mapname.keyset()){
            if  (id.toLowerCase() == 'msg')  { logEvent.txt_Message__c = mapname.get(id); }
            if ((id.toLowerCase() == 'cod')  && (mapname.get(id) != '' )) { logEvent.CBK_Error_Code__c  = mapname.get(id); }            
            if ((id.toLowerCase() == 'type') && (mapname.get(id) != '' )) { logEvent.txt_ErrType__c  = mapname.get(id); }            
        }
        return logEvent;
    }

    /**
     * @description Method to enabled Snapshot Limits Log
     * @param key
     */
    public static void enableSnapshotLimitsLog(String key){
        if(disabledSnapshotLimitsFlagKey.equalsIgnoreCase(key)){
            disabledSnapshotLimitsFlagKey = null;
        }
    }

    /**
     * @description Method to disable Snapshot Limits Log
     * @param key
     */
    public static void disableSnapshotLimitsLog(String key){
        if(String.isEmpty(disabledSnapshotLimitsFlagKey)){
            disabledSnapshotLimitsFlagKey = key;
        }
    }

    /**
     * @description Method to calculate the Project
     * @param key
     */
    public static Map<String, String> calculateProject(Map<String, CBK_Framework_Login__mdt> mapPrj, String sApexClass){
        //Map en la que almacenar la información a devolver
        Map<String, String> mapRespuesta = new Map<String, String>();
        mapRespuesta.put('project', null);
        mapRespuesta.put('emailNotif', '');
        mapRespuesta.put('notif', 'false');

        //Se calcula el proyecto a partir de la configuración del Framework de Login
        CBK_Framework_Login__mdt oConf = mapPrj.get(sApexClass);
        if (oConf == null){
            oConf = mapPrj.get(sApexClass.substring(0, sApexClass.indexOf('_') + 1) + '*');
        }

        //Si se consigue, se devuelve su configuración
        if(oConf != null){
            mapRespuesta.put('project', oConf.proyecto__c);
            mapRespuesta.put('emailNotif', oConf.Email_Notif__c);
            mapRespuesta.put('notif', oConf.Notif__c.toString());
        }

        //Retorno
        return mapRespuesta;
    }

    /**
     * @description Method to get the APEX Limits
     * @param log    : sObject Log record to put the limit into it
     * @return log with the limits inside
     */
    public static SObject getApexLimits(SObject log){
        if(String.isEmpty(disabledSnapshotLimitsFlagKey) && consultasLimites < LOG_CONFIG.snapshotExecutionLimit) {
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

    /**
     * @description Method to generate a CBK_Log from a CBK_LogEvent__e
     * @param event : CBK_LogEvent__e to extract data from
     * @return CBK_Log with all the data
     */
    public static CBK_Log__c generateLogFromEvent(CBK_LogEvent__e event){
        CBK_Log__c log = New CBK_Log__c();
        log.RecordTypeId = String.isNotBlank(event.CBK_sfdcRecordType__c) ? event.CBK_sfdcRecordType__c : recordTypeIdCBKLogApexLog;
        log.OwnerId = event.txt_User__c;
        log.Transaction_ID__c=event.txt_Context__c?.left(30); 
        log.Log_Level__c = event.txt_Level__c;
        log.Log_Message__c = event.txt_Message__c?.left(2000);
        log.Log_Message_Ext__c = event.txt_Message__c?.left(32000);
        log.Error_Code__c='';
        log.Error_Type__c = (event.txt_ErrType__c != NULL) ? (event.txt_ErrType__c+'').left(30) : '';
        log.Apex_Stack_Trace__c= (event.txt_stacktrace__c)?.left(32000);
        log.createdBy__c = event.txt_User__c; 
        log.FromAddress__c = (event.txt_FromAddress__c)?.left(255); 
        log.ToAddress__c = (event.txt_ToAddress__c)?.left(255);
        log.subject__c = (event.txt_Message__c)?.left(255);
        log.Detail__c = (event.txt_Detail__c)?.left(32000);
        log.CBK_hdReturnPath__c = (event.CBK_hdReturnPath__c)?.left(255);
        log.CBK_hdResentMessageId__c = (event.CBK_hdResentMessageId__c)?.left(255);
        log.CBK_hdTo__c = (event.CBK_hdTo__c)?.left(255);
        log.CBK_hdMessageID__c = (event.CBK_hdMessageID__c)?.left(255);
        log.CBK_hdExchangeInboxRulesLoop__c = (event.CBK_hdExchangeInboxRulesLoop__c)?.left(255);
        log.CBK_hdResentFrom__c = (event.CBK_hdResentFrom__c)?.left(255);
        log.CBK_hdExchangeParentMessageId__c = (event.CBK_hdExchangeParentMessageId__c)?.left(255);
        log.CBK_hdSFDCOriginalRCPT__c = (event.CBK_hdSFDCOriginalRCPT__c)?.left(255);
        log.CBK_hdMSHasAttach__c = (event.CBK_hdMSHasAttach__c)?.left(255);
        log.CBK_hdDeliveredTo__c = (event.CBK_hdDeliveredTo__c)?.left(255);
        log.CBK_hdReference__c = (event.CBK_hdReference__c)?.left(255);
        log.CBK_hdInReplyTo__c = (event.CBK_hdInReplyTo__c)?.left(255);
        log.CBK_sfdcMessageId__c = (event.CBK_sfdcMessageId__c)?.left(255);
        log.CBK_sfdcReplyTo__c = (event.CBK_sfdcReplyTo__c)?.left(255);
        log.CBK_sfdcToAddress__c = (event.CBK_sfdcToAddress__c)?.left(255);
        log.CBK_sfdcFromAdress__c = (event.CBK_sfdcFromAdress__c)?.left(255);
        log.CBK_sfdcEmailMessageId__c = String.isNotBlank(event.CBK_sfdcEmailMessageId__c) ? event.CBK_sfdcEmailMessageId__c : '';
        log.CBK_sfdcCaseId__c = String.isNotBlank(event.CBK_sfdcCaseId__c) ? event.CBK_sfdcCaseId__c : '';
        log.CBK_sfdcResultStatus__c  = String.isNotBlank(event.CBK_sfdcResultStatus__c) ? event.CBK_sfdcResultStatus__c : '';
        log.CBK_sfdcResultDetail__c = String.isNotBlank(event.CBK_sfdcResultDetail__c) ? event.CBK_sfdcResultDetail__c : '';
        log.CBK_MessageException__c = (event.CBK_MessageException__c)?.left(32500);
        log.CBK_sfdcType__c = event.CBK_sfdcType__c;

        log.CBK_AggregateQueries__c  = event.CBK_AggregateQueries__c;
        log.CBK_LimitAggregateQueries__c  = event.CBK_LimitAggregateQueries__c;
        log.CBK_AsyncCalls__c  = event.CBK_AsyncCalls__c;
        log.CBK_LimitAsyncCalls__c  = event.CBK_LimitAsyncCalls__c;
        log.CBK_Callouts__c  = event.CBK_Callouts__c;
        log.CBK_LimitCallouts__c  = event.CBK_LimitCallouts__c;
        log.CBK_CpuTime__c  = event.CBK_CpuTime__c;
        log.CBK_LimitCpuTime__c  = event.CBK_LimitCpuTime__c;
        log.CBK_DMLRows__c  = event.CBK_DMLRows__c;
        log.CBK_LimitDMLRows__c  = event.CBK_LimitDMLRows__c;
        log.CBK_DMLStatements__c  = event.CBK_DMLStatements__c;
        log.CBK_LimitDMLStatements__c  = event.CBK_LimitDMLStatements__c;
        log.CBK_EmailInvocations__c  = event.CBK_EmailInvocations__c;
        log.CBK_LimitEmailInvocations__c  = event.CBK_LimitEmailInvocations__c;
        log.CBK_FutureCalls__c  = event.CBK_FutureCalls__c;
        log.CBK_LimitFutureCalls__c  = event.CBK_LimitFutureCalls__c;
        log.CBK_HeapSize__c  = event.CBK_HeapSize__c;
        log.CBK_LimitHeapSize__c  = event.CBK_LimitHeapSize__c;
        log.CBK_MobilePushApexCalls__c  = event.CBK_MobilePushApexCalls__c;
        log.CBK_LimitMobilePushApexCalls__c  = event.CBK_LimitMobilePushApexCalls__c;
        log.CBK_PublishImmediateDML__c  = event.CBK_PublishImmediateDML__c;
        log.CBK_LimitPublishImmediateDML__c  = event.CBK_LimitPublishImmediateDML__c;
        log.CBK_Queries__c  = event.CBK_Queries__c;
        log.CBK_LimitQueries__c  = event.CBK_LimitQueries__c;
        log.CBK_QueryLocatorRows__c  = event.CBK_QueryLocatorRows__c;
        log.CBK_LimitQueryLocatorRows__c  = event.CBK_LimitQueryLocatorRows__c;
        log.CBK_QueryRows__c  = event.CBK_QueryRows__c;
        log.CBK_LimitQueryRows__c  = event.CBK_LimitQueryRows__c;
        log.CBK_QueueableJobs__c  = event.CBK_QueueableJobs__c;
        log.CBK_LimitQueueableJobs__c  = event.CBK_LimitQueueableJobs__c;
        log.CBK_SoslQueries__c  = event.CBK_SoslQueries__c;
        log.CBK_LimitSoslQueries__c  = event.CBK_LimitSoslQueries__c;
        log.CBK_Category__c = event.CBK_Category__c;
        log.createdDate__c = event.CBK_CreatedDate__c;
        log.Project__c = event.CBK_Project__c;
        log.Apex_Class__c = event.CBK_ApexClass__c;
        log.Apex_Method__c = event.CBK_ApexMethod__c;
        log.num_Line__c = event.CBK_LineNumber__c;

        return log;
    }

    // Result Wrapper Class
    public class ResultWrapper{
		public String Status { get; set; }
		public string Detail { get; set; }
		public String EmailMessageId { get; set; }
        public String CaseId { get; set; }
    }

    // Log Configuration Wrapper Class
    public class LogConf {
        Boolean logViaEvents;
        Boolean debug = false;
        Boolean info = false;
        Boolean warn = false;
        Boolean error = true;    
        Integer snapshotExecutionLimit = 10000;    
    }
     
    // Wrapper Class Builder (Mutable)
    public with sharing class DebugProcessConfigBuilder {

        String contextId;
        String message;
        List<Object> values;
        LoggingLevel level;
        Boolean force;
        Exception err;
        Messaging.InboundEmail email;
        String category;
        ResultWrapper inputResult;
        Messaging.InboundEnvelope envelope;
        Boolean sendMail = false;

        //Variables para sincronizar entidades
        String txtUser;
        String txtstacktrace;
        String txtDetail;
        String txtFromAddress;
        String txtToAddress;
        String sfdcMessageId;
        String messageException;
        String sfdcReplyTo;
        String sfdcType;
        String sfdcEmailMessageId;
        String sfdcCaseId;
        String sfdcResultStatus;
        String sfdcResultDetail;
        String sfdcToAddress;
        String sfdcFromAddress;
        String hdReturnPath;
        String hdResentMessageId;
        String hdTo;
        String hdMessageID;
        String hdExchangeInboxRulesLoop;
        String hdResentFrom;
        String hdExchangeParentMessageId;
        String hdSFDCOriginalRCPT;
        String hdMSHasAttach;
        String hdDeliveredTo;
        String hdReference;
        String hdInReplyTo;
        String recordTypeId;
        String ownerId;
        String transactionID;
        String logMessage;
        String logMessageExt;
        String errorCode;
        String errorType;
        String createdBy;
        String detail;
        Datetime createdDate;
        Datetime systemModstamp;
        String state;
        Map<String, String> mapOptionalFields;

        // Constructor
        public DebugProcessConfigBuilder () {
            this.message = '';
            this.values = new List<Object>();
            this.level = LoggingLevel.DEBUG;
            this.force = false;
            this.email = new Messaging.InboundEmail();
        }

        // Getters
        public String getcontextId() { return contextId; }
        public String getmessage() { return message; }
        public  List<Object> getvalues() { return values; }
        public LoggingLevel getlevel() { return level; }
        public Boolean getforce() { return force; }
        public Exception geterr() { return err; }
        public Messaging.InboundEmail getemail() { return email; }
        public String getCategory() { return category; } 
        public ResultWrapper getInputResult() { return inputResult; } 
        public Messaging.InboundEnvelope getEnvelope() { return envelope; } 
        public Boolean getSendMail() { return sendMail; }

        //Variables para sincronizar entidades
        public String getTxtUser() { return txtUser; }
        public String getTxtstacktrace() { return txtstacktrace; }
        public String getTxtDetail() { return txtDetail; }
        public String getTxtFromAddress() { return txtFromAddress; }
        public String getTxtToAddress() { return txtToAddress; }
        public String getSfdcMessageId() { return sfdcMessageId; }
        public String getMessageException() { return messageException; }
        public String getSfdcReplyTo() { return sfdcReplyTo; }
        public String getSfdcType() { return sfdcType; }
        public String getSfdcEmailMessageId() { return sfdcEmailMessageId; }
        public String getSfdcCaseId() { return sfdcCaseId; }
        public String getSfdcResultStatus() { return sfdcResultStatus; }
        public String getSfdcResultDetail() { return sfdcResultDetail; }
        public String getSfdcToAddress() { return sfdcToAddress; }
        public String getSfdcFromAddress() { return sfdcFromAddress; }
        public String getHdReturnPath() { return hdReturnPath; }
        public String getHdResentMessageId() { return hdResentMessageId; }
        public String getHdTo() { return hdTo; }
        public String getHdMessageID() { return hdMessageID; }
        public String getHdExchangeInboxRulesLoop() { return hdExchangeInboxRulesLoop; }
        public String getHdResentFrom() { return hdResentFrom; }
        public String getHdExchangeParentMessageId() { return hdExchangeParentMessageId; }
        public String getHdSFDCOriginalRCPT() { return hdSFDCOriginalRCPT; }
        public String getHdMSHasAttach() { return hdMSHasAttach; }
        public String getHdDeliveredTo() { return hdDeliveredTo; }
        public String getHdReference() { return hdReference; }
        public String getHdInReplyTo() { return hdInReplyTo; }
        public String getRecordTypeId() { return recordTypeId; }
        public String getOwnerId() { return ownerId; }
        public String getTransactionID() { return transactionID; }
        public String getLogMessage() { return logMessage; }
        public String getLogMessageExt() { return logMessageExt; }
        public String getErrorCode() { return errorCode; }
        public String getErrorType() { return errorType; }
        public String getCreatedBy() { return createdBy; }
        public String getDetail() { return detail; }
        public Datetime getCreatedDate() { return createdDate; }
        public Datetime getSystemModstamp() { return systemModstamp; }
        public String getState() { return state; }
        public Map<String, String> getMapOptionalFields() { return mapOptionalFields; }

        // Métodos del Builder para establecer los valores
        public DebugProcessConfigBuilder setEmail(Messaging.InboundEmail email) {
            this.email = email;
            return this;
        }

        public DebugProcessConfigBuilder setErr(Exception err) {
            this.err = err;
            return this;
        }

        public DebugProcessConfigBuilder setForce(Boolean force) {
            this.force = force;
            return this;
        }

        public DebugProcessConfigBuilder setSendMail(Boolean sendMail) {
            this.sendMail = sendMail;
            return this;
        }

        public DebugProcessConfigBuilder setContextId(String contextId) {
            this.contextId = contextId;
            return this;
        }

        public DebugProcessConfigBuilder setMessage(String message) {
            this.message = message;
            return this;
        }
        
        public DebugProcessConfigBuilder setValues(List<Object> values) {
            this.values = values;
            return this;
        }
        
        public DebugProcessConfigBuilder setValue(Object value) {
            this.values.add(value);
            return this;
        }
        
        public DebugProcessConfigBuilder setLevel(LoggingLevel level) {
            this.level = level;
            return this;
        }

        public DebugProcessConfigBuilder setTrace(LoggingLevel level) {
            this.level = level;
            return this;
        }

        public DebugProcessConfigBuilder setCategory(String category) {
            //Se recuperan todos los valores posibles, para guardarlos en caché para comprobaciones futuras y así evitar hacer una query cada vez que se llama a esta función
            if(setPicklistValuesCategory == null){
                String sRecordTypeIdPicklistValueCategory = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
                setPicklistValuesCategory = new Set<String>();
                for(CBK_PicklistValues__c oPicklistValue : [SELECT Id, Name
                                                            FROM CBK_PicklistValues__c
                                                            WHERE CBK_Picklist__r.CBK_Object__c = 'CBK_Log'
                                                            AND CBK_Picklist__r.Name = 'CBK_Category__c'
                                                            AND RecordTypeId = :sRecordTypeIdPicklistValueCategory])
                {
                    setPicklistValuesCategory.add(oPicklistValue.Name);
                }
            }

            //Se comprueba que el valor de 'category' sea válido solamente si viene informado
            //Si existe, se guarda en el campo 'CBK_Category' el valor guardado como Name en la entrada de CBK_PicklistValue para mantener consistencia
            if(String.isNotBlank(category)){
                if(!setPicklistValuesCategory.isEmpty() && setPicklistValuesCategory.contains(category)){
                    this.category = category;
                }else{
                    this.category = 'Default';
                }
            }

            return this;
        }

        public DebugProcessConfigBuilder setTxtUser(String txtUser){
            this.txtUser = txtUser;
            return this;
        }

        public DebugProcessConfigBuilder setTxtStacktrace(String txtStacktrace){
            this.txtStacktrace = txtStacktrace;
            return this;
        }

        public DebugProcessConfigBuilder setTxtDetail(String txtDetail){
            this.txtDetail = txtDetail;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcMessageId(String sfdcMessageId){
            this.sfdcMessageId = sfdcMessageId;
            return this;
        }

        public DebugProcessConfigBuilder setMessageException(String messageException){
            this.messageException = messageException;
            return this;
        }

        public DebugProcessConfigBuilder setTxtFromAddress(String txtFromAddress){
            this.txtFromAddress = txtFromAddress;
            return this;
        }

        public DebugProcessConfigBuilder setTxtToAddress(String txtToAddress){
            this.txtToAddress = txtToAddress;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcReplyTo(String sfdcReplyTo){
            this.sfdcReplyTo = sfdcReplyTo;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcType(String sfdcType){
            this.sfdcType = sfdcType;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcEmailMessageId(String sfdcEmailMessageId){
            this.sfdcEmailMessageId = sfdcEmailMessageId;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcCaseId(String sfdcCaseId){
            this.sfdcCaseId = sfdcCaseId;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcResultStatus(String sfdcResultStatus){
            this.sfdcResultStatus = sfdcResultStatus;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcResultDetail(String sfdcResultDetail){
            this.sfdcResultDetail = sfdcResultDetail;
            return this;
        }

        public DebugProcessConfigBuilder setHdReturnPath(String hdReturnPath){
            this.hdReturnPath = hdReturnPath;
            return this;
        }

        public DebugProcessConfigBuilder setHdResentMessageId(String hdResentMessageId){
            this.hdResentMessageId = hdResentMessageId;
            return this;
        }

        public DebugProcessConfigBuilder setHdTo(String hdTo){
            this.hdTo = hdTo;
            return this;
        }

        public DebugProcessConfigBuilder setHdMessageID(String hdMessageID){
            this.hdMessageID = hdMessageID;
            return this;
        }

        public DebugProcessConfigBuilder setHdExchangeInboxRulesLoop(String hdExchangeInboxRulesLoop){
            this.hdExchangeInboxRulesLoop = hdExchangeInboxRulesLoop;
            return this;
        }

        public DebugProcessConfigBuilder setHdResentFrom(String hdResentFrom){
            this.hdResentFrom = hdResentFrom;
            return this;
        }

        public DebugProcessConfigBuilder setHdExchangeParentMessageId(String hdExchangeParentMessageId){
            this.hdExchangeParentMessageId = hdExchangeParentMessageId;
            return this;
        }

        public DebugProcessConfigBuilder setHdSFDCOriginalRCPT(String hdSFDCOriginalRCPT){
            this.hdSFDCOriginalRCPT = hdSFDCOriginalRCPT;
            return this;
        }

        public DebugProcessConfigBuilder setHdMSHasAttach(String hdMSHasAttach){
            this.hdMSHasAttach = hdMSHasAttach;
            return this;
        }

        public DebugProcessConfigBuilder setHdDeliveredTo(String hdDeliveredTo){
            this.hdDeliveredTo = hdDeliveredTo;
            return this;
        }

        public DebugProcessConfigBuilder setHdReference(String hdReference){
            this.hdReference = hdReference;
            return this;
        }

        public DebugProcessConfigBuilder setHdInReplyTo(String hdInReplyTo){
            this.hdInReplyTo = hdInReplyTo;
            return this;
        }

        public DebugProcessConfigBuilder setRecordTypeId(String recordTypeId){
            this.recordTypeId = recordTypeId;
            return this;
        }

        public DebugProcessConfigBuilder setOwnerId(String ownerId){
            this.ownerId = ownerId;
            return this;
        }

        public DebugProcessConfigBuilder setTransactionID(String transactionID){
            this.transactionID = transactionID;
            return this;
        }

        public DebugProcessConfigBuilder setLogMessage(String logMessage){
            this.logMessage = logMessage;
            return this;
        }

        public DebugProcessConfigBuilder setLogMessageExt(String logMessageExt){
            this.logMessageExt = logMessageExt;
            return this;
        }

        public DebugProcessConfigBuilder setErrorCode(String errorCode){
            this.errorCode = errorCode;
            return this;
        }

        public DebugProcessConfigBuilder setErrorType(String errorType){
            this.errorType = errorType;
            return this;
        }

        public DebugProcessConfigBuilder setCreatedBy(String createdBy){
            this.createdBy = createdBy;
            return this;
        }

        public DebugProcessConfigBuilder setDetail(String detail){
            this.detail = detail;
            return this;
        }

        public DebugProcessConfigBuilder setCreatedDate(Datetime createdDate){
            this.createdDate = createdDate;
            return this;
        }

        public DebugProcessConfigBuilder setSystemModstamp(Datetime systemModstamp){
            this.systemModstamp = systemModstamp;
            return this;
        }

        public DebugProcessConfigBuilder setState(String state){
            this.state = state;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcToAddress(String sfdcToAddress){
            this.sfdcToAddress = sfdcToAddress;
            return this;
        }

        public DebugProcessConfigBuilder setSfdcFromAddress(String sfdcFromAddress){
            this.sfdcFromAddress = sfdcFromAddress;
            return this;
        }

        public DebugProcessConfigBuilder setMapOptionalFields(Map<String,String> mapOptionalFields){
            this.mapOptionalFields = mapOptionalFields;
            return this;
        }

        //Método para crear un CBK_LogEvent__e a partir de los datos
        public void addLog() { 
            Boolean trace;
            switch on this.level.name() {
                when 'INFO'  { trace= LOG_CONFIG.INFO; }    
                when 'WARN'  { trace= LOG_CONFIG.WARN; }
                when 'ERROR' { trace= LOG_CONFIG.ERROR; }
                when 'DEBUG' { trace= LOG_CONFIG.DEBUG; }
                when else    { trace= LOG_CONFIG.DEBUG; }
            }
            
            if (trace || this.force || (Test.isRunningTest())){
                String stacktrace = '';
                String errType = '';
                if (this.err == null) {
                    stacktrace = new DmlException().getStackTraceString();
                } else {
                    stacktrace = this.err.getStackTraceString();
                    if (stacktrace?.left(32000) == '()'){
                        stacktrace = new DmlException().getStackTraceString();
                    }
                    errType = this.err.getTypeName();
                }
                this.setContextId(this.contextId == null ? THIS_CONTEXT : '' + this.contextId);

                CBK_LogEvent__e e = new CBK_LogEvent__e();
                e.txt_User__c = UserInfo.getUserId();
                e.txt_Message__c = this.message?.left(2000);
                e.txt_ErrType__c = String.isNotBlank(errType) ? errType?.left(30) : '';
                e.txt_Level__c = this.level?.name();
                e.txt_Context__c = this.contextId?.left(80);
                e.txt_stacktrace__c = stacktrace?.left(32000);
                e.txt_FromAddress__c = this.txtFromAddress?.left(255);
                e.txt_ToAddress__c = this.txtToAddress?.left(255);
                e.txt_Detail__c = String.join(this.values,'@Det@')?.left(32000);
                e.CBK_sfdcMessageId__c = this.sfdcEmailMessageId?.left(255);
                e.CBK_MessageException__c =  this.err?.getMessage()?.left(32500);
                e.CBK_sfdcRecordType__c = this.recordTypeId;
                e.CBK_sfdcReplyTo__c =  this.sfdcReplyTo?.left(255);
                e.CBK_sfdcType__c = this.sfdcType;
                e.CBK_sfdcEmailMessageId__c = this.email?.messageId;
                e.CBK_sfdcCaseId__c = this.sfdcCaseId;
                e.CBK_sfdcResultStatus__c  = this.sfdcResultStatus;
                e.CBK_sfdcResultDetail__c = this.sfdcResultDetail?.left(255);
                e.CBK_hdReturnPath__c = this.hdReturnPath?.left(255);
                e.CBK_hdResentMessageId__c = this.hdResentMessageId?.left(255);
                e.CBK_hdTo__c = this.hdTo?.left(255);
                e.CBK_hdMessageID__c = this.hdMessageID?.left(255);
                e.CBK_hdExchangeInboxRulesLoop__c = this.hdExchangeInboxRulesLoop?.left(255);
                e.CBK_hdResentFrom__c = this.hdResentFrom?.left(255);
                e.CBK_hdExchangeParentMessageId__c = this.hdExchangeParentMessageId?.left(255);
                e.CBK_hdSFDCOriginalRCPT__c = this.hdSFDCOriginalRCPT?.left(255);
                e.CBK_hdMSHasAttach__c = this.hdMSHasAttach?.left(255);
                e.CBK_hdDeliveredTo__c = this.hdDeliveredTo?.left(255);
                e.CBK_hdReference__c = this.hdReference?.left(255);
                e.CBK_hdInReplyTo__c = this.hdInReplyTo?.left(255);
                e.CBK_sfdcToAddress__c = this.sfdcToAddress?.left(255);

                e.CBK_Error_Code__c = this.errorCode;
                e.CBK_MessageException__c = this.messageException?.left(32500);
                e.CBK_CreatedDate__c = this.createdDate;
                e.CBK_SystemModstamp__c = this.systemModstamp;
                e.CBK_State__c = this.state;
    
                if (this.mapOptionalFields != null) {
                    Set<String> logFields = Schema.SObjectType.CBK_Log__c.fields.getMap().keySet();
                    Set<String> eventFields = Schema.SObjectType.CBK_LogEvent__e.fields.getMap().keySet();
                    for (String keyMapField : this.mapOptionalFields.keyset()) {
                        if(eventFields.contains(keyMapField.toLowerCase())){
                            e.put(keyMapField, this.mapOptionalFields.get(keyMapField));
                        }else if (mapCamposLogEvent.containsKey(keyMapField.toLowerCase()) && eventFields.contains(mapCamposLogEvent.get(keyMapField.toLowerCase()))){
                            e.put(mapCamposLogEvent.get(keyMapField.toLowerCase()), this.mapOptionalFields.get(keyMapField));
                        }
                    }
                }

                e = populateLocation(e);
                if (e?.txt_Message__c?.left(1) == '{') {
                    e = deserializeMsg(e);
                }
    
                String emailNotif;
                Boolean notif;    
                CBK_Framework_Login__mdt conf;
                List<CBK_Log__c> lstLog = new List<CBK_Log__c>();
                Map<String,CBK_Framework_Login__mdt> mapPrj = new Map<String,CBK_Framework_Login__mdt>();
                    
                //Configuración de traza por clases o prefijos   
                if (fwLogin == null){
                    fwLogin = [SELECT label,proyecto__c, Email_Notif__c, Notif__c FROM CBK_Framework_Login__mdt];
                }
                for (CBK_Framework_Login__mdt prj : fwLogin) {
                    mapPrj.put(prj.label, prj);
                }
    
                Map<String, String> mapCalculateProject = calculateProject(mapPrj, e.CBK_ApexClass__c);
                e.CBK_Project__c = mapCalculateProject.get('project');
                emailNotif = mapCalculateProject.get('emailNotif');
                notif = Boolean.valueOf(mapCalculateProject.get('notif'));
                
                // Notificaciones por mail
                if (notif && (e.txt_Level__c=='ERROR') && ( owea.size() > 0 ) && (emailNotif!='') && this.sendMail) {
                    lstmailGeneral.add(enviomail(e, owea.get(0).Id, emailNotif));
                }

                e = (CBK_LogEvent__e) getApexLimits(e);
                lstErroresEventaGuardar.add(e);                
            }
        }
    }
}