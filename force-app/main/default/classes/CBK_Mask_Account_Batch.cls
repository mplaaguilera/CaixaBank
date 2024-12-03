global class CBK_Mask_Account_Batch implements Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global static final String AV_PARTICULAR = 'CC_ClientePA';
    
    global String limitValue;
    global Boolean procesarModulo;
    global Integer remainderModulo;
    global Integer divisorModulo;

    global CBK_Mask_Account_Batch(String limitQuery) {
        this.limitValue = limitQuery;
        this.procesarModulo = false;
    }
    global CBK_Mask_Account_Batch() {
        this.procesarModulo = false;
    }     
       
    global CBK_Mask_Account_Batch(String limitQuery,Integer intRemainder,Integer intDivisor) {
        this.limitValue = limitQuery;
        this.procesarModulo = true;
        this.remainderModulo = intRemainder;
        this.divisorModulo = intDivisor;
    } 
    
    global CBK_Mask_Account_Batch(Integer intRemainder,Integer intDivisor) {
        this.procesarModulo = true;
        this.remainderModulo = intRemainder;
        this.divisorModulo = intDivisor;
    } 
        
        /**
    * Create a list of Account that the recordtype is CC_ClientePA
    * @param bc  Database.BatchableContext param that contains the batch job ID
    */	
        global Database.QueryLocator start(Database.BatchableContext bc) {
            String query = 'SELECT Id, RecordtypeId, AV_FechaEnmascaramiento__c, Description, FirstName, '+
                +'LastName, PersonEmail, PersonMobilePhone, CC_Numero_Documento__pc, '+
                +'Phone, AV_RecordToMask__c,BillingStreet, BillingLatitude, BillingLongitude FROM Account';
            if(String.isNotBlank(limitValue)){
                query += ' LIMIT ' + limitValue; 
            }
                
            return Database.getQueryLocator(query);
        }
        global void execute(Database.BatchableContext bc, List<Account> listAccounts){
            try{
                List<Account> listAccountsToUpdate = new List<Account>();
                recordsProcessed = listAccounts.size();
                ID IDRTPersona = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
                ID IDRTCentroCaixaBank = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro CaixaBank').getRecordTypeId();
                for(Account cliente : listAccounts){
                    if (cliente != null && (!procesarModulo 
                        || (procesarModulo && CBK_MaskUtilities.checkCharMod(string.ValueOf(cliente.Id).right(1),remainderModulo,divisorModulo)) )){
						if (cliente.AV_RecordToMask__c){
							if(cliente.RecordTypeId == IDRTPersona){     
                                String strDocumento = CBK_MaskUtilities.generarNif();     
								cliente.CC_Numero_Documento__pc = strDocumento;
                                cliente.CC_Numero_Documento__c = strDocumento;

								String texto = CBK_MaskUtilities.generarTexto();
								cliente.Description = texto;
								cliente.BillingStreet = texto;
								cliente.BillingLatitude = null;
								cliente.BillingLongitude = null;
								String email = CBK_MaskUtilities.generarCorreoElectronico();
								cliente.PersonEmail = email;
								cliente.CC_Email__c = email;
								cliente.FirstName = CBK_MaskUtilities.generarNombre();
								cliente.LastName = CBK_MaskUtilities.generarApellidos();
								cliente.PersonMobilePhone = CBK_MaskUtilities.generarNumeroTelefono(true);
								cliente.AV_FechaEnmascaramiento__c = DATE.TODAY();
								listAccountsToUpdate.add(cliente);
							}
							if(cliente.RecordTypeId == IDRTCentroCaixaBank){          
								cliente.CC_Email__c = CBK_MaskUtilities.generarCorreoElectronico();
								cliente.AV_FechaEnmascaramiento__c = DATE.TODAY();
								listAccountsToUpdate.add(cliente);
							}
						}
					}
                }           
                if(!listAccountsToUpdate.isEmpty()){
                    Database.update(listAccountsToUpdate);
                    List<Database.SaveResult> results =Database.update(listAccountsToUpdate, false);
                    List<Object> errores = new List<Object>();
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            errores.addAll(result.getErrors());
                        }
                    }
                    if (errores.size()>0){
                        CBK_Log.error('Error Mask Batch','Error batch update accounts.' , errores);
                    }
                }
                
            }catch(System.Exception e){
                CBK_Log.error(e);
            }
        }	
	global void finish(Database.BatchableContext bc){
		CBK_Log.debug('Record Processed: ' + recordsProcessed);
	}
	
}