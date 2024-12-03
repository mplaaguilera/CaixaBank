/**********************************************************************************************************************
 Name:	  CIBE_OpportunityStateSchedulable
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para pasar a estado 'Vencido' todas las oportunidades que tengan el closeDate inferior a TODAY
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0					            Ali                        06/06/2023			Init version
***********************************************************************************************************************/
@isTest
public class CIBE_OpportunityStateSchedulable_Test {
    
    /**
	 * Create Data to test.
	 */
    @TestSetup
    static void setup() {
        
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS, CIBE_AppConstants.USER_AV_AvoidBulkApi };
        CIBE_TestInitialSetup.setupInitialData(null, 'EMP', null, null, null, listPermissionsSet);

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        
        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();

        System.runAs(usuario) {
            Account acc = CIBE_TestHelper.createCustomer(usuario);
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            Opportunity opp = new Opportunity();
                opp.ownerId = usuario.Id;
                opp.RecordTypeId = rtOpp;
                opp.CloseDate = System.today() - 5;
                opp.AccountId = acc.Id;
                opp.Name = 'Alerta Comercial';
                opp.StageName = 'En curso';
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.AV_PF__c = prodPF.Id;
                insert opp;    
        
        List<Opportunity> listaOpp = new List<Opportunity>();
        listaOpp.add(opp);
        }
    }

    /**
	 * Execute the Batch class (CIBE_OpportunityStateSchedulable) 
	 */
    @isTest
    public static void validateBatch() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(usuario) {
        
			Test.startTest();
            	CIBE_OpportunityStateSchedulable batchPrueba = new CIBE_OpportunityStateSchedulable('SELECT Id FROM Opportunity');
                CIBE_OpportunityStateSchedulable batch = new CIBE_OpportunityStateSchedulable();
                Id batchId = Database.executeBatch(batch);
            Test.stopTest();
		}
        List<Opportunity> listOpp = [SELECT id FROM Opportunity WHERE Name = 'Alerta Comercial' AND StageName = 'CIBE_Vencido' LIMIT 1];
        System.assertEquals(1, listOpp.size());
    }
}