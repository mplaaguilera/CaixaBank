/**********************************************************************************************************************
 Name:	  AV_LeadOpportunity_AnonymityBatch
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para anonimizar los datos del Lead Opp y Lead relacionado.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		     AUTHOR				 DATE				Description
	1.0			US345266		Vladislav Lityagin     03/05/2022			Init version
    1.1		    FIX11070844	    Oscar Moreno		   22/07/2024			Fix error The Global modifier should be avoided.

  
***********************************************************************************************************************/
public class AV_LeadOpportunity_AnonymityBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
	public String limitBatch;

    public AV_LeadOpportunity_AnonymityBatch(String limitQuery) {
		limitBatch = limitQuery;
    }

    public AV_LeadOpportunity_AnonymityBatch(){}

   

    /**
	 * Get a list of leads opportunities to process the data
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	

    public Database.QueryLocator start(Database.BatchableContext bc){
        String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
        /*Set<String> conditionName = new Set<String>();
        conditionName.add('LO-00000002');*/
        if(limitBatch==null || String.isEmpty(limitBatch)){
            limitBatch = '';
        }else{
            limitBatch = ' limit '+limitBatch;
        }
        String query = ('SELECT AV_Lead__c, AV_Lead2__c, AV_DueDate__c, AV_ContracType1__c, AV_ContracType1_AN__c, AV_ContracType2__c, AV_ContracType2_AN__c,'
        +'AV_AnnualIncome1__c, AV_Amount1__c, AV_Amount1_AN__c, AV_AnnualIncome2__c, AV_Amount2__c, AV_Amount2_AN__c, AV_CurrentBalanceAmount1__c,'
        +'AV_CurrentBalanceAmount1_AN__c, AV_CurrentBalanceAmount2__c, AV_CurrentBalanceAmount2_AN__c, AV_InstallmentAmount1__c,'
        +'AV_DebtMonthlyInstallment1__c, AV_DebtMonthlyInstallment1_AN__c, AV_InstallmentAmount2__c, AV_DebtMonthlyInstallment2__c,'
        +'AV_DebtMonthlyInstallment2_AN__c, AV_SavingsAmountAmount__c, AV_SavingsAmountAmount_AN__c,'
        +'AV_CustomerProHolder1__c, AV_CustomerProHolder2__c, AV_Usage__c, AV_Type__c, AV_MunicipalityCode__c, AV_ProvinceCode__c, AV_AutonomousCommunityCode__c,'
        +'AV_Country__c, AV_StreetType__c, AV_StreetName__c, AV_BuildingNumber__c, AV_StairNumber__c, AV_FloorNumber__c, AV_ApartmentNumber__c,'
		+'AV_Status__c, AV_StatusLeadOpp__c, AV_LoanTern__c, AV_LoanTern_AN__c, AV_BuyingPriceCCY__c, AV_BuyingPriceCCY_AN__c, AV_BuyingPriceAmount__c,'
		+'AV_BuyingPriceAmount_AN__c, AV_LoanAmountCCY__c, AV_LoanAmountCCY_AN__c, AV_LoanAmountAmount__c, AV_LoanAmountAmount_AN__c, AV_SavingsAmountCCY__c, AV_SavingsAmountCCY_AN__c'
        +' FROM AV_LeadOpportunity__c WHERE AV_DueDate__c != null');

		return Database.getQueryLocator(query);
    }

    /**
	 * Update Lead & LeadOpp AN Data
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<AV_LeadOpportunity__c> param with the list of Leads
	 */
    public void execute(Database.BatchableContext bc, List<AV_LeadOpportunity__c> scope){
        //process each batch of records
        String methodName = 'execute';
        try {
            AV_LogDebug.printLogDebug(methodName,'Scope size' + scope.size());
            recordsProcessed = scope.size();

            Set<Id> leadsIds = new Set<Id>();
            List<AV_LeadOpportunity__c> leadOpportunitiesToUpdate = new List<AV_LeadOpportunity__c>();
            List<Lead> leadsToUpdate = new List<Lead>();

            Date fechaActual = Date.today();

            for (AV_LeadOpportunity__c lo : scope) {
                //Validar que la fecha de vencimiento sea menor que la fecha actual para blanquear los datos
                if(lo.AV_DueDate__c != null && lo.AV_DueDate__c<fechaActual){
                    //Etapa --> Vencida: Si se ha superado a fecha de vencimiento del Lead Opp y se encuentra en las etapas Potencial, En gestión/Insistir.
                    
                    if(lo.AV_StatusLeadOpp__c == null || lo.AV_StatusLeadOpp__c.equals('Potencial') || lo.AV_StatusLeadOpp__c.equals('En gestión/insistir')){
                       lo.AV_StatusLeadOpp__c = 'Vencida'; 
                    }
                    leadsIds.add(lo.AV_Lead__c);
                    leadsIds.add(lo.AV_Lead2__c);

                    lo.AV_ContracType1_AN__c = lo.AV_ContracType1__c;
                    lo.AV_ContracType1__c = null;
                    lo.AV_ContracType2_AN__c = lo.AV_ContracType2__c;
                    lo.AV_ContracType2__c = null;
                    lo.AV_Amount1_AN__c = lo.AV_AnnualIncome1__c;
                    //lo.AV_AnnualIncome1__c = null; //Formula que tira del campo AV_Amount1__c
                    lo.AV_Amount1__c = null;
                    lo.AV_Amount2_AN__c = lo.AV_AnnualIncome2__c;
                    //lo.AV_AnnualIncome2__c = null; //Formula AV_Amount2__c
                    lo.AV_Amount2__c = null;
                    lo.AV_CurrentBalanceAmount1_AN__c = String.valueOf(lo.AV_CurrentBalanceAmount1__c);
                    lo.AV_CurrentBalanceAmount1__c = null;
                    lo.AV_CurrentBalanceAmount2_AN__c = String.valueOf(lo.AV_CurrentBalanceAmount2__c);
                    lo.AV_CurrentBalanceAmount2__c = null;
                    lo.AV_DebtMonthlyInstallment1_AN__c = lo.AV_DebtMonthlyInstallment1__c;
                    //lo.AV_DebtMonthlyInstallment1__c = null; //Formula tira del campo AV_InstallmentAmount1__c
                    lo.AV_InstallmentAmount1__c = null;
                    lo.AV_DebtMonthlyInstallment2_AN__c = lo.AV_DebtMonthlyInstallment2__c;
                    //lo.AV_DebtMonthlyInstallment2__c = null; //Formula tira de AV_InstallmentAmount2__c
                    lo.AV_InstallmentAmount2__c = null;                   
                    lo.AV_SavingsAmountAmount_AN__c = String.valueOf(lo.AV_SavingsAmountAmount__c);
                    lo.AV_SavingsAmountAmount__c = null;
                    //US XXXX
                    lo.AV_LoanTern_AN__c = lo.AV_LoanTern__c;
					lo.AV_LoanTern__c = null;
                    lo.AV_BuyingPriceCCY_AN__c = lo.AV_BuyingPriceCCY__c;
                    lo.AV_BuyingPriceCCY__c = null;
                    lo.AV_BuyingPriceAmount_AN__c = lo.AV_BuyingPriceAmount__c;
                    lo.AV_BuyingPriceAmount__c = null;
                    lo.AV_LoanAmountCCY_AN__c = lo.AV_LoanAmountCCY__c;
                    lo.AV_LoanAmountCCY__c = null;
                    lo.AV_LoanAmountAmount_AN__c = lo.AV_LoanAmountAmount__c;
                    lo.AV_LoanAmountAmount__c = null;
                    lo.AV_SavingsAmountCCY_AN__c = lo.AV_SavingsAmountCCY__c;
                    lo.AV_SavingsAmountCCY__c = null;
                    //Solo blanquear
                    //lo.AV_CustomerProHolder1__c = null; //Revisar numperso de lead, preguntar Pep si blanquearlo
                    //lo.AV_CustomerProHolder2__c = null;
                    lo.AV_Usage__c = null;
                    lo.AV_Type__c = null;
                    lo.AV_ProvinceCode__c = null;
                    lo.AV_AutonomousCommunityCode__c = null;
                    lo.AV_Country__c = null;
                    lo.AV_StreetType__c = null;
                    lo.AV_StreetName__c = null;
                    lo.AV_BuildingNumber__c = null;
                    lo.AV_StairNumber__c = null;
                    lo.AV_FloorNumber__c = null;
                    lo.AV_ApartmentNumber__c = null;
                    lo.AV_MunicipalityCode__c = null;
                    lo.AV_Lead__c = null;
                    lo.AV_Lead2__c = null;

                    
                    //Informar Fecha Cierre Gestión cuando se blanquea el LeadOportunidad
                    lo.AV_FechaCierreGestion__c = Date.today();
                   
                    leadOpportunitiesToUpdate.add(lo);
                }
            }

            
            List<Lead> leadsList = [SELECT FirstName, LastName, AV_CustomerId__c, AV_Birthdate__c, Name, AV_CustomerType__c,
                                Email, MobilePhone, AV_PhonePrefix__c
                                FROM Lead
                                WHERE Id in:leadsIds];
            
            for(Lead l : leadsList){
                l.AV_CustomerId_AN__c = l.AV_CustomerId__c;
                l.AV_CustomerId__c = null;
                l.AV_Birthdate_AN__c = l.AV_Birthdate__c;
                l.AV_Birthdate__c = null; 
                l.AV_Name_AN__c = l.Name;
                //l.Name = null; No hace falta, se autocalcula
                l.AV_CustomerType_AN__c = l.AV_CustomerType__c;
                l.AV_CustomerType__c = null;
                l.AV_Email_AN__c = l.Email;
                l.Email = null;
                l.AV_FirstName_AN__c = l.FirstName;
                l.FirstName = null;
                l.AV_LastName_AN__c = l.LastName;
                l.LastName = '-';
                l.AV_MobilePhone_AN__c = l.MobilePhone;
                l.MobilePhone = null;
                l.AV_PhonePrefix_AN__c = l.AV_PhonePrefix__c;
                l.AV_PhonePrefix__c = null;
                l.AV_numperso__c = null;
                leadsToUpdate.add(l);
            }

            recordsProcessed = recordsProcessed + leadsToUpdate.size();

            if (!leadOpportunitiesToUpdate.isEmpty()) {
                AV_LogDebug.printLogDebug(methodName,'Leads Opportunities for update: ' + leadOpportunitiesToUpdate.size());
                List<Database.SaveResult> listUpdateResult=database.update(leadOpportunitiesToUpdate);
                AV_AppUtilities.displayErrors(methodName,listUpdateResult);
            }

            if (!leadsToUpdate.isEmpty()) {
                AV_LogDebug.printLogDebug(methodName,'Leads for update: ' + leadsToUpdate.size());
                List<Database.SaveResult> listUpdateResult=database.update(leadsToUpdate);
                AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
            }
        }catch(System.Exception e){
            AV_LogDebug.printException(methodName, e);
        }
    }


    /**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
    public void finish(Database.BatchableContext bc){
        //execute any post-processing operations
        String methodName='finish';
        AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
    }
}