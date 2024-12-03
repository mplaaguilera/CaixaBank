/**********************************************************************************************************************
Name:	  CIBE_CustomCalendar_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test for AV_CustomCalendar
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US593161		Álvaro Montalbán 	    15/04/2023		Init version 
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_CustomCalendar_Controller_Test {
   @TestSetup
   static void setup(){
      CIBE_TestInitialSetup.setupInitialDataEMP();
   }

    
    

 @isTest
 public static void retrieveEventsTest(){
   List<Event> result = new List<Event>();   
   System.runAs(new User(Id = UserInfo.getUserId())) {
      Test.startTest();
      
      User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
      String stringDate= '2023-04-01';
      System.runAs(u){
         result = CIBE_CustomCalendar_Controller.retrieveEvents(u.Id,stringDate);
         CIBE_CustomCalendar_Controller.retrieveEvents('',stringDate);
      }
      Test.stopTest();
   }
   System.assert(result.isEmpty());
}


   @isTest
   public static void retrieveEventsWeekTest(){
   List<Event> result = new List<Event>();   
   System.runAs(new User(Id = UserInfo.getUserId())) {
      Test.startTest();
      
      User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
      String stringDate= '2023-04-01';
      System.runAs(u){
         result = CIBE_CustomCalendar_Controller.retrieveEventsWeek(u.Id,stringDate);
         CIBE_CustomCalendar_Controller.retrieveEventsWeek('',stringDate);
      }
      Test.stopTest();
   }
   System.assert(result.isEmpty());
 }
    
    @isTest
   public static void retrieveEventsWeekCIBTest(){
   List<Event> result = new List<Event>();   
   System.runAs(new User(Id = UserInfo.getUserId())) {
      Test.startTest();
      
      User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
      String stringDate= '2023-04-01';
      System.runAs(u){
         result = CIBE_CustomCalendar_Controller.retrieveEventsCIB(u.Id,stringDate);
         CIBE_CustomCalendar_Controller.retrieveEventsCIB('',stringDate);
      }
      Test.stopTest();
   }
   System.assert(result.isEmpty());
 }

 @isTest
   public static void retrieveEventsMonthTest(){
   List<Event> result = new List<Event>();   
   System.runAs(new User(Id = UserInfo.getUserId())) {
      Test.startTest();
      
      User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
      String stringDate= '2023-04-01';
      System.runAs(u){
         result = CIBE_CustomCalendar_Controller.retrieveEventsMonth(u.Id,stringDate);
         CIBE_CustomCalendar_Controller.retrieveEventsMonth('',stringDate);
      }
      Test.stopTest();
   }
   System.assert(result.isEmpty());
 }
}