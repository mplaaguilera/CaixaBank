/**********************************************************************************************************************
 Name:      AV_LogDebug_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Métodos útiles para controlar la severidad y entorno de los logger
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          David Rufo       11/02/2020          Init version
   1.1 		        US649249	       Gonzalo Ávila	  27/11/2023		      Include system.asserts in all methods


***********************************************************************************************************************/
@IsTest
private class AV_LogDebug_Test {

    public static final String TXT_TEST = 'test';

    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
    }

    @IsTest
    static void testPrintLogInfo() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Boolean check = true;
        System.runAs(userGcf){
        Test.startTest();
        try {
            AV_LogDebug.PrintLogInfo('testPrintLogInfo', TXT_TEST);
            check = true;
          }
          catch(Exception e) {
            e.getMessage();
            check = false;
          }
          System.assert(check, 'PrintLogInfo ERROR');
        Test.stopTest();
        }
        
        
        
    }

    @IsTest
    static void testPrintLogDebug() {
      User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Boolean check = true;
        System.runAs(userGcf){
        Test.startTest();
        try {
            AV_LogDebug.printLogDebug('testPrintLogDebug', TXT_TEST);
            check = true;
          }
          catch(Exception e) {
            e.getMessage();
            check = false;
          }
          System.assert(check, 'PrintLogDebug ERROR');
        Test.stopTest();
        }
    }

    @IsTest
    static void testPrintLogWarn() {
      User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Boolean check = true;
        System.runAs(userGcf){
        Test.startTest();
        try {
            AV_LogDebug.printLogWarn('testPrintLogWarn', TXT_TEST);
            check = true;
          }
          catch(Exception e) {
            e.getMessage();
            check = false;
          }
          System.assert(check, 'PrintLogWarn ERROR');
        Test.stopTest();
        }
        
    }

    @IsTest
    static void testPrintLogError() {
      User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Boolean check = true;
        System.runAs(userGcf){
        Test.startTest();
        try {
            AV_LogDebug.printLogError('testPrintLogError', TXT_TEST);
            check = true;
          }
          catch(Exception e) {
            e.getMessage();
            check = false;
          }
          System.assert(check, 'PrintLogError ERROR');
        Test.stopTest();
        }
    }

    @IsTest
    static void testPrintException() {
      User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Boolean check = true;
        System.runAs(userGcf){
        Test.startTest();
        try {
            AV_LogDebug.printException('testPrintException', new AV_ApplicationException(TXT_TEST));
            check = true;
          }
          catch(Exception e) {
            e.getMessage();
            check = false;
          }
          System.assert(check, 'PrintLogException ERROR');
        Test.stopTest();
        }
    }

}