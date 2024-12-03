public with sharing class CC_Informar_Canal_Empleado {
 	@InvocableMethod(label='CC_Informa_CanalEmpleado' description='Informa el Canal del Empleado según lo que venga en el Chat Transcript')
    public static void informaCanalEmpleado(List<Id> chatId) {
        List<Case> listCase = new List<Case>();
        
        List<LiveChatTranscript > listaChat = [SELECT Id, CC_Tipo__c, CaseId, Case.RecordType.DeveloperName FROM LiveChatTranscript WHERE Id IN : chatId];
        
        if(!listaChat.isEmpty()){
            for (LiveChatTranscript listado : listaChat){
                
                Case casoUpd = new Case();
                if (listado.CC_Tipo__c == 'Hidden'){
                    casoUpd.Id = listado.CaseId;
                    casoUpd.Canal_del_Empleado__c = 'Hidden';
                    listCase.add(casoUpd);
                }else if(listado.CaseId != null && listado.Case.RecordType.DeveloperName == 'CC_CSI_Bankia') {
                    casoUpd.Id = listado.CaseId;
                    casoUpd.Canal_del_Empleado__c = 'CSI';
                    listCase.add(casoUpd);
                }else{
                    casoUpd.Id = listado.CaseId;
                    casoUpd.Canal_del_Empleado__c = 'Agente';
                    listCase.add(casoUpd);
                }
            }
        }
        // Update
        if (listCase.size() > 0){
            Database.SaveResult[] oResCom = Database.update(listCase, false);
        }
    }
}