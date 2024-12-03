/*****************************************************************
 * Name: SAC_GenialQueueable
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Queueable para crear/modificar secuencialmente los datos
 * que nos llegan de la IA para tratar la reclamación. Está dividida en 4 pasos imitando los pasos
 * que realizaría un gestor para asigar un account, crear pretensiones, modificar la reclamación y
 * relacionar reclamantes secundarios.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US749927         Alexandre Pérez   06/11/23     Creación
 * 1.1            US866221         David Ramos       03/04/24     Cambiar SAC_GenialSettings__c por el nuevo custom 
 *                                                                setting que separa configuraciones por canal
 * 1.2            US866228         Alexandre Pérez   17/04/24     Shadow reclamantes
 * 2.0            US895283         Alexandre Pérez   18/04/24     Refactorización
 * 2.1            US869509         Alexandre Pérez   22/04/24     Concatenación resúmenes en la reclamación
 * 2.2            US911873         David Ramos       07/05/24     Alinear la creación de pretensiones de la fase 1 con 
 *                                                                SAC_LCMP_InsertarPretension
 * 2.3            US978023         Alexandre Pérez   29/08/24     Eliminar la creación de accounts y dejar sólo la creación de registros de resultado
*****************************************************************/
/**
* @description : Queueable para crear/modificar secuencialmente los datos
* que nos llegan de la IA para tratar la reclamación. Está dividida en 4 pasos imitando los pasos
* que realizaría un gestor para asigar un account, crear pretensiones, modificar la reclamación y
* relacionar reclamantes secundarios.
*/
public with sharing class SAC_GenialQueueable implements Queueable {
    SAC_Genial_WS.genialRequest genialRequest;
    integer fase;
    SAC_GenialSettingsCanal__c settings;

    /**
     * @description     método constructor
     * @param genial    datos recibidos de SAC_Genial_WS
     * @param fase      fase del queueable
     */
    public SAC_GenialQueueable(SAC_Genial_WS.genialRequest genial, integer fase) {
        this.genialRequest = genial;
        this.fase = fase;
        //se inicializa como un setting que tiene todo apagado
        SAC_GenialSettingsCanal__c settingsDefault = new SAC_GenialSettingsCanal__c();
        settingsDefault.Name = 'Default';
        settingsDefault.SAC_IAactiva__c = false;
        settingsDefault.SAC_Shadow__c = false;
        settingsDefault.SAC_Porcentaje__c = 0;
        this.settings = settingsDefault;

        if (genial.reclamaOriginal.Origin != null){
            if(SAC_GenialSettingsCanal__c.getInstance(genial.reclamaOriginal.Origin) != null){
                //es un origen valido, se usa su setting correspondiente
                this.settings = SAC_GenialSettingsCanal__c.getInstance(genial.reclamaOriginal.Origin);
            }
        }
    }
    public void execute(QueueableContext context) {

        if(settings.SAC_shadow__c || settings.SAC_IAactiva__c){
            
            SAC_Genial_WS.genialRequest genialRequest = this.genialRequest;
            switch on this.fase {
                when 0 {
                    cbk_log.debug('logica Account');
                    // Busqueda del account proporcionado por la IA
                    try{
                       
                        relacionarAccounts(genialRequest, settings);
                             
                    }catch(Exception e){
                        List<Object> detalle = new List<Object>();
                        detalle.add((Object)genialRequest);
                        CBK_Log.error(e, detalle);
                    }            
                    
                    /*if(!test.isRunningTest()){
                        System.enqueueJob(new SAC_GenialQueueable(genialRequest, 1));
                    }*/
                    queueableRecursivo(genialRequest, 1, context.getJobId());
                }
                when 1 {
                    //creación de pretensiones y registros shadow de reclamación y pretensión
                    cbk_log.debug('logica pretensiones');
                    try{
                        
                        if((settings.SAC_IAactiva__c && genialRequest.pdteIA)){
                            genialRequest.reclamacion.SAC_NPretensionesActivas__c = crearDatosPretensiones(genialRequest);
                        }

                        if(settings.SAC_shadow__c){
                            crearRegistrosShadow(genialRequest);    
                        }

                    }catch(Exception e){
                        List<Object> detalle = new List<Object>();
                        detalle.add((Object)genialRequest);
                        CBK_Log.error(e, detalle);
                    }
                   
                    /*if(!test.isRunningTest()){
                        System.enqueueJob(new SAC_GenialQueueable(genialRequest, 2));
                    }*/
                    queueableRecursivo(genialRequest, 2, context.getJobId());
                    
                }
                when 2 {
                    /*realizamos un primer update de la reclamación para separar el update de la pretensión principal con el cambio de owner ya que provoca 
                    conflicto updatearlo en una misma instancia*/
                    
                    cbk_log.debug('logica reclamación');

                    try{
                        if(modificarReclamacion(genialRequest, settings)){
                            queueableRecursivo(genialRequest, 4, context.getJobId());
                        }
                        
                    }catch(Exception e){
                        List<Object> detalle = new List<Object>();
                        detalle.add((Object)genialRequest);
                        CBK_Log.error(e, detalle);
                        case updatearEstado = new case();
                        Group cola = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('SAC_PendienteAsignar') LIMIT 1];
                        updatearEstado.id = genialRequest.reclamacion.Id;
                        updatearEstado.ownerId = cola.Id;
                        updatearEstado.SAC_GenialEstado__c = 'SAC_006';
                        update updatearEstado;
                    }                                      
                }
                when 3 {
                    //registros case reclamante y shadow de reclamantes secundarios
                    cbk_log.debug('logica case reclamante');
                    try{
                        crearCaseReclamantes(GenialRequest, settings); 
                    } catch(Exception e){
                        List<Object> detalle = new List<Object>();
                        detalle.add((Object)genialRequest);
                        CBK_Log.error(e, detalle);
                    }
                  
                }
                when 4 {
                    //asignación de la pretensión principal
                    cbk_log.debug('logica pretensión principal');
                    case pretension = [SELECT Id, SAC_Reclamacion__c FROM Case where Id = : genialRequest.reclamacion.SAC_PretensionPrincipal__c];
                    cbk_log.debug('pretensión principal' +pretension);
                    SAC_Case_Operativas_Controller.marcarPretensionPrincipal(pretension);

                    //comprobar si hay reclamantes secundiarios para lanzar el queueableRecursivo
                    if(genialRequest.reclamantes != null){
                        for (SAC_Genial_WS.datosReclamante reclamante : genialRequest.reclamantes) {
                            if(!reclamante.reclamantePrincipal){
                                queueableRecursivo(genialRequest, 3, context.getJobId());
                                break;
                            }
                        }  
                    }
                    
                }
                when else {
                    //nunca deberia llegar aquí, solo se llama con los numeros de fase anteriores
                    cbk_log.debug('error: ha entrado en una fase no controlada');
                }
            }

        } else {
            //desbloquear caso que en un inicio se destinó para IA pero luego la IA se bloqueó
            if(genialRequest.pdteIA){
                Group cola = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('SAC_PendienteAsignar') LIMIT 1];
                genialRequest.reclamacion.ownerId = cola.Id;
                update (genialRequest.reclamacion);
            }   
        }
    }

    /**
     * @description     busca los accounts proporcionados por la IA como reclamantes y de no encontrarlos los crea.
     *                  Evita asociar accounts confidenciales y en su lugar genera un account CONFIDENCIAL 
     * @param genialRequest    datos recibidos de SAC_Genial_WS.
     * @param settings         configuración definida en el entrono. 
     *                         varia segun el canal de entrada, pero se obtiene el que le corresponde en la constructora.
     */
    private static void relacionarAccounts(SAC_Genial_WS.genialRequest genialRequest, SAC_GenialSettingsCanal__c settings){
        account reclamantePrincipal = new account();
        map<string, account> confidenciales = new map<string, account>();
        //boolean principalInsertado = false;

        map<string, account> mapAccountsporDoc = new map<string, account>();
        map<string, Account> accountExistente = new map<string, Account>();
        //list<sObject> accountToInsertOb = new list<sObject>();

        //creamos un mapa de datos de los reclamantes y localizamos el principal
        if(genialRequest.reclamantes != null) {
            
            for(SAC_Genial_WS.datosReclamante datosReclamante : genialRequest.reclamantes) {
                if(string.isNotBlank(datosReclamante.reclamante.CC_Numero_Documento__c)) {
                    if(datosReclamante.reclamantePrincipal){
                        reclamantePrincipal = datosReclamante.reclamante;
                    }
                    mapAccountsporDoc.put(datosReclamante.reclamante.CC_Numero_Documento__c, datosReclamante.reclamante);
                } 
            }
        }
        buscarAccountBBDD(accountExistente, mapAccountsporDoc, confidenciales);

        registrarReclamantePrincipal(genialRequest, reclamantePrincipal, confidenciales);
        // if (genialRequest.reclamantes != null) {
        //     for (SAC_Genial_WS.datosReclamante datosReclamante : genialRequest.reclamantes) {
        //         //metemos el email por fuera de la creación del account para que funcione en modo shadow en caso de no pasarnos un documento
        //         if(datosReclamante.reclamantePrincipal){
        //             // Verificamos si el account es confidencial y solo rellenamos email, tlf y nombre cofidencial

        //             if (confidenciales.containsKey(datosReclamante.reclamante.CC_Numero_Documento__c)) {
        //                 genialRequest.reclamacion.SAC_NombreContacto__c = 'CONFIDENCIAL';
        //                 genialRequest.reclamacion.CC_SuppliedNIF__c = datosReclamante.reclamante.CC_Numero_Documento__c;
        //                 genialRequest.reclamacion.CC_Telefono_Contacto__c = datosReclamante.reclamante.PersonMobilePhone;                  
        //             } else {

        //                 genialRequest.reclamacion.OS_Email__c = datosReclamante.reclamante.PersonEmail;
        //                 genialRequest.reclamacion.CC_Telefono_Contacto__c = datosReclamante.reclamante.PersonMobilePhone;
        //                 genialRequest.reclamacion.SAC_DireccionContacto__c = datosReclamante.reclamante.BillingStreet;
        //                 genialRequest.reclamacion.SAC_CodigoPostalContacto__c = datosReclamante.reclamante.BillingPostalCode;
        //                 genialRequest.reclamacion.SAC_PoblacionContacto__c = datosReclamante.reclamante.BillingCity;
        //                 genialRequest.reclamacion.SAC_ProvinciaContacto__c = datosReclamante.reclamante.BillingState;
        //                 genialRequest.reclamacion.SAC_PaisContacto__c = datosReclamante.reclamante.BillingCountry;
        //                 genialRequest.reclamacion.CC_SuppliedNIF__c = datosReclamante.reclamante.CC_Numero_Documento__c;
        //                 if (datosReclamante.reclamante.firstName != null){
        //                     genialRequest.reclamacion.SAC_NombreContacto__c = datosReclamante.reclamante.firstName + ' ';
        //                 }
        //                 if (datosReclamante.reclamante.lastName != null){
        //                     genialRequest.reclamacion.SAC_NombreContacto__c += datosReclamante.reclamante.lastName;
        //                 }
        //             }
        //         }
        //         if(string.isNotBlank(datosReclamante.reclamante.CC_Numero_Documento__c)){
        //             if(datosReclamante.reclamantePrincipal){
        //                 reclamantePrincipal = datosReclamante.reclamante;
        //             }
        //         }
        //     }
        // }
                  
       // buscarAccountBBDD(accountExistente, mapAccountsporDoc, confidenciales);

       //quedarse solo con el Id con los cambios para evitar asociar accounts en la creación. 
       //tiene que existir el account y que la reclamaOriginal no tuviese ya un account asignado(formulario)
       if(accountExistente.containsKey(reclamantePrincipal.CC_Numero_Documento__c) 
       && genialRequest.reclamaOriginal.accountId == null){
            genialRequest.reclamacion.AccountId = accountExistente.get(reclamantePrincipal.CC_Numero_Documento__c).Id;
       }
       //creacion de los accounts(en cuarentena)
       /*  if(string.isNotBlank(reclamantePrincipal.CC_Numero_Documento__c)){
            if(!accountExistente.containsKey(reclamantePrincipal.CC_Numero_Documento__c) && genialRequest.reclamaOriginal.accountId == null){
                Account recPrin = construirInsertAccount(reclamantePrincipal, confidenciales);
                accountToInsertOb.add((sObject)recPrin);
                principalInsertado = true; 
                
            } else if (accountExistente.get(reclamantePrincipal.CC_Numero_Documento__c)!= null){ //podria pasar en los casos de formularios en shadow
                //si ya existe asignamos el id al caso
                genialRequest.reclamacion.AccountId = accountExistente.get(reclamantePrincipal.CC_Numero_Documento__c).Id;
            }
        }
        

        //añadimos al insert aquellos accounts que no tengamos en bbdd
        for(account accReclamante : mapAccountsporDoc.values()){
            if(accReclamante.CC_Numero_Documento__c != reclamantePrincipal.CC_Numero_Documento__c) {
                if(!accountExistente.containsKey(accReclamante.CC_Numero_Documento__c)){
                    //añadir noClientePA record type
                    Account recPrin = construirInsertAccount(accReclamante, confidenciales);
                    
                    accountToInsertOb.add((sObject)recPrin);
                }
                else if(confidenciales.containsKey(accReclamante.CC_Numero_Documento__c)){
                    accReclamante.CC_Confidencial__c = true;
                }
            }
        }


        if(settings.SAC_IAactiva__c && genialRequest.pdteIA) {
            SAC_MetodosSinSharing.modificarInsertarObjetos(accountToInsertOb, 'Insert');
            if(principalInsertado){
                genialRequest.reclamacion.AccountId = accountToInsertOb[0].Id;
                
            }
            // //para que despues del insert tenga el id
            for(sObject objInsertado : accountToInsertOb){
                Account accInsertada = (Account)objInsertado;
                mapAccountsporDoc.get(accInsertada.CC_Numero_Documento__c).Id = accInsertada.Id;
            }
        } */
    }

    /**
     * @description                 Buscar accounts en la BBDD, de existir lo incluimos en la lista de accountExistente, 
     *                              de no existir lo metemos en la lista de Confidenciales
     * @param accountExistente      mapa donde se va a asociar el CC_Numero_Documento__c con su objeto account.
     *                              contendrá los que ya existan en el entorno de ejecucion que no sean confidenciales.
     * @param mapAccountsporDoc     mapa donde se asocia el CC_Numero_Documento__c con su objeto account.
     *                              contiene los que ha informado la IA que tengan CC_Numero_Documento__c
     * @param confidenciales        mapa donde se va a asociar el CC_Numero_Documento__c con su objeto account.
     *                              contendrá los que ya existan en el entorno de ejecucion que si sean confidenciales.
     */
    private static void buscarAccountBBDD(map<string, account> accountExistente, map<string, Account> mapAccountsporDoc, map<string, Account> confidenciales) {
        String noclientePART = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();
        for(account accExistente : SAC_MetodosSinSharing.listaDeClientesPorDoc(mapAccountsporDoc.keySet())){
            if(!accountExistente.containsKey(accExistente.CC_Numero_Documento__c) || 
            (accountExistente.containsKey(accExistente.CC_Numero_Documento__c) &&
             accountExistente.get(accExistente.CC_Numero_Documento__c).recordTypeId != noclientePART)){            
                //comprobamos que lo tengamos como confidencial
                if(accExistente.AV_Confidencial__c && accExistente.AV_NumPerso__c != null){
                    confidenciales.put(accExistente.CC_Numero_Documento__c, accExistente);
                } else {
                    accountExistente.put(accExistente.CC_Numero_Documento__c, accExistente);
                    mapAccountsporDoc.get(accExistente.CC_Numero_Documento__c).Id = accExistente.Id;
                }
            }
        }
    }

    /**
     * @description                 Buscar el reclamante principal de los recibidos de la IA, 
     *                              y registrar sus datos en los campos de la reclamación correspondientes.
     * @param genialRequest         datos recibidos de SAC_Genial_WS.
     * @param reclamantePrincipal   contendrá el reclamante principal de la reclamación.
     * @param confidenciales        mapa donde está asociado el CC_Numero_Documento__c con su objeto account.
     *                              contiene los que ya existan en el entorno de ejecucion que son confidenciales.
     */
    private static void registrarReclamantePrincipal(SAC_Genial_WS.genialRequest genialRequest, account reclamantePrincipal, map<string, Account> confidenciales){
        if (genialRequest.reclamantes != null) {
            for (SAC_Genial_WS.datosReclamante datosReclamante : genialRequest.reclamantes) {
                //metemos el email por fuera de la creación del account para que funcione en modo shadow en caso de no pasarnos un documento
                if(datosReclamante.reclamantePrincipal){
                    //solo debe entrar 1 vez
                    //registro para obtener datos del reclamante que no tienen su campo a nivel de reclamación US9788023
                    SAC_Genial_WS.DatosRecPrincipal datosRecPrincipal = new SAC_Genial_WS.DatosRecPrincipal();
                    // Verificamos si el account es confidencial y solo rellenamos email, tlf y nombre cofidencial 
                    if (confidenciales.containsKey(datosReclamante.reclamante.CC_Numero_Documento__c)) {
                        genialRequest.reclamacion.SAC_NombreContacto__c = 'CONFIDENCIAL';
                        genialRequest.reclamacion.CC_SuppliedNIF__c = datosReclamante.reclamante.CC_Numero_Documento__c;
                        genialRequest.reclamacion.CC_Telefono_Contacto__c = datosReclamante.reclamante.PersonMobilePhone;
                        //US9788023
                        datosRecPrincipal.numPerso = confidenciales.get(datosReclamante.reclamante.CC_Numero_Documento__c).AV_NumPerso__c;                 
                    } else {
                        genialRequest.reclamacion.OS_Email__c = datosReclamante.reclamante.PersonEmail;
                        genialRequest.reclamacion.CC_Telefono_Contacto__c = datosReclamante.reclamante.PersonMobilePhone;
                        genialRequest.reclamacion.SAC_DireccionContacto__c = datosReclamante.reclamante.BillingStreet;
                        genialRequest.reclamacion.SAC_CodigoPostalContacto__c = datosReclamante.reclamante.BillingPostalCode;
                        genialRequest.reclamacion.SAC_PoblacionContacto__c = datosReclamante.reclamante.BillingCity;
                        genialRequest.reclamacion.SAC_ProvinciaContacto__c = datosReclamante.reclamante.BillingState;
                        genialRequest.reclamacion.SAC_PaisContacto__c = datosReclamante.reclamante.BillingCountry;
                        genialRequest.reclamacion.CC_SuppliedNIF__c = datosReclamante.reclamante.CC_Numero_Documento__c;
                        if (datosReclamante.reclamante.firstName != null){
                            genialRequest.reclamacion.SAC_NombreContacto__c = datosReclamante.reclamante.firstName + ' ';
                            //US9788023
                            datosRecPrincipal.firstName = datosReclamante.reclamante.firstName;
                        }
                        if (datosReclamante.reclamante.lastName != null){
                            genialRequest.reclamacion.SAC_NombreContacto__c += datosReclamante.reclamante.lastName;
                            //US9788023
                            datosRecPrincipal.lastName = datosReclamante.reclamante.lastName;
                        }
                        
                        
                    }
                    genialRequest.datosRecPrincipal = datosRecPrincipal;
                }
                if(string.isNotBlank(datosReclamante.reclamante.CC_Numero_Documento__c)){
                    if(datosReclamante.reclamantePrincipal){
                        reclamantePrincipal = datosReclamante.reclamante;
                    }
                }
            }
        }
    }

    /**
     * @description                 construye el insert del account dependiendo si es o no confidencia
     * @param reclamante            account a construir el insert
     * @param confidenciales        mapa donde está asociado el CC_Numero_Documento__c con su objeto account.
     *                              contiene los que ya existan en el entorno de ejecucion que son confidenciales.
     */
    private static account construirInsertAccount(account reclamante, map<string, account> confidenciales){
        Account recPrin;
        String ccCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        String noclientePART = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();
        if(confidenciales.containsKey(reclamante.CC_Numero_Documento__c)){
            recPrin = new Account();
            recPrin.recordTypeId = ccCliente;
            recPrin.Name = 'CONFIDENCIAL';
            recPrin.CC_NumPerso__c = confidenciales.get(reclamante.CC_Numero_Documento__c).AV_NumPerso__c;
            recPrin.CC_Confidencial__c = true;
            recPrin.CC_Numero_Documento__c = reclamante.CC_Numero_Documento__c;
            reclamante.av_confidencial__c = true;
        } else {
            recPrin = reclamante;
            recPrin.recordtypeId = noclientePART;
        }
        return recPrin;
    }

    /**
     * @description             Creación de los objetos de pretensiones para su posterior inserción
     *                          CAMBIAR POR LLAMADA CONJUNTA EN EL CORE DE SAC
     * @param genialRequest     datos recibidos de SAC_Genial_WS.
     */
    private static integer crearDatosPretensiones(SAC_Genial_WS.genialRequest genialRequest) {

        String rECORDTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        list<sobject> pretensiones = new list<sobject>();

        list<id> setIdsDetalleAux = new list<id>();
        //sacamos una lista de detalles proporcionados por la IA
        for(case pretension : genialRequest.pretensiones) {
            //agregamos a la lista ids de detalle para buscarlos luego y acabar de completar los datos a rellenar de la pretensión
            setIdsDetalleAux.add(pretension.SEG_Detalle__c);

        }
        //obtener mapa MCCs para su clasificación
        map<id, CC_MCC__c> mapaMcc = new map<id, CC_MCC__c>([SELECT id, Name, SAC_EntidadAfectada__c, SAC_EntidadProductora__c, SAC_EsPsd2__c, CC_Motivo__c, CC_Motivo__r.CC_Producto_Servicio__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c, 
        CC_Motivo__r.CC_Producto_Servicio__r.Name, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c
        FROM CC_MCC__c 
        WHERE Id IN: setIdsDetalleAux 
        AND RecordType.DeveloperName = 'SAC_Detalle']);

        //a revisar optimización del proceso(ya se recupera en la API REST)
        case reclamacionActual = [SELECT Id, Origin, Status, AccountId, SAC_CasoEspecial__c, CC_Canal_Procedencia__c, ContactId, CC_SuppliedNIF__c FROM Case WHERE Id = : genialRequest.reclamacion.Id];
        
        //version 2 con el generador de SAC_LCMP_InsertarPretension
        for(case pretension : genialRequest.pretensiones) {
            if(string.isNotBlank(pretension.SEG_Detalle__c) && string.isNotBlank(pretension.CC_MCC_Motivo__c) 
            && string.isNotBlank(pretension.CC_MCC_ProdServ__c) && string.isNotBlank(pretension.CC_MCC_Tematica__c)){
                String asunto = mapaMcc.get(pretension.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.Name + ' - ' + mapaMcc.get(pretension.SEG_Detalle__c).Name;
                Case pretensionGenerada = SAC_LCMP_InsertarPretension.camposPretension(reclamacionActual, pretension.SEG_Detalle__c, pretension.CC_MCC_Motivo__c, pretension.CC_MCC_ProdServ__c, pretension.CC_MCC_Tematica__c, RECORDTYPEPRETENSION, asunto, mapaMcc);
                Map<String, Object> camposPretGenerada = pretensionGenerada.getPopulatedFieldsAsMap();
                for (String nombreCampo : camposPretGenerada.keySet()) {
                    pretension.put(nombreCampo, pretensionGenerada.get(nombreCampo));
                }
                //pretension.AccountId = genialRequest.reclamacion.AccountId; 
                pretension.SAC_GenialEstado__c = 'SAC_003';
                pretensiones.add((sObject)pretension);
            }
        }

        /*
        for(case pretension : genialRequest.pretensiones) {
            pretension.recordTypeId = RECORDTYPEPRETENSION;
            
            if(string.isNotBlank(pretension.SEG_Detalle__c) && string.isNotBlank(pretension.CC_MCC_Motivo__c) 
            && string.isNotBlank(pretension.CC_MCC_ProdServ__c) && string.isNotBlank(pretension.CC_MCC_Tematica__c)){
                pretension.subject = mapaMcc.get(pretension.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.Name + ' - ' + mapaMcc.get(pretension.SEG_Detalle__c).Name;

                pretension.status = reclamacionActual.Status;
                pretension.SAC_StatusAuxiliar__c = reclamacionActual.Status;
                pretension.Origin = reclamacionActual.Origin;
                pretension.SAC_TiempoSLARegulatorio__c = 30;
                pretension.SAC_TiempoSLALetradoAlta__c = 30;
                pretension.CC_No_Identificado__c  = true;
                pretension.CC_IdentCliente__c     = '0';
                pretension.SAC_CasoEspecial__c = reclamacionActual.SAC_CasoEspecial__c;
                pretension.AccountId = genialRequest.reclamacion.AccountId; 

                pretension.SAC_Entidad_Afectada__c = mapaMcc.get(pretension.SEG_Detalle__c).SAC_EntidadAfectada__c;
                pretension.SAC_EntidadProductora__c = mapaMcc.get(pretension.SEG_Detalle__c).SAC_EntidadProductora__c;
                pretension.SAC_CASE_esPSD2__c = mapaMcc.get(pretension.SEG_Detalle__c).SAC_EsPsd2__c;
                pretension.CC_Codigo_Externo_Tematica__c = mapaMcc.get(pretension.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c;
                pretension.SAC_GenialEstado__c = 'SAC_003';
                pretensiones.add((sObject)pretension);
            }
        }
        */

        //devuelve las pretensiones que se han insertado
        return SAC_MetodosSinSharing.modificarInsertarObjetos(pretensiones, 'insert');
    }

    /**
     * @description            Crea todos los registros shadow relacionados con los datos enviados por la IA.
     *                         En primer lugar, se debe crear el registro shadow de la reclamación para tener el Id, 
     *                         luego los shadow de las pretensiones
     * @param genialRequest    datos recibidos de SAC_Genial_WS.
     */
    private static void crearRegistrosShadow(SAC_Genial_WS.genialRequest genialRequest){

        String recResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion_IA').getRecordTypeId();
        //rt de la pretensión en el objeto de resultado
        String pretResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();
        SAC_Genial_Resultado__c genRes = new SAC_Genial_Resultado__c();
        list<sobject> objRes = new list<sobject>();
        //SAC_Genial_WS.DatosRecPrincipal datosRecPrincipal = new SAC_Genial_WS.DatosRecPrincipal();

        genRes = SAC_GenialUtils.casteoCaseAgenialResultado(genialRequest.reclamacion);        
        genRes.SAC_Reclamacion__c = genialRequest.reclamacion.id;
        genRes.SAC_Json__c = genialRequest.jsonRequest;
        genRes.recordTypeId = recResRT;
        //añadimos los campos necesarios para la creación posterior del reclamante por botón     
        genRes.SAC_FirstName__c = genialRequest.datosRecPrincipal.firstName;
        genRes.SAC_LastName__c = genialRequest.datosRecPrincipal.lastName;
        genRes.SAC_NumPerso__c = genialRequest.datosRecPrincipal.numPerso;

        genialRequest.reclamacion.SAC_Resumen__c = '';

        for(case pretension : genialRequest.pretensiones) {

            genialRequest.reclamacion.SAC_Resumen__c += pretension.SAC_Resumen__c + ' ';
            if(pretension.SAC_EsPrincipal__c){
                genialRequest.reclamacion.SAC_PretensionPrincipal__c = pretension.id;
                genRes.SAC_MCC_Tematica__c = pretension.CC_MCC_Tematica__c;
                genRes.SAC_MCC_ProdServ__c = pretension.CC_MCC_ProdServ__c;
                genRes.SAC_MCC_Motivo__c = pretension.CC_MCC_Motivo__c;
                genRes.SAC_Detalle__c = pretension.SEG_Detalle__c;
                
            }
        }
        
        objRes.add((sobject)genRes);
        SAC_MetodosSinSharing.modificarInsertarObjetos(objRes, 'insert');
        objRes.clear();
        genialRequest.idShadow = genRes.id;
                      
        for(case pretension : genialRequest.pretensiones) {

            genRes = new SAC_Genial_Resultado__c();
            genRes = SAC_GenialUtils.casteoCaseAgenialResultado(pretension);
            genRes.SAC_Reclamacion__c = genialRequest.reclamacion.id;
            if(pretension.id != null) {
                genRes.SAC_Pretension__c = pretension.id;
            }
            genRes.SAC_Json__c = JSON.serialize(pretension);
            genRes.recordTypeId = pretResRT;
            genRes.SAC_ParentId__c = genialRequest.idShadow;
            objRes.add((sObject)genRes);

        }
    //insert listGenRes;
    SAC_MetodosSinSharing.modificarInsertarObjetos(objRes, 'insert');

    }

    /**
     * @description            Se modifica la reclamación con todas las modificaciones necesarias 
     *                         que se han ido realizando en los otros pasos del proceso 
     * @param genialRequest    datos recibidos de SAC_Genial_WS.
     * @param settings         configuración definida en el entrono. 
     *                         varia segun el canal de entrada, pero se obtiene el que le corresponde en la constructora.
     */
    private static boolean modificarReclamacion(SAC_Genial_WS.genialRequest genialRequest, SAC_GenialSettingsCanal__c settings) {
        case reclamacion = new case();
                        
        //devolverla a la cola "pendiente de asignar"
            Group cola = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('SAC_PendienteAsignar') LIMIT 1];
            //variable para independizar el proceso de pretension principal
            id pretPrincipalId;
            if(settings.SAC_IAactiva__c && genialRequest.pdteIA){

                //Para casos que vienen de formulario, el accountId ya viene relleno y es prioritario a lo que diga la IA, pero previamente hemos modificado los registros 
                //para dejar constancia en el modo shadow de lo que sugiere la IA
                if(genialRequest.reclamaOriginal.Origin == 'SAC_Formulario') {
                    genialRequest.reclamacion.AccountId = genialRequest.reclamaOriginal.AccountId;
                    genialRequest.reclamacion.CC_SuppliedNif__c = genialRequest.reclamaOriginal.CC_SuppliedNif__c;
                    genialRequest.reclamacion.OS_Email__c = genialRequest.reclamaOriginal.OS_Email__c;
                    genialRequest.reclamacion.CC_Telefono_Contacto__c = genialRequest.reclamaOriginal.CC_Telefono_Contacto__c;
                    genialRequest.reclamacion.SAC_DireccionContacto__c = genialRequest.reclamaOriginal.SAC_DireccionContacto__c;
                    genialRequest.reclamacion.SAC_CodigoPostalContacto__c = genialRequest.reclamaOriginal.SAC_CodigoPostalContacto__c;
                    genialRequest.reclamacion.SAC_PoblacionContacto__c = genialRequest.reclamaOriginal.SAC_PoblacionContacto__c;
                    genialRequest.reclamacion.SAC_ProvinciaContacto__c = genialRequest.reclamaOriginal.SAC_ProvinciaContacto__c;
                    genialRequest.reclamacion.SAC_PaisContacto__c = genialRequest.reclamaOriginal.SAC_PaisContacto__c;
                    genialRequest.reclamacion.SAC_NombreContacto__c = genialRequest.reclamaOriginal.SAC_NombreContacto__c;
                } else {               
                    //volvemos al estado null despues de que el casteador haya hecho su función para el shadow
                    genialRequest.reclamacion.OS_Email__c = null;
                    genialRequest.reclamacion.CC_Telefono_Contacto__c = null;
                    genialRequest.reclamacion.SAC_DireccionContacto__c = null;
                    genialRequest.reclamacion.SAC_CodigoPostalContacto__c = null;
                    genialRequest.reclamacion.SAC_PoblacionContacto__c = null;
                    genialRequest.reclamacion.SAC_ProvinciaContacto__c = null;
                    genialRequest.reclamacion.SAC_PaisContacto__c = null;
                    genialRequest.reclamacion.SAC_NombreContacto__c = null;
                    genialRequest.reclamacion.CC_SuppliedNif__c = null;
                    genialRequest.reclamacion.AccountId = null;
                }
                //como medida mitigadora temporal ocultamos el nif del representante, 
                //siguiendo los mismos criterios que en los reclamantes
                if (!settings.SAC_BotonReclamante__c){
                    genialRequest.reclamacion.SAC_NumeroDelDocumento__c = null;
                }

                reclamacion = genialRequest.reclamacion;
                reclamacion.ownerId = cola.id;
                pretPrincipalId = reclamacion.SAC_PretensionPrincipal__c;
                //blanqueamos para que el trigger no coincida con la logica de cambio de owner
                reclamacion.SAC_PretensionPrincipal__c = null;              
               
                reclamacion.SAC_GenialEstado__c = 'SAC_003';

                SAC_MetodosSinSharing.modificarInsertarObjetos((sobject)reclamacion, 'update');
                genialRequest.reclamacion.SAC_PretensionPrincipal__c = pretPrincipalId;

                /*if(!test.isRunningTest()){
                    //paso para independizar la asignación de la reclamación principal
                    //System.enqueueJob(new SAC_GenialQueueable(genialRequest, 4));
                    queueableRecursivo(genialRequest, 4);
                }*/
                //queueableRecursivo(genialRequest, 4, context.getJobId());
                return true;
                  
            } else if (settings.SAC_shadow__c) {
                
                reclamacion.Id = genialRequest.reclamacion.Id;
                reclamacion.SAC_GenialEstado__c = 'SAC_002';
                SAC_MetodosSinSharing.modificarInsertarObjetos((sobject)reclamacion, 'update');
                
                
            }
            return false;
    }

    /**
     * @description            Proceso para crear las relaciones de reclamantes secundarios con la reclamación
     *                         Se cargan los registros informacionales shadow de reclamantes secundarios
     * @param genialRequest    datos recibidos de SAC_Genial_WS.
     * @param settings         configuración definida en el entrono. 
     *                         varia segun el canal de entrada, pero se obtiene el que le corresponde en la constructora.
     */
    private static void crearCaseReclamantes(SAC_Genial_WS.genialRequest genialRequest, SAC_GenialSettingsCanal__c settings) {

        String reclaShadowRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamante_IA').getRecordTypeId();
        //SAC_CaseReclamante__c caseRec;
        //list<sObject> caseRecInsert = new list<SAC_CaseReclamante__c>();
        list<id> accountIdList = new list<id>();
        list<sObject> reclaShadowList = new list<SAC_Genial_Resultado__c>();
        //creamos lista de Ids de account ya relacionados con el caso para no duplicarlos
        for( SAC_CaseReclamante__c caseRecInt : [SELECT SAC_Account__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = : 
                                        genialRequest.reclamacion.Id]) {
            accountIdList.add(caseRecInt.SAC_Account__c);
        }     
        for(SAC_Genial_WS.datosReclamante reclamante : genialRequest.reclamantes){
            //es para secundarios, los datos del reclamante principal están a nivel del shadow de la reclamación y con la asignación del Id del account
            //se crea por trigger el registro de case reclamante del principal
            if(!reclamante.reclamantePrincipal && reclamante.reclamante.Id != null && !accountIdList.contains(reclamante.reclamante.Id)){
                /*caseRec = new SAC_CaseReclamante__c(
                    SAC_Account__c = reclamante.reclamante.Id,
                    SAC_Case__c = genialRequest.reclamacion.Id
                );*/
                //caseRecInsert.add((sObject)caseRec);
                SAC_Genial_Resultado__c reclaShadow = new SAC_Genial_Resultado__c();
                reclaShadow.SAC_AccountId__c = reclamante.reclamante.Id;
                reclaShadow.SAC_Reclamacion__c = genialRequest.reclamacion.Id;
                reclaShadow.recordTypeId = reclaShadowRT;
                reclaShadow.SAC_ParentId__c = genialRequest.idShadow;

                // Verificamos si el account es confidencial o el dummy confidencial
                if (reclamante.reclamante.CC_Confidencial__c || reclamante.reclamante.AV_Confidencial__c) {
                    reclaShadow.SAC_NombreContacto__c = 'CONFIDENCIAL';
                    reclaShadow.SAC_SuppliedNIF__c = reclamante.reclamante.CC_Numero_Documento__c;
                    reclaShadow.SAC_Telefono_Contacto__c = reclamante.reclamante.PersonMobilePhone;
                    reclaShadow.SAC_NumPerso__c = reclamante.reclamante.CC_NumPerso__c;
                    
                } else {
                    reclaShadow.SAC_Email__c = reclamante.reclamante.PersonEmail;
                    reclaShadow.SAC_Telefono_Contacto__c = reclamante.reclamante.PersonMobilePhone;
                    reclaShadow.SAC_DireccionContacto__c = reclamante.reclamante.BillingStreet;
                    reclaShadow.SAC_CodigoPostalContacto__c = reclamante.reclamante.BillingPostalCode;
                    reclaShadow.SAC_PoblacionContacto__c = reclamante.reclamante.BillingCity;
                    reclaShadow.SAC_ProvinciaContacto__c = reclamante.reclamante.BillingState;
                    reclaShadow.SAC_PaisContacto__c = reclamante.reclamante.BillingCountry;
                    reclaShadow.SAC_SuppliedNIF__c = reclamante.reclamante.CC_Numero_Documento__c;
                    reclaShadow.SAC_FirstName__c = reclamante.reclamante.FirstName;
                    reclaShadow.SAC_LastName__c = reclamante.reclamante.LastName;
                    if (reclamante.reclamante.firstName != null){
                        reclaShadow.SAC_NombreContacto__c = reclamante.reclamante.firstName + ' ';
                    }
                    if (reclamante.reclamante.lastName != null){
                        reclaShadow.SAC_NombreContacto__c += reclamante.reclamante.lastName;
                    }
                }
                if(settings.SAC_Shadow__c) {
                    reclaShadowList.add((sObject)reclaShadow);
                }
                
            }
            
        }
        //insert reclaShadowList;
        //insert caseRecInsert;
        SAC_MetodosSinSharing.modificarInsertarObjetos(reclaShadowList, 'insert');
        //comprobamos si se cumplen los requisitos para crear case reclamantes relacionados
        /*if(SAC_MetodosSinSharing.comprobarCaseReclamante(genialRequest.reclamacion.Id)){
            SAC_MetodosSinSharing.modificarInsertarObjetos(caseRecInsert, 'insert');
        }*/
        
    }

    /**
     * @description            funcion para determinar si lanza el queueable recursivo.
     * @param genialRequest    datos recibidos de SAC_Genial_WS.
     * @param posicion         fase del queueable que se va a ejecutar.
     * @param jobId            jobId del contexto en el que se hace la llamada.
     */
    private static void queueableRecursivo(SAC_Genial_WS.genialRequest genialRequest, integer posicion, id jobId) {
        //if(!test.isRunningTest()){
            //paso para independizar la asignación de la reclamación principal
            //system.enqueueJob(new SAC_GenialQueueable(genialRequest, posicion));
        
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(jobId)
                                        .addString('GenIAl')
                                        .build();
        try {
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, posicion), options);
        } catch (Exception e) {
            //Exception is thrown if there is already an enqueued job with the same 
            //signature
            //Assert.areEqual('Intento de ejecutar un Queueable duplicado', ex.getMessage());
            List<Object> detalle = new List<Object>();
            detalle.add((Object)genialRequest);
            CBK_Log.error(e, detalle);
        }
       // }
    }
}