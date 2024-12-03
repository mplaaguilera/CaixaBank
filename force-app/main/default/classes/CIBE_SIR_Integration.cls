/**********************************************************************************************************************
Name: CIBE_SIR_Integration
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración SIR(sistema de información de riesgos)
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY              AUTHOR                 DATE			Description
    1.0     US473463                Alexandre Pérez        7/6/2023       Initial version
***********************************************************************************************************************/
public with sharing class CIBE_SIR_Integration {
    
    private class ResponseWrapper {
        @AuraEnabled
        public boolean isClientIndicator;
        @AuraEnabled
        public segData segmentationData;
        @AuraEnabled
        public riskData riskData;
        @AuraEnabled
        public Map<String, Object> mapAccountFields;       
    }

    private class SegData {
        @AuraEnabled
        public integer parentSegment;
        @AuraEnabled
        public integer childSegment;
        @AuraEnabled
        public string segmentType;
        @AuraEnabled
        public integer assigmentDate;
    }

    private class RiskData {
        @AuraEnabled
        public string statusType;
        @AuraEnabled
        public decimal risk;
        @AuraEnabled
        public decimal defaultProbability;
        @AuraEnabled
        public string riskLevel;
        @AuraEnabled
        public decimal automaticLoss;
        @AuraEnabled
        public decimal referenceLoss;
        @AuraEnabled
        public decimal theoricalMargin;
        @AuraEnabled
        public decimal actualMargin;
        @AuraEnabled
        public integer volatilitySector;
        @AuraEnabled
        public decimal manualLoss;
        @AuraEnabled
        public boolean isDefaultLoss;
        @AuraEnabled
        public string sirReturnCode;
        @AuraEnabled
        public string sirReturnCode2;
        @AuraEnabled
        public integer riskDescriptor;
        @AuraEnabled
        public integer managementLevel;
        @AuraEnabled
        public integer regulationLevel;
        @AuraEnabled
        public integer economyLevel;
        @AuraEnabled
        public boolean isOperatingSegmentIndicatorRC;
        @AuraEnabled
        public decimal score;
        @AuraEnabled
        public string ratingFinal;
        @AuraEnabled
        public date expiryDate;
        @AuraEnabled
        public date calculationDate;
    }
    
    @AuraEnabled
    public static string sirIntegrationCallout(Id accountId){
        string sError = '';
        string sResp = '';
        try {  
           //Map<String, Object> mapAccountFields = new Map<String, Object>();
           
            Account acc = [SELECT Id, AV_OficinaPrincipal__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AV_NumPerso__c, recordType.developerName, CIBE_FechaRefrescoSIR__c 
            FROM Account where Id = :accountId LIMIT 1];
            if(acc.AV_NumPerso__c != null && 
            (acc.CIBE_FechaRefrescoSIR__c == null || CIBE_APPUtilities.calculateTimeDifferences(acc.CIBE_FechaRefrescoSIR__c, dateTime.now()) > 24)) {
                string tipoPersona = acc.recordType.developerName == 'CC_Cliente' ? 'Legal' : 'Physical';
                string oficinaPrincipal = acc.AV_OficinaPrincipal__c == null ? '0' : acc.AV_OficinaPrincipal__r.CC_Numero_Oficina__c;
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Map<String,string> mHeaders =  new  Map<String,string>();
                CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('getSir');
                //si detecta que usamos la name credential del camaleon le metemos su cabecera
                if(wsc?.NamedCredential__c.contains('CAMALEON')){
                    mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                }
                string body = '{"branchId":"[NUMOFICINA]","companyId":"[NUMPERSO]","isDefaultSegmentIndicator":true,"personType":"[TIPOPERSONA]"}';
                //mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
				mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                Long longUser = long.valueOf(acc.AV_NumPerso__c);
                String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
				mHeaders.put('x-absis-customerInternalId',hexDigest);
                //string body = '{"branchId":"[NUMOFICINA]","companyId":"[NUMPERSO]","isDefaultSegmentIndicator":true,"personType":"[TIPOPERSONA]"}';
                body = body.replace('[NUMOFICINA]', oficinaPrincipal).replace('[NUMPERSO]', acc.AV_NumPerso__c).replace('[TIPOPERSONA]', tipoPersona);
                system.debug(body);
                req = CBK_HttpServiceIntegration.getRequest(body, 'getSir', 'POST', mHeaders);
                res = CBK_HttpServiceIntegration.callHttpService(req, accountId, 'getSir');
                system.debug(res);
                system.debug(res.getBody());
                //API_GWT_CIBE_CAMALEON
                system.debug('@@Status'+res.getStatusCode());
                //el tratamiento de errores por código de estado no funciona en el fwk
                if(res.getStatusCode() == 200) {
                    responseWrapper resp = (responseWrapper)JSON.deserialize(res.getBody(),responseWrapper.class);
                    system.debug('@@Wrapper'+resp);
                    Map<String, Object> mapAccountFields = new Map<String, Object>();
                    mapAccountFields.put('Id', accountId);
                    mapAccountFields.put('CIBE_LGD__c', resp.riskData.manualLoss);
                    mapAccountFields.put('CIBE_Rating__c', resp.riskData.risk);
                    mapAccountFields.put('CIBE_FechaPD__c', resp.riskData.calculationDate);
                    mapAccountFields.put('CIBE_PD__c', resp.riskData.defaultProbability);
                    /*
                    if(res.getBody().length() <= 131072){
                        mapAccountFields.put('schema.Account.CIBE_FechaRefrescoSIR__c',dateTime.now());
                        mapAccountFields.put('schema.Account.CIBE_JsonSIR__c',res.getBody());
                    }*/
                    resp.mapAccountFields = mapAccountFields;
                    
                    //updatear el registro account con los datos obtenidos
                    sResp = updateAccount(mapAccountFields);
                    
                } else {
                    sError = 'AccountId: ' + accountId + '. Response Error: ' + res.getStatusCode() + ' ' + res.getBody();
                    //quitar el cbk log cuando el tratamiento de errores por status code funcione correctamente a nivel de fwk
                    cbk_log.error(sError);
                }
                
            } else {
                sResp = 'Han pasado menos de 24H desde el último refresco ' + acc.CIBE_FechaRefrescoSIR__c.format('d/M/y H:m');
            }
            return sResp;
        } catch (Exception e) {
            cbk_log.error(e, 'AccountId: ' + accountId);
            sError = 'Error al integrar con SIR, revisar logs para más información.';
            return sError;
        } finally {
            if(sError != ''){
                system.debug('sError ' + sError);
                throw new AuraHandledException(sError);
            }
            //return sResp;
        }
    }

    private static String updateAccount(map<string, object> mapAccountFields) {

        Account account = new Account();
        // Modify the fields of the Account record using the map of field names and values
        for (String fieldName : mapAccountFields.keySet()) { 
            if(mapAccountFields.get(fieldName) != null){
                System.debug('fieldName: ' + fieldName);
                account.put(fieldName, mapAccountFields.get(fieldName));
            }
        
        }
    
        // Save the changes to the Account record in the database
        Database.saveResult srList = Database.update(account, false);
        if (srList.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully updated account. Account ID: ' + srList.getId());
            return null;
        }
        else {
            String errors = '';
            // Operation failed, so get all errors                
            for(Database.Error err : srList.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
                errors = errors + err.getStatusCode() + ': ' + err.getMessage() + ' Account fields that affected this error: ' + err.getFields();
            }
            return errors;
        }
	}


}