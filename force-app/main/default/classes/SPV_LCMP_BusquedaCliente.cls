/*****************************************************************
 * Name: SPV_LCMP_BusquedaCliente
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
 * 1.0                             Carlos Gómez   --     	   Creación
*****************************************************************/
public with sharing class SPV_LCMP_BusquedaCliente {
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();


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
            
            Integer numeroDeContactos = 0;

            for (Contact contacto : oContactos) {
                numeroDeContactos++;    
            }

            if (numeroDeContactos == 1) {
                sContactId = oContactos[0].Id;
                sIdioma = oContactos[0].Account.CC_Idioma__pc;
                sOficina = oContactos[0].Account.AV_EAPGestor__r.AccountId;
            }

        }
        
        // Actualizamos el caso con los datos facilitados por el usuario.
        Case oCaseUpd = new Case(Id = sCasoId);
        
        if(sIdioma != null && !String.isBlank(sIdioma)) {
            oCaseUpd.CC_Idioma__c = sIdioma;
        }

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
        SPV_DatabaseDML.updateListDML(updateCases, true); 
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
            Integer numeroDeContactos = 0;
            
            for (Contact contacto : oContactos) {
                numeroDeContactos++;
            }
            
            if (numeroDeContactos == 1) {
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
        SPV_DatabaseDML.insertDML(reclamanteSecundario, true);
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
            SPV_DatabaseDML.updateDML(caso, true);
        }
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
            SPV_DatabaseDML.insertDML(cuenta, true);
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return cuenta.id;
    }
}