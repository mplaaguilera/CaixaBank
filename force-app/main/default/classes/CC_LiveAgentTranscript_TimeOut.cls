public with sharing class CC_LiveAgentTranscript_TimeOut {
    @AuraEnabled(cacheable=true)
    public static Boolean cerradoPorTimeOut(String idChat) {
        Boolean bCerrado = false;
        if (idChat != '')
        {
            List<LiveChatTranscript> oCons = [SELECT CC_Cerrado_TimeOut__c FROM LiveChatTranscript WHERE Id=: idChat];
            if (oCons.size() == 1)
            {
                bCerrado = oCons[0].CC_Cerrado_TimeOut__c;
            }
        }
        return bCerrado;
    }
}