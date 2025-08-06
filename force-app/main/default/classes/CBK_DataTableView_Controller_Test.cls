@isTest 
private class CBK_DataTableView_Controller_Test {

	@isTest
	private static void testName() {
		List<Task> lstTsk = createObjects();
		Test.startTest();
		string query = 'SELECT Subject, Status, CreatedDate, Who.Name FROM Task WHERE WhoId = \'@RecordId\'';
		CBK_DataTableView_Controller.retriveRecords(query,lstTsk[0].Id);
		Test.stopTest();
	}

	public static List<Task> createObjects()
	{
		String sRecordTypeCt = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Contact ct = new Contact();
		ct.RecordTypeId = sRecordTypeCt;
		ct.FirstName = 'TestA';
		ct.LastName = 'TestA';
		insert ct;

		List<Task> Lstreturn = new List<Task>();
		String sRecordTypeTsk = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
		Task tk =  new Task();
		tk.RecordTypeId = sRecordTypeTsk;
		tk.Subject = 'Otros';
		tk.Status = 'Open';
		tk.Priority = 'Normal';
		tk.WhoId = ct.Id;
		Lstreturn.add (tk);
		insert Lstreturn;
		
		return Lstreturn;
	}
}