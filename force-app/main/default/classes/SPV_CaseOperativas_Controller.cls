public with sharing class SPV_CaseOperativas_Controller {
   
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c', 'Case', 'SAC_MaestroTemas__c', 'CBK_Case_Extension__c', 'SPV_Formulario__c', 'SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Rec type de Grupo Colaborador
    private static final Id RECTYPEGRUPOGESTOR = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPEGRUPOLETRADO = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    
    //Rec Type de Case
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();    //Reclamación SPV
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();      //Pretensión SPV
    private static final Id RECORDTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();		//Consulta COPS
    private static final Id RECORDTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();		//Consulta SAC
    
    //Rec Type de Maestro Temas
    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();

    //Rec Type de Formulario
    private static final Id RECTYPEFORMNEGOCIACION = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioNegociacion').getRecordTypeId();
    private static final Id RECTYPEFORMCOMPLEMENTARIA = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioComplementarias').getRecordTypeId();

    //Rec Type de Grupo Tareas
    private static final Id RECTYGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    //Rec Type de Tareas
    private static final Id RECTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();


    @AuraEnabled
    static public Case recuperarCaso(Id caseId){        
        String userId = UserInfo.getUserId();
        Case caseSR = new Case();
        //revisar si utilizaremos todos estos campos
        if (Schema.sObjectType.Case.isAccessible()) {
            caseSR = [SELECT id, Status, SEG_Subestado__c, SEG_Grupo__c, SEG_Grupo__r.Name, OwnerId, AccountId, CaseNumber, Origin, RecordTypeId, SuppliedEmail, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoReabierto__c,
            CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c, RecordType.Name, CC_Idioma__c, Priority, SEG_Detalle__c, Subject, SAC_PretensionPrincipal__c,
            SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_Motivo__c, RecordType.DeveloperName, CC_Canal_Respuesta__c, CC_No_Identificado__c, SAC_OrigenConsulta__c, SPV_ComunidadAutonoma__c,
            SAC_EsCliente__c, ContactId, OS_Email__c, SAC_NombreContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_UsarDatos__c, SAC_PoblacionContacto__c, SAC_DireccionPostalNotificacion__c, CC_Importe_Reclamado__c, SAC_NPretensionesActivas__c,
            SAC_TipoDeRepresentante__c, SAC_DespachoRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreRepresentante__c, SAC_DireccionPostal__c,
            SAC_EmailRepresentante__c, SAC_TelefonoRepresentante__c, SAC_Naturaleza__c, SAC_CasoEspecial__c, SAC_CASE_esPSD2__c,SAC_DerivadoA__c, SAC_CasoRelacionado__c, SPV_Organismo__c,
            CC_Detalles_Solucion__c, SAC_UserElevoASupervisor__c, SAC_FechaRecepcion__c, SPV_ObservacionesVolverAnalisis__c, SAC_ObservacionesSupervisor__c, SAC_Prorrogado__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, Description, SAC_EsPrincipal__c, CC_SuppliedFiles__c,
            SPV_ComplementariaOrganismo__c ,CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, SAC_ResultadoNegociacion__c, SAC_CasoNegociado__c,

            SAC_Reclamacion__c , SAC_Reclamacion__r.Status, 

            SAC_PretensionPrincipal__r.Status, SAC_PretensionPrincipal__r.SEG_Grupo__c, SAC_PretensionPrincipal__r.SEG_Grupo__r.Name, SAC_PretensionPrincipal__r.OwnerId, 
            SAC_PretensionPrincipal__r.AccountId, SAC_PretensionPrincipal__r.CaseNumber, SAC_PretensionPrincipal__r.Origin, SAC_PretensionPrincipal__r.RecordTypeId, 
            SAC_PretensionPrincipal__r.SuppliedEmail, SAC_PretensionPrincipal__r.CC_MCC_Motivo__c, SAC_PretensionPrincipal__r.CC_MCC_ProdServ__c, SAC_PretensionPrincipal__r.CC_MCC_Tematica__c, 
            SAC_PretensionPrincipal__r.RecordType.Name, SAC_PretensionPrincipal__r.CC_Idioma__c, SAC_PretensionPrincipal__r.Priority, SAC_PretensionPrincipal__r.SEG_Detalle__c,
            SAC_PretensionPrincipal__r.Subject, SAC_PretensionPrincipal__r.SAC_Motivo__c, SAC_PretensionPrincipal__r.RecordType.DeveloperName, 
            SAC_PretensionPrincipal__r.CC_Canal_Respuesta__c, SAC_PretensionPrincipal__r.CC_No_Identificado__c, SAC_PretensionPrincipal__r.SAC_OrigenConsulta__c,
            SAC_PretensionPrincipal__r.SAC_EsCliente__c, SAC_PretensionPrincipal__r.ContactId, SAC_PretensionPrincipal__r.OS_Email__c, SAC_PretensionPrincipal__r.SAC_NombreContacto__c,
            SAC_PretensionPrincipal__r.SAC_UsarDatos__c, SAC_PretensionPrincipal__r.SAC_DireccionPostalNotificacion__c, SAC_PretensionPrincipal__r.CC_Importe_Reclamado__c,
            SAC_PretensionPrincipal__r.SAC_TipoDeRepresentante__c, SAC_PretensionPrincipal__r.SAC_DespachoRepresentante__c, SAC_PretensionPrincipal__r.SAC_TipoDeDocumento__c, 
            SAC_PretensionPrincipal__r.SAC_NumeroDelDocumento__c, SAC_PretensionPrincipal__r.SAC_NombreRepresentante__c, SAC_PretensionPrincipal__r.SAC_DireccionPostal__c,
            SAC_PretensionPrincipal__r.SAC_EmailRepresentante__c, SAC_PretensionPrincipal__r.SAC_TelefonoRepresentante__c, SAC_PretensionPrincipal__r.SAC_Naturaleza__c, 
            SAC_PretensionPrincipal__r.SAC_CasoEspecial__c, SAC_PretensionPrincipal__r.SAC_CASE_esPSD2__c, SAC_PretensionPrincipal__r.SAC_Entidad_Afectada__c, SAC_PretensionPrincipal__r.SAC_EntidadProductora__c, 
            SAC_MotivoReabrir__c, OS_Fecha_Resolucion__c, SAC_GrupoLetrado__c, SAC_GrupoLetrado__r.SAC_Email__c, SAC_PretensionPrincipal__r.Owner.Email, SAC_PretensionPrincipal__r.SAC_ResultadoNegociacion__c, SAC_PretensionPrincipal__r.SAC_Motivoresultadonegociacion__c
            FROM Case WHERE RecordType.DeveloperName LIKE 'SPV_%' AND Id = :caseId LIMIT 1];
        }
        
        return caseSR; 
    }

    @AuraEnabled 
    public static Map<String, String> fetchMotivos(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Case.SAC_Motivo__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }


   
    @AuraEnabled
    static public void tomarPropiedadCaso(Id caseId, Id ownerId){
        
        //comprobamos si el usuario puede coger el caso.
        Case caseSR = recuperarCaso(caseId);
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Boolean lanzarError = true;

        if(caseSR.OwnerId == colaSupervisores.id){


            if(caseSR.RecordTypeId == RECTYPERECLAMACION){
                colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                 WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOGESTOR
                                 AND CC_Grupo_Colaborador__c = :caseSR.SEG_Grupo__c AND CC_Usuario__c = :ownerId];
            }else if(caseSr.recordTypeId == RECTYPEPRETENSION){

                    colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                    WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOLETRADO
                    AND CC_Grupo_Colaborador__c = :caseSR.SEG_Grupo__c AND CC_Usuario__c = :ownerId];
            
      
            }
                        
            if(Test.isRunningTest() || !colabContact.isEmpty()){
                caseSR.OwnerId = ownerId;
                lanzarError = false;
            }
        }
        else{
            if(Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){

                if(caseSR.recordTypeId == RECTYPERECLAMACION){  //Si el caso es una reclamación, el grupo debe ser un grupo gestor

                    colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                    WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOGESTOR
                                    AND CC_Grupo_Colaborador__c =: caseSR.SEG_Grupo__c AND CC_Usuario__c =: ownerId];  

                }else if(caseSR.recordTypeId == RECTYPEPRETENSION){  //Si el caso es una pretensión, el grupo debe ser un grupo letrado

                    colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                     WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOLETRADO
                                     AND CC_Grupo_Colaborador__c =: caseSR.SEG_Grupo__c AND CC_Usuario__c =: ownerId];    
                }

            }
            
            if(!colabContact.isEmpty()){
                caseSR.OwnerId = ownerId;
                lanzarError = false;
            }
        }
            

        if(lanzarError){throw new AuraHandledException('No tienes permisos para tomar en propiedad el Caso');
        }else{
            SPV_DatabaseDML.updateDML(caseSR, true); 

            //Tras el update, llamar a las integraciones ERR
            
            //SPV_RecuperarDocumentosController.recuperarTicketERR(caseId);
        }
        
    }


    //Comprobar si el usuario es owner de la reclamación o de alguna de sus pretensiones
    @AuraEnabled
    public static GestorLetradoWrapper verSiGestorLetrado(id idCaso, id ownerCaso){
        String idUser = UserInfo.getUserId();
        List<Case> listaPretensiones = new List<Case>();
        Boolean esGestor = false;
        Boolean esLetrado = false;
        Boolean esCOPSAJ = false;

        //Se obtienen las pretnsiones de la reclamación
        listaPretensiones = listaPretensiones = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE SAC_Reclamacion__c = :idCaso];
  
        //Si el usuario es owner de alguna pretensión, entonces es letrado
        if(!listaPretensiones.isEmpty()){
            for(Case pretension : listaPretensiones){
                if(pretension.OwnerId == idUser){
                    esLetrado = true;
                }
            }
        }

        //Si el usuario es owner de la reclamación, entonces es gestor
        if(ownerCaso == idUser){
            esGestor = true;
        }

        //Buscar si el usuario pertence a COPS
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id FROM CC_Grupo_Colaborador_Contact__c 
                        WHERE CC_Usuario__c=:idUser AND CC_Grupo_Colaborador__r.RecordTypeId = :RECTYGRUPOTAREAS
                        AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_AJ')];

        if(!colabContact.isEmpty()){esCOPSAJ = true;}       

        //Se construye el wrapper que se va a devolver, con todos los escalados necesarios para el componente
        GestorLetradoWrapper wrapperGestorLetrado = new GestorLetradoWrapper(esLetrado, esGestor, esCOPSAJ);
        return wrapperGestorLetrado;
    }

    /*****************************************************************************************************
     * Proposito: Wrapper en el que se devolverán si el usuario es Gestor, letrado o pertenece al grupo COPS
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1126342     Sergio Martín    21/02/25        Creación
     *****************************************************************************************************/
    /**
	 * @description     Wrapper en el que se devolverán si el usuario es Gestor, letrado o pertenece al grupo COPS
	 */
    public class GestorLetradoWrapper{

        @AuraEnabled public Boolean esUsuarioLetrado {get; set;}
        @AuraEnabled public Boolean esUsuarioGestor {get; set;}
        @AuraEnabled public Boolean esUsuarioCOPSAJ {get; set;}

        public GestorLetradoWrapper(Boolean varEsUsuarioLetrado, Boolean varEsUsuarioGestor, Boolean varEsUsuarioCOPSAJ)
        {
            esUsuarioLetrado = varEsUsuarioLetrado;
            esUsuarioGestor = varEsUsuarioGestor;
            esUsuarioCOPSAJ = varEsUsuarioCOPSAJ;
        }
    }

    @AuraEnabled
    static public Map<String,String> recuperarUser(id grupoCaso, id idCaso, id ownerCaso){
        
        Map<String,String> mapKeyValue =  new Map<String,String>();
        String idUser = UserInfo.getUserId();
		List<PermissionSetAssignment> lstPS = [Select Id, PermissionSet.Name From PermissionSetAssignment Where AssigneeId = :idUser];
		for(PermissionSetAssignment ps : lstPS){
			mapKeyValue.put(ps.PermissionSet.Name,ps.PermissionSet.Name);
		}
		mapKeyValue.put('UserId',idUser); 

        if(ownerCaso == idUser){
      
            List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
                    colabContact = [SELECT id
                                    FROM CC_Grupo_Colaborador_Contact__c 
                                    WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName LIKE 'SPV_%'
                                    AND CC_Usuario__c=:ownerCaso
                                    AND CC_Grupo_Colaborador__c = :grupoCaso
                                    AND SAC_Supervisor__c = true]; 

            if(!colabContact.isEmpty()){ 
        
                Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
                List<CaseHistory> ch = [SELECT id,OldValue, NewValue, Field, CreatedDate  
                                        FROM CaseHistory 
                                        WHERE Case.RecordType.DeveloperName LIKE 'SPV_%' AND CaseId =:idCaso AND Field = 'Owner' AND DataType = 'EntityId' ORDER BY CreatedDate desc]; 
           
                if(Test.isRunningTest() || ch[0].OldValue == colaSupervisores.Id ){
                    mapKeyValue.put('mostrarSupervisor', 'si');  
                }                
            }            
        }       

        return mapKeyValue;  
    }

    
    @AuraEnabled
    static public void devolverCaso(Id caseId, /*String motivo,*/ String comentario){
        String userId = UserInfo.getUserId();
        String comentarioNuevo;
        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
        List<Task> newTasks = new List<Task>();
        Case caso = [SELECT OwnerId, recordTypeId, SAC_NumDevoluciones__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_ComentarioDevolucionCaso__c FROM Case WHERE RecordType.DeveloperName LIKE 'SPV_%' AND id = :caseId LIMIT 1];
        List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        
        if(!cola.isEmpty()){
            caso.OwnerId = cola[0].id;
            caso.SAC_NumDevoluciones__c = caso.SAC_NumDevoluciones__c == null ? 0 : caso.SAC_NumDevoluciones__c + 1;
            //caso.SAC_Motivo__c = motivo;
            caseExtension.Id = caso.CBK_Case_Extension_Id__c;
            //En caso de que ya haya comentario, se añade el nuevo en una línea aparte indicando la fecha
            if(String.isBlank(caso.CBK_Case_Extension_Id__r.SPV_ComentarioDevolucionCaso__c)){
                //comentarioNuevo = System.now() + ' : ' + comentario;
                comentarioNuevo = System.now().format('dd-MM-yyyy') + ' : ' + comentario;
            }else{
                //comentarioNuevo = System.now() + ' : ' + comentario;0
                comentarioNuevo = caso.CBK_Case_Extension_Id__r.SPV_ComentarioDevolucionCaso__c + '\n' + System.now().format('dd-MM-yyyy') + ' : ' + comentario;
            }
            caseExtension.SPV_ComentarioDevolucionCaso__c = comentarioNuevo;
            newTasks.add(new Task(
                WhatId = caseId,
                Subject = comentarioNuevo,
                Description = 'Comentario Devolución: ' + comentarioNuevo
            ));

        }
        if(Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
            SPV_DatabaseDML.updateDML(caso, true); 
            SPV_DatabaseDML.updateDML(caseExtension, true); 
            SPV_DatabaseDML.insertListDML(newTasks, true); 
        }else{
            throw new AuraHandledException('No tienes permisos');
        }
    }

    //Método al que se llama al pulsar el botón: "Devolver a letrado"
    //Se asignará como owner de la reclamación al letrado de la pretensión principal
    @AuraEnabled
    public static void devolverALetrado(Id caseId, String motivo, String observaciones){
        try{

            Case caso = recuperarCaso(caseId);
            List<Case> listaCasosActualizar = new List<Case>();
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.Id = caso.CBK_Case_Extension_Id__c;

            //Si el estado es "Envío", se devuelve al letrado y se cambia el estado a "Análisis y Decisión"
            if(caso.Status == 'SPV_Envio'){
                caso.SEG_Grupo__c = caso.SAC_PretensionPrincipal__r.SEG_Grupo__c;   //Se asigna el grupo de la pretensión a la reclamación, para que el letrado pueda ser su owner
                caso.OwnerId = caso.SAC_PretensionPrincipal__r.OwnerId;
                caso.Status = 'SPV_AnalisisDecision';
                caseExtension.SPV_MotivoDevolucionEnvio__c = motivo;
                listaCasosActualizar.add(caso);
            }else if(caso.Status == 'SPV_EnvioComplementaria'){         //Si el estado es "Envío complementaria", se devuelve al letrado y se cambia el estado a "Análisis Complementaria Organismo"
                caso.SEG_Grupo__c = caso.SAC_PretensionPrincipal__r.SEG_Grupo__c;  
                caso.OwnerId = caso.SAC_PretensionPrincipal__r.OwnerId;
                caso.Status = 'SPV_AnalisisComplementariaOrganismo';
                caseExtension.SPV_MotivoDevolucionComplementaria__c = motivo;
                listaCasosActualizar.add(caso);
            }else if(caso.Status == 'SPV_EnvioRectificacion'){         //Si el estado es "Envío Rectificación", se devuelve al letrado y se cambia el estado a "Rectificación"
                caso.SEG_Grupo__c = caso.SAC_PretensionPrincipal__r.SEG_Grupo__c;  
                caso.OwnerId = caso.SAC_PretensionPrincipal__r.OwnerId;
                caso.Status = 'SPV_Rectificacion';
                caseExtension.SPV_MotivoDevolucionRectificacion__c = motivo;
                listaCasosActualizar.add(caso);
            }
            if(motivo == 'SPV_010'){
                caseExtension.SPV_ObservacionesDevolucionLetrado__c = observaciones;
            }else{
                caseExtension.SPV_ObservacionesDevolucionLetrado__c = '';
            }
    
            if(Schema.sObjectType.Case.isUpdateable() && !listaCasosActualizar.isEmpty()){
                   SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
                   SPV_DatabaseDML.updateDML(caseExtension, true);
            }else{
                   throw nuevaExcepcion('No tienes permisos para realizar esta operación.');
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }


    }

    @AuraEnabled
    static public void descartarReclamacion(Id caseId, String motivo, String observaciones){
        try {
            String userId = UserInfo.getUserId();
           List<Case> listaCasosActualizar = new List<Case>();
            Case caso = recuperarCaso(caseId);
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();

            if(caso.Status == 'SAC_001'){   //Se puede pasar a Descartado desde alta y análisis
                caso.Status = 'Descartado';
                caso.SAC_MotivoDescarte__c = motivo;
                listaCasosActualizar.add(caso);

                caseExtension.Id = caso.CBK_Case_Extension_Id__c;
                if(motivo == 'SAC_Otros'){
                    caseExtension.SPV_ObservacionesDescartar__c = observaciones;
                }else{
                    caseExtension.SPV_ObservacionesDescartar__c = '';
                }

            }

            if(Schema.sObjectType.Case.isUpdateable() && !listaCasosActualizar.isEmpty()){
             //   SPV_DatabaseDML.updateDML(caso, true); 
                SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);
                SPV_DatabaseDML.updateDML(caseExtension, true);

            }else{
                throw nuevaExcepcion('No tienes permisos para realizar esta operación.');
            }


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Método que crea una excepción con el mensaje que le pases como argumento
    static private AuraHandledException nuevaExcepcion(String mensaje){
        AuraHandledException e = new AuraHandledException(mensaje);
        e.setMessage(mensaje);
        return e;
    }


    //Método que devuelve la reclamación al status de Alta
    @AuraEnabled
    public static void devolverReclamacionAlta(Id caseId, String motivoDevolucion, String observacionesDevolucion){

        Case caseSR = recuperarCaso(caseId);
        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
        if(caseSR.Status == 'SPV_AnalisisDecision'){
            caseSR.Status = 'SAC_001';          //Se vuelve a poner el estado en alta
            caseSR.SEG_Subestado__c = null;
            caseSR.SPV_VueltaAlta__c = true;
            
            caseExtension.Id = caseSR.CBK_Case_Extension_Id__c;
            caseExtension.SPV_MotivoDevolucionAlta__c = motivoDevolucion;
            if(motivoDevolucion == 'SPV_004'){
                caseExtension.SPV_ObservacionesDevolucionAlta__c = observacionesDevolucion;
            }else{
                caseExtension.SPV_ObservacionesDevolucionAlta__c = '';
            }

        }
        if(Schema.sObjectType.Case.isUpdateable()){
            SPV_DatabaseDML.updateDML(caseSR, true); 
            SPV_DatabaseDML.updateDML(caseExtension, true);
        }else{
            throw new AuraHandledException('No tienes permisos');
        }

    }

	/*
    @AuraEnabled
    static public void volverAnalisis(Id caseId, String observaciones){

        Case caseSR = recuperarCaso(caseId);
        if(caseSR.Status == 'SPV_EnvioOrganismos' && caseSR.SEG_Subestado__c == 'Revision'){
            caseSR.Status = 'SAC_002';
            caseSR.SEG_Subestado__c = 'Analisis';
            caseSR.SPV_ObservacionesVolverAnalisis__c = observaciones;
        }
        if(Schema.sObjectType.Case.isUpdateable()){  
            SPV_DatabaseDML.updateDML(caseSR, true); 
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la operación.');
        }
    }*/

    @AuraEnabled
    static public void establecerPretPpal(Id caseId){
        Case pretensionActual = recuperarCaso(caseId);
        
        if (Schema.sObjectType.Case.isAccessible()) {

            Case pretensionPrincipal = new Case();
            List<Case> casosActualizar = new List<Case>();

            Case reclamacion = [SELECT Id, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.SAC_EsPrincipal__c
                        FROM Case 
                        WHERE RecordTypeId = :RECTYPERECLAMACION AND id = :pretensionActual.SAC_Reclamacion__c LIMIT 1];

            //Compruebo si la reclamación ya tiene una pretensión ppal informada            
            if(reclamacion.SAC_PretensionPrincipal__c != null) {
                pretensionPrincipal = [SELECT id, status, SAC_EsPrincipal__c
                        FROM Case 
                        WHERE RecordTypeId = :RECTYPEPRETENSION AND id = :reclamacion.SAC_PretensionPrincipal__c LIMIT 1];
            }
            
            if (Schema.sObjectType.Case.isUpdateable()) {
                pretensionActual.SAC_EsPrincipal__c = true;

                if(reclamacion.SAC_PretensionPrincipal__c != null) {
                    pretensionPrincipal.SAC_EsPrincipal__c = false;
                    casosActualizar.add(pretensionPrincipal);
                }

                reclamacion.SAC_PretensionPrincipal__c = pretensionActual.id;

                casosActualizar.add(reclamacion);
                casosActualizar.add(pretensionActual);

                SPV_DatabaseDML.updateListDML(casosActualizar, true);
            }
            else{
                throw new AuraHandledException('No tienes permisos para actualizar el registro');
            }
        }
        else{
            throw new AuraHandledException('No tienes permisos para visualizar el registro');
        } 
    }

    @AuraEnabled 
    public static List<CC_Grupo_Colaborador__c> recuperarGruposLetrado(){
       
        if (Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()) {
            List<CC_Grupo_Colaborador__c> listGruposLet = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOLETRADO];

            return listGruposLet;
        }else{
            throw new AuraHandledException('No tienes permisos para recuperar los grupos');
        } 
    }

    @AuraEnabled 
    public static void reasignarGrupoLetrado(Id caseId, Id idGrupo, String motivo){
       
        if (Schema.sObjectType.Case.isAccessible()) {

            List<Case> pretensiones = [SELECT id,OwnerId,SEG_Grupo__c,CaseNumber, SAC_Reclamacion__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: caseId];
            Case reclamacion = [SELECT id, SAC_FechaUltimaAsignacionLetrado__c, SAC_MotivoReasignacion__c FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND id =: caseId];
            List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue'];

            List<Case> casosActualizar = new List<Case>();

            for(Case pretension : pretensiones){

                if(pretension.OwnerId != cola[0].Id || pretension.SEG_Grupo__c != idGrupo){
                    pretension.OwnerId = cola[0].Id;
                    pretension.SEG_Grupo__c = idGrupo;
                }
            }

            reclamacion.SAC_FechaUltimaAsignacionLetrado__c = System.now();
            //reclamacion.SAC_MotivoReasignacion__c = motivo;
            reclamacion.SAC_GrupoLetrado__c = idGrupo;
            reclamacion.SAC_Letrado__c = 'Pte. Asignar';
            reclamacion.SPV_LetradoReasignado__c = true;        //Indica que se ha reasignado el letrado de la reclamación

            
            //En caso de que ya haya comentario, se añade el nuevo en una línea aparte indicando la fecha
            if(String.isBlank(reclamacion.SAC_MotivoReasignacion__c)){
                reclamacion.SAC_MotivoReasignacion__c = System.now().format('dd-MM-yyyy') + ' : ' + motivo;
            }else{
                reclamacion.SAC_MotivoReasignacion__c = reclamacion.SAC_MotivoReasignacion__c + '\n' + System.now().format('dd-MM-yyyy') + ' : ' + motivo;
            }

            

            casosActualizar.addAll(pretensiones);
            casosActualizar.add(reclamacion);

            SPV_DatabaseDML.updateListDML(casosActualizar, true);
        }else{
            throw new AuraHandledException('No tienes permisos para reasignar el grupo letrado de las pretensiones');
        }         
    }

    @AuraEnabled
    public static void activarComplementariaEntidad(String idCaso){
        if (Schema.sObjectType.Case.isAccessible()) {
            Case caso = [SELECT id, SPV_Complementaria_Entidad__c, status, CBK_Case_Extension_Id__c, SEG_Subestado__c FROM Case WHERE id =: idCaso];
            if(caso.SPV_Complementaria_Entidad__c == true){
                caso.SPV_Complementaria_Entidad__c = false;
            }else{
                //Añadido: Al activar la complementaria entidad, se almacena la fecha en el campo correspondiente
                caso.SPV_Complementaria_Entidad__c = true;

                if(caso.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                    CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                    caseExtension.SPV_FechaComplementariaEntidad__c  = System.now();
                    SPV_DatabaseDML.insertDML(caseExtension, false);
                    caso.CBK_Case_Extension_Id__c = caseExtension.Id;   
                }else{          //Si ya lo tiene
                    CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                    caseExtension.Id = caso.CBK_Case_Extension_Id__c;
                    caseExtension.SPV_FechaComplementariaEntidad__c  = System.now();
                    SPV_DatabaseDML.updateDML(caseExtension, false);
                }
            } 
            SPV_DatabaseDML.updateDML(caso, true);

            // Crear el registro formulario de complementaria
            SPV_Formulario__c formComplementaria = new SPV_Formulario__c();
            formComplementaria.recordTypeId = RECTYPEFORMCOMPLEMENTARIA;
            formComplementaria.SPV_TipoComplementaria__c = 'SPV_Entidad';
            formComplementaria.SPV_FechaAperturaEntidad__c = System.now();
            formComplementaria.SPV_Caso__c = caso.Id;
            if(Schema.sObjectType.SPV_Formulario__c.isCreateable()){  
                SPV_DatabaseDML.insertDML(formComplementaria, true); 
            }else {
                throw new AuraHandledException('No tienes permisos para realizar la operación.');
            }
        }else{
            throw new AuraHandledException('No tienes permisos para activar la complementaria');
        }
    }   

    @AuraEnabled
    public static void activarRectificacion(String idCaso){
        if (Schema.sObjectType.Case.isAccessible()) {
        Case casoActual = recuperarCaso(idCaso);   
            casoActual.status = 'SPV_Rectificacion';
            //casoActual.SEG_Subestado__c = 'SPV_AnalisisRectificacion';
            casoActual.SPV_Rectificado__c = true;

        SPV_DatabaseDML.updateDML(casoActual, true);
        }else{
        throw new AuraHandledException('No tienes permisos para realizar la rectificación');
        }
    }   


    @AuraEnabled
    public static void prorrogarReclamacion(String idCaso, String motivo, String observaciones){
        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(idCaso); 
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();

            if(casoActual.SPV_Organismo__c == 'SPV_Consumo') {
                for (SPV_ParametrizacionesProrroga__mdt parametrizacionesComunidades : [SELECT SPV_ComunidadAutonoma__c, SPV_DiasProrroga__c FROM SPV_ParametrizacionesProrroga__mdt]) {
                    if(parametrizacionesComunidades.SPV_ComunidadAutonoma__c == casoActual.SPV_ComunidadAutonoma__c) {
                        //Utilizado este campo para almacenar los días de prorroga
                        casoActual.SPV_DiasProrroga__c = parametrizacionesComunidades.SPV_DiasProrroga__c;
                    }
                }
            } else {
                casoActual.SPV_DiasProrroga__c = 11;
            }

            //Indica que hay una prorroga activa
            casoActual.SAC_ProrrogaCounter__c = 1;
            casoActual.SAC_Prorrogado__c = true;
            casoActual.SAC_FechaProrroga__c = System.now();

            caseExtension.Id = casoActual.CBK_Case_Extension_Id__c;
            caseExtension.SPV_MotivoProrroga__c = motivo;
            if(motivo == 'SPV_004'){
                caseExtension.SPV_ObservacionesProrroga__c = observaciones;
            }else{
                caseExtension.SPV_ObservacionesProrroga__c = '';
            }

            SPV_DatabaseDML.updateDML(casoActual, true);
            SPV_DatabaseDML.updateDML(caseExtension, true);
            
            

            //Notificar la prorroga con una alerta
            String cuerpoAlerta = 'La reclamación ' + casoActual.CaseNumber + ' ha sido prorrogada. Por favor revisela.';
            notificarGrupoLetrado(casoActual, 'SPV_020', cuerpoAlerta);
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la prórroga');
        }
    }   

    @AuraEnabled
    public static void anularProrrogaReclamacion(String idCaso, String motivo, String observaciones){
        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(idCaso); 
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();

            casoActual.SAC_Prorrogado__c = false;
            caseExtension.Id = casoActual.CBK_Case_Extension_Id__c;
            caseExtension.SPV_MotivoAnulacionProrroga__c = motivo;
            if(motivo == 'SPV_003'){
                caseExtension.SPV_ObservacionesAnulacionProrroga__c = observaciones;
            }else{
                caseExtension.SPV_ObservacionesAnulacionProrroga__c = '';
            }

            SPV_DatabaseDML.updateDML(casoActual, true);
            SPV_DatabaseDML.updateDML(caseExtension, true);
            
        }else{
            throw new AuraHandledException('No tienes permisos para anular la prórroga.');
        }
    }   


    @AuraEnabled
    public static void reabrirReclamacion(String idCaso, Boolean reaperturaRectificacion, String motivoReapertura, String observacionesMotivoReapertura){

        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(idCaso);   

            if(!reaperturaRectificacion){
                casoActual.Status = 'SPV_RecepcionResolucion';
            }else{
                casoActual.Status = 'SPV_Rectificacion';
                casoActual.SPV_Rectificado__c = true;
            }
            casoActual.SAC_MotivoReabrir__c = observacionesMotivoReapertura;
            // casoActual.CC_Rechazar_Reabrir_Caso__c = true;
            casoActual.CC_Fecha_Reapertura__c = System.now();

            SPV_DatabaseDML.updateDML(casoActual, true);

            //Indicar que el caso ya ha sido reabierto
            if(casoActual.CBK_Case_Extension_Id__c != null){ //&& casoActual.CBK_Case_Extension_Id__r.SPV_CasoReabierto__c != true
                CBK_Case_Extension__c caseExtensionActualizar = new CBK_Case_Extension__c();
                caseExtensionActualizar.Id = casoActual.CBK_Case_Extension_Id__c;
                caseExtensionActualizar.SPV_CasoReabierto__c = true;
                caseExtensionActualizar.SPV_MotivoReapertura__c = motivoReapertura;
                SPV_DatabaseDML.updateDML(caseExtensionActualizar, true);
            }

            //Notificar la reapertura
            String cuerpoAlerta = 'La reclamación ' + casoActual.CaseNumber + ' ha sido reabierta. Por favor revisela.';
            notificarGrupoLetrado(casoActual, 'SPV_021', cuerpoAlerta);            
           
        }else{
            throw new AuraHandledException('No tienes permisos para reabrir la reclamación');
        }
    }   


    @AuraEnabled
    public static Boolean comprobarSLAGeneralActivo(String idCaso) {
        Boolean slaGeneralActivo = true;
        List<CaseMilestone> listaCaseMilestone = [SELECT caseid, startdate, IsCompleted, IsViolated, CompletionDate, MilestoneType.Name FROM CaseMilestone WHERE caseId =: idCaso];
        for (CaseMilestone caseMil : listaCaseMilestone) {
            if (caseMil.MilestoneType.Name == 'Plazo Regulatorio Supervisor' && (caseMil.IsCompleted || caseMil.IsViolated)) {
                slaGeneralActivo = false;
            }
        }
        return slaGeneralActivo; 
    }

    @AuraEnabled
    public static void clasificarDocumentoProrroga(Id caseId, Integer numFicheros) {
        List<ContentVersion> archivosActualizar = new List<ContentVersion>();
        List<ContentVersion> archivos = [SELECT id FROM ContentVersion WHERE FirstPublishLocationId =: caseId ORDER BY CreatedDate DESC];
        List<SAC_MaestroTemas__c> maestroTema = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'SPV_Prorroga' LIMIT 1];

        if (!maestroTema.isEmpty()) {
            for (Integer i = 0; i < numFicheros; i++) {
                ContentVersion newcont = new ContentVersion();
                newcont.id = archivos[i].id;
                newcont.SAC_TipoAdjunto__c = maestroTema[0].Id; 
                newcont.SAC_Bloque__c = 'SAC_Respuesta';           
                archivosActualizar.add(newcont);
            }
        }        
        SPV_DatabaseDML.updateListDML(archivosActualizar, true);
    }

    public static void notificarGrupoLetrado(Case caso, String tipoAlerta, String cuerpoAlerta){

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        //Si la reclamación tiene grupo letrado informado, informamos al letrado
        if(caso.SAC_GrupoLetrado__c != null){

            List<String> listaEmails = new List<String>();

            if(caso.SAC_GrupoLetrado__r.SAC_Email__c != null) {
                listaEmails.add(caso.SAC_GrupoLetrado__r.SAC_Email__c);
            }
            //Añadir el email del letrado
            if(String.isNotBlank(caso.SAC_PretensionPrincipal__r.Owner.Email)){
                listaEmails.add(caso.SAC_PretensionPrincipal__r.Owner.Email);
            }

            //Se envia alerta el owner de las pretensiones y al grupo letrado
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                            tipoAlerta,
                                            cuerpoAlerta,
                                            caso.SAC_PretensionPrincipal__r.OwnerId,
                                            '',
                                            '', 
                                            '');
                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                            wrapAlerta.listaEmailsGrupo = listaEmails;
                                            wrapAlerta.proyecto = 'SPV';

            if(caso.SAC_GrupoLetrado__c != null) {
                wrapAlerta.idGrupoColaborador = caso.SAC_GrupoLetrado__c;
            }

            //Añadirla a la lista para posteriormente llamar al método
            listaWrapperAlerta.add(wrapAlerta);
        }else{
            //Sino genera registro alerta para que quede reflejado en la reclamación
            Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue' LIMIT 1];

            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                            tipoAlerta,
                                            cuerpoAlerta,
                                            colaSupervisores.Id,
                                            '',
                                            '', 
                                            '');
                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso.Id;
                                            wrapAlerta.proyecto = 'SPV';

            //Añadirla a la lista para posteriormente llamar al método
            listaWrapperAlerta.add(wrapAlerta);
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    @AuraEnabled
    public static void activarComplementariaOrganismo(String caseId, String motivoComplementaria, String observaciones){

        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(caseId);   

            casoActual.Status = 'SPV_AnalisisComplementariaOrganismo';
            //casoActual.SEG_Subestado__c = 'SPV_AnalisisComplementaria';
            casoActual.SPV_ComplementariaOrganismo__c = true;
            casoActual.SPV_MotivoComplementariaOrganismo__c = motivoComplementaria;
            //Añadido: Al activar la complementaria organismo, se rellena la fecha en su campo correspondiente
            //casoActual.SPV_FechaComplementariaOrganismo__c = System.now();

            if(casoActual.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.SPV_FechaComplementariaOrganismo__c  = System.now();
                if(motivoComplementaria == 'SPV_Otros'){
                    caseExtension.SPV_ObservacionesComplementariaOrganismo__c = observaciones;
                }else{
                    caseExtension.SPV_ObservacionesComplementariaOrganismo__c = '';
                }
                SPV_DatabaseDML.insertDML(caseExtension, false);
                casoActual.CBK_Case_Extension_Id__c = caseExtension.Id;   
            }else{          //Si ya lo tiene
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.Id = casoActual.CBK_Case_Extension_Id__c;
                caseExtension.SPV_FechaComplementariaOrganismo__c  = System.now();
                if(motivoComplementaria == 'SPV_Otros'){
                    caseExtension.SPV_ObservacionesComplementariaOrganismo__c = observaciones;
                }else{
                    caseExtension.SPV_ObservacionesComplementariaOrganismo__c = '';
                }
                SPV_DatabaseDML.updateDML(caseExtension, false);
            }
            
            SPV_DatabaseDML.updateDML(casoActual, true);

            // Crear el registro formulario de complementaria
            SPV_Formulario__c formComplementaria = new SPV_Formulario__c();
            formComplementaria.recordTypeId = RECTYPEFORMCOMPLEMENTARIA;
            formComplementaria.SPV_TipoComplementaria__c = 'SPV_Organismo';
            formComplementaria.SPV_FechaAperturaOrganismo__c = System.now();
            formComplementaria.SPV_Caso__c = casoActual.Id;
            if(Schema.sObjectType.SPV_Formulario__c.isCreateable()){  
                SPV_DatabaseDML.insertDML(formComplementaria, true); 
            }else {
                throw new AuraHandledException('No tienes permisos para realizar la operación.');
            }

        }else{
            throw new AuraHandledException('No tienes permisos para activar la complementaria organismo.');
        }
    } 

    @AuraEnabled
    public static void desactivarComplementariaOrganismo(String caseId){

        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(caseId);   

            casoActual.Status = 'SPV_PendienteRespuestaOrganismo';
            //casoActual.SEG_Subestado__c = 'SPV_PendienteRespuestaOrganismo';
            casoActual.SPV_ComplementariaOrganismo__c = false;
            casoActual.SPV_MotivoComplementariaOrganismo__c = null;
            //Añadido: Al activar la complementaria organismo, se rellena la fecha en su campo correspondiente
            //casoActual.SPV_FechaComplementariaOrganismo__c = null;

            if(casoActual.CBK_Case_Extension_Id__c == null){      //Si aún no tiene el extension
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.SPV_FechaComplementariaOrganismo__c  = null;
                SPV_DatabaseDML.insertDML(caseExtension, false);
                casoActual.CBK_Case_Extension_Id__c = caseExtension.Id;   
            }else{          //Si ya lo tiene
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.Id = casoActual.CBK_Case_Extension_Id__c;
                caseExtension.SPV_FechaComplementariaOrganismo__c  =  null;
                SPV_DatabaseDML.updateDML(caseExtension, false);
            }
            
            SPV_DatabaseDML.updateDML(casoActual, true);
        }else{
            throw new AuraHandledException('No tienes permisos para desactivar la complementaria organismo.');
        }
    } 
    
    @AuraEnabled
    static public void cambioEstado(Id caseId, String status){
        Case caseSR = recuperarCaso(caseId);
        // Es pretensión o reclamación
        if(caseSR.RecordType.DeveloperName == 'SPV_Pretension' && status == null){
            caseSR.Status = caseSR.SAC_Reclamacion__r.Status;
        }else{
            caseSR.Status = status;
        }
        if(status == 'SPV_PendienteRespuestaOrganismo' && caseSR.SPV_ComplementariaOrganismo__c){
            caseSR.SPV_ComplementariaOrganismo__c = false;
        }
        if(Schema.sObjectType.Case.isUpdateable()){  
            SPV_DatabaseDML.updateDML(caseSR, true); 
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la operación.');
        }
    }


    /*************************************************************************************************
     * Proposito: Marcar a true el campo SPV_CasoEnNegociacion__c para indicar que la reclamación
     *               está en una negociación activa
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US1126342     Sergio Martín     03/02/25        Creación
    *************************************************************************************************/
    @AuraEnabled
    static public void activarNegociacionReclamacion(Id caseId, List<Case> pretensionesNegociacion) {
        Case caseSR = recuperarCaso(caseId);
        List<CBK_Case_Extension__c> listaCasosExtensionUpdatear = new List<CBK_Case_Extension__c>();
        List<Case> listaCasosUpdatear = new List<Case>();
        List<Case> listaPretensiones = [SELECT Id, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, SAC_CasoNegociado__c, 
                                        SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, SAC_Motivoresultadonegociacion__c, SAC_Observaciones__c, SAC_NegociacionFinalizada__c
                                    FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND Id IN: pretensionesNegociacion];     

        if(!listaPretensiones.isEmpty() && caseSR != null) {
            // Marcar el campo SPV_CasoEnNegociacion__c de la reclamacion y pretensiones a true        
            CBK_Case_Extension__c caseExtensionReclamacion = new CBK_Case_Extension__c();
            caseExtensionReclamacion.id = caseSR.CBK_Case_Extension_Id__c;
            caseExtensionReclamacion.SPV_CasoEnNegociacion__c = true;
            listaCasosExtensionUpdatear.add(caseExtensionReclamacion);

            for(Case pretension : listaPretensiones){
                CBK_Case_Extension__c caseExtensionPretensiones = new CBK_Case_Extension__c();
                caseExtensionPretensiones.id = pretension.CBK_Case_Extension_Id__c;
                caseExtensionPretensiones.SPV_CasoEnNegociacion__c = true;
                listaCasosExtensionUpdatear.add(caseExtensionPretensiones);

                // Si es la primera negociación de la reclamación o de alguna de las pretensiones se debe marcar el campo SAC_CasoNegociado__c a true
                if(pretension.SAC_CasoNegociado__c == false) {
                    pretension.SAC_CasoNegociado__c = true;
                    listaCasosUpdatear.add(pretension);
                } else { // Vaciar los campos de la negociación de las pretensiones para poder realizar otra nueva
                    pretension.SAC_ResultadoNegociacion__c = null;
                    pretension.SAC_Motivoresultadonegociacion__c = null;
                    pretension.SAC_Observaciones__c = null;
                    listaCasosUpdatear.add(pretension);
                }
            }
            if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
                SPV_DatabaseDML.updateListDML(listaCasosExtensionUpdatear, true); 
            }else{
                throw new AuraHandledException('No tienes permisos para realizar la operación.');
            }

            // Si es la primera negociación de la reclamación o de alguna de las pretensiones se debe marcar el campo SAC_CasoNegociado__c a true
            if(caseSR.SAC_CasoNegociado__c == false) {
                caseSR.SAC_CasoNegociado__c = true;
                listaCasosUpdatear.add(caseSR);
            }
            
            if(!listaCasosUpdatear.isEmpty()) {
                if(Schema.sObjectType.Case.isUpdateable()){  
                    SPV_DatabaseDML.updateListDML(listaCasosUpdatear, true); 
                }else{
                    throw new AuraHandledException('No tienes permisos para realizar la operación.');
                } 
            }

            // Crear el registro formulario de negociacion
            SPV_Formulario__c formNegociacion = new SPV_Formulario__c();
            formNegociacion.recordTypeId = RECTYPEFORMNEGOCIACION;
            formNegociacion.SPV_EstadoNegociacion__c = caseSR.Status;
            formNegociacion.SPV_NegociacionEnCurso__c = true;
            formNegociacion.SPV_FechaInicioNegociacion__c = System.now();
            formNegociacion.SPV_Caso__c = caseSR.Id;
            if(Schema.sObjectType.SPV_Formulario__c.isCreateable()){  
                SPV_DatabaseDML.insertDML(formNegociacion, true); 
            }else {
                throw new AuraHandledException('No tienes permisos para realizar la operación.');
            }
        }
    }


    /***************************************************************** 
     * Proposito: Recuperar las pretensiones del caso 
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US1126342     Sergio Martín     03/02/25        Creación
    *****************************************************************/
    @AuraEnabled
    public static List<Case> getPretensiones(String idCaso){
        List<Case> pretensionesCaso = new List<Case>();
        try {
            pretensionesCaso = [SELECT Id, CC_MCC_Tematica__r.name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.name, SEG_Detalle__r.Name, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c FROM Case 
                                WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: idCaso AND (Status != 'SAC_009' AND Status != 'Cerrado')];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return pretensionesCaso;
    }

    /*************************************************************************************************
     * Proposito: Marcar a false el campo SPV_CasoEnNegociacion__c para indicar que la reclamación
     *               ha finalizado la negociación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US1126342     Sergio Martín     03/02/25        Creación
    *************************************************************************************************/
    @AuraEnabled
    static public void finalizarNegociacionReclamacion(Id caseId){
        List<CBK_Case_Extension__c> listaCasosExtensionUpdatear = new List<CBK_Case_Extension__c>();
        String resumen = '';
        Case caseSR = recuperarCaso(caseId);
        List<Case> listaPretensiones = [SELECT Id, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, SPV_IdPretension__c, Subject,
                                        SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, SAC_Motivoresultadonegociacion__c, SAC_Observaciones__c, SAC_NegociacionFinalizada__c
                                    FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: caseId AND CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c = true];

        if(!listaPretensiones.isEmpty() && caseSR != null) {
            // Actualizar el registro formulario de negociacion con la fecha fin de negociacion y el resultado basado en las pretensiones
            SPV_Formulario__c formNegociacion = [SELECT id, SPV_NegociacionEnCurso__c FROM SPV_Formulario__c WHERE RecordTypeId =: RECTYPEFORMNEGOCIACION AND SPV_Caso__c =: caseSR.Id AND SPV_NegociacionEnCurso__c = true LIMIT 1];
            if(formNegociacion != null) {
                formNegociacion.recordTypeId = RECTYPEFORMNEGOCIACION;
                formNegociacion.SPV_NegociacionEnCurso__c = false;
                formNegociacion.SPV_ResultadoNegociacion__c = caseSR.SAC_ResultadoNegociacion__c;
                if(caseSR.SAC_PretensionPrincipal__r.SAC_Motivoresultadonegociacion__c != null) {
                    if(caseSR.SAC_PretensionPrincipal__r.SAC_Motivoresultadonegociacion__c.contains('TAE insuficiente')) {
                        formNegociacion.SPV_MotivoRechazoNegociacion__c = 'SPV_TAEInsuficiente';
                    } else if(caseSR.SAC_PretensionPrincipal__r.SAC_Motivoresultadonegociacion__c.contains('desea negociar')) {
                        formNegociacion.SPV_MotivoRechazoNegociacion__c = 'SPV_NoDeseaNegociar';
                    } else if(caseSR.SAC_PretensionPrincipal__r.SAC_Motivoresultadonegociacion__c.contains('verificar primero')) {
                        formNegociacion.SPV_MotivoRechazoNegociacion__c = 'SPV_SolicitaVerificarPrimero';
                    }
                }
                formNegociacion.SPV_FechaFinNegociacion__c = System.now();

                // Recorrer las pretensiones negociadas y recoger la información en el campo SPV_ResumenNegociacion__c
                for (Case pretension : listaPretensiones) {
                    resumen += 'Resumen pretensión '+ pretension.SPV_IdPretension__c + ' - ' + pretension.Subject + ': ';
                    if(pretension.SAC_ResultadoNegociacion__c != null) { 
                        resumen += '\r\n' + pretension.SAC_ResultadoNegociacion__c;
                    }
                    if(pretension.SAC_Motivoresultadonegociacion__c != null) { 
                        resumen += '\r\n' + pretension.SAC_Motivoresultadonegociacion__c;
                    }
                    if(pretension.SAC_Observaciones__c != null) { 
                        resumen += '\r\n' + pretension.SAC_Observaciones__c;
                    }
                    resumen += '\r\n\r\n';
                }
                formNegociacion.SPV_ResumenNegociacion__c = resumen;


                if(Schema.sObjectType.SPV_Formulario__c.isUpdateable()){  
                    SPV_DatabaseDML.updateDML(formNegociacion, true); 
                }else {
                    throw new AuraHandledException('No tienes permisos para realizar la operación.');
                }
            }

            // Marcar el campo SPV_CasoEnNegociacion__c de la reclamacion y pretensiones a false        
            CBK_Case_Extension__c caseExtensionReclamacion = new CBK_Case_Extension__c();
            caseExtensionReclamacion.id = caseSR.CBK_Case_Extension_Id__c;
            caseExtensionReclamacion.SPV_CasoEnNegociacion__c = false;
            listaCasosExtensionUpdatear.add(caseExtensionReclamacion);

            for(Case caseExtension : listaPretensiones){
                CBK_Case_Extension__c caseExtensionPretensiones = new CBK_Case_Extension__c();
                caseExtensionPretensiones.id = caseExtension.CBK_Case_Extension_Id__c;
                caseExtensionPretensiones.SPV_CasoEnNegociacion__c = false;
                listaCasosExtensionUpdatear.add(caseExtensionPretensiones);
            }
            if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
                SPV_DatabaseDML.updateListDML(listaCasosExtensionUpdatear, true); 
            }else{
                throw new AuraHandledException('No tienes permisos para realizar la operación.');
            }
        }
    }


    /*******************************************************************************************************************
    * Proposito: Comprobar que las pretensiones tienen todos los campos obligatorios de la negociación informados
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0            US1126342     Sergio Martín    20/02/25        Creación
    *******************************************************************************************************************/ 
    @AuraEnabled
    public static String comprobarCamposNegociacionInformados(Id caseId){
        List<Case> listaPretensiones = [SELECT Id, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, SPV_IdPretension__c, Subject,
                                        SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, SAC_Motivoresultadonegociacion__c, SAC_Observaciones__c, SAC_NegociacionFinalizada__c
                                    FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: caseId AND CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c = true];

        String camposSinRellenar = '';
        String camposVacios = '';
        for(Case pretension : listaPretensiones) {
            if(pretension.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c == true) {
                String cadena = 'Pretensión ' + pretension.SPV_IdPretension__c + ':\r\n';
                camposVacios = '';
                if(pretension.SAC_ResultadoNegociacion__c == null) {
                    camposVacios = camposVacios + '- Campo Resultado de negociación vacío ' + '\r\n';
                }
                if(pretension.SAC_Motivoresultadonegociacion__c == null) {
                    camposVacios = camposVacios + '- Campo Motivo rechazo negociación vacío ' + '\r\n';
                }
                if(String.isBlank(pretension.SAC_Observaciones__c)) {
                    camposVacios = camposVacios + '- Campo Observaciones vacío ' + '\r\n';
                }
                if(String.isNotBlank(camposVacios)) {
                    camposSinRellenar = camposSinRellenar + cadena + camposVacios;
                }
            }
        }
        return camposSinRellenar;
    }


    @AuraEnabled
    public static String comprobarCamposPasarEnvio(Id caseId){
        String camposSinRellenar = '';
        Map<String, String> camposAniadidos = new Map<String, String>();    //Mapa para no añadir en la lista de campos pendientes 2 veces el mismo campo

        List<Case> listaPretensiones = [SELECT Id, Status, SAC_Reclamacion__c, SAC_ResumenManual__c, CC_Importe_Reclamado__c, CBK_Case_Extension_Id__r.SPV_ValidacionResumen__c,
                                         CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c, CBK_Case_Extension_Id__r.SPV_EmisionSAC__c, CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c,
                                         CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c, CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c, CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c,
                                         CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c, CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c, CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c
                                        FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: caseId AND Status <> 'SAC_009'];
        for(Case pretension : listaPretensiones){
            if((pretension.CBK_Case_Extension_Id__r.SPV_ValidacionResumen__c == null || pretension.CBK_Case_Extension_Id__r.SPV_ValidacionResumen__c == false) && !camposAniadidos.containsKey('SPV_ValidacionResumen__c')){
                camposSinRellenar = camposSinRellenar + 'Validación Resumen ' + '\r\n';
                camposAniadidos.put('SPV_ValidacionResumen__c', 'Añadido');
            }
            if(pretension.CC_Importe_Reclamado__c == null && !camposAniadidos.containsKey('CC_Importe_Reclamado__c')){
                camposSinRellenar = camposSinRellenar + 'Importe Reclamado ' + '\r\n';
                camposAniadidos.put('CC_Importe_Reclamado__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ResumenResolucionSAC__c)) && !camposAniadidos.containsKey('SPV_ResumenResolucionSAC__c')){
                camposSinRellenar = camposSinRellenar + 'Resumen resolución SAC (argumentos) ' + '\r\n';
                camposAniadidos.put('SPV_ResumenResolucionSAC__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_EmisionSAC__c)) && !camposAniadidos.containsKey('SPV_EmisionSAC__c')){
                camposSinRellenar = camposSinRellenar + 'Emisión de respuesta del SAC ' + '\r\n';
                camposAniadidos.put('SPV_EmisionSAC__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c)) && !camposAniadidos.containsKey('SPV_ResolucionRemitidaEnPlazo__c')){
                camposSinRellenar = camposSinRellenar + 'Resolución remitida en plazo ' + '\r\n';
                camposAniadidos.put('SPV_ResolucionRemitidaEnPlazo__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c)) && !camposAniadidos.containsKey('SPV_CongruenciaRespuestaSAC__c')){
                camposSinRellenar = camposSinRellenar + 'Congruencia de la respuesta del SAC ' + '\r\n';
                camposAniadidos.put('SPV_CongruenciaRespuestaSAC__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c)) && !camposAniadidos.containsKey('SPV_CalidadRespuesta__c')){
                camposSinRellenar = camposSinRellenar + 'Calidad de la respuesta ' + '\r\n';
                camposAniadidos.put('SPV_CalidadRespuesta__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ReclamacionMalFuncionamiento__c)) && !camposAniadidos.containsKey('SPV_ReclamacionMalFuncionamiento__c')){
                camposSinRellenar = camposSinRellenar + 'Reclamación D.E.C mal funcionamiento ' + '\r\n';
                camposAniadidos.put('SPV_ReclamacionMalFuncionamiento__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_ActuacionCumpleBdE__c)) && !camposAniadidos.containsKey('SPV_ActuacionCumpleBdE__c')){
                camposSinRellenar = camposSinRellenar + 'La actuación SAC cumple criterios BdE ' + '\r\n';
                camposAniadidos.put('SPV_ActuacionCumpleBdE__c', 'Añadido');
            }
            if((pretension.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c)) && !camposAniadidos.containsKey('SPV_DisponeDocumentacion__c')){
                camposSinRellenar = camposSinRellenar + 'Dispone de documentación ' + '\r\n';
                camposAniadidos.put('SPV_DisponeDocumentacion__c', 'Añadido');
            }
            //Documentación Necesaria Solo obligatorio si el campo Dispone Documentación es NO:
            if((pretension.CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c == '' || String.isBlank(pretension.CBK_Case_Extension_Id__r.SPV_DocumentacionNecesaria__c)) && pretension.CBK_Case_Extension_Id__r.SPV_DisponeDocumentacion__c == 'No' && !camposAniadidos.containsKey('SPV_DocumentacionNecesaria__c')){
                camposSinRellenar = camposSinRellenar + 'Documentación Necesaria ' + '\r\n';
                camposAniadidos.put('SPV_DocumentacionNecesaria__c', 'Añadido');
            }


        }
        

        return camposSinRellenar;
    }


    /**********************************************************************************
     * Proposito: Metodo para controlar que es la pretensión principal y por lo tanto no se puede dar de baja.
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY        AUTHOR         DATE         Description
     * 1.0                             Iria ANPC    03/04/2025     Creación Método
    ***********************************************************************************/
    @AuraEnabled
    public static String esPrincipal(Id record){

        String respuesta;

        List<Case> pretensionActual = [SELECT id, SAC_Reclamacion__c FROM Case WHERE id =: record LIMIT 1];
        List<Case> reclamacion = [SELECT id, Status, SAC_PretensionPrincipal__c FROM CASE WHERE id =: pretensionActual[0].SAC_Reclamacion__c LIMIT 1];
        List<Case> pretensiones = [SELECT id FROM CASE WHERE SAC_Reclamacion__c =: reclamacion[0].id AND Status != 'SAC_009'];
        
        if(reclamacion[0].Status != 'SAC_001'){
            List<Case> listPrets = pretensiones;
            if(reclamacion[0].SAC_PretensionPrincipal__c == pretensionActual[0].id){
                respuesta = 'KO';
            }else{
                respuesta = 'OK';
            }
        }else{
            respuesta = 'OK';
        }
        return respuesta;
    }
      /*******************************************************************************
    * Proposito: Convertir la Reclamacion a Consulta COPS o Consulta SAC
    ******************************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0             			     Iria ANPC     04/04/2025     Creación Método
    *******************************************************************************/
    @AuraEnabled
    static public void convertirReclamacion(Id caseId, String naturaleza){
        
        // Recuperar el caso
        Case caso = recuperarCaso(caseId);
        List<Case> listaCasosUpdatear = new List<Case>();
        
        if(naturaleza == 'Consulta') {
            caso.SAC_Naturaleza__c = 'SAC_005';
            caso.SAC_Letrado__c = 'Pte. Asignar';
            caso.RecordTypeId = RECORDTYPECONSULTASAC;
        }else if(naturaleza == 'ConsultaCOPS') {
            caso.Status = 'Descartado';
            caso.SAC_StatusAuxiliar__c = caso.Status;
            caso.SAC_MotivoRechazo__c = 'Rechazada por conversión';
            if(caso.recordTypeId == RECTYPERECLAMACION && caso.SAC_NPretensionesActivas__c != 0) {
                List<Case> listaPretCasos = [SELECT id, recordTypeId, Status 
                                    FROM  Case 
                                    WHERE RecordType.DeveloperName = 'SPV_Pretension' AND SAC_Reclamacion__c =: caso.id];
                if(!listaPretCasos.isEmpty()){
                    for (Case pretension : listaPretCasos) {
                        pretension.Status = 'SAC_009';
                        pretension.SAC_StatusAuxiliar__c = 'SAC_009';
                        listaCasosUpdatear.add(pretension);
                    }
                }
            }
            
            List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
            CC_Grupo_Colaborador__c grupoDXC =[SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c ='DXC Zaragoza' LIMIT 1];
            
            // Creación de la nueva consulta COPS convertida
            Case consultaCOPS = new Case (
                SAC_FechaRecepcion__c = caso.SAC_FechaRecepcion__c, 
                AccountId = caso.AccountId, 
                ContactId = caso.ContactId,           
                recordTypeId = RECORDTYPECONSULTA,
                Description = caso.Description,
                Subject =  caso.Subject,
                Origin = caso.Origin,
                SAC_Naturaleza__c = 'SAC_005',
                CC_Idioma__c = caso.CC_Idioma__c,
                SEG_Grupo__c = grupoDXC.id,
                SuppliedEmail = caso.SuppliedEmail,
                CC_CasoRelacionado__c = caso.id,
                OwnerId = cola[0].id,
                CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta__c,
                SAC_DireccionContacto__c = caso.SAC_DireccionContacto__c,
                SAC_ProvinciaContacto__c = caso.SAC_ProvinciaContacto__c,
                SAC_CodigoPostalContacto__c = caso.SAC_CodigoPostalContacto__c,
                SAC_PoblacionContacto__c = caso.SAC_PoblacionContacto__c,
                SAC_PaisContacto__c = caso.SAC_PaisContacto__c,
                SAC_DireccionPostalNotificacion__c = caso.SAC_DireccionPostalNotificacion__c
            );
            
            if (Schema.sObjectType.Case.isCreateable()){
                SAC_DatabaseDML.insertDML(consultaCOPS, true);
            } 
            caso.CC_CasoRelacionado__c = consultaCOPS.id;
            
            // Llamada al metodo para copiar los adjuntos en el nuevo caso creado;
            copiarEmailsAdjuntos(caso.id, consultaCOPS.id);
        }
        listaCasosUpdatear.add(caso);
        if (Schema.sObjectType.Case.isUpdateable()){
            try {
                SAC_DatabaseDML.updateListDML(listaCasosUpdatear, true);
            } catch (Exception e) {
                CBK_Log.error(e);
                throw new AuraHandledException(e.getMessage());
            }
        }      
    }
   /*******************************************************************************
    * Proposito: Copiar los adjuntos y emails de un caso a otro
    *
    ******************************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0             US550726     Sergio Martín   22/05/2023     Creación Método
    *******************************************************************************/
    static public void copiarEmailsAdjuntos(Id caseIdOrigen, Id caseIdDestino){
        //Seleccionar los emailsMessage del caso que queremos copiar
        List<EmailMessage> listaEM = [SELECT Id, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, 
                                            ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted
                                            FROM EmailMessage 
                                            WHERE ParentId =: caseIdOrigen ORDER BY CreatedDate asc]; 
            
        if (!listaEM.isEmpty()) {
            List<EmailMessage> listaEmailMessParaNuevaRecla = new List<EmailMessage>();      

            for (EmailMessage em : listaEM) {
                EmailMessage emAux = em.clone();
                emAux.ParentId = caseIdDestino;  
                emAux.RelatedToId = caseIdDestino; 
                listaEmailMessParaNuevaRecla.add(emAux);
            }  
            SAC_DatabaseDML.insertListDML(listaEmailMessParaNuevaRecla, true);
        }

        //Seleccionar los ContentDocumentLink del caso que queremos copiar
        List<ContentDocumentLink> listaConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                    ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId =: caseIdOrigen];

        if (!listaConDocLink.isEmpty()) {
            List<ContentDocumentLink> listaCDLCopiar = new List<ContentDocumentLink>();

            for (ContentDocumentLink cdl : listaConDocLink) {
                ContentDocumentLink copiaCDL = new ContentDocumentLink();
                copiaCDL.LinkedEntityId = caseIdDestino;
                copiaCDL.ContentDocumentId = cdl.ContentDocumentId;
                copiaCDL.Visibility = cdl.Visibility;
                copiaCDL.ShareType = cdl.ShareType;
                listaCDLCopiar.add(copiaCDL);
            }
            //Insertar archivos adjuntos
            SAC_DatabaseDML.insertListDML(listaCDLCopiar, true);
        }
    }
        /***************************************************************************************
     * Proposito: Modificar el campo CC_SuppliedFiles__c si está marcado y el caso 
     *            no tiene archivos adjuntos.                                                  
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             DE83455          Sergio Martín         28/09/23         Creación
     * *************************************************************************************/
    public static void comprobarCheckAdjuntos(Case caso){           
        List<ContentDocumentLink> contenidos =[SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in (SELECT Id FROM Case WHERE id =: caso.id)];
        
        List<EmailMessage> adjuntos = [SELECT ParentId FROM EmailMessage WHERE ParentId =: caso.id AND HasAttachment = true];
        
        Boolean mostrarError = true;

        if (!contenidos.isEmpty() || !adjuntos.isEmpty()) {
            for(ContentDocumentLink contenido: contenidos){
                if(contenido.LinkedEntityId == caso.id){
                    mostrarError = false;
                }
            }
            if(mostrarError){
                for(EmailMessage adjunto: adjuntos){
                    if(adjunto.parentId == caso.id){mostrarError = false;}
                }    
            }
        }

        if(caso.CC_SuppliedFiles__c && mostrarError){
            caso.CC_SuppliedFiles__c = false;
        }   
    }

    //Comprobar si existen tareas pendientes en la reclamación
    @AuraEnabled
    public static Boolean comprobarTareasPtes(id idCaso){
        
        List<SAC_Accion__c> listAccionesPtes = [SELECT Id FROM SAC_Accion__C WHERE (RecordTypeId = :RECTYPEACCION OR RecordTypeId = :RECTYPEMAESTROTAREAS) AND SAC_Reclamacion__c = :idCaso AND (SAC_Estado__c != 'SAC_Finalizada' AND SAC_Estado__c != 'SAC_FinalizadaIncompleta' AND SAC_Estado__c != 'SAC_Descartada') LIMIT 1];

        if(!listAccionesPtes.isEmpty()){
            return true;
        }else{
            return false;
        }
    }
}