public class CC_WS_Maximo{
    public class ITNINCSIEBEL8V4SOAP11Port {
        public String endpoint_x = 'https://apispre.caixabank.com/maximo/meaweb/services/ITNINCSIEBEL8V4';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x=120000;
        private String[] ns_map_type_info = new String[]{'http://www.ibm.com/maximo', '', 'http://www.ibm.com/maximo/wsdl/ITNINCSIEBEL8V4', 'sdlItnincsiebel8v4'};
        public void UpdateITNINCSIEBEL8V4(CC_ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set) {
            UpdateITNINCSIEBEL8V4Type request_x = new UpdateITNINCSIEBEL8V4Type();
            request_x.ITNINCSIEBEL8V4Set = ITNINCSIEBEL8V4Set;
            UpdateITNINCSIEBEL8V4ResponseType response_x;
            Map<String, UpdateITNINCSIEBEL8V4ResponseType> response_map_x = new Map<String, UpdateITNINCSIEBEL8V4ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:processDocument',
              'http://www.ibm.com/maximo',
              'UpdateITNINCSIEBEL8V4',
              'http://www.ibm.com/maximo',
              'UpdateITNINCSIEBEL8V4Response',
              'CC_WS_Maximo.UpdateITNINCSIEBEL8V4ResponseType'}
            );
            response_x = response_map_x.get('response_x');
            
        }
        public void UpdateEventITNINCSIEBEL8V4(CC_EventITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set) {
            UpdateEventITNINCSIEBEL8V4Type request_x = new UpdateEventITNINCSIEBEL8V4Type();
            request_x.ITNINCSIEBEL8V4Set = ITNINCSIEBEL8V4Set;
            UpdateITNINCSIEBEL8V4ResponseType response_x;
            Map<String, UpdateITNINCSIEBEL8V4ResponseType> response_map_x = new Map<String, UpdateITNINCSIEBEL8V4ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:processDocument',
              'http://www.ibm.com/maximo',
              'UpdateITNINCSIEBEL8V4',
              'http://www.ibm.com/maximo',
              'UpdateITNINCSIEBEL8V4Response',
              'CC_WS_Maximo.UpdateITNINCSIEBEL8V4ResponseType'}
            );
            response_x = response_map_x.get('response_x');
            
        }
/*        public void SyncITNINCSIEBEL8V4(ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set) {
            SyncITNINCSIEBEL8V4Type request_x = new SyncITNINCSIEBEL8V4Type();
            request_x.ITNINCSIEBEL8V4Set = ITNINCSIEBEL8V4Set;
            SyncITNINCSIEBEL8V4ResponseType response_x;
            Map<String, SyncITNINCSIEBEL8V4ResponseType> response_map_x = new Map<String, SyncITNINCSIEBEL8V4ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:processDocument',
              'http://www.ibm.com/maximo',
              'SyncITNINCSIEBEL8V4',
              'http://www.ibm.com/maximo',
              'SyncITNINCSIEBEL8V4Response',
              'SyncITNINCSIEBEL8V4ResponseType'}
            );
            response_x = response_map_x.get('response_x');
        }
*/
/*        public ITNINCSIEBEL8V4SetType QueryITNINCSIEBEL8V4(ITNINCSIEBEL8V4QueryType ITNINCSIEBEL8V4Query) {
            QueryITNINCSIEBEL8V4Type request_x = new QueryITNINCSIEBEL8V4Type();
            request_x.ITNINCSIEBEL8V4Query = ITNINCSIEBEL8V4Query;
            QueryITNINCSIEBEL8V4ResponseType response_x;
            Map<String, QueryITNINCSIEBEL8V4ResponseType> response_map_x = new Map<String, QueryITNINCSIEBEL8V4ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:processDocument',
              'http://www.ibm.com/maximo',
              'QueryITNINCSIEBEL8V4',
              'http://www.ibm.com/maximo',
              'QueryITNINCSIEBEL8V4Response',
              'CC_WS_Maximo.QueryITNINCSIEBEL8V4ResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ITNINCSIEBEL8V4Set;
        }
*/
/*        public void DeleteITNINCSIEBEL8V4(ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set) {
            DeleteITNINCSIEBEL8V4Type request_x = new DeleteITNINCSIEBEL8V4Type();
            request_x.ITNINCSIEBEL8V4Set = ITNINCSIEBEL8V4Set;
            DeleteITNINCSIEBEL8V4ResponseType response_x;
            Map<String, DeleteITNINCSIEBEL8V4ResponseType> response_map_x = new Map<String, DeleteITNINCSIEBEL8V4ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:processDocument',
              'http://www.ibm.com/maximo',
              'DeleteITNINCSIEBEL8V4',
              'http://www.ibm.com/maximo',
              'DeleteITNINCSIEBEL8V4Response',
              'DeleteITNINCSIEBEL8V4ResponseType'}
            );
            response_x = response_map_x.get('response_x');
        }
*/
        public INCIDENTMboKeySetType CreateITNINCSIEBEL8V4(ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set) {
            CreateITNINCSIEBEL8V4Type request_x = new CreateITNINCSIEBEL8V4Type();
            request_x.ITNINCSIEBEL8V4Set = ITNINCSIEBEL8V4Set;
            CreateITNINCSIEBEL8V4ResponseType response_x;
            Map<String, CreateITNINCSIEBEL8V4ResponseType> response_map_x = new Map<String, CreateITNINCSIEBEL8V4ResponseType>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:processDocument',
              'http://www.ibm.com/maximo',
              'CreateITNINCSIEBEL8V4',
              'http://www.ibm.com/maximo',
              'CreateITNINCSIEBEL8V4Response',
              'CC_WS_Maximo.CreateITNINCSIEBEL8V4ResponseType'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.INCIDENTMboKeySet;
        }
    }    
    
/*    public class MXBinaryType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class MXIntQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class INCIDENTMboQueryType {
        public String WHERE_x;
        public INCIDENT_element INCIDENT;
        private String[] WHERE_x_type_info = new String[]{'WHERE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'WHERE_x','INCIDENT'};
    }
    public class QueryITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4QueryType ITNINCSIEBEL8V4Query;
        private String[] ITNINCSIEBEL8V4Query_type_info = new String[]{'ITNINCSIEBEL8V4Query','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Query'};
    }
    public class MXGLComponentQueryType {
        public String glorder;
        private String[] glorder_att_info = new String[]{'glorder'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
    public class ITNINCSIEBEL8V4SetType {
        public ITNINCSIEBEL8V4_INCIDENTType[] INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
    public class CC_ITNINCSIEBEL8V4SetType {
        public CC_ITNINCSIEBEL8V4_INCIDENTType[] INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
    public class CC_EventITNINCSIEBEL8V4SetType {
        public CC_EventITNINCSIEBEL8V4_INCIDENTType[] INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
/*    public class INCIDENTMboSetType {
        public INCIDENTObjectType[] INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
*/
/*    public class MXLongQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class MXGLComponentType {
        public String glorder;
        private String[] glorder_att_info = new String[]{'glorder'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class MXBooleanQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class MXDateTimeType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }

    public class WORKLOG_element {
        public MXStringQueryType[] CREATEBY;
        public MXStringQueryType[] DESCRIPTION;
        public MXDateTimeQueryType[] ITDCREATEDATE;
        public MXDateTimeQueryType[] ITNFECHAMJEVRU;
        public MXDomainQueryType[] LOGTYPE;
        public MXLongQueryType[] WORKLOGID;
        public Boolean filter;
        private String[] CREATEBY_type_info = new String[]{'CREATEBY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] DESCRIPTION_type_info = new String[]{'DESCRIPTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDCREATEDATE_type_info = new String[]{'ITDCREATEDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNFECHAMJEVRU_type_info = new String[]{'ITNFECHAMJEVRU','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] LOGTYPE_type_info = new String[]{'LOGTYPE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WORKLOGID_type_info = new String[]{'WORKLOGID','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] filter_att_info = new String[]{'filter'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'CREATEBY','DESCRIPTION','ITDCREATEDATE','ITNFECHAMJEVRU','LOGTYPE','WORKLOGID'};
    }
*/
    public class ITNINCSIEBEL8V4_MULTIASSETLOCCIType {
        public String COMMENTS;
        public String HIERARCHYPATH;
        public String ITNAFECPERSON;
        public String ITNCHGOUTAGE;
        public String ITNCHHOSTNAMEDESC;
        public String ITNDETALLAMADA;
        public String ITNESCENARIO;
        public String ITNESTADO;
        public String ITNINCEXTASSETNUM;
        public String ITNISAPPMMG;
        public String ITNISCORRESPON;
        public String ITNISCREACORR;
        public String ITNOBSERVACIONES;
        public String ITNPROPIETARIO;
        public String ITNTICKETCALL;
        public String LOCATION;
        //public String MULTIID;
        private String[] COMMENTS_type_info = new String[]{'COMMENTS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] HIERARCHYPATH_type_info = new String[]{'HIERARCHYPATH','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNAFECPERSON_type_info = new String[]{'ITNAFECPERSON','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCHGOUTAGE_type_info = new String[]{'ITNCHGOUTAGE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCHHOSTNAMEDESC_type_info = new String[]{'ITNCHHOSTNAMEDESC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNDETALLAMADA_type_info = new String[]{'ITNDETALLAMADA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNESCENARIO_type_info = new String[]{'ITNESCENARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNESTADO_type_info = new String[]{'ITNESTADO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCEXTASSETNUM_type_info = new String[]{'ITNINCEXTASSETNUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNISAPPMMG_type_info = new String[]{'ITNISAPPMMG','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNISCORRESPON_type_info = new String[]{'ITNISCORRESPON','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNISCREACORR_type_info = new String[]{'ITNISCREACORR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNOBSERVACIONES_type_info = new String[]{'ITNOBSERVACIONES','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNPROPIETARIO_type_info = new String[]{'ITNPROPIETARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNTICKETCALL_type_info = new String[]{'ITNTICKETCALL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] LOCATION_type_info = new String[]{'LOCATION','http://www.ibm.com/maximo',null,'0','1','false'};
        //private String[] MULTIID_type_info = new String[]{'MULTIID','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'COMMENTS','HIERARCHYPATH','ITNAFECPERSON','ITNCHGOUTAGE','ITNCHHOSTNAMEDESC','ITNDETALLAMADA','ITNESCENARIO','ITNESTADO','ITNINCEXTASSETNUM','ITNISAPPMMG','ITNISCORRESPON','ITNISCREACORR','ITNOBSERVACIONES','ITNPROPIETARIO','ITNTICKETCALL','LOCATION'/*,'MULTIID'*/};
    }
/*    public class MULTIASSETLOCCI_element {
        public MXStringQueryType[] COMMENTS;
        public MXStringQueryType[] ITNAFECPERSON;
        public MXDomainQueryType[] ITNCHGOUTAGE;
        public MXStringQueryType[] ITNCHHOSTNAMEDESC;
        public MXStringQueryType[] ITNDETALLAMADA;
        public MXStringQueryType[] ITNESCENARIO;
        public MXStringQueryType[] ITNESTADO;
        public MXBooleanQueryType[] ITNISAPPMMG;
        public MXBooleanQueryType[] ITNISCORRESPON;
        public MXBooleanQueryType[] ITNISCREACORR;
        public MXStringQueryType[] ITNOBSERVACIONES;
        public MXStringQueryType[] ITNPROPIETARIO;
        public MXStringQueryType[] ITNTICKETCALL;
        public MXStringQueryType[] LOCATION;
        public MXLongQueryType[] MULTIID;
        public Boolean filter;
        private String[] COMMENTS_type_info = new String[]{'COMMENTS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNAFECPERSON_type_info = new String[]{'ITNAFECPERSON','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCHGOUTAGE_type_info = new String[]{'ITNCHGOUTAGE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCHHOSTNAMEDESC_type_info = new String[]{'ITNCHHOSTNAMEDESC','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNDETALLAMADA_type_info = new String[]{'ITNDETALLAMADA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNESCENARIO_type_info = new String[]{'ITNESCENARIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNESTADO_type_info = new String[]{'ITNESTADO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNISAPPMMG_type_info = new String[]{'ITNISAPPMMG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNISCORRESPON_type_info = new String[]{'ITNISCORRESPON','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNISCREACORR_type_info = new String[]{'ITNISCREACORR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNOBSERVACIONES_type_info = new String[]{'ITNOBSERVACIONES','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNPROPIETARIO_type_info = new String[]{'ITNPROPIETARIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNTICKETCALL_type_info = new String[]{'ITNTICKETCALL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] LOCATION_type_info = new String[]{'LOCATION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] MULTIID_type_info = new String[]{'MULTIID','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] filter_att_info = new String[]{'filter'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'COMMENTS','ITNAFECPERSON','ITNCHGOUTAGE','ITNCHHOSTNAMEDESC','ITNDETALLAMADA','ITNESCENARIO','ITNESTADO','ITNISAPPMMG','ITNISCORRESPON','ITNISCREACORR','ITNOBSERVACIONES','ITNPROPIETARIO','ITNTICKETCALL','LOCATION','MULTIID'};
    }
    public class MXLangStringType {
        public String changed;
        public Boolean languageEnabled;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] languageEnabled_att_info = new String[]{'languageEnabled'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class MXCryptoType {
        public String changed;
        public String mxencrypted;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] mxencrypted_att_info = new String[]{'mxencrypted'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ITNINCSIEBEL8V4CombinedKeySetType {
        public INCIDENT_element[] INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
    public class INCIDENTMboType {
        public INCIDENTObjectType INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
*/
/*    public class QueryITNINCSIEBEL8V4ResponseType {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
*/
    public class ITNINCSIEBEL8V4_ITDTHIRDPARTYType {
        public String ITDBRIDGETICKETNUM;
        //public String ITDTHIRDPARTYID;
        public String ITNINCIDENTINCI;
        private String[] ITDBRIDGETICKETNUM_type_info = new String[]{'ITDBRIDGETICKETNUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDTHIRDPARTYID_type_info = new String[]{'ITDTHIRDPARTYID','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCIDENTINCI_type_info = new String[]{'ITNINCIDENTINCI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        //private String[] field_order_type_info = new String[]{'ITDBRIDGETICKETNUM','ITDTHIRDPARTYID','ITNINCIDENTINCI'};
        private String[] field_order_type_info = new String[]{'ITDBRIDGETICKETNUM','ITNINCIDENTINCI'};
    }
/*    public class MXStringQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class ITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4_INCIDENTType INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
*/
/*    public class ITNINCSIEBEL8V4QueryType {
        public String WHERE_x;
        public INCIDENT_element INCIDENT;
        private String[] WHERE_x_type_info = new String[]{'WHERE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'WHERE_x','INCIDENT'};
    }
*/
    public class CreateITNINCSIEBEL8V4ResponseType {
        public INCIDENTMboKeySetType INCIDENTMboKeySet;
        private String[] INCIDENTMboKeySet_type_info = new String[]{'INCIDENTMboKeySet','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENTMboKeySet'};
    }
/*	public class DeleteITNINCSIEBEL8V4ResponseType {
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class MXGLAccountType {
        public String VALUE;
        public MXGLComponentType[] GLCOMP;
        public String changed;
        private String[] VALUE_type_info = new String[]{'VALUE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GLCOMP_type_info = new String[]{'GLCOMP','http://www.ibm.com/maximo',null,'0','20','false'};
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'VALUE','GLCOMP'};
    }
*/
/*    public class DeleteITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
    public class MXBooleanType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
    public class ITNINCSIEBEL8V4_WORKLOGType {
        public String CREATEBY;
        public String DESCRIPTION;
        public String DESCRIPTION_LONGDESCRIPTION;
        public String ITDCREATEDATE;
        public String ITNFECHAMJEVRU;
        public String LOGTYPE;
        public String WORKLOGID;
        public String action;
        private String[] CREATEBY_type_info = new String[]{'CREATEBY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DESCRIPTION_type_info = new String[]{'DESCRIPTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DESCRIPTION_LONGDESCRIPTION_type_info = new String[]{'DESCRIPTION_LONGDESCRIPTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDCREATEDATE_type_info = new String[]{'ITDCREATEDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNFECHAMJEVRU_type_info = new String[]{'ITNFECHAMJEVRU','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] LOGTYPE_type_info = new String[]{'LOGTYPE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WORKLOGID_type_info = new String[]{'WORKLOGID','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] action_att_info = new String[]{'action'};
        private String[] field_order_type_info = new String[]{'CREATEBY','DESCRIPTION','DESCRIPTION_LONGDESCRIPTION','ITDCREATEDATE','ITNFECHAMJEVRU','LOGTYPE','WORKLOGID'};
    }
    public class UpdateITNINCSIEBEL8V4Type {
        public CC_ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
    public class UpdateEventITNINCSIEBEL8V4Type {
        public CC_EventITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
/*    public class ITDTHIRDPARTY_element {
        public MXStringQueryType[] ITDBRIDGETICKETNUM;
        public MXLongQueryType[] ITDTHIRDPARTYID;
        public MXStringQueryType[] ITNINCIDENTINCI;
        public Boolean filter;
        private String[] ITDBRIDGETICKETNUM_type_info = new String[]{'ITDBRIDGETICKETNUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDTHIRDPARTYID_type_info = new String[]{'ITDTHIRDPARTYID','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNINCIDENTINCI_type_info = new String[]{'ITNINCIDENTINCI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] filter_att_info = new String[]{'filter'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITDBRIDGETICKETNUM','ITDTHIRDPARTYID','ITNINCIDENTINCI'};
    }
    public class INCIDENTMboKeyType {
        public INCIDENTKeyType INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
    public class MXFloatQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class MXDoubleQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
    public class ITNINCSIEBEL8V4_INCIDENTType {
        public String ITDS_OWNERGROUP;      
        public String MAXINTERRORMSG;
        public String ACTUALFINISH;
        public String ACTUALSTART;
        public String AFFECTEDDATE;
        public String AFFECTEDEMAIL;
        public String AFFECTEDPERSON;
        public String AFFECTEDPERSONID;
        public String AFFECTEDPHONE;
        public String AFFECTEDUSERNAME;
        public String CLASS_x;
        public String CREATEDBY;
        public String CREATIONDATE;
        public String DESCRIPTION;
        public String DESCRIPTION_LONGDESCRIPTION;
        public String EXTERNALSYSTEM;
        public String GLOBALTICKETCLASS;
        public String GLOBALTICKETID;
        public String HIERARCHYPATH;
        public String ISGLOBAL;
        public String ITDCHCREATEDBYGROUP;
        public String ITDRESCODE;
        public String ITNAFFECTEDFINDATE;
        public String ITNAMBITO;
        public String ITNAPLICACION;
        public String ITNCINFIDENCIAL;
        public String ITNCLIENTVIP;
        public String ITNCODISSI;
        public String ITNCOMCLOSEDATE;
        public String ITNESCENARIO;
        public String ITNEVENTO;
        public String ITNEXTRA1;
        public String ITNEXTRA2;
        public String ITNEXTRA3;
        public String ITNEXTRA4;
        public String ITNEXTRA5;
        public String ITNEXTRAF1;
        //public String ITNEXTRAF2;
        public String ITNEXTRAN1;
        public String ITNEXTRAN2;
        public String ITNFILSISTEMA;
        public String ITNGRUPOPROV;
        public String ITNIMPACTCDS;
        public String ITNIMPHORTOTAL;
        public String ITNINCACCION;
        public String ITNINCCLIENTEAFEC;
        public String ITNINCCLOSECODE;
        public String ITNINCCONTRATO;
        public String ITNINCDETALLE;
        public String ITNINCEXTASSETNUM;
        public String ITNINCFAMILIA;
        public String ITNINCLISTSEGEVENTO;
        public String ITNINCPRODUCTO;
        public String ITNINCREVRESPREQUIRED;
        public String ITNINCTIPO;
        public String ITNINCTYPE;
        public String ITNINFORMEDIARIO;
        public String ITNINFORMEDIARIOEDG;
        public String ITNINFORMEDIARIOPREV;
        public String ITNLLAMADASAB;
        public String ITNLLAMADASABP;
        public String ITNLLAMADASAT;
        public String ITNLLAMADASATP;
        public String ITNLOPD;
        public String ITNNEGOCIO;
        public String ITNNOMBRE;
        public String ITNNUMABENDS;
        public String ITNOPCONCALLCENTER;
        public String ITNPROPIETARIO;
        public String ITNPUSERAFECTADOS;
        public String ITNRELEVANTE;
        public String ITNROL;
        public String ITNSENSIBLEDATA;
        public String ITNSERVICIOSN;
        public String ITNSEVERIDAD;
        public String ITNSEVERIDADTXT;
        public String ITNSLKMOTIVOLLAMADA;
        public String ITNSLKRECOMMENDEDGROUP;
        public String ITNSLKRESOLUTORGROUP;
        public String ITNSLKTIPOLLAMADA;
        public String ITNSLKUSER;
        public String ITNSOLEVENTOXML;
        public String ITNSROWGRVAL;
        public String ITNTAREAS;
        public String ITNTIPOAFEC;
        public String ITNTIPOBATCH;
        public String ITNTIPOINDISP;
        public String ITNTIPOTRANS;
        public String ITNUSERAFECTADOS;
        public String ITN_SOL_EVENTO;
        public String ITN_SOL_NOFIC;
        public String ORGID;
        public String OWNERGROUP;
        public String PLUSPCUSTOMER;
        public String PROBLEMCODE_LONGDESCRIPTION;
        public String REPORTDATE;
        public String REPORTEDBYID;
        public String REPORTEDEMAIL;
        public String REPORTEDPHONE;
        public String SITEID;
        public String STATUS;
        public String TARGETFINISH;
        public String TARGETSTART;
        public String TICKETID;
        public ITNINCSIEBEL8V4_ITDTHIRDPARTYType[] ITDTHIRDPARTY;
        public ITNINCSIEBEL8V4_WORKLOGType[] WORKLOG;
        public ITNINCSIEBEL8V4_MULTIASSETLOCCIType[] MULTIASSETLOCCI;
        public String transLanguage;
        public String action;
        private String[] MAXINTERRORMSG_type_info = new String[]{'MAXINTERRORMSG','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ACTUALFINISH_type_info = new String[]{'ACTUALFINISH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ACTUALSTART_type_info = new String[]{'ACTUALSTART','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] AFFECTEDDATE_type_info = new String[]{'AFFECTEDDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] AFFECTEDEMAIL_type_info = new String[]{'AFFECTEDEMAIL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] AFFECTEDPERSON_type_info = new String[]{'AFFECTEDPERSON','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] AFFECTEDPERSONID_type_info = new String[]{'AFFECTEDPERSONID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] AFFECTEDPHONE_type_info = new String[]{'AFFECTEDPHONE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] AFFECTEDUSERNAME_type_info = new String[]{'AFFECTEDUSERNAME','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CLASS_x_type_info = new String[]{'CLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CREATEDBY_type_info = new String[]{'CREATEDBY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CREATIONDATE_type_info = new String[]{'CREATIONDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] DESCRIPTION_type_info = new String[]{'DESCRIPTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DESCRIPTION_LONGDESCRIPTION_type_info = new String[]{'DESCRIPTION_LONGDESCRIPTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] EXTERNALSYSTEM_type_info = new String[]{'EXTERNALSYSTEM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GLOBALTICKETCLASS_type_info = new String[]{'GLOBALTICKETCLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GLOBALTICKETID_type_info = new String[]{'GLOBALTICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] HIERARCHYPATH_type_info = new String[]{'HIERARCHYPATH','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ISGLOBAL_type_info = new String[]{'ISGLOBAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDCHCREATEDBYGROUP_type_info = new String[]{'ITDCHCREATEDBYGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDRESCODE_type_info = new String[]{'ITDRESCODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNAFFECTEDFINDATE_type_info = new String[]{'ITNAFFECTEDFINDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNAMBITO_type_info = new String[]{'ITNAMBITO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNAPLICACION_type_info = new String[]{'ITNAPLICACION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCINFIDENCIAL_type_info = new String[]{'ITNCINFIDENCIAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLIENTVIP_type_info = new String[]{'ITNCLIENTVIP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCODISSI_type_info = new String[]{'ITNCODISSI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCOMCLOSEDATE_type_info = new String[]{'ITNCOMCLOSEDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNESCENARIO_type_info = new String[]{'ITNESCENARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEVENTO_type_info = new String[]{'ITNEVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA1_type_info = new String[]{'ITNEXTRA1','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA2_type_info = new String[]{'ITNEXTRA2','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA3_type_info = new String[]{'ITNEXTRA3','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA4_type_info = new String[]{'ITNEXTRA4','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA5_type_info = new String[]{'ITNEXTRA5','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRAF1_type_info = new String[]{'ITNEXTRAF1','http://www.ibm.com/maximo',null,'0','1','true'};
        //private String[] ITNEXTRAF2_type_info = new String[]{'ITNEXTRAF2','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNEXTRAN1_type_info = new String[]{'ITNEXTRAN1','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNEXTRAN2_type_info = new String[]{'ITNEXTRAN2','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNFILSISTEMA_type_info = new String[]{'ITNFILSISTEMA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNGRUPOPROV_type_info = new String[]{'ITNGRUPOPROV','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNIMPACTCDS_type_info = new String[]{'ITNIMPACTCDS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNIMPHORTOTAL_type_info = new String[]{'ITNIMPHORTOTAL','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCACCION_type_info = new String[]{'ITNINCACCION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCLIENTEAFEC_type_info = new String[]{'ITNINCCLIENTEAFEC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCLOSECODE_type_info = new String[]{'ITNINCCLOSECODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCONTRATO_type_info = new String[]{'ITNINCCONTRATO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCDETALLE_type_info = new String[]{'ITNINCDETALLE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCEXTASSETNUM_type_info = new String[]{'ITNINCEXTASSETNUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCFAMILIA_type_info = new String[]{'ITNINCFAMILIA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCLISTSEGEVENTO_type_info = new String[]{'ITNINCLISTSEGEVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCPRODUCTO_type_info = new String[]{'ITNINCPRODUCTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCREVRESPREQUIRED_type_info = new String[]{'ITNINCREVRESPREQUIRED','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCTIPO_type_info = new String[]{'ITNINCTIPO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCTYPE_type_info = new String[]{'ITNINCTYPE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINFORMEDIARIO_type_info = new String[]{'ITNINFORMEDIARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINFORMEDIARIOEDG_type_info = new String[]{'ITNINFORMEDIARIOEDG','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINFORMEDIARIOPREV_type_info = new String[]{'ITNINFORMEDIARIOPREV','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNLLAMADASAB_type_info = new String[]{'ITNLLAMADASAB','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLLAMADASABP_type_info = new String[]{'ITNLLAMADASABP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLLAMADASAT_type_info = new String[]{'ITNLLAMADASAT','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLLAMADASATP_type_info = new String[]{'ITNLLAMADASATP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLOPD_type_info = new String[]{'ITNLOPD','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNEGOCIO_type_info = new String[]{'ITNNEGOCIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNOMBRE_type_info = new String[]{'ITNNOMBRE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNUMABENDS_type_info = new String[]{'ITNNUMABENDS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNOPCONCALLCENTER_type_info = new String[]{'ITNOPCONCALLCENTER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNPROPIETARIO_type_info = new String[]{'ITNPROPIETARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNPUSERAFECTADOS_type_info = new String[]{'ITNPUSERAFECTADOS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNRELEVANTE_type_info = new String[]{'ITNRELEVANTE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNROL_type_info = new String[]{'ITNROL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSENSIBLEDATA_type_info = new String[]{'ITNSENSIBLEDATA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSERVICIOSN_type_info = new String[]{'ITNSERVICIOSN','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSEVERIDAD_type_info = new String[]{'ITNSEVERIDAD','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSEVERIDADTXT_type_info = new String[]{'ITNSEVERIDADTXT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKMOTIVOLLAMADA_type_info = new String[]{'ITNSLKMOTIVOLLAMADA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKRECOMMENDEDGROUP_type_info = new String[]{'ITNSLKRECOMMENDEDGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKRESOLUTORGROUP_type_info = new String[]{'ITNSLKRESOLUTORGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKTIPOLLAMADA_type_info = new String[]{'ITNSLKTIPOLLAMADA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKUSER_type_info = new String[]{'ITNSLKUSER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSOLEVENTOXML_type_info = new String[]{'ITNSOLEVENTOXML','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSROWGRVAL_type_info = new String[]{'ITNSROWGRVAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNTAREAS_type_info = new String[]{'ITNTAREAS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOAFEC_type_info = new String[]{'ITNTIPOAFEC','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOBATCH_type_info = new String[]{'ITNTIPOBATCH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOINDISP_type_info = new String[]{'ITNTIPOINDISP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOTRANS_type_info = new String[]{'ITNTIPOTRANS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNUSERAFECTADOS_type_info = new String[]{'ITNUSERAFECTADOS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITN_SOL_EVENTO_type_info = new String[]{'ITN_SOL_EVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_NOFIC_type_info = new String[]{'ITN_SOL_NOFIC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ORGID_type_info = new String[]{'ORGID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] OWNERGROUP_type_info = new String[]{'OWNERGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCUSTOMER_type_info = new String[]{'PLUSPCUSTOMER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PROBLEMCODE_LONGDESCRIPTION_type_info = new String[]{'PROBLEMCODE_LONGDESCRIPTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] REPORTDATE_type_info = new String[]{'REPORTDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] REPORTEDBYID_type_info = new String[]{'REPORTEDBYID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] REPORTEDEMAIL_type_info = new String[]{'REPORTEDEMAIL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] REPORTEDPHONE_type_info = new String[]{'REPORTEDPHONE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SITEID_type_info = new String[]{'SITEID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] STATUS_type_info = new String[]{'STATUS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TARGETFINISH_type_info = new String[]{'TARGETFINISH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] TARGETSTART_type_info = new String[]{'TARGETSTART','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] TICKETID_type_info = new String[]{'TICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDTHIRDPARTY_type_info = new String[]{'ITDTHIRDPARTY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WORKLOG_type_info = new String[]{'WORKLOG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] MULTIASSETLOCCI_type_info = new String[]{'MULTIASSETLOCCI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] transLanguage_att_info = new String[]{'transLanguage'};
        private String[] action_att_info = new String[]{'action'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        //private String[] field_order_type_info = new String[]{'MAXINTERRORMSG','ACTUALFINISH','ACTUALSTART','AFFECTEDDATE','AFFECTEDEMAIL','AFFECTEDPERSON','AFFECTEDPERSONID','AFFECTEDPHONE','AFFECTEDUSERNAME','CLASS_x','CREATEDBY','CREATIONDATE','DESCRIPTION','DESCRIPTION_LONGDESCRIPTION','EXTERNALSYSTEM','GLOBALTICKETCLASS','GLOBALTICKETID','HIERARCHYPATH','ISGLOBAL','ITDCHCREATEDBYGROUP','ITDRESCODE','ITNAFFECTEDFINDATE','ITNAMBITO','ITNAPLICACION','ITNCINFIDENCIAL','ITNCLIENTVIP','ITNCODISSI','ITNCOMCLOSEDATE','ITNESCENARIO','ITNEVENTO','ITNEXTRA1','ITNEXTRA2','ITNEXTRA3','ITNEXTRA4','ITNEXTRA5','ITNEXTRAF1','ITNEXTRAF2','ITNEXTRAN1','ITNEXTRAN2','ITNFILSISTEMA','ITNGRUPOPROV','ITNIMPACTCDS','ITNIMPHORTOTAL','ITNINCACCION','ITNINCCLIENTEAFEC','ITNINCCLOSECODE','ITNINCCONTRATO','ITNINCDETALLE','ITNINCEXTASSETNUM','ITNINCFAMILIA','ITNINCLISTSEGEVENTO','ITNINCPRODUCTO','ITNINCREVRESPREQUIRED','ITNINCTIPO','ITNINCTYPE','ITNINFORMEDIARIO','ITNINFORMEDIARIOEDG','ITNINFORMEDIARIOPREV','ITNLLAMADASAB','ITNLLAMADASABP','ITNLLAMADASAT','ITNLLAMADASATP','ITNLOPD','ITNNEGOCIO','ITNNOMBRE','ITNNUMABENDS','ITNOPCONCALLCENTER','ITNPROPIETARIO','ITNPUSERAFECTADOS','ITNRELEVANTE','ITNROL','ITNSENSIBLEDATA','ITNSERVICIOSN','ITNSEVERIDAD','ITNSEVERIDADTXT','ITNSLKMOTIVOLLAMADA','ITNSLKRECOMMENDEDGROUP','ITNSLKRESOLUTORGROUP','ITNSLKTIPOLLAMADA','ITNSLKUSER','ITNSOLEVENTOXML','ITNSROWGRVAL','ITNTAREAS','ITNTIPOAFEC','ITNTIPOBATCH','ITNTIPOINDISP','ITNTIPOTRANS','ITNUSERAFECTADOS','ITN_SOL_EVENTO','ITN_SOL_NOFIC','ORGID','OWNERGROUP','PLUSPCUSTOMER','PROBLEMCODE_LONGDESCRIPTION','REPORTDATE','REPORTEDBYID','REPORTEDEMAIL','REPORTEDPHONE','SITEID','STATUS','TARGETFINISH','TARGETSTART','TICKETID','ITDTHIRDPARTY','WORKLOG','MULTIASSETLOCCI'};
    	private String[] field_order_type_info = new String[]{'MAXINTERRORMSG','ACTUALFINISH','ACTUALSTART','AFFECTEDDATE','AFFECTEDEMAIL','AFFECTEDPERSON','AFFECTEDPERSONID','AFFECTEDPHONE','AFFECTEDUSERNAME','CLASS_x','CREATEDBY','CREATIONDATE','DESCRIPTION','DESCRIPTION_LONGDESCRIPTION','EXTERNALSYSTEM','GLOBALTICKETCLASS','GLOBALTICKETID','HIERARCHYPATH','ISGLOBAL','ITDCHCREATEDBYGROUP','ITDRESCODE','ITNAFFECTEDFINDATE','ITNAMBITO','ITNAPLICACION','ITNCINFIDENCIAL','ITNCLIENTVIP','ITNCODISSI','ITNCOMCLOSEDATE','ITNESCENARIO','ITNEVENTO','ITNEXTRA1','ITNEXTRA2','ITNEXTRA3','ITNEXTRA4','ITNEXTRA5','ITNEXTRAF1','ITNEXTRAN1','ITNEXTRAN2','ITNFILSISTEMA','ITNGRUPOPROV','ITNIMPACTCDS','ITNIMPHORTOTAL','ITNINCACCION','ITNINCCLIENTEAFEC','ITNINCCLOSECODE','ITNINCCONTRATO','ITNINCDETALLE','ITNINCEXTASSETNUM','ITNINCFAMILIA','ITNINCLISTSEGEVENTO','ITNINCPRODUCTO','ITNINCREVRESPREQUIRED','ITNINCTIPO','ITNINCTYPE','ITNINFORMEDIARIO','ITNINFORMEDIARIOEDG','ITNINFORMEDIARIOPREV','ITNLLAMADASAB','ITNLLAMADASABP','ITNLLAMADASAT','ITNLLAMADASATP','ITNLOPD','ITNNEGOCIO','ITNNOMBRE','ITNNUMABENDS','ITNOPCONCALLCENTER','ITNPROPIETARIO','ITNPUSERAFECTADOS','ITNRELEVANTE','ITNROL','ITNSENSIBLEDATA','ITNSERVICIOSN','ITNSEVERIDAD','ITNSEVERIDADTXT','ITNSLKMOTIVOLLAMADA','ITNSLKRECOMMENDEDGROUP','ITNSLKRESOLUTORGROUP','ITNSLKTIPOLLAMADA','ITNSLKUSER','ITNSOLEVENTOXML','ITNSROWGRVAL','ITNTAREAS','ITNTIPOAFEC','ITNTIPOBATCH','ITNTIPOINDISP','ITNTIPOTRANS','ITNUSERAFECTADOS','ITN_SOL_EVENTO','ITN_SOL_NOFIC','ORGID','OWNERGROUP','PLUSPCUSTOMER','PROBLEMCODE_LONGDESCRIPTION','REPORTDATE','REPORTEDBYID','REPORTEDEMAIL','REPORTEDPHONE','SITEID','STATUS','TARGETFINISH','TARGETSTART','TICKETID','ITDTHIRDPARTY','WORKLOG','MULTIASSETLOCCI'};
    
            }
    public class CC_ITNINCSIEBEL8V4_INCIDENTType {
        public String CLASS_x;
        public String TICKETID;
        public ITNINCSIEBEL8V4_WORKLOGType[] WORKLOG;
        public String transLanguage;
        public String action;
        private String[] CLASS_x_type_info = new String[]{'CLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TICKETID_type_info = new String[]{'TICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WORKLOG_type_info = new String[]{'WORKLOG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] transLanguage_att_info = new String[]{'transLanguage'};
        private String[] action_att_info = new String[]{'action'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'CLASS_x','TICKETID','WORKLOG'};
    }
    public class CC_EventITNINCSIEBEL8V4_INCIDENTType {
        public String ITNRELEVANTE;
        public String ITNEVENTO;
        public String ITNLLAMADASAB;
        public String ITNLLAMADASABP;
        public String ITNLLAMADASAT;
        public String ITNLLAMADASATP;
        public String CLASS_x;
        public String TICKETID;
        public ITNINCSIEBEL8V4_WORKLOGType[] WORKLOG;
        public String transLanguage;
        public String action;
        private String[] ITNRELEVANTE_type_info = new String[]{'ITNRELEVANTE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEVENTO_type_info = new String[]{'ITNEVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
		private String[] ITNLLAMADASAB_type_info = new String[]{'ITNLLAMADASAB','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNLLAMADASABP_type_info = new String[]{'ITNLLAMADASABP','http://www.ibm.com/maximo',null,'0','1','false'};
		private String[] ITNLLAMADASAT_type_info = new String[]{'ITNLLAMADASAT','http://www.ibm.com/maximo',null,'0','1','false'};
		private String[] ITNLLAMADASATP_type_info = new String[]{'ITNLLAMADASATP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CLASS_x_type_info = new String[]{'CLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TICKETID_type_info = new String[]{'TICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WORKLOG_type_info = new String[]{'WORKLOG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] transLanguage_att_info = new String[]{'transLanguage'};
        private String[] action_att_info = new String[]{'action'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNRELEVANTE','ITNEVENTO','ITNLLAMADASAB','ITNLLAMADASABP','ITNLLAMADASAT','ITNLLAMADASATP','CLASS_x','TICKETID','WORKLOG'};
    }
/*    public class SyncITNINCSIEBEL8V4ResponseType {
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class PublishITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
    public class MXFloatType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class InvokeITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
*/
    public class CreateITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
/*    public class MXStringType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class INCIDENTObjectType {
        public String TICKETID;
        public String CLASS_x;
        public String DESCRIPTION;
        public String STATUS;
        public String STATUSDATE;
        public String REPORTEDPRIORITY;
        public String INTERNALPRIORITY;
        public String IMPACT;
        public String URGENCY;
        public String REPORTEDBY;
        public String REPORTDATE;
        public String AFFECTEDPERSON;
        public String AFFECTEDDATE;
        public String SOURCE;
        public String SUPERVISOR;
        public String OWNER;
        public String OWNERGROUP;
        public String ISGLOBAL;
        public String RELATEDTOGLOBAL;
        public String GLOBALTICKETID;
        public String GLOBALTICKETCLASS;
        public String EXTERNALRECID;
        public String SITEVISIT;
        public String ORIGRECORDID;
        public String ORIGRECORDCLASS;
        public MXGLAccountType GLACCOUNT;
        public String COMMODITYGROUP;
        public String COMMODITY;
        public String INHERITSTATUS;
        public String ISKNOWNERROR;
        public String TARGETSTART;
        public String TARGETFINISH;
        public String ACTUALSTART;
        public String ACTUALFINISH;
        public String ORIGRECSITEID;
        public String ORIGRECORGID;
        public String SITEID;
        public String ORGID;
        public String CHANGEDATE;
        public String CHANGEBY;
        public String HISTORYFLAG;
        public String TEMPLATE;
        public String HASACTIVITY;
        public String FAILURECODE;
        public String PROBLEMCODE;
        public String ACTLABHRS;
        public String ACTLABCOST;
        public String AFFECTEDPHONE;
        public String REPORTEDPHONE;
        public String AFFECTEDEMAIL;
        public String REPORTEDEMAIL;
        public String ASSETSITEID;
        public String TEMPLATEID;
        public String VENDOR;
        public String ASSETNUM;
        public String LOCATION;
        public String CLASSSTRUCTUREID;
        public String ISKNOWNERRORDATE;
        public String TARGETCONTACTDATE;
        public String ACTUALCONTACTDATE;
        public String FR1CODE;
        public String FR2CODE;
        public String TICKETUID;
        public String SOLUTION;
        public String ASSETORGID;
        public String LANGCODE;
        public String HASLD;
        public String CINUM;
        public String CREATEWOMULTI;
        public String TARGETDESC;
        public String SELFSERVSOLACCESS;
        public String HASSOLUTION;
        public String CALCORGID;
        public String CALCCALENDAR;
        public String CALCSHIFT;
        public String ASSIGNEDOWNERGROUP;
        public String PLUSPQUOTETYPE;
        public String PLUSPQUOTEDPRICE;
        public String PLUSPAGREEMENT;
        public String PLUSPCUSTOMER;
        public String PLUSPCOSTCENTER;
        public String PLUSPCUSTCHACCT;
        public String PLUSPRESPONSEPLAN;
        public String PLUSPREVNUM;
        public String PLUSPPRICESCHED;
        public String PLUSPCUSTPONUM;
        public String PLUSPMAXPRICE;
        public String PLUSPBILLBATCH;
        public String PLUSPBBLINENUM;
        public String PLUSPPOREQ;
        public String PLUSPCALCORGID;
        public String PLUSPCALCCALNUM;
        public String PLUSPCALCSHIFT;
        public String PMCOMTYPE;
        public String PMCOMRESOLUTION;
        public String PMCOMIMPACT;
        public String PMCOMURGENCY;
        public String INDICATEDPRIORITY;
        public String EXTERNALSYSTEM_TICKETID;
        public String EXTERNALSYSTEM;
        public String DESCSRVID;
        public String CREATEDBY;
        public String CREATIONDATE;
        public String VIRTUALENV;
        public String OUTAGEDURATION;
        public String CLASSIFICATIONID;
        public String PMSCCRID;
        public String PMSCITEMNUM;
        public String PMSCOFFSUMMARY;
        public String PMSCQUANTITY;
        public String PMSCITEMSETID;
        public String PMSCTMPLID;
        public String PMSCINVALID;
        public String CORRELATIONATTRS;
        public String ACCUMULATEDHOLDTIME;
        public String ADJUSTEDTARGETCONTACTTIME;
        public String ADJUSTEDTARGETRESPONSETIME;
        public String ADJUSTEDTARGETRESOLUTIONTIME;
        public String RBA_RC;
        public String ITDALTPHONE;
        public String ITDCAUSECODE;
        public String ITDCHARGABLE;
        public String ITDCHCREATEDBYGROUP;
        public String ITDCHECK;
        public String ITDCLOSEDATE;
        public String ITDCLOSURECODE;
        public String ITDDOCCOUNTS;
        public String ITDEXTERNALKMREFERENCE;
        public String ITDFIRSTCALLRESOLUTION;
        public String ITDINCEMAILFLG;
        public String ITDINITWF;
        public String ITDKMRANKING;
        public String ITDMAJORINCIDENT;
        public String ITDRESCODE;
        public String ITDRESOLVERGROUP;
        public String ITDROOTCAUSEDTM;
        public String ITDSLAHOLDDATE;
        public String ITDS_OWNER;
        public String ITDS_OWNERGROUP;
        public String CONTBFACTORS;
        public String CUSTBUSIMPACT;
        public String DETECTBYMONITOR;
        public String IMPRESOLUTION;
        public String RESPONSE1;
        public String RESPONSE2;
        public String RESPONSE3;
        public String RESPONSE4;
        public String RESPONSE5;
        public String SLAIMPACTED;
        public String WHY1;
        public String WHY2;
        public String WHY3;
        public String WHY4;
        public String WHY5;
        public String ITNRTC;
        public String ITNCLIORIGEN;
        public String ITNTARGETFINISH;
        public String USERU01;
        public String DIRECTOR;
        public String GERENCIA;
        public String GERENTE;
        public String USERU2D;
        public String ITN_CREATESRMULTI;
        public String SLKONETIMECOST;
        public String SLKANUALRECCOST;
        public String ITNAPPRGROUPFILIAL;
        public String ITNAPPRGROUPSILKAPP;
        public String ITNTARGETCUSTOMER;
        public String ITNPIPA;
        public String ITNSRTIPO;
        public String ITNSOLEVENTO;
        public String ITN_SOL_DETALL_SERVEI;
        public String ITN_SOL_MODEL;
        public String ITN_SOL_NCIAM;
        public String ITN_SOL_SERIE;
        public String ITN_SOL_TIPUS;
        public String ITNAFFECTEDFINDATE;
        public String ITNAMBITO;
        public String ITNBASECALINC;
        public String ITNCALCULOPRIORIDAD;
        public String ITNCATSERV;
        public String ITNCENTRO;
        public String ITNCINFIDENCIAL;
        public String ITNCLASSIFICATIONID;
        public String ITNCLASSSTRUCTUREID;
        public String ITNCLASSSTRUCTUREIDGEN;
        public String ITNCLASSSTRUCTUREIDPLAT;
        public String ITNCLIENTVIP;
        public String ITNESCENARIO;
        public String ITNEVENTO;
        public String ITNGRUPOCONTROL;
        public String ITNGRUPONEGOCIO;
        public String ITNGRUPORESPON;
        public String ITNIMPALCANCE;
        public String ITNIMPNEGOCIO;
        public String ITNIMPRIESGO;
        public String ITNINCACCION;
        public String ITNINCCINUM;
        public String ITNINCCLASSIFICATIONIDGEN;
        public String ITNINCCLASSIFICATIONIDPLAT;
        public String ITNINCCLIENTEAFEC;
        public String ITNINCCLOSECODE;
        public String ITNINCCONTRATO;
        public String ITNINCDETALLE;
        public String ITNINCFAMILIA;
        public String ITNINCFEC_OBJACC;
        public String ITNINCFEC_OBJACEP;
        public String ITNINCFEC_OBJRES;
        public String ITNINCINRECLAS;
        public String ITNINCPRODUCTO;
        public String ITNINCREVINTREQUIRED;
        public String ITNINCTYPE;
        public String ITNINFORMEDIARIO;
        public String ITNLLAMADASAB;
        public String ITNLLAMADASAT;
        public String ITNLOPD;
        public String ITNNEGOCIO;
        public String ITNNUMABENDS;
        public String ITNNUMRECCLASIFIC;
        public String ITNOFFERTYPE;
        public String ITNOPCONCALLCENTER;
        public String ITNPSRELACIONADAS;
        public String ITNPUSERAFECTADOS;
        public String ITNREAPERTURAS;
        public String ITNRECLAMACIONES;
        public String ITNRECLASIFICACIONES;
        public String ITNRELEVANTE;
        public String ITNROL;
        public String ITNSEGPA;
        public String ITNSERVICIOTI;
        public String ITNSEVERIDAD;
        public String ITNTIPOAFEC;
        public String ITNTIPOBATCH;
        public String ITNTIPOINDISP;
        public String ITNTIPOTRANS;
        public String ITNTOTALMP;
        public String ITNTOTALMS;
        public String ITNURGENCY;
        public String ITNUSERAFECTADOS;
        public String ITNSOLEVENTOXML;
        public String ITN_SOL_EVENTO;
        public String ITNSEVERIDADTXT;
        public String ITNCOMCLOSEDATE;
        public String ITNINCLISTSEGEVENTO;
        public String ITNGRUPOPROV;
        public String ITNINCREVRESPREQUIRED;
        public String ITNINCTIPO;
        public String ITNLLAMADASABP;
        public String ITNLLAMADASATP;
        public String ITNCODISSI;
        public String ITNAPLICACION;
        public String ITNNOMBRE;
        public String ITNEXTRA1;
        public String ITNEXTRA2;
        public String ITNEXTRA3;
        public String ITNEXTRA4;
        public String ITNEXTRA5;
        public String ITNEXTRAF1;
        public String ITNEXTRAF2;
        public String ITNEXTRAN1;
        public String ITNEXTRAN2;
        public String ITNFILSISTEMA;
        public String ITNIMPACTCDS;
        public String ITNTAREAS;
        public String ITNSLKUSER;
        public String ITNSLKTIPOLLAMADA;
        public String ITNSLKMOTIVOLLAMADA;
        public String ITNIMPHORTOTAL;
        public String ITNSROWGRVAL;
        public String ITNPROPIETARIO;
        public String ITN_SOL_NOFIC;
        public String ITNSENSIBLEDATA;
        public String ITNSLKRESOLUTORGROUP;
        public String ITNSLKRECOMMENDEDGROUP;
        public String ITNINFORMEDIARIOPREV;
        public String ITNINFORMEDIARIOEDG;
        public String ITNSERVICIOSN;
        public String action;
        private String[] TICKETID_type_info = new String[]{'TICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CLASS_x_type_info = new String[]{'CLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DESCRIPTION_type_info = new String[]{'DESCRIPTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] STATUS_type_info = new String[]{'STATUS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] STATUSDATE_type_info = new String[]{'STATUSDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] REPORTEDPRIORITY_type_info = new String[]{'REPORTEDPRIORITY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] INTERNALPRIORITY_type_info = new String[]{'INTERNALPRIORITY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] IMPACT_type_info = new String[]{'IMPACT','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] URGENCY_type_info = new String[]{'URGENCY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] REPORTEDBY_type_info = new String[]{'REPORTEDBY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] REPORTDATE_type_info = new String[]{'REPORTDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] AFFECTEDPERSON_type_info = new String[]{'AFFECTEDPERSON','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] AFFECTEDDATE_type_info = new String[]{'AFFECTEDDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] SOURCE_type_info = new String[]{'SOURCE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SUPERVISOR_type_info = new String[]{'SUPERVISOR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] OWNER_type_info = new String[]{'OWNER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] OWNERGROUP_type_info = new String[]{'OWNERGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ISGLOBAL_type_info = new String[]{'ISGLOBAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] RELATEDTOGLOBAL_type_info = new String[]{'RELATEDTOGLOBAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GLOBALTICKETID_type_info = new String[]{'GLOBALTICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GLOBALTICKETCLASS_type_info = new String[]{'GLOBALTICKETCLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] EXTERNALRECID_type_info = new String[]{'EXTERNALRECID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SITEVISIT_type_info = new String[]{'SITEVISIT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ORIGRECORDID_type_info = new String[]{'ORIGRECORDID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ORIGRECORDCLASS_type_info = new String[]{'ORIGRECORDCLASS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GLACCOUNT_type_info = new String[]{'GLACCOUNT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] COMMODITYGROUP_type_info = new String[]{'COMMODITYGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] COMMODITY_type_info = new String[]{'COMMODITY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] INHERITSTATUS_type_info = new String[]{'INHERITSTATUS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ISKNOWNERROR_type_info = new String[]{'ISKNOWNERROR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TARGETSTART_type_info = new String[]{'TARGETSTART','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] TARGETFINISH_type_info = new String[]{'TARGETFINISH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ACTUALSTART_type_info = new String[]{'ACTUALSTART','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ACTUALFINISH_type_info = new String[]{'ACTUALFINISH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ORIGRECSITEID_type_info = new String[]{'ORIGRECSITEID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ORIGRECORGID_type_info = new String[]{'ORIGRECORGID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SITEID_type_info = new String[]{'SITEID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ORGID_type_info = new String[]{'ORGID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CHANGEDATE_type_info = new String[]{'CHANGEDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] CHANGEBY_type_info = new String[]{'CHANGEBY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] HISTORYFLAG_type_info = new String[]{'HISTORYFLAG','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TEMPLATE_type_info = new String[]{'TEMPLATE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] HASACTIVITY_type_info = new String[]{'HASACTIVITY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] FAILURECODE_type_info = new String[]{'FAILURECODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PROBLEMCODE_type_info = new String[]{'PROBLEMCODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ACTLABHRS_type_info = new String[]{'ACTLABHRS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ACTLABCOST_type_info = new String[]{'ACTLABCOST','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] AFFECTEDPHONE_type_info = new String[]{'AFFECTEDPHONE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] REPORTEDPHONE_type_info = new String[]{'REPORTEDPHONE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] AFFECTEDEMAIL_type_info = new String[]{'AFFECTEDEMAIL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] REPORTEDEMAIL_type_info = new String[]{'REPORTEDEMAIL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ASSETSITEID_type_info = new String[]{'ASSETSITEID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TEMPLATEID_type_info = new String[]{'TEMPLATEID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] VENDOR_type_info = new String[]{'VENDOR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ASSETNUM_type_info = new String[]{'ASSETNUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] LOCATION_type_info = new String[]{'LOCATION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CLASSSTRUCTUREID_type_info = new String[]{'CLASSSTRUCTUREID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ISKNOWNERRORDATE_type_info = new String[]{'ISKNOWNERRORDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] TARGETCONTACTDATE_type_info = new String[]{'TARGETCONTACTDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ACTUALCONTACTDATE_type_info = new String[]{'ACTUALCONTACTDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] FR1CODE_type_info = new String[]{'FR1CODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] FR2CODE_type_info = new String[]{'FR2CODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TICKETUID_type_info = new String[]{'TICKETUID','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] SOLUTION_type_info = new String[]{'SOLUTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ASSETORGID_type_info = new String[]{'ASSETORGID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] LANGCODE_type_info = new String[]{'LANGCODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] HASLD_type_info = new String[]{'HASLD','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CINUM_type_info = new String[]{'CINUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CREATEWOMULTI_type_info = new String[]{'CREATEWOMULTI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] TARGETDESC_type_info = new String[]{'TARGETDESC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SELFSERVSOLACCESS_type_info = new String[]{'SELFSERVSOLACCESS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] HASSOLUTION_type_info = new String[]{'HASSOLUTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CALCORGID_type_info = new String[]{'CALCORGID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CALCCALENDAR_type_info = new String[]{'CALCCALENDAR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CALCSHIFT_type_info = new String[]{'CALCSHIFT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ASSIGNEDOWNERGROUP_type_info = new String[]{'ASSIGNEDOWNERGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPQUOTETYPE_type_info = new String[]{'PLUSPQUOTETYPE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPQUOTEDPRICE_type_info = new String[]{'PLUSPQUOTEDPRICE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PLUSPAGREEMENT_type_info = new String[]{'PLUSPAGREEMENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCUSTOMER_type_info = new String[]{'PLUSPCUSTOMER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCOSTCENTER_type_info = new String[]{'PLUSPCOSTCENTER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCUSTCHACCT_type_info = new String[]{'PLUSPCUSTCHACCT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPRESPONSEPLAN_type_info = new String[]{'PLUSPRESPONSEPLAN','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPREVNUM_type_info = new String[]{'PLUSPREVNUM','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PLUSPPRICESCHED_type_info = new String[]{'PLUSPPRICESCHED','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCUSTPONUM_type_info = new String[]{'PLUSPCUSTPONUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPMAXPRICE_type_info = new String[]{'PLUSPMAXPRICE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PLUSPBILLBATCH_type_info = new String[]{'PLUSPBILLBATCH','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPBBLINENUM_type_info = new String[]{'PLUSPBBLINENUM','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PLUSPPOREQ_type_info = new String[]{'PLUSPPOREQ','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCALCORGID_type_info = new String[]{'PLUSPCALCORGID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCALCCALNUM_type_info = new String[]{'PLUSPCALCCALNUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PLUSPCALCSHIFT_type_info = new String[]{'PLUSPCALCSHIFT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMCOMTYPE_type_info = new String[]{'PMCOMTYPE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMCOMRESOLUTION_type_info = new String[]{'PMCOMRESOLUTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMCOMIMPACT_type_info = new String[]{'PMCOMIMPACT','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PMCOMURGENCY_type_info = new String[]{'PMCOMURGENCY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] INDICATEDPRIORITY_type_info = new String[]{'INDICATEDPRIORITY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] EXTERNALSYSTEM_TICKETID_type_info = new String[]{'EXTERNALSYSTEM_TICKETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] EXTERNALSYSTEM_type_info = new String[]{'EXTERNALSYSTEM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DESCSRVID_type_info = new String[]{'DESCSRVID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CREATEDBY_type_info = new String[]{'CREATEDBY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CREATIONDATE_type_info = new String[]{'CREATIONDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] VIRTUALENV_type_info = new String[]{'VIRTUALENV','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] OUTAGEDURATION_type_info = new String[]{'OUTAGEDURATION','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] CLASSIFICATIONID_type_info = new String[]{'CLASSIFICATIONID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMSCCRID_type_info = new String[]{'PMSCCRID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMSCITEMNUM_type_info = new String[]{'PMSCITEMNUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMSCOFFSUMMARY_type_info = new String[]{'PMSCOFFSUMMARY','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMSCQUANTITY_type_info = new String[]{'PMSCQUANTITY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PMSCITEMSETID_type_info = new String[]{'PMSCITEMSETID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] PMSCTMPLID_type_info = new String[]{'PMSCTMPLID','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] PMSCINVALID_type_info = new String[]{'PMSCINVALID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CORRELATIONATTRS_type_info = new String[]{'CORRELATIONATTRS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ACCUMULATEDHOLDTIME_type_info = new String[]{'ACCUMULATEDHOLDTIME','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ADJUSTEDTARGETCONTACTTIME_type_info = new String[]{'ADJUSTEDTARGETCONTACTTIME','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ADJUSTEDTARGETRESPONSETIME_type_info = new String[]{'ADJUSTEDTARGETRESPONSETIME','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ADJUSTEDTARGETRESOLUTIONTIME_type_info = new String[]{'ADJUSTEDTARGETRESOLUTIONTIME','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] RBA_RC_type_info = new String[]{'RBA_RC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDALTPHONE_type_info = new String[]{'ITDALTPHONE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDCAUSECODE_type_info = new String[]{'ITDCAUSECODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDCHARGABLE_type_info = new String[]{'ITDCHARGABLE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITDCHCREATEDBYGROUP_type_info = new String[]{'ITDCHCREATEDBYGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDCHECK_type_info = new String[]{'ITDCHECK','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDCLOSEDATE_type_info = new String[]{'ITDCLOSEDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITDCLOSURECODE_type_info = new String[]{'ITDCLOSURECODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDDOCCOUNTS_type_info = new String[]{'ITDDOCCOUNTS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITDEXTERNALKMREFERENCE_type_info = new String[]{'ITDEXTERNALKMREFERENCE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDFIRSTCALLRESOLUTION_type_info = new String[]{'ITDFIRSTCALLRESOLUTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDINCEMAILFLG_type_info = new String[]{'ITDINCEMAILFLG','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDINITWF_type_info = new String[]{'ITDINITWF','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDKMRANKING_type_info = new String[]{'ITDKMRANKING','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDMAJORINCIDENT_type_info = new String[]{'ITDMAJORINCIDENT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDRESCODE_type_info = new String[]{'ITDRESCODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDRESOLVERGROUP_type_info = new String[]{'ITDRESOLVERGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDROOTCAUSEDTM_type_info = new String[]{'ITDROOTCAUSEDTM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDSLAHOLDDATE_type_info = new String[]{'ITDSLAHOLDDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITDS_OWNER_type_info = new String[]{'ITDS_OWNER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITDS_OWNERGROUP_type_info = new String[]{'ITDS_OWNERGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CONTBFACTORS_type_info = new String[]{'CONTBFACTORS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] CUSTBUSIMPACT_type_info = new String[]{'CUSTBUSIMPACT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DETECTBYMONITOR_type_info = new String[]{'DETECTBYMONITOR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] IMPRESOLUTION_type_info = new String[]{'IMPRESOLUTION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] RESPONSE1_type_info = new String[]{'RESPONSE1','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] RESPONSE2_type_info = new String[]{'RESPONSE2','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] RESPONSE3_type_info = new String[]{'RESPONSE3','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] RESPONSE4_type_info = new String[]{'RESPONSE4','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] RESPONSE5_type_info = new String[]{'RESPONSE5','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SLAIMPACTED_type_info = new String[]{'SLAIMPACTED','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WHY1_type_info = new String[]{'WHY1','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WHY2_type_info = new String[]{'WHY2','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WHY3_type_info = new String[]{'WHY3','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WHY4_type_info = new String[]{'WHY4','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] WHY5_type_info = new String[]{'WHY5','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNRTC_type_info = new String[]{'ITNRTC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLIORIGEN_type_info = new String[]{'ITNCLIORIGEN','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNTARGETFINISH_type_info = new String[]{'ITNTARGETFINISH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] USERU01_type_info = new String[]{'USERU01','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] DIRECTOR_type_info = new String[]{'DIRECTOR','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GERENCIA_type_info = new String[]{'GERENCIA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] GERENTE_type_info = new String[]{'GERENTE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] USERU2D_type_info = new String[]{'USERU2D','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_CREATESRMULTI_type_info = new String[]{'ITN_CREATESRMULTI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] SLKONETIMECOST_type_info = new String[]{'SLKONETIMECOST','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] SLKANUALRECCOST_type_info = new String[]{'SLKANUALRECCOST','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNAPPRGROUPFILIAL_type_info = new String[]{'ITNAPPRGROUPFILIAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNAPPRGROUPSILKAPP_type_info = new String[]{'ITNAPPRGROUPSILKAPP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNTARGETCUSTOMER_type_info = new String[]{'ITNTARGETCUSTOMER','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNPIPA_type_info = new String[]{'ITNPIPA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSRTIPO_type_info = new String[]{'ITNSRTIPO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSOLEVENTO_type_info = new String[]{'ITNSOLEVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_DETALL_SERVEI_type_info = new String[]{'ITN_SOL_DETALL_SERVEI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_MODEL_type_info = new String[]{'ITN_SOL_MODEL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_NCIAM_type_info = new String[]{'ITN_SOL_NCIAM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_SERIE_type_info = new String[]{'ITN_SOL_SERIE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_TIPUS_type_info = new String[]{'ITN_SOL_TIPUS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNAFFECTEDFINDATE_type_info = new String[]{'ITNAFFECTEDFINDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNAMBITO_type_info = new String[]{'ITNAMBITO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNBASECALINC_type_info = new String[]{'ITNBASECALINC','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNCALCULOPRIORIDAD_type_info = new String[]{'ITNCALCULOPRIORIDAD','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNCATSERV_type_info = new String[]{'ITNCATSERV','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNCENTRO_type_info = new String[]{'ITNCENTRO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCINFIDENCIAL_type_info = new String[]{'ITNCINFIDENCIAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLASSIFICATIONID_type_info = new String[]{'ITNCLASSIFICATIONID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLASSSTRUCTUREID_type_info = new String[]{'ITNCLASSSTRUCTUREID','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLASSSTRUCTUREIDGEN_type_info = new String[]{'ITNCLASSSTRUCTUREIDGEN','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLASSSTRUCTUREIDPLAT_type_info = new String[]{'ITNCLASSSTRUCTUREIDPLAT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCLIENTVIP_type_info = new String[]{'ITNCLIENTVIP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNESCENARIO_type_info = new String[]{'ITNESCENARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEVENTO_type_info = new String[]{'ITNEVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNGRUPOCONTROL_type_info = new String[]{'ITNGRUPOCONTROL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNGRUPONEGOCIO_type_info = new String[]{'ITNGRUPONEGOCIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNGRUPORESPON_type_info = new String[]{'ITNGRUPORESPON','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNIMPALCANCE_type_info = new String[]{'ITNIMPALCANCE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNIMPNEGOCIO_type_info = new String[]{'ITNIMPNEGOCIO','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNIMPRIESGO_type_info = new String[]{'ITNIMPRIESGO','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCACCION_type_info = new String[]{'ITNINCACCION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCINUM_type_info = new String[]{'ITNINCCINUM','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCLASSIFICATIONIDGEN_type_info = new String[]{'ITNINCCLASSIFICATIONIDGEN','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCLASSIFICATIONIDPLAT_type_info = new String[]{'ITNINCCLASSIFICATIONIDPLAT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCLIENTEAFEC_type_info = new String[]{'ITNINCCLIENTEAFEC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCLOSECODE_type_info = new String[]{'ITNINCCLOSECODE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCCONTRATO_type_info = new String[]{'ITNINCCONTRATO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCDETALLE_type_info = new String[]{'ITNINCDETALLE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCFAMILIA_type_info = new String[]{'ITNINCFAMILIA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCFEC_OBJACC_type_info = new String[]{'ITNINCFEC_OBJACC','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCFEC_OBJACEP_type_info = new String[]{'ITNINCFEC_OBJACEP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCFEC_OBJRES_type_info = new String[]{'ITNINCFEC_OBJRES','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCINRECLAS_type_info = new String[]{'ITNINCINRECLAS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCPRODUCTO_type_info = new String[]{'ITNINCPRODUCTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCREVINTREQUIRED_type_info = new String[]{'ITNINCREVINTREQUIRED','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCTYPE_type_info = new String[]{'ITNINCTYPE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINFORMEDIARIO_type_info = new String[]{'ITNINFORMEDIARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNLLAMADASAB_type_info = new String[]{'ITNLLAMADASAB','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLLAMADASAT_type_info = new String[]{'ITNLLAMADASAT','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLOPD_type_info = new String[]{'ITNLOPD','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNEGOCIO_type_info = new String[]{'ITNNEGOCIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNUMABENDS_type_info = new String[]{'ITNNUMABENDS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNUMRECCLASIFIC_type_info = new String[]{'ITNNUMRECCLASIFIC','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNOFFERTYPE_type_info = new String[]{'ITNOFFERTYPE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNOPCONCALLCENTER_type_info = new String[]{'ITNOPCONCALLCENTER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNPSRELACIONADAS_type_info = new String[]{'ITNPSRELACIONADAS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNPUSERAFECTADOS_type_info = new String[]{'ITNPUSERAFECTADOS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNREAPERTURAS_type_info = new String[]{'ITNREAPERTURAS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNRECLAMACIONES_type_info = new String[]{'ITNRECLAMACIONES','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNRECLASIFICACIONES_type_info = new String[]{'ITNRECLASIFICACIONES','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNRELEVANTE_type_info = new String[]{'ITNRELEVANTE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNROL_type_info = new String[]{'ITNROL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSEGPA_type_info = new String[]{'ITNSEGPA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSERVICIOTI_type_info = new String[]{'ITNSERVICIOTI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSEVERIDAD_type_info = new String[]{'ITNSEVERIDAD','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNTIPOAFEC_type_info = new String[]{'ITNTIPOAFEC','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOBATCH_type_info = new String[]{'ITNTIPOBATCH','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOINDISP_type_info = new String[]{'ITNTIPOINDISP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTIPOTRANS_type_info = new String[]{'ITNTIPOTRANS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTOTALMP_type_info = new String[]{'ITNTOTALMP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNTOTALMS_type_info = new String[]{'ITNTOTALMS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNURGENCY_type_info = new String[]{'ITNURGENCY','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNUSERAFECTADOS_type_info = new String[]{'ITNUSERAFECTADOS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNSOLEVENTOXML_type_info = new String[]{'ITNSOLEVENTOXML','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_EVENTO_type_info = new String[]{'ITN_SOL_EVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSEVERIDADTXT_type_info = new String[]{'ITNSEVERIDADTXT','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNCOMCLOSEDATE_type_info = new String[]{'ITNCOMCLOSEDATE','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNINCLISTSEGEVENTO_type_info = new String[]{'ITNINCLISTSEGEVENTO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNGRUPOPROV_type_info = new String[]{'ITNGRUPOPROV','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCREVRESPREQUIRED_type_info = new String[]{'ITNINCREVRESPREQUIRED','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINCTIPO_type_info = new String[]{'ITNINCTIPO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNLLAMADASABP_type_info = new String[]{'ITNLLAMADASABP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNLLAMADASATP_type_info = new String[]{'ITNLLAMADASATP','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNCODISSI_type_info = new String[]{'ITNCODISSI','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNAPLICACION_type_info = new String[]{'ITNAPLICACION','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNNOMBRE_type_info = new String[]{'ITNNOMBRE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA1_type_info = new String[]{'ITNEXTRA1','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA2_type_info = new String[]{'ITNEXTRA2','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA3_type_info = new String[]{'ITNEXTRA3','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA4_type_info = new String[]{'ITNEXTRA4','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRA5_type_info = new String[]{'ITNEXTRA5','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNEXTRAF1_type_info = new String[]{'ITNEXTRAF1','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNEXTRAF2_type_info = new String[]{'ITNEXTRAF2','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNEXTRAN1_type_info = new String[]{'ITNEXTRAN1','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNEXTRAN2_type_info = new String[]{'ITNEXTRAN2','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNFILSISTEMA_type_info = new String[]{'ITNFILSISTEMA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNIMPACTCDS_type_info = new String[]{'ITNIMPACTCDS','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNTAREAS_type_info = new String[]{'ITNTAREAS','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNSLKUSER_type_info = new String[]{'ITNSLKUSER','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKTIPOLLAMADA_type_info = new String[]{'ITNSLKTIPOLLAMADA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKMOTIVOLLAMADA_type_info = new String[]{'ITNSLKMOTIVOLLAMADA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNIMPHORTOTAL_type_info = new String[]{'ITNIMPHORTOTAL','http://www.ibm.com/maximo',null,'0','1','true'};
        private String[] ITNSROWGRVAL_type_info = new String[]{'ITNSROWGRVAL','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNPROPIETARIO_type_info = new String[]{'ITNPROPIETARIO','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITN_SOL_NOFIC_type_info = new String[]{'ITN_SOL_NOFIC','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSENSIBLEDATA_type_info = new String[]{'ITNSENSIBLEDATA','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKRESOLUTORGROUP_type_info = new String[]{'ITNSLKRESOLUTORGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSLKRECOMMENDEDGROUP_type_info = new String[]{'ITNSLKRECOMMENDEDGROUP','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINFORMEDIARIOPREV_type_info = new String[]{'ITNINFORMEDIARIOPREV','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNINFORMEDIARIOEDG_type_info = new String[]{'ITNINFORMEDIARIOEDG','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] ITNSERVICIOSN_type_info = new String[]{'ITNSERVICIOSN','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] action_att_info = new String[]{'action'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'TICKETID','CLASS_x','DESCRIPTION','STATUS','STATUSDATE','REPORTEDPRIORITY','INTERNALPRIORITY','IMPACT','URGENCY','REPORTEDBY','REPORTDATE','AFFECTEDPERSON','AFFECTEDDATE','SOURCE','SUPERVISOR','OWNER','OWNERGROUP','ISGLOBAL','RELATEDTOGLOBAL','GLOBALTICKETID','GLOBALTICKETCLASS','EXTERNALRECID','SITEVISIT','ORIGRECORDID','ORIGRECORDCLASS','GLACCOUNT','COMMODITYGROUP','COMMODITY','INHERITSTATUS','ISKNOWNERROR','TARGETSTART','TARGETFINISH','ACTUALSTART','ACTUALFINISH','ORIGRECSITEID','ORIGRECORGID','SITEID','ORGID','CHANGEDATE','CHANGEBY','HISTORYFLAG','TEMPLATE','HASACTIVITY','FAILURECODE','PROBLEMCODE','ACTLABHRS','ACTLABCOST','AFFECTEDPHONE','REPORTEDPHONE','AFFECTEDEMAIL','REPORTEDEMAIL','ASSETSITEID','TEMPLATEID','VENDOR','ASSETNUM','LOCATION','CLASSSTRUCTUREID','ISKNOWNERRORDATE','TARGETCONTACTDATE','ACTUALCONTACTDATE','FR1CODE','FR2CODE','TICKETUID','SOLUTION','ASSETORGID','LANGCODE','HASLD','CINUM','CREATEWOMULTI','TARGETDESC','SELFSERVSOLACCESS','HASSOLUTION','CALCORGID','CALCCALENDAR','CALCSHIFT','ASSIGNEDOWNERGROUP','PLUSPQUOTETYPE','PLUSPQUOTEDPRICE','PLUSPAGREEMENT','PLUSPCUSTOMER','PLUSPCOSTCENTER','PLUSPCUSTCHACCT','PLUSPRESPONSEPLAN','PLUSPREVNUM','PLUSPPRICESCHED','PLUSPCUSTPONUM','PLUSPMAXPRICE','PLUSPBILLBATCH','PLUSPBBLINENUM','PLUSPPOREQ','PLUSPCALCORGID','PLUSPCALCCALNUM','PLUSPCALCSHIFT','PMCOMTYPE','PMCOMRESOLUTION','PMCOMIMPACT','PMCOMURGENCY','INDICATEDPRIORITY','EXTERNALSYSTEM_TICKETID','EXTERNALSYSTEM','DESCSRVID','CREATEDBY','CREATIONDATE','VIRTUALENV','OUTAGEDURATION','CLASSIFICATIONID','PMSCCRID','PMSCITEMNUM','PMSCOFFSUMMARY','PMSCQUANTITY','PMSCITEMSETID','PMSCTMPLID','PMSCINVALID','CORRELATIONATTRS','ACCUMULATEDHOLDTIME','ADJUSTEDTARGETCONTACTTIME','ADJUSTEDTARGETRESPONSETIME','ADJUSTEDTARGETRESOLUTIONTIME','RBA_RC','ITDALTPHONE','ITDCAUSECODE','ITDCHARGABLE','ITDCHCREATEDBYGROUP','ITDCHECK','ITDCLOSEDATE','ITDCLOSURECODE','ITDDOCCOUNTS','ITDEXTERNALKMREFERENCE','ITDFIRSTCALLRESOLUTION','ITDINCEMAILFLG','ITDINITWF','ITDKMRANKING','ITDMAJORINCIDENT','ITDRESCODE','ITDRESOLVERGROUP','ITDROOTCAUSEDTM','ITDSLAHOLDDATE','ITDS_OWNER','ITDS_OWNERGROUP','CONTBFACTORS','CUSTBUSIMPACT','DETECTBYMONITOR','IMPRESOLUTION','RESPONSE1','RESPONSE2','RESPONSE3','RESPONSE4','RESPONSE5','SLAIMPACTED','WHY1','WHY2','WHY3','WHY4','WHY5','ITNRTC','ITNCLIORIGEN','ITNTARGETFINISH','USERU01','DIRECTOR','GERENCIA','GERENTE','USERU2D','ITN_CREATESRMULTI','SLKONETIMECOST','SLKANUALRECCOST','ITNAPPRGROUPFILIAL','ITNAPPRGROUPSILKAPP','ITNTARGETCUSTOMER','ITNPIPA','ITNSRTIPO','ITNSOLEVENTO','ITN_SOL_DETALL_SERVEI','ITN_SOL_MODEL','ITN_SOL_NCIAM','ITN_SOL_SERIE','ITN_SOL_TIPUS','ITNAFFECTEDFINDATE','ITNAMBITO','ITNBASECALINC','ITNCALCULOPRIORIDAD','ITNCATSERV','ITNCENTRO','ITNCINFIDENCIAL','ITNCLASSIFICATIONID','ITNCLASSSTRUCTUREID','ITNCLASSSTRUCTUREIDGEN','ITNCLASSSTRUCTUREIDPLAT','ITNCLIENTVIP','ITNESCENARIO','ITNEVENTO','ITNGRUPOCONTROL','ITNGRUPONEGOCIO','ITNGRUPORESPON','ITNIMPALCANCE','ITNIMPNEGOCIO','ITNIMPRIESGO','ITNINCACCION','ITNINCCINUM','ITNINCCLASSIFICATIONIDGEN','ITNINCCLASSIFICATIONIDPLAT','ITNINCCLIENTEAFEC','ITNINCCLOSECODE','ITNINCCONTRATO','ITNINCDETALLE','ITNINCFAMILIA','ITNINCFEC_OBJACC','ITNINCFEC_OBJACEP','ITNINCFEC_OBJRES','ITNINCINRECLAS','ITNINCPRODUCTO','ITNINCREVINTREQUIRED','ITNINCTYPE','ITNINFORMEDIARIO','ITNLLAMADASAB','ITNLLAMADASAT','ITNLOPD','ITNNEGOCIO','ITNNUMABENDS','ITNNUMRECCLASIFIC','ITNOFFERTYPE','ITNOPCONCALLCENTER','ITNPSRELACIONADAS','ITNPUSERAFECTADOS','ITNREAPERTURAS','ITNRECLAMACIONES','ITNRECLASIFICACIONES','ITNRELEVANTE','ITNROL','ITNSEGPA','ITNSERVICIOTI','ITNSEVERIDAD','ITNTIPOAFEC','ITNTIPOBATCH','ITNTIPOINDISP','ITNTIPOTRANS','ITNTOTALMP','ITNTOTALMS','ITNURGENCY','ITNUSERAFECTADOS','ITNSOLEVENTOXML','ITN_SOL_EVENTO','ITNSEVERIDADTXT','ITNCOMCLOSEDATE','ITNINCLISTSEGEVENTO','ITNGRUPOPROV','ITNINCREVRESPREQUIRED','ITNINCTIPO','ITNLLAMADASABP','ITNLLAMADASATP','ITNCODISSI','ITNAPLICACION','ITNNOMBRE','ITNEXTRA1','ITNEXTRA2','ITNEXTRA3','ITNEXTRA4','ITNEXTRA5','ITNEXTRAF1','ITNEXTRAF2','ITNEXTRAN1','ITNEXTRAN2','ITNFILSISTEMA','ITNIMPACTCDS','ITNTAREAS','ITNSLKUSER','ITNSLKTIPOLLAMADA','ITNSLKMOTIVOLLAMADA','ITNIMPHORTOTAL','ITNSROWGRVAL','ITNPROPIETARIO','ITN_SOL_NOFIC','ITNSENSIBLEDATA','ITNSLKRESOLUTORGROUP','ITNSLKRECOMMENDEDGROUP','ITNINFORMEDIARIOPREV','ITNINFORMEDIARIOEDG','ITNSERVICIOSN'};
    }
*/
/*    public class InvokeITNINCSIEBEL8V4ResponseType {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
*/
/*    public class MXDomainQueryType {
        public String maxvalue;
        public String operator;
        public Boolean operandModeOR;
        private String[] maxvalue_att_info = new String[]{'maxvalue'};
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class SyncITNINCSIEBEL8V4Type {
        public ITNINCSIEBEL8V4SetType ITNINCSIEBEL8V4Set;
        private String[] ITNINCSIEBEL8V4Set_type_info = new String[]{'ITNINCSIEBEL8V4Set','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'ITNINCSIEBEL8V4Set'};
    }
*/
/*    public class MXGLAccountQueryType {
        public String VALUE;
        public String operator;
        public Boolean operandModeOR;
        private String[] VALUE_type_info = new String[]{'VALUE','http://www.ibm.com/maximo',null,'0','1','false'};
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'VALUE'};
    }
*/
/*    public class MXLongType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
    public class UpdateITNINCSIEBEL8V4ResponseType {
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
/*    public class MXDateTimeQueryType {
        public String operator;
        public Boolean operandModeOR;
        private String[] operator_att_info = new String[]{'operator'};
        private String[] operandModeOR_att_info = new String[]{'operandModeOR'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
/*    public class INCIDENT_element {
        public String TICKETID;
        public MXDomainQueryType[] CLASS_x;
        public MXStringQueryType[] DESCRIPTION;
        public MXDomainQueryType[] STATUS;
        public MXDateTimeQueryType[] STATUSDATE;
        public MXLongQueryType[] REPORTEDPRIORITY;
        public MXLongQueryType[] INTERNALPRIORITY;
        public MXLongQueryType[] IMPACT;
        public MXLongQueryType[] URGENCY;
        public MXStringQueryType[] REPORTEDBY;
        public MXDateTimeQueryType[] REPORTDATE;
        public MXStringQueryType[] AFFECTEDPERSON;
        public MXDateTimeQueryType[] AFFECTEDDATE;
        public MXStringQueryType[] SOURCE;
        public MXStringQueryType[] SUPERVISOR;
        public MXStringQueryType[] OWNER;
        public MXStringQueryType[] OWNERGROUP;
        public MXBooleanQueryType[] ISGLOBAL;
        public MXBooleanQueryType[] RELATEDTOGLOBAL;
        public MXStringQueryType[] GLOBALTICKETID;
        public MXDomainQueryType[] GLOBALTICKETCLASS;
        public MXStringQueryType[] EXTERNALRECID;
        public MXBooleanQueryType[] SITEVISIT;
        public MXStringQueryType[] ORIGRECORDID;
        public MXStringQueryType[] ORIGRECORDCLASS;
        public MXGLAccountQueryType[] GLACCOUNT;
        public MXStringQueryType[] COMMODITYGROUP;
        public MXStringQueryType[] COMMODITY;
        public MXBooleanQueryType[] INHERITSTATUS;
        public MXBooleanQueryType[] ISKNOWNERROR;
        public MXDateTimeQueryType[] TARGETSTART;
        public MXDateTimeQueryType[] TARGETFINISH;
        public MXDateTimeQueryType[] ACTUALSTART;
        public MXDateTimeQueryType[] ACTUALFINISH;
        public MXStringQueryType[] ORIGRECSITEID;
        public MXStringQueryType[] ORIGRECORGID;
        public MXStringQueryType[] SITEID;
        public MXStringQueryType[] ORGID;
        public MXDateTimeQueryType[] CHANGEDATE;
        public MXStringQueryType[] CHANGEBY;
        public MXBooleanQueryType[] HISTORYFLAG;
        public MXBooleanQueryType[] TEMPLATE;
        public MXBooleanQueryType[] HASACTIVITY;
        public MXStringQueryType[] FAILURECODE;
        public MXStringQueryType[] PROBLEMCODE;
        public MXDoubleQueryType[] ACTLABHRS;
        public MXDoubleQueryType[] ACTLABCOST;
        public MXStringQueryType[] AFFECTEDPHONE;
        public MXStringQueryType[] REPORTEDPHONE;
        public MXStringQueryType[] AFFECTEDEMAIL;
        public MXStringQueryType[] REPORTEDEMAIL;
        public MXStringQueryType[] ASSETSITEID;
        public MXStringQueryType[] TEMPLATEID;
        public MXStringQueryType[] VENDOR;
        public MXStringQueryType[] ASSETNUM;
        public MXStringQueryType[] LOCATION;
        public MXStringQueryType[] CLASSSTRUCTUREID;
        public MXDateTimeQueryType[] ISKNOWNERRORDATE;
        public MXDateTimeQueryType[] TARGETCONTACTDATE;
        public MXDateTimeQueryType[] ACTUALCONTACTDATE;
        public MXStringQueryType[] FR1CODE;
        public MXStringQueryType[] FR2CODE;
        public MXLongQueryType[] TICKETUID;
        public MXStringQueryType[] SOLUTION;
        public MXStringQueryType[] ASSETORGID;
        public MXStringQueryType[] LANGCODE;
        public MXBooleanQueryType[] HASLD;
        public MXStringQueryType[] CINUM;
        public MXDomainQueryType[] CREATEWOMULTI;
        public MXStringQueryType[] TARGETDESC;
        public MXBooleanQueryType[] SELFSERVSOLACCESS;
        public MXBooleanQueryType[] HASSOLUTION;
        public MXStringQueryType[] CALCORGID;
        public MXStringQueryType[] CALCCALENDAR;
        public MXStringQueryType[] CALCSHIFT;
        public MXStringQueryType[] ASSIGNEDOWNERGROUP;
        public MXDomainQueryType[] PLUSPQUOTETYPE;
        public MXDoubleQueryType[] PLUSPQUOTEDPRICE;
        public MXStringQueryType[] PLUSPAGREEMENT;
        public MXStringQueryType[] PLUSPCUSTOMER;
        public MXStringQueryType[] PLUSPCOSTCENTER;
        public MXStringQueryType[] PLUSPCUSTCHACCT;
        public MXStringQueryType[] PLUSPRESPONSEPLAN;
        public MXLongQueryType[] PLUSPREVNUM;
        public MXStringQueryType[] PLUSPPRICESCHED;
        public MXStringQueryType[] PLUSPCUSTPONUM;
        public MXDoubleQueryType[] PLUSPMAXPRICE;
        public MXStringQueryType[] PLUSPBILLBATCH;
        public MXLongQueryType[] PLUSPBBLINENUM;
        public MXBooleanQueryType[] PLUSPPOREQ;
        public MXStringQueryType[] PLUSPCALCORGID;
        public MXStringQueryType[] PLUSPCALCCALNUM;
        public MXStringQueryType[] PLUSPCALCSHIFT;
        public MXStringQueryType[] PMCOMTYPE;
        public MXDomainQueryType[] PMCOMRESOLUTION;
        public MXLongQueryType[] PMCOMIMPACT;
        public MXLongQueryType[] PMCOMURGENCY;
        public MXLongQueryType[] INDICATEDPRIORITY;
        public MXStringQueryType[] EXTERNALSYSTEM_TICKETID;
        public MXDomainQueryType[] EXTERNALSYSTEM;
        public MXStringQueryType[] DESCSRVID;
        public MXStringQueryType[] CREATEDBY;
        public MXDateTimeQueryType[] CREATIONDATE;
        public MXBooleanQueryType[] VIRTUALENV;
        public MXDoubleQueryType[] OUTAGEDURATION;
        public MXStringQueryType[] CLASSIFICATIONID;
        public MXStringQueryType[] PMSCCRID;
        public MXStringQueryType[] PMSCITEMNUM;
        public MXStringQueryType[] PMSCOFFSUMMARY;
        public MXLongQueryType[] PMSCQUANTITY;
        public MXStringQueryType[] PMSCITEMSETID;
        public MXLongQueryType[] PMSCTMPLID;
        public MXBooleanQueryType[] PMSCINVALID;
        public MXStringQueryType[] CORRELATIONATTRS;
        public MXDoubleQueryType[] ACCUMULATEDHOLDTIME;
        public MXDateTimeQueryType[] ADJUSTEDTARGETCONTACTTIME;
        public MXDateTimeQueryType[] ADJUSTEDTARGETRESPONSETIME;
        public MXDateTimeQueryType[] ADJUSTEDTARGETRESOLUTIONTIME;
        public MXStringQueryType[] RBA_RC;
        public MXStringQueryType[] ITDALTPHONE;
        public MXStringQueryType[] ITDCAUSECODE;
        public MXLongQueryType[] ITDCHARGABLE;
        public MXStringQueryType[] ITDCHCREATEDBYGROUP;
        public MXBooleanQueryType[] ITDCHECK;
        public MXDateTimeQueryType[] ITDCLOSEDATE;
        public MXStringQueryType[] ITDCLOSURECODE;
        public MXLongQueryType[] ITDDOCCOUNTS;
        public MXStringQueryType[] ITDEXTERNALKMREFERENCE;
        public MXBooleanQueryType[] ITDFIRSTCALLRESOLUTION;
        public MXBooleanQueryType[] ITDINCEMAILFLG;
        public MXBooleanQueryType[] ITDINITWF;
        public MXStringQueryType[] ITDKMRANKING;
        public MXBooleanQueryType[] ITDMAJORINCIDENT;
        public MXStringQueryType[] ITDRESCODE;
        public MXStringQueryType[] ITDRESOLVERGROUP;
        public MXBooleanQueryType[] ITDROOTCAUSEDTM;
        public MXDateTimeQueryType[] ITDSLAHOLDDATE;
        public MXStringQueryType[] ITDS_OWNER;
        public MXStringQueryType[] ITDS_OWNERGROUP;
        public MXStringQueryType[] CONTBFACTORS;
        public MXStringQueryType[] CUSTBUSIMPACT;
        public MXBooleanQueryType[] DETECTBYMONITOR;
        public MXStringQueryType[] IMPRESOLUTION;
        public MXStringQueryType[] RESPONSE1;
        public MXStringQueryType[] RESPONSE2;
        public MXStringQueryType[] RESPONSE3;
        public MXStringQueryType[] RESPONSE4;
        public MXStringQueryType[] RESPONSE5;
        public MXStringQueryType[] SLAIMPACTED;
        public MXStringQueryType[] WHY1;
        public MXStringQueryType[] WHY2;
        public MXStringQueryType[] WHY3;
        public MXStringQueryType[] WHY4;
        public MXStringQueryType[] WHY5;
        public MXStringQueryType[] ITNRTC;
        public MXStringQueryType[] ITNCLIORIGEN;
        public MXDateTimeQueryType[] ITNTARGETFINISH;
        public MXStringQueryType[] USERU01;
        public MXStringQueryType[] DIRECTOR;
        public MXStringQueryType[] GERENCIA;
        public MXStringQueryType[] GERENTE;
        public MXStringQueryType[] USERU2D;
        public MXStringQueryType[] ITN_CREATESRMULTI;
        public MXDoubleQueryType[] SLKONETIMECOST;
        public MXDoubleQueryType[] SLKANUALRECCOST;
        public MXStringQueryType[] ITNAPPRGROUPFILIAL;
        public MXStringQueryType[] ITNAPPRGROUPSILKAPP;
        public MXDateTimeQueryType[] ITNTARGETCUSTOMER;
        public MXBooleanQueryType[] ITNPIPA;
        public MXStringQueryType[] ITNSRTIPO;
        public MXStringQueryType[] ITNSOLEVENTO;
        public MXStringQueryType[] ITN_SOL_DETALL_SERVEI;
        public MXStringQueryType[] ITN_SOL_MODEL;
        public MXStringQueryType[] ITN_SOL_NCIAM;
        public MXStringQueryType[] ITN_SOL_SERIE;
        public MXStringQueryType[] ITN_SOL_TIPUS;
        public MXDateTimeQueryType[] ITNAFFECTEDFINDATE;
        public MXStringQueryType[] ITNAMBITO;
        public MXLongQueryType[] ITNBASECALINC;
        public MXDoubleQueryType[] ITNCALCULOPRIORIDAD;
        public MXLongQueryType[] ITNCATSERV;
        public MXStringQueryType[] ITNCENTRO;
        public MXBooleanQueryType[] ITNCINFIDENCIAL;
        public MXStringQueryType[] ITNCLASSIFICATIONID;
        public MXStringQueryType[] ITNCLASSSTRUCTUREID;
        public MXStringQueryType[] ITNCLASSSTRUCTUREIDGEN;
        public MXStringQueryType[] ITNCLASSSTRUCTUREIDPLAT;
        public MXBooleanQueryType[] ITNCLIENTVIP;
        public MXStringQueryType[] ITNESCENARIO;
        public MXBooleanQueryType[] ITNEVENTO;
        public MXStringQueryType[] ITNGRUPOCONTROL;
        public MXStringQueryType[] ITNGRUPONEGOCIO;
        public MXStringQueryType[] ITNGRUPORESPON;
        public MXLongQueryType[] ITNIMPALCANCE;
        public MXLongQueryType[] ITNIMPNEGOCIO;
        public MXLongQueryType[] ITNIMPRIESGO;
        public MXStringQueryType[] ITNINCACCION;
        public MXStringQueryType[] ITNINCCINUM;
        public MXStringQueryType[] ITNINCCLASSIFICATIONIDGEN;
        public MXStringQueryType[] ITNINCCLASSIFICATIONIDPLAT;
        public MXStringQueryType[] ITNINCCLIENTEAFEC;
        public MXStringQueryType[] ITNINCCLOSECODE;
        public MXStringQueryType[] ITNINCCONTRATO;
        public MXStringQueryType[] ITNINCDETALLE;
        public MXStringQueryType[] ITNINCFAMILIA;
        public MXDateTimeQueryType[] ITNINCFEC_OBJACC;
        public MXDateTimeQueryType[] ITNINCFEC_OBJACEP;
        public MXDateTimeQueryType[] ITNINCFEC_OBJRES;
        public MXBooleanQueryType[] ITNINCINRECLAS;
        public MXStringQueryType[] ITNINCPRODUCTO;
        public MXBooleanQueryType[] ITNINCREVINTREQUIRED;
        public MXStringQueryType[] ITNINCTYPE;
        public MXBooleanQueryType[] ITNINFORMEDIARIO;
        public MXLongQueryType[] ITNLLAMADASAB;
        public MXLongQueryType[] ITNLLAMADASAT;
        public MXBooleanQueryType[] ITNLOPD;
        public MXBooleanQueryType[] ITNNEGOCIO;
        public MXStringQueryType[] ITNNUMABENDS;
        public MXLongQueryType[] ITNNUMRECCLASIFIC;
        public MXStringQueryType[] ITNOFFERTYPE;
        public MXStringQueryType[] ITNOPCONCALLCENTER;
        public MXLongQueryType[] ITNPSRELACIONADAS;
        public MXLongQueryType[] ITNPUSERAFECTADOS;
        public MXLongQueryType[] ITNREAPERTURAS;
        public MXLongQueryType[] ITNRECLAMACIONES;
        public MXLongQueryType[] ITNRECLASIFICACIONES;
        public MXBooleanQueryType[] ITNRELEVANTE;
        public MXStringQueryType[] ITNROL;
        public MXBooleanQueryType[] ITNSEGPA;
        public MXStringQueryType[] ITNSERVICIOTI;
        public MXStringQueryType[] ITNSEVERIDAD;
        public MXLongQueryType[] ITNTIPOAFEC;
        public MXLongQueryType[] ITNTIPOBATCH;
        public MXLongQueryType[] ITNTIPOINDISP;
        public MXLongQueryType[] ITNTIPOTRANS;
        public MXLongQueryType[] ITNTOTALMP;
        public MXDoubleQueryType[] ITNTOTALMS;
        public MXLongQueryType[] ITNURGENCY;
        public MXLongQueryType[] ITNUSERAFECTADOS;
        public MXStringQueryType[] ITNSOLEVENTOXML;
        public MXStringQueryType[] ITN_SOL_EVENTO;
        public MXStringQueryType[] ITNSEVERIDADTXT;
        public MXDateTimeQueryType[] ITNCOMCLOSEDATE;
        public MXStringQueryType[] ITNINCLISTSEGEVENTO;
        public MXStringQueryType[] ITNGRUPOPROV;
        public MXBooleanQueryType[] ITNINCREVRESPREQUIRED;
        public MXStringQueryType[] ITNINCTIPO;
        public MXLongQueryType[] ITNLLAMADASABP;
        public MXLongQueryType[] ITNLLAMADASATP;
        public MXStringQueryType[] ITNCODISSI;
        public MXStringQueryType[] ITNAPLICACION;
        public MXStringQueryType[] ITNNOMBRE;
        public MXStringQueryType[] ITNEXTRA1;
        public MXStringQueryType[] ITNEXTRA2;
        public MXStringQueryType[] ITNEXTRA3;
        public MXStringQueryType[] ITNEXTRA4;
        public MXStringQueryType[] ITNEXTRA5;
        public MXDateTimeQueryType[] ITNEXTRAF1;
        public MXDateTimeQueryType[] ITNEXTRAF2;
        public MXLongQueryType[] ITNEXTRAN1;
        public MXLongQueryType[] ITNEXTRAN2;
        public MXStringQueryType[] ITNFILSISTEMA;
        public MXStringQueryType[] ITNIMPACTCDS;
        public MXLongQueryType[] ITNTAREAS;
        public MXStringQueryType[] ITNSLKUSER;
        public MXStringQueryType[] ITNSLKTIPOLLAMADA;
        public MXStringQueryType[] ITNSLKMOTIVOLLAMADA;
        public MXDoubleQueryType[] ITNIMPHORTOTAL;
        public MXBooleanQueryType[] ITNSROWGRVAL;
        public MXStringQueryType[] ITNPROPIETARIO;
        public MXStringQueryType[] ITN_SOL_NOFIC;
        public MXBooleanQueryType[] ITNSENSIBLEDATA;
        public MXStringQueryType[] ITNSLKRESOLUTORGROUP;
        public MXStringQueryType[] ITNSLKRECOMMENDEDGROUP;
        public MXBooleanQueryType[] ITNINFORMEDIARIOPREV;
        public MXBooleanQueryType[] ITNINFORMEDIARIOEDG;
        public MXStringQueryType[] ITNSERVICIOSN;
        private String[] TICKETID_type_info = new String[]{'TICKETID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CLASS_x_type_info = new String[]{'CLASS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] DESCRIPTION_type_info = new String[]{'DESCRIPTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] STATUS_type_info = new String[]{'STATUS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] STATUSDATE_type_info = new String[]{'STATUSDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] REPORTEDPRIORITY_type_info = new String[]{'REPORTEDPRIORITY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] INTERNALPRIORITY_type_info = new String[]{'INTERNALPRIORITY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] IMPACT_type_info = new String[]{'IMPACT','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] URGENCY_type_info = new String[]{'URGENCY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] REPORTEDBY_type_info = new String[]{'REPORTEDBY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] REPORTDATE_type_info = new String[]{'REPORTDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] AFFECTEDPERSON_type_info = new String[]{'AFFECTEDPERSON','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] AFFECTEDDATE_type_info = new String[]{'AFFECTEDDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] SOURCE_type_info = new String[]{'SOURCE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] SUPERVISOR_type_info = new String[]{'SUPERVISOR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] OWNER_type_info = new String[]{'OWNER','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] OWNERGROUP_type_info = new String[]{'OWNERGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ISGLOBAL_type_info = new String[]{'ISGLOBAL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] RELATEDTOGLOBAL_type_info = new String[]{'RELATEDTOGLOBAL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] GLOBALTICKETID_type_info = new String[]{'GLOBALTICKETID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] GLOBALTICKETCLASS_type_info = new String[]{'GLOBALTICKETCLASS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] EXTERNALRECID_type_info = new String[]{'EXTERNALRECID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] SITEVISIT_type_info = new String[]{'SITEVISIT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ORIGRECORDID_type_info = new String[]{'ORIGRECORDID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ORIGRECORDCLASS_type_info = new String[]{'ORIGRECORDCLASS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] GLACCOUNT_type_info = new String[]{'GLACCOUNT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] COMMODITYGROUP_type_info = new String[]{'COMMODITYGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] COMMODITY_type_info = new String[]{'COMMODITY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] INHERITSTATUS_type_info = new String[]{'INHERITSTATUS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ISKNOWNERROR_type_info = new String[]{'ISKNOWNERROR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] TARGETSTART_type_info = new String[]{'TARGETSTART','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] TARGETFINISH_type_info = new String[]{'TARGETFINISH','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ACTUALSTART_type_info = new String[]{'ACTUALSTART','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ACTUALFINISH_type_info = new String[]{'ACTUALFINISH','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ORIGRECSITEID_type_info = new String[]{'ORIGRECSITEID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ORIGRECORGID_type_info = new String[]{'ORIGRECORGID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] SITEID_type_info = new String[]{'SITEID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ORGID_type_info = new String[]{'ORGID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CHANGEDATE_type_info = new String[]{'CHANGEDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] CHANGEBY_type_info = new String[]{'CHANGEBY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] HISTORYFLAG_type_info = new String[]{'HISTORYFLAG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] TEMPLATE_type_info = new String[]{'TEMPLATE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] HASACTIVITY_type_info = new String[]{'HASACTIVITY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] FAILURECODE_type_info = new String[]{'FAILURECODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PROBLEMCODE_type_info = new String[]{'PROBLEMCODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ACTLABHRS_type_info = new String[]{'ACTLABHRS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ACTLABCOST_type_info = new String[]{'ACTLABCOST','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] AFFECTEDPHONE_type_info = new String[]{'AFFECTEDPHONE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] REPORTEDPHONE_type_info = new String[]{'REPORTEDPHONE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] AFFECTEDEMAIL_type_info = new String[]{'AFFECTEDEMAIL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] REPORTEDEMAIL_type_info = new String[]{'REPORTEDEMAIL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ASSETSITEID_type_info = new String[]{'ASSETSITEID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] TEMPLATEID_type_info = new String[]{'TEMPLATEID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] VENDOR_type_info = new String[]{'VENDOR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ASSETNUM_type_info = new String[]{'ASSETNUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] LOCATION_type_info = new String[]{'LOCATION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CLASSSTRUCTUREID_type_info = new String[]{'CLASSSTRUCTUREID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ISKNOWNERRORDATE_type_info = new String[]{'ISKNOWNERRORDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] TARGETCONTACTDATE_type_info = new String[]{'TARGETCONTACTDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ACTUALCONTACTDATE_type_info = new String[]{'ACTUALCONTACTDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] FR1CODE_type_info = new String[]{'FR1CODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] FR2CODE_type_info = new String[]{'FR2CODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] TICKETUID_type_info = new String[]{'TICKETUID','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] SOLUTION_type_info = new String[]{'SOLUTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ASSETORGID_type_info = new String[]{'ASSETORGID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] LANGCODE_type_info = new String[]{'LANGCODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] HASLD_type_info = new String[]{'HASLD','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CINUM_type_info = new String[]{'CINUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CREATEWOMULTI_type_info = new String[]{'CREATEWOMULTI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] TARGETDESC_type_info = new String[]{'TARGETDESC','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] SELFSERVSOLACCESS_type_info = new String[]{'SELFSERVSOLACCESS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] HASSOLUTION_type_info = new String[]{'HASSOLUTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CALCORGID_type_info = new String[]{'CALCORGID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CALCCALENDAR_type_info = new String[]{'CALCCALENDAR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CALCSHIFT_type_info = new String[]{'CALCSHIFT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ASSIGNEDOWNERGROUP_type_info = new String[]{'ASSIGNEDOWNERGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPQUOTETYPE_type_info = new String[]{'PLUSPQUOTETYPE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPQUOTEDPRICE_type_info = new String[]{'PLUSPQUOTEDPRICE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PLUSPAGREEMENT_type_info = new String[]{'PLUSPAGREEMENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCUSTOMER_type_info = new String[]{'PLUSPCUSTOMER','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCOSTCENTER_type_info = new String[]{'PLUSPCOSTCENTER','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCUSTCHACCT_type_info = new String[]{'PLUSPCUSTCHACCT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPRESPONSEPLAN_type_info = new String[]{'PLUSPRESPONSEPLAN','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPREVNUM_type_info = new String[]{'PLUSPREVNUM','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PLUSPPRICESCHED_type_info = new String[]{'PLUSPPRICESCHED','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCUSTPONUM_type_info = new String[]{'PLUSPCUSTPONUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPMAXPRICE_type_info = new String[]{'PLUSPMAXPRICE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PLUSPBILLBATCH_type_info = new String[]{'PLUSPBILLBATCH','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPBBLINENUM_type_info = new String[]{'PLUSPBBLINENUM','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PLUSPPOREQ_type_info = new String[]{'PLUSPPOREQ','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCALCORGID_type_info = new String[]{'PLUSPCALCORGID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCALCCALNUM_type_info = new String[]{'PLUSPCALCCALNUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PLUSPCALCSHIFT_type_info = new String[]{'PLUSPCALCSHIFT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMCOMTYPE_type_info = new String[]{'PMCOMTYPE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMCOMRESOLUTION_type_info = new String[]{'PMCOMRESOLUTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMCOMIMPACT_type_info = new String[]{'PMCOMIMPACT','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PMCOMURGENCY_type_info = new String[]{'PMCOMURGENCY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] INDICATEDPRIORITY_type_info = new String[]{'INDICATEDPRIORITY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] EXTERNALSYSTEM_TICKETID_type_info = new String[]{'EXTERNALSYSTEM_TICKETID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] EXTERNALSYSTEM_type_info = new String[]{'EXTERNALSYSTEM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] DESCSRVID_type_info = new String[]{'DESCSRVID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CREATEDBY_type_info = new String[]{'CREATEDBY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CREATIONDATE_type_info = new String[]{'CREATIONDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] VIRTUALENV_type_info = new String[]{'VIRTUALENV','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] OUTAGEDURATION_type_info = new String[]{'OUTAGEDURATION','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] CLASSIFICATIONID_type_info = new String[]{'CLASSIFICATIONID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMSCCRID_type_info = new String[]{'PMSCCRID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMSCITEMNUM_type_info = new String[]{'PMSCITEMNUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMSCOFFSUMMARY_type_info = new String[]{'PMSCOFFSUMMARY','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMSCQUANTITY_type_info = new String[]{'PMSCQUANTITY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PMSCITEMSETID_type_info = new String[]{'PMSCITEMSETID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] PMSCTMPLID_type_info = new String[]{'PMSCTMPLID','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] PMSCINVALID_type_info = new String[]{'PMSCINVALID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CORRELATIONATTRS_type_info = new String[]{'CORRELATIONATTRS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ACCUMULATEDHOLDTIME_type_info = new String[]{'ACCUMULATEDHOLDTIME','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ADJUSTEDTARGETCONTACTTIME_type_info = new String[]{'ADJUSTEDTARGETCONTACTTIME','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ADJUSTEDTARGETRESPONSETIME_type_info = new String[]{'ADJUSTEDTARGETRESPONSETIME','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ADJUSTEDTARGETRESOLUTIONTIME_type_info = new String[]{'ADJUSTEDTARGETRESOLUTIONTIME','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] RBA_RC_type_info = new String[]{'RBA_RC','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDALTPHONE_type_info = new String[]{'ITDALTPHONE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDCAUSECODE_type_info = new String[]{'ITDCAUSECODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDCHARGABLE_type_info = new String[]{'ITDCHARGABLE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITDCHCREATEDBYGROUP_type_info = new String[]{'ITDCHCREATEDBYGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDCHECK_type_info = new String[]{'ITDCHECK','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDCLOSEDATE_type_info = new String[]{'ITDCLOSEDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITDCLOSURECODE_type_info = new String[]{'ITDCLOSURECODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDDOCCOUNTS_type_info = new String[]{'ITDDOCCOUNTS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITDEXTERNALKMREFERENCE_type_info = new String[]{'ITDEXTERNALKMREFERENCE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDFIRSTCALLRESOLUTION_type_info = new String[]{'ITDFIRSTCALLRESOLUTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDINCEMAILFLG_type_info = new String[]{'ITDINCEMAILFLG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDINITWF_type_info = new String[]{'ITDINITWF','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDKMRANKING_type_info = new String[]{'ITDKMRANKING','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDMAJORINCIDENT_type_info = new String[]{'ITDMAJORINCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDRESCODE_type_info = new String[]{'ITDRESCODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDRESOLVERGROUP_type_info = new String[]{'ITDRESOLVERGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDROOTCAUSEDTM_type_info = new String[]{'ITDROOTCAUSEDTM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDSLAHOLDDATE_type_info = new String[]{'ITDSLAHOLDDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITDS_OWNER_type_info = new String[]{'ITDS_OWNER','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITDS_OWNERGROUP_type_info = new String[]{'ITDS_OWNERGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CONTBFACTORS_type_info = new String[]{'CONTBFACTORS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] CUSTBUSIMPACT_type_info = new String[]{'CUSTBUSIMPACT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] DETECTBYMONITOR_type_info = new String[]{'DETECTBYMONITOR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] IMPRESOLUTION_type_info = new String[]{'IMPRESOLUTION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] RESPONSE1_type_info = new String[]{'RESPONSE1','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] RESPONSE2_type_info = new String[]{'RESPONSE2','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] RESPONSE3_type_info = new String[]{'RESPONSE3','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] RESPONSE4_type_info = new String[]{'RESPONSE4','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] RESPONSE5_type_info = new String[]{'RESPONSE5','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] SLAIMPACTED_type_info = new String[]{'SLAIMPACTED','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WHY1_type_info = new String[]{'WHY1','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WHY2_type_info = new String[]{'WHY2','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WHY3_type_info = new String[]{'WHY3','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WHY4_type_info = new String[]{'WHY4','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] WHY5_type_info = new String[]{'WHY5','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNRTC_type_info = new String[]{'ITNRTC','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCLIORIGEN_type_info = new String[]{'ITNCLIORIGEN','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNTARGETFINISH_type_info = new String[]{'ITNTARGETFINISH','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] USERU01_type_info = new String[]{'USERU01','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] DIRECTOR_type_info = new String[]{'DIRECTOR','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] GERENCIA_type_info = new String[]{'GERENCIA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] GERENTE_type_info = new String[]{'GERENTE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] USERU2D_type_info = new String[]{'USERU2D','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_CREATESRMULTI_type_info = new String[]{'ITN_CREATESRMULTI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] SLKONETIMECOST_type_info = new String[]{'SLKONETIMECOST','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] SLKANUALRECCOST_type_info = new String[]{'SLKANUALRECCOST','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNAPPRGROUPFILIAL_type_info = new String[]{'ITNAPPRGROUPFILIAL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNAPPRGROUPSILKAPP_type_info = new String[]{'ITNAPPRGROUPSILKAPP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNTARGETCUSTOMER_type_info = new String[]{'ITNTARGETCUSTOMER','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNPIPA_type_info = new String[]{'ITNPIPA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSRTIPO_type_info = new String[]{'ITNSRTIPO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSOLEVENTO_type_info = new String[]{'ITNSOLEVENTO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_DETALL_SERVEI_type_info = new String[]{'ITN_SOL_DETALL_SERVEI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_MODEL_type_info = new String[]{'ITN_SOL_MODEL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_NCIAM_type_info = new String[]{'ITN_SOL_NCIAM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_SERIE_type_info = new String[]{'ITN_SOL_SERIE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_TIPUS_type_info = new String[]{'ITN_SOL_TIPUS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNAFFECTEDFINDATE_type_info = new String[]{'ITNAFFECTEDFINDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNAMBITO_type_info = new String[]{'ITNAMBITO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNBASECALINC_type_info = new String[]{'ITNBASECALINC','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNCALCULOPRIORIDAD_type_info = new String[]{'ITNCALCULOPRIORIDAD','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNCATSERV_type_info = new String[]{'ITNCATSERV','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNCENTRO_type_info = new String[]{'ITNCENTRO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCINFIDENCIAL_type_info = new String[]{'ITNCINFIDENCIAL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCLASSIFICATIONID_type_info = new String[]{'ITNCLASSIFICATIONID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCLASSSTRUCTUREID_type_info = new String[]{'ITNCLASSSTRUCTUREID','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCLASSSTRUCTUREIDGEN_type_info = new String[]{'ITNCLASSSTRUCTUREIDGEN','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCLASSSTRUCTUREIDPLAT_type_info = new String[]{'ITNCLASSSTRUCTUREIDPLAT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCLIENTVIP_type_info = new String[]{'ITNCLIENTVIP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNESCENARIO_type_info = new String[]{'ITNESCENARIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEVENTO_type_info = new String[]{'ITNEVENTO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNGRUPOCONTROL_type_info = new String[]{'ITNGRUPOCONTROL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNGRUPONEGOCIO_type_info = new String[]{'ITNGRUPONEGOCIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNGRUPORESPON_type_info = new String[]{'ITNGRUPORESPON','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNIMPALCANCE_type_info = new String[]{'ITNIMPALCANCE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNIMPNEGOCIO_type_info = new String[]{'ITNIMPNEGOCIO','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNIMPRIESGO_type_info = new String[]{'ITNIMPRIESGO','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNINCACCION_type_info = new String[]{'ITNINCACCION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCCINUM_type_info = new String[]{'ITNINCCINUM','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCCLASSIFICATIONIDGEN_type_info = new String[]{'ITNINCCLASSIFICATIONIDGEN','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCCLASSIFICATIONIDPLAT_type_info = new String[]{'ITNINCCLASSIFICATIONIDPLAT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCCLIENTEAFEC_type_info = new String[]{'ITNINCCLIENTEAFEC','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCCLOSECODE_type_info = new String[]{'ITNINCCLOSECODE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCCONTRATO_type_info = new String[]{'ITNINCCONTRATO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCDETALLE_type_info = new String[]{'ITNINCDETALLE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCFAMILIA_type_info = new String[]{'ITNINCFAMILIA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCFEC_OBJACC_type_info = new String[]{'ITNINCFEC_OBJACC','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNINCFEC_OBJACEP_type_info = new String[]{'ITNINCFEC_OBJACEP','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNINCFEC_OBJRES_type_info = new String[]{'ITNINCFEC_OBJRES','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNINCINRECLAS_type_info = new String[]{'ITNINCINRECLAS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCPRODUCTO_type_info = new String[]{'ITNINCPRODUCTO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCREVINTREQUIRED_type_info = new String[]{'ITNINCREVINTREQUIRED','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCTYPE_type_info = new String[]{'ITNINCTYPE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINFORMEDIARIO_type_info = new String[]{'ITNINFORMEDIARIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNLLAMADASAB_type_info = new String[]{'ITNLLAMADASAB','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNLLAMADASAT_type_info = new String[]{'ITNLLAMADASAT','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNLOPD_type_info = new String[]{'ITNLOPD','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNNEGOCIO_type_info = new String[]{'ITNNEGOCIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNNUMABENDS_type_info = new String[]{'ITNNUMABENDS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNNUMRECCLASIFIC_type_info = new String[]{'ITNNUMRECCLASIFIC','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNOFFERTYPE_type_info = new String[]{'ITNOFFERTYPE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNOPCONCALLCENTER_type_info = new String[]{'ITNOPCONCALLCENTER','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNPSRELACIONADAS_type_info = new String[]{'ITNPSRELACIONADAS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNPUSERAFECTADOS_type_info = new String[]{'ITNPUSERAFECTADOS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNREAPERTURAS_type_info = new String[]{'ITNREAPERTURAS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNRECLAMACIONES_type_info = new String[]{'ITNRECLAMACIONES','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNRECLASIFICACIONES_type_info = new String[]{'ITNRECLASIFICACIONES','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNRELEVANTE_type_info = new String[]{'ITNRELEVANTE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNROL_type_info = new String[]{'ITNROL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSEGPA_type_info = new String[]{'ITNSEGPA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSERVICIOTI_type_info = new String[]{'ITNSERVICIOTI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSEVERIDAD_type_info = new String[]{'ITNSEVERIDAD','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNTIPOAFEC_type_info = new String[]{'ITNTIPOAFEC','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNTIPOBATCH_type_info = new String[]{'ITNTIPOBATCH','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNTIPOINDISP_type_info = new String[]{'ITNTIPOINDISP','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNTIPOTRANS_type_info = new String[]{'ITNTIPOTRANS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNTOTALMP_type_info = new String[]{'ITNTOTALMP','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNTOTALMS_type_info = new String[]{'ITNTOTALMS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNURGENCY_type_info = new String[]{'ITNURGENCY','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNUSERAFECTADOS_type_info = new String[]{'ITNUSERAFECTADOS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNSOLEVENTOXML_type_info = new String[]{'ITNSOLEVENTOXML','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_EVENTO_type_info = new String[]{'ITN_SOL_EVENTO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSEVERIDADTXT_type_info = new String[]{'ITNSEVERIDADTXT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNCOMCLOSEDATE_type_info = new String[]{'ITNCOMCLOSEDATE','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNINCLISTSEGEVENTO_type_info = new String[]{'ITNINCLISTSEGEVENTO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNGRUPOPROV_type_info = new String[]{'ITNGRUPOPROV','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCREVRESPREQUIRED_type_info = new String[]{'ITNINCREVRESPREQUIRED','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINCTIPO_type_info = new String[]{'ITNINCTIPO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNLLAMADASABP_type_info = new String[]{'ITNLLAMADASABP','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNLLAMADASATP_type_info = new String[]{'ITNLLAMADASATP','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNCODISSI_type_info = new String[]{'ITNCODISSI','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNAPLICACION_type_info = new String[]{'ITNAPLICACION','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNNOMBRE_type_info = new String[]{'ITNNOMBRE','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEXTRA1_type_info = new String[]{'ITNEXTRA1','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEXTRA2_type_info = new String[]{'ITNEXTRA2','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEXTRA3_type_info = new String[]{'ITNEXTRA3','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEXTRA4_type_info = new String[]{'ITNEXTRA4','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEXTRA5_type_info = new String[]{'ITNEXTRA5','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNEXTRAF1_type_info = new String[]{'ITNEXTRAF1','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNEXTRAF2_type_info = new String[]{'ITNEXTRAF2','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNEXTRAN1_type_info = new String[]{'ITNEXTRAN1','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNEXTRAN2_type_info = new String[]{'ITNEXTRAN2','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNFILSISTEMA_type_info = new String[]{'ITNFILSISTEMA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNIMPACTCDS_type_info = new String[]{'ITNIMPACTCDS','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNTAREAS_type_info = new String[]{'ITNTAREAS','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNSLKUSER_type_info = new String[]{'ITNSLKUSER','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSLKTIPOLLAMADA_type_info = new String[]{'ITNSLKTIPOLLAMADA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSLKMOTIVOLLAMADA_type_info = new String[]{'ITNSLKMOTIVOLLAMADA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNIMPHORTOTAL_type_info = new String[]{'ITNIMPHORTOTAL','http://www.ibm.com/maximo',null,'0','-1','true'};
        private String[] ITNSROWGRVAL_type_info = new String[]{'ITNSROWGRVAL','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNPROPIETARIO_type_info = new String[]{'ITNPROPIETARIO','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITN_SOL_NOFIC_type_info = new String[]{'ITN_SOL_NOFIC','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSENSIBLEDATA_type_info = new String[]{'ITNSENSIBLEDATA','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSLKRESOLUTORGROUP_type_info = new String[]{'ITNSLKRESOLUTORGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSLKRECOMMENDEDGROUP_type_info = new String[]{'ITNSLKRECOMMENDEDGROUP','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINFORMEDIARIOPREV_type_info = new String[]{'ITNINFORMEDIARIOPREV','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNINFORMEDIARIOEDG_type_info = new String[]{'ITNINFORMEDIARIOEDG','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] ITNSERVICIOSN_type_info = new String[]{'ITNSERVICIOSN','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'TICKETID','CLASS_x','DESCRIPTION','STATUS','STATUSDATE','REPORTEDPRIORITY','INTERNALPRIORITY','IMPACT','URGENCY','REPORTEDBY','REPORTDATE','AFFECTEDPERSON','AFFECTEDDATE','SOURCE','SUPERVISOR','OWNER','OWNERGROUP','ISGLOBAL','RELATEDTOGLOBAL','GLOBALTICKETID','GLOBALTICKETCLASS','EXTERNALRECID','SITEVISIT','ORIGRECORDID','ORIGRECORDCLASS','GLACCOUNT','COMMODITYGROUP','COMMODITY','INHERITSTATUS','ISKNOWNERROR','TARGETSTART','TARGETFINISH','ACTUALSTART','ACTUALFINISH','ORIGRECSITEID','ORIGRECORGID','SITEID','ORGID','CHANGEDATE','CHANGEBY','HISTORYFLAG','TEMPLATE','HASACTIVITY','FAILURECODE','PROBLEMCODE','ACTLABHRS','ACTLABCOST','AFFECTEDPHONE','REPORTEDPHONE','AFFECTEDEMAIL','REPORTEDEMAIL','ASSETSITEID','TEMPLATEID','VENDOR','ASSETNUM','LOCATION','CLASSSTRUCTUREID','ISKNOWNERRORDATE','TARGETCONTACTDATE','ACTUALCONTACTDATE','FR1CODE','FR2CODE','TICKETUID','SOLUTION','ASSETORGID','LANGCODE','HASLD','CINUM','CREATEWOMULTI','TARGETDESC','SELFSERVSOLACCESS','HASSOLUTION','CALCORGID','CALCCALENDAR','CALCSHIFT','ASSIGNEDOWNERGROUP','PLUSPQUOTETYPE','PLUSPQUOTEDPRICE','PLUSPAGREEMENT','PLUSPCUSTOMER','PLUSPCOSTCENTER','PLUSPCUSTCHACCT','PLUSPRESPONSEPLAN','PLUSPREVNUM','PLUSPPRICESCHED','PLUSPCUSTPONUM','PLUSPMAXPRICE','PLUSPBILLBATCH','PLUSPBBLINENUM','PLUSPPOREQ','PLUSPCALCORGID','PLUSPCALCCALNUM','PLUSPCALCSHIFT','PMCOMTYPE','PMCOMRESOLUTION','PMCOMIMPACT','PMCOMURGENCY','INDICATEDPRIORITY','EXTERNALSYSTEM_TICKETID','EXTERNALSYSTEM','DESCSRVID','CREATEDBY','CREATIONDATE','VIRTUALENV','OUTAGEDURATION','CLASSIFICATIONID','PMSCCRID','PMSCITEMNUM','PMSCOFFSUMMARY','PMSCQUANTITY','PMSCITEMSETID','PMSCTMPLID','PMSCINVALID','CORRELATIONATTRS','ACCUMULATEDHOLDTIME','ADJUSTEDTARGETCONTACTTIME','ADJUSTEDTARGETRESPONSETIME','ADJUSTEDTARGETRESOLUTIONTIME','RBA_RC','ITDALTPHONE','ITDCAUSECODE','ITDCHARGABLE','ITDCHCREATEDBYGROUP','ITDCHECK','ITDCLOSEDATE','ITDCLOSURECODE','ITDDOCCOUNTS','ITDEXTERNALKMREFERENCE','ITDFIRSTCALLRESOLUTION','ITDINCEMAILFLG','ITDINITWF','ITDKMRANKING','ITDMAJORINCIDENT','ITDRESCODE','ITDRESOLVERGROUP','ITDROOTCAUSEDTM','ITDSLAHOLDDATE','ITDS_OWNER','ITDS_OWNERGROUP','CONTBFACTORS','CUSTBUSIMPACT','DETECTBYMONITOR','IMPRESOLUTION','RESPONSE1','RESPONSE2','RESPONSE3','RESPONSE4','RESPONSE5','SLAIMPACTED','WHY1','WHY2','WHY3','WHY4','WHY5','ITNRTC','ITNCLIORIGEN','ITNTARGETFINISH','USERU01','DIRECTOR','GERENCIA','GERENTE','USERU2D','ITN_CREATESRMULTI','SLKONETIMECOST','SLKANUALRECCOST','ITNAPPRGROUPFILIAL','ITNAPPRGROUPSILKAPP','ITNTARGETCUSTOMER','ITNPIPA','ITNSRTIPO','ITNSOLEVENTO','ITN_SOL_DETALL_SERVEI','ITN_SOL_MODEL','ITN_SOL_NCIAM','ITN_SOL_SERIE','ITN_SOL_TIPUS','ITNAFFECTEDFINDATE','ITNAMBITO','ITNBASECALINC','ITNCALCULOPRIORIDAD','ITNCATSERV','ITNCENTRO','ITNCINFIDENCIAL','ITNCLASSIFICATIONID','ITNCLASSSTRUCTUREID','ITNCLASSSTRUCTUREIDGEN','ITNCLASSSTRUCTUREIDPLAT','ITNCLIENTVIP','ITNESCENARIO','ITNEVENTO','ITNGRUPOCONTROL','ITNGRUPONEGOCIO','ITNGRUPORESPON','ITNIMPALCANCE','ITNIMPNEGOCIO','ITNIMPRIESGO','ITNINCACCION','ITNINCCINUM','ITNINCCLASSIFICATIONIDGEN','ITNINCCLASSIFICATIONIDPLAT','ITNINCCLIENTEAFEC','ITNINCCLOSECODE','ITNINCCONTRATO','ITNINCDETALLE','ITNINCFAMILIA','ITNINCFEC_OBJACC','ITNINCFEC_OBJACEP','ITNINCFEC_OBJRES','ITNINCINRECLAS','ITNINCPRODUCTO','ITNINCREVINTREQUIRED','ITNINCTYPE','ITNINFORMEDIARIO','ITNLLAMADASAB','ITNLLAMADASAT','ITNLOPD','ITNNEGOCIO','ITNNUMABENDS','ITNNUMRECCLASIFIC','ITNOFFERTYPE','ITNOPCONCALLCENTER','ITNPSRELACIONADAS','ITNPUSERAFECTADOS','ITNREAPERTURAS','ITNRECLAMACIONES','ITNRECLASIFICACIONES','ITNRELEVANTE','ITNROL','ITNSEGPA','ITNSERVICIOTI','ITNSEVERIDAD','ITNTIPOAFEC','ITNTIPOBATCH','ITNTIPOINDISP','ITNTIPOTRANS','ITNTOTALMP','ITNTOTALMS','ITNURGENCY','ITNUSERAFECTADOS','ITNSOLEVENTOXML','ITN_SOL_EVENTO','ITNSEVERIDADTXT','ITNCOMCLOSEDATE','ITNINCLISTSEGEVENTO','ITNGRUPOPROV','ITNINCREVRESPREQUIRED','ITNINCTIPO','ITNLLAMADASABP','ITNLLAMADASATP','ITNCODISSI','ITNAPLICACION','ITNNOMBRE','ITNEXTRA1','ITNEXTRA2','ITNEXTRA3','ITNEXTRA4','ITNEXTRA5','ITNEXTRAF1','ITNEXTRAF2','ITNEXTRAN1','ITNEXTRAN2','ITNFILSISTEMA','ITNIMPACTCDS','ITNTAREAS','ITNSLKUSER','ITNSLKTIPOLLAMADA','ITNSLKMOTIVOLLAMADA','ITNIMPHORTOTAL','ITNSROWGRVAL','ITNPROPIETARIO','ITN_SOL_NOFIC','ITNSENSIBLEDATA','ITNSLKRESOLUTORGROUP','ITNSLKRECOMMENDEDGROUP','ITNINFORMEDIARIOPREV','ITNINFORMEDIARIOEDG','ITNSERVICIOSN'};
    }
*/
    public class INCIDENTMboKeySetType {
        public INCIDENTKeyType[] INCIDENT;
        private String[] INCIDENT_type_info = new String[]{'INCIDENT','http://www.ibm.com/maximo',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'INCIDENT'};
    }
    public class INCIDENTKeyType {
        public String CLASS_x;
        public String TICKETID;
        private String[] CLASS_x_type_info = new String[]{'CLASS','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] TICKETID_type_info = new String[]{'TICKETID','http://www.ibm.com/maximo',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{'CLASS_x','TICKETID'};
    }
/*    public class MXIntType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class MXDoubleType {
        public String changed;
        private String[] changed_att_info = new String[]{'changed'};
        private String[] apex_schema_type_info = new String[]{'http://www.ibm.com/maximo','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
*/
}