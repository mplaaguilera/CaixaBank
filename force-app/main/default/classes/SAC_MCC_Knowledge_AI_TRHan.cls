public without sharing class SAC_MCC_Knowledge_AI_TRHan extends CC_TriggerHandlerBase{

    private static final Id RECTYPESACPROTOCOLO = Schema.SObjectType.CBK_MCC_Knowledge__c.getRecordTypeInfosByDeveloperName().get('SAC_Protocolo').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_MCC_Knowledge__c>)tp.newList, (Map<Id, CBK_MCC_Knowledge__c>)tp.newMap);
	}

    @TestVisible
    private static void process(List<CBK_MCC_Knowledge__c> listNewObj, Map<Id, CBK_MCC_Knowledge__c> mapNewObj) {
        List<CBK_MCC_Knowledge__c> listNewMccKnowFiltrada = new List<CBK_MCC_Knowledge__c>();

        //Filtrar por record type de SAC
        for (CBK_MCC_Knowledge__c mccKnow : listNewObj) {
            if (mccKnow.RecordTypeId == RECTYPESACPROTOCOLO) {
                listNewMccKnowFiltrada.add(mccKnow);
            }
        }
        
        //Si tenemos registros de SAC, llamamos a los métodos
        if (!listNewMccKnowFiltrada.isEmpty()) {
            addRelacionMCC(listNewMccKnowFiltrada);
        }
	}

    public static void addRelacionMCC(List<CBK_MCC_Knowledge__c> listNewObj){
        Set<Id> relacionesMCC = new Set<Id>();
        Set<Id> relacionesKnowledge = new Set<Id>();
        Map<Id,Id> mapRelacionMCCKnwldg =  new Map<Id,Id>(); //Variable para guardar las relaciones
        Map<Id,CBK_MCC_Knowledge__c> mapCBKMCCKnowledge = new Map<Id,CBK_MCC_Knowledge__c>(); //Variable para obtener el id del mcc con el del CBK_MCC_knowledge
       
        //Guardar las relaciones entre MCC y Knowledge
        for (CBK_MCC_Knowledge__c relacion : listNewObj) {
            relacionesMCC.add(relacion.CBK_MCC__c);    
            relacionesKnowledge.add(relacion.CBK_Knowledge__c);
            mapRelacionMCCKnwldg.put(relacion.CBK_Knowledge__c, relacion.CBK_MCC__c);   
            mapCBKMCCKnowledge.put(relacion.CBK_MCC__c, relacion);               
        }
        
        //Obtener codigos externos de MCC y su clasificacion
        Map<Id, CC_MCC__c> mccs = new Map <Id, CC_MCC__c>([SELECT Id, RecordType.DeveloperName, CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id IN :relacionesMCC]);
        
        //Obtener los registros Knowledge
        //Se obtiene el objetoKnowledgeArticleVersion que tendrá la versión del artículo y sobre el cual tenemos que trabajar
        Map <Id, KnowledgeArticleVersion> mapIdVersionKnowledge = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Id IN :relacionesKnowledge]);
        
        Map <Id, Id> mapRelacionesArticulos = new Map<Id, Id>();
        //Mapa con la relación: ID Artículo con su ID de la versión, el KnowledgeArticleId
        for (Id i : mapIdVersionKnowledge.keySet()){
            mapRelacionesArticulos.put(mapIdVersionKnowledge.get(i).KnowledgeArticleId, i);
        }
        List<KnowledgeArticleVersion> listIdVersionKnowledge = new List<KnowledgeArticleVersion>(mapIdVersionKnowledge.values());
        
        //Mapa con la relación del id del KnowledgeArticle con el MCC que está relacionado
        Map<Id, Id> mccKnowledgeArticle = new Map<Id, Id>();
        for (KnowledgeArticleVersion i : listIdVersionKnowledge){

            mccKnowledgeArticle.put(i.KnowledgeArticleId, mapRelacionMCCKnwldg.get(i.Id));

        }
 
        //Despublicar los artículos para poder modificarlos
        Map<Id,Id> mapDespublicado = new Map<Id, Id>();
        for (Id i : mapIdVersionKnowledge.keySet()){
            
            String recordId = mapIdVersionKnowledge.get(i).KnowledgeArticleId;
            mapDespublicado.putAll(unPublishArticle(recordId));
        }

        //Obtener las nuevas versiones que se han creado al despublicarlos
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                                                                                FROM KnowledgeArticleVersion 
                                                                                                WHERE IsLatestVersion =  true AND Id IN :mapDespublicado.keySet()]);

        List<KnowledgeArticleVersion> obtenidos = new List<KnowledgeArticleVersion> (obtenidoIdQuery.values());
        List<Id> ids = new List<Id>();
        for (KnowledgeArticleVersion i : obtenidos){
            ids.add(i.KnowledgeArticleId);
        }
        //Obtener el articulo nuevo que se ha creado y que será el que se modificará
        List<Knowledge__kav> newArticle = new List<Knowledge__kav>([SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                                                                    FROM Knowledge__kav WHERE KnowledgeArticleId IN :ids]);

        Map<Id, Id> viejoNuevoArticulo = new Map<Id,Id>();
        Map<Id, Integer> errorArticulos = new Map<Id, Integer>();
        //Obtener mcc relacionado
        for (Knowledge__kav i : newArticle){
            viejoNuevoArticulo.put(mapRelacionesArticulos.get(mapDespublicado.get(i.Id)), i.Id);
            Id idMapDespublicado = mapDespublicado.get(i.Id);
            Id idMccRelacionado = mccKnowledgeArticle.get(idMapDespublicado);
            CC_MCC__c mccRelacionado = mccs.get(idMccRelacionado);
            errorArticulos.putAll(updateArticle(mccRelacionado, i, idMapDespublicado));
        }

        //Para cada elemento que tiene un error (1) lanza un error como que ya se ha añadido previamente
        for (Id i : errorArticulos.keySet()){
            CBK_MCC_Knowledge__c cbkMCC = new CBK_MCC_Knowledge__c();
            cbkMCC =mapCBKMCCKnowledge.get(mccKnowledgeArticle.get(i));
            Integer posicion = listNewObj.indexOf(cbkMCC);
            if (errorArticulos.get(i) == 1){
                listNewObj[posicion].addError('Este artículo ya ha sido añadido previamente');     
            }
        }

        //Actualizar todos los mcc_Knowledge a los que estaba linkado para que todos tengan la última version
        actualizarMccs(viejoNuevoArticulo);

     }
    
    public static Map <Id, Id> unPublishArticle(String recordId){
        Map<Id,Id> despublicadoIdVersion = new Map<Id,Id>();
        String newArticleId = KbManagement.PublishingService.editOnlineArticle(recordId, true);
        despublicadoIdVersion.put(newArticleId, recordId);
        return despublicadoIdVersion;
     }

     /*Añade en el código externo correspondiente del artículo el código externo del mcc y lo publica.
     Si se está añadiendo un artículo que ya estaba linkado, le asignará en el mapa que se devuelve un 1
     Si todo va correctamente, se le asignará un 0*/
    public static Map<Id,Integer> updateArticle(CC_MCC__c mcc, Knowledge__kav newArticle, String recordId){

        Map<Id, Integer> resultadoArticulo = new Map<Id,Integer>();
        if (mcc.RecordType.DeveloperName == 'CC_Tematica'){
            if (newArticle.CBK_Codigo_Externo_Tematica__c == null){
                newArticle.CBK_Codigo_Externo_Tematica__c = mcc.CC_Codigo_Externo__c  + ' - ' ; 
            }
            else{
                if (newArticle.CBK_Codigo_Externo_Tematica__c.contains(mcc.CC_Codigo_Externo__c)){
                    resultadoArticulo.put(recordId, 1); //El poner un 1 hace que luego nos salte un error ya que ya existe esta relación.
                }
                else{
                    newArticle.CBK_Codigo_Externo_Tematica__c = newArticle.CBK_Codigo_Externo_Tematica__c +mcc.CC_Codigo_Externo__c  + ' - ' ;
                    resultadoArticulo.put(recordId, 0); //El poner un 0 nos indica que todo ha ido bien.
                }
            }

        }else if (mcc.RecordType.DeveloperName == 'CC_Producto_Servicio'){
            if (newArticle.CBK_Codigo_Externo_Producto__c == null){
                newArticle.CBK_Codigo_Externo_Producto__c = mcc.CC_Codigo_Externo__c + ' - ' ; 
            }
            else{
                if (newArticle.CBK_Codigo_Externo_Producto__c.contains(mcc.CC_Codigo_Externo__c)){
                    resultadoArticulo.put(recordId, 1); //El poner un 1 hace que luego nos salte un error ya que ya existe esta relación.
                }
                else{
                    newArticle.CBK_Codigo_Externo_Producto__c = newArticle.CBK_Codigo_Externo_Producto__c +mcc.CC_Codigo_Externo__c  + ' - ' ;
                    resultadoArticulo.put(recordId, 0); //El poner un 0 nos indica que todo ha ido bien.
                }
            }
            
        }else if (mcc.RecordType.DeveloperName == 'CC_Motivo'){
            if (newArticle.CBK_Codigo_Externo_Motivo__c == null){
                newArticle.CBK_Codigo_Externo_Motivo__c = mcc.CC_Codigo_Externo__c  + ' - ' ; 
            }
            else{
                if (newArticle.CBK_Codigo_Externo_Motivo__c.contains(mcc.CC_Codigo_Externo__c)){
                    resultadoArticulo.put(recordId, 1); //El poner un 1 hace que luego nos salte un error ya que ya existe esta relación.
                }
                else{
                    newArticle.CBK_Codigo_Externo_Motivo__c = newArticle.CBK_Codigo_Externo_Motivo__c +mcc.CC_Codigo_Externo__c  + ' - ' ;
                    resultadoArticulo.put(recordId, 0); //El poner un 0 nos indica que todo ha ido bien.
                }
            }
        }else if (mcc.RecordType.DeveloperName == 'SAC_Detalle'){
            if (newArticle.CBK_Codigo_Externo_Causa__c == null){
                newArticle.CBK_Codigo_Externo_Causa__c = mcc.CC_Codigo_Externo__c + ' - ' ; 
            }
            else{
                if (newArticle.CBK_Codigo_Externo_Causa__c.contains(mcc.CC_Codigo_Externo__c)){
                    resultadoArticulo.put(recordId, 1); //El poner un 1 hace que luego nos salte un error ya que ya existe esta relación.
                }
                else{
                    newArticle.CBK_Codigo_Externo_Causa__c = newArticle.CBK_Codigo_Externo_Causa__c +mcc.CC_Codigo_Externo__c  + ' - ' ;
                    resultadoArticulo.put(recordId, 0); //El poner un 0 nos indica que todo ha ido bien.
                }
            }
        }
        update newArticle;
        publishArticle(recordId);
        return resultadoArticulo;

     }

    public static void publishArticle(String recordId){
        KbManagement.PublishingService.publishArticle(recordId, true);
    }

    public static void actualizarMccs(Map<Id, Id> articuloNuevaVersion){
        List<CBK_MCC_Knowledge__c> objetosRelacion = new List<CBK_MCC_Knowledge__c>([SELECT Id, CBK_Knowledge__c, CBK_MCC__c FROM CBK_MCC_Knowledge__c WHERE CBK_Knowledge__c IN :articuloNuevaVersion.keySet()]);
        for (CBK_MCC_Knowledge__c objeto : objetosRelacion){
            objeto.CBK_Knowledge__c = articuloNuevaVersion.get(objeto.CBK_Knowledge__c);
        }

        update objetosRelacion;
 
    }

}