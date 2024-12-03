public with sharing class CC_SocialPost_Methods {
    
    @InvocableMethod(label='Twitter Respuesta' description='Twitter Respuesta')
    // Informar en el Caso la fecha de primera respuesta para reporting
    public static void CC_SocialPost_Methods(List<ID> ListTwitt) {
        if (ListTwitt.size() > 0){
            List<ID> ListSPId = new List<ID>();
            List<ID> oListSPAuto = new List<ID>();
            List<Case> ListaCasos = new List<Case>();
            //Map<Id, Id> MapSPId = new Map<Id, Id>();
            Boolean creaActividad = true;
            Map<Id, Boolean> MapCase = new Map<Id, Boolean>();
            // Recuperamos los datos necesarios del Social Post
            List<SocialPost> socialPost = [SELECT Id, ReplyToId, Posted, ParentId, Content, Provider, MessageType, CC_FechaCreaLocal__c, 
                                           HarvestDate, IsOutbound, CC_Primer_DM__c, CC_Solicitud_Informacion__c FROM SocialPost WHERE Id IN : ListTwitt];
            //Buscamos el texto legal por si se trata de un Social Post automatico de texto legal
            List<CC_Texto_MultiIdioma__mdt> ListLegalText = [SELECT CC_Texto__c FROM CC_Texto_MultiIdioma__mdt 
                                                             WHERE CC_Nombre__c = 'Mensaje legal'];
            
            for (SocialPost sp :  socialPost){
                ListSPId.add(sp.ParentId);                
            }
            //system.debug('ListSPId: '+ListSPId);
            //Buscamos los casos para recuperar el caso primer dm enviado
            List<Case> ListCasos = [SELECT Id, CC_Primer_DM_Enviado__c, CC_Idioma__c FROM Case WHERE Id IN : ListSPId];
            for (Case cs : ListCasos){
                MapCase.put(cs.Id, cs.CC_Primer_DM_Enviado__c);
				                
            }
            
            
            //System.debug(socialPost);
            for (Integer j=0;j<socialPost.size();j++){
                //System.debug(j);
                if (socialPost[j] != null){
                    //System.debug(socialPost[j]);
                    if (socialPost[j].IsOutbound != null && socialPost[j].ParentId != null){
                        //System.debug(socialPost[j]);
                        // Se comprueba si es un Twitter de Salida (respuesta agente)
                        //system.debug('PrimerDM: '+socialPost[j].CC_Primer_DM__c);
                        //if (socialPost[j].IsOutbound != false && socialPost[j].CC_Primer_DM__c == false){
                        if (socialPost[j].IsOutbound != false){ // && MapCase.get(socialPost[j].ParentId) == false){
                            
                            //System.debug('ParentId: '+MapCase.get(socialPost[j].ParentId));
                            //CaseId.add(socialPost[j].ParentId);
                            Case caso = new Case();
                            caso.Id = socialPost[j].ParentId;
                            caso.CC_Fecha_1a_Respuesta_Twitter__c = socialPost[j].Posted;
                            caso.CC_Admin__c=true;

                            //Crea una actividad de nuevo post en RRSS
                            String tipoMensajePubPriv = '';
                            if (socialPost[j].MessageType == 'Direct')
                            {
                                tipoMensajePubPriv = 'Mensaje Privado';
                                //ListSPId.add(socialPost[j].Id);
                                if (MapCase.get(socialPost[j].ParentId) == false){
                                    oListSPAuto.add(socialPost[j].Id);  
                                    caso.CC_Primer_DM_Enviado__c = true;
                                }
                            }
                            else
                                tipoMensajePubPriv = 'Mensaje Público';
                
                            ListaCasos.add(caso);
                            for (CC_Texto_MultiIdioma__mdt text : ListLegalText){
                                if(socialPost[j].Content == text.CC_Texto__c){
                                    creaActividad = false;
                                }
                            }
                            if (creaActividad == true){
                            	createActivity(socialPost[j].ParentId, socialPost[j].Content , 'Salida '+ tipoMensajePubPriv + ' ' + socialPost[j].Provider, 'Salida '+ tipoMensajePubPriv + ' ' + socialPost[j].Provider, socialPost[j].CC_Solicitud_Informacion__c);
                                if(socialPost[j].CC_Solicitud_Informacion__c){
                                    createActivitySolicitud(socialPost[j].ParentId, socialPost[j].Content, socialPost[j].CC_Solicitud_Informacion__c);
                                }
                            }
                        } else {
                            // Entrada de un nuevo Social Post donde informamos la fecha entrante 
                            // Reseteamos la fecha de respuesta del agente para el SLA
                            Case casoNuevo = new Case();
                            casoNuevo.Id= socialPost[j].ParentId;
                            casoNuevo.CC_Fecha_1a_Respuesta_Twitter__c = null;
                            casoNuevo.CC_Fecha_Twitter_Entrante__c = socialPost[j].HarvestDate;
                            casoNuevo.CC_Admin__c=true;
                            ListaCasos.add(casoNuevo);
                        }
                    }
                }
            }
            
            // Recuperamos los casos de los Social Post de Respuesta de agente
            /*List<Case> ListCase = [SELECT Id, CC_Fecha_1a_Respuesta_Twitter__c FROM Case WHERE Id IN : CaseId];
            // Recorremos ambas listas y al coincidir actualizamos la fecha de primera respuesta si esta es nula
            for (Integer i=0;i<socialPost.size();i++)
            {
                for (Integer n=0;n<ListCase.size();n++){
                    if (socialPost[i].ParentId == ListCase[n].Id){
                        if (ListCase[n].CC_Fecha_1a_Respuesta_Twitter__c == null){
                            Case caso = new Case();
                            caso.Id = ListCase[n].Id;
                            caso.CC_Fecha_1a_Respuesta_Twitter__c = socialPost[i].Posted;
                            ListaCasos.add(caso);
                        }
                    }
                }
            }*/
            // Actualizamos las fechas en el caso
            if (!ListaCasos.isEmpty()){
            	Database.SaveResult[] ResultSP = Database.update(ListaCasos);
                for (case c :ListaCasos){
                    c.CC_Admin__c=false;
                }
            	Database.SaveResult[] ResultSP2 = Database.update(ListaCasos);
        	}
            //System.debug('Fin');
            //Enviamos el SP automatico de tratamiento de datos
            if(!oListSPAuto.isEmpty()){
				CC_SocialPost_DM_Legal.enviarMensajeLegalTwitter(oListSPAuto);  
            }
        }
    }
    
    //Crea actividad de conversación en RRSS
    private static void createActivity(Id caseId, String comentario, String subject, String tipo, Boolean solicitudInformacion) {
        // Crear Tarea
        Date todaysDate = system.today();
        Task task = new Task();
        task.ActivityDate = todaysDate;
        task.Subject = subject;
        task.Type = tipo;
        task.Status = 'Completed';
        task.Description = comentario; 
        task.WhatId = caseId;
        task.Priority = 'Normal';
        task.CC_Solicitud_Informacion__c = solicitudInformacion;
        //insert task;
        CC_Activity.crearActividad(task);
    }

    //Crea actividad de conversación en RRSS
    private static void createActivitySolicitud(Id caseId, String comentario, Boolean solicitudInformacion) {
        // Crear Tarea
        Task actividadSolicitud= new Task();
        Date todaysDate = system.today();
        actividadSolicitud.ActivityDate = todaysDate;
        actividadSolicitud.Type = 'Solicitud Información';
        actividadSolicitud.Subject = 'Solicitud Información';
        actividadSolicitud.WhatId = caseId;
        Datetime fechaFinPlazo = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(caseId);
        actividadSolicitud.CC_Fecha_FinPlazo_SolInf__c = fechaFinPlazo;
        actividadSolicitud.Status = 'Open';
        actividadSolicitud.Description = comentario;
        actividadSolicitud.Priority = 'Normal';
        actividadSolicitud.CC_Solicitud_Informacion__c = solicitudInformacion;
        //insert task;
        CC_Activity.crearActividad(actividadSolicitud);
    }
    
}