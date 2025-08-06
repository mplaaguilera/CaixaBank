/*****************************************************************
 * Name: SAC_PorcentajesGrupoColaborador
 * Copyright © 2019  CaixaBank 
 * 
 * Proposito: Hacer que el porcentaje de asignación de todos los grupos (CC_Grupo_Colaborador__c) juntos siempre sea igual a 100
 * 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213183         Carlos Solis   10/05/21      Creación
*****************************************************************/
public with sharing class SAC_PorcentajesGrupoColaborador {
    /*****************************************************************
     * Proposito: Método para controlar el porcentaje de asignacion total de los grupos al insertar, de manera que la suma de todos
     * siempre tiene que ser igual a 100
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   7/05/21      Creación
    *****************************************************************/
    public static void comprobarPorcentajeInsert(List<CC_Grupo_Colaborador__c> listNewGrupo) {
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        if (Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()) {
            List<CC_Grupo_Colaborador__c> listaGrupoColaborador = [select id, name, SAC_PorcentajeAsignacion__c, RecordTypeId from CC_Grupo_Colaborador__c 
                                                                    where RecordTypeId = :recTypeProveedores];
            
            for (CC_Grupo_Colaborador__c grupoColab : listNewGrupo) {
                if (grupoColab.RecordTypeId == recTypeProveedores) {
                    listaGrupoColaborador.add(grupoColab);
                }
            }
            Decimal acumuladorPorcentajes = 0;
            for (CC_Grupo_Colaborador__c grupocolab : listaGrupoColaborador) {
                acumuladorPorcentajes = acumuladorPorcentajes + grupocolab.SAC_PorcentajeAsignacion__c;
            }
            for (CC_Grupo_Colaborador__c grupoColab : listNewGrupo) {
                if (acumuladorPorcentajes != 100) {
                    grupocolab.addError('El porcentaje de todos los grupos debe sumar siempre 100%');
                }
            }
        }
    }
    /*****************************************************************
     * Proposito: Método para controlar el porcentaje de asignacion total de los grupos al updatear, de manera que la suma de todos
     * siempre tiene que ser igual a 100
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   7/05/21      Creación
    *****************************************************************/
    public static void comprobarPorcentajeUpdate(List<CC_Grupo_Colaborador__c> listNewGrupo) {
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        if (Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()) {
            Decimal acumuladorPorcentajes = 0;
            Decimal oldPorcentaje = 0;
            
            List<CC_Grupo_Colaborador__c> newListaGrupoColaborador = [select id, name, SAC_PorcentajeAsignacion__c, RecordTypeId from CC_Grupo_Colaborador__c 
                                                                    where RecordTypeId = :recTypeProveedores];
            
            Map<ID, CC_Grupo_Colaborador__c> newMapGrupoColaborador = new Map<ID, CC_Grupo_Colaborador__c>();

            for (CC_Grupo_Colaborador__c grupo : newListaGrupoColaborador) {
                newMapGrupoColaborador.put(grupo.Id, grupo);
            }

            for (CC_Grupo_Colaborador__c grupoColab : listNewGrupo) {
                if (grupoColab.RecordTypeId == recTypeProveedores) {
                    if (newMapGrupoColaborador.containsKey(grupoColab.Id)) {
                        newMapGrupoColaborador.put(grupocolab.id, grupocolab);
                    }
                }
            }

            for (CC_Grupo_Colaborador__c grupo : newMapGrupoColaborador.values()) {
                acumuladorPorcentajes += grupo.SAC_PorcentajeAsignacion__c;
            }

            for (CC_Grupo_Colaborador__c grupoColab : listNewGrupo) {
                if (acumuladorPorcentajes != 100) {
                    grupocolab.addError('El porcentaje de todos los grupos debe sumar siempre 100%');
                }
            }
        }
    }
    /*****************************************************************
     * Proposito: Método para controlar el porcentaje de asignacion del grupo que se va a borrar.
     * Para que pueda borrarse, su porcentaje siempre debe ser 0.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US213183         Carlos Solis   10/05/21      Creación
    *****************************************************************/
    public static void comprobarPorcentajeDelete(List<CC_Grupo_Colaborador__c> listOldGrupo) {
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        if (Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()) {
            List<CC_Grupo_Colaborador__c> listaGrupoColaborador = [select id, name, SAC_PorcentajeAsignacion__c, RecordTypeId from CC_Grupo_Colaborador__c 
                                                                    where RecordTypeId = :recTypeProveedores];
            for (CC_Grupo_Colaborador__c grupoColab : listOldGrupo) {
                if (grupoColab.SAC_PorcentajeAsignacion__c != 0) {
                    grupocolab.addError('El porcentaje de asignación para eliminar un grupo debe ser 0');
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Al insertar un grupo colaborador, si es el primero en entrar al sistema, pone
     * el campo porcentaje de asignacion a 100. De lo contrario, lo pone a 0.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            NaN              Carlos Solis   28/01/22     Creación
    *****************************************************************/
    public static void establecerPorcentajeAsignacion(List<CC_Grupo_Colaborador__c> listNewGrupos) {
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        //Comprobar si hay algun grupo de este record type creado en el sistema
        List<CC_Grupo_Colaborador__c> listaGruposProveedores = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :recTypeProveedores];

        //Si ya hay algún grupo creado con el record type proveedores, asignamos el porcentaje a 100 en el primer grupo. Si no, lo asignamos a 0.
        if (listaGruposProveedores.isEmpty()) {
            Integer contador = 0;
            for (CC_Grupo_Colaborador__c grupo : listNewGrupos) {
                if (contador == 0) {
                    grupo.SAC_PorcentajeAsignacion__c = 100;
                } else {
                    grupo.SAC_PorcentajeAsignacion__c = 0;
                }
                contador ++;
            }
        } else {
            for (CC_Grupo_Colaborador__c grupo : listNewGrupos) {
                grupo.SAC_PorcentajeAsignacion__c = 0;
            }
        }
    }
}