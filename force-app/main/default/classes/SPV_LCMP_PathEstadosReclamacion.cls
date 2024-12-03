public with sharing class SPV_LCMP_PathEstadosReclamacion {
    private static Set<String> objetos = new Set<String>{'Case', 'SPV_Formulario__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPERECTIFICACION = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioRectificacion').getRecordTypeId();



    /***************************************************************** 
     * Proposito: Recuperar las pretensiones del caso 
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US974485     Sergio Martín     18/07/24        Creación
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensiones(String idCaso){
        List<Case> pretensionesCaso = new List<Case>();
        try {
            pretensionesCaso = [SELECT Id, CC_MCC_Tematica__r.name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.name, SEG_Detalle__r.Name FROM Case 
                                WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c =: idCaso AND (Status != 'SAC_009' AND Status != 'Cerrado')];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return pretensionesCaso;
    }


    /*****************************************************************************************************
    * Proposito: Pasar la reclamación y las pretensiones seleccionadas a la fase de negociación
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US974485     Sergio Martín     18/07/24        Creación
    *****************************************************************************************************/ 
    @AuraEnabled
    public static void pasarFaseNegociacion(String idCaso, String estado, List<Case> pretensionesNegociacion){
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular el caso.');
        }
        
        Case reclamacion = new Case();
        reclamacion.Id = idCaso;
        reclamacion.status = estado;
        reclamacion.SEG_Subestado__c = 'Negociacion';

        for(Case pretension : pretensionesNegociacion){
            pretension.Status = 'SAC_007'; 
            pretension.SAC_CasoNegociado__c = true; 
        }
        List<Case> listaCasosUpdatear = new List<Case>();
        listaCasosUpdatear.add(reclamacion);
        listaCasosUpdatear.addAll(pretensionesNegociacion);
        SPV_DatabaseDML.updateListDML(listaCasosUpdatear, false);
    }

    /*****************************************************************************************************
    * Proposito: Pasar la reclamación a estado 'Envio Organismo'
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                ---        Raúl Santos     16/10/24        Creación
    *****************************************************************************************************/ 
    @AuraEnabled
    public static void pasarFaseEnvioOrgRectificacion(String idCaso, String nuevoEstado, String nuevoSubestado){
        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.Case.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular el caso.');
        }
        if(!Schema.sObjectType.SPV_Formulario__c.isAccessible() || !Schema.sObjectType.SPV_Formulario__c.isUpdateable()){
            throw new AuraHandledException('No tienes privilegios para manipular el caso.');
        }

        SPV_Formulario__c rectificacion = [SELECT id, SPV_RectificacionCompletada__c, SPV_FechaRectificacion__c FROM SPV_Formulario__C WHERE RecordTypeId =: RECTYPERECTIFICACION AND SPV_Caso__c =: idCaso AND SPV_RectificacionCompletada__c = false LIMIT 1];
        rectificacion.SPV_RectificacionCompletada__c = true;
        rectificacion.SPV_FechaRectificacion__c =  System.now();
        SPV_DatabaseDML.updateDML(rectificacion, false);

        Case reclamacion = new Case();
        reclamacion.Id = idCaso;
        reclamacion.Status = nuevoEstado;
        reclamacion.SEG_Subestado__c = nuevoSubestado;

        List<Case> listaCasosUpdatear = new List<Case>();
        listaCasosUpdatear.add(reclamacion);
        SPV_DatabaseDML.updateListDML(listaCasosUpdatear, false);
    }
}