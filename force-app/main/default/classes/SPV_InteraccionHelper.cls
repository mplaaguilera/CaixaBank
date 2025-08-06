public with sharing class SPV_InteraccionHelper {
    //Obtención record types
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'SAC_Interaccion__c', 'SAC_MaestroAccionesReclamacion__c','CC_Grupo_Colaborador__c','SAC_MaestroTemas__c'}; //,'SAC_TMECaso__c'
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION =  mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONESREC = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SPV_MaestroAcciones').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTA_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    private static final Id RECTYPGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_BlackListEmails').getRecordTypeId();
    private static final Id RECORDTYPETMECASO = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SPV_TMECaso').getRecordTypeId();
    // private static final Id RECTYPETMECONSULTA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_Consulta').getRecordTypeId();
	private static final Id RECORDTYPEFORMANALISISDECISION = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioAnalisisDecision').getRecordTypeId();
    private static final Id RECORDTYPEFORMRECTIFICACION = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioRectificacion').getRecordTypeId();

    /*****************************************************************
     * Proposito: Filtrar las interacciones entrantes para quedarnos únicamente con los de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Sergio Martín  01/08/2024        Creación
     *****************************************************************/
    public static List<SAC_Interaccion__c> filtrarInteraccionesSPV(List<SAC_Interaccion__c> lstInteracciones) {

        List<SAC_Interaccion__c> interaccionesSPV = new List<SAC_Interaccion__c>();

        for (SAC_Interaccion__c interaccion : lstInteracciones) {
            if (interaccion.RecordTypeId == RECTYPEESCALADO || interaccion.RecordTypeId == RECTYPECONSULTA || interaccion.RecordTypeId == RECTYPECONSULTA_TAREA) {
                interaccionesSPV.add(interaccion);
            }
        }
        
        return interaccionesSPV;
    }
        
    /**************************************************************************
     * Proposito: Rellenar los campos en la actualización del Escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1276831       Iria ÁNPC    11/06/2025       Creación    
    **************************************************************************/  
    public static void rellenarCamposAlActualizarBeforeUpdate(List<SAC_Interaccion__c> listNewInteraccion, Map<Id, SAC_Interaccion__c> mapOldObj) {
        // Informar "Fecha de validación AJ" cuando finaliza el escalado
        for(SAC_Interaccion__c escalado: listNewInteraccion){
            if(mapOldObj.containsKey(escalado.Id)){
                if(mapOldObj.get(escalado.Id).SAC_Estado__c != escalado.SAC_Estado__c && escalado.SAC_Estado__c == 'SAC_Atendida'){
                    escalado.SPV_FechaValidacion__c = CBK_UtilsDate.nowDT();
                }
                if(mapOldObj.get(escalado.Id).SAC_Estado__c != escalado.SAC_Estado__c && escalado.SAC_Estado__c == 'SAC_PendienteRespuesta'){
                    escalado.SPV_FechaPendienteRespuesta__c = CBK_UtilsDate.nowDT();
                }
            }
        }
    } 
        /**************************************************************************
     * Proposito: Rellenar los campos en la actualización del Escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1276831       Iria ÁNPC    11/06/2025       Creación    
    **************************************************************************/  
    public static void rellenarCamposAlActualizarAfterUpdate(List<SAC_Interaccion__c> listNewInteraccion, Map<Id, SAC_Interaccion__c> mapOldObj) {
        List<SPV_Formulario__c> formularioToUpdate = new List<SPV_Formulario__c>();
        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_CasoEscalado__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_CasoEscalado__c);
            }
        }
        // Get Formularios
        Map<String, SPV_Formulario__c> mapaFormularios = new Map<String, SPV_Formulario__c>();
        for(SPV_Formulario__c formulario : [SELECT ID, SPV_Caso__c, RecordType.DeveloperName, SPV_InstruccionesAJ__c FROM SPV_Formulario__c WHERE SPV_Caso__c IN: listaIdsCasoRelacionado ORDER BY CreatedDate ASC]){
            mapaFormularios.put(formulario.RecordType.DeveloperName, formulario);
        }
        // Informar "Instrucciones AJ" del escalado en el formulario
        // Informar Motivo Complementaria
        for(SAC_Interaccion__c escalado: listNewInteraccion){
            if(mapOldObj.containsKey(escalado.Id) && mapaFormularios.containsKey(escalado.SPV_TipoEscalado__c)){
                SPV_Formulario__c formulario = mapaFormularios.get(escalado.SPV_TipoEscalado__c);
                if(mapOldObj.get(escalado.Id).SPV_InstruccionesAJ__c != escalado.SPV_InstruccionesAJ__c){
                    formulario.SPV_InstruccionesAJ__c  = escalado.SPV_InstruccionesAJ__c;
                    formularioToUpdate.add(formulario);
                }
                if(mapOldObj.get(escalado.Id).SPV_MotivoComplementaria__c  != escalado.SPV_MotivoComplementaria__c){
                    formulario.SPV_MotivoComplementariaOrganismo__c  = escalado.SPV_MotivoComplementaria__c;
                    formulario.SPV_MotivoComplementariaEntidad__c  = escalado.SPV_MotivoComplementaria__c;
                    formularioToUpdate.add(formulario);
                }
            }
        }
        if(!formularioToUpdate.isEmpty()){
            update formularioToUpdate;
        }
    } 
    /**************************************************************************
     * Proposito: Crear registros de formulario en la creación del Escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1276831       Iria ÁNPC    13/06/2025       Creación    
    **************************************************************************/  
    public static void crearFormularios(List<SAC_Interaccion__c> listNewInteraccion) {
		List<SPV_Formulario__c> formulariosToCreate = new List<SPV_Formulario__c>();
		// Create Formulario
        for(SAC_Interaccion__c interaccion : listNewInteraccion) {
            if(interaccion.SPV_TipoEscalado__c == 'SPV_FormularioAnalisisDecision'){
                SPV_Formulario__c formulario = new SPV_Formulario__c(
                    SPV_Caso__c = interaccion.SAC_CasoEscalado__c,
                    RecordTypeId = RECORDTYPEFORMANALISISDECISION
                );
                formulariosToCreate.add(formulario);
            }else if(interaccion.SPV_TipoEscalado__c == 'SPV_FormularioRectificacion'){
                SPV_Formulario__c formulario = new SPV_Formulario__c(
                    SPV_Caso__c = interaccion.SAC_CasoEscalado__c,
                    RecordTypeId = RECORDTYPEFORMRECTIFICACION
                );
                formulariosToCreate.add(formulario);
            }
        }
        if(!formulariosToCreate.isEmpty()){
            insert formulariosToCreate;
        }
    } 

    /**************************************************************************
     * Proposito: Rellenar los campos iniciales en la creación del Escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1276831       Iria ÁNPC    11/06/2025       Creación    
    **************************************************************************/  
    public static void rellenarCamposIniciales(List<SAC_Interaccion__c> listNewInteraccion) {
        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_CasoEscalado__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_CasoEscalado__c);
            }
        }
        // Get Grupo Creador
        Map<Id, Id> mapaGrupo = new Map<Id, Id>();
        for(CC_Grupo_Colaborador_Contact__c grupo: [SELECT ID, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId()]){
            mapaGrupo.put(UserInfo.getUserId(), grupo.CC_Grupo_Colaborador__c);
        }
        // Get Case Extensions
        Map<String, CBK_Case_Extension__c> mapaCase = new Map<String, CBK_Case_Extension__c>();
        for(CBK_Case_Extension__c caso : [SELECT ID, SPV_PropuestaLetrado__c, SPV_PropuestaRectificacionLetrado__c, Case_Id__c FROM CBK_Case_Extension__c WHERE Case_Id__c IN: listaIdsCasoRelacionado ORDER BY CreatedDate ASC]){
            mapaCase.put(caso.Case_Id__c, caso);
        }
        // Get Formularios
        Map<String, SPV_Formulario__c> mapaFormularios = new Map<String, SPV_Formulario__c>();
        for(SPV_Formulario__c formulario : [SELECT ID, SPV_Caso__c, RecordType.DeveloperName, SPV_ImporteRectificacionPropuesto__c, SPV_InstruccionesRect__c FROM SPV_Formulario__c WHERE SPV_Caso__c IN: listaIdsCasoRelacionado ORDER BY CreatedDate ASC]){
            mapaFormularios.put(formulario.RecordType.DeveloperName, formulario);
        }
		// Update Escalados
        for(SAC_Interaccion__c interaccion : listNewInteraccion) {
            //interaccion.SPV_FechaEscalado__c = CBK_UtilsDate.nowDT();
            if(mapaFormularios.containsKey(interaccion.SPV_TipoEscalado__c)) {
                interaccion.SPV_Importe__c = mapaFormularios.get(interaccion.RecordType.DeveloperName).SPV_ImporteRectificacionPropuesto__c;
                interaccion.SPV_InstruccionesLetrado__c  = mapaFormularios.get(interaccion.RecordType.DeveloperName).SPV_InstruccionesRect__c ;
            }
            if(mapaCase.containsKey(interaccion.SAC_CasoEscalado__c)){
                if(interaccion.SPV_TipoEscalado__c == 'SPV_FormularioAnalisisDecision'){
                    interaccion.SAC_Propuesta__c = mapaCase.get(interaccion.SAC_CasoEscalado__c).SPV_PropuestaLetrado__c;
                }else if(interaccion.SPV_TipoEscalado__c == 'SPV_FormularioRectificacion'){
                    interaccion.SAC_Propuesta__c = mapaCase.get(interaccion.SAC_CasoEscalado__c).SPV_PropuestaRectificacionLetrado__c;
                }
            }
            if(mapaGrupo.containsKey(UserInfo.getUserId())){
                interaccion.SAC_GrupoCreador__c = mapaGrupo.get(UserInfo.getUserId());
            }
        }
    }  
    
    /*********************************************************************************************
     * Proposito: Cuando un escalado pasa a resuelto, entonces la reclamación ya no estará pendiente de 
     *  resolución. En este método se establece el campo "Pendiente de resolución de Escalado" a false
     * de las reclamaciones cuyo escalado se haya resuelto
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US997688       Álex Polo    04/09/2024        Creación    
    *********************************************************************************************/
    public static void actualizarPendienteEscaladoReclamacion(List<SAC_Interaccion__c> listaEscaladosConsulta, Map<Id, SAC_Interaccion__c> mapOldObj, Map<Id, Case> mapaCasosActualizar){

        List<SAC_Interaccion__C> listaEscaladosNew = new List<SAC_Interaccion__c>();
        Set<Id> idsReclamaciones = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();


        //Primero se hace una lista de escalados que hayan sido resueltos o que hayan vuelto a estar pendientes de ser enviados
        for(SAC_Interaccion__c interaccion : listaEscaladosConsulta){
            if(interaccion.RecordTypeId == RECTYPEESCALADO){
                if(mapOldObj.containsKey(interaccion.Id) && mapOldObj.get(interaccion.Id).SAC_Estado__c == 'SAC_PendienteRespuesta' && (interaccion.SAC_Estado__c == 'SAC_Atendida' || interaccion.SAC_Estado__c == 'SPV_PendienteEnviar')){ //Si el estado anterior es pendiente,  y el nuevo es resuelta o pendiente de enviar, se ha resuelto
                    listaEscaladosNew.add(interaccion);
                }
            }
        }
    
        //Se obtienen los id de las reclamaciones cuyo escalado haya sido resuelto
        if(!listaEscaladosNew.isEmpty()){
            for(SAC_Interaccion__C interaccion : listaEscaladosNew){
                idsReclamaciones.add(interaccion.SAC_CasoEscalado__c);
            }
        }

        //Se obtienen las reclamaciones que correspondan a los escalados resueltos

        if(!idsReclamaciones.isEmpty()){
            listaReclamaciones = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Id IN :idsReclamaciones];

        }

        //A todas estas reclamaciones, se le pondrá el campo "Pendiente resolución escalado" a false, pues ya han sido resueltos
        if(!listaReclamaciones.isEmpty()){
            for(Case reclamacion : listaReclamaciones){
                if(mapaCasosActualizar.containsKey(reclamacion.Id)){
                    mapaCasosActualizar.get(reclamacion.Id).SPV_Pendiente_Escalado__c = false;
                }else{
                    reclamacion.SPV_Pendiente_Escalado__c = false;
                    mapaCasosActualizar.put(reclamacion.Id, reclamacion);
                }



            }

        }
    }


    /*********************************************************************************************
     * Proposito: CAl enviar un escalado, la reclamación afectada debe tener el campo
     * "Pendiente resolución de escalado" a true.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US997688       Álex Polo    04/09/2024        Creación    
    *********************************************************************************************/
    public static void actualizarReclamacionAlEnviarEscalado(List<SAC_Interaccion__c> listaEscaladosConsulta, Map<Id, SAC_Interaccion__c> mapOldObj, Map<Id, Case> mapaCasosActualizar){

        List<SAC_Interaccion__C> listaEscaladosNew = new List<SAC_Interaccion__c>();
        Set<Id> idsReclamaciones = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();

            //Primero se hace una lista de escalados que hayan sido enviados
            for(SAC_Interaccion__c interaccion : listaEscaladosConsulta){
                if(interaccion.RecordTypeId == RECTYPEESCALADO){
                    if(mapOldObj.containsKey(interaccion.Id) && mapOldObj.get(interaccion.Id).SAC_Estado__c != 'SAC_PendienteRespuesta' && interaccion.SAC_Estado__c == 'SAC_PendienteRespuesta'){ //Si el nuevo estado es pendiente de respuesta, se almacena el escalado
                        listaEscaladosNew.add(interaccion);
                    }
                }
            }


            //Se obtienen los id de las reclamaciones cuyo escalado haya sido resuelto
            if(!listaEscaladosNew.isEmpty()){
                for(SAC_Interaccion__C interaccion : listaEscaladosNew){
                    idsReclamaciones.add(interaccion.SAC_CasoEscalado__c);
                }
            }

            //Se obtienen las reclamaciones que correspondan a los escalados resueltos
            if(!idsReclamaciones.isEmpty()){
                listaReclamaciones = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Id IN :idsReclamaciones];
            }




            //A todas estas reclamaciones, se le pondrá el campo "Pendiente resolución escalado" a false, pues ya han sido resueltos
            if(!listaReclamaciones.isEmpty()){
                for(Case reclamacion : listaReclamaciones){
                    if(mapaCasosActualizar.containsKey(reclamacion.Id)){
                        mapaCasosActualizar.get(reclamacion.Id).SPV_Pendiente_Escalado__c = true;
                    }else{
                        reclamacion.SPV_Pendiente_Escalado__c = true;
                        mapaCasosActualizar.put(reclamacion.Id, reclamacion);
                    }
                }
            }
    }


    /*********************************************************************************************
     * Proposito: Al enviar o finalizar un escalado, se deben pausar o renaudar determinados
     * TMEs
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1260232       Álex Polo    05/06/2025        Creación    
    *********************************************************************************************/
    public static void pausarORenaudarTME(List<SAC_Interaccion__c> listaEscaladosConsulta, Map<Id, SAC_Interaccion__c> mapOldObj){

        List<SAC_Interaccion__c> listaEscaladosPausarTMEs = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaEscaladosRenaudarTMEs = new List<SAC_Interaccion__c>();

        for(SAC_Interaccion__c escalado : listaEscaladosConsulta){
            if(escalado.RecordTypeId == RECTYPEESCALADO){
                //Los escalados que se envíen, tienen que pausar determinados TMEs. Los enviados son los que pasan a estado SPV_PendienteRespuesta
                if(mapOldObj.containsKey(escalado.Id) && escalado.SAC_Estado__c != mapOldObj.get(escalado.Id).SAC_Estado__c && escalado.SAC_Estado__c == 'SAC_PendienteRespuesta' && mapOldObj.get(escalado.Id).SAC_Estado__c != 'SAC_PendienteRespuesta'){
                    listaEscaladosPausarTMEs.add(escalado);
                }else if(mapOldObj.containsKey(escalado.Id) &&  escalado.SAC_Estado__c != mapOldObj.get(escalado.Id).SAC_Estado__c && escalado.SAC_Estado__c == 'SAC_Atendida' && mapOldObj.get(escalado.Id).SAC_Estado__c != 'SAC_Atendida'){ //Cuando se finaliza un escalado, hay que renaudar determinados TMEs
                    listaEscaladosRenaudarTMEs.add(escalado);
                }
            }
        }

        if(!listaEscaladosPausarTMEs.isEmpty()){
            pausarTMEs(listaEscaladosPausarTMEs);
        }

        if(!listaEscaladosRenaudarTMEs.isEmpty()){
            renaudarTMEs(listaEscaladosRenaudarTMEs);
        }
    }


    /*********************************************************************************************
     * Proposito: Al enviar un escalado, se deben pausar determinados TMEs
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1260232       Álex Polo    05/06/2025        Creación    
    *********************************************************************************************/
    public static void pausarTMEs(List<SAC_Interaccion__c> listaEscaladosPausarTMEs){

        Set<Id> idsCasos = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();
        Map<Id, List<SAC_TiempoEstados__c>> mapaCasoTpes = new Map<Id, List<SAC_TiempoEstados__c>>();
        List<SAC_TiempoEstados__c> listaTPEsActualizar = new List<SAC_TiempoEstados__c>();

        //Obtener los Ids de las reclamaciones a las que hay que comprobar su TME
        for(SAC_Interaccion__c escalado : listaEscaladosPausarTMEs){

            idsCasos.add(escalado.SAC_CasoEscalado__c);
        }

        if(!idsCasos.isEmpty()){
            listaReclamaciones = [SELECT Id, Status FROM Case WHERE Id IN :idsCasos AND RecordTypeId = :RECTYPERECLAMACION];

            //Crear un mapa de las reclamaciones implicadas
            for(Case caso : listaReclamaciones){
                if(!mapaReclamaciones.containsKey(caso.Id)){
                    mapaReclamaciones.put(caso.Id, caso);
                }
            }

            //Se obtienen los TMEs que tienen las reclamaciones
            List<SAC_TMECaso__c> listaTMOsCaso = [SELECT Id, SAC_Caso__c FROM SAC_TMECaso__c WHERE RecordTypeId =: RECORDTYPETMECASO AND SAC_Caso__c IN: mapaReclamaciones.keySet()];

            //Para cada tme, se obtienen los tpe que no hayan sido finalizados (esto es el último tpe creado de cada tme asociado a la reclamación)
            if(!listaTMOsCaso.isEmpty()){
                List<SAC_TiempoEstados__c> listaTPEsCaso = [SELECT Id, SAC_TMECaso__r.SAC_Caso__c, SAC_Estado__c FROM SAC_TiempoEstados__c  WHERE SAC_TMECaso__c =: listaTMOsCaso AND SAC_Fin__c = null ORDER BY CreatedDate desc ];
                //Se contruye un mapa que relacione cada caso con sus tpes -> Reclamación - Lista Tpes asociados sin finalizar
                for(SAC_TiempoEstados__c tpe : listaTPEsCaso){
                    if(mapaCasoTpes.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c)){
                        mapaCasoTpes.get(tpe.SAC_TMECaso__r.SAC_Caso__c).add(tpe);
                    }else{
                        List<SAC_TiempoEstados__c> listTPE = new List<SAC_TiempoEstados__c>();
                        listTPE.add(tpe);
                        mapaCasoTpes.put(tpe.SAC_TMECaso__r.SAC_Caso__c, listTPE);
                    }
                }
            }

            //Se recorre cada reclamación para ver cuál de los tpes se debe finalizar
            for(Case recla : listaReclamaciones){
                List<SAC_TiempoEstados__c> tpeDeCaso = new List<SAC_TiempoEstados__c>();
                if(mapaCasoTpes.containsKey(recla.Id)){
                    tpeDeCaso = mapaCasoTpes.get(recla.Id);     //Se cogen los TPE que el caso ya tiene asociados, para ver cuál se tiene que finalizar
                
                    for(SAC_TiempoEstados__c tpe : tpeDeCaso){
                        //Hay que detener los TPE de X estados si se escala en ellos
                        if((recla.Status == 'SPV_AnalisisComplementariaOrganismo' || recla.Status == 'SPV_AnalisisDecision' || recla.Status == 'SPV_Rectificacion') && recla.Status == tpe.SAC_Estado__c){
                            tpe.SAC_Fin__c = CBK_UtilsDate.nowSYS();
                            listaTPEsActualizar.add(tpe);
                        }
                    }
                }
            }

            if(!listaTPEsActualizar.isEmpty()){
                SPV_DatabaseDML.updateListDML(listaTPEsActualizar, true);
            }

        }
    }


    /*********************************************************************************************
     * Proposito: Al finalizar un escalado, se deben renaudar determinados TMEs
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1260232       Álex Polo    05/06/2025        Creación    
    *********************************************************************************************/
    public static void renaudarTMEs(List<SAC_Interaccion__c> listaEscaladosRenaudarTMEs){
        Set<Id> idsCasos = new Set<Id>();
        List<Case> listaReclamaciones = new List<Case>();
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();
        List<SAC_TiempoEstados__c> listaTPEsAniadir = new List<SAC_TiempoEstados__c>();

        //Obtener los Ids de las reclamaciones a las que hay que comprobar su TME
        for(SAC_Interaccion__c escalado : listaEscaladosRenaudarTMEs){

            idsCasos.add(escalado.SAC_CasoEscalado__c);
        }

        if(!idsCasos.isEmpty()){
            listaReclamaciones = [SELECT Id, Status FROM Case WHERE Id IN :idsCasos AND RecordTypeId = :RECTYPERECLAMACION];

            //Crear un mapa de las reclamaciones implicadas
            for(Case caso : listaReclamaciones){
                if(!mapaReclamaciones.containsKey(caso.Id)){
                    mapaReclamaciones.put(caso.Id, caso);
                }
            }

            //Se obtienen los TMEs que tienen las reclamaciones
            List<SAC_TMECaso__c> listaTMOsCaso = [SELECT Id, SAC_Caso__c, SAC_Caso__r.Status, Name FROM SAC_TMECaso__c WHERE RecordTypeId =: RECORDTYPETMECASO AND SAC_Caso__c IN: mapaReclamaciones.keySet()];

            //Para cada TME, si se finaliza el escalado cuando se está en un estado determinado, hay que renaudar el tme que corresponda
            for(SAC_TMECaso__c tme : listaTMOsCaso){
                if((tme.SAC_Caso__r.Status == 'SPV_AnalisisComplementariaOrganismo' && tme.Name == 'TMO Análisis Complementaria Organismo') || (tme.SAC_Caso__r.Status == 'SPV_AnalisisDecision' && tme.Name == 'TMO Análisis y Decisión') || (tme.SAC_Caso__r.Status == 'SPV_Rectificacion' && tme.Name == 'TMO Rectificación')){
                    SAC_TiempoEstados__c tpe = new SAC_TiempoEstados__c();
                    tpe.SAC_Estado__c = tme.SAC_Caso__r.Status;
                    tpe.SAC_Inicio__c = CBK_UtilsDate.nowSYS();
                    tpe.SAC_TMECaso__c = tme.Id;
                    listaTPEsAniadir.add(tpe);
                }
            }

            if(!listaTPEsAniadir.isEmpty()){
                SPV_DatabaseDML.insertListDML(listaTPEsAniadir, true);
            }
        }

    }


    /*********************************************************************************************
     * Proposito: Al modificar determinados campos de un escalado, se deben registrar en la tab
     * de Actividades de la reclamación
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1276820       Álex Polo    11/06/2025        Creación    
    *********************************************************************************************/
    public static void registrarCambiosActividades(List<SAC_Interaccion__c> listInteraccionesSPV, Map<Id, SAC_Interaccion__c> mapOldObj){

        List<FeedItem> listaFeedItems = new List<FeedItem>();
        Set<Id> idsEscalados = new Set<Id>();
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        Map<String, String> mapValoresTipoEscalado = new Map<String, String>();
        Map<String, String> mapValoresMotivoEscalado = new Map<String, String>();
        Map<String, String> mapValoresConclusionEscalado = new Map<String, String>();
        Map<String, String> mapValoresDecisionFinalEscalado = new Map<String, String>();

        //Se rellenan los mapas del tipo ApiName - Label de los campos picklist a registrar
        Schema.DescribeFieldResult fieldResultTipoEscalado = SAC_Interaccion__c.SPV_TipoEscalado__c.getDescribe();
        Schema.DescribeFieldResult fieldResultMotivoEscalado = SAC_Interaccion__c.SAC_MotivoEscalado__c.getDescribe();
        Schema.DescribeFieldResult fieldResultConclusionEscalado = SAC_Interaccion__c.SAC_Conclusion__c.getDescribe();
        Schema.DescribeFieldResult fieldResultDecisionFinalEscalado = SAC_Interaccion__c.SPV_DecisionFinal__c.getDescribe();

        List<Schema.PicklistEntry> picklistValuesTipoEscalado = fieldResultTipoEscalado.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : picklistValuesTipoEscalado){
            if(!mapValoresTipoEscalado.containsKey(picklistVal.getValue())){
                mapValoresTipoEscalado.put(picklistVal.getValue(), picklistVal.getLabel());
            }
        }

        List<Schema.PicklistEntry> picklistValuesMotivoEscalado = fieldResultMotivoEscalado.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : picklistValuesMotivoEscalado){
            if(!mapValoresMotivoEscalado.containsKey(picklistVal.getValue())){
                mapValoresMotivoEscalado.put(picklistVal.getValue(), picklistVal.getLabel());
            }
        }

        List<Schema.PicklistEntry> picklistValuesConclusionEscalado = fieldResultConclusionEscalado.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : picklistValuesConclusionEscalado){
            if(!mapValoresConclusionEscalado.containsKey(picklistVal.getValue())){
                mapValoresConclusionEscalado.put(picklistVal.getValue(), picklistVal.getLabel());
            }
        }

        List<Schema.PicklistEntry> picklistValuesDecisionFinalEscalado = fieldResultDecisionFinalEscalado.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : picklistValuesDecisionFinalEscalado){
            if(!mapValoresDecisionFinalEscalado.containsKey(picklistVal.getValue())){
                mapValoresDecisionFinalEscalado.put(picklistVal.getValue(), picklistVal.getLabel());
            }
        }

        //Se recorren los escalados para registrar en Actividades aquellas actualizaciones que se necesite que sean registradas
        for(SAC_Interaccion__c escalado : listInteraccionesSPV){
            if(escalado.RecordTypeId == RECTYPEESCALADO){
                if(mapOldObj.containsKey(escalado.Id) && escalado.SPV_TipoEscalado__c != mapOldObj.get(escalado.Id).SPV_TipoEscalado__c){
                    String cuerpo =  mapOldObj.get(escalado.Id).SPV_TipoEscalado__c == null ? 'En el escalado ' + escalado.Name + ' se ha establecido el Tipo escalado en: ' + mapValoresTipoEscalado.get(escalado.SPV_TipoEscalado__c) : 'En el escalado ' + escalado.Name + ' se ha modificado el Tipo escalado.\nAnterior: ' + mapValoresTipoEscalado.get(mapOldObj.get(escalado.Id).SPV_TipoEscalado__c) + '\nActual: ' + mapValoresTipoEscalado.get(escalado.SPV_TipoEscalado__c);
                    listaFeedItems.add(crearFeedActividad(escalado.SAC_CasoEscalado__c, cuerpo));
                }

                if(mapOldObj.containsKey(escalado.Id) && escalado.SAC_MotivoEscalado__c != mapOldObj.get(escalado.Id).SAC_MotivoEscalado__c){
                    String cuerpo = mapOldObj.get(escalado.Id).SAC_MotivoEscalado__c == null ? 'En el escalado ' + escalado.Name + ' se ha establecido el Motivo escalado en: ' + mapValoresMotivoEscalado.get(escalado.SAC_MotivoEscalado__c) : 'En el escalado ' + escalado.Name + ' se ha modificado el Motivo escalado.\nAnterior: ' + mapValoresMotivoEscalado.get(mapOldObj.get(escalado.Id).SAC_MotivoEscalado__c) + '\nActual: ' + mapValoresMotivoEscalado.get(escalado.SAC_MotivoEscalado__c);
                    listaFeedItems.add(crearFeedActividad(escalado.SAC_CasoEscalado__c, cuerpo));  
                }

                if(mapOldObj.containsKey(escalado.Id) && escalado.SAC_Conclusion__c != mapOldObj.get(escalado.Id).SAC_Conclusion__c){
                    String cuerpo = mapOldObj.get(escalado.Id).SAC_Conclusion__c == null ? 'En el escalado ' + escalado.Name + ' se ha establecido la Conclusión escalado en: ' + mapValoresConclusionEscalado.get(escalado.SAC_Conclusion__c) : 'En el escalado ' + escalado.Name + ' se ha modificado la Conclusión escalado.\nAnterior: ' + mapValoresConclusionEscalado.get(mapOldObj.get(escalado.Id).SAC_Conclusion__c) + '\nActual: ' + mapValoresConclusionEscalado.get(escalado.SAC_Conclusion__c);
                    listaFeedItems.add(crearFeedActividad(escalado.SAC_CasoEscalado__c, cuerpo));  
                }

                //La decisión final solo se registra si el tipo de escalado no es "Otros"
                if(mapOldObj.containsKey(escalado.Id) && escalado.SPV_DecisionFinal__c != mapOldObj.get(escalado.Id).SPV_DecisionFinal__c && escalado.SPV_TipoEscalado__c != 'SPV_Otros'){
                    String cuerpo = mapOldObj.get(escalado.Id).SPV_DecisionFinal__c == null ? 'En el escalado ' + escalado.Name + ' se ha establecido la Decisión final en: ' + mapValoresDecisionFinalEscalado.get(escalado.SPV_DecisionFinal__c) : 'En el escalado ' + escalado.Name + ' se ha modificado la Decisión final.\nAnterior: ' + mapValoresDecisionFinalEscalado.get(mapOldObj.get(escalado.Id).SPV_DecisionFinal__c) + '\nActual: ' + mapValoresDecisionFinalEscalado.get(escalado.SPV_DecisionFinal__c);
                    listaFeedItems.add(crearFeedActividad(escalado.SAC_CasoEscalado__c, cuerpo));  
                }

                //El Importe Decisión Final se registra si el tipo de escalado es rectificación
                if(mapOldObj.containsKey(escalado.Id) && escalado.SPV_ImporteDecisionFinal__c != mapOldObj.get(escalado.Id).SPV_ImporteDecisionFinal__c && escalado.SPV_TipoEscalado__c == 'SPV_FormularioRectificacion'){      
                    String cuerpo = mapOldObj.get(escalado.Id).SPV_ImporteDecisionFinal__c == null ? 'En el escalado ' + escalado.Name + ' se ha establecido el Importe Decisión final en: ' + escalado.SPV_ImporteDecisionFinal__c + ' €' : 'En el escalado ' + escalado.Name + ' se ha modificado el Importe Decisión final.\nAnterior: ' + mapOldObj.get(escalado.Id).SPV_ImporteDecisionFinal__c + ' €\nActual: ' + escalado.SPV_ImporteDecisionFinal__c + ' €';
                    listaFeedItems.add(crearFeedActividad(escalado.SAC_CasoEscalado__c, cuerpo));  
                }

            }
        }

        //Una vez se tienen todos los items a crear, se crean para añadirse a la Tab de Actividades
        if(!listaFeedItems.isEmpty()){
            SPV_DatabaseDML.insertListDML(listaFeedItems, true);
        }
    }

    /*********************************************************************************************
     * Proposito: Al crear un escalado, se registra un mensaje informando el tipo y el motivo en
     * la tab de Actividades de la reclamación
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1276820       Álex Polo    11/06/2025        Creación    
    *********************************************************************************************/
    public static void registrarCreacionEscaladoActividades(List<SAC_Interaccion__c> listaEscalados){
        List<FeedItem> listaFeedItems = new List<FeedItem>(); 
        Map<String, String> mapValoresTipoEscalado = new Map<String, String>();
        Map<String, String> mapValoresMotivoEscalado = new Map<String, String>();

        //Se rellenan los mapas del tipo ApiName - Label de los campos picklist a registrar
        Schema.DescribeFieldResult fieldResultTipoEscalado = SAC_Interaccion__c.SPV_TipoEscalado__c.getDescribe();
        Schema.DescribeFieldResult fieldResultMotivoEscalado = SAC_Interaccion__c.SAC_MotivoEscalado__c.getDescribe();

        List<Schema.PicklistEntry> picklistValuesTipoEscalado = fieldResultTipoEscalado.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : picklistValuesTipoEscalado){
            if(!mapValoresTipoEscalado.containsKey(picklistVal.getValue())){
                mapValoresTipoEscalado.put(picklistVal.getValue(), picklistVal.getLabel());
            }
        }

        List<Schema.PicklistEntry> picklistValuesMotivoEscalado = fieldResultMotivoEscalado.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : picklistValuesMotivoEscalado){
            if(!mapValoresMotivoEscalado.containsKey(picklistVal.getValue())){
                mapValoresMotivoEscalado.put(picklistVal.getValue(), picklistVal.getLabel());
            }
        }

        //Incluir este mensaje en la reclamación de cada escalado que se crea
        for(SAC_Interaccion__c escalado : listaEscalados){
            String cuerpo = 'Se ha creado el escalado ' + escalado.Name + ' de Tipo "' + mapValoresTipoEscalado.get(escalado.SPV_TipoEscalado__c) + '" con Motivo "' + mapValoresMotivoEscalado.get(escalado.SAC_MotivoEscalado__c) + '".';
            listaFeedItems.add(crearFeedActividad(escalado.SAC_CasoEscalado__c, cuerpo));  
        }

        if(!listaFeedItems.isEmpty()){
            SPV_DatabaseDML.insertListDML(listaFeedItems, true);
        }
    }

    /*********************************************************************************************
     * Proposito: Método para crear FeedItems
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1276820       Álex Polo    11/06/2025        Creación    
    *********************************************************************************************/
    public static FeedItem crearFeedActividad(Id parentId, String body){
        FeedItem feed = new FeedItem();
        feed.ParentId = parentId;
        feed.Body = body;
        return feed;
    }


    /*********************************************************************************************
     * Proposito: Al cambiar de estado un escalado, realizar las validaciones correspondientes
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1276818       Álex Polo    09/06/2025        Creación    
    *********************************************************************************************/
    public static void validarCamposCambioEstadoEscalado(List<SAC_Interaccion__c> listaInteracciones, Map<Id, SAC_Interaccion__c> mapOldObj){

        List<SAC_Interaccion__c> listaEscaladosFinalizados = new List<SAC_Interaccion__c>();

        //Hacer una lista con los escalados que vayan a pasar a X estado, para validar los campos y ver si se permite o no
        for(SAC_Interaccion__c escalado : listaInteracciones){
            if(mapOldObj.containsKey(escalado.Id) && mapOldObj.get(escalado.Id).SAC_Estado__c != 'SAC_Atendida' && escalado.SAC_Estado__c == 'SAC_Atendida'){
                listaEscaladosFinalizados.add(escalado);
            }
        }

        //LLamar a los métodos de validación correspondientes
        if(!listaEscaladosFinalizados.isEmpty()){
            validarCamposEscaladoFinalizado(listaEscaladosFinalizados);
        }
    }

    /*********************************************************************************************
     * Proposito: Validaciones al finalizar un escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1276818       Álex Polo    09/06/2025        Creación    
    *********************************************************************************************/
    public static void validarCamposEscaladoFinalizado(List<SAC_Interaccion__c> listaEscaladosFinalizados){
        for(SAC_Interaccion__c escalado : listaEscaladosFinalizados){
            if(escalado.SAC_Conclusion__c == null || String.isBlank(escalado.SAC_Conclusion__c)){
                escalado.addError('Es necesario completar el campo Conclusión para poder finalizar el escalado.');
            }
            //El campo Decisión Final no es obligatorio si el tipo de escalado es "Otros"
            if(escalado.SPV_TipoEscalado__c != 'SPV_Otros' && (escalado.SPV_DecisionFinal__c == null || String.isEmpty(escalado.SPV_DecisionFinal__c))){
                escalado.addError('Es necesario completar el campo Decisión Final para poder finalizar el escalado.');
            }
            if(escalado.SPV_InstruccionesAJ__c == null || String.isBlank(escalado.SPV_InstruccionesAJ__c)){
                escalado.addError('Es necesario completar el campo Instrucciones AJ para poder finalizar el escalado.');
            }
            //Solo si el tipo de escalado es Rectificación, será obligatorio el campo Importe Decisión Final
            if(escalado.SPV_TipoEscalado__c == 'SPV_FormularioRectificacion' && escalado.SPV_ImporteDecisionFinal__c == null){
                escalado.addError('Es necesario completar el campo Importe Decisión Final para poder finalizar el escalado.');
            }
        }

    }

    /*********************************************************************************************
     * Proposito: Validaciones relacionadas con las observaciones del tipo y motivo del escalado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US1276818       Álex Polo    09/06/2025        Creación    
    *********************************************************************************************/
    public static void validarObservacionesEscalado(List<SAC_Interaccion__c> listaInteracciones, Map<Id, SAC_Interaccion__c> mapOldObj){
        for(SAC_Interaccion__c escalado : listaInteracciones){
            //Si se cambia el motivo a "Otros", se debe informar el campo observaciones del motivo escalado. Si el motivo es "Otros", no se podrán tampoco vaciar las observaciones del motivo escalado
            if(mapOldObj.containsKey(escalado.Id) && escalado.SAC_MotivoEscalado__c == 'SAC_OtrosMotivosEsc' /*&& mapOldObj.get(escalado.Id).SAC_MotivoEscalado__c != 'SAC_OtrosMotivosEsc'*/){
                if(escalado.SPV_ObservacionesMotivoEscalado__c == null || String.isBlank(escalado.SPV_ObservacionesMotivoEscalado__c)){
                    escalado.SPV_ObservacionesMotivoEscalado__c.addError('Es necesario informar las Observaciones Motivo escalado.');
                }
            }else{
                //Si se pasa de motivo = "Otros" a cualquier otro, se vacía el campo de observaciones
                if(mapOldObj.containsKey(escalado.Id) && escalado.SAC_MotivoEscalado__c != 'SAC_OtrosMotivosEsc' && mapOldObj.get(escalado.Id).SAC_MotivoEscalado__c == 'SAC_OtrosMotivosEsc'){
                    escalado.SPV_ObservacionesMotivoEscalado__c = null;
                }
            }
            //Si el tipo de escalado es "Otros", y se modifica el campo de observaciones tipo escalado, controlar que no se vacíe
            if(mapOldObj.containsKey(escalado.Id) && escalado.SPV_TipoEscalado__c == 'SPV_Otros' && escalado.SPV_ObservacionesTipoEscalado__c != mapOldObj.get(escalado.Id).SPV_ObservacionesTipoEscalado__c){
                if(escalado.SPV_ObservacionesTipoEscalado__c == null || String.isBlank(escalado.SPV_ObservacionesTipoEscalado__c)){
                    escalado.SPV_ObservacionesTipoEscalado__c.addError('Es necesario informar las Observaciones Tipo escalado.');
                }
            }
        }
    }


    /*********************************************************************************************
     * Proposito: Método que cambia de estado la consulta cuando se informa el campo pregunta e informa la fecha de vencimiento y/o enviar email si es necesario
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    public static void informarPreguntaConsulta(List<SAC_Interaccion__c> listaConsultasSPV, Map<Id, SAC_Interaccion__c> mapOldObj){

        Set<Id> setIdsConsultas = new Set<Id>();
        List<SAC_Interaccion__c> consultasFechaVenciiento = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> consultasEnvioMail = new List<SAC_Interaccion__c>();
        Map<Id, date> mapFechaVencimiento = new Map<Id, date>();

        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
        
        for(SAC_Interaccion__c consulta : listaConsultasSPV){ 
            if(consulta.SAC_Pregunta__c != mapOldObj.get(consulta.Id).SAC_Pregunta__c && String.isBlank(mapOldObj.get(consulta.Id).SAC_Pregunta__c)){ 
                consulta.SAC_Estado__c = 'SAC_PendienteRespuesta';

                if(consulta.SAC_GrupoColaborador__r.SAC_Externo__c == false && consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c != 'OFICINA'){
                    consulta.OwnerId = cola[0].Id;
                }

                setIdsConsultas.add(consulta.Id);
            }
        }

        if(!setIdsConsultas.isEmpty()){    
            SAC_Interaccion__c consulta = [SELECT Id, SAC_Fecha_Vencimiento__c, SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c, SAC_Oficina__c, SAC_EmailOficina__c, SAC_EmailCC__c, SAC_EmailCCO__c, SAC_GrupoColaborador__r.SAC_Externo__c, SAC_GrupoColaborador__r.SAC_Email__c , SAC_GrupoColaborador__r.SAC_Email2__c , SAC_GrupoColaborador__r.SAC_Email3__c FROM SAC_Interaccion__c WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPECONSULTA_TAREA) AND Id IN: setIdsConsultas LIMIT 1]; 
           
            if(consulta.SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c != null && consulta.SAC_Fecha_Vencimiento__c == null){
                calculoFechaVencimientoConsulta(listaConsultasSPV, consulta);
            }

            if(consulta.SAC_GrupoColaborador__r.SAC_Externo__c != true){
                enviarEmailConsultaInternaAndOficina(listaConsultasSPV, consulta);
            }
        }
    }

    /**************************************************************************
     * Proposito: Calcular los dias de vencimiento teniendo en cuenta el calendario laboral de SPV dependiendo de periodo consulta configurado en el grupo asignado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/ 
    public static void calculoFechaVencimientoConsulta(List<SAC_Interaccion__c> listaConsultasSPV, SAC_Interaccion__c consulta){

        BusinessHours bh = [SELECT id FROM BusinessHours WHERE name = 'SPV_Calendario' LIMIT 1];

        if(bh != null){

            Date fechaVencimiento = BusinessHours.add(bh.Id, datetime.now(), integer.valueof(consulta.SAC_GrupoColaborador__r.SAC_PeriodoConsulta__c*86400*1000)).date();
           
            for (SAC_Interaccion__c interaccion : listaConsultasSPV) {
                if (interaccion.Id == consulta.Id) {
                    interaccion.SAC_Fecha_Vencimiento__c = fechaVencimiento;
                    break;
                }
            }
        }
    }

    public static void enviarEmailConsultaInternaAndOficina(List<SAC_Interaccion__c> listaConsultasSPV,SAC_Interaccion__c consulta) {

        //Recuperación plantillas
        if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas' ); }
        List<EmailTemplate> listaTemplates = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'SPV_ConsultaOficina' OR DeveloperName = 'SPV_ConsultaInterna'];

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

        String whoId = UserInfo.getUserId();
        Boolean errorMessage = false;
        String emailsNoValidosEncontrados = '';

        if(String.isNotBlank(consulta.SAC_Oficina__c)){

            String para = '';
            String emailCC = '';
            String emailCCO = '';
            
            if (String.isNotBlank(consulta.SAC_EmailOficina__c)) {
                para = consulta.SAC_EmailOficina__c;    
            }
            if (String.isNotBlank(consulta.SAC_EmailCC__c)) {
                emailCC = consulta.SAC_EmailCC__c;    
            }
            if (String.isNotBlank(consulta.SAC_EmailCCO__c)) {
                emailCCO = consulta.SAC_EmailCCO__c;    
            }

            //Compruebo las direcciones de envio con las de la blackList
            emailsNoValidosEncontrados = SPV_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, emailCC, emailCCO);

            //Si las direcciones de envio son válidas (no está en la blackList), continuo el proceso
            if(emailsNoValidosEncontrados == ''){
                EmailTemplate plantillaOficina;
                //Recuperar la plantilla
                for(EmailTemplate em : listaTemplates){
                    if(em.DeveloperName == 'SPV_ConsultaOficina'){
                        plantillaOficina = em;
                    }
                }
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaOficina.Id, whoId, consulta.Id);                      
                TemplateWrapper plantilla = new TemplateWrapper(plantillaOficina.Id, plantillaOficina.Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');

                // Metodo para recuperar los adjuntos y enviar el mail
                if(String.isNotBlank(para) && plantilla != null) {
                    consulta.SAC_Titulo__c = plantilla.subjectTemplate;
                    recuperarAdjuntos(consulta.Id, para, emailCC, emailCCO, plantilla);
                }
            }else{
                //Si las direcciones de envio no son válidas (están en la blackList), notifico al usuario
                // consulta.addError('No está permitido el envío de emails a la dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
                errorMessage = true;
            }

        }else{                 
            List<String> listaDireccionesPara = new List<String>();

            if (String.isNotBlank(consulta.SAC_GrupoColaborador__r.SAC_Email__c)) {
                listaDireccionesPara.add(consulta.SAC_GrupoColaborador__r.SAC_Email__c);   
            }
            if (String.isNotBlank(consulta.SAC_GrupoColaborador__r.SAC_Email2__c)) {
                listaDireccionesPara.add(consulta.SAC_GrupoColaborador__r.SAC_Email2__c);  
            }
            if (String.isNotBlank(consulta.SAC_GrupoColaborador__r.SAC_Email3__c)) {
                listaDireccionesPara.add(consulta.SAC_GrupoColaborador__r.SAC_Email3__c);  
            } 

            List<String> emailsValidos = SPV_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si las direcciones de envio son válidas (no está en la blackList), continuo el proceso
            if(!emailsValidos.isEmpty()){
                EmailTemplate plantillaInterna;
                //Recuperar la plantilla
                for(EmailTemplate em : listaTemplates){
                    if(em.DeveloperName == 'SPV_ConsultaInterna'){
                        plantillaInterna = em;
                    }
                }
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantillaInterna.Id, whoId, consulta.Id);                      
                TemplateWrapper plantilla = new TemplateWrapper(plantillaInterna.Id, plantillaInterna.Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');

                // Metodo para recuperar los adjuntos y enviar el mail
                if(plantilla != null) {
                    String para = '';

                    for(String email : emailsValidos){
                        if(para == ''){
                            para = email;
                        }else{
                            para = para + ';' + email;
                        }
                    }

                    consulta.SAC_Titulo__c = plantilla.subjectTemplate;
                    recuperarAdjuntos(consulta.Id, para, '', '', plantilla);
                }
            }else{
                //Si las direcciones de envio no son válidas (están en la blackList), notifico al usuario
                String para = '';

                //Si no hay ninguna dirección válida, no se envía email, pero si la consulta en sf
                // for(String email : listaDireccionesPara){
                //     if(para == ''){
                //         para = email;
                //     }else{
                //         para = para + ';' + email;
                //     }
                // }
                // consulta.addError('No está permitido el envío de emails a la dirección: ' + para + ' de correo electrónico, por favor elimínela para proceder al envío');
            }
        }

        // Si se encontró un error, agregarlo al registro correspondiente en la lista del trigger
        if (errorMessage) {
            for (SAC_Interaccion__c interaccion : listaConsultasSPV) {
                if (interaccion.Id == consulta.Id) {
                    interaccion.addError('No está permitido el envío de emails a la dirección: ' + emailsNoValidosEncontrados + ' de correo electrónico, por favor elimínela para proceder al envío');
                    break;
                }
            }
        }
    }

    public static void recuperarAdjuntos(Id idConsulta, String para, String emailCC, String emailCCO, TemplateWrapper plantillaEmail){

        List<ContentVersion> adjuntos = recuperaAdjuntos(idConsulta); 

        Set<Id> idContentDocument = new Set<Id>();

        for(ContentVersion cv : adjuntos){
            if(cv.SAC_Oculto__c == false){  // No recuperamos los adjuntos ocultos (SAC_Oculto__c = true), ya que estos no debemos mandarlos.
                idContentDocument.add(cv.ContentDocumentId);
            }
        }

        List<ContentDocument> documentos = new List<ContentDocument>();
        if(!idContentDocument.isEmpty()){
            if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }
            documentos = [SELECT Id FROM ContentDocument WHERE id IN: idContentDocument]; 
        }

        Set<Id> idAdjuntos = new Set<Id>();
        for(ContentDocument doc : documentos){
            idAdjuntos.add(doc.Id);
        }

        SPV_LCMP_GestionEmails.enviarEmail(idConsulta, para, emailCC, emailCCO, plantillaEmail.htmlValueTemplate, plantillaEmail.subjectTemplate, JSON.serialize(idAdjuntos), null);
    }

    public static ContentVersion[] recuperaAdjuntos(String id){

        Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
        List<Id> idsDocumentLink = new List<Id>();

        try {
        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: id AND ContentDocument.FileType != 'SNOTE'];  
        

            for(ContentDocumentLink recordCdL : cdL){

                idsDocumentLink.add(recordCdL.ContentDocumentId);
            }

            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink ORDER BY CreatedDate ASC];

            for(ContentVersion recordCv : cv){
                contentOculto.put(recordCv.id, recordCv.SAC_Oculto__c);
            }

            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentDocumentLink record : cdL){

                if(contentOculto.get(record.id) != null){

                    resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=contentOculto.get(record.id)));

                }else{resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=false));}
            }

            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**************************************************************************
     * Proposito: Crear TME al crear una Interaccion de tipo consulta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/ 
    // public static void insertarTME(List<SAC_Interaccion__c> listConsultas) {

    //     List<SAC_TMECaso__c> listaTMEs = new List<SAC_TMECaso__c>();
        
        // for(SAC_Interaccion__c consulta : listConsultas) {

        //     SAC_TMECaso__c tme = new SAC_TMECaso__c();
        //     tme.name = 'TMO Consulta';
        //     tme.RecordTypeId = RECTYPETMECONSULTA;
        //     tme.SAC_Interaccion__c= consulta.id;
        //     listaTMEs.add(tme);
        // }

        // SAC_DatabaseDML.insertListDML(listaTMEs, true);
    // }

    /**************************************************************************
     * Proposito: Añade al campo SAC_InedexedThreadId el compuesto con los ID acotados de la Organizacion y de la Consulta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/ 
    public static void crearThreadId(List<SAC_Interaccion__c> listConsultas) {

        List<SAC_Interaccion__C> consultasUpdatear = new List<SAC_Interaccion__C>();

        for(SAC_Interaccion__c consulta : listConsultas) {
             
            String threadId = SPV_Utils.creacionThreadID(consulta.Id);
            SAC_Interaccion__c consultaSPV = new SAC_Interaccion__c();
            consultaSPV.Id = consulta.Id;
            consultaSPV.SAC_IndexedThreadId__c = threadId;
            consultasUpdatear.add(consultaSPV);
        }  
        
        SPV_DatabaseDML.updateListDML(consultasUpdatear, true);
    }

    /**************************************************************************
     * Proposito: Rellenar los campos SAC_NIF__c y SAC_NombreReclamante__c en el before insert del trigger
     * para poder utilizar los campos en los email templates
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/  
    public static void rellenarNifYNombreReclamante(List<SAC_Interaccion__c> listNewInteraccion) {
        List<Id> listaIdsCasoRelacionado = new List<Id>();
        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_Reclamacion__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_Reclamacion__c);
            }
        }

        Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, AccountId, Account.name, Account.CC_Numero_Documento__c, CC_Oficina_Afectada_Lookup__c 
                                                    FROM Case 
                                                    WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :listaIdsCasoRelacionado]);

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (mapaCasos.containsKey(interaccion.SAC_Reclamacion__c)) {
                interaccion.SAC_DNI__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).Account.CC_Numero_Documento__c;
                interaccion.SAC_Reclamante__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).Account.Name;
            }
        }
    }  

    /**************************************************************************
     * Proposito: Rellenar el campo SAC_GrupoCreador__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/  
    public static void rellenarGrupoCreador (List<SAC_Interaccion__c> listNewInteraccion) {
        id userid = userinfo.getUserId();
        user userCreador = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =:userid LIMIT 1];
        List<String> idList = new List<String>();

        List<Id> listaIdsCasoRelacionado = new List<Id>();
        List<Id> listaIdsTareaRelacionada = new List<Id>();

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if (String.IsNotBlank(interaccion.SAC_Reclamacion__c)) {
                listaIdsCasoRelacionado.add(interaccion.SAC_Reclamacion__c);
            }else if(String.IsNotBlank(interaccion.SPV_TareaRelacionada__c)){
                listaIdsTareaRelacionada.add(interaccion.SPV_TareaRelacionada__c);
            }
        }

        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        Map<Id, SAC_Accion__c> mapaTareas = new Map<Id, SAC_Accion__c>();
        
        if(!listaIdsCasoRelacionado.isEmpty()){
            Map<Id, Case> mapaCasosInt = new Map<Id, Case>([SELECT Id, SEG_Grupo__c, RecordTypeId, SAC_PretensionPrincipal__r.OwnerId, OwnerId, SAC_GrupoLetrado__c
                                                        FROM Case WHERE RecordTypeId =:RECTYPERECLAMACION AND OwnerId =:userid AND Id IN :listaIdsCasoRelacionado]);

            mapaCasos = mapaCasosInt;
        }

        if(!listaIdsTareaRelacionada.isEmpty()){
            Map<Id, SAC_Accion__c> mapaTareasInt = new Map<Id, SAC_Accion__c>([SELECT Id, SAC_EquipoResponsable__c, OwnerId
                                                        FROM SAC_Accion__c WHERE RecordTypeId IN (:RECTYPEMAESTROTAREAS, :RECTYPEOTRASTAREAS) AND OwnerId =:userid AND Id IN :listaIdsTareaRelacionada]);
        
            mapaTareas = mapaTareasInt;
        }

        if(String.isnotBlank(userCreador.SAC_GruposPerteneciente__c)){
            idList = userCreador.SAC_GruposPerteneciente__c.split(';');
        }

        for (SAC_Interaccion__c interaccion : listNewInteraccion) {
            if(idList.size() == 1 && idList != null){
                interaccion.SAC_GrupoCreador__c = idList[0];
             
            }else if(idList.size() > 1 && idList != null){
                if (String.isNotBlank(interaccion.SAC_Reclamacion__c) && mapaCasos.containsKey(interaccion.SAC_Reclamacion__c)) {
                    if(mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId == userid && String.isnotBlank(mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId)){
                        interaccion.SAC_GrupoCreador__c = mapaCasos.get(interaccion.SAC_Reclamacion__c).SAC_GrupoLetrado__c;
                    }else if(mapaCasos.get(interaccion.SAC_Reclamacion__c).OwnerId == userid && String.isnotBlank(mapaCasos.get(interaccion.SAC_Reclamacion__c).OwnerId)){
                        interaccion.SAC_GrupoCreador__c =  mapaCasos.get(interaccion.SAC_Reclamacion__c).SEG_Grupo__c;
                    }else{
                        interaccion.SAC_GrupoCreador__c = idList[0];
                    }
                }else if (String.isNotBlank(interaccion.SPV_TareaRelacionada__c) && mapaTareas.containsKey(interaccion.SPV_TareaRelacionada__c)) {
                    if(mapaTareas.get(interaccion.SPV_TareaRelacionada__c).OwnerId == userid && String.isNotBlank(mapaTareas.get(interaccion.SPV_TareaRelacionada__c).OwnerId)){
                        interaccion.SAC_GrupoCreador__c =  mapaTareas.get(interaccion.SPV_TareaRelacionada__c).SAC_EquipoResponsable__c;
                    }else{
                        interaccion.SAC_GrupoCreador__c = idList[0];
                    }
                }
            }     
        }  
    }   

    /**************************************************************************
     * Proposito: Informar el valor SAC_Oficina__c de la consulta si es una consulta de tareas. Si es distinto de oficina, se limpia el campo SAC_Oficina__c
     * de la consulta (tanto consulta de reclamacion como de tarea). En el momento en el que trae la oficina para ponerla en la interacción, también trae
     * el email de la oficina para añadirlo al campo SAC_EmailOficina__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US975885      Raúl Santos    17/07/2024       Creación    
    **************************************************************************/  
    public static void informarOficinaConsulta(List<SAC_Interaccion__c> listNewInteraccion) {

        //Guardar ids de los grupos y las reclamaciones
        Set<Id> setIdsTareas = new Set<Id>();
        Set<Id> setIdsGrupos = new Set<Id>();

        for (SAC_Interaccion__c consulta : listNewInteraccion) {
            if(String.IsNotBlank(consulta.SPV_TareaRelacionada__c)){
                setIdsTareas.add(consulta.SPV_TareaRelacionada__c);
            }

            setIdsGrupos.add(consulta.SAC_GrupoColaborador__c);
        }

        //Buscar los casos padre
        if(Schema.sObjectType.SAC_Accion__c.isAccessible() && Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){
            List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();

            if(!setIdsTareas.isEmpty()){
                listaTareas = [SELECT Id, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c, SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__r.CC_Email__c FROM SAC_Accion__c WHERE RecordTypeId IN (:RECTYPEMAESTROTAREAS, :RECTYPEOTRASTAREAS) AND Id IN :setIdsTareas];   
            }
            
            List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT Id, SAC_DeveloperName__c, SAC_Externo__c, SAC_TienePropietario__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPGRUPOTAREAS AND Id IN :setIdsGrupos];

            if((!listaTareas.isEmpty()) && !listaGrupos.isEmpty()) {
                //Guardar resultado de las búsquedas en mapas
                Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);
                Map<Id, SAC_Accion__c> mapaTareas = new Map<Id, SAC_Accion__c>(listaTareas);

                //Poner la oficina de la reclamación en la consulta
                for (SAC_Interaccion__c consulta : listNewInteraccion) {
                    //Si el grupo de la consulta es oficina y la reclamación tiene una oficina informada, llevamos la oficina de la reclamación a la consulta
                    if (mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c == 'OFICINA') {
                        if(mapaTareas.containsKey(consulta.SPV_TareaRelacionada__c)){
                            if(String.isNotBlank(mapaTareas.get(consulta.SPV_TareaRelacionada__c).SAC_Oficina__c)){
                                consulta.SAC_Oficina__c = mapaTareas.get(consulta.SPV_TareaRelacionada__c).SAC_Oficina__c;
                                if(String.isNotBlank(mapaTareas.get(consulta.SPV_TareaRelacionada__c).SAC_Oficina__r.CC_Email__c)) {
                                    consulta.SAC_EmailOficina__c = mapaTareas.get(consulta.SPV_TareaRelacionada__c).SAC_Oficina__r.CC_Email__c;
                                }
                            }
                        }
                    //Si el grupo de la consulta es distinto al de la oficina y el campo oficina está informado, limpiamos el campo oficina de la interacción
                    } else if(mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c != 'OFICINA'
                    && String.isNotBlank(consulta.SAC_Oficina__c)) {
                        consulta.SAC_Oficina__c = null;
                        if (String.isNotBlank(consulta.SAC_EmailOficina__c)) {
                            consulta.SAC_EmailOficina__c = null;
                        }
                    }
                }
            }
        }
    }

    /*********************************************************************************************
     * Proposito: Método que detecta el cambio de oficina en una consulta y posteriormente informa el campo SAC_EmailOficina__c
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    public static void cambiarOficinaConsulta(List<SAC_Interaccion__c> listaConsultasSPV, Map<Id, SAC_Interaccion__c> mapOldObj){

        Set<Id> setIdsOficinas = new Set<Id>();
        
        for(SAC_Interaccion__c consulta : listaConsultasSPV){ 
            if(consulta.SAC_Oficina__c != mapOldObj.get(consulta.Id).SAC_Oficina__c){ 
                if (String.isNotBlank(consulta.SAC_Oficina__c)) {
                    setIdsOficinas.add(consulta.SAC_Oficina__c);
                } else {
                    //Si el campo oficina viene vacio, limpamos el email
                    consulta.SAC_EmailOficina__c = null;
                }
            }
        }

        //Recuperar oficinas
        List<Account> listaOfis = new List<Account>();
        if (!setIdsOficinas.isEmpty() && Schema.sObjectType.Account.isAccessible()) {
            listaOfis = [SELECT Id, CC_Email__c FROM Account WHERE Id IN :setIdsOficinas];
        }

        //Pasar listaOfis a mapa
        Map<Id, Account> mapaOfis = new Map<Id, Account>();
        for (Account ofi : listaOfis) {
            mapaOfis.put(ofi.Id, ofi);
        }

        //Añadir correos de las oficinas a las consultas
        if (!mapaOfis.isEmpty()) {
            for (SAC_Interaccion__c consulta : listaConsultasSPV) {
                if (String.isNotBlank(consulta.SAC_Oficina__c) && mapaOfis.containsKey(consulta.SAC_Oficina__c) && String.isNotBlank(mapaOfis.get(consulta.SAC_Oficina__c).CC_Email__c)) {
                    consulta.SAC_EmailOficina__c = mapaOfis.get(consulta.SAC_Oficina__c).CC_Email__c;
                }
            }   
        }
    }

    /*****************************************************************
    * Proposito: Controlar el lanzamiento de alertas de Interacciones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --             Raúl Santos    25/09/24         Creacion
    *****************************************************************/
    public static void lanzarAlertasInteraccion(List<SAC_Interaccion__c> listInteraccionesSPV, Map<Id, SAC_Interaccion__c> mapOldObj) {
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        List<SAC_Interaccion__c> listConsultasPteRespuesta = new List<SAC_Interaccion__c>();
        // List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
        Boolean hacerQuery = false;
        Set<Id> setIdsInteraccion = new Set<Id>();
        List<SAC_Interaccion__c> listaInteraccionSelect = new List<SAC_Interaccion__c>();
        Map<Id, SAC_Interaccion__c> mapEscalados = new Map<Id, SAC_Interaccion__c>();

        for (SAC_Interaccion__c interaccion : listInteraccionesSPV) {
            if (interaccion.RecordTypeId == RECTYPEESCALADO && interaccion.SAC_Estado__c == 'SPV_PendienteEnviar' && mapOldObj == null) {
                setIdsInteraccion.add(interaccion.Id);
                hacerQuery = true;
            }
        }

        if(hacerQuery && Schema.sObjectType.SAC_Interaccion__c.isAccessible()) {
            listaInteraccionSelect = [SELECT Id, RecordTypeId, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_Email__c, SAC_GrupoColaborador__r.SAC_Email2__c, SAC_GrupoColaborador__r.SAC_Email3__c
                                        FROM SAC_Interaccion__c
                                        WHERE RecordTypeId = :RECTYPEESCALADO AND Id IN :setIdsInteraccion];

            for (SAC_Interaccion__c interaccion : listaInteraccionSelect) {
                if(interaccion.RecordTypeId == RECTYPEESCALADO) {
                    mapEscalados.put(interaccion.Id, interaccion);
                }
            }
        }

        for (SAC_Interaccion__c interaccion : listInteraccionesSPV) {

            //Si es una consulta
            if (interaccion.RecordTypeId == RECTYPECONSULTA || interaccion.RecordTypeId == RECTYPECONSULTA_TAREA) {

                //Si la consulta pasa a estado 'Pendiente Respuesta'
                if (mapOldObj.get(interaccion.Id).SAC_Estado__c != interaccion.SAC_Estado__c && interaccion.SAC_Estado__c == 'SAC_PendienteRespuesta') {
                    //Añadirla a la lista para posteriormente llamar al método
                    listConsultasPteRespuesta.add(interaccion);
                }
                //Si la consulta ha sido respondida
                else if (mapOldObj.get(interaccion.id).SAC_Estado__c != interaccion.SAC_Estado__c && interaccion.SAC_Estado__c == 'SAC_Resuelta') {
                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_Reclamacion__c,
                                                                        'SPV_005',
                                                                        'La consulta ' + interaccion.Name + ' ha sido respondida. Ya puede revisarla.',
                                                                        interaccion.CreatedById,
                                                                        '',
                                                                        '',
                                                                        interaccion.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                        wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                    
                }
            }else if(interaccion.RecordTypeId == RECTYPEESCALADO) { //Si es un escalado
                //Si el escalado ha cambiado de propietario
                if(interaccion.OwnerId != null && (mapOldObj == null || interaccion.OwnerId != mapOldObj.get(interaccion.id).OwnerId)) {
                    //Si el escalado ha cambiado de propietario
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_CasoEscalado__c,
                                                                        'SPV_029',
                                                                        'El escalado ' + interaccion.Name + ' ha sido asignado a un nuevo propietario. Ya puede revisarlo.',
                                                                        interaccion.OwnerId,
                                                                        '',
                                                                        '',
                                                                        interaccion.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                        wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                //Si es un escalado que se acaba de crear
                if(interaccion.SAC_Estado__c == 'SPV_PendienteEnviar' && mapOldObj == null && mapEscalados.containsKey(interaccion.Id)){

                    // Obtener el objeto SAC_Interaccion__c del mapa usando la clave interaccion.Id
                    SAC_Interaccion__c escalado = mapEscalados.get(interaccion.Id);

                    List<String> listaEmails = new List<String>();

                    if (escalado.SAC_GrupoColaborador__r.SAC_Email__c != null) {
                        listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email__c);
                    }
                    if (escalado.SAC_GrupoColaborador__r.SAC_Email2__c != null) {
                        listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email2__c);
                    }
                    if (escalado.SAC_GrupoColaborador__r.SAC_Email3__c != null) {
                        listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email3__c);
                    }

                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_CasoEscalado__c,
                                                                        'SPV_006',
                                                                        'El escalado ' + interaccion.Name + ' ha sido creado. Ya puede revisarlo.',
                                                                        null,
                                                                        '',
                                                                        '',
                                                                        interaccion.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                        wrapAlerta.listaEmailsGrupo = listaEmails;
                                                                        wrapAlerta.idGrupoColaborador = escalado.SAC_GrupoColaborador__c;
                                                                        wrapAlerta.proyecto = 'SPV';
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                else if(mapOldObj != null){
                    //Si el escalado ha sido respondido
                    if(mapOldObj.get(interaccion.Id).SPV_TipoRespuesta__c != interaccion.SPV_TipoRespuesta__c){
                        //Preparar una alerta
                        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(interaccion.SAC_CasoEscalado__c,
                                                                            'SPV_007',
                                                                            'El escalado ' + interaccion.Name + ' ha sido atendido. Ya puede revisarlo.',
                                                                            interaccion.CreatedById,
                                                                            '',
                                                                            '',
                                                                            interaccion.Id);
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + interaccion.Id;
                                                                            wrapAlerta.proyecto = 'SPV';
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                }
            }
        }

        //Si tenemos consultas pendiente respuesta, debemos crear el pending process para la ejecucion de sus alertas
        if (!listConsultasPteRespuesta.isEmpty()) {
            scheduleAlertaConsulta24h(listConsultasPteRespuesta);
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    /**************************************************************************
     * Proposito: Crea un registro de pendingProcess para lanzar una clase schedulable al cabo de 24 horas.
     * La clase schedulable creará una alerta si la consulta sigue en estado pendiente de asignar.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --             Raúl Santos    25/09/24         Creacion
    **************************************************************************/  
    public static void scheduleAlertaConsulta24h(List<SAC_Interaccion__c> listConsultasPteRespuesta) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (SAC_Interaccion__c consulta : listConsultasPteRespuesta) {
            CBK_SCH_PendingProcess__c pendingProcessConsulta = new CBK_SCH_PendingProcess__c();
            pendingProcessConsulta.recordId__c = consulta.Id;
            // pendingProcessConsulta.Schedule_Time__c = system.now().addHours(24);
            pendingProcessConsulta.className__c = 'SAC_SchedulableAlertas';

            //Si es una consulta de oficina la primera alerta es a las 24 horas. Sino, es a las 48 horas.
            if(String.isNotBlank(consulta.SAC_Oficina__c)){
                pendingProcessConsulta.Schedule_Time__c = system.now().addHours(24);
                pendingProcessConsulta.Param1__c = '24';
            }else{
                pendingProcessConsulta.Schedule_Time__c = system.now().addHours(48);
                pendingProcessConsulta.Param1__c = '48';
            }

            listaPendingProcess.add(pendingProcessConsulta);
        }

        if (!listaPendingProcess.isEmpty()) {
            // if (!Schema.sObjectType.CBK_SCH_PendingProcess__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
            SPV_DatabaseDML.insertListDML(listaPendingProcess, true);
        }
    } 

    public class TemplateWrapper{

        @AuraEnabled public String idTemplate{get; set;}
        @AuraEnabled public String nameTemplate{get; set;}
        @AuraEnabled public String subjectTemplate{get; set;}
        @AuraEnabled public String htmlValueTemplate{get; set;}
        @AuraEnabled public String paraTemplate{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, String paraTemplate){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.paraTemplate = paraTemplate;
        }
    }
}