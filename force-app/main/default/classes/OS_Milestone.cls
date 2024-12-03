global with sharing class OS_Milestone implements Support.MilestoneTriggerTimeCalculator {
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        //Marc Pla, julio 2020: Devuelve la duración máxima (en minutos) de la gestión del caso para cumplir el SLA para la UAI
        //Nerea Sanchez Junio 2021: Devuelve la duración máxima (en minutos) de la gestión del caso para cumplir el SLA para la UAFE
        Integer minutosRestantes = 0;
        
        List<BusinessHours> businessHoursList =  new List<BusinessHours>();
        List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA =  new List<CC_Lista_Valores__c> ();

        Case caso = new case();

        if(OS_Case_AU_TRHan.casesMap.containsKey(caseId) && !Test.isRunningTest()){
            //caso = mapCase.get(caseId);
            caso = OS_Case_AU_TRHan.casesMap.get(caseId);
        } else {
            caso = [SELECT Id, Entitlement.Name, CreatedDate, Origin, CC_Canal_Procedencia__c, CC_MCC_Tematica__c, 
            CC_MCC_Tematica__r.OS_Horario__c, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.OS_Horario__c, CC_MCC_Causa__c, 
            CC_MCC_Causa__r.OS_Horas_SLA__c, OS_Cola_Telefonia__c FROM Case WHERE Id = :caseId LIMIT 1];
        }

        if (Cache.Org.contains('local.COPS.OSCalendario')) {
             businessHoursList = (List<BusinessHours>)Cache.Org.get('local.COPS.OSCalendario');
            
        }
        else{
            businessHoursList = [SELECT Id, name, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime FROM BusinessHours];
            Cache.Org.put('local.COPS.OSCalendario', businessHoursList,300);
        }

        if (Cache.Org.contains('local.COPS.OSListas')) {
             listaBuzonesEmailColasTlfSLA = (List<CC_Lista_Valores__c>)Cache.Org.get('local.COPS.OSListas');
            
        }
        else{
            listaBuzonesEmailColasTlfSLA = [SELECT Id,Name, CC_Valor__c, CC_Lista__r.Name FROM CC_Lista_Valores__c WHERE 
            (CC_Lista__r.Name = 'COPS: SLA Relación colas telefonía y canal de procedencia email' OR CC_Lista__r.Name = 'COPS: Horas SLA para servicios UAFE')
            AND CC_Activa__c = true];
            Cache.Org.put('local.COPS.OSListas', listaBuzonesEmailColasTlfSLA,300);
        }
        //Case caso = [SELECT Id, Entitlement.Name, CreatedDate, Origin, CC_Canal_Procedencia__c, CC_MCC_Tematica__c, CC_MCC_Tematica__r.OS_Horario__c, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.OS_Horario__c, CC_MCC_Causa__c, CC_MCC_Causa__r.OS_Horas_SLA__c, OS_Cola_Telefonia__c FROM Case WHERE Id = :caseId LIMIT 1];
        
        //List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, TargetDate, CaseId, TargetResponseInMins FROM CaseMilestone WHERE CaseId =:caseId];
        /*
        List<BusinessHours> businessHoursList = [SELECT Id, name, MondayEndTime, TuesdayEndTime, WednesdayEndTime, ThursdayEndTime, FridayEndTime, SaturdayEndTime, SundayEndTime FROM BusinessHours];
        List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA = [SELECT Name, CC_Valor__c, CC_Lista__r.Name FROM CC_Lista_Valores__c WHERE 
            (CC_Lista__r.Name = 'COPS: SLA Relación colas telefonía y canal de procedencia email' OR CC_Lista__r.Name = 'COPS: Horas SLA para servicios UAFE')
            AND CC_Activa__c = true];
*/
        Map<String, Object> camposCalculoMilestone = calculoParametrosMilestone(caso, businessHoursList, listaBuzonesEmailColasTlfSLA);
        Datetime fechaLimiteResolucion = (Datetime)camposCalculoMilestone.get('fechaLimiteResolucion');
        Datetime ahora = (Datetime)camposCalculoMilestone.get('ahora');
        Id idBusinessHours = (Id)camposCalculoMilestone.get('idBusinessHours');
        Integer horasRestantes = (Integer)camposCalculoMilestone.get('horasRestantes');
        
        if (!Test.isRunningTest()) {
            //if(milestonesEnCurso.isEmpty()) {   
                //Si horas restantes viene != null es que es UAFE y se calcula mediante el metadato 'COPS: Horas SLA para servicios UAFE' que nos devuelve el número de horas
                if(horasRestantes != null) {
                    //Cuando no se encuentra un valor en la lista de valores devolvemos horas == 0 
                     minutosRestantes = horasRestantes*60; 
                    }
                //Si horas restantes = null se calcula como hasta ahora
                else {
                    minutosRestantes = BusinessHours.diff(idBusinessHours, caso.CreatedDate, fechaLimiteResolucion).intValue() / 1000 / 60;
                }
            /*} else {
                minutosRestantes = milestonesEnCurso[0].TargetResponseInMins;
            } */
        } 
        else {
            if(horasRestantes != null) {
                minutosRestantes = horasRestantes*60;   
            } 
            else {
                if(ahora.hour() < 13) {
                    minutosRestantes = BusinessHours.diff(idBusinessHours, Datetime.newInstance(ahora.year(), ahora.month(), ahora.day(), 12, 0, 0), fechaLimiteResolucion).intValue() / 1000 / 60;
                }
                else {
                    minutosRestantes = BusinessHours.diff(idBusinessHours, Datetime.newInstance(ahora.year(), ahora.month(), ahora.day(), 14, 0, 0), fechaLimiteResolucion).intValue() / 1000 / 60;
                }
            }
        } 
        return minutosRestantes > 0 ? minutosRestantes : 1;
    }

    public static Map<String,Object> calculoParametrosMilestone(Case caso, List<BusinessHours> businessHoursList, List<CC_MCC__c> businessHoursMCC) {
        List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA = new List<CC_Lista_Valores__c>();
        Map<String, Object> camposCalculoMilestone = calculoParametrosMilestone(caso, businessHoursList, listaBuzonesEmailColasTlfSLA, businessHoursMCC);
        return camposCalculoMilestone;
    }  

    public static Map<String,Object> calculoParametrosMilestone(Case caso, List<BusinessHours> businessHoursList, List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA) {
        List<CC_MCC__c> businessHoursMCC = new List<CC_MCC__c>();
        Map<String, Object> camposCalculoMilestone = calculoParametrosMilestone(caso, businessHoursList, listaBuzonesEmailColasTlfSLA, businessHoursMCC);
        return camposCalculoMilestone;
    }

    public static Map<String,Object> calculoParametrosMilestone(Case caso, List<BusinessHours> businessHoursList, List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA, List<CC_MCC__c> businessHoursMCC) {

        Map<String, Object> camposCalculoMilestone = new Map<String, Object>();

        List<String> procedenciasBosEmail = listadoCanalesProcedencias('procedenciasBosEmail');
        List<String> procedenciasGocEmail = listadoCanalesProcedencias('procedenciasGocEmail');
        List<String> procedenciasUaiEmail = listadoCanalesProcedencias('procedenciasUaiEmail');
        List<String> procedenciasHolabank = listadoCanalesProcedencias('procedenciasHolabank');
        List<String> procedenciasEfectivo = listadoCanalesProcedencias('procedenciasEfectivo');
        List<String> procedenciasUafe = listadoCanalesProcedencias('procedenciasUafe'); 
        List<String> procedenciasTotales = listadoCanalesProcedencias('procedenciasTotales');
        
        //Calculo el canal de procedencia del caso teniendo en cuenta la nueva lógica de UAFE
        Map<String,Object> camposCalculoCanalProcedencia = calculoCanalProcedenciaEmail(procedenciasTotales, caso, listaBuzonesEmailColasTlfSLA);
        Map<String, String> nombreValorLista = (Map<String, String>)camposCalculoCanalProcedencia.get('nombreValorLista');
        String canalProcedenciaCaso = (String)camposCalculoCanalProcedencia.get('canalProcedenciaCaso');

        //Cálculo Business Hours
        Map<Id,BusinessHours> mapBusinessHour = new Map<Id,BusinessHours>();
        Map<String,Id> mapBusinessHourNameId = new Map<String,Id>();
        Map<String,Time> mapDiasBusinessHours = new Map<String,Time>();
        for (BusinessHours bh : businessHoursList) {
            mapBusinessHour.put(bh.Id, bh);
            mapBusinessHourNameId.put(bh.name, bh.Id);
            mapDiasBusinessHours.put(bh.Id+':Monday', bh.MondayEndTime);
            mapDiasBusinessHours.put(bh.Id+':Tuesday', bh.TuesdayEndTime);
            mapDiasBusinessHours.put(bh.Id+':Wednesday', bh.WednesdayEndTime);
            mapDiasBusinessHours.put(bh.Id+':Thursday', bh.ThursdayEndTime);
            mapDiasBusinessHours.put(bh.Id+':Friday', bh.FridayEndTime);
            mapDiasBusinessHours.put(bh.Id+':Saturday', bh.SaturdayEndTime);
            mapDiasBusinessHours.put(bh.Id+':Sunday', bh.SundayEndTime);
        }
        
        Id idBusinessHours = mapBusinessHourNameId.get('cops');        
        Datetime fechaLimiteResolucion;
        Datetime ahora = System.now();
        String horas;
        Integer dias;

        Datetime fechaCreacionCaso;
        if(caso.CreatedDate == null) {
            fechaCreacionCaso = System.now();
        }
        else { 
            fechaCreacionCaso = caso.CreatedDate;
        }

        if (Test.isRunningTest()) {
            if(caso.CreatedDate == null) {
                ahora = System.now();
            }
            else {
                ahora = caso.CreatedDate;
            }
            fechaLimiteResolucion = ahora;
        }
        
        Boolean fueraHorarioServicio = false;
        
        if (procedenciasUaiEmail.contains(canalProcedenciaCaso)) {   
            idBusinessHours = mapBusinessHourNameId.get('cops');
            
            if (!BusinessHours.isWithin(idBusinessHours, ahora)) {
                fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, ahora);

                //Si BusinessHours.nextStartDate coincide con el día de ahora, se programa para las 18h. 
                if(fechaLimiteResolucion.date() == ahora.date()) {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 18, 0, 0);
                }
                //Si entra algún día antes de BusinessHours.nextStartDate, se programa para las 13h.
                else {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                }
            } else if (fechaCreacionCaso.hour() < 13) {
                //El caso se ha creado antes de las 13:00 de un día laborable, el SLA vence hoy a las 18:00
                fechaLimiteResolucion = Datetime.newInstance(ahora.year(), ahora.month(), ahora.day(), 18, 0, 0);
                
            } else {
                //El caso se ha creado después de las 13:00 de un día laborable, el SLA vence mañana a las 13:00
                fechaLimiteResolucion = ahora.addDays(1);
                if (BusinessHours.isWithin(idBusinessHours, fechaLimiteResolucion)) {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                } else {
                    fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, fechaLimiteResolucion);
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                }
            }
        }
        else if (procedenciasGocEmail.contains(canalProcedenciaCaso)) {   
            idBusinessHours = mapBusinessHourNameId.get('Business Hours GOC');
            
            if (!BusinessHours.isWithin(idBusinessHours, ahora)) {
                fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, ahora);
                
                //Si BusinessHours.nextStartDate coincide con el día de ahora, se programa para las 18h. 
                if(fechaLimiteResolucion.date() == ahora.date()) {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 18, 0, 0);
                }
                //Si entra algún día antes de BusinessHours.nextStartDate, se programa para las 13h.
                else {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                }                
            } else if (fechaCreacionCaso.hour() < 13) {
                //El caso se ha creado antes de las 13:00 de un día laborable, el SLA vence hoy a las 18:00
                fechaLimiteResolucion = Datetime.newInstance(ahora.year(), ahora.month(), ahora.day(), 18, 0, 0);
                
            } else {
                //El caso se ha creado después de las 13:00 de un día laborable, el SLA vence mañana a las 13:00
                fechaLimiteResolucion = ahora.addDays(1);
                if (BusinessHours.isWithin(idBusinessHours, fechaLimiteResolucion)) {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                } else {
                    fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, fechaLimiteResolucion);
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                }
            }
        }
        else if (procedenciasBosEmail.contains(canalProcedenciaCaso)) {   
            idBusinessHours = mapBusinessHourNameId.get('Business Hours BOS');
            
            if (!BusinessHours.isWithin(idBusinessHours, ahora)) {
                fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, ahora);

                //Si BusinessHours.nextStartDate coincide con el día de ahora, se programa para las 18h. 
                if(fechaLimiteResolucion.date() == ahora.date()) {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 18, 0, 0);
                }
                //Si entra algún día antes de BusinessHours.nextStartDate, se programa para las 13h.
                else {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                }                
            } else if (fechaCreacionCaso.hour() < 13) {
                //El caso se ha creado antes de las 13:00 de un día laborable, el SLA vence hoy a las 18:00
                fechaLimiteResolucion = Datetime.newInstance(ahora.year(), ahora.month(), ahora.day(), 18, 0, 0);
                
            } else {
                //El caso se ha creado después de las 13:00 de un día laborable, el SLA vence mañana a las 13:00
                fechaLimiteResolucion = ahora.addDays(1);
                if (BusinessHours.isWithin(idBusinessHours, fechaLimiteResolucion)) {
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                } else {
                    fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, fechaLimiteResolucion);
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), 13, 0, 0);
                }
            }
        } 
        else if (procedenciasEfectivo.contains(canalProcedenciaCaso) || procedenciasHolabank.contains(canalProcedenciaCaso)) {             
            
            if (!Test.isRunningTest()) {
                ahora = System.now();
            }

            Time ahoraTime = ahora.time().addMinutes(30);

            Map<Id, CC_MCC__c> mapaBusinessHoursMCC = new Map<Id, CC_MCC__c>();
            if(!businessHoursMCC.isEmpty()) {
                mapaBusinessHoursMCC = obtenerMapaBusinessHoursMCC(businessHoursMCC);
            }
            //Obtenemos las BH del MCC
            if(caso.CC_MCC_Tematica__c != null) {
                if(caso.CC_MCC_Tematica__r.OS_Horario__c != null) {
                    idBusinessHours = caso.CC_MCC_Tematica__r.OS_Horario__c;
                }
                else if(mapaBusinessHoursMCC.containsKey(caso.CC_MCC_Tematica__c)){
                    idBusinessHours = mapaBusinessHoursMCC.get(caso.CC_MCC_Tematica__c).OS_Horario__c;
                }
            }
            //Si el producto tiene BH, estas deben sobreescribir a las de la temática
            if(caso.CC_MCC_ProdServ__c != null) {
                if(caso.CC_MCC_ProdServ__r.OS_Horario__c != null) {
                    idBusinessHours = caso.CC_MCC_ProdServ__r.OS_Horario__c;
                }
                else if(mapaBusinessHoursMCC.containsKey(caso.CC_MCC_ProdServ__c)){
                    idBusinessHours = mapaBusinessHoursMCC.get(caso.CC_MCC_ProdServ__c).OS_Horario__c;
                }
            }
            //obtenemos las horas del SLA de la causa
            if(caso.CC_MCC_Causa__c != null) {
                if(caso.CC_MCC_Causa__r.OS_Horas_SLA__c != null) {
                    horas = caso.CC_MCC_Causa__r.OS_Horas_SLA__c;
                }
                else if(mapaBusinessHoursMCC.containsKey(caso.CC_MCC_Causa__c)){
                    horas = mapaBusinessHoursMCC.get(caso.CC_MCC_Causa__c).OS_Horas_SLA__c;
                }
            }
    
            //CODIGO COMÚN PARA EFECTIVO Y HOLABANK
            if (horas != null && horas != '' && idBusinessHours != null) {
                Time businessHoursEndTime = mapDiasBusinessHours.get(idBusinessHours+':'+ahora.format('EEEE')); //Endtime de las BH del día actual
                if (horas == 'Mismo dia' && ahoraTime < businessHoursEndTime && BusinessHours.isWithin(idBusinessHours, ahora)) {
                    fechaLimiteResolucion = Datetime.newInstance(ahora.year(), ahora.month(), ahora.day(), businessHoursEndTime.hour(), 0, 0);
                } 
                else if(horas != 'Mismo dia' && ahoraTime < businessHoursEndTime && BusinessHours.isWithin(idBusinessHours, ahora)) {
                    dias = Integer.valueOf(horas)/24;
                    fechaLimiteResolucion = ahora;
                    for(Integer i = 0; i < dias; i++) {
                        fechaLimiteResolucion = fechaLimiteResolucion.addDays(1);
                        if(!BusinessHours.isWithin(idBusinessHours, fechaLimiteResolucion)) {
                            fechaLimiteResolucion = BusinessHours.nextStartDate(idBusinessHours, fechaLimiteResolucion);
                        }
                    }                       
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucion.year(), fechaLimiteResolucion.month(), fechaLimiteResolucion.day(), ahora.hour(), 0, 0);
                }
                else {          
                    //El caso se ha creado en un día no laborable, el SLA vence dependiendo de las horas el próximo día laborable en el fin de Hora de Servicio
                    //Proximo dia laborable inicio dia --- si horas == 'Mismo dia' o horas == 24
                    Datetime fechaLimiteResolucionInicioDia = BusinessHours.nextStartDate(idBusinessHours, ahora);
                    
                    if(horas != 'Mismo dia' && horas != '24') {
                        dias = Integer.valueOf(horas)/24;
                        //Empieza en i=1 porque hay que restar un día. Este día ya está añadido al partir del próximo día laborable.
                        for(Integer i = 1; i < dias; i++) {
                            fechaLimiteResolucionInicioDia = fechaLimiteResolucionInicioDia.addDays(1);
                            if(!BusinessHours.isWithin(idBusinessHours, fechaLimiteResolucionInicioDia)) {
                                fechaLimiteResolucionInicioDia = BusinessHours.nextStartDate(idBusinessHours, fechaLimiteResolucionInicioDia);
                            }
                        }
                    }
                    //Calculamos el fin de hora de servicio de la fecha de resolución
                    businessHoursEndTime = mapDiasBusinessHours.get(idBusinessHours+':'+fechaLimiteResolucionInicioDia.format('EEEE')); 
                    fechaLimiteResolucion = Datetime.newInstance(fechaLimiteResolucionInicioDia.year(), fechaLimiteResolucionInicioDia.month(), fechaLimiteResolucionInicioDia.day(), businessHoursEndTime.hour(), 0, 0);          
                }            
            }
        } 
        Integer horasRestantes;
        if(procedenciasUafe.contains(canalProcedenciaCaso)) {
            if(nombreValorLista.containsKey(canalProcedenciaCaso)) {
                horasRestantes = Integer.valueOf(nombreValorLista.get(canalProcedenciaCaso));
            }
            else {
                horasRestantes = 0;
            }
            //Como para UAFE los milestones se reabren y recalculan, ahora y fechaCreacion caso son System.now()
            ahora = System.now();
            fechaCreacionCaso = System.now();
            //Calculamos fecha de resolución para campo OS_Fecha_Fin_Entitlement__c
            if(mapBusinessHourNameId.containsKey(canalProcedenciaCaso)) {
                idBusinessHours = mapBusinessHourNameId.get(canalProcedenciaCaso);
                Long horasRestantesLong = horasRestantes * 60 * 60 * 1000;
                fechaLimiteResolucion = BusinessHours.add(idBusinessHours, fechaCreacionCaso, horasRestantesLong);
            }
        }

        camposCalculoMilestone.put('fechaLimiteResolucion', fechaLimiteResolucion);
        camposCalculoMilestone.put('ahora', ahora);
        camposCalculoMilestone.put('idBusinessHours', idBusinessHours);
        camposCalculoMilestone.put('mapBusinessHour', mapBusinessHour);
        camposCalculoMilestone.put('mapBusinessHourNameId', mapBusinessHourNameId);
        camposCalculoMilestone.put('horasRestantes', horasRestantes);
        camposCalculoMilestone.put('horas', horas);

        return camposCalculoMilestone;
    }   

    public static Map<String,Object> calculoCanalProcedenciaEmail(List<String> procedenciasTotales, Case caso, List<CC_Lista_Valores__c> listaBuzonesEmailColasTlfSLA){
        Map<String,Object> camposCalculoCanalProcedencia = new Map<String,Object>();
        
        //Mapa con el nombre y el CC_Valor__c de las listas de valores 'COPS: SLA Relación colas telefonía y canal de procedencia email' y 'COPS: Horas SLA para servicios UAFE'
        Map<String, String> nombreValorLista = new Map<String, String>();
        for(CC_Lista_Valores__c valor: listaBuzonesEmailColasTlfSLA) { 
            nombreValorLista.put(valor.Name, valor.CC_Valor__c);
        }
        //Cálculo Canal de procedencia del caso
        String canalProcedenciaCaso;
        if(procedenciasTotales.contains(caso.CC_Canal_Procedencia__c)) {
            canalProcedenciaCaso = caso.CC_Canal_Procedencia__c;
        }
        //Los casos de UAFE telefonía sacan la equivalencia cola telefónica - canal procedencia email de la lista de valores 'COPS: SLA Relación colas telefonía y canal de procedencia email'
        else if(caso.Origin == 'Phone' && caso.OS_Cola_Telefonia__c != null) {
            if(nombreValorLista.containsKey(caso.OS_Cola_Telefonia__c)) {
                canalProcedenciaCaso = nombreValorLista.get(caso.OS_Cola_Telefonia__c);
            }
        }
        camposCalculoCanalProcedencia.put('nombreValorLista', nombreValorLista);
        camposCalculoCanalProcedencia.put('canalProcedenciaCaso', canalProcedenciaCaso);

        return camposCalculoCanalProcedencia;
    }
    public static List<String> listadoCanalesProcedencias(String canalProcedencia) {
        Map<String, List<String>> canalListadoProcedencias = new Map<String, List<String>>();

        List<String> procedenciasBosEmail = new List<String>{'Buzón KYC Renewal', 'Buzón Service Desk'};
        List<String> procedenciasGocEmail = new List<String>{'Buzón Contact Center International', 'Buzón International Operations', 'Buzón CC Confirming International', 'Buzón International Support'};
        List<String> procedenciasUaiEmail = new List<String>{'Buzón Comercio Exterior', 'Buzón Export Online'};
        List<String> procedenciasHolabank = new List<String>{'Buzón CCI Holabank', 'Teléfono CCI HOLABANK'};
        List<String> procedenciasEfectivo = new List<String>{'Buzón Efectivo COPS', 'Teléfono Efectivo'};
        List<String> procedenciasUafe = new List<String>{'Buzón Contact Center Confirming', 'Buzón Crédito Stock', 'Buzón Factoring Sindicados', 'Buzón Inditex Suppliers', 'Buzón UAFE', 'Buzón UAFE Express'};
  
        //Procedencias cuyo SLA cierra en la toma de posesión del caso
        List<String> procedenciasCierreTomaPropiedad = new List<String>();
        procedenciasCierreTomaPropiedad.addAll(procedenciasBosEmail);
        procedenciasCierreTomaPropiedad.addAll(procedenciasGocEmail);
        procedenciasCierreTomaPropiedad.addAll(procedenciasUaiEmail);
        //Procedencias cuyo SLA cierra en el cierre del caso
        List<String> procedenciasCierreCaso = new List<String>();
        procedenciasCierreCaso.addAll(procedenciasHolabank);
        procedenciasCierreCaso.addAll(procedenciasEfectivo);
        procedenciasCierreCaso.addAll(procedenciasUafe);

        //Todas las procedencias
        List<String> procedenciasTotales = new List<String>();
        procedenciasTotales.addAll(procedenciasCierreTomaPropiedad);
        procedenciasTotales.addAll(procedenciasCierreCaso);

        canalListadoProcedencias.put('procedenciasBosEmail', procedenciasBosEmail);
        canalListadoProcedencias.put('procedenciasGocEmail', procedenciasGocEmail);
        canalListadoProcedencias.put('procedenciasUaiEmail', procedenciasUaiEmail);
        canalListadoProcedencias.put('procedenciasHolabank', procedenciasHolabank);
        canalListadoProcedencias.put('procedenciasEfectivo', procedenciasEfectivo);
        canalListadoProcedencias.put('procedenciasUafe', procedenciasUafe);
        canalListadoProcedencias.put('procedenciasTotales', procedenciasTotales);
        canalListadoProcedencias.put('procedenciasCierreTomaPropiedad', procedenciasCierreTomaPropiedad);
        canalListadoProcedencias.put('procedenciasCierreCaso', procedenciasCierreCaso);

        List<String> listaCanalesProcedencia = new List<String>();
        if(canalListadoProcedencias.containsKey(canalProcedencia)) {
            listaCanalesProcedencia = canalListadoProcedencias.get(canalProcedencia);
        }

        return listaCanalesProcedencia;
    }

    public static Map<Id, CC_MCC__c> obtenerMapaBusinessHoursMCC(List<CC_MCC__c> businessHoursMCC) {
        Map<Id, CC_MCC__c> mapaBusinessHoursMCC = new Map<Id, CC_MCC__c>();

        for(CC_MCC__c mcc: businessHoursMCC) {
            mapaBusinessHoursMCC.put(mcc.Id, mcc);
        }

        return mapaBusinessHoursMCC;
    }
}