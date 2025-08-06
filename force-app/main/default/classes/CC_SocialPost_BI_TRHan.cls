public class CC_SocialPost_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SocialPost>)tp.newList);
	}
    
    private void process(List<SocialPost> listNewObj) {
        validarMensajeDirectoCuentaGrupo(listNewObj);
    }

    private static void validarMensajeDirectoCuentaGrupo (List<SocialPost> listNewObj)
    {
        List<ID> oPostOrigen = new List<ID>();        
        for(SocialPost oPost : listNewObj)
        {
            // Recuperar el mensaje de respuesta origen, para obtener la cuenta origen.
            oPostOrigen.add(oPost.ReplyToId);
        }
        
        List<SocialPost> oDatosPostOrigen = new List<SocialPost>();
        if (!oPostOrigen.isEmpty())
        {
            // Recuperar cuenta de respuesta.
        	oDatosPostOrigen = [SELECT Id, Handle FROM SocialPost WHERE Id IN :oPostOrigen];
        }
        oPostOrigen = null;
        
        // Preparar Map para datos de respuesta.
        Map<Id,String> oMsjRespuestas = new Map<Id,String>();
        for (SocialPost oPost : oDatosPostOrigen)
        {
            oMsjRespuestas.put(oPost.Id, oPost.Handle);
        }
        oDatosPostOrigen = null;
        
		// Recorrer los mensajes a insertar y validar.
		for(SocialPost oPost : listNewObj)
        {   
            // La cuenta origen la recuperamos del mensaje original. En la creación del post saliente todavía no está disponible el valor.
            String sCuenta = oMsjRespuestas.get(oPost.ReplyToId);
            String sHandle = oPost.Handle;
            String sRRSS = oPost.Provider;
            String sTipoPost = oPost.MessageType;
           
            
            if (sCuenta != null && sRRSS != null && sTipoPost != null && sCuenta != '' && sRRSS != '' && sTipoPost != '')
            {
                // Un mensaje directo por QuickAction / procesos notificación viene sin informar.
                if (sTipoPost == 'Direct' && sHandle == null)
                {
                    List<CC_Config_RRSS__mdt> oConfig = [SELECT Id, CC_Cuenta_RRSS__c FROM CC_Config_RRSS__mdt WHERE CC_Red_Social__c = :sRRSS AND CC_Cuenta_RRSS__c = :sCuenta];
                    if (!oConfig.isEmpty())
                    {
                        // Cuenta del grupo. Bloquear mensaje.
                        String sMensajeError = 'El caso proviene de una mención de una cuenta del grupo y todavía no hay una interacción del cliente final.';
                        sMensajeError = sMensajeError + ' No puedes enviar un mensaje directo, ya que se enviará a la cuenta del grupo.';
                        sMensajeError = sMensajeError + ' Para continuar con la operativa has de enviar un mensaje público (Responder).';
                        oPost.addError(sMensajeError);
                    }
                }
            }
            
        }
    }
}