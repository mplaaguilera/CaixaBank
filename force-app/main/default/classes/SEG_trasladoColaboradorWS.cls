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

        

        /*  Jaime:
            Operación 06: Expediente electrónico Persona
        */
        public String cifOrdenante {get;set;} //Jaime: Operación 06: Obligatorio, validar NIF
        public String nombreTitular {get;set;} //tambien presente en operacion 01
        public String contacto {get;set;} //tambien presente en operacion 01
        public String telefono {get;set;} //tambien presente en operacion 01
        public String numPer {get;set;} //obligatorio
        public String prestamoICO {get;set;} //tambien presente en operacion 01

        /*  Jaime:
            Operación 01: Expediente electrónico
         */
        public String tipoOperacion {get;set;} //select con 2 posibles valores
        public String numExpediente {get;set;}
        public String cifNif {get;set;}
        public String cifNif2 {get;set;}
        public String nombreTitular2 {get;set;}
        public String cifNif3 {get;set;}
        public String nombreTitular3 {get;set;}
        public String cifNif4 {get;set;}
        public String nombreTitular4 {get;set;}
        public String cifNif5 {get;set;}
        public String nombreTitular5 {get;set;}
        public String idEER {get;set;}


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

        public String cifOrdenante {get;set;} //Jaime: Operación 06: Obligatorio, validar NIF
        public String pagoAgrupado {get;set;}
        public String concepto {get;set;}
        public String documentos {get;set;}
        public String comunidadAutonoma {get;set;}

        /*  Jaime:
            Operación 06: Expediente electrónico Persona
        */
        public String nombreTitular {get;set;}
        public String contacto {get;set;} //tambien presente en operacion 01
        public String telefono {get;set;} //tambien presente en operacion 01
        public String numPer {get;set;} //obligatorio
        public String prestamoICO {get;set;} //tambien presente en operacion 01

        /*  Jaime:
            Operación 01: Expediente electrónico
         */
        public String tipoOperacion {get;set;} //select con 2 posibles valores
        public String numExpediente {get;set;}
        public String cifNif {get;set;}
        public String cifNif2 {get;set;}
        public String nombreTitular2 {get;set;}
        public String cifNif3 {get;set;}
        public String nombreTitular3 {get;set;}
        public String cifNif4 {get;set;}
        public String nombreTitular4 {get;set;}
        public String cifNif5 {get;set;}
        public String nombreTitular5 {get;set;}
        public String idEER {get;set;}


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
        public String action {get;set;}
        public String originId {get;set;}
        public String operationId {get;set;}
        public String branchId {get;set;}
        public String sourceApp {get;set;}
        public List<Map<String,String>> Metadatas {get;set;}
        public List<Adjuntos> Documents {get;set;}
    }

     public class SEG_RequestValijaOld
    {
        public SEG_Credenciales credenciales {get;set;}
        public Map<String,String> metadata {get;set;}
        public List<SEG_InfoData> infodata {get;set;}
        public Map<String,String> imagenesArray {get;set;}
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
     * @description Estructura del response de la respuesta de Valija 2.0.
     */
    public class SEG_ResponseValija_2 {
        public String briefcaseId {get;set;}
    }

    /**
     * @description Campos del JSON recibido en briefcaseId en Valija 2.0.
     */
    public class BriefCaseIdJSON{
        public String actor;
        public String aud;
        public String sub;
        public String iss;
        public String principalName;
        public Integer exp;
        public Integer iat;
        public String value; //Equivalente al id recibido en valijaOld 1.0
        public String jti;
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
    * @description Estructura del los archivos enviados a valija
    */
    public class Adjuntos
    {
        public String fileName {get;set;}
        public String format {get;set;}
        public String content {get;set;}
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
                String descripcionChatter = '';
                String operativa = '';

                if (datosTraslado.operacionFinalValija == '01') {
                    operativa = '01';

                    descripcionChatter = '<ul>'
                        + '<li>Se inicia el traslado a Valija del caso <b>' + datosTraslado.caseId.escapeHtml4() + '</b> asociado a ' + datosTraslado.tipoColaborador.escapeHtml4() + '</li>'
                        + '<li><b>Tipo de Operación: </b>' + datosTraslado.tipoOperacion.escapeHtml4() + '</li>' 
                        + '<li><b>Número de Expediente: </b>' + datosTraslado.numExpediente.escapeHtml4() + '</li>'
                        + '<li><b>CIF/NIF: </b>' + datosTraslado.cifNif.escapeHtml4() + '</li>' 
                        + '<li><b>Nombre Titular: </b>' + datosTraslado.nombreTitular.escapeHtml4() + '</li>' 
                        + '<li><b>CIF/NIF 2: </b>' + datosTraslado.cifNif2.escapeHtml4() + '</li>' 
                        + '<li><b>Nombre titular 2: </b>' + datosTraslado.nombreTitular2.escapeHtml4() + '</li>' 
                        + '<li><b>CIF/NIF 3: </b>' + datosTraslado.cifNif3.escapeHtml4() + '</li>' 
                        + '<li><b>Nombre titular 3: </b>' + datosTraslado.nombreTitular3.escapeHtml4() + '</li>' 
                        + '<li><b>CIF/NIF 4: </b>' + datosTraslado.cifNif4.escapeHtml4() + '</li>' 
                        + '<li><b>Nombre titular 4: </b>' + datosTraslado.nombreTitular4.escapeHtml4() + '</li>' 
                        + '<li><b>CIF/NIF 5: </b>' + datosTraslado.cifNif5.escapeHtml4() + '</li>' 
                        + '<li><b>Nombre titular 5: </b>' + datosTraslado.nombreTitular5.escapeHtml4() + '</li>' 
                        + '<li><b>Contacto: </b>' + datosTraslado.contacto.escapeHtml4() + '</li>' 
                        + '<li><b>Teléfono: </b>' + datosTraslado.telefono.escapeHtml4() + '</li>' 
                        + '<li><b>Préstamo ICO: </b>' + datosTraslado.prestamoICO.escapeHtml4() + '</li>' 
                        + '<li><b>ID_EER: </b>' + datosTraslado.idEER.escapeHtml4() + '</li>'
                        + '</ul>';
                } else if (datosTraslado.operacionFinalValija == '06') {
                    operativa = '06';

                    descripcionChatter = '<ul>'
                        + '<li>Se inicia el traslado del caso <b>' + datosTraslado.caseId.escapeHtml4() + '</b> asociado a ' + datosTraslado.tipoColaborador.escapeHtml4() + ' </li>' 
                        + '<li><b>CIF Ordenante: </b>' + datosTraslado.cifOrdenante.escapeHtml4() + '</li>' 
                        + '<li><b>Nombre Titular: </b>' + datosTraslado.nombreTitular.escapeHtml4() + '</li>' 
                        + '<li><b>Contacto: </b>' + datosTraslado.contacto.escapeHtml4() + '</li>' 
                        + '<li><b>Teléfono: </b>' + datosTraslado.telefono.escapeHtml4() + '</li>' 
                        + '<li><b>Préstamo ICO: </b>' + datosTraslado.prestamoICO.escapeHtml4() + '</li>'
                        + '</ul>';
                } else {
                    operativa = 'Autoasignar caso (Valija - WS)';

                    descripcionChatter = 'Se inicia el traslado a Valija al grupo colaborador <' + grupoTrasladoId + '> del caso '  + datosTraslado.caseId + 'asociado a ' + datosTraslado.tipoColaborador;
    
                }

                //Jaime OLD: descripcionChatter = 'Se inicia el traslado al grupo colaborador <' + grupoTrasladoId + '> asociado a ' + datosTraslado.tipoColaborador;
                descripcionChatter = (retorno.get('codigo') != '0') ? descripcionChatter + '. ERROR (' + retorno.get('codigo') + '): ' + retorno.get('detalle') : descripcionChatter;
                SEG_Case_Operativas_Controller.postOnChatter(datosTraslado.caseId, descripcionChatter, operativa, null);
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
            for (ContentDocumentLink linkFile : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId IN :mapaCasosPosiblesSinFiles.keySet()]) {
                // FIX. Excluir los ficheros HTML.
                if (linkFile.ContentDocument.FileExtension <> 'snote' && linkFile.ContentDocument.FileExtension <> 'htm' && linkFile.ContentDocument.FileExtension <> 'html'){ mapaCasosPosiblesSinFiles.put(linkFile.LinkedEntityId,true); }
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
            if (retornoTraslado.objetoTraza != null){ Database.SaveResult insertTrazaResultado = Database.insert(retornoTraslado.objetoTraza, false);}

            // Si la petición se ha enviado correctamente. Marcar el caso y los ficheros con la referencia Valija obtenida.
            if (retornoTraslado.status == 'OK')
            {
                Map<String,String> estadoUpdate = actualizarCasoDerivadoValija(datosTraslado, datosCalculadosTraslado, retornoTraslado.referenciaValija);
                if (estadoUpdate.get('codigo') != '0'){
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
                                SEG_Zona__c, SEG_Organizacion__c, SEG_Observaciones__c, Account.CC_Numero_Documento__c, Account.AV_NumPerso__c 
                                FROM Case
                                WHERE Id = :datosTraslado.caseId];
        if (!listadoCaso.isEmpty())
        {
            Case datosCaso = listadoCaso[0];

            /* Jaime: datos de operaciones 01 y 06 */
            datosRetorno.nombreTitular = (String.isNotBlank(datosTraslado.nombreTitular))?datosTraslado.nombreTitular:'';
            datosRetorno.contacto = (String.isNotBlank(datosTraslado.contacto))?datosTraslado.contacto:'';
            datosRetorno.telefono = (String.isNotBlank(datosTraslado.telefono))?datosTraslado.telefono:'';

            datosRetorno.numPer = (String.isNotBlank(datosCaso.Account?.AV_NumPerso__c))?datosCaso.Account?.AV_NumPerso__c:'';
            /* datosRetorno.numPer = (String.isNotBlank(datosTraslado.numPer))?datosTraslado.numPer:''; */
            datosRetorno.prestamoICO = (String.isNotBlank(datosTraslado.prestamoICO))?datosTraslado.prestamoICO:'';

            if (datosTraslado.operacionFinalValija == '06') {
                datosRetorno.cifOrdenante = (String.isNotBlank(datosTraslado.cifOrdenante))?datosTraslado.cifOrdenante:'';
            }else{
                datosRetorno.cifOrdenante = (String.isNotBlank(datosCaso.SEG_CIFOrdenanteValija__c))?datosCaso.SEG_CIFOrdenanteValija__c:'';
            }

            datosRetorno.tipoOperacion = (String.isNotBlank(datosTraslado.tipoOperacion))?datosTraslado.tipoOperacion:'';//select con 2 posibles valores
            datosRetorno.numExpediente = (String.isNotBlank(datosTraslado.numExpediente))?datosTraslado.numExpediente:'';
            datosRetorno.cifNif = (String.isNotBlank(datosTraslado.cifNif))?datosTraslado.cifNif:'';
            datosRetorno.cifNif2 = (String.isNotBlank(datosTraslado.cifNif2))?datosTraslado.cifNif2:'';
            datosRetorno.nombreTitular2 = (String.isNotBlank(datosTraslado.nombreTitular2))?datosTraslado.nombreTitular2:'';
            datosRetorno.cifNif3 = (String.isNotBlank(datosTraslado.cifNif3))?datosTraslado.cifNif3:'';
            datosRetorno.nombreTitular3 = (String.isNotBlank(datosTraslado.nombreTitular3))?datosTraslado.nombreTitular3:'';
            datosRetorno.cifNif4 = (String.isNotBlank(datosTraslado.cifNif4))?datosTraslado.cifNif4:'';
            datosRetorno.nombreTitular4 = (String.isNotBlank(datosTraslado.nombreTitular4))?datosTraslado.nombreTitular4:'';
            datosRetorno.cifNif5 = (String.isNotBlank(datosTraslado.cifNif5))?datosTraslado.cifNif5:'';
            datosRetorno.nombreTitular5 = (String.isNotBlank(datosTraslado.nombreTitular5))?datosTraslado.nombreTitular5:'';
            datosRetorno.idEER = (String.isNotBlank(datosTraslado.idEER))?datosTraslado.idEER:'';



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

        CC_TrazaInt__c trazaWS = new CC_TrazaInt__c();
        trazaWS.Name = 'SEG_Int_Valija';
        trazaWS.CC_FechaInicio__c = datetime.now();
        

        Boolean bError = false;
        String jsonRequest = '';
        String jsonResponse = '';

        string intSetting;

        SEG_Settings__c flujoValija = SEG_Settings__c.getValues('SEG_Flujo_Valija_Viejo');

        if (flujoValija != null && flujoValija.SEG_Activo__c) {
            intSetting = 'SEG_Int_Valija_2';
        }else {
            intSetting = 'SEG_Int_Valija';
        }

        try{

            
            //Generar el mensaje de request a Valija.
            if (flujoValija != null && flujoValija.SEG_Activo__c) {
                jsonRequest = generarJSONValija(informacionTraslado);
                
                trazaWS.CC_MensajeEntrada__c = JSON.serialize(jsonRequest);

                datosRetorno.mensajeEnviado = jsonRequest;

                String boundary = String.valueOf(Crypto.getRandomLong()).replace('-', '');

                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Accept-Encoding', 'gzip, deflate, br');
                mHeaders.put('Content-Type', 'multipart/form-data; boundary=' + boundary);

                // Construcción del cuerpo multipart/form-data
                String body = '--' + boundary + '\r\n';
                body = body + 'Content-Disposition: form-data; name="inputBody"\r\n';
                body = body + 'Content-Type: application/json\r\n\r\n';
                body = body + jsonRequest + '\r\n';
                body = body + '--' + boundary + '--';
  
                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = body;
                requestWrp.intSetting = intSetting;
                requestWrp.method = 'PUT';
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);

                // Preparar retorno.
                jsonResponse = response.getBody();
                String statusWS = 'OK';
                String detalleWS = '';
                Integer httpCodeWS = 200;
                String codigoWS = '0000';
                SEG_ResponseValija_2 datosRespuestaWS;
                String valijaIdSaliente = '';
                Boolean finOK = true;

                try{ if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                    // Error respuesta.
                    statusWS = 'NOK';
                    codigoWS = '0004';
                    httpCodeWS = response.getStatusCode();
                    detalleWS = 'Error en la integración con el servicio REST Valija (Callout - enviarTrasladoValija). ' + response.getStatus() + ' (' + response.getStatusCode() + ')';
                }else{
                    // Respuesta OK. Convertir JSON.
                    datosRespuestaWS = (SEG_ResponseValija_2)JSON.deserialize(jsonResponse, SEG_trasladoColaboradorWS.SEG_ResponseValija_2.class);
                    // Ya no aplica en Valija 2.0 statusWS = (datosRespuestaWS.ok == false) ? 'NOK' : statusWS;
                    // Ya no aplica en Valija 2.0 codigoWS = (datosRespuestaWS.ok == false) ? datosRespuestaWS.errorCode : statusWS;
                    detalleWS = 'Conexión correcta de la integración con el servicio REST Valija (Respuesta OK - enviarTrasladoValija).';
                    // FIX. Tratar la indisponibilidad / asíncromismo de Valija.

                        List<String> datosSplit = datosRespuestaWS.briefcaseId.split('\\.');
                        BriefCaseIdJSON datosBriefCase = (BriefCaseIdJSON) JSON.deserialize(EncodingUtil.base64Decode(datosSplit[1]).toString(), BriefCaseIdJSON.class);

                        valijaIdSaliente = (valijaIdSaliente == 'UNKNOWN') ? 'UNKNOWN' + CBK_UtilsDate.nowDT().getTime() : datosBriefCase.value;
                } 
                        finOK = (statusWS == 'OK') ? true : false; 
                }catch(Exception e){
                    CBK_Log.error(e);
                    trazaWS.CC_DetalleError__c = e.getMessage();
                }
                trazaWS = SEG_MetodosComunes.finTrazaNoInsert(trazaWS, jsonResponse, finOK, codigoWS, detalleWS);

                // Preparar retorno método.
                datosRetorno.status = statusWS;
                datosRetorno.detalle = detalleWS;
                datosRetorno.codigo = codigoWS;
                datosRetorno.httpCode = httpCodeWS;
                datosRetorno.mensajeRecibido = jsonResponse;
                datosRetorno.objetoTraza = trazaWS;
                datosRetorno.referenciaValija = valijaIdSaliente;

            } else {
                jsonRequest = generarJSONValijaOld(informacionTraslado);

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
                    statusWS = 'NOK'; codigoWS = '0004'; httpCodeWS = response.getStatusCode(); detalleWS = 'Error en la integración con el servicio REST Valija (Callout - enviarTrasladoValija). ' + response.getStatus() + ' (' + response.getStatusCode() + ')';
                }else{
                    // Respuesta OK. Convertir JSON.
                    datosRespuestaWS = (SEG_ResponseValija)JSON.deserialize(jsonResponse, SEG_trasladoColaboradorWS.SEG_ResponseValija.class);
                    statusWS = (datosRespuestaWS.ok == false) ? 'NOK' : statusWS;
                    codigoWS = (datosRespuestaWS.ok == false) ? datosRespuestaWS.errorCode : statusWS;
                    detalleWS = 'Error en la integración con el servicio REST Valija (Respuesta NOK - enviarTrasladoValija). ' + datosRespuestaWS.message + ' (' + datosRespuestaWS.errorCode + ')';

                    // FIX. Tratar la indisponibilidad / asíncromismo de Valija.
                    valijaIdSaliente = (datosRespuestaWS.ok == false) ? '' : datosRespuestaWS.id; valijaIdSaliente = (valijaIdSaliente == 'UNKNOWN') ? 'UNKNOWN' + Datetime.now().getTime() : valijaIdSaliente;
                } try{
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

            }
        }catch(Exception e){
            // Error en la llamada httpRequest.
            bError = true;
            datosRetorno.status = 'NOK';
            datosRetorno.codigo = '9999';
            datosRetorno.detalle = 'Error en la integración con el servicio REST (enviarTrasladoValija). ' + e.getMessage() + ' (' + e.getStackTraceString() + ')';
            CBK_Log.error(e);
        }
        insert trazaWS;
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

        if (informacionTraslado != null){

            // Estructura metadata. Separado por proceso.
            Map<String,String> metadata = new Map<String,String>();

            // Cualquier otro proceso no tratado arriba, no enviará datos en la estructura metadata.
            switch on informacionTraslado.procesoValija {

                /*  Jaime
                    Operación 01: Expediente Riesgo (SIA)
                */
                when '01'{
                    metadata.put('TIPO_OPERACION',informacionTraslado.tipoOperacion);
                    metadata.put('NUM_EXPEDIENTE',informacionTraslado.numExpediente);
                    metadata.put('CIF_NIF',informacionTraslado.cifNif);
                    metadata.put('NOMBRE_TITULAR',informacionTraslado.nombreTitular);
                    metadata.put('CIF_NIF_2',informacionTraslado.cifNif2);
                    metadata.put('NOMBRE_TITULAR2',informacionTraslado.nombreTitular2);
                    metadata.put('CIF_NIF_3',informacionTraslado.cifNif3);
                    metadata.put('NOMBRE_TITULAR3',informacionTraslado.nombreTitular3);
                    metadata.put('CIF_NIF_4',informacionTraslado.cifNif4);
                    metadata.put('NOMBRE_TITULAR4',informacionTraslado.nombreTitular4);
                    metadata.put('CIF_NIF_5',informacionTraslado.cifNif5);
                    metadata.put('NOMBRE_TITULAR5',informacionTraslado.nombreTitular5);
                    metadata.put('CONTACTO',informacionTraslado.contacto);
                    metadata.put('TELEFONO',informacionTraslado.telefono);
                    metadata.put('PRESTAMO_ICO', informacionTraslado.prestamoICO);
                    metadata.put('ID_EER',informacionTraslado.idEER);
                }

                when '02' {
                    metadata.put('TIPO_CARGO',informacionTraslado.tipoCargo);
                    metadata.put('FECHA_CARGO',informacionTraslado.fechaCargo);
                    metadata.put('CIF_ORDENANTE',informacionTraslado.cifOrdenante);
                    metadata.put('PAGO_AGRUPADO_RSS',informacionTraslado.pagoAgrupado);
                    metadata.put('SF_IDENTIFICADOR_VALIJA',informacionTraslado.paqueteriaId);
                    metadata.put('SF_MAIL_CLIENT',informacionTraslado.email);
                    metadata.put('SF_ID_CASO',informacionTraslado.caseId);
                    metadata.put('SF_NOTAS',informacionTraslado.notas);
                }

                /*  Jaime
                    Operación 06: Expediente Persona
                */
                when '06' {
                    metadata.put('CIF_NIF',informacionTraslado.cifOrdenante);
                    metadata.put('NOMBRE_TITULAR',informacionTraslado.nombreTitular);
                    metadata.put('CONTACTO',informacionTraslado.contacto);
                    metadata.put('TELEFONO',informacionTraslado.telefono);
                    metadata.put('NUMPER',informacionTraslado.numPer);
                    metadata.put('PRESTAMO_ICO', informacionTraslado.prestamoICO);
                }

                /* Impuestos AEAT */
                when '08' {
                    metadata.put('TIPO_CARGO',informacionTraslado.tipoCargo);
                    metadata.put('FECHA_CARGO',informacionTraslado.fechaCargo);
                    metadata.put('CIF_ORDENANTE',informacionTraslado.cifOrdenante);
                    metadata.put('SF_IDENTIFICADOR_VALIJA',informacionTraslado.paqueteriaId);
                    metadata.put('SF_NOTAS',informacionTraslado.notas);
                    metadata.put('SF_MAIL_CLIENT',informacionTraslado.email);
                    metadata.put('SF_ID_CASO',informacionTraslado.caseId);
                }

                /* Impuestos municipales */
                when '09' {
                    metadata.put('TIPO_CARGO',informacionTraslado.tipoCargo);
                    metadata.put('FECHA_CARGO',informacionTraslado.fechaCargo);
                    metadata.put('CIF_ORDENANTE',informacionTraslado.cifOrdenante);
                    metadata.put('SF_IDENTIFICADOR_VALIJA',informacionTraslado.paqueteriaId);
                    metadata.put('SF_NOTAS',informacionTraslado.notas);
                    metadata.put('SF_MAIL_CLIENT',informacionTraslado.email);
                    metadata.put('SF_ID_CASO',informacionTraslado.caseId);
                }

                /* Impuestos recibos no domiciliados (RIN) */
                when '47' {
                    metadata.put('TIPO_CARGO',informacionTraslado.tipoCargo);
                    metadata.put('FECHA_CARGO',informacionTraslado.fechaCargo);
                    metadata.put('CIF_ORDENANTE',informacionTraslado.cifOrdenante);
                    metadata.put('SF_IDENTIFICADOR_VALIJA',informacionTraslado.paqueteriaId);
                    metadata.put('SF_NOTAS',informacionTraslado.notas);
                    metadata.put('SF_MAIL_CLIENT',informacionTraslado.email);
                    metadata.put('SF_ID_CASO',informacionTraslado.caseId);
                }

                /* Impuestos comunidades autónomas */
                when '64' {
                    metadata.put('SF_IDENTIFICADOR_VALIJA',informacionTraslado.paqueteriaId);
                    metadata.put('SF_NOTAS',informacionTraslado.notas);
                    metadata.put('SF_MAIL_CLIENT',informacionTraslado.email);
                    metadata.put('SF_ID_CASO',informacionTraslado.caseId);
                    metadata.put('COMUNIDAD',informacionTraslado.comunidadAutonoma);
                }
            }

            // Lista para almacenar los objetos Metadatas
            List<Map<String, String>> metadatasList = new List<Map<String, String>>();

            // Convertir el mapa a la lista de objetos con key-value
            for (String key : metadata.keySet()) {
                Map<String, String> metadataEntry = new Map<String, String>();
                metadataEntry.put('key', key);
                metadataEntry.put('value', metadata.get(key));
                metadatasList.add(metadataEntry);
            }

            List<Adjuntos> blank = new List<Adjuntos>();

            // Generar la estructura de la request.
            SEG_RequestValija requestValija = new SEG_RequestValija();
            requestValija.action = 'NEW';
            requestValija.originId = 'SALESFORCE';

            
            requestValija.operationId = informacionTraslado.procesoValija;
            /* Jaime: OLD: SIEMPRE SE DA POR HECHO QUE ES OPERACION 08
            requestValija.operationId = '08'; */

            requestValija.branchId = informacionTraslado.sucursalCredencial; //Confirmar con negocio/valija
            requestValija.sourceApp = 'SEGMENTOS_SF';
            requestValija.Metadatas = metadatasList;
            requestValija.Documents = blank;

            if (!String.isBlank(informacionTraslado.ficherosBase64)) {
                List<Adjuntos> documentosCaso = new List<Adjuntos>();
                Adjuntos documento = new Adjuntos();
                documento.fileName = 'JSON Adjuntos';
                documento.format = 'JSON';
                documento.content = informacionTraslado.ficherosBase64;
                documentosCaso.add(documento);
                requestValija.Documents = documentosCaso;
            }

            // Generar el JSON de envío a Valija.
            jsonSalida = JSON.serialize(requestValija);
        }

        return jsonSalida;
    }

    public static String generarJSONValijaOld (SEG_trasladoColaboradorWS.SEG_DataTrasladoValija informacionTraslado)
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
                metadata.put('0',informacionTraslado.tipoCargo); metadata.put('1',informacionTraslado.fechaCargo); metadata.put('2',informacionTraslado.cifOrdenante); metadata.put('3',informacionTraslado.pagoAgrupado);
            }else if (informacionTraslado.procesoValija == '08' || informacionTraslado.procesoValija == '09' || informacionTraslado.procesoValija == '47'){
                // Impuestos AEAT (08), Impuestos Municipales (09), Recibos No Domiciliados - RIN (47)
                metadata.put('0',informacionTraslado.tipoCargo); metadata.put('1',informacionTraslado.fechaCargo); metadata.put('2',informacionTraslado.cifOrdenante);
            }else if (informacionTraslado.procesoValija == '64'){
                // Impuestos comunidades autónomas.
                metadata.put('0',informacionTraslado.comunidadAutonoma);
            }

            // Cualquier otro proceso no tratado arriba, no enviará datos en la estructura metadata.

            // Generar la estructura de la request.
            SEG_RequestValijaOld requestValija = new SEG_RequestValijaOld();
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