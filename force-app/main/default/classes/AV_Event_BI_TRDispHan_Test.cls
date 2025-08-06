@isTest
public with sharing class AV_Event_BI_TRDispHan_Test {
 
    @TestSetup
    static void setup(){
        Account client = AV_TestHelper.createCustomer();
        
    }
    
    @isTest 
    public static void insertTest(){
        Account client = [SELECT ID FROM Account LIMIT 1];
        User usuarioAV = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        User usuarioCIBE =CIBE_TestHelper.createUser('CIBE_Gestor');
        Contact cntUsuarioAV = AV_TestHelper.createEmployee(null, usuarioAV);
        Contact cntUsuarioCIBE = AV_TestHelper.createEmployee(null, usuarioCIBE);
        User apiOnlyUser = AV_TestHelper.createUser('API Only');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        System.runAs(apiOnlyUser){

            Event eventAV = new Event( 
                OwnerId = usuarioAV.Id,
                DurationInMinutes = 30,
                ActivityDateTime = System.today(),
                WhatId = client.Id
                );
                insert eventAV ;
                
            Event eventCIBE = new Event( 
            OwnerId = usuarioCIBE.Id,
            DurationInMinutes = 30,
            ActivityDateTime = System.today(),
            WhatId = client.Id
            );
            insert eventCIBE;
            
        }
            List<Event> retrieveEventAV = [SELECT Id,RecordTypeId FROM EVENT];
            
            for(Event ev : retrieveEventAV){
                System.assert(ev.RecordTypeId != null);
            }

        Test.stopTest();
        
    }
}