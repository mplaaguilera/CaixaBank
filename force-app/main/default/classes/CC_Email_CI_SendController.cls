public with sharing class CC_Email_CI_SendController{
    @AuraEnabled
    public static List<Folder> getCarpetas(String recordId) {
        List<Folder> carpetas = new List<Folder>();
        string carpetaDeveloperName;
        String recordTypeName = [Select Id, RecordType.DeveloperName from CC_Agrupador__c WHERE Id = :recordId LIMIT 1].RecordType.DeveloperName;
        Jerarquia_Carpetas_CI__mdt[] custMeta = [SELECT Carpeta_Raiz__c, Record_Type__c FROM Jerarquia_Carpetas_CI__mdt];
        If(!custMeta.isempty()){
            for (Jerarquia_Carpetas_CI__mdt mdt : custMeta) {
                If(mdt.Record_Type__c ==recordTypeName){
                    carpetaDeveloperName = mdt.Carpeta_Raiz__c;
                }
            }
        }
        
        Id parentId;
        parentId = [SELECT Id FROM Folder WHERE DeveloperName = :carpetaDeveloperName LIMIT 1].Id;

        if (parentId != null){
            for (Folder carpeta : [SELECT Name,DeveloperName FROM Folder WHERE TYPE = 'EmailTemplate' AND ParentId = :parentId]) {
                carpetas.add(carpeta);
            }
        }
        
        return carpetas;
    }
    @AuraEnabled
    public static List<EmailTemplate> getPlantillas(String carpeta) {
        List<EmailTemplate> opcionesPlantilla = new List<EmailTemplate>();

        Id carpetaId = [SELECT Id FROM Folder WHERE DeveloperName = :carpeta LIMIT 1].Id;
        List<EmailTemplate> plantillas = [SELECT Name,DeveloperName FROM EmailTemplate WHERE FolderId = :carpetaId ORDER BY Name ASC];
        if (!plantillas.isEmpty()){
        	for (EmailTemplate plantilla : plantillas) {
            	opcionesPlantilla.add(plantilla);
        	}
        }
        
        return opcionesPlantilla;
    }
    
    @AuraEnabled
    public static void actualizarAgrupador (String idAgrupador, String plantilla) {
                
        EmailTemplate template = new EmailTemplate();
        if (idAgrupador != null && plantilla != null) {
            
            CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);            
            if (plantilla != null) {
                template = [Select Id, HtmlValue, Subject From EmailTemplate where DeveloperName = :plantilla LIMIT 1];
                agrupador.CC_Plantilla_Comunicacion__c = plantilla;
                if (template!=null)
                	agrupador.CC_HTML_CI__c = template.HtmlValue;
                	agrupador.CC_Subject_CI_Interno__c = template.Subject;
            }
            update agrupador;
        }
    }
    
	@AuraEnabled
    public static Map<String, String> buscarColaborador(String agrupadorId) {
                
        Id idGrupoColaborador;
        List <CC_Agrupador__c> agrupadores = [Select Id, CC_CI_Id_GrupoColaborador_Interno__c from CC_Agrupador__c where Id =: agrupadorId LIMIT 1];
        CC_Agrupador__c  agrupador = new CC_Agrupador__c();
        if (!agrupadores.isempty()){	
        	agrupador = agrupadores.get(0);
        	idGrupoColaborador = agrupador.CC_CI_Id_GrupoColaborador_Interno__c;
        }
        
        Map<String, String> idMapContacto = new Map<String, String>();   
        
        //A nivel de grupo colaborador buscar si tiene el email informado, es otra query
        List<CC_Grupo_Colaborador__c> lstOfGrup = [SELECT CC_Cuenta__r.CC_Email__c FROM CC_Grupo_Colaborador__c WHERE Id = :idGrupoColaborador];
        
        if(! lstOfGrup.isEmpty()){
            for (CC_Grupo_Colaborador__c gcol : lstOfGrup) {    
                if (gcol.CC_Cuenta__r.CC_Email__c != null && gcol.CC_Cuenta__r.CC_Email__c != '') {
                    idMapContacto.put(gcol.CC_Cuenta__r.CC_Email__c, 'Para');
                }
            }
        }

        List<CC_Grupo_Colaborador_Contact__c> contactosGrupoColab = [SELECT CC_Para_CC__c,CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador AND (CC_Contacto__c != null OR CC_Usuario__c != null)];

        if(!contactosGrupoColab.isempty()){
            for (CC_Grupo_Colaborador_Contact__c contactoGrupoColab : contactosGrupoColab) {
                idMapContacto.put(contactoGrupoColab.CC_Email__c,contactoGrupoColab.CC_Para_CC__c);
            }
        }

        return idMapContacto;
    }
    

}