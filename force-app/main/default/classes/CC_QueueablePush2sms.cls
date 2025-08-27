public with sharing class CC_QueueablePush2sms implements Queueable, Database.AllowsCallouts{
    Case caso = new Case();

    public CC_QueueablePush2sms(Case casoC) {
        caso = casoC;
    }

    public void execute(QueueableContext context) {
        CC_Settings__c configPlantillas = CC_Settings__c.getValues('CC_RespuestaArgosPushSMS');
        String namePlantilla = configPlantillas.CC_Configuracion_1__c;

        String resultado = CC_WS_PushSMS.enviarNotificacionPush(caso.Id, namePlantilla);
        if (resultado == 'OK') {
            //Cerrar caso
            caso.Status = 'Cerrado';
            caso.CC_Admin__c = true; //Check para hacer bypass a la validation rule que no permite cerrar el caso cuando esta en pendiente colaborador.
            update caso;
            //Quitar check
            Case casoCheck = new Case();
            casoCheck.Id = caso.Id;
            casoCheck.CC_Admin__c = false;
            update casoCheck;
        }
    }
}