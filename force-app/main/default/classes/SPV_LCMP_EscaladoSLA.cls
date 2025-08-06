/***************************************************************** 
 * Name: SPV_LCMP_EscaladoSLA
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Controlador del componente Spv_EscaladoSLA
 * 
 * Historial
 * -------
 * VERSION        USER_STORY        AUTHOR            DATE         Description
 * 1.0             US1208742       Sergio Martín    16/06/2025      Creación
*****************************************************************/
public with sharing class SPV_LCMP_EscaladoSLA {
    /*****************************************************************
    * Proposito: Recuperar la duración del escalado
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0             US1208742       Sergio Martín    16/06/2025      Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static SLAWrapper recuperarSLAEscalado(Id recordId) {
        Id ideBH;
        Datetime fechaInicio;
        Datetime fechaFin;
        Boolean comenzado = false;
        Boolean sobrepasado = false;
        Boolean finalizado = false;
        SAC_Interaccion__c escalado = [SELECT Id, SPV_FechaPendienteRespuesta__c, SPV_SLAFinalizado__c
                                                    FROM SAC_Interaccion__c WHERE Id =: recordId LIMIT 1];

        if (escalado != null && escalado.SPV_FechaPendienteRespuesta__c != null && escalado.SPV_SLAFinalizado__c == false) {
            if (Cache.Org.contains('local.SAC.SACCalendario')) {
                String calend = (String)Cache.Org.get('local.SAC.SACCalendario');
                ideBH = Id.valueOf(calend);
            }
            else{
                ideBH = [SELECT Id, name FROM BusinessHours where name ='SPV_Calendario'].id;
                Cache.Org.put('local.SAC.SACCalendario', String.valueOf(ideBH),300);
            }
            //Para empezar a contar desde el siguiente día hábil a la fecha de paso a pendiente respuesta debemos comprobar que es día hábil 
            fechaInicio = escalado.SPV_FechaPendienteRespuesta__c.addDays(1);
            while(!BusinessHours.isWithin(ideBH, fechaInicio)) {  //Es día hábil? 
                fechaInicio = fechaInicio.addDays(1); 
            }

            fechaFin = fechaInicio.addDays(1); 

            // Si ha comenzado a contar el SLA 
            if(fechaInicio < CBK_UtilsDate.nowDT()) {
                comenzado = true;
                // Si se ha sobrepasado el SLA
                if(fechaFin < CBK_UtilsDate.nowDT()) {
                    sobrepasado = true;
                }
            }
        } else if(escalado.SPV_SLAFinalizado__c == true) {
            finalizado = true;
        }
        SLAWrapper fecha = new SLAWrapper(comenzado, sobrepasado, finalizado, fechaInicio, fechaFin);
        return fecha;
    }

    public class SLAWrapper {
        @AuraEnabled public Boolean comenzado {get; set;}
        @AuraEnabled public Boolean sobrepasado {get; set;}
        @AuraEnabled public Boolean finalizado {get; set;}
        @AuraEnabled public DateTime fechaInicio {get; set;}
        @AuraEnabled public DateTime fechaFin {get; set;}

        public SLAWrapper(Boolean comenzado, Boolean sobrepasado, Boolean finalizado, DateTime fechaInicio, DateTime fechaFin) {
            this.comenzado = comenzado;
            this.sobrepasado = sobrepasado;
            this.finalizado = finalizado;
            this.fechaInicio = fechaInicio;
            this.fechaFin = fechaFin;
        }
    }
}