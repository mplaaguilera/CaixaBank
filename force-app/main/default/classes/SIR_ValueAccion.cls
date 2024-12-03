/*****************************************************************
 Name:  SIR_ValueAccion
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase para calcular la label del picklist Acción                                                                                                    
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US258874         Atmira         10/08/2021     	  Created    

*****************************************************************/
public with sharing class SIR_ValueAccion {
    @InvocableMethod(label='Value Action' description='recogemos el valor del picklist acción')
 	public static void valueAction(List<SIREC__SIREC_obj_acciones__c> acciones){
        List<Id> listId = new List<Id>();
        for(SIREC__SIREC_obj_acciones__c accion : acciones){
            listId.add(accion.Id);
        }
		if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isUpdateable()){
    
            List<SIREC__SIREC_obj_acciones__c> listAcciones = [SELECT id ,SIR_valorAccion__c , toLabel(SIREC__SIREC_fld_accion__c) 
                                                               FROM SIREC__SIREC_obj_acciones__c 
                                                               WHERE Id IN : listId];
            for(SIREC__SIREC_obj_acciones__c item : listAcciones){
                item.SIR_valorAccion__c = item.SIREC__SIREC_fld_accion__c;
            }
            if(listAcciones.size() > 0 ){
                update listAcciones;
            }
        }
   }
}