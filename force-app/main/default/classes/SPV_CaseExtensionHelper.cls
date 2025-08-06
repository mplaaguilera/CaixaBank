/*****************************************************************
 * Name: SPV_CaseExtensionHelper
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Operaciones con el objeto Case Extension en SPV
 * Las clases test que ejecutan esta clase: SPV_CaseExtensionHelper_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                            Álex Polo       16/12/2024   Creación
*****************************************************************/
/**
*   @description SPV_CaseExtensionHelper
*/
public with sharing class SPV_CaseExtensionHelper {

    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Record Type de Case Extension para SPV
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();

    static final Map<String, String> FIELD_LABELS = new Map<String, String>{
        
        'SPV_MotivoProrroga__c' => 'Motivo prórroga',
            'SPV_ObservacionesProrroga__c' => 'Observaciones de prórroga',
            'SPV_MotivoAnulacionProrroga__c' => 'Motivo anulación de prórroga',
            'SPV_ObservacionesAnulacionProrroga__c' => 'Observaciones anulación prórroga',
            'SPV_CasoRelacionadoSPV__c' => 'Caso relacionado SPV',
            'SPV_MotivoDevolucionEnvio__c' => 'Motivo devolución envío',
            'SPV_ObservacionesDevolucionLetradoEnvio__c' => 'Observaciones devolución letrado envío',
            'SPV_MotivoDevolucionComplementaria__c' => 'Motivo devolución complementaria',
            'SPV_ObservacionDevolucionComplementarias__c' => 'Observación devolución complementarias',
            'SPV_MotivoDevolucionRectificacion__c' => 'Motivo devolución rectificación',
            'SPV_ObservacionDevolucionRectificacion__c' => 'Observación devolución rectificación',
            'SPV_GrupoAltas__c' => 'Grupo alta',
            'SPV_FechaEnvioEntidad__c' => 'Fecha envío entidad',
            'SPV_FechaEnvioEntidadOrganismo__c' => 'Fecha envío entidad organismo',
            'SPV_FechaPteRespuestaOrganismo__c' => 'Fecha pendiente respuesta organismo',
            'SPV_FechaEnvioOrganismoRectificacion__c' => 'Fecha envío organismo (rectificación)',
            'SPV_FechaRevisionEnvio__c' => 'Fecha revisión envío',
            'SPV_FechaEnvioComplementaria__c' => 'Fecha envío complementaria'
            };
        
    public static List<CBK_Case_Extension__c> filtrarCasosSPV(List<CBK_Case_Extension__c> listCasosExt){

        List<CBK_Case_Extension__c> listaCaseExtension = new List<CBK_Case_Extension__c>();

        for(CBK_Case_Extension__c casoExt : listCasosExt){
            if(casoExt.RecordTypeId == RECTYPERECLAMACIONEXTENSION){
                listaCaseExtension.add(casoExt);
            }
        }

        return listaCaseExtension;
    }

		/************************************************************************************************************
     * Proposito:  Al actualizar alguno de los campos de la reclamación, se deben registrar en actividades
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                                  Iria ANPC            02/05/2025               Creación
     * *********************************************************************************************************/
    /**
	 * @description    Al actualizar alguno de los campos de la reclamación, se deben registrar en actividades
	 * @param listaReclaSPV
     * @param mapOldObj
	 */
    public static void registrarCamposActividades(List<CBK_Case_Extension__c> listaReclaSPV, Map<Id, CBK_Case_Extension__c> mapOldObj){
        List<FeedItem> feedItemToInsert = new List<FeedItem>();
        for(CBK_Case_Extension__c recla : listaReclaSPV){
            //Si ha cambiado alguno de estos campos de la reclamación
            if (mapOldObj.containsKey(recla.Id)) {
                
                if (recla.SPV_MotivoProrroga__c != mapOldObj.get(recla.Id).SPV_MotivoProrroga__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_MotivoProrroga__c', String.valueOf(recla.SPV_MotivoProrroga__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_ObservacionesProrroga__c != mapOldObj.get(recla.Id).SPV_ObservacionesProrroga__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_ObservacionesProrroga__c', String.valueOf(recla.SPV_ObservacionesProrroga__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_MotivoAnulacionProrroga__c != mapOldObj.get(recla.Id).SPV_MotivoAnulacionProrroga__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_MotivoAnulacionProrroga__c', String.valueOf(recla.SPV_MotivoAnulacionProrroga__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_ObservacionesAnulacionProrroga__c != mapOldObj.get(recla.Id).SPV_ObservacionesAnulacionProrroga__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_ObservacionesAnulacionProrroga__c', String.valueOf(recla.SPV_ObservacionesAnulacionProrroga__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_CasoRelacionadoSPV__c != mapOldObj.get(recla.Id).SPV_CasoRelacionadoSPV__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_CasoRelacionadoSPV__c', String.valueOf(recla.SPV_CasoRelacionadoSPV__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_MotivoDevolucionEnvio__c != mapOldObj.get(recla.Id).SPV_MotivoDevolucionEnvio__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_MotivoDevolucionEnvio__c', String.valueOf(recla.SPV_MotivoDevolucionEnvio__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_ObservacionesDevolucionLetradoEnvio__c != mapOldObj.get(recla.Id).SPV_ObservacionesDevolucionLetradoEnvio__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_ObservacionesDevolucionLetradoEnvio__c', String.valueOf(recla.SPV_ObservacionesDevolucionLetradoEnvio__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_MotivoDevolucionComplementaria__c != mapOldObj.get(recla.Id).SPV_MotivoDevolucionComplementaria__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_MotivoDevolucionComplementaria__c', String.valueOf(recla.SPV_MotivoDevolucionComplementaria__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_ObservacionDevolucionComplementarias__c != mapOldObj.get(recla.Id).SPV_ObservacionDevolucionComplementarias__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_ObservacionDevolucionComplementarias__c', String.valueOf(recla.SPV_ObservacionDevolucionComplementarias__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_MotivoDevolucionRectificacion__c != mapOldObj.get(recla.Id).SPV_MotivoDevolucionRectificacion__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_MotivoDevolucionRectificacion__c', String.valueOf(recla.SPV_MotivoDevolucionRectificacion__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_ObservacionDevolucionRectificacion__c != mapOldObj.get(recla.Id).SPV_ObservacionDevolucionRectificacion__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_ObservacionDevolucionRectificacion__c', String.valueOf(recla.SPV_ObservacionDevolucionRectificacion__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_GrupoAltas__c != mapOldObj.get(recla.Id).SPV_GrupoAltas__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_GrupoAltas__c', String.valueOf(recla.SPV_GrupoAltas__c));
                    feedItemToInsert.add(actividad);
                }
                /*if (recla.SPV_MotivoComplementariaEntidad__c != mapOldObj.get(recla.Id).SPV_MotivoComplementariaEntidad__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_MotivoComplementariaEntidad__c', String.valueOf(recla.SPV_MotivoComplementariaEntidad__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_FechaEnvioEntidad__c != mapOldObj.get(recla.Id).SPV_FechaEnvioEntidad__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_FechaEnvioEntidad__c', String.valueOf(recla.SPV_FechaEnvioEntidad__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_FechaEnvioEntidadOrganismo__c != mapOldObj.get(recla.Id).SPV_FechaEnvioEntidadOrganismo__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_FechaEnvioEntidadOrganismo__c', String.valueOf(recla.SPV_FechaEnvioEntidadOrganismo__c));
                    feedItemToInsert.add(actividad);
                }*/
                if (recla.SPV_FechaEnvioOrganismoRectificacion__c != mapOldObj.get(recla.Id).SPV_FechaEnvioOrganismoRectificacion__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_FechaEnvioOrganismoRectificacion__c', String.valueOf(recla.SPV_FechaEnvioOrganismoRectificacion__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_FechaPteRespuestaOrganismo__c  != mapOldObj.get(recla.Id).SPV_FechaPteRespuestaOrganismo__c ) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_FechaPteRespuestaOrganismo__c', String.valueOf(recla.SPV_FechaPteRespuestaOrganismo__c ));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_FechaRevisionEnvio__c != mapOldObj.get(recla.Id).SPV_FechaRevisionEnvio__c) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_FechaRevisionEnvio__c', String.valueOf(recla.SPV_FechaRevisionEnvio__c));
                    feedItemToInsert.add(actividad);
                }
                if (recla.SPV_FechaEnvioComplementaria__c  != mapOldObj.get(recla.Id).SPV_FechaEnvioComplementaria__c ) {
                    FeedItem actividad = crearActividades(recla.Case_Id__c, 'SPV_FechaEnvioComplementaria__c', String.valueOf(recla.SPV_FechaEnvioComplementaria__c ));
                    feedItemToInsert.add(actividad);
                }
            }
        }
        if(!feedItemToInsert.isEmpty()){
            insert feedItemToInsert;
        }
    }
    
	/************************************************************************************************************
     * Proposito:  Crear actividad relacionada con el caso
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                                  Iria ANPC            02/05/2025               Creación
     * *********************************************************************************************************/
    /**
	 * @description    Crear actividad relacionada con el caso
	 * @param caseId
     * @param fieldName
     * @param value
	 */
    public static FeedItem crearActividades(Id caseId, String fieldName, String value){
        String fieldLabel = FIELD_LABELS.containsKey(fieldName) ? FIELD_LABELS.get(fieldName) : fieldName;
		
        // Obtener label si es un campo picklist
        if (isPicklistField('CBK_Case_Extension__c', fieldName)) {
            value = getPicklistLabel('CBK_Case_Extension__c', fieldName, value);
        }
        
        FeedItem feed = new FeedItem();
        feed.ParentId = caseId; 
        feed.Body = fieldLabel + ': ' + value;
        
        return feed;

     }
	
    	/************************************************************************************************************
     * Proposito:  Comprobar si el campo es tipo picklist
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                                  Iria ANPC            02/05/2025               Creación
     * *********************************************************************************************************/
    /**
	 * @description    Comprobar si el campo es tipo picklist
	 * @param sObjectName
     * @param fieldName
	 */
    public static Boolean isPicklistField(String sObjectName, String fieldName) {
        Schema.DescribeSObjectResult describe = CBK_Case_Extension__c.SObjectType.getDescribe();
        Schema.SObjectField field = describe.fields.getMap().get(fieldName);
        return field.getDescribe().getType() == Schema.DisplayType.Picklist;
    }
    
    
    /************************************************************************************************************
     * Proposito:  Obtener label de un campo picklist
     *
     *
     *
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                                  Iria ANPC            02/05/2025               Creación
     * *********************************************************************************************************/
    /**
	 * @description    Obtener label de un campo picklist
	 * @param sObjectName
     * @param fieldName
     * @param apiValue
	 */
    public static String getPicklistLabel(String sObjectName, String fieldName, String apiValue) {
        Schema.DescribeSObjectResult describe = CBK_Case_Extension__c.SObjectType.getDescribe();
        Schema.SObjectField field = describe.fields.getMap().get(fieldName);
        List<Schema.PicklistEntry> values = field.getDescribe().getPicklistValues();
        
        for (Schema.PicklistEntry entry : values) {
            if (entry.getValue() == apiValue) {
                return entry.getLabel();
            }
        }
        return apiValue;
    }

    /*********************************************************************************************************************
     * Proposito: Método para comprobar si hay alertas SLA relacionadas con prórrogas a lanzar y generarlas si es el caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY                AUTHOR                DATE         Description
     * 1.0            US1276839 + US1279552     Jose M. Fernández     26/06/2025   Creación
    **********************************************************************************************************************/
    /**
     * @description  Método para comprobar si hay alertas SLA relacionadas con prórrogas a lanzar y generarlas si es el caso
     * @param listCase
     * @param cola
     */
    public static void comprobarAlertasProrroga(List<CBK_Case_Extension__c> listCase, Group cola){
        //Variables utilizadas para la lógica
        List<SAC_WrapperAlerta> listWrapperAlerta = new List<SAC_WrapperAlerta>();

        //Se recuperan las IDs de los Case
        List<Id> listCaseIDs = new List<Id>();
        for(CBK_Case_Extension__c caso : listCase){
            listCaseIDs.add(caso.Case_Id__c);
        }

        //Se recorren las reclamaciones para generar los WrapperAlerta para lanzar las alertas
        for(Case caso : [SELECT Id, CaseNumber, OwnerId, SEG_Grupo__r.SAC_Email__c
                         FROM Case
                         WHERE Id IN :listCaseIDs])
        {
            //Preparación de la alerta
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso.Id,
                                                                'SPV_ConcesionProrroga',
                                                                'SPV - Se ha anulado la prórroga para el caso ' + caso.CaseNumber,
                                                                caso.OwnerId,
                                                                '',
                                                                '',
                                                                '');
                                                                wrapAlerta.enlaceParaEmail = URL.getOrgDomainUrl().toExternalForm() + '/' + caso.Id;
            if(caso.OwnerId == cola.Id && String.isNotBlank(caso.SEG_Grupo__r.SAC_Email__c)){
                wrapAlerta.listaEmailsGrupo.add(caso.SEG_Grupo__r.SAC_Email__c);
            }

            //Se añade a la lista para posteriormente llamar al método
            listWrapperAlerta.add(wrapAlerta);
        }
            

        //Si hay alertas a enviar, se llama al método que las envía
        if(!listWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listWrapperAlerta);
        }
    }
}