public with sharing class CC_Account_BI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap);
	}

    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj) {
        encryptNumper(listNewObj); //Funcion para encryptar el campo NumPerso en hexadecimal
        if(FeatureManagement.checkPermission('OS_CP_Responsable')){
            evitarDuplicadosCOPS(listNewObj, mapNewObj);
        }
	}
    
    //Funcion para encryptar el campo NumPerso en hexadecimal
    private void encryptNumper(List<Account> listNewObj) {
        
        for (Account acc : listNewObj) {
            // Campo "Numperso"
            if (!String.isEmpty(acc.CC_NumPerso__c)) {
                if (String.isEmpty(acc.CC_Numperso_HEX__c)){
                	String replaceNumper = acc.CC_NumPerso__c.replaceAll('[^0-9]', '');
                	String encryptedNumper = CC_MetodosUtiles.decimalToHex(decimal.valueOf(replaceNumper));
                    String numperHex = String.valueOf(encryptedNumper).leftPad(8, '0');
                    acc.CC_Numperso_HEX__c = numperHex.touppercase();                    
                }
            }
        }
    }
    
    private static void evitarDuplicadosCOPS(List<Account> newAccounts, Map<Id, Account> mapIdContacts){
        if (newAccounts.isEmpty()) return;

        Id buzonRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Account').getRecordTypeId();
        Set<Id> idCAM = new Set<Id> {buzonRT};

        Set<String> emails = new Set<String>();
        

        for(Account cuenta : newAccounts){
            if(cuenta.RecordTypeId == buzonRT && String.isNotBlank(cuenta.CC_Email__c))
            	emails.add(cuenta.CC_Email__c);
        }
        if (emails.size() == 0) return;

        List <Account> accountDuplicate = [SELECT CC_Email__c, RecordTypeId FROM Account WHERE CC_Email__c IN :emails AND RecordTypeId IN :idCAM];
        Map<String, List<Id>> mapaEmailRT= new Map<String, List<Id>>();

        if(!accountDuplicate.isEmpty()){
            for(Account cuentaDupl : accountDuplicate){
                if(mapaEmailRT.containsKey(cuentaDupl.CC_Email__c)){
                    mapaEmailRT.get(cuentaDupl.CC_Email__c).add(cuentaDupl.RecordTypeId);
                } else {
                    mapaEmailRT.put(cuentaDupl.CC_Email__c, new List<Id> {cuentaDupl.RecordTypeId});
                }
            }
        }

        //Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos, y sobre esos, lanzo un error.
        for(Account allAccounts : newAccounts){
            if(mapaEmailRT.keySet().contains(allAccounts.CC_Email__c)){
                if(allAccounts.RecordTypeId == buzonRT && (mapaEmailRT.get(allAccounts.CC_Email__c).contains(buzonRT))){
                    allAccounts.addError ('Ya existe una Cuenta con el mismo Email.');
                 
                }
                
            }
        }
        
        
    } 
}