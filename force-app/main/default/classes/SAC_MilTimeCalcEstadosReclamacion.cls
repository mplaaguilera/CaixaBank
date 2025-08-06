/*****************************************************************
 * Name: SAC_MilTimeCalcEstadosReclamacion
 * Copyright © 2019  CaixaBank
 * ============================================================
 * Proposito: Controlar el tiempo de vida de los milestones para las SLA de cada estado de la reclamacion para el proyecto SAC
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200213         Carlos Solis   16/04/21     Creación
 * 1.1            US213188         Luis Mesa      10/05/21     Actualización estados  
*****************************************************************/
public with sharing class SAC_MilTimeCalcEstadosReclamacion implements Support.MilestoneTriggerTimeCalculator {
/*****************************************************************
 * Proposito: En este método se calcula el tiempo del milestone dependiendo del estado en el que se encuentre el caso
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US200213         Carlos Solis   16/04/21     Creación
*****************************************************************/
    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer retornarMinutos = 1;
        Id recType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        if (Schema.sObjectType.Case.isAccessible()) {
            Case caso = [SELECT Id, RecordTypeId, Status FROM Case WHERE Id = :caseId];
            if (caso.RecordTypeId == recType) {
                switch on caso.Status{
                    when 'SAC_001'{ //Alta
                        retornarMinutos = 320;
                    }
                    when 'SAC_002'{ //Analisis
                        retornarMinutos = 320;
                    }
                    when 'SAC_003'{ //Redaccion
                        retornarMinutos = 320;
                    }
                    when 'SAC_004'{ //Ejecucion
                        retornarMinutos = 320;
                    }
                    when 'SAC_006'{ //Subsanacion
                        retornarMinutos = 320;
                    }
                    when 'SAC_007'{ //Negociacion
                        retornarMinutos = 320;
                    }
                }
            }
        }
        return retornarMinutos;
    }
}