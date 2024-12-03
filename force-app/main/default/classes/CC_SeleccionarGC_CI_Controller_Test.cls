@IsTest
public class CC_SeleccionarGC_CI_Controller_Test {
    
    @isTest
    static void getMCCGrupoList_test(){
        
        Id sRecordType = Schema.getGlobalDescribe().get('CC_Agrupador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        
        //Creación de los MCCs
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
    	mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
         CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        
        insert mccMotivo;
 
    	//Creación del Agrupador
        CC_Agrupador__c  agrupador = new CC_Agrupador__c ();
        agrupador.recordTypeId = sRecordType;
        agrupador.CC_Estado__c = 'Activo';
        agrupador.CC_Titulo__c = 'Grupo Colaborador CI Test';
        agrupador.CC_Tematica_Id__c = mccTematica.Id;
        agrupador.CC_Producto_Servicio__c = mccProducto.Id;
        agrupador.CC_Motivo__c = mccMotivo.Id;
        
        insert agrupador;
        
        
        //Creación del Grupo Colaborador
        Id recordTypeIdGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c ();
        grupoColab.Name = 'Grupo Colaborador CI Test';
        grupoColab.recordTypeId = recordTypeIdGrupoColaborador;
        grupoColab.CC_External__c = 'CI-01000';
        Insert grupoColab;
        
        //Creación del MCC_GrupoColaborador
        CC_MCC_Grupo_Colaborador__c mccGC = new CC_MCC_Grupo_Colaborador__c();
        mccGC.CC_MCC__c = mccMotivo.Id;
        mccGC.CC_Grupo_Colaborador__c = grupoColab.Id;
        
        //Recuperamos la lista de valores que devuelve la función del controlador
        List<CC_SeleccionarGC_CI_Controller.pickListWrapper> valores = new List<CC_SeleccionarGC_CI_Controller.pickListWrapper> ();
        valores = CC_SeleccionarGC_CI_Controller.getMCCGrupoList(agrupador.Id);
        String valorName;
        Id valorId;
        if (!valores.isEmpty()){
            for (CC_SeleccionarGC_CI_Controller.pickListWrapper val: valores){
                valorName = val.label;
                valorId = val.value;
            }
        }
        
        
        System.assertEquals(valorName, agrupador.CC_Titulo__c);
        CC_SeleccionarGC_CI_Controller.updateAg (agrupador.Id, grupoColab.Id,grupoColab.Name);
        String nombreGC = CC_SeleccionarGC_CI_Controller.getNombreGrupoColaborador (agrupador.Id);
        System.assertEquals(nombreGC, grupoColab.Name);
    }

}