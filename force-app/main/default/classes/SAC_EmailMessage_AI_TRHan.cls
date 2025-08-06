public with sharing class SAC_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}    
    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj){

        //Se comprueba si el correo de salida es válido. En caso de no serlo se impide el envío.
        comprobarBuzonSalida(listNewObj);

        SAC_TratarMensajesInteraccion.pegarInteraccionMessage(listNewObj);
    }

    /*********************************************************************
     * Proposito: Procesa los emails para no enviar aquellos cuya dirección destino se encuentre
     * en la lista negra 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US475059         Raúl Santos    09/11/2022   Creación
    *********************************************************************/ 
    @AuraEnabled
    public static void comprobarBuzonSalida(List<EmailMessage> listNewObj) {
        //try{
            List<String> buzonesSalidaInvalidos = new List<String>();

            for (Buzon_SAC__mdt buzonPorDefecto : [SELECT SAC_DireccionCorreo__c FROM Buzon_SAC__mdt WHERE SAC_Activo__c = true]) {
                buzonesSalidaInvalidos.add(buzonPorDefecto.SAC_DireccionCorreo__c);
            }

            for (EmailMessage emailCopy : listNewObj) {
                String destinos = '';
                if (String.isNotBlank(emailCopy.ToAddress)) {
                    destinos = emailCopy.ToAddress;    
                }
                
                if(String.isNotBlank(emailCopy.CcAddress)){
                    destinos = destinos + ';' + emailCopy.CcAddress;
                }

                if(String.isNotBlank(emailCopy.BccAddress)){
                    destinos = destinos + ';' + emailCopy.BccAddress;
                }
                
                String[] emailsDestino = new String[]{};
                if (String.isNotBlank(destinos)) {
                    emailsDestino = destinos.split(';');
                }
                Boolean emailInvalido = false;
                String emailDestinoInvalido = '';

                if (!emailsDestino.isEmpty()) {
                    for(Integer i = 0; i < emailsDestino.size(); i++){
                        String emailDestino = emailsDestino[i].trim();
                        if(buzonesSalidaInvalidos.contains(emailDestino) && !emailCopy.incoming){
                            emailInvalido = true;
                            emailDestinoInvalido = emailDestinoInvalido + ' ' + emailDestino;
                        }
                    }
                    
                    if(emailInvalido == true){
                        throw new AuraHandledException('La dirección/es de destino ' + '"' + emailDestinoInvalido + '"' + ' no es válida/s.');
                        // String m = 'Este es el mensaje de la lista negra';
                        // AuraHandledException e = new AuraHandledException(m);
                        // e.setMessage(m);
                        // throw e;
                    }   
                }

                // if(buzonesSalidaInvalidos.contains(emailCopy.ToAddress) && !emailCopy.incoming){
                //     //emailCopy.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                //     throw new AuraHandledException('La dirección de destino no es válida.');
                // }
            }
        
        // }catch (Exception e){
        //     throw new AuraHandledException('eeeeeeeeeeeerrrror');
        // } 
    }
}