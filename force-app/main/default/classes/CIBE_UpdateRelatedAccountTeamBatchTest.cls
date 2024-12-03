/**********************************************************************************************************************
Name:	  CIBE_UpdateRelatedAccountTeamBatchTest
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Test para el Batch para actualizar los clientes relacionadas a ATM
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			DEFECT		    Luis Martínez       16/01/2024			Init version
***********************************************************************************************************************/
@isTest
public class CIBE_UpdateRelatedAccountTeamBatchTest {
    
    /**
	 * Create Data to test.
	 */
    @TestSetup
    static void setup() {

        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List <String> psA = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, psA);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        User usrGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name = 'CIBE_Gestor' LIMIT 1];
        Contact gestor = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =:usrGestor.Id  ]; 
        System.runAs(usrSetup) {
            Account cust = CIBE_TestHelper.createCustomer('9876543210');
            Account acc = new Account(
                Name = 'Prueba Batch',
                RecordtypeId = rtAccount,
                AV_Negocio__c ='EMP',
                AV_EAPGestor__c = gestor.Id
            );
            
            Account acc2 = new Account(
                Name = 'Prueba Batch 2',
                RecordtypeId = rtAccount,
                AV_Negocio__c ='INT',
                AV_EAPGestor__c = gestor.Id
            );        
            Account acc3 = new Account(
                Name = 'Prueba Batch 3',
                RecordtypeId = rtAccount,
                AV_Negocio__c ='CIB',
                AV_EAPGestor__c = gestor.Id
            );        
            Account acc4 = new Account(
                Name = 'Prueba Batch 4',
                RecordtypeId = rtAccount,
                AV_Negocio__c ='COR',
                AV_EAPGestor__c = gestor.Id
            );

            List<Account> listAcc = new List<Account>{acc,acc2,acc3,acc4};
            insert listAcc;

            accountTeamMember atm = new accountTeamMember(
                AccountId = acc2.Id, 
                UserId = usrSetup.id,
                cibe_isAutomatic__c = true
            );
            accountTeamMember atm2 = new accountTeamMember(
                AccountId = acc3.Id,
                UserId = usrSetup.id,
                cibe_isAutomatic__c = true
            );
            accountTeamMember atm3 = new accountTeamMember(
                AccountId = acc.Id,
                UserId = usrSetup.Id,
                cibe_isAutomatic__c = true
            );
            accountTeamMember atm4 = new accountTeamMember(
                AccountId = acc4.Id,
                UserId = usrSetup.id,
                cibe_isAutomatic__c = true
            );
            List<accountTeamMember> listAccTM = new List<accountTeamMember>{atm,atm2,atm3,atm4};
            insert listAccTM;
        }
    }

    /**
	 * Execute the Batch class (CIBE_UpdateRelatedAccountTeamBatch) 
	 */
    @isTest
    public static void updateAccountsTest() {
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        System.runAs(usrSetup) {
            List<AccountTeamMember> listaAccTM = [SELECT Id, AccountId, Account.AV_EAPGestor__r.AV_UsuarioAsociado__c, UserId 
                                                  FROM AccountTeamMember 
                                                  WHERE CreatedDate = LAST_N_DAYS:23 AND CIBE_Negocio__c = true AND CIBE_IsAutomatic__c = true AND Account.RecordTypeID =: rtAccount LIMIT 1];
            Test.startTest();
            CIBE_UpdateRelatedAccountTeam_Batch batch = new CIBE_UpdateRelatedAccountTeam_Batch();
            Id batchId = Database.executeBatch(batch);        
            Test.stopTest();
            List<Account> accRs = [SELECT id, CIBE_AccountTeam__c FROM Account WHERE id =:listaAccTM[0].AccountId AND CIBE_AccountTeam__c !=null];
            System.assert(!accRs.isEmpty());
            System.assert(batchId!=null);
        }
    }    
}