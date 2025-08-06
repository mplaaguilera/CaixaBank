/*****************************************************************
 * Name: SAC_AsignarVF
 * Copyright © 2021  CaixaBank
 * 
 * Proposito:  Controlador del botón de Asignar a
 *             desde la Lista de vista del objeto SAC_Accion__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0              		    Daniel Benito   12/01/22      Creación
*****************************************************************/

public without sharing class SAC_AsignarVF {

    
    public class MyException extends Exception {}
   
    public List<SAC_Accion__C> listaAcciones{get;private set;}
    public boolean mostrar {get; set;}
    public Id idUsuario {get; set;}
    public List<SAC_Accion__c> listaTareas;
    public Id idNuevoPropietario {get; set;}
    public List<CC_Grupo_Colaborador_Contact__c> equipoResolutor = new List<CC_Grupo_Colaborador_Contact__c>();
    public List<SelectOption> contactlist{get; set;}
    public String selectedUser {get; set;}

    public SAC_AsignarVF(ApexPages.StandardSetController stdSetController){  

        listaAcciones = (List<SAC_Accion__C>) stdSetController.getSelected();
        idNuevoPropietario = null;

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
        String equipo = 'primero';
        Boolean equiposDiferentes = false;
        Set<Id> gruposResponsables = new Set<Id>();
        Map<Id,String> mapaGrupos = new Map<Id,String>(); 
        listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_Prorroga__c, SAC_FechaVencimientoProrroga__c, SAC_FechaVencimientoInicial__c, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c
                                        FROM SAC_Accion__c 
                                        WHERE id = :listaAcciones ];

        for(SAC_Accion__c tarea : listaTareas){

            if(equipo != 'primero' && equipo != tarea.SAC_EquipoResponsable__c){

                equiposDiferentes = true;
            }
            equipo = tarea.SAC_EquipoResponsable__c;
            gruposResponsables.add(tarea.SAC_EquipoResponsable__c);
        }

        if(equiposDiferentes){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Debes seleccionar tareas que pertenecen al mismo equipo'));

        }else{

        mapaGrupos=SAC_AccionMetodos.usarioMismoGrupoTareaAdm(gruposResponsables, idUsuario);

        try {      

            for (SAC_Accion__c tarea : listaTareas) {
                if(!SAC_AccionMetodos.laTareaEstaViva(tarea)){
                    tareasMuertas = tareasMuertas + tarea.name  + ', ';
                } 
                if(mapaGrupos.get(tarea.SAC_EquipoResponsable__c) == null && tarea.OwnerId != idUsuario){
                    tareasSinPrivilegios = tareasSinPrivilegios + tarea.name;
                }                                               
            }

            if(tareasMuertas != ''){ 
                mensaje = mensaje + tareasMuertas + ' no estan vivas. ';
            }
            if(tareasSinPrivilegios != ''){ 
                mensaje = mensaje + ' No tiene privilegios para estas tareas. Necesita ser ADM del grupo resolutor y dueño de las tareas ' + tareasSinPrivilegios;
            }
            if(mensaje != '' ){
                throw new MyException( mensaje); 
            }else{
                mostrar=true; 

                List<CC_Grupo_Colaborador_Contact__c> equipoResolutor = [SELECT id,CC_Grupo_Colaborador__c,CC_Nombre__c, CC_Apellidos__c,CC_Usuario__r.Id
                FROM CC_Grupo_Colaborador_Contact__c
                WHERE CC_Grupo_Colaborador__c IN: gruposResponsables
                AND CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion'];

                contactlist = new List<SelectOption>();

                for(CC_Grupo_Colaborador_Contact__c con : equipoResolutor)
                {
                    String nombreApellido = con.CC_Nombre__c + ' ' + con.CC_Apellidos__c;
                    contactlist.add(new SelectOption(con.CC_Usuario__r.Id, nombreApellido));
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'Elige el próximo propietario para '+ listaAcciones.size() +' registros(Tareas).'));
            }
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
            mostrar=false;
        } 

    }
    }

    public PageReference save(){    

        SAC_AccionMetodos.tomarPropiedadMasivo(listaTareas, selectedUser);
             
       return new ApexPages.Action('{!List}').invoke();
    }

}