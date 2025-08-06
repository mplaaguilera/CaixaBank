/**********************************************************************************************************************
Name:	  CIBE_UpdateOpportunityGCBatchTest
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Test para el Batch para actualizar las oportunidades relacionadas a grupos comerciales
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US776093		Luis Martínez       16/12/2023			Init version
***********************************************************************************************************************/
@isTest
public class CIBE_UpdateOpportunityGCBatchTest {
    
    /**
	 * Create Data to test.
	 */
    @TestSetup
    static void setup() {

        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();

        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        List <String> psA = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, psA);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        
        System.runAs(usrSetup) {
            Account cust = CIBE_TestHelper.createCustomer('9876543210');
            Account acc = new Account(
                Name = 'Prueba',
                RecordtypeId = rtAccount
            );
            
            Account acc2 = new Account(
                Name = 'Prueba 2',
                RecordtypeId = rtAccount
            );        
            Account acc3 = new Account(
                Name = 'Prueba 3',
                RecordtypeId = rtAccount
            );        
            Account acc4 = new Account(
                Name = 'Prueba 4',
                RecordtypeId = rtAccount
            );

            List<Account> listAcc = new List<Account>{acc,acc2,acc3,acc4};
            insert listAcc;
            FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
                Name = 'Parent',
                FinServ__InverseRole__c = 'Cliente'
            );
            insert role;
            
            FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation,
                FinServ__Account__c = listAcc[0].id,
                FinServ__RelatedAccount__c = listAcc[1].id,
                FinServ__Role__c = role.id
            );
            insert accR; 
            
            FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation,
                FinServ__Account__c = listAcc[2].id,
                FinServ__RelatedAccount__c = listAcc[3].id,
                FinServ__Role__c = role.id
            );
            insert accR2;

            Opportunity opp = new Opportunity();
            opp.AccountId = cust.Id;
            opp.Name = 'Prueba Test Email';
            opp.OwnerId = usrSetup.Id;
            opp.StageName = 'Potencial';
            opp.RecordTypeId = rtOpp.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_ClienteConfidencial__c = true;
            insert opp;   
    
        List<Opportunity> listOpp = new List<Opportunity>();
            listOpp.add(opp);
        }
    }

    /**
	 * Execute the Batch class (CIBE_UpdateOpportunityGC_Batch) 
	 */
    @isTest
    public static void updateOpportunitiesTest() {
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();

        System.runAs(usrSetup) {
            List<FinServ__AccountAccountRelation__c> listaAccR = [SELECT id, FinServ__Account__c, FinServ__RelatedAccount__c
            FROM FinServ__AccountAccountRelation__c 
            WHERE RecordTypeId = :rtAccountRelation AND FinServ__Role__r.Name = 'Parent' AND LastModifiedDate = LAST_N_DAYS:3 ORDER BY LastModifiedDate DESC LIMIT 1];
            Account cuenta = [SELECT id FROM Account WHERE AV_NumPerso__c ='9876543210'];
            listaAccR[0].FinServ__RelatedAccount__c = cuenta.ID;
            update listaAccR;
            Test.startTest();
            
                CIBE_UpdateOpportunityGC_Batch batch = new CIBE_UpdateOpportunityGC_Batch();
                Id batchId = Database.executeBatch(batch);
            
            Test.stopTest();
        }
        List<Opportunity> oppRs = [SELECT id, CIBE_GrupoComercial__c FROM Opportunity WHERE RecordTypeId =:rtOpp.ID AND CIBE_GrupoComercial__c != null];
        System.assertNotEquals(false, oppRs.size()>0);
    }    
}