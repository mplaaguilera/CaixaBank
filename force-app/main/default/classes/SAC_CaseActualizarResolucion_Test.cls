@isTest
public class SAC_CaseActualizarResolucion_Test  {
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
	static void actualizarResolucionFavorableClienteParcialmente() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: A favor de la entidad (SAC_001)
		 * P1:			null --> A favor del cliente (SAC_003)
		 * P2:			A favor de la entidad (SAC_001)
		 * P3:			Inadmisión (SAC_004) 
		 *****************************************************************/

		generateData(null, null, 'SAC_001', 'SAC_004', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_003'; //A favor del cliente

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_002 -->Favorable al cliente parcialmente
		System.assertEquals('SAC_002', reclamacion[0].SAC_SentidoResolucion__c);
	}

	@isTest
	static void actualizarResolucionAFavorEntidad() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Inadmisión (SAC_004) 
		 * P1:			null --> A favor de la entidad (SAC_001)
		 * P2:			Inadmisión (SAC_004)
		 * P3:			Inadmisión (SAC_004) 
		 *****************************************************************/

		generateData('SAC_004', null, 'SAC_004', 'SAC_004', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			//casoParaModificar.SAC_SentidoResolucion__c = 'SAC_001'; //A favor de la entidad

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_002 -->A favor de la entidad
		System.assertEquals('SAC_004', reclamacion[0].SAC_SentidoResolucion__c);
	}

	@isTest
	static void actualizarResolucionAFavorCliente() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: A favor de la entidad (SAC_001)
		 * P1:			A favor de la entidad (SAC_001) --> A favor del cliente(SAC_003)
		 * P2:			Inadmisión (SAC_004)
		 * P3:			Inadmisión (SAC_004) 
		 *****************************************************************/

		 //SAC_001 -->A favor de la entidad
			//SAC_002 -->Favorable al cliente parcialmente
			//SAC_003 -->A favor del cliente	
			//SAC_004 -->Inadmisión

		generateData('SAC_001', 'SAC_001', 'SAC_004', 'SAC_004', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_003'; //A favor del cliente

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_002 -->Favorable al cliente parcialmente
		System.assertEquals('SAC_002', reclamacion[0].SAC_SentidoResolucion__c);
	}

	@isTest
	static void actualizarResolucionUniPretension() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: null 
		 * P1:			null --> Inadmisión(SAC_004)
		 *****************************************************************/

		generateData(null, null, 'Not create', 'Not create', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_004'; //Inadmisión

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_002 -->Inadmisión
		System.assertEquals('SAC_004', reclamacion[0].SAC_SentidoResolucion__c);
	}


	@isTest
	static void actualizarResolucionUniPretension2() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: null 
		 * P1:			null --> A favor de la entidad(SAC_001)
		 *****************************************************************/

		generateData(null, null, 'Not create', 'Not create', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_001'; //A favor de la entidad

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_001 -->A favor de la entidad
		System.assertEquals('SAC_001', reclamacion[0].SAC_SentidoResolucion__c);
	}

	@isTest
	static void tratarMultipretensionesInadmisionTest() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: A favor de la entidad (SAC_001)
		 * P1:			A favor de la entidad (SAC_001) --> A favor del cliente(SAC_003)
		 * P2:			Inadmisión (SAC_004)
		 * P3:			Inadmisión (SAC_004) 
		 *****************************************************************/

		 //SAC_001 -->A favor de la entidad
			//SAC_002 -->Favorable al cliente parcialmente
			//SAC_003 -->A favor del cliente	
			//SAC_004 -->Inadmisión

		generateData('SAC_001', 'SAC_001', 'SAC_004', 'SAC_004', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_004'; //Inadmisión

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_004 -->Inadmisión
		System.assertEquals('SAC_004', reclamacion[0].SAC_SentidoResolucion__c);
	}

	@isTest
	public static void actualizarEstadoReclamacionMultiPretension1Baja(){
		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		generateData('SAC_001', 'SAC_001', 'SAC_001', 'SAC_001', usuario.Id);
		List<Case> reclamacion;

		system.runAs(usuario) {
			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
			Case pretension4 = new Case();
			pretension4.SAC_Reclamacion__c = reclamacion[0].id;
			//pretension3.Subject = 'pretension3';
			pretension4.SuppliedCompany = 'prueba4';
			pretension4.CC_Importe_Reclamado__c = 200;
			pretension4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension4.OwnerId = usuario.Id;
			pretension4.SAC_SentidoResolucion__c = 'SAC_002';
			pretension4.status = 'SAC_009';

			Test.startTest();
			Database.insert(pretension4);
			Test.stopTest();
		}
		//SAC_004 -->Inadmisión
		System.assertEquals('SAC_001', reclamacion[0].SAC_SentidoResolucion__c);
	}

	@isTest
	static void tratarMultipretensionesDesistimiento() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;

		generateData('', 'SAC_001', 'SAC_005', 'SAC_004', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_004'; //Inadmisión
			casoParaModificar.SAC_MotivoInadmision__c = 'SAC_009';

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_004 -->Inadmisión
		System.assertEquals('SAC_004', reclamacion[0].SAC_SentidoResolucion__c);
	}


	@isTest
	static void tratarMultipretensiones2() {

		User usuario = [SELECT id FROM User WHERE Email = 'email@test.com' AND isActive = true];
		List<Case> reclamacion;
		/*****************************************************************
		 * Reclamacion: Inadmisión (SAC_004) 
		 * P1:			null --> A favor de la entidad (SAC_001)
		 * P2:			Inadmisión (SAC_004)
		 * P3:			Inadmisión (SAC_004) 
		 *****************************************************************/

		generateData('SAC_004', null, 'SAC_004', 'SAC_004', usuario.Id);
		system.runAs(usuario) {

			Case casoParaModificar = [SELECT id, SAC_Reclamacion__c,SAC_SentidoResolucion__c, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba1'];
			casoParaModificar.SAC_SentidoResolucion__c = 'SAC_001'; //A favor de la entidad

			SAC_Case_AU_TRHan.procesado=false;
			Test.startTest();
			Database.update(casoParaModificar);
			Test.stopTest();

			reclamacion = [SELECT id, Status, SAC_Reclamacion__c,SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamacion'];
		}
		//SAC_001 -->A favor de la entidad
		System.assertEquals('SAC_001', reclamacion[0].SAC_SentidoResolucion__c);
	}

	private static void generateData(String resolucionRecl, String resolucionPrel1, String resolucionPrel2, String resolucionPrel3, Id userId) {
		//Reclamación Padre
		Case reclamacion = new Case();
		reclamacion.Subject = 'Reclamacion';
		reclamacion.SAC_SentidoResolucion__c = resolucionRecl;
		reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		reclamacion.OwnerId = userId;
		reclamacion.SAC_TipoConsumidor__c = 'Si';
		Database.insert(reclamacion);

		List<Case> lstPretensiones = new List<Case> ();
		//Pretensiones
		if(resolucionPrel1 != 'Not create'){
			Case pretension1 = new Case();
			pretension1.SAC_Reclamacion__c = reclamacion.id;
			//pretension1.Subject = 'Pretension1';
			pretension1.SuppliedCompany = 'prueba1';
			pretension1.CC_Importe_Reclamado__c = 0;
			pretension1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension1.OwnerId = userId;
			pretension1.SAC_SentidoResolucion__c = resolucionPrel1;
			lstPretensiones.add(pretension1);
		}
		
		if(resolucionPrel2 != 'Not create'){
			Case pretension2 = new Case();
			pretension2.SAC_Reclamacion__c = reclamacion.id;
			//pretension2.Subject = 'Pretension2';
			pretension2.SuppliedCompany = 'prueba2';
			pretension2.CC_Importe_Reclamado__c = 0;
			pretension2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension2.OwnerId = userId;
			pretension2.SAC_SentidoResolucion__c = resolucionPrel2;
			lstPretensiones.add(pretension2);
		}
		if(resolucionPrel3 != 'Not create'){
			Case pretension3 = new Case();
			pretension3.SAC_Reclamacion__c = reclamacion.id;
			//pretension3.Subject = 'pretension3';
			pretension3.SuppliedCompany = 'prueba3';
			pretension3.CC_Importe_Reclamado__c = 200;
			pretension3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
			pretension3.OwnerId = userId;
			pretension3.SAC_SentidoResolucion__c = resolucionPrel3;
			lstPretensiones.add(pretension3);
		}
		if(lstPretensiones.size()>0){
			Database.insert(lstPretensiones);
		}
	}
}