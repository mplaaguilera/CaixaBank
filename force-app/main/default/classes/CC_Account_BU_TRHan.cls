public class CC_Account_BU_TRHan extends CC_TriggerHandlerBase {

    private static Id clienteRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
	private static Id clientePARecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>)tp.oldList, (Map<Id, Account>)tp.oldMap);
	}
    
    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
        List<Account> cuentasTelefonoUnico = new List<Account>();
        encryptNumper(mapOldObj, listNewObj);//Encriptar el Numper en Hexadecimal

        if(FeatureManagement.checkPermission('OS_CP_Responsable')){
            evitarDuplicadosCOPS(listNewObj, mapNewObj, mapOldObj);
        }
        for(Account cuenta : listNewObj) {
			// Cuentas para comprobar si tienen que tener el telefono unico checked
			if (cuenta.RecordTypeId == clienteRecordTypeId || cuenta.RecordTypeId == clientePARecordTypeId) {
				cuentasTelefonoUnico.add(cuenta);
			}
        }

        if (cuentasTelefonoUnico.size() > 0) {
			comprobarTelefonoUnico(cuentasTelefonoUnico);
		}
    }
	
    //Funcion para encryptar el campo Numper en hexadecimal
    private void encryptNumper(Map<Id,Account> mapOldObj, List<Account> listNewObj) {
        for (Account acc : listNewObj) {
            if (!String.isEmpty(acc.CC_NumPerso__c)) {
                if (acc.CC_NumPerso__c != mapOldObj.get(acc.Id).CC_NumPerso__c) {
                    String replaceNumper = acc.CC_NumPerso__c.replaceAll('[^0-9]', '');
                    String encryptedNumper = CC_MetodosUtiles.decimalToHex(decimal.valueOf(replaceNumper));
                    String numperHex = String.valueOf(encryptedNumper).leftPad(8, '0');
                    acc.CC_Numperso_HEX__c = numperHex.touppercase();
                }
            }
        }
    }

    // Si no tiene oficina asociada hay que quitar el check de telefono unico
	public static void comprobarTelefonoUnico(List<Account> centros){
		List<Account> cuentaUpdate = new List<Account>();
        for(Account cuenta : centros)
        {
            if (cuenta.CC_Telefono_Unico__c == true)
            {
                if(String.isBlank(cuenta.CC_OficinaGestoraId__c) || cuenta.CC_OficinaGestoraId__c == null)
                {
                    cuenta.CC_Telefono_Unico__c = false;
                    cuentaUpdate.add(cuenta);
                }
            }
        }
    }
    
    private static void evitarDuplicadosCOPS(List<Account> newContacts, Map<Id, Account> mapIdContacts, Map<Id, Account> mapOldObj){
        if (newContacts.isEmpty()) return;

        Id buzonRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OS_Buzon_Account').getRecordTypeId();

        Set<String> emails = new Set<String>();
        
        if (!newContacts.isEmpty()){
            for (Account contacto : newContacts) {
                if (contacto.recordtypeId == buzonRT && mapOldObj.get(contacto.Id).CC_Email__c != mapIdContacts.get(contacto.Id).CC_Email__c){
                    emails.add(contacto.CC_Email__c);
                  
                }
            }
        }

        if (emails.size() == 0) return;

        List <Account> contactDuplicate = [SELECT CC_Email__c, RecordTypeId FROM Account WHERE CC_Email__c IN :emails AND RecordTypeId = :buzonRT];
        Map<String, List<Id>> mapaEmailRT= new Map<String, List<Id>>();

        if(!contactDuplicate.isEmpty()){
            for(Account contactoDupl : contactDuplicate){
                if(mapaEmailRT.containsKey(contactoDupl.CC_Email__c)){
                    mapaEmailRT.get(contactoDupl.CC_Email__c).add(contactoDupl.RecordTypeId);
                } else {
                    mapaEmailRT.put(contactoDupl.CC_Email__c, new List<Id> {contactoDupl.RecordTypeId});
                }
            }
        }

        //Ahora busco cuáles de los nuevos contactos tienen alguno de los emails repetidos, y sobre esos, lanzo un error.
        for(Account allContacts : newContacts){
            if(mapaEmailRT.keySet().contains(allContacts.CC_Email__c)){
                if(allContacts.RecordTypeId == buzonRT && (mapaEmailRT.get(allContacts.CC_Email__c).contains(buzonRT))){
                    allContacts.addError ('Ya existe una Cuenta con el mismo Email.');
                 
                }
                
            }
        }
        
        
    } 
}