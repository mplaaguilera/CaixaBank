/**********************************************************************************************************************
Name: AV_MW_Cobrowsing_Integration_WithoutPIN
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración Cobrowsing - Unblu without PIN parameter
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY              AUTHOR                 DATE			  Description
    1.0                             Bea                    09/01/2025     Initial version
***********************************************************************************************************************/

global with sharing class AV_MW_Cobrowsing_Integration_WithoutPIN implements Callable{

    private class ResponseWrapper {
        @AuraEnabled
        public String customerInternalId;
        @AuraEnabled
        public String mandatoryAssistanceEmployeeId;
        @AuraEnabled
        public String conversationType;
    }

    @AuraEnabled
    public static string cobrowsingIntegrationCallout(Id recordId){
        string sError = '';
        string sResp = '';
        try {           
            Account acc = [SELECT Id, AV_NumPerso__c, AV_Idioma__c FROM Account WHERE Id = :recordId LIMIT 1];
            User usGest = [SELECT Id, AV_ExternalID__c FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];

            if (acc.AV_NumPerso__c != null && usGest.AV_ExternalID__c != null) {
                Map<String,string> mHeaders =  new  Map<String,string>();
                CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('AV_Cobrowsing');

                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                string body = '{"customerInternalId":"[NUMPERSO]","mandatoryAssistanceEmployeeId":"[EXTERNALID]","conversationType":"[COBROWSING]","languageCode":"[LANGUAGE]"}';
                Long longUser = long.valueOf(acc.AV_NumPerso__c);
                String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);

                String language = (acc.AV_Idioma__c != null) ? acc.AV_Idioma__c : '002';

                body = body.replace('[NUMPERSO]', hexDigest).replace('[EXTERNALID]', usGest.AV_ExternalID__c).replace('[COBROWSING]', 'COBROWSING').replace('[LANGUAGE]', language);

                CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                        reqWrapper.body = body;
                        reqWrapper.intSetting = 'AV_Cobrowsing'; 
                        reqWrapper.method = 'POST';
                        reqWrapper.mHeaders =  mHeaders;
                        reqWrapper.mUriParams = new  Map<String,string>();
                        reqWrapper.mQueryParams = new  Map<String,string>();
                HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, recordId, 'AV_Cobrowsing'); 
                
                if (res.getStatusCode() == 204) {
                    sResp = 'recordId: ' + recordId + '. Response OK: ' + res.getStatusCode() + ' ' + res.getBody();

                } else {
                    sResp = 'recordId: ' + recordId + '. Response OK: ' + res.getStatusCode() + ' ' + res.getBody();
                    sError = 'recordId: ' + recordId + '. Response Error: ' + res.getStatusCode() + ' ' + res.getBody();
                    CBK_Log.error(sError);
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
    }

    global Object call(String action, Map<String, Object> args) {

        switch on action {
            when 'cobrowsingIntegrationCallout' {
                return cobrowsingIntegrationCallout((Id)args.get('recordId'));
            }
            when else {
                throw new CalloutException('Method not implemented');
            }
        }
    }
}