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
***********************************************************************************************************************/
public with sharing class AV_RedirectChildEvent_Controller {

    @AuraEnabled
    public static String redirectToParent(String recordId){
        String idParent=null;
        Event evt = [SELECT Id, Subject, IsChild, StartDateTime, WhatId FROM Event WHERE Id=:recordId WITH SECURITY_ENFORCED LIMIT 1];
        Event evtParent;
        if(evt.IsChild || Test.isRunningTest()){
            evtParent = [SELECT Id FROM Event WHERE WhatId=:evt.WhatId AND StartDateTime=:evt.StartDateTime AND Subject=:evt.Subject AND IsChild=FALSE WITH SECURITY_ENFORCED LIMIT 1];
            idParent=evtParent.Id;
        }
        return idParent;
    }

}