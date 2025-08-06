/*****************************************************************
 * Name: SAC_LCMP_infoSla
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_infoSla.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                            Daniel Benito   03/11/21      Creación
*****************************************************************/

public without sharing class SAC_LCMP_infoSla {

    /*****************************************************************
    * Proposito: Rellenar el componente de SLA's de una pretensión y una reclamación cuando el estado de la reclamación padre
        está en Negociación/Subsanación y se pausa la SLA.
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US233793         Carlos Solis   15/06/21     Creación
    *****************************************************************/
    @AuraEnabled(cacheable = true)
    public static String comprobarEstadoPausaPadre(Id caseId) {

        String estado;
        Case reclamacion = [SELECT Id, Status FROM Case WHERE id =: caseId LIMIT 1];

        if(reclamacion.Status == 'SAC_006'){
            estado = 'Subsanación en la Reclamación';
        }else if(reclamacion.Status == 'SAC_007'){
            estado = 'Negociación en la Reclamación';
        }
        return estado;
    }

}