/***************************************************************************
 * Name: SAC_ProrrogaAutomaticaSchedule
 * Copyright © 2021  CaixaBank
 * =========================================================================
 * Proposito: Llamar a la clase Batch SAC_ProrrogaAutomatica.
 * =========================================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US254503         Esteve Llaó      23/08/2021   Creación
***************************************************************************/
public without sharing class SAC_ProrrogaAutomaticaSchedule implements Schedulable {
    public void execute (SchedulableContext ctx) {
        Id batchId = Database.executeBatch(new SAC_ProrrogaAutomatica(),10);
    }
}