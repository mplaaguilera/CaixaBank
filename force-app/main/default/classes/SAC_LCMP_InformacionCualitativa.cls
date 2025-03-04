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
     * 1.2                           Álex Polo       04/02/25     Modificación
    *****************************************************************/
    @AuraEnabled
    public static void setTopicACase(String idCaso, List<String> listaTopics){
 
        List<String> listaNTopisInsert = new List<String>();
        List<String> listaNTopisDelete = new List<String>();
        Case caso= [SELECT id, OwnerId  FROM Case WHERE id =:idCaso limit 1];

        List<String> listaTopicAsigCaso = bucarTopicsDelCaso(idCaso);

        Map<String, String>  mapaListaTopicAsigCasoNombreGenerico = new Map<String, String>();      //El primer string (nomkbre normal) - el segundo nombre sin espacio ni mayúsculas/minúsculas
        for(String t: listaTopicAsigCaso){
            if(!mapaListaTopicAsigCasoNombreGenerico.containsKey(t.toLowerCase().replace(' ', ''))){
                mapaListaTopicAsigCasoNombreGenerico.put(t.toLowerCase().replace(' ', ''), t);
            }
        }

        Map<String, String>  mapaListaTopicsNombreGenerico = new Map<String, String>();      //El primer string (nomkbre normal) - el segundo nombre sin espacio ni mayúsculas/minúsculas
        for(String t: listaTopics){
            if(!mapaListaTopicsNombreGenerico.containsKey(t.toLowerCase().replace(' ', ''))){
                mapaListaTopicsNombreGenerico.put(t.toLowerCase().replace(' ', ''), t);
            }
        }

        if(!listaTopics.isEmpty()){
            for (String tema : listaTopics) {
                if(!listaTopicAsigCaso.contains(tema) && !listaTopicAsigCaso.contains(tema.toLowerCase().replace(' ', '')) && !mapaListaTopicAsigCasoNombreGenerico.containsKey(tema.toLowerCase().replace(' ', ''))){
                    listaNTopisInsert.add(tema);
                }
            }            
        } 

        if(!listaTopicAsigCaso.isEmpty()){
            for (String tema : listaTopicAsigCaso) { 
                if(!listaTopics.contains(tema) && !listaTopics.contains(tema.toLowerCase().replace(' ', '')) && !mapaListaTopicsNombreGenerico.containsKey(tema.toLowerCase().replace(' ', ''))){
                    listaNTopisDelete.add(tema);
                }
            }            
        } 


       /* if(!listaTopics.isEmpty()){
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
        } */


        List<SAC_Marca_Case__c> listaMarcasAsociadas = [SELECT id,SAC_Marca__c, SAC_Marca__r.Name FROM SAC_Marca_Case__c WHERE SAC_Case__c =: caso.id];

        //Para saber si hay que borrar alguna marca (el join marca-caso) del maestro de temas cuyo nombre no coincida con su topic:
        //Si hay alguna marca en el caso que esté asgnada al caso, pero NO se haya recibido en listaTopics, será que esa marca se va a quitar del caso, asique hay que añadirlo a la lista a borrar con su nombre de maestro temas en caso de que no lo esté ya
        for(SAC_Marca_Case__c marcaCaso : listaMarcasAsociadas){
            if(!listaNTopisDelete.contains(marcaCaso.SAC_Marca__r.Name) && mapaListaTopicAsigCasoNombreGenerico.containsKey(marcaCaso.SAC_Marca__r.Name.toLowerCase().replace(' ', '')) && !mapaListaTopicsNombreGenerico.containsKey(marcaCaso.SAC_Marca__r.Name.toLowerCase().replace(' ', '')) ){
                listaNTopisDelete.add(marcaCaso.SAC_Marca__r.Name);
            }
        }


        
        if(!listaNTopisInsert.isEmpty()){

            List<Topic> topicInsertar = new List<Topic>();
            List<TopicAssignment> taParaCaso = new List<TopicAssignment>();
            
            for (String nombreTopic : listaNTopisInsert) {
                topicInsertar.add(new Topic(Name = nombreTopic));
            }      
            SAC_DatabaseDML.insertListDML(topicInsertar, false);
            //List<Database.SaveResult> result = Database.insert(topicInsertar, false);  //Por si hay algun topic en el Maestro pero no en el Objeto Topic 
            //List<Topic> tBBDD = [SELECT id FROM Topic WHERE  name IN :listaNTopisInsert];

            List<Topic> tBBDD = new List<Topic>();
            List<Topic> todosLosTopic = [SELECT id, Name FROM Topic];

            Map<String, Topic>  mapaDeTopicNombreGenerico = new Map<String, Topic>();
            for(Topic t: todosLosTopic){
                if(!mapaDeTopicNombreGenerico.containsKey(t.Name.toLowerCase().replace(' ', ''))){
                    mapaDeTopicNombreGenerico.put(t.Name.toLowerCase().replace(' ', ''), t);
                }
            }

            for(String topicBuscado: listaNTopisInsert){
                if(mapaDeTopicNombreGenerico.containsKey(topicBuscado.toLowerCase().replace(' ', ''))){
                    tBBDD.add(mapaDeTopicNombreGenerico.get(topicBuscado.toLowerCase().replace(' ', '')));
                }
            }


            if (!tBBDD.isEmpty()) {
                for (Topic topic : tBBDD) {
                    taParaCaso.add(new TopicAssignment(TopicId=topic.Id, EntityId=caso.Id));
                }
            }
            SAC_DatabaseDML.insertListDML(taParaCaso, true);
            //Database.insert(taParaCaso);

            List<SAC_Marca_Case__c> marcaCaseInfo = new List<SAC_Marca_Case__c>();
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name, SAC_Activo__c FROM SAC_MaestroTemas__c WHERE Name = :listaNTopisInsert AND RecordTypeId =:RECTYPEINFOCUALITATIVA];
            if (!temaEnMaestro.isEmpty()) {
                for (SAC_MaestroTemas__c tema : temaEnMaestro) {
                    // Creación del registro del objeto junction SAC_Marca_Case__c que relaciona la marca con el caso
                    marcaCaseInfo.add(new SAC_Marca_Case__c(SAC_Case__c = caso.id, SAC_Marca__c = tema.id));
                }
            }
            SAC_DatabaseDML.insertListDML(marcaCaseInfo, true);
            //Database.insert(marcaCaseInfo);
        }

        if(!listaNTopisDelete.isEmpty()){

            List<Topic> todosLosTopic = [SELECT id, Name FROM Topic];
            List<Topic> tBBDD = new List<Topic>();
            Map<String, Topic>  mapaDeTopicNombreGenerico = new Map<String, Topic>();

            for(Topic t: todosLosTopic){
                if(!mapaDeTopicNombreGenerico.containsKey(t.Name.toLowerCase().replace(' ', ''))){
                    mapaDeTopicNombreGenerico.put(t.Name.toLowerCase().replace(' ', ''), t);
                }
            }

            for(String topicBuscado: listaNTopisDelete){
                if(mapaDeTopicNombreGenerico.containsKey(topicBuscado.toLowerCase().replace(' ', ''))){
                    tBBDD.add(mapaDeTopicNombreGenerico.get(topicBuscado.toLowerCase().replace(' ', '')));
                }
            }

            List<TopicAssignment>  listaTACaso = [SELECT id, TopicId FROM TopicAssignment WHERE EntityId =: caso.id AND TopicId IN: tBBDD];
            SAC_DatabaseDML.deleteListDML(listaTACaso, true);
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name IN :listaNTopisDelete AND RecordTypeId =:RECTYPEINFOCUALITATIVA];
            List<SAC_Marca_Case__c> listaMarcaCaso = [SELECT id FROM SAC_Marca_Case__c WHERE SAC_Case__c =: caso.id AND SAC_Marca__c IN: temaEnMaestro];
            SAC_DatabaseDML.deleteListDML(listaMarcaCaso, true);    


            /*List<Topic> tBBDD = [SELECT id FROM Topic WHERE  name IN :listaNTopisDelete]; 
            List<TopicAssignment>  listaTACaso = [SELECT id, TopicId 
                                                    FROM TopicAssignment
                                                    WHERE EntityId =: caso.id AND TopicId IN: tBBDD];
            SAC_DatabaseDML.deleteListDML(listaTACaso, true);
            //Database.delete(listaTACaso);
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name IN :listaNTopisDelete AND RecordTypeId =:RECTYPEINFOCUALITATIVA];
            List<SAC_Marca_Case__c> listaMarcaCaso = [SELECT id 
                                                    FROM SAC_Marca_Case__c
                                                    WHERE SAC_Case__c =: caso.id AND SAC_Marca__c IN: temaEnMaestro];
            SAC_DatabaseDML.deleteListDML(listaMarcaCaso, true);   */                                 
            //Database.delete(listaMarcaCaso);
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
                    //listaTopicsEnElCaso.add(tema.Name);
                    listaTopicsEnElCaso.add(tema.Name.toLowerCase().replace(' ', ''));
                }
            } 
            
            for (TopicAssignment topicAsignado : listaTopicsCaso) {
                if(listaTopicsEnElCaso.contains(topicAsignado.Topic.Name.toLowerCase().replace(' ', ''))){
                    listaParaRetornarTC.add(topicAsignado.Topic.Name);
                }
                /*if(listaTopicsEnElCaso.contains(topicAsignado.Topic.Name)){
                    listaParaRetornarTC.add(topicAsignado.Topic.Name);
                }*/
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
        Set<String> topicsCasoAsignadosNombreGenerico = new Set<String>();         //Se alamcenan con los nombres sin espacio y sin tener en cuenta mayúsculas y minúsculas

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
            topicsCasoAsignadosNombreGenerico.add(tCaso.Topic.Name.toLowerCase().replace(' ', ''));
        }
 
        Map<String, List<WrapperInfoCuali>> wrappersMap = new Map<String, List<WrapperInfoCuali>>(); 

        if(!listaTemasInfoCualitativa.isempty()){
            for (SAC_MaestroTemas__c maestro : listaTemasInfoCualitativa) {
                if(maestro.SAC_Activo__c || /*topicsCaso.contains(maestro.Name)*/ topicsCasoAsignadosNombreGenerico.contains(maestro.Name.toLowerCase().replace(' ', ''))) {
                    WrapperInfoCuali valor = new WrapperInfoCuali('val',true,true, tienePermisos);
                    valor.Name = maestro.Name;
                    valor.Activo = maestro.SAC_Activo__c;
                    //valor.Selecionado = topicsCaso.contains(maestro.Name); 
                    valor.Selecionado = topicsCasoAsignadosNombreGenerico.contains(maestro.Name.toLowerCase().replace(' ', '')); //True si alguna pretensión lo tiene asignado (Si está en una oretensión, solo se tiene en cuenta la propia pretensión, no el resto)
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