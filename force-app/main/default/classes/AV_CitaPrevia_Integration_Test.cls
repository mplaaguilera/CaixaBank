/**********************************************************************************************************************
Name:	  AV_CitaPrevia_Integration_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Integración con API para Eventos Test
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Jashanpreet	   	    20/10/2020		Init version
1.1         QC             Oscar Moreno         12/06/2024      Delete UserInfo.geetUserId()
1.2			PPM100538432   Sandra Gómez			19/09/2024		Change to CBK_IntegrationSetting__c
***********************************************************************************************************************/
@isTest
public with sharing class AV_CitaPrevia_Integration_Test {
    
    @TestSetup
    static void setup(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		insert new List<CBK_IntegrationSetting__c>{
        new CBK_IntegrationSetting__c(
            Name = 'AV_citaprevia_int',
            NamedCredential__c = 'callout:API_GWT_PRO/tech/asesorventasactivitiesapi/employees/{employeeId}/activities/eventsPremium',
            CBK_Method__c = 'POST'
        ), new CBK_IntegrationSetting__c(
            Name = 'AV_citaprevia_mo',
            NamedCredential__c = 'callout:API_GWT_PRO/tech/asesorventasactivitiesapi/activities/eventsPremium/{id}',
            CBK_Method__c = 'POST'
        )};
        AV_TestHelper.activateLogger();
        AV_TestHelper.createUser(null); 
    }

    @isTest
    public static void testInsCnt() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  

        String branchId = '13550';
        String employeeId = [Select AV_ExternalID__c From User Where Id = :usuarioGcf.Id][0].AV_ExternalID__c;
        
        AV_CitaPrevia_Integration.Event parms = new AV_CitaPrevia_Integration.Event();
        
        parms.subject = 'Esto es test';
        parms.employeeEvent = employeeId;
        parms.branchId = Integer.valueOf(branchId);
        parms.type = 'O';
        parms.meetingRequester = 'G';
        parms.status = 'R';
        parms.date_X =  DateTime.now().format('yyyy-MM-dd');
        parms.startTime =  DateTime.now().format('HH:mm');
        parms.endTime =  DateTime.now().format('HH:mm');
        parms.comment = 'Esto es isTest';

        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        AV_CitaPrevia_Integration.InsCntResponse eventResponse;
        System.runAs(usuarioGcf){
            eventResponse = AV_CitaPrevia_Integration.intCnt(parms, employeeId,branchId);		
        }
        Test.stopTest();
        System.assertEquals('201', eventResponse.statusCode);
    }
    
    @isTest
    public static void testModCnt() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        
        String branchId = '13550';
        String eventPremiumtId = '8911100000000001';
        String employeeId = [Select AV_ExternalID__c From User Where Id = :usuarioGcf.Id][0].AV_ExternalID__c;
        
        AV_CitaPrevia_Integration.Event parms = new AV_CitaPrevia_Integration.Event();
        
        parms.subject = 'Esto es test 2';
        parms.employeeEvent = employeeId;
        parms.branchId = Integer.valueOf(branchId);     
        parms.type = 'O';
        parms.meetingRequester = 'G';
        parms.status = 'R';
        parms.date_X =  DateTime.now().format('yyyy-MM-dd');
        parms.startTime =  DateTime.now().format('HH:mm');
        parms.endTime =  DateTime.now().format('HH:mm');
        parms.comment = 'Esto es isTest 2';

        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
        Test.startTest();
        AV_CitaPrevia_Integration.MoCntResponse eventResponse;	
        System.runAs(usuarioGcf){
            eventResponse = AV_CitaPrevia_Integration.moCnt(parms, employeeId,eventPremiumtId,branchId);		
        }	
        Test.stopTest();
        System.assertEquals('200', eventResponse.statusCode);
    }
    
    
     @isTest
    public static void testDelCnt() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        
        String branchId = '13550';
        String eventPremiumtId = '8911100000000001';
        String employeeId = [Select AV_ExternalID__c From User Where Id = :usuarioGcf.Id][0].AV_ExternalID__c;
        
        AV_CitaPrevia_Integration.Event parms = new AV_CitaPrevia_Integration.Event();
        
        parms.subject = 'Esto es test';
        parms.employeeEvent = employeeId;
        parms.branchId = Integer.valueOf(branchId);     
        parms.type = 'O';
        parms.meetingRequester = 'G';
        parms.status = 'R';
        parms.date_X =  DateTime.now().format('yyyy-MM-dd');
        parms.startTime =  DateTime.now().format('HH:mm');
        parms.endTime =  DateTime.now().format('HH:mm');
        parms.comment = 'Esto es isTest';

        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_DELCNT','OK'));
        Test.startTest();
        AV_CitaPrevia_Integration.DelCntResponse eventResponse;
        System.runAs(usuarioGcf){
            eventResponse = AV_CitaPrevia_Integration.delCnt( employeeId,eventPremiumtId  ,branchId);
        }
        Test.stopTest();
        System.assertEquals('200', eventResponse.statusCode);
    }
}