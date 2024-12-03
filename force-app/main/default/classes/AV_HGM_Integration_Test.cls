/**********************************************************************************************************************
 Name:	  AV_HGM_Integration_Test
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test para AV_HGM_Integration.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	   AUTHOR				DATE			Description
    1.0         US268687       Maria Martinez       28/09/2021      Init version
    1.1		    AV_Query IT	   Daniel Rodríguez	    04/02/2022	    Change AV_Query to SOQL for User and Account
    1.2		    AV_Query IT	   Luis Fernández	    11/07/2022	    Change AV_Query to SOQL for Task
    1.3		    US517394	   Patricia Solano	    08/02/2023	    Modify setup to change AppDefinition to AV_CRM_Intouch and 
                                                                    modify methods to add new attributtes and survey value
    1.4		    DE72361	       Patricia Solano	    24/02/2023	    Modify all methods to add runAs
    1.5         US584558	   Patricia Villacañas	09/05/2023		Added center parameter in method getHGMCustomer_fw
    1.6                        Ángel Medina         26/05/2023      Add runAs in methods getHGMCustomer_fw and validateGetSurveyId_fw
    1.7  	 	Upgrade V2	   Borja Lavesiera      15/12/2023		Modification to version V2 of NPS
    ***********************************************************************************************************************/

    @isTest
    public with sharing class AV_HGM_Integration_Test{
        @TestSetup
        static void setup(){
            AV_TestHelper.activateLogger();
            CBK_IntegrationSetting__c integration= new CBK_IntegrationSetting__c();
            integration.NamedCredential__c='callout:API_GWT_MC_PRO/marketingAndDevelopment/customerSurveys/surveys/{surveyId}/customers/id/invite';
            integration.Name='AV_CSurvey_Survey';
            CBK_IntegrationSetting__c integration2= new CBK_IntegrationSetting__c();
            integration2.NamedCredential__c='callout:API_GWT_MC_PRO/marketingAndDevelopment/customerSurveys/triggers/{triggerId}/surveys';
            integration2.Name='AV_CSurvey_triggers';
            CBK_IntegrationSetting__c integrationCibe1= new CBK_IntegrationSetting__c();
            integrationCibe1.NamedCredential__c='callout:API_GWT_PRO/marketing/customerSurveys/v2/customers/id/surveys/{surveyId}/invite';
            integrationCibe1.Name='CIBE_CSurvey_Survey';
            CBK_IntegrationSetting__c integrationCibe2= new CBK_IntegrationSetting__c();
            integrationCibe2.NamedCredential__c='callout:API_GWT_PRO/marketing/customerSurveys/v2/triggers/id/surveys{triggerId}';
            integrationCibe2.Name='CIBE_CSurvey_triggers';
            List<CBK_IntegrationSetting__c> listIntegrations= new List<CBK_IntegrationSetting__c>();
            listIntegrations.add(integration);
            listIntegrations.add(integration2);
            listIntegrations.add(integrationCibe1);
            listIntegrations.add(integrationCibe2);
            Database.insert(listIntegrations);
            User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
            User usuario = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
            User userCibe = CIBE_TestHelper.createUser('CIBE_Gestor');
            System.runAs(usuarioCli){
                Account cuenta = AV_TestHelper.createCustomerSinInsert();
                cuenta.PersonEmail = 'test@test.test';
                cuenta.PersonMobilePhone = '643567898';
                cuenta.AV_Idioma__c= '001';
                Database.insert(cuenta);
            }
            System.runAs(usuarioGcf){
                Account cuenta = [SELECT Id FROM Account WHERE PersonMobilePhone ='643567898' LIMIT 1];
                Task tarea =  AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(usuario, '01928374', cuenta );
                tarea.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT).Id;
                tarea.Status= 'Open';
                tarea.AV_SurveyValue__c = 11;
                tarea.AV_Valor5__c = 'token: E2j5VVFkG4u180y';
                Database.insert(tarea); 
            }

            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CRM_Intouch' LIMIT 1];             
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = usuarioGcf.Id, FormFactor = 'Small');
            Database.insert(app);

            
        }
    
        @isTest
        public static void validateGetSurveyId(){
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMSURVEYID', 'OK') );
            User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            Task tarea = [SELECT Id, AV_SurveyValue__c, AV_Valor5__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
            String triggerId = String.valueOf(tarea.AV_SurveyValue__c);
            AV_HGM_Integration.SurveyResponse result = new  AV_HGM_Integration.SurveyResponse();
            Test.startTest();
                System.runAs(usuarioGcf){
                    result = AV_HGM_Integration.getSurveyId(triggerId);
                }
            Test.stopTest();
            System.assertEquals('200', result.statusCode, 'statusCode distinto 200');
        }
    
        @isTest
        public static void validateGetSurveyId_fw(){
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMSURVEYID', 'OK') );
            User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            AV_HGM_Integration.SurveyResponse result = new  AV_HGM_Integration.SurveyResponse();
            Task tarea = [SELECT Id, AV_SurveyValue__c, AV_Valor5__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
            String triggerId = String.valueOf(tarea.AV_SurveyValue__c);
            Test.startTest();    
                System.runAs(usuarioGcf){
                    result = AV_HGM_Integration.getSurveyId_fw(triggerId);
                }
            Test.stopTest();
            System.assertEquals('200', result.statusCode, 'statusCode distinto 200');
        }
    
        @isTest
        public static void validateGetHGMCustomer(){
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMCUSTOMER', 'OK'));
            User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            Account cuenta = [Select Id, AV_NumPerso__c, FirstName, LastName, PersonEmail, PersonMobilePhone, AV_Idioma__c From Account Where AV_NumPerso__c = '123' and FirstName = 'FirstName' limit 1];     
            Task tarea = [SELECT Id, AV_Center__c, CreatedDate FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
            Date  todaysDate = system.today();
            AV_HGM_Integration.CustomerData datacliente = new AV_HGM_Integration.CustomerData();
            datacliente.firstname = cuenta.FirstName;
            datacliente.lastname=cuenta.LastName;
            datacliente.email=cuenta.PersonEmail;
            datacliente.prefix='0034';
            datacliente.phone=cuenta.PersonMobilePhone;
            datacliente.language=cuenta.AV_Idioma__c;
            String numper = cuenta.AV_NumPerso__c;
            datacliente.attributes =  new List<String>();
            datacliente.attributes.add(String.valueOf(tarea.CreatedDate));
            datacliente.attributes.add(String.valueOf(todaysDate));
            datacliente.attributes.add(null);
            datacliente.attributes.add('token: E2j5VVFkG4u180y');
            numper = cuenta.AV_NumPerso__c;
            Integer surveyId =  842982;
            String center = tarea.AV_Center__c;
            AV_HGM_Integration.CustomerResponse result = new AV_HGM_Integration.CustomerResponse();
            Test.startTest();
                System.runAs(usuarioGcf){
                    result = AV_HGM_Integration.getHGMCustomer(numper, surveyId, datacliente, center);
                }
                Test.stopTest();
            System.assertEquals('200', result.statusCode, 'statusCode distinto 200');
        }
         
    
        @isTest
        public static void getHGMCustomer_fw(){
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMCUSTOMER', 'OK'));
            User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            User userCibe =[SELECT Id FROM User WHERE Profile.Name = 'CIBE_Gestor' AND IsActive = true LIMIT 1];
            Account cuenta = [Select Id, AV_NumPerso__c, FirstName, LastName, PersonEmail, PersonMobilePhone, AV_Idioma__c From Account Where AV_NumPerso__c = '123' and FirstName = 'FirstName' limit 1];     
            Task tarea = [SELECT Id,CreatedDate, AV_Center__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1];
            Date  todaysDate = system.today();
            AV_HGM_Integration.CustomerData datacliente = new AV_HGM_Integration.CustomerData();
            datacliente.firstname = cuenta.FirstName;
            datacliente.lastname=cuenta.LastName;
            datacliente.email=cuenta.PersonEmail;
            datacliente.prefix='0034';
            datacliente.phone=cuenta.PersonMobilePhone;
            datacliente.language=cuenta.AV_Idioma__c;
            String numper = cuenta.AV_NumPerso__c;
            datacliente.attributes =  new List<String>();
            datacliente.attributes.add(String.valueOf(tarea.CreatedDate));
            datacliente.attributes.add(String.valueOf(todaysDate));
            datacliente.attributes.add(null);
            datacliente.attributes.add('token: E2j5VVFkG4u180y');
            numper = cuenta.AV_NumPerso__c;
            Integer surveyId =  842982;
            String center = tarea.AV_Center__c;
            Test.startTest();
                System.runAs(userCibe){
                    AV_HGM_Integration.CustomerResponse result = AV_HGM_Integration.getHGMCustomer_fw(numper, surveyId, datacliente, center);
                    System.assertEquals('200', result.statusCode, 'statusCode distinto 200');
                }
            Test.stopTest();
        } 
    }