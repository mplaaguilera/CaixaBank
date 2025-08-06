public  without sharing class AV_CheckExistsCustomers_Controller {

    @AuraEnabled
	public static CustomerList getCustomers(String leadId){
		//CustomerList cl = new CustomerList();
		Lead l  = [SELECT Id, AV_CustomerId__c, FirstName, LastName, AV_Birthdate__c FROM Lead WHERE Id = :leadId];
		if (l.AV_Birthdate__c != null &&  l.AV_CustomerId__c != null) {
		String birthdate = String.valueOfGmt(l.AV_Birthdate__c);
		birthdate = birthdate.substring(0,10);
        //Aqui sacar los Accounts
		String avQuery = 'SELECT Id, Name, AV_Financiacion__c, AV_Ingresos__c, AV_AhorroEInversion__c, AV_Rentabilidad__c, PersonMobilePhone, AV_OficinaPrincipal__r.Name, AV_OficinaPrincipal__c, AV_EAPGestor__r.Name, AV_EAPGestor__c  FROM Account WHERE CC_Numero_Documento__c = ' + '\''+l.AV_CustomerId__c+'\' AND PersonBirthdate = '+birthdate; 
			return new CustomerList((List<Account>) Database.query(avQuery));
		}
		return null;
	}

	public class CustomerList {
		@AuraEnabled
		public List<SObject> recordList;

		public CustomerList(List<SObject> recordList) {
			this.recordList = recordList;
		}

		public void add(CustomerList ol) {
			this.recordList.addAll(ol.recordList);
		}
	}
}