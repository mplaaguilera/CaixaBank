public class CC_MCC_Knowledge_Actualizar {
    
    @InvocableMethod
    public static void actualizarMCCKnowledge(List<EstadoKnowledge> input) {
         Map<Id, KnowledgeArticleVersion> articulosVersion = new Map<Id, KnowledgeArticleVersion>();
         articulosVersion = obtenerArticulos(input);
         List<Id> idVersionArticulos = new List <Id>();
         for (KnowledgeArticleVersion versionArticulo : articulosVersion.values()){
             idVersionArticulos.add(versionArticulo.KnowledgeArticleId);
         }
         obtenerMCCKnowledge(articulosVersion.keySet());
    }
    
    public static void obtenerMCCKnowledge (Set<Id> idVersionArticulos){
        //Obtener todos los artículo con su Id y sus código externos
        Map <Id, Knowledge__kav> articulos = new Map <Id, Knowledge__kav>([SELECT Id, ArticleNumber, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                                                                            FROM Knowledge__kav WHERE Id IN :idVersionArticulos]);
        //Obtener todos los ArticleNumber y obtener los código externos para obtener los mccs
        Map<Id, String> articleNumber = new Map<Id, String>();
        Map<String, Id> numberArticle = new Map<String, Id>();

        List<String> codigosExternos = new List <String>();
        Map<String, List<String>> artNumberCExternos = new Map<String, List<String>>();
        for (Id i : articulos.keySet()){
            List<String> codigosExternosArticulo = new List <String>();

            articleNumber.put(i, articulos.get(i).ArticleNumber);
            numberArticle.put(articulos.get(i).ArticleNumber,i);
            if (articulos.get(i).CBK_Codigo_Externo_Tematica__c != null){
                codigosExternos.addAll(articulos.get(i).CBK_Codigo_Externo_Tematica__c.split(' -'));
                codigosExternosArticulo.addAll(articulos.get(i).CBK_Codigo_Externo_Tematica__c.split(' -'));

            }
            if (articulos.get(i).CBK_Codigo_Externo_Causa__c != null){
                codigosExternos.addAll(articulos.get(i).CBK_Codigo_Externo_Causa__c.split(' -'));
                codigosExternosArticulo.addAll(articulos.get(i).CBK_Codigo_Externo_Causa__c.split(' -'));
            }
            if (articulos.get(i).CBK_Codigo_Externo_Motivo__c != null){
                codigosExternos.addAll(articulos.get(i).CBK_Codigo_Externo_Motivo__c.split(' -'));
                codigosExternosArticulo.addAll(articulos.get(i).CBK_Codigo_Externo_Motivo__c.split(' -'));
            }
            if (articulos.get(i).CBK_Codigo_Externo_Producto__c != null){
                codigosExternos.addAll(articulos.get(i).CBK_Codigo_Externo_Producto__c.split(' -'));
                codigosExternosArticulo.addAll(articulos.get(i).CBK_Codigo_Externo_Producto__c.split(' -'));  
            }
            artNumberCExternos.put(articulos.get(i).ArticleNumber, codigosExternosArticulo);
        }

        //si hay mccs vinculados
        if (codigosExternos != null){
            //Obtener los mccs
            Map<String, Id> mccCodigoExterno = new Map<String, Id>();
            Map<Id, CC_MCC__c> mccs = new Map<Id, CC_MCC__c>([SELECT Id, CC_Codigo_Externo__c FROM CC_MCC__c WHERE CC_Codigo_Externo__c IN :codigosExternos]);


            List <Id> idMccs = new List<Id>();
            for (Id i : mccs.keySet()){
                idMccs.add(i);
                mccCodigoExterno.put(mccs.get(i).CC_Codigo_Externo__c, i);
            }

            //A partir del Id de los mccs obtener los mccKnowledge
            Map <Id, CBK_MCC_Knowledge__c> mccKnowledges = new Map <Id, CBK_MCC_Knowledge__c>([SELECT Id, CBK_Knowledge__c, CBK_MCC__c, Name FROM CBK_MCC_Knowledge__c WHERE CBK_MCC__c IN :idMccs]);        
            Map <Id, Id> idKnowIdart = new Map <Id, Id>();
            List <Id> idArticulosKnowledge = new List <Id>();
            
            for (CBK_MCC_Knowledge__c i : mccKnowledges.values()){
                idKnowIdart.put(i.CBK_MCC__c,i.Id);
                idArticulosKnowledge.add(i.CBK_Knowledge__c);
            }

            Map <Id, Knowledge__kav> articulosMCC = new Map <Id, Knowledge__kav>([SELECT Id, ArticleNumber FROM Knowledge__kav WHERE Id IN :idArticulosKnowledge]);
            Map <String, Id> articulosArticleNumber = new Map<String, Id>();
            for (Id i : articulosMCC.keySet()){
                articulosArticleNumber.put(articulosMCC.get(i).ArticleNumber, i);
            }
            
            List<CBK_MCC_Knowledge__c> mccKnowlesgeActualizar = new  List<CBK_MCC_Knowledge__c>();
            for (String article :articulosArticleNumber.keySet()){
                Id idArticuloNuevo = numberArticle.get(article);
                    if (idArticuloNuevo != null){
                    List<String> codigos = artNumberCExternos.get(article); 
                    for (String i : codigos){
                        Id mccKnowledge = idKnowIdart.get(mccCodigoExterno.get(i));
                        CBK_MCC_Knowledge__c aux = mccKnowledges.get(mccKnowledge);
                        aux.CBK_Knowledge__c = idArticuloNuevo;
                        mccKnowlesgeActualizar.add(aux);
                    }
                }
            }
            update mccKnowlesgeActualizar;
            
        }

    }

    public static Map<Id, KnowledgeArticleVersion> obtenerArticulos(List<EstadoKnowledge> input) {
        List<Id> idArticulos = new List<Id>();
        for (EstadoKnowledge estadoArticulo : input) {
            idArticulos.add(estadoArticulo.idArticulo);
        }
        return new Map<Id, KnowledgeArticleVersion>(
            [SELECT Id, KnowledgeArticleId, PublishStatus
             FROM KnowledgeArticleVersion WHERE Id IN :idArticulos]
        );
    }
    
    public class EstadoKnowledge {      
        @InvocableVariable(required=true)
        public Id idArticulo;
        
        @InvocableVariable(required=true)
        public String estadoArticulo;
    }

}