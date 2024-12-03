/*****************************************************************
 * Name: SAC_Validaciones
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para las reglas de validación
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US242669         Carlos Solis   28/06/21     Creación
 * 1.1            US248481         Luis Mesa      14/07/21     Adición metodo validarListoParaEnviar
*****************************************************************/
public without sharing class SAC_Validaciones {
    /*****************************************************************
     * Proposito: Comprueba que el MCC esté informado si la pretensión pasa de estado alta a análisis. No se tienen 
     * en cuenta las pretensiones en estado baja.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US242669         Carlos Solis   28/06/21     Creación
    *****************************************************************/
    public static void validarMCC(List<Case> listNewCase, Map<Id, Case> mapOldCase, List<Case> listaPretensionesHijas, List<case> listaReclaAnalisis){
       
        Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();
        //Rellenar mapa con reclamacion y su lista de pretensiones
        for (Case pret : listaPretensionesHijas) {
            if (mapaRecPretensiones.containsKey(pret.SAC_Reclamacion__c)) {
                mapaRecPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
            } else {
                List<Case> lista = new List<Case>();
                lista.add(pret);
                mapaRecPretensiones.put(pret.SAC_Reclamacion__c, lista);
            }
        }
        Map<Id, Boolean> mapaReclamacionNoValida = new Map<Id, Boolean>();
        for (Case caso : listaReclaAnalisis) {
            if (mapaRecPretensiones.containsKey(caso.Id)) {
                for (Case pret : mapaRecPretensiones.get(caso.Id)) {
                    if (pret.Status != 'SAC_009' && pret.SEG_Detalle__c == null) {
                        mapaReclamacionNoValida.put(caso.Id, true);
                    }
                }
            }
        }
        for (Case caso : listNewCase) {
            if (mapaReclamacionNoValida.containsKey(caso.Id) && mapaReclamacionNoValida.get(caso.Id)) {
                caso.addError('No se puede pasar a análisis si alguna de las pretensiones no tiene el MCC informado');
            }
        }
        
    }

    /*****************************************************************
     * Proposito: En caso de que la reclamación sea multipretensión, comprueba que haya una pretensión principal asignada.
     * En caso de que no la haya, lanza un error de validación.
     * Modificación 1.1: Cambiado nombre lista listaPretensionesHijas a ListaCasoSelect y añadido nueva lista listaPretensionesHijas 
     * para solucionar el problema de casos duplicados
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US242669         Carlos Solis   28/06/21     Creación
     * 1.1            US477095         Sergio Martín  27/10/22     Modificación
    *****************************************************************/
    public static void validarPretensionPrincipal(List<Case> listNewCase, Map<Id, Case> mapOldCase, List<Case> ListaCasoSelect, List<Id> listaIdsRec){

        List<Case> listaPretensionesHijas = new List<Case>();
        Map<Id,List<Case>> mapaCasos = new  Map<Id,List<Case>>();    

        for (Case caso : ListaCasoSelect) {
            if (mapaCasos.containsKey(caso.SAC_Reclamacion__c)) {
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
            if (mapaRecPretensiones.containsKey(caso.Id) && mapaRecPretensiones.get(caso.Id).size() > 1 && String.isBlank(String.valueOf(caso.SAC_PretensionPrincipal__c))) {
                caso.addError('No se puede pasar a Análisis sin que haya una pretensión principal informada');
            }
        }
    
    }

    /*****************************************************************
     * Proposito: Validaciones a la hora de checar el campo SAC__RedaccionFinal.
     *      1. Se comprueba que la redacción no tenga contenido.
     *      2. Se valida si el campo sentido resolución está vacío.
     *      3. Validaciones sobre el campo No Aplica Tareas y la pretensión no tiene tareas.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
      * 1.0            US248481         Luis Mesa     14/07/21     Creación Método
    *****************************************************************/
    public static void validarListoParaEnviar(List<Case> pretensiones, Map<Id, Case> mapOld){
        //Comprobar que han puesto el tick en el campo SAC_RedaccionFinal
        List<Case> misPretensiones = new List<Case>();
        for(Case pretension : pretensiones){
            if(pretension.SAC_RedaccionFinal__c){
                misPretensiones.add(pretension);            
            }
        }
        //Comprobar para cada una de las pretensiones que cumple las validaciones establecidas
        List<SAC_Accion__c> acciones = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Pretension__c IN: misPretensiones];

        Map<Id, List<SAC_Accion__c>> mapPretAcciones = new Map<Id, List<SAC_Accion__c>>();
        for(SAC_Accion__c accion : acciones){
            List<SAC_Accion__c> accionesPret = new List<SAC_Accion__c>();
            if(!mapPretAcciones.containsKey(accion.SAC_Pretension__c)){
                accionesPret.add(accion);
                mapPretAcciones.put(accion.SAC_Pretension__c, accionesPret);
            }
            else{
                accionesPret = mapPretAcciones.get(accion.SAC_Pretension__c);
                accionesPret.add(accion);
                mapPretAcciones.put(accion.SAC_Pretension__c, accionesPret);
            }
        }

        List<Case> pretAct = new List<Case>();
        for(Case pretension : misPretensiones){
             if(String.isBlank(pretension.SAC_SentidoResolucion__c)){
                pretension.addError('El campo sentido resolución está vacío.');
            }
        }
    }

    public static void validarCheckTareas(List<Case> pretensiones, Map<Id, Case> mapOld){
    /*****************************************************************
     * Proposito: Validaciones a la hora de ticar el campo SAC_NoAplicaTareas.
     *      1. Se comprueba que la pretension no tenga tareas, si las tiene addError.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
      * 1.0            US248481         Luis Mesa     15/07/21     Creación Método
    *****************************************************************/
        List<Case> pretensionesModificadas = new List<Case>();
        
        for(Case pretension : pretensiones){
            if(mapOld.containsKey(pretension.Id)){
                if(mapOld.get(pretension.Id).SAC_NoAplicaTareas__c != pretension.SAC_NoAplicaTareas__c){
                    pretensionesModificadas.add(pretension);
                }
            }
        }

        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Pretension__c IN: pretensionesModificadas];

        Map<Id, List<SAC_Accion__c>> mapPretTarea = new Map<Id, List<SAC_Accion__c>>();

        if(tareas.size() > 0){

            for(SAC_Accion__c tarea : tareas){
                List<SAC_Accion__c> misAcciones = new List<SAC_Accion__c>();
                if(mapPretTarea.containsKey(tarea.SAC_Pretension__c)){
                    misAcciones = mapPretTarea.get(tarea.SAC_Pretension__c);
                    misAcciones.add(tarea);
                    mapPretTarea.put(tarea.SAC_Pretension__c, misAcciones);
                }
                else{
                    misAcciones.add(tarea);
                    mapPretTarea.put(tarea.SAC_Pretension__c, misAcciones);
                }
            }
        }
        
        for(Case pretensionFinal : pretensionesModificadas){
            if(mapPretTarea.containsKey(pretensionFinal.Id) && pretensionFinal.SAC_NoAplicaTareas__c){
                pretensionFinal.addError('No puedes marcar el campo "No aplica tareas" teniendo tareas asociadas.');
            }
            else if(!mapPretTarea.containsKey(pretensionFinal.Id) && !pretensionFinal.SAC_NoAplicaTareas__c){
                pretensionFinal.addError('No puedes desmarcar el campo "No aplica tareas" sin tener tareas asociadas.');
            }
        }        
    }

    /*****************************************************************
     * Proposito: Valida que no se pueda hacer cambio del campo "Sentido de resolución"
     * en una reclamación si sus pretensiones hijas no tienen valor en dicho campo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US254536      Nicolás García   25/08/2021    Creación Método
    *****************************************************************/

    public static void validarSentidoResolucion(List<Case> listaCasos, List<Case> reclamacionesVSentidoResolucion){ 

        List<Case> listaPretensionesHijas = new List<Case>();

        Map<Id,Case> mapaCasos = new Map<Id,Case>();                       
        for (Case caso : listaCasos) {
            mapaCasos.put(caso.SAC_Reclamacion__c, caso);
        }
        for(Case caso: reclamacionesVSentidoResolucion){                              
            if (mapaCasos.containsKey(caso.id)) {
                listaPretensionesHijas.add(mapaCasos.get(caso.id));
            }
        }       

        Map<Id, List<Case>> mapaReclamacionPretensiones = new Map<Id, List<Case>>();
        for(Case pretension : listaPretensionesHijas){
            if(mapaReclamacionPretensiones.containsKey(pretension.SAC_Reclamacion__c)){
                mapaReclamacionPretensiones.get(pretension.SAC_Reclamacion__c).add(pretension);
            }
            else{
                List<Case> listaAux = new List<Case>();
                listaAux.add(pretension);
                mapaReclamacionPretensiones.put(pretension.SAC_Reclamacion__c, listaAux);
            }
        }         

        for(Case reclamacion : reclamacionesVSentidoResolucion){
            if(mapaReclamacionPretensiones.containsKey(reclamacion.Id)){
                List<Case> listaPretensiones = mapaReclamacionPretensiones.get(reclamacion.Id);
                if(listaPretensiones.isEmpty()){
                    reclamacion.addError('No se puede cambiar el sentido de resolución porque las pretensiones hijas no tienen valor en este campo.');
                }
                else{
                    Boolean error = false;
                    for(Case pretension : listaPretensiones){
                        if(String.isBlank(pretension.SAC_SentidoResolucion__c)){
                            error = true;
                        }
                    }
                    if(error){
                        reclamacion.addError('No se puede cambiar el sentido de resolución porque las pretensiones hijas no tienen valor en este campo.'); 
                    }
                }
            }
            else{
                reclamacion.addError('No se puede cambiar el sentido de resolución porque las pretensiones hijas no tienen valor en este campo.');
            }
        }
    }

    /**************************************************************************
     * Proposito: Valida si se puede cambiar el campo SAC_CasoEspecial__c en la reclamación
     * Dependiendo del valor del campo y del Status de la reclamación, podrá o no ser cambiado.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US201485         Carlos Solis   24/02/2022   Creación
    **************************************************************************/
    public static void validarCasoEspecial(List<Case> listNewCase, Map<Id, Case> mapOldCase) {
        for (Case reclamacion : listNewCase) {
            //Si el valor del caso especial ha cambiado y...
            if (mapOldCase.containsKey(reclamacion.Id) && mapOldCase.get(reclamacion.Id).SAC_CasoEspecial__c != reclamacion.SAC_CasoEspecial__c) {
                //Si el valor de caso especial es presidencia y la reclamacion está en un estado distinto a alta, no se puede cambiar
                if (reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia' && reclamacion.Status != 'SAC_001') {
                    reclamacion.addError('No se puede cambiar el valor de caso especial a presidencia después de la fase de alta.');
                }
            }
        }
    }

    /**************************************************************************
    * Proposito: Valida que no se pueda cambiar una reclamación ha estado "Rechazado"
    * si esta no está en Alta o Análisis o si no tiene motivo de rechazo informado.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US337252        Daniel Benito   01/03/2022   Creación
    **************************************************************************/

    public static void validarAltaAnalisisRechazar(List<Case> listNewCase, Map<Id, Case> mapOldCase) {
        for (Case reclamacion : listNewCase) {
            if(isRechazarQuickAction(reclamacion) == true){
                reclamacion.SAC_MotivoRechazo__c = 'Otros';
            }
            if(mapOldCase.containsKey(reclamacion.Id) && reclamacion.SAC_MotivoRechazo__c == null){

                reclamacion.addError('No se puede rechazar un caso sin indicar el motivo.');
            }
            //Si el valor del caso especial ha cambiado y...
            if (mapOldCase.containsKey(reclamacion.Id) && mapOldCase.get(reclamacion.Id).Status != reclamacion.Status) {
                //Si el valor de caso especial es presidencia y la reclamacion está en un estado distinto a alta, no se puede cambiar
                if (reclamacion.Status == 'Rechazado' &&  (mapOldCase.get(reclamacion.Id).Status != 'SAC_001' && mapOldCase.get(reclamacion.Id).Status != 'SAC_002')) {

                    reclamacion.addError('No se puede rechazar un caso si no está en estado de Alta o Análisis.');
                }
            }
        }
    }
    /**************************************************************************
    * Proposito: Valida que si viene vacio el campo SAC_MotivoRechazo__c y porine de la quickAction es Case.CC_Rechazar_Caso
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            DE71399        Jesús Costa   31/01/2023   Creación or update
    **************************************************************************/
    //AÑADIR UN METODO QUE VALIDE SI ES UNA QUICK ACTION Y SI ES LA QUICK ACTION, NUESTRA
    private static boolean isRechazarQuickAction (Case caso){
        if( String.valueOf(Request.getCurrent().getQuiddity()) == 'QUICK_ACTION'){
            if(caso.getQuickActionName() == 'Case.CC_Rechazar_Caso' &&  String.isblank(caso.SAC_MotivoRechazo__c)){
                return true;
            }
            return false;
        }
        return false;
    }
    /**************************************************************************
    * Proposito: Valida que cuando rechazemos un caso con motivo 'Otros' 
    *  se informe un comentario.
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            Defect        Daniel Benito   11/05/2022   Creación
    **************************************************************************/

    public static void validarComentarioRechazo(List<Case> listNewCase, Map<Id, Case> mapOldCase) {
        for (Case reclamacion : listNewCase) {
            if(mapOldCase.containsKey(reclamacion.Id) && reclamacion.Comments == null && reclamacion.CC_Rechazar_Reabrir_Caso__c){

                reclamacion.addError('Es necesario informar un comentario.');
            }
        }
    }


    /*****************************************************************
     * Proposito: Validar que si las pretensiones tienen MCC de tipo GGH
     * El sistema, antes de pasar a la fase de análisis tiene que validar 
     * que al menos uno los importes reclamados esté informado.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US342617      Marcela Neira   02/03/22     Creación
    *****************************************************************/
    public static void validarImportesReclamados(List<Case> listNewCase, List<Case> listaCasos, List<case> listaReclaAnalisis){
       
        Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();
        //Rellenar mapa con reclamacion y su lista de pretensiones

        for (Case reclamacion : listaReclaAnalisis) {
            mapaRecPretensiones.put(reclamacion.id, New List<Case>());
        }

        for (Case pret : listaCasos) {
            if (mapaRecPretensiones.containsKey(pret.SAC_Reclamacion__c) && (pret.Status !='SAC_009')) {
                mapaRecPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
            } 
        }
        Map<Id, String> mapaReclamacionNoValida = new Map<Id, String>();
        for (Case caso : listaReclaAnalisis) {
            if (mapaRecPretensiones.containsKey(caso.Id)) {
                for (Case pret : mapaRecPretensiones.get(caso.Id)) {
                    if ( pret.SEG_Detalle__r.SAC_esGGH__c && (pret.SAC_ImpReclamadoGestoria__c == null  && pret.SAC_ImpReclamadoInteresesLegales__c == null  
                    && pret.SAC_ImpReclamadoNotaria__c == null  && pret.SAC_ImpReclamadoRegistros__c == null  && pret.SAC_ImpReclamadoTasacion__c == null ) ){
                        mapaReclamacionNoValida.put(caso.Id, pret.CaseNumber + ', ');
                    }
                }
            }
        }
        for (Case caso : listNewCase) {
            if (mapaReclamacionNoValida.containsKey(caso.Id)) {
                caso.addError('No se puede pasar a Análisis, las siguientes pretensiones ' + mapaReclamacionNoValida.get(caso.Id) +  ' no tienen los importes reclamados informados ' );
            }
        }
        
    }

    /*****************************************************************
     * Proposito: Validar que la reclamación tenga un accountId antes de pasar a analisis
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US344788         Luis Mesa      08/03/22     Creación
    *****************************************************************/
    public static void validarCuentaInformada(List<Case> listaReclaAnalisis){
        for(Case reclamacion : listaReclaAnalisis){
            if(String.isBlank(reclamacion.AccountId) && !reclamacion.CC_No_Identificado__c){
                reclamacion.addError('No se puede pasar a Análisis sin tener un cliente informado.' );
            }
        }
    }

    /*****************************************************************
     * Proposito: En caso que la PRETENSION tenga el campo ENTIDAD=VCx estos campos deberán estar informados obligatoriamente antes de pasar a análisis
     *     Motivo VCX:
     *     Negocio 
     *     Tipo de contingencia/prestación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US344679       Marcela Neira   10/03/22     Creación
    *****************************************************************/
    /*public static void validarCamposEntidad(List<Case> listNewCase, List<Case> listaCasos, List<case> listaReclaAnalisis){

        Map<Id,List<Case>> mapaPretensiones = New Map<Id,List<Case>>();

        for (Case reclamacion : listaReclaAnalisis) {
            mapaPretensiones.put(reclamacion.id, new List<Case>());
        }

        for(Case pretension : listaCasos){
            if(mapaPretensiones.containsKey(pretension.SAC_Reclamacion__c) && (pretension.Status !='SAC_009')){
                mapaPretensiones.get(pretension.SAC_Reclamacion__c).add(pretension);
            }
        }  

        Map<Id, String> mapaReclamacionNoValida = new Map<Id, String>();
        for (Case caso : listaReclaAnalisis) {
            if (mapaPretensiones.containsKey(caso.Id)) {
                for (Case pret : mapaPretensiones.get(caso.Id)) {
                    if ( pret.SAC_Entidad_Afectada__c == 'Vidacaixa, S.A. de Seguros y Reaseguros' && (pret.SAC_MotivoVXC__c == null  && pret.SAC_Negocio__c== null  
                    && pret.SAC_TipoContingenciaPrestacion__c == null ) ){
                        mapaReclamacionNoValida.put(caso.Id, pret.CaseNumber + ', ');
                    }
                }
            }
        }
        for (Case caso : listNewCase) {
            if (mapaReclamacionNoValida.containsKey(caso.Id)) {
                caso.addError('No se pueden cambiar de estado, las siguientes pretensiones ' + mapaReclamacionNoValida.get(caso.Id) +  ' no tienen los campos Motivo VCX, Negocio y Tipo contingencia/prestacion informados. ' );
            }
        }       
    }*/

    /*****************************************************************
     * Proposito: En caso que la PRETENSION tenga el campo ENTIDAD=VCx estos campos deberán estar informados obligatoriamente antes de pasar de análisis a otro estado
     *     Motivo VCX:
     *     Negocio 
     *     Tipo de contingencia/prestación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   24/05/22     Creación
    *****************************************************************/
    public static void validarCamposEntidadPret(List<Case> listNewCase) {
        for (Case caso : listNewCase) {
            if (caso.SAC_Entidad_Afectada__c == 'SAC_007' && (String.isBlank(caso.SAC_MotivoVXC__c) || String.isBlank(caso.SAC_Negocio__c) || String.isBlank(caso.SAC_TipoContingenciaPrestacion__c))) {
                caso.addError('No se puede cambiar de estado una pretensión de "Vidacaixa, S.A. de Seguros y Reaseguros" si no tienen los campos Motivo VCX, Negocio y Tipo contingencia/prestacion informados. ');
            }
        }
    }

     /*****************************************************************
     * Proposito: Si rechazamos una reclamación con el motivo de 'Rechazada por vinculación' y la reclamación no tiene 
     * reclamaciones vinculadas, salta esta validación y no te deja rechazarlo.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            Defect       Daniel Benito    08/04/22        Creación
    *****************************************************************/

    public static void comprobarReclamacionesVinculadas(List<Case> newCases){
        
        for(Case caso : newCases){

            if(caso.CC_CasoRelacionado__c == null){

                caso.addError('No puede seleccionar este motivo, la reclamación ' + caso.CaseNumber + ' no cuenta con reclamaciones vinculadas.');
            }
        }
    }

    /*****************************************************************
     * Proposito: Si rechazamos una reclamación con el motivo de 'Alta errónea' y la reclamación tiene
     * pretensiones no nos deberia dejar rechazar por este motivo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US354284      Marcela Neira   09/05/22        Creación
    *****************************************************************/

    public static void comprobarReclamAltaErronea(List<Case> listaRechazoAltaErronea, List<Case>  listaCasos){
        
        Map<Id,List<Case>> mapaPretensiones = New Map<Id,List<Case>>();

        for (Case reclamacion : listaRechazoAltaErronea) {
            mapaPretensiones.put(reclamacion.id, new List<Case>());
        }

        for(Case pretension : listaCasos){
            if(mapaPretensiones.containsKey(pretension.SAC_Reclamacion__c) && (pretension.Status !='SAC_009')){
                mapaPretensiones.get(pretension.SAC_Reclamacion__c).add(pretension);
            }
        }
        
        for (Case reclamacion : listaRechazoAltaErronea) {
            if(mapaPretensiones.containsKey(reclamacion.id) && !mapaPretensiones.get(reclamacion.id).isEmpty()){               
                reclamacion.addError('No puede rechazar la Reclamación si tiene pretensiones.');
            }
        }
    }

    
   /**************************************************************************
     * Proposito: 
     * Valida si puede avanzar en la fase dos y tres de la redaccion
     * Valida si se puede enviar las tareas usado al finalizar la redacción(que automatiza el envío)
     * Valida si se puede enviar la tarea de manera individual
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         	DATE         Description
     * 1.0            US356803         Alexandre Pérez  06/10/2022   Creación
    **************************************************************************/
    public static string validarEscaladoEnvioTarea(List<SAC_Accion__c> tareas, Id casoId, String tipo) {
        
        decimal sumatorio = 0.0;
        decimal sumatorioAbonado = 0.0;
        set<Id> pretensionesId = new set<Id>();
        boolean comprobarEscalado = false;
        List<SAC_Accion__c> listaInternaTareas = new List<SAC_Accion__c>();
        Map<Id, SAC_Accion__c> mapaInternaTareas = new Map<Id, SAC_Accion__c>();

        if(tareas != null) {
                listaInternaTareas.addAll(tareas);
                mapaInternaTareas.putAll(tareas);
        }
        list<string> estados = new list<string>{'SAC_Descartada'};
        if(Tipo == 'Tarea') {
                estados.add('SAC_PendienteEnviar');
        }

        //en la fase 2 de la redaccion no necesitamos la lista de tareas
        if(Tipo != 'Escalado') {

                List<SAC_Accion__c> tareasLanzadas = [SELECT Id, OwnerId, SAC_Estado__c, SAC_Pretension__c, SAC_Reclamacion__c, Name, SAC_EquipoResponsable__c,
                                                        SAC_Reclamacion__r.SAC_CasoEspecial__c, SAC_Reclamacion__r.SAC_Entidad_Afectada__c, SAC_Reclamacion__r.SEG_Grupo__c,
                                                        SAC_ImporteResuelto__c, SAC_Reclamacion__r.CC_Importe_Reclamado__c, SAC_Reclamacion__r.SAC_Importe_Resuelto__c,
                                                        SAC_ImporteAbonar__c, SAC_ImpResueltoInteresesLegales__c
                                                        FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: casoId 
                                                        AND (SAC_Estado__c NOT IN : estados)];
                //Añadido quitar duplicados
                if (!tareasLanzadas.isEmpty()) {
                    for (SAC_Accion__c accion : tareasLanzadas) {
                        if (!mapaInternaTareas.containsKey(accion.Id)) {
                            listaInternaTareas.add(accion);
                        }
                    }
                }
                //listaInternaTareas.addAll(tareasLanzadas);
        }

        Case reclamacion = [SELECT id, CC_Importe_Reclamado__c, SEG_Grupo__c, CC_MCC_Tematica__c,CC_MCC_Motivo__c, CC_MCC_ProdServ__c, 
                            SEG_Detalle__c, SAC_CasoEspecial__c, SAC_Entidad_Afectada__c, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c
                             FROM Case WHERE Id = :casoId LIMIT 1];
        List<String> mCCs = new list<String> {reclamacion.CC_MCC_Tematica__c,reclamacion.CC_MCC_Motivo__c, reclamacion.CC_MCC_ProdServ__c, reclamacion.SEG_Detalle__c};

        //obtengo el importe facultades menos restrictivo en el que el caso cumpla las condiciones que me indica el mínimo necesario para escalar el caso
        
        list<SAC_ParametrizacionEscalado__c> listEscElegido = obtenerFacultades(reclamacion);
        if(!listEscElegido.isEmpty()) {
            SAC_ParametrizacionEscalado__c escElegido = listEscElegido.get(0);
            for (SAC_Accion__c tar : listaInternaTareas) {
                if(tar.SAC_ImporteResuelto__c != null) {
                    sumatorio += tar.SAC_ImporteResuelto__c;
                }
                if(tar.SAC_ImporteAbonar__c != null){
                    sumatorioAbonado += tar.SAC_ImporteAbonar__c;
                }
                if(tar.SAC_ImpResueltoInteresesLegales__c != null){
                    sumatorioAbonado += tar.SAC_ImpResueltoInteresesLegales__c;
                }
            }
            //comprobar escalado en caso de que el importe facultades sea superado
            if(sumatorio > EscElegido.SAC_Importe__c || EscElegido.SAC_Importe__c < reclamacion.SAC_Importe_Resuelto__c) {
                comprobarEscalado = true;
            }
    
            if(comprobarEscalado || listaInternaTareas.isEmpty() || reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia'){
                
                string errorEscalado = '';
                escaladoValidarWrapper escaladoValidar = new escaladoValidarWrapper();
                decimal importe = reclamacion.SAC_Importe_Resuelto__c;
                string sTipo = 'de la reclamación';
                if(tipo == 'tarea') {
                    importe = sumatorio;
                    sTipo = 'de la(s) tarea(s) ';
                }
                escaladoValidar.reclamacion = reclamacion;
                escaladoValidar.escElegido = escElegido;
                escaladoValidar.tipo = sTipo;
                escaladoValidar.importe = importe;
                errorEscalado = validarEscalado(escaladoValidar);

                if(errorEscalado != ''){
                    return errorEscalado;
                }
    
            }
    
            //comprobar que los sumatorios de los campos resueltos y abonado de las tareas están alineados con los de la reclamación
            if(Tipo != 'Escalado') {
                if(sumatorio > reclamacion.SAC_Importe_Resuelto__c || (sumatorio > 0 && reclamacion.SAC_Importe_Resuelto__c == null)) {
                    return 'La suma de los importes resueltos de las tareas asociadas a la reclamación son mayores que el importe resuelto de la misma';
                }
                if(sumatorioAbonado > reclamacion.CC_Importe_Abonado__c  || (sumatorio > 0 && reclamacion.SAC_Importe_Resuelto__c == null)) {
                    return 'La suma de los importes a abonar de las tareas asociadas a la reclamación son mayores que el importe abonado de la misma';
                }
            }
        }
        
        //si devuelve blanco, la validación es correcta
        return '';
    }

     /**************************************************************************
     * Proposito: 
     * Valida si tiene escalado y si se encuentra dentro de los importes facultades
     * Modificación: Comentado comprobación del importe al quitarse el campo SAC_ImporteAutorizado__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         	DATE         Description
     * 1.0            US356803         Alexandre Pérez  06/11/2022   Creación
     * 1.1            US555020       Sergio Martín     16/05/2023   Modificación
    **************************************************************************/    
    public static string validarEscalado(escaladoValidarWrapper escaladoVal) {

        list<SAC_Interaccion__c> escalado = [SELECT Id, SAC_ImporteAutorizado__c FROM SAC_Interaccion__c WHERE SAC_CasoEscalado__c = :escaladoVal.reclamacion.id
                            AND (RecordType.DeveloperName = 'SAC_Escalado' OR RecordType.DeveloperName = 'SAC_EscaladoNV3')
                            AND SAC_Estado__c = : 'SAC_Atendida' ORDER BY SAC_ImporteAutorizado__c DESC LIMIT 1];

        //decimal importe = escaladoVal.importe;
        if(Escalado.isEmpty()) {
            if(escaladoVal.reclamacion.SAC_CasoEspecial__c == 'SAC_Presidencia') {
                return 'Caso especial ALTA DIRECCIÓN(se necesita escalado)';
            }
            if(escaladoVal.importe > escaladoVal.EscElegido.SAC_Importe__c) {
                return 'Se necesita escalar la reclamación ya que el importe facultades ha sido superado. ' + escaladoVal.EscElegido.SAC_Mensaje__c;
            }
        }
        // } else if(escalado[0].SAC_ImporteAutorizado__c  < escaladoVal.importe) {
        //     return 'El importe autorizado escalado es menor que el importe resuelto ' + escaladoVal.tipo +'. ' + escaladoVal.EscElegido.SAC_Mensaje__c;      
        // }
       

       /* if(!Escalado.isEmpty() && ) {
            return 'El importe autorizado escalado es menor que el importe resuelto ' + escaladoVal.tipo;
        }*/
        return '';
    }

    /**************************************************************************
     * Proposito: 
     * Obtener la parametrización escalado con el importe facultades
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         	DATE         Description
     * 1.0            US356803         Alexandre Pérez  06/11/2022   Creación
    **************************************************************************/    
    public static list<SAC_ParametrizacionEscalado__c> obtenerFacultades(Case reclamacion) {

        List<String> mCCs = new list<String> {reclamacion.CC_MCC_Tematica__c,reclamacion.CC_MCC_Motivo__c, reclamacion.CC_MCC_ProdServ__c, reclamacion.SEG_Detalle__c};
        string queryText = 'SELECT Id, SAC_Mensaje__c, SAC_GrupoDestino__c, SAC_Importe__c FROM SAC_ParametrizacionEscalado__c WHERE ';
        list<SAC_ParametrizacionEscalado__c> param = [SELECT Id, SAC_Mensaje__c, SAC_GrupoDestino__c, SAC_Importe__c 
                                            FROM SAC_ParametrizacionEscalado__c WHERE SAC_Entidad__c = : reclamacion.SAC_Entidad_Afectada__c AND SAC_Entidad__c != NULL ORDER BY SAC_Importe__c ASC LIMIT 1];
        if(!param.isEmpty()) {
            return Param;
        } else {
            return [SELECT Id, SAC_Mensaje__c, SAC_GrupoDestino__c, SAC_Importe__c FROM SAC_ParametrizacionEscalado__c 
                    WHERE ((SAC_todosMCCs__c = true AND SAC_TodosDespachos__c = true) OR 
                    (SAC_Despacho__c = : reclamacion.SEG_Grupo__c AND SAC_todosMCCs__c = true) OR
                    (SAC_MCC__c IN : mCCs AND SAC_TodosDespachos__c = true)) AND SAC_Entidad__c = NULL ORDER BY SAC_Importe__c ASC LIMIT 1];
        }
    }


    /***********************************************************************************************************
    * Proposito: Valida cuando se salga del estado "Alta" que el campo CC_Idioma__c esté informado
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US995254       Sergio Martín  20/08/2024       Creación
    ***********************************************************************************************************/
    public static void validarIdiomaInformado(List<Case> listaValidarIdioma, Map<Id, Case> mapOldCase) {
        for (Case caso : listaValidarIdioma) {
            if(mapOldCase.containsKey(caso.Id) && caso.CC_Idioma__c == null){
                caso.addError('Es necesario informar el campo idioma al salir del estado de Alta.');
            }
        }
    }

    /**************************************************************************
     * Proposito: 
     * wrapper para validaciones de escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         	DATE         Description
     * 1.0            US356803         Alexandre Pérez  06/11/2022   Creación
    **************************************************************************/    
    public class EscaladoValidarWrapper {
        case reclamacion;
        SAC_ParametrizacionEscalado__c escElegido;
        string tipo;
        decimal importe;
    }
}