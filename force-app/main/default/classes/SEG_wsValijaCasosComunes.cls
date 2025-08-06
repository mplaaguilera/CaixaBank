/**
*   @description SEG_wsValijaCasosComunes
*/
public with sharing class SEG_wsValijaCasosComunes {

    /**
     *  @description Buscar la clasificación rápida a partir del proceso de Valija.
     *  @param procesoValija Nombre del proceso de Valija.
     *  @param organizacion Organización asociado al proceso de Valija.
     *  @param bRecuperarCR Indicador si hay que recuperar los datos de la CR asociada al proceso de Valija.
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda
     */
    public static Map<String,String> recuperarProcesoValija (String procesoValija, String organizacion, Boolean bRecuperarCR)
    {
        Map<String,String> resultadoBusqueda = new Map<String,String>();
        String sError = '0';
        String sDescError = '';
        String tematicaMCC = '';
        String productoMCC = '';
        String motivoMCC = '';
        String detalleMCC = '';
        String idClasificacion = '';
        String areaProceso = '';
        Id idCR;
        String nombreCR = '';
        String descripcionProceso = 'Proceso con código ' + procesoValija;

        if (String.isNotBlank(procesoValija))
        {
            // Buscar la parametrización del proceso.
            List<CC_Lista_Valores__c> configuracionProcesoValija = [SELECT Id, OS_Descripcion__c, CC_Valor__c, CC_Valor_SFDC__c, SEG_CRId__c FROM CC_Lista_Valores__c
                                                                    WHERE CC_Lista__r.Name = 'VALIJA: PROCESOS SEGMENTOS'
                                                                    AND Name = :procesoValija 
                                                                    AND CC_Valor__c = :organizacion 
                                                                    AND CC_Activa__c = true
                                                                    LIMIT 1];
            if (!configuracionProcesoValija.isEmpty())
            {
                areaProceso = configuracionProcesoValija[0].CC_Valor__c;
                idCR = configuracionProcesoValija[0].SEG_CRId__c;
                descripcionProceso = configuracionProcesoValija[0].OS_Descripcion__c;
            }else{
                configuracionProcesoValija = [SELECT Id, OS_Descripcion__c, CC_Valor__c, CC_Valor_SFDC__c, SEG_CRId__c FROM CC_Lista_Valores__c
                                                                    WHERE CC_Lista__r.Name = 'VALIJA: PROCESOS SEGMENTOS'
                                                                    AND Name = :procesoValija 
                                                                    AND (CC_Valor__c = 'Todas' OR CC_Valor__c = null OR CC_Valor__c = '')
                                                                    AND CC_Activa__c = true
                                                                    LIMIT 1];
                if (!configuracionProcesoValija.isEmpty())
                {
                    areaProceso = configuracionProcesoValija[0].CC_Valor__c;
                    idCR = configuracionProcesoValija[0].SEG_CRId__c;
                    descripcionProceso = configuracionProcesoValija[0].OS_Descripcion__c;
                }
            }

            if (String.isBlank(areaProceso))
            {
                // Error, proceso no configurado.
                sError = '2';
                sDescError = 'No se ha encontrado el proceso de Valija configurado en Salesforce.';
            }

            if (sError == '0' && idCR !=  null && bRecuperarCR)
            {
                List<SEG_ClasificacionRapida__c> listaCR = [SELECT Id, Name, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c
                                                FROM SEG_ClasificacionRapida__c 
                                                WHERE Id = :idCR AND SEG_Inactiva__c = false];
                if (listaCR.size() == 1)
                {
                    // Cliente identificado.
                    idClasificacion = listaCR[0].Id;
                    nombreCR = listaCR[0].Name;
                    tematicaMCC = listaCR[0].SEG_Tematica__c;
                    productoMCC = listaCR[0].SEG_Producto__c;
                    motivoMCC = listaCR[0].SEG_Motivo__c;
                    detalleMCC = listaCR[0].SEG_Detalle__c;
                }else if (listaCR.size() == 0){
                    // Ningún clientes.
                    sError = '1';
                    sDescError = 'La CR no se ha encontrado';
                }
            }
        }

        resultadoBusqueda.put('codigo',sError);
        resultadoBusqueda.put('detalle',sDescError);
        resultadoBusqueda.put('areaProceso', areaProceso);
        resultadoBusqueda.put('CRId', idClasificacion);
        resultadoBusqueda.put('CRName', nombreCR);
        resultadoBusqueda.put('tematicaMCC',tematicaMCC);
        resultadoBusqueda.put('productoMCC',productoMCC);
        resultadoBusqueda.put('motivoMCC',motivoMCC);
        resultadoBusqueda.put('detalleMCC',detalleMCC);
        resultadoBusqueda.put('descripcionValija', descripcionProceso);
        return resultadoBusqueda;
    }

    /**
     * @description Método para validar si una referencia de valija está asignada a un caso.
     * @param valijaId Identificador de valija.
     * @return Indicador (true /false) si la referencia de valija ya existe.
     */
    public static Boolean comprobarValijaIdExistente (String valijaId)
    {
        Boolean bExiste = false;

        if (String.isNotBlank(valijaId))
        {
            List<Id> listaRTsSegmentos = new List<Id>();
            listaRTsSegmentos.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId());
            listaRTsSegmentos.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId());

            List<Case> listaCasos = [SELECT Id FROM Case WHERE OS_Referencia_Valija__c = :valijaId AND RecordTypeId IN :listaRTsSegmentos];
            if (!listaCasos.isEmpty())
            {
                bExiste = true;
            }
        }

        return bExiste;
    }

    /**
     * @description Método para recuperar la información de un caso en los procesos de Valija.
     * @param identificadorCaso Identificador del caso
     * @return Objeto con los datos del caso residente en Salesforce.
     */
    public static Case recuperarInformacionCaso (String identificadorCaso)
    {
        Case casoEncontrado;

        if (String.isNotBlank(identificadorCaso))
        {
            /*List<Case> listadoCasos = [SELECT Id, OS_Referencia_Valija__c, SEG_RecepcionFicherosPaqueteria__c, SEG_EstadoTrasladoValija__c, AccountId, ContactId, SEG_Organizacion__c, 
                                        SEG_Zona__c, CC_Idioma__c, SEG_Fecha_valor__c, Status, SEG_Subestado__c, SEG_Resultado__c, Origin, SEG_RefSalienteValija__c, SEG_creacionPAK__c,
                                        SEG_N_operaciones_del_caso__c, CC_MCC_Motivo__c
                                        FROM Case
                                        WHERE Id = :identificadorCaso
                                        AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')];
            if (!listadoCasos.isEmpty())
            {
                casoEncontrado = listadoCasos[0];
            }*/

            // Mantener retrocompatibilidad con el resto de clases. Recuperar el caso sin bloquearlo.
            casoEncontrado = SEG_wsValijaCasosComunesNoSharing.recuperarInformacionCaso(identificadorCaso, false);
        }

        return casoEncontrado;
    }

    /**
     * @description Validación de los ficheros asociados al proceso de Valija
     * @param caseId Identificador del caso a validar los ficheros.
     * @param tipoFichero Tipo de fichero a validar (0 -> Paqueteria, 1 -> Justificantes - Salientes, 2 -> Ficheros enviados a Valija, 3 -> Ficheros enviados a Valija (procesados))
     * @param valijaId Identificador de Valija
     * @param fileList Listado de ficheros a validar.
     * @return Mapa con el estado de la validación.
     */
    public static Map<String,String> validarFicherosValija (String caseId, Integer tipoFichero, String valijaId, List<String> fileList)
    {
        Map<String,String> retorno = new Map<String,String>();
        retorno.put('error','0');
        retorno.put('detalle','');

        if (String.isBlank(caseId) || tipoFichero == null || (tipoFichero != 0 && tipoFichero != 1 && tipoFichero != 2 && tipoFichero != 3) || 
        (tipoFichero == 0 && String.isBlank(valijaId)) || fileList == null || fileList.isEmpty())
        {
            retorno.put('error','1');
            retorno.put('detalle','Datos obligatorios no informados');
            return retorno;
        }

        // Obtener la lista de documentos asociados al caso.
        List<Id> listadoContentDocId = new List<Id>();
        for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId = :caseId])
        {
            listadoContentDocId.add(link.ContentDocumentId);
        }

        String tipoFicheroCVersion = '##NA##';
        tipoFicheroCVersion = (tipoFichero == 0) ? 'PAQUETERIA' : tipoFicheroCVersion;
        tipoFicheroCVersion = (tipoFichero == 1) ? 'JUSTIFICANTES' : tipoFicheroCVersion;
        tipoFicheroCVersion = (tipoFichero == 2 || tipoFichero == 3) ? 'ENVIADO A VALIJA' : tipoFicheroCVersion;

        String valijaEntrante = '##NA##';
        valijaEntrante = (tipoFichero == 0 || tipoFichero == 1) ? valijaId : valijaEntrante;

        String valijaSaliente = '##NA##';
        valijaSaliente = (tipoFichero == 2) ? valijaId : valijaSaliente;

        // FIX. A petición del equipo de Valija y por su gestión interna, la referencia de Valija que recibimos no será la misma que la que nos devolvió el WebService.
        //      Para el proceso 0 -> Paquetería: si se valida la coherencia del identificador de Valija.
        //      Para el proceso 1 -> Justificantes: No se valida la referencia de Valija, dado que por sus procesos internos puede no ser la misma. Sólo se valida el caso.
        //      Para el proceso 2 -> Recepción de ficheros enviados a Valija: Sólo se valida que el fichero sea del caso y se ha enviado a Valija, dado que por sus procesos internos puede no ser la misma. Sólo se valida el caso.
        List<ContentVersion> listadoContentVersion;
        if (tipoFichero == 0)
        {
            // Ficheros recibidos desde Valija.
            listadoContentVersion = [SELECT Id FROM ContentVersion
                                        WHERE ContentDocumentId IN :listadoContentDocId
                                        AND Id IN :fileList
                                        AND IsLatest = true
                                        AND SEG_ValijaId__c = :valijaEntrante
                                        AND SEG_Tipo__c = :tipoFicheroCVersion];
        }else if (tipoFichero == 1){
            // Justificantes recibidos desde Valija.
            listadoContentVersion = [SELECT Id FROM ContentVersion
                                        WHERE ContentDocumentId IN :listadoContentDocId
                                        AND Id IN :fileList
                                        AND IsLatest = true
                                        //OLD FIX. AND (SEG_ValijaId__c = :valijaEntrante OR SEG_ValijaSalienteId__c = :valijaSaliente)
                                        AND SEG_Tipo__c = :tipoFicheroCVersion
                                        ];
        }else if (tipoFichero == 2){
            // Ficheros descargados desde Valija.
            // Validación genérica de ficheros del caso. FIX. No se mira la marca de enviado a Valija para evitar que la transacción de traslado sea más tarde que la recepción del evento.
            listadoContentVersion = [SELECT Id FROM ContentVersion
                                        WHERE ContentDocumentId IN :listadoContentDocId
                                        AND Id IN :fileList
                                        AND IsLatest = true
                                        //OLD FIX. AND (SEG_ValijaId__c = :valijaEntrante OR SEG_ValijaSalienteId__c = :valijaSaliente)
                                        //OLD FIX. AND SEG_EnviadoValija__c = true
                                        ];
        }else{
            // Validación genérica de ficheros del caso y que se han enviado a Valija.
            listadoContentVersion = [SELECT Id FROM ContentVersion
                                        WHERE ContentDocumentId IN :listadoContentDocId
                                        AND Id IN :fileList
                                        AND IsLatest = true
                                        //OLD FIX. AND (SEG_ValijaId__c = :valijaEntrante OR SEG_ValijaSalienteId__c = :valijaSaliente)
                                        AND SEG_EnviadoValija__c = true
                                        ];
        }

        if (listadoContentVersion.size() != fileList.size())
        {
            retorno.put('error','2');
            retorno.put('detalle','Uno o varios ficheros no son válidos.');
            return retorno;
        }

        return retorno;
    }

    /**
     *  @description Calcular la matriz de conversión de procesos de paquetería a procesos Valija.
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda
     */
    public static Map<String,String> matrizProcesosValija ()
    {
        Map<String,String> resultadoBusqueda = new Map<String,String>();

            // Buscar la parametrización del proceso.
        for (CC_Lista_Valores__c configuracionProcesoValija : [SELECT Name, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
                                                                    WHERE CC_Lista__r.Name = 'VALIJA: PROCESOS SEGMENTOS'])
        {
            resultadoBusqueda.put(configuracionProcesoValija.Name, configuracionProcesoValija.CC_Valor_SFDC__c);
        }

        return resultadoBusqueda;
    }

    /**
     *  @description Calcular la matriz de conversión de organización a servicio Valija.
     *  @return Map<String,String> -> Mapa con los resultados de la búsqueda
     */
    public static Map<String,String> matrizServiciosValija ()
    {
        Map<String,String> resultadoBusqueda = new Map<String,String>();

            // Buscar la parametrización del proceso.
        for (CC_Lista_Valores__c configuracionProcesoValija : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                                                                    WHERE CC_Lista__r.Name = 'VALIJA: SERVICIOS'])
        {
            resultadoBusqueda.put(configuracionProcesoValija.Name, configuracionProcesoValija.CC_Valor__c);
        }
        
        return resultadoBusqueda;
    }

    /**
     * @description Método para calcular la operación a enviar a Valija.
     * @param datosTraslado Datos del traslado a enviar a Valija.
     * @return Retorno del proceso calculado.
     */
    public static Map<String,String> calcularOperacionValija (SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador datosTraslado)
    {
        Map<String,String> retorno = new Map<String,String>();
        retorno.put('codigo','0');
        retorno.put('detalle','');

        if (datosTraslado != null)
        {
            String procesoPaqueteria = '';
            String procesoFinal = '';

            if (String.isNotBlank(datosTraslado.operacionPaqueteria))
            {
                Map<String,String> matrizPaqueteria = matrizProcesosValija();
                procesoPaqueteria = (String.isNotBlank(matrizPaqueteria.get(datosTraslado.operacionPaqueteria)))?matrizPaqueteria.get(datosTraslado.operacionPaqueteria):'';
            }

            procesoFinal = (String.isNotBlank(procesoPaqueteria))?procesoPaqueteria:datosTraslado.operacionValijaMCC;
            retorno.put('operacionValija', procesoFinal);

            if (String.isBlank(procesoFinal))
            {
                retorno.put('codigo','1');
                retorno.put('detalle','No se ha podido obtener un proceso de envío a Valija. Si el caso proviene de paquetería, revisar si aplica una conversión a un proceso de envío a Valija; o bien, revisar que se haya informado una operación Valija en la asignación por MCC');
            }
        }

        return retorno;
    }
}