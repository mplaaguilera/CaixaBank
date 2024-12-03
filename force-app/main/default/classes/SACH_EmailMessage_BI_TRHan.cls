public with sharing class SACH_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {
    private static String handlerClass = 'SACH_EmailMessage_BI_TRHan';
    private static String vEventType = 'beforeInsert';
    
    public override void mainEntry(CC_TriggerParameters tp) {
        
        List<SObject> lstSO = SACH_EmailMessageTriggerHelper.filterEmailsHandlers(tp,handlerClass, vEventType);
        tp.newList = lstSO.size() > 0 ? lstSO : tp.newList;
        process((List<EmailMessage>) tp.newList);

    }
    
    private static void process(List<EmailMessage> listNewObj) { 

        List<EmailMessage> correosSACH = SACH_EmailMessageTriggerHelper.filtrarCorreosSACH(listNewObj);

        if(!correosSACH.isEmpty()){
            SACH_EmailMessageTriggerHelper.validarCorreo(correosSACH);
            SACH_EmailMessageTriggerHelper.informarInterno(correosSACH);
            SACH_EmailMessageTriggerHelper.informarOperativa(correosSACH);
            SACH_EmailMessageTriggerHelper.comprobarContactos(correosSACH);
        }
        
    }

}