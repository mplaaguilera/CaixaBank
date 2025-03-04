public with sharing class CC_Agrupador_CI_Asignacion_Casos {

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
			asociarCasosAComunicacionInformativaQueueable asociarCasos = new asociarCasosAComunicacionInformativaQueueable();
            List<Id> idsCasosList = idsCasos;
		    asociarCasos.setParams(idsCasosList);
		    System.enqueueJob(asociarCasos, options);
		} catch (DuplicateMessageException ex) {
			//Exception is thrown if there is already an enqueued job with the same signature
            CBK_log.debug('CC_Agrupador_CI_Asignacion_Casos.asociarCasosAComunicacionInformativa: ' + ex);
        }
    }

    public class asociarCasosAComunicacionInformativaQueueable implements Queueable {

        
       private List<Id> idsCasos;
		
		public void setParams(List<Id> idsCasos) {
			this.idsCasos = idsCasos;
		}

		public void execute(QueueableContext context) {
           	asociarCasosAComunicacionInformativaNoFuture(idsCasos);
    	}
	}

    private static Boolean evaluarPrevisionesCasosFuture(Set<Id> idCausas, Boolean finDeSemana, Integer horaInicioFranja) {
        Boolean crearAgrupador = false;
        for (Id idCausa : idCausas) {
            PrevisionCasos previsionCasos = new PrevisionCasos(idCausa, finDeSemana);
            crearAgrupador = previsionCasos.evaluarPrevisionFranja(horaInicioFranja, finDeSemana);
        }
        return crearAgrupador;
    }

    private class PrevisionCasos {
        Id idCausa;
        Boolean finDeSemana;
        Map<Integer, Decimal> previsionFranjas;

        PrevisionCasos(Id idCausa, Boolean finDeSemana) {
            String query = '';
            for (Integer i = 0; i < 24; i++) {
                query += ' CC_' + String.valueOf(i).leftPad(2, '0') + '__c,';
            }
            query = 'SELECT' + query.removeEnd(',') + ' FROM CC_Prevision__c WHERE CC_Activo__c = TRUE AND CC_MCC__c = :idCausa AND CC_Tipo_Dia__c = :tipoDia LIMIT 1';
            Map<String, Object> queryBinds = new Map<String, Object>{'idCausa' => idCausa, 'tipoDia' => finDeSemana ? 'Sábado y domingo' : 'Lunes a viernes'};

            CC_Prevision__c prevision = Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE) ?? null;
            if (prevision != null) {
                this.idCausa = idCausa;
                this.finDeSemana = finDeSemana;
                this.previsionFranjas = new Map<Integer, Decimal>();
                for (Integer i = 0; i < 24; i++) {
                    previsionFranjas.put(i, (Decimal)prevision.get('CC_' + String.valueOf(i).leftPad(2, '0') + '__c'));
                }
            }
        }

        public Boolean evaluarPrevisionFranja(Integer horaIniciofranja, Boolean finDeSemana) {
            Boolean crearAgrupador = false;
            if (previsionFranjas != null) {
                Decimal previsionCasos = this.previsionFranjas.get(horaInicioFranja) ?? 0;
                // List<Id> idsCasos = new List<Id>();
                    Date hoy = System.today();
                    List<Case> casos = [SELECT CC_MCC_Causa__r.CC_Desviacion_Media_LV__c, CC_MCC_Causa__r.CC_Desviacion_Media_SD__c FROM Case WHERE Status = 'Cerrado' AND RecordType.DeveloperName = 'CC_Cliente'
                                        AND CC_MCC_Causa__c = :this.idCausa AND CreatedDate = TODAY AND CC_Tipo_Contacto__c != 'Incidencia' AND CC_Agrupador_Id__c = null
                                        AND ClosedDate <= :Datetime.newInstance(hoy.year(), hoy.month(), hoy.day(), horaInicioFranja, 0, 0).addHours(1)];
                system.debug('previsionCasos: ' + previsionCasos);
                if (previsionCasos == 0) {
                    system.debug('casos NUM: ' + casos.size());
                    if(casos.size() > previsionCasos) {
                        crearAgrupador = true;
                    }
                } else {
                    system.debug('casos NUM else: ' + casos.size());
                    if (casos.size() > previsionCasos) {
                        if(finDeSemana) {
                            Decimal porcentajeCasosSobrante = (previsionCasos * casos[0].CC_MCC_Causa__r.CC_Desviacion_Media_SD__c) / 100;
                            if(casos.size() > previsionCasos + porcentajeCasosSobrante) {
                                crearAgrupador = true;
                            }
                        } else {
                            Decimal porcentajeCasosSobrante = (previsionCasos * casos[0].CC_MCC_Causa__r.CC_Desviacion_Media_LV__c) / 100;
                            if(casos.size() > previsionCasos + porcentajeCasosSobrante) {
                                crearAgrupador = true;
                            }
                        }
                    }
            	}
            }
            return crearAgrupador;
        }
    }

    public static Map<Id, List<Case>> casosExistentesEmpleadosSinAgrupar(List<Id> casesActuales, Map<Id, List<Case>> mapCausaCasosEmpleados){
        Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        List<Case> casosExistentes = [
            SELECT Id, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_MCC_Causa__c,
            CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, CC_MCC_Causa__r.Name,
            CC_Comunicacion_Informativa__c, CC_Admin__c,  CC_Campana__c, CC_Campana__r.Name, RecordTypeId
            FROM Case WHERE CC_MCC_Tematica__r.CC_Activo__c = TRUE
            AND CC_MCC_ProdServ__R.CC_Activo__c = TRUE
            AND CC_MCC_Motivo__R.CC_Activo__c = TRUE
            AND CC_MCC_Causa__R.CC_Activo__c = TRUE 
            AND Id NOT IN :casesActuales
            AND CC_Comunicacion_Informativa__c = NULL 
            AND CreatedDate = TODAY
            AND Status = 'Cerrado'
            AND CC_Tipo_Contacto__c != 'Incidencia'
            AND RecordTypeId =: rtEmpleado
            AND CC_MCC_Causa__c IN: mapCausaCasosEmpleados.keySet()
            WITH SECURITY_ENFORCED
            FOR UPDATE
        ];

        for(Case caseExist : casosExistentes){
            mapCausaCasosEmpleados.get(caseExist.CC_MCC_Causa__c).add(caseExist);
        }

        return mapCausaCasosEmpleados;
      
    }

    public static CC_Agrupador__c crearAgrupador(Case casoConMismaCausa){
        String recordTypeDeveloperName = 'CC_Comunicacion_Informativa';
        CC_Agrupador__c comunicacionInformativaNueva = new CC_Agrupador__c();
        Id comunicacionInformativaCampanaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        comunicacionInformativaNueva.RecordTypeId = comunicacionInformativaCampanaRecordTypeId;
        comunicacionInformativaNueva.CC_Estado__c = 'Activo';
        comunicacionInformativaNueva.CC_Titulo__c = casoConMismaCausa.CC_MCC_Tematica__r.Name + ' > ' + casoConMismaCausa.CC_MCC_ProdServ__r.Name + ' > ' + casoConMismaCausa.CC_MCC_Motivo__r.Name + ' > ' + casoConMismaCausa.CC_MCC_Causa__r.Name;
        comunicacionInformativaNueva.CC_Tematica_Id__c = casoConMismaCausa.CC_MCC_Tematica__c;
        comunicacionInformativaNueva.CC_Producto_Servicio__c = casoConMismaCausa.CC_MCC_ProdServ__c;
        comunicacionInformativaNueva.CC_Motivo__c = casoConMismaCausa.CC_MCC_Motivo__c;
        comunicacionInformativaNueva.CC_Causa__c = casoConMismaCausa.CC_MCC_Causa__c;
        system.debug('ANTES CLIENTE CI LISTA INSERTAR 1 : ' + comunicacionInformativaNueva);
       // system.debug('ANTES CLIENTE CI LISTA INSERTAR 2 : ' + comunicacionesInformativasInsertar.contains(comunicacionInformativaNueva));
      /*  if(!comunicacionesInformativasInsertar.contains(comunicacionInformativaNueva)){
            comunicacionesInformativasInsertar.add(comunicacionInformativaNueva);
        }*/
        return comunicacionInformativaNueva;
    }

    public static void asociarCasosAComunicacionInformativaNoFuture(List<Id> idsCasos) {
        Boolean crearAgrupador = false;
       // Set<Id> idsCasosSet = new Set<Id>(idsCasos);
      //  Set<Id> idCausas = new Set<Id>();
     //  Set<Id> idsNuevosAgrupadores = new Set<Id>();
        List<Case> casosActualizar = new List<Case>();
      //  List<Case> casosNoActualizar = new List<Case>();
       // List<Case> lstCasosOrigen = new List<Case>();
        List<Case> lstCasosConMismaCausa = new List<Case>();
        Map<Id,CC_Agrupador__c> comunicacionesInformativasInsertar = new Map<Id,CC_Agrupador__c>();
        List<CC_Agrupador__c> comunicacionesInformativasExistentes = new List<CC_Agrupador__c>();
        Map<String, String> mapAgrupadorCausa = new Map<String, String>();
        Map<Id, List<Case>> mapCausaCasos = new Map<Id, List<Case>>();
        Map<Id, List<Case>> mapCausaCasosEmpleados = new Map<Id, List<Case>>();
       // String recordTypeDeveloperName = 'CC_Comunicacion_Informativa';

        String umbralPrimerAvisoString = [SELECT CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name = :CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa') + ' - Umbral primer aviso'].CC_Valor__c;
        Integer umbralPrimerAviso = Integer.valueOf(umbralPrimerAvisoString);
		Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');

        system.debug('INICIO PROCES COMUNICACIONES INFORMATIVAS');


        lstCasosConMismaCausa = [SELECT Id, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, CC_MCC_Causa__c,
                                     CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name, CC_MCC_Causa__r.Name,
                                     CC_Comunicacion_Informativa__c, CC_Admin__c,  CC_Campana__c, CC_Campana__r.Name, RecordTypeId
                                     FROM Case WHERE CC_MCC_Tematica__r.CC_Activo__c = TRUE
                                     AND CC_MCC_ProdServ__R.CC_Activo__c = TRUE
                                     AND CC_MCC_Motivo__R.CC_Activo__c = TRUE
                                     AND CC_MCC_Causa__R.CC_Activo__c = TRUE 
                                     AND Id IN :idsCasos
                                     WITH SECURITY_ENFORCED 
                                     FOR UPDATE];

        if(lstCasosConMismaCausa.isEmpty()){
            return;
        }

        for (Case casoConMismaCausa : lstCasosConMismaCausa) {
            if(casoConMismaCausa.RecordTypeId == rtCliente){             
                if(!mapCausaCasos.containsKey(casoConMismaCausa.CC_MCC_Causa__c)) {
                    mapCausaCasos.put(casoConMismaCausa.CC_MCC_Causa__c, new List<Case>());                 
                }              
                mapCausaCasos.get(casoConMismaCausa.CC_MCC_Causa__c).add(casoConMismaCausa);
            } else{
                if(!mapCausaCasosEmpleados.containsKey(casoConMismaCausa.CC_MCC_Causa__c)) {
                    mapCausaCasosEmpleados.put(casoConMismaCausa.CC_MCC_Causa__c, new List<Case>());                 
                }              
                mapCausaCasosEmpleados.get(casoConMismaCausa.CC_MCC_Causa__c).add(casoConMismaCausa);            
            }            
        }  

        mapCausaCasosEmpleados = casosExistentesEmpleadosSinAgrupar(idsCasos, mapCausaCasosEmpleados);

        String hoyDiaSemana = System.now().format('E');
        //esto aplica para clientes. 
        crearAgrupador = evaluarPrevisionesCasosFuture(mapCausaCasos.keySet(), hoyDiaSemana == 'Sat' || hoyDiaSemana == 'Sun', System.now().hour());

        comunicacionesInformativasExistentes = [SELECT Id, CC_Campana__c, CC_Causa__c  FROM CC_Agrupador__c WHERE RecordType.DeveloperName = 'CC_Comunicacion_Informativa' AND CC_Estado__c = 'Activo' AND (CC_Causa__c IN :mapCausaCasos.keySet() OR CC_Causa__c IN :mapCausaCasosEmpleados.keySet())  AND CreatedDate = TODAY WITH SECURITY_ENFORCED];

        if (!comunicacionesInformativasExistentes.isEmpty()) {
                   
            for (CC_Agrupador__c comunicacionExistente : comunicacionesInformativasExistentes) {
                mapAgrupadorCausa.put(comunicacionExistente.CC_Causa__c , comunicacionExistente.Id);
            }
        }
        
        for (Case casoConMismaCausa : lstCasosConMismaCausa) {       

            if(mapAgrupadorCausa.containsKey(casoConMismaCausa.CC_MCC_Causa__c) && casoConMismaCausa.CC_Comunicacion_Informativa__c == null)
            {
                casoConMismaCausa.CC_Comunicacion_Informativa__c = mapAgrupadorCausa.get(casoConMismaCausa.CC_MCC_Causa__c);
                casoConMismaCausa.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCausa);
            }
            else if (mapAgrupadorCausa.containsKey(casoConMismaCausa.CC_MCC_Causa__c) && casoConMismaCausa.CC_Comunicacion_Informativa__c != mapAgrupadorCausa.get(casoConMismaCausa.CC_MCC_Causa__c)) {
                casoConMismaCausa.CC_Comunicacion_Informativa__c = mapAgrupadorCausa.get(casoConMismaCausa.CC_MCC_Causa__c);
                casoConMismaCausa.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCausa);
            }
           /* else if(mapAgrupadorCausa.containsKey(casoConMismaCausa.CC_MCC_Causa__c) && casoConMismaCausa.CC_Comunicacion_Informativa__c == mapAgrupadorCausa.get(casoConMismaCausa.CC_MCC_Causa__c))
            {
                  casosNoActualizar.add(casoConMismaCausa);
            }*/ //Aqui hay que crear el agrupador. 
            else if(!mapAgrupadorCausa.containsKey(casoConMismaCausa.CC_MCC_Causa__c) ){
                system.debug('RecordTypeId: ' + casoConMismaCausa.RecordTypeId);
                if(casoConMismaCausa.RecordTypeId == rtCliente && crearAgrupador) {
                 
                    system.debug('Causa Caso Map: ' + casoConMismaCausa.CC_MCC_Causa__c);
                    system.debug('Causa Caso contains: ' + comunicacionesInformativasInsertar.containsKey(casoConMismaCausa.CC_MCC_Causa__c));
                    if(!comunicacionesInformativasInsertar.containsKey(casoConMismaCausa.CC_MCC_Causa__c)){
                        CC_Agrupador__c comunicacionInformativaNueva = crearAgrupador(casoConMismaCausa);
                        comunicacionesInformativasInsertar.put(casoConMismaCausa.CC_MCC_Causa__c, comunicacionInformativaNueva);

                        system.debug('Causa Caso Map: ' + casoConMismaCausa.CC_MCC_Causa__c + ' ' + comunicacionInformativaNueva);
                    }                

                } else if(casoConMismaCausa.RecordTypeId == rtEmpleado){
                    //aqui es dnd esta lo del problema dle umbral
                    if (mapCausaCasosEmpleados.get(casoConMismaCausa.CC_MCC_Causa__c).size() >= umbralPrimerAviso) {

                        if(!comunicacionesInformativasInsertar.containsKey(casoConMismaCausa.CC_MCC_Causa__c)){
                            CC_Agrupador__c comunicacionInformativaNueva = crearAgrupador(casoConMismaCausa);
                            comunicacionesInformativasInsertar.put(casoConMismaCausa.CC_MCC_Causa__c, comunicacionInformativaNueva);
                        }       
                    } /*else {
                        casoConMismaCausa.CC_Comunicacion_Informativa__c = null;
                        casoConMismaCausa.CC_Admin__c = true;
                        casosActualizar.add(casoConMismaCausa);
                    }*/
                }
            }
        }

        if(!comunicacionesInformativasInsertar.isEmpty()){

            
            //List<Database.SaveResult> resultadosInsertados=Database.insert(comunicacionesInformativasInsertar.values(), false);
            Database.DMLOptions dmlOptions= new Database.DMLOptions();
            dmlOptions.duplicateRuleHeader.allowSave = false;
            Database.insert(comunicacionesInformativasInsertar.values(), dmlOptions);

            List<String> causaIdProcesada = new List<String>();

            for (CC_Agrupador__c agrupadorInsertado : comunicacionesInformativasInsertar.values()) {
                if(agrupadorInsertado.Id != null){
                    List<Case> casosAProcesar = new List<Case>();
                    if(mapCausaCasos.containsKey(agrupadorInsertado.CC_Causa__c) && !causaIdProcesada.contains(agrupadorInsertado.CC_Causa__c)){
                        casosAProcesar.addAll(mapCausaCasos.get(agrupadorInsertado.CC_Causa__c));
                        causaIdProcesada.add(agrupadorInsertado.CC_Causa__c);
                    }
                    if(mapCausaCasosEmpleados.containsKey(agrupadorInsertado.CC_Causa__c) && !causaIdProcesada.contains(agrupadorInsertado.CC_Causa__c)){
                        casosAProcesar.addAll(mapCausaCasosEmpleados.get(agrupadorInsertado.CC_Causa__c));
                        causaIdProcesada.add(agrupadorInsertado.CC_Causa__c);
                    }
                    for (Case casoAgrupado : casosAProcesar) {
                        casoAgrupado.CC_Comunicacion_Informativa__c = agrupadorInsertado.Id;
                        casoAgrupado.CC_Admin__c = true;
                        casosActualizar.add(casoAgrupado);
                    }
                }
            }
           /* List<Database.SaveResult> resultadosInsertados = Database.insert(comunicacionesInformativasInsertar, false);

            for (Database.SaveResult agrupadoInsertado : resultadosInsertados) {
                if (agrupadoInsertado.isSuccess()) {
                    idsNuevosAgrupadores.add(agrupadoInsertado.getId());
                }
            }

            if(!idsNuevosAgrupadores.isEmpty()){
                List<CC_Agrupador__c> lstAgrupadoresInsertados = [SELECT Id, CC_Causa__c FROM CC_Agrupador__c WHERE Id IN :idsNuevosAgrupadores WITH SECURITY_ENFORCED];
                Map<String, String> mapAgrupadores = new Map<String, String>();
    
                if(!lstAgrupadoresInsertados.isEmpty()){
    
                    for (CC_Agrupador__c agrupadorInsertado : lstAgrupadoresInsertados) {
                        mapAgrupadores.put(agrupadorInsertado.CC_Causa__c, agrupadorInsertado.Id);
                    }
    
                    for (CC_Agrupador__c agrupadorInsertado : lstAgrupadoresInsertados) {
                        if(mapCausaCasos.containsKey(agrupadorInsertado.CC_Causa__c)){
                            for (Case casoAgrupado : mapCausaCasos.get(agrupadorInsertado.CC_Causa__c)) {
                                    casoAgrupado.CC_Comunicacion_Informativa__c = agrupadorInsertado.Id;
                                    casoAgrupado.CC_Admin__c = true;
                                    casosActualizar.add(casoAgrupado);
                            }
                        }
                    }
                }
            }*/
        }

        system.debug('FIN PROCES COMUNICACIONES INFORMATIVAS');
 
        if(!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa__c.isUpdateable() &&  Schema.sObjectType.Case.fields.CC_Admin__c.isUpdateable()){   
            update casosActualizar;
        }
        
        List<Case> casosActualizarAux = new List<Case>();
        for (Case casoActualizar : casosActualizar) {
            casoActualizar.CC_Admin__c = false;
            casosActualizarAux.add(casoActualizar);
        }
        update casosActualizarAux;
        
    }
}