/*****************************************************************
 * Name: SAC_TareasOperativas_Controller
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Autoasignar las tareas de las pretensiones al
 *             usuario que entre dentro de la tarea y pertenezca 
 *             al mismo grupo de la tarea.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US227438       Marcela Neira   20/05/21     Creación
 * 1.1            US204745       Marcela Neira   13/07/21     Modificación: Añadir botón finalizar Tarea
 * 1.2            US204745       Marcela Neira   13/07/21     Modificación: del comportamiento de autoasignación
 * 1.3            US477799       Raúl Santos     02/11/22     Modificación: metodo cuando se pulsa el botón Prorroga
 * 1.4            DE71512        Raúl Santos     31/01/23     Modificación: mostrar botones independiente fecha vto prorroga (excepto boton prorrogar)
 * 1.5            US539784       Raúl/Sergio     20/03/23     Modificación: para las tareas de 'GENERAL PARA OFICINAS' creación del ThreadId, y envio
 *                                                                          de la tarea al mail de la oficina al enviar esta.
*****************************************************************/
public without sharing class SAC_TareasOperativas_Controller {

    public class ApplicationException extends Exception {}
    private static Set<String> objetos = new Set<String>{'Case','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static Id recordTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static Id recordTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();


    /*****************************************************************
     * Proposito: Clase wrapper para recoger los valores de las plantillas
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US537175         Raúl Santos    23/02/23     Creación
    *****************************************************************/
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

    /*****************************************************************
     * Proposito: Recuperar el registro de la Tarea 
     *            (SAC_Accion__c)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US227438        Marcela Neira   20/05/21      Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    static public SAC_Accion__c recuperarTarea(Id tareaId){
       
        SAC_Accion__c tarea = new SAC_Accion__c();    
        tarea = [SELECT id, Name, OwnerId, CreatedById, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_FechaVencimientoProrroga__c, SAC_Comentarios2__c,
                            SAC_Prorroga__c, SAC_FechaVencimientoInicial__c, SAC_ProrrogaCounter__c, SAC_Reclamacion__c, SAC_Pretension__c, SAC_Oficina__c,
                            SAC_Reclamacion__r.OwnerId, SAC_Pretension__r.OwnerId, SAC_MotivoDevolucion__c, SAC_ImpResueltoNotaria__c, SAC_EstadoNotaria__c, 
                            SAC_EstadoGestoria__c, SAC_ImpResueltoGestoria__c, SAC_EstadoRegistro__c, SAC_ImpResueltoRegistros__c, SAC_EstadoTasacion__c, 
                            SAC_ImpResueltoTasacion__c, SAC_NumeroContrato__c, SAC_NCuentaAbono__c, SAC_Comentarios__c, SAC_ImporteResuelto__c, SAC_ImporteAbonar__c,
                            SAC_MaestroAccionesReclamacion__r.SAC_tipo_formulario__c, SAC_ImpResueltoInteresesLegales__c, SAC_MaestroAccionesReclamacion__r.Name,
                            SAC_Oficina__r.CC_Email__c, SAC_IndexedThreadId__c, SAC_Antecedentes_Revisados__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c,
                            SAC_Reclamacion__r.SAC_SentidoResolucion__c
                    FROM SAC_Accion__c 
                    WHERE id = :tareaId LIMIT 1]; 
        return tarea; 
    }


    /*****************************************************************
     * Proposito: Asignar al usuario la propiedad de la tarea, si este
     *            pertenece al grupo donde esta asignada la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US227438       Marcela Neira   20/05/21      Creación
     * 1.1             US204745       Marcela Neira   14/07/21      Modificación: Para usuarios de COPS / AJ
     *                                                              No se realiza autoasignación
    *****************************************************************/
    @AuraEnabled
    static public Boolean autoasignarPropiedadTarea(Id tareaId, Id ownerId){
        Boolean refrescar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        if(sePuedeTrabajarEstaTarea(tarea) && !perteneceCOPSAJ(ownerId) && tarea.ownerId != ownerId && tarea.SAC_Estado__c == 'SAC_PendienteAsignar'){
            if(!grupoTareaIgualPropietarioTarea(tarea)){
                if(usuarioPerteneceGrupoTarea(tarea, ownerId)){
                    tarea.OwnerId = ownerId;
                    tarea.SAC_Estado__c = 'SAC_EnGestion';
                    refrescar = true;
                    SAC_DatabaseDML.updateDML(tarea, false); 
                    //Database.update(tarea);
                }
            }
        }

        return refrescar;
    }
   

    /*****************************************************************
     * Proposito: Tomar en propiedad la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US227438      Marcela Neira   20/05/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void tomarPropiedadTarea(Id tareaId, Id idUser){

        SAC_Accion__c tarea = recuperarTarea(tareaId);

        tarea.ownerId = idUser;
        if(tarea.SAC_Estado__c != 'SAC_PendienteEnviar' && tarea.SAC_Estado__c != 'SAC_Devuelta') {
            tarea.SAC_Estado__c = 'SAC_EnGestion';
        }
        
        SAC_DatabaseDML.updateDML(tarea, false); 
        //Database.update(tarea);
     
    }
     
    /*****************************************************************
     * Proposito: Devolver la tarea para que vuelva a estar pendiente de asignar
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745       Marcela Neira  12/07/21     Creación
    *****************************************************************/
    @AuraEnabled
    static public void devolverTarea(Id tareaId, Id idUser){
        
        SAC_Accion__c tarea = recuperarTarea(tareaId);
		List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        
        if(!cola.isEmpty()){ 
            tarea.OwnerId = cola[0].id;
            tarea.SAC_Estado__c='SAC_PendienteAsignar';
        }
		if(Schema.sObjectType.Case.isUpdateable()){   
            SAC_DatabaseDML.updateDML(tarea, false);    
			//Database.update(tarea);
            List<SAC_Accion__Share> accionesShare = new List<SAC_Accion__Share>();
                    accionesShare.add(new SAC_Accion__Share(
                            ParentId = tarea.Id,
                            UserOrGroupId = userInfo.getUserId(),
                            AccessLevel = 'Edit'
                        ));
            SAC_DatabaseDML.insertListDML(accionesShare, true); 
            //Database.insert(accionesShare);

		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }

    /*****************************************************************
     * Proposito: Devolver la tarea al gestor de la reclamación (si se ha creado desde la reclamación)
     * o al letrado de la pretensión (si se ha creado desde la pretensión)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745         Carlos Solis   21/06/22     Creación
    *****************************************************************/
    @AuraEnabled
    static public void devolverTareaGestorLetrado(Id tareaId, Id idUser, String motivoDevolucion){
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        //Si el campo SAC_Pretension__c no está vacío, siginifca que hay que devolver la tarea al letrado de la pretensión.
        if (String.isNotBlank(tarea.SAC_Pretension__c)) {
            tarea.ownerId = tarea.SAC_Pretension__r.OwnerId;
        } else {
            tarea.ownerId = tarea.SAC_Reclamacion__r.OwnerId;
        }

        //El estado de la tarea pasa a ser devuelta y se le añade el motivo de devolución
        tarea.SAC_Estado__c = 'SAC_Devuelta';
        //Si el motivo está en blanco, lo relleno con el nuevo valor
        if (String.isBlank(tarea.SAC_MotivoDevolucion__c)) {
            tarea.SAC_MotivoDevolucion__c = System.now() + ' ' + motivoDevolucion;
        } else { //De lo contrario, se concatena con el anterior valor
            tarea.SAC_MotivoDevolucion__c = tarea.SAC_MotivoDevolucion__c + '\n' + System.now() + ' ' + motivoDevolucion;
        }
        
        try {
            SAC_DatabaseDML.updateDML(tarea, false); 
            // Database.update(tarea);

            List<Profile> profiles = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];
            if (!profiles.isEmpty() && profiles[0].Name.equals('AV_Usuario_CaixaBank')) {
                List<SAC_Accion__Share> accionesShare = new List<SAC_Accion__Share>();
                accionesShare.add(new SAC_Accion__Share(
                        ParentId = tarea.Id,
                        UserOrGroupId = userInfo.getUserId(),
                        AccessLevel = 'Read'
                    ));
                SAC_DatabaseDML.insertListDML(accionesShare, true); 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    /*****************************************************************
     * Proposito: Comprobar si se puede Trabajar con la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745       Marcela Neira  14/07/21       Creación
    *****************************************************************/

    public static Boolean sePuedeTrabajarEstaTarea(SAC_Accion__C tarea){
        Boolean sePuede = true;
        if(tarea.SAC_Estado__c == 'SAC_Finalizada' || tarea.SAC_Estado__c == 'SAC_FinalizadaIncompleta' || tarea.SAC_Estado__c == 'SAC_PendienteEnviar' || 
           tarea.SAC_Estado__c == 'SAC_StandBy' || tarea.SAC_Estado__c == 'SAC_Descartada'){
            sePuede = false; 
        }
        return sePuede;
    }

    /*****************************************************************
     * Proposito: Comprobar si el usuario pertenece a COPS o a AJ
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745       Marcela Neira  14/07/21       Creación
    *****************************************************************/
    public static Boolean perteneceCOPSAJ(Id idUser){
        Boolean pertenece = false;

        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
            colabContact = [SELECT id    //Buscar si el usuario pertenece a COPS o a AJ
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Usuario__c=:idUser
                            AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' 
                            AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'AJ')];

         if(!colabContact.isEmpty()){
             pertenece = true;
         }                   
       
         return pertenece;
    }
    /*****************************************************************
     * Proposito: Buscar si el Grupo de la Tarea es el mismo grupo del propietario de la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745       Marcela Neira  15/07/21       Creación
    *****************************************************************/
    public static Boolean grupoTareaIgualPropietarioTarea(SAC_Accion__c tarea){

        Boolean esElMismoGrupo = false;

        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c   //Buscar si el Grupo de la Tarea es el mismo grupo del propietario de la tarea
                        FROM CC_Grupo_Colaborador_Contact__c 
                        WHERE CC_Grupo_Colaborador__c=:tarea.SAC_EquipoResponsable__c and CC_Usuario__c=:tarea.OwnerId 
                        AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' LIMIT 1];

        if(!colabContact.isEmpty()){
            esElMismoGrupo = true;
        }

        return esElMismoGrupo;               
    }

    /*****************************************************************
     * Proposito: Buscar si el usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745       Marcela Neira  15/07/21       Creación
    *****************************************************************/
    public static Boolean usuarioPerteneceGrupoTarea(SAC_Accion__c tarea, Id idUser){
        Boolean esElMismoGrupo = false;

        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
                                WHERE CC_Grupo_Colaborador__c=:tarea.SAC_EquipoResponsable__c 
                                AND CC_Usuario__c=:idUser AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion'];


        if(!colabContact.isEmpty()){
            esElMismoGrupo = true;
        }
        else {
            List<Contact> empleadoOficina= new List<Contact>();
            empleadoOficina = [SELECT AccountId FROM contact WHERE AV_UsuarioAsociado__c =: idUser ];

            if(!empleadoOficina.isEmpty())
            {
                esElMismoGrupo = (tarea.SAC_Oficina__c != null && empleadoOficina[0].AccountId == tarea.SAC_Oficina__c);
            }
        }

        return esElMismoGrupo;
    }


    /*****************************************************************
     * Proposito: Buscar si el usuario que ejecuta la acción pertenece al grupo gestor 
     *             de la reclamación o al grupo letrado de la pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US613713       Sergio Martín   29/05/23       Creación
    *****************************************************************/
    public static Boolean usuarioPerteneceGrupoCaso(SAC_Accion__c tarea, Id idUser){
        Boolean esGrupoCaso = false;
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la acción pertenece al grupo gestor de la reclamación o al grupo letrado de la pretensión
                                WHERE (CC_Grupo_Colaborador__c=:tarea.SAC_Reclamacion__r.SEG_Grupo__c OR CC_Grupo_Colaborador__c=:tarea.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c)
                                AND CC_Usuario__c=:idUser];
                    
        if(!colabContact.isEmpty()){
            esGrupoCaso = true;
        }

        return esGrupoCaso;
    }
    
    /*****************************************************************
     * Proposito: Finalizar la tarea 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US204745        Marcela Neira   15/07/21      Creación
     * 1.1             US1100360       Raúl Santos     20/01/2025    Modificación: Cuando una tarea va a pasar a estado Finalizado o Finalizado incompleta y esta tiene informado el campo SAC_ImporteAbonar__c,
     *                                                                             debemos validar que la reclamacion no tiene sentido de resolución "Favorable a la entidad" "Inadmisión" o "Desistimiento"
    *****************************************************************/
    @AuraEnabled
    public static void finalizarTarea(Id tareaId, Id idUser, String observaciones){
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        List<SAC_TMECaso__c> tmesTarea = [SELECT ID, SAC_Accion__c FROM SAC_TMECaso__c WHERE SAC_Accion__c =: tareaId];

        if(tarea.SAC_ImporteAbonar__c != null && tarea.SAC_ImporteAbonar__c != 0 && (tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_001' || tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_004' || tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_005')){
            throw new AuraHandledException('Revise el sentido de la resolución de la reclamación. No es posible indicar sentido de la resolución "Favorable a la entidad" "Inadmisión" o "Desistimiento" e informar un importe abonado.');
        }

        if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar' || tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_Devuelta'){
            tomarPropiedadTarea(tareaId, idUser);
        }

        if(System.IsBatch() == false && System.isFuture() == false){
            finalizarTareaFuture(tareaid, idUser, observaciones);
        }       
        
    }

    /*****************************************************************
     * Proposito: Finalizar la tarea con observaciones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US204745        Luis Mesa      13/04/22      Creación
     * 1.1             US1100360       Raúl Santos    20/01/2025    Modificación: Cuando una tarea va a pasar a estado Finalizado o Finalizado incompleta y esta tiene informado el campo SAC_ImporteAbonar__c,
     *                                                                            debemos validar que la reclamacion no tiene sentido de resolución "Favorable a la entidad" "Inadmisión" o "Desistimiento"
    *****************************************************************/
    @AuraEnabled
    public static void finalizarTareaObservacion(Id tareaId, Id idUser, String observaciones, String estado){

        SAC_Accion__c tarea = recuperarTarea(tareaId);
        
        if(tarea.SAC_ImporteAbonar__c != null && tarea.SAC_ImporteAbonar__c != 0 && estado != 'SAC_Descartada' && (tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_001' || tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_004' || tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_005')){
            throw new AuraHandledException('Revise el sentido de la resolución de la reclamación. No es posible indicar sentido de la resolución "Favorable a la entidad" "Inadmisión" o "Desistimiento" e informar un importe abonado.');
        }

        if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar' || tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_Devuelta'){
            tomarPropiedadTarea(tareaId, idUser);
        }

        if(System.IsBatch() == false && System.isFuture() == false){
            finalizarTareaFutureObservacion(tareaid, idUser, observaciones, estado);
        }       
        
    }
     
    /*****************************************************************
     * Proposito: Mostrar el botón de "tomar en propiedad" dependiendo
     *            de si el ususario pertenece al mismo grupo de la tarea
     *            y si tiene permisos de modificación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US227438        Marcela Neira   24/05/21      Creación
     * 1.1            US204745        Carlos Solis    04/07/22      Modificación (No se muestra el botón si el estado es Devuelta)
     * 1.2            US613713       Sergio Martín    30/05/23     Modificación (Se muestra si pertenece al grupo gestor de la reclamación 
     *                                                              o al grupo letrado de la pretensión)
    *****************************************************************/

    @AuraEnabled
    public static boolean mostrarTomarPropiedad(Id tareaId, Id idUser){
        
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);  

        if(tarea.ownerId == idUser || (tarea.SAC_Estado__c == 'SAC_Devuelta' && !(usuarioPerteneceGrupoCaso(tarea, idUser) || perteneceCOPSAJ(idUser)))){
            return false;
        }
        
        if ( (sePuedeTrabajarEstaTarea(tarea) && tarea.ownerId != idUser && usuarioPerteneceGrupoTarea(tarea, idUser) ) || 
            ((sePuedeTrabajarEstaTarea(tarea) ||  tarea.SAC_Estado__c == 'SAC_PendienteEnviar') && (usuarioPerteneceGrupoCaso(tarea, idUser) || perteneceCOPSAJ(idUser)))){ 
            mostrar = Schema.SObjectType.SAC_Accion__c.isUpdateable(); 
        }
        return mostrar;
    }

     /*****************************************************************
     * Proposito: Mostrar el botón de "Finalizar Tarea"
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   15/07/21      Creación
     * 1.1            US613713       Sergio Martín    30/05/23     Modificación (Se muestra si pertenece al grupo gestor de la reclamación 
     *                                                              o al grupo letrado de la pretensión)
    *****************************************************************/

    @AuraEnabled
    public static boolean mostrarFinalizarTarea(Id tareaId, Id idUser){
      
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        if ( (sePuedeTrabajarEstaTarea(tarea) && tarea.ownerId == idUser) || 
            ((sePuedeTrabajarEstaTarea(tarea) ||  tarea.SAC_Estado__c == 'SAC_PendienteEnviar') && (usuarioPerteneceGrupoCaso(tarea, idUser) || perteneceCOPSAJ(idUser))) ){             
            mostrar = Schema.SObjectType.SAC_Accion__c.isUpdateable(); 
        }
        return mostrar;
    }

     /*****************************************************************
     * Proposito: Mostrar el botón de "Devolver al grupo"
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   16/07/21      Creación
    *****************************************************************/

    @AuraEnabled
    public static boolean mostrarDevolverTarea(Id tareaId, Id idUser){
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        if (sePuedeTrabajarEstaTarea(tarea) && tarea.SAC_Estado__c != 'SAC_PendienteEnviar' && tarea.SAC_Estado__c != 'SAC_Devuelta' && !SAC_AccionMetodos.esLaCola(tarea.ownerId) && (tarea.ownerId == idUser || usuarioPerteneceGrupoTarea(tarea, idUser) || perteneceCOPSAJ(idUser) )){             
            mostrar = Schema.SObjectType.SAC_Accion__c.isUpdateable(); 
        }
        return mostrar;
    }

     /*****************************************************************
     * Proposito: Mostrar el botón de "Prorrogar"
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204756        Marcela Neira   28/07/21      Creación
    *****************************************************************/

    @AuraEnabled
    public static boolean mostrarProrrogarTarea(Id tareaId, Id idUser){
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        if (sePuedeTrabajarEstaTarea(tarea) && !(tarea.SAC_FechaVencimientoProrroga__c < Date.today()) && tarea.SAC_Estado__c != 'SAC_PendienteEnviar' && tarea.SAC_Estado__c != 'SAC_Devuelta'
            && (tarea.ownerId == idUser || usuarioPerteneceGrupoTarea(tarea, idUser) || perteneceCOPSAJ(idUser) )){             
            mostrar = Schema.SObjectType.SAC_Accion__c.isUpdateable(); 
        }

        return mostrar;
    }


     /*****************************************************************
     * Proposito: Enviar tarea, o lo que es lo mismo mover el estado de la tarea a en gestion
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204756         Luis Mesa     24/03/22      Creación
     * 1.1            US356803         Alex Perez    23/10/22      validación envio tarea importe
     * 1.2            US539784         Raúl/Sergio   20/03/23      Modificación: para las tareas 'GENERAL PARA OFICINAS' preparar el envio
     *                                                                           de mail a la oficina
     * 1.3            US723742         Raúl Santos   05/03/24      Modificación: añadir lógica envio emails blackList
    *****************************************************************/

    @AuraEnabled
    public static String enviarTarea(Id tareaId){
        String emailsInvalidos = '';
        Group pendiente = [SELECT id, DeveloperName FROM Group WHERE DeveloperName =: 'SAC_PendienteAsignar' LIMIT 1];
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        list<SAC_Accion__c> ltarea = new list<SAC_Accion__c>();
        ltarea.add(tarea);
        if(tarea.SAC_MaestroAccionesReclamacion__r?.SAC_tipo_formulario__c == 'Importe' || 
        tarea.SAC_MaestroAccionesReclamacion__r?.SAC_tipo_formulario__c == 'Importes hipotecarios') {
            string errorValidacion = SAC_Validaciones.validarEscaladoEnvioTarea(ltarea, tarea.SAC_Reclamacion__c, 'Tarea');
            if(errorValidacion != '') {
                throw new AuraHandledException(errorValidacion);
            }
        }
        
        //Si el estado está en devuelta, hay que enviarla al owner que la devolvió (siempre que pertenezca al grupo resolutor ya que podrían haberlo cambiado)
        if (tarea.SAC_Estado__c == 'SAC_Devuelta') {
            //Recuperar antiguos owners
            List<SAC_Accion__History> listaAccionHistory = [SELECT id,OldValue, NewValue, Field, CreatedDate  FROM SAC_Accion__History WHERE ParentId = :tareaId AND Field = 'Owner' AND DataType = 'EntityId' ORDER BY CreatedDate desc];
            //Si la query nos devuelve datos, la recorremos
            if (!listaAccionHistory.isEmpty() || Test.isRunningTest()) {
                String nuevoOwner;
                Boolean encontrado = false;
                for (SAC_Accion__History accionHistory : listaAccionHistory) {
                    //Si el owner anterior no es la cola pendiente de asignar, es el que buscamos
                    if (accionHistory.OldValue != pendiente.Id) {
                        nuevoOwner = String.valueOf(accionHistory.OldValue);
                        encontrado = true;
                        break;
                    }
                }
                //Si ha encontrado al anterior user y este pertenece al grupo responsable, la tarea pasa a en gestión y el owner será el que hemos encontrado
                if (encontrado && comprobarUserEsDelGrupo(nuevoOwner, tarea.SAC_EquipoResponsable__c)) {
                    tarea.SAC_Estado__c = 'SAC_EnGestion';
                    tarea.OwnerId = nuevoOwner;
                } else { //De lo contrario, se pondrá a en pendiente de asignar tanto el estado como el owner
                    tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
                    tarea.OwnerId = pendiente.Id;
                }
            } else { //Si la query no nos ha devuelto datos, se pondrá a en pendiente de asignar tanto el estado como el owner
                tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
                tarea.OwnerId = pendiente.Id;
            }
        } else { //Si el estado no es devuelta, se pondrá a en pendiente de asignar tanto el estado como el owner
            tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
            tarea.OwnerId = pendiente.Id;
        }
        
        SAC_DatabaseDML.updateDML(tarea, false); 
        //Database.update(tarea);

        // Recuperar las tareas 'GENERAL PARA OFICINAS' para preparar el envio de correo electronico a la oficina
        if(tarea.SAC_MaestroAccionesReclamacion__r.Name == 'GENERAL PARA OFICINAS'){

            if(String.isBlank(tarea.SAC_Oficina__c)){
                throw new AuraHandledException('Para enviar la tarea necesita una oficina informada.');
            }

            //Recuperamos el para, el correo de la oficina
            String para = ''; 
            if(String.isNotBlank(tarea.SAC_Oficina__r.CC_Email__c)) {
                para = tarea.SAC_Oficina__r.CC_Email__c;    
            }else{
                throw new AuraHandledException('Para enviar la tarea necesita que la oficina tenga un email informado.');
            }

            if(String.isBlank(tarea.SAC_Comentarios__c)){
                throw new AuraHandledException('Para enviar la tarea debe detallar un comentario.');
            }

            //Recuperamos la plantilla
            if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas' ); }
            EmailTemplate listaTemplate = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType FROM EmailTemplate WHERE DeveloperName = 'SAC_TareaOficina'];

            if (listaTemplate != null) {
                //Recupero los emails no validos de envio (emails en la blackList)
                List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

                //Compruebo la dirección de envio con las de la blackList
                String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, '', '');
                
                //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
                if(emailsNoValidosEncontrados == ''){
                    String whoId = UserInfo.getUserId();
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(listatemplate.Id, whoId, tarea.Id);                      
                    TemplateWrapper plantilla = new TemplateWrapper(listaTemplate.Id, listaTemplate.Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');
    
                    // Metodo para recuperar los adjuntos y enviar el mail
                    if (String.isNotBlank(para) && plantilla != null) {
                        recuperarAdjuntos(tarea.Id, para, plantilla);
                    }
                }else{
                    //Si la dirección de envio no es válida (está en la blackList) muestro mensaje informativo
                    emailsInvalidos = emailsNoValidosEncontrados;
                }
            }
        }
        
        return emailsInvalidos;
    }

    /**************************************************************************
     * Proposito: Añade al campo SAC_InedexedThreadId el compuesto con los ID
     * acotados de la Organizacion y de la Consulta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US539784       Raúl/Sergio     20/03/23      Creación: crear el ThreadId para las tareas 'GENERAL PARA OFICINAS'
    **************************************************************************/    
    public static void crearThreadId(List<SAC_Accion__c> acciones) {
        List<SAC_Accion__c> listAcciones = new List<SAC_Accion__c>();
        
        for (SAC_Accion__c accion : acciones) {
            if(accion.SAC_MaestroAccionesReclamacion__r.Name == 'GENERAL PARA OFICINAS'){
                String threadId;
                String tareaId = accion.Id; 

                if (String.isBlank(accion.SAC_IndexedThreadId__c)) {
                    //threadId = ('ref:_'+ UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + tareaId + ':ref');
                    threadId = SAC_Utils.creacionThreadID(tareaId);
                    accion.SAC_IndexedThreadId__c = threadId;
                    listAcciones.add(accion);
                }
            }
        }  
        
        SAC_DatabaseDML.updateListDML(listAcciones, true); 
        //Database.update(listAcciones);
    }

    /**************************************************************************
     * Proposito: Rrcuperar los adjuntos de la tarea y envia el correo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US539784       Raúl/Sergio     20/03/23      Creación 
    **************************************************************************/ 

    public static void recuperarAdjuntos(Id idTarea, String para, TemplateWrapper plantillaEmail){

        List<ContentVersion> adjuntos = SAC_LCMP_gestionAdjuntosGlobal.recuperaAdjuntos(idTarea); 

        Set<Id> idContentDocument = new Set<Id>();

        for(ContentVersion cv : adjuntos){
            if(cv.SAC_Oculto__c == false){  // No recuperamos los adjuntos ocultos (SAC_Oculto__c = true), ya que estos no debemos mandarlos.
                idContentDocument.add(cv.ContentDocumentId);
            }
        }

        List<ContentDocument> documentos = new List<ContentDocument>();
        if(!idContentDocument.isEmpty()){
            if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el ContentDocument.' ); }
            documentos = [SELECT Id FROM ContentDocument WHERE id IN: idContentDocument]; 
        }

        Set<Id> idAdjuntos = new Set<Id>();
        for(ContentDocument doc : documentos){
            idAdjuntos.add(doc.Id);
        }

        SAC_LCMP_GestionEmails.enviarEmail(idTarea, para, '', '', plantillaEmail.htmlValueTemplate, plantillaEmail.subjectTemplate, JSON.serialize(idAdjuntos), null);
    }

     /*****************************************************************
     * Proposito: Comprueba si el usuario introducido forma parte del grupo introducido.
     * Si forma parte, devuelve true. De lo contrario, devuelve false.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   25/07/22     Creación
    *****************************************************************/
    public static Boolean comprobarUserEsDelGrupo(String usuarioId, String grupoId) {
        List<CC_Grupo_Colaborador_Contact__c> listaColabContact = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c 
                                                                    WHERE CC_Usuario__c = :usuarioId
                                                                    AND CC_Grupo_Colaborador__c = :grupoId];

        return !listaColabContact.isEmpty() ? true : false;
    }

      /*****************************************************************
     * Proposito: Mostrar el botón de "Notificar"
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            TA412866        Daniel Benito   17/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean mostrarNotificar(Id tareaId, Id idUser){
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        if(tarea.SAC_Reclamacion__c != null){
            //Si es gestor de la reclamación o letrado de las pretensiones, tiene permiso para tocar el botón
            Boolean esPropietario = false;
            List<Case> listaIdOwners = [SELECT Id, OwnerId FROM Case WHERE (RecordTypeId = :recordTypeReclamacion OR RecordTypeId = :recordTypePretension)
                                        AND (
                                            (RecordTypeId = :recordTypeReclamacion AND Id = :tarea.SAC_Reclamacion__c)
                                        OR (RecordTypeId = :recordTypePretension AND SAC_Reclamacion__c = :tarea.SAC_Reclamacion__c))];

            if (!listaIdOwners.isEmpty()) {
                for (Case caso : listaIdOwners) {
                    if (idUser == caso.OwnerId) {
                        esPropietario = true;
                    }
                }
            }
            //Case caso = [SELECT id, OwnerId FROM Case WHERE id =: tarea.SAC_Reclamacion__c LIMIT 1];
            Group pendiente = [SELECT id, DeveloperName FROM Group WHERE DeveloperName =: 'SAC_PendienteAsignar' LIMIT 1];

            if (sePuedeTrabajarEstaTarea(tarea) && (esPropietario && tarea.OwnerId != pendiente.id) && tarea.SAC_Estado__c != 'SAC_Devuelta'){  

                mostrar = true;
                
                return mostrar;
            }   
        }

        return mostrar;
    }

      /*****************************************************************
     * Proposito: Mostrar el botón de "Enviar Tarea" 
     * (Siempre se muestra cuando el user es el propietario de la reclamación o alguna pretensión)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US346710         Luis Mesa      24/03/22     Creación
     * 1.1            US204745         Carlos Solis   04/07/22     modificación (Ahora tambien se muestra cuando a parte de ser owner de 
     *                                                             algún caso de la familia, la tarea está en estado Devuelta)
     * 1.2            US613713       Sergio Martín    30/05/23     Modificación (Se muestra si pertenece al grupo gestor de la reclamación 
     *                                                              o al grupo letrado de la pretensión)
    *****************************************************************/
    @AuraEnabled
    public static boolean mostrarEnvioTarea(Id tareaId, Id idUser){
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar' || tarea.SAC_Estado__c == 'SAC_Devuelta'){
            if(String.isNotBlank(tarea.SAC_Reclamacion__c)){

                Case reclamacion = [SELECT id, OwnerId FROM Case WHERE id =: tarea.SAC_Reclamacion__c LIMIT 1];
                
                List<Case> pretensiones = [SELECT OwnerId FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
                Set<Id> ids = new Set<Id>();
    
                for(Case pretension : pretensiones){
                    ids.add(pretension.OwnerId);
                }

                if (idUser == reclamacion.OwnerId || ids.contains(idUser) || idUser == tarea.OwnerId || usuarioPerteneceGrupoCaso(tarea, idUser) || perteneceCOPSAJ(idUser)){  
                    mostrar = true;
                    return mostrar;
                }
            }    
        }
        
        return mostrar;
    }

    /*****************************************************************
     * Proposito: Mostrar el botón devolver tarea al gestor/letrado
     * Este se muestra cuando la tarea está en estado 'En gestión' y el
     * usuario es el owner de la tarea.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745         Carlos Solis   21/06/222    Creación
     * 1.1            US613713       Sergio Martín    30/05/23     Modificación (Se muestra si pertenece al grupo gestor de la reclamación 
     *                                                              o al grupo letrado de la pretensión)
    *****************************************************************/
    @AuraEnabled
    public static boolean mostrarDevolverGestorLetrado(Id tareaId, Id idUser){
        Boolean mostrar = false;
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        //Comprobar si el usuario actual es administrador del grupo de tareas.
        List<CC_Grupo_Colaborador_Contact__c> listaColabContacts = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c 
                                                                    WHERE CC_Grupo_Colaborador__c = : tarea.SAC_EquipoResponsable__c 
                                                                    AND CC_Usuario__c = :idUser
                                                                    AND SAC_Administrador__c = true];
        Boolean esAdmin = listaColabContacts.isEmpty() ? false : true;

        if((tarea.SAC_Estado__c == 'SAC_EnGestion' && (tarea.OwnerId == idUser || esAdmin)) || 
            (tarea.SAC_Estado__c == 'SAC_PendienteAsignar' && (usuarioPerteneceGrupoCaso(tarea, idUser) || perteneceCOPSAJ(idUser)))){
            mostrar = true;
        }

        return mostrar;
    }

     /*****************************************************************
     * Proposito: Mostrar Todo el Panel de botones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   16/07/21      Creación
    *****************************************************************/

    @AuraEnabled
    public static String mostrarBotones(Id tareaId, Id idUser){

        String respuesta = '';

        if(mostrarTomarPropiedad(tareaId, idUser)){
            respuesta +='1';
        }else{
            respuesta+=0;
        }

        if(mostrarFinalizarTarea(tareaId, idUser)){
            respuesta +='1';
        }else{
            respuesta+=0;
        }

        if(mostrarDevolverTarea(tareaId, idUser)){
            respuesta +='1';
        }else{
            respuesta+=0;
        }

        if(mostrarProrrogarTarea(tareaId, idUser)){
            respuesta +='1';
        }else{
            respuesta+=0;
        }

        if(mostrarNotificar(tareaId, idUser)){
            respuesta += '1';
        }else{
            respuesta+=0;
        }

        if(mostrarEnvioTarea(tareaId, idUser)){
            respuesta += '1';
        }else{
            respuesta+=0;
        }

        if(mostrarDevolverGestorLetrado(tareaId, idUser)){
            respuesta += '1';
        }else{
            respuesta+=0;
        }

        return respuesta;
        
    }
    /*****************************************************************
     * Proposito: Pasar a estado finalizado la tarea 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745        Marcela Neira   22/07/21      Creación
    *****************************************************************/

    @future
    public static void finalizarTareaFuture(Id tareaid, Id idUser, String observaciones){
        SAC_Accion__c tarea = recuperarTarea(tareaId);        
    
        tarea.SAC_Comentarios2__c = (tarea.SAC_Comentarios2__c != null) ? tarea.SAC_Comentarios2__c + observaciones: observaciones;
        tarea.SAC_Estado__c = 'SAC_Finalizada';
        SAC_DatabaseDML.updateDML(tarea, false); 
        //Database.update(tarea);
        
        
    }

    /*****************************************************************
     * Proposito: Pasar a estado finalizado la tarea 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204745         Luis Mesa      13/04/22      Creación
    *****************************************************************/

    @future
    public static void finalizarTareaFutureObservacion(Id tareaid, Id idUser, String observaciones, String estado){
        SAC_Accion__c tarea = recuperarTarea(tareaId);      

        //Si el estado es descartada, se rellena un campo de observaciones distinto
        if (estado == 'SAC_Descartada') {
            tarea.SAC_MotivoDescarte__c = observaciones.replaceAll('<[/a-zAZ0-9]*>','');
            tarea.SAC_MotivoDescarte__c = tarea.SAC_MotivoDescarte__c.left(255);
            tarea.SAC_Estado__c = estado;
        } else { //De lo contrario se procede normalmente            
            tarea.SAC_Comentarios2__c =  observaciones;
            tarea.SAC_Estado__c = estado;
        }
        
        SAC_DatabaseDML.updateDML(tarea, false); 
        //Database.update(tarea);
        
    }

    /*****************************************************************
     * Proposito: Enviar notificación(campanita) de el gestor de la reclamación al
     *            propietario de la acción.
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            TA412866        Daniel Benito   17/11/21      Creación
     * 1.1            US307778        Carlos Solis    04/05/22      Añadido método postChatterTarea (registra en el chatter de la tarea la notificación)
    *****************************************************************/
    @AuraEnabled
    public static Boolean notificarPropietarioAccion(Id tareaId, String mensaje){
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        SAC_Accion__c tarea = recuperarTarea(tareaId);
        
        String titulo = 'Notificación de la Acción ' + tarea.Name;

        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                            'SAC_016',
                                                            'Notificación de la Acción ' + tarea.Name + '. ' + mensaje,
                                                            tarea.OwnerId,
                                                            '',
                                                            tarea.Id,
                                                            '');
                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
        //Añadirla a la lista para posteriormente llamar al método
        listaWrapperAlerta.add(wrapAlerta);

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }

        //Llamada método para insertar la notificación en el chatter de la tarea
        postChatterTarea(tareaId, titulo, mensaje);

        return true;
    }

    /*****************************************************************
     * Proposito: Grabar en el "Chatter" de la reclamación y la pretensión vinculada a la acción la notificación .
     *  
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            TA412866        Daniel Benito   17/11/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void postOnChatter(Id tareaId, String observacion){

        List<FeedItem> feeds = new List<FeedItem>();
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        String operativa = 'Notificación de la Acción ' + tarea.Name;

        FeedItem feedReclamacion = new FeedItem();
		feedReclamacion.ParentId = tarea.SAC_Reclamacion__c; 
        feedReclamacion.Body = operativa + ' : ' + observacion; 
		
		feeds.add(feedReclamacion); 

        if(tarea.SAC_Pretension__c != null){

            FeedItem feedPretension = new FeedItem();
            feedPretension.ParentId = tarea.SAC_Pretension__c; 
            feedPretension.Body = operativa + ' : ' + observacion; 
            
            feeds.add(feedPretension);
        }

        SAC_DatabaseDML.insertListDML(feeds, true); 
        //Database.insert(feeds);
    }  
    
    /*****************************************************************
     * Proposito: Inserta un registro en el chatter de la tarea. Este registro contiene la
     * notificación que se manda con el botón Notificar.
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US307778        Carlos Solis    04/05/22      Creación
    *****************************************************************/
    public static void postChatterTarea(String tareaId, String titulo, String mensaje) {
        FeedItem feedTarea = new FeedItem();
        feedTarea.ParentId = tareaId;
        feedtarea.Body = titulo + ' : ' + mensaje;

        SAC_DatabaseDML.insertDML(feedTarea, false); 
        //Database.insert(feedTarea);
    }
    
    /*****************************************************************
     * Proposito: Retornar el campo SAC_Comentarios2__c de la tarea
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                           Marcela Neira   21/06/22      Creación
    *****************************************************************/
    @AuraEnabled
    public static String cargarComentarios2(String tareaId) {
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        return String.isNotBlank(tarea.SAC_Comentarios2__c) ? tarea.SAC_Comentarios2__c : '';
    }


    @AuraEnabled
    public static void enviarTareaGGH(Id tareaId){

        SAC_Accion__C tarea = new SAC_Accion__C(Id = tareaId, SAC_Estado__c = 'SAC_PendienteAsignar');
        try {
            SAC_DatabaseDML.updateDML(tarea, false); 
            //Database.update(tarea);
        } catch (Exception e) { 
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            if (String.isNotBlank(pureErrorMsg)) {
                pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                throw new AuraHandledException(pureErrorMsg);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        }        
    }

    @AuraEnabled
    public static void finalizarTareaGGH(Id tareaId){
        SAC_Accion__C tarea = new SAC_Accion__C(Id = tareaId, SAC_Estado__c = 'SAC_Finalizada');
        SAC_DatabaseDML.updateDML(tarea, true); 
        //Database.update(tarea);               
    }

    /*****************************************************************
     * Proposito: Retornar si el campo SAC_Antecedentes_Revisados__c de la tarea de tipo importe está marcado
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US535408      Sergio Martín   23/02/23      Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean devolverAntecedentesRevisados(Id tareaId){
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        if(tarea.SAC_MaestroAccionesReclamacion__r.SAC_tipo_formulario__c == 'Importe') {
            return tarea.SAC_Antecedentes_Revisados__c;
        } else {
            return true;
        }                
    }
 }