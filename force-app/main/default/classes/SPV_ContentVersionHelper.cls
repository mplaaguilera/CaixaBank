public with sharing class SPV_ContentVersionHelper {

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEACCIONMAESTRO = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();


    public static List<ContentVersion> filtrarRTSPV(List<ContentVersion> listNewObj, Map<Id, Case> mapCase) {

        Schema.SObjectType expectedCase = Schema.Case.getSObjectType();
        Set<Id> setIdRec = new Set<Id>();
        List<ContentVersion> listCVSPV = new List<ContentVersion>();
        Set<Id> setId = new Set<Id>();

        for (ContentVersion cv : listNewObj) {

            if(String.isNotBlank(cv.FirstPublishLocationId) && cv.FirstPublishLocationId != null){
                Schema.SObjectType tipoObjeto = cv.FirstPublishLocationId.getsobjecttype();

                if(tipoObjeto == expectedCase){
                    setIdRec.add(cv.FirstPublishLocationId);  
                } 
            }
        }

        if(!setIdRec.isEmpty()){
            //Busco si existen reclamaciones de SPV que estén en el setIdRegistro
            List<Case> listCaseSPV = [SELECT Id, RecordTypeId, OwnerId, CaseNumber, SAC_GrupoLetrado__c, SAC_GrupoLetrado__r.SAC_Email__c, SAC_PretensionPrincipal__r.OwnerId, SEG_Grupo__c, SEG_Grupo__r.SAC_Email__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACIONSPV OR RecordTypeId = :RECTYPEPRETENSION) AND Id IN :setIdRec];

            if(!listCaseSPV.isEmpty()){
                for(Case rec : listCaseSPV){
                    mapCase.put(rec.Id, rec);
                    setId.add(rec.Id);
                }
                if(!setId.isEmpty()){
                    for (ContentVersion cv : listNewObj) {
                        if(setId.contains(cv.FirstPublishLocationId)){
                            listCVSPV.add(cv);  
                        } 
                    }
                }
            }
        }

        return listCVSPV;
    }

    public static void alertaNuevaDocuReclamacion(List<ContentVersion> listNewObj, Map<Id, Case> mapaReclamaciones) {

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        Group colaPteAsignarSPV = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

        for(ContentVersion cv : listNewObj){

            //Si el owner del contentVersion es diferente al gestor/letrado de la reclamación debemos mandar una alerta
            if(mapaReclamaciones.containsKey(cv.FirstPublishLocationId) && mapaReclamaciones.get(cv.FirstPublishLocationId).OwnerId != cv.CreatedById && mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_PretensionPrincipal__r.OwnerId != cv.CreatedById){

                //Si tiene pretensiones informadas
                if(mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_PretensionPrincipal__c != null){

                    //Se envia alerta al letrado, si esta pte de asignar se envía al grupo letrado
                    if(mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_PretensionPrincipal__r.OwnerId != colaPteAsignarSPV.Id){

                        SAC_WrapperAlerta wrapAlerta = generarRegistroAlerta(mapaReclamaciones.get(cv.FirstPublishLocationId).Id, mapaReclamaciones.get(cv.FirstPublishLocationId).CaseNumber, mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_PretensionPrincipal__r.OwnerId, null, '');

                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }else{
                        List<String> listaEmails = new List<String>();
                        if(mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_GrupoLetrado__r.SAC_Email__c != null) {
                            listaEmails.add(mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_GrupoLetrado__r.SAC_Email__c);
                        }

                        SAC_WrapperAlerta wrapAlerta = generarRegistroAlerta(mapaReclamaciones.get(cv.FirstPublishLocationId).Id, mapaReclamaciones.get(cv.FirstPublishLocationId).CaseNumber, mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_PretensionPrincipal__r.OwnerId, listaEmails, mapaReclamaciones.get(cv.FirstPublishLocationId).SAC_GrupoLetrado__c);
                        
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                }else{ //Si no tiene pretensiones
                    //Se envia alerta al gestor, si esta pte de asignar se envía al grupo gestor
                    if(mapaReclamaciones.get(cv.FirstPublishLocationId).OwnerId != colaPteAsignarSPV.Id){

                        SAC_WrapperAlerta wrapAlerta = generarRegistroAlerta(mapaReclamaciones.get(cv.FirstPublishLocationId).Id, mapaReclamaciones.get(cv.FirstPublishLocationId).CaseNumber, mapaReclamaciones.get(cv.FirstPublishLocationId).OwnerId, null, '');

                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }else{
                        List<String> listaEmails = new List<String>();
                        if(mapaReclamaciones.get(cv.FirstPublishLocationId).SEG_Grupo__r.SAC_Email__c != null) {
                            listaEmails.add(mapaReclamaciones.get(cv.FirstPublishLocationId).SEG_Grupo__r.SAC_Email__c);
                        }

                        SAC_WrapperAlerta wrapAlerta = generarRegistroAlerta(mapaReclamaciones.get(cv.FirstPublishLocationId).Id, mapaReclamaciones.get(cv.FirstPublishLocationId).CaseNumber, mapaReclamaciones.get(cv.FirstPublishLocationId).OwnerId, listaEmails, mapaReclamaciones.get(cv.FirstPublishLocationId).SEG_Grupo__c);
                        
                        //Añadirla a la lista para posteriormente llamar al método
                        listaWrapperAlerta.add(wrapAlerta);
                    }
                }
            }                
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    public static SAC_WrapperAlerta generarRegistroAlerta(String caseId, String caseNumber, String ownerId, List<String> listaEmailsEnviar, String idGrupo) {

        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caseId,
                                                    'SPV_017',
                                                    'Se ha añadido documentación complementaria en la reclamación ' + caseNumber + '. Debe volver a revisarla.',
                                                    ownerId,
                                                    '',
                                                    '', 
                                                    '');
                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caseId;
                                                    wrapAlerta.proyecto = 'SPV';

        if(listaEmailsEnviar != null){
            wrapAlerta.listaEmailsGrupo = listaEmailsEnviar;
        }

        if(String.isNotBlank(idGrupo)){
            wrapAlerta.idGrupoColaborador = idGrupo;
        }
                                                    
        return wrapAlerta;
    }
}