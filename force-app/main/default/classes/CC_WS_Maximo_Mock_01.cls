@isTest
global class CC_WS_Maximo_Mock_01 implements WebServiceMock {
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
                       
			CC_WS_Maximo.INCIDENTKeyType oDatos = new CC_WS_Maximo.INCIDENTKeyType();
			oDatos.CLASS_x = 'INCIDENT';
			oDatos.TICKETID = 'IN0001';
                   
			List<CC_WS_Maximo.INCIDENTKeyType> oListDatos = new List<CC_WS_Maximo.INCIDENTKeyType>();
			oListDatos.add(oDatos);
                   
			CC_WS_Maximo.INCIDENTMboKeySetType oDatos2 = new CC_WS_Maximo.INCIDENTMboKeySetType();
			oDatos2.INCIDENT = oListDatos;
                   
			CC_WS_Maximo.CreateITNINCSIEBEL8V4ResponseType response_x = new CC_WS_Maximo.CreateITNINCSIEBEL8V4ResponseType();
			response_x.INCIDENTMboKeySet = oDatos2;

            response.put('response_x', response_x);
       }
    }