global class CC_Reversion_ImaginHex_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global CC_Reversion_ImaginHex_Batch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, AccountId, Account.CC_Numperso__c, Account.CC_Numperso_HEX__c FROM Case WHERE CC_Estado_Reversion__c = \'Pendiente envío\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Account> oUpdAcc = new List<Account>();
        //Vamos a informar el campo numperso hexadecimal para aquellos casos en los que no se haya actualizado la cuenta antes de que se realice el envío
        for (Case oCaso : scope) {
            // Campo "Numperso"
            if (!String.isEmpty(oCaso.Account.CC_NumPerso__c)) {
                if (String.isEmpty(oCaso.Account.CC_Numperso_HEX__c)){
                    Account oAccount = new Account();
                    oAccount.Id = oCaso.AccountId;
                	String replaceNumper = oCaso.Account.CC_NumPerso__c.replaceAll('[^0-9]', '');
                	String encryptedNumper = CC_MetodosUtiles.decimalToHex(decimal.valueOf(replaceNumper));
                    String numperHex = String.valueOf(encryptedNumper).leftPad(8, '0');
                    oAccount.CC_Numperso_HEX__c = numperHex.touppercase();
                    oUpdAcc.add(oAccount);
                }
            }
        }
        
        Set<Account> myset = new Set<Account>();
        List<Account> result = new List<Account>();
        myset.addAll(oUpdAcc);
        result.addAll(myset);
        if (result.size() > 0){
            Database.SaveResult[] oResult = Database.update(result, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
            //Si el metadato está activo o no hay registro se planifica con el framework	
        	List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_Reversion_ImaginHex_Batch' and Activo__c=false LIMIT 1];
            if (oConf.isEmpty()){
                //CBK_BatchJob.executeBatch('CC_Reversion_ImaginHex_Batch',1);
                //Se planifica con el framework
            } else {
                String scheduleName = 'CC_Reversion_Imagin_HEX ';
                if(!Test.isRunningTest()){
                    CC_Reversion_ImaginHex_Schedule newJob = new CC_Reversion_ImaginHex_Schedule();
                    String dt = DateTime.now().addMinutes(2).format('s m H d M ? y');
                    String CRON_EXP = string.valueOf(dt);
                    System.schedule(scheduleName + dt, CRON_EXP, newJob);        
                }                             
            }        
    }
}