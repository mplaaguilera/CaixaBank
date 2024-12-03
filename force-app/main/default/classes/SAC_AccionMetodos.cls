/*****************************************************************
 * Name: SAC_AccionMetodos
 * Copyright © 2021  CaixaBank
 **************************************************************************
 * Proposito:  Metodos para las acciones masivas
 *             desde la Lista de vista del objeto SAC_Accion__c
 * 			Esta clase se testea desde SAC_AccionVF_Test
 **************************************************************************
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0       204745 y US204756    Marcela Neira   13/07/21        Creación
 * 1.1            US344870        Marcela Neira   04/03/22      Modificación implementación de las Business Hours
*****************************************************************/
public without sharing class SAC_AccionMetodos {

    private static Set<String> objetos = new Set<String>{'Task', 'SAC_Accion__c', 'Case', 'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEREGISTRO = mapRTsObjects.get('Task').get('SAC_Registro').getRecordTypeId(); 
    private static final Id RECTYPEOTRATAREA = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREA = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();   
    private static final Id RECTYPEGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();  
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId(); 


    /**
    Wrapper para retornar datos de los adjuntos de las tareas de GGH
    */
    public class WrapperAdjuntoGGH{
        public Id id{get; set;}
        public String title{get; set;}
        public Blob versionData{get; set;}
		public String fileType{get; set;}
    }

     /*****************************************************************
     * Proposito: Comprobar si el Id que se está pasando es la cola genérica
     *********************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
    *****************************************************************/
    public static Boolean esLaCola(id idPropietario){
        Boolean respuesta= false;        
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        if(idPropietario == cola[0].id){  //Cuando se hace un "Devolver a la cola"
            respuesta = true;
        }
        return respuesta;
    }
   /*****************************************************************
     * Proposito: Comprobar si la tarea está viva
     * **************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
    *****************************************************************/
    public static Boolean laTareaEstaViva(SAC_Accion__c tarea){

        Boolean respuesta = true;

        if(tarea.SAC_Estado__c == 'SAC_Finalizada' || tarea.SAC_Estado__c == 'SAC_FinalizadaIncompleta'){
            respuesta = false;             
        }
        return respuesta;
    }

     /*****************************************************************
     * Proposito: Comprobar usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
    *****************************************************************/

    public static Map<Id,String> usarioMismoGrupoTarea(Set<Id> gruposResponsables, Id idPropietario){

        Map<Id,String> mapaGrupos = new Map<Id,String>();
        for (Id ideGrupoResponsable : gruposResponsables) {
            mapaGrupos.put(ideGrupoResponsable, null);
        }
        List<CC_Grupo_Colaborador_Contact__c> 
        colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
                                WHERE CC_Grupo_Colaborador__c IN : gruposResponsables
                                AND CC_Usuario__c=:idPropietario AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion'];
                                 

        if(!colabContact.isEmpty()){  //Montamos el mapa para luego comprobar 
            for(CC_Grupo_Colaborador_Contact__c gcc : colabContact){
                mapaGrupos.put(gcc.CC_Grupo_Colaborador__c, gcc.CC_Grupo_Colaborador__c);
            }
        } 

        return mapaGrupos;
    }

    /*****************************************************************
     * Proposito: Comprobar usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea y es adm resolutor
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                          Daniel Benito   12/01/22      Creación
    *****************************************************************/

    public static Map<Id,String> usarioMismoGrupoTareaAdm(Set<Id> gruposResponsables, Id idPropietario){

        Map<Id,String> mapaGrupos = new Map<Id,String>();
        List<CC_Grupo_Colaborador_Contact__c> 
        colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c, SAC_Administrador__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
                                WHERE CC_Grupo_Colaborador__c IN : gruposResponsables
                                AND CC_Usuario__c=:idPropietario AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' AND SAC_Administrador__c = true];
                                 

        if(!colabContact.isEmpty()){  //Montamos el mapa para luego comprobar 
            for(CC_Grupo_Colaborador_Contact__c gcc : colabContact){
                mapaGrupos.put(gcc.CC_Grupo_Colaborador__c, gcc.CC_Grupo_Colaborador__c);
            }
        } 

        return mapaGrupos;
    }   

    /**************************************************************************
     * Proposito: Finalizar la tarea usamos future para dejar trazabilidad
     ***************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
    *****************************************************************************/

    @future
    public static void finalizarTareaFuture(List<Id> idsTareas, Id idUsuario, String observaciones){

        List<SAC_Accion__c> listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_FechaVencimientoProrroga__c, SAC_Comentarios2__c
                                FROM SAC_Accion__c 
                                WHERE id IN: idsTareas];
                                
        for (SAC_Accion__c tarea : listaTareas) {
            tarea.ownerId = idUsuario;
            tarea.SAC_Estado__c = 'SAC_Finalizada';
            if(String.isNotBlank(tarea.SAC_Comentarios2__c)) {
                tarea.SAC_Comentarios2__c = tarea.SAC_Comentarios2__c + observaciones; 
            } else {
                tarea.SAC_Comentarios2__c = observaciones; 
            }      
        }
        finalizarTMEs(listaTareas);

        Database.update(listaTareas);
    }

    /**************************************************************************
     * Proposito: Cuando se finalizan las tareas se deben finalizar los TMEs
     ***************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
    *****************************************************************************/
    public static void finalizarTMEs(List<SAC_Accion__c> listaTareas){

        List<SAC_TMECaso__c> tmesTarea = [SELECT ID, SAC_Accion__c FROM SAC_TMECaso__c WHERE SAC_Accion__c =: listaTareas];
        
        for(SAC_TMECaso__c tme : tmesTarea){
            tme.SAC_FechaFin__c = Datetime.Now();
        }
        
        Database.update(tmesTarea);
    }
     /**************************************************************************
     * Proposito: Prorrogar la tarea a nivel masivo donde se coge el valor 
     *            establecido dentro de la tarea para prorrogar
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
     * 1.1            US344870        Marcela Neira   04/03/22      Modificación implementación de las Business Hours
    *****************************************************************************/

    public static void prorrogarTarea(List<SAC_Accion__c> listaTareas){     
        Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SAC_Calendario'].id;    

       for (SAC_Accion__c tarea : listaTareas) {

            if((tarea.SAC_FechaVencimientoInicial__c + Integer.valueOf(tarea.SAC_Prorroga__c)) <= Date.today()  && tarea.SAC_FechaVencimientoProrroga__c == null){
                //tarea.SAC_FechaVencimientoProrroga__c = Date.today() + Integer.valueOf(tarea.SAC_Prorroga__c);
                tarea.SAC_FechaVencimientoProrroga__c = BusinessHours.add(ideBH, Date.today() , cacularMilisegundos(Integer.valueOf(tarea.SAC_Prorroga__c)+1)).date();                              

            }else{
                if(tarea.SAC_FechaVencimientoProrroga__c == null){
                    tarea.SAC_FechaVencimientoProrroga__c = BusinessHours.add(ideBH, tarea.SAC_FechaVencimientoInicial__c, cacularMilisegundos(Integer.valueOf(tarea.SAC_Prorroga__c)+1)).date();
                }else{
                    tarea.SAC_FechaVencimientoProrroga__c = BusinessHours.add(ideBH, tarea.SAC_FechaVencimientoProrroga__c, cacularMilisegundos(Integer.valueOf(tarea.SAC_Prorroga__c)+1)).date();                
                }
            }       
       }
       
        
       Database.update(listaTareas);
        
    }
    /**************************************************************************
     * Proposito: Prorrogar la tarea a nivel tarea y se crea un registro de Task
     *              en la reclamación para dejar trazabilidad.
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
     * 1.1            DE71512         Raúl Santos     31/01/23      Modificación: No permitir prorrogar a una fecha anterior a la actual
    *****************************************************************************/

    public static Task prorrogarTarea(SAC_Accion__c accionOld, SAC_Accion__c accionNew){
        
        Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SAC_Calendario'].id;
        Date fechaHastaQueSePuedeProrrogar = null;
		
        if(accionNew.SAC_Prorroga__c != null){
        	if(accionOld.SAC_FechaVencimientoProrroga__c == null){
                fechaHastaQueSePuedeProrrogar = BusinessHours.add(ideBH, accionNew.SAC_FechaVencimientoInicial__c, cacularMilisegundos(accionNew.SAC_Prorroga__c+1)).date();            
            }else{
                fechaHastaQueSePuedeProrrogar = BusinessHours.add(ideBH, accionOld.SAC_FechaVencimientoProrroga__c, cacularMilisegundos(accionNew.SAC_Prorroga__c+1)).date();            
            }
        }
        
        if(accionNew.SAC_FechaVencimientoProrroga__c > fechaHastaQueSePuedeProrrogar  ||  accionNew.SAC_FechaVencimientoProrroga__c < Date.today()){
            accionNew.adderror('La fecha de vencimiento de prórroga no es válida.');
        }else{
            /**El valor de SAC_FechaVencimientoProrroga__c es tipo Date para poder comprobar que el día que se elige no es festivo debemos utilizar
             * BusinessHours.isWithin pero el segundo parametro evalua también el horario, pasando solo la SAC_FechaVencimientoProrroga__c coge de
             * hora 00:00:00 y el método nos dice que no entra en el horario laboral por eso se añaden 12 horas para que compruebe en un horario laboral 
             */
            Datetime fechaprorroga = accionNew.SAC_FechaVencimientoProrroga__c;
            if(BusinessHours.isWithin(ideBH, fechaprorroga.addHours(12))){
                accionNew.SAC_FechaSolitudProrroga__c = Date.today();
                accionNew.SAC_ProrrogaCounter__c = accionNew.SAC_ProrrogaCounter__c+1; 
                accionNew.SAC_ProrrogaTareaCheck__c = true;      
                
            }else{
                accionNew.adderror('La fecha de vencimiento de prórroga no es válida compruebe que no sea un día festivo.');
            }
            
        }

        Task tarea = new Task();
        tarea.RecordTypeId = RECTYPEREGISTRO;
        tarea.WhatId = accionNew.SAC_Reclamacion__c;
        tarea.OwnerId = UserInfo.getUserId();
        tarea.Status = 'Open';
        tarea.Subject = 'Solicitud de prórroga en tarea: ' + accionNew.name;

        return tarea;
    }

    /**************************************************************************
     * Proposito: Comprobar si todas las tareas de la reclamación estan finalizadas
     * Modificación 1.1: Optimizar el código eliminando querys dentro de bucles y añadir nueva lógica necesaria
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
     * 1.1            DE96857         Raúl Santos     30/05/24      Modificación.
    *****************************************************************************/
    public static void comprobarTareasFinalizadas(Map<Id, List<SAC_Accion__c>> reclamacionTareasMap){

        Set<Id> reclamacionIds = new Set<Id>(reclamacionTareasMap.keySet());

        Set<Id> tareasEnMapaIds = new Set<Id>();
        for (List<SAC_Accion__c> tareasEnMapa : reclamacionTareasMap.values()) {
            for (SAC_Accion__c tareaEnMapa : tareasEnMapa) {
                tareasEnMapaIds.add(tareaEnMapa.Id);
            }
        }

        //Recupero todas las tareas de la reclamación, SIN las tareas que han sido finalizadas
        List<SAC_Accion__c> tareas = [SELECT Id, SAC_Reclamacion__c, SAC_Estado__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEMAESTROTAREA OR RecordTypeId = :RECTYPEOTRATAREA) AND SAC_Reclamacion__c IN :reclamacionIds AND Id NOT IN :tareasEnMapaIds];

        //Crear una lista para almacenar todas las tareas combinadas
        List<SAC_Accion__c> todasLasTareas = new List<SAC_Accion__c>();

        // Añadir las tareas del mapa a la lista
        for (List<SAC_Accion__c> tareasEnMapa : reclamacionTareasMap.values()) {
            todasLasTareas.addAll(tareasEnMapa);
        }

        //Añadir las tareas de la consulta a la lista
        todasLasTareas.addAll(tareas);
        
        List<Id> recParaCerrar = new List<Id>();

        //Recorreos las reclamaciones, y dentro de estas recorremos las tareas, si la tarea es de la reclamación actual comprueba si no está finalizada.
        //Si todas las tareas de una reclamación están finalizadas, llamamos al método que cierra las reclamaciones
        for (Id reclamacionId : reclamacionTareasMap.keySet()) {

            Boolean todasFinalizadas = true;
            
            for (SAC_Accion__c tarea : todasLasTareas) {
                if(tarea.SAC_Reclamacion__c == reclamacionId){
                    if (tarea.SAC_Estado__c != 'SAC_Finalizada' && tarea.SAC_Estado__c != 'SAC_FinalizadaIncompleta' && tarea.SAC_Estado__c != 'SAC_Descartada') {
                        todasFinalizadas = false;
                        break;
                    }
                }
            }
        
            if (todasFinalizadas) {
                recParaCerrar.add(reclamacionId);
            }
        }

        if(!recParaCerrar.isEmpty()){
            cerrarReclamaciones(recParaCerrar);
        }
    }

    /**************************************************************************
     * Proposito: Cerrar las reclamaciones
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
    *****************************************************************************/
    public static void cerrarReclamaciones(List<Id> reclamacionesParaCerrar){
        List<Case> listaReclamaciones = [SELECT id, status FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN: reclamacionesParaCerrar];
        List<Case> casosUpdate = new List<Case>();

        for(Case reclamacion: listaReclamaciones){
            if(reclamacion.Status == 'SAC_004'){
                reclamacion.Status='Cerrado';
                reclamacion.SAC_StatusAuxiliar__c = reclamacion.status;
                casosUpdate.add(reclamacion);
            }
        }

        if(!casosUpdate.isEmpty()){            
            Database.update(casosUpdate);
        }
        
    }

    /*****************************************************************
     * Proposito: Devolver la tarea para que vuelva a estar pendiente de asignar
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745       Marcela Neira  12/07/21     Creación
    *****************************************************************/

    static public void devolverTareas(List<SAC_Accion__c> listaTareas){
        
        //SAC_Accion__c tarea = recuperarTarea(tareaId);
		List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        
        if(cola.size() == 1){ 
            for(SAC_Accion__c tarea : listaTareas){
                
                if(tarea.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'GGH'){
                    tarea.OwnerId = cola[0].id;
                }else{
                    tarea.OwnerId = cola[0].id;
                    tarea.SAC_Estado__c='SAC_PendienteAsignar';
                }
            }            
        }
		if(Schema.sObjectType.Case.isUpdateable()){   
			Database.update(listaTareas);
		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }

    /*****************************************************************
     * Proposito: calcula los milisegundos párametro necesario para calcular las Business Hours
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US344870     Marcela Neira    04/03/2022     creación
    *****************************************************************/
    public static Long cacularMilisegundos(Decimal cantidad) {
        //10 por las horas definidas en las Business Hours de SAC_Calendario
        //return  Long.valueOf(String.valueof(cantidad*10*3600000));

        //Se cambia a 24 horas por petición de negocio
        return  Long.valueOf(String.valueof(cantidad*24*3600000));
    }

    /*****************************************************************
     * Proposito: Comprobar que cada tarea que se crea pertenece al owner de la reclamación
     * o a la pretensión desde la que se crea.
     * Además, comprueba que no se pueda crear una accion cuando la reclamación o la
     * pretensión está en estado cerrada si la reclamacion no está en estado de ejecución.
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   24/01/22     Creación
     * 1.1            US577617         Raúl Santos    25/05/2023   Modificación: Saltar validación de solo poder crear tareas si eres el propietario de la reclamación.
     *                                                                           Para poder crear tareas si el usuario es miembro de los grupos responsables de las tareas creadas en la reclamación/pretensión
    *****************************************************************/
    public static void accionComprobarOwnerYStatus(List<SAC_Accion__c> listNewAccion) {

        List<Id> listaIdsPretensiones = new List<Id>();
        List<Id> listaIdsReclamaciones = new List<Id>();
        List<Id> listaIdsAcciones = new List<Id>();
        List<SAC_Accion__c> listaTareaRelacionada = new List<SAC_Accion__c>();
        Map<Id,Boolean> mapaPerteneceGrupo = new Map<Id, Boolean>();

        for (SAC_Accion__c accion : listNewAccion) {
            listaIdsAcciones.add(accion.SAC_Reclamacion__c);
        }

        //Recuperamos las tareas asociadas a la reclamacion/es que tenga la tarea/s que se crean
        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
        List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c, SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEMAESTROTAREA OR RecordTypeId = :RECTYPEOTRATAREA) AND SAC_Reclamacion__c IN :listaIdsAcciones];

        //LLenamos el mapa por id de la reclamación junto a la lista de tareas de dicha reclamación
        Map<Id,List<SAC_Accion__c>> mapTareasCaso = new Map<Id,List<SAC_Accion__c>>();
        for (SAC_Accion__c accion : acciones) {
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                if(mapTareasCaso.containsKey(accion.SAC_Pretension__c)){
                    mapTareasCaso.get(accion.SAC_Pretension__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Pretension__c, accionesAux);
                }
            }else{
                if(mapTareasCaso.containsKey(accion.SAC_Reclamacion__c)){
                    mapTareasCaso.get(accion.SAC_Reclamacion__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Reclamacion__c, accionesAux);
                }
            }
        }
                
        //Recuperamos los grupos a los que pertenece el usuario que crea la tarea
        if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible() || !Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar los grupos a los que pertenece su usuario' ); }
        List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT id, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =:  UserInfo.getUserId())];

        for (SAC_Accion__c accion : listNewAccion) {

            // US577617 -> Para las tareas que se insertan desde la reclamación/pretensión (el usuario no es propietario de la reclamación, pero que es miembro de los grupos responsables de las tareas creadas en la reclamación/pretensión)
            //             el usuario ha podido pulsar el botón de crear nueva tarea, y debe poder crear cualquier tipo de tarea.
            //             Finalidad: Saltar la validación de solo poder crear tareas si eres el propietario de la reclamación/pretensión.

            if (String.isNotBlank(accion.SAC_Pretension__c)) {
                listaIdsPretensiones.add(accion.SAC_Pretension__c);

                // US577617
                Boolean crearTarea = false;
                crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, accion, listaGrupos);

                if(crearTarea){
                    mapaPerteneceGrupo = saltarValidacionOwner(mapTareasCaso, accion);
                } 
            } else if (String.isNotBlank(accion.SAC_Reclamacion__c)) {
                listaIdsReclamaciones.add(accion.SAC_Reclamacion__c);

                // US577617
                Boolean crearTarea = false;
                crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, accion, listaGrupos);

                if(crearTarea){
                    mapaPerteneceGrupo = saltarValidacionOwner(mapTareasCaso, accion);
                }
            } else if(String.isBlank(accion.SAC_Reclamacion__c)){ //US662800 no permitir crear tareas sin estar relacionadas con una reclamación/pretensión
                listaTareaRelacionada.add(accion);
            }
        }

        if (!listaIdsPretensiones.isEmpty() || !listaIdsReclamaciones.isEmpty()) {
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, RecordTypeId, OwnerId, Status, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId, SAC_Reclamacion__r.Status, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId FROM Case WHERE Id IN :listaIdsPretensiones OR Id IN :listaIdsReclamaciones]);

            for (SAC_Accion__c accion : listNewAccion) {
                if (mapaCasos.containsKey(accion.SAC_Pretension__c) && mapaCasos.get(accion.SAC_Pretension__c).OwnerId != UserInfo.getUserId() && mapaCasos.get(accion.SAC_Pretension__c).SAC_Reclamacion__r.OwnerId != UserInfo.getUserId() && (mapaPerteneceGrupo.isEmpty() && mapaPerteneceGrupo.get(accion.SAC_Reclamacion__c) == false)) {
                    accion.addError('No puedes crear una tarea si no eres el dueño de la pretensión o de la reclamación');
                }else if (mapaCasos.containsKey(accion.SAC_Reclamacion__c) && String.isBlank(accion.SAC_Pretension__c) && (mapaCasos.get(accion.SAC_Reclamacion__c).OwnerId != UserInfo.getUserId() && mapaCasos.get(accion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId != UserInfo.getUserId() && (mapaPerteneceGrupo.isEmpty() && mapaPerteneceGrupo.get(accion.SAC_Reclamacion__c) == false))) {
                    accion.addError('No puedes crear una tarea si no eres el dueño de la reclamación o de la pretensión');
                }
                if (mapaCasos.containsKey(accion.SAC_Pretension__c) && ((mapaCasos.get(accion.SAC_Pretension__c).Status == 'Cerrado' || mapaCasos.get(accion.SAC_Pretension__c).Status == 'SAC_009') && mapaCasos.get(accion.SAC_Pretension__c).SAC_Reclamacion__r.Status == 'Cerrado')) {
                    accion.addError('No puedes crear una tarea si la reclamación ya está cerrada');
                } /*else if (mapaCasos.containsKey(accion.SAC_Reclamacion__c) && String.isBlank(accion.SAC_Pretension__c) && 
                          (mapaCasos.get(accion.SAC_Reclamacion__c).Status == 'Cerrado' || mapaCasos.get(accion.SAC_Reclamacion__c).Status == 'SAC_009' || mapaCasos.get(accion.SAC_Reclamacion__c).Status == 'SAC_004')) {
                    accion.addError('No puedes crear una tarea si la reclamación ya está cerrada');
                }
                */
            }
        }

        if(!listaTareaRelacionada.isEmpty()){
            for (SAC_Accion__c accion : listNewAccion) {
                accion.addError('No puede crear una tarea desde aquí. Si desea crear una tarea debe hacerlo desde la reclamación/pretensión');
            }
        }
    }

    /*****************************************************************
     * Proposito: Asignar una fecha de vencimiento inicial teniendo en cuenta las
     *              BusinessHours
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US344870      Marcela Neira    03/03/2022     creación
    *****************************************************************/
    public static void calcularFechaVencimientoInicial(List<SAC_Accion__c> listaAcciones) {
        Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SAC_Calendario'].id; 
        for (SAC_Accion__c accion : listaAcciones) {            
            if(accion.SAC_PlazoMaximo__c != null){
                if(accion.CreatedDate ==null){//Viene del BI
                    accion.SAC_FechaVencimientoInicial__c = BusinessHours.add(ideBH, System.now(), cacularMilisegundos(accion.SAC_PlazoMaximo__c)).date();
                }else{
                    accion.SAC_FechaVencimientoInicial__c = BusinessHours.add(ideBH, accion.CreatedDate, cacularMilisegundos(accion.SAC_PlazoMaximo__c)).date();
                }                
            }
        }
        
    }

    

    /*****************************************************************
     * Proposito: rellenar el campo de Fecha de ejecución cuando se finaliza la tarea
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US308680     Daniel Benito    09/03/2022     creación
    *****************************************************************/

    public static void rellenarFechaEjecucion(List<SAC_Accion__c> listNewAccion){

        Integer cambio = 15;

        for(SAC_Accion__c accion : listNewAccion){
            if(accion.SAC_FechaDeEjecucion__c == null){
                accion.SAC_FechaDeEjecucion__c = DateTime.now();
            } 
        }

    }
    /**************************************************************************
     * Proposito: Tomar en propiedad las tareas y cambiar el estado a En gestión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
     * 1.1            DE77526         Raúl Santos     31/05/23      Modificación: controlar el estado de las tareas GGH
    *****************************************************************************/
    public static void tomarPropiedadMasivo(List<SAC_Accion__c> listaTareas, Id idUsuario){

        for (SAC_Accion__c tarea : listaTareas) {

            if(tarea.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'GGH'){
                tarea.ownerId = idUsuario;
                //tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
            }else{
                tarea.ownerId = idUsuario;
                tarea.SAC_Estado__c = 'SAC_EnGestion';
            }
        }
        Database.update(listaTareas);
    }


    /**************************************************************************
     * Proposito: Crear una tarea con la reclamación cerrada, reabre esta a estado de ejecución
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US383820       Daniel Benito   07/06/22      Creación
    *****************************************************************************/
    public static void tareaReclamacionCerrada(List<SAC_Accion__c> listNewAccion){

        List<Id> listaIdsReclamaciones = new List<Id>();
        List<Id> listaIdsActualizar = new List<Id>();
        List<Case> listaReclamacionesUpdate = new List<Case>();

        for (SAC_Accion__c accion : listNewAccion) {
            if (String.isNotBlank(accion.SAC_Reclamacion__c)) {
                listaIdsReclamaciones.add(accion.SAC_Reclamacion__c);
            }
        }

        if(!listaIdsReclamaciones.isEmpty()){
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, RecordTypeId, OwnerId, Status FROM Case WHERE Id IN :listaIdsReclamaciones]);
            for (SAC_Accion__c accion : listNewAccion) {

                if (mapaCasos.containsKey(accion.SAC_Reclamacion__c) && (mapaCasos.get(accion.SAC_Reclamacion__c).Status == 'Cerrado')) {
                   
                    listaIdsActualizar.add(accion.SAC_Reclamacion__c);
                }
            }

            listaReclamacionesUpdate = [SELECT id,Status, SAC_StatusAuxiliar__c FROM CASE WHERE id IN: listaIdsActualizar AND RecordType.DeveloperName = 'SAC_Reclamacion'];

            if(!listaReclamacionesUpdate.isEmpty()){

                for(Case caso : listaReclamacionesUpdate){

                    caso.Status = 'SAC_004';
                    caso.SAC_StatusAuxiliar__c = 'SAC_004';
                }

                Database.update(listaReclamacionesUpdate);
            }
        }
    }

    /**************************************************************************
     * Proposito: Método para la implementación del WS de GGH
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                           Daniel Benito   23/06/22      Creación
    *****************************************************************************/
    @Future(callout=true)
    public static void envioGGH(String stringNewAccion){

        List<SAC_Accion__c> listNewAccion = (List<SAC_Accion__c>)JSON.deserialize(stringNewAccion, List<SAC_Accion__c>.class);
        Map<Id,SAC_Accion__c> mapaTareas = new Map<Id,SAC_Accion__c>(listNewAccion);
        Map<Id, List<WrapperAdjuntoGGH>> mapaAccionDocumentos = new Map<Id, List<WrapperAdjuntoGGH>>();
        List<SAC_Accion__c> listaAccionesConError = new List<SAC_Accion__c>();
        Set<Id> setIdsAccionesGGH = new Set<Id>();

        User usuario = [SELECT Id, FederationIdentifier FROM User WHERE id =: UserInfo.getUserId() LIMIT 1 ];
        String usuarioAlta = usuario.FederationIdentifier;

        Map<Id,SAC_Accion__c> mapaAccionesGGH = new Map<Id,SAC_Accion__c>(
                                                [SELECT Id, RecordTypeId, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c, SAC_Reclamacion__r.CC_SuppliedNIF__c 
                                                FROM SAC_Accion__c 
                                                WHERE Id IN :mapaTareas.keySet() 
                                                AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH']);

        if(!mapaAccionesGGH.values().isEmpty()){
            //Pasar Ids a Set para posteriormente buscar sus contentDocumentLink
            for (SAC_Accion__c accionGGH : mapaAccionesGGH.values()) {
                setIdsAccionesGGH.add(accionGGH.Id);
            }
        }

        //Si el set no está vacío, pasamos a buscar los ficheros adjuntos de las tareas
        Boolean heapSizeSuperado = false;
        if (!setIdsAccionesGGH.isEmpty()) {
            //Primero hay que comprobar que no se excede el heap size limit recuperando el peso de cada fichero
            heapSizeSuperado = comprobarContentSize(setIdsAccionesGGH);
            //Si el heap size no se ha superado, recuperamos los documentos
            if (!heapSizeSuperado) {
                mapaAccionDocumentos = recuperarAdjuntosGGH(setIdsAccionesGGH);
            }
        }

        Id profileId=userinfo.getProfileId();
        String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;

        for (SAC_Accion__c tareaGGH : mapaAccionesGGH.values()) {
            if (heapSizeSuperado) {
                tareaGGH.SAC_Error__c = 'Ha superado el límite de 12 Megabytes en archivos adjuntos. Inténtelo de nuevo o reduzca el peso total de ficheros adjuntos';
                tareaGGH.SAC_Estado__c = 'SAC_PendienteEnviar';
                listaAccionesConError.add(tareaGGH);
            } else {
                String impNotaria;
                String impGestoria;
                String impRegistro;
                String impTasacion;

                if(mapaTareas.containsKey(tareaGGH.Id)){
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoNotaria__c)){
                        impNotaria = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoNotaria__c);
                    }
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoGestoria__c)){
                        impGestoria = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoGestoria__c);
                    }
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoRegistro__c)){
                        impRegistro = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoRegistros__c);
                    }
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoTasacion__c)){
                        impTasacion = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoTasacion__c);
                    }
                }

                List<SAC_WS_GGH_Callout_RQ.Documentacion> documentacionWrapper = new List<SAC_WS_GGH_Callout_RQ.Documentacion>();
                List<WrapperAdjuntoGGH> contentAuxiliar = new List<WrapperAdjuntoGGH>();
            
                if(!mapaAccionDocumentos.isEmpty()){
                    contentAuxiliar = mapaAccionDocumentos.get(tareaGGH.id);
                }
                //Variable para controlar el total de bytes de todos los archivos de esta tarea
                for(WrapperAdjuntoGGH cv : contentAuxiliar){
                    String content = EncodingUtil.base64Encode(cv.versionData);

                    SAC_WS_GGH_Callout_RQ.Documentacion documentoWrapper = new SAC_WS_GGH_Callout_RQ.Documentacion(content, cv.title + '.' + cv.fileType);
                    documentacionWrapper.add(documentoWrapper);
                }

                //Quitar etiquetas html del campo comentarios en caso de que este relleno
                String comentarios = '';
                if (String.isNotBlank(mapaTareas.get(tareaGGH.Id).SAC_Comentarios__c)) {
                    comentarios = mapaTareas.get(tareaGGH.Id).SAC_Comentarios__c.stripHtmlTags();
                }
                SAC_WS_GGH_Callout_RQ.Reclamacion reclamacionWrapper = new SAC_WS_GGH_Callout_RQ.Reclamacion(
                    mapaTareas.get(tareaGGH.Id).SAC_Pretension__c,
                    tareaGGH.Id,
                    mapaAccionesGGH.get(tareaGGH.Id).SAC_Reclamacion__r.CC_SuppliedNIF__c,
                    impNotaria, impGestoria, impRegistro, impTasacion,
                    mapaTareas.get(tareaGGH.Id).SAC_NumeroContrato__c,
                    mapaTareas.get(tareaGGH.Id).SAC_NCuentaAbono__c,
                    comentarios);
                
                SAC_WS_GGH_Callout_RQ.GGHRequest gghResquesWrapper = new SAC_WS_GGH_Callout_RQ.GGHRequest(usuarioAlta, reclamacionWrapper, documentacionWrapper);
                SAC_WS_GGH_Callout_RP.GGHResponse respuesta = SAC_WS_GGH_Callout.sendRequest(gghResquesWrapper, profileName);
                
                if(respuesta.getResult() == null){
                    tareaGGH.SAC_Estado__c = 'SAC_PendienteEnviar';
                    listaAccionesConError.add(tareaGGH);
                }else if(!respuesta.getResult()) {
                    tareaGGH.SAC_Error__c = respuesta.gestError();
                    tareaGGH.SAC_Estado__c = 'SAC_PendienteEnviar';
                    listaAccionesConError.add(tareaGGH);
                }else if(respuesta.getResult()){
                    tareaGGH.SAC_Error__c = null;
                    tareaGGH.SAC_Estado__c = 'SAC_PendienteRevision';
                    listaAccionesConError.add(tareaGGH);
                }
            }
        }

        if(!listaAccionesConError.isEmpty()){
            Database.update(listaAccionesConError);
        }
    }

    public static Boolean comprobarEstadosGGH(String estado) {

        Boolean enviar = false;
        if(estado == null || estado == 'SAC_008' || estado == 'SAC_005' || estado == 'SAC_006' || estado == 'SAC_007'){		
            enviar = true;
        }

        return enviar;
    }

    public static String reemplazarPunto(Decimal importeDecimal) {

        String importe = String.valueOf(importeDecimal);
        String importe2 = '';
        if(String.isNotBlank(importe)){
            String regExp = '.';
            String replacement = ',';
            importe2 = importe.replace(regExp, replacement);
        }
        return importe2;
    }

    /**************************************************************************
     * Proposito: Método para recuperar los adjuntos de las acciones de GGH
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                             Carlos Solis   23/06/22     Creación
    *****************************************************************************/
    public static Map<Id, List<WrapperAdjuntoGGH>> recuperarAdjuntosGGH(Set<Id> setIdsAccionesGGH) {
        Map<Id, List<WrapperAdjuntoGGH>> mapaAccionDocumentos = new Map<Id, List<WrapperAdjuntoGGH>>();

        List<ContentDocumentLink> listaCDL = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Title,
                                              ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.FirstPublishLocationId,
                                              ContentDocument.LatestPublishedVersion.fileType
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId IN :setIdsAccionesGGH];

        if (!listaCDL.isEmpty()) {
            for (ContentDocumentLink cdl : listaCDL) {
                //Crear wrapper con los datos del adjunto
                WrapperAdjuntoGGH wrapAdjunto = new WrapperAdjuntoGGH();
                wrapAdjunto.id = cdl.ContentDocument.LatestPublishedVersionId;
                wrapAdjunto.title = cdl.ContentDocument.LatestPublishedVersion.Title;
                wrapAdjunto.versionData = cdl.ContentDocument.LatestPublishedVersion.VersionData;
                wrapAdjunto.fileType = cdl.ContentDocument.LatestPublishedVersion.fileType;
                if (mapaAccionDocumentos.containsKey(cdl.LinkedEntityId)) {
                    mapaAccionDocumentos.get(cdl.LinkedEntityId).add(wrapAdjunto);
                } else {
                    List<WrapperAdjuntoGGH> listaWrapAdjunto = new List<WrapperAdjuntoGGH>();
                    listaWrapAdjunto.add(wrapAdjunto);
                    mapaAccionDocumentos.put(cdl.LinkedEntityId, listaWrapAdjunto);
                }
            }
        }
        
        return mapaAccionDocumentos;
    }

    /**************************************************************************
     * Proposito: Método para comprobar si entre todos los ficheros se supera el heap size limit
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                             Carlos Solis   08/05/23     Creación
    *****************************************************************************/
    public static Boolean comprobarContentSize(Set<Id> setIdsAccionesGGH) {
        Boolean heapSizeSuperado = false;
        Integer sizeTotal = 0;
        
        List<ContentDocumentLink> listaCDL = [SELECT ContentDocument.LatestPublishedVersion.ContentSize
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId IN :setIdsAccionesGGH];

        if (!listaCDL.isEmpty()) {
            // Recorrer los documentos para comprobar si supera el heapSize limit
            for (ContentDocumentLink cdl : listaCDL) {
                sizeTotal = sizeTotal + cdl.ContentDocument.LatestPublishedVersion.ContentSize;
                if (sizeTotal > 8900000) {
                    heapSizeSuperado = true;
                    break;
                }
            }
        }

        return heapSizeSuperado;
    }

    /**************************************************************************
     * Proposito: Comprueba si el que está modificando la tarea es propietario de
     * la reclamación o la pretensión padre. En caso de serlo, devuelve true
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             19/09/22     Creación
    *****************************************************************************/
    public static Map<Id,Boolean> esPropietarioRecOPret(List<SAC_Accion__c> listNewObj){

        List<Case> listaReclamacionesPadre = new List<Case>();
        Map<Id, Case> mapaReclamacionesPadre = new Map<Id, Case>();
        Set<Id> setIdsRec = new Set<Id>();
        Map<Id,Boolean> mapaUserTienePermiso = new Map<Id,Boolean>();
        //Recoger ids de las reclamaciones padre de las acciones
        
        for (SAC_Accion__c accion : listNewObj) {
            setIdsRec.add(accion.SAC_Reclamacion__c);
        }

        //Recuperar las reclamaciones con sus pretensiones principales y los owners de ambas
        if (!setIdsRec.isEmpty()) {
            listaReclamacionesPadre = [SELECT Id, OwnerId, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId 
                                        FROM Case 
                                        WHERE RecordTypeId = :RECTYPERECLAMACION
                                        AND Id IN :setIdsRec];
            for (Case reclamacion : listaReclamacionesPadre) {
                mapaReclamacionesPadre.put(reclamacion.Id, reclamacion);
            }
        }

        //Comprobar si el usuario de la accion es usuario de la reclamación o la pretensión para devolverlo en un mapa de booleans
        for (SAC_Accion__c accion : listNewObj) {
            if (mapaReclamacionesPadre.containsKey(accion.SAC_Reclamacion__c) && String.isNotBlank(mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId)) {
                if (mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId == accion.OwnerId || mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).OwnerId == accion.OwnerId) {
                    mapaUserTienePermiso.put(accion.OwnerId, true);
                }
            } else if (mapaReclamacionesPadre.containsKey(accion.SAC_Reclamacion__c) && String.isNotBlank(mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).OwnerId)) {
                if (mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).OwnerId == accion.OwnerId) {
                    mapaUserTienePermiso.put(accion.OwnerId, true);
                }
            }
        }

        return mapaUserTienePermiso;
    }


    /**************************************************************************
     * Proposito: Carga el grupo del usuario en el momento en el que se crea una 
     * tarea
     * 
     * MOD 1.1: Las tareas solo recogen la oficina afectada de la reclamación en caso de
     * que el grupo de la tarea sea de oficinas. De lo contrario, lo deja en blanco.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Raúl S.        28/10/22     Creación
     * 1.1            DE71137          Carlos S.      03/02/23     Modificación
     * 1.2            US577617         Raúl Santos    25/05/23     Modificación: Completar el campo SAC_GrupoCreadorTarea__c cuando la tarea la crea un usuario miembro de los grupos 
     *                                                                           responsables de las tareas creadas en la reclamación/pretensión
    *****************************************************************************/
    public static void cargarDatos(List<SAC_Accion__c> listNew) {

        String idTareaOwner;
        Set<Id> setIdsRec = new Set<Id>();
        Set<Id> setIdsPret = new Set<Id>();
        Set<Id> setEquiposResponsables = new Set<Id>();
        List<Id> listaIdsAcciones = new List<Id>();
        
        for (SAC_Accion__c accion : listNew) {
            
            setIdsRec.add(accion.SAC_Reclamacion__c);
            setIdsPret.add(accion.SAC_Pretension__c);
            idTareaOwner = accion.OwnerId;
            setEquiposResponsables.add(accion.SAC_EquipoResponsable__c);
        }

        for (SAC_Accion__c accion : listNew) {
            listaIdsAcciones.add(accion.SAC_Reclamacion__c);
        }

        //Recuperamos las tareas asociadas a la reclamacion/es que tenga la tarea/s que se crean
        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
        List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c, SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEMAESTROTAREA OR RecordTypeId = :RECTYPEOTRATAREA) AND SAC_Reclamacion__c IN :listaIdsAcciones];

        //Cargamos el mapa por id de la reclamación junto a la lista de tareas de dicha reclamación
        Map<Id,List<SAC_Accion__c>> mapTareasCaso = new Map<Id,List<SAC_Accion__c>>();
        for (SAC_Accion__c accion : acciones) {
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                if(mapTareasCaso.containsKey(accion.SAC_Pretension__c)){
                    mapTareasCaso.get(accion.SAC_Pretension__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Pretension__c, accionesAux);
                }
            }else{
                if(mapTareasCaso.containsKey(accion.SAC_Reclamacion__c)){
                    mapTareasCaso.get(accion.SAC_Reclamacion__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Reclamacion__c, accionesAux);
                }
            }
        }

        //Recuperar equipos responsables para posteriormente comprobar si son equipos de oficina
        List<CC_Grupo_Colaborador__c> listaEquiposResponsables = new List<CC_Grupo_Colaborador__c>();
        Map<Id, CC_Grupo_Colaborador__c> mapaEquiposResponsables = new Map<Id, CC_Grupo_Colaborador__c>();
        if (!setEquiposResponsables.isEmpty()) {
            listaEquiposResponsables = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOTAREAS AND Id IN :setEquiposResponsables];
            for (CC_Grupo_Colaborador__c grupo : listaEquiposResponsables) {
                mapaEquiposResponsables.put(grupo.Id, grupo);
            }
        }

        List<Case> listaRec = new List<Case>();
        Map<Id, Case> mapaRec = new Map<Id, Case>();
        if (!setIdsRec.isEmpty()) {
            listaRec = [SELECT Id, OwnerId, SEG_Grupo__c, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId, SEG_Grupo__r.Name, CC_Oficina_Afectada_Lookup__c 
                                        FROM Case 
                                        WHERE RecordTypeId = :RECTYPERECLAMACION
                                        AND Id IN :setIdsRec];
            for (Case reclamacion : listaRec) {
                mapaRec.put(reclamacion.Id, reclamacion);
            }
        }

        List<Case> listaPret = new List<Case>();
        Map<Id, Case> mapaPret = new Map<Id, Case>();
        if (!setIdsPret.isEmpty()) {
            listaPret = [SELECT Id, OwnerId, SAC_Reclamacion__c, SEG_Grupo__c, SEG_Grupo__r.Name, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SEG_Grupo__r.Name, SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c 
                                        FROM Case 
                                        WHERE RecordTypeId = :RECTYPEPRETENSION
                                        AND Id IN :setIdsPret];
            for (Case pretension : listaPret) {
                mapaPret.put(pretension.Id, pretension);
            }
        }

        Map<Id,Boolean> esPropietario = new Map<Id,Boolean>();
        List<User> usuario2 = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =: idTareaOwner LIMIT 1];

        // Select de los grupos pertenecientes del usuario actual
        if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible() || !Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar los grupos a los que pertenece su usuario' ); }
        List<CC_Grupo_Colaborador__c> listaGruposUserAct = [SELECT id, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =:  UserInfo.getUserId())];
    
        if (!usuario2.isEmpty()) {
            for(SAC_Accion__c tarea: listNew){

                //La tarea se ha creado desde una reclamación
                if(String.isNotBlank(tarea.SAC_Reclamacion__c) && String.isBlank(tarea.SAC_Pretension__c)){
    
                    //Comprobamos si el usuario de la accion es usuario de la reclamación
                    List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
                    listaAcciones.add(tarea); 
                    esPropietario = esPropietarioRecOPret(listaAcciones);
                    List<Boolean> siEsPropietario = esPropietario.values();
                    //Comprobamos los grupos a los que pertenece el usuario
                    if(siEsPropietario.contains(true) && usuario2[0].SAC_GruposPerteneciente__c != null){
    
                        String[] gruposUsuario = usuario2[0].SAC_GruposPerteneciente__c.split(';');
                        //Comprobamos que el usuario pertenece al grupo de la reclamación
                        if(gruposUsuario.contains(mapaRec.get(tarea.SAC_Reclamacion__c).SEG_Grupo__c)){
                                //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo de la reclamación
                                tarea.SAC_GrupoCreadorTarea__c = mapaRec.get(tarea.SAC_Reclamacion__c).SEG_Grupo__r.Name;
                                //Añadido DE71137 03/02/23
                                if (mapaEquiposResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && mapaEquiposResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
                                    tarea.SAC_Oficina__c = mapaRec.get(tarea.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c;
                                }
                        }
                    }else{
                        //US577617
                        //Comprobar si el usuario que crea la tarea, es un usuario perteneciente al equipo responsable de algunas de las tareas creadas, y en caso afirmativo completar el campo SAC_GrupoCreadorTarea__c.
    
                        Boolean crearTarea = false;
                        crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, tarea, listaGruposUserAct);
            
                        if(crearTarea){
                            completarGrupoCreadorNoOwner(mapTareasCaso, tarea, mapaEquiposResponsables, mapaRec, mapaPret);
                        } 
                    }
                }else if(String.isNotBlank(tarea.SAC_Pretension__c)){
    
                    //La tarea se ha creado desde una pretensión
                    if(mapaPret.containsKey(tarea.SAC_Pretension__c) && String.isNotBlank(mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__c) && String.isNotBlank(tarea.SAC_Pretension__c)){
    
                        //Comprobamos si el usuario de la accion es usuario de la pretensión y si el usuario pertenece a algun grupo
                        if(tarea.OwnerId == mapaPret.get(tarea.SAC_Pretension__c).OwnerId && usuario2[0].SAC_GruposPerteneciente__c != null){
                            //Comprobamos si la pretension tiene el campo de grupo cargado, si no es así buscamos el campo de la reclamacion y cargamos este
                            if(String.isNotBlank(mapaPret.get(tarea.SAC_Pretension__c).SEG_Grupo__c)){
                                //Si el usuario pertenece a algun grupo
                                String[] gruposUsuario = usuario2[0].SAC_GruposPerteneciente__c.split(';');
                                //Si el usuario pertenece al grupo de la pretension
                                if(gruposUsuario.contains(mapaPret.get(tarea.SAC_Pretension__c).SEG_Grupo__c)){
                                    //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo de la reclamación
                                    tarea.SAC_GrupoCreadorTarea__c = mapaPret.get(tarea.SAC_Pretension__c).SEG_Grupo__r.Name;
                                    //Añadido DE71137 03/02/23
                                    if (mapaEquiposResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && mapaEquiposResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
                                        tarea.SAC_Oficina__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c;
                                    }
                                }        
                            }else if(String.isNotBlank(mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.SEG_Grupo__c)){
                                String[] gruposUsuario = usuario2[0].SAC_GruposPerteneciente__c.split(';');
                                //Si el usuario pertenece al grupo de la reclamación
                                if(gruposUsuario.contains(mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.SEG_Grupo__c)){
                                    //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo de la reclamación
                                    tarea.SAC_GrupoCreadorTarea__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.SEG_Grupo__r.Name;
                                    //Añadido DE71137 03/02/23
                                    if (mapaEquiposResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && mapaEquiposResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
                                        tarea.SAC_Oficina__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c;
                                    }
                                }
                            } 
                        }else{
                            //US577617
                            //Comprobar si el usuario que crea la tarea, es un usuario perteneciente al equipo responsable de algunas de las tareas creadas, y en caso afirmativo completar el campo SAC_GrupoCreadorTarea__c.
                            Boolean crearTarea = false;
                            crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, tarea, listaGruposUserAct);
                
                            if(crearTarea){
                                completarGrupoCreadorNoOwner(mapTareasCaso, tarea, mapaEquiposResponsables, mapaRec, mapaPret);
                            }
                        }
                    } 
                }
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprueba si el usuario que se esta insertando en la acción tiene permisos para serlo.
     * Lanza un error de que no se puede poner el nuevo owner si se cumplen las siguientes condiciones:
     * El owner que se está poniendo NO es la cola &&
     * El usuario NO pertenece ni a COPS ni a AJ &&
     * El usuario que se esta poniendo NO pertenece al grupo responsable de la tarea &&
     * ( No es empleado de ninguna oficina O la oficina no es la suya ) &&
     * El owner que se está poniendo es diferente al creador de la tarea &&
     * El owner que se está poniendo NO es ni el owner de la pretension ni de la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS        24/05/23     Creación
    *****************************************************************************/
    public static void comprobarNuevoOwner(List<SAC_Accion__c> listaCambioOwner, Map<Id, Case> mapCasosRelated, Group cola, Group colaSupervisores, Map<Id, SAC_Accion__c> mapOldObj) {
        Boolean esCola = false;
        Boolean puedeSerPropietario= false;
        Boolean noPasaValidacionPropiedad = false;
        Map<Id, Id> mapaUsuarioColaboradorCOPSAJ = new Map<Id, Id>();
        Map<String, String> mapaGrupoUsuarios = new Map<String, String>();
        Map<Id,Boolean> mapaUsuarioEsDeRecOPret = new Map<Id,Boolean>();
        Set<Id> setUsuariosAccion = new Set<Id>();
        Set<Id> setGruposAccion = new Set<Id>();
        List<Contact> empleadoOficina = new List<Contact>();
        
        for (SAC_Accion__c accion : listaCambioOwner) {
            //Guardar owners para posteriormente comprobar si pertenecen a COPS o AJ
            setUsuariosAccion.add(accion.OwnerId);
            //Guardar equipos responsables para posteriormente comprobar si los usuarios pertenecen a dicho grupo
            setGruposAccion.add(accion.SAC_EquipoResponsable__c);
        }

        //Recuperar grupos
        mapaGrupoUsuarios = comprobarUsuariosGrupoAccion(setUsuariosAccion, setGruposAccion);

        //Comprobar si los owners pertenecen a COPS o AJ
        mapaUsuarioColaboradorCOPSAJ = comprobarUsuariosCOPSAJ(setUsuariosAccion);

        //Comprobar si el owner que ejecuta es empleado de oficinas
        empleadoOficina = [SELECT AccountId FROM contact WHERE AV_UsuarioAsociado__c =: UserInfo.getUserId()];

        mapaUsuarioEsDeRecOPret = SAC_AccionMetodos.esPropietarioRecOPret(listaCambioOwner);

        //Recorrer acciones a las que les ha cambiado el owner para comprobar si el nuevo owner tiene permiso
        for (SAC_Accion__c accion : listaCambioOwner) {
            //Comprobar si el owner es la cola
            esCola = usuarioEsCola(accion.OwnerId, cola, colaSupervisores); //Cuando se hace un "Devolver a la cola"

            if(mapCasosRelated.get(accion.SAC_Reclamacion__c) != null){
                noPasaValidacionPropiedad = accion.CreatedById == mapCasosRelated.get(accion.SAC_Reclamacion__c).OwnerId ? true : false;
            }else if(mapCasosRelated.get(accion.SAC_Pretension__c) != null){
                noPasaValidacionPropiedad = accion.CreatedById == mapCasosRelated.get(accion.SAC_Pretension__c).OwnerId ? true : false;
            }
            if(!noPasaValidacionPropiedad){
                if(!SAC_AccionMetodos.laTareaEstaViva(mapOldObj.get(accion.Id))){
                    accion.addError('Tarea finalizada o finalizada incompleta');
                }
                if(!esCola && !mapaUsuarioColaboradorCOPSAJ.containsKey(accion.ownerId) && !mapaGrupoUsuarios.containsKey(String.valueOf(accion.SAC_EquipoResponsable__c)+String.valueOf(accion.ownerId)) &&
                (empleadoOficina.isEmpty() || accion.SAC_Oficina__c != empleadoOficina?.get(0)?.AccountId) && (accion.OwnerId != accion.CreatedById) && 
                mapaUsuarioEsDeRecOPret.containsKey(accion.ownerId) && !mapaUsuarioEsDeRecOPret.get(accion.ownerId)){
                    accion.addError('No tiene privilegios para ser el propietario de esta tarea');
                }
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprueba si el usuario es igual a alguna de las colas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS        24/05/23     Creación
    *****************************************************************************/
    public static Boolean usuarioEsCola(Id idUsuario, Group cola, Group colaSupervisores) {
        Boolean esCola = false;
        if (idUsuario == cola.Id || idUsuario == colaSupervisores.Id) {
            esCola = true;
        }

        return esCola;
    }

    /**************************************************************************
     * Proposito: Comprueba si los usuarios introducidos pertenecen a COPS o AJ
     * y lo devuelve en forma de mapa
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS        24/05/23     Creación
    *****************************************************************************/
    public static Map<Id, Id> comprobarUsuariosCOPSAJ(Set<Id> setUsuarios) {

        List<CC_Grupo_Colaborador_Contact__c> listaColabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Map<Id, Id> mapaUserColaborador = new Map<Id, Id>();
        //Buscar si los usuario pertenecen a COPS o a AJ
        listaColabContact = [SELECT id, CC_Usuario__c
                            FROM CC_Grupo_Colaborador_Contact__c
                            WHERE CC_Usuario__c = :setUsuarios
                            AND CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOTAREAS
                            AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'AJ')];
        //Pasar lista a mapa
        if (!listaColabContact.isEmpty()) {
            for (CC_Grupo_Colaborador_Contact__c colaborador : listaColabContact) {
                mapaUserColaborador.put(colaborador.CC_Usuario__c, colaborador.CC_Usuario__c);
            }
        }

        return mapaUserColaborador;
    }

    /**************************************************************************
     * Proposito: Comprueba los usuarios introducidos pertenecen a los grupos
     * de acciones introducidos y lo devuelve en forma de mapa juntando como key la id
     * del usuario y del grupo en caso de que pertenezca
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS        24/05/23     Creación
    *****************************************************************************/
    public static Map<String, String> comprobarUsuariosGrupoAccion(Set<Id> setUsuarios, Set<Id> setGrupos) {

        List<CC_Grupo_Colaborador_Contact__c> listaColabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Map<String, String> mapaGrupoUsers = new Map<String, String>();
        //Buscar si los usuario pertenecen a los grupos de las acciones
        listaColabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c
                        FROM CC_Grupo_Colaborador_Contact__c
                        WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOTAREAS
                        AND CC_Grupo_Colaborador__c IN :setGrupos
                        AND CC_Usuario__c = :setUsuarios];
        //Pasar lista a mapa
        if (!listaColabContact.isEmpty()) {
            for (CC_Grupo_Colaborador_Contact__c colaborador : listaColabContact) {
                String grupoMasUser = String.valueOf(colaborador.CC_Grupo_Colaborador__c) + String.valueOf(colaborador.CC_Usuario__c);
                mapaGrupoUsers.put(grupoMasUser, grupoMasUser);
            }
        }

        return mapaGrupoUsers;
    }

    /**************************************************************************
     * Proposito: Comprueba si los usuariosdel equipo responsable de una tarea tienen permisos para crear tareas desde la reclamación/pretensión
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.1            US577617         Raúl Santos    25/05/2023   Creación
    *****************************************************************************/
    public static Map<Id,Boolean> saltarValidacionOwner(Map<Id,List<SAC_Accion__c>> mapaCasos, SAC_Accion__c tarea) {

        Map<Id,Boolean> mapaTienePermisos = new Map<Id,Boolean>();
        
        if(mapaCasos.containsKey(tarea.SAC_Pretension__c)){
            mapaTienePermisos.put(tarea.SAC_Pretension__c, true);
        }else if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c)){
            mapaTienePermisos.put(tarea.SAC_Reclamacion__c, true);
        }
                
        return mapaTienePermisos;
    }

    /**************************************************************************
     * Proposito: Completar el campo SAC_GrupoCreadorTarea__c cuando la tarea la crea un usuario de un grupo perteneciente (no un owner de la reclamación/pretensión)
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.1            US577617         Raúl Santos    25/05/2023   Creación
    *****************************************************************************/
    public static void completarGrupoCreadorNoOwner(Map<Id,List<SAC_Accion__c>> mapaCasos, SAC_Accion__c tarea,  Map<Id, CC_Grupo_Colaborador__c> eqResponsables, Map<Id, Case> mapaRec, Map<Id, Case> mapaPret) {

        //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo al que pertenece el usuario que crea la tarea
        tarea.SAC_GrupoCreadorTarea__c = eqResponsables.get(tarea.SAC_EquipoResponsable__c).Name;

        if (eqResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && eqResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
            if(mapaCasos.containsKey(tarea.SAC_Pretension__c)){
                tarea.SAC_Oficina__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c;
            }else if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c)){
                tarea.SAC_Oficina__c = mapaRec.get(tarea.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c;
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprobar si el usuario tiene permisos para crear nuevas tareas (es usuario del equipo responsable)
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.1            US577617         Raúl Santos    25/05/2023   Creación
    *****************************************************************************/
    public static Boolean comprobarPermisosCrearTarea(Map<Id,List<SAC_Accion__c>> mapaCasos, SAC_Accion__c tarea, List<CC_Grupo_Colaborador__c> grupos) {
        
        Boolean userPerteneceGrupo = false;

        if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c) || mapaCasos.containsKey(tarea.SAC_Pretension__c)){
            
            List<SAC_Accion__c> listAccionesCaso = new List<SAC_Accion__c>(); 
            if(mapaCasos.containsKey(tarea.SAC_Pretension__c)){
                listAccionesCaso.addAll(mapaCasos.get(tarea.SAC_Pretension__c));
            }else if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c)){
                listAccionesCaso.addAll(mapaCasos.get(tarea.SAC_Reclamacion__c));
            }
            
            //Comprobamos si el usuario pertenece a alguno de los equipos responsables de las tareas
            userPerteneceGrupo = SAC_LCMP_NuevaTarea.tienePermisosGrupoAccion(listAccionesCaso, grupos);
        }

        return userPerteneceGrupo;
    }

     /**************************************************************************
     * Proposito: Actualizar el valor del campo Fecha Tentativa de la tarea
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.1            US662800         Raúl Santos    12/09/2023   Creación
    *****************************************************************************/
    public static void actualizarFechaTentativa(List<SAC_Accion__c> listaCambioTercero) {
        
        for(SAC_Accion__c tarea : listaCambioTercero){
            tarea.SAC_FechaTentativa__c = null;
        }
    }
}