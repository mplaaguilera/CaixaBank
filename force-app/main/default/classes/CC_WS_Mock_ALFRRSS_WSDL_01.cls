@isTest
global class CC_WS_Mock_ALFRRSS_WSDL_01 implements WebServiceMock {
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

            List<CC_WS_ALF_RRSS.listaItem> oListItem = new List<CC_WS_ALF_RRSS.listaItem>();
            CC_WS_ALF_RRSS.listaItem oItem = new CC_WS_ALF_RRSS.listaItem();
            oItem.estat = 0;
            oItem.identif = '@twitter';
            oItem.nalias = 'x';
            oItem.numPerso = Decimal.valueOf('9999999999');
            oItem.perCont = 'x';
            oItem.priorida = 0;
            oItem.tipoId = 0;
            oItem.tipoId = 0;
            oListItem.add(oItem);

            CC_WS_ALF_RRSS.toredsocialsalidasi oResp = new CC_WS_ALF_RRSS.toredsocialsalidasi();
            oResp.continuacion = null;
            oResp.empresaEnt = 0;
            oResp.errors = null;
            oResp.idEntra = '@twitter';
            oResp.indCont = 'x';
            oResp.lista = oListItem;
            oResp.numPerEnt = Decimal.valueOf('9999999999');
                   
            CC_WS_ALF_RRSS.GestionRedSocialResponse response_x = new CC_WS_ALF_RRSS.GestionRedSocialResponse();
            response_x.return_x = oResp;
            response.put('response_x', response_x);
                   
			
       }
    }