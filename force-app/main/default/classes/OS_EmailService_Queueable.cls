public with sharing class OS_EmailService_Queueable implements Queueable{


    public Messaging.InboundEmail emailQueue = new Messaging.InboundEmail();
    public Messaging.InboundEnvelope envelopeQueue = new Messaging.InboundEnvelope();
    public Map<String, Integer> reintentos = new Map<String, Integer>();

    public OS_EmailService_Queueable(OS_EmailService.WrapperValoresEmail envioEmailQueueable) {
        this.emailQueue = envioEmailQueueable.emailQueue;
        this.envelopeQueue = envioEmailQueueable.envelopeQueue;
        this.reintentos = envioEmailQueueable.reintentosMap;
    }

    public void execute(QueueableContext context){
        String emailId = String.valueof(emailQueue.messageId);
        if(reintentos.containsKey(emailId) && reintentos.get(emailId) < 5){
            Integer addReintento = reintentos.get(emailId)+1;
            reintentos.put(String.valueOf(emailQueue.messageId), addReintento);
            OS_EmailService emailServiceCOPS = new OS_EmailService();
            emailServiceCOPS.procesarCorreoEntrante(emailQueue, envelopeQueue, reintentos);
        } else{
            reintentos.put(String.valueOf(emailQueue.messageId), 1);
            OS_EmailService emailServiceCOPS = new OS_EmailService();
            emailServiceCOPS.procesarCorreoEntrante(emailQueue, envelopeQueue, reintentos);
        }
    }
}