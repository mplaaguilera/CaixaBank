/*****************************************************************
 * Name: SAC_RechazarReclamacionMasiva_Controller
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controller de la VisualForce Page SAC_RechazarReclamacionMasiva.page
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0             DE71399       Sergio Martín    23/02/2023       Creación 
*****************************************************************/
public without sharing class SAC_RechazarReclamacionMasiva_Controller {
    public List<Case> getIDs;
    public String updateIds{get;set;}    
    public SAC_RechazarReclamacionMasiva_Controller(ApexPages.StandardSetController controller){
        getIDs = controller.getSelected();
        updateIds = '';  
        for(Case myIds : getIDs){
            updateIds += myIds.Id + ','; 
        }
        updateIds = updateIds.removeEnd(','); 
    }   
}