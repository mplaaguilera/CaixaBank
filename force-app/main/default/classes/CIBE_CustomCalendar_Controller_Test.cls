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

    AV_TestHelper.createUser(null);
    
    
 }

 @isTest
 public static void retrieveEventsTest(){
   List<Event> result = new List<Event>();   
   System.runAs(new User(Id = UserInfo.getUserId())) {
      Test.startTest();
      
      User u = [Select ID FROM User WHERE Alias = 'tsAlias' AND Email = 'test@test.dev'];
      String stringDate= '2023-04-01';
      System.runAs(u){
         result = CIBE_CustomCalendar_Controller.retrieveEvents(u.Id,stringDate);
         CIBE_CustomCalendar_Controller.retrieveEvents('',stringDate);
      }
      Test.stopTest();
   }
   System.assert(result.isEmpty());
 }
}