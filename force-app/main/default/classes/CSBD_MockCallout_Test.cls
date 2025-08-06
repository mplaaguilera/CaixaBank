/**********************************************************************************************************************
Name:     CSBD_MockCallout_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de integraciones
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY     AUTHOR               DATE            Description
    1.0         Test Class     Esperanza Conde      24/02/2022      Init version
    1.1         Api Premium    Alexandre Pérez      08/05/2025      Respuestas para api premium para CSBD
    1.2         US1283689      Alexandre Pérez      13/06/2025      Respuestas para api de integración gdpr y productos de CSBD

***********************************************************************************************************************/
@isTest
public class CSBD_MockCallout_Test implements HttpCalloutMock {
    
    /**
     * Option 1: normal execution
     * Option 2: exception in execution
     * Option 3: return error message in body response
    */
    private String option;
    private String status;
    
    /**
      * MockCalloutESB   Mock for testing class ESB Abstract integration
      * @param  option   Option 1: normal execution
      *               Option 2: exception in execution
    */
    public CSBD_MockCallout_Test(String option, String status) {
        this.option = option;
        this.status = status;
    }

    public static final String RESPONSE_CP_INTCNT   = '{"statusCode": "201","eventPremiumId": "8911100000000001"}';
    public static final String RESPONSE_COGNITIVO   = '{"sr": "2-912076545","model_name": "model-001","category": "UAFE Confirming","categories": [{"category": "UAFE Confirming", "ratio": "0.52114"},{"category": "UAFE Factoring", "ratio": "0.22389"},{"category": "UAFE Grandes Clientes", "ratio": "0.20729"},{"category": "UAFE Sucursales Internacionales", "ratio": "0.02778"},{"category": "UAFE Export Finance", "ratio": "0.01109"},{"category": "UAFE Cartera de Efectos", "ratio": "0.00698"},{"category": "UAFE Clasificador", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';
    public static final String RESPONSE_ERROR       = '{"mensaje": "Error","tipo": "XXXXX"}';
    public static final String RESPONSE_EXTENDED = '{"customerInternalId":13550,"customerName":"RAQUEL","customerLastName":"ALONSO  CASAS","customerDocId":{"key":"NIF","value":"28656271L"},"birthDate":"1959-05-15","language":"1","mobilePhoneNumber":695782046,"mobilePhonePrefix":"+34","email":"pruebas@caixabank.com","employeeId":"U0129197","employeeName":"ROBERTO PEDRO GUARC PALLARES                        ","principalBranch":3022,"RelatedBranch":[555,894,5210],"LoyaltyPrograms":[{"program":{"key":"AGRCT","value":"AgroBank"},"isCompilance":false},{"program":{"key":"CBXN","value":"CaixaBank"},"isCompilance":true},{"program":{"key":"PSU","value":"Día a Día"},"isCompilance":true,"compilanceValue":"100%"}],"Balance":[{"type":{"key":"P","value":"LIABILITIES"},"amount":201690.97},{"type":{"key":"A","value":"ASSETS"},"amount":2049.53},{"type":{"key":"R","value":"PROFITABILITY"},"amount":303.77},{"type":{"key":"N","value":"PENSION INCOME"},"amount":5252.66},{"type":{"key":"P","value":"PENSION INCOME"},"amount":5252.66},{"type":{"key":"F","value":"PROFESSIONAL INCOME"},"amount":1111},{"type":{"key":"L","value":"PERSONAL INCOME"},"amount":2703.16}],"clientExperience":0,"hasWall":true,"LoyaltyLink":[{"isCompilance":true,"indicators":10,"financialIndicator":8}],"segment":{"key":"BPR","value":"Banca Privada"},"isConfidential":false,"confidentialBranch":0,"customerType":{"key":"F","value":"Físico"},"isEmployee":false,"LoyaltySignals":[{"key":"16","value":"Limitación en ventas seguros"}],"scoring":{"status":{"key":"A","value":"A"},"value":1.5},"rating":{"status":{"key":"A","value":"A"},"value":2.5},"contactPerson":"","attentionModel":{"key":"A","value":"Alto Potencial"},"subAttentionModel":"A    ","contactNumber":3,"realContactNumber":3,"attentionModelType":"   ","attentionModelCompilance":70,"isCompilanceAttentionModel":false,"isMustCompilanceAttentionModel":false,"globalCompilancePercentage":0,"cnaeCode":"0","cnaeDescription":"","postCode":"08024","country":"11","contactTime":{"initialTime":"11:00 ","finalTime":" 12:00, 15:00 "},"isClient":true,"isPreconceived":false,"interlocId":13550,"RelatedEntities":[{"key":"BNKMIX","value":"Bankia mixto"}],"customerBusiness":[{"key":"BPE","value":"Banca Premier"}],"riskMatrix":0,"preconceived":0,"isAdvised":false,"prevalence":" ","LEXDate":"2020-10-10","Extended":{}}';
    public static final String RESPONSE_EXTENDED_EMPTY_BALANCE = '{"customerInternalId":13550,"customerName":"RAQUEL","customerLastName":"ALONSO  CASAS","customerDocId":{"key":"NIF","value":"28656271L"},"birthDate":"1959-05-15","language":"1","mobilePhoneNumber":695782046,"mobilePhonePrefix":"+34","email":"pruebas@caixabank.com","employeeId":"U0129197","employeeName":"ROBERTO PEDRO GUARC PALLARES                        ","principalBranch":3022,"RelatedBranch":[555,894,5210],"segment":{"key":"BPR","value":"Banca Privada"},"isConfidential":false,"confidentialBranch":0,"customerType":{"key":"F","value":"Físico"},"isEmployee":false,"scoring":{"status":{"key":"A","value":"A"},"value":1.5},"contactPerson":"","attentionModel":{"key":"A","value":"Alto Potencial"},"subAttentionModel":"A    ","contactNumber":3,"realContactNumber":3,"attentionModelType":"   ","attentionModelCompilance":70,"isCompilanceAttentionModel":false,"isMustCompilanceAttentionModel":false,"globalCompilancePercentage":0,"cnaeCode":"0","cnaeDescription":"","postCode":"08024","country":"11","contactTime":{"initialTime":"11:00 ","finalTime":" 12:00, 15:00 "},"isClient":true,"isPreconceived":false,"interlocId":0,"RelatedEntities":[{"key":"BNKMIX","value":"Bankia mixto"}],"riskMatrix":0,"preconceived":0,"isAdvised":false,"prevalence":" ","LEXDate":"0.0","Extended":{}}'; 
    public static final string RESPONSE_PRODUCTOS = '{"customerBusiness":[{"business":{"key":"BPA","value":"Banca particulares"},"experiences":[{"experience":{"key":"BPA001","value":"Dia a dia"},"globalExperience":1,"order":1,"isMyBox":false,"products":[{"productCode":{"key":"50046","value":"Tarjeta crédito"},"state":{"key":"2","value":"tiene"},"order":1,"isProfessional":false,"preconceived":50,"isTarget":false,"isPotential":false}]}]}]}';
    public static final string RESPONSE_GDPR = '{"treatmentId":"0040-A","isResult":false,"userId":279,"consentList":[{"consentId":1,"isConsent":false},{"consentId":6,"isConsent":false},{"consentId":4,"isConsent":true}]}';
    
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(status == 'KO'){
            response.setBody(RESPONSE_ERROR);
            response.setStatusCode(500); 
        } else if(option == 'COGNITIVO' && status == 'OK'){
            response.setBody(RESPONSE_COGNITIVO);
            response.setStatusCode(200); 
        } else if(option == 'EXTENDED' && status == 'OK') {
            response.setBody(RESPONSE_EXTENDED);
            response.setStatusCode(200);
        } else if(option == 'EXTENDED_EMPTY_BALANCE' && status == 'OK') {
            response.setBody(RESPONSE_EXTENDED_EMPTY_BALANCE);
            response.setStatusCode(200);
        } else if(option == 'PRODUCTOS' && status == 'OK') {
            response.setBody(RESPONSE_PRODUCTOS);
            response.setStatusCode(200);
        } else if(option == 'GDPR' && status == 'OK') {
            response.setBody(RESPONSE_GDPR);
            response.setStatusCode(200);
        } else if(option == 'GDPR' && status == 'KOC') {
            response.setBody('{"detail": "Error"}');
            response.setStatusCode(500);
        } else if(option == 'CP_INTCNT' && status == 'OK') {
            response.setBody(RESPONSE_CP_INTCNT);
            response.setStatusCode(201);
        }
        
        return response; 
    }
}