public with sharing class CC_SocialPost_Respuestas 
{
 	@InvocableMethod(label='Solicitud Información' description='Reclamación Solicitud Información')
       public static void CC_SocialPost_Reclamacion_Respuesta(List<ID> ListTwitt)
       {
            if (ListTwitt.size() > 0){
                //Listado para actualizar los casos y los SocialPost
                List<Case> listaCasos = new List<Case>();
                List<SocialPost> listaPosts = new List<SocialPost>();
                
                // Recuperamos los datos necesarios del Social Post
                List<SocialPost> socialPost = [SELECT Id, ReplyToId, ParentId, Provider, MessageType, CC_Respuesta_Reclamada__c, Handle, 
                                                CC_ReclamacionActiva__c
                                               FROM SocialPost WHERE Id IN : ListTwitt];

                // Recuperar cuentas del grupo CBK, para no reclamar a ellas.
                List<String> oCuentasGrupo = CC_InboundSocialPostHandlerImpl.getCuentasGrupo('Twitter');

                // Listado de peticiones de reclamaciones Twitter a enviar.
                List<QuickAction.QuickActionRequest> oListReqRec1 = new List<QuickAction.QuickActionRequest>();
                List<QuickAction.QuickActionRequest> oListReqRec2 = new List<QuickAction.QuickActionRequest>();

                // Recuperar los casos asociados a cada SocialPost.
                Set<ID> oListaCasos = new Set<ID>();
                for (SocialPost oPost : socialPost)
                {
                    if (oPost.ParentId != null)
                    {
                        oListaCasos.add(oPost.ParentId);
                    }
                }

                Map<ID,Case> oCasosAsociados = new Map<ID,Case>();
                if (!oListaCasos.isEmpty())
                {
                    oCasosAsociados = new Map<ID,Case>([SELECT Id, Status, CC_Idioma__c, CC_CuentaRRSS_CLI__c FROM Case WHERE Id IN :oListaCasos]);
                }

                // Tratamiento de los posts creados.
                for (Integer j=0;j<socialPost.size();j++)
                {
                    if (socialPost[j] != null)
                    {
                        // Si la reclamación está activa, continuar con el proceso de reclamaciones del SocialPost.
                        if (socialPost[j].CC_ReclamacionActiva__c)
                        {
                            // Recuperamos el estado actual del Caso del MAP calculado.
                            Case caso = oCasosAsociados.get(socialPost[j].ParentId);
                            
                            if (caso != null)
                            {
                                // Saltamos la creación de Posts de reclamación automática a cuentas del grupo CBK.
                                Boolean bCuentaGrupo = oCuentasGrupo.contains(caso.CC_CuentaRRSS_CLI__c);
                               
                                //Sólo debemos reclamar respuesta si el Caso sigue en estado Pendiente Cliente
                                if (caso.Status == 'Pendiente Cliente' && !bCuentaGrupo)
                                {
                                    //Si la respuesta no se ha reclamado anteriormente, se hace la primera reclamación
                                    //Si la respuesta ya se ha reclamado una vez (CC_Respuesta_Reclamada__c=true) se cierra el caso y se avisa al cliente
                                    if(!socialPost[j].CC_Respuesta_Reclamada__c)
                                    {
                                        //Recuperamos por metadata el contenido del mensaje a enviar (sólo habrá un mensaje para cada idioma)
                                        List<CC_Reclamacion_Respuesta_RRSS__mdt> STRespuestas = new List<CC_Reclamacion_Respuesta_RRSS__mdt>();
                                        STRespuestas = [SELECT Respuesta__c FROM CC_Reclamacion_Respuesta_RRSS__mdt where idioma__c = :caso.CC_Idioma__c];
                                        
                                        // Preparar el Post de reclamación a enviar.
                                        SocialPost reclamacion = new SocialPost();
                                        reclamacion.ParentId = socialPost[j].ParentId;
                                        reclamacion.ReplyToId = socialPost[j].ReplyToId;
                                        reclamacion.MessageType = 'Direct';
                                        reclamacion.Content = STRespuestas[0].Respuesta__c;
                                        //reclamacion.CC_TipoReclamacion__c = 'Reclamación automática';

                                        // Crear la petición
                                        QuickAction.QuickActionRequest oReq = new QuickAction.QuickActionRequest();
                                        oReq.quickActionName = Schema.Case.QuickAction.SocialPublisher;
                                        oReq.record = reclamacion; // Asignar el mensaje a la petición.
                                        oReq.contextId = socialPost[j].ParentId; // Contexto. Caso ID.
                                        oListReqRec1.add(oReq);                  
                                        
                                        //Se actualiza el SocialPost inicial para indicar que ya se ha reclamado
                                        socialPost[j].CC_Respuesta_Reclamada__c = true;
                                        //update socialPost[j];
                                        listaPosts.add(socialPost[j]);
                                    }
                                    else
                                    {
                                        //Se cierra el caso y se envía un POST al cliente para informarle

                                        //Recuperamos por metadata el contenido del mensaje a enviar (sólo habrá un mensaje para cada idioma)
                                        List<CC_Aviso_Cierre_RRSS__mdt> STCierre = new List<CC_Aviso_Cierre_RRSS__mdt>();
                                        STCierre = [SELECT Respuesta__c FROM CC_Aviso_Cierre_RRSS__mdt where idioma__c = :caso.CC_Idioma__c];

                                        // Preparar el Post de reclamación a enviar.
                                        SocialPost reclamacion = new SocialPost();
                                        reclamacion.ParentId = socialPost[j].ParentId;
                                        reclamacion.ReplyToId = socialPost[j].ReplyToId;
                                        reclamacion.MessageType = 'Direct';
                                        reclamacion.Content = STCierre[0].Respuesta__c;
                                        //reclamacion.CC_TipoReclamacion__c = 'Aviso de cierre automático';

                                        // Crear la petición
                                        QuickAction.QuickActionRequest oReq = new QuickAction.QuickActionRequest();
                                        oReq.quickActionName = Schema.Case.QuickAction.SocialPublisher;
                                        oReq.record = reclamacion; // Asignar el mensaje a la petición.
                                        oReq.contextId = socialPost[j].ParentId; // Contexto. Caso ID.
                                        oListReqRec2.add(oReq);  

                                        // finalizar reclamación.
                                        socialPost[j].CC_ReclamacionActiva__c = false;
                                        listaPosts.add(socialPost[j]);  
                                        
                                        caso.CC_Admin__c = true;
                                        caso.Status = 'Cerrado';
                                        listaCasos.add(caso);
                                    }
                                }else{
                                    // Inactivamos la reclamación para el batch.
                                    socialPost[j].CC_ReclamacionActiva__c = false;
                                    listaPosts.add(socialPost[j]);
                                }
                            }else{
                                // Inactivamos la reclamación para el batch.
                                socialPost[j].CC_ReclamacionActiva__c = false;
                                listaPosts.add(socialPost[j]);
                            }
                        }
                    }
                }
                // Actualizamos el estado del caso
            	if (!listaCasos.isEmpty())
                {
                    Database.SaveResult[] ResultCS = Database.update(listaCasos, false);
                    for (case c :ListaCasos){
                    	c.CC_Admin__c=false;
                	}
            		Database.SaveResult[] ResultCS2 = Database.update(ListaCasos, false);

                }

                // Actualizamos los sociaPosts
            	if (!listaPosts.isEmpty())
                {
                    Database.SaveResult[] ResultSP = Database.update(listaPosts);
                }

                // Enviar los posts de reclamaciones.
                if (!oListReqRec1.isEmpty())
                {
                    List<QuickAction.QuickActionResult> oDataRes = QuickAction.performQuickActions(oListReqRec1, false);
                    /*List<SocialPost> oActualizarNombreSP = new List<SocialPost>();
                    for (QuickAction.QuickActionResult oResultOp : oDataRes)
                    {
                        if (oResultOp.isSuccess())
                        {
                            for (ID oNewPostId : oResultOp.getIds())
                            {
                                SocialPost oNewPostAux = new SocialPost();
                                oNewPostAux.Id = oNewPostId;
                                oNewPostAux.Name = 'Reclamación automática';
                                oActualizarNombreSP.add(oNewPostAux);
                            }
                        }
                    }

                    if (!oActualizarNombreSP.isEmpty())
                    {
                        Database.SaveResult[] ResultSPRecl = Database.update(oActualizarNombreSP);
                    }*/
                }

                if (!oListReqRec2.isEmpty())
                {
                    List<QuickAction.QuickActionResult> oDataRes = QuickAction.performQuickActions(oListReqRec2, false);
                    /*List<SocialPost> oActualizarNombreSP = new List<SocialPost>();
                    for (QuickAction.QuickActionResult oResultOp : oDataRes)
                    {
                        if (oResultOp.isSuccess())
                        {
                            for (ID oNewPostId : oResultOp.getIds())
                            {
                                SocialPost oNewPostAux = new SocialPost();
                                oNewPostAux.Id = oNewPostId;
                                oNewPostAux.Name = 'Aviso de cierre automático';
                                oActualizarNombreSP.add(oNewPostAux);
                            }
                        }
                    }

                    if (!oActualizarNombreSP.isEmpty())
                    {
                        Database.SaveResult[] ResultSPRecl = Database.update(oActualizarNombreSP);
                    }*/
                }
            }
       }
}