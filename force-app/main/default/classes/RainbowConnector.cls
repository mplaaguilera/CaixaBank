/**********************************************************************************************************************
Name:	  RainbowConnector
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de la integración de Rainbow
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
    VERSION		USER_STORY         AUTHOR              DATE			    Description
    1.0             -              Bea y Ali           3/04/2024        Init Version

***********************************************************************************************************************/

@RestResource(urlMapping='/RainbowConnector/*')

global with sharing class  RainbowConnector extends CBK_HttpServiceIntegration_Abstract {

    webService static String getUserEmail() {
        return UserInfo.getUserEmail();
    }
    webService static String getMainURL(){
        return ApexPages.currentPage().getUrl();
    } 

    webService static String phoneNumberWithoutPrefix(String phoneNumber) {
        String formatPhoneNumber = phoneNumber;
        if (phoneNumber.startsWith('+34')) {
            formatPhoneNumber = phoneNumber.substring(3);
        }
        return formatPhoneNumber;
    }

    webService static String phoneNumberWithSpace(String phoneNumber) {
        String formatPhoneNumber = phoneNumber;
        if (phoneNumber.startsWith('+34')) {
            formatPhoneNumber = phoneNumber.substring(0, 3) + ' ' + phoneNumber.substring(3);
        }
        return formatPhoneNumber;
    }

    @AuraEnabled
    webService static String getAccountsByPhoneNumber(String phoneNumber, String direction) {
        String withoutPrefix = phoneNumberWithoutPrefix(phoneNumber);
        String withSpace = phoneNumberWithSpace(phoneNumber);
        List<String> phoneList =  new List<String> {phoneNumber, withoutPrefix, withSpace};
        List <Account> accountList = new List<Account>();

        accountList = [SELECT Id, Name, Phone,PersonMobilePhone, AV_AttentionModel__c, BillingAddress, Owner.Name, PersonEmail, CC_Email__c,  
                        AV_EAPGestor__c, AV_EAPGestor__r.Name, CC_Numero_Documento__c, Description, AV_LoyaltyPrograms__c, AV_Preconceived__c, AV_PreconceivedText__c, AV_LastContactDate__c, AV_LastContactDateText__c
                        FROM Account 
                        WHERE Phone IN :phoneList OR PersonMobilePhone IN :phoneList LIMIT 10];
        
        Map<String,String> pickListValuesMap = new Map<String,String>();
        for( Schema.PicklistEntry pickListVal : Account.AV_AttentionModel__c.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
        }

        for(Account acc: accountList){
            if (acc.AV_AttentionModel__c != null && pickListValuesMap.containsKey(acc.AV_AttentionModel__c)) {
                acc.AV_AttentionModel__c = pickListValuesMap.get(acc.AV_AttentionModel__c);
            }
        }

        String callInfoJson;
        if(!accountList.isEmpty()){
            Exception exc;
            List<Wrapper> callInfo = new List<Wrapper>();
            for(Account acc : accountList){
                
                Wrapper wrap = new Wrapper();
                wrap.accId = acc.Id;
                wrap.accName = acc.Name;
                wrap.phoneNumber = phoneNumber;
                wrap.dt = Datetime.now();
                wrap.atModel = acc.AV_AttentionModel__c;
                wrap.eapGestorId = (String.isBlank(acc.AV_EAPGestor__c)) ? '' : acc.AV_EAPGestor__c;
                wrap.eapGestorName = (String.isBlank(acc.AV_EAPGestor__r.Name)) ? '' : acc.AV_EAPGestor__r.Name; 

                callInfo.add(wrap);

                acc.Name = acc.Name + ' / ' + ((String.isBlank(acc.CC_Numero_Documento__c)) ? '' : acc.CC_Numero_Documento__c);
                acc.AV_LoyaltyPrograms__c = 'Programa fidelización: ' + acc.AV_LoyaltyPrograms__c;
                

            }

            callInfoJson = JSON.serialize(callInfo);
            CBK_Log.saveError('Rainbow: ',exc,'callInfo: ',callInfo);
        }

        String JSONString = JSON.serialize(accountList);

        return JSONString;
    }

    webService static String getAccountsByFirstLastName(String firstlastname) {
        List <Account> accountList = new List<Account>();

        accountList = [SELECT Id, Name, Phone, PersonMobilePhone, AV_AttentionModel__c, BillingAddress, Owner.Name, PersonEmail, CC_Email__c  FROM Account 
        WHERE Name = :firstlastname LIMIT 10];
        
        String JSONString = JSON.serialize(accountList);
        return JSONString;
    }

    webService static String getAllRecordTypes() {
        List <RecordType> recordTypeList = new List<RecordType>();
        for (RecordType recordTypes : [SELECT Id,Name,SobjectType,Description FROM RecordType ]) {
            recordTypeList.add(recordTypes);
        }
        string JSONString=JSON.serialize(recordTypeList);
        return JSONString;
    }

    webservice static String getProfileRecordTypesAccount(){
    List<RecordTypeInfo> recordTypes = new List<RecordTypeInfo>();
        for(RecordTypeInfo info: Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable() && info.name != 'Master') {
                recordTypes.add(info);
            }
        }
    String JSONString=JSON.serialize(recordTypes);
    return JSONString;
    }


    webService static String addCallRecord(String calldatetime, String  phoneNumber, String duration, String direction, String callid, String state, String comments,String accountid){

        String objectID='';
        
        List <CC_Llamada__c> callExtIDList = [SELECT AV_ExternalID__c FROM CC_Llamada__c WHERE AV_ExternalID__c =: callid LIMIT 1];
        
        
        try{
            if(callExtIDList.isEmpty()){
                if(accountid != null){
                    String withoutPrefix = phoneNumberWithoutPrefix(phoneNumber);
                    String withSpace = phoneNumberWithSpace(phoneNumber);
                    List<String> phoneList =  new List<String> {phoneNumber, withoutPrefix, withSpace};
                    List <Account> accPhoneList = [SELECT Id FROM Account WHERE Phone IN :phoneList OR PersonMobilePhone IN :phoneList];
                    List<AggregateResult>  accCountResults = [SELECT COUNT(Id) total FROM Account WHERE Phone IN :phoneList OR PersonMobilePhone IN :phoneList];
                    Integer accCount = (Integer)accCountResults[0].get('total');
                    if(accCount == 1){
                        accountid = accPhoneList[0].Id;
                    }
                }
                List<String> tipos = new List<String>{'Entrante', 'Saliente'};
                List<String> directions = new List<String>{'incoming', 'outgoing'};

                List<String> estados = new List<String>{'Respondida', 'Perdida'};
                List<String> states = new List<String>{'answered', 'missed'};

                Map<String, String> tiposMap = new Map<String, String>();

                for (Integer i = 0; i < directions.size(); i++) {
                    tiposMap.put(directions[i], tipos[i]);
                }
                
                Map <String, String> stateMap =  new Map <String, String>();
                for (Integer i = 0; i < states.size(); i++) {
                    stateMap.put(states[i], estados[i]);
                }
                
                RecordType rt = AV_AppUtilities.getRecordType('CC_Llamada__c', 'AV_CallLog');

                
                CC_Llamada__c llamada = new CC_Llamada__c(
                        CC_Fecha_Inicio__c = DateTime.valueOf(calldatetime),
                        OB_Telefono__c = phoneNumber,
                        AV_Duration__c = duration,
                        CC_Tipo__c = tiposMap.get(direction),
                        AV_State__c = stateMap.get(state),
                        AV_Account__c = (String.isBlank(accountid)) ? null : accountid,
                        AV_ExternalID__c = callid,
                        RecordtypeId = rt.Id);
                
                if(llamada.CC_Tipo__c == 'Saliente' && llamada.CC_Tipo__c != null){
                    llamada.AV_State__c = 'Respondida';
                }

                // Obtener los settings para el tipo de duración
                List<AV_CallDurationType__c> settings = [SELECT MinDuration__c, MaxDuration__c, Type__c FROM AV_CallDurationType__c];
                if (llamada.AV_Duration__c != null) {
                    // Convertir AV_Duration__c de String a Number
                    Integer durationInt;
                    try {
                        durationInt = Integer.valueOf(llamada.AV_Duration__c);
                    } catch (Exception e) {
                        // Manejar la excepción si la conversión falla, se establece la duración en -1 para que no coincida con ningún rango
                        durationInt = -1;
                    }
                    
                    for (AV_CallDurationType__c setting : settings) {
                        if (durationInt >= setting.MinDuration__c && (setting.MaxDuration__c == null || durationInt <= setting.MaxDuration__c)) {
                            llamada.AV_DurationType__c = setting.Type__c;
                        }
                    }
                }
                
                
                insert llamada;

                List <Account> numperList =  [SELECT AV_NumPerso__c  FROM Account WHERE Id = :llamada.AV_Account__c LIMIT 1];
                List <CC_Llamada__c> llamadaNameList = [SELECT Name FROM CC_Llamada__c WHERE Id = :llamada.Id LIMIT 1];
                List <Contact> matriculaGestorList = [SELECT CC_Matricula__c  FROM Contact WHERE AV_UsuarioAsociado__c  = :llamada.OwnerId LIMIT 1];

                String numper = (!numperList.isEmpty()) ? numperList[0].AV_NumPerso__c : '';
                String llamadaName = llamadaNameList[0].Name;
                String matriculaGestor = (!matriculaGestorList.isEmpty()) ? matriculaGestorList[0].CC_Matricula__c : '';
                
                if (accountid == null || accountid == '') {
                        objectID = callid+ ',' + null + ',' + llamadaName + ',' + null;       
                } else {
                        objectID = callid + ',' + numper + ',' + llamadaName + ',' + matriculaGestor;
                }

            }
        } catch (DmlException e) {
            // Registrar el mensaje de error completo
            System.debug('Error al insertar el registro: ' + e.getMessage());
            objectID = 'ignoremessage';
            // Verificar si el error es de tipo DUPLICATE_VALUE
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                System.debug('Error DUPLICATE_VALUE: ' + e.getMessage());
            }
            
        } catch (Exception e) {
            objectID = callid + ',' + 'Error Exception: '+ e.getMessage();
            System.debug('Error Exception: ' + e.getMessage());
        }
        return objectID;
    }


    public class Wrapper{
        @AuraEnabled
        public String accId {get;set;}

        @AuraEnabled
        public String accName {get;set;}

        @AuraEnabled
        public String phoneNumber {get;set;}

        @AuraEnabled
        public DateTime dt {get;set;}

        @AuraEnabled
        public String atModel {get;set;}

        @AuraEnabled
        public String eapGestorId {get;set;}

        @AuraEnabled
        public String eapGestorName {get;set;}

    }

}