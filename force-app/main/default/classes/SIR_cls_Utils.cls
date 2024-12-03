public with sharing class SIR_cls_Utils {

    public static Set<Id> getAppRtIds(String appDevName,String obj){
        
        Set<Id> setRtIds = new Set<Id>();
        if(appDevName == SIR_Constantes.APP_EMPRESA_DEVELOPERNAME){
            switch on obj {
                when 'SIREC__SIREC_obj_proceso__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId());  
                }
                when 'SIREC__SIREC_obj_acciones__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_EMPRESA).getRecordTypeId());
                }
            }
        }
        else if(appDevName == SIR_Constantes.APP_RETAIL_DEVELOPERNAME){
            switch on obj {
                when 'SIREC__SIREC_obj_proceso__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA).getRecordTypeId());  
                }
                when 'SIREC__SIREC_obj_acciones__c' {
                    Map<String, Schema.RecordTypeInfo> mapRT = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_WORKFLOW).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
                    setRtIds.add(mapRT.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO).getRecordTypeId());
                }
            }
        }
        return setRtIds;
    }
   // Devuelve el prefijo que se debe incorporar en las llamadas a WS segun la app en la que esté conetada el gestor
    public static String getActorPrefix(){
        List<UserAppInfo> userAppInfo;    
        if(Schema.SObjectType.UserAppInfo.isAccessible()){  
            userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() AND FormFactor !='Small' ORDER BY LastModifiedDate DESC LIMIT 1 ];            
        }    
        return userAppInfo.size()>0 ? getActorPrefix(userAppInfo[0].AppDefinitionId): '';                 
   }

    public static String getActorPrefix(String appDefinitionId){
        try {
            String appDeveloperName;
            if(Test.isRunningTest() && appDefinitionId == 'mcsolutions'){                
                appDeveloperName = 'SIR_misClientesSolutions';
            }else if(Test.isRunningTest() && appDefinitionId == 'mcsolutionsEmp'){                
                appDeveloperName = 'SIRE_MisClientesSolucionesEMP';
            }else{
                appDeveloperName = [SELECT DurableId, DeveloperName FROM AppDefinition Where DurableId = :appDefinitionId LIMIT 1].DeveloperName;
            }
            String prefix='';
            if (appDeveloperName != null){
                switch on appDeveloperName {
                when 'SIR_misClientesSolutions' {
                    prefix = SIR_Constantes.APP_ACT_MCSOL_PREFIX;
                }
                when 'SIRE_MisClientesSolucionesEMP' {
                    prefix = SIR_Constantes.APP_ACT_MCSOLEMP_PREFIX;
                }
                when else {
                    prefix = '';
                  }
               }     
           } 
           return prefix;
        } catch (Exception ex) {
            throw new SIRECallException('SIR_cls_Utils - La aplicación que se está usando no tiene acceso al Sistema SIREC');
        }        
   }
    // 
    /**
	* Obtiene los valores de la custom setting SIR_Parametros que se recibe por parametro y los devuelve en una lista con los registros de SIR_Parametros__c
	*
	* @param maxItem   Name del registro de SIR_Parametros que contiene el nro de items del parametro a consultar
    * @param nameItem  Primera parte del Name del registro de SIR_Parametros a consultar
    * @return List<SIR_Parametros__c> lista con los registros de SIR_Parametros del Name que se recibe por parametro
	*/	
    public static List<SIR_Parametros__c> getSIRParametros(String maxItem, String nameItem){
        List<SIR_Parametros__c> lstParam= new List<SIR_Parametros__c>();
        SIR_Parametros__c configMaxItem = SIR_Parametros__c.getInstance(maxItem);
        Integer iMaxItem = (String.isNotBlank(configMaxItem?.SIR_Valor__c)) ? Integer.valueOf(configMaxItem?.SIR_Valor__c) : 10;
        for (Integer i = 0; i < iMaxItem; i++){
            String clave = nameItem + '_' + String.valueOf(i).leftPad(2,'0');
            lstParam.add(SIR_Parametros__c.getInstance(clave));
        }
        return lstParam;
    }
  
    /**
	* Obtiene la lista de los usuarios con Profile API que tenemos parametrizados en SIR_Parametros. Son usuarios que pueden tener asignados procesos SIREC
	*
	* @return  List<String> lista con usuarios con profile API
	*/	
    public static List<String> getUsersAPI(){
        List<String> lstUser = new List<String>();
        List<SIR_Parametros__c> lstParam = getSIRParametros('maxUserIntegration', 'userIntegration');        
        for (SIR_Parametros__c param :lstParam){
            if (String.isNotBlank(param?.SIR_Valor__c) && param?.SIR_Activo__c == true){
                lstUser.add(param?.SIR_Valor__c);
            }
        }
        return lstUser;
    }

    /**
	* Obtiene la lista de todos los Id de los userDXC de todos los negocios
	* @return  List<Id> Lista con los Id de los usuarios DXC 
	*/	
    public static List<Id> getUsersDXC(){        
        return getUsersDXC('ALL');
    }

    /**
	* Obtiene la lista de Id de los userDXC de un negocio.
	* @param negocio   Nombre del negocio del que se quiere obtener los usuarios para distribuir los procesos DXC
	* @return  List<Id> Lista con los Id de los usuarios DXC 
	*/	
    public static List<Id> getUsersDXC(String negocio){
        List<String> lstUser = new List<String>();
        List<Id> lstUserId = new List<Id>();
        List<SIR_Parametros__c> lstParam = getSIRParametros('maxUserDXC', 'userDXC');        
        //obtiene las matriculas de los empleados DXC parametrizados en la custom setting
        for (SIR_Parametros__c param :lstParam){
            if ((param?.SIR_Parametro__c == negocio || negocio == 'ALL') && String.isNotBlank(param?.SIR_Valor__c) && param?.SIR_Activo__c == true){
                lstUser.add(param?.SIR_Valor__c);
            }
        }
        // seleccionar los id de los empleados a partir de la lista de matricular
        for (User u : [SELECT Id FROM User WHERE EmployeeNumber in :lstUser]){
            lstUserId.add(u.Id);
        }
        return lstUserId;
    }

    /**
	* Obtiene la lista de las estrategiasDXC de un negocio.
	* @param negocio   Nombre del negocio del que se quiere obtener las estrategias de los procesos DXC
	* @return  List<String> Lista con los codigos de las estrategias DXC
	*/
    public static List<String> getEstrategiasDXC(String negocio){
        List<String> lstUser = new List<String>();
        List<SIR_Parametros__c> lstParam = getSIRParametros('maxEstrategiasDXC', 'estrategiasDXC');        
        for (SIR_Parametros__c param :lstParam){
            if (param?.SIR_Parametro__c == negocio && String.isNotBlank(param?.SIR_Valor__c) && param?.SIR_Activo__c == true){
                lstUser.add(param?.SIR_Valor__c);
            }
        }
        return lstUser;
    }


    // Propiedad estragiaCatalogo donde estarán todos los registros de estrategias activos ordenados 
    // la query se realiza una única vez solo cuando se accede a la propiedad y está vacía
    @AuraEnabled
    public static List<SIREC__SIREC_obj_Catalogo__c> estrategiasCatalogo {
        get {
            if (estrategiasCatalogo == null) {
                estrategiasCatalogo = [SELECT name,  SIREC__SIREC_fld_Codigo__c, SIREC__SIREC_fld_Descripcion__c, SIREC__SIREC_fld_MasterRecordId__c, SIREC__SIREC_fld_CodigoActivo__c, SIREC__SIREC_fld_CodigoAgrupador__c, SIREC__SIREC_fld_CodigoNegocio__c, SIREC__SIREC_fld_DescAgrupador__c, SIREC__SIREC_fld_OrdenAgrupador__c 
                                    FROM SIREC__SIREC_obj_Catalogo__c 
                                    WHERE Name = :SIR_Constantes.CATALOGO_PREFIJO_ESTRATEGIA 
                                    AND SIREC__SIREC_fld_CodigoActivo__c = 'S'
                                    ORDER BY SIREC__SIREC_fld_OrdenAgrupador__c];
            }
            return estrategiasCatalogo;
    }
        set;
    }

    // Recorre la propiedad estrategia para obtener las estrategias de un negocio recibido como parametro
    @AuraEnabled(Cacheable=true)
    public static  List<SIREC__SIREC_obj_Catalogo__c> getEstrategiasNegocio(String negocio){        
        List<SIREC__SIREC_obj_Catalogo__c> estrategiasNegocio = new List<SIREC__SIREC_obj_Catalogo__c>();
        for(SIREC__SIREC_obj_Catalogo__c e : estrategiasCatalogo) {
            if(e.SIREC__SIREC_fld_CodigoNegocio__c == negocio){
            estrategiasNegocio.add(e);
            }
        }
        return estrategiasNegocio;
    }

    public class SIRECallException extends Exception {}
}