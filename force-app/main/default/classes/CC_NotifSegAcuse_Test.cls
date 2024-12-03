@IsTest
public with sharing class CC_NotifSegAcuse_Test {
    @TestSetup
    public static void datosAltaTest(){

        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		List<Case> listCase = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Caso de prueba CC_AcuseDelay__c';
        caso.recordtypeId= recordTypeCasoCliente;
        caso.Origin = 'Email';
        caso.CC_AcuseDelay__c = datetime.now();
        caso.CC_Canal_Operativo__c = 'App BrokerNow';
        listCase.add(caso);
        Insert listCase;
    }
    
    @isTest
    public static void workTest() {

        List<Case> lstCasos = [SELECT Id FROM Case LIMIT 200];
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
        Datetime vToday = datetime.now();
        
        for(Case caso: lstCasos){
            CBK_SCH_PendingProcess__c pendingProcess1 = new CBK_SCH_PendingProcess__c();
            pendingProcess1.RecordId__c = caso.Id;
            pendingProcess1.Schedule_Time__c = vToday.addDays(- 1);
            pendingProcess1.ClassName__c = 'CC_NotifSegAcuse';
            pendingProcessInsertList.add(pendingProcess1);
        }
                
        Insert pendingProcessInsertList;
        
        test.startTest();
        
        CC_NotifSegAcuse implClass = new CC_NotifSegAcuse();
        implClass.lstInfoProcess = pendingProcessInsertList; 
        System.enqueueJob(implClass);
        
        test.stopTest();

        Case casoPost = [SELECT Id,CC_Notif_Cont_Inter__c FROM Case LIMIT 1];
        System.assertNotEquals(null, casoPost.CC_Notif_Cont_Inter__c, 'No se ha relenado el campo'); 
        
    }
}