@isTest
global class CC_WS_Maximo_Mock_02 implements WebServiceMock {
       global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
                   
			CC_WS_Maximo.UpdateITNINCSIEBEL8V4ResponseType response_x = new CC_WS_Maximo.UpdateITNINCSIEBEL8V4ResponseType();

            response.put('response_x', response_x);
       }
    }