public with sharing class CC_Agrupador_CIC_Asignacion_Casos {

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
			asociarCasosCampanaAComunicacionInformativaQueueable asociarCasosCIC = new asociarCasosCampanaAComunicacionInformativaQueueable();
            List<Id> idsCasosList = idsCasos;
		    asociarCasosCIC.setParams(idsCasosList);
		    System.enqueueJob(asociarCasosCIC, options);

		} catch (DuplicateMessageException ex) {
			//Exception is thrown if there is already an enqueued job with the same signature
            CBK_log.debug('CC_Agrupador_CIC_Asignacion_Casos.asociarCasosCampanaAComunicacionInformativa: ' + ex);
        }
	}

    public class asociarCasosCampanaAComunicacionInformativaQueueable implements Queueable {

        
       private List<Id> idsCasos;
		
		public void setParams(List<Id> idsCasos) {
			this.idsCasos = idsCasos;
		}

		public void execute(QueueableContext context) {
            asociarCasosCampanaAComunicacionInformativaNoFuture(idsCasos);
    	}
	}
    
    public static void asociarCasosCampanaAComunicacionInformativaNoFuture(List<Id> idsCasos) {

        Set<Id> idsCasosSet = new Set<Id>(idsCasos);
        Set<Id> idsCampanasSet = new Set<Id>();
        Set<Id> idsCampanasNuevosAgrupadores = new Set<Id>();
        List<Case> casosActualizar = new List<Case>();
        List<Case> lstCasosConCampana = new List<Case>();
        List<Case> lstCasosConMismaCampana = new List<Case>();
        List<CC_Agrupador__c> comunicacionesInformativasExistentes = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> comunicacionesInformativasInsertar = new List<CC_Agrupador__c>();
        Map<String, String> mapAgrupadorCampana = new Map<String, String>();
        Map<String, List<Case>> mapCampanaCasos = new Map<String, List<Case>>();
        Map<String, String> mapCasoAgrupador = new Map<String, String>();
        String recordTypeDeveloperName = 'CC_Comunicacion_Informativa_de_Campana';
        
        String umbralPrimerAvisoString = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name = :CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso'].CC_Valor__c;
        Integer umbralPrimerAviso = Integer.valueOf(umbralPrimerAvisoString);

        lstCasosConMismaCampana = [SELECT Id, CC_Comunicacion_Informativa_Campana__c, CC_Admin__c, 
                                    CC_Campana__c, CC_Campana__r.Name FROM Case   
                                    WHERE Id IN :idsCasos
                                    WITH SECURITY_ENFORCED];

        if(lstCasosConMismaCampana.isEmpty()){
            return;
        }


        for (Case casoConMismaCampana : lstCasosConMismaCampana) {
            if(mapCampanaCasos.containsKey(casoConMismaCampana.CC_Campana__c)) {
                List<Case> lstCasosAgrupados = mapCampanaCasos.get(casoConMismaCampana.CC_Campana__c);
                lstCasosAgrupados.add(casoConMismaCampana);
                mapCampanaCasos.put(casoConMismaCampana.CC_Campana__c,lstCasosAgrupados);
            } else {
                mapCampanaCasos.put(casoConMismaCampana.CC_Campana__c, new List<Case> {casoConMismaCampana});
            }
        }                                       

        comunicacionesInformativasExistentes = [SELECT Id, CC_Campana__c FROM CC_Agrupador__c WHERE RecordType.DeveloperName = :recordTypeDeveloperName AND CC_Estado__c = 'Activo' AND CC_Campana__c IN :mapCampanaCasos.keySet() AND CreatedDate = TODAY WITH SECURITY_ENFORCED];
     
        if(!comunicacionesInformativasExistentes.isEmpty()) {
            for (CC_Agrupador__c comunicacionExistente : comunicacionesInformativasExistentes) {
                mapAgrupadorCampana.put(comunicacionExistente.CC_Campana__c , comunicacionExistente.Id);
            }
        }

        for (Case casoConMismaCampana : lstCasosConMismaCampana) {
            if (mapAgrupadorCampana.containsKey(casoConMismaCampana.CC_Campana__c) && casoConMismaCampana.CC_Comunicacion_Informativa_Campana__c != mapAgrupadorCampana.get(casoConMismaCampana.CC_Campana__c)) {
                casoConMismaCampana.CC_Comunicacion_Informativa_Campana__c = mapAgrupadorCampana.get(casoConMismaCampana.CC_Campana__c);
                casoConMismaCampana.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCampana);
			} else {
                if (mapCampanaCasos.get(casoConMismaCampana.CC_Campana__c).size() >= umbralPrimerAviso) {
                	CC_Agrupador__c comunicacionInformativaNueva = new CC_Agrupador__c();
                    Id comunicacionInformativaCampanaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
                    comunicacionInformativaNueva.RecordTypeId = comunicacionInformativaCampanaRecordTypeId;
                    comunicacionInformativaNueva.CC_Estado__c = 'Activo';
                    comunicacionInformativaNueva.CC_Titulo__c = casoConMismaCampana.CC_Campana__r.Name;
                    comunicacionInformativaNueva.CC_Campana__c = casoConMismaCampana.CC_Campana__c;
                    if(!comunicacionesInformativasInsertar.contains(comunicacionInformativaNueva)){
                    	comunicacionesInformativasInsertar.add(comunicacionInformativaNueva);
                    }
                } else {
                    casoConMismaCampana.CC_Comunicacion_Informativa__c = null;
                    casoConMismaCampana.CC_Admin__c = true;
                    casosActualizar.add(casoConMismaCampana);
                }
            }
        }

        if(!comunicacionesInformativasInsertar.isEmpty()){
            List<Database.SaveResult> resultadosInsertados = Database.insert(comunicacionesInformativasInsertar, false);

            for (Database.SaveResult agrupadoInsertado : resultadosInsertados) {
                if (agrupadoInsertado.isSuccess()) {
                    idsCampanasNuevosAgrupadores.add(agrupadoInsertado.getId());
                }
            }
        }

        if(!idsCampanasNuevosAgrupadores.isEmpty()){
            List<CC_Agrupador__c> lstAgreupadoresInsertados = [SELECT Id, CC_Campana__c FROM CC_Agrupador__c WHERE Id IN :idsCampanasNuevosAgrupadores WITH SECURITY_ENFORCED];

            if(!lstAgreupadoresInsertados.isEmpty()){

                for (CC_Agrupador__c agrupadorInsertado : lstAgreupadoresInsertados) {
                    if(mapCampanaCasos.containsKey(agrupadorInsertado.CC_Campana__c)){
                        for (Case casoAgrupado : mapCampanaCasos.get(agrupadorInsertado.CC_Campana__c)) {
                        	if (casoAgrupado.CC_Comunicacion_Informativa_Campana__c != agrupadorInsertado.Id) {
                            	casoAgrupado.CC_Comunicacion_Informativa_Campana__c = agrupadorInsertado.Id;
                            	casoAgrupado.CC_Admin__c = true;
                            	casosActualizar.add(casoAgrupado);
                        	}
                    	}
                    }

                }
            }
        }
        
        if(!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa_Campana__c.isUpdateable() &&  Schema.sObjectType.Case.fields.CC_Admin__c.isUpdateable()){
            update casosActualizar;
        }

        for (Case casoActualizar : casosActualizar) {
            casoActualizar.CC_Admin__c = false;
        }

        update casosActualizar;
    }
}