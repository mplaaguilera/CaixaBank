/**********************************************************************************************************************
Name: AV_MW_Cobrowsing_Integration
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración Cobrowsing - Unblu
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY              AUTHOR                 DATE			  Description
    1.0                             Bea y Ali              28/6/2024      Initial version
    1.1     PPM101193755            Ángel Medina           30/04/2025     Modify method cobrowsingIntegrationCallout to add hashedCustomerInternalId, hashedMandatoryAssistanceEmployeeId, customerDocumentId and mandatoryAssistanceEmployeeEmail     
***********************************************************************************************************************/

global with sharing class AV_MW_Cobrowsing_Integration implements Callable {

    private class ResponseWrapper {
        @AuraEnabled
        //public String hashedCustomerInternalId;
        public String customerInternalId;
        @AuraEnabled
        //public String hashedMandatoryAssistanceEmployeeId;
        public String mandatoryAssistanceEmployeeId;
        @AuraEnabled
        public String conversationType;
        /*@AuraEnabled
        public String customerDocumentId;
        @AuraEnabled
        public String mandatoryAssistanceEmployeeEmail;*/
    }

    @AuraEnabled
    public static string cobrowsingIntegrationCallout(Id recordId, String pinCode){
        string sError = '';
        string sResp = '';
        Id accountId = recordId;

        if (pinCode != null){
            try {  
                
                if(String.isNotBlank(recordId)) {
                    if (recordId.getSObjectType() == Account.SObjectType) {
                        accountId = recordId;
                    } else if (recordId.getSObjectType() == Case.SObjectType) {
                        accountId = [SELECT AccountId FROM Case WHERE Id = :recordId LIMIT 1].AccountId;
                    }
                }

                List <Account> accList = [SELECT Id, AV_NumPerso__c, AV_Idioma__c, CC_Numero_Documento__c FROM Account WHERE Id = :accountId LIMIT 1];
                List <User> usGestList = [SELECT Id, AV_ExternalID__c, Email FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];

                if (accList[0].AV_NumPerso__c != null && usGestList[0].AV_ExternalID__c != null) {

                    Map<String,string> mHeaders =  new  Map<String,string>();
                    CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('AV_Cobrowsing');
                    mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                    String body = '{"customerInternalId":"[NUMPERSO]","mandatoryAssistanceEmployeeId":"[EXTERNALID]","conversationType":"[COBROWSING]","languageCode":"[LANGUAGE]","pin":"[PINCODE]"}';
                    Long longUser = long.valueOf(accList[0].AV_Numperso__c);
                    String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
                    /*String body = '{"hashedCustomerInternalId":"[NUMPERSO]","customerDocumentId":"[DNI]","hashedMandatoryAssistanceEmployeeId":"[EXTERNALID]","mandatoryAssistanceEmployeeEmail":"[EMAIL]","conversationType":"[COBROWSING]","languageCode":"[LANGUAGE]","pin":"[PINCODE]"}';*/
                    String language = (accList[0].AV_Idioma__c != null) ? accList[0].AV_Idioma__c : '002';

                    body = body.replace('[NUMPERSO]', hexDigest).replace('[EXTERNALID]', usGestList[0].AV_ExternalID__c).replace('[COBROWSING]', 'COBROWSING').replace('[LANGUAGE]', language).replace('[PINCODE]', pinCode);
                    /*Blob hashedCustomerBlob = Crypto.generateDigest('SHA-512', Blob.valueOf(accList[0].AV_NumPerso__c));
                    Blob hashedEmployeeBlob = Crypto.generateDigest('SHA-512', Blob.valueOf(usGestList[0].AV_ExternalID__c));

                    String hashedCustomerInternalId = EncodingUtil.convertToHex(hashedCustomerBlob);
                    String hashedMandatoryAssistanceEmployeeId = EncodingUtil.convertToHex(hashedEmployeeBlob);
    
                    body = body.replace('[NUMPERSO]', hashedCustomerInternalId).replace('[DNI]', accList[0].CC_Numero_Documento__c).replace('[EXTERNALID]', hashedMandatoryAssistanceEmployeeId).replace('[EMAIL]', usGestList[0].Email).replace('[COBROWSING]', 'COBROWSING').replace('[LANGUAGE]', language).replace('[PINCODE]', pinCode);*/

                    CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                            reqWrapper.body = body;
                            reqWrapper.intSetting = 'AV_Cobrowsing';
                            reqWrapper.method = 'POST';
                            reqWrapper.mHeaders =  mHeaders;
                            reqWrapper.mUriParams = new  Map<String,string>();
                            reqWrapper.mQueryParams = new  Map<String,string>();
                    
                    HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
                    HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, recordId, 'AV_Cobrowsing');
                    
                    if (res.getStatusCode() == 201) {
                        sResp = 'recordId: ' + recordId + '. Response OK: ' + res.getStatusCode() + ' ' + res.getBody();
                    } else {
                        sResp = 'recordId: ' + recordId + '. Response Error: ' + res.getStatusCode() + ' ' + res.getBody();
                        CBK_Log.error(sResp);
                    } 
                } 
                
                return sResp;
    
            } catch (Exception e) {
                CBK_Log.error(e, 'recordId: ' + recordId);
                sError = 'Error al integrar con MW_COBROWSING, revisar logs para más información.';
                return sError;
    
            } finally {
                if(sError != ''){
                    throw new AuraHandledException(sError);
                }
            }

        } else{
            sError = 'recordId: ' + recordId + '. PinCode is empty: ';
            CBK_Log.error(sError);
            return sError;
        }
    }
    
    global Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'cobrowsingIntegrationCallout' {
                return cobrowsingIntegrationCallout((Id)args.get('recordId'), (String)args.get('pinCode'));
            }
            when else {
                throw new CalloutException('Method not implemented');
            }
        }
    }
    
}