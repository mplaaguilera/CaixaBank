public with sharing class SPV_MilestoneAnalisisDecisionLetrado implements Support.MilestoneTriggerTimeCalculator {
    //Obtener record Type
    Set<String> objetos = new Set<String>{'Case','SPV_Formulario__c'};
    Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    Id recTypePretension = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    Id recTypeFormulario = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioAnalisisDecision').getRecordTypeId();


    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer tiempo = 21600; // 15 días naturales
        Case caso;
        Id ideBH;
        Datetime fechaFin;
        Datetime fechaInicial; 
        Integer diasRestantes;

        if (Schema.sObjectType.Case.isAccessible()) {
            caso = [SELECT Id, CreatedDate, RecordTypeId, CBK_Case_Extension_Id__r.SPV_FechaAnalisisDecision__c, SAC_TipoConsumidor__c, SPV_Organismo__c, SAC_FechaRecepcion__c, SAC_DiaVencimientoSLA__c, SPV_DiasProrroga__c, CBK_Case_Extension_Id__r.SPV_MotivoAnulacionProrroga__c, CBK_Case_Extension_Id__r.SPV_FechaAnulacionProrroga__c FROM Case WHERE Id = :caseId];

            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }

            fechaInicial = calcularFechaInicial(caso);
            
            //Para empezar a contar desde el siguiente día hábil al momento en que entra en estado de envío debemos comprobar que es día hábil 
            fechaInicial = fechaInicial.addDays(1);
            while(!BusinessHours.isWithin(ideBH, fechaInicial)) {  
                fechaInicial = fechaInicial.addDays(1); 
            }

            // Si NO es organismo Consumo
            if(caso.SPV_Organismo__c != 'SPV_Consumo') {
                List<SPV_Formulario__c> formAnalisis = [SELECT Id, SPV_DecisionFinal__c, RecordType.DeveloperName FROM SPV_Formulario__c WHERE SPV_Caso__c =: caseId AND RecordTypeId =: recTypeFormulario ORDER BY CreatedDate DESC LIMIT 1];
                if(!formAnalisis.isEmpty()) {
                    // Cambiará a 10 hábiles si al informar el campo "Decisión final" de la reclamación es "Alegaciones"
                    if(formAnalisis[0].SPV_DecisionFinal__c == 'SPV_005') {
                        fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(10));
                    } else {
                        fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(7));
                    }
                } else{
                    fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(7));
                }
            // Si es organismo Consumo y el "Plazo Regulatorio Análisis" tiene un plazo igual o inferior a 11 días naturales, el "SLA Análisis y Decisión Letrado" será de 5 días hábiles. Si es superior a 11 días, será de 7 días hábiles
            } else {
                if(caso.SAC_DiaVencimientoSLA__c != null) {
                    diasRestantes = CBK_UtilsDate.todayDT().daysBetween(caso.SAC_DiaVencimientoSLA__c);
                    if(diasRestantes <= 11) {
                        fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(5));
                    } else {
                        fechaFin = BusinessHours.add(ideBH, fechaInicial, calcularMilisegundos(7));
                    }
                }
            }

            //Añade los días correspondientes en caso de que se haya prorrogado la reclamación y no se haya anulado la prórroga
            if(caso.SPV_DiasProrroga__c != 0 && caso.CBK_Case_Extension_Id__r.SPV_MotivoAnulacionProrroga__c == null) {
                if(caso.SPV_Organismo__c != 'SPV_Consumo') {
                    // Si se suman 11  naturales o menos al "Plazo Regulatorio Análisis", sumará 5 días hábiles al "SLA Análisis y Decisión Letrado"
                    if(caso.SPV_DiasProrroga__c <= 11) {
                        fechaFin = BusinessHours.add(ideBH, fechaFin, calcularMilisegundos(5));
                    // Si se suman más de 11 naturales al "Plazo Regulatorio Análisis", sumará 7 días hábiles al "SLA Análisis y Decisión Letrado"
                    } else {
                        fechaFin = BusinessHours.add(ideBH, fechaFin, calcularMilisegundos(7));
                    }
                } else {
                    // Si se suman 7 naturales o menos al "Plazo Regulatorio Análisis", sumará 3 días hábiles al "SLA Análisis y Decisión Letrado",
                    if(caso.SPV_DiasProrroga__c <= 7) {
                        fechaFin = BusinessHours.add(ideBH, fechaFin, calcularMilisegundos(3));
                    // Si se suman más de 7 naturales al "Plazo Regulatorio Análisis", sumará 5 días hábiles al "SLA Análisis y Decisión Letrado"
                    } else {
                        fechaFin = BusinessHours.add(ideBH, fechaFin, calcularMilisegundos(5));
                    }
                }
            } 

            if(fechaFin != null) {
                //Para comprobar que es día hábil el día de finalización
                while(!BusinessHours.isWithin(ideBH, fechaFin)) {  
                    fechaFin = fechaFin.addDays(1); 
                }

                //Añade los minutos necesarios a la fecha fin del SLA regulatorio para que siempre acabe a las 23:59 del día de finalización
                Integer minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(fechaFin);
                fechaFin = fechaFin.addMinutes(minutosDiaCompleto);

                Long restaTiempo = fechaFin.getTime() - fechaInicial.getTime();
                tiempo = (restaTiempo / 60000).intValue(); 
            }   
        }
        
        return tiempo;
    }

    public Datetime calcularFechaInicial(Case caso) {
        Datetime fechaInicial; 
        if(caso.CBK_Case_Extension_Id__r.SPV_FechaAnalisisDecision__c == null){
            fechaInicial = CBK_UtilsDate.nowSYS();
        }else{
            fechaInicial = caso.CBK_Case_Extension_Id__r.SPV_FechaAnalisisDecision__c;
        }
        return fechaInicial;
    }


    public Long calcularMilisegundos(Integer dias) {
        Long milisegundos = dias * 24 * 60 * 60 * 1000L;
        return milisegundos;
    }
}