/**********************************************************************************************************************
Name:	  CSBD_WS_ConsultaOTP
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: WS para API SALESFORCE sobre la consulta de código OTP.
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	            AUTHOR		   		DATE				Description
1.0			App CSBD        	    Esperanza Conde   	28/01/2022		    Init version
***********************************************************************************************************************/
@RestResource(urlMapping='/ConsultaOTP')
global with sharing class CSBD_WS_ConsultaOTP {

    @HttpPost
    global static void getKeyOTP() {
               
        RestRequest request = RestContext.request;
        CSBD_OTPChat.getOPT();

    }  

}