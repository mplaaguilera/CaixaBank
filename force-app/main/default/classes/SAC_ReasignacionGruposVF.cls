/*****************************************************************
 * Name: SAC_FinalizarTareaVF
 * Copyright © 2021  CaixaBank
 * 
 * Proposito:  Controlador del botón de Reasignación masiva de grupos
 *             desde la Lista de vista del objeto Case
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US308688         Luis Mesa     22/03/22        Creación
*****************************************************************/
public without sharing class SAC_ReasignacionGruposVF {

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

    public List<Case> listaCasos{get;private set;}
    public List<Case> listaSeleccionados{get; set;}
    public Id idUsuario {get; set;}
    public boolean mostrar {get; set;}
    public String selectedValor1 {get; set;}
    public String selectedValor2 {get; set;}
    public String decision {get; set;}
    public boolean perteneceACOPSAJ {get; set;}
    public boolean esUsuarioConPermisos {get; set;}
   
    //public String getGrupoSeleccionado {get; set;}
    //public List<CC_Grupo_Colaborador__c> grupos;
    //public String grupoSeleccionado {get; set;}

    List<selectOption> gruposProveedores = new List<selectOption>();
    List<selectOption> gruposLetrados = new List<selectOption>();

    public SAC_ReasignacionGruposVF(ApexPages.StandardSetController stdSetController) {
        listaCasos = (List<Case>) stdSetController.getSelected();
         
        if(listaCasos.isempty()){         
            mostrar = false;   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Debes seleccionar al menos un registro.'));
        }else{
             
            idUsuario =UserInfo.getUserId();
            perteneceACOPSAJ = SAC_TareasOperativas_Controller.perteneceCOPSAJ(idUsuario);
            esUsuarioConPermisos = comprobarLetrado(idUsuario); 

            if(perteneceACOPSAJ || esUsuarioConPermisos){
                mostrar = true;
                listaSeleccionados = [SELECT Id, CaseNumber, SEG_Grupo__c, OwnerId, Status FROM 
                Case WHERE (RecordTypeId =: RECTYPERECLAMACION OR RecordTypeId =: RECTYPEPRETENSION) AND Id IN: listaCasos];               
            }
            else{
                mostrar = false;   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No tiene permisos para realizar esta acción. '));
            }
            //comprobar(listaCasos);                     
        }
    }

	public List<selectOption> getGruposProveedores() { 
        Id tipoRegistroProveedor = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();  
        gruposProveedores.clear();
		for(CC_Grupo_Colaborador__c grupo : [SELECT Id, name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: tipoRegistroProveedor ORDER BY name ASC]) {
			gruposProveedores.add(new selectOption(grupo.id, grupo.name));
		}
		return gruposProveedores;
	}

    public List<selectOption> getGruposLetrados() {
        Id tipoRegistroLetrado = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();   
        gruposLetrados.clear();
		for(CC_Grupo_Colaborador__c grupo : [SELECT Id, name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId =: tipoRegistroLetrado ORDER BY name ASC]) {
			gruposLetrados.add(new selectOption(grupo.id, grupo.name));
		}
		return gruposLetrados;
	}

    public void modificarReclamaciones(String grupo, List<Case> listaCasos){ 

        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        Set<Id> ids = new Set<Id>();

        List<Case> listaAuxiliar = [SELECT Id, SAC_Reclamacion__c, RecordTypeId FROM Case WHERE (RecordTypeId =: RECTYPERECLAMACION OR RecordTypeId =: RECTYPEPRETENSION) AND Id IN: listaCasos];

        for(Case caso : listaAuxiliar){
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                ids.add(caso.Id);
            }
            else if(caso.RecordTypeId == RECTYPEPRETENSION){
                ids.add(caso.SAC_Reclamacion__c);
            }
        }

        if(!ids.isempty()){
            List<Case> casosAModificar = [SELECT Id, SEG_Grupo__c, OwnerId 
                                            FROM Case 
                                            WHERE RecordTypeId =: RECTYPERECLAMACION
                                                AND Id IN: ids];


            for(Case caso : casosAModificar){ 
                caso.SEG_Grupo__c = grupo;
                caso.OwnerId = cola.Id;
            } 
            update casosAModificar;
        }
        
    }

    public void  modificarPretensiones(String grupo, List<Case> listaCasos){
         
        mostrar = false;
        Set<Id> ids = new Set<Id>();
        Set<Id> setDeGrupos = new Set<Id>();
        List<Case> casosAUpdatear = new List<Case>();

        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        
        List<Case> listaAuxiliar = [SELECT Id, SEG_Grupo__c, SAC_Reclamacion__c, SAC_Reclamacion__r.SEG_Grupo__c, RecordTypeId 
        FROM Case WHERE (RecordTypeId =: RECTYPERECLAMACION OR RecordTypeId =: RECTYPEPRETENSION) AND Id IN: listaCasos];

        for(Case caso : listaAuxiliar){
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                ids.add(caso.Id);
            }
            else if(caso.RecordTypeId == RECTYPEPRETENSION){
                ids.add(caso.SAC_Reclamacion__c);
            }

            //Añadir los grupos en un set para buscar los CC_Grupo_Colaborador_Contact__c
            setDeGrupos.add(caso.SEG_Grupo__c); 
        }

        if(!ids.isEmpty()){ 
            List<Case> casosAModificar = [SELECT Id, SAC_Reclamacion__c, SEG_Grupo__c, OwnerId, SAC_Reclamacion__r.SEG_Grupo__c
                                            FROM Case 
                                            WHERE RecordTypeId =: RECTYPEPRETENSION
                                                AND SAC_Reclamacion__c IN: ids];
            

            //Si pertenece a COPS o AJ, puede cambiar los grupos de las pretensiones
            if (perteneceACOPSAJ) {
                
                for(Case caso : casosAModificar){                    
                    caso.SEG_Grupo__c = grupo;
                    caso.OwnerId = cola.Id;
                    casosAUpdatear.add(caso);
                }

                //Si no pertenece a COPS o AJ pero es admin de un grupo letrados, o admin del grupo proveedor de la reclamacion se comprueba si es el admin de dicho grupo y realmente puede
            } else if (esUsuarioConPermisos) { 
                //Buscar los CC_Grupo_Colaborador_Contact__c en los que el usuario sea el ejecutor de la acción, que el grupo sea el de los casos a modificar y que el check de administrador esté en true
                List<CC_Grupo_Colaborador_Contact__c> listaGCC = [SELECT Id, CC_Grupo_Colaborador__c 
                                                        FROM CC_Grupo_Colaborador_Contact__c 
                                                        WHERE CC_Usuario__c =:idUsuario 
                                                        AND CC_Grupo_Colaborador__c =:setDeGrupos AND SAC_Administrador__c =true];
                                                        
                Set<Id> gruposEncontrados = new Set<Id>();
    
                if (!listaGCC.isEmpty()) {
                    for (CC_Grupo_Colaborador_Contact__c gccAux : listaGCC) {
                        gruposEncontrados.add(gccAux.CC_Grupo_Colaborador__c);
                    }    
                }
                
    
                if(!gruposEncontrados.isEmpty()){
                    for(Case caso : casosAModificar){
                        if (gruposEncontrados.contains(caso.SEG_Grupo__c) || gruposEncontrados.contains(caso.SAC_Reclamacion__r.SEG_Grupo__c)){
                            caso.SEG_Grupo__c = grupo;
                            caso.OwnerId = cola.Id;
                            casosAUpdatear.add(caso);
                        }
                    }
                }
            }

            if(!casosAUpdatear.isEmpty()){
                update casosAUpdatear;
                mostrar = true;
            }
        }               
    }       
    

    public PageReference save(){
        
        //reclamaciones a cambiar
        //al seleccionar desde la reclamacion que se quiere modificar las pretensiones; modificar todas las pretensiones que contiene la reclamacion, con el grupo seleccionado y el propietario a pdt asignar
        //system.debug('debug decicion ' + decision);
        if(decision == 'Reclamaciones' && perteneceACOPSAJ){
            modificarReclamaciones(selectedValor1, listaCasos);      
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Modificación aplicada.'));
            return new ApexPages.Action('{!List}').invoke();      
        }else if(decision == 'Pretensiones' && (perteneceACOPSAJ || esUsuarioConPermisos)){
           
            modificarPretensiones(selectedValor2, listaCasos);

            if (mostrar) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Modificación aplicada.'));
                return new ApexPages.Action('{!List}').invoke();
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No tiene permisos para esta acción'));
                return null;
            }
            
        }else{
            mostrar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No tiene permisos para esta acción'));
            return null;
        }
        
    }

    public Boolean comprobarLetrado(Id letrado){

        List<PermissionSetAssignment> listaPSA = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
                                                    FROM PermissionSetAssignment WHERE Assignee.Id =:letrado AND PermissionSet.Name = 'SAC_AdministradorGrupos'];

                                                    System.debug(listaPSA);
        return !listaPSA.isEmpty();
    }

}