/**********************************************************************************************************************
 Name:      AV_LogDebug
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Métodos útiles para controlar la severidad y entorno de los logger
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          David Rufo       11/02/2020          Init version

***********************************************************************************************************************/
@IsTest
private class AV_LogDebug_Test {

    public static final String TXT_TEST = 'test';

    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
    }

    @IsTest
    static void testPrintLogInfo() {
        Test.startTest();
        AV_LogDebug.printLogInfo('testPrintLogInfo', TXT_TEST);
        Test.stopTest();
    }

    @IsTest
    static void testPrintLogDebug() {
        Test.startTest();
        AV_LogDebug.printLogDebug('testPrintLogDebug', TXT_TEST);
        Test.stopTest();
    }

    @IsTest
    static void testPrintLogWarn() {
        Test.startTest();
        AV_LogDebug.printLogWarn('testPrintLogWarn', TXT_TEST);
        Test.stopTest();
    }

    @IsTest
    static void testPrintLogError() {
        Test.startTest();
        AV_LogDebug.printLogError('testPrintLogError', TXT_TEST);
        Test.stopTest();
    }

    @IsTest
    static void testPrintException() {
        Test.startTest();
        AV_LogDebug.printException('testPrintException', new AV_ApplicationException(TXT_TEST));
        Test.stopTest();
    }

}