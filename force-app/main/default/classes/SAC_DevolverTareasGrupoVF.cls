/*****************************************************************
 * Name: SAC_DevolverTareasGrupoVF
 * Copyright © 2021  CaixaBank
 * 
 * Proposito:  Controlador del botón de Devolver al grupo masivo
 *             desde la Lista de vista del objeto SAC_Accion__c,
 *             esta clase la testea SAC_AccionVF_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             TA412863    Marcela Neira     18/11/21        Creación
*****************************************************************/
public without sharing class SAC_DevolverTareasGrupoVF {
    public class MyException extends Exception {}
   
    public List<SAC_Accion__C> listaAcciones{get;private set;}
    public boolean mostrar {get; set;}
    public Id idUsuario {get; set;}
    public List<SAC_Accion__c> listaTareas;

    public SAC_DevolverTareasGrupoVF(ApexPages.StandardSetController stdSetController) {
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
        Set<Id> gruposResponsables = new Set<Id>();
        Map<Id,String> mapaGrupos = new Map<Id,String>(); 
        listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_Prorroga__c, SAC_FechaVencimientoProrroga__c, SAC_FechaVencimientoInicial__c, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c
                                        FROM SAC_Accion__c 
                                        WHERE id = :listaAcciones ];

        /*Boolean puedeSerPropietario = SAC_TareasOperativas_Controller.perteneceCOPSAJ(idUsuario);  

        System.debug('puedeSerPropietario' + puedeSerPropietario);

        for(SAC_Accion__c tarea : listaTareas){ 
            gruposResponsables.add(tarea.SAC_EquipoResponsable__c);
        }

        mapaGrupos=SAC_AccionMetodos.usarioMismoGrupoTarea(gruposResponsables, idUsuario);*/

        try {      

            for (SAC_Accion__c tarea : listaTareas) {
                if(!SAC_AccionMetodos.laTareaEstaViva(tarea)){
                    tareasMuertas = tareasMuertas + tarea.name  + ', ';
                } 
                if(tarea.OwnerId != idUsuario){
                    tareasSinPrivilegios = tareasSinPrivilegios + tarea.name  + ', ';
                }                                               
            }

            if(tareasMuertas != ''){ 
                mensaje = mensaje + tareasMuertas + ' no estan vivas. ';
            }
            if(tareasSinPrivilegios != ''){ 
                mensaje = mensaje + tareasSinPrivilegios + ' no tiene privilegios para estas tareas. ';
            }
            if(mensaje != '' ){
                throw new MyException( mensaje); 
            }else{
                mostrar=true;  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'Se devolverán '+ listaAcciones.size() +' registros (Tareas).'));
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
            mostrar=false;
        } 
    }

    public PageReference save(){    
        
        SAC_AccionMetodos.devolverTareas(listaTareas);
             
       return new ApexPages.Action('{!List}').invoke();
    }
}