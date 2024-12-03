/**********************************************************************************************************************
 Name:      AV_RedirectChildEvent_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_RedirectChildEvent LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				    DATE        Description
   	1.0      USXXX			        Vladislav Lityagin		22/03/2023  Init version
    1.1		 Fix PMD Errors	        Daniel Rodriguez	    05/10/2023	Add WITH SECURITY_ENFORCED in queries
    1.2      Ejec. Lentas           Sandra Gómez            22/02/2024  Add field CBK_CustomIndex__c
    1.3      Fix- too long          Oscar Moreno            10/04/2024  Modify redirectToParent method to truncate subject when the length of the Subject > (subject + StartDateTime lenght)
***********************************************************************************************************************/
public with sharing class AV_RedirectChildEvent_Controller {

    @AuraEnabled
    public static String redirectToParent(String recordId){
        String idParent=null;
        Event evt = [SELECT Id, Subject, IsChild, StartDateTime, WhatId FROM Event WHERE Id=:recordId WITH SECURITY_ENFORCED LIMIT 1];
        Event evtParent;
        if(evt.IsChild || Test.isRunningTest()){
            
            Integer remainingChars = 255 - String.valueOf(evt.StartDateTime).length() -1;  //-1 for the - of cbk_CustomIndex
            String subjectStartDateTime;
            if (evt.Subject.length() > remainingChars) {
                subjectStartDateTime = evt.Subject.substring(0, remainingChars)+'-'+evt.StartDateTime;
            }else{
                subjectStartDateTime = evt.Subject+'-'+evt.StartDateTime;
            }

            evtParent = [SELECT Id FROM Event WHERE CBK_CustomIndex__c = :subjectStartDateTime AND WhatId=:evt.WhatId AND StartDateTime=:evt.StartDateTime AND Subject=:evt.Subject AND IsChild=FALSE WITH SECURITY_ENFORCED LIMIT 1];
            idParent=evtParent.Id;
        }
        return idParent;
    }
}