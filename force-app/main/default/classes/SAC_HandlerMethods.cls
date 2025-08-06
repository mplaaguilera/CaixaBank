/*****************************************************************
 * Name: SAC_HandlerMethods
 * Copyright © 2021  CaixaBank 
 * 
 * Proposito: Clase que contiene los métodos reutilizables para el proyecto de SAC
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            N/A           Nicolás García   09/05/21      Creación
 * 1.1            US554738       Raúl Santos     23/03/23      Modificación: creación del método comprobarE2ERec() para tratar las pretensiones E2E 
 * 															   asociadas a un caso.
 *****************************************************************/
public without sharing class SAC_HandlerMethods {
	private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c', 'Case'};
	private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

	private static final Id RECTYPECASEEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SAC_ReclamacionCaseExt').getRecordTypeId();
	private static final Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

	
	/*****************************************************************
	 * Proposito: Método que comprueba si un Caso ha cambiado de Account y Contact y crea
	 * un registro en el objeto reclamante en caso de que así sea.
	 *  
	 * Historial
	 * -------
	 * VERSION        USER_STORY       AUTHOR         DATE         Description
	 * 1.0            US213184       Nicolás García   9/05/21      Creación
	 *****************************************************************/
	public static void createReclamanteRecord(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
		//RecordTypesIds
		Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
		Id recTypeConsulta= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
		Id recTypeConsultaSAC= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();

		List<SAC_CaseReclamante__c> reclamantesAInsertar = new List<SAC_CaseReclamante__c> ();
		Map<String, Id> mapReclamantes = new Map<String, Id> ();

		if (!Schema.sObjectType.SAC_CaseReclamante__c.isCreateable() || !Schema.sObjectType.SAC_CaseReclamante__c.isUpdateable() || !Schema.sObjectType.Case.isAccessible()) {
			return;
		}

		List<SAC_CaseReclamante__c> reclamantesTotal = [SELECT Id, SAC_Case__c, SAC_Account__c, SAC_Contact__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c in(SELECT Id FROM Case WHERE Id IN :listNewObj)];
		for (SAC_CaseReclamante__c tReclamantes : reclamantesTotal) {
			mapReclamantes.put(String.valueOf(tReclamantes.SAC_Case__c) + String.valueOf(tReclamantes.SAC_Account__c) + String.valueOf(tReclamantes.SAC_Contact__c), tReclamantes.Id);
		}
		Set<Id> sCasos = new Set<Id> ();

		//Si el mapa viene sin informar, estamos en un "insert"
		if (mapOldObj == null && !listNewObj.isEmpty()) {
			for (Case casoNuevo : listNewObj) {
				Boolean cuentaInformada = String.isNotBlank(casoNuevo.AccountId);
				if ((casoNuevo.RecordTypeId == recTypeReclamacion || casoNuevo.RecordTypeId == recTypeConsulta || casoNuevo.RecordTypeId == recTypeConsultaSAC) && cuentaInformada) {
					SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c(SAC_Account__c = casoNuevo.AccountId,
					                                                             SAC_Contact__c = casoNuevo.ContactId,
					                                                             SAC_Case__c = casoNuevo.Id,
					                                                             SAC_ReclamantePrincipal__c = true,
																				 Id = mapReclamantes.get(String.valueOf(casoNuevo.Id) + String.valueOf(casoNuevo.AccountId) + String.valueOf(casoNuevo.ContactId)));
					reclamantesAInsertar.add(reclamante);
					sCasos.add(casoNuevo.Id);
				}
			}
		}
		//Si el mapa no viene a nulo, estamos en un update
		else if (!listNewObj.isEmpty() && mapOldObj != null) {
			for (Case casoNuevo : listNewObj) {
				Boolean cuentaInformada = String.isNotBlank(casoNuevo.AccountId);
				if (mapOldObj.containsKey(casoNuevo.Id) && (casoNuevo.RecordTypeId == recTypeReclamacion || casoNuevo.RecordTypeId == recTypeConsulta || casoNuevo.RecordTypeId == recTypeConsultaSAC)&& cuentaInformada && mapOldObj.get(casoNuevo.Id).AccountId != casoNuevo.AccountId) {
					SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c(SAC_Account__c = casoNuevo.AccountId,
					                                                             SAC_Contact__c = casoNuevo.ContactId,
					                                                             SAC_Case__c = casoNuevo.Id,
					                                                             SAC_ReclamantePrincipal__c = true,
					                                                             Id = mapReclamantes.get(String.valueOf(casoNuevo.Id) + String.valueOf(casoNuevo.AccountId) + String.valueOf(casoNuevo.ContactId)));
					reclamantesAInsertar.add(reclamante);
					sCasos.add(casoNuevo.Id);
				}
			}
		}

		List<SAC_CaseReclamante__c> reclamantes = new List<SAC_CaseReclamante__c>();
		List<SAC_CaseReclamante__c> reclamantesAModificar = [SELECT Id, SAC_Account__c, SAC_Contact__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_ReclamantePrincipal__c = true AND SAC_Case__c in :sCasos AND Id not in :reclamantesAInsertar];
		for (SAC_CaseReclamante__c reclamante : reclamantesAModificar) {
			reclamante.SAC_ReclamantePrincipal__c = false;
		}

		reclamantes.addAll(reclamantesAModificar);
		reclamantes.addAll(reclamantesAInsertar);
		
		if (!reclamantes.isEmpty()) {
            SAC_DatabaseDML.upsertListDML(reclamantes, false);
		}
	}

	/*****************************************************************
	 * Proposito: Método para llevar la marcar E2E desde el MCC de cualquiera de las pretensiones a la reclamación. Con que uno de los MCC de las pretensiones (en estado no baja) sea de este tipo 
	 * ya se debe activar la marca en la reclamación.
	 *  
	 * Historial
	 * -------
	 * VERSION        USER_STORY       AUTHOR         DATE         Description
	 * 1.0            US554738       Raúl Santos    23/03/23       Creación
	 *****************************************************************/
	public static void comprobarE2ERec(List<Case> listaPretensiones, List<Id> listaIDsReclamacionGlobal, Boolean esNuevaPretension, Id recTypeReclamacion, Id recTypePretension) {  // Si esNuevaPretension == true  -> Se trata de pretensiones que se insertan

		Map<Id, Boolean> mapaReclamacion = new Map<Id, Boolean>();
		List<Case> listaReclamaciones = new List<Case>();

		List<Case> pretensiones = [SELECT Id, SEG_Detalle__c, SEG_Detalle__r.SAC_EndToEnd__c, SAC_Reclamacion__c, SAC_Reclamacion__r.SAC_E2E__c, Status FROM Case WHERE RecordTypeId = :recTypePretension AND Id IN :listaPretensiones];  //  (Status != 'SAC_009' OR Status != 'Cerrado')ORDER BY SAC_Reclamacion__r.SAC_E2E__c = true, asi si hay de estas solo entra una vez en el for

		//Crear un mapa de <Case,Id> para asociar cada una de las pretensiones que llega a su correspondiente reclamación
        //El mapa y todo lo demas se hace si pretensiones es distinto de vacio y nombralo lstPretensiones
        Map<Case,Id> mapaPretensiones = new Map<Case,Id>();                       
        for (Case pret : pretensiones) {
            mapaPretensiones.put(pret, pret.SAC_Reclamacion__c);
        }

		//Recorrer el mapa anterior, para crear uno nuevo con key el id de las reclamaciones, y asociar a cada una de estas sus pretensiones.
		Map<Id, List<Case>> mapaReclamacionPretensiones = new Map<Id, List<Case>>();
		for(Case pret : mapaPretensiones.keySet()){
			if(mapaReclamacionPretensiones.containsKey(pret.SAC_Reclamacion__c)){
                mapaReclamacionPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
            }else{
                List<Case> listaAux = new List<Case>();
                listaAux.add(pret);
                mapaReclamacionPretensiones.put(pret.SAC_Reclamacion__c, listaAux);
            }
		}

		//Comprobar si las reclamaciones tiene más pretensiones asociadas además de las que estamos tratando.
		List<Case> pretensionesAsociadas = [SELECT Id, SEG_Detalle__c, SEG_Detalle__r.SAC_EndToEnd__c, SAC_Reclamacion__c, Status FROM Case WHERE RecordTypeId = :recTypePretension AND SAC_Reclamacion__c IN :listaIDsReclamacionGlobal AND Id NOT IN :listaPretensiones AND (Status != 'SAC_009' AND Status != 'Cerrado')];
		if(!pretensionesAsociadas.isEmpty()){
			for(Case pret : pretensionesAsociadas){
				mapaReclamacionPretensiones.get(pret.SAC_Reclamacion__c).add(pret);
			}
		}
		
		for(Case pret : pretensiones){
			if(pret.SAC_Reclamacion__c != null){
				//Si la reclamación tiene el campo E2E a falso (no tiene ninguna otra pretension E2E), compruebo si la pretensión actual es E2E
				if(pret.SAC_Reclamacion__r.SAC_E2E__c == false){

					//Si la pretensión actual es E2E, añadimos a un nuevo mapa el id de la reclamación y el valor true, para posteriormente asignar el valor true al campo E2E de la reclamación.
					if(pret.SEG_Detalle__r.SAC_EndToEnd__c == true){
						mapaReclamacion.put(pret.SAC_Reclamacion__c, true);
					}
				}else if(pret.SAC_Reclamacion__r.SAC_E2E__c == true && esNuevaPretension != true){ //Si la reclamación tiene el campo E2E a true (ya tiene otra pretension E2E), si estoy insertando una nueva pretensión, no entro aquí

					//Recorremos todas las pretensiones de nuestro caso padre, para añadir las pretensiones hermanas en una lista
					List<Case> listaPretensionesHijas = new List<Case>();
					for(Id id : mapaReclamacionPretensiones.keySet()){
						if(pret.SAC_Reclamacion__c.equals(id)){
							for(Case pretension : mapaReclamacionPretensiones.get(id)){
								if(pretension.Id != pret.Id){
									listaPretensionesHijas.add(pretension);
								}
							}
						}	
					}

					//Si tenemos pretensiones hermanas 
					if(!listaPretensionesHijas.isEmpty()){ 
						Boolean pretE2EEncontrada = false;
						for(Case pretension : listaPretensionesHijas){

							//Comprobamos si alguna pretension hermana en estado diferente a baja, tiene el campo E2E del MCC con valor true.
							//En caso afirmativo, activamos un flag que indicará que el campo E2E de la reclamación debe seguir con valor true.
							if(pretension.SEG_Detalle__r.SAC_EndToEnd__c == true && pretension.Status != 'SAC_009'){
								pretE2EEncontrada = true;
							}
						}
						//Si ninguna pretension ha activado el flag, cambiamos a false el campo E2E de la reclamación
						if(pretE2EEncontrada == false){
							mapaReclamacion.put(pret.SAC_Reclamacion__c, false);
						}
					}else{
						//Si la reclamación solo tiene una pretensión, y esta pasa a baja, actualizaremos el campo E2E de la reclamación a false
						if(pret.Status == 'SAC_009'){
							mapaReclamacion.put(pret.SAC_Reclamacion__c, false);
						}else{  //Sino, lo actualizamos al valor del campo E2E del MCC de la pretension
							mapaReclamacion.put(pret.SAC_Reclamacion__c, pret.SEG_Detalle__r.SAC_EndToEnd__c);
						}	
					}
				}
			}
		}

		//Si debemos modificar el campo de la reclamación, recuperamos esta
		List<Case> reclamaciones = new List<Case>();
		if(!mapaReclamacion.isEmpty()){
			reclamaciones = [SELECT Id, SAC_E2E__c FROM Case WHERE RecordTypeId = :recTypeReclamacion AND Id IN :listaIDsReclamacionGlobal]; 
		}

		//Modificamos el campo E2E de la reclamación, con el valor que haya sido asignado en el mapa correspondiente.
		if(!reclamaciones.isEmpty()){
			for(Case rec : reclamaciones){
				if(mapaReclamacion.containsKey(rec.Id)){
					rec.SAC_E2E__c = mapaReclamacion.get(rec.Id);
					listaReclamaciones.add(rec);
				}
			}
			if (!Schema.sObjectType.Case.isUpdateable()) { throw new AuraHandledException( 'Error al actualizar el campo End2End de la reclamación.' ); }
            SAC_DatabaseDML.updateListDML(listaReclamaciones, false);
		}
	}


	/*******************************************************************************************************************
     * Proposito: Método para crear un registro asociado del CBK_Case_Extension__c a la reclamacion
     * 			Modificación 1.1: Se añade que las pretensiones que se crean en las reclamaciones cerradas se ponga a true el campo
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1114134     Sergio Martín   26/12/24     	Creación
	 * 1.1            US1132463     Sergio Martín   21/01/25     	Modificación
    **********************************************************************************************************************/
    /**
     * @description  Método para crear un registro asociado del CBK_Case_Extension__c a la reclamacion
     * @param listCasosInsertar
     */
    public static void creacionCaseExtension(List<Case> listCasosInsertar) { 
        List<CBK_Case_Extension__c> listaCaseExtension = new List<CBK_Case_Extension__c>();
        List<Case> listaCase = new List<Case>();
        Set<Id> idCasos = new Set<Id>();

        for(Case caso : listCasosInsertar) {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.recordTypeId = RECTYPECASEEXTENSION;
            caseExtension.Case_Id__c = caso.id;
			// Para la US1132463 se añade que las pretensiones que se crean en las reclamaciones cerradas se ponga a true el campo
			if(caso.recordTypeId == RECORDTYPEPRETENSION && caso.Status == 'SAC_003') {
				caseExtension.SAC_PretensionCreadaCerrada__c = true;
			}
            listaCaseExtension.add(caseExtension);
            idCasos.add(caso.id);
        }

        if (Schema.sObjectType.CBK_Case_Extension__c.isCreateable()) {    
            SAC_DatabaseDML.insertListDML(listaCaseExtension, false);
            List<Case> listaCaseActualizar = [SELECT Id, RecordTypeId, Status FROM Case WHERE Id IN :idCasos];
            if(!listaCaseActualizar.isEmpty()) {
                for(Case caso : listaCaseActualizar) {
                    for(CBK_Case_Extension__c extension : listaCaseExtension) {
                        if(extension.Case_Id__c == caso.id) {
                            caso.CBK_Case_Extension_Id__c = extension.id;
                            listaCase.add(caso);
                        }
                    }
                }

                if (Schema.sObjectType.Case.isUpdateable()) {  
                    SAC_DatabaseDML.updateListDML(listaCase, false);
                }
            }
        }
    }


	/*******************************************************************************************************************
     * Proposito: Método para insertar permisos al creador de las pretensiones que se crean cerradas directamente
	 *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US1132463     Sergio Martín   22/01/25     	Creación
    **********************************************************************************************************************/
    /**
     * @description  Método para crear un registro asociado del CBK_Case_Extension__c a la reclamacion
     * @param listaPretensionesCreadasCerradas
     */
    public static void insertarCaseSharePretensionCerrada(List<Case> listaPretensionesCreadasCerradas) { 
        List<CaseShare> listaCaseShare = new List<CaseShare>();
        
        if(!listaPretensionesCreadasCerradas.isEmpty()){
            for(Case pretension : listaPretensionesCreadasCerradas){
                CaseShare csNuevo = new CaseShare();
                csNuevo.CaseId = pretension.Id;
                csNuevo.UserOrGroupId = pretension.CreatedById;
                csNuevo.CaseAccessLevel='Edit';
                listaCaseShare.add(csNuevo);
            }
			if(!listaCaseShare.isEmpty()){
            	SAC_DatabaseDML.insertListDML(listaCaseShare, false);
			}
        }
    }
}