/**********************************************************************************************************************
 Name:	  AV_PoolEvents_Controller
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class por Pool Meeting home table
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			PPM100492394	Luis Fernández   	17/09/2024			Init version
    1.2         Carga de citas Pool 
                sin asignar     Luis Fernández      18/10/2024          Added new version of getCurrentDT which can return a map of input centers with related DT's with a single query.
***********************************************************************************************************************/
public with sharing class AV_PoolEvents_Controller {
    /**
     * Class to map event fields to lightning dataTable
     */
    public class TableEventData{
        @AuraEnabled
        public string clientName;
        @AuraEnabled
        public string clientId;
        @AuraEnabled
        public string eventSubject;
        @AuraEnabled
        public string eventId;
        @AuraEnabled
        public string eventDateTime;
        @AuraEnabled
        public string eventType;
        @AuraEnabled
        public string eventRightId;
    
        public TableEventData(Event evt){
            this.clientName = evt.Account.Name;
            this.clientId = '/'+evt.AccountId;
            this.eventSubject = evt.Subject;
            this.eventId = '/'+evt.Id;
            this.eventRightId = evt.Id;
            this.eventDateTime = evt.ActivityDateTime.format('dd MMM yyyy, HH:mm');
            this.eventType = evt.AV_Tipo__c;
        }
    }
    /**
     * Class to send well-formated event information to lwc
     */
    public with sharing class ResponseWrapper{
        @AuraEnabled 
        public List<TableEventData> data = new List<TableEventData>();
        @AuraEnabled 
        public Integer dataSize = 0;
        @AuraEnabled 
        public Map<String,Map<String,String>> eventToClientMapReport = new Map<String,Map<String,String>>() ;
        @AuraEnabled 
        public Map<String,Map<String,String>> eventToClientMapAssign = new Map<String,Map<String,String>>() ;

        public ResponseWrapper(List<Event> evts){
            List<Contact> cntGestor = [SELECT AV_EmpleadoIntouch__c,CC_Matricula__c  FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
            String isIntouch = (!cntGestor.isEmpty()) ? String.valueOf(cntGestor[0].AV_EmpleadoIntouch__c) : null;
            String clientPlate = (!cntGestor.isEmpty()) ? String.valueOf(cntGestor[0].CC_Matricula__c) : null;
            for(Event evt : evts){
                this.dataSize++;
                this.data.add(new TableEventData(evt));
                this.eventToClientMapReport.put(evt.Id,
                    new Map<String,String>{
                    'c__recId' =>  evt.Id,
                    'c__id' => evt.Account.Name,
                    'c__rt' => evt.RecordType.DeveloperName,
                    'c__intouch' => isIntouch,
                    'c__account' => evt.AccountId
                    }
                );
                this.eventToClientMapAssign.put(evt.Id,
                    new Map<String,String>{
                    'c__id' => evt.Id
                    }
                );
            }
        }

    }
    /**
     * Retrieve today and future events related to current user pool.
     */
    @AuraEnabled
    public static ResponseWrapper retrievePoolEvents(){
        String methodName = 'retrievePoolEvents';
        List<User> currentUser = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId()];
        String multiGestId = getCurrentDT(currentUser[0].AV_NumeroOficinaEmpresa__c);
        if(multiGestId != null){
            String center = (currentUser[0].AV_NumeroOficinaEmpresa__c.contains(AV_AppConstants.DASH))? currentUser[0].AV_NumeroOficinaEmpresa__c.split(AV_AppConstants.DASH)[1] : currentUser[0].AV_NumeroOficinaEmpresa__c;
            List<Event> data = [SELECT Id,AccountId,Account.Name,Account.AV_Numperso__c,Subject,ActivityDateTime,TOLABEL(AV_Tipo__c),RecordType.DeveloperName FROM Event WHERE ActivityDate >= TODAY AND OwnerId = :multiGestId AND RecordType.DeveloperName = :AV_AppConstants.EVENTCLIENTE_RT AND AV_Center__c = :center ORDER BY ActivityDateTime ASC ,Account.AV_LastContactDate__c ASC];
            return new ResponseWrapper(data);
        }

        return null;
    }   

    /**
    Find the actual DT Office of the given office and return the appropiate multigest user
    @param  currentOfficeNumber Office to find related DT
    */
    @AuraEnabled
    public static String getCurrentDT(String currentOfficeNumber){
        String methodName = 'getCurrentDT';
        String dtOfficesNumber;
        List<Account> searchingDT = [SELECT Id, AV_TipoCentro__c,CC_Numero_Oficina_Empresa__c, 
            AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,

            AV_CentroSuperior__r.AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,

            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,

            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c

            FROM Account
            WHERE  CC_Numero_Oficina_Empresa__c = :currentOfficeNumber];
            
        if(!searchingDT.isEmpty()){
            Account currentAccount = searchingDT[0];
            if(currentAccount.AV_TipoCentro__c == null){
                return null;
            }else if(currentAccount.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                dtOfficesNumber = currentAccount.CC_Numero_Oficina_Empresa__c;
                
            }
            else if(currentAccount.AV_CentroSuperior__c == null){
                return null;
            }else if(currentAccount.AV_CentroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                dtOfficesNumber = currentAccount.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                
            }
            else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__c == null){
                return null;
            }else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                dtOfficesNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                
            }
            else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__c == null){
                return null;
            }else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                dtOfficesNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                
            }
            else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__r.AV_CentroSuperior__c == null){
                return null;
            }else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                dtOfficesNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                
            }
            
            if(dtOfficesNumber == null){
                currentOfficeNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                dtOfficesNumber = getCurrentDT(currentOfficeNumber);
                List<User> findedBP = [SELECT Id,Alias,Name FROM User WHERE Id = :dtOfficesNumber AND Alias LIKE 'BPA0%'];
                if(!findedBP.isEmpty()){
                    return dtOfficesNumber;
                }
            }
            
            List<AV_MultiEmployees__mdt> aliasOfficeMultigeMap = [SELECT AV_Alias__c FROM AV_MultiEmployees__mdt WHERE AV_NumeroOficinaEmpresa__c = :dtOfficesNumber  LIMIT 1];
            if(!aliasOfficeMultigeMap.isEmpty()){
                List<User> multigestor = [SELECT Id FROM User WHERE Alias = :aliasOfficeMultigeMap[0].AV_Alias__c ORDER BY CreatedDate DESC];
                if(!multigestor.isEmpty()){
                    return (String) multigestor[0].Id;
                }
            }
        }
        return null;

    }
    /**
     * Works as getCurrentDT but can handle a list of offices and search them based on CC_Numero_Oficina__c since it is mean to be used withing the AV_Center__c of events.
     * @param List<String> officesToDt. OfficesTo map
     */
    public static Map<String,String> getCurrentDTMap(Set<String> officesToSolve){
        String methodName = 'getCurrentDTMap';
        String dtOfficesNumber;
        Map<String,String> officeToDt = new Map<String,String>();
        Map<String,String> centerNumberToEmpresaNumber = new Map<String,String>();
        Map<String,String> officesToPoolUser = new Map<String,String>();
        Map<String,String> unfindedDTs = new Map<String,String>();
        List<Account> searchingDT = [SELECT Id, AV_TipoCentro__c,CC_Numero_Oficina_Empresa__c,CC_Numero_Oficina__c ,
            AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,

            AV_CentroSuperior__r.AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,

            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,

            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c, 
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c,
            AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina__c

            FROM Account
            WHERE  CC_Numero_Oficina__c = :officesToSolve AND RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT];
            
        if(!searchingDT.isEmpty()){
            for(Account currentAccount : searchingDT){
                centerNumberToEmpresaNumber.put(currentAccount.CC_Numero_Oficina__c,currentAccount.CC_Numero_Oficina_Empresa__c);
                if(currentAccount.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    dtOfficesNumber = currentAccount.CC_Numero_Oficina_Empresa__c;
                    
                }
                else if(currentAccount.AV_CentroSuperior__c == null){
                    return null;
                }
                  else if(currentAccount.AV_CentroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    dtOfficesNumber = currentAccount.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                    
                }
                else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__c == null){
                    return null;
                }
                  else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    dtOfficesNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                    
                }
                else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__c == null){
                    return null;
                }
                  else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    dtOfficesNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                    
                }
                else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__r.AV_CentroSuperior__c == null){
                    return null;
                }
                  else if(currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_centroSuperior__r.AV_CentroSuperior__r.AV_TipoCentro__c.equals(AV_AppConstants.FUNCION_DT)){
                    dtOfficesNumber = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina_Empresa__c;
                    
                }
                
                if(dtOfficesNumber != null){
                    officeToDt.put(currentAccount.CC_Numero_Oficina_Empresa__c,dtOfficesNumber);
                }else{
                    String nextTry = currentAccount.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__r.CC_Numero_Oficina__c;
                    unfindedDTs.put(nextTry,currentAccount.CC_Numero_Oficina__c);
                }
            }


            if(!unfindedDTs.isEmpty()){
                Map<String,String> deeperHierarchyOffices = getCurrentDTMap(unfindedDTs.keySet());
                for(String office : deeperHierarchyOffices.keySet()){
                    String baseOffice = unfindedDTs.get(office);
                    officesToPoolUser.put(baseOffice,deeperHierarchyOffices.get(office));
                }
            }
            
            if(!officeToDt.isEmpty()){ 
                List<AV_MultiEmployees__mdt> aliasOfficeMultigeMap = [SELECT AV_Alias__c FROM AV_MultiEmployees__mdt WHERE AV_NumeroOficinaEmpresa__c = :officeToDt.values()];
                if(!aliasOfficeMultigeMap.isEmpty()){
                    List<String> poolAlias = new List<String>();
                    for(AV_MultiEmployees__mdt poolUser : aliasOfficeMultigeMap){
                        poolAlias.add(poolUser.AV_Alias__c);
                    }
                    List<User> multigestor = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias IN :poolAlias ORDER BY CreatedDate DESC];
                    if(!multigestor.isEmpty()){
                        Map<String,String> dtToPool = new Map<String,String>();
                        for(User multi : multigestor){
                            dtToPool.put(multi.AV_NumeroOficinaEmpresa__c,multi.Id);
                        }

                        for(String originalOffice : officesToSolve){
                            if(!officesToPoolUser.containsKey(originalOffice)){
                                String empresaNumber = centerNumberToEmpresaNumber.get(originalOffice);
                                String currentDt = officeToDt.get(empresaNumber);
                                String dtPoolUser = dtToPool.get(currentDt);
                                officesToPoolUser.put(originalOffice,dtPoolUser);
                            }
                        }
                        return officesToPoolUser;
                    }else{
                        return null;
                    }
                    }
                }else if(!officesToPoolUser.isEmpty()){
                    return officesToPoolUser;
            }else{
                return null;

            }
        }
        return null;

    }

     
}