/*****************************************************************************************
 * Name: SAC_Accion_RellenarImporte
 * Copyright © 2021  CaixaBank
 * 
 * Propósito: Clase que contiene un método para heredar el importe de una pretensión para
 * rellenar el importe al crear una acción
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0            US277162         Daniel Benito      19/10/21      Creación Clase
******************************************************************************************/

public with sharing class SAC_Accion_RellenarImporte {
    
/*****************************************************************
* Proposito: Método que hereda el número de abono e importe de la pretensión 
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US277162         Daniel Benito   19/10/21      Creación
*****************************************************************/

public static void rellenarImporteAbono(List<SAC_Accion__c> listNewAcciones){

        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        List<Id> listaIdsCasos = new List<Id>();

        for (SAC_Accion__c accion : listNewAcciones) {
            //busco la pretension de la acción para saber cual es su padre
            if (accion.SAC_Pretension__c != null) {
                listaIdsCasos.add(accion.SAC_Pretension__c);
            }
        }

        if (Schema.sObjectType.Case.isAccessible()) {
            List<Case> listaPretensiones = [select id,CC_Importe_Abonado__c from Case where id in :listaIdsCasos
                                            and recordtypeId = :recTypePretension];

            for(SAC_Accion__c accion : listNewAcciones){

                for(Case pretension : listaPretensiones){

                    if(accion.SAC_Pretension__c == pretension.id){

                        accion.SAC_ImporteAbonar__c = pretension.CC_Importe_Abonado__c;

                    }
                }
            }
        }
    }

}