/**********************************************************************************************************************
Name:	  AV_MultiRequestMock_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de integraciones
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Jashanpreet Singh   	30/04/2021		Init version
    1.1         US268687        Maria Martinez      27/09/2021      Add Customer Service Request
***********************************************************************************************************************/
@isTest
public class AV_MultiRequestMock_Test  implements HttpCalloutMock {
        Map<String, HttpCalloutMock> requests;
     
        public AV_MultiRequestMock_Test(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }
     
        public HTTPResponse respond(HTTPRequest req) {

            HttpCalloutMock mock = requests.get(req.getHeader('SOAPAction'));
            
            if (mock != null) {
                return mock.respond(req);
            }else{
               if(req.getEndpoint().contains('/oauth2/v2.0/token')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }else if(req.getEndpoint().contains('/v1.0/users/U01')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }else if(req.getEndpoint().contains('/onlineMeetings')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }else if(req.getEndpoint().contains('/activities/eventsPremium')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }else if(req.getEndpoint().contains('/marketingAndDevelopment/customerSurveys/triggers')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }else if(req.getEndpoint().contains('/marketingAndDevelopment/customerSurveys/surveys')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }else if(req.getEndpoint().contains('partyReferenceDataDirectory/basic/tickets')){
                    mock = requests.get(req.getEndpoint());
                    return mock.respond(req);
                }
            }
            return null;
        }
     
        public void addRequestMock(String url, HttpCalloutMock mock) {
            requests.put(url, mock);
        }
    }