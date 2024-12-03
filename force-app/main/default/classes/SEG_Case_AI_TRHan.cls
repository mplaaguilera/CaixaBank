/**
*   @description SEG_Case_AI_TRHan
*/
public with sharing class SEG_Case_AI_TRHan extends CC_TriggerHandlerBase{
    /**
     * @description   Método principal del trigger.
     * @param tp -> Contexto del trigger.
     */ 
    public override void mainEntry(CC_TriggerParameters tp)
    {
        // Quedarnos solo con los registros de segmentos.

        List<Id> casosSegmentos = new List<Id>();
		List<Id> casosSeguimiento = new List<Id> ();
        List<Id> allCasesSEG = new List<Id> ();
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        for (Case caso : (List<Case>)tp.newList)
        {
            if (caso.RecordTypeId == recordTypeSEG)
            {
                casosSegmentos.add(caso.Id);
            }
			else if (caso.RecordTypeId == recordTypeSeguimiento) {
				casosSeguimiento.add(caso.Id);
			}
        }
        if(casosSegmentos.size()>0 || casosSeguimiento.size()>0)
        {   
            // Preparar la lista completa de los TODOS los casos de segmentos.
			allCasesSEG.addAll(casosSeguimiento);
			allCasesSEG.addAll(casosSegmentos);
            process(allCasesSEG, casosSegmentos,casosSeguimiento, (Map<Id, Case>)tp.newMap, (Map<Id, Case>)tp.oldMap);
        }

    }
    /**
     * @description   Proceso de negocio del trigger.
     * @param allCasesSEG Lista de todos los Ids de casos de segmentos.
     * @param casosSEG -> Lista de Ids de casos de Segmentos.
     * @param casosSeguimiento Lista de Ids de los casos de Seguimiento
     * @param mapNewObj -> Mapa de casos con los valores nuevos
     * @param mapOldObj -> Mapa de casos con los valores nuevos
     */ 
    private void process(List<Id> allCasesSEG,List<Id> casosSEG,List<Id> casosSeguimiento, Map<Id, Case> mapNewObj, Map<Id, Case> mapOldObj)
    {
        insertarMarcas(allCasesSEG, mapNewObj, mapOldObj);
        llamarEncolableGestorComercial(allCasesSEG, mapNewObj);
        indicarGrupoAnterior(mapNewObj);
        insertarDatosChatter(allCasesSEG,mapNewObj); // US820562 - Chatter - Incluir información del 1r contactocuenta informado en el caso
        conexionTaskConnect(allCasesSEG, mapNewObj); // US697153 - Metodo para realizar la conexión inicial con TaskConect para los casos identificados como tales.
    }

    public static void llamarEncolableGestorComercial(List<Id> allCasesSEG, Map<Id, Case> mapNewObj){
        Map<Id,Case> mapNewObjCloned = new map<Id,Case>();
        for(Id caseId : mapNewObj.keySet()){ 
            mapNewObjCloned.put(caseId, mapNewObj.get(caseId).clone(true, true, false, true));
        }
        ID jobID = System.enqueueJob(new SEG_GrupoGestorCaseQueable(allCasesSEG, mapNewObjCloned));
    }

    public static void insertarMarcas(List<Id> casosSEG, Map<Id, Case> mapNewObj, Map<Id,Case> mapOldObj){
       

		String flag = 'CaseAI';
		SEG_Case_Utilities.insertarMarcas(casosSEG, mapNewObj, mapOldObj, flag);
	}    

    /**
	 * @description Metodo para generar el registro de propietarios según los grupos del caso. Si el propietario es un usuario si indicará como propietario anterior.
	 * @param allCasosSegmentos Lista de los casos
	 */
	public static void indicarGrupoAnterior (Map<Id, Case> mapNewObj){
		List<Case> casosIndicarGrupoAnterior = new List<Case>();
        List<SEG_Grupos_por_caso__c> listaRegistroGrupos = new List<SEG_Grupos_por_caso__c>();
		for (Id caseId : mapNewObj.keySet()) {
			if (mapNewObj.get(caseId).SEG_Grupo__c != null){
				casosIndicarGrupoAnterior.add(mapNewObj.get(caseId));				
			}
		}
		if(!casosIndicarGrupoAnterior.isEmpty()){
            for (Case caso : casosIndicarGrupoAnterior) {
                SEG_Grupos_por_caso__c grupoCasoNuevo = new SEG_grupos_por_caso__c();
                grupoCasoNuevo.SEG_GrupoId__c = caso.SEG_Grupo__c;
                grupoCasoNuevo.SEG_CaseId__c = caso.Id;
                
                if(caso.OwnerId.getSObjectType() == Schema.getGlobalDescribe().get('User')){
                    grupocasoNuevo.SEG_PropAnteriorGrupo__c = caso.OwnerId;
                }

                listaRegistroGrupos.add(grupoCasoNuevo);
            }

            if (!listaRegistroGrupos.isEmpty()) {
                insert listaRegistroGrupos;
            }
		}
	}

    
    /**
	 * @description US697153 - Metodo para realizar la conexión inicial con TaskConect para los casos identificados como tales.
	 * @param allCasosSegmentos Lista de los casos
	 */
	public static void conexionTaskConnect(List<Id> allCasesSEG, Map<Id, Case> mapNewObj){

        Map<Id, String> mapCasosTaskConnect = new Map<Id, String>();

        for (Id idCaso : allCasesSEG) {
            if(mapNewObj.containsKey(idCaso) && mapNewObj.get(idCaso).SEG_sincronizado_con_TaskConnect__c){
                mapCasosTaskConnect.put(idCaso, 'A'); //US745996 - Task Connect - Diferenciar primera invocación de las siguientes - Se indica que es un alta Taskconnect
            }
        }
        if (!mapCasosTaskConnect.isEmpty()) {
            SEG_TaskConnect.envioComunicacionTrigger(mapCasosTaskConnect);
        }
	}

    /**
	* @description Método para indicar el contacto y cuenta de caso junto con su email y nif en el chatter.
	* @param casosSEG Lista de Ids de los casos
	* @param mapNewObj Mapa de casos nuevos
	*/
	public static void insertarDatosChatter(List<Id> casosSEG, Map<Id, Case> mapNewObj){

        List<Id> listaComentariosChatter = new List<Id>();
        Map<Id, Account> mapIdCuenta;
        Map<Id, Contact> mapIdContacto;
        Set<Id> setCuentas = new Set<Id>();
        Set<Id> setContactos = new Set<Id>();
        List<FeedItem> comentariosChatter = new List<FeedItem>();

        for (Id idCaso : casosSEG) {
            if(mapNewObj.containsKey(idCaso) && mapNewObj.get(idCaso).AccountId != null || mapNewObj.get(idCaso).ContactId != null){
                listaComentariosChatter.add(idCaso);
                if(mapNewObj.get(idCaso).AccountId != null){
                    setCuentas.add(mapNewObj.get(idCaso).AccountId);
                }
                if(mapNewObj.get(idCaso).ContactId != null){
                    setContactos.add(mapNewObj.get(idCaso).ContactId);
                }
            }
        }

        if(!listaComentariosChatter.isEmpty()){
            if(!setCuentas.isEmpty()){
                mapIdCuenta = new Map<Id, Account>([SELECT id, Name, CC_Numero_Documento__c FROM Account WHERE id IN :setCuentas]);
            }
            if(!setCuentas.isEmpty()){
                mapIdContacto = new Map<Id, Contact>([SELECT id, Name, Email FROM Contact WHERE id IN :setContactos]);
            }

            for(id casoChatter : listaComentariosChatter){
                // Variable donde se guardara el mensaje a insertar
                String msg = '';
                // Insertar en Chatter
                FeedItem feed = new FeedItem();
                feed.ParentId = casoChatter;
                feed.Type = 'TextPost';               

                if(mapIdContacto.containsKey(mapNewObj.get(casoChatter).ContactId)){
                    msg += 'Nombre de contacto ' + mapIdContacto.get(mapNewObj.get(casoChatter).ContactId).Name + ' - ' + mapIdContacto.get(mapNewObj.get(casoChatter).ContactId).Email + ' ';
                }

                if(mapIdCuenta.containsKey(mapNewObj.get(casoChatter).AccountId)){
                    msg += 'Nombre de cliente ' + mapIdCuenta.get(mapNewObj.get(casoChatter).AccountId).Name + ' - ' + mapIdCuenta.get(mapNewObj.get(casoChatter).AccountId).CC_Numero_Documento__c;
                }

                feed.Body = msg;
                comentariosChatter.add(feed);
            }
                    
            if(!comentariosChatter.isEmpty()){
            	Database.insert (comentariosChatter, false);
			}
        }
	}
}