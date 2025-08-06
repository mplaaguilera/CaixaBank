@isTest
public with sharing class CBK_SCH_OS_ScheduleAgenteBackupTest {
 
    @TestSetup
    public static void datosAltaTest(){
        
       
        
        User usuario1 = new User();
        usuario1.Alias = 'standt1';
        usuario1.Email = 'standarduser1@testorg.com';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LastName = 'Testing';
        usuario1.LanguageLocaleKey ='en_US';
        usuario1.LocaleSidKey = 'en_US';
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'].Id;
        usuario1.TimeZoneSidKey = 'America/Los_Angeles';
        usuario1.UserName = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,8) + '@myorg.com';
        usuario1.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'COPS'].Id;
        insert usuario1;
        
        User usuario2 = new User();
        usuario2.Alias = 'standt2';
        usuario2.Email = 'standarduser2@testorg.com';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LastName = 'Testing';
        usuario2.LanguageLocaleKey ='en_US';
        usuario2.LocaleSidKey = 'en_US';
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'].Id;
        usuario2.TimeZoneSidKey = 'America/Los_Angeles';
        usuario2.UserName = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,8) + '@myorg.com';
        usuario2.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'COPS'].Id;
        insert usuario2;
        
        
    }
    
    @isTest
    public static void CBK_SCH_CSBD_SchedulePendienteCita_Test() {
        
        User u1 = [SELECT Id, Name, OS_Fin_Vigencia_Agente_Backup__c,OS_Inicio_Vigencia_Agente_Backup__c, OS_Agente_Backup__c  FROM User WHERE Email='standarduser1@testorg.com'];
        User u2 = [SELECT Id  FROM User WHERE Email='standarduser2@testorg.com'];
        
        u1.OS_Agente_Backup__c = u2.Id;
        u1.OS_Inicio_Vigencia_Agente_Backup__c =  System.Now()-1;
        u1.OS_Fin_Vigencia_Agente_Backup__c = System.Today();
        update u1;
        
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = [SELECT Id, RecordId__c, Schedule_Time__c, ClassName__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c =: u1.Id];
        System.assert(!pendingProcessInsertList.isEmpty());
        
        System.runAs(u1){
            
            test.startTest();
            
            CBK_SCH_OS_ScheduleAgenteBackup implClass = new CBK_SCH_OS_ScheduleAgenteBackup();
            implClass.lstInfoProcess = pendingProcessInsertList;
            System.enqueueJob(implClass);
            
            test.stopTest();
                
            System.assert([SELECT Id, OS_Agente_Backup__c FROM User WHERE Id =: u1.Id].OS_Agente_Backup__c == null); 
        }
       
    }
    
    
}