/***************************************************************************
 * Name: SPV_Reclamaciones_IntegrationBatch
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Insertar diariamente las reclamaciones obtenidas de la integración SPV_Reclamaciones_Integration
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0             US1031912      Álex Polo        03/10/2024      Creación
 * 1.1                            Raúl Santos      09/10/2024      Modificación: lógica para detectar expediente duplicado
***************************************************************************/

public with sharing class SPV_Reclamaciones_IntegrationBatch implements Database.batchable<sObject> {
  
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();        //Se obtiene el id del record type de case de las reclamaciones SPV
    //Id batchJobId = Database.executeBatch(new SPV_Reclamaciones_IntegrationBatch(), 200);

    //Mapeo de los ids del campo 'empresaProcede' con su correspondiente apiNombre de entidad afectada
    private static Map<Integer, String> apiNameEmpresaMap = new Map<Integer, String>{
        1 => 'SAC_002',
        6 => 'SAC_003',
        8 => 'SAC_004',
        29 => 'SAC_005',
        30 => 'SAC_006',
        42 => 'SAC_007',
        82 => 'SAC_008',
        121 => 'SAC_021',
        124 => 'SAC_009',
        548 => 'SAC_010',
        811 => 'SAC_011',
        2038 => 'SAC_012',
        6802 => 'SAC_013',
        8221 => 'SAC_005',
        8776 => 'SAC_015'
    };


    public Iterable<sObject> start(Database.BatchableContext dbc){
        List<Case> lista = new List<Case>();
        Case caso = new Case();
        caso.Status = 'SAC_001';
        lista.add(caso);
        return lista;
    }

    public void execute (Database.BatchableContext dbc, List<sObject> cases){
        List<SPV_Reclamaciones_Integration.ListaResultado> listaReclamacionesRecibidas = new List<SPV_Reclamaciones_Integration.ListaResultado>();  //Almacena los objetos que son los campos con los que se van a crear las reclamaciones. Se recibe de la integración

        //Se llama a la integración
        SPV_Reclamaciones_Integration.ReclamacionResponse reclamacionResponse = SPV_Reclamaciones_Integration.getReclamaciones();
      
        if(reclamacionResponse.statusCode.equalsIgnoreCase('200')){
            if(reclamacionResponse.data != null){
                listaReclamacionesRecibidas = reclamacionResponse.data; //Lista de objetos donde cada uno incluye lso campos que van a representar una reclamación
            }
            
            Map<String, CC_Grupo_Colaborador__c> mapaGrupos  = new Map<String, CC_Grupo_Colaborador__c>();  //Mapa nombreGrupo - grupo
            Map<String, Account> mapaAccounts = new Map<String, Account>();                                 //Mapa numDocumento - Account
            Map<String, Case> casosExpDuplicadoMap = new Map<String, Case>();                               //Mapa SPV_NumExpediente__c + SAC_Entidad_Afectada__c - Case
            Map<String, SPV_Reclamaciones_Integration.ListaResultado> casosExpNoDuplicadoMap = new Map<String, SPV_Reclamaciones_Integration.ListaResultado>();  //Mapa SPV_NumExpediente__c + SAC_Entidad_Afectada__c - SPV_Reclamaciones_Integration.ListaResultado
            List<Account> listaAccounts  = new List<Account>();                                             //Lista de accounts de las reclamaciones recibidas
            List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();                //Lista de grupos de las reclamaciones recibidas
            List<Case> listaCasosExpDuplicado = new List<Case>();                                           //Lista de las reclamaciones ya existentes en las que se ha detectado un expediente duplicado (basado en los datos de entrada)
            List<SPV_Reclamaciones_Integration.ListaResultado> listaRecRecibidasExpNoDuplicado = new List<SPV_Reclamaciones_Integration.ListaResultado>();  //Lista filtrada de los campos recibidos por la integración. No contiene datos de reclamaciones ya existentes.
            Set<String> numsDocAccounts = new Set<String>();                                                //números de documento de las cuentas de las reclamaciones recibidas
            Set<String> nombresGrupos = new Set<String>();                                                  //nombres de los grupos de las reclamaciones recibidas
            Set<String> setNumeroExp = new Set<String>();                                                   //números de expediente de las reclamaciones recibidas
            Set<String> setEntidadAfectada = new Set<String>();                                             //apiNames de la entidad afectada de las reclamaciones recibidas

            //Obtener los ids de los campos que se van a necesitar para hacer las querys
            for(SPV_Reclamaciones_Integration.ListaResultado campos : listaReclamacionesRecibidas){

                if(campos.numDocReclamante != null){
                    numsDocAccounts.add(campos.numDocReclamante);
                }

                if(campos.grupo != null){
                    nombresGrupos.add(campos.grupo);
                }

                if(campos.expedienteReclamacion != null){
                    setNumeroExp.add(campos.expedienteReclamacion);
                }

                if(campos.empresaProcede != null){
                    Integer empresaProcedeInt = Integer.valueOf(campos.empresaProcede);
                    String apiNameEmpresa = apiNameEmpresaMap.get(empresaProcedeInt);
                    
                    if(apiNameEmpresa != null){
                    	setEntidadAfectada.add(apiNameEmpresaMap.get(empresaProcedeInt));  
                    }
                }
            }

            //Obtener los accounts y grupso necesarios
            if(!numsDocAccounts.isEmpty()){
                listaAccounts = [SELECT Id, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c IN :numsDocAccounts];
            }

            if(!nombresGrupos.isEmpty()){
                listaGrupos = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name IN :nombresGrupos];
            }

            if(!setNumeroExp.isEmpty() && !setNumeroExp.isEmpty()){
                listaCasosExpDuplicado = [SELECT Id, SPV_NumExpediente__c, SAC_Entidad_Afectada__c, Status FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND SPV_NumExpediente__c IN :setNumeroExp AND SAC_Entidad_Afectada__c IN :setEntidadAfectada];
            }

            //Crear mapas con todos los datos requeridos
            if(!listaAccounts.isEmpty()){
                for(Account cuenta : listaAccounts){
                    if(!mapaAccounts.containsKey(cuenta.CC_Numero_Documento__c)){
                        mapaAccounts.put(cuenta.CC_Numero_Documento__c, cuenta);
                    }
                }
            }

            if(!listaGrupos.isEmpty()){
                for(CC_Grupo_Colaborador__c grupo : listaGrupos){
                    if(!mapaGrupos.containsKey(grupo.Name)){
                        mapaGrupos.put(grupo.Name, grupo);
                    }
                }
            }

            if(!listaCasosExpDuplicado.isEmpty()){
                for(Case caso : listaCasosExpDuplicado) {
                    String clave = caso.SPV_NumExpediente__c + '-' + caso.SAC_Entidad_Afectada__c;
                    casosExpDuplicadoMap.put(clave, caso);
                }
            }
            
            //Recorrer la lista de reclamaciones recibidas y comprobar si existe en el mapa, para añadir a una lista las no duplicadas con el fin de insertarlas en sf
            for(SPV_Reclamaciones_Integration.ListaResultado campos : listaReclamacionesRecibidas) {
                Integer empresaProcedeInt = Integer.valueOf(campos.empresaProcede);
                String clave = campos.expedienteReclamacion + '-' + apiNameEmpresaMap.get(empresaProcedeInt);

                if(!casosExpDuplicadoMap.containsKey(clave) && !casosExpNoDuplicadoMap.containsKey(clave)) {
                    listaRecRecibidasExpNoDuplicado.add(campos);

                    //Para evitar insertar reclamaciones duplicadas (mismo expediente y entidad vienen a la vez de la integración y no existen aún en el sistema sf), creamos un mapa donde añadimos la reclamacion no duplicada para posteriormente comparar que no existe ya
                    if(apiNameEmpresaMap.get(empresaProcedeInt) != null){
                        casosExpNoDuplicadoMap.put(clave, campos);
                    }
                }
            }

            //Se recorre la lista de los datos de reclamaciones que no estan duplicadas, para crear las reclamaciones con los campos requeridos
            if(!listaRecRecibidasExpNoDuplicado.isEmpty()){
                procesarReclamacionesNoDuplicadas(listaRecRecibidasExpNoDuplicado, mapaGrupos, mapaAccounts);
        	}
        	
            //Aquellas reclaciones en las que se han detectado expediente duplicado (basandose en las reclamaciones de entrada de la integración), debemos insertar los documentos oportunos y actualizar estas en determinadas casuísticas
            if(!listaCasosExpDuplicado.isEmpty()){
                procesarReclamacionesDuplicadas(listaCasosExpDuplicado);
            }

        }


    }

    public void finish(Database.BatchableContext dbc){
        System.debug('Fin del Batch');
    }

    //Método para procesar las reclamaciones no duplicadas (insercción en sf)
    public static void procesarReclamacionesNoDuplicadas(List<SPV_Reclamaciones_Integration.ListaResultado> listaRecExpNoDuplicado, Map<String, CC_Grupo_Colaborador__c> mapaGrupos, Map<String, Account> mapaAccounts){

        List<Case> listaReclamacionesInsertar = new List<Case>();       //Lista de reclamaciones que se van a través de los campos recibidos de la integración
        
        Group colaPteAsignar = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];  //grupo Pte.Asignar SPV
        
        //Se recorre esa lista y se van creando las reclamaciones con los campos requeridos
        for(SPV_Reclamaciones_Integration.ListaResultado campos : listaRecExpNoDuplicado){
            Case reclamacion = new Case();

            /*
            public String expedienteReclamacion; ------------- SPV_NumExpediente__c
            public String estado; ---------------------------  Status
            public String usuario; --------------------------- OwnerId??? Tengo puesto que se ponga pte. asignar
            public String nombreUsuario;         NO ESTA?????
            public String orgProcedencia;--------------------- SPV_Organismo__c ????????
            public String grupo;------------------------------ SEG_Grupo__c
            public String prodReclamN1;          NO ESTÁ??????        
            public String motivoReclamN1;        NO ESTÁ?????????
            public String numDocReclamante; ------------------ CC_SuppliedNIF__c-> o usarlo para obtener el account Id
            public String nomReclamante;   ------------------- AccountId?????????????
            public String idReclamacion; --------------------- Id?????????????? no se puede
            public String prodReclamaN2;	     NO ESTÁ????????
            public String prodReclamaN3;         NO ESTÁ????????
            public String motivoReclamN2;        NO ESTÁ????????
            public String tieneRectificacion;    NO ESTÁ????????
            public String empresaProcede; -------------------  SAC_Empresa__c???????????? -> entidad afectada
            public String migrada;               NO ESTÁ????????
            public String activa;                NO ESTÁ????????
            public String fechaRecepcion;--------------------- SAC_FechaRecepcion__c    
            public String fechaVencimiento; -----------------  SAC_FechaVencimientoSLA__c
            public String descProdReclamN1;      NO ESTÁ????????
            public String descProdReclamN2;      NO ESTÁ????????
            public String descProdReclamN3;      NO ESTÁ????????
            public String descMotivoReclamN1;    NO ESTÁ????????
            public String descMotivoReclamN2;    NO ESTÁ????????
            public String pdteResp;--------------NO ESTA???????
            public String pdteRevisarResp;       NO ESTÁ????????
            public String idTipo; ---------------NO ESTÁ????????
            public String reclActiva;            NO ESTÁ????????
            public String esProrroga; ------------------------- SAC_Prorrogado__c???????????????
            */
            
            /* picklist: Statu , SPV_Organismo__c, 
            Buscar:   SEG_Grupo__c
            */

            /*System.debug('Fecha');
            System.debug(campos.fechaRecepcion);
            //System.debug(Date.valueOf(campos.fechaRecepcion));

            DateTime nuevaFecha = formarDate(campos.fechaRecepcion.subString(0,4), campos.fechaRecepcion.subString(4,6), campos.fechaRecepcion.subString(6,8));
            System.debug('Fecha nueva');
            System.debug(nuevaFecha);
            System.debug(DateTime.valueOf(nuevaFecha));*/



            //Se rellenan los campos de la reclamación
            reclamacion.SPV_NumExpediente__c = (campos.expedienteReclamacion == null) ? null : campos.expedienteReclamacion;     

            //Status
            String resultadoStatus = obtenerApiPicklist('Status', campos.estado);
            reclamacion.Status = (campos.estado == null) ? null : resultadoStatus;
            
            //Username
            /*List<User> listaUsers = [SELECT Id, Name FROM User WHERE username = :campos.usuario LIMIT 1];
            User usuarioRecibido = null;
            if(!listaUsers.isEmpty()){
                usuarioRecibido= listaUsers[0];
            }
            reclamacion.ownerId = (usuarioRecibido == null) ? null : usuarioRecibido.Id;*/

            //Si se le pone Pte. Asignar como Owner:
            reclamacion.ownerId = colaPteAsignar.Id;

            //
            //Organismo
            String resultadoOrganismo = obtenerApiPicklist('SPV_Organismo__c', campos.orgProcedencia);
            reclamacion.SPV_Organismo__c = (resultadoOrganismo == null) ? null : resultadoOrganismo;


            //Grupo
            if(campos.grupo != null){
                //List<CC_Grupo_Colaborador__c> listaGrupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :campos.grupo LIMIT 1];
                CC_Grupo_Colaborador__c grupoRecibido= null;
                if(mapaGrupos.containsKey(campos.grupo)){
                    grupoRecibido = mapaGrupos.get(campos.grupo);
                }
                reclamacion.SEG_Grupo__c = (grupoRecibido == null) ? null : grupoRecibido.Id;
            }
            
            //Entidad afectada
            if(campos.empresaProcede != null){
                Integer empresaProcedeInt = Integer.valueOf(campos.empresaProcede);

                reclamacion.SAC_Entidad_Afectada__c = (apiNameEmpresaMap.get(empresaProcedeInt) != null) ? apiNameEmpresaMap.get(empresaProcedeInt) : null;
            }

            if(campos.numDocReclamante != null){
                //List<Account> listaAccount = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = :campos.numDocReclamante];
                Account accountRecibida = null;
                if(mapaAccounts.containsKey(campos.numDocReclamante)){
                    accountRecibida = mapaAccounts.get(campos.numDocReclamante);
                }
                reclamacion.AccountId = (accountRecibida == null) ? null : accountRecibida.Id;
                reclamacion.CC_SuppliedNIF__c = (accountRecibida == null) ? null : campos.numDocReclamante;
            }

            //reclamacion.AccountId = (campos.nomReclamante == null) ? null : campos.nomReclamante;
            //reclamacion.Id = (campos.idReclamacion == null) ? null : campos.idReclamacion;
            //
            //
            //
            //
            String resultadoEmpresa = obtenerApiPicklist('SAC_Empresa__c', campos.empresaProcede);
            reclamacion.SAC_Empresa__c = (campos.empresaProcede == null) ? null : resultadoEmpresa;
            //
            //
            reclamacion.SAC_FechaRecepcion__c = (campos.fechaRecepcion == null) ? null : formarDate(campos.fechaRecepcion.subString(0,4), campos.fechaRecepcion.subString(4,6), campos.fechaRecepcion.subString(6,8));
            reclamacion.SAC_FechaVencimientoSLA__c = (campos.fechaVencimiento == null) ? null : formarDate(campos.fechaRecepcion.subString(0,4), campos.fechaRecepcion.subString(4,6), campos.fechaRecepcion.subString(6,8));
            //
            //
            //
            //
            //
            reclamacion.SPV_Pendiente_Escalado__c = (campos.pdteResp == null) ? null : comprobarTrueFalse(campos.pdteResp);
            //
            //reclamacion.RecordTypeId = (campos.idTipo == null) ? RECTYPERECLAMACION : campos.idTipo;
            reclamacion.RecordTypeId = RECTYPERECLAMACION;
            //
            reclamacion.SAC_Prorrogado__c = (campos.esProrroga == null) ? null : comprobarTrueFalse(campos.esProrroga);
            
            //Se añade la nueva reclamación a la lista de reclamaciones a insertar
            // if(Test.isRunningTest()){
                reclamacion.Subject= 'SubjectTest'; //ESTE SOLO PARA LAS PRUEBAAAAASSSSSSSSSSSSSSSSS, CUANDO SE ACABE PONER LO DE ISRUNNINGTEST
            // }

            listaReclamacionesInsertar.add(reclamacion);
        }

        if(!listaReclamacionesInsertar.isEmpty()){
            SPV_DatabaseDML.insertListDML(listaReclamacionesInsertar, false);
            //Database.insert(listaReclamacionesInsertar);
        }
    }

    //Método para procesar las reclamaciones duplicadas. Insertar los documentos oportunos y actualización en determinadas casuísticas
    public static void procesarReclamacionesDuplicadas(List<Case> listaRecExpDuplicado){

        //Recorremos las reclamaciones que se han detectado un expediente duplicado
        for(Case rec : listaRecExpDuplicado){

            //Si el estado es "Pendiente respeusta organismo2, actualizamos la reclamación. En el resto de casos, se envía alerta de nueva documentación adjunta en la reclamación (alerta se envía en el SPV_ContentVersionHelper tras el insert de los adjuntos)
           // if(rec.Status == 'SPV_PendienteRespuestaOrganismos'){
				//rec.Status = 'SAC_002';
				//rec.SEG_Subestado__c = 'SPV_AnalisisComplementaria';
           // }

            //Recupera y adjunta los documentos en la reclamación
            SPV_RecuperarDocumentosController.recuperarTicketERR(rec.Id);
        }
    }

    //Método que crea un Date a partir de Strings para día, mes y año
    public static Date formarDate(String anio, String mes, String dia){
        Date fechaDevolver = Date.newInstance(Integer.valueOf(anio), Integer.valueOf(mes), Integer.valueOf(dia) );
        return fechaDevolver;
    }


    //Si el campo es boolean, si vale S/Y devuelve true, si vale N devuelve false. Si no, devuelve null
    public static Boolean comprobarTrueFalse(String valorCampo){
        if(valorCampo.equalsIgnoreCase('S') || valorCampo.equalsIgnoreCase('Y')){
            return true;
        }else{
            if(valorCampo.equalsIgnoreCase('N')){
                return false;
            }else{
                return null;
            }
        }
    }

    //El value es el API name
    public static String obtenerApiPicklist(String nombreCampo, String valorLabelABuscar){
        //mapa labelValorPicklist - Api name
        Map<String, String> mapaPicklist = new Map<String, String>();

        //Obtener la info del campo a buscar lso valores de la pickList
      /*  Map<String, Schema.SObjectField> mapaCamposCase = Schema.getGlobalDescribe().get('Case').getDescribe().Fields.getMap(); //Obtengo mapa de los campos de Case
        Schema.DescribeFieldResult fieldResult = mapaCamposCase.get(nombreCampo).getDescribe();                                 //Obtengo el campo que busco
        List<Schema.PicklistEntry> valores = fieldResult.getPickListValues();     */                                              //Obtengo los valores de la picklist de ese campo
       
        Schema.DescribeSObjectResult casoDescribe = Case.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> mapaCamposCase = casoDescribe.fields.getMap(); //Obtengo mapa de los campos de Caso
        Schema.DescribeFieldResult fieldResult = mapaCamposCase.get(nombreCampo).getDescribe();                                 //Obtengo el campo que busco
        List<Schema.PicklistEntry> valores = fieldResult.getPickListValues();         


        //Crear un mapa labelValorPicklist - Api name
        for(Schema.PicklistEntry valor : valores){
            if(!mapaPicklist.containsKey(valor.getLabel().toUpperCase())){
                mapaPicklist.put(valor.getLabel().toUpperCase(), valor.getValue());
            }
        }

        //Obtener el Api del label que se ha recibido para esa picklist
        String valorRetornar = '';
        if(!mapaPicklist.isEmpty()){
            if(mapaPicklist.containsKey(valorLabelABuscar.toUpperCase())){
                valorRetornar = mapaPicklist.get(valorLabelABuscar.toUpperCase());
            }else{
                valorRetornar = null;
            }
        }

        //Si no se ha pasado un estado válido, se pone en alta
        /*if(nombreCampo.equalsIgnoreCase('Status') && valorRetornar == null){
            valorRetornar = 'SAC_001';  
        }*/

        return valorRetornar;
    }
}