/**********************************************************************************************************************
 Name:	  AV_C2C_MockCallout_Test
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test de integración con C2C
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY	   AUTHOR		   		DATE			Description
   1.0			Test Class	   David Rufo	   	    21/07/2020		Init version
   1.1		    FIX11070844	    Oscar Moreno		   22/07/2024			Fix error The Global modifier should be avoided.


***********************************************************************************************************************/
@isTest
public class AV_C2C_MockCallout_Test implements HttpCalloutMock {

    /**
     * Option 1: normal execution
     * Option 2: exception in execution
     * Option 3: return error message in body response
     */
    private String option;

    /**
     * MockCalloutESB   Mock for testing class ESB Abstract integration
     * @param  option   Option 1.1: normal execution
     *                  Option 1.2: error 1
     *                  Option 1.3: error 2
     *                  Option 1.4: error 3
     *                  Option 1.5: error 4
     *                  Option 1.6: error 5
     *                  Option 2: exception in execution
     *                  Option 3: return error message in body response
     */
    public AV_C2C_MockCallout_Test(String option) {
        this.option = option;
    }

    public static final String CONTAINS_API_GWT     = 'callout:API_GWT';

    public static final String C2C_OK        = '{"Result":"0", "StatusCode":"0"}';
    public static final String C2C_ERR1      = '{"Result":"1", "StatusCode":"4"}';
    public static final String C2C_ERR2      = '{"Result":"2", "StatusCode":"9"}';
    public static final String C2C_ERR3      = '{"Result":"4", "StatusCode":"13"}';
    public static final String C2C_ERRX      = '{"Result":"X", "StatusCode":"X"}';
    public static final String C2C_ERR_MSG   = '{"error":"X", "error-code":"X"}';

    /**
     * @description     prepare data for test
     * @param req       request
     * @return          response OK
     **/
    public HTTPResponse respond(HTTPRequest req) {
        System.debug(LoggingLevel.DEBUG, 'AV_C2C_MockCallout_Test - Option: ' + this.option);
        System.debug(LoggingLevel.DEBUG, 'AV_C2C_MockCallout_Test: ' + req.getEndPoint());
        HttpResponse res = new HttpResponse();
        res.setHeader(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON);

        //Throw exception
        if ('2'.equalsIgnoreCase(this.option)) {
            CalloutException e = new CalloutException();
            e.setMessage('This is a constructed exception!');
            throw e;
        }
        //Error in body
        else if ('3'.equalsIgnoreCase(this.option)) {
            res.setStatusCode(Integer.valueOf(AV_IntegrationConstants.HTTP_STATUS_NOT_FOUND));
            res.setBody(C2C_ERR_MSG);
        }
        //OK
        else if ('1.1'.equalsIgnoreCase(this.option)) {
            setResponse(req, res, C2C_OK, C2C_ERRX);
        }
        //ERR2
        else if ('1.2'.equalsIgnoreCase(this.option)) {
            setResponse(req, res, C2C_ERR1, C2C_ERRX);
        }
        //ERR3
        else if ('1.3'.equalsIgnoreCase(this.option)) {
            setResponse(req, res, C2C_ERR2, C2C_ERRX);
        }
        //ERR4
        else if ('1.4'.equalsIgnoreCase(this.option)) {
            setResponse(req, res, C2C_ERR3, C2C_ERRX);
        }
        //ERR5
        else if ('1.5'.equalsIgnoreCase(this.option)) {
            setResponse(req, res, C2C_ERRX, C2C_ERRX);
        }
        //ERR6
        else if ('1.6'.equalsIgnoreCase(this.option)) {
            setResponse(req, res, C2C_ERR_MSG, C2C_ERRX);
        }
        else{
            res.setStatusCode(Integer.valueOf(AV_IntegrationConstants.HTTP_STATUS_NOT_FOUND));
            res.setBody(C2C_ERR_MSG);
        }

        return res;
    }

    private void setResponse(HTTPRequest req, HttpResponse res, String msgOK, String msgKO){
        //Check request
        if (req.getEndPoint().startsWith(CONTAINS_API_GWT)
                && req.getMethod().equalsIgnoreCase(AV_IntegrationConstants.HTTP_VERB_POST)){
            // Create a fake response
            res.setStatusCode(Integer.valueOf(AV_IntegrationConstants.HTTP_STATUS_OK));
            res.setBody(msgOK);
        }
        //Other case return error
        else{
            res.setStatusCode(Integer.valueOf(AV_IntegrationConstants.HTTP_STATUS_NOT_FOUND));
            res.setBody(msgKO);
        }
    }

}