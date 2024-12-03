public with sharing class CC_SocialPost_DM_Legal {
    /*
        Método para enviar mensaje legal por Twitter con DM.
    */
    //@InvocableMethod(label='Enviar mensaje legal a cliente' description='Enviar mensaje legal a cliente')
    //@future(callout=true)
    static public void enviarMensajeLegalTwitter(List<Id> socialPostIds) {
		List<Id> ListIdPost = new List<Id>();
        List<SocialPost> oListPost = new List<SocialPost>();
        List<QuickAction.QuickActionRequest> oListReq = new List<QuickAction.QuickActionRequest>();
        List<Case> oUpdCasos = new List<Case>();

        List<SocialPost> sPosts = [SELECT Id,ParentId,ReplyToId FROM SocialPost WHERE Id IN :socialPostIds];
        List<Id> casoIds = new List<Id>();
        for (SocialPost sPost : sPosts) {
            casoIds.add(sPost.ParentId);
        }
        List<Case> idiomas = [SELECT Id,CC_Idioma__c FROM Case WHERE Id IN : casoIds];
        Map<Id,String> casoIdioma = new Map<Id,String>();
        for (Case idioma : idiomas) {
            casoIdioma.put(idioma.Id, idioma.CC_Idioma__c);
        }

        String textoContentES = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'es'].CC_Texto__c;
        String textoContentCA = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'ca'].CC_Texto__c;
        String textoContentEN = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt WHERE CC_Nombre__c = 'Mensaje legal' AND CC_Idioma__c = 'en'].CC_Texto__c;
        List<Case> lstCasoUpdate = new List<Case>();


        for (SocialPost sPost : sPosts) {
            // Mensaje privado a enviar.
            SocialPost oPost = new SocialPost();
            oPost.ParentId = sPost.ParentId; // Registro padre asociado.
            oPost.ReplyToId = sPost.ReplyToId; // Mensaje al que se está respondiendo.
            oPost.MessageType = 'Direct'; // Tipo de mensaje enviado.
            String idioma = casoIdioma.get(sPost.ParentId);
            if (idioma == 'es') { // Contenido del mensaje.
                oPost.Content = textoContentES;
            } else if (idioma == 'ca') {
                oPost.Content = textoContentCA;
            } else if (idioma == 'en') {
                oPost.Content = textoContentEN;
            }
            Case oCaso = new Case();
            oCaso.Id = oPost.ParentId;
            oCaso.CC_Primer_DM_Enviado__c = true;
            lstCasoUpdate.add(oCaso);

            // Cuerpo petición.
            QuickAction.QuickActionRequest oReq = new QuickAction.QuickActionRequest();
            oReq.quickActionName = Schema.Case.QuickAction.SocialPublisher;
            oReq.record = oPost; // Asignar el mensaje a la petición.
            oReq.contextId = sPost.ParentId; // Contexto. Caso ID.
            // Añadir la petición.
            oListReq.add(oReq);
            
        }

        if (!lstCasoUpdate.isEmpty()) {
            Database.update(lstCasoUpdate);
        }
		
        // Lanzar las peticiones de mensajes a enviar.
        if (!oListReq.isEmpty()) {
            List<QuickAction.QuickActionResult> oDataRes = QuickAction.performQuickActions(oListReq, false);
            
            // Tratar respuesta y actualizar el caso como enviado.
            for (QuickAction.QuickActionResult oRes : oDataRes) {
                if (oRes.isSuccess()){
                    ListIdPost = oRes.getIds();
                }
                if (!oRes.isSuccess()) {
                    if (oRes.getContextId() != null) {
                        Case oCaso = new Case();
                        oCaso.CC_Primer_DM_Enviado__c = false;
                        oUpdCasos.add(oCaso);
                    }
                }
            }
            for (Id idPost : ListIdPost){
                SocialPost sp = new SocialPost();
                sp.Id = idPost;
                sp.CC_Primer_DM__c = true;
                oListPost.add(sp);
            }
            // COMENTADO PORQUE DA ERROR CON EL ENVÍO.
            //update oListPost;
        }
    }
}