@isTest
public with sharing class AM_Case_RelParentCase_Controller_Test {

    @isTest
    public static void validarCamposTest()
    {
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-00000112';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-00000121';
        insert mccProducto;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-0000012';
        insert mccMotivo;

        Id recordTypeCasoPadre = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Parent_Case').getRecordTypeId();
        Case casoPadre = new Case();
        casoPadre.Subject='Caso Padre';
        casoPadre.recordtypeId= recordTypeCasoPadre;
        casoPadre.Origin='Email';
        casoPadre.CC_Canal_Procedencia__c = 'Buzón Carteras';
        casoPadre.CC_Tipo_Contacto__c = 'Operativa';
        casoPadre.CC_En_Tercer_Nivel__c=true;
        casoPadre.Status='Activo';
        insert casoPadre;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(recordtypeId = recordTypeCaso, CC_Idioma__c = null));
        caseList.add(new Case(recordtypeId = recordTypeCaso, Origin = 'Email', CC_Detalles_Consulta__c= 'AAAAA', CC_Canal_Procedencia__c = 'Buzón Carteras', CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = mccTematica.Id, CC_MCC_ProdServ__c = mccProducto.Id, CC_MCC_Motivo__c = mccMotivo.Id));
        insert caseList;

        // Todos los campos fallan, excepto el que requiere una comprobación a los MCCs
        List<String> invalidFieldsList = AM_Case_RelacionarParentCase_Controller.validarCampos(caseList[0].Id, casoPadre.Id);
        System.assertEquals(8, invalidFieldsList.size());

        // Sólo falla que el MCC se encuentra inactivo
        invalidFieldsList = AM_Case_RelacionarParentCase_Controller.validarCampos(caseList[1].Id, casoPadre.Id);
        System.assertEquals(2, invalidFieldsList.size());
        System.assertEquals('Cuenta y Contacto', invalidFieldsList[0]);
    }
}