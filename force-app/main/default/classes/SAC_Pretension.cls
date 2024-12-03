/*****************************************************************
 * Name: SAC_Pretension
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para el comportamiento de las pretensiones (informar el subject, MCC, etc)
 * Clase test -> SAC_Pretension_Test
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US242669         Carlos Solis   28/06/21     Creación
*****************************************************************/
public without sharing class SAC_Pretension {

    private static Set<String> objetos = new Set<String>{'Case', 'CC_MCC__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static Id recTypeMCCDetalle = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    private static Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    

    /*****************************************************************
     * Proposito: Método para rellenar el subject de la pretensión cuando se actualiza el MCC.
     * El subject pasa a tener el valor: MCC nivel 2 - MCC nivel 4
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US242669         Carlos Solis   28/06/21     Creación
    *****************************************************************/
    public static void subjectMCC(List<Case> listNewCase, Map<Id, Case> mapOldCase){
        String cadena= '';
        List<Case> listaCasos = new List<Case>();
        List<Id> listaMCCs = new List<Id>();
        for (Case caso : listNewCase) {
            if (mapOldCase.containsKey(caso.Id) && caso.SEG_Detalle__c != mapOldCase.get(caso.Id).SEG_Detalle__c && String.isNotBlank(String.valueOf(caso.SEG_Detalle__c))) {
                listaCasos.add(caso);
                listaMCCs.add(caso.CC_MCC_ProdServ__c);
                listaMCCs.add(caso.SEG_Detalle__c);
            }
        }

        if (!listaCasos.isEmpty()) {
            Map<Id, CC_MCC__c> mapaMCCs = new Map<Id, CC_MCC__c>([SELECT Id, Name FROM CC_MCC__c WHERE Id IN :listaMCCs]);
            for (Case caso : listaCasos) {
                if (mapaMCCs.containsKey(caso.CC_MCC_ProdServ__c) && mapaMCCs.containsKey(caso.SEG_Detalle__c)) {
                    caso.Subject = mapaMCCs.get(caso.CC_MCC_ProdServ__c).Name + ' - ' + mapaMCCs.get(caso.SEG_Detalle__c).Name;
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Al cambiar de estado Alta a Análisis, si la reclamación es unipretensión, ésta se
     * marca como pretensión principal
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US242669         Carlos Solis   30/06/21     Creación
    *****************************************************************/
    public static void marcarPretensionPrincipal(List<Case> listNewCase, List<Case> listaCasos, List<Id> listaIdsRec, List<Case> listaRecCambioPretPrincipal){
        List<Case> listaPretensionesHijas = new  List<Case>();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        
        Map<Id,List<Case>> mapaCasos = new Map<Id, List<Case>>(); 

        for (Case caso : listaCasos) {
            if (mapaCasos.containsKey(caso.SAC_Reclamacion__c)){
                mapaCasos.get(caso.SAC_Reclamacion__c).add(caso);
            }else{
                List<Case> lista = new List<Case>();
                lista.add(caso);
                mapaCasos.put(caso.SAC_Reclamacion__c, lista);
            }
        }
        for(Id ide: listaIdsRec){                              
            if (mapaCasos.containsKey(ide)) {
                listaPretensionesHijas.addAll(mapaCasos.get(ide));
            }
        } 
                
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

        for (Case caso : listNewCase) {
            if (mapaRecPretensiones.containsKey(caso.Id) && mapaRecPretensiones.get(caso.Id).size() == 1) {
                caso.SAC_PretensionPrincipal__c = mapaRecPretensiones.get(caso.Id).get(0).Id;
                caso.SAC_Entidad_Afectada__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_Entidad_Afectada__c;
                caso.SAC_EntidadProductora__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_EntidadProductora__c;
                // caso.CC_MCC_Tematica__c = mapaRecPretensiones.get(caso.Id).get(0).CC_MCC_Tematica__c;
                // caso.CC_MCC_ProdServ__c = mapaRecPretensiones.get(caso.Id).get(0).CC_MCC_ProdServ__c;
                // caso.CC_MCC_Motivo__c = mapaRecPretensiones.get(caso.Id).get(0).CC_MCC_Motivo__c;
                // caso.SEG_Detalle__c = mapaRecPretensiones.get(caso.Id).get(0).SEG_Detalle__c;

                // caso.SAC_Motivo_BDE__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_Motivo_BDE__c;
                // caso.SAC_FamiliaBdE__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_FamiliaBdE__c;
                // caso.SAC_ProductoBDE__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_ProductoBDE__c;
                // caso.SAC_DGS__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_DGS__c;
                // caso.SAC_Producto2BdE__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_Producto2BdE__c;
                // caso.SAC_MotivoReclamacion__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_MotivoReclamacion__c;
                // caso.SAC_AgrupacionesFamilias__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_AgrupacionesFamilias__c;
                // caso.SAC_ServicioInversion__c = mapaRecPretensiones.get(caso.Id).get(0).SAC_ServicioInversion__c;
                
                listaRecCambioPretPrincipal.add(caso);
            }
        }
        
    }

    /*****************************************************************
     * Proposito: Traer el DNI del reclamante a la reclamación cuando se informa un cliente
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   08/09/21     Creación
    *****************************************************************/
    public static void datosClienteReclamacion(List<Case> listNewCase, Map<Id, Case> mapOldCase) {
        String aux = '';
        List<Case> listaCasosConCuenta = new List<Case>();
        List<Id> listaIdsAccounts = new List<Id>();
        for (Case caso : listNewCase) {
            if (mapOldCase.containsKey(caso.Id) && caso.AccountId != mapOldCase.get(caso.Id).AccountId) {
                listaCasosConCuenta.add(caso);
                listaIdsAccounts.add(caso.AccountId);
            }
        }

        if (!listaCasosConCuenta.isEmpty()) {
            Map <Id, Account> mapaCuentas = new Map <Id, Account>([SELECT Id, CC_Numero_Documento__c FROM Account WHERE Id IN : listaIdsAccounts]);
            
            for (Case caso : listaCasosConCuenta) {
                if (String.isNotBlank(caso.AccountId) && mapaCuentas.containsKey(caso.AccountId)) {
                    caso.CC_SuppliedNIF__c = mapaCuentas.get(caso.AccountId).CC_Numero_Documento__c;
                } else if (String.isBlank(caso.AccountId)) {
                    caso.CC_SuppliedNIF__c = null;
                }
            }
        }
    }
    /*****************************************************************
     * Proposito: Rellenar el canal de procendencia de las pretensiones dada una reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Marcela Neira   21/09/21     Creación
     *                               Esteve Llao    21/09/21     Creación
    *****************************************************************/
    public static Map<Id,Case> rellenarProcedencia(List<Case> listaCasos /**Query */, List<Case> listaReclaPadreCanalProcedencia, map<Id,Case> mapaDatosCasosActualizar) { 
        Map<Id,List<Case>> mapaCasos = new Map<Id,List<Case>>();
        Map<Id,Case> mapaCasoPadre = new Map<Id,Case>(listaReclaPadreCanalProcedencia);
       
        for (Case caso : listaReclaPadreCanalProcedencia) {
            List<case> listaAux = new List<case> ();
            mapaCasos.put(caso.id, listaAux);
        }
        for (Case caso : listaCasos) {
            if(mapaCasos.containsKey(caso.SAC_Reclamacion__c)){ 
                List<case> listaAux = mapaCasos.get(caso.SAC_Reclamacion__c);
                Case casoAux = caso;
                casoAux.CC_Canal_Procedencia__c = mapaCasoPadre.get(caso.SAC_Reclamacion__c).CC_Canal_Procedencia__c;
                listaAux.add(casoAux);                
                mapaCasos.put(caso.SAC_Reclamacion__c, listaAux);
            }            
        }

        List<Case> listaCasosUpdatear = new List<Case>();
        for(Id key : mapaCasos.keySet()){ 
            listaCasosUpdatear.addAll(mapaCasos.get(key));            
        }
        
        for (Case caso : listaCasosUpdatear) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).CC_Canal_Procedencia__c = caso.CC_Canal_Procedencia__c;
            }else{
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        } 
        return mapaDatosCasosActualizar;
    }

    /*****************************************************************
     * Proposito: Rellenar campo SAC_CASE_esPSD2__c de la pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US317120       Daniel Benito   24/01/22       Creación
    *****************************************************************/

    public static void rellenarEsPSD2(List<Case> pretensiones){

        List<Id> idsMccs = new List<Id>();
        Map<Id, Id> pretensionMCC = new Map<Id, Id>();
        String idMcc;
        CC_MCC__c mcc;

        for(Case caso : pretensiones){

            if(String.isNotBlank(caso.SEG_Detalle__c)){

                idsMccs.add(caso.SEG_Detalle__c);
                pretensionMCC.put(caso.id, caso.SEG_Detalle__c);
            }
        }

        if(!idsMccs.isEmpty()){
  
            Map<Id, CC_MCC__c> clasifiPSD2 = new Map<Id, CC_MCC__c>([SELECT Id, SAC_EsPsd2__c FROM CC_MCC__c WHERE id IN: idsMccs]);

            for(Case caso : pretensiones){

                if(pretensionMCC.containsKey(caso.id)){
                
                    idMcc = pretensionMCC.get(caso.id);

                    if(clasifiPSD2.containsKey(idMcc)){

                        mcc = clasifiPSD2.get(idMcc);

                        caso.SAC_CASE_esPSD2__c = mcc.SAC_EsPsd2__c;
                    }
                }
            }
        }
    }
    
     /*****************************************************************
     * Proposito: Rellenar el campo SAC_Importe_ResultadoNegociacion__c de una pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US308674        Daniel Benito   02/02/22      Creación
    *****************************************************************/

    public static void rellenarImporteResultadoNegocio(List<Case> listaPretensionesImporte, Map<Id, Case> mapOldCase){

        for(Case caso : listaPretensionesImporte){

            if(mapOldCase.containsKey(caso.id) && mapOldCase.get(caso.id).Status == 'SAC_007' &&
            (caso.CC_Importe_Reclamado__c != mapOldCase.get(caso.Id).CC_Importe_Reclamado__c || caso.SAC_Importe_Resuelto__c != mapOldCase.get(caso.Id).SAC_Importe_Resuelto__c)){

                if(caso.CC_Importe_Reclamado__c != null && caso.SAC_Importe_Resuelto__c != null){

                    caso.SAC_Importe_ResultadoNegociacion__c = caso.CC_Importe_Reclamado__c - caso.SAC_Importe_Resuelto__c;

                }
            }
        }
    }


    /*****************************************************************
     * Proposito: Cuando se cambia el campo TAE en la pretensión principal, se 
     * debe cambiar en su reclamación padre
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US832968       Álex Polo      20/08/24      Creación
    *****************************************************************/
    public static void actualizarTAE(List<Case> listaPretensionesCambiaTAE, Map<Id, Case> mapaDatosCasosActualizar, List<Case> listaCasosSelect){
        
     
        List<Case> listaReclamaciones = new List<Case>();
        List<Id> listaReclamacionesId = new List<Id>();
        Map<Id, Case> mapaPretensiones = new Map<Id, Case>();
        Map<Id,Case> mapaReclamaciones = new Map<Id, Case>();

        Map<Id,Case> mapaCasos = new Map<Id, Case>();

        for(Case pretension : listaPretensionesCambiaTAE){
            mapaPretensiones.put(pretension.Id, pretension);            //Mapa de las pretensiones principales con TAE actualizado
            listaReclamacionesId.add(pretension.SAC_Reclamacion__C);    //Para cada pretension principal almaceno el ID de su reclamación padre
        }

        //Hago mapa de todos los casos
        for(Case caso: listaCasosSelect){
            mapaCasos.put(caso.Id, caso); 
        }

        //En un mapa obtengo y almaceno las reclamaciones padre
        if(!listaReclamacionesId.isEmpty()){
            for(Id id : listaReclamacionesId ){
                if(mapaCasos.containsKey(id)){
                    if(!mapaReclamaciones.containsKey(id))
                    mapaReclamaciones.put(id, mapaCasos.get(id));   //Aquí están las reclamaciones padre
                }
            }
        }
        
        //Se recorren las pretensiones, obteniendo para cada una su reclamación padre, actualizando su TAE y almacenandolas en el mapa de casos a actualizar
       if(!mapaReclamaciones.isEmpty()){
        for(Case pretension : listaPretensionesCambiaTAE){
            if(mapaReclamaciones.containsKey(pretension.SAC_Reclamacion__c)){  //Si se ha encontrado la reclamación padre de la pretensión, se actualizará su TAE
                Case reclamacion = new Case();
                reclamacion.Id =  mapaReclamaciones.get(pretension.SAC_Reclamacion__c).Id;
                if(!mapaDatosCasosActualizar.containsKey(reclamacion.Id)){
                    reclamacion.SAC_TAE__c = pretension.SAC_TAE__c;
                    mapaDatosCasosActualizar.put(reclamacion.Id, reclamacion);
                }else{
                    mapaDatosCasosActualizar.get(reclamacion.Id).SAC_TAE__c = pretension.SAC_TAE__c;
                }
            }
        }
       }
       
        
       


    }

    /*****************************************************************
     * Proposito: Comprobar que una pretensión en estado de negociación tiene los campos rellenos para volver al estado de análisis.
     * Modificación: Añadido que se compruebe cuando se pase a estado análisis, resolución o cerrado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR            DATE         Description
     * 1.0            US308674        Daniel Benito   02/03/2022      Creación
     * 1.1            US392178        Sergio Martín   18/07/2023      Modificación
    *****************************************************************/

    public static void comprobarNegocioAnalisis(List<Case> listaPretensionNegocioAnalisis, Map<Id, Case> mapOldCase){
        for(Case caso : listaPretensionNegocioAnalisis){

            if(mapOldCase.containsKey(caso.id) && caso.Status != mapOldCase.get(caso.Id).Status && (caso.Status == 'SAC_002' || caso.Status == 'SAC_003' || caso.Status == 'Cerrado') && mapOldCase.get(caso.Id).Status == 'SAC_007'){

                if(caso.SAC_ResultadoNegociacion__c == null){

                    caso.addError('No se puede actualizar la reclamación, el campo "Resultado de la negociación" de la pretensión debe ser informado');
                }

                if(caso.SAC_ResultadoNegociacion__c == 'Sin acuerdo' && caso.SAC_DetalleResultadoNegociacion__c == null){

                    caso.addError('No se puede actualizar la reclamación, el campo "Detalle resultado negociación" de la pretensión debe ser informado');
                }

                if(caso.CC_Importe_Reclamado__c == null || caso.CC_Importe_Reclamado__c == 0.00 ){

                    caso.addError('No se puede actualizar la reclamación, el campo "Importe reclamado" de la pretensión no está relleno');

                }else if(caso.SAC_Importe_Resuelto__c == null || caso.CC_Importe_Reclamado__c == 0.00){

                    caso.addError('No se puede actualizar la reclamación,  el campo "Importe resuelto" de la pretensión no está relleno');

                }else if(caso.SAC_Importe_ResultadoNegociacion__c == null){

                    caso.addError('No se puede actualizar la reclamación,  el campo "Importe resultado negocio" de la pretensión no está relleno');

                } 
            }
        }
    }

     /*****************************************************************
     * Proposito: Rellenar el campo Reclamante conforme para negociación de las pretensiones de una reclamación.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            Defect        Daniel Benito   14/03/2022      Creación
    *****************************************************************/

    public static void rellenarReclamanteConforme(List<Case> listNewCase){

        List<Id> listaIds = new List<Id>();

        for(Case caso : listNewCase){

            listaIds.add(caso.id);
        }

        List<Case> pretensiones = [SELECT id, SAC_ReclamanteConformeNegociacion__c FROM CASE WHERE SAC_Reclamacion__c IN: listaIds];

        if(!pretensiones.isEmpty()){

            for(Case pretension : pretensiones){

                pretension.SAC_ReclamanteConformeNegociacion__c = true;
            }
        }

        update pretensiones;

    }


    /*****************************************************************
     * Proposito: Rellenar el campo CC_Codigo_Externo_Tematica__c de las pretensiones cuando se le asignan un MCC.
     * Modificación: Rellena los campos del caso con los codigos externos de los mccs para poder utilizarlos como
     * 'suggested Knowledge'. Tambíen rellena los campos con los nombres.
     * Utilizamos el campo CC_Codigo_Externo_Causa__c poara almacenar el código del mcc SEG_Detalle__c
     * Modificacion 1.2: Añadido campos nuevos MCC 
     * Modificacion 1.3: Añadidos campos entidad productora y afectada a al pretension 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            Defect        Daniel Benito   04/04/2022      Creación
     * 1.1            --            Carlos Solis    09/06/2022      Modificación
     * 1.2            US421835      Raúl y Sergio   27/09/2022      Modificación
     * 1.3            US421835      Sergio          20/10/2022      Modificación
    *****************************************************************/
    public static void rellenarCodigosExternosMCC(List<Case> listNewCase, List<Id> listaPretTematicaMCC){
        
        Map<Id, CC_MCC__c> mapaMCC = new Map<Id, CC_MCC__c>([SELECT id, Name, CC_Codigo_Externo__c, CC_Motivo__r.CC_Codigo_Externo__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Codigo_Externo__c,
                                                                CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name,
                                                                CC_Motivo__r.CC_Producto_Servicio__r.Name, CC_Motivo__r.Name, SAC_FamiliaBdE__c, SAC_ProductoBDE__c, SAC_DGS__c, SAC_Producto2BdE__c,
                                                                SAC_MotivoReclamacion__c, SAC_AgrupacionesFamilias__c, SAC_ServicioInversion__c, SAC_Motivo_BDE__c, SAC_EntidadProductora__c, SAC_EntidadAfectada__c,
                                                                SAC_FamiliaMotivoBdE__c
                                                                FROM CC_MCC__c WHERE RecordTypeId = :recTypeMCCDetalle
                                                                AND id IN: listaPretTematicaMCC]);

        for(Case caso : listNewCase){
            if(mapaMCC.containsKey(caso.SEG_Detalle__c)){
                //Campos de códigos a rellenar
                caso.CC_Codigo_Externo_Tematica__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Codigo_Externo__c;
                caso.CC_Codigo_Externo_Producto__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.CC_Codigo_Externo__c;
                caso.CC_Codigo_Externo_Motivo__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Motivo__r.CC_Codigo_Externo__c;
                caso.CC_Codigo_Externo_Causa__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Codigo_Externo__c;
                //Campos internos con el nombre
                caso.CC_Tematica__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name;
                caso.CC_Producto_Servicio__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Motivo__r.CC_Producto_Servicio__r.Name;
                caso.CC_Motivo__c = mapaMCC.get(caso.SEG_Detalle__c).CC_Motivo__r.Name;
                caso.CC_Causa__c = mapaMCC.get(caso.SEG_Detalle__c).Name;

                caso.SAC_Motivo_BDE__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_Motivo_BDE__c;
                caso.SAC_FamiliaBdE__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_FamiliaBdE__c;
                caso.SAC_ProductoBDE__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_ProductoBDE__c;
                caso.SAC_FamiliaMotivoBdE__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_FamiliaMotivoBdE__c;
                caso.SAC_DGS__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_DGS__c;
                caso.SAC_Producto2BdE__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_Producto2BdE__c;
                caso.SAC_MotivoReclamacion__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_MotivoReclamacion__c;
                caso.SAC_AgrupacionesFamilias__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_AgrupacionesFamilias__c;
                caso.SAC_ServicioInversion__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_ServicioInversion__c;
                if(caso.RecordTypeID == recTypePretension) {
                    caso.SAC_Entidad_Afectada__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_EntidadAfectada__c; 
                    caso.SAC_EntidadProductora__c = mapaMCC.get(caso.SEG_Detalle__c).SAC_EntidadProductora__c;
            	}
            }
        }
    }

     /*****************************************************************
     * Proposito: Calcular cuantas pretensiones activas hay en la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200293      Marcela Neira   12/05/2022      Creación
    *****************************************************************/
    public static void calcularPretensionesActivas(List<Case> listNewCase, List<Case> listaQuery, Map<Id,Case> mapaDatosCasosActualizar) {

        Map<Id,List<Case>> mapaPretensiones = new Map<Id,List<Case>>();
        List<Case> listaReclamaciones = new List<Case>();

        for(Case caso: listNewCase){
            mapaPretensiones.put(caso.SAC_Reclamacion__c, new List<Case>());
        }

        for(Case caso: listaQuery){ //filtro la 
            if(mapaPretensiones.containsKey(caso.SAC_Reclamacion__c)){
                List<Case> listaAux = mapaPretensiones.get(caso.SAC_Reclamacion__c);
                listaAux.add(caso);
                mapaPretensiones.put(caso.SAC_Reclamacion__c, listaAux);
            }
        }

        for(Id ide : mapaPretensiones.keySet()){ 
            Integer numPretensiones = 0;
            
            for(Case pretension: mapaPretensiones.get(ide)){
                if(pretension.Status != 'SAC_009'){
                    numPretensiones++;
                }
            }

            if(numPretensiones!=0){
                listaReclamaciones.add(new Case(Id= ide, SAC_NPretensionesActivas__c = numPretensiones));
            }                        
        }
        
        for (Case caso : listaReclamaciones) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).SAC_NPretensionesActivas__c = caso.SAC_NPretensionesActivas__c;
            }else{
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        }

    }


    /*****************************************************************
    * Proposito: Insertar permisos al crear una pretensión
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            Defect         Daniel Benito  30/05/2022      Creación
    *****************************************************************/

    public static void insertarPermisosPretension(List<Case> listNewCase){

        List<Id> idsReclamacion = new List<Id>();
        Map<Id, String> reclaIdOwner = new Map<Id, String>();
        List<CaseShare> permisos = new List<CaseShare>();

        for(Case pretension : listNewCase){

            idsReclamacion.add(pretension.SAC_Reclamacion__c);
        }

        List<Case> reclamaciones = [SELECT id, OwnerId FROM CASE WHERE id IN: idsReclamacion];
        
        if(!reclamaciones.isEmpty()){
            
            for(Case reclamacion : reclamaciones){
    
                reclaIdOwner.put(reclamacion.Id, reclamacion.OwnerId);
            }
    
            for(Case pretension : listNewCase){
    
                CaseShare csNuevo = new CaseShare();
                csNuevo.CaseId = pretension.Id;
                csNuevo.UserOrGroupId = reclaIdOwner.get(pretension.SAC_Reclamacion__c);
                csNuevo.CaseAccessLevel='Edit';
                permisos.add(csNuevo);
            }
    
            Database.insert(permisos, false);
        }
    }  

    /* Este método pone el valor del campo caso especial de la reclamación en la pretensión y se llama cuando se updatea la reclamación */
    public static void casoEspecialPretensiones(List<Case> listNewCaseEspecial, List<Case> listaSelect, Map<Id, Case> mapaDatosCasosActualizar) {
        Map<Id, Case> mapaSelect = new Map<Id,Case>(listaSelect);
        Map<Id, Case> mapaNewCaseEspecial = new Map<Id,Case>(listNewCaseEspecial);

        for (Case caso : listaSelect) {
            if (mapaNewCaseEspecial.containsKey(caso.SAC_Reclamacion__c)) {
                if (mapaDatosCasosActualizar.containsKey(caso.Id)) {
                    mapaDatosCasosActualizar.get(caso.Id).SAC_CasoEspecial__c = mapaNewCaseEspecial.get(caso.SAC_Reclamacion__c).SAC_CasoEspecial__c;
                } else {
                    Case casoActualizar = new Case();
                    casoActualizar.Id = caso.Id;
                    casoActualizar.SAC_CasoEspecial__c = mapaNewCaseEspecial.get(caso.SAC_Reclamacion__c).SAC_CasoEspecial__c;
                    mapaDatosCasosActualizar.put(casoActualizar.Id, casoActualizar);
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Se llama en el trigger case_AU. Cuando cambia el owner de la pretensión,
     * actualiza el campo letrado de su reclamación padre
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US424963         Carlos Solis   18/08/2022   Creación
    *****************************************************************/
    public static void cambioLetrado(List<Case> listNewPretensiones, Map<Id, Case> mapaDatosCasosActualizar, Group cola) {
        Map<Id, Id> mapaRecclamacionLetrado = new Map<Id, Id>();
        Set<Id> setIdsOwnersPret = new Set<Id>();
        //Recorrer pretensiones a las que les ha cambiado el owner
        for (Case pretension : listNewPretensiones) {
            //Almacenar ids de owners en un set para posteriormente buscar sus nombres
            setIdsOwnersPret.add(pretension.OwnerId);
            //Almacenar en un mapa la id del letrado que tendrá la reclamación padre
            mapaRecclamacionLetrado.put(pretension.SAC_Reclamacion__c, pretension.OwnerId);
        }

        if (!setIdsOwnersPret.isEmpty()) {
            //Buscar los nombres de los usuarios
            Map<Id, User> mapaUsers = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :setIdsOwnersPret]);

            for (Id idRec : mapaRecclamacionLetrado.keySet()) {
                //Si el owner es un usuario, debe estar en el mapa de Users
                if (mapaUsers.containsKey(mapaRecclamacionLetrado.get(idRec))) {
                    if (mapaDatosCasosActualizar.containsKey(idRec)) {
                        mapaDatosCasosActualizar.get(idRec).SAC_Letrado__c = mapaUsers.get(mapaRecclamacionLetrado.get(idRec)).Name;
                    } else {
                        Case reclamacionActualizar = new Case();
                        reclamacionActualizar.Id = idRec;
                        reclamacionActualizar.SAC_Letrado__c = mapaUsers.get(mapaRecclamacionLetrado.get(idRec)).Name;
                        mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
                    }
                //Si el owner es la cola, no es un User si no un Group
                } else if (mapaRecclamacionLetrado.get(idRec) == cola.Id) {
                    if (mapaDatosCasosActualizar.containsKey(idRec)) {
                        mapaDatosCasosActualizar.get(idRec).SAC_Letrado__c = 'Pte. Asignar';
                    } else {
                        Case reclamacionActualizar = new Case();
                        reclamacionActualizar.Id = idRec;
                        reclamacionActualizar.SAC_Letrado__c = 'Pte. Asignar';
                        mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
                    }
                //Si no es ni usuario ni la cola pendiente asignar, es la cola Pte. Supervisor
                } else {
                    if (mapaDatosCasosActualizar.containsKey(idRec)) {
                        mapaDatosCasosActualizar.get(idRec).SAC_Letrado__c = 'Pte. Supervisor';
                    } else {
                        Case reclamacionActualizar = new Case();
                        reclamacionActualizar.Id = idRec;
                        reclamacionActualizar.SAC_Letrado__c = 'Pte. Supervisor';
                        mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
                    }
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Se llama en el trigger case_AI. Cuando se inserta una pretensión,
     * comprueba que la reclamacion padre no tenga el campo SAC_Letrado__c informado.
     * Si no lo tiene informado, significa que es la primera pretensión que entra y por lo tanto
     * debe tener de letrado todavia al owner de la reclamación. Por lo tanto, se pone en el campo
     * SAC_Letrado__c de la reclamación el name de el owner de la misma reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US424963         Carlos Solis   24/08/2022   Creación
    *****************************************************************/
    public static void informarLetrado(List<Case> listNewPretensiones, List<Case> listaSelect, Map<Id, Case> mapaDatosCasosActualizar) {
        Map<Id, Case> mapaSelect = new Map<Id, Case>(listaSelect);
        for (Case pret : listNewPretensiones) {
            if (mapaSelect.containsKey(pret.SAC_Reclamacion__c) && String.isBlank(mapaSelect.get(pret.SAC_Reclamacion__c).SAC_Letrado__c)) {
                if (mapaDatosCasosActualizar.containsKey(pret.SAC_Reclamacion__c)) {
                    mapaDatosCasosActualizar.get(pret.SAC_Reclamacion__c).SAC_Letrado__c = mapaSelect.get(pret.SAC_Reclamacion__c).Owner.Name;
                } else {
                    Case reclamacionActualizar = new Case();
                    reclamacionActualizar.Id = pret.SAC_Reclamacion__c;
                    reclamacionActualizar.SAC_Letrado__c = mapaSelect.get(pret.SAC_Reclamacion__c).Owner.Name;
                    mapaDatosCasosActualizar.put(reclamacionActualizar.Id, reclamacionActualizar);
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Cambiar el owner de las pretensiones hermanas cuando cambia el owner de una de ellas (pone el mismo owner en todas).
     * Cambia solamente si el cambio no se esta produciendo en todas las pretensiones. Si hay alguna pretension de la familia
     * que no está viniendo en el trigger new, es entonces cuando updatea solamente esta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             24/08/2022   Creación
    *****************************************************************/
    /*public static void cambiarOwnersPretsHermanas(List<Case> listTNewCase, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar) {
        Map<Id, Map<Id, Case>> mapaReclaPret = new Map<Id, Map<Id, Case>>();
        //Montar mapa con las pretensiones modificadas por cada reclamación (las que vienen del trigger new)
        for (Case caso : listTNewCase) {
            if (caso.RecordTypeId == recTypePretension) {
                if (mapaReclaPret.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaReclaPret.get(caso.SAC_Reclamacion__c).put(caso.Id, caso);
                } else {
                    Map<Id, Case> mapaPret = new Map<Id, Case>();
                    mapaPret.put(caso.Id, caso);
                    mapaReclaPret.put(caso.SAC_Reclamacion__c, mapaPret);
                }
            }
        }

        //Montar mapa con las pretensiones por cada reclamación (las que vienen del select del case_au)
        Map<Id, List<Case>> mapaReclaPretSelect = new Map<Id, List<Case>>();
        for (Case caso : listaCasosSelect) {
            if (caso.RecordTypeId == recTypePretension) {
                if (mapaReclaPretSelect.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaReclaPretSelect.get(caso.SAC_Reclamacion__c).add(caso);
                } else {
                    List<Case> listaPret = new List<Case>();
                    listaPret.add(caso);
                    mapaReclaPretSelect.put(caso.SAC_Reclamacion__c, listaPret);
                }
            }
        }

        
        Comprobar si alguna pretensión de cada familia de reclamaciones no está en el trigger new.
        Si no lo está, comprobar que el owner es el mismo.
        Si no es el mismo owner, lo updatea.
        
        for (String idRecla : mapaReclaPretSelect.keySet()) {
            for (Case pretensionSelect : mapaReclaPretSelect.get(idRecla)) {
                if (mapaReclaPret.containsKey(idRecla) && !mapaReclaPret.get(idRecla).containsKey(pretensionSelect.Id)) {
                    for (Case pretNew : mapaReclaPret.get(idRecla).values()) {
                        if (pretNew.OwnerId != pretensionSelect.OwnerId) {
                            //Actualizar pretension del select que no se esta actualizando
                            if (mapaDatosCasosActualizar.containsKey(pretensionSelect.Id)) {
                                mapaDatosCasosActualizar.get(pretensionSelect.Id).OwnerId = pretNew.OwnerId;
                                break;
                            } else {
                                Case pretUpdatear = new Case();
                                pretUpdatear.Id = pretensionSelect.Id;
                                pretUpdatear.OwnerId = pretNew.OwnerId;
                                mapaDatosCasosActualizar.put(pretUpdatear.Id, pretUpdatear);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }*/
}