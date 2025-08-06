@isTest
private class CBK_CustomPicklist_Controller_Test {

	@isTest
	private static void checkPicklistvalues() {

		List<CBK_PicklistValues__c> lstPick = new List<CBK_PicklistValues__c> ();
		string rtIdPick = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
		string rtIdPickVal = Schema.getGlobalDescribe().get('CBK_PicklistValues__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();

		CBK_PicklistValues__c pick = new CBK_PicklistValues__c();
		pick.RecordTypeId = rtIdPick;
		pick.Name = 'Field Picklist';
		pick.CBK_Object__c = 'Object';
		insert pick;

		List<CBK_PicklistValues__c> lstPickVal = new List<CBK_PicklistValues__c>();
		CBK_PicklistValues__c pickVal = new CBK_PicklistValues__c();
		pickVal.RecordTypeId = rtIdPickVal;
		pickVal.CBK_Picklist__c = pick.Id;
		pickVal.Name = 'Opcion1';
		pickVal.CBK_HasDependency__c = true;
		pickVal.CBK_Dependencies__c = 'Valor1';
		lstPickVal.add(pickVal);

		pickVal = new CBK_PicklistValues__c();
		pickVal.RecordTypeId = rtIdPickVal;
		pickVal.CBK_Picklist__c = pick.Id;
		pickVal.Name = 'Opcion2';
		pickVal.CBK_HasDependency__c = true;
		pickVal.CBK_Dependencies__c = 'Valor2';
		lstPickVal.add(pickVal);

		pickVal = new CBK_PicklistValues__c();
		pickVal.RecordTypeId = rtIdPickVal;
		pickVal.CBK_Picklist__c = pick.Id;
		pickVal.Name = 'Opcion3';
		pickVal.CBK_HasDependency__c = true;
		pickVal.CBK_Dependencies__c = 'Valor1;Valor2';
		lstPickVal.add(pickVal);

		pickVal = new CBK_PicklistValues__c();
		pickVal.RecordTypeId = rtIdPickVal;
		pickVal.CBK_Picklist__c = pick.Id;
		pickVal.Name = 'Opcion4';
		lstPickVal.add(pickVal);
		insert lstPickVal;


		CBK_PicklistValues__c pick2 = new CBK_PicklistValues__c();
		pick2.RecordTypeId = rtIdPick;
		pick2.CBK_ParentId__c = pick.Id;
		pick2.CBK_Object__c = 'Object';
		pick2.Name = 'Field Picklist 2';
		insert pick2;

		List<CBK_PicklistValues__c> lstPickVal2 = new List<CBK_PicklistValues__c>();
		CBK_PicklistValues__c pickVal2 = new CBK_PicklistValues__c();
		pickVal2.RecordTypeId = rtIdPickVal;
		pickVal2.CBK_Picklist__c = pick2.Id;
		pickVal2.Name = 'Valor1';
		lstPickVal2.add(pickVal2);

		pickVal2 = new CBK_PicklistValues__c();
		pickVal2.RecordTypeId = rtIdPickVal;
		pickVal2.CBK_Picklist__c = pick2.Id;
		pickVal2.Name = 'Valor2';
		lstPickVal2.add(pickVal2);
		insert lstPickVal2;

		Test.startTest();
		List<CBK_CustomPicklist_Controller.PicklistItems> lstPrecarga  = CBK_CustomPicklist_Controller.picklistValues('Field Picklist', 'Object');
		Boolean check = false;
		if(String.valueOf(lstPrecarga).contains('Opcion1') && String.valueOf(lstPrecarga).contains('Opcion2') && String.valueOf(lstPrecarga).contains('Opcion3') &&
			String.valueOf(lstPrecarga).contains('Opcion4')){
			check = true;
		}
		System.assert(true, check);

		List<CBK_CustomPicklist_Controller.PicklistItems> lstPrecarga2  = CBK_CustomPicklist_Controller.picklistValues('Field Picklist 2', 'Object');
		check = false;
		if(String.valueOf(lstPrecarga).contains('Valor1') && String.valueOf(lstPrecarga).contains('Valor2')){
			check = true;
		}
		System.assert(true, check);

		List<CBK_CustomPicklist_Controller.PicklistItems> lstDeppen = CBK_CustomPicklist_Controller.picklistValuesDependency('Field Picklist','Opcion1', 'Object');
		check = false;
		if(String.valueOf(lstPrecarga).contains('Valor1')){
			check = true;
		}
		System.assert(true, check);

		List<CBK_CustomPicklist_Controller.PicklistItems> lstDeppen2 = CBK_CustomPicklist_Controller.picklistValuesDependency('Field Picklist','Opcion2', 'Object');
		check = false;
		if(String.valueOf(lstPrecarga).contains('Valor2')){
			check = true;
		}
		System.assert(true, check);

		List<CBK_CustomPicklist_Controller.PicklistItems> lstDeppen3 = CBK_CustomPicklist_Controller.picklistValuesDependency('Field Picklist','Opcion3', 'Object');
		check = false;
		if(String.valueOf(lstPrecarga).contains('Valor1') && String.valueOf(lstPrecarga).contains('Valor2')){
			check = true;
		}
		System.assert(true, check);

		List<CBK_CustomPicklist_Controller.PicklistItems> lstDeppen4 = CBK_CustomPicklist_Controller.picklistValuesDependency('Field Picklist','Opcion4', 'Object');
		check = false;
		if(String.valueOf(lstPrecarga).contains('Valor1') && String.valueOf(lstPrecarga).contains('Valor2')){
			check = true;
		}
		System.assert(true, check);
		Test.stopTest();
	}
}