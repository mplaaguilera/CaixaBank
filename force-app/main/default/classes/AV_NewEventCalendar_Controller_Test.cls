/**********************************************************************************************************************
 Name:	  AV_NewEventCalendar_Controller_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Test class for AV_NewEventCalendar_Controller
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US135429			Álvaro López		11/12/2020			Init version
	1.1 		FIX					Luis Fernández		12/07/2022			Changed AV_Query to SOQL query

***********************************************************************************************************************/
@isTest
public with sharing class AV_NewEventCalendar_Controller_Test {

    @isTest
    public static void eventTest(){
		 AV_NewEventCalendar_Controller.newEventController();
         AV_UserEventsHelper.getUserEvents();

	}

}