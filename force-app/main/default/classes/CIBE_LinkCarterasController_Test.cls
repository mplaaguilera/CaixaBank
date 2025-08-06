/**********************************************************************************************************************
Name:	  CIBE_LinkCarterasController_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de la clase CIBE_LinkCarterasController 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			US644636		    Lucia Muñoz         15/09/2023		    Init version

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_LinkCarterasController_Test {

    @TestSetup
    static void setup(){ 

        CIBE_TestInitialSetup.setupInitialDataEMP();

        System.runAs(new User(Id = UserInfo.getUserId())){

            User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

            
            Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :u.Id ];
            System.debug('@@@@ ' + c);
            Account acc = [SELECT Id FROM Account WHERE Name = '00001 - CENTER' ];

            AV_Book__c  cartera = new AV_Book__c  (
                AV_Centro__c = acc.Id,
                AV_Activa__c = 'S',
                AV_Negocio__c = 'BPR',
                OwnerId = u.Id
            );
            insert cartera;

            AV_BookManagementMember__c carteraManager = new AV_BookManagementMember__c(
                AV_Cartera__c = cartera.Id,
                AV_EmpleadoGestor__c = c.Id
            );
            insert carteraManager;

        }
    }


    @isTest
    private static void testGetUrl(){
 
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        System.runAs(usuario){
            String url = '';
            CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_Carteras');

            Contact centroUser = [SELECT Id, AccountId, Account.Name FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            
            AV_BookManagementMember__c cartera = [SELECT Id, AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c, AV_EmpleadoGestor__r.CC_Matricula__c, AV_EmpleadoGestor__r.AV_UsuarioAsociado__r.AV_ExternalID__c, AV_EmpleadoGestor__r.Name 
            FROM AV_BookManagementMember__c 
            WHERE AV_Cartera__r.AV_Centro__c = :centroUser.AccountId];

            String urlTesting = result.CIBE_URL__c.replace('{empleadoEjec}', cartera.AV_EmpleadoGestor__r.CC_Matricula__c).replace('{centroEjec}', cartera.AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c).replace('{centro}', cartera.AV_Cartera__r.AV_Centro__r.CC_Numero_Oficina__c).replace('{empleado}', cartera.AV_EmpleadoGestor__r.AV_UsuarioAsociado__r.AV_ExternalID__c);

            Test.startTest();
            url = cibe_LinkCarterasController.getUrl();
            Test.stopTest();
            System.assertEquals(urlTesting, url);
        }
    }
    
}