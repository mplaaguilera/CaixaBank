/*****************************************************************
 * Name: SPV_LCMP_SeccionesInfoCualitativa 

 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controller de spv_SeccionesInfoCualitativa

 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US313245       Álex Polo       31/01/2025     Creación
*****************************************************************/
public with sharing class SPV_LCMP_SeccionesInfoCualitativa {

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //RT de la reclamación y las pretensiones
    private static final Id recTypeReclamacion = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id recTypePretension = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();

    //Rt para el maestro de temas que es la información cualitativa en SPV
    private static final Id recTypeInfoCualitativa = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_InformacionCualitativa').getRecordTypeId();


    /*****************************************************************
     * Proposito: Busca los topic que estas asignados al caso
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US313245       Álex Polo       03/02/2025     
    *****************************************************************/
    @AuraEnabled
    public static List<String> bucarTopicsDelCaso(String idCaso){ 
        List<String> listaTopicsEnElCaso = new List<String>();
        List<String> listaParaRetornarTC = new List<String>();  // Topic que estan asignados al caso que son RT cualitativa y activos
        List<TopicAssignment> listaTopicsCaso = [SELECT id, TopicId, Topic.Name FROM TopicAssignment WHERE EntityId =:idCaso ORDER BY CreatedDate DESC];     

        if(!listaTopicsCaso.isempty()){
            List<SAC_MaestroTemas__c> listTopics =  [SELECT Name FROM SAC_MaestroTemas__c 
                                                                                    WHERE RecordTypeId =:recTypeInfoCualitativa 
                                                                                    AND SAC_Activo__c = true];
 
            if(!listTopics.isEmpty()){
                for (SAC_MaestroTemas__c tema : listTopics) {                     
                    listaTopicsEnElCaso.add(tema.Name.toLowerCase().replace(' ', ''));
                }
            } 
            
            for (TopicAssignment topicAsignado : listaTopicsCaso) {
                if(listaTopicsEnElCaso.contains(topicAsignado.Topic.Name.toLowerCase().replace(' ', ''))){
                    listaParaRetornarTC.add(topicAsignado.Topic.Name);
                }
            }
        } 
         
        return listaParaRetornarTC;
    }

    @AuraEnabled
    public static Map<String, List<WrapperInfoCuali>> getSeccionesYInfoCualitativaManual(String idUsuario, String idCaso) { 
        System.debug('entra a manual  ' + idUsuario + '  ' + idCaso);
        Map<String, List<WrapperInfoCuali>> resultado = getSeccionesYInfoCualitativa(idUsuario, idCaso);
        return resultado;
    }

    @AuraEnabled(cacheable=true) 
    public static Map<String, List<WrapperInfoCuali>> getSeccionesYInfoCualitativa(String idUsuario, String idCaso) { 

        List<Case> listaCasoRecord = new List<Case>();  //Lista donde se recupera el caso actual
        List<Case> listaCasosFamilia = new List<Case>();    //Lista donde estarán las pretensiones de la reclamación y la propia reclamación
        Set<String> topicsCasoAsignados = new Set<String>();         //Se almacenan los nombres de las info cualitativas que estén asociadas a alguna pretensión
        Set<String> topicsCasoAsignadosNombreGenerico = new Set<String>();         //Se alamcenan con los nombres sin espacio y sin tener en cuenta mayúsculas y minúsculas
        
        Case caso = new Case();
        Boolean tienePermisos = false;      //Solo se podrán editar la info. cualitativa si es una pretensión y se es su owner o de la reclamación. Si es una reclamación, este valor permanece en false

        //Mapa String(nombre sección) - Wrapper(distintos topics de la info cualitativa que hay dentro de esa misma sección), esto permite clasificarlos por secciones
        Map<String, List<WrapperInfoCuali>> wrappersMap = new Map<String, List<WrapperInfoCuali>>(); 

        listaCasoRecord = [SELECT id, OwnerId, RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId FROM Case WHERE id =:idCaso limit 1];
        if(!listaCasoRecord.isEmpty()){
            caso = listaCasoRecord[0];  //De este modo, al no asignar la query directamente al caso, se evita un posible fallo

            
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                listaCasosFamilia = [SELECT Id FROM Case WHERE SAC_Reclamacion__c =:caso.id];        //Si el caso actual es una reclamación, se obtienen sus pretensiones
            }else if(caso.RecordTypeId == RECTYPEPRETENSION){
                tienePermisos = (idUsuario == caso.OwnerId || idUsuario == caso.SAC_Reclamacion__r.OwnerId ) ? true : false;        //Si es una pretensión, comprueba que tiene permisos sobre esta o su reclamación
            }

            //Si es una reclamación, se añade a la lista junto al resto de pretensiones. Si es una pretensión, será la única en la lista
            listaCasosFamilia.add(caso);

            //Se recuperan aquellos registros activos existentes de información cualitativa para SPV
            List<SAC_MaestroTemas__c> listaTemasInfoCualitativa = [SELECT Name, SAC_Seccion__c, SAC_Activo__c  FROM SAC_MaestroTemas__c WHERE RecordType.DeveloperName ='SPV_InformacionCualitativa' AND SAC_Seccion__c <> null ORDER BY SAC_Seccion__c, Name];        


            //Se obtienen aquellos que están relaccionados a el caso actual (o en caso de ser una reclamación, a alguna de sus pretensiones)
            List<TopicAssignment> listaTopicsCaso = [SELECT Topic.Name FROM TopicAssignment WHERE EntityId =:listaCasosFamilia ORDER BY Topic.Name];
            for (TopicAssignment tCaso :listaTopicsCaso){
                topicsCasoAsignados.add(tCaso.Topic.Name);
                topicsCasoAsignadosNombreGenerico.add(tCaso.Topic.Name.toLowerCase().replace(' ', ''));
            }
     
            //Se recorren los registros de info cualitativa SPV y se añaden indicando si está seleccionado o no
            if(!listaTemasInfoCualitativa.isEmpty()){
                for(SAC_MaestroTemas__c maestro : listaTemasInfoCualitativa){
                    if(maestro.SAC_Activo__c || topicsCasoAsignadosNombreGenerico.contains(maestro.Name.toLowerCase().replace(' ', ''))){    //Solo coger los activos, o aquel que, en caso de no estar activo, ya está asignado a una pretensión
                        WrapperInfoCuali valor = new WrapperInfoCuali('val',true,true, tienePermisos);
                        valor.Name = maestro.Name;
                        valor.Activo = maestro.SAC_Activo__c;
                       // valor.Selecionado = topicsCasoAsignados.contains(maestro.Name); //True si alguna pretensión lo tiene asignado (Si está en una oretensión, solo se tiene en cuenta la propia pretensión, no el resto)
                       valor.Selecionado = topicsCasoAsignadosNombreGenerico.contains(maestro.Name.toLowerCase().replace(' ', '')); //True si alguna pretensión lo tiene asignado (Si está en una oretensión, solo se tiene en cuenta la propia pretensión, no el resto)
                        if(!wrappersMap.containsKey(maestro.SAC_Seccion__c)){
                            wrappersMap.put(maestro.SAC_Seccion__c, new List<WrapperInfoCuali>{valor});
                        }else{
                            wrappersMap.get(maestro.SAC_Seccion__c).add(valor);
                        }

                    }
                }
            }

        }
        if(wrappersMap.isEmpty()){
            return null;
        }else{
            return wrappersMap;
        }
    }

    
    /*****************************************************************
     * Proposito: Hace la asignación de el topic al caso
     * Historial
     * Modificación: Cuando se activen topics de la información cualitativa se tiene
     *       que crear un registro del objeto junction SAC_Marca_Case__c
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US313245       Álex Polo       03/02/2025     
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
            SPV_DatabaseDML.insertListDML(topicInsertar, false);
            //List<Database.SaveResult> result = Database.insert(topicInsertar, false);  //Por si hay algun topic en el Maestro pero no en el Objeto Topic  
            //List<Topic> tBBDD = [SELECT id FROM Topic WHERE  name IN :listaNTopisInsert]; 
            List<Topic> tBBDD = new List<Topic>();
            //Se obtienen los topics tras haber insertado los nuevos 
            List<Topic> todosLosTopic = [SELECT id, Name FROM Topic];

            //Se almacenan los topics per sin espacio y en minúsculas como clave
            Map<String, Topic>  mapaDeTopicNombreGenerico = new Map<String, Topic>();
            for(Topic t: todosLosTopic){
                if(!mapaDeTopicNombreGenerico.containsKey(t.Name.toLowerCase().replace(' ', ''))){
                    mapaDeTopicNombreGenerico.put(t.Name.toLowerCase().replace(' ', ''), t);
                }
            }

            //Se recogen los topics que se van a insertar, buscandolos pasándolos a sin espacio y a minúsculas para ver si existe un topic que coincida con él
            for(String topicBuscado: listaNTopisInsert){
                if(mapaDeTopicNombreGenerico.containsKey(topicBuscado.toLowerCase().replace(' ', ''))){
                    tBBDD.add(mapaDeTopicNombreGenerico.get(topicBuscado.toLowerCase().replace(' ', '')));  //Se añade a tBBDD el topic como tal, sin modificarle el nombre
                }
            }

            if (!tBBDD.isEmpty()) {
                for (Topic topic : tBBDD) {
                    taParaCaso.add(new TopicAssignment(TopicId=topic.Id, EntityId=caso.Id));
                }
            }  
            SPV_DatabaseDML.insertListDML(taParaCaso, true);

            List<SAC_Marca_Case__c> marcaCaseInfo = new List<SAC_Marca_Case__c>();
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name, SAC_Activo__c FROM SAC_MaestroTemas__c WHERE Name = :listaNTopisInsert AND RecordTypeId =:recTypeInfoCualitativa];
            if (!temaEnMaestro.isEmpty()) {
                for (SAC_MaestroTemas__c tema : temaEnMaestro) {
                    // Creación del registro del objeto junction SAC_Marca_Case__c que relaciona la marca con el caso
                    marcaCaseInfo.add(new SAC_Marca_Case__c(SAC_Case__c = caso.id, SAC_Marca__c = tema.id));
                }
            }

            SPV_DatabaseDML.insertListDML(marcaCaseInfo, true);
        }

        if(!listaNTopisDelete.isEmpty()){

          
            List<Topic> todosLosTopic = [SELECT id, Name FROM Topic];
            List<Topic> tBBDD = new List<Topic>();
            Map<String, Topic>  mapaDeTopicNombreGenerico = new Map<String, Topic>();

            //Se almacenan los topics per sin espacio y en minúsculas como clave
            for(Topic t: todosLosTopic){
                if(!mapaDeTopicNombreGenerico.containsKey(t.Name.toLowerCase().replace(' ', ''))){
                    mapaDeTopicNombreGenerico.put(t.Name.toLowerCase().replace(' ', ''), t);
                }
            }

            //Se recogen los topics que se van a insertar, buscandolos pasándolos a sin espacio y a minúsculas para ver si existe un topic que coincida con él
            for(String topicBuscado: listaNTopisDelete){
                if(mapaDeTopicNombreGenerico.containsKey(topicBuscado.toLowerCase().replace(' ', ''))){
                    tBBDD.add(mapaDeTopicNombreGenerico.get(topicBuscado.toLowerCase().replace(' ', ''))); //Se añade a tBBDD el topic como tal, sin modificarle el nombre
                }
            }
          

            List<TopicAssignment>  listaTACaso = [SELECT id, TopicId FROM TopicAssignment WHERE EntityId =: caso.id AND TopicId IN: tBBDD];
            SPV_DatabaseDML.deleteListDML(listaTACaso, true);
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name IN :listaNTopisDelete AND RecordTypeId =:recTypeInfoCualitativa];
            List<SAC_Marca_Case__c> listaMarcaCaso = [SELECT id 
                                                    FROM SAC_Marca_Case__c
                                                    WHERE SAC_Case__c =: caso.id AND SAC_Marca__c IN: temaEnMaestro];

            SPV_DatabaseDML.deleteListDML(listaMarcaCaso, true);          
            /*List<Topic> tBBDD = [SELECT id FROM Topic WHERE  name IN :listaNTopisDelete]; 
            List<TopicAssignment>  listaTACaso = [SELECT id, TopicId 
                                                    FROM TopicAssignment
                                                    WHERE EntityId =: caso.id AND TopicId IN: tBBDD];
            SPV_DatabaseDML.deleteListDML(listaTACaso, true);
            List<SAC_MaestroTemas__c> temaEnMaestro = [SELECT id, name FROM SAC_MaestroTemas__c WHERE Name IN :listaNTopisDelete];
            List<SAC_Marca_Case__c> listaMarcaCaso = [SELECT id 
                                                    FROM SAC_Marca_Case__c
                                                    WHERE SAC_Case__c =: caso.id AND SAC_Marca__c IN: temaEnMaestro];
            SPV_DatabaseDML.deleteListDML(listaMarcaCaso, true);             */                       
        }
               
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