/*****************************************************************************************
 * Name: SAC_Reclamacion
 * Copyright © 2021  CaixaBank
 * 
 * Propósito: Clase que contiene un método para rellenar datos de un caso insertado.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0            DE52981        Daniel Benito      26/10/21      Creación Clase 
******************************************************************************************/
/**
*   @description SAC_Reclamacion
*/
public without sharing class SAC_Reclamacion {

    private static Set<String> objetos = new Set<String>{'Case','SAC_Accion__c', 'CC_Grupo_Colaborador__c','CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();  
    private static final Id RECTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();  
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final String RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final String RECTYPEACCIONMAESTRO = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static final String RECTYPEACCIONOTRAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private static final String RECTYPEGRUPORESPONSABLEACCION = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SAC_ReclamacionCaseExt').getRecordTypeId();

    private static final String STATUS_RECHAZADO = 'Rechazado';
    /**************************************************************************
     * Proposito: 
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            DE53996       Marcela Neira   15/11/2021      Creación
    **************************************************************************/
    /**
	 * @description    Devolver consultas COPS
	 * @param mapaReclamaciones
     * @param listaSelect
     * @param cola
     * @param mapaDatosCasosActualizar
	 */
    public static void devolverConsultasCOPS(Map<Id, Case> mapaReclamaciones, List<Case> listaSelect, Group cola, Map<Id, Case> mapaDatosCasosActualizar){
        //OR (RecordTypeId = :RECTYPECONSULTA AND CC_CasoRelacionado__c IN: idesReclaGlobal AND (Status != 'SAC_008' OR Status != 'SAC_012' OR Status != 'SAC_013'))

        List<Case> listaConsultas = new List<Case>();
        for (Case casoSelect : listaSelect) {
            if (casoSelect.RecordTypeId == RECTYPECONSULTA && String.isNotBlank(casoSelect.CC_CasoRelacionado__c) && (casoSelect.Status != 'SAC_008' && casoSelect.Status != 'SAC_012' && casoSelect.Status != 'SAC_013' && casoSelect.status != 'Rechazado')) {
                listaConsultas.add(casoSelect);
            }
        }
        if (!listaConsultas.isEmpty()) {
            CC_Grupo_Colaborador__c cops =[SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: RECTYPEGRUPORESPONSABLEACCION AND Name ='COPS' LIMIT 1];

            for (Case consulta : listaConsultas) {
                if(consulta.RecordTypeId == RECTYPECONSULTA && mapaReclamaciones.containsKey(consulta.CC_CasoRelacionado__c)){
                    if(mapaDatosCasosActualizar.containsKey(consulta.id)){
                        //mapaDatosCasosActualizar.get(consulta.id).CC_CasoRelacionado__c = null;
                        mapaDatosCasosActualizar.get(consulta.id).SEG_Grupo__c = cops.id; mapaDatosCasosActualizar.get(consulta.id).OwnerId = cola.id;
                    //mapaDatosCasosActualizar.get(consulta.id).Status = 'SAC_011';
                    }else{
                        //consulta.CC_CasoRelacionado__c = null;
                        consulta.SEG_Grupo__c = cops.id;
                        consulta.OwnerId = cola.id;
                        //consulta.Status = 'SAC_011';
                        mapaDatosCasosActualizar.put(consulta.id, consulta);
                    }
                }
            }
        }   
    }

    /**************************************************************************
     * Proposito: Recuperar el gestor del cliente y traerlo al caso
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            DE53996          Carlos Solis   11/02/2022   Creación
    **************************************************************************/
        /**
	 * @description    Recuperar el gestor del cliente y traerlo al caso
	 * @param listNewCase
	 */  
    public static void recuperarGestorCliente(List<Case> listNewCase) {
        Set<Id> setIdsAccounts = new Set<Id>();
        for (Case caso : listNewCase) {
            setIdsAccounts.add(caso.AccountId);
        }
        
        Map<Id, Account> mapaAccounts = new Map<Id, Account>([SELECT Id, SEG_Nombre_empleado_gestor__c FROM Account WHERE Id IN :setIdsAccounts]);

        for (Case caso : listNewCase) {
            if (mapaAccounts.containsKey(caso.AccountId)) {
                caso.SAC_Gestordelcliente__c = mapaAccounts.get(caso.AccountId).SEG_Nombre_empleado_gestor__c;
            }
        }
    }

     /**************************************************************************
     * Proposito: Rellenar campos del caso relacionados con el contacto insertado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US336184         Daniel Benito  21/02/2022   Creación
    *************************************************************************

    public static void rellenarDatosReclamante(List<Case> listNewCase){
        Set<Id> setIdsAccounts = new Set<Id>();
        for (Case caso : listNewCase) {
            setIdsAccounts.add(caso.AccountId);
        }

        Map<Id, Account> mapaAccounts = new Map<Id, Account>([SELECT Id, Phone, CC_Email__c, ShippingPostalCode, CC_Segmento__c, CC_SubSegmento__c, CC_Edad__pc,CC_Gestor_InTouch__c, CC_FechaNac__pc FROM Account WHERE Id IN :setIdsAccounts]);

        for (Case caso : listNewCase) {
            if (mapaAccounts.containsKey(caso.AccountId)) {
                caso.SAC_TelefonoCliente__c = mapaAccounts.get(caso.AccountId).Phone;
                caso.SAC_CorreoElectronico_Cliente__c = mapaAccounts.get(caso.AccountId).CC_Email__c;
                caso.SAC_Edad__c = mapaAccounts.get(caso.AccountId).CC_Edad__pc;
                caso.SAC_FechaNacimiento__c = mapaAccounts.get(caso.AccountId).CC_FechaNac__pc;
                caso.SAC_DireccionPostal_Cliente__c = mapaAccounts.get(caso.AccountId).ShippingPostalCode;
                caso.SAC_Segmento__c = mapaAccounts.get(caso.AccountId).CC_Segmento__c;
                caso.SAC_Subsegmento__c = mapaAccounts.get(caso.AccountId).CC_SubSegmento__c;

                if(String.isNotBlank(mapaAccounts.get(caso.AccountId).CC_Gestor_InTouch__c)){

                    caso.SAC_GestorInTouch__c = mapaAccounts.get(caso.AccountId).CC_Gestor_InTouch__c;
                    caso.SAC_ClienteInTouch__c = true;

                }else{

                    caso.SAC_ClienteInTouch__c = false;
                }
            }
        }
    }

*/


        /*****************************************************************
     * Proposito: 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US832968       Álex Polo      20/08/24      Creación
    *****************************************************************/
    /*public static void actualizarTAE(List<Case> listaReclamaciones, List<Case> listaCasos){
        
    
        List<Id> listaIdPrincipales = new List<Id>();
        List<Case> listaPretensionesPrincipales = new List<Case>();
        Map<Id, Case> mapaPretensiones = new Map<Id, Case>();
        Map<Id,Case> mapaReclamaciones = new Map<Id, Case>();

        Map<Id,Case> mapaCasos = new Map<Id, Case>();

        //Se crea un mapa con las reclamaciones actualizadas y se llena una lista con todas las pretensiones principales
        for(Case reclamacion : listaReclamaciones){
            mapaReclamaciones.put(reclamacion.Id, reclamacion);
            listaIdPrincipales.add(reclamacion.SAC_PretensionPrincipal__c);
        }
    
        //Mapa con todos los casos
        for(Case caso : listaCasos){
            mapaCasos.put(caso.Id, caso); 
        }

        //Se crea un mapa con todas las pretensiones principales
        for(Id id : listaIdPrincipales){
            if(mapaCasos.containsKey(id)){
                listaPretensionesPrincipales.add(mapaCasos.get(id));
                if(!mapaPretensiones.containsKey(id)){
                    mapaPretensiones.put(id, mapaCasos.get(id));
                }

            }
        }

        //Para cada reclamación, si el mapa de pretensiones tiene su pretensión principal, se le asigna el valor del TAE de su pretensión principal
        if(!listaPretensionesPrincipales.isEmpty()){
            for(Case reclamacion : listaReclamaciones){
                if(mapaPretensiones.containsKey(reclamacion.SAC_PretensionPrincipal__c)){
                    reclamacion.SAC_TAE__c = mapaPretensiones.get(reclamacion.SAC_PretensionPrincipal__c).SAC_TAE__c;
                }else{
                    reclamacion.SAC_TAE__c = null;
                }
            }

        }
    }*/

    /**************************************************************************
     * Proposito: Modificar los campos relativos a la direccion postal en su campo global
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US338137         Luis Mesa  02/03/2022   Creación
    **************************************************************************/
    /**
	 * @description    Modificar los campos relativos a la direccion postal en su campo global
	 * @param listNewCase
	 */  

    public static void informarDireccionPostar(List<Case> listNewCase){
        for(Case caso : listNewCase){
            String direccion;
            if (String.isNotBlank(caso.SAC_DireccionContacto__c)) {
                direccion = caso.SAC_DireccionContacto__c;
            }
            if (String.isNotBlank(caso.SAC_CodigoPostalContacto__c)) {
                if (String.isNotBlank(direccion)) {
                    direccion = direccion + ', ' + caso.SAC_CodigoPostalContacto__c;

                } else {
                    direccion = caso.SAC_CodigoPostalContacto__c;

                }
            }
            if (String.isNotBlank(caso.SAC_PoblacionContacto__c)) {
                if (String.isNotBlank(direccion)) {
                    direccion = direccion + ', ' + caso.SAC_PoblacionContacto__c;
                } else {
                    direccion = caso.SAC_PoblacionContacto__c;
                }
            }
            if (String.isNotBlank(caso.SAC_ProvinciaContacto__c)) {
                if (String.isNotBlank(direccion)) {
                    direccion = direccion + ', ' + caso.SAC_ProvinciaContacto__c;
                } else {
                    direccion = caso.SAC_ProvinciaContacto__c;
                }
            }
            if (String.isNotBlank(caso.SAC_PaisContacto__c)) {
                if (String.isNotBlank(direccion)) {
                    direccion = direccion + ', ' + caso.SAC_PaisContacto__c;
                } else {
                    direccion = caso.SAC_PaisContacto__c;
                }
            }
            caso.SAC_DireccionPostalNotificacion__c = direccion;
        }
    }

    /**************************************************************************
     * Proposito: Insertar permisos para que el letrado de las pretensiones pueda modificar
     * la reclamación padre. Si cambia el owner a uno nuevo, también borra el case share del antiguo
     * owner de la pretensión
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   22/03/2022   Creación
    **************************************************************************/
    /**
	 * @description    Insertar permisos para que el letrado de las pretensiones pueda modificar la reclamación padre.
	 * @param listNewCase
     * @param listaSelect
     * @param mapOldCase
	 */  

    public static void modificarPermisoLetrado(List<Case> listNewCase, List<Case> listaSelect, Map<Id, Case> mapOldCase){
        //Pasar lista de todo lo que traemos del select del trigger a mapa
        Map<Id, Case> mapaSelect = new Map<Id, Case>(listaSelect);

        //Buscar los padres de las pretensiones a las que les ha cambiado el owner en el mapa para almacenarlos
        Map<Id, Set<Id>> mapaCaseShareNuevos = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapaCaseShareGestorRec = new Map<Id, Set<Id>>();
        Set<Id> setIdsPadres = new Set<Id>();
        Set<Id> setIdsOwnersPret = new Set<Id>();
        Set<Id> setIdsOwnersRec = new Set<Id>();
        for (Case caso : listNewCase) {
            //Nuevos a añadir
            if (mapaSelect.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaCaseShareNuevos.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaCaseShareNuevos.get(caso.SAC_Reclamacion__c).add(caso.OwnerId);
                } else {
                    Set<Id> setCS = new Set<Id>();
                    setCS.add(caso.OwnerId);
                    mapaCaseShareNuevos.put(caso.SAC_Reclamacion__c, setCS);
                }
            }
            
            //Antiguos a eliminar    
            if (mapOldCase.containsKey(caso.Id) && mapaSelect.containsKey(caso.SAC_Reclamacion__c) && mapOldCase.get(caso.Id).OwnerId != mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId) {
                setIdsPadres.add(mapaSelect.get(caso.SAC_Reclamacion__c).Id);
                setIdsOwnersPret.add(mapOldCase.get(caso.Id).OwnerId);
            }
            
            //Añadido para rec
            if (mapaSelect.containsKey(caso.SAC_Reclamacion__c) && mapOldCase.containsKey(caso.Id) && mapOldCase.get(caso.Id).OwnerId == mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId &&
                caso.OwnerId != mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId) {
                setIdsOwnersRec.add(mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId);
                if (mapaCaseShareGestorRec.containsKey(mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId)) {
                    mapaCaseShareGestorRec.get(mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId).add(caso.Id);
                } else {
                    Set<Id> setCSRec = new Set<Id>();
                    setCSRec.add(caso.Id);
                    mapaCaseShareGestorRec.put(mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId, setCSRec);
                }
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
        
        //Añadido
        if (!mapaCaseShareGestorRec.isEmpty()) {
            for (Id idOwnerRec : mapaCaseShareGestorRec.keySet()) {
                for (Id idPretension : mapaCaseShareGestorRec.get(idOwnerRec)) {
                    CaseShare csNuevo = new CaseShare();
                    csNuevo.CaseId = idPretension;
                    csNuevo.UserOrGroupId = idOwnerRec;
                    csNuevo.CaseAccessLevel='Edit';
                    listaCaseShareNuevos.add(csNuevo);
                }
            }
        }
        

        //Insertar CaseShare nuevos
        if (!listaCaseShareNuevos.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaCaseShareNuevos, false);
        }
        
        //Borrar CaseShare de antiguo owner
        if (!setIdsPadres.isEmpty() && !setIdsOwnersPret.isEmpty() && !Test.isRunningTest()) {
            List<CaseShare> listaCaseShareBorrar = [SELECT Id FROM CaseShare WHERE CaseId IN :setIdsPadres AND UserOrGroupId IN :setIdsOwnersPret];
            

            if (!listaCaseShareBorrar.isEmpty()) {
                SAC_DatabaseDML.deleteListDML(listaCaseShareBorrar, false);
            }
        }
    }

    /**************************************************************************
     * Proposito: Insertar permisos para que el Owner de la reclamación pueda modificar las
     * pretensiones hijas de su reclamación. Cuando cambia el owner de la reclamación, inserta los
     * permisos del nuevo Owner y borra los del antiguo.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   14/04/2022   Creación
    **************************************************************************/ 
    /**
	 * @description    Insertar permisos para que el Owner de la reclamación pueda modificar las pretensiones hijas de su reclamación.
	 * @param listNewCase
     * @param listaSelect
     * @param mapOldCase
	 */  
    public static void modificarPermisoGestor(List<Case> listNewCase, List<Case> listaSelect, Map<Id, Case> mapOldCase) {
        Map<Id, Case> mapaNewCase = new Map<Id, Case>(listNewCase);
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
            if (mapaNewCase.containsKey(caso.SAC_Reclamacion__c) && mapOldCase.containsKey(caso.SAC_Reclamacion__c) &&
                mapaNewCase.get(caso.SAC_Reclamacion__c).OwnerId != mapOldCase.get(caso.SAC_Reclamacion__c).OwnerId) {
                setIdsPretensiones.add(caso.Id);
                setIdsOwners.add(mapOldCase.get(caso.SAC_Reclamacion__c).OwnerId);
            }
        }

        //Recorrer el mapa y añadir un case share por cada pretension
        List<CaseShare> listaCSNuevos = new List<CaseShare>();
        for (Id idReclamacion : mapaRecListaPret.keySet()) {
            for (Case pretension : mapaRecListaPret.get(idReclamacion)) {
                CaseShare csNuevo = new CaseShare();
                csNuevo.CaseId = pretension.Id;
                csNuevo.UserOrGroupId = mapaIdreclamacionIdOwner.get(idReclamacion);
                csNuevo.CaseAccessLevel='Edit';
                listaCSNuevos.add(csNuevo);
            }
        }

        if (!listaCSNuevos.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaCSNuevos, false);
        }

        if (!setIdsPretensiones.isEmpty() && CaseShare.SObjectType.getDescribe().isAccessible()) {
            List<CaseShare> listaCSBorrar = [SELECT CaseId, UserOrGroupId FROM CaseShare WHERE CaseId IN :setIdsPretensiones AND UserOrGroupId IN :setIdsOwners];

            if (!listaCSBorrar.isEmpty()) {
                SAC_DatabaseDML.deleteListDML(listaCSBorrar, false);
            }
        }
    }

    /**************************************************************************
     * Proposito: Inserta permisos para que el gestor de la reclamación pueda tener permisos
     * sobre las pretensiones hijas. Se ejecuta al cambiar el owner de las pretensiones
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   27/04/2022   Creación
    **************************************************************************/
    /**
	 * @description    Inserta permisos para que el gestor de la reclamación pueda tener permisos sobre las pretensiones hijas.
	 * @param listNewPretensiones
     * @param listaSelect
	 */  

    public static void insertarCaseShare(List<Case> listNewPretensiones, List<Case> listaSelect){
        Map<Id, Case> mapaSelect = new Map<Id, Case>(listaSelect);
        Map<Id, List<Case>> mapaRecPrets = new Map<Id, List<Case>>();
        Map<String, String> mapaReclamaciones = new Map<String, String>();
        for (Case caso : listNewPretensiones) {
            if (mapaSelect.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaRecPrets.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaRecPrets.get(caso.SAC_Reclamacion__c).add(caso);
                } else {
                    List<Case> listaPrets = new List<Case>();
                    listaPrets.add(caso);
                    mapaRecPrets.put(caso.SAC_Reclamacion__c, listaPrets);
                    mapaReclamaciones.put(caso.SAC_Reclamacion__c, mapaSelect.get(caso.SAC_Reclamacion__c).OwnerId);
                }
            }
        }

        List<CaseShare> listaCSNuevos = new List<CaseShare>();
        for (Id idReclamacion : mapaRecPrets.keySet()) {
            for (Case pretension : mapaRecPrets.get(idReclamacion)) {
                if (mapaReclamaciones.containsKey(idReclamacion)) {
                    CaseShare csNuevo = new CaseShare();
                    csNuevo.CaseId = pretension.Id;
                    csNuevo.UserOrGroupId = mapaReclamaciones.get(idReclamacion);
                    csNuevo.CaseAccessLevel='Edit';
                    listaCSNuevos.add(csNuevo);
                }
            }
        }

        if (!listaCSNuevos.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaCSNuevos, false);
        }
    }

    /**************************************************************************
     * Proposito: Si se cambia el tipo de representante hay que comprobar si se elimina el despacho representante del Case Extension relacionado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1093930       Álex Polo     08/01/2025   Creación
    **************************************************************************/
    /**
	 * @description    Si se cambia el tipo de representante hay que comprobar si se elimina el despacho representante del Case Extension relacionado
	 * @param listaCasosSelect
     * @param listaComprobarDespachoRepresentante
	 */  
    public static void comprobarDespachoRepresentante(List<Case> listaCasosSelect, List<Case> listaComprobarDespachoRepresentante, Map<Id, Case> mapOldObj){

        List<CBK_Case_Extension__c> listaCaseExtensionUpdate = new List<CBK_Case_Extension__c>();

        if(!listaComprobarDespachoRepresentante.isEmpty()){
            for(Case caso : listaComprobarDespachoRepresentante){
                //Si el tipo de representante no es abogado, se vacía el despacho representante
                if(caso.SAC_TipoDeRepresentante__c != 'SAC_Abogado' && mapOldObj.get(caso.Id).SAC_TipoDeRepresentante__c == 'SAC_Abogado'){
                    CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();
                    casoExtension.Id = caso.CBK_Case_Extension_Id__c;
                    casoExtension.SAC_DespachoRepresentante__c = null;
                    listaCaseExtensionUpdate.add(casoExtension);
                }
            }

            if(!listaCaseExtensionUpdate.isEmpty()){
                SAC_DatabaseDML.updateListDML(listaCaseExtensionUpdate, true);
            }
        }
    }



    /**************************************************************************
     * Proposito: Si una Complementaria se vincula a una reclamación, se debe sumar el importe abonado de la complementaria a la reclamación vinculada
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1094159       Álex Polo     20/01/2025     Creación
    **************************************************************************/

    public static void arrastrarImporteReclamacionVinculada(List<Case> listaCasosSelect, List<Case> listaReclaCambiaVinculacion, Map<Id, Case> mapaDatosCasosActualizar){

        Map<Id, Case> mapaReclamacionesVinculadas = new Map<Id, Case>(); 
        Set<Id> idsReclamacionesVinculadas = new Set<Id>();         //Ids de las reclamaciones a las que se han vinculado las complementarias
        Map<Id, Case> mapaComplementariayReclamacion = new Map<Id, Case>();  //Id de la reclamación - Case que se vincula a esa reclamación
        List<Case> listaReclamacionesVinculadas = new List<Case>();
        
        Map<Id, Case> mapaReclamacionesActualizar = new Map<Id, Case>();        //Mapa donde se almacena la reclamación a actualizar con su importe final

        for(Case complementaria : listaReclaCambiaVinculacion){
            idsReclamacionesVinculadas.add(complementaria.CC_CasoRelacionado__c);
        }

        listaReclamacionesVinculadas = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE Id IN :idsReclamacionesVinculadas];

        if(!listaReclamacionesVinculadas.isEmpty()){
            //Crear un mapa con las reclamacion que se han vinculado a las  complementaria
            for(Case reclamacion : listaReclamacionesVinculadas){
                mapaReclamacionesVinculadas.put(reclamacion.Id, reclamacion);
            }

            //Se recorren las complementarias y se le va sumando el importe abonado a su reclamación vinculada
            for(Case complementaria : listaReclaCambiaVinculacion){
                if(mapaReclamacionesVinculadas.containsKey(complementaria.CC_CasoRelacionado__c) && complementaria.CC_Importe_Abonado__c != null){
                    if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c == null){
                        mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = complementaria.CC_Importe_Abonado__c;
                    }else{
                        mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c += complementaria.CC_Importe_Abonado__c;
                    } 
                }
            }


            //Se añaden las reclamaciones con importe abonado actualizado al mapa de casos a actualizar
            for(Id idReclamacion : mapaReclamacionesVinculadas.keySet()){
                if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                    mapaDatosCasosActualizar.get(idReclamacion).CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                }else{
                    Case nuevaReclamacion = new Case();
                    nuevaReclamacion.Id = idReclamacion;
                    nuevaReclamacion.CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                    //System.debug('Nuevo importe ' + nuevaReclamacion.Id + ' ' + nuevaReclamacion.CC_Importe_Abonado__c);
                    mapaDatosCasosActualizar.put(nuevaReclamacion.Id, nuevaReclamacion);
                }
            }
        }

    }
    

    /**************************************************************************
     * Proposito: Al cambiar la naturaleza a complementaria, o de complementaria a otra, hay que recalcular los importes abonados en el caso relacionado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1094159       Álex Polo     22/01/2025     Creación
    **************************************************************************/

    public static void calcularNuevoImporteCambioNaturaleza(List<Case> listaCambiaNaturalezaComplementaria, Map<Id, Case> mapOldObj, Map<Id, Case> mapaDatosCasosActualizar){

        Set<Id> idsReclamacionesVinculadas = new Set<Id>();
        List<Case> listaReclamacionesVinculadas = new List<Case>();
        Map<Id, Case> mapaReclamacionesVinculadas = new Map<Id, Case>(); 

        for(Case caso : listaCambiaNaturalezaComplementaria){
            if(caso.CC_CasoRelacionado__c != null){
                idsReclamacionesVinculadas.add(caso.CC_CasoRelacionado__c);
            }
        }

        listaReclamacionesVinculadas = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE Id IN :idsReclamacionesVinculadas];

        if(!listaReclamacionesVinculadas.isEmpty()){
            //Crear un mapa con las reclamacion que se han vinculado a las  complementaria
            for(Case reclamacion : listaReclamacionesVinculadas){
                mapaReclamacionesVinculadas.put(reclamacion.Id, reclamacion);
            }

            //Se recorren los casos que han cambiado de naturaleza, y si ahora son Complementarias, se suma su importe abonado a su caso relacionado
            //Si la naturaleza deja de ser Complementaria, se resta su importe abonado de su caso realacionado
            for(Case complementaria : listaCambiaNaturalezaComplementaria){
                if(complementaria.CC_Importe_Abonado__c != null && complementaria.CC_CasoRelacionado__c != null){
                    if(mapOldObj.containsKey(complementaria.Id) && complementaria.SAC_Naturaleza__c == 'SAC_007'){  //Entra aquí cuando la nueva naturaleza es complementaria, habrá que sumar su importe abonado
                        if(mapaReclamacionesVinculadas.containsKey(complementaria.CC_CasoRelacionado__c)){
                            if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c == null){
                                mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = complementaria.CC_Importe_Abonado__c;
                            }else{
                                mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c += complementaria.CC_Importe_Abonado__c;
                            } 
                        }
                    }else if(mapOldObj.containsKey(complementaria.Id) && complementaria.SAC_Naturaleza__c != 'SAC_007'){ //Entra aquí cuando deja de ser Complementaria, habrá que restar su importe
                        mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c -= complementaria.CC_Importe_Abonado__c;
                        if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c < 0){
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = 0;
                        }
                    }


                }
            }

            //Se añaden las reclamaciones con importe abonado actualizado al mapa de casos a actualizar
            for(Id idReclamacion : mapaReclamacionesVinculadas.keySet()){
                if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                    mapaDatosCasosActualizar.get(idReclamacion).CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                }else{
                    Case nuevaReclamacion = new Case();
                    nuevaReclamacion.Id = idReclamacion;
                    nuevaReclamacion.CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                    //System.debug('Nuevo importe ' + nuevaReclamacion.Id + ' ' + nuevaReclamacion.CC_Importe_Abonado__c);
                    mapaDatosCasosActualizar.put(nuevaReclamacion.Id, nuevaReclamacion);
                }
            }

        }



    }




    /**************************************************************************
     * Proposito: Si una Complementaria se vincula a otra reclamación, o se desvincula, se debe sumar el importe abonado de la complementaria a la nueva reclamación vinculada
     * y restar de la que estaba vinculada anteriormente (Si es solo desvinculación, no habrá nueva reclamación vinculada)
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1094159       Álex Polo     20/01/2025     Creación
    **************************************************************************/
 
    public static void actualizarImporteCambioVinculacion(List<Case> listaCasosSelect, Map<Id, Case> mapOldObj, List<Case> listaReclaCambiaVinculacion, Map<Id, Case> mapaDatosCasosActualizar){

        Map<Id, Case> mapaReclamacionesVinculadas = new Map<Id, Case>();    //Nuevas reclamaciones a las que se vinculan, tanto las nuevas como las anteriores
        Map<Id, Case> mapaReclamacionesAnteriores = new Map<Id, Case>(); 
        Set<Id> idsReclamacionesVinculadas = new Set<Id>();         //Ids de las reclamaciones a las que se han vinculado las complementarias
        Map<Id, Case> mapaComplementariayReclamacion = new Map<Id, Case>();  //Id de la reclamación - Case que se vincula a esa reclamación
        List<Case> listaReclamacionesVinculadas = new List<Case>();

        Map<Id, Case> mapaReclamacionesActualizar = new Map<Id, Case>();        //Mapa donde se almacena la reclamación a actualizar con su importe final

            for(Case complementaria : listaReclaCambiaVinculacion){

                if(complementaria.CC_CasoRelacionado__c != null){
                    idsReclamacionesVinculadas.add(complementaria.CC_CasoRelacionado__c);
                }
                
                //Se añaden también las reclamaciones a la que antes estaba vinculada antes de cambiarla por otra
                if(mapOldObj.containsKey(complementaria.Id) && mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c != null){
                    idsReclamacionesVinculadas.add(mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c);
                }
            }

            listaReclamacionesVinculadas = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE Id IN :idsReclamacionesVinculadas];

            if(!listaReclamacionesVinculadas.isEmpty()){
                //Crear un mapa con las reclamacion que se han vinculado a las complementaria
                for(Case reclamacion : listaReclamacionesVinculadas){
                    mapaReclamacionesVinculadas.put(reclamacion.Id, reclamacion);
                }

                //Se recorre cada complementaria para ir sumando los importes a las nuevas reclamaciones vinculadas, y para ir restando los importes
                //de las reclamaciones que se hayan desvinculado (o cambiado por las nuevas)
                for(Case complementaria : listaReclaCambiaVinculacion){

                    //Primero: Sumar los importes de las complementarias a las reclamaciones nuevas a las que se vinculan
                    //Si el caso relacionado es null, es porque se ha desvinculado y no hay que sumar nada
                    if(complementaria.CC_CasoRelacionado__c != null && mapaReclamacionesVinculadas.containsKey(complementaria.CC_CasoRelacionado__c) && complementaria.CC_Importe_Abonado__c != null){

                        if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c == null){
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = complementaria.CC_Importe_Abonado__c;
                        }else{
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c += complementaria.CC_Importe_Abonado__c;
                        } 
                    }

                    //Segundo: Restar los importes de la reclamación a la que estaban vinculadas antes
                    if(mapOldObj.containsKey(complementaria.Id) && mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c != null && complementaria.CC_Importe_Abonado__c != null){

                        if(mapaReclamacionesVinculadas.get(mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c).CC_Importe_Abonado__c != null){
                            mapaReclamacionesVinculadas.get(mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c).CC_Importe_Abonado__c -= complementaria.CC_Importe_Abonado__c;
                            if(mapaReclamacionesVinculadas.get(mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c).CC_Importe_Abonado__c < 0){
                                mapaReclamacionesVinculadas.get(mapOldObj.get(complementaria.Id).CC_CasoRelacionado__c).CC_Importe_Abonado__c = 0;
                            }
                        }
                    }


                }

                //Se añaden las reclamaciones con importe abonado actualizado al mapa de casos a actualizar
                for(Id idReclamacion : mapaReclamacionesVinculadas.keySet()){
                    if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                        mapaDatosCasosActualizar.get(idReclamacion).CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                    }else{
                        Case nuevaReclamacion = new Case();
                        nuevaReclamacion.Id = idReclamacion;
                        nuevaReclamacion.CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                        mapaDatosCasosActualizar.put(nuevaReclamacion.Id, nuevaReclamacion);
                    }
                }
            }
        }




    /**************************************************************************
     * Proposito: Al cambiar el importe abonado de una complementaria, se debe actualizar en su reclamación vinculada
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US1094159       Álex Polo     20/01/2025     Creación
    **************************************************************************/
  
    public static void calcularNuevoImporteAbonado(List<Case> listaCasosSelect, Map<Id, Case> mapOldObj, List<Case> listaReclaCambiaVinculacion, Map<Id, Case> mapaDatosCasosActualizar){
        
        Map<Id, Case> mapaReclamacionesVinculadas = new Map<Id, Case>();    
        Map<Id, Double> mapaComplementariaImporteAbonado = new Map<Id, Double>();     //Mapa donde se relaciona cada caso con su diferencia del cambio de valor en el importe abonado 
        Set<Id> idsReclamacionesVinculadas = new Set<Id>();         //Ids de las reclamaciones a las que se han vinculado las complementarias
        Map<Id, Case> mapaComplementariayReclamacion = new Map<Id, Case>();  //Id de la reclamación - Case que se vincula a esa reclamación
        List<Case> listaReclamacionesVinculadas = new List<Case>();

        Map<Id, Case> mapaReclamacionesActualizar = new Map<Id, Case>();        //Mapa donde se almacena la reclamación a actualizar con su importe final

        for(Case complementaria : listaReclaCambiaVinculacion){

            //Primero, calcular la diferencia entre el antiguo y el nuevo importe abonado
            Double valorAnterior = mapOldObj.get(complementaria.Id).CC_Importe_Abonado__c == null ? 0.0 : mapOldObj.get(complementaria.Id).CC_Importe_Abonado__c;
            Double valorNuevo = complementaria.CC_Importe_Abonado__c == null ? 0.0 : complementaria.CC_Importe_Abonado__c;
            Double diferencia = valorNuevo - valorAnterior;     //Si es >0, es porque el nuevo es mayor (hay que sumar la diferencia a la recl. vinculada)
                                                                //Si es <0, es porque el nuevo valor es menor (hay que restar la diferencia a la recl. vinculada)

            mapaComplementariaImporteAbonado.put(complementaria.Id, diferencia);
            if(complementaria.CC_CasoRelacionado__c != null){
                idsReclamacionesVinculadas.add(complementaria.CC_CasoRelacionado__c);
            }
        }

        listaReclamacionesVinculadas = [SELECT Id, CC_Importe_Abonado__c FROM Case WHERE Id IN :idsReclamacionesVinculadas];
        if(!listaReclamacionesVinculadas.isEmpty()){

            //Crear un mapa con las reclamacion que se han vinculado a las complementaria
            for(Case reclamacion : listaReclamacionesVinculadas){
                    mapaReclamacionesVinculadas.put(reclamacion.Id, reclamacion);
            }

            //Se recorren las complementarias cuyo valor de importe se ha actualizado, para actualizar así sus reclamaciones vinculadas
            for(Case complementaria : listaReclaCambiaVinculacion){
                if(mapaComplementariaImporteAbonado.containsKey(complementaria.Id)){
                    if(mapaComplementariaImporteAbonado.get(complementaria.Id) > 0 ){   //Si la diferencia >0, hay que sumar la diferencia a la recl. vinculada
                        if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c == null){
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = mapaComplementariaImporteAbonado.get(complementaria.Id);
                        }else{
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c += Math.abs(mapaComplementariaImporteAbonado.get(complementaria.Id));
                        } 
                    }else{                                                              //Si la diferencia <0, hay que restar la diferencia a la recl. vinculada
                        if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c == null){
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = 0;    
                        }
                        mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c -= Math.abs(mapaComplementariaImporteAbonado.get(complementaria.Id));
                        if(mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c < 0){
                            mapaReclamacionesVinculadas.get(complementaria.CC_CasoRelacionado__c).CC_Importe_Abonado__c = 0;
                        }
                        

                    }

                }
            }

            //Se añaden las reclamaciones con importe abonado actualizado al mapa de casos a actualizar
            for(Id idReclamacion : mapaReclamacionesVinculadas.keySet()){
                if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                    mapaDatosCasosActualizar.get(idReclamacion).CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                }else{
                    Case nuevaReclamacion = new Case();
                    nuevaReclamacion.Id = idReclamacion;
                    nuevaReclamacion.CC_Importe_Abonado__c = mapaReclamacionesVinculadas.get(idReclamacion).CC_Importe_Abonado__c;
                    mapaDatosCasosActualizar.put(nuevaReclamacion.Id, nuevaReclamacion);
                }
            }
        }

    }



    /**************************************************************************
     * Proposito: Si en la pretensión principal cambia el campo SAC_Entidad_Afectada__c, pone en la reclamación
     * los nuevos valores de la entidad afectada
     * Modificacion 1.1: Modificado juntándolo con el método entidadProductoraPrincipal para cambiar también el valor del campo SAC_EntidadProductora__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   06/04/2022   Creación
     * 1.1            US422667         Sergio Martín  20/10/2022   Modificacion
    **************************************************************************/
    /**
	 * @description    Si en la pretensión principal cambia el campo SAC_Entidad_Afectada__c, pone en la reclamación
     * los nuevos valores de la entidad afectada
	 * @param listaCasosSelect
     * @param listNewCase
     * @param mapaDatosCasosActualizar
	 */  

    public static void entidadAfectadaPrincipal(List<Case> listaCasosSelect, List<Case> listNewCase, Map<Id, Case> mapaDatosCasosActualizar) {         
        Map<Id,Case> mapaCasosSelect = new Map<Id,Case>(listaCasosSelect);

        for (Case caso : listNewCase) {
            if (mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_Entidad_Afectada__c = caso.SAC_Entidad_Afectada__c;
                mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_EntidadProductora__c = caso.SAC_EntidadProductora__c;
            } else if(mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && !mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                Case reclamacionActualizar = new Case();
                reclamacionActualizar.Id = caso.SAC_Reclamacion__c;
                reclamacionActualizar.SAC_Entidad_Afectada__c = caso.SAC_Entidad_Afectada__c;
                reclamacionActualizar.SAC_EntidadProductora__c = caso.SAC_EntidadProductora__c;
                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
            }
        }
    }


    /********************************************************************************************************
     * Proposito: Si se modifica el campo SAC_MotivoSentidoResolucion__c en alguna de la pretensiones
     *            modificar el campo SAC_ArgumentarioPretensiones__c de la reclamación
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US809544      Sergio Martín   26/02/2024      Creación
    *********************************************************************************************************/
    /**
	 * @description    Si se modifica el campo SAC_MotivoSentidoResolucion__c en alguna de la pretensiones modificar el campo SAC_ArgumentarioPretensiones__c de la reclamación
	 * @param listaCasosSelect
     * @param listNewCase
     * @param mapaDatosCasosActualizar
	 */  
    public static void actualizarArgumentarioResolucion(List<Case> listaCasosSelect, List<Case> listNewCase, Map<Id, Case> mapaDatosCasosActualizar) {         
        Map<Id,Case> mapaCasosSelect = new Map<Id,Case>(listaCasosSelect);
        Id idReclamacion;
        String argumentario = '';
        String sentido;

        for (Case caso : listaCasosSelect) {
            if(caso.recordTypeId == RECTYPERECLAMACION) {
                idReclamacion = caso.id;
            } else if(caso.recordTypeId == RECTYPEPRETENSION && caso.SAC_MotivoSentidoResolucion__c != null) {
                if (caso.SAC_SentidoResolucion__c == 'SAC_001'){
                    sentido = 'A favor de la entidad';
                } else if (caso.SAC_SentidoResolucion__c == 'SAC_002'){
                    sentido = 'Favorable al cliente parcialmente';
                } else if (caso.SAC_SentidoResolucion__c == 'SAC_003'){
                    sentido = 'A favor del cliente';
                } else if (caso.SAC_SentidoResolucion__c == 'SAC_004'){
                    sentido = 'Inadmisión';
                } else if (caso.SAC_SentidoResolucion__c == 'SAC_005'){
                    sentido = 'Desistimiento';
                }
                argumentario += caso.CaseNumber + '  ' + sentido + ': ' + '\r\n' + caso.SAC_MotivoSentidoResolucion__c + '\r\n\r\n';
            }
        }

        for (Case caso : listNewCase) {
            if (mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_ArgumentarioPretensiones__c = argumentario;
            } else if(mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && !mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                Case reclamacionActualizar = new Case();
                reclamacionActualizar.Id = caso.SAC_Reclamacion__c;
                reclamacionActualizar.SAC_ArgumentarioPretensiones__c = argumentario;
                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
            }
        }
    }


    /**************************************************************************
     * Proposito: Si la reclamación pasa a estado Rechazado, cerrar las todas las tareas de la propia reclamación
     * y de las pretensiones hijas.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --             Daniel Benito   07/04/2022     Creación
    **************************************************************************/
    /**
	 * @description    Si la reclamación pasa a estado Rechazado, cerrar las todas las tareas de la propia reclamación y de las pretensiones hijas.
	 * @param listNewCase
	 */  
    
    public static void cerrarTareas(List<Case> listNewCase){

        List<Id> idsCases = new List<Id>();
        List<SAC_Accion__c> listFamiliaAcciones = new List<SAC_Accion__c>();

        for(Case caso : listNewCase){

            idsCases.add(caso.Id);
        }

        if(SAC_Accion__c.SObjectType.getDescribe().isAccessible()){
            listFamiliaAcciones = [SELECT id, SAC_Estado__c,SAC_SaltarValidacion__c
                                    FROM  SAC_Accion__c 
                                    WHERE RecordTypeId IN (:RECTYPEACCIONMAESTRO, :RECTYPEACCIONOTRAS) AND SAC_Reclamacion__c IN: idsCases];
        }

       
        if(!listFamiliaAcciones.isEmpty()){

            for(SAC_Accion__c accion : listFamiliaAcciones){

                if(accion.SAC_SaltarValidacion__c){

                    accion.SAC_SaltarValidacion__c = false;

                }else{

                    accion.SAC_SaltarValidacion__c = true;

                }
               
                accion.SAC_Estado__c = 'SAC_Finalizada';
            }

            SAC_DatabaseDML.updateListDML(listFamiliaAcciones, true);
                 
        }
    }

    /**************************************************************************
    * Proposito: Guardar los comentarios en el chatter del caso cuando se rechaza
    * desde la 'list view'.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            Defect        Daniel Benito   11/05/2022   Creación
    **************************************************************************/
    /**
	 * @description    Guardar los comentarios en el chatter del caso cuando se rechaza desde la 'list view'.
	 * @param listNewCase
     * @param mapOldCase
	 */  

    public static void guardarComentariosRechazo(List<Case> listNewCase, Map<Id, Case> mapOldCase) {

        List<FeedItem> chatters = new List<FeedItem>();

        for (Case reclamacion : listNewCase) {
            if(mapOldCase.containsKey(reclamacion.Id) && reclamacion.Comments != null){

                FeedItem feed = new FeedItem();
		        feed.ParentId = reclamacion.Id; 
                feed.Body = 'Se ha rechazado el caso por el motivo: ' + reclamacion.SAC_MotivoRechazo__c; 
                feed.Body += '\n Observación: ' + reclamacion.Comments;

                chatters.add(feed);

            }else if(mapOldCase.containsKey(reclamacion.Id) && reclamacion.Comments == null){

                FeedItem feed = new FeedItem();
		        feed.ParentId = reclamacion.Id; 
                feed.Body = 'Se ha rechazado el caso por el motivo: ' + reclamacion.SAC_MotivoRechazo__c; 
                feed.Body += '\n Sin observación';

                chatters.add(feed);
            }    
		}

        SAC_DatabaseDML.insertListDML(chatters, true);
    }

    /**************************************************************************
    * Proposito: Dar de baja las pretensiones de una reclamación cuando esta se rechaza desde el botón de la list view
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            Defect        Daniel Benito   26/06/2022       Creación
    **************************************************************************/
    /**
	 * @description    Dar de baja las pretensiones de una reclamación cuando esta se rechaza desde el botón de la list view
	 * @param listNewCase
	 */  


    public static void bajaPretensionesRechazo(List<Case> listNewCase) {
        List<Id> idReclamaciones = new List<Id>();
        List<Case> pretensiones = new List<Case>();

        for(Case reclamacion : listNewCase){

            idReclamaciones.add(reclamacion.id);
        }
        pretensiones = [SELECT id, SAC_StatusAuxiliar__c, Status FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN: idReclamaciones];

        if(!pretensiones.isEmpty()){

            for(Case pretension: pretensiones){
                pretension.Status = 'SAC_009';
                pretension.SAC_StatusAuxiliar__c = 'SAC_009';
            }

            SAC_DatabaseDML.updateListDML(pretensiones, true);
        }
    }

    /**************************************************************************
    * Proposito: Arrastrar el valor del campo SAC_EntidadProductora__c del pretensión
    *            principal a la reclamación
    * Modificacion: Comentado metodo al ser añadido la funcionalidad en el metodo entidadAfectadaPrincipal
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US351981        Marcela Neira   18/05/2022   Creación
    **************************************************************************/
    // public static void entidadProductoraPrincipal(List<Case> listaCasosSelect, List<Case> listNewCase, Map<Id, Case> mapaDatosCasosActualizar) {
    //     Map<Id,Case> mapaCasosSelect = new Map<Id,Case>(listaCasosSelect);
    //     for (Case caso : listNewCase) {
    //         if (mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
    //             mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_EntidadProductora__c = mapaCasosSelect.get(caso.SAC_Reclamacion__c).SAC_EntidadProductora__c;
    //         } else if(mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && !mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
    //             Case reclamacionActualizar = new Case();
    //             reclamacionActualizar.Id = caso.SAC_Reclamacion__c;
    //             reclamacionActualizar.SAC_EntidadProductora__c = caso.SAC_EntidadProductora__c;
    //             mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
    //         }
    //     }
    // }

    /**************************************************************************
    * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 45 dias.
    * La clase schedulable creará una alerta si la reclamación sigue en negociación.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US418231         CS             06/09/2022   Creación
    **************************************************************************/
        /**
	 * @description    Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 45 dias.
	 * @param listNewRecPret
	 */ 
    public static void scheduleAlertaNegociacion(List<Case> listNewRecPret) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (Case caso : listNewRecPret) {
            CBK_SCH_PendingProcess__c pendingProcessCaso = new CBK_SCH_PendingProcess__c();
            pendingProcessCaso.recordId__c = caso.Id;
            pendingProcessCaso.Schedule_Time__c = system.now().addDays(45);
            pendingProcessCaso.className__c = 'SAC_SchedulableNegociacion';
            listaPendingProcess.add(pendingProcessCaso);
        }

        if (!listaPendingProcess.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    }

    /**************************************************************************
    * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 10 dias.
    * La clase schedulable creará una alerta si la reclamación sigue en subsanación.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US418231         CS             06/09/2022   Creación
    **************************************************************************/
    /**
	 * @description    Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 10 dias.
	 * @param listNewRecPret
	 */ 
    public static void scheduleAlertaSubsanacion(List<Case> listNewRecPret) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (Case caso : listNewRecPret) {
            CBK_SCH_PendingProcess__c pendingProcessCaso = new CBK_SCH_PendingProcess__c();
            pendingProcessCaso.recordId__c = caso.Id;
            pendingProcessCaso.Schedule_Time__c = system.now().addDays(10);
            pendingProcessCaso.className__c = 'SAC_SchedulableSubsanacion';
            listaPendingProcess.add(pendingProcessCaso);
        }

        if (!listaPendingProcess.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    }


    public static void guardarUsuario(List<Case> listNewCase){
        Id userId = UserInfo.getUserId();
        //Recorrer la lista de casos que acaban de pasar a subsanación o negociación
        for (Case caso : listNewCase) {
            //Si cambia una reclamación y el owner es el usuario que ejecuta, es el gestor
            if (caso.RecordTypeId == RECTYPERECLAMACION && caso.OwnerId == userId) {
                caso.CC_SuppliedUser__c = 'Ges';
            //Si cambia una reclamación y el owner NO es el usuario que ejecuta, es el letrado
            } else if(caso.RecordTypeId == RECTYPERECLAMACION && caso.OwnerId != userId) {
                caso.CC_SuppliedUser__c = 'Let';
            //Si cambia una pretensión y el owner es el usuario que ejecuta, es el letrado
            } else if(caso.RecordTypeId == RECTYPEPRETENSION && caso.OwnerId == userId) {
                caso.CC_SuppliedUser__c = 'Let';
            //Si cambia una pretensión y el owner NO es el usuario que ejecuta, es el gestor
            } else if(caso.RecordTypeId == RECTYPEPRETENSION && caso.OwnerId != userId) {
                caso.CC_SuppliedUser__c = 'Ges';
            }
        }
    }

    /**************************************************************************
    * Proposito: Rellenar el campo SAC_GrupoLetrado__c de la reclamación cuando cambia el campo SEG_Grupo__c
    * de la pretensión principal hija. Se llama en el SAC_Case_AU.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --               CS             06/09/2022   Creación
    **************************************************************************/
    /**
	 * @description    Rellenar el campo SAC_GrupoLetrado__c de la reclamación cuando cambia el campo SEG_Grupo__c
    * de la pretensión principal hija. Se llama en el SAC_Case_AU.
	 * @param listaPretensionGrupoCambiado
     * @param listaCasosSelect
     * @param mapaDatosCasosActualizar
	 */ 
    public static void informarGrupoLetrado(List<Case> listaPretensionGrupoCambiado, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar) {
        //Pasar listaCasosSelect a mapa
        Map<Id, Case> mapaCasosSelect = new Map<Id, Case>();
        for (Case caso : listaCasosSelect) {
            mapaCasosSelect.put(caso.Id, caso);
        }

        //Recorrer las pretensiones a las que les ha cambiado el grupo, y mandar a actualizar la reclamación que contiene dicha pretensión como principal
        //con el cambio de grupo hecho
        for (Case pret : listaPretensionGrupoCambiado) {
            if (mapaCasosSelect.containsKey(pret.SAC_Reclamacion__c) && mapaCasosSelect.get(pret.SAC_Reclamacion__c).SAC_PretensionPrincipal__c == pret.Id && String.isNotBlank(pret.SEG_Grupo__c)) {
                if (mapaDatosCasosActualizar.containsKey(pret.SAC_Reclamacion__c)) {
                    mapaDatosCasosActualizar.get(pret.SAC_Reclamacion__c).SAC_GrupoLetrado__c = pret.SEG_Grupo__c;
                } else {
                    Case rec = new Case();
                    rec.Id = pret.SAC_Reclamacion__c;
                    rec.SAC_GrupoLetrado__c = pret.SEG_Grupo__c;
                    mapaDatosCasosActualizar.put(rec.Id, rec);
                }
            }
        }
    }


    /**************************************************************************
    * Proposito: Cuando se cambia el idioma de la reclamación, se cambia el footer y la plantilla lateral del documento redacción
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1005847       Álex Polo      15/11/2024   Creación
    **************************************************************************/
    /**
	 * @description    Cuando se cambia el idioma de la reclamación, se cambia el footer y la plantilla lateral del documento redacción
	 * @param listaCasosSelect
     * @param listaCasosCambiaIdioma
	 */ 
    public static void actualizarPlantillaLateral(List<Case> listaCasosSelect, List<Case> listaCasosCambiaIdioma){
        Map<Id, Case> mapaReclamacionesCambiaIdioma = new Map<Id, Case>();
        Set<Id> idsReclamaciones = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();

        List<SAC_DocumentoEnvio__c> listaDocumentos = new List<SAC_DocumentoEnvio__c>();
        Map<Id, SAC_DocumentoEnvio__c> mapaDocumentos = new Map<Id, SAC_DocumentoEnvio__c>();

        List<SAC_DocumentoEnvio__c> listaDocumentosUpdate = new List<SAC_DocumentoEnvio__c>();

        List<EmailTemplate> lstPlantillas = new List<EmailTemplate>();
        Map<String, EmailTemplate> mapaEmailTemplates = new Map<String, EmailTemplate>();


        for (Case caso : listaCasosCambiaIdioma) {
            mapaReclamacionesCambiaIdioma.put(caso.Id, caso);
            idsReclamaciones.add(caso.Id);
            listaReclamaciones.add(caso);
        }

        if(!idsReclamaciones.isEmpty()){
            listaDocumentos = [SELECT Id, SAC_Caso__c, SAC_NombrePlantillaLateral__c, createdDate FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c IN :idsReclamaciones AND SAC_TipoDocumento__c = 'redaccion' ORDER by createdDate desc];
            if(EmailTemplate.SObjectType.getDescribe().isAccessible()){
                lstPlantillas = [SELECT Id, Name, HtmlValue, DeveloperName FROM EmailTemplate WHERE Developername IN ('SAC_Footer', 'SAC_Footer_ENG', 'SAC_FOOTER_CAT', 'SAC_FOOTER_Valenciano', 'SAC_FOOTER_Gallego', 'SAC_FOOTER_Euskera')];
            }



            if(!listaDocumentos.isEmpty()){
                for(SAC_DocumentoEnvio__c doc : listaDocumentos){
                    if(!mapaDocumentos.containsKey(doc.SAC_Caso__c)){ 
                        mapaDocumentos.put(doc.SAC_Caso__c, doc);       //Se añade solo el primero, ya que al estar ordenados por DESC, será el primero de la lista
                    }
                }
            }

            if(!lstPlantillas.isEmpty()){
                for(EmailTemplate em : lstPlantillas){
                    if(!mapaEmailTemplates.containsKey(em.DeveloperName)){ 
                        mapaEmailTemplates.put(em.DeveloperName, em);       
                    }
                }
            }


            for(Case caso : listaReclamaciones){
                if(mapaDocumentos.containsKey(caso.Id)){        //Si esta reclamación ya tiene documento, se cambia su plantilla lateral en función del nuevo idioma
                    SAC_DocumentoEnvio__c documentoNuevo = new SAC_DocumentoEnvio__c();
                    documentoNuevo.Id = mapaDocumentos.get(caso.Id).Id;
                    if(caso.CC_Idioma__c == 'en'){              //Si el nuevo idioma es inglés
                        documentoNuevo.SAC_NombrePlantillaLateral__c = 'SAC_Lateral_ENG';
                        if(mapaEmailTemplates.containsKey('SAC_Footer_ENG')){       //También se le asocia un footer según el idioma
                            documentoNuevo.SAC_Footer__c = mapaEmailTemplates.get('SAC_Footer_ENG').HtmlValue;
                        }

                    }else if(caso.CC_Idioma__c == 'ca'){                                 //Si el nuevo idioma es catalán
                        documentoNuevo.SAC_NombrePlantillaLateral__c = 'SAC_Lateral_CAT';
                        if(mapaEmailTemplates.containsKey('SAC_FOOTER_CAT')){
                            documentoNuevo.SAC_Footer__c = mapaEmailTemplates.get('SAC_FOOTER_CAT').HtmlValue;
                        }
                    }else if(caso.CC_Idioma__c == 'va'){
                        documentoNuevo.SAC_NombrePlantillaLateral__c = 'SAC_CartaPlantilla';  //La lateral será castellano si el idioma es valenciano
                        if(mapaEmailTemplates.containsKey('SAC_FOOTER_Valenciano')){
                            documentoNuevo.SAC_Footer__c = mapaEmailTemplates.get('SAC_FOOTER_Valenciano').HtmlValue;
                        }
                    }else if(caso.CC_Idioma__c == 'ga'){
                        documentoNuevo.SAC_NombrePlantillaLateral__c = 'SAC_CartaPlantilla';    //La lateral será castellano si el idioma es gallego
                        if(mapaEmailTemplates.containsKey('SAC_FOOTER_Gallego')){
                            documentoNuevo.SAC_Footer__c = mapaEmailTemplates.get('SAC_FOOTER_Gallego').HtmlValue;
                        }
                    }else if(caso.CC_Idioma__c == 'eu'){
                        documentoNuevo.SAC_NombrePlantillaLateral__c = 'SAC_CartaPlantilla';    //La lateral será castellano si el idioma es euskera
                        if(mapaEmailTemplates.containsKey('SAC_FOOTER_Euskera')){
                            documentoNuevo.SAC_Footer__c = mapaEmailTemplates.get('SAC_FOOTER_Euskera').HtmlValue;
                        }
                    }else{                                      //Si el nuevo idioma es castellano o cualquier otro
                        documentoNuevo.SAC_NombrePlantillaLateral__c = 'SAC_CartaPlantilla';    
                        if(mapaEmailTemplates.containsKey('SAC_Footer')){
                            documentoNuevo.SAC_Footer__c = mapaEmailTemplates.get('SAC_Footer').HtmlValue;
                        }
                    }
                    listaDocumentosUpdate.add(documentoNuevo);
                    
                }
            }

            //Actualizar los documentos existentes
            if(!listaDocumentosUpdate.isEmpty()){ SAC_DatabaseDML.updateListDML(listaDocumentosUpdate, true); }
            

        }


    }



    /**************************************************************************
    * Proposito: Crear una task para el proyecto mis clientes. Se llama en el trigger AU de case
    * en el momento en el que se informa una fecha de resolución. La task solo se crea para las
    * reclamaciones que tienen activado el check de SAC_GenerarTaskMisClientes__c, no tienen un sentido
    * de resolución de inadmisión, y que solo tengan una única pretensión.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US542308         CS             10/05/2023   Creación
    * 1.1            US867835         Raúl Santos    01/04/2024   Modificación: sustituir la creación de la task de mis clientes por la creación de un pending process por cada reclamación.
    *                                                                           posteriormente, en el pending process se creará la task correspondiente.                                                                        
    **************************************************************************/
    /**
	 * @description    Crear una task para el proyecto mis clientes.
	 * @param listaRecPreFechaResolucion
     * @param listaCasosSelect
	 */ 

    public static void crearTaskMisClientes(List<Case> listaRecPreFechaResolucion, List<Case> listaCasosSelect) {

        //Pasar listaCasosSelect a mapa
        Map<Id, Case> mapaCasosSelect = new Map<Id, Case>();
        for (Case casoSelect : listaCasosSelect) {
            mapaCasosSelect.put(casoSelect.Id, casoSelect);
        }
        //Comprobar que el mcc de la reclamación tiene activado el check de SAC_GenerarTaskMisClientes__c y que el sentido de la resolución de la reclamación es distinto a inadmisión,
        //para guardarlas en una lista y posteriormente comprobar que solo tienen una pretensión
        Map<Id, Integer> mapaReclamacionNumeroPrets = new Map<Id, Integer>();
        for (Case caso : listaRecPreFechaResolucion) {
            if (caso.recordTypeId == RECTYPERECLAMACION && mapaCasosSelect.containsKey(caso.Id) && mapaCasosSelect.get(caso.Id).SEG_Detalle__r.SAC_GenerarTaskMisClientes__c && caso.SAC_SentidoResolucion__c != 'SAC_004'
                && caso.OS_Fecha_Resolucion__c != null) {
                mapaReclamacionNumeroPrets.put(caso.Id, 0);
            }
        }

        //Comprobar cuantas pretensiones tiene cada reclamación
        if (!mapaReclamacionNumeroPrets.isEmpty()) {
            for (Case casoSelect : listaCasosSelect) {
                if (mapaReclamacionNumeroPrets.containsKey(casoSelect.SAC_Reclamacion__c)) {
                    Integer numeroPrets = mapaReclamacionNumeroPrets.get(casoSelect.SAC_Reclamacion__c) + 1; 
                    mapaReclamacionNumeroPrets.put(casoSelect.SAC_Reclamacion__c, numeroPrets);
                }
            }
    
            //Preparar una lista con las reclamaciones a las que se les tiene que insertar la task (solo las que el numero de sus pretensiones sea 1)
            List<Id> listaReclamacionAInsertarTask = new List<Id>();
            for (Id ideRecla : mapaReclamacionNumeroPrets.keySet()) {
                if (mapaReclamacionNumeroPrets.get(ideRecla) == 1) {
                    listaReclamacionAInsertarTask.add(ideRecla);
                }
            }
    
            //Crear un pending process por cada reclamacion (posteriormente en este se creará la task)
            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

            for (Id ideRecla : listaReclamacionAInsertarTask) {
                CBK_SCH_PendingProcess__c pendingProcessReclamacion = new CBK_SCH_PendingProcess__c();
                pendingProcessReclamacion.recordId__c = ideRecla;
                pendingProcessReclamacion.Schedule_Time__c = system.now().addMinutes(2);
                pendingProcessReclamacion.className__c = 'SAC_SchedulableTaskMisClientes';
                listaPendingProcess.add(pendingProcessReclamacion);
            }

             //Insertar registros
            if (!listaPendingProcess.isEmpty()) {
                SAC_DatabaseDML.insertListDML(listaPendingProcess, true);
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
     * 1.0            US392178      Sergio Martín    11/07/2023       Creación
    *****************************************************************/
    /**
	 * @description    Comprobar que el campo SAC_ResultadoNegociacion__c de la reclamación se complete bien cuando se cambia el campo en la pretensión
	 * @param listaCambioResultadoNegociacion
     * @param listaCasosSelect
     * @param mapaDatosCasosActualizar
	 */ 
    public static void comprobarResultadoNegociacion(List<Case> listaCambioResultadoNegociacion, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar) {
        Set<String> resultados = new Set<String>();
        String resultadoReclamacion; 
        Id idReclamacion;
       
        for (Case caso : listaCasosSelect) {
            if(caso.recordTypeId == RECTYPERECLAMACION) {
                idReclamacion = caso.id;
            } else if(caso.recordTypeId == RECTYPEPRETENSION && caso.SAC_ResultadoNegociacion__c != null) {
                resultados.add(caso.SAC_ResultadoNegociacion__c);
            }
        }

        if(resultados.contains('Con acuerdo') && resultados.size() == 1) { // Si todas son con acuerdo -> con acuerdo
            resultadoReclamacion = 'Con acuerdo';
        } else if(resultados.contains('Sin acuerdo') && resultados.size() == 1) { // Si todas son sin acuerdo -> sin acuerdo
            resultadoReclamacion = 'Sin acuerdo';
        } else if(resultados.contains('Sin respuesta') && resultados.size() == 1) { // Si todas son sin respuesta -> sin respuesta
            resultadoReclamacion = 'Sin respuesta';
        } else if(resultados.contains('Con acuerdo') && resultados.contains('Sin acuerdo')) { // Si hay una pretension con acuerdo y otra sin acuerdo -> con acuerdo parcial
            resultadoReclamacion = 'Con acuerdo parcial';
        } else if(resultados.contains('Con acuerdo') && resultados.contains('Sin respuesta')) { // Si hay una pretension con acuerdo y otra sin respuesta -> con acuerdo
            resultadoReclamacion = 'Con acuerdo';
        } else if(resultados.contains('Sin acuerdo') && resultados.contains('Sin respuesta')) { // Si hay una pretension sin acuerdo y otra sin respuesta -> sin acuerdo
            resultadoReclamacion = 'Sin acuerdo';
        }

        if (mapaDatosCasosActualizar.containsKey(idReclamacion)) {
            mapaDatosCasosActualizar.get(idReclamacion).SAC_ResultadoNegociacion__c = resultadoReclamacion;
        } else {
            Case rec = new Case();
            rec.Id = idReclamacion;
            rec.SAC_ResultadoNegociacion__c = resultadoReclamacion;
            mapaDatosCasosActualizar.put(rec.Id, rec);
        }
    }


    public static void informarFechaUltimaActualizacion(List<Case> listaBalanceoLetrado) {

        for (Case caso : listaBalanceoLetrado) {
            caso.SAC_FechaUltimaAsignacionLetrado__c = System.now();
   
        }
    }

    public static void informarEsCliente(List<Case> listaCambioCliente) {
        //Guardar ids de las Accounts para su búsqueda
        Set<Id> setIdsAccounts = new Set<Id>();
        for (Case caso : listaCambioCliente) {
            if (String.isNotBlank(caso.AccountId)) {
                setIdsAccounts.add(caso.AccountId);
            } else {
                //Si el caso a pasado a tener el AccountId en nulo, se pone falso en el check de empleado
                caso.SAC_Empleado__c = false;
            }
        }

        if(!setIdsAccounts.isEmpty()){
            //Buscar accounts de los casos
            Map<Id, Account> mapaAccounts = new Map<Id, Account>([SELECT Id, AV_Empleado__c FROM Account WHERE Id IN :setIdsAccounts]);

            //Asignar check empleado al caso
            for (Case caso : listaCambioCliente) {
                if (mapaAccounts.containsKey(caso.AccountId)) {
                    caso.SAC_Empleado__c = mapaAccounts.get(caso.AccountId).AV_Empleado__c;
                }
            }
        }
    }

    @AuraEnabled
    public static void validarReclamacion(List<Case> listaValidacionPretension, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar){
      
        Map<Id, Map<Id, Case>> mapReclaPret = new Map <Id, Map<Id, Case>>();

        //Montar mapa con los casos del select
        Map<Id, Case> mapaCasosSelect = new Map <Id, Case>();
        for (Case casoSelect : listaCasosSelect) {
            mapaCasosSelect.put(casoSelect.Id, casoSelect);
        }

        //Montar mapa con key reclamación (cuya pret se ha actualizado el check) y valor mapa con pretension que ha cambiado el check
        for (Case prete : listaValidacionPretension) {
            if (mapaCasosSelect.containsKey(prete.SAC_Reclamacion__c)) {
                if (!mapReclaPret.containsKey(prete.SAC_Reclamacion__c)) {
                    Map<Id, Case> mapPrets =  new Map<Id, Case>();
                    mapPrets.put(prete.Id, prete);
                    mapReclaPret.put(prete.SAC_Reclamacion__c, mapPrets);
                }else{
                    mapReclaPret.get(prete.SAC_Reclamacion__c).put(prete.Id, prete);
                }
            }
        }

        //Completar mapa con reclamacion y mapa de pretensiones con el resto de pretensiones hermanas del select
        for (Case casoSelect : listaCasosSelect) {
            if (mapReclaPret.containsKey(casoSelect.SAC_Reclamacion__c) && !mapReclaPret.get(casoSelect.SAC_Reclamacion__c).containsKey(casoSelect.Id)) {
                mapReclaPret.get(casoSelect.SAC_Reclamacion__c).put(casoSelect.Id, casoSelect);
            }
        }
        for (Id idCaso : mapReclaPret.keySet()) {
            
            Boolean esValida = true;
            for(Id idPretehija : mapReclaPret.get(idCaso).keySet()){
                if(!mapReclaPret.get(idCaso).get(idPretehija).SAC_ValidacionMCC__c && mapReclaPret.get(idCaso).get(idPretehija).Status != 'SAC_009'){
                    esValida = false;
                    break;
                }
            }
            if(mapaCasosSelect.containsKey(idCaso) && esValida != mapaCasosSelect.get(idCaso).SAC_ValidacionMCC__c){
                if(mapaDatosCasosActualizar.containsKey(idCaso)){
                    mapaDatosCasosActualizar.get(idCaso).SAC_ValidacionMCC__c = esValida;
                }else{
                    mapaCasosSelect.get(idCaso).SAC_ValidacionMCC__c = esValida;
                    mapaDatosCasosActualizar.put(idCaso, mapaCasosSelect.get(idCaso));
                }
            }
        }
    }

    //Informa la fecha de derivación en la reclamación cuando esta entra en este estado
    public static void informarFechaDerivacion(List<Case> listaCasoDerivacion) {

        for (Case caso : listaCasoDerivacion) {
            caso.SAC_FechaDerivacion__c = System.now();
   
        }
    }

    //Informa la fecha de ejecución en la reclamación cuando esta entra en este estado
    public static void informarFechaEjecucion(List<Case> listaCasoEjecucion) {

        for (Case caso : listaCasoEjecucion) {
            caso.SAC_FechaEjecucion__c = System.now();
   
        }
    }

    /**************************************************************************
    * Proposito: Informa el campo SAC_DetenidoDesde__c que contiene 
    *            el valor del campo StopStartDate cuando se pasa a subsanación
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US959472     Sergio Martín   11/07/2024       Creación
    **************************************************************************/
    /**
	 * @description    Comnforma el campo SAC_DetenidoDesde__c que contiene el valor del campo StopStartDate cuando se pasa a subsanación
	 * @param listaCasosSubsanacion
	 */ 
    public static void informarDetenidoDesde(List<Case> listaCasosSubsanacion) {
        for (Case caso : listaCasosSubsanacion) {
            caso.SAC_DetenidoDesde__c = System.now();
        }
    }

    /*****************************************************************
    * @description comprueba si la reclamación en la que ha cambiado el campo SAC_GrupoLetrado__c, esta asociada a alguna consulta SAC, para en caso afirmativo, actualizar el campo SAC_GrupoLetrado__c de la consulta
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.0             US683740      Raúl Santos       05/11/24        Creación
    *****************************************************************/
    public static void informarGrupoLetradoConsultaSAC(List<Case> listaRecCambioGrupoLetrado, Set<Id> idsReclamacion) {
        Map<Id,Case> mapReclamaciones = new Map<Id,Case>( listaRecCambioGrupoLetrado );
        List<Case> listConsultasSAC = new List<Case>();

        if(Case.SObjectType.getDescribe().isAccessible()){
            listConsultasSAC = [SELECT Id, CC_CasoRelacionado__c, CC_CasoRelacionado__r.SAC_GrupoLetrado__c FROM Case WHERE RecordTypeId = :RECTYPECONSULTASAC AND CC_CasoRelacionado__c IN :idsReclamacion];
        }

        if(!listConsultasSAC.isEmpty()){
            for(Case consulta : listConsultasSAC){  
                if(mapReclamaciones.containsKey(consulta.CC_CasoRelacionado__c)){
                    consulta.SAC_GrupoLetrado__c = mapReclamaciones.get(consulta.CC_CasoRelacionado__c).SAC_GrupoLetrado__c;
                    consulta.SAC_Letrado__c = 'Pte. Asignar';
                }   
            }

            SAC_DatabaseDML.updateListDML(listConsultasSAC, true);
        }
    }
    
    /********************************************************************************************************
     * Proposito: Si se modifica el campo SAC_ResumenManual__c en alguna de la pretensiones
     *            modificar el campo SAC_ResumenManual de la reclamación
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1026683          Carlos Gómez   7/11/2024      Creación
    *********************************************************************************************************/
    /**
	 * @description    Si se modifica el campo SAC_ResumenManual__c en alguna de la pretensiones modificar el campo SAC_ResumenManual de la reclamación
	 * @param listaCasosSelect
     * @param listNewCase
     * @param mapaDatosCasosActualizar
	 */ 
    public static void actualizarResumenManual(List<Case> listaCasosSelect, List<Case> listNewCase, Map<Id, Case> mapaDatosCasosActualizar) {
        Map<Id,Case> mapaCasosSelect = new Map<Id,Case>(listaCasosSelect);
        Id idReclamacion;
        String resumen = '';
        for (Case caso : listaCasosSelect) {
            if(caso.recordTypeId == RECTYPERECLAMACION) {
                idReclamacion = caso.id;
            } else if(caso.recordTypeId == RECTYPEPRETENSION && caso.SAC_ResumenManual__c != null && caso.Status != 'SAC_009') { 
                resumen += 'Resumen pretensión '+ caso.CaseNumber +': ' + '\r\n' + caso.SAC_ResumenManual__c + '\r\n\r\n';
            }

        }

        for (Case caso : listNewCase) {
            if (mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                mapaDatosCasosActualizar.get(caso.SAC_Reclamacion__c).SAC_ResumenManual__c = resumen;

            } else if(mapaCasosSelect.containsKey(caso.SAC_Reclamacion__c) && !mapaDatosCasosActualizar.containsKey(caso.SAC_Reclamacion__c)) {
                Case reclamacionActualizar = new Case();
                reclamacionActualizar.Id = caso.SAC_Reclamacion__c;
                reclamacionActualizar.SAC_ResumenManual__c = resumen;
                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
            }
        }
    }

    /********************************************************************************************************
     * Proposito: Si se modifica el campo SAC_ResumenManual__c y estan todas sus pretensiones con este 
     *              campo relleno, se pondrá a true el campo SAC_CheckResumen__c de la reclamacion
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1026683        Carlos Gómez   7/11/2024      Creación
    *********************************************************************************************************/ 
    /**
	 * @description    Si se modifica el campo SAC_ResumenManual__c y estan todas sus pretensiones con este campo relleno, se pondrá a true el campo SAC_CheckResumen__c de la reclamacion
	 * @param listaCasosSelect
     * @param listaValidacionPretension
     * @param mapaDatosCasosActualizar
	 */ 

    @AuraEnabled
    public static void validarResumenManual( List<Case> listaCasosSelect, List<Case> listaValidacionPretension, Map<Id, Case> mapaDatosCasosActualizar){
    
        Map<Id, Map<Id, Case>> mapReclaPret = new Map <Id, Map<Id, Case>>();

        //Montar mapa con los casos del select
        Map<Id, Case> mapaCasosSelect = new Map <Id, Case>();
        for (Case casoSelect : listaCasosSelect) {
            mapaCasosSelect.put(casoSelect.Id, casoSelect);
        }

        //Montar mapa con key reclamación (cuya pret se ha actualizado el campo SAC_ResumenManual__c )
        for (Case prete : listaValidacionPretension) {
            if (mapaCasosSelect.containsKey(prete.SAC_Reclamacion__c)) {
                if (!mapReclaPret.containsKey(prete.SAC_Reclamacion__c)) {
                    Map<Id, Case> mapPrets =  new Map<Id, Case>();
                    mapPrets.put(prete.Id, prete);
                    mapReclaPret.put(prete.SAC_Reclamacion__c, mapPrets);
                }else{  mapReclaPret.get(prete.SAC_Reclamacion__c).put(prete.Id, prete);
                }
            }
        }

        //Completar mapa con reclamacion y mapa de pretensiones con el resto de pretensiones hermanas del select
        for (Case casoSelect : listaCasosSelect) {
            if (mapReclaPret.containsKey(casoSelect.SAC_Reclamacion__c) && !mapReclaPret.get(casoSelect.SAC_Reclamacion__c).containsKey(casoSelect.Id)) {
                mapReclaPret.get(casoSelect.SAC_Reclamacion__c).put(casoSelect.Id, casoSelect);
            }
        }
        for (Id idCaso : mapReclaPret.keySet()) { 
            Boolean esValida = true;
            for(Id idPretehija : mapReclaPret.get(idCaso).keySet()){
                if((mapReclaPret.get(idCaso).get(idPretehija).SAC_ResumenManual__c == null || mapReclaPret.get(idCaso).get(idPretehija).SAC_ResumenManual__c == '') &&  mapReclaPret.get(idCaso).get(idPretehija).Status != 'SAC_009' ){ esValida = false; break;}
            }
            if(mapaCasosSelect.containsKey(idCaso) && esValida != mapaCasosSelect.get(idCaso).SAC_CheckResumen__c){
                if(mapaDatosCasosActualizar.containsKey(idCaso)){
                    mapaDatosCasosActualizar.get(idCaso).SAC_CheckResumen__c = esValida;
                }else{ mapaCasosSelect.get(idCaso).SAC_CheckResumen__c = esValida; mapaDatosCasosActualizar.put(idCaso, mapaCasosSelect.get(idCaso));
                }
            }
        }
    }
    /**************************************************************************
     * Proposito: Inserta permisos para que el gestor de la reclamación pueda tener permisos
     * sobre las pretensiones hijas.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --              Iria ANPC    07/01/2025       Creación
    **************************************************************************/
    /**
	 * @description    Inserta permisos para que el gestor de la reclamación pueda tener permisos sobre las pretensiones hijas, 
	 * 				   y para que pueda tener permisos sobre la reclamación el gestor de la pretensión.
     * @param casos
	 */  

    public static void insertarCaseSharePorReclamacionOPretension(List<Case> casos) {
        if (casos.isEmpty()) {
            return;
        }
        
        // Identificar IDs de reclamaciones y pretensiones
        Set<Id> idsReclamaciones = new Set<Id>();
        Set<Id> idsPretensiones = new Set<Id>();
        
        for (Case caso : casos) {
            if (caso.SAC_Reclamacion__c == null) {
                idsReclamaciones.add(caso.Id); // Es una reclamación
            } else {
                idsPretensiones.add(caso.Id);  // Es una pretensión
            }
        }
        
        // Mapas para almacenar relaciones
        Map<Id, List<Case>> mapaReclamacionAPretensiones = new Map<Id, List<Case>>();
        Map<Id, Case> mapaPretensionAReclamacion = new Map<Id, Case>();
        
        // Obtener pretensiones relacionadas a las reclamaciones
        if (!idsReclamaciones.isEmpty()) {
            List<Case> pretensiones = [SELECT Id, OwnerId, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c IN :idsReclamaciones];
            for (Case pret : pretensiones) {
                if (!mapaReclamacionAPretensiones.containsKey(pret.SAC_Reclamacion__c)) {
                    mapaReclamacionAPretensiones.put(pret.SAC_Reclamacion__c, new List<Case>());
                }
                mapaReclamacionAPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
            }
        }
        
        // Obtener pretensiones y sus reclamaciones padres
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();
        if (!idsPretensiones.isEmpty()) {
            List<Case> pretensiones = [SELECT Id, OwnerId, SAC_Reclamacion__c FROM Case WHERE Id IN :idsPretensiones];
            Set<Id> idsReclamacionesDesdePretensiones = new Set<Id>();
            
            for (Case pret : pretensiones) {
                if (pret.SAC_Reclamacion__c != null) {
                    idsReclamacionesDesdePretensiones.add(pret.SAC_Reclamacion__c);
                    mapaPretensionAReclamacion.put(pret.Id, pret);
                }
            }
            
            // Obtener las reclamaciones padres
            if (!idsReclamacionesDesdePretensiones.isEmpty()) {
                List<Case> reclamaciones = [SELECT Id, OwnerId FROM Case WHERE Id IN :idsReclamacionesDesdePretensiones];
                for (Case rec : reclamaciones) {
                    mapaReclamaciones.put(rec.Id, rec);
                }
            }
        }
        
        // Lista de CaseShare a insertar
        List<CaseShare> listaCaseShares = new List<CaseShare>();
        
        // Crear manual shares para pretensiones desde reclamaciones
        for (Id idReclamacion : mapaReclamacionAPretensiones.keySet()) {
            Case reclamacion = mapaReclamaciones.get(idReclamacion);
            if (reclamacion != null) {
                for (Case pretension : mapaReclamacionAPretensiones.get(idReclamacion)) {
                    CaseShare cs = new CaseShare();
                    cs.CaseId = pretension.Id;
                    cs.UserOrGroupId = reclamacion.OwnerId;
                    cs.CaseAccessLevel = 'Edit';
                    cs.RowCause = 'Manual';
                    listaCaseShares.add(cs);
                }
            }
        }
        
        // Crear manual shares para reclamaciones desde pretensiones
        for (Id idPretension : mapaPretensionAReclamacion.keySet()) {
            Case pretension = mapaPretensionAReclamacion.get(idPretension);
            Case reclamacion = mapaReclamaciones.get(pretension.SAC_Reclamacion__c);
            if (reclamacion != null) {
                CaseShare cs = new CaseShare();
                cs.CaseId = reclamacion.Id;
                cs.UserOrGroupId = pretension.OwnerId;
                cs.CaseAccessLevel = 'Edit';
                cs.RowCause = 'Manual';
                listaCaseShares.add(cs);
            }
        }
        
        // Insertar los manual shares si hay registros
        if (!listaCaseShares.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaCaseShares, false);
        }
    }



    /**************************************************************************
     * Proposito: Al cambiar el grupo letrado de la consulta SAC, el owner letrado pasará a ser 'Pte. Asignar'
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US683740      Raúl Santos    09/01/25        Creación
    **************************************************************************/
    /**
	 * @description Al cambiar el grupo letrado de la consulta SAC, el owner letrado pasará a ser 'Pte. Asignar'
     * @param listConsultaSAC
	 */  

    public static void reasignarOwnerLetrado(List<Case> listConsultaSAC){
        for(Case caso : listConsultaSAC){
            caso.SAC_Letrado__c = 'Pte. Asignar';
        }
    }

    /**
	 * @description Al cambiar el campo CC_CasoRelacionado__c, verificar que el registro informado es una reclamación SAC
	 */  

    public static void validarCambioCasoRelacionado(List<Case> listUpdate, Map<Id, Case> mapOldCase, Set<Id> idsRelacionados){

        Set<Id> idsCasosRel = new Set<Id>();
        List<Case> listRelacionadas = [SELECT Id FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :idsRelacionados];
        if(!listRelacionadas.isEmpty()){
            for(Case rel : listRelacionadas){
                idsCasosRel.add(rel.Id);
            }
        }

        if(!idsCasosRel.isEmpty()){ //Vinculación con botón o vinculación editando el campo CC_CasoRelacionado__c (Reclamacion SAC)
            for(Case caso : listUpdate){
                if(!idsCasosRel.contains(caso.Id)){
                    if(caso.CC_CasoRelacionado__c != null && !idsCasosRel.contains(caso.CC_CasoRelacionado__c)){
                        caso.addError('Solo puede informar registros de SAC reclamación en el campo "Caso relacionado"');
                    }
                }
            }
        }else{ //Conversión a consulta COPS o vinculación editando el campo CC_CasoRelacionado__c (Consulta COPS/SAC)
            for(Case caso : listUpdate){
                if(mapOldCase.containsKey(caso.Id) && caso.Status == mapOldCase.get(caso.Id).Status){ //Edicción del campo CC_CasoRelacionado__c (no cambia estado), lanzamos error que no se puede vincular a una consulta SAC/COPS
                                                                                                      //En caso de conversión a una consulta COPS, no debe saltar error
                    caso.addError('Solo puede informar registros de SAC reclamación en el campo "Caso relacionado"');
                }
            }
        }
    }


    /**************************************************************************************************************
     * Proposito: Al modificar los campos de una reclamación cerrada se debe registrar en el case history
     *
     * Historial
     * -------
     * VERSION         USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1278295     Sergio Martín    28/07/25         Creación
    **************************************************************************************************************/
    public static void crearCaseHistoryReclamacionCerrada(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<CBK_CaseHistory__c> caseHistoryRecords = new List<CBK_CaseHistory__c>();

        Map<String,Schema.SObjectField> mfields = Schema.SObjectType.Case.fields.getMap();

        Schema.DescribeFieldResult fieldDescribe;
        
        for (Case newCase : listNewObj) {
            Case oldCase = mapOldObj.get(newCase.Id);
            for (String fieldName : mfields.keySet()) {
                
                if (newCase.get(fieldName) != oldCase.get(fieldName) && (fieldName.startsWith('sac_') || fieldName.startsWith('cc_') || fieldName.startsWith('seg_'))) {
                    fieldDescribe = mfields.get(fieldName).getDescribe();
                    String fieldLabel = fieldDescribe.getLabel();
                    Schema.SObjectField field = mfields.get(fieldName);      
                    CBK_CaseHistory__c caseHistoryRecord = new CBK_CaseHistory__c();
                    caseHistoryRecord.CBK_IsDeleted__c = false;
                    caseHistoryRecord.CBK_CaseId__c = newCase.Id;
                    caseHistoryRecord.CBK_CreatedDate__c = CBK_UtilsDate.todayDT();
                    caseHistoryRecord.CBK_DataType__c = String.valueOf(fieldDescribe.getType());
                    caseHistoryRecord.CBK_Field__c = fieldLabel;
                    caseHistoryRecord.CBK_OldValue__c = String.valueOf(oldCase.get(fieldName));
                    caseHistoryRecord.CBK_NewValue__c = String.valueOf(newCase.get(fieldName));
                    caseHistoryRecords.add(caseHistoryRecord);
                }
            }
        }
        if (!caseHistoryRecords.isEmpty()) {
            SAC_DatabaseDML.insertListDML(caseHistoryRecords, false);  
        }
    }


    /**************************************************************************************************************
     * Proposito: Al modificar los campos de una reclamación cerrada se debe registrar en el case history
     *
     * Historial
     * -------
     * VERSION         USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1278295     Sergio Martín    28/07/25         Creación
    **************************************************************************************************************/
    public static void crearCaseExtensionHistoryReclamacionCerrada(Map<Id, CBK_Case_Extension__c> mapOldObj, List<CBK_Case_Extension__c> listNewObj) {
        List<CBK_CaseHistory__c> caseHistoryRecords = new List<CBK_CaseHistory__c>();

        Map<String,Schema.SObjectField> mfields = Schema.SObjectType.CBK_Case_Extension__c.fields.getMap();
        Schema.DescribeFieldResult fieldDescribe;
        for (CBK_Case_Extension__c newCaseExtension : listNewObj) {
            CBK_Case_Extension__c oldCaseExtension = mapOldObj.get(newCaseExtension.Id);
            for (String fieldName : mfields.keySet()) {
                if (newCaseExtension.get(fieldName) != oldCaseExtension.get(fieldName) && newCaseExtension.SAC_ReclamacionCerrada__c && (fieldName.startsWith('sac_') || fieldName.startsWith('cc_') || fieldName.startsWith('seg_'))) {
                    fieldDescribe = mfields.get(fieldName).getDescribe();

                    String fieldLabel = fieldDescribe.getLabel();
                    Schema.SObjectField field = mfields.get(fieldName);      
                    CBK_CaseHistory__c caseHistoryRecord = new CBK_CaseHistory__c();
                    caseHistoryRecord.CBK_IsDeleted__c = false;
                    caseHistoryRecord.CBK_CaseId__c = newCaseExtension.Case_Id__c;
                    caseHistoryRecord.CBK_CreatedDate__c = CBK_UtilsDate.todayDT();
                    caseHistoryRecord.CBK_DataType__c = String.valueOf(fieldDescribe.getType());
                    caseHistoryRecord.CBK_Field__c = fieldLabel;
                    caseHistoryRecord.CBK_OldValue__c = String.valueOf(oldCaseExtension.get(fieldName));
                    caseHistoryRecord.CBK_NewValue__c = String.valueOf(newCaseExtension.get(fieldName));
                    caseHistoryRecords.add(caseHistoryRecord);
                }
            }
        }
        if (!caseHistoryRecords.isEmpty()) {
            SAC_DatabaseDML.insertListDML(caseHistoryRecords, false);  
        }
    }
}