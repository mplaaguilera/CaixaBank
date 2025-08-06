public class CC_Informar_DG_DAN_Caso {
    @InvocableMethod(label='CC_Informa_DAN_DG' description='Informa DAN y DG')
    public static void informaDANDG(List<Id> caseID) {
        List<Case> listCase = new List<Case>();
        
        List<Case > listaCase = [SELECT Id, AccountId, Account.CC_OficinaGestoraId__c, Account.CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c,
                                 Account.CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId FROM Case WHERE Id IN : caseID];
        
        if(!listaCase.isEmpty()){
            for (Case Listado : listaCase){
                if (Listado.Account.CC_OficinaGestoraId__c != null ){
                    Case casoUpd = new Case();
                    casoUpd.Id = Listado.Id;
                    if (Listado.Account.CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c != null){
                        casoUpd.CC_DAN__c = Listado.Account.CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c;                        
                    } 
                    if (Listado.Account.CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId != null){
                        casoUpd.CC_DG__c = Listado.Account.CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId;
                        
                    }
                    if (casoUpd.CC_DAN__c != null || casoUpd.CC_DG__c != null){
                        listCase.add(casoUpd);
                    }
                }                
            }
        }
        // Update
        if (listCase.size() > 0){
            Database.SaveResult[] oResCom = Database.update(listCase, false);
        }
    }
}