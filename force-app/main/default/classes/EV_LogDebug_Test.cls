/**********************************************************************************************************************
 Name:      EV_LogDebug_Test
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Métodos útiles para controlar la severidad y entorno de los logger
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App Eventos          Daniel Rodriguez 20/12/2022          Init version

***********************************************************************************************************************/
@IsTest
private class EV_LogDebug_Test {

    public static final String TXT_TEST = 'test';

    @TestSetup
    static void setup(){
        EV_TestHelper.activateLoggerEV();
    }

    @IsTest
    static void testPrintLogInfo() {
        Test.startTest();
        EV_LogDebug.printLogInfo('testPrintLogInfo', TXT_TEST);
        Test.stopTest();
        System.assertEquals(TXT_TEST, 'test', 'Test');
    }

    @IsTest
    static void testPrintLogDebug() {
        Test.startTest();
        EV_LogDebug.printLogDebug('testPrintLogDebug', TXT_TEST);
        Test.stopTest();
        System.assertEquals(TXT_TEST, 'test', 'Test');
    }

    @IsTest
    static void testPrintLogWarn() {
        Test.startTest();
        EV_LogDebug.printLogWarn('testPrintLogWarn', TXT_TEST);
        Test.stopTest();
        System.assertEquals(TXT_TEST, 'test', 'Test');
    }

    @IsTest
    static void testPrintLogError() {
        Test.startTest();
        EV_LogDebug.printLogError('testPrintLogError', TXT_TEST);
        Test.stopTest();
        System.assertEquals(TXT_TEST, 'test', 'Test');
    }

    @IsTest
    static void testPrintException() {
        Test.startTest();
        EV_LogDebug.printException('testPrintException', new AV_ApplicationException(TXT_TEST));
        Test.stopTest();
        System.assertEquals(TXT_TEST, 'test', 'Test');
    }

}