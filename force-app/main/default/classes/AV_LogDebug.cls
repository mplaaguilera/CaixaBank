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
public with sharing class AV_LogDebug {

    private static final String BRACKET_LEFT        = '(';
    private static final String BRACKET_RIGHT       = ') ';
    private static final String BRACKET_RIGHT_ERROR = ') Error: ';

    /**
     * Print the data in INFO mode when the flag is activated (LogInfo) in ByPass object
     *
     * @param methodName    String param with the name of the method
     * @param msg           String param with the message to include in the log
     */
    public static void printLogInfo(String methodName, String msg){
        if (AV_Bypass__c.getOrgDefaults().LogInfo__c) {
            print(LoggingLevel.INFO, methodName, msg, false);
        }
    }

    /**
     * Print the data in DEBUG mode when the flag is activated (LogDebug) in ByPass object
     *
     * @param methodName    String param with the name of the method
     * @param msg           String param with the message to include in the log
     */
    public static void printLogDebug(String methodName, String msg){
        if (AV_Bypass__c.getOrgDefaults().LogDebug__c) {
            print(LoggingLevel.DEBUG, methodName, msg, false);
        }
    }

    /**
     * Print the data in WARN mode when the flag is activated (LogWarn) in ByPass object
     *
     * @param methodName    String param with the name of the method
     * @param msg           String param with the message to include in the log
     */
    public static void printLogWarn(String methodName, String msg){
        if (AV_Bypass__c.getOrgDefaults().LogWarn__c) {
            print(LoggingLevel.WARN, methodName, msg, false);
        }
    }

    /**
     * Print the data in ERROR mode when the flag is activated (LogError) in ByPass object
     *
     * @param methodName    String param with the name of the method
     * @param msg           String param with the message to include in the log
     */
    public static void printLogError(String methodName, String msg){
        if (AV_Bypass__c.getOrgDefaults().LogError__c) {
            print(LoggingLevel.ERROR, methodName, msg, true);
        }
    }

    /**
     * Print the exception problem detected in any flow
     *
     * @param methodName    String param with the name of the method that cause error
     * @param ex            Exception problem
     */
    public static void printException(String methodName, Exception ex) {
        print(LoggingLevel.ERROR, methodName, ex.getMessage(), true);
        System.debug(LoggingLevel.ERROR, ex.getCause());
        System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
    }

    private static void print(LoggingLevel level, String methodName, String msg, boolean isError){
        if (msg!=null && msg.length()<6000000) {
            String msgError = BRACKET_LEFT + methodName + (isError ? BRACKET_RIGHT_ERROR : BRACKET_RIGHT) + msg;
            System.debug(level, msgError);
        }
    }

}