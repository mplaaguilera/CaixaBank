/*****************************************************************
 * Name: SAC_NuevaReclamacionVinculada
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                     Marcela Neira   25/05/2022   Creación
*****************************************************************/
public without sharing class SAC_NuevaReclamacionVinculada implements Queueable {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final String RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    private static final String RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final String RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    List<Case> listaCasos;
    Case casoCerrado;

    public SAC_NuevaReclamacionVinculada(List<Case> listaCasosC, Case casoCerradoC) {
        listaCasos = listaCasosC;
        casoCerrado = casoCerradoC;
    }

    public void execute(QueueableContext context) { 

        try {
            List<Id> listaIdAdjuntos = new List<Id>();
            String idNuevaReclamacion;
            String idNuevaPretensionP;
            
            List<Database.SaveResult> resultado = Database.insert(listaCasos, false);

            idNuevaReclamacion = (resultado[0].isSuccess()) ? resultado[0].getId() : null;
            idNuevaPretensionP = (resultado[1].isSuccess()) ? resultado[1].getId() : null;

            listaIdAdjuntos.add(idNuevaReclamacion);
            listaIdAdjuntos.add(casoCerrado.Id);
            listaIdAdjuntos.add(casoCerrado.SAC_PretensionPrincipal__r.Id);

            //Se le añade el despacho representante del caso cerrado a la reclamación nueva
            List<Case> listaCasoNuevo = [SELECT Id,CBK_Case_Extension_Id__c FROM Case WHERE Id =: idNuevaReclamacion];

            if(!listaCasoNuevo.isEmpty() && listaCasoNuevo[0].CBK_Case_Extension_Id__c!= null){
                CBK_Case_Extension__c casoNuevoExtension = new CBK_Case_Extension__c();
                casoNuevoExtension.Id = listaCasoNuevo[0].CBK_Case_Extension_Id__c;
                casoNuevoExtension.SAC_DespachoRepresentante__c = casoCerrado.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c;
    
                SAC_DatabaseDML.updateDML(casoNuevoExtension, false);  
            }


            listaCasos.clear(); 
            Case casoRecla = new Case();
            casoRecla.id = idNuevaReclamacion;
            casoRecla.SAC_PretensionPrincipal__c = idNuevaPretensionP;
            // casoRecla.SAC_FechaRecepcion__c = null; //quitado, se rellena con el createdDate
   
            casoRecla.OS_Fecha_Resolucion__c = null; //se vacia la fecha resolucion, porque esta en analisis
            casoRecla.SAC_AltaAutomatica__c = true;
            casoRecla.AccountId = casoCerrado.AccountId;
            casoRecla.ContactId = casoCerrado.ContactId;
            casoRecla.OwnerId = casoCerrado.OwnerId;
            casoRecla.SEG_Grupo__c = casoCerrado.SEG_Grupo__c;
            casoRecla.SAC_NPretensionesActivas__c = 1; //Sabemos que la unica pretensión activa que tiene es la pretension principal
            listaCasos.add(casoRecla); 

            Case casoPretension = new Case();
            casoPretension.id = idNuevaPretensionP;
            casoPretension.SAC_EsPrincipal__c = true;
            casoPretension.Subject = casoCerrado.SAC_PretensionPrincipal__r.Subject;
            casoPretension.SAC_Reclamacion__c = idNuevaReclamacion;
            // casoPretension.SAC_FechaRecepcion__c = null; //quitado, se rellena con el createdDate
            casoPretension.OS_Fecha_Resolucion__c = null; //se vacia la fecha resolucion, porque esta en analisis
            casoPretension.SAC_AltaAutomatica__c = true;
            casoPretension.AccountId = casoCerrado.SAC_PretensionPrincipal__r.AccountId;
            casoPretension.ContactId = casoCerrado.SAC_PretensionPrincipal__r.ContactId;
            listaCasos.add(casoPretension);

            SAC_DatabaseDML.updateListDML(listaCasos, true);  
            //Database.update(listaCasos);   
            
            List<TopicAssignment> clasificacionCaso = [SELECT id, TopicId from TopicAssignment where EntityId =: casoCerrado.id];
            List<TopicAssignment> clasificacionCasoNuevo = new  List<TopicAssignment>();
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

            for (TopicAssignment ta : clasificacionCaso) {
                TopicAssignment topicAssig = new TopicAssignment(TopicId=ta.TopicId, EntityId=idNuevaReclamacion);
                clasificacionCasoNuevo.add(topicAssig);
            }
            
            if (!clasificacionCasoNuevo.isEmpty()) {
                SAC_DatabaseDML.insertListDML(clasificacionCasoNuevo, true);  
                //Database.insert(clasificacionCasoNuevo);
            }

            try {            

                List<EmailMessage> listaEM = [SELECT id
                                                FROM EmailMessage 
                                                WHERE RelatedToId IN: listaIdAdjuntos AND HasAttachment = true]; 
                
                if (!listaEM.isEmpty()) {
                    List<Attachment> listaAttach = [SELECT id, ParentId, Name, Body
                                                        FROM Attachment   
                                                        WHERE ParentId IN:listaEM]; 
                    
                    List<EmailMessage> listaEmailMessParaNuevaRecla = new List<EmailMessage>();      
                    List<Attachment> listaAttachParaNuevaRecla = new List<Attachment>();

                    for (EmailMessage em : listaEM) {
                        EmailMessage emAux = em.clone(false, false, false, false);
                        emAux.ParentId = listaIdAdjuntos[0];  //El la posicion 1 es donde se encuentra la Reclamación nueva
                        emAux.RelatedToId = listaIdAdjuntos[0]; 
                        listaEmailMessParaNuevaRecla.add(emAux);
                    }  

                    List<Database.SaveResult> resultadoEM = Database.insert(listaEmailMessParaNuevaRecla, false);

                    Id idEM = (resultadoEM[0].isSuccess()) ? resultadoEM[0].getId() : null;

                    for (Attachment att : listaAttach) {
                        Attachment attAux = att.clone(false, false, false, false);
                        attAux.ParentId = idEM;
                        listaAttachParaNuevaRecla.add(attAux);
                    }
                    SAC_DatabaseDML.insertListDML(listaAttachParaNuevaRecla, true);  
                    //List<Database.SaveResult> resultadoAtt = Database.insert(listaAttachParaNuevaRecla);

                    //Revisar cuando haya tiempo y hacerlo bien!!!!
                    SAC_DatabaseDML.deleteListDML(listaEmailMessParaNuevaRecla, true);  
                    //Database.delete(listaEmailMessParaNuevaRecla);
                }

                List<ContentDocumentLink> contenidos = [SELECT LinkedEntityId, contentdocumentid   
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId IN: listaIdAdjuntos]; 

                List<ContentDocumentLink> nuevosCDL = new List<ContentDocumentLink>();
                for (ContentDocumentLink cdl : contenidos) {
                    ContentDocumentLink cdlAux = new ContentDocumentLink();
                    cdlAux.LinkedEntityId = listaIdAdjuntos[0]; //Id de la nueva reclamación
                    cdlAux.contentdocumentid = cdl.contentdocumentid;
                    cdlAux.ShareType = 'I';
                    nuevosCDL.add(cdlAux);
                } 
                if (!nuevosCDL.isEmpty()) {
                    SAC_DatabaseDML.insertListDML(nuevosCDL, true);  
                    //Database.insert(nuevosCDL);
                    casoCerrado.CC_Detalles_Solucion__c =null;
                    SAC_DatabaseDML.insertDML(casoCerrado, false);  
                    //Database.update(casoCerrado);
                    
                    String linkCaso = URL.getSalesforceBaseUrl().toExternalForm() + '/' + idNuevaReclamacion;

                    /*SAC_LCMP_GestionEmails.enviarEmail(casoCerrado.Id, UserInfo.getUserEmail(), '', '', 
                    'Desde la reclamación cerrada número: ' + casoCerrado.CaseNumber + ', se ha generado con éxito la nueva reclamación vinculada, puede consultarla en el siguiente enlace: \n' + linkCaso,
                    'Finalización copia reclamación ' + casoCerrado.CaseNumber, '', '');*/
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(casoCerrado.Id,
                                                                        'SAC_017',
                                                                        'La nueva reclamación vinculada del caso: ' + casoCerrado.CaseNumber + ' se ha creado correctamente.',
                                                                        casoCerrado.OwnerId,
                                                                        '',
                                                                        '',
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = linkCaso;
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);

                    /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                    SAC_Notificacion.enviarNotificacion(casoRecla.OwnerId, 
                                        idNuevaReclamacion, 
                                        'Se ha creado correctamente',
                                        'La nueva reclamación vinculada del caso: ' + casoCerrado.CaseNumber + ' pinche aquí para consultarla.');*/
                
                    //Si tenemos alertas que enviar, se llama al método que las envía
                    if (!listaWrapperAlerta.isEmpty()) {
                        SAC_Alertas.generarAlertas(listaWrapperAlerta);
                    }
                }

            } catch (Exception e) { 
                throw new AuraHandledException(e.getMessage());
            } 
        } catch (Exception e) { 
            List<String> listaDireccionesPara = new List<String>{ UserInfo.getUserEmail() };

            //Recupero los emails no validos de envio (emails en la blackList)
            List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

            //Compruebo las direcciones de envio con las de la blackList
            List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si existen direcciones válidas, continuo el proceso
            if(!emailsValidos.isEmpty()){
                SAC_LCMP_GestionEmails.enviarEmail(casoCerrado.Id, UserInfo.getUserEmail(), '', '',
                'Las copias lanzadas desde la reclamación ' + casoCerrado.CaseNumber + ' no han podido ser generadas. Por favor, reintente el proceso. ' + e,
                'Finalización copia reclamación ' + casoCerrado.CaseNumber + ' no realizada.', '', '');
            }
            
            CBK_Log.error(e);
        }
        
    }
}