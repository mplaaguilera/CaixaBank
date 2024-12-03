public class CC_Casos_Semanales_Por_Causa_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    public CC_Casos_Semanales_Por_Causa_Batch() {
        CBK_Log.debug('Iniciación - Batch CC_Casos_Semanales_Por_Causa_Batch',logginglevel.INFO);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM CC_MCC__c WHERE CC_Activo__c = true AND RecordType.DeveloperName = \'CC_Causa\' AND CC_Tipo_Cliente__c IN (\'Cliente\', \'Cliente/Empleado\') AND CC_Desviacion_Media_LV__c != null AND CC_Desviacion_Media_SD__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> causas) {
        try {
            Id recordTypeCasoCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id recordTypePrevisionCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Prevision__c', 'CC_PrevisionCaso');
            Set<Id> setCausas = new Set<Id>();
            List<CC_Prevision__c> previsionesAnteriores = [SELECT Id, CC_Activo__c FROM CC_Prevision__c WHERE CC_Activo__c = TRUE AND CreatedDate < :DateTime.now().addDays(-1)];

            for(CC_Prevision__c prevision : previsionesAnteriores) {
                prevision.CC_Activo__c = false;
            }

            for(SObject causa : causas) {
                setCausas.add(causa.Id);
            }
            
            // Obtener casos semanales
            List<Case> casosSemanales = new List<Case>();
            if (Test.isRunningTest()){
	            casosSemanales = [SELECT Id, CreatedDate, CC_MCC_Causa__c FROM Case WHERE CreatedDate = THIS_WEEK AND Status = 'Cerrado' AND RecordTypeId = :recordTypeCasoCliente AND CC_MCC_Causa__c IN :setCausas ORDER BY CreatedDate];     
            } else {
                casosSemanales = [SELECT Id, CreatedDate, CC_MCC_Causa__c FROM Case WHERE CreatedDate = LAST_WEEK AND Status = 'Cerrado' AND RecordTypeId = :recordTypeCasoCliente AND CC_MCC_Causa__c IN :setCausas ORDER BY CreatedDate]; 
            }
            
            // Inicializar mapa para contar por hora, causa y tipo de día
            Map<String, Map<String, Map<String, Double>>> contadorPorHoraPorCausaPorTipoDia = new Map<String, Map<String, Map<String, Double>>>();
            
            // Inicializar mapa de horas
            List<String> horas = new List<String>();
            for (Integer i = 0; i < 24; i++) {
                String hora = i < 10 ? '0' + i : String.valueOf(i);
                horas.add(hora);
            }
            
            // Procesar casos semanales
            for (Case casoSemanal : casosSemanales) {
                String diaDeLaSemana = casoSemanal.CreatedDate.format('E');
                String tipoDia = (diaDeLaSemana == 'Sat' || diaDeLaSemana == 'Sun') ? 'S-D' : 'L-V';
                String franjaHoraria = String.valueOf(casoSemanal.CreatedDate.hour());
                if (franjaHoraria.length() < 2) {
                    franjaHoraria = '0' + franjaHoraria;
                }                
                if (!contadorPorHoraPorCausaPorTipoDia.containsKey(casoSemanal.CC_MCC_Causa__c)) {
                    contadorPorHoraPorCausaPorTipoDia.put(casoSemanal.CC_MCC_Causa__c, new Map<String, Map<String, Double>>());
                }                
                if (!contadorPorHoraPorCausaPorTipoDia.get(casoSemanal.CC_MCC_Causa__c).containsKey(tipoDia)) {
                    contadorPorHoraPorCausaPorTipoDia.get(casoSemanal.CC_MCC_Causa__c).put(tipoDia, new Map<String, Double>());
                    for (String hora : horas) {
                        contadorPorHoraPorCausaPorTipoDia.get(casoSemanal.CC_MCC_Causa__c).get(tipoDia).put(hora, 0);
                    }
                }
                contadorPorHoraPorCausaPorTipoDia.get(casoSemanal.CC_MCC_Causa__c).get(tipoDia).put(franjaHoraria, contadorPorHoraPorCausaPorTipoDia.get(casoSemanal.CC_MCC_Causa__c).get(tipoDia).get(franjaHoraria) + 1);
            }
            
            // Crear previsiones acumulativas por hora, causa y tipo de día
            List<CC_Prevision__c> nuevasPrevisiones = new List<CC_Prevision__c>();
            List<CC_TrazaInt__c> lstTrazasMapas = new List<CC_TrazaInt__c>();
            
            for (String causa : contadorPorHoraPorCausaPorTipoDia.keySet()) {
                for (String tipoDia : contadorPorHoraPorCausaPorTipoDia.get(causa).keySet()) {
                    Map<String, Double> contadorPorHora = contadorPorHoraPorCausaPorTipoDia.get(causa).get(tipoDia);
                    String mensajeTraza = '';
                    Double acumulado = 0;
                    Integer division = (tipoDia == 'L-V') ? 5 : 2;
                    CC_Prevision__c prevision = new CC_Prevision__c();
                    prevision.RecordTypeId = recordTypePrevisionCaso;
                    prevision.CC_MCC__c = causa;
                    prevision.CC_Tipo_Dia__c = (tipoDia == 'L-V') ? 'Lunes a viernes' : 'Sábado y domingo';
                    
                    acumulado += contadorPorHora.get('00');
                    contadorPorHora.put('00', acumulado / division);
                    
                    acumulado += contadorPorHora.get('01');
                    contadorPorHora.put('01', acumulado / division);
                    
                    acumulado += contadorPorHora.get('02');
                    contadorPorHora.put('02', acumulado / division);
                    
                    acumulado += contadorPorHora.get('03');
                    contadorPorHora.put('03', acumulado / division);
                    
                    acumulado += contadorPorHora.get('04');
                    contadorPorHora.put('04', acumulado / division);
                    
                    acumulado += contadorPorHora.get('05');
                    contadorPorHora.put('05', acumulado / division);
                    
                    acumulado += contadorPorHora.get('06');
                    contadorPorHora.put('06', acumulado / division);
                    
                    acumulado += contadorPorHora.get('07');
                    contadorPorHora.put('07', acumulado / division);
                    
                    acumulado += contadorPorHora.get('08');
                    contadorPorHora.put('08', acumulado / division);
                    
                    acumulado += contadorPorHora.get('09');
                    contadorPorHora.put('09', acumulado / division);
                    
                    acumulado += contadorPorHora.get('10');
                    contadorPorHora.put('10', acumulado / division);
                    
                    acumulado += contadorPorHora.get('11');
                    contadorPorHora.put('11', acumulado / division);
                    
                    acumulado += contadorPorHora.get('12');
                    contadorPorHora.put('12', acumulado / division);
                    
                    acumulado += contadorPorHora.get('13');
                    contadorPorHora.put('13', acumulado / division);
                    
                    acumulado += contadorPorHora.get('14');
                    contadorPorHora.put('14', acumulado / division);
                    
                    acumulado += contadorPorHora.get('15');
                    contadorPorHora.put('15', acumulado / division);
                    
                    acumulado += contadorPorHora.get('16');
                    contadorPorHora.put('16', acumulado / division);
                    
                    acumulado += contadorPorHora.get('17');
                    contadorPorHora.put('17', acumulado / division);
                    
                    acumulado += contadorPorHora.get('18');
                    contadorPorHora.put('18', acumulado / division);
                    
                    acumulado += contadorPorHora.get('19');
                    contadorPorHora.put('19', acumulado / division);
                    
                    acumulado += contadorPorHora.get('20');
                    contadorPorHora.put('20', acumulado / division);
                    
                    acumulado += contadorPorHora.get('21');
                    contadorPorHora.put('21', acumulado / division);
                    
                    acumulado += contadorPorHora.get('22');
                    contadorPorHora.put('22', acumulado / division);
                    
                    acumulado += contadorPorHora.get('23');
                    contadorPorHora.put('23', acumulado / division);
                    
                    prevision.CC_00__c = contadorPorHora.get('00');
                    prevision.CC_01__c = contadorPorHora.get('01');
                    prevision.CC_02__c = contadorPorHora.get('02');
                    prevision.CC_03__c = contadorPorHora.get('03');
                    prevision.CC_04__c = contadorPorHora.get('04');
                    prevision.CC_05__c = contadorPorHora.get('05');
                    prevision.CC_06__c = contadorPorHora.get('06');
                    prevision.CC_07__c = contadorPorHora.get('07');
                    prevision.CC_08__c = contadorPorHora.get('08');
                    prevision.CC_09__c = contadorPorHora.get('09');
                    prevision.CC_10__c = contadorPorHora.get('10');
                    prevision.CC_11__c = contadorPorHora.get('11');
                    prevision.CC_12__c = contadorPorHora.get('12');
                    prevision.CC_13__c = contadorPorHora.get('13');
                    prevision.CC_14__c = contadorPorHora.get('14');
                    prevision.CC_15__c = contadorPorHora.get('15');
                    prevision.CC_16__c = contadorPorHora.get('16');
                    prevision.CC_17__c = contadorPorHora.get('17');
                    prevision.CC_18__c = contadorPorHora.get('18');
                    prevision.CC_19__c = contadorPorHora.get('19');
                    prevision.CC_20__c = contadorPorHora.get('20');
                    prevision.CC_21__c = contadorPorHora.get('21');
                    prevision.CC_22__c = contadorPorHora.get('22');
                    prevision.CC_23__c = contadorPorHora.get('23');

                    mensajeTraza += '00 = ' + contadorPorHora.get('00') + ' ; ';
                    mensajeTraza += '01 = ' + contadorPorHora.get('01') + ' ; ';
                    mensajeTraza += '02 = ' + contadorPorHora.get('02') + ' ; ';
                    mensajeTraza += '03 = ' + contadorPorHora.get('03') + ' ; ';
                    mensajeTraza += '04 = ' + contadorPorHora.get('04') + ' ; ';
                    mensajeTraza += '05 = ' + contadorPorHora.get('05') + ' ; ';
                    mensajeTraza += '06 = ' + contadorPorHora.get('06') + ' ; ';
                    mensajeTraza += '07 = ' + contadorPorHora.get('07') + ' ; ';
                    mensajeTraza += '08 = ' + contadorPorHora.get('08') + ' ; ';
                    mensajeTraza += '09 = ' + contadorPorHora.get('09') + ' ; ';
                    mensajeTraza += '10 = ' + contadorPorHora.get('10') + ' ; ';
                    mensajeTraza += '11 = ' + contadorPorHora.get('11') + ' ; ';
                    mensajeTraza += '12 = ' + contadorPorHora.get('12') + ' ; ';
                    mensajeTraza += '13 = ' + contadorPorHora.get('13') + ' ; ';
                    mensajeTraza += '14 = ' + contadorPorHora.get('14') + ' ; ';
                    mensajeTraza += '15 = ' + contadorPorHora.get('15') + ' ; ';
                    mensajeTraza += '16 = ' + contadorPorHora.get('16') + ' ; ';
                    mensajeTraza += '17 = ' + contadorPorHora.get('17') + ' ; ';
                    mensajeTraza += '18 = ' + contadorPorHora.get('18') + ' ; ';
                    mensajeTraza += '19 = ' + contadorPorHora.get('19') + ' ; ';
                    mensajeTraza += '20 = ' + contadorPorHora.get('20') + ' ; ';
                    mensajeTraza += '21 = ' + contadorPorHora.get('21') + ' ; ';
                    mensajeTraza += '22 = ' + contadorPorHora.get('22') + ' ; ';
                    mensajeTraza += '23 = ' + contadorPorHora.get('23') + ' ; ';
                    nuevasPrevisiones.add(prevision);
                    
                    CC_TrazaInt__c trazaMapa = new CC_TrazaInt__c();
                    trazaMapa.Name = 'CC_Casos_Semanales_Por_Causa_Batch';
                    trazaMapa.CC_MensajeSalida__c = mensajeTraza;
                    trazaMapa.CC_FechaInicio__c = datetime.now();
                    lstTrazasMapas.add(trazaMapa);
                }
            }
            if(!lstTrazasMapas.isEmpty()) {
                insert lstTrazasMapas;
            }
            if(!nuevasPrevisiones.isEmpty()) {
                insert nuevasPrevisiones;
            }
            if(!previsionesAnteriores.isEmpty()) {
                update previsionesAnteriores;
            }
        } catch (DmlException e) {
            CBK_Log.error(e);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - Batch CC_Casos_Semanales_Por_Causa_Batch',logginglevel.INFO);
    }
}