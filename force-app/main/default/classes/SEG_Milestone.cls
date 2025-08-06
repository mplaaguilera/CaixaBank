global without sharing class  SEG_Milestone implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        
        
        Datetime ahora = system.now();
        // Calculo Fecha inicio SLA
        Case caso = [SELECT Id, createddate,SEG_Fecha_inicio_SLA__c, SEG_Fecha_valor__c FROM Case WHERE Id = :caseId LIMIT 1];

        if (caso.SEG_Fecha_valor__c != null){
            ahora = caso.SEG_Fecha_valor__c;
        }
        else if (caso.SEG_Fecha_inicio_SLA__c != null){
            ahora = caso.SEG_Fecha_inicio_SLA__c;
        } 


        Integer horaInicio = 8; //Se mantiene el inicio de 08 por si falla la obtención del metadata
        Integer minutoInicio = 0; //Se mantiene el inicio de 08 por si falla la obtención del metadata
        Integer horaFin = 17; //Se mantiene el fin de 17 por si falla la obtención del metadata
        Integer minutoFin = 0; //Se mantiene el fin de 17 por si falla la obtención del metadata

        //US596437 - Se cambia la obtención de las horas de inicio y fin. Se traspasa la obtención del dato al Custom Metadata Type - SEG_Rango_SLA 
        SEG_Rango_SLA__mdt rangoHoras = [SELECT SEG_Horario_Activo__c, SEG_Hora_Inicio_SLA__c, SEG_Minutos_Inicio_SLA__c, SEG_Hora_Fin_SLA__c, SEG_Minutos_Fin_SLA__c FROM SEG_Rango_SLA__mdt WHERE SEG_Horario_Activo__c = true LIMIT 1];
        if(rangoHoras != null){
            horaInicio = (rangoHoras.SEG_Hora_Inicio_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Hora_Inicio_SLA__c) : horaInicio;
            minutoInicio = (rangoHoras.SEG_Minutos_Inicio_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Minutos_Inicio_SLA__c) : minutoInicio;
            horaFin = (rangoHoras.SEG_Hora_Fin_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Hora_Fin_SLA__c) : horaFin;
            minutoFin = (rangoHoras.SEG_Minutos_Fin_SLA__c != null) ? Integer.valueOf(rangoHoras.SEG_Minutos_Fin_SLA__c) : minutoFin;
        }

        Time timeIni = Time.newInstance(horaInicio, minutoInicio, 0, 0); 
        Time timeEnd = Time.newInstance(horaFin, minutoFin, 0, 0); 

        DateTime dtIni = DateTime.newInstance(ahora.date(), timeIni);
        DateTime dtEnd = DateTime.newInstance(ahora.date(), timeEnd);
        Id idBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id; 
        
        Datetime fechaInicioSLA;
        Datetime fechaResolucionSLA;
        Integer  diaCorreccion = 0;

        //Correccion a día hábil
        if((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
            (ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  >= dtIni))
        {
            fechaInicioSLA = ahora;
        }
        else if ((ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtEnd) && 
                 (ahora.isSameDay(BusinessHours.nextStartDate(idBusinessHours, ahora)) && ahora  < dtIni))
        {
            fechaInicioSLA = dtIni;
        }
        else{
            fechaInicioSLA = BusinessHours.nextStartDate(idBusinessHours, Datetime.newInstance(ahora.addDays(1).year(), ahora.addDays(1).month(), ahora.addDays(1).day(), 8, 0, 0));
        }

        Time iniJornada = Time.newInstance(8, 0, 0, 0);
        if(iniJornada == fechaInicioSLA.time())
        {
            diaCorreccion = 1;
        }



        // Calculo Fecha fin SLA
        //Long milisegundosdia = BusinessHours.diff(idBusinessHours, BusinessHours.nextStartDate(idBusinessHours, fechaInicioSLA.addDays(1)), BusinessHours.nextStartDate(idBusinessHours, BusinessHours.nextStartDate(idBusinessHours, fechaInicioSLA.addDays(1)).addDays(1)));
        DateTime d1 = BusinessHours.nextStartDate(idBusinessHours,DateTime.newInstance(2023, 1, 2, 8, 0, 0));
        DateTime d2 = BusinessHours.nextStartDate(idBusinessHours,d1.addDays(1));
        Long milisegundosdia = BusinessHours.diff(idBusinessHours, d1, d2);
        Long milisegundosSLA;
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        if (mt.Name != null && mt.Name.equals('SEG SLA Dia despues')) { 
            milisegundosSLA = milisegundosdia*(1+diaCorreccion);
            fechaResolucionSLA = BusinessHours.add(idBusinessHours, fechaInicioSLA, milisegundosSLA);
        }
        else if(mt.Name != null && mt.Name.equals('SEG SLA 2 dias')){ 
            milisegundosSLA = milisegundosdia*(2+diaCorreccion);
            fechaResolucionSLA = BusinessHours.add(idBusinessHours, fechaInicioSLA, milisegundosSLA);
        }
        else if(mt.Name != null && mt.Name.equals('SEG SLA 3 dias')){
            milisegundosSLA = milisegundosdia*(3+diaCorreccion);
            fechaResolucionSLA = BusinessHours.add(idBusinessHours, fechaInicioSLA, milisegundosSLA);
        }
        else if(mt.Name != null && mt.Name.equals('SEG SLA 4 dias')){
            milisegundosSLA = milisegundosdia*(4+diaCorreccion);
            fechaResolucionSLA = BusinessHours.add(idBusinessHours, fechaInicioSLA, milisegundosSLA);
        }
        else if(mt.Name != null && mt.Name.equals('SEG SLA 5 dias')){
            milisegundosSLA = milisegundosdia*(5+diaCorreccion);
            fechaResolucionSLA = BusinessHours.add(idBusinessHours, fechaInicioSLA, milisegundosSLA);
        }
        else if(mt.Name != null && mt.Name.equals('SEG SLA 1 semana')){ 
            fechaResolucionSLA = BusinessHours.nextStartDate(idBusinessHours, fechaInicioSLA.addDays(7));
        }
        else if(mt.Name != null && mt.Name.equals('SEG SLA 1 mes')){  
            fechaResolucionSLA = BusinessHours.nextStartDate(idBusinessHours, fechaInicioSLA.addMonths(1));
        }
        else {
            //mismo día
            fechaResolucionSLA = fechaInicioSLA;   
        }
        fechaResolucionSLA = Datetime.newInstance(fechaResolucionSLA.year(), fechaResolucionSLA.month(), fechaResolucionSLA.day(), 23, 59, 0);   

        Integer minutosRestantes;
        minutosRestantes = BusinessHours.diff(idBusinessHours, fechaInicioSLA, fechaResolucionSLA).intValue() / 60000;

        //// update CaseMilestone
        try {
            if(!System.isFuture()){
                Boolean actualizarFecha = false;
                List<CaseMilestone> milestonesEnCurso = [SELECT id, StartDate FROM caseMilestone WHERE caseId =: caseId AND MilestoneTypeId =: milestoneTypeId];
                if (!milestonesEnCurso.isEmpty() || Test.isRunningTest()) {
                    List<CaseMilestone> lstMilestones = new List<CaseMilestone>();
                    for (CaseMilestone milestone : milestonesEnCurso) {
                        if(milestone.StartDate != fechaInicioSLA) {
                            actualizarFecha = true;
                        }
                    }
                    if(actualizarFecha || Test.isRunningTest()){
                        updateFechaInicio(caseId, milestoneTypeId, fechaInicioSLA);
                    }
                }
            }
        } catch (Exception e) {
            cbk_log.error(e);
        }

        return minutosRestantes >= 0 ? minutosRestantes : 1;
    }

    @InvocableMethod
    public static void completarMilestones(List<Id> idCasos) {
        //Completa los milestones abiertos de los casos indicados
        List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate FROM CaseMilestone WHERE CaseId IN :idCasos AND CompletionDate = null];
        for (CaseMilestone milestone : milestonesEnCurso) {
            milestone.CompletionDate = System.now();
        }
        update milestonesEnCurso;
        
    }

    @future
    public static void updateFechaInicio(String caseId, String milestoneTypeId, Datetime fechaInicioSLA){
        List<CaseMilestone> milestonesEnCurso = [SELECT id, StartDate FROM caseMilestone WHERE caseId =: caseId AND MilestoneTypeId =: milestoneTypeId];
        if (!milestonesEnCurso.isEmpty() || Test.isRunningTest()) {
            try {
                List<CaseMilestone> lstMilestones = new List<CaseMilestone>();
                for (CaseMilestone milestone : milestonesEnCurso) {
                    if(milestone.StartDate != fechaInicioSLA)
                    {
                        milestone.StartDate = fechaInicioSLA;
                        lstMilestones.add(milestone);
                    }
                } 

                if(!lstMilestones.isEmpty()){
                    update lstMilestones;
                }
            } catch (Exception e) {
                cbk_log.error(e);
            }
        }
    }
}