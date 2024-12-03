/*****************************************************************
 * Name: SAC_LCMP_BusquedaCliente
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear el componente SAC_BusquedaCliente
 * Este clase se cubre con los siguientes test:
 * SAC_LCMP_BusquedaCliente_Test
 * SAC_LCMP_BusquedaSecundaria_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213183         Nicolás García --     	   Creación
*****************************************************************/
public without sharing class SAC_LCMP_BusquedaCliente {
    
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECORDTYPECONSULTA = mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static Id RECORDTYPECONSULTASAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    
    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoListSexo(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = Account.CC_Sexo__pc.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoListTipoCodigo(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = Account.SAC_TipoDeCodigo__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoListIdioma(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = Account.CC_Idioma__pc.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
    }

    public class PlantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }

    @AuraEnabled
    public static Map<String, Object> getIdentidad(String tipoBusqueda, String valorBusqueda) {
        if(tipoBusqueda == 'SF')
        {
            return busquedaClienteLocal (valorBusqueda);
        }
        else
        {
            return CC_IdentCliente_Future.IdentificarPersALFSync(tipoBusqueda, valorBusqueda);
        }
    }

    static public Map<String,Object> busquedaClienteLocal (String sBusqueda)
    {

        String sCuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();

        Map<String,Object> oRes = new Map<String,Object>();

        List<List<SObject>> searchList = SAC_HandlerWithoutSharingMethods.queryBusquedaClienteLocal(sBusqueda, sCuentaRecordType);
												
		for (List<SObject> searchSubList : searchList)
		{
			if (!searchSubList.isEmpty())
			{
				if (searchSubList[0].getSObjectType() == Schema.Account.getSObjectType())
				{
					oRes.put('CUENTAS', searchSubList);
				}
			}
		}

        if(oRes.isEmpty()){
            oRes.put('CUENTAS', new Set<Account>{});
        }
        
		return oRes;
    }
    static public void actualizaIdentidad (String sID)
    {
        List<Account> datosCuenta = [SELECT Id, AV_NumPerso__c FROM Account WHERE RecordType.DeveloperName in ('CC_ClientePA', 'CC_Cliente', 'SAC_NoCliente_PA', 'CC_CentroCaixaBank') and Id = :sID];
        if (!datosCuenta.isEmpty())
        {
            CC_IdentCliente_Future.IdentificarPersALFASynchronous('NP', datosCuenta[0].AV_NumPerso__c);
        }
    }


	public class ContratoPicklistItemWrapper {
		@AuraEnabled
        public String value{get;set;}

		@AuraEnabled
        public String label{get;set;}
    }

	public class RepresentanteOrContactoWrapper {
		@AuraEnabled
        public Boolean representante{get;set;}

        @AuraEnabled
        public String idContacto{get;set;}

        @AuraEnabled
        public String idRepresentante{get;set;}

        @AuraEnabled
        public String idJunction{get;set;}

        @AuraEnabled
        public String nombre{get;set;}

        @AuraEnabled
        public String nombreCuenta{get;set;}

        @AuraEnabled
        public String nombreContrato{get;set;}

        @AuraEnabled
        public String tipoRepresentante{get;set;}

        @AuraEnabled
        public String cargoRepresentante{get;set;}

        @AuraEnabled
        public String idCuenta{get;set;}

        @AuraEnabled
        public String tipoPersonaCliente{get;set;}
    }
    
    @AuraEnabled
    public static List<ContratoPicklistItemWrapper> getContratosCliente(String sRepresentanteOrContactoId, String sTipoRegistro) {
		List<ContratoPicklistItemWrapper> oContratos = new List<ContratoPicklistItemWrapper>();
        String sClienteId = '';
        if (sTipoRegistro == 'Representante') {
			sClienteId = [SELECT CC_ClienteRepresentante__c FROM CC_Representante_Contrato__c WHERE Id = :sRepresentanteOrContactoId].CC_ClienteRepresentante__c;
        } else if (sTipoRegistro == 'Contacto') {
            sClienteId = [SELECT AccountId FROM Contact WHERE Id = :sRepresentanteOrContactoId].AccountId;
        }

        String sContratoRecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Contrato').getRecordTypeId();
        for (CC_Representante_Contrato__c contrato : [SELECT CC_Contrato__c FROM CC_Representante_Contrato__c WHERE RecordTypeId = :sContratoRecordTypeId AND CC_ClienteContrato__c = :sClienteId]) {
            ContratoPicklistItemWrapper contratoPicklistItem = new ContratoPicklistItemWrapper();
            contratoPicklistItem.value = contrato.Id;
            contratoPicklistItem.label = contrato.CC_Contrato__c + ' - ' + 'Descripción del contrato';
            oContratos.add(contratoPicklistItem);
        }
        return oContratos;
    }
    
    @AuraEnabled
    public static List<RepresentanteOrContactoWrapper> getRepresentantesOrContactosCliente(String sCliente) {

		List<RepresentanteOrContactoWrapper> oRepresentantesOrContactos = new List<RepresentanteOrContactoWrapper>();
		// Si no hay datos, salir.
        if (sCliente == '' || sCliente == null) {
            return null;
        }
        
        String sTipoPersona = SAC_HandlerWithoutSharingMethods.queryRepresentantesOrContactosCliente(sCliente);

        // Buscar los representantes de la cuenta.
        if (sTipoPersona == 'J') {
            String sRepresentanteRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
            for (Contact representante : [SELECT CC_CuentaRepresentada__c, CC_CuentaRepresentada__r.Name, FirstName,
                                          LastName, CC_CargoRepresentante__c
                                          FROM Contact
                                          WHERE CC_CuentaRepresentada__c = :sCliente
                                          AND CC_CuentaRepresentada__r.CC_NumPerso__c <> null
                                          AND RecordTypeId = :sRepresentanteRecordTypeId]) {
                RepresentanteOrContactoWrapper representanteWrapper = new RepresentanteOrContactoWrapper();
                representanteWrapper.representante = true;
                representanteWrapper.tipoPersonaCliente = sTipoPersona;
                representanteWrapper.idRepresentante = representante.Id;
                representanteWrapper.nombre = representante.FirstName + ' ' +  representante.LastName;
                representanteWrapper.nombreCuenta = representante.CC_CuentaRepresentada__r.Name;
                representanteWrapper.idCuenta = representante.CC_CuentaRepresentada__c;
                representanteWrapper.cargoRepresentante = representante.CC_CargoRepresentante__c;
                oRepresentantesOrContactos.add(representanteWrapper);
            }
        } else if (sTipoPersona == 'F') {
            String sRepresentanteContratoRecordTypeId = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_RepresentanteContrato').getRecordTypeId();
            for (CC_Representante_Contrato__c representante : [SELECT CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c, CC_RepresentanteAsociado__c, CC_RepresentanteAsociado__r.CC_Nombre__c, CC_RepresentanteAsociado__r.CC_Apellido1__c, CC_RepresentanteAsociado__r.CC_Apellido2__c, CC_RepresentanteAsociado__r.CC_TipoRepresentante__c, CC_ContratoAsociado__r.Name FROM CC_Representante_Contrato__c WHERE CC_RepresentanteAsociado__r.CC_ClienteRepresentante__r.Id = :sCliente AND CC_RepresentanteAsociado__r.CC_ClienteRepresentante__r.CC_NumPerso__c <> null AND RecordTypeId = :sRepresentanteContratoRecordTypeId]) {
                RepresentanteOrContactoWrapper representanteWrapper = new RepresentanteOrContactoWrapper();
                representanteWrapper.representante = true;
				representanteWrapper.tipoPersonaCliente = sTipoPersona;
                representanteWrapper.idJunction = representante.Id;
                representanteWrapper.idRepresentante = representante.CC_RepresentanteAsociado__c;
                representanteWrapper.nombre = representante.CC_RepresentanteAsociado__r.CC_Nombre__c + ' ' +  representante.CC_RepresentanteAsociado__r.CC_Apellido1__c + ' ' + representante.CC_RepresentanteAsociado__r.CC_Apellido2__c;
                representanteWrapper.nombreContrato = representante.CC_ContratoAsociado__r.Name;
                representanteWrapper.idCuenta = representante.CC_RepresentanteAsociado__r.CC_ClienteRepresentante__c;
                representanteWrapper.tipoRepresentante = representante.CC_RepresentanteAsociado__r.CC_TipoRepresentante__c;
                oRepresentantesOrContactos.add(representanteWrapper);
            }
        }

        // Si la cuenta no tiene representantes, buscar sus contactos.
        if (oRepresentantesOrContactos.isEmpty()) {
            oRepresentantesOrContactos = getContactosCliente(sCliente);
        }

        if(oRepresentantesOrContactos.isEmpty()){
            return null;
        }else{
            return oRepresentantesOrContactos;
        }
        
    }
    
    @AuraEnabled
    public static List<RepresentanteOrContactoWrapper> getContactosCliente(String sCliente) {
		List<RepresentanteOrContactoWrapper> oContactos = new List<RepresentanteOrContactoWrapper>();

        String sClienteRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        String sCuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();

        List<Contact> listaContactos = [SELECT AccountId, Name, Account.Name
                                 FROM Contact
                                 WHERE Account.Id = :sCliente AND (Account.CC_NumPerso__c <> null OR Account.RecordTypeId=:sCuentaRecordType)
                                 AND (RecordTypeId = :sClienteRecordType OR RecordTypeId = null)];

        if(listaContactos.isEmpty()){
            RepresentanteOrContactoWrapper contactoWrapper = new RepresentanteOrContactoWrapper();
            contactoWrapper.representante = false;
            contactoWrapper.idContacto = null;
            contactoWrapper.nombre = null;
            contactoWrapper.nombreCuenta = null;
            contactoWrapper.idCuenta = sCliente;
            oContactos.add(contactoWrapper);
        }else{
            for (Contact contacto: listaContactos) {
                RepresentanteOrContactoWrapper contactoWrapper = new RepresentanteOrContactoWrapper();
                contactoWrapper.representante = false;
                contactoWrapper.idContacto = contacto.Id;
                contactoWrapper.nombre = contacto.Name;
                contactoWrapper.nombreCuenta = contacto.Account.Name;
                contactoWrapper.idCuenta = contacto.AccountId;
                oContactos.add(contactoWrapper);
            }
        }
        
        return oContactos;
    }

    @AuraEnabled
    public static void setClienteCaso(String sID, String sTipo, String sCasoId) {

        Map<String, Object> oRes = new Map<String, Object>();

        if(!Schema.sObjectType.Contact.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes permisos para realizar esta acción.');
        }
        
        // Si no hay datos, salir.
        if (String.isBlank(sID) || String.isBlank(sTipo)) {
            throw new AuraHandledException('No se ha seleccionado un registro válido.');
        }

        if (String.isBlank(sCasoId)) {
            throw new AuraHandledException('No hay un caso vinculado.');
        }

        //Actualizamos con datos de ALF
        actualizaIdentidad (sID);
        //Preparar los datos de cuenta y contacto para actualizar en el caso.
		String sRepresentanteId = '';
        String sContactId = null;
        String sCuentaId = null;
        String sIdioma = '';
        String sOficina = '';
        
        if (sTipo == 'Representante') {
            
            sContactId = sID;
            
            // Buscamos el cliente asociado al contacto.
            Contact oContacto = [SELECT CC_CuentaRepresentada__c, Account.CC_Idioma__pc, Account.AV_EAPGestor__c, Account.AV_EAPGestor__r.AccountId FROM Contact WHERE Id = :sContactId];

            if (oContacto.CC_CuentaRepresentada__c != null) {
                sCuentaId = oContacto.CC_CuentaRepresentada__c;
                sIdioma = oContacto.Account.CC_Idioma__pc;
                sOficina = oContacto.Account.AV_EAPGestor__r.AccountId;
            }
        } else if (sTipo == 'Contacto') {

            sContactId = sID;
            
            // Buscamos el cliente asociado al contacto.
            Contact oContacto = [SELECT AccountId, Account.CC_Idioma__pc, Account.AV_EAPGestor__c, Account.AV_EAPGestor__r.AccountId FROM Contact WHERE Id = :sContactId];
            if (oContacto.AccountId != null) {
                sCuentaId = oContacto.AccountId;
                sIdioma = oContacto.Account.CC_Idioma__pc;
                sOficina = oContacto.Account.AV_EAPGestor__r.AccountId;
            }

        } else {
            sCuentaId = sID;

            List<Contact> oContactos = [SELECT Id, Account.CC_Idioma__pc, Account.AV_EAPGestor__c, Account.AV_EAPGestor__r.AccountId FROM Contact WHERE AccountId = :sID];
            if (oContactos.size() == 1) {
                sContactId = oContactos[0].Id;
                sIdioma = oContactos[0].Account.CC_Idioma__pc;
                sOficina = oContactos[0].Account.AV_EAPGestor__r.AccountId;
            }

        }
        
        // Actualizamos el caso con los datos facilitados por el usuario.
        Case oCaseUpd = new Case(Id = sCasoId);
        
        // if(sIdioma != null && !String.isBlank(sIdioma)) {
        //     //oCaseUpd.CC_Idioma__c = sIdioma;
        // }

        if(sOficina != null && !String.isBlank(sOficina)) {
            oCaseUpd.CC_Oficina__c = sOficina;
        }

        oCaseUpd.ContactId = sContactId;
        oCaseUpd.AccountId = sCuentaId;
        
        if (oCaseUpd.AccountId == null && oCaseUpd.ContactId == null && oCaseUpd.CC_Representante__c == null) {
            oCaseUpd.CC_No_Identificado__c  = true;
            oCaseUpd.CC_IdentCliente__c     = '0'; // Sin datos ALF
        } else {
            oCaseUpd.CC_No_Identificado__c  = false;
            oCaseUpd.CC_IdentCliente__c     = '2'; // Alfabetico manual
        }

        List<Case> pretensiones = [SELECT id, ContactId, AccountId, CC_Representante__c, CC_No_Identificado__c, CC_IdentCliente__c FROM CASE WHERE recordTypeId =: RECORDTYPEPRETENSION AND SAC_Reclamacion__C =: sCasoId];

        if(!pretensiones.isEmpty()){

            for(Case pretension : pretensiones){

                pretension.ContactId = sContactId;
                pretension.AccountId = sCuentaId;
        
                if (pretension.AccountId == null && pretension.ContactId == null && pretension.CC_Representante__c == null) {
                    
                    pretension.CC_No_Identificado__c  = true;
                    pretension.CC_IdentCliente__c     = '0'; // Sin datos ALF

                } else {

                    pretension.CC_No_Identificado__c  = false;
                    pretension.CC_IdentCliente__c     = '2'; // Alfabetico manual
                }
            }
        }
        
		List<Case> updateCases = new List<Case>();
        
        updateCases.add(oCaseUpd);
        
        if(!pretensiones.isEmpty()){
        	updateCases.addAll(pretensiones);
        }
        SAC_DatabaseDML.updateListDML(updateCases, true); 
    }

    @AuraEnabled
    public static void crearReclamanteSecundario(String sID, String sTipo, String sCasoId){

        //Actualizamos con datos de ALF
        actualizaIdentidad (sID);

        String sRepresentanteId = '';
        String sContactId       = null;
        String sCuentaId        = null;

        if (sTipo == 'Representante') {
            
            sContactId = sID;
            
            // Buscamos el cliente asociado al contacto.
            Contact oContacto = [SELECT CC_CuentaRepresentada__c FROM Contact WHERE Id = :sContactId];
            if (oContacto.CC_CuentaRepresentada__c != null) {
                sCuentaId = oContacto.CC_CuentaRepresentada__c;
            }
            
        } else if (sTipo == 'Contacto') {
            sContactId = sID;
            
            // Buscamos el cliente asociado al contacto.
            Contact oContacto = [SELECT AccountId FROM Contact WHERE Id = :sContactId];
            if (oContacto.AccountId != null) {
                sCuentaId = oContacto.AccountId;
            }
        }
        else {
            sCuentaId = sID;

            List<Contact> oContactos = [SELECT Id FROM Contact WHERE AccountId = :sID];
            if (oContactos.size() == 1) {
                sContactId = oContactos[0].Id;
            }
        }
        SAC_CaseReclamante__c reclamanteSecundario = new SAC_CaseReclamante__c(
                                                                                SAC_Case__c = sCasoId, 
                                                                                SAC_Account__c = sCuentaId, 
                                                                                SAC_Contact__c = sContactId
                                                                            );
        List<SAC_CaseReclamante__c> reclamantesExistentes = [SELECT Id FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :sCasoId 
                                                                                                        AND SAC_Account__c = :sCuentaId 
                                                                                                        AND SAC_Contact__c = :sContactId];
        // if(!reclamantesExistentes.isEmpty()){
        //     throw new AuraHandledException('Ya existe este reclamante en la reclamación.');
        // }
        SAC_DatabaseDML.insertDML(reclamanteSecundario, true);
    }

    private static String getTipoRegistro(Id sID) {
        //Devolvemos el tipo de registro para poder realizar las acciones necesarias en cada una de las diferentes entidades
        String sTipoRegistro = '';
        if ((sID).getSObjectType() == Schema.getGlobalDescribe().get('Case')) {
            sTipoRegistro = 'Caso';
        }
        return sTipoRegistro;
    }

    @AuraEnabled
    public static String getContactoAsoc(String sCuenta) {
        return [SELECT Id FROM Contact WHERE AccountId = :sCuenta].Id;
    }
    
    @AuraEnabled
	public static Boolean getEsPropietarioCaso(Id recordId) {
		//Comparamos el usuario logado con el propietario del registro y devolvemos si coinciden o no
        Case caso = new Case();
        Id usuarioActual = UserInfo.getUserId();
        String tipoRegistro = getTipoRegistro(recordId);
        if (tipoRegistro == 'Caso') {
            caso = [SELECT OwnerId, SAC_PretensionPrincipal__r.OwnerId FROM Case WHERE RecordTypeId IN (:RECORDTYPERECLAMACION, :RECORDTYPECONSULTA, :RECORDTYPECONSULTASAC, :RECORDTYPEPRETENSION) AND Id = :recordId];
        }
        return (caso.OwnerId == usuarioActual || caso.SAC_PretensionPrincipal__r.OwnerId == usuarioActual) ? true : false;
	}
    
    @AuraEnabled
	public static void actualizarIdentificacion(Id recordId, Boolean noIdentificado, String tipoRegistro) {

        if (tipoRegistro == 'Case') {
            Case caso = new Case(Id = recordId);

            caso.CC_No_Identificado__c = noIdentificado;
            if (noIdentificado) {
                caso.AccountId = null;
                caso.ContactId = null;
                caso.CC_Representante__c = null;
                caso.CC_IdentCliente__c = '0'; // Sin datos ALF
            }
            SAC_DatabaseDML.updateDML(caso, true);
        }
    }
    
    @AuraEnabled
    public static List<Case> datosCaso(String recordId) {
        return [SELECT CC_No_Identificado__c, ContactId, AccountId FROM Case WHERE RecordTypeId IN (:RECORDTYPERECLAMACION, :RECORDTYPECONSULTA, :RECORDTYPECONSULTASAC, :RECORDTYPEPRETENSION) AND Id = :recordId];
    }

    @AuraEnabled
    public static sObject datosRegistro(Id recordId) {
        sObject retorno;
        retorno = [SELECT CC_No_Identificado__c, SAC_OrigenConsulta__c, AccountId, ContactId, RecordType.DeveloperName, SAC_CasoRelacionado__c FROM Case WHERE RecordTypeId IN (:RECORDTYPERECLAMACION, :RECORDTYPECONSULTA, :RECORDTYPECONSULTASAC, :RECORDTYPEPRETENSION) AND Id = :recordId];
        return retorno;
    }

    @AuraEnabled
	public static Boolean comprobarMultiplesCasosCliente(Id contactId, Id accountId) {
        Id userId = UserInfo.getUserId();
        Group pendienteAsignar = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        List<Case> casosExistentes = [SELECT Id FROM Case WHERE RecordTypeId =: RECORDTYPERECLAMACION AND Status NOT IN ('Cerrado', 'Rechazado', 'SAC_008', 'SAC_009', 'SAC_012', 'SAC_013', 'SAC_014') AND OwnerId <>: pendienteAsignar.Id AND ((AccountId <> NULL AND AccountId =: accountId) OR (ContactId <> null AND ContactId=:contactId)) AND OwnerId <>: userId];

        return (casosExistentes.size()>0);
	}

    @AuraEnabled
    public static string getRecTypeCliente(){
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE DeveloperName = 'SAC_NoCliente_PA' and SobjectType='Account' AND IsPersonType=True LIMIT 1];
        return personAccountRecordType.Id;
    }

    @AuraEnabled
    public static void actualizarReclamanteNoCliente(String caseId, String accountId){
        try {
            SAC_HandlerWithoutSharingMethods.actualizarReclamanteNoClienteWithoutSharing(caseId, accountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void insertarPermisosAccount(Id cuenta){
        Id idUsuario = UserInfo.getUserId();
        List <AccountShare> listaAccountShare = new List <AccountShare>();

        AccountShare acshare = new AccountShare();

        acshare.AccountId = cuenta;
        acshare.UserOrGroupId = idUsuario;
        acshare.AccountAccessLevel = 'Read';
        acshare.OpportunityAccessLevel = 'None';
        acshare.CaseAccessLevel = 'None';

        listaAccountShare.add(acshare);

        SAC_DatabaseDML.insertListDML(listaAccountShare, false);
    }

    @AuraEnabled
    public static Id crearNoCli(String firstName, String lastName, String personEmail, /*Date CC_FechaNac,*/ String phone, String sacTipoDeCodigo, String ccNumeroDocumento, /*String CC_Idioma, String CC_Sexo,*/ String billingStreet, String billingPostalCode, String billingCity, String billingState, String billingCountry){

        String sCuentaRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAC_NoCliente_PA').getRecordTypeId();

        Account cuenta = new Account();

        cuenta.RecordTypeId = sCuentaRecordType;
        cuenta.FirstName = firstName;
        cuenta.LastName = lastName;
        cuenta.PersonEmail = personEmail;
        cuenta.CC_Email__c = personEmail;
        cuenta.Phone = phone;
        cuenta.SAC_TipoDeCodigo__c = sacTipoDeCodigo;
        cuenta.CC_Numero_Documento__c = ccNumeroDocumento;
        cuenta.BillingStreet = billingStreet;
        cuenta.BillingPostalCode = billingPostalCode;
        cuenta.BillingCity = billingCity;
        cuenta.BillingState = billingState;
        cuenta.BillingCountry = billingCountry;

        try{
            SAC_DatabaseDML.insertDML(cuenta, true);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return cuenta.id;
    }

    @AuraEnabled
    public static List<CC_Caracteristica_Detalle__c> comprobarCaracteristicasCliente(Id accountId){

        Id sacCaracteristicaClienteRT = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SAC_CaracteristicaClienteCuenta').getRecordTypeId();

        List<CC_Caracteristica_Detalle__c> caracteristicasCliente = [SELECT Id, CC_Caracteristica__c, CC_Caracteristica__r.Name, CC_Caracteristica__r.CC_Descripcion__c FROM CC_Caracteristica_Detalle__c WHERE SAC_Cuenta__c = :accountId AND CC_Caracteristica__r.RecordTypeId = :sacCaracteristicaClienteRT AND CC_Caracteristica__r.CC_Activo__c = true];
        
        return caracteristicasCliente;
    }
}