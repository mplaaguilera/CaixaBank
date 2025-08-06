global class CBK_Mask_Contact_Batch implements Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global String limitValue;
    global Boolean procesarModulo;
    global Integer remainderModulo;
    global Integer divisorModulo;

    global Map<String, String> range;
    
    global CBK_Mask_Contact_Batch(String limitQuery) {
        this.limitValue = limitQuery;
        this.procesarModulo = false;
    }
    global CBK_Mask_Contact_Batch(String limitQuery,Integer intRemainder,Integer intDivisor) {
        this.limitValue = limitQuery;
        this.procesarModulo = true;
        this.remainderModulo = intRemainder;
        this.divisorModulo = intDivisor;
    } 
    global CBK_Mask_Contact_Batch() {
        this.procesarModulo = false;
    }     
    global CBK_Mask_Contact_Batch(Map<String, String> rangeBatch) {
        this.range = rangeBatch;
        this.procesarModulo = false;
    } 
    global CBK_Mask_Contact_Batch(Map<String, String> rangeBatch,Integer intRemainder,Integer intDivisor) {
        this.range = rangeBatch;
        this.procesarModulo = true;
        this.remainderModulo = intRemainder;
        this.divisorModulo = intDivisor;
    } 
    
    /**
    * Create a list of Account that the recordtype is CC_contactoPA
    * @param bc  Database.BatchableContext param that contains the batch job ID
    */	
        global Database.QueryLocator start(Database.BatchableContext bc) {
            String query = 'SELECT Id, Description, Email, FirstName, LastName, '+
                +'MobilePhone, OtherPhone, AssistantPhone, HomePhone, Phone, IsPersonAccount FROM Contact';
            if (range != null){
                query += ' WHERE id>= \''+ range.get('first') +'\' and id<=  \''+range.get('last') +'\'';
            }
            if(String.isNotBlank(limitValue)){
                query += ' LIMIT ' + limitValue; 
            }
            system.debug('query: '+query);
            return Database.getQueryLocator(query);
        }
        global void execute(Database.BatchableContext bc, List<Contact> listContacts){
            try{
                List<Contact> lstContactsToUpdate = new List<Contact>();
                recordsProcessed += listContacts.size();
               for(Contact contacto : listContacts){
                   if(contacto != null && !contacto.IsPersonAccount && (!procesarModulo || (procesarModulo && CBK_MaskUtilities.checkCharMod(string.ValueOf(contacto.Id).right(1),remainderModulo,divisorModulo)) )){
                       contacto.Description = CBK_MaskUtilities.generarTexto();
                       contacto.Email = CBK_MaskUtilities.generarCorreoElectronico();
                       contacto.FirstName = CBK_MaskUtilities.generarNombre();
                       contacto.LastName = CBK_MaskUtilities.generarApellidos();
                       contacto.MobilePhone = CBK_MaskUtilities.generarNumeroTelefono(true);
                       String strTelfijo = CBK_MaskUtilities.generarNumeroTelefono(false);
                       contacto.AssistantPhone = strTelfijo;
                       contacto.HomePhone = strTelfijo;
                       contacto.OtherPhone = strTelfijo;
                       contacto.Phone = strTelfijo;
                       lstContactsToUpdate.add(contacto);
                   }
                }        
                if(!lstContactsToUpdate.isEmpty()){
                    List<Database.SaveResult> results =Database.update(lstContactsToUpdate, false);
                    List<Object> errores = new List<Object>();
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            errores.addAll(result.getErrors());
                        }
                    }
                    if (errores.size()>0){
                        CBK_Log.error('Error Mask Batch','Error batch update contacts.',errores);
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