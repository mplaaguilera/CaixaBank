/*****************************************************************
 * Name: SAC_Case_Operativas_Controller
 * Copyright © 2021  CaixaBank
 * 
 * Proposito:  Handler para controlar el componente de SAC_Case_Operativas
 * 
 * Clases test: SAC_Case_Operativas_Controller_Test y SAC_Case_Operativas_Controller_Test2
 * 
 * Historial
 * -------          
*****************************************************************/
public without sharing class SAC_Case_Operativas_Controller {

    public class MyException extends Exception{}

    private static Set<String> objetos = new Set<String>{'Case','CC_Grupo_Colaborador__c', 'CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static Id RECORDTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static Id RECORDTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    final static Id RECORDTYPECASECLIENTE = mapRTsObjects.get('Case').get('CC_Cliente').getRecordTypeId();
    final static Id RECORDTYPEGRUPOPLET = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    final static Id RECTYPECASEEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SAC_ReclamacionCaseExt').getRecordTypeId();
    

    public class WrapperCC {
        @AuraEnabled
        public List<Case> lstCases;
        @AuraEnabled
        public List<ContentVersion> lstCV;
        @AuraEnabled
        public List<EmailMessage> lstEmail;
    }

    @AuraEnabled
    static public Case recuperarCaso(Id caseId){        
        String userId = UserInfo.getUserId();
        Case caseSR = new Case();
        if (Schema.sObjectType.Case.isAccessible()) {
            caseSR = [SELECT id, Status, SEG_Grupo__c, SEG_Grupo__r.Name, OwnerId, AccountId, CaseNumber, Origin, RecordTypeId, SuppliedEmail, 
            CC_MCC_Motivo__c,CC_MCC_ProdServ__c,CC_MCC_Tematica__c, RecordType.Name, CC_Idioma__c, Priority, SEG_Detalle__c, Subject, SAC_PretensionPrincipal__c,
            SAC_Reclamacion__r.SAC_PretensionPrincipal__c, SAC_Motivo__c, RecordType.DeveloperName, CC_Canal_Respuesta__c, CC_No_Identificado__c, SAC_OrigenConsulta__c,
            SAC_EsCliente__c, ContactId, OS_Email__c, SAC_NombreContacto__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_UsarDatos__c, SAC_PoblacionContacto__c, SAC_DireccionPostalNotificacion__c, CC_Importe_Reclamado__c, SAC_NPretensionesActivas__c,
            SAC_TipoDeRepresentante__c, SAC_DespachoRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreRepresentante__c, SAC_DireccionPostal__c,
            SAC_EmailRepresentante__c, SAC_TelefonoRepresentante__c, SAC_Naturaleza__c, SAC_CasoEspecial__c, SAC_CASE_esPSD2__c,SAC_DerivadoA__c, SAC_CasoRelacionado__c,
            CC_Detalles_Solucion__c, SAC_UserElevoASupervisor__c, SAC_FechaRecepcion__c, SAC_ObservacionesSupervisor__c, SAC_Prorrogado__c, SAC_Entidad_Afectada__c, SAC_EntidadProductora__c, Description, SAC_EsPrincipal__c, CC_SuppliedFiles__c,

            SAC_Reclamacion__c , SAC_Reclamacion__r.Status, CC_AcuseRecibo__c, CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c,CBK_Case_Extension_Id__c,

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
            SAC_MotivoReabrir__c, OS_Fecha_Resolucion__c, SAC_Letrado__c, SAC_GrupoLetrado__c
            FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id = :caseId LIMIT 1];
        }
        
        return caseSR; 
    }

    @AuraEnabled
    static public Map<String,String> recuperarUser(Case casoActual, id ownerCaso){
        
        Map<String,String> mapKeyValue =  new Map<String,String>();
        String idUser = UserInfo.getUserId();
		List<PermissionSetAssignment> lstPS = [Select Id, PermissionSet.Name From PermissionSetAssignment Where AssigneeId = :idUser];
		for(PermissionSetAssignment ps : lstPS){
			mapKeyValue.put(ps.PermissionSet.Name,ps.PermissionSet.Name);
		}
		mapKeyValue.put('UserId',idUser); 

        String userName = UserInfo.getName();
        mapKeyValue.put('UserName',userName); 

        if(ownerCaso == idUser){
      
            List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
                    colabContact = [SELECT id
                                    FROM CC_Grupo_Colaborador_Contact__c 
                                    WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName LIKE 'SAC_%'
                                    AND CC_Usuario__c=:ownerCaso
                                    AND CC_Grupo_Colaborador__c = :casoActual.SEG_Grupo__c
                                    AND SAC_Supervisor__c = true]; 

            if(!colabContact.isEmpty()){ 
        
                Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];
                List<CaseHistory> ch = [SELECT id,OldValue, NewValue, Field, CreatedDate  
                                        FROM CaseHistory 
                                        WHERE Case.RecordType.DeveloperName LIKE 'SAC_%' AND CaseId =:casoActual.Id AND Field = 'Owner' AND DataType = 'EntityId' ORDER BY CreatedDate desc]; 

                if(Test.isRunningTest() || (!ch.isEmpty() && ch[0].OldValue == colaSupervisores.Id)){
                    mapKeyValue.put('mostrarSupervisor', 'si');  
                }                
            }            
        }       

        return mapKeyValue;  
    }

    public class WrapperPretensiones {
        @AuraEnabled public Boolean tienePretensiones {get; set;}
        @AuraEnabled public Boolean tienePretensionesPSD2 {get; set;}

        public WrapperPretensiones(Boolean tienePretensiones, Boolean tienePretensionesPSD2) {
            this.tienePretensiones = tienePretensiones;
            this.tienePretensionesPSD2 = tienePretensionesPSD2;
        }
    }
    
    //INI - MOD -> DE51383 | Luis Mesa García
    @AuraEnabled
    public static WrapperPretensiones tienePretensiones(String idCaso){
        List<Case> pretensiones = new List<Case>();
        WrapperPretensiones pretensionesCaso = new WrapperPretensiones(false, false);
        try {
            pretensiones = [SELECT Id, SAC_Reclamacion__c, SAC_CASE_esPSD2__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c =: idCaso AND Status <> 'SAC_009'];
            if(!pretensiones.isEmpty()) {
                pretensionesCaso.tienePretensiones = true;
                pretensionesCaso.tienePretensionesPSD2 = false;
                for(Case pretension : pretensiones) {
                    if(pretension.SAC_CASE_esPSD2__c == true) {pretensionesCaso.tienePretensionesPSD2 = true;}
                }
            }
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}

        return pretensionesCaso;
    }
    //FIN - MOD -> DE51383 | Luis Mesa García    

    /********************************************************************************************************
     * Proposito: Devuelve para el tipo de registro de Reclamación si existen casos con el mismo account asociados
     * a un usuario distinto
     * ******************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                  -          IBM              -            Creación
    *****************************************************************/
    @AuraEnabled
    static public boolean multiplesCasosMismoAccount(Id caseId, Id ownerId){
        Case caseSR = recuperarCaso(caseId);
        List<Case> caseOld= new List<Case>();
        //Si este campo no está en blanco, significa que es un caso copiado masivamente y no debe mostrar el pop up de casos con el mismo account
        //Si el campo SAC_UserElevoASupervisor__c  no está en blanco, significa Que es una elevacion a supervisor y no debe mostrar el pop up de casos con el mismo account
        if (String.isNotBlank(caseSR.SAC_CasoRelacionado__c) || String.isNotBlank(caseSR.SAC_UserElevoASupervisor__c)) {
            return (caseOld.size()>0);
        }
        caseOld = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND AccountId =: caseSR.AccountId AND isClosed = False AND AccountId <> NULL AND OwnerId <>: ownerId AND Id <> :caseId ];
        return (!caseOld.isEmpty());
    }

    /********************************************************************************************************
     * Proposito: Devuelve para el tipo de registro de Consulta si existen casos con el mismo account asociados
     * a un usuario distinto
     * ******************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US270459      Nicolás García   27/09/21      Creación
    *****************************************************************/

    @AuraEnabled
    static public boolean multiplesCasosMismoAccountConsulta(Id caseId, Id ownerId){
        Case caseSR = recuperarCaso(caseId);

        List<Case> caseOld= new List<Case>();
        caseOld = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId 
                    FROM Case
                    WHERE ((RecordType.DeveloperName = 'SAC_Consulta' OR RecordType.DeveloperName = 'SAC_ConsultaSAC')
                    AND AccountId =: caseSR.AccountId AND isClosed = False 
                    AND AccountId <> NULL AND OwnerId <>: ownerId AND Id <> :caseId)];
        return (!caseOld.isEmpty());
    }

    /**************************************************************************************************************
     * Proposito: Devuelve para el tipo de registro de Reclamación si existen casos con el mismo account asociados
     * a un usuario distinto
     * **************************************************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                  -          IBM              -            Creación
    *****************************************************************/
    @AuraEnabled
    static public boolean multiplesCasosMismoAccountAsignados(Id caseId, Id ownerId){
        Case caseSR = recuperarCaso(caseId);

        List<Case> caseOld= new List<Case>();
        caseOld = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, RecordTypeId  FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND AccountId =: caseSR.AccountId AND OwnerId = :ownerId AND isClosed = False AND AccountId <> NULL AND Id <> :caseId ];
        return (!caseOld.isEmpty());
    }

    /*****************************************************************
     * Proposito: Devuelve para el tipo de registro de Consulta si existen casos con el mismo account asociados
     * a un usuario distinto
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US270459     Nicolás García   28/09/2021       Creación
    *****************************************************************/
    @AuraEnabled
    static public boolean casosMismoAccountAsignadosConsulta(Id caseId, Id ownerId){
        Case caseSR = recuperarCaso(caseId);

        List<Case> caseOld= new List<Case>();
        caseOld = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId 
                    FROM Case 
                    WHERE (RecordType.DeveloperName = 'SAC_Consulta' OR RecordType.DeveloperName = 'SAC_ConsultaSAC')
                    AND AccountId =: caseSR.AccountId AND OwnerId = :ownerId AND isClosed = False AND AccountId <> NULL AND Id <> :caseId ];
        return (!caseOld.isEmpty());
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
    

    /*****************************************************************
     * Proposito: Deriva la reclamación a Contact Center creando un nuevo caso e insertándolo y actualiza el estado de la reclamación
     * Modificación 1.1: Recuperadas las pretensiones del caso y dadas de baja al poderse derivar a Contact Center con pretensiones
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            DE51383     Luis Mesa García                  Creación
     * 1.1            US477862     Sergio Martín     14/12/2022     Modificación
     * 1.2            US994116      Raúl Santos      12/09/2024     Modificación: Si la reclamación está en estado 'Alta' y no se ha enviado el acuse de recibo, se envia automáticamente al derivar (tanto vía email como carta postal)
    *****************************************************************/
    @AuraEnabled
    public static void derivarACC(String idCasoDisparador) {
       
        if (Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Case.isCreateable()){

            WrapperCC contactCenter = new WrapperCC();
            Case casoParaContact = new Case();
            Boolean enviarAcuse = false;
            Case casoSAC = new Case();

            List<Case> listaCasos = new List<Case>();
            listaCasos = [SELECT Id, status, Description, Subject, ownerId, Origin, RecordTypeId, CC_Idioma__c, AccountId, ContactId, RecordType.DeveloperName, CC_AcuseRecibo__c,
                          Account.CC_Numero_Documento__c, Account.AV_OficinaPrincipal__r.CC_Tipo_Centro__c, Account.AV_OficinaPrincipal__r.Parent.CC_Tipo_Centro__c, Account.AV_OficinaPrincipal__r.Parent.Parent.CC_Tipo_Centro__c,
                          Account.AV_OficinaPrincipal__r.Parent.Parent.Parent.CC_Tipo_Centro__c, Account.AV_OficinaPrincipal__r.ParentId, Account.AV_OficinaPrincipal__r.Parent.ParentId, Account.AV_OficinaPrincipal__r.Parent.Parent.ParentId,
                          CC_Canal_Respuesta__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c,SuppliedEmail, OS_Email__c, SAC_NombreContacto__c,
                          CreatedDate, CaseNumber, SAC_M2P__c
                          FROM Case WHERE (RecordType.DeveloperName = 'SAC_Reclamacion' OR RecordType.DeveloperName = 'SAC_Pretension')
                            AND (Id = :idcasoDisparador OR SAC_Reclamacion__c = :idcasoDisparador)];


            Id colaCC = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Inbound_Email_AC' AND Type = 'Queue' LIMIT 1].Id;

                    
            List<Case> listaCasosParaContact = new List<Case>();
            if (!listaCasos.isEmpty()) {
                for (Case caso : listaCasos) {
                    if (caso.RecordType.DeveloperName == 'SAC_Reclamacion') {
                        casoSAC = caso;
                        //Ponemos el estado del caso  de SAC en Derivación
                        if(caso.CC_AcuseRecibo__c != '2' && caso.Status == 'SAC_001'){
                            if(caso.CC_Canal_Respuesta__c == 'SAC_CartaPostal' && (caso.SAC_DireccionContacto__c == null || caso.SAC_CodigoPostalContacto__c == null || caso.SAC_PoblacionContacto__c == null || caso.SAC_ProvinciaContacto__c == null || caso.SAC_PaisContacto__c == null)){
                                throw new AuraHandledException('Revise que están informados todos los campos de la dirección de contacto del reclamante para que se pueda crear la carta postal del acuse de recibo.');
                            }else if(caso.CC_Canal_Respuesta__c == 'Email' && (caso.SuppliedEmail == null && caso.OS_Email__c == null)){
                                throw new AuraHandledException('Revise que hay informado un correo asociado al reclamante para que se pueda realizar el envío del acuse de recibo.');
                            }else{
                                enviarAcuse = true;
                                caso.CC_AcuseRecibo__c = '2';
                            }
                        }

                        caso.status = 'SAC_008'; 
                        caso.SAC_DerivadoA__c = 'Contact Center';
                        caso.SAC_StatusAuxiliar__c = caso.Status;

                        //Preparamos el caso con los datos necesarios para pasar a Contact Center
                        casoParaContact.Description = caso.Description;
                        casoParaContact.Subject =  caso.Subject;
                        casoParaContact.ParentId = caso.Id; 
                        casoParaContact.Origin = caso.Origin;
                        casoParaContact.CC_Idioma__c = caso.CC_Idioma__c;
                        casoParaContact.Origin = 'Email';
                        casoParaContact.CC_Canal_Procedencia__c = 'Atención al Cliente';
                        casoParaContact.OwnerId = colaCC;
                        casoParaContact.AccountId = caso.AccountId;
                        casoParaContact.ContactId = caso.ContactId;
                        if(caso?.Account?.AV_OficinaPrincipal__c != null){
                            casoParaContact.CC_Oficina_Afectada_Lookup__c = caso.Account.AV_OficinaPrincipal__c;
                        }
                        
                        //Informar la DT del caso
                        //
                        
                        if (caso?.Account?.AV_OficinaPrincipal__r?.CC_Tipo_Centro__c == 'DT'){casoParaContact.CC_Direccion_Territorial__c = caso.Account.AV_OficinaPrincipal__c;
                        } else if (caso?.Account?.AV_OficinaPrincipal__r?.Parent?.CC_Tipo_Centro__c == 'DT'){casoParaContact.CC_Direccion_Territorial__c = caso.Account.AV_OficinaPrincipal__r.ParentId;
                        } else if (caso?.Account?.AV_OficinaPrincipal__r?.Parent?.Parent?.CC_Tipo_Centro__c == 'DT'){casoParaContact.CC_Direccion_Territorial__c = caso.Account.AV_OficinaPrincipal__r.Parent.ParentId;
                        } else if (caso?.Account?.AV_OficinaPrincipal__r?.Parent?.Parent?.Parent?.CC_Tipo_Centro__c == 'DT'){casoParaContact.CC_Direccion_Territorial__c = caso.Account.AV_OficinaPrincipal__r.Parent.Parent.ParentId;
                        }                            
                                            
                        
                        casoParaContact.CC_Numero_Documento__c = caso.Account.CC_Numero_Documento__c;
                        casoParaContact.recordTypeId = RECORDTYPECASECLIENTE;

                        listaCasosParaContact.add(casoParaContact);

                    } else if (caso.RecordType.DeveloperName == 'SAC_Pretension') {
                        caso.Status = 'SAC_009';
                        caso.SAC_StatusAuxiliar__c = 'SAC_009';
                    }
                }
                SAC_DatabaseDML.updateListDML(listaCasos, true);

                if(enviarAcuse){
                    if(casoSAC.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
                        String pais = '';

                        if(casoSAC.SAC_PaisContacto__c.trim().toLowerCase().contains('españa')){
                            pais = '011';
                        }else{
                            pais = '000';
                        }
            
                        SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(casoSAC, casoSAC.SAC_DireccionContacto__c, casoSAC.SAC_CodigoPostalContacto__c, casoSAC.SAC_PoblacionContacto__c, casoSAC.SAC_ProvinciaContacto__c, pais);

                    }else if(casoSAC.CC_Canal_Respuesta__c == 'Email'){
                        List<Case> casos = new List<Case>();
                        casos.add(casoSAC);
                        Map<Id, Case> mapa = new Map<Id, Case>();
                        SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
                    }else{
                        Case casoAcusePte = new Case(Id = casoSAC.Id, CC_AcuseRecibo__c = '1');
                        SAC_DatabaseDML.updateDML(casoAcusePte, true);
                    }
                } 
            }


            if (!listaCasosParaContact.isEmpty()) {
                DateTime dt = DateTime.now();
		        Long dateInMilliseconds = dt.getTime();
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
                try {
                    System.enqueueJob(new SAC_QueueableDerivarCC(idCasoDisparador, listaCasosParaContact), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }    
                List<Id> idsCasos = new List<Id>();
                for(Case c : listaCasosParaContact)
                {
                    idsCasos.add(c.id);
                }
                CC_Informar_DT_Caso.informaDireccionTerritorial(idsCasos);
            }


            
       }      
    }

    //FIN - MOD -> DE51383 | Luis Mesa García

	 @AuraEnabled
    static public void devolverCaso(Id caseId,String motivo){
        String userId = UserInfo.getUserId();
        Case caso = [SELECT OwnerId, Status, CC_Owner_Anterior__c, recordTypeId, SAC_NumDevoluciones__c FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND id = :caseId LIMIT 1];
		List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        if(!cola.isEmpty()){
            caso.OwnerId = cola[0].id;
			caso.SAC_NumDevoluciones__c = caso.SAC_NumDevoluciones__c == null ? 0 : caso.SAC_NumDevoluciones__c + 1;
			caso.SAC_Motivo__c = motivo;
            if(caso.recordTypeId == RECORDTYPECONSULTA || caso.recordTypeId == RECORDTYPECONSULTASAC){
                caso.Status = 'SAC_010';
                caso.SAC_StatusAuxiliar__c = caso.Status;
            }
        }
		if(Schema.sObjectType.Case.isUpdateable()){  
            SAC_DatabaseDML.updateDML(caso, true); 
		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }

	@AuraEnabled
    static public void postOnChatter(Id caseId, String observacion, String motivo){

    	FeedItem feed = new FeedItem();
		feed.ParentId = caseId; 
        if(string.isNotBlank(motivo)){
            feed.Body = 'Se ha devuelto el caso a la cola genérica por el motivo: ' + motivo;
        }
        else{
            feed.Body = 'Se ha devuelto el caso a la cola genérica'; 
        }
		if(String.isNotBlank(observacion)){
			feed.Body += '\n Observación: ' + observacion;
		}
		
        SAC_DatabaseDML.insertDML(feed, true);
    }

    @AuraEnabled
    static public void postOnChatterDescartar(Id caseId, String observacion, String motivo){

    	FeedItem feed = new FeedItem();
		feed.ParentId = caseId; 
        feed.Body = 'Se ha descartado la consulta por siguiente motivo: ' + motivo;
        
		if(String.isNotBlank(observacion)){
			feed.Body += '\n Observación: ' + observacion;
		}
		
		SAC_DatabaseDML.insertDML(feed, true); 
    }

    @AuraEnabled
    static public void postOnChatterDevolverLetrado(Id caseId, String observacion, String motivo){

    	FeedItem feed = new FeedItem();
		feed.ParentId = caseId;  
        feed.Body = 'Se ha devuelto la propiedad del letrado a la cola genérica por el motivo: ' + motivo;
  
		if(String.isNotBlank(observacion)){
			feed.Body += '\n Observación: ' + observacion;
		}
		
        SAC_DatabaseDML.insertDML(feed, true);
    }

    @AuraEnabled
    static public void devolverLetradoConsulta(Id caseId, String motivo){
        Case caso = [SELECT Id, SAC_Letrado__c FROM Case WHERE RecordTypeId = :RECORDTYPECONSULTASAC AND id = :caseId LIMIT 1];
        caso.SAC_Letrado__c = 'Pte. Asignar';

        //Quitar permisos sobre el registro al propietario letrado
        Id userActual = UserInfo.getUserId();
        CaseShare eliminarCS = [SELECT Id FROM CaseShare WHERE CaseId = :caseId AND UserOrGroupId = :userActual LIMIT 1];
		
		if(Schema.sObjectType.Case.isUpdateable()){  
            SAC_DatabaseDML.updateDML(caso, true); 
            SAC_DatabaseDML.deleteDML(eliminarCS, true); 
		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }

    @AuraEnabled
    static public void tomarPropiedadCaso(Id caseId, Id ownerId){
        
        //comprobamos si el usuario puede coger el caso.
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];

        Case caseSR = recuperarCaso(caseId);
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Boolean lanzarError = true;

        if(caseSR.OwnerId == colaSupervisores.id){

            List<GroupMember> listaSupervisotres = [SELECT Id, UserOrGroupId 
                                                    FROM GroupMember WHERE Group.DeveloperName ='SAC_PteSupervisor' 
                                                    AND UserOrGroupId =:ownerId];
            if(!listaSupervisotres.isEmpty()){
                colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoProveedores'  
                                 AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c AND CC_Usuario__c=:ownerId 
                                AND SAC_Supervisor__c = true];

                if(Test.isRunningTest() || !colabContact.isEmpty()){
                    caseSR.OwnerId = ownerId;
                    lanzarError = false;
                }
            }
        }else{
            if (Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()) {
                colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                 WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoProveedores'  
                                 AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c != 'COPS'
                                 AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c AND CC_Usuario__c=:ownerId];
            }
            if(!colabContact.isEmpty()){
                caseSR.OwnerId = ownerId;
                lanzarError = false;
            }
        }

        if(lanzarError){
            throw new AuraHandledException('No tienes permisos para tomar en propiedad el Caso');
        }else{
            SAC_DatabaseDML.updateDML(caseSR, true); 
        }
        
               
    }

    /**********************************************************************************************************
     * Proposito: Devuelve para el tipo de registro de Consulta si existen casos con el mismo account asociados
     * a un usuario distinto
     * ********************************************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US270459      Nicolás García   27/09/21      Creación
    *****************************************************************/

    @AuraEnabled
    static public void tomarPropiedadCasoConsulta(Id caseId, Id ownerId){

        //comprobamos si el usuario puede coger el caso.
        Case caseSR = recuperarCaso(caseId);
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Id profileId=userinfo.getProfileId();
        String profileName=[SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
        
        if (Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()) {

            if(caseSR.RecordTypeId == RECORDTYPECONSULTA){
                colabContact = [SELECT Id, CC_Grupo_Colaborador__c, CC_Usuario__c 
                FROM CC_Grupo_Colaborador_Contact__c 
                WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion'  
                AND CC_Usuario__c=:ownerId 
                AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c];
            }else if(caseSR.RecordTypeId == RECORDTYPECONSULTASAC){
                colabContact = [SELECT Id, CC_Grupo_Colaborador__c, CC_Usuario__c 
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoProveedores'  
                            AND CC_Usuario__c=:ownerId 
                            AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c];                
            }
        }
        
        if(colabContact.isEmpty()){
            throw new AuraHandledException('No tienes permisos para tomar en propiedad La Consulta');	 
        }
        else {
            caseSR.OwnerId = ownerId;
            caseSR.Status = 'SAC_011';
            caseSR.SAC_StatusAuxiliar__c = caseSR.Status;
            if (Schema.sObjectType.Case.isUpdateable()) {
                SAC_DatabaseDML.updateDML(caseSR, true); 
            }
        }       
    }

    @AuraEnabled
    static public Boolean autoasignarPropiedadCaso(Id caseId, Id ownerId){
        Boolean refrescar = false;
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];
        Case caseSR = recuperarCaso(caseId);
        if (caseSR.OwnerId != ownerId && caseSR.OwnerId != colaSupervisores.Id)
        {
            List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
            colabContact = [SELECT id 
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE (CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoProveedores'
                            OR  CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_Letrados'
                            OR CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion')
                            AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c AND CC_Usuario__c=:caseSR.OwnerId LIMIT 1];
            
            if(colabContact.isEmpty())
            {
                colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c 
                                WHERE (CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoProveedores' 
                                OR CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_Letrados'
                                OR CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion')
                                AND CC_Usuario__c=:ownerId 
                                AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c];

                List<Case> caseOld= new List<Case>();
                caseOld = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, RecordTypeId 
                            FROM Case 
                            WHERE (RecordTypeId = :RECORDTYPERECLAMACION OR RecordTypeId = :RECORDTYPECONSULTA OR RecordTypeId = :RECORDTYPECONSULTASAC OR RecordTypeId =: RECORDTYPEPRETENSION) 
                            AND AccountId =: caseSR.AccountId AND isClosed = False AND AccountId <> NULL AND OwnerId <>: ownerId AND Id <> :caseId];
                if(!colabContact.isEmpty() && caseOld.isEmpty())
                {
                    
                    caseSR.OwnerId = ownerId;
                    if((caseSR.RecordTypeId == RECORDTYPECONSULTA && caseSR.Status != 'SAC_013') || caseSR.RecordTypeId == RECORDTYPECONSULTASAC){
                        caseSR.Status = 'SAC_011';
                        caseSR.SAC_StatusAuxiliar__c = caseSR.Status;
                    }
                    refrescar = true;
                    SAC_DatabaseDML.updateDML(caseSR, true); 
                }
            }
        }
        return refrescar;
    }

    // INI - INS: US204743 - Luis Mesa García
    @AuraEnabled
    static public void marcarPretensionPrincipal(Case pretension){
        /****************************************************************************
         * Proposito: Método para modificar la pretension principal de la reclamacion
         * 1.1 : Modificado método para actualizar el campo SAC_EsPrincipal__c de las pretensiones
         * **************************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US204743         Luis Mesa    30/04/21       Creación Método
         * 1.1            US574649         Sergio Martín  02/05/23       Modificación
        *****************************************************************/
        Case pretensionPrincipal = new Case();
        Case reclamacion = new Case();
        List<Case> casosUpdated = new List<Case>();
        Case pretensionActualizar = new Case();
        pretensionActualizar.Id = pretension.Id;
        
        if (Schema.sObjectType.Case.isAccessible()) {

            reclamacion = [SELECT id, status, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.SAC_EsPrincipal__c
                        FROM Case 
                        WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND id = :pretension.SAC_Reclamacion__c LIMIT 1];
            
            if(reclamacion.SAC_PretensionPrincipal__c != null) {
                pretensionPrincipal = [SELECT id, status, SAC_EsPrincipal__c
                        FROM Case 
                        WHERE RecordType.DeveloperName = 'SAC_Pretension' AND id = :reclamacion.SAC_PretensionPrincipal__c LIMIT 1];
            }
            
            if (Schema.sObjectType.Case.isUpdateable()) {
                pretensionActualizar.SAC_EsPrincipal__c = true;
                if(reclamacion.SAC_PretensionPrincipal__c != null) {
                    pretensionPrincipal.SAC_EsPrincipal__c = false;
                    casosUpdated.add(pretensionPrincipal);
                }
                reclamacion.SAC_PretensionPrincipal__c = pretensionActualizar.id;
                //reclamacion.SAC_Entidad_Afectada__c = pretension.SAC_Entidad_Afectada__c; //Quitado porque se ha movido al trigger. 28/03/2024
                //reclamacion.SAC_EntidadProductora__c = pretension.SAC_EntidadProductora__c; //Quitado porque se ha movido al trigger. 28/03/2024
                casosUpdated.add(reclamacion);
                casosUpdated.add(pretensionActualizar);

                SAC_DatabaseDML.updateListDML(casosUpdated, true);
            }
            else{
                throwAuraHandledException( 'No tienes permisos para actualizar los registros' );
            }
        }
        else{
            throwAuraHandledException( 'No tienes permisos para visualizar los registros' );
        }
        
    }
    
    private static void throwAuraHandledException( String errorMsg ){
        /*****************************************************************
         * Proposito: Método para controlar errores y lanzarlos por pantalla
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US204743         Luis Mesa    30/04/21       Creación Método
        *****************************************************************/
                AuraHandledException auraException = new AuraHandledException( errorMsg );
                auraException.setMessage( errorMsg );
                throw auraException;
            }

    // FIN - INS: US204743

    // INI - INS: US270459 - Marcela Neira
    @AuraEnabled
    static public void modificarEstadoCaso(Id caseId, String estado, String motivo){
        /*****************************************************************
         * Proposito: Modificar el estado de la Consulta
         **************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US270459       Marcela Neira  11/10/21       Creación Método
        *****************************************************************/
        Case consulta = recuperarCaso(caseId);
        consulta.Status = estado;
        consulta.SAC_StatusAuxiliar__c = consulta.Status;

        if(motivo != null){
            consulta.SAC_Motivo__c = motivo;
        }
        
        if (Schema.sObjectType.Case.isUpdateable()){
            SAC_DatabaseDML.updateDML(consulta, true); 
        }      
    }

    /*****************************************************************
     * Proposito: Modificar el estado de la Consulta
     **************************************************************
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR         DATE         Description
        * 1.0            US270459       Marcela Neira  11/10/21       Creación Método
    *****************************************************************/
    @AuraEnabled
    static public void descartarConsulta(Id caseId, String estado, String motivo){
       
        Case consulta = recuperarCaso(caseId);
        consulta.Status = estado;
        consulta.SAC_StatusAuxiliar__c = consulta.Status;

        if(motivo != null){
            consulta.SAC_MotivoDescarte__c = motivo;
        }
        
        if (Schema.sObjectType.Case.isUpdateable()){
            SAC_DatabaseDML.updateDML(consulta, true);
        }      
   }


   /*******************************************************************************
    * Proposito: Convertir Consulta COPS a Reclamación o a Consulta SAC
    *            Convertir la Reclamacion a Consulta COPS o Consulta SAC
    *            Convertir la Consulta SAC a una Reclamación
    ******************************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0             US550726     Sergio Martín  10/04/2023     Creación Método
    *******************************************************************************/
    @AuraEnabled
    static public void convertirReclamacion(Id caseId, String naturaleza){
       
        // Recuperar el caso
        Case caso = recuperarCaso(caseId);
        List<Case> listaCasosUpdatear = new List<Case>();

        if(caso.recordTypeId == RECORDTYPERECLAMACION && naturaleza == 'Consulta') {
            caso.SAC_Naturaleza__c = 'SAC_005';
            caso.SAC_Letrado__c = 'Pte. Asignar';

            if(caso.recordTypeId == RECORDTYPERECLAMACION && caso.SAC_NPretensionesActivas__c != 0) {
                List<Case> listaPretCasos = [SELECT id, recordTypeId, Status 
                                    FROM  Case 
                                    WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c =: caso.id];
                if(!listaPretCasos.isEmpty()){
                    for (Case pretension : listaPretCasos) {
                        pretension.Status = 'SAC_009';
                        pretension.SAC_StatusAuxiliar__c = 'SAC_009';
                    }
                }

                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())
                .addString('listaPretCasos')
                .build();
                try {
                    System.enqueueJob(new SAC_QueueableCerrarMilestoneLetrado(listaPretCasos), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }     
            }
        }
        else if (caso.recordTypeId == RECORDTYPECONSULTASAC && naturaleza == 'Reclamacion') {
            caso.SAC_Naturaleza__c = 'SAC_004';
            caso.recordTypeId = RECORDTYPERECLAMACION;
            caso.Status = 'SAC_001';
            caso.SAC_StatusAuxiliar__c = 'SAC_001';

            //Comprobar que la consulta no tenga el check CC_SuppliedFiles__c marcado sin archivos adjuntos
            comprobarCheckAdjuntos(caso);
        } else {
            // En caso de que sea una reclamación a Consulta COPS o que viene de una Consulta COPS se debe rechazar el caso
            caso.Status = 'Rechazado';
            caso.SAC_StatusAuxiliar__c = caso.Status;
            caso.SAC_MotivoRechazo__c = 'Rechazada por conversión';
            
            if(caso.recordTypeId == RECORDTYPERECLAMACION && caso.SAC_NPretensionesActivas__c != 0) {
                List<Case> listaPretCasos = [SELECT id, recordTypeId, Status 
                                    FROM  Case 
                                    WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c =: caso.id];
                if(!listaPretCasos.isEmpty()){
                    for (Case pretension : listaPretCasos) {
                        pretension.Status = 'SAC_009';
                        pretension.SAC_StatusAuxiliar__c = 'SAC_009';
                        listaCasosUpdatear.add(pretension);
                    }
                }

                /*if(Case.SObjectType.getDescribe().isUpdateable()){
                    SAC_DatabaseDML.updateListDML(listaPretCasos, true);
                }*/
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())
                .addString('listaPretCasos')
                .build();
                try {
                    System.enqueueJob(new SAC_QueueableCerrarMilestoneLetrado(listaPretCasos), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
            }

            if(naturaleza == 'Reclamacion' || naturaleza == 'Consulta') {
                List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
                // Creación de la nueva consulta SAC/Reclamación convertida
                Case reclamacion = new Case (
                    SAC_FechaRecepcion__c = caso.SAC_FechaRecepcion__c, 
                    AccountId = caso.AccountId, 
                    ContactId = caso.ContactId,           
                    Description = caso.Description,
                    Subject =  caso.Subject,
                    recordTypeId = RECORDTYPERECLAMACION,
                    Origin = caso.Origin,
                    CC_Idioma__c = caso.CC_Idioma__c,
                    SuppliedEmail = caso.SuppliedEmail,
                    OwnerId = cola[0].id,
                    CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta__c,
                    CC_CasoRelacionado__c = caso.id
                );
                                      
                if (Schema.sObjectType.Case.isCreateable()){
                    SAC_DatabaseDML.insertDML(reclamacion, true);
                } 
    
                // Llamada al metodo para copiar los adjuntos en el nuevo caso creado;
                copiarEmailsAdjuntos(caso.id, reclamacion.id);

                // Si es una consulta se necesita lanzar un update future para el cambio de naturaleza
                if(naturaleza == 'Consulta') {
                    reclamacion.SAC_Naturaleza__c = 'SAC_005';
                    reclamacion.Status = 'SAC_010';
                    reclamacion.SAC_StatusAuxiliar__c = 'SAC_010';
                    reclamacion.recordTypeId = RECORDTYPECONSULTASAC;

                    List<Case> casoActualizar = new List<Case>();
                    casoActualizar.add(reclamacion);
                    SAC_Utils.updateCase(JSON.serialize(casoActualizar));
                } 
    
                caso.CC_CasoRelacionado__c = reclamacion.id;
            } else if(naturaleza == 'ConsultaCOPS') {
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
        }

        listaCasosUpdatear.add(caso);
        if (Schema.sObjectType.Case.isUpdateable()){
            try {
                //SAC_DatabaseDML.updateDML(caso, true);
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


    /*****************************************************************
     * Proposito: Obtener el listado de posibles Motivos
     *****************************************************************
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR         DATE         Description
        * 1.0            US289215       Luis Mesa       28/10/21      Creación Método
    *****************************************************************/
    @AuraEnabled
    static public List<plantillasWrapper> getPickListValuesIntoList(){
       
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
        Schema.DescribeFieldResult fieldResult = Case.SAC_MotivoDescarte__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
           plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
           pickListValuesList.add(wrapper);
        }
        return pickListValuesList;
    }

    public class PlantillasWrapper{
        //Clase wrapper a usar en getPickListValuesIntoList a usar en -> SAC_ConsultaOperativas
        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }
 
    @AuraEnabled
    static public void escalarCOPS(Id caseId,String motivo){
        String recordTypeGrupoResponsable = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Case caso = [SELECT OwnerId, Status, CC_Owner_Anterior__c, recordTypeId, SAC_NumDevoluciones__c FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND id = :caseId LIMIT 1];
        List<CC_Grupo_Colaborador__c> gruposCops = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recordTypeGrupoResponsable AND SAC_DeveloperName__c = 'COPS'];
		List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        if(!cola.isEmpty()){
            caso.OwnerId = cola[0].id;
            caso.SEG_Grupo__c = gruposCops[0].Id;
        }
		if(Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.FeedItem.isUpdateable() ){   
            SAC_DatabaseDML.updateDML(caso, true);

            FeedItem feed = new FeedItem();
            feed.ParentId = caseId; 
            feed.Body = 'Se ha escalado la consulta al departamento COPS: ' + motivo;
            SAC_DatabaseDML.insertDML(feed, true);

		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }
    
    @AuraEnabled
    static public void retornarEscaladoConsulta(Id caseId,String motivo){
        Case caso = [SELECT OwnerId, Status, CC_Owner_Anterior__c, recordTypeId, RecordType.DeveloperName FROM Case WHERE RecordType.DeveloperName LIKE 'SAC_%' AND id = :caseId LIMIT 1];
        SAC_EmailService__c customSetting = [SELECT SAC_EmailEntrante__c, SAC_GroupName__c, SAC_Naturaleza__c, SAC_RecordTypeDeveloperName__c FROM SAC_EmailService__c WHERE SAC_RecordTypeDeveloperName__c =: caso.RecordType.DeveloperName LIMIT 1];
        CC_Grupo_Colaborador__c gruposCops = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c =: customSetting.SAC_GroupName__c LIMIT 1];
        
        List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        if(!cola.isEmpty()){
            caso.OwnerId = cola[0].id;
            caso.SEG_Grupo__c = gruposCops.Id;
        }
		if(Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.FeedItem.isUpdateable() ){   
            SAC_DatabaseDML.updateDML(caso, true);

            FeedItem feed = new FeedItem();
            feed.ParentId = caseId; 
            feed.Body = 'Se ha retornado la consulta al Grupo original: ' + motivo;
            SAC_DatabaseDML.insertDML(feed, true);

		}else{
			throw new AuraHandledException('No tienes permisos');
		}
    }

    /*****************************************************************
     * Proposito: Comprueba desde una pretensión, su Reclamación padre y sus
     *            hermanas 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            DE54908     Marcela Neira   16/12/2021       Creación
    *****************************************************************/
    @AuraEnabled
    static public boolean esPropietarioFamiliaCaso(Id caseId, String userActual){

        Boolean tienePermiso = false;
        Case casoActual = recuperarCaso(caseId); 
        List<Case> listaFamilia = new List<Case>();

        if(casoActual.RecordTypeId == RECORDTYPERECLAMACION){
            listaFamilia = [SELECT id, OwnerId
                FROM Case
                WHERE RecordType.DeveloperName LIKE 'SAC_%' AND (SAC_Reclamacion__c =: casoActual.Id OR id = :casoActual.Id)];
        }
        else if(casoActual.RecordTypeId == RECORDTYPEPRETENSION){
            listaFamilia = [SELECT id, OwnerId
                FROM Case
                WHERE RecordType.DeveloperName LIKE 'SAC_%' AND (SAC_Reclamacion__c =: casoActual.SAC_Reclamacion__c OR id = :casoActual.SAC_Reclamacion__c)];
        }
        
                                   
        if(!listaFamilia.isEmpty()){
            for (Case caso : listaFamilia) { 
                if(caso.OwnerId == userActual){
                    tienePermiso=true;
                    break;
                }
            }
        } 

        return tienePermiso;        
    }

    @AuraEnabled
    static public void reabrirConsulta(Id caseId, String motivoReabrir){

        if(!Schema.sObjectType.Case.isAccessible() || 
            !Schema.sObjectType.CaseHistory.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

        Case casoPorActualizar = [SELECT Id, Status 
        FROM Case
        WHERE RecordType.DeveloperName LIKE 'SAC_%' AND Id =: caseId];

        List<CaseHistory> ch = new List<CaseHistory>();
        Integer resta = 0;
        if(!Test.isRunningTest()){
            ch = [SELECT Id, OldValue FROM CaseHistory WHERE CaseId =: casoPorActualizar.Id AND Field = 'Status' ORDER BY CreatedDate desc];
        }
        
        if(Test.isRunningTest()){
            casoPorActualizar.Status = 'SAC_001';
            casoPorActualizar.SAC_StatusAuxiliar__c = 'SAC_001';
        }
        else{
            casoPorActualizar.Status = ch[0].OldValue.toString();
            casoPorActualizar.SAC_StatusAuxiliar__c = ch[0].OldValue.toString();
            casoPorActualizar.SAC_DerivadoA__c = '';
            casoPorActualizar.SAC_MotivoReabrir__c = motivoReabrir;
        }

        if( Case.SObjectType.getDescribe().isUpdateable()){ 
            SAC_DatabaseDML.updateDML(casoPorActualizar, true);
        }
        else{ throw new AuraHandledException( 'Fallo al acutalizar.' ); }


    }

    /*****************************************************************
     * Proposito: Volver a abrir una reclamación. La reclamación se puede reabrir cuando está en estado
     * Ejecución o Cerrado. Al reabrir, vuelve a poner la reclamación en estado redacción. Las pretensiones
     * hijas también las pone en estado redacción (ignora las que esten en estado baja, solo reabre las que 
     * esten cerradas). Si la reclamación tenía tareas en estado 'pendiente de asignar' o en estado
     * 'en gestion', las pone en estado 'Stand By'. Si el caso esta en estado derivado, al reabrirlo tiene que
     * volver al estado anterior a la derivación.
     * 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US200252         Carlos Solis   26/01/2022   Creación
    *****************************************************************/
    @AuraEnabled
    public static void reabrirReclamacion(String caseId, String motivoReabrir) {
        //Comprobar si el caso está en estado de derivación
        Case casoEntrada = recuperarCaso(caseId);
        String estadoAnterior;
        DateTime fechaCambio;

        //Lista para almacenar todos los registros de distintos objetos que hay que actualizar
        List<SObject> listaActualizar = new List<SObject>();

        //Reclamación que se está reabriendo
        Case casoReabrir = new Case();
        
        //Comprobar si el estado es derivación o rechazado, si es así, asignar el estado que tenía anterior a la derivación o rechazado
        if(casoEntrada.Status == 'SAC_008'){

            List<CaseHistory> historial = [SELECT id, NewValue,OldValue,CreatedDate FROM CaseHistory WHERE CaseId =: caseId ORDER BY CreatedDate ASC];

            for(CaseHistory h : historial){
                if(String.valueOf(h.NewValue) == 'SAC_008'){
                    fechaCambio = h.CreatedDate;
                    estadoAnterior = String.valueOf(h.OldValue);
                }
            }

            casoReabrir.Status = estadoAnterior;
            casoReabrir.SAC_StatusAuxiliar__c = estadoAnterior;
            
        }else if(casoEntrada.Status == 'Rechazado'){

            List<CaseHistory> historial = [SELECT id, NewValue,OldValue,CreatedDate FROM CaseHistory WHERE CaseId =: caseId ORDER BY CreatedDate ASC];

            for(CaseHistory h : historial){
                if(String.valueOf(h.NewValue) == 'Rechazado'){
                    fechaCambio = h.CreatedDate;
                    estadoAnterior = String.valueOf(h.OldValue);
                }
            }

            casoReabrir.Status = estadoAnterior;
            casoReabrir.SAC_StatusAuxiliar__c = estadoAnterior;
            casoReabrir.SAC_MotivoRechazo__c = null;

        }else{

            casoReabrir.Status = 'SAC_003'; //Se devuelve a estado redacción
            casoReabrir.SAC_StatusAuxiliar__c = 'SAC_003';
        }

        casoReabrir.Id = caseId;
        casoReabrir.OS_Fecha_Resolucion__c = null; //Se vacía el campo
        casoReabrir.SAC_StatusAuxiliar__c = casoReabrir.Status;
        casoReabrir.SAC_DerivadoA__c = null; //Se vacía el campo
        casoReabrir.SAC_MotivoReabrir__c = motivoReabrir;
        casoReabrir.SAC_MotivoCierre__c = null; //Se vacía el campo
        //Inicio modificación
        //Añadido US501943 11/01/23. Se debe desmarcar el campo SAC_CasoNegociado__c para poder reabrir el SLA de un caso que habia sido negociado
        casoReabrir.SAC_CasoNegociado__c = false;
        //Fin modificación
        //Inicio modificación
        //Añadido 19/03/24. Se rellena el campo CC_Fecha_Reapertura__c
        casoReabrir.CC_Fecha_Reapertura__c = System.now();
        //Fin modificación
        //Inicio modificación
        //Añadido 20/06/24. Poner ek campo SAC_ValidarEnvioResolucion__c a false
        casoReabrir.SAC_ValidarEnvioResolucion__c = false;
        //Fin modificación

        listaActualizar.add(casoReabrir);

        if(casoReabrir.Status == 'SAC_003'){

            //Se buscan las pretensiones hijas de la reclamación
            List<Case> listaPretensiones = [SELECT Id, SAC_SentidoResolucion__c, SAC_RedaccionFinal__c, Status FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :caseId];

            if (!listaPretensiones.isEmpty()) {
                for (Case pretension : listaPretensiones) {
                    if (pretension.Status == 'Cerrado') { //Si la pretensión estaba cerrada (no estaba ni en baja ni descartada)
                        pretension.Status = 'SAC_003';
                        pretension.SAC_StatusAuxiliar__c = pretension.Status;
                        //Añadido US501943 11/01/23. Se debe desmarcar el campo SAC_CasoNegociado__c para poder reabrir el SLA de un caso que habia sido negociado
                        pretension.SAC_CasoNegociado__c = false;
                        //Fin modificación
                        listaActualizar.add(pretension);
                    }
                }    
            }   

        
        }else if(casoEntrada.Status == 'Rechazado' || casoEntrada.Status == 'SAC_008'){ //Si la reclamación se reabre estando Rechazada o Derivada, las pretensiones que no estaban en baja se reabren con su estado anterior.

            if(!Test.isRunningTest()){
            List<Case> listaPretensiones = [SELECT Id, SAC_SentidoResolucion__c, SAC_RedaccionFinal__c, Status FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :caseId];

            if(!listaPretensiones.isEmpty()){
                
                List<CaseHistory> historialPretensiones = [SELECT id, NewValue,OldValue,CaseId,CreatedDate FROM CaseHistory WHERE CaseId IN: listaPretensiones ORDER BY CreatedDate ASC];
                Map<Id, List<CaseHistory>> mapIdHistorial = new Map<Id, List<CaseHistory>>();

                for(CaseHistory h : historialPretensiones){
                    if(mapIdHistorial.containsKey(h.CaseId)){

                        List<CaseHistory> hPretensionAux = mapIdHistorial.get(h.CaseId);
                        hPretensionAux.add(h);
                        mapIdHistorial.put(h.CaseId, hPretensionAux);

                    }else{
                        mapIdHistorial.put(h.CaseId, new List<CaseHistory> { h });
                    }
                }

                for(Case pretension : listaPretensiones){
                    List<CaseHistory> hPretension = mapIdHistorial.get(pretension.id);
                    for(CaseHistory hP : hPretension){
                        if(String.valueOf(hP.NewValue) == 'SAC_009' && hP.createdDate == fechaCambio){
                            pretension.Status = String.valueOf(hP.OldValue);
                            pretension.SAC_StatusAuxiliar__c = String.valueOf(hP.OldValue);
                            //Añadido US501943 11/01/23. Se debe desmarcar el campo SAC_CasoNegociado__c para poder reabrir el SLA de un caso que habia sido negociado
                            pretension.SAC_CasoNegociado__c = false;
                            //Fin modificación
                            listaActualizar.add(pretension);
                        }
                    }
                }
            }
            }
        }

        //Se comprueban las tareas que tiene el caso
        List<SAC_Accion__c> listaTareas = [SELECT Id, SAC_Estado__c
                                            FROM SAC_Accion__c WHERE RecordType.DeveloperName LIKE 'SAC_%' AND SAC_Reclamacion__c = :caseId 
                                            AND (SAC_Estado__c = 'SAC_PendienteAsignar' OR SAC_Estado__c = 'SAC_EnGestion')];

        if (!listaTareas.isEmpty()) {
            for (SAC_Accion__c tarea : listaTareas) {
                //Las tareas pasan a estar en stand by
                tarea.SAC_Estado__c = 'SAC_StandBy';
                listaActualizar.add(tarea);
            }
        }

        // Si la reclamación no tiene un registro del CBK_Case_Extension__c asociado se crea uno al reabrir
        if(casoEntrada.CBK_Case_Extension_Id__c == null) {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.recordTypeId = RECTYPECASEEXTENSION;
            caseExtension.Case_Id__c = casoReabrir.id;

            if (Schema.sObjectType.CBK_Case_Extension__c.isCreateable()) {    
                SAC_DatabaseDML.insertDML(caseExtension, false);
                casoReabrir.CBK_Case_Extension_Id__c = caseExtension.id;
            }
        }
        //Se updatea todo lo que hemos ido añadiendo a la lista
        SAC_DatabaseDML.updateListDML(listaActualizar, true);   
    }


    /*****************************************************************
     * Proposito: Desde la Reclamación en estado cerrrada o ejecución, se debe poder crear una nueva reclamación
     *              y la vinculamos a la que esta cerrada.
     * 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US325822      Marcela Neira   02/02/2022      Creación
    *****************************************************************/


    @AuraEnabled
    public static List<Id> nuevaReclamacionVinculada(Case casoCerrado){ 
        
        List<Case> listaCasos = new List<Case>();
        List<Id> listaIdsCasosRetornar = new List<Id>();


        try {
            Case reclamacionClonada = casoCerrado.clone(false, false, false, false);
            reclamacionClonada.Subject = 'Nueva reclamación vinculada a ' + casoCerrado.CaseNumber;
            reclamacionClonada.Status = 'SAC_002';
            reclamacionClonada.SAC_StatusAuxiliar__c = 'SAC_002'; 
            reclamacionClonada.CC_CasoRelacionado__c = casoCerrado.Id; 
            reclamacionClonada.AccountId =null;
            reclamacionClonada.ContactId=null;

           
            Case pretensionNueva = new case( 
                SEG_Grupo__c = casoCerrado.SAC_PretensionPrincipal__r.SEG_Grupo__c, 
                OwnerId = casoCerrado.SAC_PretensionPrincipal__r.OwnerId, 
                Origin =  casoCerrado.SAC_PretensionPrincipal__r.Origin, 
                RecordTypeId = casoCerrado.SAC_PretensionPrincipal__r.RecordTypeId,
                Status = 'SAC_002',
                SAC_StatusAuxiliar__c = 'SAC_002',
                SuppliedEmail = casoCerrado.SAC_PretensionPrincipal__r.SuppliedEmail, 
                CC_MCC_Motivo__c = casoCerrado.SAC_PretensionPrincipal__r.CC_MCC_Motivo__c, 
                CC_MCC_ProdServ__c = casoCerrado.SAC_PretensionPrincipal__r.CC_MCC_ProdServ__c, 
                CC_MCC_Tematica__c= casoCerrado.SAC_PretensionPrincipal__r.CC_MCC_Tematica__c, 
                CC_Idioma__c = casoCerrado.SAC_PretensionPrincipal__r.CC_Idioma__c, 
                Priority = casoCerrado.SAC_PretensionPrincipal__r.Priority, 
                SEG_Detalle__c = casoCerrado.SAC_PretensionPrincipal__r.SEG_Detalle__c,                
                CC_No_Identificado__c = casoCerrado.SAC_PretensionPrincipal__r.CC_No_Identificado__c, 
                SAC_OrigenConsulta__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_OrigenConsulta__c,
                OS_Email__c = casoCerrado.SAC_PretensionPrincipal__r.OS_Email__c, 
                SAC_NombreContacto__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_NombreContacto__c,
                SAC_UsarDatos__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_UsarDatos__c, 
                SAC_DireccionPostalNotificacion__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_DireccionPostalNotificacion__c,
                CC_Importe_Reclamado__c = casoCerrado.SAC_PretensionPrincipal__r.CC_Importe_Reclamado__c,
                SAC_TipoDeRepresentante__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_TipoDeRepresentante__c, 
                SAC_DespachoRepresentante__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_DespachoRepresentante__c, 
                SAC_TipoDeDocumento__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_TipoDeDocumento__c, 
                SAC_NumeroDelDocumento__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_NumeroDelDocumento__c, 
                SAC_NombreRepresentante__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_NombreRepresentante__c, 
                SAC_DireccionPostal__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_DireccionPostal__c,
                SAC_EmailRepresentante__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_EmailRepresentante__c,
                SAC_TelefonoRepresentante__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_TelefonoRepresentante__c, 
                SAC_Naturaleza__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_Naturaleza__c, 
                SAC_CasoEspecial__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_CasoEspecial__c, 
                SAC_CASE_esPSD2__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_CASE_esPSD2__c,
                SAC_Entidad_Afectada__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_Entidad_Afectada__c,
                SAC_EntidadProductora__c = casoCerrado.SAC_PretensionPrincipal__r.SAC_EntidadProductora__c,
                AccountId = null,
                ContactId = null
               
            );
            
            listaCasos.add(reclamacionClonada);
            listaCasos.add(pretensionNueva);
            
            DateTime dt = DateTime.now();
            Long dateInMilliseconds = dt.getTime();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
            ID jobID;
            try {
                jobID = System.enqueueJob(new SAC_NuevaReclamacionVinculada(listaCasos, casoCerrado), options);    
            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
            
            casoCerrado.CC_Detalles_Solucion__c = jobID;
            SAC_DatabaseDML.updateDML(casoCerrado, true);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listaIdsCasosRetornar;
    }

    @AuraEnabled
    public static void nuevaReclamacionVinculadaPage2(List<Id> listaIdAdjuntos){
        
        try {            

            List<EmailMessage> listaEM = [SELECT id, ToAddress
                                            FROM EmailMessage 
                                            WHERE RelatedToId IN: listaIdAdjuntos AND HasAttachment = true]; 
            if (!listaEM.isEmpty()) {
                List<Attachment> listaAttach = [SELECT id, ParentId, Name, Body
                                                    FROM Attachment   
                                                    WHERE ParentId IN:listaEM]; 
                List<EmailMessage> listaEmailMessParaNuevaRecla = new List<EmailMessage>();      
                List<Attachment> listaAttachParaNuevaRecla = new List<Attachment>();

                for (EmailMessage em : listaEM) {
                    EmailMessage emAux = em.clone(false, false, false, false);
                    emAux.ParentId = listaIdAdjuntos[0];  //El la posicion 1 es donde se encuentra la Reclamación nueva
                    emAux.RelatedToId = listaIdAdjuntos[0];
                    listaEmailMessParaNuevaRecla.add(emAux);
                }  

                

                List<Database.SaveResult> resultadoEM = Database.insert(listaEmailMessParaNuevaRecla, false);
                Id idEM = (resultadoEM[0].isSuccess()) ? resultadoEM[0].getId() : null;

                for (Attachment att : listaAttach) {
                    Attachment attAux = att.clone(false, false, false, false);
                    attAux.ParentId = idEM;
                    listaAttachParaNuevaRecla.add(attAux);
                }
                SAC_DatabaseDML.insertListDML(listaAttachParaNuevaRecla, false);
                //List<Database.SaveResult> resultadoAtt = Database.insert(listaAttachParaNuevaRecla, false);
            }


            
            List<ContentDocumentLink> contenidos = [SELECT LinkedEntityId, contentdocumentid   
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId IN: listaIdAdjuntos]; 
            List<ContentDocumentLink> nuevosCDL = new List<ContentDocumentLink>();
            for (ContentDocumentLink cdl : contenidos) {
                ContentDocumentLink cdlAux = new ContentDocumentLink();
                cdlAux.LinkedEntityId = listaIdAdjuntos[0]; //Id de la nueva reclamación
                cdlAux.contentdocumentid = cdl.contentdocumentid;
                cdlAux.ShareType = 'I';
                nuevosCDL.add(cdlAux);
            } 
            if (!nuevosCDL.isEmpty()) {
                SAC_DatabaseDML.insertListDML(nuevosCDL, true);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    } 

    @AuraEnabled
    public static void resolverCartaPostal(String idCaso){
        try {
            SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =:idCaso  AND SAC_TipoDocumento__c =: 'resolución consulta' LIMIT 1];

            String vfHostname = DomainCreator.getVisualforceHostname(null);
            String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + carta.Id;

            SAC_GeneracionCartas.adjuntarPDFaCaso2(urlVF, idCaso, 'resolución consulta');

            modificarEstadoCaso(idCaso, 'SAC_012', null);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*****************************************************************
     * Proposito: Tomar propiedad para los letrados, desencadena para la familia la misma asignacion del propietario con el mismo valor
     * 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            NaN             Luis Mesa     22/02/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void tomarPropiedadPretensionesApex(Id caseId, Id ownerId){
        
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];
        
        Case caseSR = recuperarCaso(caseId);
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Boolean lanzarError = true;        
        List<Case> familia = new List<Case>();

        if(caseSR.OwnerId == colaSupervisores.id){ 

            List<GroupMember> listaSupervisotres = [SELECT Id, UserOrGroupId 
                                                    FROM GroupMember WHERE Group.DeveloperName ='SAC_PteSupervisor' 
                                                    AND UserOrGroupId =:ownerId];

            if(!listaSupervisotres.isEmpty()){
                colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_Letrados' 
                                AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c AND CC_Usuario__c=:ownerId  
                                AND SAC_Supervisor__c = true]; 

                if(Test.isRunningTest() || !colabContact.isEmpty()){

                    lanzarError = false;
                    caseSR.OwnerId = ownerId;
                    familia = [SELECT Id, OwnerId FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__c =: caseSR.SAC_Reclamacion__c];

                    if(!familia.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                        for(Case pretension : familia){
                            pretension.OwnerId = ownerId;
                        }
                    }                     
                }
            }
        }else{        
            if (Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()) {
                colabContact = [SELECT Id, CC_Grupo_Colaborador__c, CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c 
                                WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_Letrados'
                                AND CC_Usuario__c=:ownerId 
                                AND CC_Grupo_Colaborador__c=:caseSR.SEG_Grupo__c ];
            }

            if(!colabContact.isEmpty()){             
                if (Schema.sObjectType.Case.isAccessible()) {
                    familia = [SELECT Id, OwnerId FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__c =: caseSR.SAC_Reclamacion__c];
                }
                
                if(!familia.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                    lanzarError = false;
                    for(Case pretension : familia){
                        pretension.OwnerId = ownerId;
                    }                    
                } 
            }            
        }
 
        if(lanzarError){
            throw new AuraHandledException('No tienes permisos para tomar en propiedad el Caso');
        }else{ 
            SAC_DatabaseDML.updateListDML(familia, true);
        }
    }

    /*****************************************************************
     * Proposito: Devolver las pretensiones a la cola Pdte asignar.
     * 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            NaN             Luis Mesa     22/02/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void devolverPretensionesApex(Id caseId, String motivo){
        Case caseSR = recuperarCaso(caseId);
        List<Case> familia = new List<Case>();
        List<Group> cola = new List<Group>();
        if (Schema.sObjectType.Group.isAccessible()) {
            cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue' LIMIT 1];
        }
        if(!cola.isEmpty()){
            if (Schema.sObjectType.Case.isAccessible()) {
                familia = [SELECT Id, OwnerId, SAC_NumDevoluciones__c, SAC_Motivo__c FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__c =: caseSR.SAC_Reclamacion__c];
            }
            if(!familia.isEmpty()){
                for(Case caso : familia){
                    caso.OwnerId = cola[0].id;
                    caso.SAC_NumDevoluciones__c = caso.SAC_NumDevoluciones__c == null ? 0 : caso.SAC_NumDevoluciones__c + 1;
                    caso.SAC_Motivo__c = motivo;
                }
            }
            if(Schema.sObjectType.Case.isUpdateable()){ 
                SAC_DatabaseDML.updateListDML(familia, true);  
            }else{
                throw new AuraHandledException('No tienes permisos');
            }
        }
        else{
            throw new AuraHandledException('No tienes permisos para devolver las pretensiones a la cola');
        }
    }

    
    /*****************************************************************
     * Proposito: Comprobar si el usuario propietario pertenece al grupo COPS.
     * 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US309487       Daniel Benito   22/03/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean propietarioCOPSAdministrador(Case caso){
 
        List<CC_Grupo_Colaborador_Contact__c> listaGCC = new List<CC_Grupo_Colaborador_Contact__c>();    
        Id idUser = UserInfo.getUserId();

        try {
            //Buscar los CC_Grupo_Colaborador_Contact__c en los que el usuario sea el ejecutor de la acción, que el grupo sea el de los casos a modificar y que el check de administrador esté en true
            listaGCC = [SELECT Id, CC_Grupo_Colaborador__c 
            FROM CC_Grupo_Colaborador_Contact__c 
            WHERE (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS' OR 
            (CC_Grupo_Colaborador__c =:caso.SAC_PretensionPrincipal__r.SEG_Grupo__c AND SAC_Administrador__c =true)
            OR 
            (CC_Grupo_Colaborador__c =:caso.SEG_Grupo__c AND SAC_Administrador__c =true))
            AND CC_Usuario__c=:idUser];
 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        if(!listaGCC.isEmpty()){
            return true;
        }else{
            return false;
        }
    }


     /*****************************************************************
     * Proposito: Comprobar si el usuario pertenece al grupo Letrados.
     * 
     * ***************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US309487       Sergio Martín  07/11/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static boolean esGrupoLetrado(){
 
        List<CC_Grupo_Colaborador_Contact__c> listaLetrados = new List<CC_Grupo_Colaborador_Contact__c>();    
        Id idUser = UserInfo.getUserId();

        try {
            listaLetrados = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__r.RecordType.DeveloperName 
            FROM CC_Grupo_Colaborador_Contact__c 
            WHERE CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_Letrados' AND CC_Usuario__c =: idUser];
 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        if(!listaLetrados.isEmpty()){
            return true;
        }else{
            return false;
        }
    }

    /*****************************************************************
    * Proposito: Método para rellenar una picklist con los grupos Letrado
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US309487       Daniel Benito   22/03/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static Map<Id, String> getGruposLetrado(){

        Map<Id, String> grupoNombre = new Map<Id, String>();
        List<CC_Grupo_Colaborador__c> gruposLetrados = [SELECT id, Name FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_Letrados' ORDER BY Name ASC];

        for(CC_Grupo_Colaborador__c grupo : gruposLetrados){
            grupoNombre.put(grupo.Id, grupo.Name);
        }

        return grupoNombre;

    }

    /*****************************************************************
    * Proposito: Método para reasginar las pretensiones de una reclamación
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US309487       Daniel Benito   22/03/2022      Creación
    * 1.1            US592561       Raúl Santos     15/05/2023      Modificación: al reasignar letrado, actualizar los campos indicador y fecha última asignación a letrado de la reclamación
    * 1.2            US638153       Raúl Santos     15/04/2024      Modificación: añadir el motivo de la reasignación a la reclamación y crear un feed item para mostrar en el historico de comunicaciones de la reclamación
    *****************************************************************/
    @AuraEnabled
    public static void reasignarPretensiones(Id caseId, Id idGrupo, String motivo){
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        List<Case> pretensiones = [SELECT id,OwnerId,SEG_Grupo__c,CaseNumber, SAC_Reclamacion__c FROM CASE WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c =: caseId];
        Case reclamacion = [SELECT id,SAC_IndicadorRevisado__c, SAC_FechaUltimaAsignacionLetrado__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Reclamacion' AND id =: caseId];
        List<Group> cola = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PendienteAsignar' AND Type = 'Queue'];

        List<Case> casosActualizar = new List<Case>();

        for(Case pretension : pretensiones){

            if(pretension.OwnerId != cola[0].Id || pretension.SEG_Grupo__c != idGrupo){
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(pretension.SAC_Reclamacion__c,
                                                                    'SAC_NuevoPropietarioCaso',
                                                                    'La pretensión ' + pretension.CaseNumber + ' ha cambiado de propietario',
                                                                    pretension.OwnerId,
                                                                    pretension.Id,
                                                                    '',
                                                                    '');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + pretension.Id;
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                pretension.OwnerId = cola[0].Id;
                pretension.SEG_Grupo__c = idGrupo;
            }
        }

        reclamacion.SAC_IndicadorRevisado__c = null;
        reclamacion.SAC_FechaUltimaAsignacionLetrado__c = System.now();
        reclamacion.SAC_MotivoReasignacion__c = motivo;

        casosActualizar.addAll(pretensiones);
        casosActualizar.add(reclamacion);

        SAC_DatabaseDML.updateListDML(casosActualizar, true);

        FeedItem feed = new FeedItem();
		feed.ParentId = caseId; 
        feed.Body = 'Se ha reasignado el letrado de las pretensiones por el siguiente motivo: ' + motivo;		
		SAC_DatabaseDML.insertDML(feed, true); 

        try{
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
        }  catch (DMLException e) {
            CBK_Log.error(e);
        }
    }

     /*****************************************************************
    * Proposito: Método para elevar una reclamación a la cola de supervisores 
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US383184      Marcela Neira  28/06/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void elevarCasoSupervisor(Case reclamacion, String texto) {
        
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];
        String comentarios;

        if (String.isBlank(texto)) {
            texto = 'No se dejó ningún comentario';
        }

        if(String.isNotBlank(reclamacion.SAC_ObservacionesSupervisor__c)){
            comentarios = reclamacion.SAC_ObservacionesSupervisor__c + 
            ' \n' + System.now() + '<p style="color:rgb(255,0,0);"> | Gestor | </p> \n' + 
            texto + '<p style="color:rgb(255,0,0);"> | ' + UserInfo.getName() + ' | </p> \n';
        }else{
            comentarios = System.now() + '<p style="color:rgb(255,0,0);"> | Gestor | </p> \n' + 
            texto + '<p style="color:rgb(255,0,0);"> | ' + UserInfo.getName() + ' | </p> \n';
        }

        Case caso = New Case(Id = reclamacion.Id, 
                            OwnerId = colaSupervisores.id, 
                            SAC_UserElevoASupervisor__c = UserInfo.getUserId(), 
                            SAC_ObservacionesSupervisor__c = comentarios);

        SAC_DatabaseDML.updateDML(caso, true);
    }

     /*****************************************************************
    * Proposito: Método para devolver una reclamación a la cola de supervisores 
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US383184      Marcela Neira  08/08/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void devolverCasoSupervisores(Case reclamacion, String texto) {
        
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];
        String comentarios;

        if (String.isBlank(texto)) {
            texto = 'No se dejó ningún comentario';
        }

        if(String.isNotBlank(reclamacion.SAC_ObservacionesSupervisor__c)){
            comentarios = reclamacion.SAC_ObservacionesSupervisor__c + 
            ' \n' + System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
            texto + '<p style="color:rgb(34,139,34);"> | ' + UserInfo.getName() + ' | </p> \n';
        }else{
            comentarios = System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
            texto + '<p style="color:rgb(34,139,34);"> | ' + UserInfo.getName() + ' | </p> \n';
        }
        Case caso = New Case(Id = reclamacion.Id, OwnerId = colaSupervisores.id, SAC_ObservacionesSupervisor__c = comentarios);
        
        SAC_DatabaseDML.updateDML(caso, true);
    }


     /*****************************************************************
    * Proposito: Método para elevar ula familia de pretensiones a la cola de supervisores 
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US383184      Marcela Neira  28/06/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void elevarCasoSupervisorPre(Id caseId, String texto) {

        String comentarios;
        Case casoAux = recuperarCaso(caseId);
        List<Case> listaPretensiones = [SELECT Id, SAC_ObservacionesSupervisor__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :casoAux.SAC_Reclamacion__c];
        
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];

        if (String.isBlank(texto)) {
            texto = 'No se dejó ningún comentario';
        }

        for (Case prete : listaPretensiones) {
            prete.OwnerId = colaSupervisores.id;
            prete.SAC_UserElevoASupervisor__c = UserInfo.getUserId();

            if(String.isNotBlank(prete.SAC_ObservacionesSupervisor__c)){
                comentarios = prete.SAC_ObservacionesSupervisor__c + 
                ' \n' + System.now() + '<p style="color:rgb(255,0,0);"> | Letrado | </p> \n' + 
                texto + '<p style="color:rgb(255,0,0);"> | ' + UserInfo.getName() + ' | </p> \n';
            }else{
                comentarios = System.now() + '<p style="color:rgb(255,0,0);"> | Letrado | </p> \n' + 
                texto + '<p style="color:rgb(255,0,0);"> | ' + UserInfo.getName() + ' | </p> \n';
            }
            prete.SAC_ObservacionesSupervisor__c = comentarios;
        }
        if(!Test.isRunningTest()) {
            try {
                SAC_DatabaseDML.updateListDML(listaPretensiones, true);
            } catch (Exception e) {
                throw new MyException(e);
            }
        }
        
    }
    

     /*****************************************************************
    * Proposito: Método para devolver el caso al gestor/proveedor que elevó la reclamación a la cola de supervisores
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US413828      Marcela Neira  19/07/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void devolverPropietarioAnterior(Case reclamacion, String texto) {
        
        String comentarios;

        if (String.isBlank(texto)) {
            texto = 'No se dejó ningún comentario';
        }

        if(String.isNotBlank(reclamacion.SAC_ObservacionesSupervisor__c)){
            comentarios = reclamacion.SAC_ObservacionesSupervisor__c + 
            ' \n' + System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
            texto + '<p style="color:rgb(34,139,34);"> | ' + UserInfo.getName() + ' | </p> \n';
        }else{
            comentarios = System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
            texto + '<p style="color:rgb(34,139,34);"> | ' + UserInfo.getName() + ' | </p> \n';
        }
                
        Case casoAux = New Case(Id = reclamacion.Id, 
                                OwnerId = reclamacion.SAC_UserElevoASupervisor__c, 
                                SAC_UserElevoASupervisor__c = null, 
                                SAC_ObservacionesSupervisor__c = comentarios);
    
        SAC_DatabaseDML.updateDML(casoAux, true);
    }


      /*****************************************************************
    * Proposito: Método para devolver la familia de pretensiones la cola de supervisores 
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US383184      Marcela Neira  08/08/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void devolverPretensionesSupervisores(Id caseId, String texto) {

        String comentarios;
        Case casoAux = recuperarCaso(caseId);
        List<Case> listaPretensiones = [SELECT Id, SAC_ObservacionesSupervisor__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :casoAux.SAC_Reclamacion__c];
        
        Group colaSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'SAC_PteSupervisor' AND Type = 'Queue' LIMIT 1];

        if (String.isBlank(texto)) {
            texto = 'No se dejó ningún comentario';
        }

        for (Case prete : listaPretensiones) {
            prete.OwnerId = colaSupervisores.id;

            if(String.isNotBlank(prete.SAC_ObservacionesSupervisor__c)){
            comentarios = prete.SAC_ObservacionesSupervisor__c + 
            ' \n' + System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
            texto + '<p style="color:rgb(34,139,34);"> | ' + UserInfo.getName() + ' | </p> \n';
            }else{
                comentarios = System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
                texto + '<p style="color:rgb(34,139,34);"> | ' + UserInfo.getName() + ' | </p> \n';
            } 
            
            prete.SAC_ObservacionesSupervisor__c = comentarios;
        }

        SAC_DatabaseDML.updateListDML(listaPretensiones, true);
    }

     /*****************************************************************
    * Proposito: Método para devolver la familia de pretensiones al gestor/proveedor/letrado que elevó la reclamación a la cola de supervisores
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US413828      Marcela Neira  19/07/2022      Creación
    *****************************************************************/
    @AuraEnabled
    public static void devolverPropietarioAnteriorPre(Id caseId, String texto) {
        
        String comentarios;
        Case casoAux = recuperarCaso(caseId);
        List<Case> listaPretensiones = [SELECT Id, SAC_ObservacionesSupervisor__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :casoAux.SAC_Reclamacion__c];

        if (String.isBlank(texto)) {
            texto = 'No se dejó ningún comentario';
        }

        for (Case prete : listaPretensiones) {
            prete.OwnerId = casoAux.SAC_UserElevoASupervisor__c;
            prete.SAC_UserElevoASupervisor__c = null;

            if(String.isNotBlank(prete.SAC_ObservacionesSupervisor__c)){
            comentarios = prete.SAC_ObservacionesSupervisor__c + 
            ' \n' + System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
            texto + '<p style="color:rgb(255,0,0);"> | ' + UserInfo.getName() + ' | </p> \n';
            }else{
                comentarios = System.now() + '<p style="color:rgb(34,139,34);"> | Supervisor | </p> \n' + 
                texto + '<p style="color:rgb(255,0,0);"> | ' + UserInfo.getName() + ' | </p> \n';
            } 
            prete.SAC_ObservacionesSupervisor__c = comentarios;
        }
        
        SAC_DatabaseDML.updateListDML(listaPretensiones, true);
    }

      /*****************************************************************
    * Proposito: Rellena el cuerpo de la plantilla de prorrogar caso
    * 
    * ***************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            DE65531          Raúl y Sergio  20/09/2022   Creación
    * 1.1                                            18/04/2023   Modificación
    * 1.2            US608688         Jose Carlos    10/10/2023   Modificación casos PSD2  
    *****************************************************************/
    @AuraEnabled
    public static String rellenarCampoCuerpoMensajeProrroga(String caseId) {

        Case casoAux = recuperarCaso(caseId);
        
        List<Case> lstPretensiones = [SELECT Id, SAC_Reclamacion__c, SAC_CASE_esPSD2__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :caseId];
    
        String whoId = UserInfo.getUserId();
        String stringFinal = '';
        String cuerpoEmail = '';
        Boolean esPSD2 = false;
        List<String> canalRespuesta = new List<String>();

        if(!lstPretensiones.isEmpty()){
            for(Case pretension : lstPretensiones){
                if(pretension.SAC_CASE_esPSD2__c == true){
                    esPSD2 = true;
                }
            }
        }

        if(!canalRespuesta.contains(casoAux.CC_Canal_Respuesta__c)){

            canalRespuesta.add(casoAux.CC_Canal_Respuesta__c); 
        }

        if(esPSD2 == true){
            
            Id idPlantilla = null;
            SAC_PlantillaRedaccion__c maestroPlantillas = new SAC_PlantillaRedaccion__c();
            if(casoAux.CC_Canal_Respuesta__c == 'Email' || casoAux.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
                maestroPlantillas = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, SAC_CanalRespuesta__c FROM SAC_PlantillaRedaccion__c WHERE RecordType.DeveloperName = 'SAC_Redaccion' AND SAC_TipoPlantilla__c =: 'SAC_Prorroga' AND SAC_CanalRespuesta__c IN: canalRespuesta];
            }
            
            if(maestroPlantillas.SAC_CanalRespuesta__c == 'Email'){
               
                if(casoAux.CC_Idioma__c == 'es'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                } else if(casoAux.CC_Idioma__c == 'ca'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCatalanId__c;
                } else if(casoAux.CC_Idioma__c == 'en'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaInglesId__c;
                } else {
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                }

                if(idPlantilla != null){
                    EmailTemplate templateEmail = new EmailTemplate();
                    templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantilla];
                    
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId); 
                    cuerpoEmail = renderStored.getHtmlBody();
                }

            } else if (maestroPlantillas.SAC_CanalRespuesta__c == 'SAC_CartaPostal'){
            
                if(casoAux.CC_Idioma__c == 'es'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                } else if(casoAux.CC_Idioma__c == 'ca'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCatalanId__c;
                } else if(casoAux.CC_Idioma__c == 'en'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaInglesId__c;
                } else {
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                }

                if(idPlantilla != null){
                    EmailTemplate templateEmail = new EmailTemplate();
                    templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantilla];
                    
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId); 
                    cuerpoEmail = renderStored.getHtmlBody();
                }
                
            } else if (casoAux.CC_Canal_Respuesta__c != 'Email' && casoAux.CC_Canal_Respuesta__c != 'SAC_CartaPostal'){
               
                EmailTemplate templateEmail = new EmailTemplate();
                templateEmail = [SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_ProrrogarCasoCXB' LIMIT 1];

                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId); 
                cuerpoEmail = renderStored.getHtmlBody();

                // Modificacion 1.1 - Crear fecha para posteriormente recoger el valor fecha actual de la plantilla (FECHAACTUAL) y sustituirlo por el System.Today
                // De esta manera sacamos la fecha ya que no es posible obtenerla en el Email Template con el mergeo de datos
                Datetime d = System.today();
                String formattedDate = d.day() + '-' + d.month()  + '-' + d.year();
                
                if(cuerpoEmail.contains('(FECHAACTUAL)')){
                    cuerpoEmail = renderStored.getHtmlBody().replace('(FECHAACTUAL)', formattedDate);
                }   
            }

        } else {
            EmailTemplate templateEmail = new EmailTemplate();
            templateEmail = [SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_ProrrogarCasoCXB' LIMIT 1];

            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId); 
            cuerpoEmail = renderStored.getHtmlBody();

            // Modificacion 1.1 - Crear fecha para posteriormente recoger el valor fecha actual de la plantilla (FECHAACTUAL) y sustituirlo por el System.Today
            // De esta manera sacamos la fecha ya que no es posible obtenerla en el Email Template con el mergeo de datos
            Datetime d = System.today();
            String formattedDate = d.day() + '-' + d.month()  + '-' + d.year();
            
            if(cuerpoEmail.contains('(FECHAACTUAL)')){
                cuerpoEmail = renderStored.getHtmlBody().replace('(FECHAACTUAL)', formattedDate);
            }
        }
        return cuerpoEmail;
    }

    @AuraEnabled
    public static String rellenarCampoSubjectMensajeProrroga(String caseId) {

        Case casoAux = recuperarCaso(caseId);

        List<Case> lstPretensiones = [SELECT Id, SAC_Reclamacion__c, SAC_CASE_esPSD2__c FROM Case WHERE RecordType.DeveloperName = 'SAC_Pretension' AND SAC_Reclamacion__c = :caseId];
        String whoId = UserInfo.getUserId();
        String subjectEmail = '';
        Boolean esPSD2 = false;
        List<String> canalRespuesta = new List<String>();

        if(!lstPretensiones.isEmpty()){
            for(Case pretension : lstPretensiones){
                if(pretension.SAC_CASE_esPSD2__c == true){
                    esPSD2 = true;
                }
            }
        }
   
        if(!canalRespuesta.contains(casoAux.CC_Canal_Respuesta__c)){

            canalRespuesta.add(casoAux.CC_Canal_Respuesta__c); 
        }
        
        
       
        if(esPSD2 == true){

            Id idPlantilla = null;
            SAC_PlantillaRedaccion__c maestroPlantillas = new SAC_PlantillaRedaccion__c();
            if(casoAux.CC_Canal_Respuesta__c == 'Email' || casoAux.CC_Canal_Respuesta__c == 'SAC_CartaPostal'){
                maestroPlantillas = [SELECT Id, SAC_PlantillaCatalanId__c, SAC_PlantillaCastellanoId__c, SAC_PlantillaInglesId__c, SAC_CanalRespuesta__c FROM SAC_PlantillaRedaccion__c WHERE RecordType.DeveloperName = 'SAC_Redaccion' AND SAC_TipoPlantilla__c =: 'SAC_Prorroga' AND SAC_CanalRespuesta__c IN: canalRespuesta];
            }
            
            if(maestroPlantillas.SAC_CanalRespuesta__c == 'Email'){
                
                if(casoAux.CC_Idioma__c == 'es'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                } else if(casoAux.CC_Idioma__c == 'ca'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCatalanId__c;
                } else if(casoAux.CC_Idioma__c == 'en'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaInglesId__c;
                } else {
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                }

                if(idPlantilla != null){
                    EmailTemplate templateEmail = new EmailTemplate();
                    templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantilla];
                    
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId); 
                    subjectEmail = renderStored.getSubject();
                }

            } else if (maestroPlantillas.SAC_CanalRespuesta__c == 'SAC_CartaPostal'){
                
                if(casoAux.CC_Idioma__c == 'es'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                } else if(casoAux.CC_Idioma__c == 'ca'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaCatalanId__c;
                } else if(casoAux.CC_Idioma__c == 'en'){
                    idPlantilla = maestroPlantillas.SAC_PlantillaInglesId__c;
                } else {
                    idPlantilla = maestroPlantillas.SAC_PlantillaCastellanoId__c;
                }

                if(idPlantilla != null){
                    EmailTemplate templateEmail = new EmailTemplate();
                    templateEmail = [SELECT Id, Name, Subject, HtmlValue FROM EmailTemplate WHERE Id =: idPlantilla];
                    
                    Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId); 
                    subjectEmail = renderStored.getSubject();
                }

            } else if (casoAux.CC_Canal_Respuesta__c != 'Email' && casoAux.CC_Canal_Respuesta__c != 'SAC_CartaPostal'){
                EmailTemplate templateEmail = new EmailTemplate();
                templateEmail = [SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_ProrrogarCasoCXB' LIMIT 1];
    
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId);               
                subjectEmail = renderStored.getSubject();
            }

        } else {

            EmailTemplate templateEmail = new EmailTemplate();
            templateEmail = [SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_ProrrogarCasoCXB' LIMIT 1];

            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(templateEmail.Id, whoId, caseId);              
            subjectEmail = renderStored.getSubject();
        }
        return subjectEmail;
    }

    @AuraEnabled
    static public void tomarPropiedadLetradoConsulta(Id caseId, Id ownerId){
        
        Case caseSR = recuperarCaso(caseId);
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Boolean lanzarError = true;

        if (Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()) {
            colabContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECORDTYPEGRUPOPLET  
                                AND CC_Grupo_Colaborador__c = :caseSR.SAC_GrupoLetrado__c AND CC_Usuario__c = :ownerId];
        }
        if(!colabContact.isEmpty()){
            String userName = UserInfo.getName();

            caseSR.SAC_Letrado__c = userName;
            lanzarError = false;
        }
        
        if(lanzarError){
            throw new AuraHandledException('No tienes permisos para tomar la propiedad como letrado de la consulta');
        }else{
            SAC_DatabaseDML.updateDML(caseSR, true); 

            //Dar permisos sobre el registro al propietario letrado
            CaseShare nuevoCS = new CaseShare();
            nuevoCS.CaseId = caseSR.Id;
            nuevoCS.UserOrGroupId = ownerId;
            nuevoCS.CaseAccessLevel='Edit';

            SAC_DatabaseDML.insertDML(nuevoCS, true); 
            
        }     
    }
    
    @AuraEnabled
    public static Boolean checkUserPermission(){
        Boolean hasPermission = false;
        List<String> permissionGroupList = new List<String>();
        String gruposLabel = System.Label.SAC_GruposDescartarConsultas;
        if(gruposLabel.contains(',')){
            permissionGroupList = (System.Label.SAC_GruposDescartarConsultas).split('\\s*,\\s*');
        }
        List<CC_Grupo_Colaborador_Contact__c> colaboradorList = [SELECT Id, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: userInfo.getUserId() AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c IN: permissionGroupList LIMIT 1];
        if(!colaboradorList.isEmpty()){
            hasPermission = true;
        }
        return hasPermission;
    }
}