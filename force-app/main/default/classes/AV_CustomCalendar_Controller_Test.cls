/**********************************************************************************************************************
Name:	  AAV_CustomCalendar_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test for AV_CustomCalendar
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US593161		Luis Fernández 	    15/04/2023		Init version 
***********************************************************************************************************************/
@isTest
public with sharing class AV_CustomCalendar_Controller_Test {
 @TestSetup
 static void setup(){

    AV_TestHelper.createUser(null);
    
    
 }

 @isTest
 public static void retrieveEventsTest(){
    Test.startTest();
    List<Event> result = new List<Event>();
    User u = [Select ID FROM User WHERE Alias = 'tsAlias' AND Email = 'test@test.dev'];
    String stringDate= '2023-04-01';
    System.runAs(u){
        result = AV_CustomCalendar_Controller.retrieveEvents(u.Id,stringDate);
        AV_CustomCalendar_Controller.retrieveEvents('',stringDate);
    }
    Test.stopTest();

    System.assert(result.isEmpty());
 }
}