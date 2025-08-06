/**********************************************************************************************************************
 Name:	  CBK_InboundEmailUtils
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar para tratar los InboundEmails.
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US851015  		    Sergio Garcia	   	20/03/2024		    Init version
***********************************************************************************************************************/
public with sharing class CBK_InboundEmailUtils {
    
    public static PriorityHeaderResult getPriorityHeader(PriorityHeaderPetition petition){
        PriorityHeaderResult pHeader = new PriorityHeaderResult();
        Map<String,Integer> mdtMap = new Map<String, Integer>();
        Map<Integer, List<Messaging.InboundEmail.Header>> mapHeadersByPriority = new Map<Integer, List<Messaging.InboundEmail.Header>>();
        List<Messaging.InboundEmail.Header> headerListAux = new List<Messaging.InboundEmail.Header>();
        List<Messaging.InboundEmail.Header> priorityHeaderList = new List<Messaging.InboundEmail.Header>();
        List<Messaging.InboundEmail.Header> restHeaderList = new List<Messaging.InboundEmail.Header>();
        List<Messaging.InboundEmail.Header> restHeaderListNoPriority = new List<Messaging.InboundEmail.Header>();
        List<Messaging.InboundEmail.Header> priorityRestHeaderList = new List<Messaging.InboundEmail.Header>();

        pHeader.priorityHeaders = petition.header;

        if(JSON.serialize(petition.header).length() > petition.limitCharacters){
            //Obtenemos los metadatos con los campos y la prioridad y lo guardamos en un mapa
            for(CBK_HeaderHandlerEmail__mdt mdtHandler : [SELECT CBK_App__c, CBK_HeaderKey__c, CBK_Priority__c FROM CBK_HeaderHandlerEmail__mdt WHERE CBK_App__c IN ('CBK', : petition.app ) ORDER BY CBK_Priority__c ASC]){
                mdtMap.put(mdtHandler.CBK_HeaderKey__c,(Integer) mdtHandler.CBK_Priority__c);
            }
            //Recorremos el header
            if(!mdtMap.isEmpty()){
                for(Messaging.InboundEmail.Header headerElement : petition.header){
                    //Miramos si el elemento del header es prioritario
                    if(mdtMap.containsKey(headerElement.name) ){
                        //Miramos si la prioridad del campo está creado en el mapa
                        if(!mapHeadersByPriority.containsKey(mdtMap.get(headerElement.name))){
                            //Informamos el mapa con la prioridad como clave y creamos la lista con el elemento del header
                            mapHeadersByPriority.put(mdtMap.get(headerElement.name), new List <Messaging.InboundEmail.Header>{headerElement});
                        }else{
                            //Actualizamos la lista de elementos con prioridad X
                            headerListAux = mapHeadersByPriority.get(mdtMap.get(headerElement.name));
                            headerListAux.add(headerElement);
                            mapHeadersByPriority.put(mdtMap.get(headerElement.name), headerListAux);
                        }
                    }else{
                        restHeaderListNoPriority.add(headerElement);
                    }
                }
                //Recorremos el mapa con los elementos del header con prioridad
                if(!mapHeadersByPriority.isEmpty()){
                    for(Integer i : mapHeadersByPriority.keySet()){
                        for(Messaging.InboundEmail.Header headerElement : mapHeadersByPriority.get(i)){
                            //Miramos si al introducir un nuevo elemento sobrepasa el límite informado, si sobrepasa lo guardamos en otra lista
                            if(JSON.serialize(priorityHeaderList).length() + JSON.serialize(headerElement).length() <= petition.limitCharacters){
                                priorityHeaderList.add(headerElement);
                            }else{
                                //Si quedan elementos con prioridad que no caben en la lista con prioridad, los introducimos en primer lugar
                                if(JSON.serialize(priorityRestHeaderList).length() + JSON.serialize(headerElement).length() <= petition.limitCharacters){
                                    priorityRestHeaderList.add(headerElement);
                                } else {
                                    //Llegamos al límite de carácteres en ambas listas, terminamos el bucle.
                                    break;
                                }
                            }
                        }
                    }
                    pHeader.priorityHeaders = priorityHeaderList;

                    //Si hay campos con prioridad en el restHeader añadimos a continuacion los elementos sin prioridad mirando los limites
                    if(!priorityRestHeaderList.isEmpty()){
                        for(Messaging.InboundEmail.Header headerElement : restHeaderListNoPriority){
                            if(JSON.serialize(priorityRestHeaderList).length() + JSON.serialize(headerElement).length() <= petition.limitCharacters){
                                priorityRestHeaderList.add(headerElement);
                            } else {
                                //Llegamos al límite de carácteres en ambas listas, terminamos el bucle.
                                break;
                            }
                        }
                        pHeader.secondPriorityHeaders = priorityRestHeaderList;
                    }else{
                        //Si no, rellenamos los elementos sin prioridad mirando los limites
                        for(Messaging.InboundEmail.Header headerElement : restHeaderListNoPriority){
                            if(JSON.serialize(restHeaderList).length() + JSON.serialize(headerElement).length() <= petition.limitCharacters){
                                restHeaderList.add(headerElement);
                            } else {
                                //Llegamos al límite de carácteres en ambas listas, terminamos el bucle.
                                break;
                            }
                        }
                        pHeader.secondPriorityHeaders = restHeaderList;
                    }
                }
            }
        }

        return pHeader;
    }

    
    public class PriorityHeaderResult{
        public List<Messaging.InboundEmail.Header> priorityHeaders;
        public List<Messaging.InboundEmail.Header> secondPriorityHeaders;
	}

    public class PriorityHeaderPetition{
        public String app;
        public List<Messaging.InboundEmail.Header> header;
        public Integer limitCharacters;
	}
}