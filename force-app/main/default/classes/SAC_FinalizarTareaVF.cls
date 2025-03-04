/*****************************************************************
 * Name: SAC_FinalizarTareaVF
 * Copyright © 2021  CaixaBank
 * 
 * Proposito:  Controlador del botón de Finalizar Tarea  Masiva
 *             desde la Lista de vista del objeto SAC_Accion__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0              US204745    Marcela Neira   13/07/21        Creación
*****************************************************************/
public without sharing class SAC_FinalizarTareaVF {

    public class MyException extends Exception {}

    public List<SAC_Accion__C> listaAcciones{get;private set;}
    public boolean mostrar {get; set;}
    public Id idUsuario {get; set;}
    public String  observaciones {get; set;}
    public List<SAC_Accion__c> listaTareas;


    public SAC_FinalizarTareaVF(ApexPages.StandardSetController stdSetController) {
        listaAcciones = (List<SAC_Accion__C>) stdSetController.getSelected();

        if(listaAcciones.isempty()){            
            mostrar=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Debes seleccionar al menos un registro.'));
        }else{
            idUsuario =UserInfo.getUserId();
            comprobar(listaAcciones);                     
        }
    }

    public void comprobar(List<SAC_Accion__c> listaAcciones){
        String mensaje='';    
        String tareasMuertas = '';     
        String tareasSinPrivilegios= '';
        String tareasPteGGH = '';
        String tareasImpAbonado = '';
        Set<Id> gruposResponsables = new Set<Id>();
        Set<Id> gruposUser = new Set<Id>();
        Map<Id,String> mapaGrupos = new Map<Id,String>(); 
        listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c,
                              SAC_Reclamacion__r.SAC_SentidoResolucion__c, SAC_ImporteAbonar__c
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
                if(tarea.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'GGH' && tarea.SAC_Estado__c == 'SAC_PendienteRevision'){
                    tareasPteGGH = tareasPteGGH + tarea.name + ', ';
                }
                if(tarea.SAC_ImporteAbonar__c != null && tarea.SAC_ImporteAbonar__c != 0 && (tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_001' || tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_004' || tarea.SAC_Reclamacion__r.SAC_SentidoResolucion__c == 'SAC_005')){
                    tareasImpAbonado = tareasImpAbonado + tarea.Name + ', ';
                }                                         
            }
            if(tareasMuertas != ''){ 
                mensaje = mensaje + tareasMuertas + ' no estan vivas. ';
            }
            if(tareasSinPrivilegios != ''){ 
                mensaje = mensaje + tareasSinPrivilegios + ' no tiene privilegios para estas tareas. ';
            }
            if(tareasPteGGH != ''){
                mensaje = mensaje + tareasPteGGH + ' no se puede finalizar, está pendiente de otro sistema. ';
            }
            if(tareasImpAbonado != ''){
                mensaje = mensaje + tareasImpAbonado + ' no se puede finalizar, revise el sentido de la resolución de la reclamación. No es posible indicar sentido de la resolución "Favorable a la entidad" "Inadmisión" o "Desistimiento" e informar un importe abonado. ';
            }
            if(mensaje != '' ){
                throw new MyException( mensaje); 
            }else{
                mostrar=true;  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'Se Finalizaran '+ listaAcciones.size() +' registros (Tareas).'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
            mostrar=false;
        } 
    }

    public PageReference save(){
        String observaciones = apexpages.currentPage().getParameters().get('observaciones');
        List<SAC_Accion__c> tareasSinAsignar = new List<SAC_Accion__c>();
        List<Id> idsTareas = new List<Id>();
        
        for(SAC_Accion__c tarea : listaTareas){ 
            if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar' || tarea.SAC_Estado__c == 'SAC_PendienteAsignar'){
                tareasSinAsignar.add(tarea);
            }
            idsTareas.add(tarea.id);
        }
        SAC_AccionMetodos.tomarPropiedadMasivo(tareasSinAsignar, idUsuario);

        if(String.isNotBlank(observaciones)){
            if(System.IsBatch() == false && System.isFuture() == false ){
                if(observaciones == 'sincomentarios') {
                    SAC_AccionMetodos.finalizarTareaFuture(idsTareas, idUsuario, '');
                }else{
                    SAC_AccionMetodos.finalizarTareaFuture(idsTareas, idUsuario, observaciones);
                }   
            }
            return new ApexPages.Action('{!List}').invoke();
        }       
        
        return new ApexPages.Action('{!List}').invoke();        
    }

}