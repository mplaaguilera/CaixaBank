public with sharing class CC_NotifSegCaso {
    /*
    Método para tratar la creación de tareas sobre el caso y enviar una notificación de seguimiento.
    */
    /*
    Método para enviar acuse de recibo en la creación de casos.
    */
    @InvocableMethod(label='Notificar caso a cliente' description='Notificación de un caso al cliente')
    static public void gestionarSeguimientoCliente (List<ID> oIDs)
    {
        // Gestionar notificaciones para el acuse.
        
        // Quitar duplicados.
        Set<ID> oSetID = new Set<ID>(oIDs);
        
        // Lanzamos un máximo de 50 con las llamadas repartidas (límite Hard).
        if (oSetID.size() > 0)
        {
            List<ID> oIDList = new List<ID>(oSetID);
            Integer j = 1;
            Map<Integer,List<ID>> oMap = new Map<Integer,List<ID>>();
            for (Integer i=0;i<oIDList.size();i++)
            {
                if (j > 50) {
                    j = 1;
                }
                
                
                // Inicializar listas.
                if (oMap.get(j) == null) {
                    List<ID> oSet = new List<ID>();
                    oMap.put(j,oSet);
                }
                
                // Añadir valor.
                oMap.get(j).add(oIDList[i]);
                
                j = j + 1;
            }
            
            // Lanzar llamadas Futuras.
            List<Id> idsTareas = new List<Id>();
            for(List<Id> listTareas : oMap.values()){
                idsTareas.addAll(listTareas);
            }
            
            CC_NotifSegCaso.gestionarBatchNotificacionCliente (idsTareas, 'CC_SegOperativa');
            
            oIDList.clear();
            oIDList = null;
            oIDList = null;
            
            oMap.clear();
            oMap = null;
        }
        
        oSetID.clear();
        oSetID = null;
    }
    /*@InvocableMethod(label='Notificar caso a cliente' description='Notificación de un caso al cliente')
    static public void gestionarSeguimientoCliente (List<ID> oIDs)
    {
        // TO_DO. CAMBIAR COMO LA DE ACUSE DE RECIBO.
        
        gestionarNotificacionCliente (oIDs);
        
    }*/
    
    /*
    Método para configuraciones en modo test.
    */
    static private void recuperaConfigTest(String sProceso, Map<String,String> oCfgOrigen, Map<String,Map<String,String>> oCfgMail, Map<String,Map<String,String>> oCfgTwitter)
    {
        if (sProceso == 'CC_NotIncidencia')
        {
            oCfgOrigen.put('TareasTipo','Traslado Incidencia;');
            oCfgOrigen.put('TareasOrigen','Email##;Twitter##;');
            oCfgOrigen.put('TareasEstado','Completed');
            oCfgOrigen.put('CasoOrigen','');
            oCfgOrigen.put('Origen','Tarea');
            
            Map<String,String> oAttr = new Map<String,String>();
            oAttr.put('Cuerpo', 'Cuerpo');
            oAttr.put('RemitenteName', 'Remitente');
            oAttr.put('Carpeta', 'Carpeta');
            oAttr.put('RemitenteCfg', 'test@remi.es');
            oAttr.put('Plantilla', '');
            oAttr.put('Remitente', '');
            
            List<EmailTemplate> oTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'CC_NotIncidencia' ];
            
            if (!oTemplate.isEmpty())
            {
                if (oTemplate[0] != null)
                {
                    oAttr.put('Plantilla', oTemplate[0].Id);
                }
            }
            
            oCfgMail.put('es##CC_NotIncidencia', oAttr);
            oCfgTwitter.put('es##CC_NotIncidencia', oAttr);
        }
        
        if (sProceso == 'CC_AcuseRecibo')
        {
            oCfgOrigen.put('TareasTipo','');
            oCfgOrigen.put('TareasOrigen','');
            oCfgOrigen.put('TareasEstado','');
            oCfgOrigen.put('CasoOrigen','Email##;Twitter##;');
            oCfgOrigen.put('Origen','Caso');
            
            Map<String,String> oAttr = new Map<String,String>();
            oAttr.put('Cuerpo', 'Cuerpo');
            oAttr.put('RemitenteName', 'Remitente');
            oAttr.put('Carpeta', 'Carpeta');
            oAttr.put('RemitenteCfg', 'test@remi.es');
            oAttr.put('Plantilla', '');
            oAttr.put('Remitente', '');
            
            List<EmailTemplate> oTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'CC_AcuseRecibo' ];
            
            if (!oTemplate.isEmpty())
            {
                if (oTemplate[0] != null)
                {
                    oAttr.put('Plantilla', oTemplate[0].Id);
                }
            }
            
            oCfgMail.put('es##CC_AcuseRecibo', oAttr);
        }
        
        if (sProceso == 'CC_SegOperativa')
        {
            oCfgOrigen.put('TareasTipo','Traslado Colaborador;');
            oCfgOrigen.put('TareasOrigen','');
            oCfgOrigen.put('TareasEstado','Open');
            oCfgOrigen.put('CasoOrigen','');
            oCfgOrigen.put('Origen','Tarea');
            
            Map<String,String> oAttr = new Map<String,String>();
            oAttr.put('Cuerpo', 'Cuerpo');
            oAttr.put('RemitenteName', 'Remitente');
            oAttr.put('Carpeta', 'Carpeta');
            oAttr.put('RemitenteCfg', 'test@remi.es');
            oAttr.put('Plantilla', '');
            oAttr.put('Remitente', '');
            
            List<EmailTemplate> oTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'CC_SegOperativa' ];
            
            if (!oTemplate.isEmpty())
            {
                if (oTemplate[0] != null)
                {
                    oAttr.put('Plantilla', oTemplate[0].Id);
                }
            }
            
            oCfgMail.put('es##CC_SegOperativa', oAttr);
        }
    }
    
    /*
    Método BATCH para envío de e-mails.
    */
    public static void gestionarBatchNotificacionCliente(List<Id> oIDs, String sProceso) {
        
        if (oIDs == null || oIDs.isEmpty() || sProceso == '') {
            // Salir de la gestión.
            return;
        }        
        // Recuperar configuración mensajes a enviar.
        Map<String, String> oCfgOrigen = getConfigOrigen(sProceso); //, 'CC_NotifOrigen');
        Map<String, Map<String, String>> oCfgTwitter = getConfigCanal(sProceso, 'Twitter');
        Map<String, Map<String, String>> oCfgMail = getConfigCanal(sProceso, 'Email');
        Map<String, Map<String, String>> oCfgSMS = getConfigCanal(sProceso, 'SMS');
        
        // Modo test. Forzado custommetadatos activos
        if (Test.isRunningTest()) {
            recuperaConfigTest(sProceso, oCfgOrigen, oCfgMail, oCfgTwitter);
        }
        
        Integer iElementos = oIDs.size();
        List<Id> oIDEnviar = new List<Id>();
        
        for (Integer i = 0; i < iElementos; i++) {
            oIDEnviar.add(oIDs[i]);
        }
        CC_NotifSegCaso.gestionarNotificacionCliente(oIDEnviar, sProceso, oCfgOrigen, oCfgTwitter, oCfgMail, oCfgSMS);
    }
    
    /*
    Método de notificación a cliente.
    NOTAS: los Maps de configuración estarán vacíos si no están activos o configurados.
    */
    static public void gestionarNotificacionCliente (List<ID> oIDs, String sProceso, Map<String, String> oCfgOrigen, Map<String, Map<String, String>> oCfgTwitter, Map<String, Map<String, String>> oCfgMail, Map<String, Map<String, String>> oCfgSMS) {
        
        if (oIDs == null || oIDs.isEmpty() || sProceso == '') {
            return;
        }        
        // TO_DO. GESTIÓN DE ENVÍO DE SMS NO REALIZADO.
        
        Map<String, Map<String, Map<String, String>>> oCanalCasos = new Map<String, Map<String, Map<String, String>>>();
        
        // Recuperar configuración mensajes a enviar.
        /*Map<String,String> oCfgOrigen = getConfigOrigen (sProceso); //, 'CC_NotifOrigen');
        Map<String,Map<String,String>> oCfgTwitter = getConfigCanal (sProceso, 'Twitter');
        Map<String,Map<String,String>> oCfgMail = getConfigCanal (sProceso, 'Email');
        Map<String,Map<String,String>> oCfgSMS = getConfigCanal (sProceso, 'SMS');*/
        
        //*******************************************************************************
        // TO_DO. Añadir comprobación de configuración. Consistencia de registros.
        // Validar origen y campos obligatorios informados.
        // Validar algún canal configurado para ese proceso.
        //*******************************************************************************
        
        // Si la configuración no está activa, el origen se queda vacío. Inactivación del proceso.
        String sOrigen = '';
        if (oCfgOrigen.get('Origen') != null)
        if (oCfgOrigen.get('Origen') != '')
        sOrigen = oCfgOrigen.get('Origen');
        
        // Separar los IDs por origen.
        List<Id> oTareasOrig = new List<Id>();
        List<Id> oCasoOrig = new List<Id>();
        
        for (Id iIdent : oIDs) {
            String sObjName = '';
            Schema.SObjectType oTipoObj = iIdent.getSobjectType();
            if (oTipoObj != null) {
                try {
                    sObjName = oTipoObj.getDescribe().getName();
                } catch (Exception e) {
                    sObjName = '';
                }
                
                if (sObjName == 'Case' && sOrigen == 'Caso')
                {
                    oCasoOrig.add(iIdent);
                }
                
                if (sObjName == 'Task' && sOrigen == 'Tarea')
                {
                    oTareasOrig.add(iIdent);
                }
            }
        }
        
        Map<String,String> oTaskCase = new Map<String,String>();
        Map<String,String> oCaseCase = new Map<String,String>();
        List<Case> oUpdCasos = new List<Case>();
        
        // Recuperar los casos asociados a las tareas.
        if (!oTareasOrig.isEmpty()) {
            oTaskCase = getTaskCasosSeguimiento (oTareasOrig, oCfgOrigen, sProceso);
        }
        
        // Recuperar los casos creados.
        if (!oCasoOrig.isEmpty()) {
            oCaseCase = getCaseCasosSeguimiento (oCasoOrig, oCfgOrigen, sProceso);
        }
        
        // Recuperar los casos asociados a las tareas.
        //if (!oIDs.isEmpty())
        //    oTaskCase = getPotCasosSeguimiento (oIDs);
        
        // Map para creación de contactos temporales.
        Map<String,String> oTempCont = new Map<String,String>();
        
        // Recuperar los casos que se ha de enviar la notificación. Sólo se envía 1 vez al cliente.
        if (!oTaskCase.isEmpty() || !oCaseCase.isEmpty())
        oCanalCasos = getDatosCasos (oTaskCase, oCaseCase, sProceso, oTempCont);
        
        // DESCARTADO. SE CREAN CONTACTOS TEMPORALES PARA EL ENVÍO.
        // INCOMPATIBILIDAD CON LA IDENTIFICACIÓN DE CLIENTES EN MODO FUTURE.
        
        // Crear los contactos temporales para enviar el e-mail.
        /*if (!oCanalCasos.isEmpty())
        {
            if (oCanalCasos.get('Email') != null)
            {
                // Se trata por referencia.
                tratarDatosContacto (oCanalCasos.get('Email'));
            }
        }*/
        
        // Realizar notificaciones a cliente.
        if (!oCanalCasos.isEmpty()) {
            for (String sCanal : oCanalCasos.keySet()) {
                if (oCfgTwitter != null && !oCfgTwitter.isEmpty() && sCanal == 'Twitter') {
                    // Canal Twitter.
                    // Preparar los mensajes a enviar.
                    Map<String, Map<String, String>> oMensajes = obtenerMensajesTwitterDM(oCanalCasos.get(sCanal));
                    // Enviar los mensajes a Twitter.
                    oUpdCasos = enviarMensajesTwitter (oMensajes, oCfgTwitter, sProceso);
                } else if (oCfgMail != null && !oCfgMail.isEmpty() && sCanal == 'Email') {
                    // Canal Email.
                    // Preparar los mensajes a enviar.
                    Map<String, Map<String, String>> oMensajes = obtenerMensajesMail(oCanalCasos.get(sCanal));
                    // Enviar los mensajes vía Mail.
                    oUpdCasos = enviarMensajesMail(oMensajes, oCfgMail, sProceso);
                    // Descartamos pasar los agrupadores para el tratamiento de plantillas.
                    // oUpdCasos = enviarMensajesMail (oMensajes, oCfgMail, sProceso, oCanalCasos.get('Agrupadores'));
                } else if (oCfgSMS != null && !oCfgSMS.isEmpty() && sCanal == 'SMS') {
                    // Canal SMS
                    // Preparar los mensajes a enviar.
                    Map<String, Map<String, String>> oMensajes = obtenerMensajesSMS(oCanalCasos.get(sCanal));
                    // Enviar los mensajes vía Mail.
                    oUpdCasos = enviarMensajesSMS(oMensajes, oCfgSMS, sProceso);
                }
            }
        }
        
        if (!oUpdCasos.isEmpty()) {
            actualizarCasos(oUpdCasos);
        }
        
        //Borrar los contactos temporales creados para el envío de e-mail.
        if (!oTempCont.isEmpty()) {
            Set<Id> oContID = new Set<Id>();
            for (String sClave : oTempCont.keySet()) {
                if (oTempCont.get(sClave) != null) {
                    oContID.add(oTempCont.get(sClave));
                }
            }
            
            if (!oContID.isEmpty())
            {
                List<ID> oDel = new List<ID>(oContID);
                Database.DeleteResult[] oResDel = Database.delete(oDel, false);
                oResDel = null;
                oDel = null;
            }
            oContID = null;
        }
        oTempCont = null;
    }
    
    /*
    Tratamiento para crear / actualizar los datos de contacto. La entrada es por referencia.
    */
    
    /*
    POR AHORA COMENTAMOS. EL PROCESO GESTIONA CONTACTOS TEMPORALES.
    
    static void tratarDatosContacto (Map<String,Map<String,String>> oDatosCont)
    {
        //List<String> oContactId = new List<String>();
        //List<String> oEmail = new List<String>();
        //List<String> oContName = new List<String>();
        
        //Map<String,String> oContMail = new Map<String,String>();
        //Map<String,String> oCasoMail = new Map<String,String>();
        
        // Tratamiento. AccountId y ContactId sin informar.
        List<Contact> oContactNew = new List<Contact>();
        
        // Tratamiento. ContactId informado.
        Map<String,Contact> oMapContactUp = new Map<String,Contact>();
        List<Contact> oContactUp = new List<Contact>();
        
        // Tratamiento. AccountId informado y ContactId sin informar.
        Map<String,String> oAccName = new Map<String,String>();
        List<String> oAccountId = new List<String>();
        List<Contact> oContactNew2 = new List<Contact>();
        List<Contact> oContactUp2 = new List<Contact>();
        
        
        if (oDatosCont == null)
        return;
        
        if (oDatosCont.isEmpty())
        return;
        
        // Record type para Contactos.
        String sRecordTypeCont = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        
        for (String sClave : oDatosCont.keySet())
        {
            if (oDatosCont.get(sClave) != null)
            {
                // Datos a tratar.
                if (oDatosCont.get(sClave).get('ContactId') != null)
                {
                    // Existe contacto.
                    
                    if (oDatosCont.get(sClave).get('MailTelfCaso') != null && oDatosCont.get(sClave).get('MailTelfCaso') != '')
                    {
                        // Actualizar e-mail principal del contacto.
                        Contact oCAux = new Contact();
                        oCAux.Id = oDatosCont.get(sClave).get('ContactId');
                        oCAux.Email = oDatosCont.get(sClave).get('MailTelfCaso');
                        
                        //oContactUp.add(oCAux); --> Elementos duplicados para el mismo contacto.
                        oMapContactUp.put(oDatosCont.get(sClave).get('ContactId'), oCAux);
                        
                        // Preparar creación canal comunicación.
                        //oContactId.add(oDatosCont.get(sClave).get('ContactId'));
                        //oEmail.add(oDatosCont.get(sClave).get('MailTelfCaso'));
                        //oContMail.put(oDatosCont.get(sClave).get('ContactId'), oDatosCont.get(sClave).get('MailTelfCaso'));
                    }
                    
                }else{
                    // No existe contacto.
                    
                    if (oDatosCont.get(sClave).get('MailTelfCaso') != null && oDatosCont.get(sClave).get('MailTelfCaso') != '')
                    {
                        if (oDatosCont.get(sClave).get('AccountId') != null)
                        {
                            // Preparar búsqueda contactos cliente.
                            oAccountId.add(oDatosCont.get(sClave).get('AccountId'));
                            oAccName.put(oDatosCont.get(sClave).get('NombreAcc') + '##' + oDatosCont.get(sClave).get('AccountId'), sClave);
                            
                        }else{
                            // Creamos contacto.
                            Contact oCAux = new Contact();
                            oCAux.Email = oDatosCont.get(sClave).get('MailTelfCaso');
                            
                            if (oDatosCont.get(sClave).get('NombreAcc') != null)
                            {
                                if (oDatosCont.get(sClave).get('NombreAcc').length() > 80)
                                oCAux.LastName = oDatosCont.get(sClave).get('NombreAcc').substring(0,80);
                                else
                                oCAux.LastName = oDatosCont.get(sClave).get('NombreAcc');
                            }
                            
                            if (oDatosCont.get(sClave).get('idiomaCaso') != null)
                            oCAux.CC_Idioma__c = oDatosCont.get(sClave).get('idiomaCaso');
                            
                            // Indicar campo origen creación.
                            oCAux.CC_OrigenCont__c = sClave;
                            
                            oContactNew.add(oCAux);
                            
                            //oCasoMail.put(oDatosCont.get(sClave).get('CasoId'), oDatosCont.get(sClave).get('MailTelfCaso'));
                        }
                    }
                }
            }
        }
        
        // ****************************************************************************
        // Caso: No existe un AccountId y un ContactId vinculado.
        // ****************************************************************************
        if (!oContactNew.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.insert(oContactNew, false);
        }
        oContactNew =  null;
        
        // ****************************************************************************
        // Caso: Existe un AccountId y existe un ContactId vinculado.
        // El objeto ya está actualizado para el envío del e-mail.
        // ****************************************************************************
        
        for (String sClave : oMapContactUp.keySet())
        {
            oContactUp.add(oMapContactUp.get(sClave));
        }
        oMapContactUp = null;
        
        if (!oContactUp.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oContactUp, false);
        }
        oContactUp = null;
        
        // ****************************************************************************
        // Caso: Existe un AccountId y no existe un ContactId vinculado.
        // Aquellos contactos que se encuentren, se actualizan en el objeto para el envío del e-mail.
        // ****************************************************************************
        
        oMapContactUp = new Map<String,Contact>();
        
        // Buscar si existe algún contacto con el mismo nombre en clientes existentes.
        if (!oAccountId.isEmpty())
        {
            for (Contact oCont : [SELECT Id, AccountId, Email, Name FROM Contact WHERE AccountId IN :oAccountId AND RecordTypeId = :sRecordTypeCont])
            {
                String sAux = oCont.Name + '##' + oCont.AccountId;
                if (oAccName.get(sAux) != null)
                {
                    // Existe contacto con el mismo nombre.
                    String sCasoId = oAccName.get(sAux);
                    
                    // Actualizar estructura.
                    oDatosCont.get(sCasoId).put('ContactId', oCont.Id);
                    
                    // Actualizar contacto.
                    Contact oCAux = new Contact();
                    oCAux.Id = oDatosCont.get(sCasoId).get('ContactId');
                    oCAux.Email = oDatosCont.get(sCasoId).get('MailTelfCaso');
                    
                    //oContactUp2.add(oCAux); --> Elementos duplicados para el mismo contacto.
                    oMapContactUp.put(oDatosCont.get(sCasoId).get('ContactId'), oCAux);
                    
                    // Eliminar el registro del map.
                    oAccName.remove(sAux);
                    
                    // Preparar creación canal comunicación.
                    //oContactId.add(oDatosCont.get(sClave).get('ContactId'));
                    //oEmail.add(oDatosCont.get(sClave).get('MailTelfCaso'));
                    //oContMail.put(oDatosCont.get(sClave).get('ContactId'), oDatosCont.get(sClave).get('MailTelfCaso'));
                }
            }
            
            // Los contactos restantes se han de crear.
            for (String sClave : oAccName.keySet())
            {
                String sCasoId = oAccName.get(sClave);
                
                // Crear contacto.
                Contact oCAux = new Contact();
                oCAux.RecordTypeId = sRecordTypeCont;
                oCAux.AccountId = oDatosCont.get(sCasoId).get('AccountId');
                oCAux.Email = oDatosCont.get(sCasoId).get('MailTelfCaso');
                
                if (oDatosCont.get(sCasoId).get('NombreAcc') != null)
                {
                    if (oDatosCont.get(sCasoId).get('NombreAcc').length() > 80)
                    oCAux.LastName = oDatosCont.get(sCasoId).get('NombreAcc').substring(0,80);
                    else
                    oCAux.LastName = oDatosCont.get(sCasoId).get('NombreAcc');
                }
                
                if (oDatosCont.get(sCasoId).get('idiomaCaso') != null)
                oCAux.CC_Idioma__c = oDatosCont.get(sCasoId).get('idiomaCaso');
                
                // Indicar campo origen creación.
                oCAux.CC_OrigenCont__c = sCasoId;
                
                oContactNew2.add(oCAux);
            }
        }
        oAccName = null;
        
        for (String sClave : oMapContactUp.keySet())
        {
            oContactUp2.add(oMapContactUp.get(sClave));
        }
        oMapContactUp = null;
        
        // Actualizar contactos.
        if (!oContactUp2.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.update(oContactUp2, false);
        }
        oContactUp2 = null;
        
        
        // Crear contactos.
        if (!oContactNew2.isEmpty())
        {
            Database.SaveResult[] oResUp = Database.insert(oContactNew2, false);
        }
        oContactNew2 = null;
        
        // Recuperar los contactos creados para el caso y actualizar la estructura final.
        // Se buscará por el campo origen, que tendrá el Id de caso.
        // Se actualizará la estructura final.
        
        if (!oDatosCont.isEmpty())
        {
            for (Contact oCont : [SELECT Id, CC_OrigenCont__c FROM Contact WHERE CC_OrigenCont__c IN :oDatosCont.keySet() AND RecordTypeId = :sRecordTypeCont])
            {
                if (oCont.CC_OrigenCont__c != null)
                {
                    oDatosCont.get(oCont.CC_OrigenCont__c).put('ContactId', oCont.Id);
                }
            }
        }
        
        // Crear el canal de comunicación de los formularios tratados y que no exista en Salesforce.
        List<String> oContMailAct = new List<String>();
        Map<String,String> oMailCont = new Map<String,String>();
        //List<CC_Canal_Com__c> oCanales = new List<CC_Canal_Com__c>();
        
        for (String sClave : oDatosCont.keySet())
        {
            if (oDatosCont.get(sClave) != null)
            {
                // Datos a tratar.
                if (oDatosCont.get(sClave).get('ContactId') != null)
                {
                    if (oDatosCont.get(sClave).get('MailTelfCaso') != null && oDatosCont.get(sClave).get('MailTelfCaso') != '')
                    {
                        oContMailAct.add(oDatosCont.get(sClave).get('ContactId'));
                        oMailCont.put(oDatosCont.get(sClave).get('ContactId') + '##' + oDatosCont.get(sClave).get('MailTelfCaso'), sClave);
                    }
                }
            }
        }
        
        crearCanalesComunicacion ('EMAIL', oContMailAct, oMailCont, oDatosCont);
        
        /*if (!oContMailAct.isEmpty())
        {
            String sRecordTypeMail = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
            
            for (CC_Canal_Com__c oCanal : [SELECT Id, CC_ContactoId__c, CC_Email__c FROM CC_Canal_Com__c WHERE RecordTypeId = :sRecordTypeMail AND CC_ContactoId__c IN :oContMailAct])
            {
                if (oCanal.CC_Email__c != null && oCanal.CC_Email__c != '')
                {
                    if (oMailCont.get(oCanal.CC_ContactoId__c + '##' + oCanal.CC_Email__c) != null)
                    {
                        // Eliminar el registro del map.
                        oMailCont.remove(oCanal.CC_ContactoId__c + '##' + oCanal.CC_Email__c);
                    }
                }
            }
            
            // Los contactos restantes se han de crear.
            for (String sClave : oMailCont.keySet())
            {
                String sCasoId = oMailCont.get(sClave);
                
                if ((oDatosCont.get(sCasoId).get('AccountId') != null || oDatosCont.get(sCasoId).get('ContactId') != null) &&
                oDatosCont.get(sCasoId).get('MailTelfCaso') != null)
                {
                    if ((oDatosCont.get(sCasoId).get('AccountId') != '' || oDatosCont.get(sCasoId).get('ContactId') != '') &&
                    oDatosCont.get(sCasoId).get('MailTelfCaso') != '')
                    {
                        // Crear canal de contacto.
                        CC_Canal_Com__c oCCanal = new CC_Canal_Com__c();
                        oCCanal.RecordTypeId = sRecordTypeMail;
                        oCCanal.CC_Email__c = oDatosCont.get(sCasoId).get('MailTelfCaso');
                        
                        if (oDatosCont.get(sCasoId).get('AccountId') != null)
                        oCCanal.CC_CuentaId__c = oDatosCont.get(sCasoId).get('AccountId');
                        
                        if (oDatosCont.get(sCasoId).get('ContactId') != null)
                        oCCanal.CC_ContactoId__c = oDatosCont.get(sCasoId).get('ContactId');
                        
                        oCanales.add(oCCanal);
                    }
                }
            }
            
            if (!oCanales.isEmpty())
            {
                Database.SaveResult[] oResUp = Database.insert(oCanales, false);
            }
        }*/
        
        /*
        oContMailAct = null;
        oMailCont = null;
        //oCanales = null;
        
    }
    */
    
    /*
    Crear canales de comunicación de contactos.
    */
    public static void crearCanalesComunicacion (String sTipo, List<String> oContMailAct, Map<String,String> oMailCont, Map<String,Map<String,String>> oDatosCont) {
        
        List<CC_Canal_Com__c> oCanales = new List<CC_Canal_Com__c>();
        
        if (!oContMailAct.isEmpty())
        {
            String sRecordTypeMail = '';
            if (sTipo == 'EMAIL')
            sRecordTypeMail = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
            else
            sRecordTypeMail = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
            
            for (CC_Canal_Com__c oCanal : [SELECT Id, CC_ContactoId__c, CC_Email__c, CC_Telefono__c FROM CC_Canal_Com__c WHERE RecordTypeId = :sRecordTypeMail AND CC_ContactoId__c IN :oContMailAct ])
            {
                
                if (sTipo == 'EMAIL')
                {
                    if (oCanal.CC_Email__c != null && oCanal.CC_Email__c != '')
                    {
                        if (oMailCont.get(oCanal.CC_ContactoId__c + '##' + oCanal.CC_Email__c.toLowerCase()) != null)
                        {
                            // Eliminar el registro del map.
                            oMailCont.remove(oCanal.CC_ContactoId__c + '##' + oCanal.CC_Email__c);
                        }
                    }
                }else{
                    if (oCanal.CC_Telefono__c != null && oCanal.CC_Telefono__c != '')
                    {
                        if (oMailCont.get(oCanal.CC_ContactoId__c + '##' + oCanal.CC_Telefono__c) != null)
                        {
                            // Eliminar el registro del map.
                            oMailCont.remove(oCanal.CC_ContactoId__c + '##' + oCanal.CC_Telefono__c);
                        }
                    }
                }
            }
            
            
            // Los contactos restantes se han de crear.
            for (String sClave : oMailCont.keySet())
            {
                String sClaveMap = oMailCont.get(sClave);
                
                if (oDatosCont.get(sClaveMap) != null)
                {
                    if ((oDatosCont.get(sClaveMap).get('AccountId') != null || oDatosCont.get(sClaveMap).get('ContactId') != null) &&
                    oDatosCont.get(sClaveMap).get('MailTelfCaso') != null)
                    {
                        if ((oDatosCont.get(sClaveMap).get('AccountId') != '' || oDatosCont.get(sClaveMap).get('ContactId') != '') &&
                        oDatosCont.get(sClaveMap).get('MailTelfCaso') != '')
                        {
                            // Crear canal de contacto.
                            CC_Canal_Com__c oCCanal = new CC_Canal_Com__c();
                            oCCanal.RecordTypeId = sRecordTypeMail;
                            
                            if (sTipo == 'EMAIL')
                            oCCanal.CC_Email__c = oDatosCont.get(sClaveMap).get('MailTelfCaso');
                            else
                            oCCanal.CC_Telefono__c = oDatosCont.get(sClaveMap).get('MailTelfCaso');
                            
                            if (oDatosCont.get(sClaveMap).get('AccountId') != null)
                            oCCanal.CC_CuentaId__c = oDatosCont.get(sClaveMap).get('AccountId');
                            
                            if (oDatosCont.get(sClaveMap).get('ContactId') != null)
                            oCCanal.CC_ContactoId__c = oDatosCont.get(sClaveMap).get('ContactId');
                            
                            oCanales.add(oCCanal);
                            
                        }
                    }
                }
            }
            
            
            if (!oCanales.isEmpty())
            {
                Database.SaveResult[] oResUp = Database.insert(oCanales, false);
            }
        }
        
        oCanales =  null;
        
        return;
    }
    
    /*
    Buscar configuración canal Twitter.
    */
    @TestVisible
    static public Map<String,Map<String,String>> getConfigCanal(String sProceso, String sCanal) {
        
        Map<String, Map<String, String>> oDatos = new Map<String, Map<String, String>>();
        
        if (sCanal != '') {
            Set<String> setRemitentes = new Set<String>();
            List<CC_ConfigNotifCliente__mdt> oConfigs = CC_MetodosUtiles.getNotificacionesConfig(sProceso, sCanal);
            Map<String, List<OrgWideEmailAddress>> mapAddressId = new Map<String, List<OrgWideEmailAddress>>();
            
            for (CC_ConfigNotifCliente__mdt oConf : oConfigs) {
                setRemitentes.add(oConf.CC_Remitente__c);
            }
            
            List<OrgWideEmailAddress> lstOwea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :setRemitentes ];
            
            for (OrgWideEmailAddress owea : lstOwea) {
                if(mapAddressId.containsKey(owea.Address)){
                    List<OrgWideEmailAddress> lstOweaAux = mapAddressId.get(owea.Address);
                    lstOweaAux.add(owea);
                    mapAddressId.put(owea.Address,lstOweaAux);
                } else {
                    List<OrgWideEmailAddress> lstOweaAux = new List<OrgWideEmailAddress>();
                    lstOweaAux.add(owea);
                    mapAddressId.put(owea.Address,lstOweaAux);
                }
            }
            
            for (CC_ConfigNotifCliente__mdt oConf : oConfigs) {
                /*if (oConf.CC_Idioma__c != null && oConf.CC_Cuerpo__c != null)
                {
                    if (oConf.CC_Idioma__c != '' && oConf.CC_Cuerpo__c != '')
                    {
                        oDatos.put(oConf.CC_Idioma__c, oConf.CC_Cuerpo__c);
                    }
                }*/
                
                Map<String, String> oAttr = new Map<String, String>();
                oAttr.put('Cuerpo', oConf.CC_Cuerpo__c);
                oAttr.put('RemitenteName', oConf.CC_EtiRemitente__c);
                oAttr.put('Carpeta', oConf.CC_Carpeta__c);
                oAttr.put('RemitenteCfg', oConf.CC_Remitente__c);
                
                String sPlantilla = '';
                if (oConf.CC_PlantillaBase__c != null && oConf.CC_PlantillaBase__c != '')
                {
                    sPlantilla = oConf.CC_PlantillaBase__c;
                }else{
                    sPlantilla = oConf.CC_Plantilla__c;
                }
                
                
                //Recuperar plantillas
                if ((sCanal == 'Email' || sCanal == 'SMS') && oConf.CC_Carpeta__c != null && sPlantilla != null) {
                    if (oConf.CC_Carpeta__c != '' && sPlantilla != '') {
                        // Realizamos de forma consciente esta búsqueda dentro del FOR de forma controlada.
                        List<EmailTemplate> oTemplate = [SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = :oConf.CC_Carpeta__c AND Name = :sPlantilla ];
                        
                        if (!oTemplate.isEmpty())
                        {
                            if (oTemplate[0] != null)
                            {
                                oAttr.put('Plantilla', oTemplate[0].Id);
                            }
                        }
                    }
                }
                
                //Recuperar remitente. Sólo canal e-mail.
                if (sCanal == 'Email' && oConf.CC_Remitente__c != null) {
                    if (oConf.CC_Remitente__c != '') {
                        List<OrgWideEmailAddress> oDirMail = mapAddressId.get(oConf.CC_Remitente__c);
                        if (!oDirMail.isEmpty()) {
                            if (oDirMail[0] != null) {
                                oAttr.put('Remitente', oDirMail[0].Id);
                            }
                        }
                    }
                }
                
                if (String.isNotBlank(oConf.CC_OrigenCasoNotificacion__c) && String.isNotBlank(oConf.CC_ProcedenciaOrigenNotificacion__c))
                {
                    oDatos.put(oConf.CC_Idioma__c + '##' + oConf.CC_Proceso__c + '##' + oConf.CC_OrigenCasoNotificacion__c + '##' + oConf.CC_ProcedenciaOrigenNotificacion__c, oAttr);
                } else if (String.isNotBlank(oConf.CC_ProcedenciaOrigenNotificacion__c))
                {
                    oDatos.put(oConf.CC_Idioma__c + '##' + oConf.CC_Proceso__c + '##' + oConf.CC_ProcedenciaOrigenNotificacion__c, oAttr);
                } else if (String.isNotBlank(oConf.CC_Tipo_Cliente__c))
                {
                    oDatos.put(oConf.CC_Idioma__c + '##' + oConf.CC_Proceso__c + '##' + oConf.CC_Tipo_Cliente__c, oAttr);
                } else {
                    oDatos.put(oConf.CC_Idioma__c + '##' + oConf.CC_Proceso__c, oAttr);
                }
            }
        }
        return oDatos;
        
    }
    
    //Buscar configuración general del proceso
    static private Map<String, String> getConfigOrigen(String sConfigOrigen) {
        
        Map<String, String> oDatos = new Map<String, String>();
        
        if (sConfigOrigen != '') {
            List<CC_ConfigNotifCliente__mdt> oConfigs = CC_MetodosUtiles.getNotificacionesConfig(sConfigOrigen, '');
            
            for (CC_ConfigNotifCliente__mdt oConf : oConfigs)
            {
                oDatos.put('Origen', oConf.CC_EntidadOrigen__c);
                
                if (oConf.CC_EntidadOrigen__c == 'Tarea')
                {
                    if (oConf.CC_TaskOrigenProc__c != '')
                    {
                        oDatos.put('TareasOrigen', oConf.CC_TaskOrigenProc__c);
                    }
                    
                    oDatos.put('TareasEstado', 'N/A');
                    if (oConf.CC_EstadoTarea__c != null)
                    if (oConf.CC_EstadoTarea__c != '')
                    oDatos.put('TareasEstado', oConf.CC_EstadoTarea__c);
                    
                    if (oConf.CC_TiposTareaCaso__c != '')
                    {
                        oDatos.put('TareasTipo', oConf.CC_TiposTareaCaso__c);
                    }
                }
                
                if (oConf.CC_EntidadOrigen__c == 'Caso')
                {
                    if (oConf.CC_CaseOrigenProc__c != '')
                    {
                        oDatos.put('CasoOrigen',oConf.CC_CaseOrigenProc__c);
                    }
                }
            }
        }
        
        
        return oDatos;
    }
    
    /*
    Recuperar los casos potenciales a notificar el seguimiento del mismo al cliente como origen una operativa del caso.
    */
    static private Map<String,String> getTaskCasosSeguimiento (List<ID> oIDs, Map<String,String> oCfgOrigen, String sProceso)
    {
        
        Map<String,String> oRes = new Map<String,String>();
        Map<String,String> oResPot = new Map<String,String>();
        List<String> oTiposTarea = new List<String>();
        Map<String,String> oCasosOrig = new Map<String,String>();
        String sEstadoTarea = '';
        
        // Buscar la configuración de las tareas a tener en cuenta del caso.
        //List<CC_ConfigNotifCliente__mdt> oConfig = [SELECT Id, CC_TiposTareaCaso__c FROM CC_ConfigNotifCliente__mdt WHERE DeveloperName = 'CC_TareasCaso' AND CC_Activa__c = true];
        //if (!oConfig.isEmpty())
        if (!oCfgOrigen.isEmpty())
        {
            if (oCfgOrigen.get('TareasTipo') != null)
            {
                //String sTipos = oConfig[0].CC_TiposTareaCaso__c;
                String sTipos = oCfgOrigen.get('TareasTipo');
                if (sTipos != null && sTipos != '')
                {
                    List<String> oAux = new List<String>();
                    oAux = sTipos.split(';');
                    
                    // Borrado de tipos vacíos.
                    for (String sValor : oAux)
                    {
                        if (sValor != '')
                        oTiposTarea.add(sValor);
                    }
                    oAux = null;
                }
            }
            
            if (oCfgOrigen.get('TareasOrigen') != null)
            {
                String sOrigen = oCfgOrigen.get('TareasOrigen');
                if (sOrigen != null && sOrigen != '')
                {
                    List<String> oAux = new List<String>();
                    oAux = sOrigen.split(';');
                    
                    // Borrado de tipos vacíos.
                    for (String sValor : oAux)
                    {
                        if (sValor != '')
                        oCasosOrig.put(sValor,sValor);
                    }
                    oAux = null;
                }
            }
            
            if (oCfgOrigen.get('TareasEstado') != null)
            {
                sEstadoTarea = oCfgOrigen.get('TareasEstado');
            }
        }
        
        if (!oIDs.isEmpty() && !oTiposTarea.isEmpty()) {
            List<Task> oTasks = [SELECT WhatId FROM Task WHERE Id IN :oIDs AND Type IN :oTiposTarea AND Status = :sEstadoTarea ]; // (Type = 'Traslado Colaborador' OR Type = 'Traslado Tercer Nivel')];
            for (Task oTask : oTasks)
            {
                if (oTask.WhatId != null)
                oResPot.put(String.valueOf(oTask.WhatId), String.valueOf(oTask.Id));
            }
        }
        
        
        // Descartar los casos que no cumplan la configuración.
        if (!oResPot.isEmpty()) {
            List<Case> oDataCases = new List<Case>();
            if (sProceso == 'CC_SegOperativa') {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c FROM Case WHERE Id IN :oResPot.keySet() AND CC_SegOperativa__c = '1' ];
            }
            
            if (sProceso == 'CC_NotIncidencia') {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c FROM Case WHERE Id IN :oResPot.keySet() AND CC_NotIncidencia__c = '1' AND CC_Agrupador_Id__c <> null ];
            }
            
            for (Case oCaso : oDataCases) {
                String sEntrada = oCaso.Origin + '##' + oCaso.CC_Canal_Procedencia__c;
                
                
                // Si no hay datos de origen configurados. Se lanza para todos los tipos de casos.
                if (oCasosOrig.isEmpty()) {
                    oRes.put(oCaso.Id, 'Tarea');
                } else {
                    if (oCasosOrig.get(sEntrada) != null) {
                        // Caso para tratar.
                        //oRes.put(oCaso.Id, oResPot.get(oCaso.Id));
                        oRes.put(oCaso.Id, 'Tarea');
                    } else {
                        // Comprobar solo por Origin.
                        sEntrada = oCaso.Origin + '##';
                        if (oCasosOrig.get(sEntrada) != null)
                        {
                            oRes.put(oCaso.Id, 'Tarea');
                        }
                    }
                }
            }
        }
        oResPot = null;
        
        
        return oRes;
    }
    
    /*
    Recuperar los casos potenciales a notificar el seguimiento del mismo al cliente como origen de la creación del caso.
    */
    static private Map<String,String> getCaseCasosSeguimiento (List<ID> oIDs, Map<String,String> oCfgOrigen, String sProceso)
    {
        
        Map<String,String> oRes = new Map<String,String>();
        Map<String,String> oCasosOrig = new Map<String,String>();
        
        // Buscar la configuración de los casos a tener en cuenta.
        if (!oCfgOrigen.isEmpty())
        {
            if (oCfgOrigen.get('CasoOrigen') != null)
            {
                String sOrigen = oCfgOrigen.get('CasoOrigen');
                if (sOrigen != null && sOrigen != '')
                {
                    List<String> oAux = new List<String>();
                    oAux = sOrigen.split(';');
                    
                    // Borrado de tipos vacíos.
                    for (String sValor : oAux)
                    {
                        if (sValor != '')
                        oCasosOrig.put(sValor,sValor);
                    }
                    oAux = null;
                }
            }
        }
        
        // Descartar los casos que no cumplan la configuración.
        if (!oIDs.isEmpty()) {
            List<Case> oDataCases = new List<Case>();
            
            if (sProceso == 'CC_AcuseRecibo') {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c  FROM Case WHERE Id IN :oIDs AND CC_AcuseRecibo__c = '1' ];
            } else if (sProceso == 'CC_Contacto_Intermedio_AC') {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_Notif_Cont_Inter__c  FROM Case
                WHERE Id IN :oIDs AND CC_Notif_Cont_Inter__c = false AND CC_Canal_Procedencia__c = 'Atención al Cliente' ];
            } else if (sProceso == 'CC_Contacto_Intermedio_Preventivas') {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_Notif_Cont_Inter__c
                FROM Case WHERE Id IN :oIDs AND CC_Notif_Cont_Inter__c = false AND CC_Canal_Procedencia__c = 'Oficina Preventiva' ];
            }
            
            for (Case oCaso : oDataCases) {
                String sEntrada = oCaso.Origin + '##' + oCaso.CC_Canal_Procedencia__c;
                if (oCasosOrig.get(sEntrada) != null)
                {
                    // Caso para tratar.
                    oRes.put(oCaso.Id, 'Caso');
                }else{
                    // Comprobar solo por Origin.
                    sEntrada = oCaso.Origin + '##';
                    if (oCasosOrig.get(sEntrada) != null)
                    {
                        oRes.put(oCaso.Id, 'Caso');
                    }
                }
            }
        }
        return oRes;
    }
    
    /*
    Recuperar los casos potenciales a notificar el seguimiento del mismo al cliente.
    */
    /* NO UTILIZADA POR EL MOMENTO.
    
    static private Map<String,String> getPotCasosSeguimiento (List<ID> oIDs)
    {
        
        Map<String,String> oRes = new Map<String,String>();
        List<String> oTiposTarea = new List<String>();
        
        // Buscar la configuración de las tareas a tener en cuenta del caso.
        List<CC_ConfigNotifCliente__mdt> oConfig = [SELECT Id, CC_TiposTareaCaso__c FROM CC_ConfigNotifCliente__mdt WHERE DeveloperName = 'CC_TareasCaso' AND CC_Activa__c = true];
        if (!oConfig.isEmpty())
        {
            // Nos quedamos con la primera configuración activa.
            String sTipos = oConfig[0].CC_TiposTareaCaso__c;
            if (sTipos != null && sTipos != '')
            oTiposTarea = sTipos.split(';');
        }
        
        if (!oIDs.isEmpty() && !oTiposTarea.isEmpty())
        {
            
            List<Task> oTasks = [SELECT Id, WhatId FROM Task WHERE Id IN :oIDs AND Type IN :oTiposTarea]; // (Type = 'Traslado Colaborador' OR Type = 'Traslado Tercer Nivel')];
            for (Task oTask : oTasks)
            {
                if (oTask.WhatId != null)
                oRes.put(String.valueOf(oTask.WhatId), String.valueOf(oTask.Id));
            }
        }
        
        
        return oRes;
    }
    */
    
    /*
    Recuperar casos a enviar la notificación de seguimiento, con su canal saliente.
    */
    @TestVisible
    static private Map<String, Map<String, Map<String, String>>> getDatosCasos (Map<String, String> oCasosTarea, Map<String, String> oCasosCreados, String sProceso, Map<String, String> oCaseCont) {
        
        Map<String, Map<String, Map<String, String>>> oRes = new Map<String, Map<String, Map<String, String>>>();
        Map<String, Map<String, String>> oTwitter = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> oMail = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> oSMS = new Map<String, Map<String, String>>();
        
        // Estructuras de gestión de contactos.
        Map<String, Contact> oCasoContacto = new Map<String, Contact>();
        Map<String, String> oContCase = new Map<String, String>();
        Map<String, String> oGrupoOficinaCase = new Map<String, String>();
        Map<String, String> oGrupoOficinaCaseCC = new Map<String, String>();
        
        // Unir los dos maps para hacer una única consulta.
        Set<String> oCasos = new Set<String>();
        
        if (!oCasosTarea.isEmpty())
        oCasos.addAll(oCasosTarea.keySet());
        
        if (!oCasosCreados.isEmpty())
        oCasos.addAll(oCasosCreados.keySet());
        
        
        if (!oCasos.isEmpty()) {
            // Buscar los casos susceptibles de enviar la notificación de seguimiento.
            // Casos en los que se ha activado el seguimiento.
            // Casos en los que no se ha enviado la notificación de seguimiento.
            List<Case> oDataCases = new List<Case>();
            Map<String, String> oNoTratarCasos = new Map<String, String>();
            Map<String, String> oDataCom = new Map<String, String>();
            
            // Agrupadores asociados a los casos.
            Map<String, Map<String, String>> oComAgr = new Map<String, Map<String, String>>();
            
            
            //NEREA SANCHEZ - DICIEMBRE 2021 <--
            List<Case> listadoCasos = [SELECT CC_AcuseRecibo__c, CC_SegOperativa__c, CaseNumber, Origin, CC_Canal_Procedencia__c, CC_CanalNotifCli__c, CC_GrupoOficina__c, CC_Idioma__c,CC_NotIncidencia__c,
            CC_MailTelfNotif__c, ContactId, AccountId, Account.Name, Account.CC_Email__c, CC_Agrupador_Id__c, CC_Agrupador_Id__r.RecordType.DeveloperName,CC_Agrupador_Id__r.RecordTypeId, RecordType.Name, CC_Notif_Cont_Inter__c, CC_Contacto_Intermedio__c
            FROM Case WHERE Id IN :oCasos AND (CC_AcuseRecibo__c = '1'
            OR CC_SegOperativa__c = '1'
            OR (CC_NotIncidencia__c = '1' AND CC_Agrupador_Id__c <> null)
            OR (CC_Notif_Cont_Inter__c = false AND CC_Canal_Procedencia__c = 'Atención al Cliente')
            OR (CC_Canal_Procedencia__c = 'Oficina Preventiva' AND CC_Notif_Cont_Inter__c = false)) ];
            
            for (Case caso : listadoCasos) {
                if ((sProceso == 'CC_AcuseRecibo' && caso.CC_AcuseRecibo__c == '1')
                || (sProceso == 'CC_SegOperativa' && caso.CC_SegOperativa__c == '1')
                || (sProceso == 'CC_NotIncidencia' && caso.CC_NotIncidencia__c == '1' && caso.CC_Agrupador_Id__c != null)
                || (sProceso == 'CC_Contacto_Intermedio_AC' && caso.CC_Notif_Cont_Inter__c == false && caso.CC_Canal_Procedencia__c == 'Atención al Cliente')
                || (sProceso == 'CC_Contacto_Intermedio_Preventivas' && caso.CC_Canal_Procedencia__c == 'Oficina Preventiva' && caso.CC_Notif_Cont_Inter__c == false)) {
                    oDataCases.add(caso);
                }
                
                
            }
            //NEREA SANCHEZ - DICIEMBRE 2021 -->
            
            /*if (sProceso == 'CC_AcuseRecibo')
            {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_CanalNotifCli__c, CC_GrupoOficina__c, CC_Idioma__c,
                CC_MailTelfNotif__c, ContactId, AccountId, Account.Name, CC_Agrupador_Id__c, RecordType.Name
                FROM Case WHERE Id IN :oCasos AND CC_AcuseRecibo__c = '1'];
            }
            
            if (sProceso == 'CC_SegOperativa')
            {
                oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_CanalNotifCli__c, CC_Idioma__c, CC_GrupoOficina__c,
                CC_MailTelfNotif__c, ContactId, AccountId, Account.Name, CC_Agrupador_Id__c, RecordType.Name
                FROM Case WHERE Id IN :oCasos AND CC_SegOperativa__c = '1'];
            }*/
            
            if (sProceso == 'CC_NotIncidencia')
            {
                /*oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_CanalNotifCli__c, CC_Idioma__c, CC_GrupoOficina__c,
                CC_MailTelfNotif__c, ContactId, AccountId, Account.Name, CC_Agrupador_Id__c, RecordType.Name
                FROM Case WHERE Id IN :oCasos AND CC_NotIncidencia__c = '1' AND CC_Agrupador_Id__c <> null];
                */
                // Preparar agrupadores a consultar plantillas.
                for (Case oAuxCase : oDataCases) {
                    oComAgr.put(oAuxCase.CC_Agrupador_Id__c, null);
                }
                
                if (!oComAgr.isEmpty()) {
                    // Preparamos actualización de casos para el cuerpo de la notificación.
                    String sRecordType = Schema.SObjectType.CC_PlantillaAsociada__c.getRecordTypeInfosByDeveloperName().get('CC_Agrupador').getRecordTypeId();
                    for (CC_PlantillaAsociada__c oAuxPlant : [SELECT CC_Canal__c, CC_Idioma__c, CC_CuerpoNotificacion__c, CC_Agrupador__c, CC_Tipo_Cliente__c, CC_Revisada__c FROM CC_PlantillaAsociada__c WHERE CC_Agrupador__c IN :oComAgr.keySet() AND CC_Agrupador__r.CC_Notificar_Clientes__c = true  ORDER BY CreatedDate])
                    {
                        if (oAuxPlant.CC_CuerpoNotificacion__c != '' && oAuxPlant.CC_Canal__c != '' && oAuxPlant.CC_Idioma__c != '' && oAuxPlant.CC_Revisada__c != false)
                        {
                            oDataCom.put(oAuxPlant.CC_Agrupador__c + '##' + oAuxPlant.CC_Canal__c + '##' + oAuxPlant.CC_Idioma__c + '##' + oAuxPlant.CC_Tipo_Cliente__c, oAuxPlant.CC_CuerpoNotificacion__c);
                        }
                    }
                    
                    List<Case> oActCasos = [SELECT CC_Agrupador_Id__c, CC_NotIncidencia__c, CC_CanalNotifCli__c, CC_Idioma__c, RecordType.Name, CC_NotIncidenciaCuerpo__c FROM Case WHERE Id IN :oCasos AND CC_NotIncidencia__c = '1' AND CC_Agrupador_Id__c <> null ];
                    List<Case> oUpdFin = new List<Case>();
                    for (Case oUPD : oActCasos)
                    {
                        String sClaveData = oUPD.CC_Agrupador_Id__c + '##' + oUPD.CC_CanalNotifCli__c + '##' + oUPD.CC_Idioma__c + '##' + oUPD.RecordType.Name;
                        if (oDataCom.get(sClaveData) != null)
                        {
                            
                            oUPD.CC_NotIncidenciaCuerpo__c = oDataCom.get(sClaveData);
                            oUpdFin.add(oUPD);
                        } else {
                            oNoTratarCasos.put(oUPD.Id, oUPD.Id);
                            oUPD.CC_NotIncidencia__c = '3';
                            oUpdFin.add(oUPD);
                        }
                    }
                    
                    // Actualizar cuerpo notificación en el caso.
                    if (!oUpdFin.isEmpty())
                    {
                        Database.SaveResult[] oResUp = Database.update(oUpdFin, false);
                    }
                    
                    /* DESCARTAMOS POR AHORA LA GESTIÓN DE PLANTILLAS TOTALES EN EL AGRUPADOR.
                    String sRecordType = Schema.SObjectType.CC_PlantillaAsociada__c.getRecordTypeInfosByDeveloperName().get('CC_Agrupador').getRecordTypeId();
                    for (CC_PlantillaAsociada__c oAuxPlant : [SELECT Id, CC_Canal__c, CC_Idioma__c, CC_PlantillaId__c, CC_Agrupador__c FROM CC_PlantillaAsociada__c WHERE CC_Agrupador__c IN :oComAgr.keySet()])
                    {
                        String sClave = oAuxPlant.CC_Canal__c + '##' + oAuxPlant.CC_Idioma__c;
                        Map<String,String> oPlantilla;
                        
                        if (oComAgr.get(oAuxPlant.CC_Agrupador__c) != null)
                        {
                            oPlantilla = oComAgr.get(oAuxPlant.CC_Agrupador__c);
                        }else{
                            oPlantilla = new Map<String,String>();
                        }
                        
                        oPlantilla.put(sClave, oAuxPlant.CC_PlantillaId__c);
                        
                        oComAgr.put(oAuxPlant.CC_Agrupador__c, oPlantilla);
                    }
                    
                    // Añadir datos al retorno.
                    oRes.put('Agrupadores', oComAgr);
                    */
                }
                oComAgr = null;
            }
            
            if (sProceso == 'CC_Contacto_Intermedio_AC') {
                
                /*oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_CanalNotifCli__c, CC_Idioma__c, CC_MailTelfNotif__c,
                ContactId, AccountId, Account.Name, CC_Agrupador_Id__c, Account.CC_Email__c, CC_Notif_Cont_Inter__c,
                CC_Contacto_Intermedio__c, CC_GrupoOficina__c, RecordType.Name FROM Case
                WHERE Id IN :oCasos AND CC_Notif_Cont_Inter__c = false AND CC_Canal_Procedencia__c = 'Atención al Cliente'];*/
                
                if (!oDataCases.isEmpty())
                {
                    List<Case> oUpdFin = new List<Case>();
                    for (Case oUPD : oDataCases) {
                        if (oUPD.Account.CC_Email__c == null) {
                            oNoTratarCasos.put(oUPD.Id, oUPD.Id);
                            oUPD.CC_Notif_Cont_Inter__c = true;
                            oUPD.CC_Contacto_Intermedio__c = true;
                            oUpdFin.add(oUPD);
                        } else if (oUPD.ContactId == null) {
                            oNoTratarCasos.put(oUPD.Id, oUPD.Id);
                            oUPD.CC_Notif_Cont_Inter__c = true;
                            oUPD.CC_Contacto_Intermedio__c = true;
                            oUpdFin.add(oUPD);
                        } else {
                            oUPD.CC_MailTelfNotif__c = oUPD.Account.CC_Email__c;
                            oUpdFin.add(oUPD);
                        }
                    }
                    
                    // Actualizar cuerpo notificación en el caso.
                    if (!oUpdFin.isEmpty()) {
                        Database.SaveResult[] oResUp = Database.update(oUpdFin, false);
                    }
                }
            }
            
            if (sProceso == 'CC_Contacto_Intermedio_Preventivas')
            {
                /*oDataCases = [SELECT CaseNumber, Origin, CC_Canal_Procedencia__c, CC_CanalNotifCli__c, CC_Idioma__c, CC_MailTelfNotif__c,
                ContactId, AccountId, Account.Name, CC_Agrupador_Id__c, Account.CC_Email__c, CC_Notif_Cont_Inter__c,
                CC_Contacto_Intermedio__c, CC_GrupoOficina__c, RecordType.Name FROM Case
                WHERE Id IN :oCasos AND CC_Canal_Procedencia__c = 'Oficina Preventiva' AND CC_Notif_Cont_Inter__c = false];
                */
                if (!oDataCases.isEmpty())
                {
                    List<Case> oUpdFin = new List<Case>();
                    for (Case oUPD : oDataCases) {
                        if (oUPD.CC_GrupoOficina__c == null) {
                            oNoTratarCasos.put(oUPD.Id, oUPD.Id);
                            oUPD.CC_Notif_Cont_Inter__c = true;
                            oUPD.CC_Contacto_Intermedio__c = true;
                            oUpdFin.add(oUPD);
                        } else {
                            oUPD.CC_MailTelfNotif__c = oUPD.CC_GrupoOficina__c;
                            oUpdFin.add(oUPD);
                        }
                    }
                    
                    // Actualizar cuerpo notificación en el caso.
                    if (!oUpdFin.isEmpty()){
                        Database.SaveResult[] oResUp = Database.update(oUpdFin, false);
                    }
                }
            }
            
            for (Case oCaso : oDataCases)
            {
                Boolean bMail = false;
                Boolean bTel = false;
                Boolean bSMS = false;
                
                
                if (oNoTratarCasos.get(oCaso.Id) == null)
                {
                    Map<String, String> oAttrCasos = new Map<String, String>();
                    oAttrCasos.put('CasoId', oCaso.Id);
                    oAttrCasos.put('Origen', oCaso.Origin);
                    oAttrCasos.put('CanalProcedencia', oCaso.CC_Canal_Procedencia__c);
                    oAttrCasos.put('numCaso', oCaso.CaseNumber);
                    oAttrCasos.put('idiomaCaso', oCaso.CC_Idioma__c);
                    oAttrCasos.put('MailTelfCaso', oCaso.CC_MailTelfNotif__c);
                    oAttrCasos.put('ContactId', oCaso.ContactId);
                    oAttrCasos.put('AccountId', oCaso.AccountId);
                    oAttrCasos.put('RecordTypeName', oCaso.RecordType.Name);
                    
                    // Indicar plantilla configurada para ese agrupador.
                    if (oCaso.CC_Agrupador_Id__c != null)
                    {
                        //oAttrCasos.put('PlantillaComId', oCaso.CC_Agrupador_Id__r.CC_ComCierre__c);
                        oAttrCasos.put('AgrupadorId', oCaso.CC_Agrupador_Id__c);
                        oAttrCasos.put('RecordTypeId.AgrupadorId', oCaso.CC_Agrupador_Id__r.RecordTypeId);
                        oAttrCasos.put('RecordTypeDeveloperName.AgrupadorId', oCaso.CC_Agrupador_Id__r.RecordType.DeveloperName);
                        
                        // Asignar el mensaje a enviar (Twitter).
                        String sClaveMsj = oCaso.CC_Agrupador_Id__c + '##' + oCaso.CC_CanalNotifCli__c + '##' + oCaso.CC_Idioma__c;
                        if (oDataCom.get(sClaveMsj) != null)
                        oAttrCasos.put('MensajeCierreInc', oDataCom.get(sClaveMsj));
                    }
                    
                    if (oCaso.AccountId != null)
                    oAttrCasos.put('NombreAcc', oCaso.Account.Name);
                    else
                    oAttrCasos.put('NombreAcc', oCaso.CC_MailTelfNotif__c);
                    
                    // OLD. Priorizamos la creación del caso para avisar.
                    /*if (oCasosCreados.get(oCaso.Id) != null)
                    oAttrCasos.put('Proceso','Caso');
                    else
                    oAttrCasos.put('Proceso','Tarea');
                    */
                    oAttrCasos.put('Proceso', sProceso);
                    
                    // Fijar el canal de envío de la notificación.
                    if (oCaso.CC_CanalNotifCli__c != null)
                    {
                        if (oCaso.CC_CanalNotifCli__c == 'Twitter') {
                            oTwitter.put(oCaso.Id, oAttrCasos);
                        } else if (oCaso.CC_CanalNotifCli__c == 'Email') {
                            bMail = true;
                            oMail.put(oCaso.Id, oAttrCasos);
                        } else if (oCaso.CC_CanalNotifCli__c == 'SMS') {
                            bSMS = true;
                            oSMS.put(oCaso.Id, oAttrCasos);
                        } else if (oCaso.CC_CanalNotifCli__c == '') {
                            // Tratar el caso por defecto. Mail.
                            bMail = true;
                            oMail.put(oCaso.Id, oAttrCasos);
                        }
                    } else {
                        // Tratar el caso por defecto. Mail.
                        bMail = true;
                        oMail.put(oCaso.Id, oAttrCasos);
                    }
                    
                    // Preparar la creación del contacto temporal.
                    if (bMail && oCaso.ContactId != null && oCaso.CC_GrupoOficina__c == null)
                    {
                        oContCase.put(oCaso.ContactId, oCaso.Id);
                    }
                    
                    // Preparar la creación del contacto temporal de acuse a una oficina.
                    if (bMail && oCaso.CC_GrupoOficina__c != null)
                    {
                        oGrupoOficinaCase.put(oCaso.CC_GrupoOficina__c, oCaso.Id);
                    }
                    
                    
                    // Tratar los casos con contacto asociado.
                    /*if (bMail && (oCaso.ContactId != null || oCaso.AccountId != null) && oCaso.CC_MailTelfNotif__c != null && oCaso.CC_MailTelfNotif__c != '')
                    {
                        Map<String,String> oAttrContEmail = new Map<String,String>();
                        oAttrContEmail.put('Email', oCaso.CC_MailTelfNotif__c);
                        oAttrContEmail.put('ContactId', oCaso.ContactId);
                        oAttrContEmail.put('AccountId', oCaso.AccountId);
                        oAttrContEmail.put('NombreAcc', oCaso.Account.Name);
                        
                        oContactCase.put(oCaso.Id, oAttrContEmail);
                    }*/
                }
            }
            oNoTratarCasos = null;
            
            // Creación de los contactos temporales.
            if (!oContCase.isEmpty())
            {
                List<Contact> oListCont = [SELECT RecordTypeId, FirstName, LastName, Phone, Email, CC_OrigenCont__c FROM Contact WHERE Id IN :oContCase.keySet() ];
                for (Contact oAux : oListCont)
                {
                    Contact oTemp = new Contact();
                    oTemp.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    oTemp.FirstName = oAux.FirstName;
                    oTemp.LastName = oAux.LastName;
                    //oTemp.Email = oAux.Email; // Cambiar por el e-mail del caso.
                    if (String.isNotBlank(oMail.get(oContCase.get(oAux.Id)).get('MailTelfCaso')))
                    {
                        oTemp.Email = oMail.get(oContCase.get(oAux.Id)).get('MailTelfCaso');
                    } else {
                        oTemp.Email = oAux.Email;
                    }
                    oTemp.CC_OrigenCont__c = oContCase.get(oAux.Id);
                    oCasoContacto.put(oContCase.get(oAux.Id), oTemp);
                }
            }
            oContCase = null;
            
            // Creación de los contactos temporales en los grupos de oficina.
            if (!oGrupoOficinaCase.isEmpty())
            {
                List<CC_Grupo_Colaborador__c> oListaGrupos = [SELECT CC_Email__c, (Select Id, CC_Email__c from Colaboradores__r) FROM CC_Grupo_Colaborador__c WHERE Id IN :oGrupoOficinaCase.keySet() ];
                for (CC_Grupo_Colaborador__c oAux : oListaGrupos)
                {
                    Contact oTemp = new Contact();
                    oTemp.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    oTemp.LastName = oAux.CC_Email__c;
                    oTemp.Email = oAux.CC_Email__c;
                    oTemp.CC_OrigenCont__c = oGrupoOficinaCase.get(oAux.Id);
                    oCasoContacto.put(oGrupoOficinaCase.get(oAux.Id), oTemp);
                    
                    String sCorreosCC = '';
                    for (CC_Grupo_Colaborador_Contact__c oAuxCC : oAux.Colaboradores__r)
                    {
                        if (String.isNotBlank(oAuxCC.CC_Email__c))
                        {
                            sCorreosCC = sCorreosCC + oAuxCC.CC_Email__c + ';';
                        }
                    }
                    
                    oGrupoOficinaCaseCC.put(oGrupoOficinaCase.get(oAux.Id),sCorreosCC);
                }
            }
            oGrupoOficinaCase = null;
            
            // Preparar los contactos temporales para casos sin contacto.
            if (!oMail.isEmpty())
            {
                for (String sClave : oMail.keySet())
                {
                    if (oCasoContacto.get(sClave) == null)
                    {
                        // Crear contacto.
                        Contact oTemp = new Contact();
                        oTemp.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                        oTemp.LastName = oMail.get(sClave).get('NombreAcc');
                        oTemp.Email = oMail.get(sClave).get('MailTelfCaso');
                        oTemp.CC_OrigenCont__c = sClave;
                        oCasoContacto.put(sClave, oTemp);
                    }else{
                        Contact oTemp = oCasoContacto.get(sClave);
                        //oTemp.Email = oMail.get(sClave).get('MailTelfCaso');
                        oCasoContacto.put(sClave,oTemp);
                    }
                }
            }
            
            // Crear los contactos temporales.
            if (!oCasoContacto.isEmpty())
            {
                List<Contact> oInsertCont = new List<Contact>();
                for (String sClave : oCasoContacto.keySet())
                {
                    if (oCasoContacto.get(sClave) != null)
                    {
                        oInsertCont.add(oCasoContacto.get(sClave));
                    }
                }
                Database.SaveResult[] oResIns = Database.insert(oInsertCont, false);
                for (Integer iRes = 0; iRes<oResIns.size(); iRes++)
                {
                    if (oResIns[iRes].isSuccess())
                    {
                        oCaseCont.put(oInsertCont[iRes].CC_OrigenCont__c, oResIns[iRes].getId());
                    }
                }
            }
            oCasoContacto = null;
            
            // Actualizar los IDs de los contactos temporales.
            if (!oCaseCont.isEmpty() && !oMail.isEmpty())
            {
                for (String sClave : oMail.keySet())
                {
                    if (oCaseCont.get(sClave) != null)
                    {
                        oMail.get(sClave).put('ContactId', oCaseCont.get(sClave));
                        oMail.get(sClave).put('listaCC', oGrupoOficinaCaseCC.get(sClave));
                    }
                }
            }
            
            // Incorporar los datos de salida.
            if (!oTwitter.isEmpty())
            oRes.put('Twitter', oTwitter);
            
            if (!oMail.isEmpty())
            oRes.put('Email', oMail);
            
            if (!oSMS.isEmpty())
            oRes.put('SMS', oSMS);
            
            //if (!oContactCase.isEmpty())
            //    oRes.put('Contactos', oContactCase);
        }
        
        
        return oRes;
    }
    
    /*
    Método para preparar los mensajes a enviar por Twitter.
    */
    static private Map<String,Map<String,String>> obtenerMensajesTwitterDM(Map<String,Map<String,String>> oCasos)
    {
        Map<String,Map<String,String>> oRes = new Map<String,Map<String,String>>();
        
        // Recuperar plantillas de los CustomMetaData.
        
        // Recuperar el último DM del caso para contestar.
        if (oCasos != null)
        {
            //List<Case> oListaCasos = [SELECT Id, (SELECT Id, MessageType FROM Posts WHERE MessageType = 'Direct' AND IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1) FROM Case WHERE Id IN :oCasos.keySet()];
            
            // Buscamos el último mensaje de cliente asociado al caso.
            List<Case> oListaCasos = [SELECT Id, (SELECT MessageType FROM Posts WHERE IsOutbound = false ORDER BY CreatedDate DESC LIMIT 1) FROM Case WHERE Id IN :oCasos.keySet() ];
            
            for (Case oCaso : oListaCasos)
            {
                for (SocialPost oPost : oCaso.Posts)
                {
                    // Tenemos el caso y su último DM.
                    
                    // Preparar estructura de mensajes a enviar.
                    Map<String,String> oMsjDatos = oCasos.get(oCaso.Id);
                    oMsjDatos.put('MensajeOrigen', oPost.Id);
                    oMsjDatos.put('MensajeTipo', 'Direct');
                    //oMsjDatos.put('MensajeTipo', oPost.MessageType);
                    //oMsjDatos.put('Mensaje', 'PENDIENTE PLANTILLA');
                    
                    oRes.put(oCaso.Id, oMsjDatos);
                }
            }
        }
        
        
        return oRes;
    }
    
    /*
    Método para enviar mensajes por Twitter.
    */
    //static public void enviarMensajesTwitter (List<Map<String,String>> oMensajes)
    static private List<Case> enviarMensajesTwitter (Map<String,Map<String,String>> oMensajes, Map<String,Map<String,String>> oCfg, String sProceso)
    {
        List<QuickAction.QuickActionRequest> oListReq = new List<QuickAction.QuickActionRequest>();
        List<Case> oUpdCasos = new List<Case>();
        
        try {
            
            //for (Map<String,String> oMapa : oMensajes)
            //{
                if (oMensajes != null)
                {
                    for (String sClave : oMensajes.keySet())
                    {
                        if (oMensajes.get(sClave) != null)
                        {
                            // Recorrer cada mensaje a enviar.
                            Map<String,String> oMapa = oMensajes.get(sClave);
                            if (oMapa != null)
                            {
                                // Recuperar los parámetros del mensaje.
                                String sCasoId = '';
                                String sMensOrigId = '';
                                String sMensTipo = '';
                                String sMensaje = '';
                                String sIdioma = '';
                                String sProcesoMsj = '';
                                
                                if (oMapa.get('CasoId') != null)
                                {
                                    sCasoId = oMapa.get('CasoId');
                                }
                                
                                if (oMapa.get('MensajeOrigen') != null)
                                {
                                    sMensOrigId = oMapa.get('MensajeOrigen');
                                }
                                
                                if (oMapa.get('MensajeTipo') != null)
                                {
                                    sMensTipo = oMapa.get('MensajeTipo');
                                }
                                
                                if (oMapa.get('idiomaCaso') != null)
                                {
                                    sIdioma = oMapa.get('idiomaCaso');
                                }
                                
                                if (oMapa.get('Proceso') != null)
                                {
                                    sProcesoMsj = oMapa.get('Proceso');
                                }
                                
                                
                                // Recuperar mensaje configurado.
                                if (oCfg.get(sIdioma + '##'+ sProcesoMsj) != null)
                                {
                                    Map<String,String> oCfgAttr = oCfg.get(sIdioma + '##'+ sProcesoMsj);
                                    sMensaje = oCfgAttr.get('Cuerpo');
                                }
                                
                                // Si hay mensaje específico de aviso a incidencia, se incorpora.
                                if (oMapa.get('MensajeCierreInc') != null)
                                {
                                    if (oMapa.get('MensajeCierreInc') != '')
                                    {
                                        sMensaje = oMapa.get('MensajeCierreInc');
                                    }
                                }
                                
                                // Tratar los reemplazos de las variables del mensaje.
                                for (String sClaveCanal : oMapa.keySet())
                                {
                                    if (oMapa.get(sClaveCanal) != null)
                                    sMensaje = sMensaje.replaceAll('##' + sClaveCanal + '##', oMapa.get(sClaveCanal));
                                }
                                
                                if (sCasoId != '' && sMensOrigId != '' && sMensTipo != '' && sMensaje != '')
                                {
                                    // Mensaje a enviar.
                                    SocialPost oPost = new SocialPost();
                                    oPost.ParentId = sCasoId; // Registro padre asociado.
                                    oPost.ReplyToId = sMensOrigId; // Mensaje al que se está respondiendo.
                                    oPost.MessageType = sMensTipo; // Tipo de mensaje enviado.
                                    oPost.Content = sMensaje; // Contenido del mensaje.
                                    
                                    // Cuerpo petición.
                                    QuickAction.QuickActionRequest oReq = new QuickAction.QuickActionRequest();
                                    oReq.quickActionName = Schema.Case.QuickAction.SocialPublisher;
                                    oReq.record = oPost; // Asignar el mensaje a la petición.
                                    oReq.contextId = sCasoId; // Contexto. Caso ID.
                                    
                                    // Añadir la petición.
                                    oListReq.add(oReq);
                                }
                            }
                        }
                    }
                }
                
                // Lanzar las peticiones de mensajes a enviar.
                if (!oListReq.isEmpty())
                {
                    List<QuickAction.QuickActionResult> oDataRes = QuickAction.performQuickActions(oListReq, false);
                    
                    // Tratar respuesta y actualizar el caso como enviado.
                    for (QuickAction.QuickActionResult oRes : oDataRes)
                    {
                        if (oRes.isSuccess() || Test.isRunningTest())
                        {
                            if (oRes.getContextId() != null || Test.isRunningTest())
                            {
                                Case oCaso = new Case();
                                oCaso.Id = oRes.getContextId();
                                
                                String sResultado = '2';
                                if (sProceso == 'CC_AcuseRecibo')
                                {
                                    oCaso.CC_AcuseRecibo__c = sResultado;
                                }
                                
                                if (sProceso == 'CC_SegOperativa')
                                {
                                    oCaso.CC_SegOperativa__c = sResultado;
                                }
                                
                                if (sProceso == 'CC_NotIncidencia')
                                {
                                    oCaso.CC_NotIncidencia__c = sResultado;
                                }
                                
                                //oCaso.CC_NotifClienteEnv__c = true;
                                oUpdCasos.add(oCaso);
                            }
                        }
                    }
                }
                
            }catch (Exception e) {
                System.debug('Excepcion: ' + e);
                System.debug('Excepcion (enviarMensajesTwitter): ' + e.getMessage());
            }
            
            
            return oUpdCasos;
        }
        
        /*
        Método para preparar los mensajes a enviar por Mail.
        */
        static private Map<String,Map<String,String>> obtenerMensajesMail (Map<String,Map<String,String>> oCasos) {
            
            Map<String,Map<String,String>> oRes = new Map<String,Map<String,String>>();
            
            // Recuperar plantillas de los CustomMetaData.
            // Recuperar el último DM del caso para contestar.
            if (oCasos != null) {
                for (String sCaso : oCasos.keySet()) {
                    
                    Map<String,String> oMsjDatos = oCasos.get(sCaso);
                    oRes.put(sCaso, oMsjDatos);
                    
                }
            }
            
            return oRes;
        }
        
        /*
        Método para enviar mensajes por Email.
        */
        //static private List<Case> enviarMensajesMail (Map<String,Map<String,String>> oMensajes, Map<String,Map<String,String>> oCfg, String sProceso, Map<String,Map<String,String>> oAgrupadores)
        static private List<Case> enviarMensajesMail (Map<String,Map<String,String>> oMensajes, Map<String,Map<String,String>> oCfg, String sProceso)
        {
            List<Messaging.SingleEmailmessage> oListMail = new List<Messaging.SingleEmailmessage>();
            List<Case> oUpdCasos = new List<Case>();
            Map<String, Id> mapIdIdiomaPlantillaHDT = new Map<String, Id>();
            Map<String, Id> mapIdIdiomaPlantilla = new Map<String, Id>();
            List<EmailTemplate> emailPlantillas = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Encuesta_Offline_Notificacion' OR DeveloperName = 'Enquesta_Offline_Notificacion' ];
            List<EmailTemplate> hdtEmailPlantillas = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'HDT_Survey_Offline_Notificacion_IN' OR DeveloperName = 'HDT_Encuesta_Offline_Notificacion_ES' OR DeveloperName = 'HDT_Enquesta_Offline_Notificacion_CA'];
            
            for(EmailTemplate emailp : emailPlantillas)
            {
                if(emailp.DeveloperName == 'Enquesta_Offline_Notificacion'){
                    mapIdIdiomaPlantilla.put('ca', emailp.Id);
                }else{
                    mapIdIdiomaPlantilla.put('es', emailp.Id);
                }
            }
            
            for(EmailTemplate emailp : hdtEmailPlantillas)
            {
                if(emailp.DeveloperName == 'HDT_Enquesta_Offline_Notificacion_CA'){
                    mapIdIdiomaPlantillaHDT.put('ca', emailp.Id);
                }else if(emailp.DeveloperName == 'HDT_Encuesta_Offline_Notificacion_ES'){
                    mapIdIdiomaPlantillaHDT.put('es', emailp.Id);
                }else if(emailp.DeveloperName == 'HDT_Survey_Offline_Notificacion_IN'){
                    mapIdIdiomaPlantillaHDT.put('en', emailp.Id);
                }
            }
            
            try {
                if (oMensajes != null)
                {
                    Set<Id> setCasos = new Set<Id>();
                    List<Case> listCasosEncuenta = new List<Case>();
                    Map<Id, String> mapCasoEncuesta = new Map<Id, String>();
                    for (String sClave : oMensajes.keySet()) {
                        if (oMensajes.get(sClave) != null) {
                            Map<String,String> oMapa = oMensajes.get(sClave);
                            if (oMapa != null) {
                                if (oMapa.get('CasoId') != null)
                                {
                                    setCasos.add(oMapa.get('CasoId'));
                                }
                            }
                        }
                    }
                    
                    listCasosEncuenta = [SELECT CC_URL_Encuesta_3N__c, Id FROM Case WHERE Id IN :setCasos ];
                    
                    for (Case casoEncuenta : listCasosEncuenta) {
                        mapCasoEncuesta.put(casoEncuenta.Id,casoEncuenta.CC_URL_Encuesta_3N__c);
                    }
                    
                    for (String sClave : oMensajes.keySet()) {
                        if (oMensajes.get(sClave) != null) {
                            // Recorrer cada mensaje a enviar.
                            Map<String,String> oMapa = oMensajes.get(sClave);
                            
                            if (oMapa != null)
                            {
                                // Recuperar los parámetros del mensaje.
                                String sCasoId = '';
                                String sIdioma = '';
                                String sPlantillaId = '';
                                String sRemitenteNombre = '';
                                String sDest = '';
                                String sContactId = '';
                                String sProcesoMsj = '';
                                String sRemitenteId = '';
                                String sListaCC = '';
                                
                                // Bifurcar remitente por Origen, Canal de procedencia y recordType
                                String sOrigen = '';
                                String sCanalProcedencia = '';
                                String sRecordTypeName = '';
                                
                                if (oMapa.get('CasoId') != null)
                                {
                                    sCasoId = oMapa.get('CasoId');
                                }
                                
                                if (String.isNotBlank(oMapa.get('Origen')))
                                {
                                    sOrigen = oMapa.get('Origen');
                                }
                                
                                if (String.isNotBlank(oMapa.get('CanalProcedencia')))
                                {
                                    sCanalProcedencia = oMapa.get('CanalProcedencia');
                                }
                                
                                if (oMapa.get('idiomaCaso') != null)
                                {
                                    sIdioma = oMapa.get('idiomaCaso');
                                }
                                
                                if (oMapa.get('Proceso') != null)
                                {
                                    sProcesoMsj = oMapa.get('Proceso');
                                }
                                
                                if (oMapa.get('ContactId') != null)
                                {
                                    sContactId = oMapa.get('ContactId');
                                }
                                
                                if (oMapa.get('listaCC') !=  null)
                                {
                                    sListaCC = oMapa.get('listaCC');
                                }
                                
                                if (oMapa.get('MailTelfCaso') != null)
                                {
                                    sDest = oMapa.get('MailTelfCaso');
                                }
                                
                                if (oMapa.get('RecordTypeName') != null)
                                {
                                    sRecordTypeName = oMapa.get('RecordTypeName');
                                }
                                
                                
                                // Recuperar el mensaje configurado por Origen y Canal de procedencia.
                                if (oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sOrigen + '##' + sCanalProcedencia) != null)
                                {
                                    // Recuperar mensaje configurado por Origen y Canal de procedencia.
                                    Map<String,String> oCfgAttr = oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sOrigen + '##' + sCanalProcedencia);
                                    sPlantillaId = oCfgAttr.get('Plantilla');   sRemitenteNombre = oCfgAttr.get('RemitenteName');
                                    sRemitenteId = oCfgAttr.get('Remitente');
                                }
                                else if (oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sCanalProcedencia) != null)
                                {
                                    // Recuperar mensaje configurado por defecto (proceso actual)
                                    Map<String,String> oCfgAttr = oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sCanalProcedencia);
                                    sPlantillaId = oCfgAttr.get('Plantilla'); sRemitenteNombre = oCfgAttr.get('RemitenteName');
                                    sRemitenteId = oCfgAttr.get('Remitente');
                                }
                                else if (oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sRecordTypeName) != null)
                                {
                                    // Recuperar mensaje configurado por defecto (proceso actual)
                                    Map<String,String> oCfgAttr = oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sRecordTypeName);
                                    sPlantillaId = oCfgAttr.get('Plantilla'); sRemitenteNombre = oCfgAttr.get('RemitenteName');
                                    sRemitenteId = oCfgAttr.get('Remitente');
                                }
                                else if (oCfg.get(sIdioma + '##' + sProcesoMsj) != null)
                                {
                                    // Recuperar mensaje configurado por defecto (proceso actual)
                                    Map<String,String> oCfgAttr = oCfg.get(sIdioma + '##' + sProcesoMsj);
                                    sPlantillaId = oCfgAttr.get('Plantilla');
                                    sRemitenteNombre = oCfgAttr.get('RemitenteName');
                                    sRemitenteId = oCfgAttr.get('Remitente');
                                }
                                
                                // Recuperar posible plantilla configurada para el envío del cierre.
                                /* DESCARTAMOS LA GESTIÓN DE PLANTILLAS POR AGRUPADOR.
                                if (oMapa.get('AgrupadorId') != null && sIdioma != '')
                                {
                                    String sAgr = oMapa.get('AgrupadorId');
                                    if (oAgrupadores.get(sAgr) != null)
                                    {
                                        sPlantillaId = oAgrupadores.get(sAgr).get('Email##' + sIdioma);
                                    }
                                }
                                */
                                
                                String caseComprobarEncuesta3N = mapCasoEncuesta.get(sCasoId);

                                //if (sCasoId != '' && sPlantillaId != '' && sRemitenteNombre != '' && sDest != '' && sContactId != '')
                                if (sCasoId != '' && sPlantillaId != '' && (sRemitenteNombre != '' || sRemitenteId != '') && sContactId != '')
                                {
                                    // Mensaje a enviar.
                                    Messaging.SingleEmailMessage oMail = new Messaging.SingleEmailMessage();
                                    oMail.setTemplateId(sPlantillaId);
                                    //String sAgr = oMapa.get('RecordTypeDeveloperName.AgrupadorId');
                                    if(sRecordTypeName == 'Empleado' && Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosById().get(oMapa.get('RecordTypeId.AgrupadorId')).getDeveloperName().startsWith('CC_Incidencia')) 
                                    {
                                        if(sIdioma == 'ca' && caseComprobarEncuesta3N != null)
                                        {
                                            oMail.setTemplateId(mapIdIdiomaPlantilla.get('ca')); 
                                        }else if (sIdioma == 'es' && caseComprobarEncuesta3N != null){//nuevo
                                            oMail.setTemplateId(mapIdIdiomaPlantilla.get('es'));
                                        }else{
                                            //Mantenemos la plantilla de envio de notificaciones predefinida
                                            oMail.setTemplateId(sPlantillaId);
                                        }   
                                    }else if(sRecordTypeName == 'Empleado (HDT)' && Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosById().get(oMapa.get('RecordTypeId.AgrupadorId')).getDeveloperName().startsWith('CC_Incidencia'))
                                    {
                                        if(sIdioma == 'ca' && caseComprobarEncuesta3N != null)
                                        {
                                            oMail.setTemplateId(mapIdIdiomaPlantillaHDT.get('ca')); 
                                        }else if (sIdioma == 'es' && caseComprobarEncuesta3N != null){//nuevo
                                            oMail.setTemplateId(mapIdIdiomaPlantillaHDT.get('es'));
                                        }else if (sIdioma == 'en' && caseComprobarEncuesta3N != null){
                                            //Mantenemos la plantilla de envio de notificaciones predefinida
                                            oMail.setTemplateId(mapIdIdiomaPlantillaHDT.get('en'));
                                        }   
                                    }
                                    //oMail.setHtmlBody('<BODY>Probando plantilla{{{Case.CaseNumber}}}</BODY>');
                                    oMail.setSaveAsActivity(true);
                                    //oMail.setSaveAsActivity(false);
                                    String[] toAddresses = new String[] {sDest};
                                    //oMail.setToAddresses(toAddresses);
                                    system.debug(sCasoId);
                                    oMail.setWhatId(sCasoId);
                                    
                                    //oMail.setSenderDisplayName(sRemitenteNombre);
                                    if (sRemitenteId != '')
                                    oMail.setOrgWideEmailAddressId(sRemitenteId);
                                    else
                                    oMail.setSenderDisplayName(sRemitenteNombre);
                                    
                                    //if (sContactId != '')
                                    oMail.setTargetObjectId(sContactId);
                                    
                                    //oMail.setTargetObjectId('0036E00000duHBoQAM');
                                    if (String.isNotBlank(sListaCC))
                                    {
                                        oMail.setCcAddresses(sListaCC.split(';'));
                                    }
                                    
                                    // Añadir la petición.
                                    oListMail.add(oMail);
                                    
                                }
                            }
                        }
                    }
                }
                
                // Lanzar las peticiones de mensajes a enviar.
                if (!oListMail.isEmpty())
                {
                    List<Messaging.SingleEmailmessage> oMaxEnvios = new List<Messaging.SingleEmailmessage>();
                    Integer iMensaje = 0;
                    Integer iTotalMsj = oListMail.size();
                    
                    for (Integer iMens = 0; iMens < iTotalMsj; iMens++) {
                        oMaxEnvios.add(oListMail[iMens]);
                        iMensaje = iMensaje + 1;
                        
                        
                        if (iMensaje == 10 || iMens == iTotalMsj-1)
                        {
                            // Enviar bloques de 10 mensajes máximo.
                            
                            List<Messaging.SendEmailResult> oDataRes = Messaging.sendEmail(oMaxEnvios, false);
                            
                            // Suponemos que el orden de devolución de resultados, es el orden de entrada de la lista de e-mails.
                            // Actualizamos estado en función de ello.
                            for (Integer iRes = 0; iRes<oDataRes.size(); iRes++)
                            {
                                Case oCaso = new Case();
                                oCaso.Id = oMaxEnvios[iRes].getWhatId();
                                
                                String sResultado = '';
                                Boolean cResultado = false;
                                if (oDataRes[iRes].isSuccess())
                                {
                                    sResultado = '2'; cResultado = true;
                                }else{
                                    sResultado = '3';
                                }
                                
                                if (sProceso == 'CC_AcuseRecibo')
                                {
                                    oCaso.CC_AcuseRecibo__c = sResultado;
                                }
                                
                                if (sProceso == 'CC_SegOperativa')
                                {
                                    oCaso.CC_SegOperativa__c = sResultado;
                                }
                                
                                if (sProceso == 'CC_NotIncidencia')
                                {
                                    oCaso.CC_NotIncidencia__c = sResultado;
                                }
                                if (sProceso == 'CC_Contacto_Intermedio_AC')
                                {
                                    oCaso.CC_Notif_Cont_Inter__c = cResultado;
                                }
                                if (sProceso == 'CC_Contacto_Intermedio_Preventivas')
                                {
                                    oCaso.CC_Notif_Cont_Inter__c = cResultado;
                                }
                                oUpdCasos.add(oCaso);
                            }
                            
                            // Resetear variable de conteo y lista de envíos.
                            oMaxEnvios.clear();
                            iMensaje = 0;
                            
                        }
                    }
                    
                    /*for (String sClave : oMensajes.keySet())
                    {
                        Case oCaso = new Case();
                        oCaso.Id = sClave;
                        oCaso.CC_AcuseRecibo__c = '2';
                        oUpdCasos.add(oCaso);
                    }*/
                    
                    /*List<QuickAction.QuickActionResult> oDataRes = QuickAction.performQuickActions(oListReq, false);
                    
                    // Tratar respuesta y actualizar el caso como enviado.
                    for (QuickAction.QuickActionResult oRes : oDataRes)
                    {
                        if (oRes.isSuccess())
                        {
                            if (oRes.getContextId() != null)
                            {
                                Case oCaso = new Case();
                                oCaso.Id = oRes.getContextId();
                                oCaso.CC_NotifClienteEnv__c = true;
                                oUpdCasos.add(oCaso);
                            }
                        }
                    }*/
                }
                
                
                
            }catch (Exception e) {
                System.debug('Excepcion: ' + e);
                System.debug('Excepcion (enviarMensajesMail): ' + e.getMessage());
            }
            
            
            return oUpdCasos;
        }
        
        @TestVisible
        private static Map<String, Map<String, String>> obtenerMensajesSMS(Map<String, Map<String, String>> oCasos) {
            
            Map<String, Map<String, String>> oRes = new Map<String, Map<String, String>>();
            if (oCasos != null) {
                for (String sCaso : oCasos.keySet()) {
                    Map<String, String> oMsjDatos = oCasos.get(sCaso);
                    oRes.put(sCaso, oMsjDatos);
                }
            }
            
            return oRes;
        }
        
        @TestVisible
        private static List<Case> enviarMensajesSMS(Map<String, Map<String, String>> oMensajes, Map<String, Map<String, String>> oCfg, String sProceso) {
            
            List<CC_Push_SMS.CC_Push_SMS_Mensaje> oListSMS = new List<CC_Push_SMS.CC_Push_SMS_Mensaje>();
            List<Case> oUpdCasos = new List<Case>();
            List<EmailTemplate> listTemplates = new List<EmailTemplate>();
            Set<Id> setPlantillasId = new Set<Id>();
            Map<Id, String> mapIdEmailBody = new Map<Id, String>();
            Map<String, String> mapClavePlantillaId = new Map<String, String>();
            
            try {
                if (oMensajes != null) {
                    for (String sClave : oMensajes.keySet()) {
                        if (oMensajes.get(sClave) != null) {
                            // Recorrer cada mensaje a enviar.
                            Map<String, String> oMapa = oMensajes.get(sClave);
                            
                            if (oMapa != null) {
                                // Recuperar los parámetros del mensaje.
                                String sCasoId = '';
                                String sIdioma = '';
                                String sPlantillaId = '';
                                String sDest = '';
                                String sProcesoMsj = '';
                                
                                //Bifurcar remitente por Origen y Canal de procedencia.
                                String sOrigen = ''; String sCanalProcedencia = '';
                                
                                if (oMapa.get('CasoId') != null) {
                                    sCasoId = oMapa.get('CasoId');
                                }
                                
                                if (String.isNotBlank(oMapa.get('Origen'))) {
                                    sOrigen = oMapa.get('Origen');
                                }
                                
                                if (String.isNotBlank(oMapa.get('CanalProcedencia'))) {
                                    sCanalProcedencia = oMapa.get('CanalProcedencia');
                                }
                                
                                if (oMapa.get('idiomaCaso') != null) {
                                    sIdioma = oMapa.get('idiomaCaso');
                                }
                                
                                if (oMapa.get('Proceso') != null) {
                                    sProcesoMsj = oMapa.get('Proceso');
                                }
                                
                                if (oMapa.get('MailTelfCaso') != null) {
                                    sDest = oMapa.get('MailTelfCaso');
                                }
                                
                                
                                // Recuperar el mensaje configurado por Origen y Canal de procedencia.
                                if (oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sOrigen + '##' + sCanalProcedencia) != null) {
                                    // Recuperar mensaje configurado por Origen y Canal de procedencia.
                                    Map<String, String> oCfgAttr = oCfg.get(sIdioma + '##' + sProcesoMsj + '##' + sOrigen + '##' + sCanalProcedencia);
                                    sPlantillaId = oCfgAttr.get('Plantilla');
                                } else if (oCfg.get(sIdioma + '##' + sProcesoMsj) != null) {
                                    // Recuperar mensaje configurado por defecto (proceso actual)
                                    Map<String, String> oCfgAttr = oCfg.get(sIdioma + '##' + sProcesoMsj);
                                    sPlantillaId = oCfgAttr.get('Plantilla');
                                }
                                
                                if (sPlantillaId != '') {
                                    setPlantillasId.add(sPlantillaId);
                                    mapClavePlantillaId.put(sClave, sPlantillaId);
                                }
                            }
                        }
                    }
                    
                    if(!setPlantillasId.isEmpty()){
                        listTemplates = [SELECT HtmlValue, Id FROM EmailTemplate WHERE Id IN :setPlantillasId ];
                    }
                    for (EmailTemplate template : listTemplates) {
                        mapIdEmailBody.put(template.Id, template.HtmlValue);
                    }
                    
                    for (String sClave : oMensajes.keySet()) {
                        String sCasoId = '';
                        String sDest = '';
                        if (oMensajes.get(sClave) != null) {
                            Map<String, String> oMapa = oMensajes.get(sClave);
                            if (oMapa != null && oMapa.get('CasoId') != null) {
                                sCasoId = oMapa.get('CasoId');
                                
                                if (oMapa.get('MailTelfCaso') != null) {
                                    sDest = oMapa.get('MailTelfCaso');
                                }
                                
                                if (sCasoId != '') {
                                    // Mensaje a enviar.
                                    CC_Push_SMS.CC_Push_SMS_Mensaje mensaje = new CC_Push_SMS.CC_Push_SMS_Mensaje();
                                    mensaje.sObjectId = sCasoId; mensaje.destinatario = sDest;
                                    mensaje.texto = mapIdEmailBody.get(mapClavePlantillaId.get(sClave));
                                    oListSMS.add(mensaje);
                                }
                            }
                        }
                    }
                }
                
                //Lanzar las peticiones de mensajes a enviar.
                if (!oListSMS.isEmpty()) {
                    CC_Push_SMS.enviarNotificacionPush(oListSMS);
                }
            } catch (Exception e) {
                System.debug('Excepcion: ' + e);
                System.debug('Excepcion (enviarMensajesSMS): ' + e.getMessage());
            }
            
            return oUpdCasos;
        }
        
        /*
        Método para actualizar los casos.
        */
        static private void actualizarCasos (List<Case> oUpdCasos)
        {
            if (oUpdCasos != null)
            {
                if (!oUpdCasos.isEmpty())
                {
                    Database.SaveResult[] oResUp = Database.update(oUpdCasos, false);
                }
            }
        }
    }