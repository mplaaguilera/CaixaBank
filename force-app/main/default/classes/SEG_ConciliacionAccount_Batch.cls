/**
*   @description SEG_ConciliacionAccount_Batch
*/
public class SEG_ConciliacionAccount_Batch implements Database.Batchable<sObject> {

    /*
        @description Valor para limitar la query
    */    
    public String limitQuery;
    
    /**
    *    @description Constructor por defecto
    */
    public SEG_ConciliacionAccount_Batch() {
        limitQuery = '';
    }

    /**
    *   @description Constructor con parámetro de LIMIT
    *   @param paramLimit -> limite de la query.
    */
    public SEG_ConciliacionAccount_Batch(String paramLimit) {
        /**
         * @return SEG_ConciliacionAccount_Batch
         */
        limitQuery = paramLimit;
    }

    /**
     *  @description Recuperar los clientes propios de Segmentos.
     *  @param bc -> Objeto contexto
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        CBK_Log.debug('Start - Batch conciliación clientes',logginglevel.INFO);

        String query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, CC_Numero_Documento__c, CC_Email__c, Phone,';
        query = query + ' SEG_AreaFFEE__c, SEG_Cajetin__c, SEG_CentroSegmento__c, SEG_DominioMail__c, SEG_Empleado_gestor_Segmentos__c,';
        query = query + ' SEG_EnviarAcuse__c, SEG_Estado__c, SEG_GestorFinEstructurada__c, SEG_GestorOperativaInternacional__c,';
        query = query + ' SEG_GestorOperativaNacional__c, SEG_NotasImportantes__c, SEG_Oficina_Gestora_Segmentos__c,';
        query = query + ' SEG_OficinaDoc__c, SEG_Organizacion__c, SEG_Prioridad__c, SEG_Prioridad_Carterizacion_Segmentos__c,';
        query = query + ' SEG_TipoEmpresaFFEE__c, SEG_Zona__c, Name, AV_EAPGestor__c, AV_OficinaPrincipal__c';
        query = query + ' FROM Account';
        query = query + ' WHERE RecordType.DeveloperName = \'CC_ClienteSEG\'';
        query = query + ' AND (CC_Numero_Documento__c <> null OR CC_Numero_Documento__c <> \'\')';
        //query = query + ' AND Id = \'0015r00000JS5nyAAD\''; // MODO TEST
        query = query + ' ORDER BY CreatedDate ASC';

        if (String.isNotBlank(limitQuery))
        {
            query = query + ' LIMIT ' + limitQuery;
        }

        return Database.getQueryLocator(query);
    }

    /**
     *  @description Tratamiento de los clientes.
     *  @param bc -> Objeto contexto
     *  @param scope -> Scope del batch
     */
    public void execute(Database.BatchableContext bc, List<Account> scope)
    {
        if (scope.isEmpty()) 
        {
            // No hay registros, salir.
            return;
        }

        // Indicar el número de registros a tratar en el lote.
        CBK_Log.debug('Execute - Batch conciliación clientes. Número registros lote: ' + scope.size(),logginglevel.INFO);

        Savepoint transaccionBBDD = null;

        try {
            // Abrimos transacción BBDD.
            transaccionBBDD = Database.setSavepoint();

            // Preparar lista de documentos a buscar.
            List<String> cifEmpresasSEG = new List<String>();
            List<ID> clientesSEGId = new List<ID>();
            for (Account cuentaSEG : scope)
            {
                cifEmpresasSEG.add(cuentaSEG.CC_Numero_Documento__c);
                clientesSEGId.add(cuentaSEG.Id);
            }

            // ********************************************************
            // Preparar mapa de cuentas por CIF existentes de ALF
            // Fusionaremos con la más reciente, si existe más de un CIF de ALF.
            // ********************************************************
            Map<String,Account> mapaCuentasALF = new Map<String,Account>();
            List<ID> clientesALFId = new List<ID>();
            for (Account cuentaALF : [SELECT Id, RecordTypeId, CC_Numero_Documento__c, CC_Email__c, Phone,
                                        SEG_AreaFFEE__c, SEG_Cajetin__c, SEG_CentroSegmento__c, SEG_DominioMail__c, SEG_Empleado_gestor_Segmentos__c,
                                        SEG_EnviarAcuse__c, SEG_Estado__c, SEG_GestorFinEstructurada__c, SEG_GestorOperativaInternacional__c,
                                        SEG_GestorOperativaNacional__c, SEG_NotasImportantes__c, SEG_Oficina_Gestora_Segmentos__c,
                                        SEG_OficinaDoc__c, SEG_Organizacion__c, SEG_Prioridad__c, SEG_Prioridad_Carterizacion_Segmentos__c,
                                        SEG_TipoEmpresaFFEE__c, SEG_Zona__c, AV_EAPGestor__c, AV_OficinaPrincipal__c
                                        FROM Account
                                        WHERE RecordType.DeveloperName = 'CC_Cliente'
                                        AND CC_Numero_Documento__c IN :cifEmpresasSEG
                                        //AND CC_NumPerso__c <> null --> Nos guiamos por el AV_NumPerso__c finalmente.
                                        AND AV_NumPerso__c <> null
                                        AND Id NOT IN :clientesSEGId
                                        ORDER BY CreatedDate DESC])
            {
                mapaCuentasALF.put(cuentaALF.CC_Numero_Documento__c, cuentaALF);
                clientesALFId.add(cuentaALF.Id);
            }

            // MODO TEST.
            /*for (Account cuentaALF : [SELECT Id, RecordTypeId, CC_Numero_Documento__c, CC_Email__c, Phone,
                                        SEG_AreaFFEE__c, SEG_Cajetin__c, SEG_CentroSegmento__c, SEG_DominioMail__c, SEG_Empleado_gestor_Segmentos__c,
                                        SEG_EnviarAcuse__c, SEG_Estado__c, SEG_GestorFinEstructurada__c, SEG_GestorOperativaInternacional__c,
                                        SEG_GestorOperativaNacional__c, SEG_NotasImportantes__c, SEG_Oficina_Gestora_Segmentos__c,
                                        SEG_OficinaDoc__c, SEG_Organizacion__c, SEG_Prioridad__c, SEG_Prioridad_Carterizacion_Segmentos__c,
                                        SEG_TipoEmpresaFFEE__c, SEG_Zona__c
                                        FROM Account
                                        WHERE RecordType.DeveloperName = 'CC_ClienteSEG'
                                        AND CC_Numero_Documento__c IN :cifEmpresasSEG
                                        AND Id NOT IN :clientesSEGId
                                        ORDER BY CreatedDate DESC])
            {
                mapaCuentasALF.put(cuentaALF.CC_Numero_Documento__c, cuentaALF);
                clientesALFId.add(cuentaALF.Id);
            }*/
            cifEmpresasSEG.clear();

            // ********************************************************
            // Buscar las relaciones de cuentas y contactos.
            // ********************************************************
            Map<ID,List<AccountContactRelation>> mapRelacionContactos = new Map<ID,List<AccountContactRelation>>();
            for (AccountContactRelation contactoRelSEG : [SELECT Id, AccountId, ContactId
                                        FROM AccountContactRelation
                                        WHERE AccountId IN :clientesSEGId])
            {
                List<AccountContactRelation> listaContactos;
                if (mapRelacionContactos.get(contactoRelSEG.AccountId) != null)
                {
                    listaContactos = mapRelacionContactos.get(contactoRelSEG.AccountId);
                }else{
                    listaContactos = new List<AccountContactRelation>();
                }

                listaContactos.add(contactoRelSEG);
                mapRelacionContactos.put(contactoRelSEG.AccountId, listaContactos);
            }

            // ********************************************************
            // Buscar las relaciones de cuentas y contactos del cliente ALF.
            // Evitar el fallo de inserción y controlar el flujo del Batch.
            // ********************************************************
            Map<String,String> mapRelacionContactosALF = new Map<String,String>();
            for (AccountContactRelation contactoRelALF : [SELECT Id, AccountId, ContactId
                                        FROM AccountContactRelation
                                        WHERE AccountId IN :clientesALFId])
            {
                String sClaveRelacion = contactoRelALF.AccountId + '_' + contactoRelALF.ContactId;
                mapRelacionContactosALF.put(sClaveRelacion,'Y');
            }

            // ********************************************************
            // Buscar los contactos principales
            // ********************************************************
            Map<ID,List<Contact>> mapContactosSEG = new Map<ID,List<Contact>>();
            for (Contact contactoSEG : [SELECT Id, AccountId
                                        FROM Contact
                                        WHERE AccountId IN :clientesSEGId])
            {
                List<Contact> listaContactos;
                if (mapContactosSEG.get(contactoSEG.AccountId) != null)
                {
                    listaContactos = mapContactosSEG.get(contactoSEG.AccountId);
                }else{
                    listaContactos = new List<Contact>();
                }

                listaContactos.add(contactoSEG);
                mapContactosSEG.put(contactoSEG.AccountId, listaContactos);
            }

            // ********************************************************
            // Recuperar las notas y ficheros relacionados con la cuenta
            // ********************************************************
            Map<ID,List<ContentDocumentLink>> mapContentDocumentSEG = new Map<ID,List<ContentDocumentLink>>();
            for (ContentDocumentLink documentosSEG : [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility
                                                        FROM ContentDocumentLink
                                                        WHERE LinkedEntityId IN :clientesSEGId])
            {
                List<ContentDocumentLink> listaDocuments;
                if (mapContentDocumentSEG.get(documentosSEG.LinkedEntityId) != null)
                {
                    listaDocuments = mapContentDocumentSEG.get(documentosSEG.LinkedEntityId);
                }else{
                    listaDocuments = new List<ContentDocumentLink>();
                }

                listaDocuments.add(documentosSEG);
                mapContentDocumentSEG.put(documentosSEG.LinkedEntityId, listaDocuments);
            }

            // ********************************************************
            // Recuperar marcas relacionadas con la cuenta
            // ********************************************************
            Map<ID,List<SEG_Marca_de_un_cliente__c>> mapMarcasSEG = new Map<ID,List<SEG_Marca_de_un_cliente__c>>();
            for (SEG_Marca_de_un_cliente__c marcaSEG : [SELECT Id, SEG_Cliente__c, SEG_Caracteristica__c
                                                        FROM SEG_Marca_de_un_cliente__c
                                                        WHERE SEG_Cliente__c IN :clientesSEGId])
            {
                List<SEG_Marca_de_un_cliente__c> listaMarcas;
                if (mapMarcasSEG.get(marcaSEG.SEG_Cliente__c) != null)
                {
                    listaMarcas = mapMarcasSEG.get(marcaSEG.SEG_Cliente__c);
                }else{
                    listaMarcas = new List<SEG_Marca_de_un_cliente__c>();
                }

                listaMarcas.add(marcaSEG);
                mapMarcasSEG.put(marcaSEG.SEG_Cliente__c, listaMarcas);
            }

            // ********************************************************
            // Recuperar las marcas existentes de la cuenta, para no duplicar en ALF.
            // ********************************************************
            Map<ID,List<ID>> mapMarcasALF = new Map<ID,List<ID>>();
            for (SEG_Marca_de_un_cliente__c marcaALF : [SELECT Id, SEG_Cliente__c, SEG_Caracteristica__c
                                                        FROM SEG_Marca_de_un_cliente__c
                                                        WHERE SEG_Cliente__c IN :clientesALFId])
            {
                List<ID> listaMarcas;
                if (mapMarcasALF.get(marcaALF.SEG_Cliente__c) != null)
                {
                    listaMarcas = mapMarcasALF.get(marcaALF.SEG_Cliente__c);
                }else{
                    listaMarcas = new List<ID>();
                }

                listaMarcas.add(marcaALF.SEG_Caracteristica__c);
                mapMarcasALF.put(marcaALF.SEG_Cliente__c, listaMarcas);
            }

            // ********************************************************
            // Recuperar casos relacionadas con la cuenta
            // ********************************************************
            Map<ID,List<Case>> mapCasosSEG = new Map<ID,List<Case>>();
            for (Case casoSEG : [SELECT Id, AccountId
                                FROM Case
                                WHERE AccountId IN :clientesSEGId])
            {
                List<Case> listaCasos;
                if (mapCasosSEG.get(casoSEG.AccountId) != null)
                {
                    listaCasos = mapCasosSEG.get(casoSEG.AccountId);
                }else{
                    listaCasos = new List<Case>();
                }

                listaCasos.add(casoSEG);
                mapCasosSEG.put(casoSEG.AccountId, listaCasos);
            }

            // ********************************************************
            // Recuperar los post de chattter relacionadas con la cuenta
            // ********************************************************
            Map<ID,List<FeedItem>> mapFeedsSEG = new Map<ID,List<FeedItem>>();
            for (FeedItem feedSEG : [SELECT Id, ParentId, Type, Revision, CommentCount, LikeCount, Title, Body, LinkUrl, IsRichText, 
                                    RelatedRecordId, InsertedById, NetworkScope, Visibility, BestCommentId, HasContent, HasLink, 
                                    HasFeedEntity, HasVerifiedComment, IsClosed, Status
                                    FROM FeedItem
                                    WHERE ParentId IN :clientesSEGId])
            {
                List<FeedItem> listaFeeds;
                if (mapFeedsSEG.get(feedSEG.ParentId) != null)
                {
                    listaFeeds = mapFeedsSEG.get(feedSEG.ParentId);
                }else{
                    listaFeeds = new List<FeedItem>();
                }

                listaFeeds.add(feedSEG);
                mapFeedsSEG.put(feedSEG.ParentId, listaFeeds);
            }

            /**
             * SEG_Excepciones_Empresa__c - excepciones
             * SEG_Excepciones_Grupo_Empresa__c
SEG_ExcepcionesEmpresa__c - plantillas
             */

            // ********************************************************
            // Recuperar contratos relacionadas con la cuenta
            // ********************************************************
            Map<ID,List<SEG_Contratos__c>> mapContratosSEG = new Map<ID,List<SEG_Contratos__c>>();
            for (SEG_Contratos__c contratoSEG : [SELECT Id, SEG_NombreCuenta__c
                                FROM SEG_Contratos__c
                                WHERE SEG_NombreCuenta__c IN :clientesSEGId])
            {
                List<SEG_Contratos__c> listaContratos;
                if (mapContratosSEG.get(contratoSEG.SEG_NombreCuenta__c) != null)
                {
                    listaContratos = mapContratosSEG.get(contratoSEG.SEG_NombreCuenta__c);
                }else{
                    listaContratos = new List<SEG_Contratos__c>();
                }

                listaContratos.add(contratoSEG);
                mapContratosSEG.put(contratoSEG.SEG_NombreCuenta__c, listaContratos);
            }

            // ********************************************************
            // Recuperar excepciones relacionadas con la cuenta
            // ********************************************************
            Map<ID,List<SEG_Excepciones_Empresa__c>> mapExcepcionesSEG = new Map<ID,List<SEG_Excepciones_Empresa__c>>();
            for (SEG_Excepciones_Empresa__c excepcionSEG : [SELECT Id, Empresa__c
                                FROM SEG_Excepciones_Empresa__c
                                WHERE Empresa__c IN :clientesSEGId])
            {
                List<SEG_Excepciones_Empresa__c> listaExcepciones;
                if (mapExcepcionesSEG.get(excepcionSEG.Empresa__c) != null)
                {
                    listaExcepciones = mapExcepcionesSEG.get(excepcionSEG.Empresa__c);
                }else{
                    listaExcepciones = new List<SEG_Excepciones_Empresa__c>();
                }

                listaExcepciones.add(excepcionSEG);
                mapExcepcionesSEG.put(excepcionSEG.Empresa__c, listaExcepciones);
            }

            // ********************************************************
            // Recuperar excepciones relacionadas con la cuenta grupo
            // ********************************************************
            Map<ID,List<SEG_Excepciones_Grupo_Empresa__c>> mapExcepcionesGrupoSEG = new Map<ID,List<SEG_Excepciones_Grupo_Empresa__c>>();
            for (SEG_Excepciones_Grupo_Empresa__c excepcionGrupoSEG : [SELECT Id, SEG_GrupoEmpresa__c
                                FROM SEG_Excepciones_Grupo_Empresa__c
                                WHERE SEG_GrupoEmpresa__c IN :clientesSEGId])
            {
                List<SEG_Excepciones_Grupo_Empresa__c> listaExcepciones;
                if (mapExcepcionesGrupoSEG.get(excepcionGrupoSEG.SEG_GrupoEmpresa__c) != null)
                {
                    listaExcepciones = mapExcepcionesGrupoSEG.get(excepcionGrupoSEG.SEG_GrupoEmpresa__c);
                }else{
                    listaExcepciones = new List<SEG_Excepciones_Grupo_Empresa__c>();
                }

                listaExcepciones.add(excepcionGrupoSEG);
                mapExcepcionesGrupoSEG.put(excepcionGrupoSEG.SEG_GrupoEmpresa__c, listaExcepciones);
            }

            // ********************************************************
            // Recuperar plantillas relacionadas con la cuenta
            // ********************************************************
            Map<ID,List<SEG_ExcepcionesEmpresa__c>> mapPlantillasSEG = new Map<ID,List<SEG_ExcepcionesEmpresa__c>>();
            for (SEG_ExcepcionesEmpresa__c plantillaSEG : [SELECT Id, SEG_Empresa__c
                                FROM SEG_ExcepcionesEmpresa__c
                                WHERE SEG_Empresa__c IN :clientesSEGId])
            {
                List<SEG_ExcepcionesEmpresa__c> listaPlantillas;
                if (mapPlantillasSEG.get(plantillaSEG.SEG_Empresa__c) != null)
                {
                    listaPlantillas = mapPlantillasSEG.get(plantillaSEG.SEG_Empresa__c);
                }else{
                    listaPlantillas = new List<SEG_ExcepcionesEmpresa__c>();
                }

                listaPlantillas.add(plantillaSEG);
                mapPlantillasSEG.put(plantillaSEG.SEG_Empresa__c, listaPlantillas);
            }

            // ********************************************************
            // Recuperar plantillas relacionadas con la cuenta de grupo
            // ********************************************************
            Map<ID,List<SEG_ExcepcionesGrupoEmpresa__c>> mapPlantillasGrupoSEG = new Map<ID,List<SEG_ExcepcionesGrupoEmpresa__c>>();
            for (SEG_ExcepcionesGrupoEmpresa__c plantillaSEG : [SELECT Id, SEG_GrupoEmpresa__c
                                FROM SEG_ExcepcionesGrupoEmpresa__c
                                WHERE SEG_GrupoEmpresa__c IN :clientesSEGId])
            {
                List<SEG_ExcepcionesGrupoEmpresa__c> listaPlantillas;
                if (mapPlantillasGrupoSEG.get(plantillaSEG.SEG_GrupoEmpresa__c) != null)
                {
                    listaPlantillas = mapPlantillasGrupoSEG.get(plantillaSEG.SEG_GrupoEmpresa__c);
                }else{
                    listaPlantillas = new List<SEG_ExcepcionesGrupoEmpresa__c>();
                }

                listaPlantillas.add(plantillaSEG);
                mapPlantillasGrupoSEG.put(plantillaSEG.SEG_GrupoEmpresa__c, listaPlantillas);
            }

            // ********************************************************
            // Recuperar canales de comunicación de la cuenta
            // ********************************************************
            Map<ID,List<CC_Canal_Com__c>> mapCanalesSEG = new Map<ID,List<CC_Canal_Com__c>>();
            for (CC_Canal_Com__c canalSEG : [SELECT Id, CC_CuentaId__c
                                            FROM CC_Canal_Com__c
                                            WHERE CC_CuentaId__c IN :clientesSEGId])
            {
                List<CC_Canal_Com__c> listaCanales;
                if (mapCanalesSEG.get(canalSEG.CC_CuentaId__c) != null)
                {
                    listaCanales = mapCanalesSEG.get(canalSEG.CC_CuentaId__c);
                }else{
                    listaCanales = new List<CC_Canal_Com__c>();
                }

                listaCanales.add(canalSEG);
                mapCanalesSEG.put(canalSEG.CC_CuentaId__c, listaCanales);
            }

            // Por cada cuenta SEG creada manualmente, buscar si existe una cuenta de ALF para hacer la fusión.
            List<AccountContactRelation> nuevaRelacionContacto = new List<AccountContactRelation>();
            List<Contact> nuevoParentContact = new List<Contact>();
            List<AccountContactRelation> borrarRelacionContacto = new List<AccountContactRelation>();
            List<ContentDocumentLink> nuevaRelacionDocumento = new List<ContentDocumentLink>();
            List<ContentDocumentLink> borrarRelacionDocumento = new List<ContentDocumentLink>();
            List<SEG_Marca_de_un_cliente__c> nuevaRelacionMarca = new List<SEG_Marca_de_un_cliente__c>();
            List<SEG_Marca_de_un_cliente__c> borrarRelacionMarca = new List<SEG_Marca_de_un_cliente__c>();
            List<Case> nuevaAccountCase = new List<Case>();
            List<FeedItem> nuevaRelacionFeed = new List<FeedItem>();
            List<FeedItem> borrarRelacionFeed = new List<FeedItem>();
            Map<Id,Account> actualizarCuentaALF = new Map<Id,Account>();
            Map<Id,Account> borrarCuentaSEG = new Map<Id,Account>();
            Map<ID,ContentNote> notasPorCliente = new Map<ID,ContentNote>();
            List<SEG_Contratos__c> nuevaAccountContrato = new List<SEG_Contratos__c>();
            List<SEG_Excepciones_Empresa__c> nuevaAccountExcepcion = new List<SEG_Excepciones_Empresa__c>();
            List<SEG_Excepciones_Grupo_Empresa__c> nuevaAccountGrupoExcepcion = new List<SEG_Excepciones_Grupo_Empresa__c>();
            List<SEG_ExcepcionesEmpresa__c> nuevaAccountPlantilla = new List<SEG_ExcepcionesEmpresa__c>();
            List<SEG_ExcepcionesGrupoEmpresa__c> nuevaAccountGrupoPlantilla = new List<SEG_ExcepcionesGrupoEmpresa__c>();
            List<CC_Canal_Com__c> nuevaAccountCanal = new List<CC_Canal_Com__c>();

            for (Account cuentaSEG : scope)
            {
                if (mapaCuentasALF.get(cuentaSEG.CC_Numero_Documento__c) != null)
                {
                    Account cuentaALF = mapaCuentasALF.get(cuentaSEG.CC_Numero_Documento__c);

                    // ********************************************************
                    // Crear las relaciones de contactos con la cuenta de ALF.
                    // ********************************************************
                    List<AccountContactRelation> listaRelaciones = mapRelacionContactos.get(cuentaSEG.Id);
                    if (listaRelaciones !=  null)
                    {
                        for (AccountContactRelation contactoRelSEG : listaRelaciones)
                        {
                            String sClaveRel = cuentaALF.Id + '_' + contactoRelSEG.ContactId;
                            if (mapRelacionContactosALF.get(sClaveRel) == null)
                            {
                                AccountContactRelation relacionClon = contactoRelSEG.clone(false,true,false,false);
                                relacionClon.AccountId = cuentaALF.Id;
                                relacionClon.ContactId = contactoRelSEG.ContactId;
                                nuevaRelacionContacto.add(relacionClon);

                                borrarRelacionContacto.add(contactoRelSEG);
                            }
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta principal del contacto.
                    // ********************************************************
                    List<Contact> listaContactos = mapContactosSEG.get(cuentaSEG.Id);
                    if (listaContactos != null)
                    {
                        for (Contact contactoRelSEG : listaContactos)
                        {
                            contactoRelSEG.AccountId = cuentaALF.Id;
                            nuevoParentContact.add(contactoRelSEG);
                        }
                    }

                    // ********************************************************
                    // Crear las nuevas vinculaciones con ficheros y notas con la cuenta ALF.
                    // ********************************************************
                    List<ContentDocumentLink> listaDocumentos = mapContentDocumentSEG.get(cuentaSEG.Id);
                    if (listaDocumentos !=  null)
                    {
                        for (ContentDocumentLink documentoSEG : listaDocumentos)
                        {
                            ContentDocumentLink relacionClon = documentoSEG.clone(false,true,false,false);
                            relacionClon.LinkedEntityId = cuentaALF.Id;
                            nuevaRelacionDocumento.add(relacionClon);

                            borrarRelacionDocumento.add(documentoSEG);
                        }
                    }

                    // ********************************************************
                    // Crear las nuevas vinculaciones con marcas con la cuenta ALF.
                    // ********************************************************
                    List<SEG_Marca_de_un_cliente__c> listaMarcas = mapMarcasSEG.get(cuentaSEG.Id);
                    List<ID> listaMarcasALF = mapMarcasALF.get(cuentaALF.Id);
                    if (listaMarcas !=  null)
                    {
                        for (SEG_Marca_de_un_cliente__c marcaSEG : listaMarcas)
                        {
                            if (listaMarcasALF == null || !listaMarcasALF.contains(marcaSEG.SEG_Caracteristica__c))
                            {
                                // Si la marca a incorporar no la tiene, crearla.
                                SEG_Marca_de_un_cliente__c relacionClon = marcaSEG.clone(false,true,false,false);
                                relacionClon.SEG_Cliente__c = cuentaALF.Id;
                                nuevaRelacionMarca.add(relacionClon);
                            }

                            borrarRelacionMarca.add(marcaSEG);
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta principal del caso.
                    // ********************************************************
                    List<Case> listaCasos = mapCasosSEG.get(cuentaSEG.Id);
                    if (listaCasos != null)
                    {
                        for (Case casoSEG : listaCasos)
                        {
                            casoSEG.AccountId = cuentaALF.Id;
                            nuevaAccountCase.add(casoSEG);
                        }
                    }

                    // ********************************************************
                    // Crear las nuevas vinculaciones con Feeds de Chatter con la cuenta ALF.
                    // ********************************************************
                    List<FeedItem> listaFeeds = mapFeedsSEG.get(cuentaSEG.Id);
                    if (listaFeeds !=  null)
                    {
                        for (FeedItem feedSEG : listaFeeds)
                        {
                            FeedItem relacionClon = feedSEG.clone(false,true,false,false);
                            relacionClon.ParentId = cuentaALF.Id;
                            nuevaRelacionFeed.add(relacionClon);

                            borrarRelacionFeed.add(feedSEG);
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta principal del contrato.
                    // ********************************************************
                    List<SEG_Contratos__c> listaContratos = mapContratosSEG.get(cuentaSEG.Id);
                    if (listaContratos != null)
                    {
                        for (SEG_Contratos__c contratoSEG : listaContratos)
                        {
                            contratoSEG.SEG_NombreCuenta__c = cuentaALF.Id;
                            nuevaAccountContrato.add(contratoSEG);
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta de la excepción.
                    // ********************************************************
                    List<SEG_Excepciones_Empresa__c> listaExcepciones = mapExcepcionesSEG.get(cuentaSEG.Id);
                    if (listaExcepciones != null)
                    {
                        for (SEG_Excepciones_Empresa__c excepcionSEG : listaExcepciones)
                        {
                            excepcionSEG.Empresa__c = cuentaALF.Id;
                            nuevaAccountExcepcion.add(excepcionSEG);
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta grupo de la excepción.
                    // ********************************************************
                    List<SEG_Excepciones_Grupo_Empresa__c> listaGrupoExcepciones = mapExcepcionesGrupoSEG.get(cuentaSEG.Id);
                    if (listaGrupoExcepciones != null)
                    {
                        for (SEG_Excepciones_Grupo_Empresa__c excepcionGrupoSEG : listaGrupoExcepciones)
                        {
                            excepcionGrupoSEG.SEG_GrupoEmpresa__c = cuentaALF.Id;
                            nuevaAccountGrupoExcepcion.add(excepcionGrupoSEG);
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta de la plantilla.
                    // ********************************************************
                    List<SEG_ExcepcionesEmpresa__c> listaPlantillas = mapPlantillasSEG.get(cuentaSEG.Id);
                    if (listaPlantillas != null)
                    {
                        for (SEG_ExcepcionesEmpresa__c plantillaSEG : listaPlantillas)
                        {
                            plantillaSEG.SEG_Empresa__c = cuentaALF.Id;
                            nuevaAccountPlantilla.add(plantillaSEG);
                        }
                    }

                    // ********************************************************
                    // Modificar la relación de la cuenta grupo de la plantilla.
                    // ********************************************************
                    List<SEG_ExcepcionesGrupoEmpresa__c> listaGrupoPlantillas = mapPlantillasGrupoSEG.get(cuentaSEG.Id);
                    if (listaGrupoPlantillas != null)
                    {
                        for (SEG_ExcepcionesGrupoEmpresa__c plantillaSEG : listaGrupoPlantillas)
                        {
                            plantillaSEG.SEG_GrupoEmpresa__c = cuentaALF.Id;
                            nuevaAccountGrupoPlantilla.add(plantillaSEG);
                        }
                    }
                    
                    // ********************************************************
                    // Modificar la relación de la cuenta principal del canal de comunicación.
                    // ********************************************************
                    List<CC_Canal_Com__c> listaCanales = mapCanalesSEG.get(cuentaSEG.Id);
                    if (listaCanales != null)
                    {
                        for (CC_Canal_Com__c canalSEG : listaCanales)
                        {
                            canalSEG.CC_CuentaId__c = cuentaALF.Id;
                            nuevaAccountCanal.add(canalSEG);
                        }
                    }

                    // ********************************************************
                    // Volcar la información de Segmentos al cliente de ALF.
                    // ********************************************************

                    //cuentaALF.CC_Email__c = cuentaSEG.CC_Email__c; --> Fix. No actualizamos este dato en online (partimos de la carga batch).
                    cuentaALF.SEG_Telefono_Segmentos__c = cuentaSEG.Phone;
                    cuentaALF.SEG_AreaFFEE__c = cuentaSEG.SEG_AreaFFEE__c;
                    cuentaALF.SEG_TipoEmpresaFFEE__c = cuentaSEG.SEG_TipoEmpresaFFEE__c;
                    cuentaALF.SEG_Organizacion__c = cuentaSEG.SEG_Organizacion__c;
                    cuentaALF.SEG_Zona__c = cuentaSEG.SEG_Zona__c;
                    cuentaALF.SEG_Cajetin__c = cuentaSEG.SEG_Cajetin__c;
                    cuentaALF.SEG_CentroSegmento__c = cuentaSEG.SEG_CentroSegmento__c;
                    cuentaALF.SEG_OficinaDoc__c = cuentaSEG.SEG_OficinaDoc__c;
                    cuentaALF.SEG_EnviarAcuse__c = cuentaSEG.SEG_EnviarAcuse__c;
                    cuentaALF.SEG_Prioridad__c = cuentaSEG.SEG_Prioridad__c;
                    cuentaALF.SEG_NotasImportantes__c = cuentaSEG.SEG_NotasImportantes__c;
                    cuentaALF.SEG_Estado__c = cuentaSEG.SEG_Estado__c;
                    cuentaALF.SEG_GestorOperativaNacional__c = cuentaSEG.SEG_GestorOperativaNacional__c;
                    cuentaALF.SEG_GestorOperativaInternacional__c = cuentaSEG.SEG_GestorOperativaInternacional__c;
                    cuentaALF.SEG_GestorFinEstructurada__c = cuentaSEG.SEG_GestorFinEstructurada__c;

                    // Cambio gestión campos Segmentos para Oficina y Empleado gestor.
                    //cuentaALF.SEG_Prioridad_Carterizacion_Segmentos__c = (String.isNotBlank(cuentaSEG.SEG_Oficina_Gestora_Segmentos__c))?true:false;//true; //cuentaSEG.SEG_Prioridad_Carterizacion_Segmentos__c;
                    //cuentaALF.SEG_Oficina_Gestora_Segmentos__c = cuentaSEG.SEG_Oficina_Gestora_Segmentos__c;
                    //cuentaALF.SEG_Empleado_gestor_Segmentos__c = cuentaSEG.SEG_Empleado_gestor_Segmentos__c;

                    //cuentaALF.SEG_Prioridad_Carterizacion_Segmentos__c = (String.isNotBlank(cuentaSEG.AV_OficinaPrincipal__c))?true:false;
                    //cuentaALF.SEG_Oficina_Gestora_Segmentos__c = (cuentaSEG.AV_OficinaPrincipal__c != null) ? cuentaSEG.AV_OficinaPrincipal__c : cuentaSEG.SEG_Oficina_Gestora_Segmentos__c;
                    //cuentaALF.SEG_Empleado_gestor_Segmentos__c = (cuentaSEG.AV_EAPGestor__c != null) ? cuentaSEG.AV_EAPGestor__c : cuentaSEG.SEG_Empleado_gestor_Segmentos__c;

                    Boolean priorizacionSegmentos = (cuentaSEG.SEG_Prioridad_Carterizacion_Segmentos__c != null) ? cuentaSEG.SEG_Prioridad_Carterizacion_Segmentos__c : false;
                    String oficinaGestoraAux = (priorizacionSegmentos == true) ? cuentaSEG.SEG_Oficina_Gestora_Segmentos__c : cuentaALF.AV_OficinaPrincipal__c;
                    String empleadoGestorAux = (priorizacionSegmentos == true) ? cuentaSEG.SEG_Empleado_gestor_Segmentos__c : cuentaALF.AV_EAPGestor__c;

                    cuentaALF.SEG_Prioridad_Carterizacion_Segmentos__c = priorizacionSegmentos;
                    cuentaALF.SEG_Oficina_Gestora_Segmentos__c = oficinaGestoraAux;
                    cuentaALF.SEG_Empleado_gestor_Segmentos__c = empleadoGestorAux;

                    String dominioMail = cuentaALF.SEG_DominioMail__c;
                    if (String.isNotBlank(dominioMail))
                    {
                        if (String.isNotBlank(cuentaSEG.SEG_DominioMail__c))
                        {
                            dominioMail = dominioMail + ';' + cuentaSEG.SEG_DominioMail__c;
                        }
                    }else{
                        dominioMail = cuentaSEG.SEG_DominioMail__c;
                    }
                    cuentaALF.SEG_DominioMail__c = dominioMail;


                    if (!actualizarCuentaALF.containsKey(cuentaALF.Id)) {
                        actualizarCuentaALF.put(cuentaALF.Id, cuentaALF);
                    }


                    if (!borrarCuentaSEG.containsKey(cuentaSEG.Id)) {
                        borrarCuentaSEG.put(cuentaSEG.Id, cuentaSEG);
                    }

                    // ********************************************************
                    // Crear una nota para la cuenta de ALF, indicando la fusión.
                    // ********************************************************
                    String tituloNota = 'Cuenta fusionada';
                    String contenido = 'La cuenta con ID <' + cuentaSEG.Id + '>, con NIF <' + cuentaSEG.CC_Numero_Documento__c;
                    contenido = contenido + '> y nombre <' + cuentaSEG.Name + '> se ha fusionado con la cuenta actual de Alfabético.';
                    Blob blobNota = Blob.valueof(contenido.escapeHtml4());
                    notasPorCliente.put(cuentaALF.Id, new ContentNote(Title = tituloNota, Content = blobNota));
                }
            }

            // ********************************************************
            // Variable de control de errores con framework logger.
            // ********************************************************
            Boolean bError = false;

            // ********************************************************
            // Insertar las nuevas relaciones de los clientes.         
            // ******************************************************** 
            //insert nuevaRelacionContacto;
            Database.SaveResult[] resultadoInsercion = Database.insert(nuevaRelacionContacto, false);
            for (Integer i = 0; i < resultadoInsercion.size(); i++)
            {
                if (!resultadoInsercion[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoInsercion[i].getErrors(), nuevaRelacionContacto[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al crear registros en AccountContactRelation');
            }

            // ********************************************************
            // Actualizar el Parent Account de los contactos.
            // ********************************************************
            //update nuevoParentContact;
            Database.SaveResult[] resultadoUpdate = Database.update(nuevoParentContact, false);
            for (Integer i = 0; i < resultadoUpdate.size(); i++)
            {
                if (!resultadoUpdate[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate[i].getErrors(), nuevoParentContact[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Contact');
            }

            // ********************************************************
            // Borrar relaciones de contactos con la cuenta de SEG.
            // ********************************************************
            //delete borrarRelacionContacto;
            Database.DeleteResult[] resultadoDelete = Database.delete(borrarRelacionContacto, false);
            for (Integer i = 0; i < resultadoDelete.size(); i++)
            {
                if (!resultadoDelete[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoDelete[i].getErrors(), borrarRelacionContacto[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al borrar registros en AccountContactRelation');
            }

            // ********************************************************
            // Crear las vinculaciones con Notas y Files.
            // ********************************************************
            //insert nuevaRelacionDocumento;
            Database.SaveResult[] resultadoInsercion2 = Database.insert(nuevaRelacionDocumento, false);
            for (Integer i = 0; i < resultadoInsercion2.size(); i++)
            {
                if (!resultadoInsercion2[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoInsercion2[i].getErrors(), nuevaRelacionDocumento[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al crear registros en ContentDocumentLink');
            }

            // ********************************************************
            // Borrar las vinculaciones con Notas y Files de la cuenta SEG.
            // ********************************************************
            //delete borrarRelacionDocumento;
            Database.DeleteResult[] resultadoDelete2 = Database.delete(borrarRelacionDocumento, false);
            for (Integer i = 0; i < resultadoDelete2.size(); i++)
            {
                if (!resultadoDelete2[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoDelete2[i].getErrors(), borrarRelacionDocumento[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al borrar registros en ContentDocumentLink');
            }

            // ********************************************************
            // Crear las marcas asociadas.
            // ********************************************************
            //insert nuevaRelacionMarca;
            Database.SaveResult[] resultadoInsercion3 = Database.insert(nuevaRelacionMarca, false);
            for (Integer i = 0; i < resultadoInsercion3.size(); i++)
            {
                if (!resultadoInsercion3[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoInsercion3[i].getErrors(), nuevaRelacionMarca[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al crear registros en SEG_Marca_de_un_cliente__c');
            }

            // ********************************************************
            // Borrar las marcas asociadas a la cuenta SEG.
            // ********************************************************
            //delete borrarRelacionMarca;
            Database.DeleteResult[] resultadoDelete3 = Database.delete(borrarRelacionMarca, false);
            for (Integer i = 0; i < resultadoDelete3.size(); i++)
            {
                if (!resultadoDelete3[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoDelete3[i].getErrors(), borrarRelacionMarca[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al borrar registros en SEG_Marca_de_un_cliente__c');
            }

            // ********************************************************
            // Actualizar los AccountId de los casos.
            // ********************************************************
            //update nuevaAccountCase;
            Database.SaveResult[] resultadoUpdate2 = Database.update(nuevaAccountCase, false);
            for (Integer i = 0; i < resultadoUpdate2.size(); i++)
            {
                if (!resultadoUpdate2[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate2[i].getErrors(), nuevaAccountCase[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Case');
            }

            // ********************************************************
            // Actualizar los AccountId de los contratos.
            // ********************************************************
            Database.SaveResult[] resultadoUpdate4 = Database.update(nuevaAccountContrato, false);
            for (Integer i = 0; i < resultadoUpdate4.size(); i++)
            {
                if (!resultadoUpdate4[i].isSuccess() && !Test.isRunningTest())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate4[i].getErrors(), nuevaAccountContrato[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Contratos');
            }

            // ********************************************************
            // Actualizar los AccountId de las excepciones.
            // ********************************************************
            Database.SaveResult[] resultadoUpdate5 = Database.update(nuevaAccountExcepcion, false);
            for (Integer i = 0; i < resultadoUpdate5.size(); i++)
            {
                if (!resultadoUpdate5[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate5[i].getErrors(), nuevaAccountExcepcion[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Excepciones');
            }

            // ********************************************************
            // Actualizar los AccountId de las excepciones de Grupo.
            // ********************************************************
            Database.SaveResult[] resultadoUpdate6 = Database.update(nuevaAccountGrupoExcepcion, false);
            for (Integer i = 0; i < resultadoUpdate6.size(); i++)
            {
                if (!resultadoUpdate6[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate6[i].getErrors(), nuevaAccountGrupoExcepcion[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Excepciones de Grupo');
            }

            // ********************************************************
            // Actualizar los AccountId de las plantillas.
            // ********************************************************
            Database.SaveResult[] resultadoUpdate7 = Database.update(nuevaAccountPlantilla, false);
            for (Integer i = 0; i < resultadoUpdate7.size(); i++)
            {
                if (!resultadoUpdate7[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate7[i].getErrors(), nuevaAccountPlantilla[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Plantillas');
            }

            // ********************************************************
            // Actualizar los AccountId de las plantillas de grupo
            // ********************************************************
            Database.SaveResult[] resultadoUpdate8 = Database.update(nuevaAccountGrupoPlantilla, false);
            for (Integer i = 0; i < resultadoUpdate8.size(); i++)
            {
                if (!resultadoUpdate8[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate8[i].getErrors(), nuevaAccountGrupoPlantilla[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Plantillas de Grupo');
            }      
            
            // ********************************************************
            // Actualizar los AccountId de los canales de comunicación
            // ********************************************************
            Database.SaveResult[] resultadoUpdate9 = Database.update(nuevaAccountCanal, false);
            for (Integer i = 0; i < resultadoUpdate9.size(); i++)
            {
                if (!resultadoUpdate9[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoUpdate9[i].getErrors(), nuevaAccountCanal[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Canales de Comunicación');
            }

            // ********************************************************
            // Migrar los feedItem del chatter a la cuenta ALF.
            // ********************************************************
            //insert nuevaRelacionFeed;
            Database.SaveResult[] resultadoInsercion4 = Database.insert(nuevaRelacionFeed, false);
            for (Integer i = 0; i < resultadoInsercion4.size(); i++)
            {
                if (!resultadoInsercion4[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoInsercion4[i].getErrors(), nuevaRelacionFeed[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al crear registros en FeedItem');
            }

            // ********************************************************
            // Borrar feedItem de la cuenta de SEG.
            // ********************************************************
            //delete borrarRelacionFeed;
            Database.DeleteResult[] resultadoDelete4 = Database.delete(borrarRelacionFeed, false);
            for (Integer i = 0; i < resultadoDelete4.size(); i++)
            {
                if (!resultadoDelete4[i].isSuccess())
                {
                    bError = true;
                    SEG_MetodosComunes.registrarErrorDML (resultadoDelete4[i].getErrors(), borrarRelacionFeed[i]);
                }
            }
            if (bError)
            {
                throw new DMLException('SEG_ConciliacionAccount_Batch : Error al borrar registros en FeedItem');
            }

            // ********************************************************
            // Sincronizar la ficha del cliente.
            // ********************************************************
            //update actualizarCuentaALF;
            List<Account> lstCuentasALFUpdate = new List<Account>();

            if (actualizarCuentaALF != null && !actualizarCuentaALF.isEmpty()) {
                lstCuentasALFUpdate.addAll(actualizarCuentaALF.values());
            }

            if (!lstCuentasALFUpdate.isEmpty()) {
                Database.SaveResult[] resultadoUpdate3 = Database.update(lstCuentasALFUpdate, false);
                for (Integer i = 0; i < resultadoUpdate3.size(); i++)
                {
                    if (!resultadoUpdate3[i].isSuccess())
                    {
                        bError = true;
                        SEG_MetodosComunes.registrarErrorDML (resultadoUpdate3[i].getErrors(), lstCuentasALFUpdate[i]);
                    }
                }
                if (bError)
                {
                    throw new DMLException('SEG_ConciliacionAccount_Batch : Error al actualizar registros en Account');
                }
            }

            // ********************************************************
            // Borrar la cuenta de Segmentos.
            // ********************************************************
            //delete borrarCuentaSEG;

            List<Account> lstCuentasBorrarSEG = new List<Account>();

            if (borrarCuentaSEG != null && !borrarCuentaSEG.isEmpty()) {
                lstCuentasBorrarSEG.addAll(borrarCuentaSEG.values());
            }

            if (!lstCuentasBorrarSEG.isEmpty()) {

                Database.DeleteResult[] resultadoDelete5 = Database.delete(lstCuentasBorrarSEG, false);
                for (Integer i = 0; i < resultadoDelete5.size(); i++)
                {
                    if (!resultadoDelete5[i].isSuccess())
                    {
                        bError = true;
                        SEG_MetodosComunes.registrarErrorDML (resultadoDelete5[i].getErrors(), lstCuentasBorrarSEG[i]);
                    }
                }
                if (bError)
                {
                    throw new DMLException('SEG_ConciliacionAccount_Batch : Error al borrar registros en Account');
                }
            }

            // ********************************************************
            // Crear la nota asociada.
            // ********************************************************
            if (!notasPorCliente.isEmpty())
            {
                Database.SaveResult[] resultadoInsercion5 = Database.insert(notasPorCliente.values(), false);
                for (Integer i = 0; i < resultadoInsercion5.size(); i++)
                {
                    if (!resultadoInsercion5[i].isSuccess())
                    {
                        bError = true;
                        SEG_MetodosComunes.registrarErrorDML (resultadoInsercion5[i].getErrors(), notasPorCliente.values()[i]);
                    }
                }
                if (bError)
                {
                    throw new DMLException('SEG_ConciliacionAccount_Batch : Error al crear registros en ContentNote (nota informativa fusión)');
                }
                
                // Vincular las notas.
                List<ContentDocumentLink> listaLinksNotas = new List<ContentDocumentLink>();		
                for (Id clienteId : notasPorCliente.keySet())
                {				
                    ContentNote notaCliente = notasPorCliente.get(clienteId);				
                    if (notaCliente.Id != null)
                    {
                    
                        ContentDocumentLink linkNota = new ContentDocumentLink();
                        linkNota.ContentDocumentId = notaCliente.Id;
                        linkNota.LinkedEntityId = clienteId;
                        linkNota.Visibility = 'AllUsers';
                        linkNota.ShareType = 'I';
                        listaLinksNotas.add(linkNota);
                    }
                }
                
                if (!listaLinksNotas.isEmpty())
                {
                    //insert listaLinksNotas;
                    Database.SaveResult[] resultadoInsercion6 = Database.insert(listaLinksNotas, false);
                    for (Integer i = 0; i < resultadoInsercion6.size(); i++)
                    {
                        if (!resultadoInsercion6[i].isSuccess())
                        {
                            bError = true;
                            SEG_MetodosComunes.registrarErrorDML (resultadoInsercion6[i].getErrors(), listaLinksNotas[i]);
                        }
                    }
                    if (bError)
                    {
                        throw new DMLException('SEG_ConciliacionAccount_Batch : Error al crear registros en ContentDocumentLink (nota informativa fusión)');
                    }
                }

                /*
                Database.insert(notasPorCliente.values(), false);
                List<ContentDocumentLink> listaLinksNotas = new List<ContentDocumentLink>();		
                for (Id clienteId : notasPorCliente.keySet())
                {				
                    ContentNote notaCliente = notasPorCliente.get(clienteId);				
                    if (notaCliente.Id != null)
                    {
                    
                        ContentDocumentLink linkNota = new ContentDocumentLink();
                        linkNota.ContentDocumentId = notaCliente.Id;
                        linkNota.LinkedEntityId = clienteId;
                        linkNota.Visibility = 'AllUsers';
                        linkNota.ShareType = 'I';
                        listaLinksNotas.add(linkNota);
                    }
                }
                
                if (!listaLinksNotas.isEmpty())
                {
                    insert listaLinksNotas;
                }*/
            }
        } catch (Exception e) {
            // En caso de error, hacemos rollback de la BBDD.
            Database.rollback(transaccionBBDD);

            // Registrar error.
            CBK_Log.error(e);
        }
    }

    /**
     *  @description Proceso final del batch.
     *  @param bc -> Objeto contexto
     */
    public void finish(Database.BatchableContext bc)
    {
        CBK_Log.debug('Finalización - Batch conciliación clientes',logginglevel.INFO);
    }

    /**
     *  @description Función para registrar errores dml.
     *  @param errores -> Listado con los errores DML.
     */
    /*private static void SEG_MetodosComunes.registrarErrorDML (List<Database.Error> listaErrores, SObject objetoAsociado)
    {
        List<String> mensajesError = new List<String>();
        for (Database.Error error : listaErrores)
        {
            mensajesError.add(error.getStatusCode() + ' - ' + error.getMessage());
        }
        mensajesError.add('Objeto -> ' + objetoAsociado);
        DmlException excepcion = new DMLException(String.join(mensajesError, ', '));
        CBK_Log.error(excepcion);
    }*/
}