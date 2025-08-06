public with sharing class SEG_BPO_WS {
    /*
•	Alta de proceso Pre-Premium (Código S01)
•	Modificación (Código S02)
•	Respuesta alta/modificación de cliente (Código S03)

    */
    public static String enviarCaso(String casoId,String tipoProceso,String notasCif, List<String> listaFicheros)
    {
        /*SEG_cbpo038.consultav2 mensaje = new SEG_cbpo038.consultav2();
        mensaje.tipoProceso='S01';
        mensaje.origen='Siebel';
        mensaje.numeroSR=caso.CaseNumber;
        mensaje.codigoOperativa='13';
        mensaje.fechaEvento=DateTime.now().day()+'/'+DateTime.now().month()+'/'+DateTime.now().year();
        mensaje.textoMail='hola!';
        //SEG_cbpo014Intsiebelv2Tws ws = new SEG_cbpo014Intsiebelv2Tws();
        SEG_cbpo014Intsiebelv2Tws.IntSiebelv2Soap wsSBL = new SEG_cbpo014Intsiebelv2Tws.IntSiebelv2Soap();
        wsSBL.clientCertName_x='Cert_2wSSL';
        SEG_cbpo038.ConsultarRequestv2 consultaRequestV2 = new SEG_cbpo038.ConsultarRequestv2();
        consultaRequestV2.Consulta=mensaje;
        wsSBL.Recepcion(consultaRequestV2);  */
        String resultadoBPO = '';
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('SEG_CBPO_config');
        String certBPO = oConfig.CC_Certificado__c;
        List<Case> listCasos = new List<Case>();
        List<Id> ficherosSelect = new List<Id>();
        ficherosSelect = listaFicheros;
        listCasos = [select id,CaseNumber,Priority, Description,SEG_Organizacion__c, SEG_Zona__c, CreatedDate,Account.CC_Numero_Documento__c,CC_MCC_Motivo__r.Name,SEG_Numero_centro__c from Case where id=:casoId limit 1];

        //List<CC_InterfaceSettings__mdt> oConfig = [SELECT Id, CC_Activa__c, CC_DiasRef__c,CC_Certificado__c FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];

        if(listCasos.size()==1)
        {
            if(tipoProceso=='alta')
            {
                //preparar mensaje de entrada:
                SEG_proc220IntsalesforceTws.ReceptorEntrada mensaje = new SEG_proc220IntsalesforceTws.ReceptorEntrada();

                mensaje.tipoProceso='S01';
                mensaje.origen='Salesforce';
                mensaje.numeroCaso=listCasos[0].CaseNumber;
                mensaje.codigoOperativa='13';
                mensaje.idCaso=listCasos[0].id;
                mensaje.fechaEvento=DateTime.now().day()+'/'+DateTime.now().month()+'/'+DateTime.now().year();
                mensaje.textoMail = listCasos[0].Description;
                
                Map<Id,List<ContentVersion>> mapEmailsAttachments = new Map<Id,List<ContentVersion>>();
                Map<Id,List<ContentVersion>> mapAttachmentsSelected = new Map<Id,List<ContentVersion>>();
                Map<Id,EmailMessage> mapEmails = new Map<Id,EmailMessage>();
                for(EmailMessage eM:[select id, FromAddress,CcAddress,BccAddress,Subject,ToAddress,HtmlBody,CreatedDate from EmailMessage where ParentId =:casoId])
                {
                    mapEmails.put(eM.id,eM);
                }
                mapEmailsAttachments = getEmailAndAttachments(casoId);
                //mapAttachmentsSelected = getFicherosSeleccionados(casoId,ficherosSelect);
                //System.debug('mapEmailsAttachments : ' + mapEmailsAttachments);
                //System.debug('mapAttachmentsSelected : ' + mapAttachmentsSelected);
                List<SEG_proc220IntsalesforceTws.ContenidoAdicional> listofAdicional= new List<SEG_proc220IntsalesforceTws.ContenidoAdicional>();
                
                List<SEG_proc220IntsalesforceTws.TipoMail> listofMails= new List<SEG_proc220IntsalesforceTws.TipoMail>();
                
                Datetime GMTDate = listCasos[0].CreatedDate;
                String strConvertedDate = GMTDate.format('MM/dd/yyyy HH:mm:ss','America/New_York');
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdRem= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdRec= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdAsu= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdZna= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdFec= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdMcc= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdGrp= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdNif= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdcentro= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdAccion= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdPrio= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.TipoAdjunto adjuntoAtt = new SEG_proc220IntsalesforceTws.TipoAdjunto();
                List<SEG_proc220IntsalesforceTws.TipoAdjunto> listofAdjuntos= new List<SEG_proc220IntsalesforceTws.TipoAdjunto>();
                SEG_proc220IntsalesforceTws.TipoMail email = new SEG_proc220IntsalesforceTws.TipoMail();
                //NOTAS
                if(String.isNotBlank(notasCif)){
                    SEG_proc220IntsalesforceTws.ContenidoAdicional contAdNotas= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                    contAdNotas.key = 'NOTAS';
                    contAdNotas.value = notasCif;
                    listofAdicional.add(contAdNotas);
                }

                for(id mailid:mapEmails.keyset())
                {
                    if(mapEmails.get(mailid)!=null)
                    {
                        //SEG_proc220IntsalesforceTws.TipoMail email = new SEG_proc220IntsalesforceTws.TipoMail();
                        email.id=mailid;
                        email.remitente=mapEmails.get(mailid).FromAddress;
                        email.asunto=mapEmails.get(mailid).Subject;
                        email.destinatario=mapEmails.get(mailid).ToAddress;
                        email.cc=mapEmails.get(mailid).CcAddress;
                        email.fechaCreacion=string.valueof(mapEmails.get(mailid).CreatedDate);
                        email.cuerpoHTML=mapEmails.get(mailid).HtmlBody;
                        contAdRem.key='Correo remitente';
                        contAdRem.value=mapEmails.get(mailid).FromAddress;
                        listofAdicional.add(contAdRem);
                        contAdRec.key='RECEPETOR';
                        contAdRec.value=mapEmails.get(mailid).ToAddress;
                        listofAdicional.add(contAdRec);
                        contAdAsu.key='Asunto';
                        contAdAsu.value=mapEmails.get(mailid).Subject;
                        //List<SEG_proc220IntsalesforceTws.TipoAdjunto> listofAdjuntos= new List<SEG_proc220IntsalesforceTws.TipoAdjunto>();
                        /*for(ContentVersion cv:mapEmailsAttachments.get(mailid))
                        {
                            SEG_proc220IntsalesforceTws.TipoAdjunto adjunto = new SEG_proc220IntsalesforceTws.TipoAdjunto();
                            adjunto.fileName=cv.Title;
                            adjunto.fileId=cv.Id;
                            listofAdjuntos.add(adjunto);
                        }
                        email.docAdjuntos=listofAdjuntos;*/
                        //listofMails.add(email);
                        listofAdicional.add(contAdAsu);
                    }
                    
                }
                if(ficherosSelect != null && !ficherosSelect.isEmpty()){
                    for(ContentVersion cvAtt:[select id,Title,FileExtension,ContentDocumentId from ContentVersion where ContentDocumentId in :ficherosSelect]){  
                        adjuntoAtt = new SEG_proc220IntsalesforceTws.TipoAdjunto();   
                        adjuntoAtt.fileName=cvAtt.Title;
                        adjuntoAtt.fileId=cvAtt.Id;
                        listofAdjuntos.add(adjuntoAtt);
                    }
                    email.docAdjuntos=listofAdjuntos;
                    //listofMails.add(email);
                }
                listofMails.add(email);

                contAdZna.key='Zona';
                contAdZna.value=listCasos[0].SEG_Zona__c;
                listofAdicional.add(contAdZna);
                contAdFec.key='FECHA APERTURA';
                contAdFec.value=strConvertedDate;
                listofAdicional.add(contAdFec);
                contAdMcc.key='Codificación MCC';
                contAdMcc.value='13';
                listofAdicional.add(contAdMcc);
                contAdGrp.key='Grupo';
                contAdGrp.value='13';
                listofAdicional.add(contAdGrp);
                contAdNif.key='NIF';
                contAdNif.value=listCasos[0].Account.CC_Numero_Documento__c;
                listofAdicional.add(contAdNif);
                contAdcentro.key='centro';
                contAdcentro.value=listCasos[0].SEG_Numero_centro__c;
                listofAdicional.add(contAdcentro);
                contAdAccion.key='Accion';
                contAdAccion.value=listCasos[0].CC_MCC_Motivo__r.Name;
                listofAdicional.add(contAdAccion);
                contAdPrio.key='Prioridad';
                contAdPrio.value=listCasos[0].Priority;
                listofAdicional.add(contAdPrio);
                mensaje.contenidoMail=listofMails;
                mensaje.contenidoAdicional=listofAdicional;
                
                SEG_proc220IntsalesforceTws.ReceptorContenido receptor = new SEG_proc220IntsalesforceTws.ReceptorContenido();
                receptor.Consulta = mensaje;
                SEG_proc220IntsalesforceTws.IntSalesforceSoap comunicacionws = new SEG_proc220IntsalesforceTws.IntSalesforceSoap();
                comunicacionws.clientCertName_x = certBPO;
                List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
                CC_TrazaInt__c oTraza;
                String sDescError = '';
                String sDetalleError = '';
                    
                // Generar traza.
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'CBPO_Segmentos';
                oTraza.CC_FechaInicio__c = datetime.now();
                oTraza.CC_MensajeEntrada__c = String.valueOf(mensaje);

                if (!Test.isRunningTest()){
                    try {
                        resultadoBPO = comunicacionws.Recepcion(receptor);
                        oTraza.CC_MensajeSalida__c = resultadoBPO;
                        oTraza.CC_FechaFin__c = datetime.now();
                        oTraza.CC_FinOK__c = true;
                    } catch (Exception e) {
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = 'Error comunicaciones.';
                        oTraza.CC_DetalleError__c = e.getMessage();
                    }

                    if (oTraza != null){
                        oListTrazas.add(oTraza);
                    }
                }

                if (!oListTrazas.isEmpty()){
                    Database.SaveResult[] oResultTrazas = Database.insert(oListTrazas, false);
                }

            }
        } 

        return resultadoBPO;
    }
    @future(callout=true)
    public static void actualizarCaso(String casoId,String tipoProceso)
    {
        /*SEG_cbpo038.consultav2 mensaje = new SEG_cbpo038.consultav2();
        mensaje.tipoProceso='S01';
        mensaje.origen='Siebel';
        mensaje.numeroSR=caso.CaseNumber;
        mensaje.codigoOperativa='13';
        mensaje.fechaEvento=DateTime.now().day()+'/'+DateTime.now().month()+'/'+DateTime.now().year();
        mensaje.textoMail='hola!';
        //SEG_cbpo014Intsiebelv2Tws ws = new SEG_cbpo014Intsiebelv2Tws();
        SEG_cbpo014Intsiebelv2Tws.IntSiebelv2Soap wsSBL = new SEG_cbpo014Intsiebelv2Tws.IntSiebelv2Soap();
        wsSBL.clientCertName_x='Cert_2wSSL';
        SEG_cbpo038.ConsultarRequestv2 consultaRequestV2 = new SEG_cbpo038.ConsultarRequestv2();
        consultaRequestV2.Consulta=mensaje;
        wsSBL.Recepcion(consultaRequestV2);  */
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('SEG_CBPO_config');
        String certBPO = oConfig.CC_Certificado__c;
        CBK_Log.debug('Entrando a actualizarCaso', logginglevel.INFO);
        List<Case> listCasos = new List<Case>();
        listCasos = [select id,CaseNumber, Priority, Description,SEG_Organizacion__c, SEG_Zona__c, CreatedDate,Account.CC_Numero_Documento__c,CC_MCC_Motivo__r.Name,SEG_Numero_centro__c from Case where id=:casoId limit 1];

        //List<CC_InterfaceSettings__mdt> oConfig = [SELECT Id, CC_Activa__c, CC_DiasRef__c,CC_Certificado__c FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :sInterfaz AND CC_Activa__c = true];

        if(listCasos.size()==1)
        {
            
            if(tipoProceso=='modificación')
            {
                //preparar mensaje de entrada:
                SEG_proc220IntsalesforceTws.ReceptorEntrada mensaje = new SEG_proc220IntsalesforceTws.ReceptorEntrada();

                mensaje.tipoProceso='S02';
                mensaje.origen='Salesforce';
                mensaje.numeroCaso=listCasos[0].CaseNumber;
                mensaje.codigoOperativa='13';
                mensaje.idCaso=listCasos[0].id;
                mensaje.fechaEvento=DateTime.now().day()+'/'+DateTime.now().month()+'/'+DateTime.now().year();
                mensaje.textoMail = listCasos[0].Description;
                
                Map<Id,List<ContentVersion>> mapEmailsAttachments = new Map<Id,List<ContentVersion>>();
                Map<Id,EmailMessage> mapEmails = new Map<Id,EmailMessage>();
                for(EmailMessage eM:[select id, FromAddress,CcAddress,BccAddress,Subject,ToAddress,HtmlBody,CreatedDate from EmailMessage where ParentId =:casoId and status != '5' order by CreatedDate DESC LIMIT 1])
                {
                    mapEmails.put(eM.id,eM);
                }
                mapEmailsAttachments = getEmailAndAttachments(casoId);
                List<SEG_proc220IntsalesforceTws.ContenidoAdicional> listofAdicional= new List<SEG_proc220IntsalesforceTws.ContenidoAdicional>();
                
                List<SEG_proc220IntsalesforceTws.TipoMail> listofMails= new List<SEG_proc220IntsalesforceTws.TipoMail>();
                
                Datetime GMTDate = listCasos[0].CreatedDate;
                String strConvertedDate = GMTDate.format('MM/dd/yyyy HH:mm:ss','America/New_York');
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdRem= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdRec= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdAsu= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdZna= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdFec= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdMcc= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdGrp= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdNif= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdcentro= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdAccion= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdPrio= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.TipoAdjunto adjuntoAtt = new SEG_proc220IntsalesforceTws.TipoAdjunto();
                List<SEG_proc220IntsalesforceTws.TipoAdjunto> listofAdjuntos= new List<SEG_proc220IntsalesforceTws.TipoAdjunto>();
                SEG_proc220IntsalesforceTws.TipoMail email = new SEG_proc220IntsalesforceTws.TipoMail();
                
                
                for(id mailid:mapEmails.keyset())
                {
                    if(mapEmails.get(mailid)!=null)
                    {
                        //SEG_proc220IntsalesforceTws.TipoMail email = new SEG_proc220IntsalesforceTws.TipoMail();
                        email.id=mailid;
                        email.remitente=mapEmails.get(mailid).FromAddress;
                        email.asunto=mapEmails.get(mailid).Subject;
                        email.destinatario=mapEmails.get(mailid).ToAddress;
                        email.cc=mapEmails.get(mailid).CcAddress;
                        email.fechaCreacion=string.valueof(mapEmails.get(mailid).CreatedDate);
                        email.cuerpoHTML=mapEmails.get(mailid).HtmlBody;
                        contAdRem.key='Correo remitente';
                        contAdRem.value=mapEmails.get(mailid).FromAddress;
                        listofAdicional.add(contAdRem);
                        contAdRec.key='RECEPETOR';
                        contAdRec.value=mapEmails.get(mailid).ToAddress;
                        listofAdicional.add(contAdRec);
                        contAdAsu.key='Asunto';
                        contAdAsu.value=mapEmails.get(mailid).Subject;
                        //List<SEG_proc220IntsalesforceTws.TipoAdjunto> listofAdjuntos= new List<SEG_proc220IntsalesforceTws.TipoAdjunto>();
                        for(ContentVersion cv:mapEmailsAttachments.get(mailid))
                        {
                            SEG_proc220IntsalesforceTws.TipoAdjunto adjunto = new SEG_proc220IntsalesforceTws.TipoAdjunto();
                            adjunto.fileName=cv.Title;
                            adjunto.fileId=cv.Id;
                            listofAdjuntos.add(adjunto);
                            System.debug('cv:'+cv);
                        }
                        email.docAdjuntos=listofAdjuntos;
                        listofMails.add(email);
                        listofAdicional.add(contAdAsu);
                    }
                    
                }

                //Añadir todos los adjuntos del caso
                Set<Id> ContentDocumentIdIds = new Set<Id>();
                for(ContentDocumentLink codLink :[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId =:casoId ]){
                    ContentDocumentIdIds.add(codLink.ContentDocumentId);
                }
    
                for(ContentVersion cvAtt:[select id,Title,FileExtension,ContentDocumentId from ContentVersion where ContentDocumentId in :ContentDocumentIdIds]){     
                    adjuntoAtt.fileName=cvAtt.Title;
                    adjuntoAtt.fileId=cvAtt.Id;
                    listofAdjuntos.add(adjuntoAtt);
                    System.debug('ADJUNTOS caso modificar : ' + adjuntoAtt);
                }
                email.docAdjuntos=listofAdjuntos;
                listofMails.add(email);

                contAdZna.key='Zona';
                contAdZna.value=listCasos[0].SEG_Zona__c;
                listofAdicional.add(contAdZna);
                contAdFec.key='FECHA APERTURA';
                contAdFec.value=strConvertedDate;
                listofAdicional.add(contAdFec);
                contAdMcc.key='Codificación MCC';
                contAdMcc.value='13';
                listofAdicional.add(contAdMcc);
                contAdGrp.key='Grupo';
                contAdGrp.value='13';
                listofAdicional.add(contAdGrp);
                contAdNif.key='NIF';
                contAdNif.value=listCasos[0].Account.CC_Numero_Documento__c;
                listofAdicional.add(contAdNif);
                contAdcentro.key='centro';
                contAdcentro.value=listCasos[0].SEG_Numero_centro__c;
                listofAdicional.add(contAdcentro);
                contAdAccion.key='Accion';
                contAdAccion.value=listCasos[0].CC_MCC_Motivo__r.Name;
                listofAdicional.add(contAdAccion);
                contAdPrio.key='Prioridad';
                contAdPrio.value=listCasos[0].Priority;
                listofAdicional.add(contAdPrio);

                mensaje.contenidoMail=listofMails;
                mensaje.contenidoAdicional=listofAdicional;

                //SEG_proc220IntsalesforceTws.IntSalesforceSoap comunicacionws = new SEG_proc220IntsalesforceTws.IntSalesforceSoap();
                //comunicacionws.clientCertName_x = 'Cert_2wSSL';
                //string test = comunicacionws.Recepcion();
                SEG_proc220IntsalesforceTws.ReceptorContenido receptor = new SEG_proc220IntsalesforceTws.ReceptorContenido();
                receptor.Consulta = mensaje;
                SEG_proc220IntsalesforceTws.IntSalesforceSoap comunicacionws = new SEG_proc220IntsalesforceTws.IntSalesforceSoap();
                comunicacionws.clientCertName_x = certBPO;
                List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
                CC_TrazaInt__c oTraza;
                String sDescError = '';
                String sDetalleError = '';

                    // Generar traza.
                    oTraza = new CC_TrazaInt__c();
                    oTraza.Name = 'CBPO_Segmentos_Modificar';
                    oTraza.CC_FechaInicio__c = datetime.now();

                if (!Test.isRunningTest()){

                    try {
                        string resultadoBPO = comunicacionws.Recepcion(receptor);
                        oTraza.CC_MensajeEntrada__c = String.valueOf(mensaje);
                        oTraza.CC_MensajeSalida__c = resultadoBPO;
                        oTraza.CC_FechaFin__c = datetime.now();
                        System.debug('resultado CBPO:'+resultadoBPO);

                    } catch (Exception e) {
                        oTraza.CC_FinOK__c = false;
                        oTraza.CC_TipoError__c = 'Error comunicaciones.';
                        oTraza.CC_DetalleError__c = e.getMessage();

                    }
                    if (oTraza != null){
                        oListTrazas.add(oTraza);
                    }

                }
                if (!oListTrazas.isEmpty()){
                    Database.SaveResult[] oResultTrazas = Database.insert(oListTrazas, false);
                }
            }
        } 
    }

    //Respuesta alta/modificación de cliente (Código S03)
    public static void altaomodificacionCliente(String casoId,String tipoProceso)
    {
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('SEG_CBPO_config');
        String certBPO = oConfig.CC_Certificado__c;
        List<Case> listCasos = new List<Case>();
        listCasos = [select id,CaseNumber, Description,SEG_Organizacion__c, SEG_Zona__c, CreatedDate,Account.CC_Numero_Documento__c,CC_MCC_Motivo__r.Name,SEG_Numero_centro__c from Case where id=:casoId limit 1];

        if(listCasos.size()==1)
        {
            if(tipoProceso=='alta')
            {
                //preparar mensaje de entrada:
                SEG_proc220IntsalesforceTws.ReceptorEntrada mensaje = new SEG_proc220IntsalesforceTws.ReceptorEntrada();

                mensaje.tipoProceso='S03';
                mensaje.origen='Salesforce';
                mensaje.numeroCaso=listCasos[0].CaseNumber;
                mensaje.codigoOperativa='13';
                mensaje.idCaso=listCasos[0].id;
                mensaje.fechaEvento=DateTime.now().day()+'/'+DateTime.now().month()+'/'+DateTime.now().year();
                mensaje.textoMail = listCasos[0].Description;
                
                Map<Id,List<ContentVersion>> mapEmailsAttachments = new Map<Id,List<ContentVersion>>();
                Map<Id,EmailMessage> mapEmails = new Map<Id,EmailMessage>();
                for(EmailMessage eM:[select id, FromAddress,CcAddress,BccAddress,Subject,ToAddress,HtmlBody,CreatedDate from EmailMessage where ParentId =:casoId])
                {
                    mapEmails.put(eM.id,eM);
                }
                mapEmailsAttachments = getEmailAndAttachments(casoId);
                List<SEG_proc220IntsalesforceTws.ContenidoAdicional> listofAdicional= new List<SEG_proc220IntsalesforceTws.ContenidoAdicional>();
                
                List<SEG_proc220IntsalesforceTws.TipoMail> listofMails= new List<SEG_proc220IntsalesforceTws.TipoMail>();
                
                Datetime GMTDate = listCasos[0].CreatedDate;
                String strConvertedDate = GMTDate.format('MM/dd/yyyy HH:mm:ss','America/New_York');
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdRem= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdRec= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdAsu= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdZna= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdFec= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdMcc= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdGrp= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdNif= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdcentro= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                SEG_proc220IntsalesforceTws.ContenidoAdicional contAdAccion= new SEG_proc220IntsalesforceTws.ContenidoAdicional();
                for(id mailid:mapEmails.keyset())
                {
                    if(mapEmails.get(mailid)!=null)
                    {
                        SEG_proc220IntsalesforceTws.TipoMail email = new SEG_proc220IntsalesforceTws.TipoMail();
                        email.id=mailid;
                        email.remitente=mapEmails.get(mailid).FromAddress;
                        email.asunto=mapEmails.get(mailid).Subject;
                        email.destinatario=mapEmails.get(mailid).ToAddress;
                        email.cc=mapEmails.get(mailid).CcAddress;
                        email.fechaCreacion=string.valueof(mapEmails.get(mailid).CreatedDate);
                        email.cuerpoHTML=mapEmails.get(mailid).HtmlBody;
                        contAdRem.key='Correo remitente';
                        contAdRem.value=mapEmails.get(mailid).FromAddress;
                        listofAdicional.add(contAdRem);
                        contAdRec.key='RECEPETOR';
                        contAdRec.value=mapEmails.get(mailid).ToAddress;
                        listofAdicional.add(contAdRec);
                        contAdAsu.key='Asunto';
                        contAdAsu.value=mapEmails.get(mailid).Subject;
                        List<SEG_proc220IntsalesforceTws.TipoAdjunto> listofAdjuntos= new List<SEG_proc220IntsalesforceTws.TipoAdjunto>();
                        for(ContentVersion cv:mapEmailsAttachments.get(mailid))
                        {
                            SEG_proc220IntsalesforceTws.TipoAdjunto adjunto = new SEG_proc220IntsalesforceTws.TipoAdjunto();
                            adjunto.fileName=cv.Title;
                            adjunto.fileId=cv.Id;
                            listofAdjuntos.add(adjunto);
                            System.debug('cv:'+cv);
                        }
                        email.docAdjuntos=listofAdjuntos;
                        listofMails.add(email);
                        listofAdicional.add(contAdAsu);
                    }
                    
                }
                contAdZna.key='Zona';
                contAdZna.value=listCasos[0].SEG_Zona__c;
                listofAdicional.add(contAdZna);
                contAdFec.key='FECHA APERTURA';
                contAdFec.value=strConvertedDate;
                listofAdicional.add(contAdFec);
                contAdMcc.key='Codificación MCC';
                contAdMcc.value='13';
                listofAdicional.add(contAdMcc);
                contAdGrp.key='Grupo';
                contAdGrp.value='13';
                listofAdicional.add(contAdGrp);
                contAdNif.key='NIF';
                contAdNif.value=listCasos[0].Account.CC_Numero_Documento__c;
                listofAdicional.add(contAdNif);
                contAdcentro.key='centro';
                contAdcentro.value=listCasos[0].SEG_Numero_centro__c;
                listofAdicional.add(contAdcentro);
                contAdAccion.key='Accion';
                contAdAccion.value=listCasos[0].CC_MCC_Motivo__r.Name;
                listofAdicional.add(contAdAccion);

                mensaje.contenidoMail=listofMails;
                mensaje.contenidoAdicional=listofAdicional;
                System.debug('mensaje: ' + mensaje.contenidoAdicional);
                SEG_proc220IntsalesforceTws.ReceptorContenido receptor = new SEG_proc220IntsalesforceTws.ReceptorContenido();
                receptor.Consulta = mensaje;
                SEG_proc220IntsalesforceTws.IntSalesforceSoap comunicacionws = new SEG_proc220IntsalesforceTws.IntSalesforceSoap();
                comunicacionws.clientCertName_x = certBPO;
                List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
                CC_TrazaInt__c oTraza;
                String sDescError = '';
                String sDetalleError = '';
                // Generar traza.
                oTraza = new CC_TrazaInt__c();
                oTraza.Name = 'CBPO_Segmentos_S03';
                oTraza.CC_FechaInicio__c = datetime.now();

                try {
                    string resultadoBPO = comunicacionws.Recepcion(receptor);
                    oTraza.CC_MensajeEntrada__c = String.valueOf(mensaje);
                    oTraza.CC_MensajeSalida__c = resultadoBPO;
                    oTraza.CC_FechaFin__c = datetime.now();
                    System.debug('resultado CBPO:'+resultadoBPO);

                } catch (Exception e) {
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = 'Error comunicaciones.';
                    oTraza.CC_DetalleError__c = e.getMessage();

                }
                if (oTraza != null){
                    oListTrazas.add(oTraza);
                }

                if (!oListTrazas.isEmpty()){
                    Database.SaveResult[] oResultTrazas = Database.insert(oListTrazas, false);
                }
                /*if (Test.isRunningTest()){
                }else{*/
                    //string test = comunicacionws.Recepcion(receptor);
                    //System.debug('resultado CBPO:'+test);
                //}
            }
        } 
    }


    public static Map<Id,List<ContentVersion>> getEmailAndAttachments(id casoId)
    {
        Map<Id,List<ContentVersion>> mapEmails = new Map<Id,List<ContentVersion>>();
        Set<Id> emailsIds = new Set<Id>();
        List<EmailMessage> listEmails = new List<EmailMessage>();
        listEmails = [select id, FromAddress,CcAddress,BccAddress,Subject,ToAddress,HtmlBody,CreatedDate from EmailMessage where ParentId =:casoId];
        for(EmailMessage eM:listEmails)
        {
            emailsIds.add(eM.id);
        }
        Map<Id,List<Id>> mapContentDocumentEmailLink = new Map<Id,List<Id>>();
        Set<Id> ContentDocumentIdIds = new Set<Id>();
        if(!emailsIds.isEmpty()){
            for(ContentDocumentLink codLink :[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId in:emailsIds ])
            {
                ContentDocumentIdIds.add(codLink.ContentDocumentId);
                if(mapContentDocumentEmailLink.containsKey(codLink.LinkedEntityId))
                {
                    List<Id> listContentDocumentId = new List<Id>();
                    listContentDocumentId = mapContentDocumentEmailLink.get(codLink.LinkedEntityId);
                    listContentDocumentId.add(codLink.ContentDocumentId);
                    mapContentDocumentEmailLink.put(codLink.LinkedEntityId,listContentDocumentId);
                }
                else
                {
                    List<Id> listContentDocumentId = new List<Id>();
                    listContentDocumentId.add(codLink.ContentDocumentId);
                    mapContentDocumentEmailLink.put(codLink.LinkedEntityId,listContentDocumentId); 
                }
            }

            
            Map<Id,ContentVersion> contentdocumentidFile = new Map<id,ContentVersion>(); //primer id --> contendocumentid, segundo id --> id
            for(ContentVersion cv:[select id,Title,FileExtension,ContentDocumentId from ContentVersion where ContentDocumentId in :ContentDocumentIdIds])
            {
            
                contentdocumentidFile.put(cv.ContentDocumentId,cv);
            }

            ////Map<Id,List<ContentDocument>> mapEmails = new Map<Id,List<ContentDocument>>();
            //Map<Id,List<Id>> mapContentDocumentEmailLink = new Map<Id,List<Id>>(); --> contiene id de email/linkedentitity y list de ContentDocumentId
            for(EmailMessage eM:listEmails)
            {
                if(mapContentDocumentEmailLink.containsKey(eM.id))
                {
                    if(mapEmails.containsKey(eM.id))
                    {
                        List<ContentVersion> cDM= mapEmails.get(eM.id);
                        for(id cDid:mapContentDocumentEmailLink.get(eM.id))
                        {
                            cDM.add(contentdocumentidFile.get(cDid));
                        }
                        mapEmails.put(eM.id,cDM);
                    }
                    else
                    {
                        List<ContentVersion> cDM= new List<ContentVersion>();
                        for(id cDid:mapContentDocumentEmailLink.get(eM.id))
                        {
                            cDM.add(contentdocumentidFile.get(cDid));
                        }
                        mapEmails.put(eM.id,cDM);
                    }
                }
                else
                {
                    List<ContentVersion> cDM= new List<ContentVersion>();
                    mapEmails.put(eM.id,cDM);
                }
            }
            /*for(id test:mapEmails.keyset())
            {
                if(mapEmails.get(test)!=null)
                {
                    System.debug('El correo con id: '+test+' tiene:');
                    for(ContentVersion cv:mapEmails.get(test))
                    {
                        System.debug('cv:'+cv);
                    }
                }
                
            }*/
        
            return mapEmails;
        }
    return null;
        
    }
    
}



/*
        public class TipoMail {
        public String id;
        public String remitente;
        public String asunto;
        public String destinatario;
        public String cc;
        public String fechaCreacion;
        public String cuerpoHTML;
        public SEG_proc220IntsalesforceTws.TipoAdjunto[] docAdjuntos;
        private String[] id_type_info = new String[]{'id','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] remitente_type_info = new String[]{'remitente','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] asunto_type_info = new String[]{'asunto','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] destinatario_type_info = new String[]{'destinatario','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] cc_type_info = new String[]{'cc','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] fechaCreacion_type_info = new String[]{'fechaCreacion','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] cuerpoHTML_type_info = new String[]{'cuerpoHTML','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] docAdjuntos_type_info = new String[]{'docAdjuntos','http://PROC220/IntSalesforce.tws',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://PROC220/IntSalesforce.tws','true','false'};
        private String[] field_order_type_info = new String[]{'id','remitente','asunto','destinatario','cc','fechaCreacion','cuerpoHTML','docAdjuntos'};
    }
     public class TipoAdjunto {
        public String fileName;
        public String fileId;
        private String[] fileName_type_info = new String[]{'fileName','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] fileId_type_info = new String[]{'fileId','http://PROC220/IntSalesforce.tws',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://PROC220/IntSalesforce.tws','true','false'};
        private String[] field_order_type_info = new String[]{'fileName','fileId'};
*/