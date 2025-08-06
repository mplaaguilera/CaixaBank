/**********************************************************************************************************************
Name:     AV_DetailExpCliente_Controller_Test
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test for AV_DetailExpCliente_Controller class
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE            Description
1.0         US284842            Víctor Santiago     22/06/2022      Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_DetailExpCliente_Controller_Test {

    @isTest
    public static void retrieveDataTest() {
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('SURVEY_FC', 'OK'));
        String numPerso = '13550';
        Test.startTest();
        String result = AV_DetailExpCliente_Controller.retrieveData(numPerso);
        Test.stopTest();
        List<AV_DetailExpCliente_Controller.SurveyBundle> data =
            (List<AV_DetailExpCliente_Controller.SurveyBundle>)JSON.deserialize(result, List<AV_DetailExpCliente_Controller.SurveyBundle>.class);
        System.assertEquals(true, String.isNotBlank(data.get(0).momento), 'Could not get data');
    }

}