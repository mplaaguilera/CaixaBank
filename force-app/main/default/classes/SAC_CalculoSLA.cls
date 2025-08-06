/*****************************************************************
 * Name: SAC_CalculoSLA
 * Copyright © 2021  CaixaBank  
 * 
 * Proposito: Clase para buscar la parametrización en base al MCC
 *            y rellenar los campos SAC_TiempoSLARegulatorio__c y
 *            SAC_TiempoSLALetradoAlta__c en el Caso (Reclamación
 *            y Pretensión)
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0              ---             Marcela Neira  27/09/21     Creación
 *                                  Esteve Llao        
*****************************************************************/
public without sharing class SAC_CalculoSLA {
    /*****************************************************************
     * Proposito: Método para sacar el tiempo de la parametrización del MCC del Caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            NaN              Marcela Neira  10/09/21     Creación
     *                                 Esteve Llao      
    *****************************************************************/
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

    private static final Id RECTYPESLAREGULATORIO = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLARegulatorio').getRecordTypeId();
    private static final Id RECTYPESLALETRADO = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLALetrado').getRecordTypeId();
    private static final Id RECTYPESLACIRCUITOSESPECIALES = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_SLACircuitosEspeciales').getRecordTypeId();

    public static List<Case> buscarParametrizacionMCC(List<Case> listaFamilia) {
        
        Map<Id,List<case>> mapaFamilia = SAC_ComportamientoSLAs.montarMapaReclamacionFamilia(listaFamilia);
        Map<String,List<SAC_ParametrizacionSLATME__c>> mapaParametrizacionesRegulatorio = new Map<String,List<SAC_ParametrizacionSLATME__c>>();
        Map<String,List<SAC_ParametrizacionSLATME__c>> mapaParametrizacionesLetrado = new Map<String,List<SAC_ParametrizacionSLATME__c>>();
        Map<Id,List<SAC_ParametrizacionSLATME__c>> mapaParamFamiliaRegulatorio = new Map<Id,List<SAC_ParametrizacionSLATME__c>>();
        Map<Id,List<SAC_ParametrizacionSLATME__c>> mapaParamFamiliaLetrado = new Map<Id,List<SAC_ParametrizacionSLATME__c>>();
        Map<String,Decimal> mapaParamEspeciales = new Map<String,Decimal>();
        Set<Id> idMCC = new Set<Id>();
        Set<String> setCanalProcedencia = new Set<String>();

        for (Case caso : listaFamilia) {
            String clave = caso.SEG_Detalle__c + caso.CC_Canal_Procedencia__c;            
            mapaParametrizacionesRegulatorio.put(clave, new List<SAC_ParametrizacionSLATME__c>()); 
            mapaParametrizacionesLetrado.put(clave, new List<SAC_ParametrizacionSLATME__c>()); 
            idMCC.add(caso.SEG_Detalle__c);
            setCanalProcedencia.add(caso.CC_Canal_Procedencia__c);           
        }

        List<SAC_ParametrizacionSLATME__c> listaParametrizacion = [SELECT id, SAC_Duracion__c, RecordTypeId, SAC_MCC__c, SAC_CanalProcedencia__c, SAC_Tipo__c FROM SAC_ParametrizacionSLATME__c
                                                                    WHERE (RecordTypeId = :RECTYPESLAREGULATORIO AND SAC_MCC__c in :idMCC  AND SAC_CanalProcedencia__c IN :setCanalProcedencia) //caso.canal
                                                                    OR (RecordTypeId = :RECTYPESLALETRADO AND SAC_MCC__c in :idMCC AND SAC_CanalProcedencia__c IN :setCanalProcedencia)
                                                                    OR (RecordTypeId = :RECTYPESLACIRCUITOSESPECIALES)];
        
        
        for (SAC_ParametrizacionSLATME__c paramAux : listaParametrizacion) {
            String clave = paramAux.SAC_MCC__c + paramAux.SAC_CanalProcedencia__c;
            if(paramAux.RecordTypeId == RECTYPESLAREGULATORIO && mapaParametrizacionesRegulatorio.containsKey(clave)){
                mapaParametrizacionesRegulatorio.get(clave).add(paramAux);
            }
            if(paramAux.RecordTypeId == RECTYPESLALETRADO && mapaParametrizacionesRegulatorio.containsKey(clave)){
                mapaParametrizacionesLetrado.get(clave).add(paramAux);
            }
            //Si es especial, relleno un mapa con la clave de el tipo de especial y su duracion
            if (paramAux.RecordTypeId == RECTYPESLACIRCUITOSESPECIALES) {
                mapaParamEspeciales.put(paramAux.SAC_Tipo__c, paramAux.SAC_Duracion__c);
            }
        }

        for (Case caso : listaFamilia) {
            if (caso.RecordTypeId == RECTYPERECLAMACION) {
                mapaParamFamiliaRegulatorio.put(caso.id, new List<SAC_ParametrizacionSLATME__c>());
                mapaParamFamiliaLetrado.put(caso.id, new List<SAC_ParametrizacionSLATME__c>());
            }
        }
        

        for (Case caso : listaFamilia) {
            String clave = caso.SEG_Detalle__c + caso.CC_Canal_Procedencia__c;
            if(caso.RecordTypeId == RECTYPERECLAMACION){ 
                mapaParamFamiliaRegulatorio.get(caso.id).addAll(mapaParametrizacionesRegulatorio.get(clave)); 
                mapaParamFamiliaLetrado.get(caso.id).addAll(mapaParametrizacionesLetrado.get(clave));                
            }else{
                mapaParamFamiliaRegulatorio.get(caso.SAC_Reclamacion__c).addAll(mapaParametrizacionesRegulatorio.get(clave));
                mapaParamFamiliaLetrado.get(caso.SAC_Reclamacion__c).addAll(mapaParametrizacionesLetrado.get(clave));
            }            
        }


        for(Id ide : mapaFamilia.keySet()){ 

            Integer tiempoRegulatorio = SAC_CalculoSLA.buscarParametrizacionCortaRegulatorio(mapaParamFamiliaRegulatorio.get(ide));
            Integer tiempoLetrado = SAC_CalculoSLA.buscarparametrizacionCortaLetrado(mapaParamFamiliaLetrado.get(ide), tiempoRegulatorio);

            for (Case caso : mapaFamilia.get(ide)) {                   
                
                caso.SAC_TiempoSLARegulatorio__c = tiempoRegulatorio;
                caso.SAC_TiempoSLALetradoAlta__c = tiempoLetrado;

                //Asignacion de SLA Letrado de circuitos especiales
                if (caso.SAC_Reclamacion__r.SAC_CasoEspecial__c == 'SAC_Presidencia' && mapaParamEspeciales.containsKey('SAC_Presidencia')) {
                    caso.SAC_TiempoSLALetradoAlta__c = mapaParamEspeciales.get('SAC_Presidencia');
                }
                if (caso.SAC_Reclamacion__r.SAC_CasoEspecial__c == 'SAC_Sensible' && mapaParamEspeciales.containsKey('SAC_CasoSensible')) {
                    caso.SAC_TiempoSLALetradoAlta__c = mapaParamEspeciales.get('SAC_CasoSensible');
                }
            } 
        }
        

        List<Case> listaRetornar = new List<Case>();

        for(Id ide : mapaFamilia.keySet()){ 
            listaRetornar.addAll(mapaFamilia.get(ide));
        }
        return listaRetornar;
    }

    public static Integer buscarParametrizacionCortaRegulatorio(List<SAC_ParametrizacionSLATME__c> listaParametrizacion) {
        
        //Buscar la parametrización con la duración más corta
        Integer minutos =  1500000;
        Integer duracionMasCorta =  1500000;
        Integer slaSinMcc = 30;
        if (!listaParametrizacion.isEmpty()) {
            for (SAC_ParametrizacionSLATME__c parametrizacion : listaParametrizacion) {
                minutos = Integer.valueOf(parametrizacion.SAC_Duracion__c);
                if (minutos < DuracionMasCorta) {
                    duracionMasCorta = minutos;
                }
            }
            return duracionMasCorta;
        } else {
            return slaSinMcc;
        }
    }
    public static Integer buscarparametrizacionCortaLetrado(List<SAC_ParametrizacionSLATME__c> listaParametrizacion, Integer tiempoRegulatorio) {
        Integer sla = 30;
        if (!listaParametrizacion.isEmpty()) {
            for (SAC_ParametrizacionSLATME__c parametrizacion : listaParametrizacion) {
                if (tiempoRegulatorio <= parametrizacion.SAC_Duracion__c) {
                    sla = tiempoRegulatorio ;
                } else if(tiempoRegulatorio > parametrizacion.SAC_Duracion__c) {
                    sla = Integer.valueOf(parametrizacion.SAC_Duracion__c) ;
                }
            }
        } else {
            if (sla > tiempoRegulatorio) {
                sla = tiempoRegulatorio;
            }
        }
        return sla;
    }

}