public with sharing class SPV_LCMP_CamposNegociacion {
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();


    /*******************************************************************************
     * Proposito: Recuperar las pretensiones del caso que están en negociación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     18/07/24        Creación
    *******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensiones(String casoId){
        List<Case> pretensionesCaso = new List<Case>();
        List<Case> pretensionesMostrar = new List<Case>();

        try {
            pretensionesCaso = [SELECT Id, Status, CaseNumber, SAC_CasoNegociado__c, SAC_ResultadoNegociacion__c, SAC_Reclamacion__r.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, CC_MCC_Tematica__r.name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.name, SEG_Detalle__r.Name, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, CBK_Case_Extension_Id__c FROM Case 
                                WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: casoId];

            for(Case pretension : pretensionesCaso) {
                // Se muestran las pretensiones que están en negociación en caso de que la reclamación esté en negociación
                if((pretension.SAC_Reclamacion__r.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c == true && pretension.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c == true)) {
                    pretensionesMostrar.add(pretension);
                }
                // Se muestran las pretensiones que se han negociado en caso de que la reclamación NO esté en negociación
                if((pretension.SAC_Reclamacion__r.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c == false && pretension.SAC_CasoNegociado__c == true && pretension.SAC_ResultadoNegociacion__c != null)) {
                    pretensionesMostrar.add(pretension);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return pretensionesMostrar;
    }


    /*******************************************************************************
     * Proposito: Recuperar las pretensiones del caso que NO están en negociación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     18/07/24        Creación
    *******************************************************************************/
    @AuraEnabled
    public static List<Case> addPretensionesNegociacionReclamacion(String idCaso){
        List<Case> pretensionesCaso = new List<Case>();
        try {
            pretensionesCaso = [SELECT Id, CC_MCC_Tematica__r.name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.name, SEG_Detalle__r.Name, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c FROM Case 
                                WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: idCaso AND (Status != 'SAC_009' AND Status != 'Cerrado') AND CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c = false];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return pretensionesCaso;
    }


    /*************************************************************************************************
     * Proposito: Marcar a true el campo SPV_CasoEnNegociacion__c para indicar que las pretensiones añadidas
     *               está en una negociación activa
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US1126342     Sergio Martín     18/02/25        Creación
    *************************************************************************************************/
    @AuraEnabled
    static public void activarNegociacionPretension(Id caseId, List<Case> pretensionesNegociacion) {
        List<CBK_Case_Extension__c> listaCasosExtensionUpdatear = new List<CBK_Case_Extension__c>();
        List<Case> listaCasosUpdatear = new List<Case>();
        List<Case> listaPretensiones = [SELECT Id, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c, SAC_CasoNegociado__c, 
                                        SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c, SAC_Motivoresultadonegociacion__c, SAC_Observaciones__c, SAC_NegociacionFinalizada__c
                                    FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND Id IN: pretensionesNegociacion];

        if(!listaPretensiones.isEmpty() && caseId != null) {
            for(Case pretension : listaPretensiones){
                CBK_Case_Extension__c caseExtensionPretensiones = new CBK_Case_Extension__c();
                caseExtensionPretensiones.id = pretension.CBK_Case_Extension_Id__c;
                caseExtensionPretensiones.SPV_CasoEnNegociacion__c = true;
                listaCasosExtensionUpdatear.add(caseExtensionPretensiones);

                // Si es la primera negociación de la reclamación o de alguna de las pretensiones se debe marcar el campo SAC_CasoNegociado__c a true
                if(pretension.SAC_CasoNegociado__c == false) {
                    pretension.SAC_CasoNegociado__c = true;
                    listaCasosUpdatear.add(pretension);
                } else { // Vaciar los campos de la negociación de las pretensiones para poder realizar otra nueva
                    pretension.SAC_ResultadoNegociacion__c = null;
                    pretension.SAC_Motivoresultadonegociacion__c = null;
                    pretension.SAC_Observaciones__c = null;
                    listaCasosUpdatear.add(pretension);
                }
            }
            if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
                SPV_DatabaseDML.updateListDML(listaCasosExtensionUpdatear, true); 
            }else{
                throw new AuraHandledException('No tienes permisos para realizar la operación.');
            }
            
            if(!listaCasosUpdatear.isEmpty()) {
                if(Schema.sObjectType.Case.isUpdateable()){  
                    SPV_DatabaseDML.updateListDML(listaCasosUpdatear, true); 
                }else{
                    throw new AuraHandledException('No tienes permisos para realizar la operación.');
                } 
            }
        }
    }


     /*************************************************************************************************
     * Proposito: Marcar a false el campo SPV_CasoEnNegociacion__c para indicar que la pretensión ha
     *               sido eliminada de la negociación en curso
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US1126342     Sergio Martín     18/02/25        Creación
    *************************************************************************************************/
    @AuraEnabled
    static public void eliminarPretensionNegociacion(Id caseId) {
        // Marcar el campo SPV_CasoEnNegociacion__c de la pretensión a false        
        CBK_Case_Extension__c caseExtensionPretension = [SELECT id FROM CBK_Case_Extension__c WHERE Case_Id__c =: caseId LIMIT 1];
        caseExtensionPretension.SPV_CasoEnNegociacion__c = false;

        // Vaciar los campos de negociación de la pretensión eliminada
        Case pretensionEliminada = new Case();
        pretensionEliminada.Id = caseId;
        pretensionEliminada.SAC_ResultadoNegociacion__c = null;
        pretensionEliminada.SAC_Motivoresultadonegociacion__c = null;
        pretensionEliminada.SAC_Observaciones__c = null;

        if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){  
            SPV_DatabaseDML.updateDML(caseExtensionPretension, false); 
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la operación.');
        }

        if(Schema.sObjectType.Case.isUpdateable()){  
            SPV_DatabaseDML.updateDML(pretensionEliminada, false); 
        }else{
            throw new AuraHandledException('No tienes permisos para realizar la operación.');
        }
    }
}