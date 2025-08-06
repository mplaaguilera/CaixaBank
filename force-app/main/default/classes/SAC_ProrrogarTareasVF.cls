/*****************************************************************
 * Name: SAC_ProrrogarTareasVF
 * Copyright © 2021  CaixaBank  
 * 
 * Proposito:  Controlador del botón de Prorrogar Masiva
 *             desde la Lista de vista del objeto SAC_Accion__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0              US204756    Marcela Neira   26/07/21        Creación
*****************************************************************/
public without sharing class SAC_ProrrogarTareasVF {
    public class MyException extends Exception {}
   
    public List<SAC_Accion__C> listaAcciones{get;private set;}
    public boolean mostrar {get; set;}
    public Id idUsuario {get; set;}
    public List<SAC_Accion__c> listaTareas;

    
    public SAC_ProrrogarTareasVF(ApexPages.StandardSetController stdSetController){  

        listaAcciones = (List<SAC_Accion__C>) stdSetController.getSelected();

        if(listaAcciones.isempty()){            
            mostrar=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Debes seleccionar al menos un registro.'));
        }else{                   
            idUsuario =UserInfo.getUserId();  
            comprobar();            
        }
    }

    public void comprobar(){
        String mensaje='';    
        String tareasMuertas = ''; 
        String tareasSinPrivilegios= '';
        String tareasVtoProrrogaSuperado= '';
        Set<Id> gruposResponsables = new Set<Id>();
        Set<Id> gruposUser = new Set<Id>();
        Map<Id,String> mapaGrupos = new Map<Id,String>(); 
        listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_Prorroga__c, SAC_FechaVencimientoProrroga__c, 
                            SAC_FechaVencimientoInicial__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c
                        FROM SAC_Accion__c 
                        WHERE id = :listaAcciones ];

        Boolean puedeSerPropietario = SAC_TareasOperativas_Controller.perteneceCOPSAJ(idUsuario);  

        List<CC_Grupo_Colaborador_Contact__c> colabContactUser = [SELECT id, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c=:idUsuario];

        for (CC_Grupo_Colaborador_Contact__c grupo : colabContactUser) {
            gruposUser.add(grupo.CC_Grupo_Colaborador__c);
        }

        for(SAC_Accion__c tarea : listaTareas){ 
            gruposResponsables.add(tarea.SAC_EquipoResponsable__c);
        }

        mapaGrupos=SAC_AccionMetodos.usarioMismoGrupoTarea(gruposResponsables, idUsuario);

        try {      

            for (SAC_Accion__c tarea : listaTareas) {
                if(!SAC_AccionMetodos.laTareaEstaViva(tarea)){
                    tareasMuertas = tareasMuertas + tarea.name  + ', ';
                } 
                if((!puedeSerPropietario && !(gruposUser.contains(tarea.SAC_Reclamacion__r.SEG_Grupo__c) || gruposUser.contains(tarea.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c))) && mapaGrupos.get(tarea.SAC_EquipoResponsable__c) == null ){
                    tareasSinPrivilegios = tareasSinPrivilegios + tarea.name  + ', ';
                }    
                if(tarea.SAC_FechaVencimientoProrroga__c < Date.today()){
                    tareasVtoProrrogaSuperado = tareasVtoProrrogaSuperado + tarea.name  + ', '; 
                }                                            
            }

            if(tareasMuertas != ''){ 
                mensaje = mensaje + tareasMuertas + ' no estan vivas. ';
            }
            if(tareasSinPrivilegios != ''){ 
                mensaje = mensaje + tareasSinPrivilegios + ' no tiene privilegios para estas tareas. ';
            }

            if(tareasVtoProrrogaSuperado != ''){ 
                mensaje = mensaje + tareasVtoProrrogaSuperado + ' ha superado la fecha de vencimiento de prorroga. '; 
            }
            
            if(mensaje != '' ){
                throw new MyException( mensaje); 
            }else{
                mostrar=true;  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'Se prorrogarán '+ listaAcciones.size() +' registros (Tareas).'));
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
            mostrar=false;
        } 
    }

    public PageReference save(){    
        
        SAC_AccionMetodos.prorrogarTarea(listaTareas);
             
       return new ApexPages.Action('{!List}').invoke();
    }

}