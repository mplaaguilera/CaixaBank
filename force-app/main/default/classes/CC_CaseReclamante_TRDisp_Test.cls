@isTest
private class CC_CaseReclamante_TRDisp_Test {

	@TestSetup
	static void makeData() {
		SAC_CaseReclamante__c re = new SAC_CaseReclamante__c();
		re.SAC_ReclamantePrincipal__c = false;
		insert re;
	}

	@isTest
	private static void testName() {
		createObjects();
		deleteObjects();
		updateObjects();
	}

	public static void createObjects()
	{
		SAC_CaseReclamante__c casoReclamante = new SAC_CaseReclamante__c();
		casoReclamante.SAC_ReclamantePrincipal__c = true;
		insert casoReclamante;
	}
	public static void deleteObjects()
	{
		SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c LIMIT 1];
		delete caseRecl;
	}
	public static void updateObjects()
	{
		SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c LIMIT 1];
		caseRecl.SAC_ReclamantePrincipal__c = true;
		update caseRecl;
	}
}