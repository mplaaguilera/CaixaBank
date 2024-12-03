/*****************************************************************************************
 * Name: SAC_Accion_PermisoPropietario
 * Copyright © 2021  CaixaBank
 * =======================================================================================
 * Propósito: Clase que contiene un método para darle permisos de edición y eliminado de las acciónes
 *  al propietario de una reclamación
 * =======================================================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0            DE53083         Daniel Benito      21/10/21      Creación Clase
******************************************************************************************/

public without sharing class SAC_Accion_PermisoPropietario {

    /**************************************************************************
     * Proposito: Darle permisos de edición sobre una tarea al propietario actual de una pretensión/reclamación
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            DE53083          Daniel Benito    22/10/2021   Creación
    **************************************************************************/    
    public static List<SAC_Accion__Share> permisosAccionPropietario(List<Case> listaCasosNuevos, Map<Id,Case> mapOldObj){

        List<Id> idsCase = new List<Id>();
        List<SAC_Accion__Share> accionesShare = new List<SAC_Accion__Share>();
        Map<Id,List<SAC_Accion__C>> casoAcciones = new Map<Id,List<SAC_Accion__C>>();

        for(Case reclamacion : listaCasosNuevos){

            idsCase.add(reclamacion.id);

        }

        List<SAC_Accion__c> acciones = [SELECT id, SAC_Reclamacion__c,SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c IN: idsCase OR SAC_Pretension__c IN: idsCase];

        List<SAC_Accion__c> accionesPretension = new List<SAC_Accion__c>();
        List<SAC_Accion__c> accionesReclamacion = new List<SAC_Accion__c>();
        
            for(SAC_Accion__c accion : acciones){

               if(idsCase.contains(accion.SAC_Pretension__c)){

                    accionesPretension.add(accion);

               }else{

                    accionesReclamacion.add(accion);
               }
            }
          
        //Relleno del Mapa

        for(SAC_Accion__c accionRecla : accionesReclamacion){

            List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();

            if(casoAcciones.containsKey(accionRecla.SAC_Reclamacion__c)){

                accionesAux = casoAcciones.get(accionRecla.SAC_Reclamacion__c);

            }

            accionesAux.add(accionRecla);
            casoAcciones.put(accionRecla.SAC_Reclamacion__c, accionesAux);
        }

        for(SAC_Accion__c accionPrete : accionesPretension){

            List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();

            if(casoAcciones.containsKey(accionPrete.SAC_Pretension__c)){

                accionesAux = casoAcciones.get(accionPrete.SAC_Pretension__c);

            }

            accionesAux.add(accionPrete);
            casoAcciones.put(accionPrete.SAC_Pretension__c, accionesAux);
        }

        //Eliminar los permisos al propieatrio anterior
        if(listaCasosNuevos != null){

            Map<Id,List<SAC_Accion__c>> accionesCaso = new Map<Id,List<SAC_Accion__c>>();
            Map<Id,List<SAC_Accion__Share>> permisosUsuario = new Map<Id,List<SAC_Accion__Share>>();
            List<SAC_Accion__Share> permisosBorrar = new List<SAC_Accion__Share>();

            List<Id> idsOldCase = new List<Id>();
            List<String> anteriorOwner = new List<String>();

            for(Case casoNuevo : listaCasosNuevos){

                if(mapOldObj.containsKey(casoNuevo.id)){

                    idsOldCase.add(casoNuevo.id);
                    anteriorOwner.add(casoNuevo.OwnerId);
                    
                }
            }

            List<SAC_Accion__c> accionesToDelete = [SELECT id,SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c IN:idsOldCase OR SAC_Pretension__c IN:idsOldCase ];

            List<SAC_Accion__Share> sharesToDelete = [SELECT id,UserOrGroupId,ParentId,Parent.SAC_Pretension__c, Parent.SAC_Reclamacion__c FROM SAC_Accion__Share WHERE ParentId IN:accionesToDelete AND UserOrGroupId IN:anteriorOwner  AND AccessLevel = 'Edit' 
                                                        AND (Parent.SAC_Reclamacion__c IN: idsOldCase OR Parent.SAC_Pretension__c IN: idsOldCase) ];

            //Rellenar mapa accionesCaso                                            
            for(SAC_Accion__c accionToDelete : accionesToDelete){

                List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();

                if(accionToDelete.SAC_Pretension__c != null){

                    if(accionesCaso.containsKey(accionToDelete.SAC_Pretension__c)){

                        accionesAux = accionesCaso.get(accionToDelete.SAC_Pretension__c);
                    }

                    accionesAux.add(accionToDelete);
                    accionesCaso.put(accionToDelete.SAC_Pretension__c, accionesAux);

                }else{

                    if(accionesCaso.containsKey(accionToDelete.SAC_Reclamacion__c)){

                        accionesAux = accionesCaso.get(accionToDelete.SAC_Reclamacion__c);
                    }
    
                    accionesAux.add(accionToDelete);
                    accionesCaso.put(accionToDelete.SAC_Reclamacion__c, accionesAux);
                }  
            }     

            //Rellenar mapa permisosUsuario
            for(SAC_Accion__Share shareToDelete : sharesToDelete){

                List<SAC_Accion__Share> sharesAux = new List<SAC_Accion__Share>();

                if(permisosUsuario.containsKey(shareToDelete.UserOrGroupId)){

                    sharesAux = permisosUsuario.get(shareToDelete.UserOrGroupId);

                }

                sharesAux.add(shareToDelete);
                permisosUsuario.put(shareToDelete.UserOrGroupId, sharesAux);

            }

            //Crear lista para sacar los permisos a borrar
            for(Id idUsuario : permisosUsuario.keySet()){

                for(SAC_Accion__Share permiso : permisosUsuario.get(idUsuario)){

                    if(permiso.Parent.SAC_Pretension__c != null){

                        if(accionesCaso.containsKey(permiso.Parent.SAC_Pretension__c)){

                            permisosBorrar.add(permiso);
                        }
                    }else{

                        if(accionesCaso.containsKey(permiso.Parent.SAC_Reclamacion__c)){

                            permisosBorrar.add(permiso);

                        }
                    }    
                }
            }

            Database.delete(permisosBorrar,false);
        }

        //Creación y asiganción al nuevo propietario de las sharing rules
        for(Case reclamacion : listaCasosNuevos){

            if(casoAcciones.containsKey(reclamacion.id)){

                List<SAC_Accion__c> accionesValor = casoAcciones.get(reclamacion.id);

                    for(SAC_Accion__c accionesPermitir : accionesValor){

                        accionesShare.add(new SAC_Accion__Share(
                            ParentId = accionesPermitir.id,
                            UserOrGroupId = reclamacion.OwnerId,
                            AccessLevel = 'Edit'
                        ));
                    }
                }
            } 
        return accionesShare;
    }

     /**************************************************************************
     * Proposito: Darle permisos de edición sobre una NUEVA tarea al propietario actual de una pretensión/reclamación
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            DE53083          Daniel Benito    25/10/2021   Creación
    **************************************************************************/    

   public static void permisosNuevaAccionPropietario(List<SAC_Accion__c> listaAccionesNuevas){

    system.debug('etra en el método permisos' + listaAccionesNuevas);

        Map<Id,List<SAC_Accion__c>> casoAcciones = new Map<Id,List<SAC_Accion__c>>();
        List<SAC_Accion__Share> accionesShare = new List<SAC_Accion__Share>();
        List<Id> idsCase = new List<Id>();

        for(SAC_Accion__c accion : listaAccionesNuevas){

            if(accion.SAC_Reclamacion__c != null){

                idsCase.add(accion.SAC_Reclamacion__c);

            }

            if(accion.SAC_Pretension__c != null){

                idsCase.add(accion.SAC_Pretension__c);

            }
        }

        List<Case> casosPadres = [SELECT Id, OwnerId FROM CASE WHERE id IN: idsCase];

        for(SAC_Accion__c accion : listaAccionesNuevas){

            List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();

            if(accion.SAC_Reclamacion__c != null){

                if(casoAcciones.containsKey(accion.SAC_Reclamacion__c)){

                    accionesAux = casoAcciones.get(accion.SAC_Reclamacion__c);

                }

                accionesAux.add(accion);
                casoAcciones.put(accion.SAC_Reclamacion__c, accionesAux);

            }else if(accion.SAC_Pretension__c != null){

                if(casoAcciones.containsKey(accion.SAC_Pretension__c)){

                    accionesAux = casoAcciones.get(accion.SAC_Pretension__c);

                }

                accionesAux.add(accion);
                casoAcciones.put(accion.SAC_Pretension__c, accionesAux);

            }
        }

        for(Case casoPadre : casosPadres){

            if(casoAcciones.containsKey(casoPadre.id)){
    
                List<SAC_Accion__c> accionesValor = casoAcciones.get(casoPadre.id);
    
                for(SAC_Accion__c accionesPermitir : accionesValor){
    
                    accionesShare.add(new SAC_Accion__Share(
                        ParentId = accionesPermitir.id,
                        UserOrGroupId = casoPadre.OwnerId,
                        AccessLevel = 'Edit'
                    ));
                }
            }    
        }

        Database.insert(accionesShare, false);
    }
}