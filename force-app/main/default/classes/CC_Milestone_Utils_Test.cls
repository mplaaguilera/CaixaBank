@isTest
private class CC_Milestone_Utils_Test {

    @isTest
    static void testCompletarMilestonesCaso(){
        
        List<SlaProcess> listaSlaProc = [SELECT Id FROM SlaProcess WHERE Name = 'Call Center Clientes'];

        if (!listaSlaProc.isEmpty()) {
            //Crear datos de prueba
            Account newAccount = new Account();
            newAccount.Name = 'Account para probar funcionalidad de Milestones';
            insert newAccount;

            Entitlement newEntitlement = new Entitlement();
            newEntitlement.Name = 'Entitlement para probar funcionalidad de Milestones';
            newEntitlement.Type = 'Web Support';
            newEntitlement.SlaProcessId = listaSlaProc[0].Id;
            newEntitlement.AccountId = newAccount.Id; //Se necesita Account dummy ya que es requerido
            newEntitlement.StartDate = system.today();
            insert newEntitlement;

            Case newCase = new Case();
            newCase.Subject = 'Caso para probar funcionalidad de Milestones';
            insert newCase;
            
            newCase.Status = 'New';
            update newCase;
            
            newCase.EntitlementId = newEntitlement.Id;
            update newCase;

            List<Id> caseIds = new List<Id>();
            caseIds.add(newCase.Id);

            //Ejecutar cierre de milestones
            test.startTest();
            
            CC_Milestone_Utils.completarMilestonesCaso(caseIds, system.now().addHours(-1));
            
            test.stopTest();

            //Comprobar que el caso ya no tiene Milestones no completados
            List<CaseMilestone> cms = [SELECT Id FROM CaseMilestone
                                        WHERE caseId in :caseIds AND completionDate = null];

            System.assert(cms.isEmpty());
        }
    }
}