public with sharing class SAC_CaseReclamanteHandler {

	public static void actualizaReclamanteCaso_AD(List<SAC_CaseReclamante__c> listOld)
	{
		if (!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable() || !Schema.sObjectType.SAC_CaseReclamante__c.isAccessible() || !Schema.sObjectType.SAC_CaseReclamante__c.isUpdateable()) {
			return;
		}
		//RecordTypesIds
		Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

		Map<Id,Case> mapCaseUpd = new Map<Id,Case>();
		//Obtener todos los reclamantes del caso
		Set<Id> caseIds = new Set<Id> ();
		Id caseId;
		for (SAC_CaseReclamante__c oldRecl : listOld) {
			caseId = oldRecl.SAC_Case__c!= null ? oldRecl.SAC_Case__c : oldRecl.SAC_Pretension__c;
			caseIds.add(caseId);
		}

		Map<Id, List<SAC_CaseReclamante__c>> caseReclamante = obtenerReclamantesCasos(caseIds);

		SAC_CaseReclamante__c newRec;
		List<SAC_CaseReclamante__c> lstNewRec = new List<SAC_CaseReclamante__c> ();
		Case updCase;
		for (SAC_CaseReclamante__c c : listOld) {
			if (c.SAC_ReclamantePrincipal__c == true) {
				caseId = c.SAC_Case__c!= null ? c.SAC_Case__c : c.SAC_Pretension__c; 	
				if (caseReclamante.containsKey(caseId)) {
					newRec = caseReclamante.get(caseId).get(0);
					newRec.SAC_ReclamantePrincipal__c = true;
					lstNewRec.add(newRec);
				}else if(!mapCaseUpd.containsKey(caseId)){
					updCase = new Case(Id = caseId, AccountId = null, ContactId = null, CC_Telefono_Contacto__c = null,
				                   SAC_DireccionPostalNotificacion__c = null,
				                   SAC_ReclamanteConformeNegociacion__c = false, OS_Email__c = null);
					mapCaseUpd.put(updCase.Id,updCase);
				}
			}
		}
		if (mapCaseUpd.size() > 0) {
			update mapCaseUpd.values();
		}
		if (lstNewRec.size() > 0) {
			update lstNewRec;
		}
	}

	public static void actualizaReclamanteCaso(List<SAC_CaseReclamante__c> listNew) {
		
		if (!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable() || !Schema.sObjectType.SAC_CaseReclamante__c.isAccessible() || !Schema.sObjectType.SAC_CaseReclamante__c.isUpdateable()) {
			return;
		}

		Case[] updates = new Case[] { };
		Map<Id, Case> caseMap = new Map<Id, Case> ([Select Id, AccountId, ContactId from Case where Id IN(SELECT SAC_Case__c FROM SAC_CaseReclamante__c where Id in :listNew)]);
		Id caseId;
		if(caseMap.size()>0){
			for (SAC_CaseReclamante__c c : listNew) {
				caseId = c.SAC_Case__c!= null ? c.SAC_Case__c : c.SAC_Pretension__c;
				if (c.SAC_ReclamantePrincipal__c == true && (c.SAC_Account__c != caseMap.get(caseId).AccountId || c.SAC_Contact__c != caseMap.get(caseId).ContactId)) {
					updates.add(new Case(Id = c.SAC_Case__c, AccountId = c.SAC_Account__c, ContactId = c.SAC_Contact__c));
				}
			}
			update updates;
		}
	}

	public static void validarUpdate(List<SAC_CaseReclamante__c> listNewObj, Map<Id, SAC_CaseReclamante__c> mapOldObj)
    {
		//Obtener todos los reclamantes del caso
		Set<Id> caseIds = new Set<Id> ();
		Id caseId;
		for (SAC_CaseReclamante__c newRecl : listNewObj) {
			caseId = newRecl.SAC_Case__c!= null ? newRecl.SAC_Case__c : newRecl.SAC_Pretension__c;
			caseIds.add(caseId);
		}
		Map<Id, List<SAC_CaseReclamante__c>> caseReclamante = obtenerReclamantesCasos(caseIds);

   		for(SAC_CaseReclamante__c rec :listNewObj){
			caseId = rec.SAC_Case__c!= null ? rec.SAC_Case__c : rec.SAC_Pretension__c;
			if(!rec.SAC_ReclamantePrincipal__c && mapOldObj.get(rec.Id).SAC_ReclamantePrincipal__c && !existeReclamantePrincipal(caseReclamante.get(caseId),rec.Id)){
				rec.SAC_ReclamantePrincipal__c.addError('Un caso con reclamantes tiene que tener al menos un reclamante como principal');
			}
		}
    }
	private static Boolean existeReclamantePrincipal(List<SAC_CaseReclamante__c> lstRecl,Id currentRecId){
		for(SAC_CaseReclamante__c r : lstRecl){
			if(currentRecId!= r.Id && r.SAC_ReclamantePrincipal__c){
				return true;
			}
		}
		return false;
	}
	private static Map<Id, List<SAC_CaseReclamante__c>> obtenerReclamantesCasos(Set<Id> caseIds){
		Map<Id, List<SAC_CaseReclamante__c>> caseReclamante = new Map<Id, List<SAC_CaseReclamante__c>> ();
		List<SAC_CaseReclamante__c> lstRecla = [SELECT SAC_Case__c,SAC_Pretension__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c where SAC_Case__c in :caseIds OR SAC_Pretension__c in:caseIds];
		Id caseId;
		for (SAC_CaseReclamante__c r : lstRecla) {
			caseId = r.SAC_Case__c!= null ? r.SAC_Case__c : r.SAC_Pretension__c; 
			if (caseReclamante.containsKey(caseId)) {
				caseReclamante.get(caseId).add(r);
			} else {
				caseReclamante.put(caseId, new List<SAC_CaseReclamante__c> { r });
			}
		}
		return caseReclamante;
	}

	public static void compruebaPrincipal(List<SAC_CaseReclamante__c> listNewObj){

		//Caso -> Reclamantes
		Map<Id, List<SAC_CaseReclamante__c>> mapDatos = new Map<Id, List<SAC_CaseReclamante__c>>();
		
		//Id caso vinculado al reclamante nuevo
		Set<Id> idCasos = new Set<Id>();
		
		for(SAC_CaseReclamante__c reclamante : listNewObj){
			idCasos.add(reclamante.SAC_Case__c);			
		}

		//reclamantes vinculados a casos que coinciden con los casos vinculados de los reclamantes nuevos
		List<SAC_CaseReclamante__c> reclamantesExistentes = [SELECT Id, SAC_Case__c,SAC_Pretension__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c IN: idCasos];
		
		for(SAC_CaseReclamante__c reclamante : reclamantesExistentes){
			if(mapDatos.containsKey(reclamante.SAC_Case__c)){
				List<SAC_CaseReclamante__c> aux = mapDatos.get(reclamante.SAC_Case__c);
				aux.add(reclamante);
				mapDatos.put(reclamante.SAC_Case__c, aux);
			}
			else{
				List<SAC_CaseReclamante__c> aux = new List<SAC_CaseReclamante__c>();
				aux.add(reclamante);
				mapDatos.put(reclamante.SAC_Case__c, aux);
			}
		}

		for(SAC_CaseReclamante__c reclamante : listNewObj){
			//si el mapa contiene valor para este caso quiere decir que ya hay un reclamante principal
			if(mapDatos.containsKey(reclamante.SAC_Case__c)){
				reclamante.SAC_ReclamantePrincipal__c = false;
			}
			else{
				reclamante.SAC_ReclamantePrincipal__c = true;
			}
		}
	}

	 /**************************************************************************
     * Proposito: Rellenar campos del caso relacionados con el contacto insertado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US336184         Daniel Benito  21/02/2022   Creación
    **************************************************************************/  

    public static void rellenarDatosCaseReclamante(List<SAC_CaseReclamante__c> listNewCaseReclamante){
        Set<Id> setIdsAccounts = new Set<Id>();
		List<Case> casosUpdate = new List<Case>();
        for (SAC_CaseReclamante__c reclamante : listNewCaseReclamante) {
            setIdsAccounts.add(reclamante.SAC_Account__c);
        }

        Map<Id, Account> mapaAccounts = new Map<Id, Account>([SELECT Id, Phone, CC_Email__c, PersonEmail, ShippingPostalCode, CC_Segmento__c, CC_SubSegmento__c, BillingPostalCode, BillingStreet, BillingCity, BillingState, CC_Edad__pc,CC_Gestor_InTouch__c, CC_FechaNac__pc, AV_OfficeManager__c FROM Account WHERE Id IN :setIdsAccounts]);
        for (SAC_CaseReclamante__c reclamante : listNewCaseReclamante) {
            if (mapaAccounts.containsKey(reclamante.SAC_Account__c)) {
                reclamante.SAC_Telefono__c = mapaAccounts.get(reclamante.SAC_Account__c).Phone;
				if(String.isNotBlank(mapaAccounts.get(reclamante.SAC_Account__c).CC_Email__c)){
					reclamante.SAC_CorreoElectronico__c = mapaAccounts.get(reclamante.SAC_Account__c).CC_Email__c; 
				}
				else if(String.isNotBlank(mapaAccounts.get(reclamante.SAC_Account__c).PersonEmail)){
					reclamante.SAC_CorreoElectronico__c = mapaAccounts.get(reclamante.SAC_Account__c).PersonEmail;
				}
                reclamante.SAC_Edad__c = mapaAccounts.get(reclamante.SAC_Account__c).CC_Edad__pc;
                reclamante.SAC_FechaDeNacimiento__c = mapaAccounts.get(reclamante.SAC_Account__c).CC_FechaNac__pc;

				reclamante.SAC_DireccionPostal__c = mapaAccounts.get(reclamante.SAC_Account__c).BillingStreet;
				if(reclamante.SAC_DireccionPostal__c != null && reclamante.SAC_DireccionPostal__c.length() > 60){
					reclamante.SAC_DireccionPostal__c = reclamante.SAC_DireccionPostal__c.substring(0, 60);
				}

                reclamante.SAC_Segmento__c = mapaAccounts.get(reclamante.SAC_Account__c).CC_Segmento__c;
                reclamante.SAC_Subsegmento__c = mapaAccounts.get(reclamante.SAC_Account__c).CC_SubSegmento__c;
				reclamante.SAC_PoblacionContacto__c = mapaAccounts.get(reclamante.SAC_Account__c).BillingCity;
				reclamante.SAC_ProvinciaContacto__c = mapaAccounts.get(reclamante.SAC_Account__c).BillingState;
				reclamante.SAC_CodigoPostalContacto__c = mapaAccounts.get(reclamante.SAC_Account__c).BillingPostalCode;
				reclamante.SAC_CodigoPostalContacto__c = mapaAccounts.get(reclamante.SAC_Account__c).BillingPostalCode;

				String sOficina = mapaAccounts.get(reclamante.SAC_Account__c).AV_OfficeManager__c;
				if(!String.isBlank(sOficina)) {
					Case oCaseUpd = new Case();
					oCaseUpd.id = reclamante.SAC_Case__c;
					oCaseUpd.CC_Oficina__c = sOficina;
					casosUpdate.add(oCaseUpd);
				}

                if(String.isNotBlank(mapaAccounts.get(reclamante.SAC_Account__c).CC_Gestor_InTouch__c)){

                    reclamante.SAC_GestorInTouch__c = mapaAccounts.get(reclamante.SAC_Account__c).CC_Gestor_InTouch__c;
                    reclamante.SAC_ClienteInTouch__c = true;

                }else{

                    reclamante.SAC_ClienteInTouch__c = false;
                }
            }
        }

		if(!casosUpdate.isEmpty()) {
			SAC_DatabaseDML.updateListDML(casosUpdate, false);
		}
    }
}