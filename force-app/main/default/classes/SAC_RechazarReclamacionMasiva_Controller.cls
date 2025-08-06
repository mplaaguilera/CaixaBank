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
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPECONSULTACOPS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
    public List<Case> getIDs;
    public String updateIds{get;set;}    
    public Boolean distintosRT{get;set;}
    public String tipoCaso{get;set;}  
    public SAC_RechazarReclamacionMasiva_Controller(ApexPages.StandardSetController controller){
        distintosRT = false;
        getIDs = controller.getSelected();
        updateIds = ''; 
        String recordType = null;
        for(Case myIds : getIDs){
            updateIds += myIds.Id + ','; 
            if(recordType == null || recordType == myIds.RecordTypeId){
                recordType = myIds.RecordTypeId;
            }else{
                distintosRT = true;
            }
            if(myIds.RecordTypeId == RECTYPERECLAMACION){
                tipoCaso = 'SAC_Reclamacion';
            }else if(myIds.RecordTypeId == RECTYPECONSULTACOPS){
                tipoCaso = 'SAC_Consulta';
            }
        }
        updateIds = updateIds.removeEnd(','); 
    }   
}