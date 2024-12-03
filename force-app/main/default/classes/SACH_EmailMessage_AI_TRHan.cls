public with sharing class SACH_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        List<EmailMessage> correosSACH = SACH_EmailMessageTriggerHelper.filtrarcorreosSACH(listNewObj);
        if (!correosSACH.isEmpty()) {
            SACH_EmailMessageTriggerHelper.validarBuzonSalida(correosSACH);
            SACH_EmailMessageTriggerHelper.comprobarAnexosPermitidos(correosSACH, mapNewObj);
            SACH_EmailMessageTriggerHelper.switchProcedencia(correosSACH);
        }
	}
}