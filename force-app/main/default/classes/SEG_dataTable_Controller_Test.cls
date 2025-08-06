@isTest
public class SEG_dataTable_Controller_Test {

	@isTest
	public static void test_GetAccount()
	{
		Account centro = new Account();
		centro.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		centro.Name = 'Oficina 00001';
		centro.CC_Numero_Oficina_Empresa__c = '001-00001';
		centro.SEG_Organizacion__c = 'Banca Corporativa';
		centro.SEG_Zona__c = 'Corporativa';
		insert centro;

		List<SObject> res = SEG_dataTable_Controller.retriveRecords('Select Id, Name From Account Where Id = \'@RecordId\'', centro.Id);
		List<Account> lstAcc = (List<Account>) res;
		System.assertEquals(centro.Id,res[0].Id);

	}
}