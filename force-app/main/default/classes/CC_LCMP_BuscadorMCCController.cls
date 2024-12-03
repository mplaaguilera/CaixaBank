public with sharing class CC_LCMP_BuscadorMCCController {
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c','CC_MCC__c','Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECORDTYPEGRUPOPROV = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoProveedores').getRecordTypeId();
    final static Id RECORDTYPEGRUPOLET = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    final static Id RECORDTYPEGRUPORESPONSABLE = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
    final static Id RECORDTYPETEMATICA = mapRTsObjects.get('CC_MCC__c').get('CC_Tematica').getRecordTypeId();
    final static Id RECORDTYPEPRODSERV = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
    final static Id RECORDTYPEMOTIVO = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();
    final static Id RECORDTYPEDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    final static Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    @AuraEnabled(cacheable=true)
    public static List<SObject> buscarResultados(String searchTerm, String tipoBusqueda, String id, String recordTypeName) {

        List<String> idList = new List<String>();
        List<SObject> listaResultado = new List<sObject>();
        String cadenaBusqueda= '%'+searchTerm+'%';
        
        system.debug('recordTypeName: '+recordTypeName);

        if(String.isNotBlank(id)){
            for (String s : id.split(',')) {
                idList.add(s.trim());
            }
        }
        if (Schema.sObjectType.CC_MCC__c.isAccessible()) {
            if(tipoBusqueda == 'buscadorTematica'){
                listaResultado = [SELECT Id, Name, CC_Detalle__c FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPETEMATICA AND  CC_Activo__c = true AND CC_Tipo_Cliente__c = :recordTypeName AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 50];
            }

            if(tipoBusqueda == 'buscadorProducto'){
                listaResultado = [SELECT Id, Name, CC_Detalle__c FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEPRODSERV AND CC_Activo__c = true AND CC_Tipo_Cliente__c = :recordTypeName AND CC_Tematica__c IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 50]; 
            }

            if(tipoBusqueda == 'buscadorMotivo'){
                listaResultado = [SELECT Id, Name, CC_Detalle__c FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEMOTIVO AND CC_Activo__c = true AND CC_Tipo_Cliente__c = :recordTypeName AND CC_Producto_Servicio__c IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 50]; 
            }

            if(tipoBusqueda == 'buscadorDetalle'){
                listaResultado = [SELECT Id, Name, CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, SEG_Motivo_Formula__c, CC_Detalle__c FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEDETALLE AND CC_Activo__c = true AND CC_Tipo_Cliente__c = :recordTypeName AND CC_Motivo__c IN :idList AND Name LIKE :cadenaBusqueda ORDER BY Name ASC LIMIT 50]; 
            }
        }

        return listaResultado;
    }


     /*********************************************************************************************
     * Proposito: Buscador de grupos colaboradores del detalle seleccionado                                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US750018           Sergio Martín         04/01/24       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static List<CC_MCC_Grupo_Colaborador__c> buscarGruposDetalle(String idDetalle) {
        List<CC_MCC_Grupo_Colaborador__c> listMccGrupos = new List<CC_MCC_Grupo_Colaborador__c>();
        if (Schema.sObjectType.CC_MCC_Grupo_Colaborador__c.isAccessible()) {
            listMccGrupos = [SELECT CC_MCC__c, CC_Grupo_Colaborador__c, Name, CC_Grupo_Colaborador__r.Name
                                FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c = :idDetalle];
        }                                                        
        return listMccGrupos;
    }


    /*********************************************************************************************
     * Proposito: Actualiza el caso al guardar la nueva clasificación desde la pretensión                                       
     * 
     * Historial
     * VERSION        USER_STORY            AUTHOR                DATE        Description
     * 1.0             US750018           Sergio Martín         16/01/24       Creación
     * *******************************************************************************************/
    @AuraEnabled
    public static void actualizarCaso(Id recordId, Id idDetalle) {
        Case caso = new Case();
		//Actividad de retipificación con la clasificación anterior
        if (Schema.sObjectType.Case.isAccessible()) {
		    caso = [SELECT Id, RecordTypeId FROM Case WHERE RecordTypeId =: RECORDTYPEPRETENSION AND Id = :recordId];
        }

        if (caso != null && !String.isBlank(caso.id)){
            //Actualización del caso
            if (Schema.sObjectType.CC_MCC__c.isAccessible()) {
                CC_MCC__c nuevaClasificacion = [SELECT Id, CC_Motivo__r.Id, CC_Motivo__r.CC_Producto_Servicio__r.Id, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id
                                                    FROM CC_MCC__c WHERE RecordTypeId = :RECORDTYPEDETALLE AND Id = :idDetalle];
                caso.CC_MCC_Tematica__c = nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Id;
                caso.CC_MCC_ProdServ__c = nuevaClasificacion.CC_Motivo__r.CC_Producto_Servicio__r.Id;
                caso.CC_MCC_Motivo__c = nuevaClasificacion.CC_Motivo__r.Id;
                caso.SEG_Detalle__c = nuevaClasificacion.Id;
                //Actualizamos la pretensión con la nueva clasificación del MCC
                if (Schema.sObjectType.Case.isUpdateable()){
                    SAC_DatabaseDML.updateDML(caso, false);
                } 
            }
        }
	}
}