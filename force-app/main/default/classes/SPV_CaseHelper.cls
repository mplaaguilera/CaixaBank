/**
*   @description SPV_CaseHelper
*/
public with sharing class SPV_CaseHelper {
    
    public class SPVException extends Exception {}

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'CC_Grupo_Colaborador__c','SAC_Interaccion__c', 'Account', 'SAC_ImagenDocumento__c', 'CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEACCIONMAESTRO = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEGRUPOPROVEEDOR = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPEGRUPOLETRADO = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPEGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPECASEEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();

    //Obtener el record type de los no clientes
    private static final Id RECTYPENOCLIENTE = mapRTsObjects.get('Account').get('SAC_NoCliente_PA').getRecordTypeId();

    //RT del objeto intermedio reclamación-oficinas afectadas
    private static final Id RECTYPEOFICINAS = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SPV_OficinaAfectada').getRecordTypeId();

    private static final String ORIGEN_CNMV = 'SPV_CNMV';
    private static final String ORIGEN_DGS = 'SPV_DGS';
    private static final String ORIGEN_CONSUMO = 'SPV_Consumo'; 
    private static final String ORIGEN_BDE = 'SPV_BDE'; 
    private static final String GRUPOLET_FYRLEGAL = 'SPV_FYRLEGALLETRADO'; 
    private static final String GRUPOLET_INDRA = 'SPV_INDRALETRADO'; 



    /*****************************************************************
     * Proposito: Filtrar los casos entrantes para quedarnos únicamente con los de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    /**
	 * @description    Filtrar los casos entrantes para quedarnos únicamente con los de SPV
	 * @param lstCasos 
	 */
    public static List<Case> filtrarCasosSPV(List<Case> lstCasos) {

        List<Case> casosSPV = new List<Case>();

        for (Case caso : lstCasos) {
            if (caso.RecordTypeId == RECTYPERECLAMACION || caso.RecordTypeId == RECTYPEPRETENSION) {
                casosSPV.add(caso);
            }
        }
        
        return casosSPV;
    }

    /*****************************************************************
	 * Proposito: Método que comprueba si un Caso ha cambiado de Account y Contact y crea
	 * un registro en el objeto reclamante en caso de que así sea.
	 *  
	 * Historial
	 * -------
	 * VERSION        USER_STORY       AUTHOR         DATE         Description
	 * 1.0              ---          Carlos Gómez   12/06/24     Creación
	 *****************************************************************/
        /**
	 * @description    Método que comprueba si un Caso ha cambiado de Account y Contact y crea
	 * un registro en el objeto reclamante en caso de que así sea.
	 * @param listNewObj
     * @param mapOldObj
	 */
    public static void createReclamanteRecord(List<Case> listNewObj, Map<Id, Case> mapOldObj) {

        List<Case> listaCasosReclamante = new List<Case>();
		List<SAC_CaseReclamante__c> reclamantesAInsertar = new List<SAC_CaseReclamante__c> ();
		Map<String, Id> mapReclamantes = new Map<String, Id> ();

        for(Case caso :listNewObj){
            if((mapOldObj == null && caso.AccountId != null) || 
                (mapOldObj != null && mapOldObj.containsKey(caso.Id) && caso.AccountId != mapOldObj.get(caso.Id).AccountId)){
                listaCasosReclamante.add(caso);
            }
        }

        if(!listaCasosReclamante.isEmpty()){

            if (!Schema.sObjectType.SAC_CaseReclamante__c.isCreateable() || !Schema.sObjectType.SAC_CaseReclamante__c.isUpdateable() || !Schema.sObjectType.Case.isAccessible()) {
                return;
            }

            List<SAC_CaseReclamante__c> reclamantesTotal = [SELECT Id, SAC_Case__c, SAC_Account__c, SAC_Contact__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c in(SELECT Id FROM Case WHERE Id IN :listaCasosReclamante)];
            for (SAC_CaseReclamante__c tReclamantes : reclamantesTotal) {
                mapReclamantes.put(String.valueOf(tReclamantes.SAC_Case__c) + String.valueOf(tReclamantes.SAC_Account__c) + String.valueOf(tReclamantes.SAC_Contact__c), tReclamantes.Id);
            }
            Set<Id> sCasos = new Set<Id> ();

            //Si el mapa viene sin informar, estamos en un "insert"
            if (mapOldObj == null && !listaCasosReclamante.isEmpty()) {
                for (Case casoNuevo : listaCasosReclamante) {
                    Boolean cuentaInformada = String.isNotBlank(casoNuevo.AccountId);
                    if ((casoNuevo.RecordTypeId == RECTYPERECLAMACION) && cuentaInformada) {
                        SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c(SAC_Account__c = casoNuevo.AccountId,
                                                                                    SAC_Contact__c = casoNuevo.ContactId,
                                                                                    SAC_Case__c = casoNuevo.Id,
                                                                                    SAC_ReclamantePrincipal__c = true,
                                                                                    Id = mapReclamantes.get(String.valueOf(casoNuevo.Id) + String.valueOf(casoNuevo.AccountId) + String.valueOf(casoNuevo.ContactId)));
                        reclamantesAInsertar.add(reclamante);
                        sCasos.add(casoNuevo.Id);
                    }
                }
            }else if (!listaCasosReclamante.isEmpty() && mapOldObj != null) {//Si el mapa no viene a nulo, estamos en un update
                for (Case casoNuevo : listaCasosReclamante) {
                    Boolean cuentaInformada = String.isNotBlank(casoNuevo.AccountId);
                    if ((casoNuevo.RecordTypeId == RECTYPERECLAMACION)&& cuentaInformada && mapOldObj.get(casoNuevo.Id).AccountId != casoNuevo.AccountId) {
                        SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c(SAC_Account__c = casoNuevo.AccountId,
                                                                                    SAC_Contact__c = casoNuevo.ContactId,
                                                                                    SAC_Case__c = casoNuevo.Id,
                                                                                    SAC_ReclamantePrincipal__c = true,
                                                                                    Id = mapReclamantes.get(String.valueOf(casoNuevo.Id) + String.valueOf(casoNuevo.AccountId) + String.valueOf(casoNuevo.ContactId)));
                        reclamantesAInsertar.add(reclamante);
                        sCasos.add(casoNuevo.Id);
                    }
                }
            }

            List<SAC_CaseReclamante__c> reclamantes = new List<SAC_CaseReclamante__c>();
            List<SAC_CaseReclamante__c> reclamantesAModificar = [SELECT Id, SAC_Account__c, SAC_Contact__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_ReclamantePrincipal__c = true AND SAC_Case__c in :sCasos AND Id not in :reclamantesAInsertar];
            for (SAC_CaseReclamante__c reclamante : reclamantesAModificar) {
                reclamante.SAC_ReclamantePrincipal__c = false;
            }

            reclamantes.addAll(reclamantesAModificar);
            reclamantes.addAll(reclamantesAInsertar);
            
            if (!reclamantes.isEmpty()) {
                SPV_DatabaseDML.upsertListDML(reclamantes, false);
            }
        
        
        
        }
        

		
	}

    /************************************************************************************************************
     * Proposito:  Cuando se actualiza el importe de una pretensión, se calculará el de la reclamación padre
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                   US963386       Álex Polo          28/08/2024               Creación
     * *********************************************************************************************************/
            /**
	 * @description    Cuando se actualiza el importe de una pretensión, se calculará el de la reclamación padre
	 * @param listaCasosSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
	 */
     public static void calcular(List<Case> listaCasosSPV, Map<Id, Case> mapOldObj, Map<Id,Case> mapaDatosCasosActualizar) {
 

         Set<Id> setIdesRec = new Set<Id>();
         List<Case> listaPretensionesActualizadas = new List<Case>();
         List<Case> listReclaUpdatear = new List<Case> ();
         Map<Id, List<Case>> mapListPretensiones = new Map<Id, List<Case>> ();

         //Obtener las pretensiones que hayan cambiado su importe abonado
        for(Case caso : listaCasosSPV){
            if(caso.RecordTypeId == RECTYPEPRETENSION){
                if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).CC_Importe_Abonado__c != caso.CC_Importe_Abonado__c){
                    listaPretensionesActualizadas.add(caso);
                }

            }
        }

        //Obtener un set de Ids con los Id de las reclamaciones a las que corresponden las pretensiones actualizadas
        if(!listaPretensionesActualizadas.isEmpty()){
            for(Case pretension : listaPretensionesActualizadas){
                setIdesRec.add(pretension.SAC_Reclamacion__C);
            }
        }

        //Obtener todas las pretensiones hermanas de cada reclamación
        List<Case> listaTodasLasPretensiones = [SELECT Id, CC_Importe_Reclamado__c, SAC_Reclamacion__c, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c, SAC_Quebranto__c FROM Case WHERE SAC_Reclamacion__c IN :setIdesRec];

        //Se crea un mapa en el que para cada id de la reclamación, se almacena sus pretensiones 
        for (Id ide : setIdesRec) {
            mapListPretensiones.put(ide, new List<Case>());
        }


        if(!listaTodasLasPretensiones.isEmpty()){
            for(Case pretension : listaTodasLasPretensiones){
                if(mapListPretensiones.containsKey(pretension.SAC_Reclamacion__c)){
                    /*Case pretensionDeReclamacion = new Case ();
                    pretensionDeReclamacion.Id = pretension.Id;
                    pretensionDeReclamacion.CC_Importe_Reclamado__c = pretension.CC_Importe_Reclamado__c;*/
                    mapListPretensiones.get(pretension.SAC_Reclamacion__C).add(pretension);
                }
            }
        }


   
        if(!mapListPretensiones.isEmpty()){
            listReclaUpdatear = calcularImporte(mapListPretensiones);
        }

        

        //Se añaden las reclamaciones a actualizar al mapa de datos a actualizar del trigger 
        for (Case caso : listReclaUpdatear) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).CC_Importe_Reclamado__c = caso.CC_Importe_Reclamado__c;
                mapaDatosCasosActualizar.get(caso.id).CC_Importe_Abonado__c = caso.CC_Importe_Abonado__c;
            }else{
                Case reclamacion = new Case();
                reclamacion.id = caso.id;
                reclamacion.CC_Importe_Abonado__c = caso.CC_Importe_Abonado__c;
                reclamacion.CC_Importe_Reclamado__c = caso.CC_Importe_Reclamado__c;
                mapaDatosCasosActualizar.put(caso.id, reclamacion);
            }
        }

 
     }

    /************************************************************************************************************
     * Proposito:  Al añadir una pretensión, se arrastran los datos del reclamante de la reclamación a las
     * pretensiones añadidas. También al actualizar el accountId de la pretensión es necesario actuaalizar los
     * campos correspondientes
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                                  Álex Polo            22/10/2024               Creación
     * *********************************************************************************************************/
    /**
	 * @description    Al añadir una pretensión, se arrastran los datos del reclamante de la reclamación a las
     * pretensiones añadidas.
	 * @param listCasosSPV
     * @param mapOldObj
     * @param mapNewObj
	 */
     public static void arrastrarReclamantePretension(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj){
        
        List<Case> listapretensiones = new List<Case>();
        Set<Id> idsReclamacionesPadre = new Set<Id>();
        Map<Id, List<Case>> mapListPretensiones = new Map<Id, List<Case>>();    //Mapa donde se relaciona clave: id reclamación con su lista de pretensiones
        List<Case> listaReclamaciones = new List<Case>();

        for(Case caso : listCasosSPV){

            //Si es before insert, entra por el if
            if(mapOldObj.isEmpty()){
               
                if(caso.RecordTypeId == RECTYPEPRETENSION){
                    listapretensiones.add(caso);
                    idsReclamacionesPadre.add(caso.SAC_Reclamacion__c);
                    
                    //Se añade al mapa la pretensión
                    if(mapListPretensiones.containsKey(caso.SAC_Reclamacion__c)){
                      
                        mapListPretensiones.get(caso.SAC_Reclamacion__C).add(caso);
                    }else{
                        
                        mapListPretensiones.put(caso.SAC_Reclamacion__c, new List<Case>());
                        mapListPretensiones.get(caso.SAC_Reclamacion__C).add(caso);
                    }
                }
            }else{      //Entra por el else si es before update
              
                if(caso.RecordTypeId ==  RECTYPEPRETENSION  && mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).AccountId != caso.AccountId)){
                    listaPretensiones.add(caso);
                    idsReclamacionesPadre.add(caso.SAC_Reclamacion__c);
                    
                    //Se añade al mapa la pretensión
                    if(mapListPretensiones.containsKey(caso.SAC_Reclamacion__c)){
                    
                        mapListPretensiones.get(caso.SAC_Reclamacion__C).add(caso);
                    }else{
                        
                        mapListPretensiones.put(caso.SAC_Reclamacion__c, new List<Case>());
                        mapListPretensiones.get(caso.SAC_Reclamacion__C).add(caso);
                    }
    
                }
            }

           
        }


        //Se obtienen las reclamaciones con los campos de reclamante que se van a asignar a las pretensiones
        if(!idsReclamacionesPadre.isEmpty()){

            listaReclamaciones = [SELECT Id, AccountId, CC_SuppliedNIF__c, ContactId, SAC_UsarDatos__c, OS_Email__c,  CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c 
            FROM Case WHERE Id IN :idsReclamacionesPadre];

        }


     
        if(!listaReclamaciones.isEmpty()){

            //Se recorren las reclamaciones para a sus pretensiones darles su valor de los campos del reclamante correspondientes
            for(Case reclamacion : listaReclamaciones){
                if(mapListPretensiones.containsKey(reclamacion.Id)){
                    for(Case pretension : mapListPretensiones.get(reclamacion.Id)){
                        
                        pretension.AccountId = reclamacion.AccountId;
                        pretension.CC_SuppliedNIF__c = reclamacion.CC_SuppliedNIF__c;
                        pretension.ContactId = reclamacion.ContactId;
                        pretension.SAC_UsarDatos__c = reclamacion.SAC_UsarDatos__c;
                        pretension.OS_Email__c = reclamacion.OS_Email__c;
                        pretension.CC_Telefono_Contacto__c = reclamacion.CC_Telefono_Contacto__c;
                        pretension.SAC_DireccionPostalNotificacion__c = reclamacion.SAC_DireccionPostalNotificacion__c;
                     
                    }
                }
            }
        }

     }



    /************************************************************************************************************
     * Proposito:  Al actualizar alguno de los datos del reclamante en la reclamación, se deben actualizar de sus 
     * pretensiones
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                                  Álex Polo            22/10/2024               Creación
     * *********************************************************************************************************/
    /**
	 * @description    Al actualizar alguno de los datos del reclamante en la reclamación, se deben actualizar de sus 
     * pretensiones
	 * @param listaReclaSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
	 */
    public static void actualizarDatosReclamantePretensiones(List<Case> listaReclaSPV, Map<Id, Case> mapOldObj, Map<Id,Case> mapaDatosCasosActualizar){

        List<Case> listaPretensiones = new List<Case>();
        Set<Id> idsReclamaciones = new Set<Id>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();

        for(Case recla : listaReclaSPV){
            //Si ha cambiado alguno de estos campos de la reclamación, habrá que actualizar sus valores en las pretensiones


            if(mapOldObj.containsKey(recla.Id) && (recla.AccountId != mapOldObj.get(recla.Id).AccountId || recla.CC_SuppliedNIF__c != mapOldObj.get(recla.Id).CC_SuppliedNIF__c || recla.ContactId != mapOldObj.get(recla.Id).ContactId
            || recla.SAC_UsarDatos__c != mapOldObj.get(recla.Id).SAC_UsarDatos__c || recla.OS_Email__c != mapOldObj.get(recla.Id).OS_Email__c || recla.CC_Telefono_Contacto__c != mapOldObj.get(recla.Id).CC_Telefono_Contacto__c 
            || recla.SAC_DireccionPostalNotificacion__c != mapOldObj.get(recla.Id).SAC_DireccionPostalNotificacion__c )){


                idsReclamaciones.add(recla.id);
                if(!mapaReclamaciones.containsKey(recla.Id)){
                    mapaReclamaciones.put(recla.Id, recla);
                }

            }
        }


        //Se obtienen las pretensiones de las reclamaciones que cumplen esas condiciones anteriores
        if(!idsReclamaciones.isEmpty()){
            listaPretensiones = [SELECT Id, AccountId, CC_SuppliedNIF__c, ContactId, SAC_UsarDatos__c, OS_Email__c,  CC_Telefono_Contacto__c, SAC_DireccionPostalNotificacion__c, SAC_Reclamacion__c
                                FROM Case WHERE SAC_Reclamacion__c IN :idsReclamaciones];
        }

        //Actualizar los datos de cada pretensión
        if(!listaPretensiones.isEmpty()){

            for(Case pretension : listaPretensiones){
                //Se comprueba que su reclamación padre esté en el mapa de reclamaciones que haya cambiado algún dato a tratar
                if(mapaReclamaciones.containsKey(pretension.SAC_Reclamacion__c)){
                    
                    if(!mapaDatosCasosActualizar.containsKey(pretension.Id)){
                        pretension.AccountId = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).AccountId;
                        pretension.CC_SuppliedNIF__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_SuppliedNIF__c;
                        pretension.ContactId = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).ContactId;
                        pretension.SAC_UsarDatos__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SAC_UsarDatos__c;
                        pretension.OS_Email__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).OS_Email__c;
                        pretension.CC_Telefono_Contacto__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_Telefono_Contacto__c;
                        pretension.SAC_DireccionPostalNotificacion__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SAC_DireccionPostalNotificacion__c;
                        mapaDatosCasosActualizar.put(pretension.Id, pretension);
                    }else{
                        //Si la pretensión ya está en el mapa de datos a actualizar, se actualiza desde ahí
                        mapaDatosCasosActualizar.get(pretension.Id).AccountId = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).AccountId;
                        mapaDatosCasosActualizar.get(pretension.Id).CC_SuppliedNIF__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_SuppliedNIF__c;
                        mapaDatosCasosActualizar.get(pretension.Id).ContactId = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).ContactId;
                        mapaDatosCasosActualizar.get(pretension.Id).SAC_UsarDatos__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SAC_UsarDatos__c;
                        mapaDatosCasosActualizar.get(pretension.Id).OS_Email__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).OS_Email__c;
                        mapaDatosCasosActualizar.get(pretension.Id).CC_Telefono_Contacto__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_Telefono_Contacto__c;
                        mapaDatosCasosActualizar.get(pretension.Id).SAC_DireccionPostalNotificacion__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SAC_DireccionPostalNotificacion__c;
                    }
                }
            }
        }





     }


    /************************************************************************************************************
     * Proposito:  Al asociar un AccountId (o actualizarlo) a una reclamación, se rellenan los campos DAN y
     * Dirección Territorial (DT)
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                   US963386       Álex Polo          29/08/2024               Creación
     * *********************************************************************************************************/
        /**
	 * @description    Al asociar un AccountId (o actualizarlo) a una reclamación, se rellenan los campos DAN y
     * Dirección Territorial (DT)
	 * @param listCasosSPV
     * @param mapOldObj
     * @param mapNewObj
	 */
     public static void asignarDTyDAN(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj){

        List<Case> listaReclamacionesCambiaAccount = new List<Case>();
        Set <Id> setIdsAccounts = new Set<Id>();
       

        //Obtener las reclamaciones que hayan cambiado de accountId
        //Además, almaceno los IDs de las Account nuevas

        if(mapOldObj.isEmpty()){    //Si el mapa Old está vacío, es porque viene de Insert
            for(Case caso : listCasosSPV){
                if(caso.RecordTypeId == RECTYPERECLAMACION){
                     listaReclamacionesCambiaAccount.add(caso);
                        if(caso.AccountId != null){
                            setIdsAccounts.add(caso.AccountId);
                        }
                    
                }
            }
        }else{                      //Si no stá vacío el mapa Old, es porque viene de Update
            for(Case caso : listCasosSPV){
                if(caso.RecordTypeId == RECTYPERECLAMACION){
                    if(mapOldObj.containsKey(caso.Id) && caso.AccountId != mapOldObj.get(caso.Id).AccountId){
                     listaReclamacionesCambiaAccount.add(caso);
                        if(caso.AccountId != null){
                            setIdsAccounts.add(caso.AccountId);
                        }
                    }
                }
            }
        }

    

      
        Map<Id,Account> mapAccount = new Map<Id, Account>();

  
        //Se obtendrán las Account necesarias
        if(!setIdsAccounts.isEmpty()){
            mapAccount = new Map<Id, Account>([SELECT Id, CC_Email__c,Name, CC_NumPerso__c,CC_Tipo_Centro__c,AV_OficinaPrincipal__c, CC_Numero_Documento__c, CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c,
            CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId, AV_OficinaPrincipal__r.CC_Tipo_Centro__c, AV_OficinaPrincipal__r.Parent.CC_Tipo_Centro__c, AV_OficinaPrincipal__r.Parent.Parent.CC_Tipo_Centro__c,
            AV_OficinaPrincipal__r.Parent.Parent.Parent.CC_Tipo_Centro__c, AV_OficinaPrincipal__r.ParentId, AV_OficinaPrincipal__r.Parent.ParentId, AV_OficinaPrincipal__r.Parent.Parent.ParentId 
            FROM Account WHERE Id IN :setIdsAccounts]);
        }

        //Se asigna a cada reclamación el DAN y DT correspondiente
        if(!listaReclamacionesCambiaAccount.isEmpty() && !mapAccount.isEmpty()){
            for(Case reclamacion : listaReclamacionesCambiaAccount){

                //Añadir el DAN   
                if(mapAccount.containsKey(reclamacion.AccountId) && mapAccount.get(reclamacion.AccountId).CC_OficinaGestoraId__c != null){
                    reclamacion.CC_DAN__c = mapAccount.get(reclamacion.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c;
                }

                //Añadir DT (Direccion territorial)
                if(mapAccount.containsKey(reclamacion.AccountId)){
                    //En función de si la cuenta asociada, o alguna de sus padres tiene tipo Centro = DT, se pone valor de dirección territorial del ID de la cuenta que lo tenga (Ya sea la asociada o alguno de sus padres)
                    if(mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r?.CC_Tipo_Centro__c == 'DT'){ reclamacion.CC_Direccion_Territorial__c = mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__c;
                    }else if(mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r?.Parent?.CC_Tipo_Centro__c == 'DT'){ reclamacion.CC_Direccion_Territorial__c = mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r.ParentId;
                    }else if(mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r?.Parent?.Parent?.CC_Tipo_Centro__c == 'DT'){ reclamacion.CC_Direccion_Territorial__c = mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r.Parent.ParentId;
                    }else if(mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r?.Parent?.Parent?.Parent?.CC_Tipo_Centro__c == 'DT'){reclamacion.CC_Direccion_Territorial__c = mapAccount.get(reclamacion.AccountId).AV_OficinaPrincipal__r.Parent.Parent.ParentId;
                    }
                }
        

            }
        }
    

     }
   




    /*****************************************************************
     * Proposito: Cuando alguno de los campos del representante cambia, se comprueba primero si el check 'usar los datos de ALF' está activo.
     * Si es así, se traen los datos del Account de el caso. Si el email, la direccion postal o el teléfono del representante estan informados
     * con el check de usar datos de alf en false, se traen los valores a los campos de datos de contacto de la reclamación
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US997670        Álex Polo      30/08/24      
    *****************************************************************/
    /**
	 * @description    Cuando alguno de los campos del representante cambia,, se realizan comprobaciones
	 * @param listaCasosSPV
     * @param mapOldObj
	 */
    public static void camposRepresentanteValido(List<Case> listaCasosSPV, Map<Id, Case> mapOldObj) {

        List<Case> listaCasosSelect = new List<Case>();
        List<Case> listaRecRepresentanteValido = new List<Case>();
    
        for(Case caso : listaCasosSPV){
            if(caso.recordTypeId == RECTYPERECLAMACION){
                if ((mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_EmailRepresentante__c != caso.SAC_EmailRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionPostal__c != caso.SAC_DireccionPostal__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_UsarDatos__c != caso.SAC_UsarDatos__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NombreRepresentante__c != caso.SAC_NombreRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeRepresentante__c != caso.SAC_TipoDeRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TipoDeDocumento__c != caso.SAC_TipoDeDocumento__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DespachoRepresentante__c != caso.SAC_DespachoRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_NumeroDelDocumento__c != caso.SAC_NumeroDelDocumento__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_TelefonoRepresentante__c != caso.SAC_TelefonoRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_DireccionRepresentante__c != caso.SAC_DireccionRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_CodigoPostalRepresentante__c != caso.SAC_CodigoPostalRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PoblacionRepresentante__c != caso.SAC_PoblacionRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_ProvinciaRepresentante__c != caso.SAC_ProvinciaRepresentante__c) ||
                (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PaisRepresentante__c != caso.SAC_PaisRepresentante__c) 
                ) {
                    listaRecRepresentanteValido.add(caso);
                  }
    
            }
           
        }
          
        
        if(!listaRecRepresentanteValido.isEmpty()){
    
            listaCasosSelect= [SELECT Id, SAC_Reclamacion__c, Status, RecordTypeId, SEG_Detalle__c,subject, ownerId, AccountId, SEG_Grupo__c, 
            isClosed, SAC_TiempoSLALetradoAlta__c, SAC_SentidoResolucion__c, CC_Canal_Procedencia__c, CC_MCC_Tematica__c,
            CC_MCC_ProdServ__c, CC_MCC_Motivo__c, Account.PersonEmail, Account.BillingStreet, Account.BillingPostalCode, 
            Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.Phone, Account.PersonMobilePhone,
            Account.Name, SEG_Detalle__r.SAC_esGGH__c, SAC_ImpReclamadoGestoria__c, SAC_ImpReclamadoInteresesLegales__c, SAC_TAE__c,
            SAC_ImpReclamadoNotaria__c, SAC_ImpReclamadoRegistros__c, SAC_ImpReclamadoTasacion__c, CaseNumber, SAC_Entidad_Afectada__c,
            SAC_MotivoVXC__c, SAC_Negocio__c, SAC_TipoContingenciaPrestacion__c, SAC_Reclamacion__r.ownerId, SAC_Motivo_BDE__c,
            SAC_FamiliaBdE__c, SAC_ProductoBDE__c, SAC_DGS__c, SAC_Producto2BdE__c, SAC_MotivoReclamacion__c, SAC_AgrupacionesFamilias__c,
            SAC_ServicioInversion__c, SAC_EntidadProductora__c, OS_Fecha_Resolucion__c, SEG_Grupo__r.SAC_Email__c, SAC_CasoNegociado__c, SAC_FamiliaMotivoBdE__c, SAC_DetenidoHasta__c
            FROM Case 
            WHERE Id IN :listaRecRepresentanteValido];
        }
    
            Map<Id, Case> mapaCasosSelect = new Map<Id, Case>(listaCasosSelect);
            for (Case caso : listaRecRepresentanteValido) {
                //Si el check de ALF está activo, traemos los datos del Account
                if (mapaCasosSelect.containsKey(caso.Id) && caso.SAC_UsarDatos__c) {
                    caso.OS_Email__c = mapaCasosSelect.get(caso.Id).Account.PersonEmail;
                    //Traer datos teléfono
                    if (mapaCasosSelect.containsKey(caso.Id) && String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.Phone)) {
                        caso.CC_Telefono_Contacto__c = mapaCasosSelect.get(caso.Id).Account.Phone;
                    } else if (mapaCasosSelect.containsKey(caso.Id) && String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.PersonMobilePhone)) {
                        caso.CC_Telefono_Contacto__c = mapaCasosSelect.get(caso.Id).Account.PersonMobilePhone;
                    } else {
                        caso.CC_Telefono_Contacto__c = null;
                    }
                    //Rellenar la dirección
                    String direccion;
                    String d;
                    String cp;
                    String poblacion;
                    String provincia;
                    String pais;
                    if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingStreet)) {
                        direccion = mapaCasosSelect.get(caso.Id).Account.BillingStreet;
                        d = mapaCasosSelect.get(caso.Id).Account.BillingStreet;
                    }
                    if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingPostalCode)) {
                        if (String.isNotBlank(direccion)) {
                            direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingPostalCode;
                        } else {
                            direccion = mapaCasosSelect.get(caso.Id).Account.BillingPostalCode;
                        }
                        cp = mapaCasosSelect.get(caso.Id).Account.BillingPostalCode;
                    }
                    if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingCity)) {
                        if (String.isNotBlank(direccion)) {
                            direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingCity;
                        } else {
                            direccion = mapaCasosSelect.get(caso.Id).Account.BillingCity;
                        }
                        poblacion = mapaCasosSelect.get(caso.Id).Account.BillingCity;
                    }
                    if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingState)) {
                        if (String.isNotBlank(direccion)) {
                            direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingState;
                        } else {
                            direccion = mapaCasosSelect.get(caso.Id).Account.BillingState;
                        }
                        provincia = mapaCasosSelect.get(caso.Id).Account.BillingState;
                    }
                    if (String.isNotBlank(mapaCasosSelect.get(caso.Id).Account.BillingCountry)) {
                        if (String.isNotBlank(direccion)) {
                            direccion = direccion + ', ' + mapaCasosSelect.get(caso.Id).Account.BillingCountry;
                        } else {
                            direccion = mapaCasosSelect.get(caso.Id).Account.BillingCountry;
                        }
                        pais = mapaCasosSelect.get(caso.Id).Account.BillingCountry;
                    }
                    caso.SAC_DireccionPostalNotificacion__c = direccion;
    
                    caso.SAC_DireccionContacto__c = d;
                    caso.SAC_CodigoPostalContacto__c = cp;
                    caso.SAC_PoblacionContacto__c = poblacion;
                    caso.SAC_ProvinciaContacto__c = provincia;
                    caso.SAC_PaisContacto__c = pais;
    
                    //Rellenar nombre del contacto
                    caso.SAC_NombreContacto__c = mapaCasosSelect.get(caso.Id).Account.Name;
                } else {
                    caso.OS_Email__c = null;
                    caso.CC_Telefono_Contacto__c = null;
                    caso.SAC_DireccionPostalNotificacion__c = null;
                    caso.SAC_NombreContacto__c = null;
                    caso.SAC_DireccionContacto__c = null;
                    caso.SAC_CodigoPostalContacto__c = null;
                    caso.SAC_PoblacionContacto__c = null;
                    caso.SAC_ProvinciaContacto__c = null;
                    caso.SAC_PaisContacto__c = null;
                }
                //Si alguno de los campos del representante está informado, hay que empezar con las validaciones
                if (String.isNotBlank(caso.SAC_TipoDeRepresentante__c) || String.isNotBlank(caso.SAC_TipoDeDocumento__c) || String.isNotBlank(caso.SAC_NombreRepresentante__c) ||
                    String.isNotBlank(caso.SAC_EmailRepresentante__c) || String.isNotBlank(caso.SAC_DespachoRepresentante__c) || String.isNotBlank(caso.SAC_NumeroDelDocumento__c) ||
                    String.isNotBlank(caso.SAC_DireccionPostal__c) || String.isNotBlank(caso.SAC_TelefonoRepresentante__c) || String.isNotBlank(caso.SAC_DireccionRepresentante__c) || 
                    String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c) || String.isNotBlank(caso.SAC_PoblacionRepresentante__c) || String.isNotBlank(caso.SAC_ProvinciaRepresentante__c) || 
                    String.isNotBlank(caso.SAC_PaisRepresentante__c) ) {
    
                        String direccionNotificacion;
    
                        if(String.isNotBlank(caso.SAC_DireccionRepresentante__c)){
                            direccionNotificacion = caso.SAC_DireccionRepresentante__c;
                        }
    
                        if(String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_CodigoPostalRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_CodigoPostalRepresentante__c;
                            }
                        }
    
                        if(String.isNotBlank(caso.SAC_PoblacionRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PoblacionRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_PoblacionRepresentante__c;
                            }
                        }
    
                        if(String.isNotBlank(caso.SAC_ProvinciaRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_ProvinciaRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_ProvinciaRepresentante__c;
                            }
                        }
    
                        if(String.isNotBlank(caso.SAC_PaisRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PaisRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_PaisRepresentante__c;
                            }
                        }
    
                        caso.SAC_DireccionPostal__c = direccionNotificacion;
    
                    //Si el email, la direccion postal, el teléfono o el nombre del representante estan informados con el check de usar datos de alf en false, 
                    //arrastro los valores a los campos de datos de contacto de la reclamación
                    if ((String.isNotBlank(caso.SAC_EmailRepresentante__c) || String.isNotBlank(caso.SAC_DireccionPostal__c) || String.isNotBlank(caso.SAC_TelefonoRepresentante__c) || 
                        String.isNotBlank(caso.SAC_NombreRepresentante__c) || String.isNotBlank(caso.SAC_DireccionRepresentante__c) || String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c) || 
                        String.isNotBlank(caso.SAC_PoblacionRepresentante__c) || String.isNotBlank(caso.SAC_ProvinciaRepresentante__c) || String.isNotBlank(caso.SAC_PaisRepresentante__c)) 
                        && !caso.SAC_UsarDatos__c) {
    
                        caso.OS_Email__c = caso.SAC_EmailRepresentante__c;
                        caso.CC_Telefono_Contacto__c = caso.SAC_TelefonoRepresentante__c;
                        caso.SAC_NombreContacto__c = caso.SAC_NombreRepresentante__c;
    
                        caso.SAC_DireccionContacto__c = caso.SAC_DireccionRepresentante__c;
                        caso.SAC_CodigoPostalContacto__c = caso.SAC_CodigoPostalRepresentante__c;
                        caso.SAC_PoblacionContacto__c = caso.SAC_PoblacionRepresentante__c;
                        caso.SAC_ProvinciaContacto__c = caso.SAC_ProvinciaRepresentante__c;
                        caso.SAC_PaisContacto__c = caso.SAC_PaisRepresentante__c;
    
                        //String direccionNotificacion;
    
                        if(String.isNotBlank(caso.SAC_DireccionRepresentante__c)){
                            direccionNotificacion = caso.SAC_DireccionRepresentante__c;
                        }
    
                        if(String.isNotBlank(caso.SAC_CodigoPostalRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_CodigoPostalRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_CodigoPostalRepresentante__c;
                            }
                        }
    
                        if(String.isNotBlank(caso.SAC_PoblacionRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PoblacionRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_PoblacionRepresentante__c;
                            }
                        }
    
                        if(String.isNotBlank(caso.SAC_ProvinciaRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_ProvinciaRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_ProvinciaRepresentante__c;
                            }
                        }
    
                        if(String.isNotBlank(caso.SAC_PaisRepresentante__c)){
                            if(String.isNotBlank(direccionNotificacion)){
                                direccionNotificacion = direccionNotificacion + ', ' + caso.SAC_PaisRepresentante__c;
                            }
                            else{
                                direccionNotificacion = caso.SAC_PaisRepresentante__c;
                            }
                        }
    
                        caso.SAC_DireccionPostal__c = direccionNotificacion;
    
                        caso.SAC_DireccionPostalNotificacion__c = caso.SAC_DireccionPostal__c;
                    }
                }
            }
        }
       
    
        /*****************************************************************
         * Proposito: Si cambia el account del caso y el check 'usar los datos de ALF' está activo,
         * traer los datos de la nueva Account informada
         *
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         *1.0              US997670        Álex Polo      30/08/24      
        *****************************************************************/
        /**
         * @description    Si cambia el account del caso y el check 'usar los datos de ALF' está activo,
         * traer los datos de la nueva Account informada
         * @param listCasesSPV
         * @param mapOldObj
         */
        public static void usarDatosDeAlf(List<Case> listCasesSPV, Map<Id, Case> mapOldObj) {
    
    
            List<Case> listNewCase = new List<Case>();
    
            for(Case caso : listCasesSPV){
    
                if(!mapOldObj.isEmpty()){       //Si viene desde el update
                    if(caso.recordTypeId == RECTYPERECLAMACION){
                        if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).AccountId != caso.AccountId && caso.SAC_UsarDatos__c) {
                            listNewCase.add(caso);
                        }
                    }
                }else{                          //Si viene del insert, mapOldObj estará vacío
                    if(caso.recordTypeId == RECTYPERECLAMACION){
                        if(caso.SAC_UsarDatos__c){  //Si se tiene a true el campo "usar datos del reclamante"
                        listNewCase.add(caso);
                   }
                    }
                }
            }
    
    
    
    
    
            List<Id> listaAccountIds = new List<Id>();
            for (Case caso : listNewCase) {
                listaAccountIds.add(caso.AccountId);
            }
            
            if (!listaAccountIds.isEmpty()) {
                Map<Id, Account> mapaAccounts = new Map<Id, Account>([SELECT Id, PersonEmail, BillingStreet, BillingPostalCode, 
                                                                    BillingCity, BillingState, BillingCountry, Phone, PersonMobilePhone, Name, CC_Numero_Documento__c
                                                                    FROM Account 
                                                                    WHERE Id IN :listaAccountIds]);
    
                for (Case caso : listNewCase) {
                    if (mapaAccounts.isEmpty()) {
                        caso.SAC_DireccionPostalNotificacion__c = null;
                        caso.SAC_DireccionContacto__c = null;
                        caso.SAC_CodigoPostalContacto__c = null;
                        caso.SAC_PoblacionContacto__c = null;
                        caso.SAC_ProvinciaContacto__c = null;
                        caso.SAC_PaisContacto__c = null;
                        caso.SAC_NombreContacto__c = null;
                        caso.CC_SuppliedNIF__c = null;
                    } else {
                        if (mapaAccounts.containsKey(caso.AccountId)) {
                            caso.OS_Email__c = mapaAccounts.get(caso.AccountId).PersonEmail;
                            //Traer datos teléfono
                            if (mapaAccounts.containsKey(caso.AccountId) && String.isNotBlank(mapaAccounts.get(caso.AccountId).Phone)) {
                                caso.CC_Telefono_Contacto__c = mapaAccounts.get(caso.AccountId).Phone;
                            } else if (mapaAccounts.containsKey(caso.AccountId) && String.isNotBlank(mapaAccounts.get(caso.AccountId).PersonMobilePhone)) {
                                caso.CC_Telefono_Contacto__c = mapaAccounts.get(caso.AccountId).PersonMobilePhone;
                            } else {
                                caso.CC_Telefono_Contacto__c = null;
                            }
                            //Rellenar la dirección
                            String direccion;
                            String d;
                            String cp;
                            String poblacion;
                            String provincia;
                            String pais;
                            String numDoc;

                            if(String.isNotBlank(mapaAccounts.get(caso.AccountId).CC_Numero_Documento__c)){
                                numDoc = mapaAccounts.get(caso.AccountId).CC_Numero_Documento__c;
                            }

                            if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingStreet)) {
                                direccion = mapaAccounts.get(caso.AccountId).BillingStreet;
                                d = mapaAccounts.get(caso.AccountId).BillingStreet;
                            }
                            if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingPostalCode)) {
                                if (String.isNotBlank(direccion)) {
                                    direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingPostalCode;
                                } else {
                                    direccion = mapaAccounts.get(caso.AccountId).BillingPostalCode;
                                }
                                cp = mapaAccounts.get(caso.AccountId).BillingPostalCode;
                            }
                            if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingCity)) {
                                if (String.isNotBlank(direccion)) {
                                    direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingCity;
                                } else {
                                    direccion = mapaAccounts.get(caso.AccountId).BillingCity;
                                }
                                poblacion = mapaAccounts.get(caso.AccountId).BillingCity;
                            }
                            if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingState)) {
                                if (String.isNotBlank(direccion)) {
                                    direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingState;
                                } else {
                                    direccion = mapaAccounts.get(caso.AccountId).BillingState;
                                }
                                provincia = mapaAccounts.get(caso.AccountId).BillingState;
                            }
                            if (String.isNotBlank(mapaAccounts.get(caso.AccountId).BillingCountry)) {
                                if (String.isNotBlank(direccion)) {
                                    direccion = direccion + ', ' + mapaAccounts.get(caso.AccountId).BillingCountry;
                                } else {
                                    direccion = mapaAccounts.get(caso.AccountId).BillingCountry;
                                }
                                pais = mapaAccounts.get(caso.AccountId).BillingCountry;
                            }
                            caso.SAC_DireccionPostalNotificacion__c = direccion;
                            caso.SAC_DireccionContacto__c = d;
                            caso.SAC_CodigoPostalContacto__c = cp;
                            caso.SAC_PoblacionContacto__c = poblacion;
                            caso.SAC_ProvinciaContacto__c = provincia;
                            caso.SAC_PaisContacto__c = pais;
                            //Rellenar nombre del contacto
                            caso.SAC_NombreContacto__c = mapaAccounts.get(caso.AccountId).Name;
                            caso.CC_SuppliedNIF__c = numDoc;
                        }
                    }
                }
            }
        }




    /************************************************************************************************************
     * Proposito:  Con el Set de Ides hacer una consulta de todas sus pretensiones para luego sumar los importes
     *              y rellenar el importe de la Reclamación padre
     *
     * Parameters: Set de ides
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     *                      US963386        Álex Polo           28/08/2024            
     * *********************************************************************************************************/
    /**
     * @description    Con el Set de Ides hacer una consulta de todas sus pretensiones para luego sumar los importes
     * y rellenar el importe de la Reclamación padre
     * @param mapListPretensiones
     */
     private static List<Case> calcularImporte(Map<Id,List<Case>> mapListPretensiones){

        Map<Id, Decimal> mapaReclImporteParaActualizar = new Map<Id, Decimal>();
        Map<Id, Decimal> mapaReclQuebrantoParaActualizar = new Map<Id, Decimal>();
        Map<Id, Decimal> mapaReclImporteResueltoParaActualizar = new Map<Id, Decimal>();
        Map<Id, Decimal> mapaReclImporteAbonadoParaActualizar = new Map<Id, Decimal>();
        Map<Id, Case> mapaReclaUpdatear = new Map<Id, Case>();
        List<Case> listaReclaUpdatear = new List<Case>();

        //NEW sumatorios tareas
        //Decimal importeResueltoTotal = 0;
        //Decimal importeAbonadoTotal = 0;
        map<id, list<decimal>> importeTareasMap = importeTareasDirectas(mapListPretensiones.keySet());

        for(Id key : mapListPretensiones.keySet()){
            //Metemos dentro del Mapa los importes de las pretensiones, si es 0 o null no sumaremos
            Decimal importe = 0;
            Decimal importeResuelto = 0;
            Decimal importeAbonado = 0;

            for(Case pretension: mapListPretensiones.get(key)){
                if((pretension.CC_Importe_Reclamado__c != null)/* && (pretension.CC_Importe_Reclamado__c !=0 )*/){
                    if(!mapaReclImporteParaActualizar.containsKey(key)){
                        mapaReclImporteParaActualizar.put(key, 0);
                    }
                    if(mapaReclImporteParaActualizar.containsKey(key)){
                        importe = mapaReclImporteParaActualizar.get(key);
                        importe += pretension.CC_Importe_Reclamado__c;
                        mapaReclImporteParaActualizar.put(key, importe);
                    }
                }
            }

            //Calculo importe resuelto
                //Metemos dentro del Mapa los importes de las pretensiones, si es 0 o null no sumaremos
                //

            for(Case pretension: mapListPretensiones.get(key)){

                Decimal importeTarea = pretension.SAC_Importe_Resuelto__c == null ? 0 : pretension.SAC_Importe_Resuelto__c;
                if(mapaReclImporteResueltoParaActualizar.containsKey(key)){
                    importeTarea = mapaReclImporteResueltoParaActualizar.get(key);
                }
                importeResuelto += importeTarea;
            }

            //Calculo importe abonado
            //O o null se tiene que tener en cuenta para poner el valor a 0 si en todas las pretensiones se ha cambiado a null o a 0
            for(Case pretension: mapListPretensiones.get(key)){
                Decimal importeTarea = pretension.CC_Importe_Abonado__c == null ? 0 : pretension.CC_Importe_Abonado__c;
                if(mapaReclImporteAbonadoParaActualizar.containsKey(key)){
                    importeTarea = mapaReclImporteAbonadoParaActualizar.get(key);
                }
                importeAbonado += importeTarea;
            }

            //añadir al resuelto y el abonado el importe de sus tareas directas
            if(importeTareasMap.containsKey(key)){
                importeResuelto += importeTareasMap.get(key)[0];
                importeAbonado += importeTareasMap.get(key)[1];
            }
            mapaReclImporteResueltoParaActualizar.put(key, importeResuelto);
            mapaReclImporteAbonadoParaActualizar.put(key, importeAbonado);

            //Calculo quebranto -- Añadido
            Decimal importe2 = 0;
            for(Case pretension: mapListPretensiones.get(key)){
                if((pretension.SAC_Quebranto__c != null) && (pretension.SAC_Quebranto__c !=0 )){
                    if(!mapaReclQuebrantoParaActualizar.containsKey(key)){
                        mapaReclQuebrantoParaActualizar.put(key, 0);
                    }
                    if(mapaReclQuebrantoParaActualizar.containsKey(key)){
                        importe2 = mapaReclQuebrantoParaActualizar.get(key);
                        importe2 += pretension.SAC_Quebranto__c;
                        mapaReclQuebrantoParaActualizar.put(key, importe2);
                    }
                }
            }
        }

        for(Id ide : mapaReclImporteParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).CC_Importe_Reclamado__c = mapaReclImporteParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.CC_Importe_Reclamado__c = mapaReclImporteParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Calculo importe resuelto
        for(Id ide : mapaReclImporteResueltoParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).SAC_Importe_Resuelto__c = mapaReclImporteResueltoParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.SAC_Importe_Resuelto__c = mapaReclImporteResueltoParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Calculo importe abonado
        for(Id ide : mapaReclImporteAbonadoParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).CC_Importe_Abonado__c = mapaReclImporteAbonadoParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.CC_Importe_Abonado__c = mapaReclImporteAbonadoParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Calculo quebranto -- Añadido
        for(Id ide : mapaReclQuebrantoParaActualizar.keySet()){
            if (mapaReclaUpdatear.containsKey(ide)) {
                mapaReclaUpdatear.get(ide).SAC_Quebranto__c = mapaReclQuebrantoParaActualizar.get(ide);
            } else {
                Case reclamacion = new case();
                reclamacion.id = ide;
                reclamacion.SAC_Quebranto__c = mapaReclQuebrantoParaActualizar.get(ide);
                mapaReclaUpdatear.put(ide, reclamacion);
            }
        }

        //Pasar las reclamaciones a actualizar del mapa a una lista
        for (Id ideMapaActualizar : mapaReclaUpdatear.keySet()) {
            listaReclaUpdatear.add(mapaReclaUpdatear.get(ideMapaActualizar));
        }

        return listaReclaUpdatear;
    }


     /************************************************************************************************************
     * Proposito:  Sacar los sumatorios de las tareas que están directamente asociadas a la reclamación(no están
     * asociadas a ninguna de sus pretensiones)
     *
     * Parameters: Set de ides
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     *                       US963386        Álex Polo           28/08/2024     
     * *********************************************************************************************************/
    /**
     * @description    Sacar los sumatorios de las tareas que están directamente asociadas a la reclamación(no están
     * asociadas a ninguna de sus pretensiones)
     * @param recId
     */
     public static map<id, list<decimal>> importeTareasDirectas(set<Id> recId) {
        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        if(SAC_Accion__c.SObjectType.getDescribe().isAccessible()){
            listaTareas = [SELECT Id, SAC_ImporteResuelto__c, SAC_ImporteAbonar__c, SAC_ImpResueltoInteresesLegales__c,
                            SAC_Reclamacion__c
                            FROM SAC_Accion__c WHERE SAC_Reclamacion__c IN : recId AND SAC_Pretension__c = null];
        }
        map<id, list<decimal>> importeTareasMap = new map<id, list<decimal>>();
        for(SAC_Accion__c acc : listaTareas) {
            if(!importeTareasMap.containsKey(acc.SAC_Reclamacion__c)){
                list<decimal> importes = new list<decimal>();
                importes.add(0);
                importes.add(0);
                importeTareasMap.put(acc.SAC_Reclamacion__c, importes);
            }

            if(acc.SAC_ImporteResuelto__c != null) {
                importeTareasMap.get(acc.SAC_Reclamacion__c)[0] += acc.SAC_ImporteResuelto__c;
            }
            if(acc.SAC_ImporteAbonar__c != null) {
                importeTareasMap.get(acc.SAC_Reclamacion__c)[1] += acc.SAC_ImporteAbonar__c;
            }
            if(acc.SAC_ImpResueltoInteresesLegales__c != null) {
                importeTareasMap.get(acc.SAC_Reclamacion__c)[1] += acc.SAC_ImpResueltoInteresesLegales__c;
            }
        }
        return importeTareasMap;
    }


     /*****************************************************************
     * Proposito: Al modificar el grupo de una reclamación, o al añadir una reclamación 
     * se deberá asignar el valor correspondiente al campo SAC_Empresa__c de la reclamación en 
     * función del valor del campo CC_Grupo_Colaborador__c del grupo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US963386      Álex Polo     12/08/2024        Creación
     *****************************************************************/
    /**
     * @description    Actualizar el valor del campo SAC_Empresa__c
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void asignarEmpresaReclamacion ( List<Case> listCasosSPV, Map<Id, Case> mapOldObj ){
       

        List <Case> listReclamacionesActualizar = new List<Case>();

        for(Case caso : listCasosSPV){
        //Si se ha actualizado el grupo, se cambia la empresa
        if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Grupo__c != caso.SEG_Grupo__c && caso.recordTypeId == RECTYPERECLAMACION){
            listReclamacionesActualizar.add(caso);
        }
        }


        //Se obtiene una lista con los nuevos grupos de las reclamaciones actualizadas
        List<Id> listaIdGrupos = new List<Id>();
        if(!listReclamacionesActualizar.isEmpty()){
            for(Case caso : listReclamacionesActualizar){
                if(caso.SEG_Grupo__c != null){
                    listaIdGrupos.add(caso.SEG_Grupo__c);
              
                }
            }
        }
       

      
        List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT Id, CC_Empresa__c, Name FROM CC_Grupo_Colaborador__c WHERE Id IN :listaIdGrupos];
       

        //En el mapa se gaurda para cada grupo, el nombre de su Empresa en CC_Empresa__c
        Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id,CC_Grupo_Colaborador__c>();
    
        if(!listaGrupos.isEmpty()){
            for(CC_Grupo_Colaborador__c grupo : listaGrupos){
                mapaGrupos.put(grupo.Id, grupo);
            }
          }

       
        if(!listReclamacionesActualizar.isEmpty() && !listaGrupos.isEmpty()){
            //Se recorren las reclamaciones, añadiendole a cada una la empresa de su nuevo grupo
            for(Case caso : listReclamacionesActualizar){
                //Si la reclamación actualizada no tiene grupo, se quita la empresa asociada
                if(caso.SEG_Grupo__c == null){
                    caso.SAC_Empresa__c = null;
                }else{
                
                    if(mapaGrupos.containsKey(caso.SEG_Grupo__c)){
                      
                        //En caso de que, si es null o "sin provedor", se requiera otro valor de picklist y no null, descomentar lo siguiente
                       /* if(mapaGrupos.get(caso.SEG_Grupo__c).CC_Empresa__c == null || mapaGrupos.get(caso.SEG_Grupo__c).CC_Empresa__c == 'SIN PROVEEDOR'){
                            caso.SAC_Empresa__c = 'Temporal';
                        }*/
        
                        //Al ser BU, basta con actualizar el campo así, no es necesario hacer la operación updateDML
                        caso.SAC_Empresa__c = mapaGrupos.get(caso.SEG_Grupo__c).CC_Empresa__c;
                        
                    }
                }
               
              }
        }else{
            //Si ninguna tiene grupo, se pondrá su campo empresa a null
            if(!listReclamacionesActualizar.isEmpty() && listaGrupos.isEmpty()){
                for(Case caso : listReclamacionesActualizar){
                    caso.SAC_Empresa__c = null;
                }
            }
        }
    }




      /*****************************************************************
     * Proposito: Al modificar el subestado de un caso a Alegación o a Allanamiento,
     * su fecha de allanamiento o su fecha de alegación cambiará según cuál haya
     * sido cambiada
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US963386      Álex Polo     13/08/2024        Creación
     * 1.1             US1037919     Álex Polo     14/10/2024        Modificación
     *****************************************************************/
    /**
     * @description    Al modificar el subestado de un caso a Alegación o a Allanamiento,
     * su fecha de allanamiento o su fecha de alegación cambiará según cuál haya
     * sido cambiada
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void cambiarFechaAlegacionAllanamiento( List<Case> listCasosSPV, Map<Id, Case> mapOldObj ){

        List <Case> listReclamacionesCambiarFechaSubestado = new List <Case>();
        for(Case caso : listCasosSPV){
              //Si el estado anterior no era alegación, y el nuevo sí, se cambiará la fecha de alegación
              if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Subestado__c != 'Alegaciones' && caso.SEG_Subestado__c == 'Alegaciones'){
                listReclamacionesCambiarFechaSubestado.add(caso);
            }

            //Si el estado anterior no era allanamiento, y el nuevo sí, se cambiará la fecha de allanamiento
            if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Subestado__c != 'Allanamiento' && caso.SEG_Subestado__c == 'Allanamiento'){
                listReclamacionesCambiarFechaSubestado.add(caso);
            }
        }
       


        //Para cada caso cuyo estado haya pasado a alegación o allanamiento, se actualiza
        //su fecha correspondiente
        if(!listReclamacionesCambiarFechaSubestado.isEmpty()){
            for(Case caso : listReclamacionesCambiarFechaSubestado){
                //Si pasa a alegaciones, la fecha de alegación será la actual
                if(caso.SEG_Subestado__c == 'Alegaciones'){
                    caso.SPV_FechaAlegacion__c = System.now();      //Fecha y hora actual
                }else if(caso.SEG_Subestado__c == 'Allanamiento'){  //Si pasa a allanamiento, la de allanamiento será la actual
                    caso.SPV_FechaAllanamiento__c = System.now();
                } 
            }
        }
        

        //Si la fecha de alegación y allanamiento se actualiza cuando se pasa al estado de envío organismos DESCOMENTAR ESTO
        /*for(Case caso : listCasosSPV){
            //Si el subestado anterior antes de pasar a  envío organismos era alegación
            if(mapOldObj.containsKey(caso.Id) &&  mapOldObj.get(caso.Id).SEG_Subestado__c == 'Alegaciones' && mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SPV_EnvioOrganismos'){
                listReclamacionesCambiarFechaSubestado.add(caso);
            }

            //Si el subestado anterior antes de pasar a  envío organismos era allanamiento
            if(mapOldObj.containsKey(caso.Id) &&  mapOldObj.get(caso.Id).SEG_Subestado__c == 'Allanamiento' && mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SPV_EnvioOrganismos'){
                listReclamacionesCambiarFechaSubestado.add(caso);
            }

            //Si el subestado anterior antes de pasar a  envío organismos era desistimiento
            if(mapOldObj.containsKey(caso.Id) &&  mapOldObj.get(caso.Id).SEG_Subestado__c == 'Desistimiento' && mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SPV_EnvioOrganismos'){
                listReclamacionesCambiarFechaSubestado.add(caso);
            }

        }

        //Para cada caso cuyo estado haya pasado a alegación o allanamiento, se actualiza
        //su fecha correspondiente
        if(!listReclamacionesCambiarFechaSubestado.isEmpty()){
            for(Case caso : listReclamacionesCambiarFechaSubestado){
                //Si pasa a alegaciones, la fecha de alegación será la actual
                if(mapOldObj.get(caso.Id).SEG_Subestado__c == 'Alegaciones'){
                    caso.SPV_FechaAlegacion__c = System.now();      //Fecha y hora actual
                }else if(mapOldObj.get(caso.Id).SEG_Subestado__c == 'Allanamiento'){  //Si pasa a allanamiento, la de allanamiento será la actual
                    caso.SPV_FechaAllanamiento__c = System.now();
                } 
                // else if(mapOldObj.get(caso.Id).SEG_Subestado__c == 'Desistimiento'){
                //     //caso.SPV_FechaDesistimiento__c = date.today();
                // }
            }
        }*/



    }




    
    /*****************************************************************
     * Proposito: Al añadir una nueva reclamación, sele asigna unaa fecha Y además una cola
     * de recepción
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US963386      Álex Polo     14/08/2024        Creación
     *****************************************************************/
    /**
     * @description    Al añadir una nueva reclamación, sele asigna unaa fecha Y además una cola
     * de recepción
     * @param listCasosSPV
     * @param cola
     */
    public static void asignarFechaRecepcionYColaReclamacion(List<Case> listCasosSPV, Group cola){

        List<Case> listaReclamaciones = new List<Case>();
            for(Case caso : listCasosSPV){
                if(caso.RecordTypeId == RECTYPERECLAMACION){
                    listaReclamaciones.add(caso);
                }
            }
        
        for(Case caso : listaReclamaciones){
            //Si el caso a añadortiene un caso relacionado, es porque viene de una copia y el campo fechaRecepcion ya está relleno
            if(String.isBlank(caso.SAC_CasoRelacionado__c)){
                caso.SAC_FechaRecepcion__c = System.now();  
            }
            //Y además asigne a cada caso nuevo de SPV, el owner a la cola Pte. Asignar
            caso.OwnerId = cola.id;
        }


    }


    /*****************************************************************
     * Proposito: Cuando la reclamación recibe un cambio en el sentido de resolución, se actualiza 
     * la fecha en la que se ha obtenido la resolución
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1037919      Álex Polo     30/10/2024        Creación
     *****************************************************************/
    /**
     * @description    Cuando la reclamación recibe un cambio en el sentido de resolución, se actualiza 
     * la fecha en la que se ha obtenido la resolución
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void rellenarFechaRecepcionResolucion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj){

        List<Case> listaCambiarFechaRecepcionResolucion = new List<Case>();

        for(Case caso : listCasosSPV){
            //Se cambiará la fecha de aquellas reclamaciones cuyo sentido de resolución haya cambiado
            if(caso.recordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.SAC_SentidoResolucion__c != mapOldObj.get(caso.Id).SAC_SentidoResolucion__c){
                listaCambiarFechaRecepcionResolucion.add(caso);
            }
        }

        if(!listaCambiarFechaRecepcionResolucion.isEmpty()){
            for(Case reclamacion : listaCambiarFechaRecepcionResolucion){

                /*if(reclamacion.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                    CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                    caseExtension.SPV_FechaRecepcionResolucion__c  = date.today();
                    SPV_DatabaseDML.insertDML(caseExtension, false);
                    reclamacion.CBK_Case_Extension_Id__c = caseExtension.Id;   
                }else{          //Si ya lo tiene
                    CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                    caseExtension.Id = reclamacion.CBK_Case_Extension_Id__c;
                    caseExtension.SPV_FechaRecepcionResolucion__c  = date.today();
                    SPV_DatabaseDML.updateDML(caseExtension, false);
                }*/

                reclamacion.SPV_FechaRecepcionResolucion__c = date.today();
            }
        }
    }


    /*****************************************************************
     * Proposito: Al actualizar la fecha de recepción de una reclamacón, se actualizará la
     * fehca de recepción de sus pretensiones hijas 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US963386      Álex Polo     14/08/2024        Creación
    //  *****************************************************************/
    /**
     * @description    Al actualizar la fecha de recepción de una reclamacón, se actualizará la
     * fehca de recepción de sus pretensiones hijas 
     * @param listaCasosActualizar
     * @param mapOldCase
     */
     public static void  actualizarFechaRecepcionPretensiones(List <Case> listaCasosActualizar, Map<Id,Case> mapOldCase){


         //En este mapa se van a ir almacenando los casos que hay que actualizar, y al final del método se usa para hacer el update
         Map <Id, Case> mapaPretensionesActualizar = new Map<Id, Case>();
         Map <Id, Case> mapaReclamaciones = new Map<Id, Case>();
         List<Case> listaPretensiones = new List<Case>();


         for(Case caso : listaCasosActualizar){
             //Si se trata de una reclamación a la cual se le ha actualizado la fecha de recepción
             if(mapOldCase.containsKey(caso.Id) && caso.recordTypeId == RECTYPERECLAMACION && mapOldCase.get(caso.Id).SAC_FechaRecepcion__c != caso.SAC_FechaRecepcion__c){
                mapaReclamaciones.put(caso.Id, caso);
              
             }
         }


                //Se obtienen sus pretensiones hijas
                if(!mapaReclamaciones.isEmpty()){
                    listaPretensiones = [SELECT Id, SAC_FechaRecepcion__c, SAC_Reclamacion__C FROM Case WHERE recordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN: mapaReclamaciones.keySet()];
                   
                }

                if(!listaPretensiones.isEmpty()){
                   //Si hay pretensiones, se recorren
                    for(Case pretension : listaPretensiones){
                        if(!mapaPretensionesActualizar.containsKey(pretension.Id)){ //Si no está en el mapa, se actualiza la fecha de la pretensión y se añade al mapa de que hay que actualizar
                            pretension.SAC_FechaRecepcion__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__C).SAC_FechaRecepcion__c; //A la pretensión se le asigna la fecha de recepción de la reclamación
                            //pretension.SAC_FechaRecepcion__c = caso.SAC_FechaRecepcion__c;
                      
                            mapaPretensionesActualizar.put(pretension.Id, pretension);
                        }else{
                               mapaPretensionesActualizar.get(pretension.Id).SAC_FechaRecepcion__c = mapaReclamaciones.get(pretension.SAC_Reclamacion__C).SAC_FechaRecepcion__c; //Si sí está en el mapa, se actualiza su valor de nuevo
                          //  mapaPretensionesActualizar.get(pretension.Id).SAC_FechaRecepcion__c = caso.SAC_FechaRecepcion__c; //Si sí está en el mapa, se actualiza su valor de nuevo
                        }
                      

                    }
                }

         //Tras haber recorrido todas las pretensiones de todos los casos, se actualizan
         if(!mapaPretensionesActualizar.isEmpty()){
             SPV_DatabaseDML.updateListDML(mapaPretensionesActualizar.values(), false);
         }
        
     }

    /*****************************************************************
     * Proposito: Añade permisos para que el gestor de la reclamación pueda modificar
     * las pretensiones hijas. Se ejecuta cuando se asigna un user como propietario de la reclamación,
     * insertando a este los permisos y borra los del antiguo.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    /**
     * @description    Añade permisos para que el gestor de la reclamación pueda modificar
     * las pretensiones hijas.
     * @param listReclamaciones
     * @param listaSelect
     * @param mapOldCase
     */
    public static void permisosGestor(List<Case> listReclamaciones, List<Case> listaSelect, Map<Id, Case> mapOldCase) {

        Map<Id, Case> mapaNewCase = new Map<Id, Case>(listReclamaciones);
        Map<Id, List<Case>> mapaRecListaPret = new Map<Id, List<Case>>();
        Map<Id, Id> mapaIdreclamacionIdOwner = new Map<Id, Id>();
        Set<Id> setIdsPretensiones = new Set<Id>();
        Set<Id> setIdsOwners = new Set<Id>();

        for (Case caso : listaSelect) {
            //Preparación CaseShare nuevos a insertar
            if (mapaNewCase.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaRecListaPret.containsKey(mapaNewCase.get(caso.SAC_Reclamacion__c).Id)) {
                    mapaRecListaPret.get(mapaNewCase.get(caso.SAC_Reclamacion__c).Id).add(caso);
                } else {
                    List<Case> listaPret = new List<Case>();
                    listaPret.add(caso);
                    mapaRecListaPret.put(mapaNewCase.get(caso.SAC_Reclamacion__c).Id, listaPret);
                }
                mapaIdreclamacionIdOwner.put(mapaNewCase.get(caso.SAC_Reclamacion__c).Id, mapaNewCase.get(caso.SAC_Reclamacion__c).OwnerId);
            }
            //Preparación CaseShare a borrar
            if (mapaNewCase.containsKey(caso.SAC_Reclamacion__c) && mapOldCase.containsKey(caso.SAC_Reclamacion__c) && mapaNewCase.get(caso.SAC_Reclamacion__c).OwnerId != mapOldCase.get(caso.SAC_Reclamacion__c).OwnerId) {
                setIdsPretensiones.add(caso.Id);
                setIdsOwners.add(mapOldCase.get(caso.SAC_Reclamacion__c).OwnerId);
            }
        }

        //Recorrer el mapa y añadir un case share por cada pretension
        List<CaseShare> listaCSNuevos = new List<CaseShare>();
        for (Id idReclamacion : mapaRecListaPret.keySet()) {
            String ownerPretensiones = '';
            for (Case pretension : mapaRecListaPret.get(idReclamacion)) {
                CaseShare csNuevo = new CaseShare();
                csNuevo.CaseId = pretension.Id;
                csNuevo.UserOrGroupId = mapaIdreclamacionIdOwner.get(idReclamacion);
                csNuevo.CaseAccessLevel='Edit';
                ownerPretensiones = pretension.OwnerId;
                listaCSNuevos.add(csNuevo);
            }

            //Al cambiar el propietario de la reclamación, Salesforce borra los CaseShare manuales que esta tuviese. Por ello debemos insertar un CaseShare para que el letrado de la pretensión pueda modificar la reclamación padre.
            CaseShare csReclamacion = new CaseShare();
            csReclamacion.CaseId = idReclamacion;
            csReclamacion.UserOrGroupId = ownerPretensiones;
            csReclamacion.CaseAccessLevel = 'Edit';
            listaCSNuevos.add(csReclamacion);

        }

        //Insertar CaseShare nuevos
        if (!listaCSNuevos.isEmpty()) {
            SPV_DatabaseDML.insertListDML(listaCSNuevos, false);
        }

        //Borrar CaseShare de antiguo owner
        List<CaseShare> listaCSBorrar = new List<CaseShare>();
        if (!setIdsPretensiones.isEmpty() && CaseShare.SObjectType.getDescribe().isAccessible()) {
            listaCSBorrar = [SELECT Id FROM CaseShare WHERE CaseId IN :setIdsPretensiones AND UserOrGroupId IN :setIdsOwners];

            if (!listaCSBorrar.isEmpty()) {
                SPV_DatabaseDML.deleteListDML(listaCSBorrar, false);
            }
        }
    }


    /*****************************************************************
     * Proposito: Añade permisos para que el letrado de la pretensión pueda modificar
     * la reclamación padre. Se ejecuta cuando se asigna un user como propietario de la pretensión,
     * insertando a este los permisos y borra los del antiguo.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    /**
     * @description    Añade permisos para que el letrado de la pretensión pueda modificar
     * la reclamación padre.
     * @param listPretensiones
     * @param listaSelect
     * @param mapOldCase
     */
    public static void permisosLetrado(List<Case> listPretensiones, List<Case> listaSelect, Map<Id, Case> mapOldCase) {

        //Pasar lista de todo lo que traemos del select del trigger a mapa
        Map<Id, Case> mapaSelect = new Map<Id, Case>(listaSelect);

        //Buscar los padres de las pretensiones a las que les ha cambiado el owner en el mapa para almacenarlos
        Map<Id, Set<Id>> mapaCaseShareNuevos = new Map<Id, Set<Id>>();
        Map<Id, List<Case>> mapaRecListaPret = new Map<Id, List<Case>>();
        Map<Id, Id> mapaIdreclamacionIdOwner = new Map<Id, Id>();
        Set<Id> setIdsPadres = new Set<Id>();
        Set<Id> setIdsOwnersPret = new Set<Id>();

        for (Case caso : listPretensiones) {
            //Nuevos a añadir
            if (mapaSelect.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaCaseShareNuevos.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaCaseShareNuevos.get(caso.SAC_Reclamacion__c).add(caso.OwnerId);
                } else {
                    Set<Id> setCS = new Set<Id>();
                    setCS.add(caso.OwnerId);
                    mapaCaseShareNuevos.put(caso.SAC_Reclamacion__c, setCS);
                }

                //Agregar pretensiones al mapa de reclamaciones
                if (mapaRecListaPret.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaRecListaPret.get(caso.SAC_Reclamacion__c).add(caso);
                } else {
                    List<Case> listaPretensionesReclamacion = new List<Case>();
                    listaPretensionesReclamacion.add(caso);
                    mapaRecListaPret.put(caso.SAC_Reclamacion__c, listaPretensionesReclamacion);
                }
                mapaIdreclamacionIdOwner.put(mapaSelect.get(caso.SAC_Reclamacion__c).Id, mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId);
            }
            //Antiguos a eliminar    
            if (mapOldCase.containsKey(caso.Id) && mapaSelect.containsKey(caso.SAC_Reclamacion__c) && mapOldCase.get(caso.Id).OwnerId != mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId) {
                setIdsPadres.add(mapaSelect.get(caso.SAC_Reclamacion__c).Id);
                setIdsOwnersPret.add(mapOldCase.get(caso.Id).OwnerId);
            }            
        }

        //Pasar mapa a lista de CaseShare para insertar
        List<CaseShare> listaCaseShareNuevos = new List<CaseShare>();
        if (!mapaCaseShareNuevos.isEmpty()) {
            for (Id ideRec : mapaCaseShareNuevos.keySet()) {
                for (Id ideOwner : mapaCaseShareNuevos.get(ideRec)) {
                    CaseShare csNuevo = new CaseShare();
                    csNuevo.CaseId = ideRec;
                    csNuevo.UserOrGroupId = ideOwner;
                    csNuevo.CaseAccessLevel='Edit';
                    listaCaseShareNuevos.add(csNuevo);
                }               
            }
        }

        //Al cambiar el propietario de la pretensión, Salesforce borra los CaseShare manuales que esta tuviese. Por ello debemos insertar un CaseShare para que el gestor de la reclamación pueda modificar la pretensión actualiada.
        if(!mapaRecListaPret.isEmpty()){
            for (Id ideRec : mapaRecListaPret.keySet()) {
                for (Case pretension : mapaRecListaPret.get(ideRec)) {
                    CaseShare csNuevo = new CaseShare();
                    csNuevo.CaseId = pretension.Id;
                    csNuevo.UserOrGroupId = mapaIdreclamacionIdOwner.get(ideRec);
                    csNuevo.CaseAccessLevel='Edit';
                    listaCaseShareNuevos.add(csNuevo);
                }
            }
        }

        //Insertar CaseShare nuevos
        if (!listaCaseShareNuevos.isEmpty()) {
            SPV_DatabaseDML.insertListDML(listaCaseShareNuevos, false);
        }
        
        //Borrar CaseShare de antiguo owner
        if (!setIdsPadres.isEmpty() && !setIdsOwnersPret.isEmpty()) {

            List<CaseShare> listaCaseShareBorrar = [SELECT Id FROM CaseShare WHERE CaseId IN :setIdsPadres AND UserOrGroupId IN :setIdsOwnersPret];
            if (!listaCaseShareBorrar.isEmpty()) {
                SPV_DatabaseDML.deleteListDML(listaCaseShareBorrar, false);
            }
        }
    }    


    /*****************************************************************
     * Proposito: Cuando actualizo el owner de una reclamación o pretensión, doy permisos sobre las tareas al nuevo owner y elimino los
     * del owner anterior.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    /**
     * @description    Cuando actualizo el owner de una reclamación o pretensión, doy permisos sobre las tareas al nuevo owner y elimino los
     * del owner anterior.
     * @param listNewCases
     * @param listaSelect
     * @param mapOldCase
     */
    public static void permisosTareas(List<Case> listNewCases, List<Case> listaSelect, Map<Id, Case> mapOldCase) {

        List<Id> idsCase = new List<Id>();
        Set<Id> idsAcciones = new Set<Id>();
        Set<Id> idsOldOwners = new Set<Id>();
        Map<Id, Set<Id>> mapaAccionShareNuevos = new Map<Id, Set<Id>>();

        for (Case caso : listNewCases) {
            idsCase.add(caso.SAC_Reclamacion__c != null ? caso.SAC_Reclamacion__c : caso.Id);

            if(mapOldCase.containsKey(caso.Id)){
                idsOldOwners.add(mapOldCase.get(caso.Id).OwnerId);
            }
        }

        List<SAC_Accion__c> listAcciones = new List<SAC_Accion__c>();
        if(Schema.sObjectType.SAC_Accion__c.isAccessible()){
            listAcciones = [SELECT Id, SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE (RecordTypeId =: RECTYPEACCION OR RecordTypeId = :RECTYPEACCIONMAESTRO) AND SAC_Reclamacion__c IN :idsCase];
        }

        Map<Id, Case> mapaSelect = new Map<Id, Case>(listaSelect);
        for (SAC_Accion__c accion : listAcciones) {
            idsAcciones.add(accion.Id);

            //Nuevos a añadir
            for(Id caso : mapaSelect.keySet()){
                if (mapaAccionShareNuevos.containsKey(accion.Id)) {
                    mapaAccionShareNuevos.get(accion.Id).add(mapaSelect.get(caso).OwnerId);
                } else {
                    Set<Id> setCS = new Set<Id>();
                    setCS.add(mapaSelect.get(caso).OwnerId);
                    mapaAccionShareNuevos.put(accion.Id, setCS);
                }
            }
        }

        //Pasar mapa a lista de AccionShare para insertar
        List<SAC_Accion__Share> listaAccionShareNuevos = new List<SAC_Accion__Share>();
        if (!mapaAccionShareNuevos.isEmpty()) {
            for (Id idAccion : mapaAccionShareNuevos.keySet()) {
                for (Id idOwner : mapaAccionShareNuevos.get(idAccion)) {
                    SAC_Accion__Share accionShare = new SAC_Accion__Share();
                    accionShare.ParentId = idAccion;
                    accionShare.AccessLevel = 'Edit';
                    accionShare.UserOrGroupId = idOwner;
                    listaAccionShareNuevos.add(accionShare);
                }               
            }
        }

        //Insertar AccionShare nuevos
        if (!listaAccionShareNuevos.isEmpty()) {
            SPV_DatabaseDML.insertListDML(listaAccionShareNuevos, false);
        }

        //Borrar AccionShare de antiguo owner reclamacion o pretension
        if (!idsAcciones.isEmpty()) {
            List<SAC_Accion__Share> listaCSBorrar = [SELECT Id FROM SAC_Accion__Share WHERE ParentId IN :idsAcciones AND UserOrGroupId IN :idsOldOwners];

            if (!listaCSBorrar.isEmpty()) {
                SPV_DatabaseDML.deleteListDML(listaCSBorrar, false);
            }
        }
    }

    /*****************************************************************
     * Proposito: Al insertar una pretensión doy permisos sobre la pretensión al owner de la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    /**
     * @description    Al insertar una pretensión doy permisos sobre la pretensión al owner de la reclamación
     * @param listNewCases
     */
    public static void insertarPermisosPretension(List<Case> listNewCases) {

        
        List<CaseShare> listNuevosCS = new List<CaseShare>();
        Set<Id> setIdsCaso = new Set<Id>();

        for (case caso : listNewCases) {
            setIdsCaso.add(caso.SAC_Reclamacion__c);
        }
       
    
        List<Case> lstReclamaciones = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND SAC_Reclamacion__c IN :setIdsCaso];
        
        
        Map<Id, Case> mapaSelect = new Map<Id, Case>(lstReclamaciones);
        
        // Iterar a través de las pretensiones
        for (Case pretension : listNewCases) {
           
            //Encuentra la reclamación padre correspondiente utilizando el mapa
            Case reclamacion = mapaSelect.get(pretension.SAC_Reclamacion__c);

            if (reclamacion != null) {
                //Crear un CaseShare
                CaseShare caseShare = new CaseShare();
                caseShare.CaseId = pretension.Id;
                caseShare.UserOrGroupId = reclamacion.OwnerId;
                caseShare.CaseAccessLevel = 'Edit'; 
                listNuevosCS.add(caseShare);
            }
        }
    
        //Insertar los CaseShares creados
        if(!listNuevosCS.isEmpty()) {
            SPV_DatabaseDML.insertListDML(listNuevosCS, false);
        }
    }

    /*****************************************************************
     * Proposito: Cuando la reclamacion pasa de estado 'Alta' a 'Analisis' se produce el balanceo letrado. Se evaluan diferentes casuísticas para decidir a que grupo deben balancear las pretensiones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    /**
     * @description    Cuando la reclamacion pasa de estado 'Alta' a 'Analisis' se produce el balanceo letrado.
     * @param listSelect
     * @param listReclamaciones
     * @param mapaDatosCasosActualizar
     * @param cola
     */
    public static void balanceoLetrado(List<Case> listSelect, List<Case> listReclamaciones, Map<Id, Case> mapaDatosCasosActualizar, Group cola) {

        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>(listReclamaciones);
        List<Case> listPretensiones = new List<Case>();
        Case reclamacion = new Case();

        for (Case caso : listSelect) {
            Case reclamacionesCase = mapaReclamaciones.get(caso.Id);
            if (reclamacionesCase != null || mapaReclamaciones.get(caso.SAC_Reclamacion__c) != null) {
                if(caso.RecordTypeId == RECTYPEPRETENSION){
                    listPretensiones.add(caso);
                }else if(caso.RecordTypeId == RECTYPERECLAMACION){
                    //Cogemos la primera reclamación, porque a pesar de recibir una lista, el cambio de estado de 'Alta' a 'Analisis' solo pude hacerse por la botonera (debido a una validation rule), por lo tanto solo entrará una reclamación
                    reclamacion = caso;
                }
            }
        }
        
        //Si ha vuelto de análisis a alta, el campo SPV_VueltaAlta valdrá true, y no hay que balancear
        if(!listPretensiones.isEmpty() && reclamacion.SPV_VueltaAlta__c != true){
        
            if((reclamacion.SPV_Organismo__c == ORIGEN_CNMV || reclamacion.SPV_Organismo__c == ORIGEN_DGS || reclamacion.SPV_Organismo__c == ORIGEN_CONSUMO) && Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
                //Si el origen de la reclamacion es CNMV o DGS se hace el balanceo al grupo FyR Legal
                CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOLETRADO AND SAC_DeveloperName__c = :GRUPOLET_FYRLEGAL LIMIT 1];
                balancearPretensiones(listPretensiones, mapaDatosCasosActualizar, grupo.Id, cola);

            }else if(reclamacion.SPV_Organismo__c == ORIGEN_BDE){
                //Si el origen de la reclamación es BDE, evaluamos otras condiciones 
                //Si la reclamacion tiene antecedentes SAC con grupo letrado informado
                if(reclamacion.CC_CasoRelacionado__c != null && reclamacion.CC_CasoRelacionado__r.SAC_GrupoLetrado__c != null){
                    String grupoLetradoSAC = reclamacion.CC_CasoRelacionado__r.SAC_GrupoLetrado__r.Name;

                    if(grupoLetradoSAC.toLowerCase().trim().contains('indra') && Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
                        //Si los antecedentes son gestionados por el grupo letrado INDRA, se hace el balanceo a INDRA
                        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOLETRADO AND SAC_DeveloperName__c = :GRUPOLET_INDRA LIMIT 1];
                        balancearPretensiones(listPretensiones, mapaDatosCasosActualizar, grupo.Id, cola);

                    }else if((grupoLetradoSAC.toLowerCase().trim().contains('fyrlegal') || grupoLetradoSAC.toLowerCase().trim().contains('vilar')) && Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
                        //Si los antecedenttes son gestionados por FYRLEGAL O VILAR, se hace el balanceo a FyR Legal
                        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOLETRADO AND SAC_DeveloperName__c = :GRUPOLET_FYRLEGAL LIMIT 1];
                        balancearPretensiones(listPretensiones, mapaDatosCasosActualizar, grupo.Id, cola);
                    }else{
                        //Si los antecedentes son gestionados por Ferrer o DXC, entro en balanceo por MCC
                        balanceoPorMCC(reclamacion, listPretensiones, mapaDatosCasosActualizar, cola);
                    }
                }else{
                    //Entro en balanceo por MCC
                    balanceoPorMCC(reclamacion, listPretensiones, mapaDatosCasosActualizar, cola);
                }
            }else{
                //Si no tiene organismo informado, hace el balanceo por MCC
                balanceoPorMCC(reclamacion, listPretensiones, mapaDatosCasosActualizar, cola);
            }
        }
    }

    /*****************************************************************
     * Proposito: Evalua y define el balanceo por detalle del MCC. Recupera el detalle del MCC de la pretension principal, y posteriormente el check de balanceo forzado del detalle MCC.
     * Si el balanceo forzado esta activo, se balancea sobre el grupo asociado a ese MCC
     * Si no esta activo, se evaluan los grupos colaboradores asociados a ese MCC y se balancea dependiendo del numero maximo de casos y el porcentaje de asignación.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/ 
    /**
     * @description    Evalua y define el balanceo por detalle del MCC.
     * @param reclamacion
     * @param pretensiones
     * @param mapaDatosCasosActualizar
     * @param cola
     */
    private static void balanceoPorMCC(Case reclamacion, List<Case> pretensiones, Map<Id, Case> mapaDatosCasosActualizar, Group cola) {
        
        Id mccPretensionPrincipal = null;
        Boolean balanceoForzado = false;

        mccPretensionPrincipal = reclamacion.SAC_PretensionPrincipal__r.SEG_Detalle__c;

        if (mccPretensionPrincipal != null && Schema.sObjectType.CC_MCC_Grupo_Colaborador__c.isAccessible()) {
            Id grupoAsociado = null;

            balanceoForzado = reclamacion.SAC_PretensionPrincipal__r.SEG_Detalle__r.SPV_BalanceoForzado__c;

            //obtenemos todos los grupos
            List<CC_MCC_Grupo_Colaborador__c> listMccGrupos = [SELECT CC_MCC__c, CC_Grupo_Colaborador__c, SAC_PorcentajeAsignacion__c, Name, SAC_MaximoDeCasosDiarios__c
                        FROM CC_MCC_Grupo_Colaborador__c 
                        WHERE CC_MCC__c = :mccPretensionPrincipal AND SPV_Tipo_Cliente__c = 'SPV'];

            if(!listMccGrupos.isEmpty()){
                if(balanceoForzado == false){
                    //mapa de Grupo colaborador - numero de pretensiones
                    Map<Id, Integer> mapGrupoCasos = new Map<Id, Integer>();

                    //mapa de id Grupo colaborador - grupo
                    Map<Id, CC_MCC_Grupo_Colaborador__c> mapIdGrupo = new Map<Id, CC_MCC_Grupo_Colaborador__c>();

                    //relleno las keys del mapa
                    for(CC_MCC_Grupo_Colaborador__c mccGrupo : listMccGrupos){
                        mapGrupoCasos.put(mccGrupo.CC_Grupo_Colaborador__c, 0);
                        mapIdGrupo.put(mccGrupo.CC_Grupo_Colaborador__c, mccGrupo);
                    }
                    
                    //Obtener aquellas pretensiones en las que la pretension principal de su familia tiene el mcc localizado anteriormente al obtener los grupos, ayudandonos del set<id>
                    List<AggregateResult> listaCasos = [SELECT count(Id)countCasos, SEG_Grupo__c FROM Case
                                WHERE RecordTypeId = :RECTYPEPRETENSION
                                AND SEG_Grupo__c != null
                                AND SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Detalle__c = :mccPretensionPrincipal
                                AND CC_Fecha_Traslado_Colaborador__c = TODAY
                                GROUP BY SEG_Grupo__c];
                    

                    //relleno los valores del mapa obteniendo registros del mapa con clave - 0 o clave - numero de pretensiones
                    for(AggregateResult caso : listaCasos){
                        if(mapGrupoCasos.containsKey(String.valueOf(caso.get('SEG_Grupo__c')))){
                            mapGrupoCasos.put(String.valueOf(caso.get('SEG_Grupo__c')), Integer.valueOf(caso.get('countCasos')));
                        }
                    }
                    
                    //inicio calculo balanceo
                    //Paso 1: obtener el total de casos
                    Integer numTotalCasos = recuperarTotalCasos(mapGrupoCasos, listMccGrupos);
                    
                    //Paso 2: comprobar si se ha excedido el número de casos totales para los grupos ej:(tengo gestionando 50 casos y solo me puedo ocupar de 30)
                    Boolean todosLosGruposLLenos = compruebaGruposLlenos(mapGrupoCasos, listMccGrupos);

                    //Paso 3: el calculo y decision de cual es el grupo que se va a balancear
                    Decimal porcentajeActual = 0;
                    Decimal desviacion = -100;
                    
                    for (Id grupoId : mapIdGrupo.keySet()) {
                        //calculo del porcentaje actual
                        if (!todosLosGruposLLenos && numTotalCasos != 0) { 
                            //Si no estan todos los grupos en su máxima capacidad de casos diarios, calculo el porcentaje actual normalmente
                            porcentajeActual = (mapGrupoCasos.get(grupoId) * 100) / numTotalCasos;
                        }else if(!todosLosGruposLLenos && numTotalCasos == 0){
                            porcentajeActual = 0;
                        }else{
                            //De lo contrario, calculo el porcentaje actual restando el valor de el maximo de casos diarios y con el valor del nuevo numTotalCasos
                            porcentajeActual = (mapGrupoCasos.get(grupoId) - mapIdGrupo.get(grupoId).SAC_MaximoDeCasosDiarios__c) * 100 / numTotalCasos;
                        }

                        //calculo de la desviacion para saber que grupo tiene la desviacion mas grande y asignar ese grupo a las pretensiones
                        if(mapIdGrupo.get(grupoId).SAC_PorcentajeAsignacion__c - porcentajeActual > desviacion && (todosLosGruposLLenos || mapIdGrupo.get(grupoId).SAC_MaximoDeCasosDiarios__c >= mapGrupoCasos.get(grupoId))){
                            desviacion = mapIdGrupo.get(grupoId).SAC_PorcentajeAsignacion__c - porcentajeActual;
                            grupoAsociado = mapIdGrupo.get(grupoId).CC_Grupo_Colaborador__c;
                        }
                    }
                }else{
                    //Al tratarse de un balanceo forzado, el MCC solo tendrá un único grupo colabador asociado sobre el que se balanceará
                    grupoAsociado = listMccGrupos[0].CC_Grupo_Colaborador__c;
                }
                
                //Paso 4: asignar el grupo seleccionado a las pretensiones
                balancearPretensiones(pretensiones, mapaDatosCasosActualizar, grupoAsociado, cola);
            }
        }
    }

    /*****************************************************************
     * Proposito: ültimo paso del balanceo, tras el analisis previo aquí se asigna el grupo deseado a la pretension. También se informan los cambios en la reclamación padre
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/
    /**
     * @description    ültimo paso del balanceo, tras el analisis previo aquí se asigna el grupo deseado a la pretension.
     * @param pretensiones
     * @param mapaDatosCasosActualizar
     * @param grupoAsociado
     * @param cola
     */
    private static void balancearPretensiones(List<Case> pretensiones, Map<Id, Case> mapaDatosCasosActualizar, Id grupoAsociado, Group cola){

        for(Case pretension : pretensiones){
            
            if(mapaDatosCasosActualizar.containsKey(pretension.Id)){
                mapaDatosCasosActualizar.get(pretension.Id).SEG_Grupo__c = grupoAsociado;
                mapaDatosCasosActualizar.get(pretension.Id).CC_Fecha_Traslado_Colaborador__c = Datetime.now();
            }
            else{
                pretension.SEG_Grupo__c = grupoAsociado;
                pretension.CC_Fecha_Traslado_Colaborador__c = Datetime.now();
                mapaDatosCasosActualizar.put(pretension.Id, pretension);
            }

            pretension.OwnerId = cola.Id;

            //Rellenar el campo SAC_Letrado__c de la reclamacion padre y el campo SAC_GrupoLetrado__c de la reclamación padre
            if (mapaDatosCasosActualizar.containsKey(pretension.SAC_Reclamacion__c)) {
                mapaDatosCasosActualizar.get(pretension.SAC_Reclamacion__c).SAC_Letrado__c = 'Pte. Asignar';
            }else {
                Case reclamacionActualizar = new Case();
                reclamacionActualizar.Id = pretension.SAC_Reclamacion__c;
                reclamacionActualizar.SAC_Letrado__c = 'Pte. Asignar';
                reclamacionActualizar.SAC_GrupoLetrado__c = grupoAsociado;
                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
            }
        }

        //Enviar alerta del paso de Alta a Analisis
        CC_Grupo_Colaborador__c grupo = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Id = :grupoAsociado LIMIT 1];

        if(pretensiones[0].SEG_Grupo__c == grupo.Id){

            List<SAC_WrapperAlerta> listaWrapperAlerta = new List <SAC_WrapperAlerta>();
            List<String> listaEmails = new List<String>();

            if(String.isNotBlank(grupo.SAC_Email__c)) {
                listaEmails.add(grupo.SAC_Email__c);
            }

            //Se envia alerta el owner de las pretensiones y al grupo letrado
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(pretensiones[0].SAC_Reclamacion__C,
                                            'SPV_012',
                                            'La reclamación ' + pretensiones[0].SAC_Reclamacion__r.CaseNumber + ' a pasado de Alta a análisis.',
                                            cola.Id,
                                            '',
                                            '', 
                                            '');
                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + pretensiones[0].SAC_Reclamacion__C;
                                            wrapAlerta.listaEmailsGrupo = listaEmails;
                                            wrapAlerta.idGrupoColaborador = pretensiones[0].SEG_Grupo__c;
                                            wrapAlerta.proyecto = 'SPV';
            //Añadirla a la lista para posteriormente llamar al método
            listaWrapperAlerta.add(wrapAlerta);

            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
        }
    }

    /*****************************************************************
     * Proposito: Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/
    /**
     * @description    Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * @param mapGrupos
     * @param listMccGrupos
     */
    private static Integer recuperarTotalCasos(Map<Id, Integer> mapGrupos, List<CC_MCC_Grupo_Colaborador__c> listMccGrupos) {
        
        Integer totalCasos = 0;
        Integer totalMaximosDiarios = 0;

        //Mapa para transversar la informacion de la lista listMccGrupos, a usar en el bucle for
        Map<Id, CC_MCC_Grupo_Colaborador__c> mapaGrupoAJunction = new Map<Id, CC_MCC_Grupo_Colaborador__c>();
        
        //Mapa para poder iterar y nutrir el mapa definido anteriormente
        Map<Id, CC_MCC_Grupo_Colaborador__c> mapaMccGrupoCol = new Map<Id, CC_MCC_Grupo_Colaborador__c>(listMccGrupos);
        for(Id grupo : mapaMccGrupoCol.keySet()){
            mapaGrupoAJunction.put(mapaMccGrupoCol.get(grupo).CC_Grupo_Colaborador__c, mapaMccGrupoCol.get(grupo));
        }

        //Bucle para comprobar los casos de los grupos y sus maximos diarios
        for(Id grupo : mapGrupos.keySet()) {
            totalCasos += mapGrupos.get(grupo);

            if(mapaGrupoAJunction.containsKey(grupo)){
                totalMaximosDiarios += Integer.valueOf(mapaGrupoAJunction.get(grupo).SAC_MaximoDeCasosDiarios__c);
            }
            else{
                throw new AuraHandledException('No existe ningún grupo asignado al MCC seleccionado');
            }
        }

        //Si todos los grupos llenos
        if (totalCasos >= totalMaximosDiarios) { 
            Boolean gruposLlenos = compruebaGruposLlenos(mapGrupos, listMccGrupos);

            if(gruposLlenos){
                totalCasos = totalCasos - totalMaximosDiarios;
            }
        }

        return totalCasos;
    }

    /*****************************************************************
     * Proposito: Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/
    /**
     * @description    Método para recuperar el numero total de casos que hay que tener en cuenta para los calculos de asignación
     * @param mapGrupos
     * @param listMccGrupos
     */
    private static Boolean compruebaGruposLlenos(Map<Id, Integer> mapGrupos, List<CC_MCC_Grupo_Colaborador__c> listMccGrupos) {
        Boolean resultado = false;

        Integer contador = 0;

        for(CC_MCC_Grupo_Colaborador__c gruposCol : listMccGrupos){
            if(mapGrupos.containsKey(gruposCol.CC_Grupo_Colaborador__c) && gruposCol.SAC_MaximoDeCasosDiarios__c < mapGrupos.get(gruposCol.CC_Grupo_Colaborador__c)){
                contador = contador + 1;
            }
        }

        if(contador == listMccGrupos.size()){
            resultado = true;
        }

        return resultado;
    }

    /*****************************************************************
     * Proposito: Cuando una reclamación pasa de 'Alta' a 'Analisis' comprueba sus pretensiones hijas, si es unipretension esta pasa a ser la pretension principal
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/
        /**
     * @description    Cuando una reclamación pasa de 'Alta' a 'Analisis' comprueba sus pretensiones hijas, si es unipretension esta pasa a ser la pretension principal
     * @param listaCasos
     * @param listaIdsRec
     * @param listaRecCambioPretPrincipal
     */
    public static void marcarPretensionPrincipal(List<Case> listaCasos, List<Id> listaIdsRec, List<Case> listaRecCambioPretPrincipal){

        List<Case> listaPretensionesHijas = [SELECT Id, SAC_Reclamacion__C, Status, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c  FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN :listaIdsRec];

        if(!listaPretensionesHijas.isEmpty()){
            Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();

            for(Case pret : listaPretensionesHijas){
                if(mapaRecPretensiones.containsKey(pret.SAC_Reclamacion__c) && pret.Status != 'SAC_009') {
                    mapaRecPretensiones.get(pret.SAC_Reclamacion__c).add(pret);

                }else if(pret.Status != 'SAC_009'){
                    List<Case> lista = new List<Case>();
                    lista.add(pret);
                    mapaRecPretensiones.put(pret.SAC_Reclamacion__c, lista);
                }
            }

            for(Case rec : listaCasos){
                if (mapaRecPretensiones.containsKey(rec.Id) && mapaRecPretensiones.get(rec.Id).size() == 1) {
                    rec.SAC_PretensionPrincipal__c = mapaRecPretensiones.get(rec.Id).get(0).Id;
                    // rec.SAC_Entidad_Afectada__c = mapaRecPretensiones.get(rec.Id).get(0).SAC_Entidad_Afectada__c; //Se informará en la creación del caso, se eliminan los automatismos que arrastren la Entidad Afectada desde las pretensiones
                    rec.SAC_EntidadProductora__c = mapaRecPretensiones.get(rec.Id).get(0).SAC_EntidadProductora__c;

                    rec.CC_MCC_Tematica__c = mapaRecPretensiones.get(rec.Id).get(0).CC_MCC_Tematica__c;
                    rec.CC_MCC_ProdServ__c = mapaRecPretensiones.get(rec.Id).get(0).CC_MCC_ProdServ__c;
                    rec.CC_MCC_Motivo__c = mapaRecPretensiones.get(rec.Id).get(0).CC_MCC_Motivo__c;
                    rec.SEG_Detalle__c = mapaRecPretensiones.get(rec.Id).get(0).SEG_Detalle__c;
                    
                    listaRecCambioPretPrincipal.add(rec);
                }
            }
        }        
    }

    /*****************************************************************
     * Proposito: Cuando una reclamación cambia de estado, se debe cambiar el estado de sus pretensiones hijas
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    ****************************************************************/
    /**
     * @description    Cuando una reclamación cambia de estado, se debe cambiar el estado de sus pretensiones hijas
     * @param idsReclaCambiarEstado
     * @param mapaDatosCasosActualizar
     * @param listaFamilaRec
     */
    public static void actualizarEstadosPretension(Set<Id> idsReclaCambiarEstado, Map<Id,Case> mapaDatosCasosActualizar, List<Case> listaFamilaRec){
        

        if(!listaFamilaRec.isEmpty()){
            Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();

            for(Case pret : listaFamilaRec){
                if(pret.RecordTypeId == RECTYPEPRETENSION){
                    if(mapaRecPretensiones.containsKey(pret.SAC_Reclamacion__c) && pret.Status != 'SAC_009') {
                        mapaRecPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
    
                    }else if(pret.Status != 'SAC_009'){
                        List<Case> lista = new List<Case>();
                        lista.add(pret);
                        mapaRecPretensiones.put(pret.SAC_Reclamacion__c, lista);
                    }
                }
            }

            List<Case> pretensionesReclamacion = new List<Case>();
            for(Id ide : mapaRecPretensiones.keySet()){ 
                pretensionesReclamacion.addAll(mapaRecPretensiones.get(ide) );         
            }

            for (Case pretensionSinActualizar : pretensionesReclamacion) {
                if((pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_002' && pretensionSinActualizar.Status == 'SAC_001') ||
                (pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_001' && pretensionSinActualizar.Status == 'SAC_002') ){

                    if(pretensionSinActualizar.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == pretensionSinActualizar.id) {
                        pretensionSinActualizar.SAC_EsPrincipal__c = true;  
                    }

                    pretensionSinActualizar.Status = pretensionSinActualizar.SAC_Reclamacion__r.Status;
                    pretensionSinActualizar.SAC_StatusAuxiliar__c = pretensionSinActualizar.SAC_Reclamacion__r.Status;
                }
            }

            for (Case caso : pretensionesReclamacion) {
                if(mapaDatosCasosActualizar.containsKey(caso.id)){
                    mapaDatosCasosActualizar.get(caso.id).Status = caso.Status;
                    mapaDatosCasosActualizar.get(caso.id).SAC_StatusAuxiliar__c = caso.Status;
                    mapaDatosCasosActualizar.get(caso.id).SAC_EsPrincipal__c = caso.SAC_EsPrincipal__c;
                }else if (!mapaDatosCasosActualizar.containsKey(caso.id)){
                    mapaDatosCasosActualizar.put(caso.id, caso);
                }
            }
        }        
    }


    /***************************************************************** 
     * Proposito: Comprobar que el campo SAC_ResultadoNegociacion__c de la reclamación 
     *              se complete bien cuando se cambia el campo en la pretensión
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     17/07/24        Creación
     * 1.1             US1037919    Álex Polo         24/10/2024      Añadido para tener en cuenta la fase de rectificación
    *****************************************************************/
    /**
     * @description    Comprobar que el campo SAC_ResultadoNegociacion__c de la reclamación se complete bien cuando se cambia el campo en la pretensión
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void comprobarResultadoNegociacion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj) {
        List<Case> listaCambioResultadoNegociacion = new List<Case>();
        List<Case> listaCasosSelect = new List<Case>();
        Set<Id> setIdsCaso = new Set<Id>();

        for (case caso : listCasosSPV) {
            if (mapOldObj.containsKey(caso.Id) && (mapOldObj.get(caso.Id).SAC_ResultadoNegociacion__c != caso.SAC_ResultadoNegociacion__c || mapOldObj.get(caso.Id).SAC_NegociacionFinalizada__c != caso.SAC_NegociacionFinalizada__c)) {
                listaCambioResultadoNegociacion.add(caso);
                setIdsCaso.add(caso.SAC_Reclamacion__c);
            }   
        }
        if(!listaCambioResultadoNegociacion.isEmpty()) {
            if(!setIdsCaso.isEmpty() && Schema.sObjectType.Case.isAccessible()){
                listaCasosSelect = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_ResultadoNegociacion__c, SAC_NegociacionFinalizada__c, SPV_Rectificado__c
                                    FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION) 
                                    AND ((RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsCaso) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN :setIdsCaso))];
            }

            Set<String> resultados = new Set<String>();
            Set<String> resultadosNegociacionFinalizada = new Set<String>();
            Boolean reclamacionNegociacionFnalizada = false;

            String resultadoReclamacion; 
            Id idReclamacion;
            Boolean casoRectificado;    //Añadido --v.1.1
        
            for (Case caso : listaCasosSelect) {
                if(caso.recordTypeId == RECTYPERECLAMACION) {
                    idReclamacion = caso.id;
                    casoRectificado = caso.SPV_Rectificado__c;  //Añadido --v.1.1
                } else if(caso.recordTypeId == RECTYPEPRETENSION && caso.SAC_ResultadoNegociacion__c != null) {
                    resultados.add(caso.SAC_ResultadoNegociacion__c);
                    //Añadido --v.1.1
                    //Se añade a resultadosNegociacionFinalizada para comprobar si todas las pretensiones tienen negociación finalizada
                    if(caso.SAC_NegociacionFinalizada__c != null){      
                        resultadosNegociacionFinalizada.add(String.valueOf(caso.SAC_NegociacionFinalizada__c));
                    }
                }
            }

            if(resultados.contains('Con acuerdo') && resultados.size() == 1) { // Si todas son con acuerdo -> con acuerdo
                resultadoReclamacion = 'Con acuerdo';
            } else if(resultados.contains('Sin acuerdo') && resultados.size() == 1) { // Si todas son sin acuerdo -> sin acuerdo
                resultadoReclamacion = 'Sin acuerdo';
            } else if(resultados.contains('Sin respuesta') && resultados.size() == 1) { // Si todas son sin respuesta -> sin respuesta
                resultadoReclamacion = 'Sin respuesta';
            } else if(resultados.contains('Acuerdo revocado') && resultados.size() == 1) { // Si todas son Acuerdo revocado -> Acuerdo revocado
                resultadoReclamacion = 'Acuerdo revocado';
            } else if(resultados.contains('Con acuerdo') && resultados.contains('Sin acuerdo')) { // Si hay una pretension con acuerdo y otra sin acuerdo -> con acuerdo parcial
                resultadoReclamacion = 'Con acuerdo parcial';
            } else if(resultados.contains('Con acuerdo') && resultados.contains('Acuerdo revocado')) { // Si hay una pretension con acuerdo y otra acuerdo revocado -> con acuerdo parcial
                resultadoReclamacion = 'Con acuerdo parcial';
            } else if(resultados.contains('Con acuerdo') && resultados.contains('Sin respuesta')) { // Si hay una pretension con acuerdo y otra sin respuesta -> con acuerdo
                resultadoReclamacion = 'Con acuerdo';
            } else if(resultados.contains('Sin acuerdo') && resultados.contains('Sin respuesta')) { // Si hay una pretension sin acuerdo y otra sin respuesta -> sin acuerdo
                resultadoReclamacion = 'Sin acuerdo';
            } else if(resultados.contains('Acuerdo revocado') && resultados.contains('Sin respuesta')) { // Si hay una pretension acuerdo revocado y otra sin respuesta -> acuerdo revocado
                resultadoReclamacion = 'Acuerdo revocado';
            } else if(resultados.contains('Acuerdo revocado') && resultados.contains('Sin acuerdo')) { // Si hay una pretension acuerdo revocado y otra sin acuerdo -> sin acuerdo
                resultadoReclamacion = 'Sin acuerdo';
            }
           
            ////Añadido --v.1.1
            //Comprobar sialguna pretensión NO ha finalizado la negociación. Si es así, la reclamación no ha finalizado la negociación
            if(resultadosNegociacionFinalizada.contains('false')){
                reclamacionNegociacionFnalizada = false;
            }else{
                reclamacionNegociacionFnalizada = true;
            }

            if(Schema.sObjectType.Case.isUpdateable()) { 
                Case rec = new Case();
                rec.Id = idReclamacion;
                if(casoRectificado == true){    //Añadido --v.1.1

                    if(rec.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                        caseExtension.SPV_ResultadoNegociacionRectificacion__c  = resultadoReclamacion;
                        caseExtension.SPV_NegociacionFinalizadaRectificacion__c  = reclamacionNegociacionFnalizada;
                        SPV_DatabaseDML.insertDML(caseExtension, false);
                        rec.CBK_Case_Extension_Id__c = caseExtension.Id;   
                    }else{          //Si ya lo tiene
                        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                        caseExtension.Id = rec.CBK_Case_Extension_Id__c;
                        caseExtension.SPV_ResultadoNegociacionRectificacion__c  = resultadoReclamacion;
                        caseExtension.SPV_NegociacionFinalizadaRectificacion__c  = reclamacionNegociacionFnalizada;
                        SPV_DatabaseDML.updateDML(caseExtension, false);
                    }

                    //rec.SPV_ResultadoNegociacionRectificacion__c = resultadoReclamacion;
                    //rec.SPV_NegociacionFinalizadaRectificacion__c = reclamacionNegociacionFnalizada;


                }else{
                    rec.SAC_ResultadoNegociacion__c = resultadoReclamacion;
                    rec.SAC_NegociacionFinalizada__c = reclamacionNegociacionFnalizada;
                }
                
                SPV_DatabaseDML.updateDML(rec, false);
            }
        }
    }    

     /***************************************************************************************** 
     * Proposito: Actualizar el estado de la reclamación cuando se actualiza la pretensión
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     17/07/24        Creación
    *******************************************************************************************/
        /**
     * @description   Actualizar el estado de la reclamación cuando se actualiza la pretensión
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void actualizarEstado(List<Case> listCasosSPV, Map<Id, Case> mapOldObj) {
        List<Case> listaEntradaNegociacion = new List<Case>();
        List<Case> listaSalidaNegociacion = new List<Case>();
        Set<Id> setIdsCaso = new Set<Id>();

        for (case caso : listCasosSPV) {
            if (mapOldObj.containsKey(caso.Id) && caso.SEG_Subestado__c != mapOldObj.get(caso.Id).SEG_Subestado__c && mapOldObj.get(caso.Id).SEG_Subestado__c == 'Negociacion') {
                listaSalidaNegociacion.add(caso);
                setIdsCaso.add(caso.Id);
            }  
        }
        if(!listaSalidaNegociacion.isEmpty()) {
            salidaFaseNegociacion(listaSalidaNegociacion, mapOldObj, setIdsCaso);
        }
    }

    /***************************************************************************************** 
     * Proposito: Actualizar el estado de las pretensiones cuando se sale de la fase de negociación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     17/07/24        Creación
    *******************************************************************************************/
    /**
     * @description   Actualizar el estado de la reclamación cuando se actualiza la pretensión
     * @param listaSalidaNegociacion
     * @param mapOldObj
     * @param setIdsCaso
     */
    public static void salidaFaseNegociacion(List<Case> listaSalidaNegociacion, Map<Id, Case> mapOldObj, Set<Id> setIdsCaso) {
        if(!listaSalidaNegociacion.isEmpty() && !setIdsCaso.isEmpty() && Schema.sObjectType.Case.isAccessible()) {
            List<Case> listaPretensionesHijas = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.Status, Status, SAC_ResultadoNegociacion__c,CaseNumber, SAC_NegociacionFinalizada__c
                                FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN :setIdsCaso ];
            Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();

            for(Case pret : listaPretensionesHijas) {
                if(mapaRecPretensiones.containsKey(pret.SAC_Reclamacion__c) && pret.Status == 'SAC_007') {
                    // Se comprueba que todas las pretensiones que están en negociación tienen relleno el campo "Resultado de negociación"
                    if(pret.SAC_ResultadoNegociacion__c == null) {
                        throw new SPVException('Para salir del estado negociación debe rellenar el campo "Resultado de negociación" de la pretensión número ' + pret.CaseNumber);
                    }
                    // Se comprueba que todas las pretensiones que están en negociación tienen relleno el campo "Negociación Finalizada"
                    if(pret.SAC_NegociacionFinalizada__c == false) {
                        throw new SPVException('Para salir del estado negociación debe marcar el campo "Negociación Finalizada" de la pretensión número ' + pret.CaseNumber);
                    }
                    mapaRecPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
                }else if(pret.Status == 'SAC_007'){
                    // Se comprueba que todas las pretensiones que están en negociación tienen relleno el campo "Resultado de negociación"
                    if(pret.SAC_ResultadoNegociacion__c == null) {
                        throw new SPVException('Para salir del estado negociación debe rellenar el campo "Resultado de negociación" de la pretensión número ' + pret.CaseNumber);
                    }
                    // Se comprueba que todas las pretensiones que están en negociación tienen relleno el campo "Negociación Finalizada"
                    if(pret.SAC_NegociacionFinalizada__c == false) {
                        throw new SPVException('Para salir del estado negociación debe marcar el campo "Negociación Finalizada" de la pretensión número ' + pret.CaseNumber);
                    }
                    List<Case> lista = new List<Case>();
                    lista.add(pret);
                    mapaRecPretensiones.put(pret.SAC_Reclamacion__c, lista);
                }
            }
            List<Case> pretensionesReclamacion = new List<Case>();
            for(Id ide : mapaRecPretensiones.keySet()){ 
                pretensionesReclamacion.addAll(mapaRecPretensiones.get(ide));         
            }


            for (Case pretensionSinActualizar : pretensionesReclamacion) {
                pretensionSinActualizar.Status = pretensionSinActualizar.SAC_Reclamacion__r.Status;
            }

            if(!pretensionesReclamacion.isEmpty() && Schema.sObjectType.Case.isUpdateable()) { 
                SPV_DatabaseDML.updateListDML(pretensionesReclamacion, false);
            }
        }
    }

    /**************************************************************************
     * Proposito: Finaliza las consultas en estado pendiende de respuesta, sin grupo y sin pregunta informados de la reclamación cuando se cierra la reclamación
     * 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    **************************************************************************/
        /**
     * @description   Finaliza las consultas en estado pendiende de respuesta, sin grupo y sin pregunta informados de la reclamación cuando se cierra la reclamación
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void finalizarConsultasReclamacion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj) {

        List<Case> listaReclamacionesConsultasAFinalizar = new List<Case>();
        Set<Id> idsCases = new Set<Id>();

        for (case caso : listCasosSPV) {
            if (mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado') {
                listaReclamacionesConsultasAFinalizar.add(caso);
                idsCases.add(caso.Id);
            } 
        }
        
        if(!listaReclamacionesConsultasAFinalizar.isEmpty() && Schema.sObjectType.SAC_Interaccion__c.isAccessible()){

            Boolean hayError = false;
            Map<Id,Case> mapCasos = new Map<Id,Case>(listaReclamacionesConsultasAFinalizar);

            List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id, SAC_Estado__c, SAC_Reclamacion__c, SAC_MotivoDeFinalizado__c, SAC_GrupoColaborador__r.SAC_PermiteConsultas__c, SAC_GrupoColaborador__r.SAC_TieneUsuariosActivos__c, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_Pregunta__c FROM SAC_Interaccion__c  WHERE RecordTypeId = :RECTYPECONSULTA AND SAC_Reclamacion__c IN: idsCases AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva' OR SAC_Estado__c = '')];
            
            if (!listaConsultasAFinalizar.isEmpty()) {
                for (SAC_Interaccion__c consulta : listaConsultasAFinalizar) {
                    if((consulta.SAC_GrupoColaborador__r.SAC_PermiteConsultas__c && consulta.SAC_GrupoColaborador__r.SAC_TieneUsuariosActivos__c) || (consulta.SAC_GrupoColaborador__r.SAC_PermiteConsultas__c && consulta.SAC_GrupoColaborador__r.SAC_Externo__c)  || (consulta.SAC_GrupoColaborador__c == null && String.isBlank(consulta.SAC_Pregunta__c)) || (consulta.SAC_GrupoColaborador__c != null && String.isNotBlank(consulta.SAC_Pregunta__c))){
                        consulta.SAC_Estado__c = 'SAC_Finalizada';
                        consulta.SAC_MotivoDeFinalizado__c = 'SAC_FinalizadaSinContestar';
                    }else{
                        if(mapCasos.containsKey(consulta.SAC_Reclamacion__c)){
                            mapCasos.get(consulta.SAC_Reclamacion__c).addError('Las consultas no se pueden finalizar debido a que su grupo no tiene el check de permite consultas o no tiene usuarios activos');
                            hayError = true;
                        }
                    }
                }
    
                if(!hayError){
                    SPV_DatabaseDML.updateListDML(listaConsultasAFinalizar, false);
                }
            }
        }
    }


     /***************************************************************************************** 
     * Proposito: Rellenar los campos del caso en el Trigger SPV_CaseBUTRHan
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     30/07/24        Creación
     * 1.1             US1037919      Álex Polo       28/10/2024      Añadidas fechas de envío organismos
    *******************************************************************************************/
    /**
     * @description  Rellenar los campos del caso en el Trigger SPV_CaseBUTRHan
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void rellenarCampos(List<Case> listCasosSPV, Map<Id, Case> mapOldObj) {
        List<Case> listaEntradaNegociacion = new List<Case>();
        List<Case> listaEntradaAllanamiento = new List<Case>();
        List<Case> listaEntradaAlegaciones = new List<Case>();
        List<Case> listaEntradaDesistimiento = new List<Case>();
        List<Case> listaEntraEnvioOrganismos = new List<Case>();
        List<Case> listaEntraPteRespuestaOrganismos = new List<Case>();

        for (case caso : listCasosSPV) {
            //Si el caso pasa a subestado negociación y no habia estado nunca en subestado negociación (el check caso negociado no esta marcado)
            if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && (caso.SEG_Subestado__c == 'Negociacion' && !caso.SAC_CasoNegociado__c)) {
                listaEntradaNegociacion.add(caso);
            }  
            //Si el caso pasa a subestado allanamiento y no habia estado nunca en subestado allanamiento (el check caso allanado no esta marcado)
            if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && (caso.SEG_Subestado__c == 'Allanamiento' && !caso.SPV_CasoAllanado__c)) {
                listaEntradaAllanamiento.add(caso);
            } 
            //Si el caso pasa a subestado alegacion y no habia estado nunca en subestado alegacion (el check caso alegado no esta marcado)
            if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && (caso.SEG_Subestado__c == 'Alegaciones' && !caso.SPV_CasoAlegado__c)) {
                listaEntradaAlegaciones.add(caso);
            } 
            //Si el caso pasa a subestado desistimiento y no habia estado nunca en subestado desistimiento (el check caso allanado no esta marcado)
            if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && (caso.SEG_Subestado__c == 'Desistimiento' && !caso.SPV_CasoDesistido__c)) {
                listaEntradaDesistimiento.add(caso);
            }
            //Añadido: Al pasar a envío organismos, se rellena el campo de fecha correspondiente
            if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SPV_EnvioOrganismos'){
                listaEntraEnvioOrganismos.add(caso);
            }
            //Añadido: Al pasar a Pendiente respuesta organismos, se rellena el campo de fecha correspondiente
            if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SPV_PendienteRespuestaOrganismos'){
                listaEntraPteRespuestaOrganismos.add(caso);
            }
        }
        if(!listaEntradaNegociacion.isEmpty()) {
            rellenarCasoNegociado(listaEntradaNegociacion);
        }  
        if(!listaEntradaAllanamiento.isEmpty()) {
            rellenarCasoAllanado(listaEntradaAllanamiento);
        } 
        if(!listaEntradaAlegaciones.isEmpty()) {
            rellenarCasoAlegado(listaEntradaAlegaciones);
        } 
        if(!listaEntradaDesistimiento.isEmpty()) {
            rellenarCasoDesistido(listaEntradaDesistimiento);
        } 
        //Añadido:
        if(!listaEntraEnvioOrganismos.isEmpty()) {
            rellenarFechaEnvioOrganismos(listaEntraEnvioOrganismos);
        }
        if(!listaEntraPteRespuestaOrganismos.isEmpty()) {
            rellenarFechaPteRespuestaOrganismos(listaEntraPteRespuestaOrganismos);
        } 
    }



    /***********************************************************************************************
     * Proposito: Al pasar al estado "Envío Organismos", se rellena la fecha en la que esto ocurre
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1037919      Álex Polo     28/10/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Al pasar al estado "Envío Organismos", se rellena la fecha en la que esto ocurre
     * @param listaCasoNegociacion
     */
    public static void rellenarFechaEnvioOrganismos(List<Case> listaCasoNegociacion) {
        for (Case caso : listaCasoNegociacion) {

            if(caso.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.SPV_FechaEnvioOrganismos__c  = System.now();
                SPV_DatabaseDML.insertDML(caseExtension, false);
                caso.CBK_Case_Extension_Id__c = caseExtension.Id;   
            }else{          //Si ya lo tiene
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.Id = caso.CBK_Case_Extension_Id__c;
                caseExtension.SPV_FechaEnvioOrganismos__c  = System.now();
                SPV_DatabaseDML.updateDML(caseExtension, false);
            }
        }
    }

    /***********************************************************************************************
     * Proposito: Al pasar al estado "Pendiente Respuesta Organismos", se rellena la fecha en la que esto ocurre
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1037919      Álex Polo     28/10/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Al pasar al estado "Pendiente Respuesta Organismos", se rellena la fecha en la que esto ocurre
     * @param listaCasoNegociacion
     */
    public static void rellenarFechaPteRespuestaOrganismos(List<Case> listaCasoNegociacion) {
        for (Case caso : listaCasoNegociacion) {
            if(caso.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.SPV_FechaPteRespuestaOrganismo__c  = System.now();
                SPV_DatabaseDML.insertDML(caseExtension, false);
                caso.CBK_Case_Extension_Id__c = caseExtension.Id;   
            }else{          //Si ya lo tiene
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.Id = caso.CBK_Case_Extension_Id__c;
                caseExtension.SPV_FechaPteRespuestaOrganismo__c  = System.now();
                SPV_DatabaseDML.updateDML(caseExtension, false);
            }
        }
    }


    /***********************************************************************************************
     * Proposito: Marcar el check SAC_CasoNegociado__c cuando un caso pasa a estado negociación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US974485     Sergio Martín     30/07/24        Creación
     ***********************************************************************************************/
        /**
     * @description  Marcar el check SAC_CasoNegociado__c cuando un caso pasa a estado negociación
     * @param listaCasoNegociacion
     */
    public static void rellenarCasoNegociado(List<Case> listaCasoNegociacion) {
        for (Case caso : listaCasoNegociacion) {
            caso.SAC_CasoNegociado__c = true;
        }
    }

    /***********************************************************************************************
     * Proposito: Marcar el check SPV_CasoAllanado__c cuando un caso pasa a subestado allanamiento
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE         Description
     * 1.0            US1013702     Sergio Martín    23/09/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Marcar el check SPV_CasoAllanado__c cuando un caso pasa a subestado allanamiento
     * @param listaEntradaAllanamiento
     */
    public static void rellenarCasoAllanado(List<Case> listaEntradaAllanamiento) {
        for (Case caso : listaEntradaAllanamiento) {
            caso.SPV_CasoAllanado__c = true;
        }
    }

    /***********************************************************************************************
     * Proposito: Marcar el check SPV_CasoAlegado__c cuando un caso pasa a subestado alegaciones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1013702     Sergio Martín    23/09/24        Creación
     ***********************************************************************************************/
        /**
     * @description  Marcar el check SPV_CasoAlegado__c cuando un caso pasa a subestado alegaciones
     * @param listaEntradaAlegaciones
     */
    public static void rellenarCasoAlegado(List<Case> listaEntradaAlegaciones) {
        for (Case caso : listaEntradaAlegaciones) {
            caso.SPV_CasoAlegado__c = true;
        }
    }

    /***********************************************************************************************
     * Proposito: Marcar el check SPV_CasoDesistido__c cuando un caso pasa a subestado desistimiento
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1013702     Sergio Martín    23/09/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Marcar el check SPV_CasoDesistido__c cuando un caso pasa a subestado desistimiento
     * @param listaEntradaDesistimiento
     */
    public static void rellenarCasoDesistido(List<Case> listaEntradaDesistimiento) {
        for (Case caso : listaEntradaDesistimiento) {
            caso.SPV_CasoDesistido__c = true;
        }
    }


     /***************************************************************************************** 
     * Proposito: Validar los cambios de estado en el Trigger SPV_CaseBUTRHan
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     19/08/24        Creación
     * 1.1             US1013904      Álex Polo         10/09/2024      Añadido alta-análisis
    *******************************************************************************************/
    /**
     * @description  Validar los cambios de estado en el Trigger SPV_CaseBUTRHan
     * @param listCasosSPV
     * @param mapOldObj
     * @param mapNewObj
     */
    public static void validarCambioEstado(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj) {
        List<Case> listaEntradaPretensionNegociacion = new List<Case>();
        Set<Id> setIdsCaso = new Set<Id>();
        List<Case> listaEntradaReclamacionesAnalisis = new List<Case>();

        for (case caso : listCasosSPV) {
            //Si la pretensión pasa a estado negociación
            if (caso.RecordTypeId == RECTYPEPRETENSION && mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status != caso.Status && caso.Status == 'SAC_007') {
                listaEntradaPretensionNegociacion.add(caso);
                setIdsCaso.add(caso.SAC_Reclamacion__c);
            }  

            //Si la reclamación pasa de alta a análisis
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002'){
                listaEntradaReclamacionesAnalisis.add(caso);
            }

        }
        if(!listaEntradaPretensionNegociacion.isEmpty()) {
            validarPasoNegociacionPretension(listaEntradaPretensionNegociacion, mapNewObj);
        }  

        if(!listaEntradaReclamacionesAnalisis.isEmpty()){
            validarCamposEntraAnalisisReclamacion(listaEntradaReclamacionesAnalisis, mapOldObj, mapNewObj);
        }

    }


    /***********************************************************************************************
     * Proposito: Comprobar que no se permite cambiar de alta a análisis si no están informados
     * los campos requeridos
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1013904      Álex Polo       10/09/2024     Creación
     * 1.1             US1037919      Álex Polo       23/10/2024     Cambio la forma de tratar las oficinas afectadas    
     ***********************************************************************************************/
    /**
     * @description  Comprobar que no se permite cambiar de alta a análisis si no están informados
     * los campos requeridos
     * @param listaCasos
     * @param mapOldObj
     * @param mapNewObj
     */
    public static void validarCamposEntraAnalisisReclamacion(List<Case> listaCasos, Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj){

        List<Case> listaPretensiones = new List<Case>();
        Map<Id, List<Case>> mapaPretensiones = new Map<Id, List<Case>>(); //Mapa id reclamación - lista de sus pretensiones
        Map<Id, Account> mapaAccount = new Map<Id, Account>();            //Mapa donde se almacenan las Account asociadas a las reclamaciones
        Set<Id> setIdsReclamaciones = new Set<Id>();
        Set<Id> setIdsAccounts = new Set<Id>();
        List<Account> listaAccounts = new List<Account>();
        
        List<SAC_ImagenDocumento__c> listaOficinasAfectadas = new List<SAC_ImagenDocumento__c>();

        for(Case caso : listaCasos){
            setIdsReclamaciones.add(caso.Id);
            setIdsAccounts.add(caso.AccountId);
        }

        if(!setIdsReclamaciones.isEmpty()){
            listaPretensiones = [SELECT Id, SAC_Reclamacion__c, Status, SAC_EntidadProductora__c, SPV_ObservacionesReclamacion__c, SAC_EsPrincipal__c FROM Case WHERE SAC_Reclamacion__c IN :setIdsReclamaciones AND Status <> 'SAC_009'];
     
            //Obtener las oficinas afectadas relacionadas  -- v. 1.1
            listaOficinasAfectadas = [SELECT Id, SAC_Caso__c FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c IN :setIdsReclamaciones];


        }

            //Se obtienen las cuentas que están asociadas a los casos
            listaAccounts = [SELECT Id, RecordTypeId FROM Account WHERE Id IN :setIdsAccounts];
        

    

        //-- v. 1.1
        //Se crea un mapa en el que se relaciona una reclamación con su oficina afectada (aunque tenga más de una), para controlar que tenga AL MENOS una oficina afectada
        Map<Id, SAC_ImagenDocumento__c> mapaReclamacionOficinasAfectadas = new Map<Id, SAC_ImagenDocumento__c>();
        if(!listaOficinasAfectadas.isEmpty()){
            for(SAC_ImagenDocumento__c oficina : listaOficinasAfectadas){
                if(!mapaReclamacionOficinasAfectadas.containsKey(oficina.SAC_Caso__c)){
                    mapaReclamacionOficinasAfectadas.put(oficina.SAC_Caso__c, oficina);     //Con añadir la primera oficina es suficiente para las comprobaciones
                }
            }
        }


        //Ahora se construirá un mapa con las Account para poder acceder directamente a través de su Id 
        if(!listaAccounts.isEmpty()){
            for(Account cuenta : listaAccounts){
                if(!mapaAccount.containsKey(cuenta.Id)){
                    mapaAccount.put(cuenta.Id, cuenta);
                }
            }
        }

        //Se construye un mapa con clave= id reclamación, donde cada entrada contiene una lista con las pretensiones de su reclamación correspondiente
        if(!listaPretensiones.isEmpty()){
            for(Case pretension : listaPretensiones){
                if(mapaPretensiones.containsKey(pretension.SAC_Reclamacion__c)){
                    mapaPretensiones.get(pretension.SAC_Reclamacion__c).add(pretension);    //Se añade la pretensión a la lista de pretensiones de esa reclamación
                }else{
                    List<Case> listaTemp = new List<Case>();
                    listaTemp.add(pretension);
                    mapaPretensiones.put(pretension.SAC_Reclamacion__c, listaTemp);    //Se crea una nueva entrada en el mapa
                }
                //contadorPrets++;
            }
        }



        for(Case caso : listaCasos){
            
            //Paso de alta a análisis
            if(mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002'){

                //Si tiene una sola pretensión, al pasar a análisis, esa será la principal, asique no hace falta indicar que seleccione una principal
                //Si tiene más de una, será necesario marcar una pretensión como principal
                if(!mapaPretensiones.containsKey(caso.Id)){  //Si la reclamación no está en el mapa, es porque no tiene ninguna pretensión activa
                    caso.addError('No se puede pasar al estado de Análisis sin tener pretensiones activas.');
                }else{  //Si tiene una pretensión solamente, no hace falta que esté marcada como principal, se marcará como tal al pasar a análisis
                    if(mapaPretensiones.get(caso.Id).size() > 1 && (caso.SAC_PretensionPrincipal__c == null || String.isBlank(String.valueOf(caso.SAC_PretensionPrincipal__c)))){
                        caso.addError('No se puede pasar al estado de Análisis sin una pretensión principal informada.');
                    }
                }


                if(caso.SAC_FechaRecepcion__c == null || String.isBlank(String.valueOf(caso.SAC_FechaRecepcion__c))){
                    caso.addError('No se puede pasar al estado de Análisis sin haber establecido la fecha de recepción.');
                }

                if(caso.SPV_Organismo__c == null || String.isBlank(caso.SPV_Organismo__c)){
                    caso.addError('No se puede pasar al estado de Análisis sin haber establecido el Organismo de la reclamación.');
                }

                if(caso.SPV_NumExpediente__c == null || String.isBlank(caso.SPV_NumExpediente__c)){
                    caso.addError('No se puede pasar al estado de Análisis sin haber establecido el número de expediente de la reclamación.');
                }

                /*ANTES:
                if(caso.CC_Oficina_Afectada_Lookup__c == null || String.isBlank(String.valueOf(caso.CC_Oficina_Afectada_Lookup__c))){
                    caso.addError('No se puede pasar al estado de Análisis sin haber establecido la oficina afectada de la reclamación.');
                }*/

                //-- v. 1.1
                //Si el mapa no tiene una entrada con eset caso, es porque no tiene oficina afectada
                if(!mapaReclamacionOficinasAfectadas.containsKey(caso.Id)){
                    caso.addError('No se puede pasar al estado de Análisis sin haber establecido la oficina afectada de la reclamación.');
                }
                

                if(caso.SPV_FechaIniRegulador__c == null || String.isBlank(String.valueOf(caso.SPV_FechaIniRegulador__c ))){
                    caso.addError('No se puede pasar al estado de Análisis sin tener informado el campo Fecha Ini Regulador.');
                }

                if(caso.CC_Recipient_Oficina_Gestora__c == null && caso.CC_No_Identificado__c == false || String.isBlank(caso.CC_Recipient_Oficina_Gestora__c) && caso.CC_No_Identificado__c == false ){
                    if(mapaAccount.containsKey(caso.AccountId) && mapaAccount.get(caso.AccountId).RecordTypeId != RECTYPENOCLIENTE  && (caso.CC_Recipient_Oficina_Gestora__c == null || String.isBlank(caso.CC_Recipient_Oficina_Gestora__c))){
                        caso.addError('No se puede pasar al estado de Análisis sin tener informado el campo Oficina Gestora.');
                    }       
                   /* if(caso.AccountId == null){  //Aquí entra en caso de que no se ahya añadido no cliente o cliente -> porque el campo CC_No_Identificado__c estará a false y su cuenta estrá a null
                        caso.addError('No se puede pasar al estado de Análisis sin tener informado el campo Oficina Gestora.');
                    }*/
                }
 
             
                //Si no hay contact id, pero se ha pulsado en el botón de no se identifica, sí se puede pasar a análisis
                //El botón de no identifica cliente -> cc_no_identificado a true. Si no se ha pulsado, vale false
                //Además, si se ha pulsado, se permite que la oficina gestora no esté rellena
                if(caso.contactId == null && caso.CC_No_Identificado__c == false || String.isBlank(caso.contactId) && caso.CC_No_Identificado__c == false){
                    caso.addError('No se puede pasar al estado de Análisis sin haber seleccionado un contacto.');
                }
           


                //En caso de haber una sola pretensión, al pasar a análisis se establecerá esa como principal
                //Y en ese momento a la reclamación se asignará la entidaqd productora de su única pretensión 
                //Por lo que, en caso de haber solo una pretensión y rec no tener la entidad informada, comprobar que la única pretensión sí la tiene informada
                if(
                  (caso.SAC_EntidadProductora__c == null && mapaPretensiones.containsKey(caso.Id) && mapaPretensiones.get(caso.Id).size() != 1) ||
                  (caso.SAC_EntidadProductora__c == null && mapaPretensiones.containsKey(caso.Id) && mapaPretensiones.get(caso.Id).size() == 1 && mapaPretensiones.get(caso.Id)[0].SAC_EntidadProductora__c == null) 
                  ){
                    caso.addError('No se puede pasar al estado de Análisis sin haber establecido el valor de Entidad productora.');
                  }
            

                //En caso de que todas las pretensiones tengan que tener observación de la reclamación:
                if(mapaPretensiones.containsKey(caso.Id)){
                    //List<Case> listaPretensionesDeReclamacion = mapaPretensiones.get(caso.Id);   //Se obtienen las pretensiones de la reclamación actual (caso)
                    Boolean faltaObservacion = false;   //Si a alguna pretensión le falta observación, se marca a true

                    //DESCOMENTAR SI: hay que comprobar las observaciones en las pretensiones
                    /*if(listaPretensionesDeReclamacion.size() == 1 && (listaPretensionesDeReclamacion[0].SPV_ObservacionesReclamacion__c == null || String.isBlank(listaPretensionesDeReclamacion[0].SPV_ObservacionesReclamacion__c ))){    //En caso de que haya una sola pretensión, esta se convertirá en principal aunque ahora no esté marcada. Se comprueba solo esa.
                            faltaObservacion = true;
                    }else{  	//En caso de haber más de una pretensión, solo se comprueba aquella marcada como 
                        for(Case pretension : listaPretensionesDeReclamacion){
                            if(pretension.SAC_EsPrincipal__c == true && (pretension.SPV_ObservacionesReclamacion__c == null || String.isBlank(pretension.SPV_ObservacionesReclamacion__c))){
                                faltaObservacion = true;
                            }
                        }
                       
                    }

                    //En caso de que el campo observaciones tenga que estar relleno en todas las pretensiones:
                    for(Case pretension : listaPretensionesDeReclamacion){
                        if(pretension.SPV_ObservacionesReclamacion__c == null || String.isBlank(pretension.SPV_ObservacionesReclamacion__c)){
                            faltaObservacion = true;
                        }
                    }*/

                if(faltaObservacion == true){
                    caso.addError('No se puede pasar al estado de Análisis sin haber informado las observaciones de la reclamación en cada pretensión.');
                }

                }

            }
        }


    }


    /***********************************************************************************************
     * Proposito: Verificar que no se pase una pretensión a negociación sin tener la reclamación en ese estado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     19/08/24        Creación
     ***********************************************************************************************/
        /**
     * @description  Verificar que no se pase una pretensión a negociación sin tener la reclamación en ese estado
     * @param listaEntradaPretensionNegociacion
     * @param mapNewObj
     */
    public static void validarPasoNegociacionPretension(List<Case> listaEntradaPretensionNegociacion, Map<Id, Case> mapNewObj) {
        for (Case caso : listaEntradaPretensionNegociacion) {
            //Si la pretensión pasa a estado negociación y su reclamación no está en el subestado de negociación
            if (mapNewObj.containsKey(caso.SAC_Reclamacion__c) && mapNewObj.get(caso.SAC_Reclamacion__c).SEG_Subestado__c != 'Negociacion') {
                caso.addError('No se puede pasar al estado de negociación desde la pretensión, hágalo desde la reclamación.');
            } 
        }
    }

    /***********************************************************************************************
     * Proposito: Atuomatismos que desencadena el cambio de owner de una reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                             Espe Conde     05/08/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Atuomatismos que desencadena el cambio de owner de una reclamación
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void cambioOwnerReclamacion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj) {

        List<Case> listaCambioOwnerReclamacion = new List<Case>();
        Set<Id> setIdsCaso = new Set<Id>();

        for (case caso : listCasosSPV){
            if (mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId){//Si cambia el Owner de la reclamación
                listaCambioOwnerReclamacion.add(caso);
                setIdsCaso.add(caso.Id);
            }
        }

        if (!listaCambioOwnerReclamacion.isEmpty()) {
                List<Case> lstCasosSelect = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId
                                            FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsCaso) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN :setIdsCaso)];


                //Añade permisos para que el gestor de la reclamación pueda modificar las pretensiones hijas, insertando a este los permisos y borra los del antiguo.
                permisosGestor(listaCambioOwnerReclamacion, lstCasosSelect, mapOldObj);
                //Añade permisos para que el gestor de la reclamación pueda modificar las tareas, insertando a este los permisos y borra los del antiguo.
                permisosTareas(listaCambioOwnerReclamacion, lstCasosSelect, mapOldObj);
                //Para las reclamaciones que cambian de owner, se cambia el del reclamante
                cambiarOwnerReclamante(listaCambioOwnerReclamacion);
        } 
    }

    public static void cambiarOwnerReclamante(List<Case> listaOwnersCambiados){

        //Se van a recorrer los casos para almacenar los ids de estos de forma que no haya repetidos, para hacer una única consulta y obtener todos los reclamantes 
        
        Set<Id> idsReclamaciones = new Set<Id>();    //Id de las reclamaciones sin haber repetidos
        Map<Id, Id> mapaOwnersReclamaciones = new Map<Id, Id>();    //Mapa en el que para cada reclamación se relaciona con su nuevo Owner para luego poder asociarselo al reclamante


        for(Case caso : listaOwnersCambiados){
            idsReclamaciones.add(caso.Id);
            if(!mapaOwnersReclamaciones.containsKey(caso.Id)){
                mapaOwnersReclamaciones.put(caso.Id, caso.OwnerId);
            }
        }


        //Se obtienen los reclamantes de las reclamaciones cuyo Owner se ha cambiado
        List<SAC_CaseReclamante__c> listaReclamantes =  [SELECT Id, OwnerId, SAC_Case__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c IN: idsReclamaciones];

        //A cada reclamante se le asigna el nuevo Owner de su reclamación
        for(SAC_CaseReclamante__c reclamante : listaReclamantes){
            if(mapaOwnersReclamaciones.containsKey(reclamante.SAC_Case__c)){
                reclamante.OwnerId = mapaOwnersReclamaciones.get(reclamante.SAC_Case__c);
            }
        }

        SPV_DatabaseDML.updateListDML(listaReclamantes, false);
    } 

    /**
     * @description  Cambio de estado de alta a análisis
     * @param listCasosSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
     */
    public static void cambioAltaAnalisisReclamacion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){

        Set<Id> idsReclaCambiarEstado = new Set<Id>();
        List<Id> listaIdsRec = new List<Id>();
        List<Case> listaBalanceoLetrado = new List<Case>();

        for(Case caso : listCasosSPV){
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && ((mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002'))) {
                //Detectar el cambio de 'Alta' a 'Analisis' de las reclamaciones, para pasar las pretensiones a analisis. A futuro se deberán añadir el resto de cambios de esado
                idsReclaCambiarEstado.add(caso.Id);
                if(mapOldObj.get(caso.Id).Status == 'SAC_001' && caso.Status == 'SAC_002'){
                    //Al pasar de alta a análisis la reclamación, se hace el balanceo de letrado
                    listaBalanceoLetrado.add(caso);
                    
                }
                listaIdsRec.add(caso.Id);
            }
        }

        if(!idsReclaCambiarEstado.isEmpty() || !listaBalanceoLetrado.isEmpty()){

    
            List<Case> listaFamilaRec = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId, SAC_Letrado__c, SPV_VueltaAlta__c, Origin, CC_CasoRelacionado__c, CC_CasoRelacionado__r.SAC_GrupoLetrado__c, CC_CasoRelacionado__r.SAC_GrupoLetrado__r.Name, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.SEG_Detalle__c,
                                                SAC_PretensionPrincipal__r.SEG_Detalle__r.SPV_BalanceoForzado__c, SPV_Organismo__c, SAC_ResultadoNegociacion__c, Status, SAC_Reclamacion__r.Status, SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_Reclamacion__r.CaseNumber, SEG_Grupo__c, SEG_Grupo__r.SAC_Email__c
                                                FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION AND Id IN :listaIdsRec) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN :listaIdsRec)];

            if(!idsReclaCambiarEstado.isEmpty()) {
                //Actualizar el estado de las pretensiones 
                actualizarEstadosPretension(idsReclaCambiarEstado, mapaDatosCasosActualizar, listaFamilaRec);
            }
            if(!listaBalanceoLetrado.isEmpty()){
                Group colaPteAsignarSPV = new Group();
                if(Group.SObjectType.getDescribe().isAccessible()){
                    colaPteAsignarSPV = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
                }

                balanceoLetrado(listaFamilaRec, listaBalanceoLetrado, mapaDatosCasosActualizar, colaPteAsignarSPV);
            }
        }
    }


    /***********************************************************************************************
     * Proposito: Atuomatismos que desencadena el cambio de owner de una pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                             Espe Conde     06/08/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Atuomatismos que desencadena el cambio de owner de una pretensión
     * @param listCasosSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
     */
    public static void cambioOwnerPretension(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar) {

        List<Case> lstPretensiones = new List<Case>();
        List<Case> listaReclamacionesPretension = new List<Case>();
        Set<Id> setIdsCaso = new Set<Id>();
        
        for(Case caso :listCasosSPV){
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId){
                lstPretensiones.add(caso);
                setIdsCaso.add(caso.SAC_Reclamacion__c);
            }
        }
        
        if(!lstPretensiones.isEmpty()){
        
            List<Case> listaCasosSelect = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId, SAC_Letrado__c 
                                    FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsCaso) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN :setIdsCaso)];
        
            if(!listaCasosSelect.isEmpty()){
                Group colaPteAsignarSPV = new Group();
                if(Group.SObjectType.getDescribe().isAccessible()){
                    colaPteAsignarSPV = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
                }

                for(Case reclamacion : listaCasosSelect) {
                    if(setIdsCaso.contains(reclamacion.Id)) {
                        listaReclamacionesPretension.add(reclamacion);
                    }
                }

                //Añade permisos para que el letrado de la pretensión pueda modificar la reclamación padre, insertando a este los permisos y borra los del antiguo.
                permisosLetrado(lstPretensiones, listaCasosSelect, mapOldObj);
                //Añade permisos para que el gestor de la reclamación pueda modificar las pretensiones hijas, insertando a este los permisos y borra los del antiguo.
                permisosGestor(listaReclamacionesPretension, listaCasosSelect, mapOldObj);
                //Añade permisos para que el letrado de la pretensión pueda modificar las tareas, insertando a este los permisos y borra los del antiguo.
                permisosTareas(lstPretensiones, listaCasosSelect, mapOldObj);
                ////Para las reclamaciones que cambian de owner, se cambia el de sus hermanas
                // SPV_Pretension.cambiarOwnersPretsHermanas(lstPretensiones, listaCasosSelect, mapaDatosCasosActualizar);
                // SPV_Pretension.cambioLetrado(lstPretensiones, mapaDatosCasosActualizar, cola, colaSupervisores, colaPteAsignarSPV);
                cambioSLAAsignacionLetrado(lstPretensiones, mapOldObj, colaPteAsignarSPV);
            }
        }

    }



    /***********************************************************************************************
     * Proposito: Al actualizar la entidad productora de la pretensión pricipal, se cambia de su reclamación padre
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US963386        Álex Polo     26/08/24        Creación
     ***********************************************************************************************/
        /**
     * @description  Al actualizar la entidad productora de la pretensión pricipal, se cambia de su reclamación padre
     * @param listCasosSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
     */
    public static void actualizarEntidadProductoraReclamacion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){
        
        List <Case> listaPretensiones = new List<Case>();
        Set <Id> setIdReclamaciones = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();

        //Se almacenan aquellas pretensiones principales a las que le haya cambiado la entidad Productora
        for(Case caso : listCasosSPV){
           
            if(caso.SAC_EsPrincipal__c == true && caso.RecordTypeId == RECTYPEPRETENSION && mapOldObj.get(caso.Id).SAC_EntidadProductora__c != caso.SAC_EntidadProductora__c){
                listaPretensiones.add(caso);
                
                setIdReclamaciones.add(caso.SAC_Reclamacion__C);
            }
        }

        //Se obtienen las reclamaciones correspondientes a dichas pretensiones principales que han cambiado

        if(!setIdReclamaciones.isEmpty()){
            listaReclamaciones = [SELECT Id, SAC_EntidadProductora__c FROM Case WHERE Id IN :setIdReclamaciones];
        }
       
       
        for(Case caso : listaReclamaciones){
            if(!mapaReclamaciones.containsKey(caso.Id)){
                mapaReclamaciones.put(caso.Id, caso);
            }
        }

       
        if(!mapaReclamaciones.isEmpty()){
            for(Case pretension : listaPretensiones){
                if(mapaReclamaciones.containsKey(pretension.SAC_Reclamacion__c)){
                   
                    Case reclamacionNueva = new Case();
                    reclamacionNueva.Id =  mapaReclamaciones.get(pretension.SAC_Reclamacion__c).Id;
                    if(!mapaDatosCasosActualizar.containsKey(reclamacionNueva.Id)){
                     
                        reclamacionNueva.SAC_EntidadProductora__c = pretension.SAC_EntidadProductora__c;
                        mapaDatosCasosActualizar.put(reclamacionNueva.Id, reclamacionNueva);
                    }else{
                        mapaDatosCasosActualizar.get(reclamacionNueva.Id).SAC_EntidadProductora__c = pretension.SAC_EntidadProductora__c;
                    }
                }
           
            }
        }
    }





    /*****************************************************************
     * Proposito: En caso de que la reclamación sea multipretensión, comprueba que haya una pretensión principal asignada.
     * En caso de que no la haya, lanza un error de validación.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US909081      Raúl Santos    24/06/24        Creación
    *****************************************************************/
    /**
     * @description  En caso de que la reclamación sea multipretensión, comprueba que haya una pretensión principal asignada.
     * En caso de que no la haya, lanza un error de validación.
     * @param listaCasos
     * @param listaIdsRec
     */
    public static void validarPretensionPrincipal(List<Case> listaCasos, List<Id> listaIdsRec){ //List<Case> listNewCase, Map<Id, Case> mapOldCase, List<Case> ListaCasoSelect, List<Id> listaIdsRec

        List<Case> listaPretensionesHijas = [SELECT Id, SAC_Reclamacion__c, Status FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN : listaIdsRec];
       
        Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();
        for (Case pretension : listaPretensionesHijas) {
            if (mapaRecPretensiones.containsKey(pretension.SAC_Reclamacion__c) && pretension.Status != 'SAC_009') {
                mapaRecPretensiones.get(pretension.SAC_Reclamacion__c).add(pretension);
            } else if(pretension.Status != 'SAC_009'){
                List<Case> lista = new List<Case>();
                lista.add(pretension);
                mapaRecPretensiones.put(pretension.SAC_Reclamacion__c, lista);
            }
        }

        for (Case caso : listaCasos) {
            if (mapaRecPretensiones.containsKey(caso.Id) && mapaRecPretensiones.get(caso.Id).size() > 1 && String.isBlank(String.valueOf(caso.SAC_PretensionPrincipal__c))) {
                caso.addError('No se puede pasar a Análisis sin que haya una pretensión principal informada');
            }
        }
    
    }


    /*****************************************************************
     * Proposito: Asigna un grupo a la reclamación dependiendo del grupo indicado
     * en el metadata SPV_Configuraciones__mdt
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             23/08/24     Creacion
    *****************************************************************/
    /**
     * @description  Asigna un grupo a la reclamación dependiendo del grupo indicado en el metadata SPV_Configuraciones__mdt
     * @param listaCasosNew
     */
    public static void asignarGrupoReclamacion(List<Case> listaCasosNew) {
        //Almacenar los casos que sean reclamaciones
        List<Case> listaReclamacionesAsignarGrupo = new List<Case>();
        for (Case caso : listaCasosNew) {
            if (caso.RecordTypeId == RECTYPERECLAMACION) {
                listaReclamacionesAsignarGrupo.add(caso);
            }
        }

        //Si se está insertando una reclamación, buscar el metadata con el grupo al que debemos balancear
        if (!listaReclamacionesAsignarGrupo.isEmpty()) {

            List<SPV_Configuraciones__mdt> listaMetadata = new List<SPV_Configuraciones__mdt>();
            listaMetadata = [SELECT SPV_GrupoProveedorReclamaciones__c FROM SPV_Configuraciones__mdt LIMIT 1];

            if (!listaMetadata.isEmpty() && String.isNotBlank(listaMetadata[0].SPV_GrupoProveedorReclamaciones__c)) {
                //Buscar el grupo indicado en el metadata
                List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT Id , CC_Empresa__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOPROVEEDOR AND SAC_DeveloperName__c = :listaMetadata[0].SPV_GrupoProveedorReclamaciones__c];
                if (!listaGrupos.isEmpty()) {
                    for (Case recla : listaReclamacionesAsignarGrupo) {
                        recla.SEG_Grupo__c = listaGrupos[0].Id;
                        if(String.isNotBlank(listaGrupos[0].CC_Empresa__c)){
                             recla.SAC_Empresa__c = listaGrupos[0].CC_Empresa__c;
                        }
                    }
                }
            }
        }
    }
       /*****************************************************************
    * Proposito: Asigna el idPretensión cuando se crea una nueva pretensión
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --               CGomez         29/08/24     Creacion
   *****************************************************************/
     /**
     * @description  Asigna el idPretensión cuando se crea una nueva pretensión
     * @param listaPretensionesNew
     */
    public static void asignarIdPretension(List<Case> listaPretensionesNew){
        
        Map<Id, String> mapPreteIdNumExpediente = new Map<Id, String>();
        List<Id> listaIdsPrete = new List<Id>();      
        List<Case> listaPrete = new List<Case>();

        for(Case prete : listaPretensionesNew){
            listaIdsPrete.add(prete.id);
        }

        List<Case> lstReclamacion= [SELECT id, SAC_Reclamacion__R.SPV_NumExpediente__c FROM Case WHERE id  IN : listaIdsPrete];
        List<Case> lstPretensiones= [SELECT id, SPV_IdPretension__c, CaseNumber FROM Case WHERE id  IN : listaIdsPrete];


        for(Case reclamacion : lstReclamacion) {
            mapPreteIdNumExpediente.put(reclamacion.Id, reclamacion.SAC_Reclamacion__r.SPV_NumExpediente__c);
        }

        for(Case prete : lstPretensiones) {
            if(mapPreteIdNumExpediente.containsKey(prete.Id)) {
                prete.SPV_IdPretension__c = mapPreteIdNumExpediente.get(prete.Id)+'-'+prete.CaseNumber;
                listaPrete.add(prete);
            }
        }
        
        if (!listaPrete.isEmpty()) {
            SPV_DatabaseDML.upsertListDML(listaPrete, false);
        }

    }


    /*****************************************************************
    * Proposito: Al actualizar el número de expediente de una reclamación, en las pretensiones
    * se debe actualizar su id, pues es: numExpediente-caseNumberPretensión
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --              Álex Polo      19/09/24        Creacion
    *****************************************************************/
    /**
     * @description  Al actualizar el número de expediente de una reclamación, en las pretensiones se debe actualizar su id, pues es: numExpediente-caseNumberPretensión
     * @param listaReclamacionesSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
     */
    public static void actualizarIdPretension(List<Case> listaReclamacionesSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){

        List<Case> listaPretensiones = new List<Case>();
        Map <Id, Case> mapaReclamacionesCambiaExpediente = new Map<Id, Case>(); //Reclamaciones con un nuevo número de expediente
        Set <Id> idsReclamacionesNuevoExpediente = new Set<Id>();

        //Unicamente se accede si el nuevo número de expediente es distinto al anterior
        for(Case reclamacion : listaReclamacionesSPV){
            if(mapOldObj.containsKey(reclamacion.Id) && reclamacion.SPV_NumExpediente__c != mapOldObj.get(reclamacion.Id).SPV_NumExpediente__c){
                mapaReclamacionesCambiaExpediente.put(reclamacion.Id, reclamacion);
                idsReclamacionesNuevoExpediente.add(reclamacion.Id);
            }
        }

        //Se obtiene una lista de las pretensiones de la reclamación cuyo número de expediente se ha cambiado
        if(!idsReclamacionesNuevoExpediente.isEmpty()){
            listaPretensiones = [SELECT Id, SPV_IdPretension__c, SAC_Reclamacion__c, CaseNumber FROM Case WHERE SAC_Reclamacion__c IN :idsReclamacionesNuevoExpediente];
        }

        //Después, se actualiza el campo idPretensión de todas esas pretensiones

        if(!listaPretensiones.isEmpty()){
            for(Case pretension : listaPretensiones){

                if(mapaReclamacionesCambiaExpediente.containsKey(pretension.SAC_Reclamacion__c)){
                    //El nuevo idPretensión será el nuevo núm. Expediente de la reclamación + CaseNumber de la pretensión
                    pretension.SPV_IdPretension__c = mapaReclamacionesCambiaExpediente.get(pretension.SAC_Reclamacion__c).SPV_NumExpediente__c + '-' + pretension.CaseNumber;

                    if(!mapaDatosCasosActualizar.containsKey(pretension.Id)){
                        Case pretensionNueva = new Case();
                        pretensionNueva.Id = pretension.Id;
                        pretensionNueva.SPV_IdPretension__c = pretension.SPV_IdPretension__c;
                        mapaDatosCasosActualizar.put(pretensionNueva.Id, pretensionNueva);
                    }else{
                        mapaDatosCasosActualizar.get(pretension.Id).SPV_IdPretension__c = pretension.SPV_IdPretension__c;
                    }
                }
            }
        }


    }



    /*****************************************************************
    * Proposito: Controlar el lanzamiento de alertas de Casos
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --               CS             02/09/24     Creacion
    *****************************************************************/
    /**
     * @description  Controlar el lanzamiento de alertas de Casos
     * @param listaCasosSPV
     * @param mapOldObj
     */
    public static void lanzarAlertas(List<Case> listaCasosSPV, Map<Id, Case> mapOldObj) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        Boolean hacerQuery = false;
        Boolean queryOldOwner = false;
        Set<Id> setIdsReclamaciones = new Set<Id>();
        Set<String> setNameOldOwner = new Set<String>();
        List<Case> listaCasosSelect = new List<Case>();
        List<User> listaUserSelect = new List<User>();
        Map<Id, List<Case>> mapaIdReclaPretensiones = new Map<Id, List<Case>>();
        Map<Id, Case> mapReclamaciones = new Map<Id, Case>();
        Map<Id, String> mapRecOldOwnerPretStr = new Map<Id, String>();
        Map<Id, User> mapRecOldOwnerPret = new Map<Id, User>();
        List<Case> listCasosNegociacion = new List<Case>();
        Group cola = new Group();


        for (Case caso : listaCasosSPV) {
            if (caso.RecordTypeId == RECTYPERECLAMACION){
                if((mapOldObj.get(caso.Id).Status == 'SPV_EnvioOrganismos' && caso.Status == 'SAC_002') || (mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SAC_001') || (mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SPV_EnvioOrganismos') ||
                   (mapOldObj.get(caso.Id).Status == 'SPV_PendienteRespuestaOrganismos' && caso.Status == 'SAC_002' && caso.SPV_Complementaria_Entidad__c == true) || (mapOldObj.get(caso.Id).Status == 'SPV_PendienteRespuestaOrganismos' && caso.Status == 'SPV_Rectificacion')) {
                    setIdsReclamaciones.add(caso.Id);
                    hacerQuery = true;
                }
                if(mapOldObj.get(caso.Id).SAC_GrupoLetrado__c != null && mapOldObj.get(caso.Id).SAC_GrupoLetrado__c != caso.SAC_GrupoLetrado__c){
                    setIdsReclamaciones.add(caso.Id);
                    setNameOldOwner.add(mapOldObj.get(caso.Id).SAC_Letrado__c);
                    mapRecOldOwnerPretStr.put(caso.Id, mapOldObj.get(caso.Id).SAC_Letrado__c);
                    hacerQuery = true;
                    queryOldOwner = true;
                }
            }
        }

        if (hacerQuery) {
            listaCasosSelect = [SELECT Id, RecordTypeId, SAC_Reclamacion__c, OwnerId, SEG_Grupo__r.SAC_Email__c, SAC_PretensionPrincipal__r.OwnerId, SAC_GrupoLetrado__r.SAC_Email__c, Owner.Email, SAC_PretensionPrincipal__r.Owner.Email,
                                    SAC_PretensionPrincipal__r.SEG_Grupo__r.SAC_Email__c
                                FROM Case
                                WHERE (RecordTypeId = :RECTYPEPRETENSION OR RecordTypeId = :RECTYPERECLAMACION) AND (Id = :setIdsReclamaciones OR SAC_Reclamacion__c IN :setIdsReclamaciones)];

            if(Group.SObjectType.getDescribe().isAccessible()){
                cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            }

            if(queryOldOwner && User.SObjectType.getDescribe().isAccessible()){
                listaUserSelect = [SELECT Id, Email FROM User WHERE Name IN :setNameOldOwner];
            }
            
            for (Case caso : listaCasosSelect) {
                if(caso.RecordTypeId == RECTYPERECLAMACION){
                    mapReclamaciones.put(caso.Id, caso);
                }

                if(mapRecOldOwnerPretStr.containsKey(caso.Id)){
                    for (User user : listaUserSelect) {
                        mapRecOldOwnerPret.put(caso.Id, user);
                    }
                }
            }
        }

        for (Case caso : listaCasosSPV) {
            //Si es una reclamación
            if (caso.RecordTypeId == RECTYPERECLAMACION) {
                Case reclamacion = mapReclamaciones.get(caso.Id);

                //Status pasa de análisis a alta
                if (mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SAC_001') {

                    List<String> listaEmails = new List<String>();
                    if(reclamacion.SEG_Grupo__r.SAC_Email__c != null) {
                        listaEmails.add(reclamacion.SEG_Grupo__r.SAC_Email__c);
                    }
                    //Añadir el email del gestor
                    listaEmails.add(reclamacion.Owner.Email);

                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                            'SPV_001',
                                                            'Devolución letrado a gestor. ' + 
                                                            'Se ha devuelto la reclamación ' + caso.CaseNumber + ' a estado de alta. Debe volver a revisar la reclamación.',
                                                            caso.OwnerId,
                                                            '',
                                                            '',
                                                            '');
                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                                            wrapAlerta.listaEmailsGrupo = listaEmails;
                                                            wrapAlerta.idGrupoColaborador = caso.SEG_Grupo__c;
                                                            wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                //Status pasa de análisis a envío organismo
                else if (mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SPV_EnvioOrganismos') {

                    List<String> listaEmails = new List<String>();
                    if(reclamacion.SEG_Grupo__r.SAC_Email__c != null) {
                        listaEmails.add(reclamacion.SEG_Grupo__r.SAC_Email__c);
                    }
                    //Añadir el email del gestor
                    listaEmails.add(reclamacion.Owner.Email);

                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                            'SPV_002',
                                                            'La reclamación ' + caso.CaseNumber + ' a pasado de análisis a Envío organismo.',
                                                            caso.OwnerId,
                                                            '',
                                                            '',
                                                            '');
                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                                            wrapAlerta.listaEmailsGrupo = listaEmails;
                                                            wrapAlerta.idGrupoColaborador = caso.SEG_Grupo__c;
                                                            wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                //Status pasa de envío organismo a análisis
                else if (mapOldObj.get(caso.Id).Status == 'SPV_EnvioOrganismos' && caso.Status == 'SAC_002') {

                    List<String> listaEmails = new List<String>();
                    if(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c != null) {
                        listaEmails.add(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c);
                    }
                    //Añadir el email del letrado
                    listaEmails.add(reclamacion.SAC_PretensionPrincipal__r.Owner.Email);
                
                    //Se envia alerta el owner de las pretensiones y al grupo letrado
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                    'SPV_003',
                                                    'La reclamación ' + caso.CaseNumber + ' a pasado de Envío organismo a análisis.',
                                                    reclamacion.SAC_PretensionPrincipal__r.OwnerId,
                                                    '',
                                                    '', 
                                                    '');
                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                                    wrapAlerta.listaEmailsGrupo = listaEmails;
                                                    wrapAlerta.idGrupoColaborador = caso.SAC_GrupoLetrado__c;
                                                    wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                //Status pasa de pendiente respuesta organismos a análisis y tenga la complementaria entidad activa
                else if (mapOldObj.get(caso.Id).Status == 'SPV_PendienteRespuestaOrganismos' && caso.Status == 'SAC_002' && caso.SPV_Complementaria_Entidad__c == true) {

                    List<String> listaEmails = new List<String>();
                    if(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c != null) {
                        listaEmails.add(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c);
                    }
                    //Añadir el email del letrado
                    listaEmails.add(reclamacion.SAC_PretensionPrincipal__r.Owner.Email);

                    //Se envia alerta el owner de las pretensiones y al grupo letrado
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                    'SPV_011',
                                                    'La reclamación ' + caso.CaseNumber + ' a pasado de Pendiente respuesta organismo a análisis.',
                                                    reclamacion.SAC_PretensionPrincipal__r.OwnerId,
                                                    '',
                                                    '', 
                                                    '');
                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                                    wrapAlerta.listaEmailsGrupo = listaEmails;
                                                    wrapAlerta.idGrupoColaborador = caso.SAC_GrupoLetrado__c;
                                                    wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                //Reasignación grupo letrado (grupo letrado diferente al que inicialmente se había asignado)
                else if (mapOldObj.get(caso.Id).SAC_GrupoLetrado__c != null && mapOldObj.get(caso.Id).SAC_GrupoLetrado__c != caso.SAC_GrupoLetrado__c) {

                    if(mapRecOldOwnerPret.containsKey(caso.Id)){
                        List<String> listaEmails = new List<String>();
                        if(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c != null) {
                            listaEmails.add(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c);
                        }
                        //Añadir el email del letrado antiguo
                        listaEmails.add(mapRecOldOwnerPret.get(caso.Id).Email);

                        //Se envia alerta el owner de las pretensiones y al grupo letrado
                        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                        'SPV_013',
                                                        'La reclamación ' + caso.CaseNumber + ' ha sido reasignada a otro letrado.',
                                                        mapRecOldOwnerPret.get(caso.Id).Id,
                                                        '',
                                                        '', 
                                                        '');
                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                                        wrapAlerta.listaEmailsGrupo = listaEmails;
                                                        wrapAlerta.idGrupoColaborador = caso.SAC_GrupoLetrado__c;
                                                        wrapAlerta.proyecto = 'SPV';
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                }
                //Status pasa de Pendiente respeusta organismo a Rectificacion
                else if (mapOldObj.get(caso.Id).Status == 'SPV_PendienteRespuestaOrganismos' && caso.Status == 'SPV_Rectificacion') {

                    List<String> listaEmails = new List<String>();
                    if(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c != null) {
                        listaEmails.add(reclamacion.SAC_GrupoLetrado__r.SAC_Email__c);
                    }
                    //Añadir el email del letrado
                    if(String.isNotBlank(reclamacion.SAC_PretensionPrincipal__r.Owner.Email)) {
                        listaEmails.add(reclamacion.SAC_PretensionPrincipal__r.Owner.Email);
                    }

                    //Se envia alerta el owner de las pretensiones y al grupo letrado
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                    'SPV_014',
                                                    'La reclamación ' + caso.CaseNumber + ' ha pasado de Pendiente respuesta Organismo a Rectificación.',
                                                    reclamacion.SAC_PretensionPrincipal__r.OwnerId,
                                                    '',
                                                    '', 
                                                    '');
                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                                    wrapAlerta.listaEmailsGrupo = listaEmails;
                                                    wrapAlerta.idGrupoColaborador = caso.SAC_GrupoLetrado__c;
                                                    wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                //Si el subestado es 'Negociacion', lanzar schedulable  para dentro de 7 dias comprobar si sigue en negociación y mandar alerta
                else if (mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && caso.SEG_Subestado__c == 'Negociacion') {
                    listCasosNegociacion.add(caso);
                }
            }
        }

        //Si tenemos reclamaciones en subestado negociacion, debemos crear el pending process para la ejecucion de sus alertas
        if (!listCasosNegociacion.isEmpty()) {
            scheduleAlertaNegociacion(listCasosNegociacion);
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /**************************************************************************
    * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 7 dias.
    * La clase schedulable creará una alerta si la reclamación sigue en negociación.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --             Raúl Santos    25/09/24         Creacion
    **************************************************************************/
    /**
     * @description  Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 7 dias.
     * @param listNewRecPret
     */
    public static void scheduleAlertaNegociacion(List<Case> listNewRecPret) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (Case caso : listNewRecPret) {
            CBK_SCH_PendingProcess__c pendingProcessCaso = new CBK_SCH_PendingProcess__c();
            pendingProcessCaso.recordId__c = caso.Id;
            pendingProcessCaso.Schedule_Time__c = system.now().addDays(7);
            pendingProcessCaso.className__c = 'SAC_SchedulableNegociacion';
            listaPendingProcess.add(pendingProcessCaso);
        }

        if (!listaPendingProcess.isEmpty()) {
            SPV_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    }

    /*****************************************************************
    * Proposito: Informar el MCC y las entidades de la pretension principal en la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0               ---         Raúl Santos    18/09/24         Creacion
    *****************************************************************/
    /**
     * @description  Informar el MCC y las entidades de la pretension principal en la reclamación
     * @param listaCasosSPV
     * @param mapOldObj
     */
    public static void actualizarMCCYEntidadRelamacion(List<Case> listaCasosSPV, Map<Id, Case> mapOldObj) {

        List<Case> listaRecCambioPretPrincipal = new List<Case>();
        Set<Id> setIdesCambioPretPrincipal = new Set<Id>();

        for(Case caso : listaCasosSPV){
            if (mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_PretensionPrincipal__c != caso.SAC_PretensionPrincipal__c) {
                setIdesCambioPretPrincipal.add(caso.SAC_PretensionPrincipal__c);
                listaRecCambioPretPrincipal.add(caso);
            }
        }

        if(!listaRecCambioPretPrincipal.isEmpty()){

            Map<Id, Case> mapaReclamaciones = new Map<Id, Case>(listaRecCambioPretPrincipal);

            List<Case> listaPretensiones = [SELECT Id,SAC_Reclamacion__c, Status, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND Id = :setIdesCambioPretPrincipal];

            for (Case pretension : listaPretensiones) {
                if (String.isNotBlank(pretension.SAC_Reclamacion__c) && mapaReclamaciones.containsKey(pretension.SAC_Reclamacion__c) && pretension.Status != 'SAC_009') {
                    mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_MCC_Tematica__c = pretension.CC_MCC_Tematica__c;
                    mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_MCC_ProdServ__c = pretension.CC_MCC_ProdServ__c;
                    mapaReclamaciones.get(pretension.SAC_Reclamacion__c).CC_MCC_Motivo__c   = pretension.CC_MCC_Motivo__c;
                    mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SEG_Detalle__c     = pretension.SEG_Detalle__c;
    
                    // mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SAC_Entidad_Afectada__c = pretension.SAC_Entidad_Afectada__c; //Se informará en la creación del caso, se eliminan los automatismos que arrastren la Entidad Afectada desde las pretensiones
                    mapaReclamaciones.get(pretension.SAC_Reclamacion__c).SAC_EntidadProductora__c = pretension.SAC_EntidadProductora__c;
                
                }
            }
        }
    }


    /*****************************************************************************************
     * Proposito: Al tomar en propiedad una pretensión, se actualiza el Owner de todas las
     *  pretensiones hermanas, y se actualiza el campo SAC_Letrado__c en la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1025762      Álex Polo     26/09/24        Creación
    **********************************************************************************************/
    /**
     * @description  Al tomar en propiedad una pretensión, se actualiza el Owner de todas las
     *  pretensiones hermanas, y se actualiza el campo SAC_Letrado__c en la reclamación
     * @param listaPretensiones
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
     */
    public static void actualizarOwnerPretensionesHermanas(List <Case> listaPretensiones, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){
        
        //coger la reclamación y las pretensiones hermanas
        List<Case> listaPretensionesCambiaOwner = new List<Case>();     //Pretensiones y reclamación de la pretensión que ha cambiado el owner
        Set<Id> idsReclamacionesPadre = new Set<Id>();                  //Ids de las reclamaciones cuya pretensión ha cambiado de owner
        Set<Id> idsUsuarios= new Set<Id>();                             //Set de ids donde se almacenan los nuevos owner
        Map<Id, Id> mapaReclamacionNuevoOwnwer = new Map<Id, Id>();     //Mapa id padre - id nuevo owner pretensiones
        List<Case> listaPretensionesCambiaOwnerInicial = new List<Case>();  //Lista donde se almacenan las pretensiones que han cambiado de owner (las que vienen del trigger)


        for(Case pretension : listaPretensiones){
            if(mapOldObj.containsKey(pretension.Id) && mapOldObj.get(pretension.Id).OwnerId != pretension.OwnerId){         //Si la pretensión ha cambiado de owner
                listaPretensionesCambiaOwnerInicial.add(pretension);
                idsReclamacionesPadre.add(pretension.SAC_Reclamacion__C);
                idsUsuarios.add(pretension.OwnerId);
                if(!mapaReclamacionNuevoOwnwer.containsKey(pretension.SAC_Reclamacion__C)){
                    mapaReclamacionNuevoOwnwer.put(pretension.SAC_Reclamacion__C, pretension.OwnerId);  //Mapa indicando el nuevo owner de las pretensiones de la reclamación cuyo id es el que hay en pretension.SAC_Reclamacion__C
                }

            }
        }

        //Se obtienen todas las pretensiones hermanas de las pretensiones cuyo owner haya cambiado
        if(!idsReclamacionesPadre.isEmpty()){
            listaPretensionesCambiaOwner = [SELECT Id, OwnerId, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c IN :idsReclamacionesPadre];
        }
        

        //Se añaden al mapaCasosActualizar las pretensiones hermanas con el nuevo owner cambiado
        if(!listaPretensionesCambiaOwner.isEmpty()){
            for(Case pretension : listaPretensionesCambiaOwner){
                if(mapaDatosCasosActualizar.containsKey(pretension.Id)){
                    mapaDatosCasosActualizar.get(pretension.Id).OwnerId = mapaReclamacionNuevoOwnwer.get(pretension.SAC_Reclamacion__c);
                }else{
                    Case nuevaPretension = new Case();
                    nuevaPretension.Id = pretension.Id;
                    nuevaPretension.OwnerId = mapaReclamacionNuevoOwnwer.get(pretension.SAC_Reclamacion__c);
                    mapaDatosCasosActualizar.put(nuevaPretension.Id, nuevaPretension);
                }
            }
        }

        //Actualización de SAC_Letrado__c en la reclamación: 

        //Se recuperan los usuarios que son los nuevos owner
        List<User> listaUsuarios = new List<User>();

        if(!idsUsuarios.isEmpty() && User.SObjectType.getDescribe().isAccessible()){
            listaUsuarios = [SELECT Id, Name FROM User WHERE Id IN :idsUsuarios];
        }
        


        //Crear mapa con los usuarios obtenidos
        Map<Id, User> mapaUsersOwners = new Map<Id, User>();
        if(!listaUsuarios.isEmpty()){
            for(User usuario : listaUsuarios){
                if(!mapaUsersOwners.containsKey(usuario.Id)){
                    mapaUsersOwners.put(usuario.Id, usuario);
                }
            }
        }


        //Añadir al mapa de casos a actualizar, las reclamaciones cuyas pretensiones hayan cambiado de owner, con el campo SAC_Letrado__c actualizado
        for(Case pretension : listaPretensionesCambiaOwnerInicial){
            if(mapaDatosCasosActualizar.containsKey(pretension.SAC_Reclamacion__c)){

                if(!mapaUsersOwners.containskey(pretension.OwnerId)){       //Si en el mapa de usuarios no está el nuevo owner, es porque se ha devuelto el caso (no hay usuario que se corresponda con el nuevo owner)
                    mapaDatosCasosActualizar.get(pretension.SAC_Reclamacion__c).SAC_Letrado__c = 'Pte. Asignar'; 
                }else{                                                      //Si sí está, se indica que el letrado de la reclamación es el Name del usuario
                    mapaDatosCasosActualizar.get(pretension.SAC_Reclamacion__c).SAC_Letrado__c = mapaUsersOwners.get(pretension.OwnerId).Name;
                }
                
            }else{

                Case nuevaReclamacion = new Case();
                nuevaReclamacion.Id = pretension.SAC_Reclamacion__c;
                if(!mapaUsersOwners.containskey(pretension.OwnerId)){
                    nuevaReclamacion.SAC_Letrado__c = 'Pte. Asignar';
                }else{
                    nuevaReclamacion.SAC_Letrado__c = mapaUsersOwners.get(pretension.OwnerId).Name;
                }
                mapaDatosCasosActualizar.put(nuevaReclamacion.Id, nuevaReclamacion);

            }
        }
    }


    /*****************************************************************
    * Proposito: Al seleccionar una oficina afectada en la reclamación, se crea un registro de SAC_ImagenDocumento
    * donde se relaciona el caso con sus oficinas afectadas
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1037919       Álex Polo      17/10/24         Creacion
    *****************************************************************/
        /**
     * @description  Al seleccionar una oficina afectada en la reclamación, se crea un registro de SAC_ImagenDocumento
    * donde se relaciona el caso con sus oficinas afectadas
     * @param listCasosSPV
     * @param mapOldObj
     * @param mapaDatosCasosActualizar
     */
    public static void addOficinaAfectada(List<Case> listCasosSPV, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){

        Set<Id> listaIdsReclamaciones = new Set<Id>();
        List<Case> listaReclamacionesAddOficina = new List<Case>();
        Map<Id, Case> mapaReclamacionesAddOficina = new Map<Id, Case>();

        Map<Id, List<Account>> mapaRecalmacionAccounts = new Map<Id, List<Account>>();
        Set<Id> idsAccounts = new Set<Id>();

        
        //Obtener aquellas reclamaciones a las que se le hayan añadido una oficina afectada
        for(Case reclamacion : listCasosSPV){
            if(mapOldObj.containsKey(reclamacion.Id) && mapOldObj.get(reclamacion.Id).CC_Oficina_Afectada_Lookup__c == null && reclamacion.CC_Oficina_Afectada_Lookup__c != null){
                listaReclamacionesAddOficina.add(reclamacion);
                listaIdsReclamaciones.add(reclamacion.Id);
                if(!mapaReclamacionesAddOficina.containsKey(reclamacion.Id)){
                    mapaReclamacionesAddOficina.put(reclamacion.Id, reclamacion);
                }
                idsAccounts.add(reclamacion.CC_Oficina_Afectada_Lookup__c);
            }
        }

        //Buscar todas las oficinas afectadas que ya tiene la reclamación para no añadir repetidos
        Map<Id, Map<Id, Id>> mapaReclamacionOficinasYaExistentes = new Map<Id, Map<Id, Id>>();    //Mapa en el que cada id de reclamación se relaciona con los id de oficinas que tiene añadidas
        List<SAC_ImagenDocumento__c> listaOficinasYaExistentes = new List<SAC_ImagenDocumento__c>();
        
            listaOficinasYaExistentes = [SELECT Id, SAC_Caso__c, SPV_OficinaAfectada_Lookup__c FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c IN :listaIdsReclamaciones];
        


        //Se rellena un mapa en el que a cada reclamación se le relacciona con los ids de oficinas que tiene añadidas
        if(!listaOficinasYaExistentes.isEmpty()){
            for(SAC_ImagenDocumento__c objIntermedio : listaOficinasYaExistentes){
                if(!mapaReclamacionOficinasYaExistentes.containsKey(objIntermedio.SAC_Caso__c)){
                    mapaReclamacionOficinasYaExistentes.put(objIntermedio.SAC_Caso__c, new Map<Id, Id>());
                    mapaReclamacionOficinasYaExistentes.get(objIntermedio.SAC_Caso__c).put(objIntermedio.SPV_OficinaAfectada_Lookup__c, objIntermedio.SPV_OficinaAfectada_Lookup__c);   //Se añade el id de Account como un Map para poder acceder haciendo .get y comprobar si está haciendo .containsKey
                }else{
                    mapaReclamacionOficinasYaExistentes.get(objIntermedio.SAC_Caso__c).put(objIntermedio.SPV_OficinaAfectada_Lookup__c, objIntermedio.SPV_OficinaAfectada_Lookup__c);
                }
            }
        }

        //Se recuperan los datos de las Account que se van a añadir como oficinas afectadas
        Map<Id,Account> mapAccount = new Map<Id, Account>();
        if(!idsAccounts.isEmpty()){
            mapAccount = new Map<Id, Account>([SELECT Id, CC_Email__c,Name, CC_Tipo_Centro__c, ParentId, Parent.CC_Tipo_Centro__c, Parent.ParentId, 
            Parent.Parent.CC_Tipo_Centro__c, Parent.Parent.ParentId, Parent.Parent.Parent.CC_Tipo_Centro__c, Parent.Parent.Parent.ParentId
            FROM Account WHERE Id IN :idsAccounts]);
        }

        //Se rellena un mapa en el que se relacciona cada reclamación con un listado de las oficinas afectadas que se le van a añadir a ella
        if(!listaReclamacionesAddOficina.isEmpty()){

            for(Case reclamacion : listaReclamacionesAddOficina){

                if(mapAccount.containsKey(reclamacion.CC_Oficina_Afectada_Lookup__c)){
                    Account oficina = mapAccount.get(reclamacion.CC_Oficina_Afectada_Lookup__c);            //Se obtiene la oficina cuyo id se tiene en la reclamación, que se obtuvo en la query de Accounts
    
                    if(!mapaRecalmacionAccounts.containsKey(reclamacion.Id)){
                        List<Account> listaOficinasRecla = new List<Account>();
                        listaOficinasRecla.add(oficina);
                        mapaRecalmacionAccounts.put(reclamacion.Id, listaOficinasRecla);
                    }else{
                        mapaRecalmacionAccounts.get(reclamacion.Id).add(oficina);
                    }
                }
            }
        }

 
        List<SAC_ImagenDocumento__c> listaReclaOficina = new List<SAC_ImagenDocumento__c>();

        //Para cada reclamación que haya añadido una oficina, se crea un objeto intermedio que indique la relación de esa oficina con la reclamación
        if(!listaReclamacionesAddOficina.isEmpty()){
            for(Case reclamacion : listaReclamacionesAddOficina){

                //Entra si va a añadir al menos una oficina, es decir, si la lista de oficinas a añadir para esa reclamación no está vacía 
                if(mapaRecalmacionAccounts.containsKey(reclamacion.Id) && !mapaRecalmacionAccounts.get(reclamacion.Id).isEmpty()){
    
                    List<Account> listaOficinasAfectadasReclamacion = mapaRecalmacionAccounts.get(reclamacion.Id);
                    
                    for(Account oficina : listaOficinasAfectadasReclamacion){
        
                        //Comprobar si la reclamación ya tiene esta oficina añadida:
                        Boolean esRepetida = false;
                        //Si la reclamación está en el siguiente mapa, es que tiene oficinas añadidas. Ver si la que se quiere añadir no es repetida
                        if(mapaReclamacionOficinasYaExistentes.containsKey(reclamacion.Id) && mapaReclamacionOficinasYaExistentes.get(reclamacion.Id).containsKey(oficina.Id)){
                            esRepetida = true;  //Si es repetida, no se añadirá
                        }
        
                        if(esRepetida == false){
        
                            SAC_ImagenDocumento__c nuevoObjIntermedio = new SAC_ImagenDocumento__c();
                            nuevoObjIntermedio.SAC_Caso__c = reclamacion.Id;
                            //nuevoObjIntermedio.SPV_OficinaAfectada_Lookup__c = reclamacion.CC_Oficina_Afectada_Lookup__c;
                            nuevoObjIntermedio.SPV_OficinaAfectada_Lookup__c = oficina.Id;
                            nuevoObjIntermedio.RecordTypeId = RECTYPEOFICINAS;
                
            
                            //Añadirle el DAN de la oficina afectada
                           
                             if(oficina.Parent.CC_Tipo_Centro__c == 'GC'){
                                    nuevoObjIntermedio.SPV_DAN_OficinaAfectada__c = oficina.ParentId;
                                }else if(oficina.Parent.Parent.CC_Tipo_Centro__c == 'GC'){
                                        nuevoObjIntermedio.SPV_DAN_OficinaAfectada__c = oficina.Parent.ParentId;
                                }else if(oficina.Parent.Parent.Parent.CC_Tipo_Centro__c == 'GC'){
                                            nuevoObjIntermedio.SPV_DAN_OficinaAfectada__c = oficina.Parent.Parent.ParentId;
                                } else if(oficina.Parent.Parent.Parent.Parent.CC_Tipo_Centro__c == 'GC'){
                                                nuevoObjIntermedio.SPV_DAN_OficinaAfectada__c = oficina.Parent.Parent.Parent.ParentId;
                                }else{
                                    nuevoObjIntermedio.SPV_DAN_OficinaAfectada__c = null;
                                }
            
            
                            listaReclaOficina.add(nuevoObjIntermedio);
                
                            //Al crear el correspondiente objeto intermedio, vaciar de nuevo el campo oficina afectada de la reclamación para que si se desea puedan añadir más oficinas
                            if(!mapaDatosCasosActualizar.containskey(reclamacion.Id)){
                                Case nuevaReclamacion = new Case();
                                nuevaReclamacion.Id = reclamacion.Id;
                                nuevaReclamacion.CC_Oficina_Afectada_Lookup__c =null;
                                mapaDatosCasosActualizar.put(nuevaReclamacion.Id, nuevaReclamacion);
                            }else{
                                mapaDatosCasosActualizar.get(reclamacion.Id).CC_Oficina_Afectada_Lookup__c = null;
                            }
                        }else{
                            reclamacion.addError('La oficina que se intenta añadir ya fue añadida.');
                        }
        
                    }
    
                }
    
            }
        }



        if(!listaReclaOficina.isEmpty()){
            SPV_DatabaseDML.insertListDML(listaReclaOficina, false);
        }
    }




    /*****************************************************************
    * Proposito: Arrastrar el estado de las pretensiones que no se encuentran en baja
    *           al estado en el que está la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1013702     Sergio Martín   20/09/24         Creacion
    * 1.1            US1036419      Álex Polo      09/10/24         Añadida vuelta a alta
    *****************************************************************/
    /**
     * @description  Arrastrar el estado de las pretensiones que no se encuentran en baja al estado en el que está la reclamación
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void arrastrarEstadoReclamacionPretension(List<Case> listCasosSPV, Map<Id, Case> mapOldObj){

        Set<Id> listaIdsReclamaciones = new Set<Id>();
        List<Case> listaPasoEnvioOrganismos = new List<Case>();
        List<Case> listaPasoPendienteRespuestaOrganismos = new List<Case>();
        List<Case> listaVueltaAnalisis = new List<Case>();
        List<Case> listaVueltaAlta = new List<Case>();
        List<Case> listaCerrarReclamaciones = new List<Case>();
        List<Case> listaDescartarReclamaciones = new List<Case>();
        List<Case> listaPasoRectificacion = new List<Case>();


        for(Case caso : listCasosSPV){
            //Detectar el cambio de estado a "Envio Organismo"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SPV_EnvioOrganismos') {
                listaIdsReclamaciones.add(caso.Id);
                listaPasoEnvioOrganismos.add(caso);
            }
            //Detectar el cambio de estado a "Pendiente Respuesta Organismo"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SPV_PendienteRespuestaOrganismos') {
                listaIdsReclamaciones.add(caso.Id);
                listaPasoPendienteRespuestaOrganismos.add(caso);
            }

            //Detectar el cambio de estado de "Envio Organismo" a "Análisis"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && mapOldObj.get(caso.Id).Status == 'SPV_EnvioOrganismos' && caso.Status == 'SAC_002') {
                listaIdsReclamaciones.add(caso.Id);
                listaVueltaAnalisis.add(caso);
            }

            //Detectar el cambio de estado de "Pendiente Respuesta Organismo" a "Análisis"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && mapOldObj.get(caso.Id).Status == 'SPV_PendienteRespuestaOrganismos' && caso.Status == 'SAC_002') {
                listaIdsReclamaciones.add(caso.Id);
                listaVueltaAnalisis.add(caso);
            }

            //Detectar el cambio de estado de "Análisis" a "Alta"
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).Status == 'SAC_002' && caso.Status == 'SAC_001'){
                listaIdsReclamaciones.add(caso.Id);
                listaVueltaAlta.add(caso);
            }

            //Detectar el cambio de estado a "Cerrado"
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado'){
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarReclamaciones.add(caso);
            }

            //Detectar el cambio de estado a "Descartado"
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Descartado'){
                listaIdsReclamaciones.add(caso.Id);
                listaDescartarReclamaciones.add(caso);
            }

            //Detectar el cambio de estado a "Rectificación"
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'SPV_Rectificacion'){
                listaIdsReclamaciones.add(caso.Id);
                listaPasoRectificacion.add(caso);
            }
        }


        if(!listaIdsReclamaciones.isEmpty()){
            List<Case> listaFamilaRec = [SELECT Id, OwnerId, recordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId, SAC_Letrado__c, Origin, CC_CasoRelacionado__c, CC_CasoRelacionado__r.SAC_GrupoLetrado__c, CC_CasoRelacionado__r.SAC_GrupoLetrado__r.Name, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.SEG_Detalle__c,
                                                SAC_PretensionPrincipal__r.SEG_Detalle__r.SPV_BalanceoForzado__c, SPV_Organismo__c, SAC_ResultadoNegociacion__c, Status, SAC_Reclamacion__r.Status, SAC_Reclamacion__r.SAC_PretensionPrincipal__c
                                                FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION AND Id IN :listaIdsReclamaciones) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__C IN :listaIdsReclamaciones)];

            if(!listaPasoEnvioOrganismos.isEmpty()){
                //Actualizar el estado de las pretensiones a "Envio Organismo"
                actualizarEstadosReclamacionPretension(listaIdsReclamaciones, listaFamilaRec);
            }
            if(!listaPasoPendienteRespuestaOrganismos.isEmpty()){
                //Actualizar el estado de las pretensiones a "Pendiente Respuesta Organismo"
                actualizarEstadosReclamacionPretension(listaIdsReclamaciones, listaFamilaRec);
            }
            if(!listaVueltaAnalisis.isEmpty()){
                //Actualizar el estado de las pretensiones a "Analisis"
                actualizarEstadosReclamacionPretension(listaIdsReclamaciones, listaFamilaRec);
            }

            if(!listaVueltaAlta.isEmpty()){
                //Actualizar el estado de las pretensiones que pasan a "Alta"
                actualizarEstadosReclamacionPretension(listaIdsReclamaciones, listaFamilaRec);
            }

            if(!listaPasoRectificacion.isEmpty()){
                //Actualizar el estado de las pretensiones que pasan a "Rectificacion"
                actualizarEstadosReclamacionPretension(listaIdsReclamaciones, listaFamilaRec);
            }

            if(!listaCerrarReclamaciones.isEmpty() || !listaDescartarReclamaciones.isEmpty()){
                //Actualizar el estado de las pretensiones que pasan a "Cerrado" o "Descartado"
                actualizarEstadosReclamacionPretension(listaIdsReclamaciones, listaFamilaRec);
            }            
        }
    }


    /*****************************************************************
     * Proposito: Cuando una reclamación cambia de estado, se debe cambiar el estado de sus pretensiones hijas activas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1013702     Sergio Martín   20/09/24         Creacion
    ****************************************************************/
    /**
     * @description  Cuando una reclamación cambia de estado, se debe cambiar el estado de sus pretensiones hijas activas
     * @param idsReclaCambiarEstado
     * @param listaFamilaRec
     */
    public static void actualizarEstadosReclamacionPretension(Set<Id> idsReclaCambiarEstado, List<Case> listaFamilaRec){
        if(!listaFamilaRec.isEmpty()){
            Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();

            for(Case pret : listaFamilaRec){
                if(pret.RecordTypeId == RECTYPEPRETENSION){
                    if(mapaRecPretensiones.containsKey(pret.SAC_Reclamacion__c) && pret.Status != 'Descartado') {
                        mapaRecPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
    
                    }else if(pret.Status != 'Descartado'){
                        List<Case> lista = new List<Case>();
                        lista.add(pret);
                        mapaRecPretensiones.put(pret.SAC_Reclamacion__c, lista);
                    }
                }
            }

            List<Case> pretensionesReclamacion = new List<Case>();
            for(Id ide : mapaRecPretensiones.keySet()){ 
                pretensionesReclamacion.addAll(mapaRecPretensiones.get(ide) );         
            }

            for (Case pretensionSinActualizar : pretensionesReclamacion) {
                pretensionSinActualizar.Status = pretensionSinActualizar.SAC_Reclamacion__r.Status;
            }

            if(!pretensionesReclamacion.isEmpty() && Schema.sObjectType.Case.isUpdateable()) { 
                SPV_DatabaseDML.updateListDML(pretensionesReclamacion, false);
            }
        }        
    }


    /*****************************************************************************************
     * Proposito: Cerrar una reclamación poniendo el subestado correcto según su case history
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US974485     Sergio Martín     30/07/24        Creación
    **********************************************************************************************/
    /**
     * @description  Cerrar una reclamación poniendo el subestado correcto según su case history
     * @param casoACerrar
     */
    public static Case cerrarReclamacion(Case casoACerrar){
        List<CaseHistory> historial = new List<CaseHistory>();
        if(CaseHistory.SObjectType.getDescribe().isAccessible()){
            historial = [SELECT id, NewValue,OldValue,CreatedDate FROM CaseHistory WHERE CaseId =: casoACerrar.Id ORDER BY CreatedDate ASC];
        } 

        for(CaseHistory h : historial){
            if(String.valueOf(h.NewValue) == 'Allanamiento'){
                casoACerrar.SEG_Subestado__c = 'Cerrada allanamiento';
            } else if(String.valueOf(h.NewValue) == 'Alegaciones'){
                casoACerrar.SEG_Subestado__c = 'Cerrada alegaciones';
            } else if(String.valueOf(h.NewValue) == 'Desistimiento'){
                casoACerrar.SEG_Subestado__c = 'Cerrada desistimiento';
            }
        }

        casoACerrar.Status = 'Cerrado';
        return casoACerrar;
    }

    public static void guardarUsuario(List<Case> listaCasosSPV, Map<Id, Case> mapOldObj){

        Id userId = UserInfo.getUserId();

        for(Case caso : listaCasosSPV){
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && caso.SEG_Subestado__c == 'Negociacion') {
                //Si cambia una reclamación y el owner es el usuario que ejecuta, es el gestor
                if (caso.OwnerId == userId) {
                    caso.CC_SuppliedUser__c = 'Ges';
                //Si cambia una reclamación y el owner NO es el usuario que ejecuta, es el letrado
                } else if(caso.OwnerId != userId) {
                    caso.CC_SuppliedUser__c = 'Let';
                }
            }
        }
    }


    /*******************************************************************************************************************
     * Proposito: Método para asignar un entitlement al caso y asi disponer del Entitlement Process en un caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US942879     Sergio Martín   02/10/24     Creación
    **********************************************************************************************************************/
    /**
     * @description  Método para asignar un entitlement al caso y asi disponer del Entitlement Process en un caso
     * @param listNewCase
     */
    public static void asignarEntitlementProcess(List<Case> listNewCase) {
        if (Schema.sObjectType.Entitlement.isAccessible()) {
            List <Entitlement> entls = [SELECT id, SlaProcess.name FROM Entitlement WHERE SlaProcess.name = 'SPV_Process' ORDER BY LastModifiedDate desc limit 1]; 
            for (Case newCase : listNewCase) {
                if (!entls.isEmpty()) {
                    newCase.entitlementId = entls[0].Id;
                }
            }
        }
    }

    /***********************************************************************************************
     * Proposito: Validar que el campo 'SAC_EntidadAfectada__c' de la reclamación solo se puede modificar por usuarios de COPS o usuarios administradores del grupo gestor de la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0               ---         Raúl Santos      08/10/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Validar que el campo 'SAC_EntidadAfectada__c' de la reclamación solo se puede modificar por usuarios de COPS o usuarios administradores del grupo gestor de la reclamación
     * @param listNewCase
     * @param mapOldObj
     */
    public static void validarEntidadAfectadaReclamacion(List<Case> listNewCase, Map<Id, Case> mapOldObj) {

        List<Case> listRecCambioEntidad = new List<Case>();
        Set<Id> setIdGruposGestor = new Set<Id>();

        for (Case caso : listNewCase) {
            //Si la reclamacion cambia la entidad afectada
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && mapOldObj.get(caso.Id).SAC_Entidad_Afectada__c != caso.SAC_Entidad_Afectada__c) {
                listRecCambioEntidad.add(caso);

                if(caso.SEG_Grupo__c != null){
                    setIdGruposGestor.add(caso.SEG_Grupo__c);
                }
            } 
        }

        if(!listRecCambioEntidad.isEmpty() && !setIdGruposGestor.isEmpty() && Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){
            
            Id userId = UserInfo.getUserId();
            Id profileId = UserInfo.getProfileId();
            Map<Id, CC_Grupo_Colaborador_Contact__c> mapGrupoColab = new Map<Id, CC_Grupo_Colaborador_Contact__c>();

            String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;

            if(!profileName.toLowerCase().contains('admin')){

                List<CC_Grupo_Colaborador_Contact__c> listColaboradores = [SELECT Id, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.SAC_DeveloperName__c FROM CC_Grupo_Colaborador_Contact__c WHERE (CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOPROVEEDOR AND CC_Grupo_Colaborador__c IN :setIdGruposGestor AND CC_Usuario__c = :userId AND SAC_Administrador__c = true) OR (CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOTAREAS AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_COPS' AND CC_Usuario__c = :userId)]; 

                for (Case rec : listRecCambioEntidad) {

                    if(!listColaboradores.isEmpty()){
                        for(CC_Grupo_Colaborador_Contact__c colab : listColaboradores){ 
                            if(rec.SEG_Grupo__c != colab.CC_Grupo_Colaborador__c && colab.CC_Grupo_Colaborador__r.SAC_DeveloperName__c != 'SPV_COPS'){
                                rec.addError('No puede actualizar la entidad afectada. Esta operativa solo está disponible para usuarios COPS y administradores del grupo gestor de la reclamación.');
                            }
                        }
                    }else{
                        rec.addError('No puede actualizar la entidad afectada. Esta operativa solo está disponible para usuarios COPS y administradores del grupo gestor de la reclamación.');
                    }   
                }
            }
        }
    }


    /***********************************************************************************************
     * Proposito: Completar el SLA de asignacion a Letrado si se asigna un letrado a la pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US942879     Sergio Martín     11/10/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Completar el SLA de asignacion a Letrado si se asigna un letrado a la pretensión
     * @param listNewCase
     * @param mapOldObj
     * @param colaPendienteAsignar
     */
    public static void cambioSLAAsignacionLetrado(List<Case> listNewCase, Map<Id, Case> mapOldObj, Group colaPendienteAsignar) {
        List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
        Set<Id> setIdRecCambioLetrado = new Set<Id>();

        for (Case caso : listNewCase) {
            //Si la pretension cambia de owner y anteriormente era la cola de Pte. Asignar
            if (caso.RecordTypeId == RECTYPEPRETENSION && mapOldObj.containsKey(caso.Id) && caso.SAC_EsPrincipal__c && mapOldObj.get(caso.Id).OwnerId == colaPendienteAsignar.Id && mapOldObj.get(caso.Id).OwnerId != caso.OwnerId) {
                setIdRecCambioLetrado.add(caso.SAC_Reclamacion__c);
            } 
        }

        if(!setIdRecCambioLetrado.isEmpty() && Schema.sObjectType.CaseMilestone.isAccessible()){
            List<CaseMilestone> listaCaseMilestone = [SELECT caseid, startdate, IsCompleted, IsViolated, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId IN :setIdRecCambioLetrado];
            for (CaseMilestone caseMil : listaCaseMilestone) {
                if (String.isBlank(String.valueOf(caseMil.CompletionDate)) && caseMil.MilestoneType.Name == 'SLA Alta y Asignación Letrado') {
                    caseMil.CompletionDate = system.now();
                    listaCaseMilestoneUpdatear.add(caseMil);
                }
            }
            if(!listaCaseMilestoneUpdatear.isEmpty() && Schema.sObjectType.CaseMilestone.isUpdateable()) {
                SPV_DatabaseDML.updateListDML(listaCaseMilestoneUpdatear, true);
            }
        }
    }


    /***********************************************************************************************
     * Proposito: Desmarcar el campo SPV_EscaladoAJ__c cuando se cambia de estado en la reclamacion
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US942879     Sergio Martín     14/10/24        Creación
     ***********************************************************************************************/
        /**
     * @description  Desmarcar el campo SPV_EscaladoAJ__c cuando se cambia de estado en la reclamacion
     * @param listaCasosSPV
     * @param mapOldObj
     */
    public static void desactivarEscaladoAJ(List<Case> listaCasosSPV, Map<Id, Case> mapOldObj){
        for(Case caso : listaCasosSPV){
            if (caso.RecordTypeId == RECTYPERECLAMACION && ((mapOldObj.get(caso.Id).SEG_Subestado__c != caso.SEG_Subestado__c && caso.Status == 'SAC_002') || mapOldObj.get(caso.Id).Status != caso.Status)) {
                //Si cambia una reclamación y el owner es el usuario que ejecuta, es el gestor
                if (caso.SPV_EscaladoAJ__c) {
                    caso.SPV_EscaladoAJ__c = false;
                }
            }
        }
    }


    /***********************************************************************************
    * Proposito: Cerrar los SLA de la reclamación cuando se va cambiando de estado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US942879     Sergio Martín    16/10/24         Creacion
    ***********************************************************************************/
    /**
     * @description  Cerrar los SLA de la reclamación cuando se va cambiando de estado
     * @param listCasosSPV
     * @param mapOldObj
     */
    public static void cerrarSLAReclamacion(List<Case> listCasosSPV, Map<Id, Case> mapOldObj){

        Set<Id> listaIdsReclamaciones = new Set<Id>();
        List<Case> listaCerrarSLAFases = new List<Case>();
        List<Case> listaCerrarSLAReclamaciones = new List<Case>();

        for(Case caso : listCasosSPV){
            //Detectar la salida del subestado "Analisis"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.SEG_Subestado__c != mapOldObj.get(caso.Id).SEG_Subestado__c && mapOldObj.get(caso.Id).SEG_Subestado__c == 'Analisis') {
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAFases.add(caso);
            }
            //Detectar la salida del subestado "Alegaciones"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.SEG_Subestado__c != mapOldObj.get(caso.Id).SEG_Subestado__c && mapOldObj.get(caso.Id).SEG_Subestado__c == 'Alegaciones') {
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAFases.add(caso);
            }

            //Detectar la salida del subestado "Allanamiento"
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.SEG_Subestado__c != mapOldObj.get(caso.Id).SEG_Subestado__c && mapOldObj.get(caso.Id).SEG_Subestado__c == 'Allanamiento') {
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAFases.add(caso);
            }

            //Detectar la salida de la complementarias de organismo
            if (caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.SPV_ComplementariaOrganismo__c != mapOldObj.get(caso.Id).SPV_ComplementariaOrganismo__c && mapOldObj.get(caso.Id).SPV_ComplementariaOrganismo__c == false) {
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAFases.add(caso);
            }

            //Detectar la salida de la rectificacion
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && mapOldObj.get(caso.Id).Status == 'SPV_Rectificacion'){
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAFases.add(caso);
            }

            //Detectar el cambio de estado a "Cerrado"
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado'){
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAReclamaciones.add(caso);
            }

            //Detectar el cambio de estado a "Descartado"
            if(caso.RecordTypeId == RECTYPERECLAMACION && mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Descartado'){
                listaIdsReclamaciones.add(caso.Id);
                listaCerrarSLAReclamaciones.add(caso);
            }
        }


        if(!listaIdsReclamaciones.isEmpty()){
            if(!listaCerrarSLAFases.isEmpty()){
                //Cerrar el SLA de la fase en la que se encuentra la reclamación
                cerrarSLAFasesReclamacion(listaIdsReclamaciones);
            }

            if(!listaCerrarSLAReclamaciones.isEmpty()){
                // Completar todos los SLA de la reclamación
                cerrarSLAActivosReclamacion(listaIdsReclamaciones);
            }            
        }
    }



    /***********************************************************************************************
     * Proposito: Cerrar los SLA internos de la reclamación cuando se sales de la fase
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US942879     Sergio Martín     16/10/24         Creacion
     ***********************************************************************************************/
        /**
     * @description  Cerrar los SLA internos de la reclamación cuando se sales de la fase
     * @param setIdReclamaciones
     */
    public static void cerrarSLAFasesReclamacion(Set<Id> setIdReclamaciones) {
        if(!setIdReclamaciones.isEmpty() && Schema.sObjectType.CaseMilestone.isAccessible()){
            List<CaseMilestone> listaCaseMilestone = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId IN :setIdReclamaciones];
            List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
            for (CaseMilestone caseMil : listaCaseMilestone) {
                if (String.isBlank(String.valueOf(caseMil.CompletionDate)) && caseMil.MilestoneType.Name != 'Plazo Regulatorio Supervisor' && caseMil.MilestoneType.Name != 'SLA Alta y Asignación Letrado') {
                    caseMil.CompletionDate = system.now();
                    listaCaseMilestoneUpdatear.add(caseMil);
                }
            }
            
            if(!listaCaseMilestoneUpdatear.isEmpty() && Schema.sObjectType.CaseMilestone.isUpdateable()) { 
                SPV_DatabaseDML.updateListDML(listaCaseMilestoneUpdatear, false);
            }
        }
    }

    /***********************************************************************************************
     * Proposito: Cerrar los SLA de la reclamación cuando se cierra o descarta una reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US942879     Sergio Martín     09/10/24        Creación
     ***********************************************************************************************/
    /**
     * @description  Cerrar los SLA de la reclamación cuando se cierra o descarta una reclamación
     * @param setIdReclamaciones
     */
    public static void cerrarSLAActivosReclamacion(Set<Id> setIdReclamaciones) {
        if(!setIdReclamaciones.isEmpty() && Schema.sObjectType.CaseMilestone.isAccessible()){
            List<CaseMilestone> listaCaseMilestone = [SELECT caseid, startdate, IsCompleted, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId IN :setIdReclamaciones];
            List<CaseMilestone> listaCaseMilestoneUpdatear = new List<CaseMilestone>();
            for (CaseMilestone caseMil : listaCaseMilestone) {
                if (String.isBlank(String.valueOf(caseMil.CompletionDate))) {
                    caseMil.CompletionDate = system.now();
                    listaCaseMilestoneUpdatear.add(caseMil);
                }
            }
            
            if(!listaCaseMilestoneUpdatear.isEmpty() && Schema.sObjectType.CaseMilestone.isUpdateable()) { 
                SPV_DatabaseDML.updateListDML(listaCaseMilestoneUpdatear, false);
            }
        }
    }


    /*******************************************************************************************************************
     * Proposito: Método para crear un registro asociado del CBK_Case_Extension__c a la reclamacion
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                          Sergio Martín   02/10/24     Creación
    **********************************************************************************************************************/
    /**
     * @description  Método para crear un registro asociado del CBK_Case_Extension__c a la reclamacion
     * @param listCasosSPV
     */
    public static void creacionCaseExtension(List<Case> listCasosSPV) { 
        List<CBK_Case_Extension__c> listaCaseExtension = new List<CBK_Case_Extension__c>();
        List<Case> listaCase = new List<Case>();
        Set<Id> idCasos = new Set<Id>();

        for(Case caso : listCasosSPV) {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.recordTypeId = RECTYPECASEEXTENSION;
            caseExtension.Case_Id__c = caso.id;
            listaCaseExtension.add(caseExtension);
            idCasos.add(caso.id);
        }

        if (Schema.sObjectType.CBK_Case_Extension__c.isCreateable()) {    
            SPV_DatabaseDML.insertListDML(listaCaseExtension, false);
            List<Case> listaCaseActualizar = [SELECT Id FROM Case WHERE Id IN :idCasos];
            if(!listaCaseActualizar.isEmpty()) {
                for(Case caso : listaCaseActualizar) {
                    for(CBK_Case_Extension__c extension : listaCaseExtension) {
                        if(extension.Case_Id__c == caso.id) {
                            caso.CBK_Case_Extension_Id__c = extension.id;
                            listaCase.add(caso);
                        }
                    }
                }

                if (Schema.sObjectType.Case.isUpdateable()) {  
                    SPV_DatabaseDML.updateListDML(listaCase, false);
                }
            }
        }
    }
}