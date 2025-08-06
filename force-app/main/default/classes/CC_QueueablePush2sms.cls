public with sharing class CC_QueueablePush2sms implements Queueable, Database.AllowsCallouts{
    Case caso = new Case();

    public CC_QueueablePush2sms(Case casoC) {
        caso = casoC;
    }

    public void execute(QueueableContext context) {
        CC_Settings__c configPlantillas = CC_Settings__c.getValues('CC_RespuestaArgosPushSMS');
        String namePlantilla = configPlantillas.CC_Configuracion_1__c;
        if (caso.CC_Idioma__c == 'ca') {
            namePlantilla = configPlantillas.CC_Configuracion_2__c;
        } else if (caso.CC_Idioma__c == 'en') {
            namePlantilla = configPlantillas.CC_Configuracion_3__c;
        }

        List<EmailTemplate> plantillas = [SELECT Id, HtmlValue FROM EmailTemplate WHERE Name = :namePlantilla LIMIT 1];

        if (!plantillas.isEmpty() && String.isNotBlank(plantillas[0].HtmlValue)) {
            // CC_WS_PushSMS.CC_WS_PushSMS_Mensaje pushsms = new CC_WS_PushSMS.CC_WS_PushSMS_Mensaje();
            // pushsms.destinatario = caso.Account.AV_NumPerso__c;
            // pushsms.sObjectId = caso.Id;
            // pushsms.idPlantilla = plantillas[0].Id;
            // pushsms.texto = plantillas[0].HTMLValue;
            //String resultado = CC_WS_PushSMS.enviarNotificacionPush(pushsms);
            String resultado = CC_WS_PushSMS.enviarNotificacionPush(caso.Id, caso.Account.AV_NumPerso__c, '0000004', caso.CC_Idioma__c, caso.Account.AV_IndicadoresClientes__c);
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
}