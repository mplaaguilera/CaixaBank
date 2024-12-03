public with sharing class CC_Agrupador_CIM_Asignacion_Casos {

    @InvocableMethod
    public static void asociarCasosAComunicacionInformativa(List<Id> idsCasos) {

        DateTime dt = DateTime.now();
		Long dateInMilliseconds = dt.getTime();
		
		AsyncOptions options = new AsyncOptions();
		options.DuplicateSignature = QueueableDuplicateSignature.Builder()
		.addId(UserInfo.getUserId())
						.addString(String.valueOf(dateInMilliseconds))
						.build();

		try {
			asociarCasosMarcaAComunicacionInformativaQueueable asociarCasosCIM = new asociarCasosMarcaAComunicacionInformativaQueueable();
            List<Id> idsCasosList = idsCasos;
		    asociarCasosCIM.setParams(idsCasosList);
		    System.enqueueJob(asociarCasosCIM, options);

		} catch (DuplicateMessageException ex) {
			//Exception is thrown if there is already an enqueued job with the same signature
            CBK_log.debug('CC_Agrupador_CIM_Asignacion_Casos.asociarCasosMarcaAComunicacionInformativaQueueable: ' + ex);
        }
    }

    public class asociarCasosMarcaAComunicacionInformativaQueueable implements Queueable {

       private List<Id> idsCasos;
		
		public void setParams(List<Id> idsCasos) {
			this.idsCasos = idsCasos;
		}

		public void execute(QueueableContext context) {
            asociarCasosMarcaAComunicacionInformativaNoFuture(idsCasos);
    	}
	}
    
    public static void asociarCasosMarcaAComunicacionInformativaNoFuture(List<Id> idsCasos) {

        Set<Id> idsMarcasNuevosAgrupadores = new Set<Id>();
        Set<Id> idsCasosMarca = new Set<Id>();
        List<Case> casosActualizar = new List<Case>();
        List<CC_Marca_Case__c> lstCaseMarca = new List<CC_Marca_Case__c>();
        List<CC_Agrupador__c> comunicacionesInformativasExistentes = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> comunicacionesInformativasInsertar = new List<CC_Agrupador__c>();
        Map<String, String> mapAgrupadorMarca = new Map<String, String>();
        Map<Id, List<Id>> mapMarcaCase = new Map<Id, List<Id>>();
        Map<Id, CC_Caracteristica__c> mapMarca = new Map<Id, CC_Caracteristica__c>();
        Map<String, List<Case>> mapCasosMarca = new Map<String, List<Case>>();
        Id recordTypeDeveloperName = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa_de_Marca');


        lstCaseMarca = [SELECT CC_Case__c, CC_Marca__c, CC_Marca__r.CC_Casos_requeridos_CIM__c, CC_Marca__r.Name FROM CC_Marca_Case__c WHERE CC_Case__c IN :idsCasos];

        if(lstCaseMarca.isEmpty()){
            return;
        } 

        for (CC_Marca_Case__c marcaCaso : lstCaseMarca) {      
            if(!mapMarca.containsKey(marcaCaso.CC_Marca__c)){
                 CC_Caracteristica__c marca = new CC_Caracteristica__c();
                 marca.CC_Casos_requeridos_CIM__c = marcaCaso.CC_Marca__r.CC_Casos_requeridos_CIM__c;
                 marca.Name = marcaCaso.CC_Marca__r.Name;
                 mapMarca.put(marcaCaso.CC_Marca__c, marca);
            }                   
             
        }   
        
        comunicacionesInformativasExistentes = [SELECT Id, CC_Marca__c FROM CC_Agrupador__c WHERE RecordTypeId = :recordTypeDeveloperName AND CC_Estado__c = 'Activo' AND CC_Marca__c IN :mapMarca.keySet() AND CreatedDate = TODAY WITH SECURITY_ENFORCED];

        if(!comunicacionesInformativasExistentes.isEmpty()) {
            for (CC_Agrupador__c comunicacionExistente : comunicacionesInformativasExistentes) {
                mapAgrupadorMarca.put(comunicacionExistente.CC_Marca__c , comunicacionExistente.Id);
            }
        }

        List<Case> casosConMismaMarca = new List<Case>();
        casosConMismaMarca =  [SELECT CC_Comunicacion_Informativa__c, CC_Admin__c FROM Case WHERE Id = :idsCasos
                                        AND CC_MCC_Tematica__r.CC_Activo__c = true
                                        AND CC_MCC_ProdServ__R.CC_Activo__c = TRUE
                                        AND CC_MCC_Motivo__R.CC_Activo__c = TRUE
                                        AND CC_MCC_Causa__R.CC_Activo__c = TRUE
                                        WITH SECURITY_ENFORCED];

        for (Case caso : casosConMismaMarca) {
            for (CC_Marca_Case__c marca : lstCaseMarca) {
                    if(mapCasosMarca.containsKey(marca.CC_Marca__c)) {
                        List<Case> lstCasosAgrupados = mapCasosMarca.get(marca.CC_Marca__c);
                        lstCasosAgrupados.add(caso);
                        mapCasosMarca.put(marca.CC_Marca__c,lstCasosAgrupados);
                    } else {
                        mapCasosMarca.put(marca.CC_Marca__c, new List<Case> {caso});
                    }
            }
        }
        
        for(Id marcaId: mapCasosMarca.keySet()){
            List<Case> casosMismaMarca = mapCasosMarca.get(marcaId);
            Integer totalCasos = casosMismaMarca.size();
            for (Case caso : casosMismaMarca) {
                if (mapAgrupadorMarca.containsKey(marcaId) && caso.CC_Comunicacion_Informativa__c == null) {
                    caso.CC_Comunicacion_Informativa__c = mapAgrupadorMarca.get(marcaId);
                    caso.CC_Admin__c = true;
                    casosActualizar.add(caso);
                } else {
                    CC_Caracteristica__c marca = mapMarca.get(marcaId);
                    if (totalCasos >= marca.CC_Casos_requeridos_CIM__c) {
                        CC_Agrupador__c comunicacionInformativaNueva = new CC_Agrupador__c();
                        Id comunicacionInformativaMarcaRecordTypeId = recordTypeDeveloperName;
                        comunicacionInformativaNueva.RecordTypeId = comunicacionInformativaMarcaRecordTypeId;
                        comunicacionInformativaNueva.CC_Estado__c = 'Activo';
                        comunicacionInformativaNueva.CC_Titulo__c = marca.Name;
                        comunicacionInformativaNueva.CC_Marca__c = marcaId;
                        if(!comunicacionesInformativasInsertar.contains(comunicacionInformativaNueva)){
                            comunicacionesInformativasInsertar.add(comunicacionInformativaNueva);
                        }
                    } else {
                        caso.CC_Comunicacion_Informativa__c = null;
                        caso.CC_Admin__c = true;
                        casosActualizar.add(caso);
                    }
                }
            }
        }
        

        if(!comunicacionesInformativasInsertar.isEmpty()){
            List<Database.SaveResult> resultadosInsertados = Database.insert(comunicacionesInformativasInsertar, false);

            for (Database.SaveResult agrupadoInsertado : resultadosInsertados) {
                if (agrupadoInsertado.isSuccess()) {
                    idsMarcasNuevosAgrupadores.add(agrupadoInsertado.getId());
                }
            }
        }

        if(!idsMarcasNuevosAgrupadores.isEmpty()){
            List<CC_Agrupador__c> lstAgreupadoresInsertados = [SELECT Id, CC_Marca__c FROM CC_Agrupador__c WHERE Id IN :idsMarcasNuevosAgrupadores WITH SECURITY_ENFORCED];

            if(!lstAgreupadoresInsertados.isEmpty()){

                for (CC_Agrupador__c agrupadorInsertado : lstAgreupadoresInsertados) {
                    if(mapCasosMarca.containsKey(agrupadorInsertado.CC_Marca__c)){
                        for (Case casoAgrupado : mapCasosMarca.get(agrupadorInsertado.CC_Marca__c)) {
                        	if (casoAgrupado.CC_Comunicacion_Informativa__c != agrupadorInsertado.Id) { 
                            	casoAgrupado.CC_Comunicacion_Informativa__c = agrupadorInsertado.Id;
                            	casoAgrupado.CC_Admin__c = true;
                            	casosActualizar.add(casoAgrupado);
                        	}
                    	}
                    }
                }
            }
        }
        
        if(!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa__c.isUpdateable() &&  Schema.sObjectType.Case.fields.CC_Admin__c.isUpdateable()){
            update casosActualizar;
        }

        for (Case casoActualizar : casosActualizar) {
            casoActualizar.CC_Admin__c = false;
        }

        update casosActualizar;
    }
}