/**
 * @description Clase para el traslado a colaborador de tipo WebService.
 * Métodos auxiliares para la gestión del proceso.
 */
public with sharing class SEG_trasladoColaboradorWS{

    /**
     * @description Estructura de datos necesaria para realizar el traslado a colaborador.
     */
    public class SEG_DataTrasladoColaborador
    {
        public String caseId {get;set;}
        public String tipoColaborador {get;set;}
        public String oldGrupoId {get;set;}
        public String oldGrupoColaboradorId {get;set;}
        public String oldStatus {get;set;}
        public String oldSubStatus {get;set;}
        public String newGrupoId {get;set;}
        public String newGrupoName {get;set;}
        public String newGrupoColaboradorId {get;set;}
        public String newStatus {get;set;}
        public String newSubStatus {get;set;}
        public String operacionPaqueteria {get;set;}
        public String operacionValijaMCC {get;set;}
        public String operacionFinalValija {get;set;}
        public String notasManuales {get;set;}
        public String cuerpoTraslado {get;set;}
        public List<Id> ficherosSeleccionados {get;set;}

        public SEG_DataTrasladoColaborador()
        {
            // Inicalizamos la lista de ficheros.
            this.ficherosSeleccionados = new List<Id>();
        }
    }

    /**
     * @description Estructura de datos necesaria para los ficheros a trasladar a Valija.
     */
    public class SEG_DataFilesValija
    {
        public String nombredocumento {get;set;}
        public String ticketdocumento {get;set;}
        public String formato {get;set;}
    }

    /**
     * @description Estructura de datos necesaria con toda la información para el traslado a VALIJA.
     */
    public class SEG_DataTrasladoValija
    {
        // Estado del proceso de captación de datos.
        public String codigo {get;set;}
        public String detalle {get;set;}

        // Estructura credenciales.
        public String sucursalCredencial {get;set;}

        // Estructura metadata.
        public String caseId {get;set;}
        public String numeroCaso {get;set;}
        public String centro {get;set;}
        public String procesoValija {get;set;}
        public String email {get;set;}
        public String paqueteriaId {get;set;}
        public String tipoCargo {get;set;}
        public String fechaCargo {get;set;}
        public String cifOrdenante {get;set;}
        public String pagoAgrupado {get;set;}
        public String concepto {get;set;}
        public String documentos {get;set;}
        public String comunidadAutonoma {get;set;}

        // Estructura adicional
        public String zona {get;set;}
        public String servicio {get;set;}
        public String notas {get;set;}

        // Ficheros para valija.
        public String ficherosBase64 {get;set;}
        public List<SEG_DataFilesValija> ficheros {get;set;}
    }

    /**
     * @description Estructura de la request para el envío a Valija.
     */
    public class SEG_RequestValija
    {
        public SEG_Credenciales credenciales {get;set;}
        public Map<String,String> metadata {get;set;}
        public List<SEG_InfoData> infodata {get;set;}
        public Map<String,String> imagenesArray {get;set;}
    }

    public class SEG_Credenciales
    {
        public String sucursal {get;set;}
        public String codigo {get;set;}
        public String user {get;set;}
        public String password {get;set;}
        public String canal {get;set;}
    }

    public class SEG_InfoData 
    {
        public String nombre {get;set;}
        public String valor {get;set;}
    }

    /**
     * @description Estructura del response de la respuesta de Valija.
     */
    public class SEG_ResponseValija
    {
        public Boolean ok {get;set;}
        public String id {get;set;}
        public String errorCode {get;set;}
        public String message {get;set;}
    }

    /**
     * @description Estructura de datos para el retorno del traslado a colaborador por WebService
     */
    public class SEG_ResultadoTrasladoWS
    {
        public String status {get;set;}
        public String codigo {get;set;}
        public String detalle {get;set;}
        public String mensajeEnviado {get;set;}
        public String mensajeRecibido {get;set;}
        public Integer httpCode {get;set;}
        public CC_TrazaInt__c objetoTraza {get;set;}
        public String referenciaValija {get;set;}
    }

    /**
     * @description Método para preparar e iniciar el traslado a colaborador vía WebService
     * @param datosTraslado Datos necesarios para realizar el traslado a colaborador.
     */
    public static Map<String,String> iniciarTrasladoColaboradorWS (SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador datosTraslado)
    {
        Map<String,String> retorno = new Map<String,String>();
        retorno.put('codigo','0');
        retorno.put('detalle','');

        if (datosTraslado != null)
        {
            String grupoTrasladoId = '';

            try {
                // Estructura de traslado del proceso.
                grupoTrasladoId = (String.isNotBlank(datosTraslado.newGrupoName))?datosTraslado.newGrupoName:datosTraslado.newGrupoColaboradorId;
                Boolean seguirTraslado = true;
                Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> mapaDatosTraslados = new Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador>();

                // Preparación datos necesarios al traslado a colaborador de tipo Valija.
                if (datosTraslado.tipoColaborador == 'VALIJA')
                {
                    // Calcular la operación de Valija destino.
                    Map<String,String> datosOperacionValija = SEG_wsValijaCasosComunes.calcularOperacionValija(datosTraslado);
                    if (datosOperacionValija.get('codigo') != '0')
                    {
                        // Error calculando la operación.
                        String detalleError = 'Error al iniciar el traslado a colaborador <' + datosTraslado.newGrupoId + '> asociado a ' + datosTraslado.tipoColaborador;
                        detalleError = detalleError + '. Más información: ' + datosOperacionValija.get('detalle');

                        seguirTraslado = false;
                        retorno.put('codigo','1');
                        retorno.put('detalle', detalleError);
                    }else{
                        datosTraslado.operacionFinalValija = datosOperacionValija.get('operacionValija');
                    }

                    // Si es correcto, seguimos con la preparación de datos a enviar a Valija.
                    if (seguirTraslado)
                    {
                        mapaDatosTraslados.put(datosTraslado.caseId, datosTraslado);
                        SEG_DataTrasladoColaborador.preparacionDatosAdicionalesTrasladoValija(mapaDatosTraslados);

                        // Recuperar el usuario SEG_BO para asignarlo al caso.
                        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO'];

                        // Actualizamos el caso para ponerlo en el grupo destino.
                        Case caseUpdate = new Case();
                        caseUpdate.Id = datosTraslado.caseId;
                        caseUpdate.SEG_Validacion_Valija__c = true;
                        caseUpdate.OwnerId = colasBO[0].Id;
                        caseUpdate.SEG_Grupo__c = (String.isNotBlank(datosTraslado.newGrupoId)) ? datosTraslado.newGrupoId : datosTraslado.oldGrupoId;
                        caseUpdate.SEG_Grupo_colaborador_Externo__c = (String.isNotBlank(datosTraslado.newGrupoColaboradorId)) ? datosTraslado.newGrupoColaboradorId : datosTraslado.oldGrupoColaboradorId;
                        caseUpdate.Status = datosTraslado.newStatus;
                        caseUpdate.SEG_Subestado__c = datosTraslado.newSubStatus;
                        caseUpdate.OS_Referencia_Operacion__c = datosTraslado.operacionFinalValija;
                        SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(caseUpdate);
                    }
                }

                // Lanzamos el proceso asíncrono para el envío a Valija.
                if (seguirTraslado)
                {
                    List<SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> listadoTraslados = new List<SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador>();
                    listadoTraslados.add(datosTraslado);
                    SEG_trasladoColaboradorWSQueueable envioColaboradorWS = new SEG_trasladoColaboradorWSQueueable(listadoTraslados);
                    if (!listadoTraslados.isEmpty())
                    {
                        System.enqueueJob(envioColaboradorWS);
                    }
                }

            } catch (Exception e) {
                String detalleError = 'Error al iniciar el traslado a colaborador <' + grupoTrasladoId + '> asociado a ' + datosTraslado.tipoColaborador;
                detalleError = detalleError + '. Más información: ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
                retorno.put('codigo','9999');
                retorno.put('detalle',detalleError);
            }

            // Crear un post de chatter informando del inicio del proceso de traslado a WS.
            try
            {
                String descripcionChatter = 'Se inicia el traslado al grupo colaborador <' + grupoTrasladoId + '> asociado a ' + datosTraslado.tipoColaborador;
                descripcionChatter = (retorno.get('codigo') != '0') ? descripcionChatter + '. ERROR (' + retorno.get('codigo') + '): ' + retorno.get('detalle') : descripcionChatter;
                SEG_Case_Operativas_Controller.postOnChatter(datosTraslado.caseId, descripcionChatter, 'Autoasignar caso (Valija - WS)', null);
            }catch (Exception e){
                // Registramos el error.
                CBK_Log.error(e);
            }
        }

        return retorno;
    }

    /**
     * @description Método auxiliar para preparar todos los datos adicionales para el traslado de la petición a Valija.
     * @param mapaDatosTraslados Mapa por caso con los datos de su traslado a Valija.
     */
    public static void preparacionDatosAdicionalesTrasladoValija (Map<Id,SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador> mapaDatosTraslados)
    {
        if (mapaDatosTraslados == null || mapaDatosTraslados.isEmpty())
        {
            // Salimos sin tratar nada adicional.
            return;
        }

        Set<Id> setCasosFilesCreados = new Set<Id>();
        List<ContentVersion> filesToInsert = new List<ContentVersion>();

        // -------------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------------
        // Generar un fichero con el cuerpo del primer correo entrante que tiene anexado el caso.
        //      UPDATE: Queda descartado. NO se enviarán correos en formato HTML a Valija, ya que no los procesa.
        // -------------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------------
        /*for (Case caso : [SELECT Id, (SELECT Id, TextBody, HtmlBody FROM EmailMessages WHERE Incoming = true AND Status = '1' ORDER BY CreatedDate ASC LIMIT 1) 
                            FROM Case 
                            WHERE Id IN :mapaDatosTraslados.keySet()])
        {
            // Iteramos el posible resultado del primer correo entrante.
            for (EmailMessage email : caso.EmailMessages)
            {
                String dateMS = String.valueOf(Datetime.now().getTime());
                String nombreFile = 'Correo entrante (Valija) ' + dateMS;
                String cuerpoMail = email.HtmlBody;
                cuerpoMail = (String.isBlank(cuerpoMail)) ? email.TextBody : cuerpoMail;

                // Preparar la creación del fichero.
                ContentVersion newFile = new ContentVersion();
                newFile.ContentLocation = 'S';
                newFile.PathOnClient = nombreFile + '.html';
                newFile.Origin = 'C';
                newFile.Title = nombreFile;
                newFile.VersionData = Blob.valueOf(cuerpoMail);
                newFile.Description = 'TRASLADO_VALIJA_CORREO_ENTRANTE_' + caso.Id;
                newFile.SEG_ValijaSalienteId__c = null;
                //newFile.SEG_Tipo__c = 'ENVIADO A VALIJA';
                newFile.SEG_EnviadoValija__c = true;
                filesToInsert.add(newFile);
                setCasosFilesCreados.add(caso.Id);

                break;
            }
        }*/

        // -------------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------------
        // Generar un fichero con la posible nota de traslado a colaborador
        //      UPDATE: Queda descartado, dado que un traslado manual ya no funciona como en Siebel, a partir de la escritura de un correo.
        // -------------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------------
        /*for (Id caseId : mapaDatosTraslados.keySet())
        {
            String cuerpoTraslado = mapaDatosTraslados.get(caseId).cuerpoTraslado;
            if (String.isNotBlank(cuerpoTraslado))
            {
                ContentVersion newFile = new ContentVersion();
                newFile.ContentLocation = 'S';
                newFile.PathOnClient = 'Datos traslado (Valija).html';
                newFile.Origin = 'C';
                newFile.Title = 'Datos traslado (Valija)';
                newFile.VersionData = Blob.valueOf(cuerpoTraslado);
                newFile.Description = 'TRASLADO_VALIJA_' + caseId;
                newFile.SEG_ValijaSalienteId__c = null;
                newFile.SEG_Tipo__c = 'ENVIADO A VALIJA';
                filesToInsert.add(newFile);
                setCasosFilesCreados.add(caseId);
            }
        }

        if (!filesToInsert.isEmpty())
        {
            insert filesToInsert;

            // Recuperar los documentos generados para vincularlos al caso.
            List<Id> listadoVersiones = new List<Id>();
            for (ContentVersion versionDocumento : filesToInsert)
            {
                listadoVersiones.add(versionDocumento.Id);
            }

            // Recuperar los ContentDocument creados para vincularlos con su caso asociado.
            List<ContentDocumentLink> listadoLinksFiles = new List<ContentDocumentLink>();
            for (ContentVersion versionDocumento : [SELECT Id, ContentDocumentId, Description FROM ContentVersion WHERE Id IN :listadoVersiones AND IsLatest = true])
            {
                String caseId = versionDocumento.Description;
                caseId = (String.isNotBlank(caseId)) ? caseId.replaceAll('TRASLADO_VALIJA_CORREO_ENTRANTE_', '') : caseId;

                ContentDocumentLink linkFile = new ContentDocumentLink();
                linkFile.LinkedEntityId = caseId;
                linkFile.ContentDocumentId = versionDocumento.ContentDocumentId;
                linkFile.ShareType = 'I';
                listadoLinksFiles.add(linkFile);
            }

            if (!listadoLinksFiles.isEmpty())
            {
                insert listadoLinksFiles;
            }
        }*/

        // -------------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------------
        // Creación del fichero dummy para todos aquellos casos que no tienen ningún fichero.
        // -------------------------------------------------------------------------------------------------------------------
        // -------------------------------------------------------------------------------------------------------------------
        Map<Id,Boolean> mapaCasosPosiblesSinFiles = new Map<Id,Boolean>();
        for (Id caseId : mapaDatosTraslados.keySet())
        {
            Boolean contieneFiles = false;

            List<Id> ficherosSeleccionados = mapaDatosTraslados.get(caseId).ficherosSeleccionados;
            contieneFiles = ((ficherosSeleccionados != null && !ficherosSeleccionados.isEmpty()) || setCasosFilesCreados.contains(caseId)) ? true : false;
            if (!contieneFiles)
            {
                mapaCasosPosiblesSinFiles.put(caseId,false);
            }
        }

        // Recuperar todos los ficheros anexos del caso que NO se han detectado inicialmente ficheros a enviar.
        if (!mapaCasosPosiblesSinFiles.isEmpty())
        {
            for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN :mapaCasosPosiblesSinFiles.keySet()])
            {
                // FIX. Excluir los ficheros HTML.
                if (linkFile.ContentDocument.FileExtension <> 'snote' && linkFile.ContentDocument.FileExtension <> 'htm' && linkFile.ContentDocument.FileExtension <> 'html')
                {
                    mapaCasosPosiblesSinFiles.put(linkFile.LinkedEntityId,true);
                }
            }

            // Generar los ficheros dummy de los casos que no se ha detectado ningún fichero a enviar a Valija.
            List<ContentVersion> filesDummyToInsert = new List<ContentVersion>();
            for (Id caseId : mapaCasosPosiblesSinFiles.keySet())
            {
                if (!mapaCasosPosiblesSinFiles.get(caseId))
                {
                    String dateMS = String.valueOf(Datetime.now().getTime());
                    String nombreFile = 'Dummy_' + dateMS;

                    ContentVersion newFile = new ContentVersion();
                    newFile.ContentLocation = 'S';
                    newFile.PathOnClient = nombreFile + '.txt';
                    newFile.Origin = 'C';
                    newFile.Title = nombreFile;
                    newFile.VersionData = Blob.valueOf('Sin ficheros enviados');
                    newFile.Description = 'TRASLADO_VALIJA_FICHERO_DUMMY_' + caseId;
                    newFile.SEG_ValijaSalienteId__c = null;
                    //newFile.SEG_Tipo__c = 'ENVIADO A VALIJA';
                    newFile.SEG_EnviadoValija__c = true;
                    filesDummyToInsert.add(newFile);
                }
            }

            if (!filesDummyToInsert.isEmpty())
            {
                insert filesDummyToInsert;

                // Recuperar los documentos generados para vincularlos al caso.
                List<Id> listadoVersiones = new List<Id>();
                for (ContentVersion versionDocumento : filesDummyToInsert)
                {
                    listadoVersiones.add(versionDocumento.Id);
                }

                // Recuperar los ContentDocument creados para vincularlos con su caso asociado.
                List<ContentDocumentLink> listadoLinksFiles = new List<ContentDocumentLink>();
                for (ContentVersion versionDocumento : [SELECT Id, ContentDocumentId, Description FROM ContentVersion WHERE Id IN :listadoVersiones AND IsLatest = true])
                {
                    String caseId = versionDocumento.Description;
                    caseId = (String.isNotBlank(caseId)) ? caseId.replaceAll('TRASLADO_VALIJA_FICHERO_DUMMY_', '') : caseId;

                    ContentDocumentLink linkFile = new ContentDocumentLink();
                    linkFile.LinkedEntityId = caseId;
                    linkFile.ContentDocumentId = versionDocumento.ContentDocumentId;
                    linkFile.ShareType = 'I';
                    listadoLinksFiles.add(linkFile);
                }

                if (!listadoLinksFiles.isEmpty())
                {
                    insert listadoLinksFiles;
                }
            }
        }

        return;
    }

    /**
     * @description Método para realizar el traslado a colaborador VALIJA.
     * @param datosTraslado Datos necesarios para realizar el traslado a colaborador.
     */
    public static SEG_ResultadoTrasladoWS realizarTrasladoValija (SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador datosTraslado)
    {
        SEG_ResultadoTrasladoWS retornoTraslado = new SEG_ResultadoTrasladoWS();
        retornoTraslado.status = 'NOK';
        retornoTraslado.codigo = '0001';
        retornoTraslado.detalle = 'Traslado no enviado (realizarTrasladoValija)';

        if (datosTraslado != null)
        {
            // Recuperar todos los datos necesarios para realizar el traslado a colaborador.
            SEG_trasladoColaboradorWS.SEG_DataTrasladoValija datosCalculadosTraslado = recuperarDatosParaValija (datosTraslado);

            // Realizar el envío a colaborador VALIJA.
            if (datosCalculadosTraslado.codigo == '0')
            {
                retornoTraslado = enviarTrasladoValija (datosCalculadosTraslado);
            }else{
                retornoTraslado.codigo = '0002';
                retornoTraslado.detalle = datosCalculadosTraslado.detalle;
            }

            // Crear el objeto de traza
            if (retornoTraslado.objetoTraza != null)
            {
                Database.SaveResult insertTrazaResultado = Database.insert(retornoTraslado.objetoTraza, false);
            }

            // Si la petición se ha enviado correctamente. Marcar el caso y los ficheros con la referencia Valija obtenida.
            if (retornoTraslado.status == 'OK')
            {
                Map<String,String> estadoUpdate = actualizarCasoDerivadoValija(datosTraslado, datosCalculadosTraslado, retornoTraslado.referenciaValija);
                if (estadoUpdate.get('codigo') != '0')
                {
                    retornoTraslado.status = 'NOK';
                    retornoTraslado.codigo = '0003';
                    retornoTraslado.detalle = estadoUpdate.get('detalle');
                }
            }
        }

        return retornoTraslado;
    }

    /**
     * @description Recuperar y preparar todos los datos necesarios para el envío a Valija.
     * @param datosTraslado Datos iniciales del traslado a Valija.
     * @return Retorno de la estructura con todos los datos necesarios a enviar al WebService de Valija.
     */
    public static SEG_trasladoColaboradorWS.SEG_DataTrasladoValija recuperarDatosParaValija (SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador datosTraslado)
    {
        SEG_trasladoColaboradorWS.SEG_DataTrasladoValija datosRetorno = new SEG_trasladoColaboradorWS.SEG_DataTrasladoValija();
        datosRetorno.codigo = '0';
        datosRetorno.detalle = '';

        // Recuperar la configuración de servicios de valija.
        Map<String,String> matrizServicios = SEG_wsValijaCasosComunes.matrizServiciosValija();

        // Recuperar los datos del caso.
        List<Case> listadoCaso = [SELECT Id, AccountId, Account.RecordTypeId, Account.RecordType.DeveloperName, Account.SEG_Prioridad_Carterizacion_Segmentos__c, 
                                Account.SEG_Oficina_Gestora_Segmentos__c, Account.AV_OficinaPrincipal__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, 
                                Account.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, SEG_Numero_centro__c, SEG_Numero_de_centro__c,
                                CaseNumber, ContactId, Contact.Email, OS_Referencia_Valija__c, SEG_TipoCargo__c, SEG_CIFOrdenanteValija__c,
                                SEG_PagoAgrupado__c, SEG_ConceptoValija__c, SEG_DocumentosValija__c, SEG_ComunidadAutonoma__c, SEG_FechaCargo__c,
                                SEG_Zona__c, SEG_Organizacion__c, SEG_Observaciones__c, Account.CC_Numero_Documento__c
                                FROM Case
                                WHERE Id = :datosTraslado.caseId];
        if (!listadoCaso.isEmpty())
        {
            Case datosCaso = listadoCaso[0];

            datosRetorno.sucursalCredencial = (String.isNotBlank(datosCaso.SEG_Numero_centro__c))?datosCaso.SEG_Numero_centro__c:'';
            datosRetorno.caseId = datosCaso.Id;
            datosRetorno.numeroCaso = datosCaso.CaseNumber;
            datosRetorno.centro = (String.isNotBlank(datosCaso.SEG_Numero_centro__c))?datosCaso.SEG_Numero_centro__c:'';
            datosRetorno.email = (String.isNotBlank(datosCaso.Contact?.Email))?datosCaso.Contact?.Email:'';
            datosRetorno.paqueteriaId = (String.isNotBlank(datosCaso.OS_Referencia_Valija__c))?datosCaso.OS_Referencia_Valija__c:'';
            datosRetorno.tipoCargo = (String.isNotBlank(datosCaso.SEG_TipoCargo__c))?datosCaso.SEG_TipoCargo__c:'';
            datosRetorno.fechaCargo = (datosCaso.SEG_FechaCargo__c != null)?String.valueOf(datosCaso.SEG_FechaCargo__c):'';
            // A petición de negocio, solo se envía el CIF Ordenante que ha llegado desde paquetería o que ha puesto explícito el usuario.
            // FIX. datosRetorno.cifOrdenante = (String.isNotBlank(datosCaso.SEG_CIFOrdenanteValija__c))?datosCaso.SEG_CIFOrdenanteValija__c:((String.isNotBlank(datosCaso.Account?.CC_Numero_Documento__c))?datosCaso.Account?.CC_Numero_Documento__c:'');
            datosRetorno.cifOrdenante = (String.isNotBlank(datosCaso.SEG_CIFOrdenanteValija__c))?datosCaso.SEG_CIFOrdenanteValija__c:'';
            datosRetorno.pagoAgrupado = (String.isNotBlank(datosCaso.SEG_PagoAgrupado__c))?datosCaso.SEG_PagoAgrupado__c:'';
            datosRetorno.concepto = (String.isNotBlank(datosCaso.SEG_ConceptoValija__c))?datosCaso.SEG_ConceptoValija__c:'';
            datosRetorno.documentos = (datosCaso.SEG_DocumentosValija__c != null)?String.valueOf(datosCaso.SEG_DocumentosValija__c):'0';
            datosRetorno.comunidadAutonoma = (String.isNotBlank(datosCaso.SEG_ComunidadAutonoma__c))?datosCaso.SEG_ComunidadAutonoma__c:'';
            datosRetorno.zona = (String.isNotBlank(datosCaso.SEG_Zona__c))?datosCaso.SEG_Zona__c:'';
            datosRetorno.notas = (String.isNotBlank(datosTraslado.notasManuales))?datosTraslado.notasManuales:'';

            // Estandarizar a 5 dígitos el número de oficina.
            datosRetorno.sucursalCredencial = datosRetorno.sucursalCredencial?.leftPad(5,'0');
            datosRetorno.centro = datosRetorno.centro?.leftPad(5,'0');

            // Proceso Valija.
            datosRetorno.procesoValija = datosTraslado.operacionFinalValija;

            // Calcular el servicio de Valija.
            datosRetorno.servicio = (String.isNotBlank(matrizServicios.get(datosCaso.SEG_Organizacion__c)))?matrizServicios.get(datosCaso.SEG_Organizacion__c):'';

            // Preparar los ficheros para el traslado.
            List<SEG_DataFilesValija> listadoFicherosWS = new List<SEG_DataFilesValija>();

            if (datosTraslado?.ficherosSeleccionados != null && !datosTraslado.ficherosSeleccionados.isEmpty())
            {
                // Recuperar los ficheros seleccionados. Vienen contentDocumentIds.
                for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, 
                                                        ContentDocument.FileExtension, ContentDocument.Title
                                                        FROM ContentDocumentLink WHERE LinkedEntityId = :datosTraslado.caseId AND ContentDocumentId IN :datosTraslado.ficherosSeleccionados])
                {
                    // FIX. Excluir los ficheros html.
                    if (linkFile.ContentDocument.FileExtension <> 'snote' && linkFile.ContentDocument.FileExtension <> 'htm' && linkFile.ContentDocument.FileExtension <> 'html')
                    {
                        SEG_DataFilesValija newFile = new SEG_DataFilesValija();
                        newFile.ticketdocumento = linkFile.ContentDocument.LatestPublishedVersionId;
                        newFile.formato = linkFile.ContentDocument.FileExtension;
                        newFile.nombredocumento = linkFile.ContentDocument.Title;
                        listadoFicherosWS.add(newFile);
                    }
                }

                // Recuperar los ficheros creados automáticos en el proceso de traslado.
                for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, 
                                                        ContentDocument.FileExtension, ContentDocument.Title
                                                        FROM ContentDocumentLink WHERE LinkedEntityId = :datosTraslado.caseId 
                                                        AND ContentDocument.LatestPublishedVersion.SEG_ValijaSalienteId__c = null
                                                        //AND ContentDocument.LatestPublishedVersion.SEG_Tipo__c = 'ENVIADO A VALIJA'
                                                        AND ContentDocument.LatestPublishedVersion.SEG_EnviadoValija__c = true
                                                        ])
                {
                    // FIX. Excluir los ficheros html.
                    if (linkFile.ContentDocument.FileExtension <> 'snote' && linkFile.ContentDocument.FileExtension <> 'htm' && linkFile.ContentDocument.FileExtension <> 'html')
                    {
                        SEG_DataFilesValija newFile = new SEG_DataFilesValija();
                        newFile.ticketdocumento = linkFile.ContentDocument.LatestPublishedVersionId;
                        newFile.formato = linkFile.ContentDocument.FileExtension;
                        newFile.nombredocumento = linkFile.ContentDocument.Title;
                        listadoFicherosWS.add(newFile);
                    }
                }

            }else{
                // Recuperar todos los ficheros anexos del caso. Se recuperará los html creados y el posible fichero dummy.txt. Para gestionar los traslados automáticos sin intervención del usuario.
                for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersionId, 
                                                        ContentDocument.FileExtension, ContentDocument.Title
                                                        FROM ContentDocumentLink WHERE LinkedEntityId = :datosTraslado.caseId])
                {
                    // FIX. Excluir los ficheros html.
                    if (linkFile.ContentDocument.FileExtension <> 'snote' && linkFile.ContentDocument.FileExtension <> 'htm' && linkFile.ContentDocument.FileExtension <> 'html')
                    {
                        SEG_DataFilesValija newFile = new SEG_DataFilesValija();
                        newFile.ticketdocumento = linkFile.ContentDocument.LatestPublishedVersionId;
                        newFile.formato = linkFile.ContentDocument.FileExtension;
                        newFile.nombredocumento = linkFile.ContentDocument.Title;
                        listadoFicherosWS.add(newFile);
                    }
                }
            }
            
            datosRetorno.ficheros = listadoFicherosWS;

            // Generar el contenido en Base64 de los ficheros.
            SEG_trasladoColaboradorWS.SEG_DataTrasladoValija jsonFicheros = new SEG_trasladoColaboradorWS.SEG_DataTrasladoValija();
            jsonFicheros.ficheros = listadoFicherosWS;
            
            String contenidoAdjuntosJson = JSON.serialize(jsonFicheros, true);
            contenidoAdjuntosJson = EncodingUtil.base64Encode(Blob.valueOf(contenidoAdjuntosJson));
            datosRetorno.ficherosBase64 = contenidoAdjuntosJson;

        }else{
            // Error, no se ha encontrado el caso.
            datosRetorno.codigo = '1';
            datosRetorno.detalle = 'No se ha encontrado el caso ' + datosTraslado.caseId;
            CBK_Log.error('TRASLADO VALIJA. ' + datosRetorno.detalle);
        }
        return datosRetorno;
    }

    /**
     * @description Realizar el traslado a colaborador por petición HTTPRequest.
     * @param datosTraslado Datos iniciales del traslado a Valija.
     * @return Retorno de la estructura con todos los datos necesarios a enviar al WebService de Valija.
     */
    public static SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS enviarTrasladoValija (SEG_trasladoColaboradorWS.SEG_DataTrasladoValija informacionTraslado)
    {
        SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS datosRetorno = new SEG_trasladoColaboradorWS.SEG_ResultadoTrasladoWS();
        datosRetorno.status = 'NOK';
        datosRetorno.codigo = '0001';
        datosRetorno.detalle = 'Traslado no enviado (enviarTrasladoValija)';

        CC_TrazaInt__c trazaWS;
        Boolean bError = false;
        String jsonRequest = '';
        String jsonResponse = '';

        string intSetting = 'SEG_Int_Valija';

        try{

            // Generar el mensaje de request a Valija.
            jsonRequest = generarJSONValija (informacionTraslado);
            datosRetorno.mensajeEnviado = jsonRequest;

            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(jsonRequest, intSetting, 'POST', mHeaders);

            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);


            // Preparar retorno.
            jsonResponse = response.getBody();
            String statusWS = 'OK';
            String detalleWS = '';
            Integer httpCodeWS = 200;
            String codigoWS = '0000';
            SEG_ResponseValija datosRespuestaWS;
            String valijaIdSaliente = '';

            if (response.getStatusCode() != 200) {
                // Error respuesta.
                statusWS = 'NOK';
                codigoWS = '0004';
                httpCodeWS = response.getStatusCode();
                detalleWS = 'Error en la integración con el servicio REST Valija (Callout - enviarTrasladoValija). ' + response.getStatus() + ' (' + response.getStatusCode() + ')';
            }else{
                // Respuesta OK. Convertir JSON.
                datosRespuestaWS = (SEG_ResponseValija)JSON.deserialize(jsonResponse, SEG_trasladoColaboradorWS.SEG_ResponseValija.class);
                statusWS = (datosRespuestaWS.ok == false) ? 'NOK' : statusWS;
                codigoWS = (datosRespuestaWS.ok == false) ? datosRespuestaWS.errorCode : statusWS;
                detalleWS = 'Error en la integración con el servicio REST Valija (Respuesta NOK - enviarTrasladoValija). ' + datosRespuestaWS.message + ' (' + datosRespuestaWS.errorCode + ')';

                // FIX. Tratar la indisponibilidad / asíncromismo de Valija.
                valijaIdSaliente = (datosRespuestaWS.ok == false) ? '' : datosRespuestaWS.id;
                valijaIdSaliente = (valijaIdSaliente == 'UNKNOWN') ? 'UNKNOWN' + Datetime.now().getTime() : valijaIdSaliente;
            }

            try{
                Boolean finOK = (statusWS == 'OK') ? true : false;
                trazaWS = SEG_MetodosComunes.finTrazaNoInsert(trazaWS, jsonResponse, finOK, codigoWS, detalleWS);
            }catch(Exception e){CBK_Log.error(e);}

            // Preparar retorno método.
            datosRetorno.status = statusWS;
            datosRetorno.detalle = detalleWS;
            datosRetorno.codigo = codigoWS;
            datosRetorno.httpCode = httpCodeWS;
            datosRetorno.mensajeRecibido = jsonResponse;
            datosRetorno.objetoTraza = trazaWS;
            datosRetorno.referenciaValija = valijaIdSaliente;

        }catch(Exception e){
            // Error en la llamada httpRequest.
            bError = true;
            datosRetorno.status = 'NOK';
            datosRetorno.codigo = '9999';
            datosRetorno.detalle = 'Error en la integración con el servicio REST (enviarTrasladoValija). ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
            CBK_Log.error(e);
        }

        return datosRetorno;
    }

    /**
     * @description Método para generar la request JSON necesaria para envío a Valija.
     * @param informacionTraslado Datos de la información del traslado a enviar.
     * @return JSON de envío a Valija.
     */
    public static String generarJSONValija (SEG_trasladoColaboradorWS.SEG_DataTrasladoValija informacionTraslado)
    {
        String jsonSalida = '';

        if (informacionTraslado != null)
        {
            // Recuperar parámetros configurados para Valija.
            Map<String, SEG_Parametros__mdt> mapaParametrosValija = SEG_MetodosComunes.recuperarParametrosProceso('Valija');
            String codigoValija = mapaParametrosValija.get('SEG_Valija_Operacion')?.SEG_Valor__c;
            String userValija = mapaParametrosValija.get('SEG_Valija_Usuario')?.SEG_Valor__c;
            String passwordValija = mapaParametrosValija.get('SEG_Valija_Password')?.SEG_Valor__c;
            String canalValija = mapaParametrosValija.get('SEG_Valija_Canal')?.SEG_Valor__c;

            // Estructura credenciales.
            SEG_Credenciales credenciales = new SEG_Credenciales();
            credenciales.sucursal = informacionTraslado.sucursalCredencial;
            credenciales.codigo = codigoValija;
            credenciales.user = userValija;
            credenciales.password = passwordValija;
            credenciales.canal = canalValija;

            // Estructura infoData.
            List<SEG_InfoData> listaInfoData = new List<SEG_InfoData>();

            SEG_InfoData data1 = new SEG_InfoData();
            data1.nombre = 'SF_ID_PROCESO_VALIJA';
            data1.valor = informacionTraslado.procesoValija;
            listaInfoData.add(data1);

            SEG_InfoData data2 = new SEG_InfoData();
            data2.nombre = 'SF_ID_CASO';
            data2.valor = informacionTraslado.caseId;
            listaInfoData.add(data2);

            SEG_InfoData data3 = new SEG_InfoData();
            data3.nombre = 'SF_IDENTIFICADOR_VALIJA';
            data3.valor = informacionTraslado.paqueteriaId;
            listaInfoData.add(data3);

            SEG_InfoData data4 = new SEG_InfoData();
            data4.nombre = 'SF_MAIL_CLIENT';
            data4.valor = informacionTraslado.email;
            listaInfoData.add(data4);

            SEG_InfoData data5 = new SEG_InfoData();
            data5.nombre = 'SF_NOTAS';
            data5.valor = informacionTraslado.notas;
            listaInfoData.add(data5);

            SEG_InfoData data6 = new SEG_InfoData();
            data6.nombre = 'SF_SERVICIO';
            data6.valor = informacionTraslado.servicio;
            listaInfoData.add(data6);

            SEG_InfoData data7 = new SEG_InfoData();
            data7.nombre = 'SF_ZONA';
            data7.valor = informacionTraslado.zona;
            listaInfoData.add(data7);

            // Estructura imagenesArray.
            Map<String,String> imagenesArray = new Map<String,String>();
            imagenesArray.put('adjuntos_json', informacionTraslado.ficherosBase64);

            // Estructura metadata. Separado por proceso.
            Map<String,String> metadata = new Map<String,String>();

            if (informacionTraslado.procesoValija == '02')
            {
                // Seguros Sociales.
                metadata.put('0',informacionTraslado.tipoCargo);
                metadata.put('1',informacionTraslado.fechaCargo);
                metadata.put('2',informacionTraslado.cifOrdenante);
                metadata.put('3',informacionTraslado.pagoAgrupado);
            }else if (informacionTraslado.procesoValija == '08' || informacionTraslado.procesoValija == '09' || informacionTraslado.procesoValija == '47'){
                // Impuestos AEAT (08), Impuestos Municipales (09), Recibos No Domiciliados - RIN (47)
                metadata.put('0',informacionTraslado.tipoCargo);
                metadata.put('1',informacionTraslado.fechaCargo);
                metadata.put('2',informacionTraslado.cifOrdenante);
            }else if (informacionTraslado.procesoValija == '64'){
                // Impuestos comunidades autónomas.
                metadata.put('0',informacionTraslado.comunidadAutonoma);
            }

            // Cualquier otro proceso no tratado arriba, no enviará datos en la estructura metadata.

            // Generar la estructura de la request.
            SEG_RequestValija requestValija = new SEG_RequestValija();
            requestValija.credenciales = credenciales;
            requestValija.metadata = metadata;
            requestValija.infodata = listaInfoData;
            requestValija.imagenesArray = imagenesArray;
    
            // Generar el JSON de envío a Valija.
            jsonSalida = JSON.serialize(requestValija);
            jsonSalida = jsonSalida.replaceAll('adjuntos_json', 'adjuntos.json');
        }

        return jsonSalida;
    }

    /**
     * @description Actualizar los datos del caso y ficheros que se han enviado a Valija.
     * @param datosOriginalesTraslado Datos originales que han iniciado el traslado a colaborador.
     * @param informacionTraslado Datos utilizados en el traslado a colaborador de Valija.
     * @param retornoValija Datos retornados por el servicio de Valija.
     * @return Estado del proceso de actualización.
     */
    public static Map<String,String> actualizarCasoDerivadoValija (SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador datosOriginalesTraslado, SEG_trasladoColaboradorWS.SEG_DataTrasladoValija informacionTraslado, String referenciaValija)
    {
        Map<String,String> retorno = new Map<String,String>();
        retorno.put('codigo','0');
        retorno.put('detalle','');

        if (informacionTraslado == null || referenciaValija == null)
        {
            retorno.put('codigo','1');
            retorno.put('detalle','No hay datos de traslado o referencia de Valija para actualizar el caso. Error interno en <actualizarCasoDerivadoValija>');
            return retorno;
        }

        // Comprobar si ya existe un caso con la referencia de Valija asignada.
        Boolean esValidaReferencia = true;

        //Queda deprecada la obtención de RT por rendimiento
        Set<String> objetos = new Set<String>();
		objetos.add('Case');
		Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
		Id recordTypeSEG = rtObjetos.get('Case').get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = rtObjetos.get('Case').get('SEG_Seguimiento').getRecordTypeId();

        List<Id> listaIds = new List<Id>();
        listaIds.add(recordTypeSEG);
        listaIds.add(recordTypeSeguimiento);

        List<Case> listaCasos = [SELECT Id FROM Case WHERE SEG_RefSalienteValija__c = :referenciaValija AND Id <> :informacionTraslado.caseId AND RecordTypeId IN :listaIds];
        if (!listaCasos.isEmpty())
        {
            esValidaReferencia = false;
            retorno.put('codigo','2');
            retorno.put('detalle','La referencia de Valija <' + referenciaValija + '> devuelta por el proceso de traslado ya está asignada a otro caso (' + listaCasos[0].Id + ')');
        }

        // Actualizar el caso con la información tratada.
        SEG_Case_BU_TRHan.procesado = true;
        SEG_Modificadores_Trigger.desactivarModificador('SEG_Case_BU_TRHan: reejecutar lógica');
        SEG_Modificadores_Trigger.activarModificador('SEG_Case_AU_TRHan: bypass');

        Case caseUpdate = new Case();
        caseUpdate.Id = informacionTraslado.caseId;
        caseUpdate.SEG_EstadoTrasladoValija__c = 'Iniciado';
        caseUpdate.SEG_RefSalienteValija__c = (esValidaReferencia == true) ? referenciaValija : null;
        // En caso de error con la referencia, se activará el caso en el grupo respuesta del traslado con una incidencia.
        caseUpdate.Status = (esValidaReferencia == true) ? datosOriginalesTraslado.newStatus : datosOriginalesTraslado.oldStatus;
        caseUpdate.SEG_Subestado__c = (esValidaReferencia == true) ? datosOriginalesTraslado.newSubStatus : datosOriginalesTraslado.oldSubStatus;     
        // Actualizar el cif ordenante enviado a Valija.
        caseUpdate.SEG_CIFOrdenanteValija__c = informacionTraslado.cifOrdenante;   
        SEG_wsValijaCasosComunesNoSharing.actualizarCaseQueueable(caseUpdate);

        // Actualizar el listado de ficheros enviados a Valija.
        if (informacionTraslado.ficheros != null && !informacionTraslado.ficheros.isEmpty())
        {
            List<ContentVersion> listadoFicherosUpdate = new List<ContentVersion>();
            for (SEG_DataFilesValija fichero : informacionTraslado.ficheros)
            {
                ContentVersion ficheroUpdate = new ContentVersion();
                ficheroUpdate.Id = fichero.ticketdocumento;
                ficheroUpdate.SEG_ValijaSalienteId__c = referenciaValija;
                //ficheroUpdate.SEG_Tipo__c = 'ENVIADO A VALIJA';
                ficheroUpdate.SEG_EnviadoValija__c = true;
                listadoFicherosUpdate.add(ficheroUpdate);
            }

            if (!listadoFicherosUpdate.isEmpty())
            {
                SEG_wsValijaCasosComunesNoSharing.actualizarFilesQueueable(listadoFicherosUpdate);
            }
        }

        return retorno;
    }
}