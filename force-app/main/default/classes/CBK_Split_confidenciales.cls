public class CBK_Split_confidenciales implements Callable {
     /**
     * Dynamically called static method.
     */
    public static boolean fision(CBK_Fusion__c fus) {
        string resultado='Registro fisionado correctamente';
        string idPri = fus.Id_Principal__c;
        
        Account principal = [Select Id,AV_NumPerso__c,CC_NumPerso__c from Account where Id=:idPri];
        String numPersoCC = principal.CC_NumPerso__c;
        String numPersoAV = principal.AV_NumPerso__c;
        
        if (string.IsNotBlank(numPersoCC)){
            principal.CC_NumPerso__c='';
            Update principal;

            //Limpieza del CC_NumPerso__c al cliente de AV
            list<Contact> lstCon = [Select Id,CC_NumPerso__c from Contact where CC_NumPerso__c=:numPersoCC]; 
            if (lstCon.size()>0){
                lstCon[0].CC_NumPerso__c='';
            }
            Update lstCon;
        }
        
        // Crear cuenta confidencial.
        Account oAccount = new Account();
        oAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        oAccount.Name = 'CONFIDENCIAL';
        oAccount.CC_NumPerso__c = numPersoAV;
        oAccount.CC_Confidencial__c = true;
        oAccount.AV_NumPerso__c = null;
        insert oAccount;

        Contact oContact = new Contact();
        oContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        oContact.FirstName = '';
        oContact.LastName = 'CONFIDENCIAL';
        oContact.AccountId = oAccount.Id;
        oContact.CC_NumPerso__c = numPersoAV;
        oContact.CC_Confidencial__c = true;
 
        insert oContact;
              
        fus.ID_Secundario__c = oAccount.Id;
        
        //MOVER CASOS/TAREAS CC AL CONFIDENCIAL
        list<Case> lstCases = [Select Id,AccountId,ContactId from Case where AccountId = :idPri];
        for (Case c : lstCases){
            c.AccountId = oAccount.Id;
            c.ContactId = oContact.Id;                
        }
        update lstCases;
        
        fus.resultado__c=resultado;
        
        return true;
    }
    
    /**
     * Callable::call() implementation, calling static function (completeTask, rather than this.completeTask)
     */
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'exec' {
                return fision((CBK_Fusion__c)args.get('reg'));
            }
            when else {
                throw new CalloutException('Method not implemented');
            }
        }
    }    

    
}