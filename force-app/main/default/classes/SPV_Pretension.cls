public with sharing class SPV_Pretension {
  
    private static Set<String> objetos = new Set<String>{'Case', 'CC_MCC__c'};
    private static Map<String, Map<String, Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static Id RECTYPEMCCDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    private static Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();

    public static void cambiarOwnersPretsHermanas(List<Case> listTNewCase, List<Case> listaCasosSelect, Map<Id, Case> mapaDatosCasosActualizar){

        //Mapa en el que para cada reclamación, se le relacionan sus pretensiones
        Map<Id, Map<Id, Case>> mapaReclaPret = new Map<Id, Map<Id, Case>>();

        for(Case caso : listTNewCase){
            if(caso.RecordTypeId == RECTYPEPRETENSION){
                if(!mapaReclaPret.containsKey(caso.SAC_Reclamacion__c)){    //Si la reclamación no está en el mapa, se añade la reclamación y la pretensión
                    Map<Id, Case> mapaPretensiones = new Map<Id, Case>();
                    mapaPretensiones.put(caso.Id, caso);
                    mapaReclaPret.put(caso.SAC_Reclamacion__c, mapaPretensiones);
                }else{                                                      //Si la reclamación sí está, se actualiza el mapa de pretensiones añadiendo la nueva
                    Map<Id, Case> mapaPretensiones = mapaReclaPret.get(caso.SAC_Reclamacion__C);
                    mapaPretensiones.put(caso.Id, caso);
                    mapaReclaPret.put(caso.SAC_Reclamacion__c, mapaPretensiones);
                }
            }
        }

        //El mapa para las reclamaciones del Select
        Map<Id, List<Case>> mapaReclaPretSelect = new Map<Id, List<Case>>();

        for(Case caso : listaCasosSelect){
            if(caso.RecordTypeId == RECTYPEPRETENSION){
                if(!mapaReclaPretSelect.containsKey(caso.SAC_Reclamacion__c)){    //Si la reclamación no está en el mapa, se añade la reclamación y la pretensión
                    List<Case> listaPretensiones = new List<Case>();
                    listaPretensiones.add(caso);
                    mapaReclaPretSelect.put(caso.SAC_Reclamacion__c, listaPretensiones);
                }else{                                                      //Si la reclamación sí está, se actualiza el mapa de pretensiones añadiendo la nueva
                    List<Case> listaPretensiones = mapaReclaPretSelect.get(caso.SAC_Reclamacion__C);
                    listaPretensiones.add(caso);
                    mapaReclaPretSelect.put(caso.SAC_Reclamacion__c, listaPretensiones);
                }
            }
        }


        /*
        Comprobar si alguna pretensión de cada familia de reclamaciones no está en el trigger new.
        Si no lo está, comprobar que el owner es el mismo.
        Si no es el mismo owner, lo updatea.
        */

        for(String idReclamacion : mapaReclaPretSelect.keySet()){
            for(Case pretensionSelect : mapaReclaPretSelect.get(idReclamacion)){
                if(mapaReclaPret.containsKey(idReclamacion) && !mapaReclaPret.get(idReclamacion).containsKey(pretensionSelect.Id)){
                    for(Case pretensionNew : mapaReclaPret.get(idReclamacion).values()){
                        if(pretensionNew.OwnerId != pretensionSelect.OwnerId){
                            //Actualizar la pretensión del select
                            if(mapaDatosCasosActualizar.containsKey(pretensionSelect.Id)){
                                mapaDatosCasosActualizar.get(pretensionSelect.Id).OwnerId = pretensionNew.OwnerId;
                                break;
                            }else{
                                Case pretensionUpdatear = new Case();
                                pretensionUpdatear.Id = pretensionSelect.Id;
                                pretensionUpdatear.OwnerId = pretensionNew.OwnerId;
                                mapaDatosCasosActualizar.put(pretensionUpdatear.Id, pretensionUpdatear);
                                break;
                            }
                        }
                    }
                }
            }
        }



        



    }



    public static void cambioLetrado(List<Case> listNewPretensiones, Map<Id, Case> mapaDatosCasosActualizar, Group cola, Group colaSupervisores, Group colaIA){
        Map<Id, Id> mapaReclamacionLetrado = new Map<Id, Id>();
        Set<Id> setIdsOwnersPretension = new Set<Id>();

        //Almacenar los ids de las pretensiones con cambio de Owner y almacenando para cada reclamación de las pretensiones, su nuevo Owner
        for(Case pretension: listNewPretensiones){
            setIdsOwnersPretension.add(pretension.OwnerId);
            mapaReclamacionLetrado.put(pretension.SAC_Reclamacion__c, pretension.OwnerId); //El letrado de cada reclamación tendrá este Owner id 
        }

        if(!setIdsOwnersPretension.isEmpty()){
            Map<Id, User> mapaUsuarios = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN: setIdsOwnersPretension]);    //Se obtienen los usuarios cuyas Ids son las que se han asignado como nuevos Owners

            for(Id idReclamacion : mapaReclamacionLetrado.keySet()){
                
                if(mapaUsuarios.containsKey(mapaReclamacionLetrado.get(idReclamacion))){    //Si el Owner es un usuario, se hace esto. La otra posibilidad es que sea un Grupo o una cola
                    if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                        mapaDatosCasosActualizar.get(idReclamacion).SAC_Letrado__c = mapaUsuarios.get(mapaReclamacionLetrado.get(idReclamacion)).Name;   //Se le asigna de letrado el nuevo id de owner de las pretensiones, y se coge el nombre de ese Id de usuario
                    }else{
                        Case nuevaReclamacionActualizada = new Case();
                        nuevaReclamacionActualizada.Id = idReclamacion;
                        nuevaReclamacionActualizada.SAC_Letrado__c = mapaUsuarios.get(mapaReclamacionLetrado.get(idReclamacion)).Name;
                        mapaDatosCasosActualizar.put(nuevaReclamacionActualizada.Id, nuevaReclamacionActualizada);
                    }
                }else{  //Si no es un usuario el nuevo owner, será una cola. Se va a comprobar las distintas opciones
                        if(mapaReclamacionLetrado.get(idReclamacion) == cola.Id){
                            if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                                mapaDatosCasosActualizar.get(idReclamacion).SAC_Letrado__c = 'Pte.Asignar';
                            }else{
                                Case nuevaReclamacionActualizada = new Case();
                                nuevaReclamacionActualizada.Id = idReclamacion;
                                nuevaReclamacionActualizada.SAC_Letrado__c = 'Pte. Asignar';
                                mapaDatosCasosActualizar.put(nuevaReclamacionActualizada.Id, nuevaReclamacionActualizada);
                            }
                        }else{  //Si no es de la cola Pte. Asignar, se ve si lo es de la de Pte. Supervisor
                            if(mapaReclamacionLetrado.get(idReclamacion) == colaSupervisores.Id){
                                if (mapaDatosCasosActualizar.containsKey(idReclamacion)) {
                                    mapaDatosCasosActualizar.get(idReclamacion).SAC_Letrado__c = 'Pte. Supervisor';
                                } else {
                                    Case nuevaReclamacionActualizada = new Case();
                                    nuevaReclamacionActualizada.Id = idReclamacion;
                                    nuevaReclamacionActualizada.SAC_Letrado__c = 'Pte. Supervisor';
                                    mapaDatosCasosActualizar.put(nuevaReclamacionActualizada.Id, nuevaReclamacionActualizada);
                                }
                            }else{      //Si tampoco es de la cola Pte. Supervisor, se comprueba si lo es de la cola Pte. IA
                                if(mapaReclamacionLetrado.get(idReclamacion) == colaIA.Id){
                                    if (mapaDatosCasosActualizar.containsKey(idReclamacion)) {
                                        mapaDatosCasosActualizar.get(idReclamacion).SAC_Letrado__c = 'Pte. IA';
                                    } else {
                                        Case nuevaReclamacionActualizada = new Case();
                                        nuevaReclamacionActualizada.Id = idReclamacion;
                                        nuevaReclamacionActualizada.SAC_Letrado__c = 'Pte. IA';
                                        mapaDatosCasosActualizar.put(nuevaReclamacionActualizada.Id, nuevaReclamacionActualizada);
                                    }
                                }
                            }
                        }



                    /*Id a = mapaReclamacionLetrado.get(idReclamacion);
                    switch on mapaReclamacionLetrado.get(idReclamacion){        
                        when cola.Id{
                            if(mapaDatosCasosActualizar.containsKey(idReclamacion)){
                                mapaDatosCasosActualizar.get(idReclamacion).SAC_Letrado__c = 'Pte.Asignar';
                            }else{
                                Case nuevaReclamacionActualizada = new Case();
                                nuevaReclamacionActualizada.Id = idRec;
                                nuevaReclamacionActualizada.SAC_Letrado__c = 'Pte. Asignar';
                                mapaDatosCasosActualizar.put(nuevaReclamacionActualizada.Id, nuevaReclamacionActualizada);
                            }
                        }

                        when colaSupervisores.Id{
                            if (mapaDatosCasosActualizar.containsKey(idRec)) {
                                mapaDatosCasosActualizar.get(idRec).SAC_Letrado__c = 'Pte. Supervisor';
                            } else {
                                Case nuevaReclamacionActualizada = new Case();
                                nuevaReclamacionActualizada.Id = idRec;
                                nuevaReclamacionActualizada.SAC_Letrado__c = 'Pte. Supervisor';
                                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, nuevaReclamacionActualizada);
                            }
                        }

                        when colaIA.Id{
                            if (mapaDatosCasosActualizar.containsKey(idRec)) {
                                mapaDatosCasosActualizar.get(idRec).SAC_Letrado__c = 'Pte. IA';
                            } else {
                                Case nuevaReclamacionActualizada = new Case();
                                nuevaReclamacionActualizada.Id = idRec;
                                nuevaReclamacionActualizada.SAC_Letrado__c = 'Pte. IA';
                                mapaDatosCasosActualizar.put(reclamacionActualizar.Id, nuevaReclamacionActualizada);
                            }
                        }
                    }*/

                }
                

                }
            }
        }
    }