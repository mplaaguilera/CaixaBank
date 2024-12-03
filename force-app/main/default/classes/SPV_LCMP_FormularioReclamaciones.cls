public with sharing class SPV_LCMP_FormularioReclamaciones {
    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c', 'Case','SPV_Formulario__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_Formulario').getRecordTypeId();


    /*****************************************************************************
    * Proposito: Comprueba si hay algún formulario en la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US926182     Sergio Martín   18/06/24        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getFormularioExistente(String casoId) {
        if(Schema.sObjectType.SPV_Formulario__c.isAccessible()) {
            List<SPV_Formulario__c> listaFormularios = [SELECT Id FROM SPV_Formulario__c WHERE RecordTypeId = :RECTYPEFORMULARIO AND SPV_Caso__c = :casoId];
            if (!listaFormularios.isEmpty()) {
                return listaFormularios[0].id;
            }
        }
        return null;
    }


    /*********************************************************************************
    * Proposito: Recupera los campos deseados de las pretensiones de la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US926182     Sergio Martín   19/06/24        Creación
    ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensionesReclamacion(String casoId) {
        List<Case> listaPretensiones = new List<Case>();
        if(Schema.sObjectType.Case.isAccessible()) {
            listaPretensiones = [SELECT Id, CaseNumber, Subject, SPV_CriterioBDEMateriaFuente__c, SPV_DecisionAlegaciones__c, SPV_ObservacionesDecisionAlegaciones__c, SPV_DecisionAllanamiento__c, SPV_Documentacion__c FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :casoId];
        }
        return listaPretensiones;
    }


    /*************************************************************************
    * Proposito: Notificar al propietario del escalado que se ha modificado 
    *            el formulario e la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US929908     Sergio Martín   20/06/24        Creación
    * 1.1               ---         Raúl Santos    02/10/24        Modificación: Enviar alerta al owner si esta asignado, o al grupo si el owner es pte asignar
    *************************************************************************/
    @AuraEnabled
    public static void notificarCambioFicha(String casoId, String caseNumber) {

        if(Schema.sObjectType.SAC_Interaccion__c.isAccessible()) {
            List<SAC_Interaccion__c> listaEscalados = [SELECT Id, Name, SAC_CasoEscalado__c, OwnerId, SAC_Estado__c, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_Email__c, SAC_GrupoColaborador__r.SAC_Email2__c, SAC_GrupoColaborador__r.SAC_Email3__c
                                                         FROM SAC_Interaccion__c WHERE RecordTypeId = :RECTYPEESCALADO AND SAC_CasoEscalado__c = :casoId AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SPV_PendienteEnviar') ORDER BY CreatedDate DESC LIMIT 1];

            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

            if(!cola.isEmpty() && !listaEscalados.isEmpty()){
                for(SAC_Interaccion__c escalado : listaEscalados) {

                    //Preparar una alerta
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(escalado.SAC_CasoEscalado__c,
                                                                        'SPV_018',
                                                                        'La ficha de la reclamación ' + caseNumber + ' ha sido modificada, por favor revise antes de continuar con la resolución del escalado ' + escalado.Name,
                                                                        escalado.OwnerId,
                                                                        '',
                                                                        '',
                                                                        escalado.Id);
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + escalado.Id;
                                                                        wrapAlerta.idGrupoColaborador = escalado.SAC_GrupoColaborador__c;
                                                                        wrapAlerta.proyecto = 'SPV';

                    //Alerta al grupo si esta pte asignar
                    if(escalado.OwnerId == cola[0].Id) {
                        List<String> listaEmails = new List<String>();  

                        if (escalado.SAC_GrupoColaborador__r.SAC_Email__c != null) {
                            listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email__c);
                        }
                        if (escalado.SAC_GrupoColaborador__r.SAC_Email2__c != null) {
                            listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email2__c);
                        }
                        if (escalado.SAC_GrupoColaborador__r.SAC_Email3__c != null) {
                            listaEmails.add(escalado.SAC_GrupoColaborador__r.SAC_Email3__c);
                        }
                                                                                                
                        wrapAlerta.listaEmailsGrupo = listaEmails;    
                    }

                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
            }

            //Si tenemos alertas que enviar, se llama al método que las envía
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
        }
    }
}