global class CBK_Mask_Case_Batch implements Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    
    global String limitValue;
    global Boolean procesarModulo;
    global Integer remainderModulo;
    global Integer divisorModulo;

    global CBK_Mask_Case_Batch(String limitQuery) {
        this.limitValue = limitQuery;
        this.procesarModulo = false;
    }
    global CBK_Mask_Case_Batch() {
        this.procesarModulo = false;
    }     
       
    global CBK_Mask_Case_Batch(String limitQuery,Integer intRemainder,Integer intDivisor) {
        this.limitValue = limitQuery;
        this.procesarModulo = true;
        this.remainderModulo = intRemainder;
        this.divisorModulo = intDivisor;
    } 
    
    global CBK_Mask_Case_Batch(Integer intRemainder,Integer intDivisor) {
        this.procesarModulo = true;
        this.remainderModulo = intRemainder;
        this.divisorModulo = intDivisor;
    } 
        
    /**
    * @param bc  Database.BatchableContext param that contains the batch job ID
    */	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, CC_MailTelfNotif__c FROM Case';
        if(String.isNotBlank(limitValue)){
            query += ' LIMIT ' + limitValue; 
        }        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> listCases){
        try{
            List<Case> listCasesToUpdate = new List<Case>();
            recordsProcessed = listCases.size();
            for(Case casoProcesado : listCases){
                if (casoProcesado != null && (!procesarModulo 
                    || (procesarModulo && CBK_MaskUtilities.checkCharMod(string.ValueOf(casoProcesado.Id).right(1),remainderModulo,divisorModulo)) )){
                    if(casoProcesado.CC_MailTelfNotif__c != null && casoProcesado.CC_MailTelfNotif__c != ''){      
                        casoProcesado.CC_MailTelfNotif__c = null;
                        listCasesToUpdate.add(casoProcesado);
                    }
                }
            }           
            if(!listCasesToUpdate.isEmpty()){
                Database.update(listCasesToUpdate);
                List<Database.SaveResult> results =Database.update(listCasesToUpdate, false);
                List<Object> errores = new List<Object>();
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        errores.addAll(result.getErrors());
                    }
                }
                if (errores.size()>0){
                    CBK_Log.error('Error Mask Batch','Error batch update cases.' , errores);
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