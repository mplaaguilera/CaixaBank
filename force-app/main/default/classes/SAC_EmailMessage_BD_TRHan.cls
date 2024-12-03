public with sharing class SAC_EmailMessage_BD_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EmailMessage>)tp.oldList);
    }
    private void process(List<EmailMessage> oldList){
        CBK_log.debug('Handler SAC - SAC_EmailMessage_BD_TRHan');
        preventEmailDeletion(oldList);
    }
    public static void preventEmailDeletion(List<EmailMessage> oldList) {
        for(EmailMessage em: oldList){
            em.addError('No es posible eliminar el email.');
        }
    }
}