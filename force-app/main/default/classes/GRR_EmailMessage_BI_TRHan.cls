public with sharing class GRR_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {
    private static String handlerClass = 'GRR_EmailMessage_BI_TRHan';
    private static String vEventType = 'beforeInsert';
    
    public override void mainEntry(CC_TriggerParameters tp) {
        
        List<SObject> lstSO = GRR_EmailMessageTriggerHelper.filterEmailsHandlers(tp,handlerClass, vEventType);
        tp.newList = lstSO.size() > 0 ? lstSO : tp.newList;
        process((List<EmailMessage>) tp.newList);

    }
    
    private static void process(List<EmailMessage> listNewObj) { 

        List<EmailMessage> correosGRR = GRR_EmailMessageTriggerHelper.filtrarCorreosGRR(listNewObj);

        if(!correosGRR.isEmpty()){
            GRR_EmailMessageTriggerHelper.validarCorreo(correosGRR);
            GRR_EmailMessageTriggerHelper.informarInterno(correosGRR); 
            GRR_EmailMessageTriggerHelper.informarOperativa(correosGRR);
            GRR_EmailMessageTriggerHelper.comprobarContactos(correosGRR);
        }
        
    }

}