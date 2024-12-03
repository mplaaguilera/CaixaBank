@isTest
public class CBK_copado_Promotion_AU_TRHan_Test {
    private static User runningUser;
    private static copado__Environment__c sourceEnv1;
    private static copado__Environment__c targetEnv2;
    private static copado__Org__c sourceOrg1;
    private static copado__Org__c targetOrg2;

    private static void setupTestData() {
        // Create admin user for creating and assigning the Copado licenses to a running user
        User adminUser = createAdminUser();
        insert adminUser;

        System.runAs(adminUser) {
            // Create running user
            runningUser = createStandardUser();
            runningUser.ProfileId = adminUser.ProfileId;
            insert runningUser;

            // Assign the Copado permission set to the running user
            PermissionSetAssignment psa = new PermissionSetAssignment (
                PermissionSetId = getCopadoUserPermissionSet().Id,
                AssigneeId = runningUser.Id
            );
            insert psa;

            // Assign A Copado License to the running User
            copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI();
            copado.GlobalAPI.UserLicense UL = new copado.GlobalAPI.UserLicense();
            UL.isCopadoEnabled = true;
            UL.isCCMEnabled = true;
            UL.userId = runningUser.id;
            copadoGlobalAPI.upsertCopadoLicense(runningUser.id, UL);
        }

    }
    
	@isTest
	public static void test1() {		
        setupTestData();
        System.runAs(runningUser) {            
            copado__Deployment_Flow__c pipeline = New copado__Deployment_Flow__c(Name='TestPipeline',copado__Active__c=true);
            insert pipeline;
    
            copado__Project__c project = New copado__Project__c(Name='Oficina Técnica',copado__Deployment_Flow__c =pipeline.Id);
            insert project;
    
            copado__Environment__c entorno = New copado__Environment__c(Name = 'TestEntorno',CBK_CheckMetadata__c=true);
            insert entorno;
    
            copado__Org__c cred = new copado__Org__c(Name ='TestCredential',copado__Default_Credential__c =true,copado__Org_Type__c ='Production/Developer', copado__Environment__c =entorno.id);
            insert cred;
                                                                
            copado__Release__c release = New copado__Release__c(Name='TestRelease');
            insert release;
            
            copado__Deployment_Flow_Step__c step = new copado__Deployment_Flow_Step__c(copado__Deployment_Flow__c =pipeline.Id,copado__Branch__c ='tst',copado__Destination_Environment__c =entorno.id,copado__Source_Environment__c=entorno.id );
            insert step;
            
            copado__User_Story__c us = new copado__User_Story__c(copado__Project__c = project.Id,
                                                                 copado__Release__c = release.Id,
                                                                 copado__Environment__c = entorno.id
                                                                );
            insert us;
            
            copado__User_Story_Metadata__c metadata = new copado__User_Story_Metadata__c (copado__Metadata_API_Name__c='TestMetadata',
                                                                                          copado__User_Story__c = us.Id,
                                                                                          copado__Last_Commit_Date__c =system.now()
                                                                                         );
            insert metadata;
            
            copado__Promotion__c promo = new copado__Promotion__c(copado__Project__c = project.id,
                                                                 copado__Release__c =release.id,
                                                                 copado__Source_Environment__c = entorno.id,
                                                                 copado__Destination_Environment__c = entorno.id,
                                                                 copado__Source_Org_Credential__c = cred.id,
                                                                 copado__Status__c='Draft'
                                                                 );
            insert promo;
            
            copado__Promoted_User_Story__c pUs = new copado__Promoted_User_Story__c(Name ='Test',
                                                                                   copado__User_Story__c = us.id,
                                                                                   copado__Promotion__c = promo.id);
            insert pUs;
    
            test.startTest();
            promo.copado__Status__c='Completed';
            update promo;
            test.stopTest();
            system.assertNotEquals(null,promo.Id);
    	}     
	}
    public static PermissionSet getCopadoUserPermissionSet(){
        return [SELECT Id FROM PermissionSet WHERE Name = 'Copado_User'];
    }    
    public static User createAdminUser(){
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator' Limit 1];
        User newUser = new User();
        newUser.ProfileId = adminProfile.Id;
        newUser.FirstName = 'Rebekah';
        newUser.LastName = 'Admin';
        newUser.email = 'admin@aa.test';
        newUser.Username = 'admin@aa.test';
        newUser.Alias = 'tadmin';
        newUser.CommunityNickname = 'tadmin';
        newUser.LocaleSidKey = 'es_ES';
        newUser.emailencodingkey='UTF-8';
        newUser.languagelocalekey='en_US';
        newUser.TimeZoneSidKey='Europe/Rome';
        return newUser;
    }

    public static User createStandardUser(){
        Profile standardProfile = [Select Id From Profile Where Name = 'Standard User' Limit 1];
        User newUser = new User();
        newUser.ProfileId = standardProfile.Id;
        newUser.FirstName = 'Daniel';
        newUser.LastName = 'Standard';
        newUser.email = 'standard@aa.test';
        newUser.Username = 'standard@aa.test';
        newUser.Alias = 'tandard';
        newUser.CommunityNickname = 'tstand';
        newUser.LocaleSidKey = 'es_ES';
        newUser.emailencodingkey='UTF-8';
        newUser.languagelocalekey='en_US';
        newUser.TimeZoneSidKey='Europe/Rome';

        return newUser;
    }
}