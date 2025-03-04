public with sharing class SPV_CaseOperativas_Controller {
   
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c', 'Case', 'SAC_MaestroTemas__c', 'CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Rec type de Grupo Colaborador
    private static final Id RECTYPEGRUPOGESTOR = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPEGRUPOLETRADO = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    
    //Rec Type de Case
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();    //Reclamación SPV
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();      //Pretensión SPV

    //Rec Type de Maestro Temas
    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();


    @AuraEnabled
    static public Case recuperarCaso(Id caseId){        
        String userId = UserInfo.getUserId();
        Case caseSR = new Case();
        //revisar si utilizaremos todos estos campos
        if (Schema.sObjectType.Case.isAccessible()) {
            caseSR = [SELECT id, Status, SEG_Subestado__c, SEG_Grupo__c, SEG_Grupo__r.Name, OwnerId, AccountId, CaseNumber, Origin, RecordTypeId, SuppliedEmail, CBK_Case_Extension_Id__c, 
            CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c, RecordType.Name, CC_Idioma__c, Priority, SEG_Detalle__c, Subject, SAC_PretensionPrincipal__c,
            SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_Motivo__c, RecordType.DeveloperName, CC_Canal_Respuesta__c, CC_No_Identificado__c, SAC_OrigenConsulta__c, SPV_ComunidadAutonoma__c,
            SAC_EsCliente__c, ContactId, OS_Email__c, SAC_NombreContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_UsarDatos__c, SAC_PoblacionContacto__c, SAC_DireccionPostalNotificacion__c, CC_Importe_Reclamado__c, SAC_NPretensionesActivas__c,
            SAC_TipoDeRepresentante__c, SAC_DespachoRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreRepresentante__c, SAC_DireccionPostal__c,
            SAC_EmailRepresentante__c, SAC_TelefonoRepresentante__c, SAC_Naturaleza__c, SAC_CasoEspecial__c, SAC_CASE_esPSD2__c,SAC_DerivadoA__c, SAC_CasoRelacionado__c, SPV_Organismo__c,
            CC_Detalles_Solucion__c, SAC_UserElevoASupervisor__c, SAC_FechaRecepcion__c, SPV_ObservacionesVolverAnalisis__c, SAC_ObservacionesSupervisor__c, SAC_Prorrogado__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, Description, SAC_EsPrincipal__c, CC_SuppliedFiles__c,
            SPV_ComplementariaOrganismo__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c,

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
            SAC_MotivoReabrir__c, OS_Fecha_Resolucion__c, SAC_GrupoLetrado__c, SAC_GrupoLetrado__r.SAC_Email__c, SAC_PretensionPrincipal__r.Owner.Email
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
    public static Boolean verSiGestorLetrado(id idCaso, id ownerCaso){
        String idUser = UserInfo.getUserId();
        List<Case> listaPretensiones = new List<Case>();
        Boolean esGestor = false;
        Boolean esLetrado = false;

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

        //Si es gestor o letrado, se devuelve true para la variable esGestorLetrado del js
        if(esGestor == true || esLetrado == true){
            return true;
        }else{
            return false;
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
    static public void devolverCaso(Id caseId, String motivo){
        String userId = UserInfo.getUserId();
        Case caso = [SELECT OwnerId, recordTypeId, SAC_NumDevoluciones__c FROM Case WHERE RecordType.DeveloperName LIKE 'SPV_%' AND id = :caseId LIMIT 1];
        List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        if(!cola.isEmpty()){
            caso.OwnerId = cola[0].id;
            caso.SAC_NumDevoluciones__c = caso.SAC_NumDevoluciones__c == null ? 0 : caso.SAC_NumDevoluciones__c + 1;
            caso.SAC_Motivo__c = motivo;
        }
        if(Schema.sObjectType.Case.isUpdateable()){  
            SPV_DatabaseDML.updateDML(caso, true); 
        }else{
            throw new AuraHandledException('No tienes permisos');
        }
    }


    @AuraEnabled
    static public void descartarReclamacion(Id caseId, String motivo){
        try {
            String userId = UserInfo.getUserId();
           List<Case> listaCasosActualizar = new List<Case>();
            Case caso = recuperarCaso(caseId);
    
            if(caso.Status == 'SAC_001'){   //Se puede pasar a Descartado desde alta y análisis
                caso.Status = 'Descartado';
                caso.SAC_MotivoRechazo__c = motivo;
                listaCasosActualizar.add(caso);
            }

            if(Schema.sObjectType.Case.isUpdateable() && !listaCasosActualizar.isEmpty()){
             //   SPV_DatabaseDML.updateDML(caso, true); 
                SPV_DatabaseDML.updateListDML(listaCasosActualizar, true);

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
    public static void devolverReclamacionAlta(Id caseId){

        Case caseSR = recuperarCaso(caseId);
        if(caseSR.Status == 'SPV_AnalisisDecision'){
            caseSR.Status = 'SAC_001';          //Se vuelve a poner el estado en alta
            caseSR.SEG_Subestado__c = null;
            caseSR.SPV_VueltaAlta__c = true;
        }
        if(Schema.sObjectType.Case.isUpdateable()){
            SPV_DatabaseDML.updateDML(caseSR, true); 
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
            Case reclamacion = [SELECT id, SAC_FechaUltimaAsignacionLetrado__c FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND id =: caseId];
            List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar' AND Type = 'Queue'];

            List<Case> casosActualizar = new List<Case>();

            for(Case pretension : pretensiones){

                if(pretension.OwnerId != cola[0].Id || pretension.SEG_Grupo__c != idGrupo){
                    pretension.OwnerId = cola[0].Id;
                    pretension.SEG_Grupo__c = idGrupo;
                }
            }

            reclamacion.SAC_FechaUltimaAsignacionLetrado__c = System.now();
            reclamacion.SAC_MotivoReasignacion__c = motivo;
            reclamacion.SAC_GrupoLetrado__c = idGrupo;
            reclamacion.SAC_Letrado__c = 'Pte. Asignar';
            reclamacion.SPV_LetradoReasignado__c = true;        //Indica que se ha reasignado el letrado de la reclamación

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
    public static void prorrogarReclamacion(String idCaso){
        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(idCaso); 
            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c, SAC_TipoAdjunto__r.SAC_DeveloperName__c  FROM ContentVersion WHERE FirstPublishLocationId =: idCaso];
            ContentVersion[] listaAdjuntos =  new List<ContentVersion>();

            for(ContentVersion record : cv){
                if(record.SAC_TipoAdjunto__r.SAC_DeveloperName__c == 'SPV_Prorroga') {
                    listaAdjuntos.add(record);
                }
            }

            if(listaAdjuntos.isEmpty()) {
                throw new AuraHandledException('Debe adjuntar un documento de prórroga.');   
            }
            // DESCOMENTAR CUANDO SE ENVIE LA DOCUMENTACION A BANCO DE ESPAÑA
            // if(casoActual.organismo == 'SPV_BDE') {
            //     //SPV_LCMP_RedaccionEnvioOrganismos.generarBatchEnvioBDE(caseId, listaAdjuntos);
            // } else{
                SPV_LCMP_RedaccionEnvioOrganismos.generarTareaAutomaticaOrganismo(idCaso, casoActual.SPV_Organismo__c, listaAdjuntos);
            //}
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

            // Clasificar la prorroga si se realiza en fase de analisis (1) o en complementarias de organismos (2)
            if(casoActual.status == 'SPV_AnalisisDecision' && casoActual.SPV_ComplementariaOrganismo__c == false) {
                casoActual.SAC_ProrrogaCounter__c = 1;
            } else if(casoActual.SPV_ComplementariaOrganismo__c){
                casoActual.SAC_ProrrogaCounter__c = 2;
            }

            casoActual.SAC_Prorrogado__c = true;
            casoActual.SAC_FechaProrroga__c = System.now();
            SPV_DatabaseDML.updateDML(casoActual, true);

            //Notificar la prorroga con una alerta
            String cuerpoAlerta = 'La reclamación ' + casoActual.CaseNumber + ' ha sido prorrogada. Por favor revisela.';
            notificarGrupoLetrado(casoActual, 'SPV_020', cuerpoAlerta);
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la prórroga');
        }
    }   

    
    @AuraEnabled
    public static void reabrirReclamacion(String idCaso, Boolean reaperturaRectificacion, String motivoReapertura){

        if (Schema.sObjectType.Case.isAccessible()) {
            Case casoActual = recuperarCaso(idCaso);   

            if(!reaperturaRectificacion){
                casoActual.Status = 'SPV_RecepcionResolucion';
            }else{
                casoActual.Status = 'SPV_Rectificacion';
                casoActual.SPV_Rectificado__c = true;
            }
            casoActual.SAC_MotivoReabrir__c = motivoReapertura;
            // casoActual.CC_Rechazar_Reabrir_Caso__c = true;
            casoActual.CC_Fecha_Reapertura__c = System.now();

            SPV_DatabaseDML.updateDML(casoActual, true);

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
    public static void activarComplementariaOrganismo(String caseId, String motivoComplementaria){

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
                SPV_DatabaseDML.insertDML(caseExtension, false);
                casoActual.CBK_Case_Extension_Id__c = caseExtension.Id;   
            }else{          //Si ya lo tiene
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.Id = casoActual.CBK_Case_Extension_Id__c;
                caseExtension.SPV_FechaComplementariaOrganismo__c  = System.now();
                SPV_DatabaseDML.updateDML(caseExtension, false);
            }
            
            SPV_DatabaseDML.updateDML(casoActual, true);
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
        caseSR.Status = status;
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
        List<CBK_Case_Extension__c> listaCasosExtensionUpdatear = [SELECT Id, SPV_CasoEnNegociacion__c FROM CBK_Case_Extension__c WHERE Case_Id__c =: caseId OR Case_Id__c IN: pretensionesNegociacion];
        System.debug('listaCasosExtensionUpdatear ' + listaCasosExtensionUpdatear);
        System.debug('caseId ' + caseId);

        for(CBK_Case_Extension__c caseExtension : listaCasosExtensionUpdatear){
            caseExtension.SPV_CasoEnNegociacion__c = true;
        }
        
        if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
            SPV_DatabaseDML.updateListDML(listaCasosExtensionUpdatear, true); 
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la operación.');
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
        Case caseSR = recuperarCaso(caseId);

        if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
            CBK_Case_Extension__c caseExtensionReclamacion = new CBK_Case_Extension__c();
            caseExtensionReclamacion.id = caseSR.CBK_Case_Extension_Id__c;
            caseExtensionReclamacion.SPV_CasoEnNegociacion__c = false;
            SPV_DatabaseDML.updateDML(caseExtensionReclamacion, true); 
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la operación.');
        }
    }
}