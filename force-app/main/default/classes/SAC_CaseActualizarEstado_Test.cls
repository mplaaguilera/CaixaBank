@isTest
public with sharing class SAC_CaseActualizarEstado_Test {
	@TestSetup
	static void makeData() {

		//Usuario con perfil SAC_General para ejecutar la acción
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
		usuarioGeneral.Email = 'email@test.com';
		Database.insert(usuarioGeneral);

		PermissionSet ps = [select id from PermissionSet where PermissionSet.Label = 'SAC_General'];
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
		Database.insert(psa);

	}

	@isTest
	static void actualizarEstadoReclamacionRedaccion() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Alta (SAC_001)
		 * P1:			Alta (SAC_001) --> Redacción(SAC_003)
		 * P2:			Alta (SAC_001)
		 * P3:			Alta (SAC_001) 
		 *****************************************************************/
		generateData('SAC_001', 'SAC_001', 'SAC_001', 'SAC_001', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'Pretension1'];
			casoParaModificar.Status = 'SAC_003'; //Redacción
			casoParaModificar.SAC_StatusAuxiliar__c = 'SAC_003';
			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_003', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}

	@isTest
	static void actualizarEstadoReclamacionInadmision() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Alta (SAC_001)
		 * P1:			Alta (SAC_001) --> Redaccion(SAC_003)
		 * P2:			Baja (SAC_009)
		 * P3:			Baja (SAC_009) 
		 *****************************************************************/
		generateData('SAC_001', 'SAC_001', 'SAC_009', 'SAC_009', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'Pretension1'];
			casoParaModificar.Status = 'SAC_003'; //Redaccion
			casoParaModificar.SAC_StatusAuxiliar__c = 'SAC_003';
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_004';
			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_003', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}


	@isTest
	static void actualizarEstadoReclamacionInadmision2() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Redaccion (SAC_003)
		 * P1:			Alta (SAC_001) --> Redaccion(SAC_003)
		 * P2:			Redaccion (SAC_003)
		 * P3:			Redaccion (SAC_003) 
		 *****************************************************************/
		generateData('SAC_003', 'SAC_001', 'SAC_003', 'SAC_003', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'Pretension1'];
			casoParaModificar.Status = 'SAC_003'; //Redaccion
			casoParaModificar.SAC_StatusAuxiliar__c = 'SAC_003';
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_004';
 
			List<Case> casosPreUpdate = new List<Case>();
			Case casoParaModificar2 = new Case();
			casoParaModificar2 = [SELECT id, SAC_Reclamacion__c, Subject, Status, SAC_SentidoResolucion__c FROM Case WHERE SuppliedCompany = 'Pretension2'];
			casoParaModificar2.SAC_SentidoResolucion__c = 'SAC_004';
			casosPreUpdate.add(casoParaModificar2);
			Case casoParaModificar3 = new Case();
			casoParaModificar3 = [SELECT id, SAC_Reclamacion__c, Subject, Status, SAC_SentidoResolucion__c FROM Case WHERE SuppliedCompany = 'pretension3'];
			casoParaModificar3.SAC_SentidoResolucion__c = 'SAC_004';
			casosPreUpdate.add(casoParaModificar3);
			Case casoParaModificar4 = new Case();
			casoParaModificar4 = [SELECT id, Subject, Status FROM Case WHERE Subject = 'Reclamacion'];
			casoParaModificar4.SAC_PretensionPrincipal__c = casoParaModificar.id;
			casosPreUpdate.add(casoParaModificar4);
			Database.update(casosPreUpdate);

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_003', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}


	@isTest
	static void actualizarEstadoReclamacionAnalisis() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Redacción (SAC_003)
		 * P1:			Redacción (SAC_003)
		 * P2:			Alta (SAC_001) --> Análisis(SAC_002)
		 * P3:			Alta (SAC_001) 
		 *****************************************************************/
		generateData('SAC_003', 'SAC_003', 'SAC_001', 'SAC_001', usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status,RecordTypeId FROM Case WHERE SuppliedCompany = 'Pretension2'];
			casoParaModificar.Status = 'SAC_002'; //Análisis
			casoParaModificar.SAC_StatusAuxiliar__c = casoParaModificar.Status;

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_002', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}

	/*@isTest
	static void actualizarEstadoReclamacion_Negociacion() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Análisis (SAC_002)
		 * P1:			Redacción (SAC_003)
		 * P2:			Análisis (SAC_002)
		 * P3:			Alta (SAC_001) --> Negociación(SAC_007)
		 *****************************************************************/
		/*generateData('SAC_002', 'SAC_003', 'SAC_002', 'SAC_001', usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'Pretension3'];
			casoParaModificar.Status = 'SAC_007'; //Negociación

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			update casoParaModificar;
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_002', reclamacion[0].Status);
	}

	@isTest
	static void actualizarEstadoReclamacion_Subsanacion() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Negociación (SAC_007)
		 * P1:			Redacción (SAC_003)
		 * P2:			Análisis (SAC_002) --> Subsanación(SAC_006)
		 * P3:			Negociación (SAC_007) 
		 *****************************************************************/
		/*generateData('SAC_007', 'SAC_003', 'SAC_002', 'SAC_007', usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, CC_Importe_Reclamado__c, Status FROM Case WHERE SuppliedCompany = 'Pretension2'];
			casoParaModificar.Status = 'SAC_006'; //Subsanación
			
			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			update casoParaModificar;
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_006', reclamacion[0].Status);
	}*/

	@isTest
	static void actualizarEstadoReclamacionBaja() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Negociación (SAC_007)
		 * P1:			Redacción (SAC_003)
		 * P2:			Subsanación (SAC_002) --> Análisis(SAC_002)
		 * P3:			Baja (SAC_009) 
		 *****************************************************************/
		generateData('SAC_007', 'SAC_003', 'SAC_002', 'SAC_009', usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, CC_Importe_Reclamado__c, Status FROM Case WHERE SuppliedCompany = 'Pretension2'];
			casoParaModificar.Status = 'SAC_002'; //Análisis
			casoParaModificar.SAC_StatusAuxiliar__c = casoParaModificar.Status;
			
			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_007', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}

	@isTest
	static void actualizarEstadoReclamacionSameStatus() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Análisis (SAC_002)
		 * P1:			Negociación (SAC_007)
		 * P2:			Negociación (SAC_007)
		 * P3:			Alta (SAC_001) --> Negociación (SAC_007)
		 *****************************************************************/
		generateData('SAC_002', 'SAC_007', 'SAC_007', 'SAC_001', usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, CC_Importe_Reclamado__c, Status FROM Case WHERE SuppliedCompany = 'Pretension3'];
			casoParaModificar.Status = 'SAC_007'; //Negociación
			casoParaModificar.SAC_StatusAuxiliar__c = casoParaModificar.Status;
			
			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_007', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}

	@isTest
	static void actualizarEstadoReclamacionUniPretension() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Análisis (SAC_002)
		 * P1:			Análisis (SAC_002) --> Redacción (SAC_003)
		 *****************************************************************/
		generateData('SAC_002', 'SAC_002', null, null, usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'Pretension1'];
			casoParaModificar.Status = 'SAC_003'; //Redacción
			casoParaModificar.SAC_StatusAuxiliar__c = casoParaModificar.Status;

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_003', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}
	@isTest
	static void actualizarEstadoReclamacionUniPretensionAlta() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Análisis (SAC_002)
		 * P1:			Alta (SAC_001) --> Redacción (SAC_003)
		 *****************************************************************/
		generateData('SAC_002', 'SAC_001', null, null, usuario.Id);

		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'Pretension1'];
			casoParaModificar.Status = 'SAC_003'; //Redacción
			casoParaModificar.SAC_StatusAuxiliar__c = casoParaModificar.Status;

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		System.assertEquals('SAC_003', reclamacion[0].Status, 'El estado de la reclamación no ha sido cambiado correctamente');
	}

	private static void generateData(String statusRecl, String statusPre1, String statusPre2, String statusPre3, Id userId) {
		String recordTypeIdMCCSAC = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

		//Reclamación Padre
		Case reclamacion = new Case();
		reclamacion.Subject = 'Reclamacion';
		reclamacion.Status = statusRecl;
		reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
		reclamacion.SAC_TipoConsumidor__c = 'Sí';
		reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		reclamacion.OwnerId = userId;
		reclamacion.SAC_Naturaleza__c = 'SAC_004';
		Database.insert(reclamacion);
		
        CC_MCC__c mccDetalle = new CC_MCC__c(Name='Banca Electrónica', CC_Codigo_Externo__c='d', RecordTypeId=recordTypeIdMCCSAC, CC_Tipo_Cliente__c='SAC');
        insert mccDetalle;

		List<Case> lstPretensiones = new List<Case> ();
		//Pretensiones
		if(String.isNotEmpty(statusPre1)){
			Case pretension1 = new Case();
			pretension1.SAC_Reclamacion__c = reclamacion.id;
			pretension1.SuppliedCompany = 'Pretension1';
			pretension1.CC_Importe_Reclamado__c = 0;
			pretension1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension1.OwnerId = userId;
			pretension1.Status = statusPre1;
			pretension1.SAC_StatusAuxiliar__c = pretension1.Status;
			pretension1.SEG_Detalle__c=mccDetalle.id;
			pretension1.SAC_Reclamacion__c = reclamacion.Id;
			lstPretensiones.add(pretension1);
		}
		
		if(String.isNotEmpty(statusPre2)){
			Case pretension2 = new Case();
			pretension2.SAC_Reclamacion__c = reclamacion.id;
			pretension2.SuppliedCompany = 'Pretension2';
			pretension2.CC_Importe_Reclamado__c = 0;
			pretension2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension2.OwnerId = userId;
			pretension2.Status = statusPre2;
			pretension2.SAC_StatusAuxiliar__c = pretension2.Status;
			pretension2.SEG_Detalle__c=mccDetalle.id;
			pretension2.SAC_Reclamacion__c = reclamacion.Id;
			lstPretensiones.add(pretension2);
		}
		if(String.isNotEmpty(statusPre3)){
			Case pretension3 = new Case();
			pretension3.SAC_Reclamacion__c = reclamacion.id;
			pretension3.SuppliedCompany = 'pretension3';
			pretension3.CC_Importe_Reclamado__c = 200;
			pretension3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension3.OwnerId = userId;
			pretension3.Status = statusPre3;
			pretension3.SAC_StatusAuxiliar__c = pretension3.Status;
			pretension3.SEG_Detalle__c=mccDetalle.id;
			pretension3.SAC_Reclamacion__c = reclamacion.Id;
			lstPretensiones.add(pretension3);
		}
		if(lstPretensiones.size()>0){
			Database.insert(lstPretensiones);
		}
	}
}