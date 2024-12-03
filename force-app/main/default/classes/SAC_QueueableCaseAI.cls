public without sharing class SAC_QueueableCaseAI implements Queueable {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();

    List<Case> listaRecOrigenEmail = new List<Case>();
    List<Case> listaCasosReglaClasif = new List<Case>();
    Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();
    static Map<Id,Case> mapCaseUpdate = new Map<Id,Case>(); //Este mapa se va a utilizar para lanzar el update de todos los casos que se recojan y se tengan que updatear en los métodos

    public SAC_QueueableCaseAI(List<Case> listaRecOrigenEmailC, List<Case> listaCasosReglaClasifC, Map<Id, Case> mapaDatosCasosActualizarC) {
        listaRecOrigenEmail = listaRecOrigenEmailC;
        listaCasosReglaClasif = listaCasosReglaClasifC;
        mapaDatosCasosActualizar = mapaDatosCasosActualizarC;
    }

    public void execute(QueueableContext context) {
        //Metodo para threadId
        if (!listaRecOrigenEmail.isEmpty()) {
            crearThreadId(listaRecOrigenEmail);
        }
        //Metodo para aplicar reglas de clasificación
        if (!listaCasosReglaClasif.isEmpty()) {
            aplicarReglaClasif(listaCasosReglaClasif);
        }
        //Updatear casos
        if (!mapCaseUpdate.isEmpty()) {
            Database.update(mapCaseUpdate.values());
        }
        //Enviar acuse recibo (debe estar despues del update, para que ya tengan un thread id añadido en el caso)
        // COMENTADO POR US995254
        // if (!listaRecOrigenEmail.isEmpty()) {
        //     //enviarAcuseRecibo(listaRecOrigenEmail, mapaDatosCasosActualizar);
        // }
    }

    /*****************************************************************
     * Proposito: Método para calcular la semilla, puesto en futuro para poder hacer update después de que se genere el Id del caso.
     *            Mandamos el acuse de recibo una vez tenemos este valor.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR               DATE         Description
     * 1.0            US498472         Esperanza Conde      04/01/23     Creación
     *                                 Jose Carlos Blanco
     * 1.1            US723742         Raúl Santos          05/03/24     Modificación: debido a que se updatea el campo CC_AcuseRecibo__c antes de enviar el email del acuse de recibo
     *                                                                                 y es en el momento del envio del acuse cuando se comprueba si se debe enviar el email o no (dependiendo
     *                                                                                 si el email está en la blackList). Se añade aquí la comprobación de que el email asociado al caso esta o no
     *                                                                                 en la blackList. Si está en la blackList no updateo el campo CC_AcuseRecibo__c a valor 2 (porque no se enviará
     *                                                                                 el acuse de recibo). En caso de no estar el email del caso en la blackList, se update el campo CC_AcuseRecibo__c a
     *                                                                                 valor 2 (porque se enviará el acuse de recibo)
    *****************************************************************/
    public static void crearThreadId(List<Case> listNewCase) {
        List<Case> lstUpdateCase = new List<Case>();

        //Recupero los emails no validos de envio (emails en la blackList)
        // List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        for (Case caso : listNewCase) {
            Case casoNew = new case();
            String threadId;
            String casoID = caso.Id;
            casoNew.Id = casoID;
            threadId = SAC_Utils.creacionThreadID(casoID);
            casoNew.CC_SuppliedID__c = threadId;

            //COMENTADO VERSION 1.1 POR US994116
            //Compruebo la direcciones de envio con las de la blackList
            // List<String> listaDireccionesPara = new List<String>{ caso.SuppliedEmail };
            // List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);
            // if(!emailsValidos.isEmpty()){
            //     casoNew.CC_AcuseRecibo__c = '2';
            // }
            
            lstUpdateCase.add(casoNew);
        }

        if (!lstUpdateCase.isEmpty()) {
            addCasosAMapaUpdatear(lstUpdateCase);
        }
    }

    /*****************************************************************
     * Proposito: Método para añadir los cambios de estado y otros campos en los casos que se insertan con
     * una regla de clasificación añadida. Posteriormente, lo añade a una lista para updatear
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR               DATE         Description
     * 1.0                             CS                   20/04/23     Creación
    *****************************************************************/
    public static void aplicarReglaClasif(List<Case> listaCasosReglaClasif) {
        List<Case> listaUpdatearCasosReglas = new List<Case>();
        Set<Id> setIdsReglasClasif = new Set<Id>();
        //Añadir las ids de las reglas de clasificación a un set para buscarlas por query
        for (Case caso : listaCasosReglaClasif) {
            setIdsReglasClasif.add(caso.OS_ReglaUtilizada__c);
        }

        List<SEG_Regladeclasificacion__c> listaReglasClasif = [SELECT Id, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.OS_EstadoCaso__c, SEG_ClasificacionRapida__r.SAC_MotivoRechazo__c,
                                                                SEG_ClasificacionRapida__r.SAC_MotivoDescarte__c
                                                                FROM SEG_Regladeclasificacion__c 
                                                                WHERE Id IN :setIdsReglasClasif];
                                                                
        //Si la lista de reglas no está vacía, pasamos la lista a mapa y recorremos los casos que tienen una regla de clasificación para aplicarle los valores de la clasificación rápida de dicha regla.
        if (!listaReglasClasif.isEmpty()) {
            Map<Id, SEG_Regladeclasificacion__c> mapaReglasClasif = new Map<Id, SEG_Regladeclasificacion__c>(listaReglasClasif);
            for (Case casoConRegla : listaCasosReglaClasif) {
                Case casoConReglaNew = new Case();
                casoConReglaNew.Id = casoConRegla.Id;
                //Boolean para indicar que este caso debe actualizarse solo si se produce algun cambio en alguno de los campos
                Boolean updatearCaso = false;
                //Si el mapa de reglas contiene la regla del caso, le aplicamos los valores a los campos del caso
                if (mapaReglasClasif.containsKey(casoConRegla.OS_ReglaUtilizada__c)) {
                    //Comprobamos que cada valor esta relleno y no es nulo
                    if (String.isNotBlank(mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.OS_EstadoCaso__c)) {
                        casoConReglaNew.Status = mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.OS_EstadoCaso__c;
                        casoConReglaNew.SAC_StatusAuxiliar__c = mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.OS_EstadoCaso__c;
                        updatearCaso = true;
                    }
                    if (String.isNotBlank(mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.SAC_MotivoRechazo__c)) {
                        casoConReglaNew.SAC_MotivoRechazo__c = mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.SAC_MotivoRechazo__c;
                        updatearCaso = true;
                    }
                    if (String.isNotBlank(mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.SAC_MotivoDescarte__c)) {
                        casoConReglaNew.SAC_MotivoDescarte__c = mapaReglasClasif.get(casoConRegla.OS_ReglaUtilizada__c).SEG_ClasificacionRapida__r.SAC_MotivoDescarte__c;
                        updatearCaso = true;
                    }
                }
                //Si el caso debe actualizarse, se añade al mapa para retornar casos a actualizar
                if (updatearCaso) {
                    listaUpdatearCasosReglas.add(casoConReglaNew);
                }
            }
        }

        if (!listaUpdatearCasosReglas.isEmpty()) {
            addCasosAMapaUpdatear(listaUpdatearCasosReglas);    
        }
    }

    public static void enviarAcuseRecibo(List<Case> listNewCase, Map<Id, Case> mapaDatosCasosActualizar) {
        //Filtrar los casos para que no se mande acuse de recibo a los que sean copias generadas masivamente (campo SAC_CasoRelacionado__c relleno)
        List<Case> listNewCaseFiltrada = new List<Case>();
        for (Case cs : listNewCase) {
            if (String.isBlank(cs.SAC_CasoRelacionado__c)) {
                listNewCaseFiltrada.add(cs);
            }
        }
        SAC_AcuseRecibo_Email.envioAcuseRecibo(listNewCaseFiltrada, mapaDatosCasosActualizar);
    }

    public static void addCasosAMapaUpdatear(List<Case> listaCasosUpdatear) {
        for (Case casoUpdatear : listaCasosUpdatear) {
            if (mapCaseUpdate.containsKey(casoUpdatear.Id)) {
                // Obtener el caso correspondiente del mapa
                Case casoEnMapa = mapCaseUpdate.get(casoUpdatear.Id);

                // Obtener los campos rellenos del caso a actualizar
                Map<String, Object> camposRellenos = casoUpdatear.getPopulatedFieldsAsMap();

                // Iterar sobre los campos rellenos y agregar los valores al caso en el mapa
                for (String campo : camposRellenos.keySet()) {
                    casoEnMapa.put(campo, camposRellenos.get(campo));
                }

                // Actualizar el caso en el mapa
                mapCaseUpdate.put(casoUpdatear.Id, casoEnMapa);
            } else {
                mapCaseUpdate.put(casoUpdatear.Id, casoUpdatear);
            }
        }
    }
}