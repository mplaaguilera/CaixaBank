/*****************************************************************
 * Name: SPV_QueueableSendCVToEER
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Enviar los documentos cargados en Salesforce hacia EER
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0                             Esperanza Conde  15/10/2024   Creación
*****************************************************************/

public with sharing class SPV_QueueableSendCVToEER implements Queueable  {

    private static final String BRACKET_LEFT        = '(';
    private static final String BRACKET_RIGHT       = ') ';
    private static final String BRACKET_RIGHT_ERROR = ') Error: ';

    List<ContentVersion> lstCV;

    public SPV_QueueableSendCVToEER(List<ContentVersion> lstCVInsert) {
        lstCV = lstCVInsert;
    }

    public void execute(QueueableContext context) {
       
        String methodName = 'execute';
        List<ContentVersion> lstCVUpdate = new List<ContentVersion>();

        if(!lstCV.isEmpty()){
            for(ContentVersion contVersion : lstCV){
                //Enviar a EER
                SPV_Documentos_Integration_EER.PostDocumentoResponse response = SPV_Documentos_Integration_EER.postDocument(contVersion.FirstPublishLocationId, contVersion);
                //Recuperar el ticketEER y actualizar contentVersion
                if(response != null && (response.statusCode.equalsIgnoreCase('200') || response.statusCode.equalsIgnoreCase('201'))
                && response.documentoDetail != null && response.documentoDetail.metadata != null && response.documentoDetail.metadata.documentId != null){
                    contVersion.SAC_IdEER__c = String.valueOf(response.documentoDetail.metadata.documentId);
                    lstCVUpdate.add(contVersion);
                }
            }
        }
        

        if(!lstCVUpdate.isEmpty()){
            SPV_DatabaseDML.updateListDML(lstCVUpdate, false);
        }
        

    }

}