/**********************************************************************************************************************
 Name:	  EV_ConnectApi_Mock
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description Clase para Mock de ConnectApi
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US785364        Daniel Rodriguez    21/12/2023 			Init version
***********************************************************************************************************************/

@isTest
public class EV_ConnectApi_Mock implements HttpCalloutMock{
    public Integer code;
	/**
 	* @description code of response
 	*/
    public EV_ConnectApi_Mock(Integer code) {
        this.code = code;
    }
    /**
 	* @description response Mock
 	*/
    public HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '{authenticationProtocol=Custom, credentials={EXPIRES={encrypted=false, value=2023-12-20 13:42:09}, SECURITY={encrypted=false, value=@rh3iw5vhLTkieS15V22ThlxMCPvai2gk8_vYRScLqi-kuWnneqzFroW8su7q3QY478jVH6OJjYqaJlIcDFhVmlkT2T9z0Hp-ujPYmf7YyQ0=}, SESSION={encrypted=false, value=___6e43634a-c12c-4347-9214-8f4aa11e34fb}}, externalCredential=EV_AdobeCampaignCredentialPRE, principalName=SFTokens, principalType=NamedPrincipal}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}