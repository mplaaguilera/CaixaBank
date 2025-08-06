public with sharing class CSBD_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) { 
        List<EmailMessage> correosCsbd = CSBD_EmailMessage.descartarCorreosNoCsbd(listNewObj);
        informarIdOportunidadCorreosSalientes(correosCsbd);
	}

    private void informarIdOportunidadCorreosSalientes(List<EmailMessage> correosCsbd) {
        for (EmailMessage correo : correosCsbd) {
            if (!correo.Incoming) {
                correo.CC_Aplicacion__c = 'CSBD';
                correo.CSBD_Oportunidad_Id__c = correo.RelatedToId;
            }
        }
    }
}