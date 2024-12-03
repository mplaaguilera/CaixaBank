/*****************************************************************
 * Name: SAC_BalanceoLetrado_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_BalanceoLetrado
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         		DATE         Description
 * 1.0            US200213         Jose Gonzalez  		04/06/21     Creación
 * 1.1            US563153         Jose Carlos Blanco   07/03/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/

@isTest
public without sharing class SAC_BalanceoLetrado_Test {
 
	@TestSetup
	static void makeData() {
 
		//Account
		Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
		Database.insert(cuenta);

		//Grupos
		List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c> ();

		CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
		grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
		grupoColaborador.SAC_MaximoCasosDiarios__c = 1;
		listaGrupos.add(grupoColaborador);

		List <CC_Grupo_Colaborador__c> gruposLetrados = SAC_TestDataFactory.crearGrupoColaborador('GrupoLetrados',3);
		gruposLetrados[0].SAC_PorcentajeAsignacion__c = 100;
		gruposLetrados[0].SAC_MaximoCasosDiarios__c = 1;
		gruposLetrados[0].SAC_Sensible__c = true;
		listaGrupos.add(gruposLetrados[0]);

		gruposLetrados[1].SAC_PorcentajeAsignacion__c = 0;
		gruposLetrados[1].SAC_MaximoCasosDiarios__c = 1;
		gruposLetrados[1].SAC_Presidencia__c = true;
		listaGrupos.add(gruposLetrados[1]);

		gruposLetrados[2].SAC_PorcentajeAsignacion__c = 4;
		gruposLetrados[2].SAC_MaximoCasosDiarios__c = 1;
		gruposLetrados[2].SAC_EndToEnd__c = true;
		listaGrupos.add(gruposLetrados[2]);

		Database.insert(listaGrupos);

		//Usuarios
		List<User> lstUser = SAC_TestDataFactory.crearUsuarioSACGeneral(3);
		Database.insert(lstUser);
		
		//Contacts grupos
		List<CC_Grupo_Colaborador_Contact__c> lstCol = new List<CC_Grupo_Colaborador_Contact__c>();

		CC_Grupo_Colaborador_Contact__c colaborador = SAC_TestDataFactory.crearColaboradorContact(lstUser[1].Id, listaGrupos[0].Id);
		lstCol.add(colaborador);

		CC_Grupo_Colaborador_Contact__c colaborador2 = SAC_TestDataFactory.crearColaboradorContact(lstUser[2].Id, listaGrupos[2].Id);
		lstCol.add(colaborador2);

		CC_Grupo_Colaborador_Contact__c colaborador3 = SAC_TestDataFactory.crearColaboradorContact(lstUser[0].Id, listaGrupos[1].Id);
		lstCol.add(colaborador3);

		//insert lstCol;

		//MCCs
		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		mccTematica.Name = 'Tematica1';
		mccTematica.CC_Tipo_Cliente__c = 'SAC';
		mccTematica.CC_Codigo_Externo__c = 'TE-0000051';
		mccTematica.SAC_ImporteDesdeMCC__c = 4000;
		mccTematica.SAC_ImporteHastaMCC__c = 5000;
		mccTematica.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		Database.insert(mccTematica);

		CC_MCC__c mccProducto = new CC_MCC__c();
		mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		mccProducto.Name = 'Producto1';
		mccProducto.CC_Tipo_Cliente__c = 'SAC';
		mccProducto.CC_Codigo_Externo__c = 'PR-0000051';
		mccProducto.CC_Tematica__c = mccTematica.id;
		mccProducto.SAC_ImporteDesdeMCC__c = 3000;
		mccProducto.SAC_ImporteHastaMCC__c = 4000;
		mccProducto.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		Database.insert(mccProducto);

		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		mccMotivo.Name = 'Motivo1';
		mccMotivo.CC_Tipo_Cliente__c = 'SAC';
		mccMotivo.CC_Codigo_Externo__c = 'MO-0000051';
		mccMotivo.CC_Producto_Servicio__c = mccProducto.id;
		mccMotivo.SAC_ImporteDesdeMCC__c = 2000;
		mccMotivo.SAC_ImporteHastaMCC__c = 3000;
		mccMotivo.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		Database.insert(mccMotivo);

		List<CC_MCC__c> detalles = new List<CC_MCC__c>();
		CC_MCC__c mccDetalle = new CC_MCC__c();
		mccDetalle.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mccDetalle.Name = 'Detalle';
		mccDetalle.CC_Tipo_Cliente__c = 'SAC';
		mccDetalle.CC_Codigo_Externo__c = 'DE-0000043';
		mccDetalle.SAC_EndToEnd__c = true;
		mccDetalle.SAC_GrupoColaborador__c = listaGrupos[1].Id;
		detalles.add(mccDetalle);

		CC_MCC__c mccDetalle2 = new CC_MCC__c();
		mccDetalle2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mccDetalle2.Name = 'Detalle2';
		mccDetalle2.CC_Tipo_Cliente__c = 'SAC';
		mccDetalle2.CC_Codigo_Externo__c = 'DE-0000055';
		mccDetalle2.SAC_EndToEnd__c = false;
		mccDetalle2.SAC_GrupoColaborador__c = listaGrupos[1].Id;
		detalles.add(mccDetalle2);

		CC_MCC__c mccDetalle3 = new CC_MCC__c();
		mccDetalle3.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mccDetalle3.Name = 'Detalle3';
		mccDetalle3.CC_Tipo_Cliente__c = 'SAC';
		mccDetalle3.CC_Codigo_Externo__c = 'DE-0000056';
		mccDetalle3.SAC_EndToEnd__c = true;
		mccDetalle3.SAC_GrupoColaborador__c = listaGrupos[3].Id;
		detalles.add(mccDetalle3);

		CC_MCC__c mccDetalle4 = new CC_MCC__c();
		mccDetalle4.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mccDetalle4.Name = 'Detalle4';
		mccDetalle4.CC_Tipo_Cliente__c = 'SAC';
		mccDetalle4.CC_Codigo_Externo__c = 'DE-0000057';
		mccDetalle4.SAC_EndToEnd__c = false;
		mccDetalle4.CC_Motivo__c = mccMotivo.id;
		mccDetalle4.SAC_GrupoColaborador__c = listaGrupos[1].Id;
		mccDetalle4.SAC_ImporteDesdeMCC__c = 1000;
		mccDetalle4.SAC_ImporteHastaMCC__c = 2000;
		mccDetalle4.SAC_GrupoLetradoMCC__c = listaGrupos[1].Id;
		detalles.add(mccDetalle4);

		Database.insert(detalles);

		//Grupo MCCs
		List<CC_MCC_Grupo_Colaborador__c> relacionesMccGrupos = new List<CC_MCC_Grupo_Colaborador__c>();

		CC_MCC_Grupo_Colaborador__c relacionMCCGrupo = new CC_MCC_Grupo_Colaborador__c();
		relacionMCCGrupo.CC_MCC__c = mccDetalle.Id;
		relacionMCCGrupo.CC_Grupo_Colaborador__c = listaGrupos[0].Id;
		relacionMCCGrupo.SAC_PorcentajeAsignacion__c = 100;
		relacionMCCGrupo.Name = 'Prueba';
		relacionMCCGrupo.SAC_MaximoDeCasosDiarios__c = 1;
		relacionMCCGrupo.SPV_Tipo_Cliente__c = 'SAC';
		relacionesMccGrupos.add(relacionMCCGrupo);

		CC_MCC_Grupo_Colaborador__c relacionMCCGrupo2 = new CC_MCC_Grupo_Colaborador__c();
		relacionMCCGrupo2.CC_MCC__c = mccDetalle4.Id;
		relacionMCCGrupo2.CC_Grupo_Colaborador__c = listaGrupos[0].Id;
		relacionMCCGrupo2.SAC_PorcentajeAsignacion__c = 100;
		relacionMCCGrupo2.Name = 'Prueba2';
		relacionMCCGrupo2.SAC_MaximoDeCasosDiarios__c = 1;
		relacionMCCGrupo2.SPV_Tipo_Cliente__c = 'SAC';
		relacionesMccGrupos.add(relacionMCCGrupo2);

		Database.insert(relacionesMccGrupos);
		

		//Reclamaciones
		List<Case> reclamaciones = new List<Case>();
		//RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('OwnerId', lstUser[1].Id);
        camposRecl.put('SEG_Grupo__c', listaGrupos[0].Id);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposRecl.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
        camposRecl.put('SAC_CasoEspecial__c', 'SAC_Sensible');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

		//RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('OwnerId', lstUser[1].Id);
        camposRecl2.put('SEG_Grupo__c', listaGrupos[0].Id);
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposRecl2.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		camposRecl2.put('SEG_Detalle__c', mccDetalle.Id);
        camposRecl2.put('SAC_CasoEspecial__c', 'SAC_Presidencia');
        camposRecl2.put('AccountId', cuenta.Id);
        camposRecl2.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

		//RECLAMACION 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('OwnerId', lstUser[1].Id);
        camposRecl3.put('SEG_Grupo__c', listaGrupos[3].Id);
        camposRecl3.put('Status', 'SAC_001');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposRecl3.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		camposRecl3.put('SEG_Detalle__c', mccDetalle3.Id);
        camposRecl3.put('AccountId', cuenta.Id);
        camposRecl3.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

		//RECLAMACION 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('Origin', 'Backoffice');
        camposRecl4.put('OwnerId', lstUser[1].Id);
        camposRecl4.put('SEG_Grupo__c', listaGrupos[3].Id);
        camposRecl4.put('Status', 'SAC_001');
        camposRecl4.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposRecl4.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		camposRecl4.put('SEG_Detalle__c', mccDetalle3.Id);
        camposRecl4.put('AccountId', cuenta.Id);
        camposRecl4.put('SAC_TipoConsumidor__c', 'Si');

        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);

		//RECLAMACION 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'TestRec5');
        camposRecl5.put('Origin', 'Backoffice');
        camposRecl5.put('OwnerId', lstUser[1].Id);
        camposRecl5.put('SEG_Grupo__c', listaGrupos[3].Id);
        camposRecl5.put('Status', 'SAC_001');
        camposRecl5.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposRecl5.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		camposRecl5.put('SEG_Detalle__c', mccDetalle3.Id);
        camposRecl5.put('AccountId', cuenta.Id);
        camposRecl5.put('SAC_TipoConsumidor__c', 'Si');
		// camposRecl5.put('CC_Importe_Reclamado__c', 1500);

        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl5);

		reclamaciones.add(casoReclamacion);
		reclamaciones.add(casoReclamacion2);
		reclamaciones.add(casoReclamacion3);
		reclamaciones.add(casoReclamacion4);
		reclamaciones.add(casoReclamacion5);
		Database.insert(reclamaciones);

		//Pretensiones
		List<Case> pretensiones = new List<Case>();
		//PRETENSION 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('OwnerId', lstUser[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
        camposPret.put('SEG_Detalle__c', mccDetalle.Id);
		camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
		
        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
		pretensiones.add(casoPretension);

		//PRETENSION 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'prueba2');
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('OwnerId', lstUser[0].Id);
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret2.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		camposPret2.put('SEG_Grupo__c', listaGrupos[1].Id);
        camposPret2.put('SEG_Detalle__c', mccDetalle.Id);
		camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);

        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
		pretensiones.add(casoPretension2);

		//PRETENSION 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'prueba3');
        camposPret3.put('Origin', 'Backoffice');
        camposPret3.put('OwnerId', lstUser[0].Id);
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret3.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		//camposPret3.put('SEG_Grupo__c', grupoColaborador.Id);
        camposPret3.put('SEG_Detalle__c', mccDetalle.Id);
		camposPret3.put('SAC_Reclamacion__c', casoReclamacion.Id);

        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);
		pretensiones.add(casoPretension3);

		//PRETENSION 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'prueba4');
        camposPret4.put('Origin', 'Backoffice');
        camposPret4.put('OwnerId', lstUser[0].Id);
        camposPret4.put('Status', 'SAC_001');
        camposPret4.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret4.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		//camposPret4.put('SEG_Grupo__c', grupoColaborador.Id);
        camposPret4.put('SEG_Detalle__c', mccDetalle.Id);
		camposPret4.put('SAC_Reclamacion__c', casoReclamacion2.Id);

        Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);
		pretensiones.add(casoPretension4);

		//PRETENSION 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('SuppliedCompany', 'prueba5');
        camposPret5.put('Origin', 'Backoffice');
        camposPret5.put('OwnerId', lstUser[0].Id);
        camposPret5.put('Status', 'SAC_001');
        camposPret5.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret5.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
        camposPret5.put('SEG_Detalle__c', mccDetalle3.Id);
		camposPret5.put('SAC_Entidad_Afectada__c', 'SAC_007');
		camposPret5.put('SAC_Reclamacion__c', casoReclamacion3.Id);

        Case casoPretension5 = SAC_TestDataFactory.crearCaso('Pretension',camposPret5);
		pretensiones.add(casoPretension5);

		//PRETENSION 6
        Map<String, Object> camposPret6 = new Map<String, Object>();
        camposPret6.put('SuppliedCompany', 'prueba6');
        camposPret6.put('Origin', 'Backoffice');
        camposPret6.put('OwnerId', lstUser[0].Id);
        camposPret6.put('Status', 'SAC_001');
        camposPret6.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret6.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
		//camposPret6.put('SEG_Grupo__c', grupoColaborador.Id);
        camposPret6.put('SEG_Detalle__c', mccDetalle.Id);
		camposPret6.put('SAC_Reclamacion__c', casoReclamacion4.Id);

        Case casoPretension6 = SAC_TestDataFactory.crearCaso('Pretension',camposPret6);
		pretensiones.add(casoPretension6);

		//PRETENSION 7
        Map<String, Object> camposPret7 = new Map<String, Object>();
        camposPret7.put('SuppliedCompany', 'prueba7');
        camposPret7.put('Origin', 'Backoffice');
        camposPret7.put('OwnerId', lstUser[0].Id);
        camposPret7.put('Status', 'SAC_001');
        camposPret7.put('SAC_StatusAuxiliar__c', 'SAC_001');
		camposPret7.put('SAC_FechaRecepcion__c', system.now().addHours(-1));
        camposPret7.put('CC_Importe_Reclamado__c', 1500);
		camposPret7.put('SEG_Detalle__c', mccDetalle4.Id);
		camposPret7.put('CC_MCC_Tematica__c', mccTematica.Id);
		camposPret7.put('CC_MCC_ProdServ__c', mccProducto.Id);
		camposPret7.put('CC_MCC_Motivo__c', mccMotivo.Id);
		camposPret7.put('SAC_Reclamacion__c', casoReclamacion5.Id);

        Case casoPretension7 = SAC_TestDataFactory.crearCaso('Pretension',camposPret7);
		pretensiones.add(casoPretension7);
		Database.insert(pretensiones);

		Test.startTest();
		List<Case> reclamacionesUpd = new List<Case>();
		casoReclamacion.SAC_PretensionPrincipal__c = casoPretension3.Id;
		casoReclamacion2.SAC_PretensionPrincipal__c = casoPretension4.Id;
		reclamacionesUpd.add(casoReclamacion);
		reclamacionesUpd.add(casoReclamacion2);
		Database.update(reclamacionesUpd);

		List<SAC_MaestroTemas__c>  marca = SAC_TestDataFactory.crearMaestroTemas(2, 'SAC_Temas');
		marca[0].SAC_GrupoLetrado__c = gruposLetrados[0].Id;
		marca[0].SAC_OrdenPrelacion__c = 5;
		marca[1].SAC_GrupoLetrado__c = gruposLetrados[0].Id;
		Database.insert(marca);

		List <SAC_Marca_Case__c> listMarcas = new List<SAC_Marca_Case__c>();
		SAC_Marca_Case__c marcaAsociada = new SAC_Marca_Case__c();
		marcaAsociada.SAC_Case__c = casoReclamacion4.Id;
		marcaAsociada.SAC_Marca__c = marca[0].id;
		listMarcas.add(marcaAsociada);

		SAC_Marca_Case__c marcaAsociada2 = new SAC_Marca_Case__c();
		marcaAsociada2.SAC_Case__c = casoReclamacion2.Id;
		marcaAsociada2.SAC_Marca__c = marca[0].id;
		listMarcas.add(marcaAsociada2);

		SAC_Marca_Case__c marcaAsociada3 = new SAC_Marca_Case__c();
		marcaAsociada3.SAC_Case__c = casoReclamacion2.Id;
		marcaAsociada3.SAC_Marca__c = marca[1].id;
		listMarcas.add(marcaAsociada3);

		Database.insert(listMarcas);

		Test.stopTest();
	}
 
	@isTest
	static void endToEndTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		List<Case> casos = [SELECT Id, OwnerId, Subject, SEG_Grupo__c, Status FROM Case WHERE Subject = 'TestRec' OR Subject = 'TestRec2'];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba3' Limit 1];
		Case cs;
		Case cs2;
		
		for(Case caso : casos){
			if(caso.Subject == 'TestRec'){
				cs = caso;
			}
			else{
				cs2 = caso;
			}
		}
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
					
			Database.update(cs);

			cs2.Status = 'SAC_002';
			cs2.SAC_StatusAuxiliar__c = cs2.Status;

			Database.update(cs2);
			Test.stopTest();
		}

		cs = [SELECT Status FROM Case WHERE Subject = 'TestRec' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba3' Limit 1];
		String estadoPosterior = cs.Status;

		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');	
	}
 
	 @isTest
	 static void balanceoLetradoEspecialTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec2' Limit 1];
		Case caso2 = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec' Limit 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba4' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;

			caso2.Status = 'SAC_002';
			caso2.SAC_StatusAuxiliar__c = caso2.Status;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);
			listaCasos.add(caso2);

			Database.update(listaCasos);
			Test.stopTest();
		}
			
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec2' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba4' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs2.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}
 
	@isTest
	static void entidadAfectadaTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec3' Limit 1];

		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba5' Limit 1];
		
		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;

			Database.update(cs);
			Test.stopTest();
		}

		pretension = [SELECT Id, OwnerId, Status FROM Case WHERE SuppliedCompany = 'prueba5' Limit 1];

		Assert.areEqual('SAC_002', pretension.Status, 'El cambio de estado no ha funcionado');
	}
 
	@isTest
	static void balanceoMarcaTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec4' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba6' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();	
		}
		
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec4' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba6' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}
 
	@isTest
	static void balanceoMarcaTest2() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec2' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba4' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();
		}
		
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec2' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba4' Limit 1];
		
		System.assertNotEquals(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		System.assertNotEquals(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}

	@isTest
	static void balanceoPorDetalleMCCDetalleTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			cs.CC_Importe_Reclamado__c = 1500;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();
		}
		
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec5' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}

	@isTest
	static void balanceoPorDetalleMCCMotivoTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status, SEG_Detalle__c, CC_MCC_Motivo__c FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			cs.CC_Importe_Reclamado__c = 2500;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();
		}

		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec5' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}

	@isTest
	static void balanceoPorDetalleMCCProductoTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			cs.CC_Importe_Reclamado__c = 3500;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();
		}
		
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec5' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}

	@isTest
	static void balanceoPorDetalleMCCTematicaTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			cs.CC_Importe_Reclamado__c = 4500;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();
		}
		
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec5' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}

	@isTest
	static void balanceoPorDetalleMCCFueraRangoTest() {
		User usuario = [SELECT id FROM User WHERE username = 'usertest1@test.com.testSetup' AND IsActive = true LIMIT 1];
		Case cs = [SELECT Id, OwnerId, Status, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c, Status, SEG_Detalle__c, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		String estadoAnterior = cs.Status;

		System.runAs(usuario){
			Test.startTest();
			cs.Status = 'SAC_002';
			cs.SAC_StatusAuxiliar__c = cs.Status;
			cs.CC_Importe_Reclamado__c = 5500;

			List<Case> listaCasos = new List<Case>();
			listaCasos.add(cs);

			Database.update(listaCasos);
			Test.stopTest();
		}
		
		Case cs2 = [SELECT Status FROM Case WHERE Subject = 'TestRec5' Limit 1];
		Case pretension2 = [SELECT Id, OwnerId, SEG_Grupo__c, Status FROM Case WHERE SuppliedCompany = 'prueba7' Limit 1];
		
		Assert.areNotEqual(estadoAnterior, cs.Status, 'El cambio de estado no ha funcionado');
		Assert.areNotEqual(pretension.SEG_Grupo__c, pretension2.SEG_Grupo__c, 'El balanceo no ha funcionado');
	}
}