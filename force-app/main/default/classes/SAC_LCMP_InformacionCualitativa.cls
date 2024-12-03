/*****************************************************************
 * Name: SAC_LCMP_InformacionCualitativa 

 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controller para el componente SAC_InformacionCualitativa 

 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US313245       Marcela Neira   21/01/22     Creación
*****************************************************************/
public with sharing class SAC_LCMP_InformacionCualitativa {
     /*****************************************************************
     * Proposito: Busca la información incial (Caso y topics asignados) 
     *             y devuelve un Wrapper con la información para que el 
     *             Js la pueda tratar
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   10/12/21     Creación
    *****************************************************************/
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    
    private static final Id RECTYPEINFOCUALITATIVA = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_InformacionCualitativa').getRecordTypeId();

    /*@AuraEnabled(cacheable=true) 
    public static TopicsWrapper cargarDatos(String idUsuario, String idCaso) {

        Case caso= [SELECT id, OwnerId  FROM Case WHERE id =:idCaso limit 1];
        
        Set<Id> idTopics = new Set<Id>();
        Set<String> nombreTopics =new Set<String>();
        List<String> listaTopics = new List<String>();
        List<String> listaTodosTopics = new List<String>();

        //Busco todos los temas dados de Alta en la BD que se pueden utilizar
        List<SAC_MaestroTemas__c> listaTemasInfoCualitativa = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =:RECTYPEINFOCUALITATIVA AND SAC_Activo__c = true];
        if(!listaTemasInfoCualitativa.isempty()){
            for (SAC_MaestroTemas__c maestro : listaTemasInfoCualitativa) {
                listaTodosTopics.add(maestro.Name);
            }
        }

        listaTopics=bucarTopicsDelCaso(caso.id); 
                
        Boolean esPropieratio = (idUsuario == caso.OwnerId) ? true : false;
        TopicsWrapper tw= new TopicsWrapper(esPropieratio, listaTodosTopics, listaTopics);
        return tw;
    }*/

    /*****************************************************************
     * Proposito: Hace la asignación de el topic al caso
     * Historial
     * Modificación: Cuando se activen topics de la información cualitativa se tiene
     *       que crear un registro del objeto junction SAC_Marca_Case__c
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   24/01/22     Creación
     * 1.1                           Sergio Martín   15/06/23     Modificación
    *****************************************************************/
    @AuraEnabled
    public static void setTopicACase(String idCaso, List<String> listaTopics){
 
        List<String> listaNTopisInsert = new List<String>();
        List<String> listaNTopisDelete = new List<String>();
        Case caso= [SELECT id, OwnerId  FROM Case WHERE id =:idCaso limit 1];

        List<String> listaTopicAsigCaso = bucarTopicsDelCaso(idCaso);


        if(!listaTopics.isEmpty()){
            for (String tema : listaTopics) {
                if(!listaTopicAsigCaso.contains(tema)){
                    listaNTopisInsert.add(tema);
                }
            }            
        } 

        if(!listaTopicAsigCaso.isEmpty()){
            for (String tema : listaTopicAsigCaso) { 
                if(!listaTopics.contains(tema)){
                    listaNTopisDelete.add(tema);
                }
            }            
        } 

        if(!listaNTopisInsert.isEmpty()){

            List<Topic> topicInsertar = new List<Topic>();
            List<TopicAssignment> taParaCaso = new List<TopicAssignment>();
            
            for (String nombreTopic : listaNTopisInsert) {
                topicInsertar.add(new Topic(Name = nombreTopic));
            }      
            List<Database.SaveResult> result = Database.insert(topicInsertar, false);  //Por si hay algun topic en el Maestro pero no en el Objeto Topic 
            List<Topic> tBBDD = [SELECT id FROM Topic WHERE  name IN :listaNTopisInsert]; 

            if (!tBBDD.isEmpty()) {
                for (Topic topic : tBBDD) {
                    taParaCaso.add(new TopicAssignment(TopicId=topic.Id, EntityId=caso.Id));
                }
            } 
            Database.insert(taParaCaso);

            List<SAC_Marca_Case__c> marcaCaseInfo = new List<SAC_Marca_Case__c>();
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name, SAC_Activo__c FROM SAC_MaestroTemas__c WHERE Name = :listaNTopisInsert];
            if (!temaEnMaestro.isEmpty()) {
                for (SAC_MaestroTemas__c tema : temaEnMaestro) {
                    // Creación del registro del objeto junction SAC_Marca_Case__c que relaciona la marca con el caso
                    marcaCaseInfo.add(new SAC_Marca_Case__c(SAC_Case__c = caso.id, SAC_Marca__c = tema.id));
                }
            } 
            Database.insert(marcaCaseInfo);
        }

        if(!listaNTopisDelete.isEmpty()){
            List<Topic> tBBDD = [SELECT id FROM Topic WHERE  name IN :listaNTopisDelete]; 
            List<TopicAssignment>  listaTACaso = [SELECT id, TopicId 
                                                    FROM TopicAssignment
                                                    WHERE EntityId =: caso.id AND TopicId IN: tBBDD];
 
            Database.delete(listaTACaso);
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name IN :listaNTopisDelete];
            List<SAC_Marca_Case__c> listaMarcaCaso = [SELECT id 
                                                    FROM SAC_Marca_Case__c
                                                    WHERE SAC_Case__c =: caso.id AND SAC_Marca__c IN: temaEnMaestro];                                       
            Database.delete(listaMarcaCaso);
        }
               
    }

    /*****************************************************************
     * Proposito: Busca los topic que estas asignados al caso
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439       Marcela Neira   24/01/22     Creación
    *****************************************************************/
    @AuraEnabled
    public static List<String> bucarTopicsDelCaso(String idCaso){ 

        List<String> listaTopicsEnElCaso = new List<String>();
        List<String> listaParaRetornarTC = new List<String>();  // Topic que estan asignados al caso que son RT cualitativa y activos
        List<TopicAssignment> listaTopicsCaso = [SELECT id, TopicId, Topic.Name FROM TopicAssignment WHERE EntityId =:idCaso ORDER BY CreatedDate DESC];     


        if(!listaTopicsCaso.isempty()){
            List<SAC_MaestroTemas__c> listTopics =  [SELECT Name FROM SAC_MaestroTemas__c 
                                                                                    WHERE RecordTypeId =:RECTYPEINFOCUALITATIVA 
                                                                                    AND SAC_Activo__c = true];
 
            if(!listTopics.isEmpty()){
                for (SAC_MaestroTemas__c tema : listTopics) {                     
                    listaTopicsEnElCaso.add(tema.Name);
                }
            } 
            
            for (TopicAssignment topicAsignado : listaTopicsCaso) {
                if(listaTopicsEnElCaso.contains(topicAsignado.Topic.Name)){
                    listaParaRetornarTC.add(topicAsignado.Topic.Name);
                }
            }
        } 
         
        return listaParaRetornarTC;
    }
    
    /*****************************************************************
     * Name: ReclamacionWrapper
     * Copyright © 2021  CaixaBank
     *                                                                                        
     * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
     *  del Lightning Web Component: sAC_BuscadorTopic.
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US300439     Marcela Neira     21/01/22      Creación Clase
    *****************************************************************/


    /*public class TopicsWrapper{        
        
        @AuraEnabled public Boolean esPropietario {get; set;}
        @AuraEnabled public List<String> listaTodosTopics {get; set;}
        @AuraEnabled public List<String> listaTopicsCaso {get; set;}
        
        public TopicsWrapper(Boolean esPropietarioActual, List<String> listaTopics , List<String> listaTopicsActual)
        {
            esPropietario = esPropietarioActual;
            listaTodosTopics = listaTopics;
            listaTopicsCaso = listaTopicsActual;
        }
        
    }*/




    @AuraEnabled(cacheable=true) 
    public static Map<String, List<WrapperInfoCuali>> cargarDatosOCS(String idUsuario, String idCaso) { 

        Case caso= [SELECT id, OwnerId, RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId FROM Case WHERE id =:idCaso limit 1];
        List<Case> listaFamilia = new List<Case>();
        Boolean tienePermisos = false;

        if(caso.RecordTypeId == RECTYPERECLAMACION){
            listaFamilia = [SELECT Id FROM Case WHERE SAC_Reclamacion__c =:caso.id];
            //tienePermisos =  (idUsuario == caso.OwnerId) ? true : false;
        }else if(caso.RecordTypeId == RECTYPEPRETENSION){
            tienePermisos = (idUsuario == caso.OwnerId || idUsuario == caso.SAC_Reclamacion__r.OwnerId ) ? true : false;
        }
        
        listaFamilia.add(caso);


        List<SAC_MaestroTemas__c> listaTemasInfoCualitativa = [SELECT Name, SAC_Seccion__c, SAC_Activo__c  FROM SAC_MaestroTemas__c 
                                                       WHERE RecordType.DeveloperName ='SAC_InformacionCualitativa' 
                                                       AND SAC_Seccion__c <> null
                                                       ORDER BY SAC_Seccion__c, Name];        

        Set<String> topicsCaso = new Set<String>();
        List<TopicAssignment> listaTopicsCaso = [SELECT Topic.Name FROM TopicAssignment WHERE EntityId =:listaFamilia ORDER BY Topic.Name];
        for (TopicAssignment tCaso :listaTopicsCaso){
            topicsCaso.add(tCaso.Topic.Name);
        }
 
        Map<String, List<WrapperInfoCuali>> wrappersMap = new Map<String, List<WrapperInfoCuali>>(); 

        if(!listaTemasInfoCualitativa.isempty()){
            for (SAC_MaestroTemas__c maestro : listaTemasInfoCualitativa) {
                if(maestro.SAC_Activo__c || topicsCaso.contains(maestro.Name)) {
                    WrapperInfoCuali valor = new WrapperInfoCuali('val',true,true, tienePermisos);
                    valor.Name = maestro.Name;
                    valor.Activo = maestro.SAC_Activo__c;
                    valor.Selecionado = topicsCaso.contains(maestro.Name); 
                    
                    if(!wrappersMap.containsKey(maestro.SAC_Seccion__c)){
                        wrappersMap.put(maestro.SAC_Seccion__c, new List<WrapperInfoCuali>{valor} );
                    }
                    else{
                        wrappersMap.get(maestro.SAC_Seccion__c).add(valor);
                    }
                }
            }
        }
 
        return wrappersMap;
    }
    public class WrapperInfoCuali {
        @AuraEnabled public Boolean esPropietario {get; set;}
		@AuraEnabled public String Name {get;set;}
		@AuraEnabled public boolean Activo {get;set;}
		@AuraEnabled public boolean Selecionado {get;set;}
        
        public WrapperInfoCuali(String Name, boolean Activo, boolean Selecionado, Boolean esPropietario) {
            this.Name = Name;
            this.Activo = Activo;
            this.Selecionado = Selecionado;
            this.esPropietario = esPropietario;
        }
	}

}