public with sharing class GRR_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        List<EmailMessage> correosGRR = GRR_EmailMessageTriggerHelper.filtrarcorreosGRR(listNewObj);
        if (!correosGRR.isEmpty()) {
            GRR_EmailMessageTriggerHelper.validarBuzonSalida(correosGRR);
            GRR_EmailMessageTriggerHelper.comprobarAnexosPermitidos(correosGRR, mapNewObj);
            GRR_EmailMessageTriggerHelper.switchProcedencia(correosGRR);
        }
	}
}