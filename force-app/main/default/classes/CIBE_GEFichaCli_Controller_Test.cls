/**********************************************************************************************************************
Name:     CIBE_GEFichaCli_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_GEFichaCli_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      DE80894				Bea     		23/08/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_GEFichaCli_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {

            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
            Name = 'Cliente-Test',
            RecordTypeId = rt.Id,
            AV_ToDelete__c = false,
            AV_Negocio__c = 'CIB',
            AV_NumPerso__c = '1022946312'
            
            );
            insert acc;

            RecordType rt2 = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_G_ECONOMICO_RT);
            Account accGE = new Account(
                Name = 'GE-Test',
                RecordTypeId = rt2.Id,
                AV_ToDelete__c = false,
                CIBE_GEId__c = 'GE-10070'

                );
            insert accGE;

            FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
                Name = 'Parent',
                FinServ__InverseRole__c = 'Cliente',
                OwnerId = usrGestor.Id
            );
            insert role;

            RecordType rt3 = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCACCRELATION, CIBE_AppConstants.ACCOUNT_G_ECONOMICO_RT);
            FinServ__AccountAccountRelation__c accAccRel = new FinServ__AccountAccountRelation__c(
                FinServ__Role__c = role.id,
                FinServ__Account__c = acc.Id,
                FinServ__RelatedAccount__c = accGE.Id,
                RecordTypeId = rt3.Id,
                AV_ToDelete__c = false,
                CIBE_TipoGrupo__c = '120',
                CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
                CIBE_Matriz__c = true,
                OwnerId = usrGestor.Id

            );
            
            insert accAccRel;
        }
    }

    @isTest
	public static void CommercialGroupTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Cliente-Test'];
        Account accGE = [SELECT Id, Name FROM Account WHERE Name = 'GE-Test'];


        System.runAs(usuarioGe) {
           FinServ__AccountAccountRelation__c accAccRel = [SELECT FinServ__RelatedAccount__c,  FinServ__RelatedAccount__r.Name  FROM FinServ__AccountAccountRelation__c WHERE RecordType.Developername = 'CIBE_GrupoEconomico' AND CIBE_TipoGrupo__c = '120' AND FinServ__Account__c = :acc.Id AND FinServ__RelatedAccount__r.AV_ToDelete__c = false];
 
            Test.startTest();
            List<CIBE_GEFichaCli_Controller.Wrapper> results = CIBE_GEFichaCli_Controller.gruposEconomicos(acc.Id);

            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}