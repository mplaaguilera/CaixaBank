/*****************************************************************
 * Name: SAC_NotificacionesBatch
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Clase schedulable para programar el lanzamiento del batch SAC_NotificacionesBatch
 *            Clase Test que la cubre: SAC_NotificacionesBatch_Test
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US271705         Carlos Solis   20/10/21     Creación
*****************************************************************/
public with sharing class SAC_NotificacionesBatchSchedule implements Schedulable {
    public void execute (SchedulableContext ctx) {
        Id batchId = Database.executeBatch(new SAC_NotificacionesBatch(),10);
    }
}