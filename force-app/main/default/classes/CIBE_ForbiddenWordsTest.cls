/**********************************************************************************************************************
Name:	  CIBE_ForbiddenWords_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_ForbiddenWords"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Luis Martínez   	   11/06/2024		Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_ForbiddenWordsTest {
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA,
            CIBE_AppConstants.CIBE_ANALYTICS,
            CIBE_AppConstants.CIBE_OPERATIVAEMP, 
            CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        RecordType rtCliente = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_CIB_RT);

        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usrTest){
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            Database.insert(word, false);
        }
    }
    
    @isTest
    private static void forbiddenWordsTest() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usrTest){
            Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = CIBE_ForbiddenWords.fetchForbiddenWords();
            String word = mapForbiddenWords.get( new List<String>(mapForbiddenWords.keySet())[0] ).CBK_EXPRES__c;
            String transformedString = CIBE_ForbiddenWords.transformWords('Forbidden words test: ' + word);
            List<CBK_ForbiddenWord__c> listFW =  CIBE_ForbiddenWords.validateExpr(transformedString, mapForbiddenWords);
            System.assertEquals(word, listFW[0].CBK_EXPRES__c);
        }
        Test.stopTest();
    }
    
    @isTest
    private static void validateRecordsTest() {
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        List<String> setFields = new List<String>{'Name','AV_Comentarios__c'};
        List<String> setFieldsTask = new List<String>{'Subject','Description'};
        Date today = System.Today();
        String todayString = String.valueOf(today);
        RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
        Map<String,Map<String,Object>> taskWrappedList = new Map<String,Map<String,Object>>();
        taskWrappedList.put((true)?'isEditable': 's', new Map<String,Object>{
                                            'id' => 'idProvisional',
                                            'rt' => rtTask.Id,
                                            'subject' => 'Subject test',
                                            'tareaDate' => todayString,
                                            'status' => 'Open',
                                            'Description' => 'Prueba de comentario ABELLOTS and CAUCASIC'
                                        });

        Map<String,Map<String,Object>> oppoWrappedList = new Map<String,Map<String,Object>>();
        oppoWrappedList.put((true)?'idProvisional0': 's', new Map<String,Object>{
                                        'Name' => 'Oportunidad Test',
                                        'oppoDate' => todayString,
                                        'fechaCierre' => todayString,
                                        'probabilidad' => 'Media',
                                        'AV_Comentarios__c' => 'test',
                                        'comentario' => 'test'
                                    });
        
        Test.startTest();
        System.runAs(usrTest){
            String result = CIBE_ForbiddenWords.validateRecords(oppoWrappedList, taskWrappedList, setFields, setFieldsTask);
            System.assertEquals(result, 'OK');
        }
        Test.stopTest();
    }
}