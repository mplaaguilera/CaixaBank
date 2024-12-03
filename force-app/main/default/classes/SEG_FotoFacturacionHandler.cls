public class SEG_FotoFacturacionHandler implements Queueable {
	public enum Operativa { MCC, Marca, Grupo }
	private class ServicioCsoWrapper {
		SEG_ServiciosCSO__c servicioCso { get; set; }
		Set<String> mmcs { get; set; }
		Set<Id> idDetalleGrupos { get; set; }
		Set<Id> idGruposCso { get; set; }
		Set<Id> idMarcas { get; set; }
	}
	private List<Id> lstCases { get; set; }
	private List<Id> lstFF { get; set; }
	private Operativa op { get; set; }
	private Id detalle { get; set; }
	private Id producto { get; set; }
	private Id motivo { get; set; }
	private Id tematica { get; set; }
	private Map<Id, List<SEG_Marcasdeuncaso__c>> caseMarcas { get; set; }
	private Map<Id, List<SEG_Operacion__c>> caseOperaciones { get; set; }
	private Map<Id, SEG_UsuariosCSO__c> mapUsuarioCSO;

	public SEG_FotoFacturacionHandler(List<Id> lstCases, Operativa op, Map<Id, List<SEG_Marcasdeuncaso__c>> caseMarcas) {
		this(lstCases, op);
		this.caseMarcas = caseMarcas;
	}
	public SEG_FotoFacturacionHandler(List<Id> lstCases, Operativa op) {
		this.lstCases = lstCases;
		this.op = op;
	}
	public SEG_FotoFacturacionHandler(List<Id> lstCases, Operativa op, Map<Id, List<SEG_Operacion__c>> caseOperaciones, Id detalle, Id producto, Id motivo, Id tematica) {
		this(lstCases, op);
		this.caseOperaciones = caseOperaciones;
		this.detalle = detalle;
		this.producto = producto;
		this.motivo = motivo;
		this.tematica = tematica;
	}
	public SEG_FotoFacturacionHandler(Operativa op, List<Id> lstFF) {
		this.op = op;
		this.lstFF = lstFF;
	}
	//Realizar las acciones de forma asincrona
	public void execute(QueueableContext context) {
		if (lstFF != null) {
			updateFF();
		} else {
			createFF();
		}
	}
	public void createFF() {
		
		Set<Id> caseIds = new Set<Id>(lstCases);
		Map<Id, Case> mapCase = getMapCases(caseIds);

		mapUsuarioCSO = getMapUsuariosCSO(mapCase.values());

		Map<Id, ServicioCsoWrapper> mapServCsoW = getMapServiciosCSO(mapCase.values());
		Set<Id> setCaseADeterminar = getSetCaseADeterminar(mapCase.values());

		List<SEG_Fotosdefacturacion__c> lstInsertFF = new List<SEG_Fotosdefacturacion__c> ();
		List<SEG_Fotosdefacturacion__c> lstFF;
		List<ServicioCsoWrapper> lstServiciosFiltrados;
		List<SEG_ServiciosCSO__c> lstServCSO;
		SEG_UsuariosCSO__c usuarioCso;
		Boolean isMarcaDeleted;

		// Lista fotos de facturacion
		List<SEG_Fotosdefacturacion__c>  lstComprobarFF = [SELECT Id, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_NumeroSR__c, SEG_Operativa__c FROM SEG_Fotosdefacturacion__c  WHERE SEG_NumeroSR__c IN :caseIds];
		//
		for (Case cs : mapCase.values()) {
			lstServiciosFiltrados = getServiciosCsoFiltered(cs, mapServCsoW.values());
			if (op == Operativa.MCC) {
				for (SEG_Operacion__c operacion : caseOperaciones.get(cs.Id)) {

					usuarioCso = mapUsuarioCSO.get(operacion.SEG_Usuario__c);
					if (usuarioCso != null) {
						lstServCSO = getIdServicioMcc(lstServiciosFiltrados, usuarioCso.SEG_GrupoCSO__c, detalle, producto, motivo, tematica);
						lstFF = createFFMcc(cs, lstServCSO, operacion, setCaseADeterminar.contains(cs.Id), usuarioCso, detalle, producto, motivo, tematica);
						
						//Informar id de operación para acceder desde el trigger de FF AI 
						for(SEG_Fotosdefacturacion__c ff : lstFF)
						{
							ff.SEG_Operacion__c = operacion.id; 
						} 

						lstInsertFF.addAll(lstFF);
					}
				}
			}
			else if (op == Operativa.Marca) {
				for (SEG_Marcasdeuncaso__c marca : caseMarcas.get(cs.Id)) {
					usuarioCso = mapUsuarioCSO.get(marca.SEG_Usuario__c);
					isMarcaDeleted = marca.Id == null;
					if (usuarioCso != null) {
						lstServCSO = getIdServicioMarca(cs, lstServiciosFiltrados, marca.SEG_Caracteristica__c, usuarioCso.SEG_GrupoCSO__c);
						lstFF = createFFMarca(cs, lstServCSO, marca.SEG_Caracteristica__c, setCaseADeterminar.contains(cs.Id), usuarioCso,isMarcaDeleted);
						lstInsertFF.addAll(lstFF);
					}
				}
			}
			// Comprobamos si es de tipo grupo, si es así, solo podrá tener una FF
			else {
				Boolean contieneGrupo = false;
				// Comrpobamos si tiene FF de Grupo
				usuarioCso = mapUsuarioCSO.get(cs.OwnerId);
				if (usuarioCso != null) {
					lstServCSO = getIdServicioGrupo(cs, lstServiciosFiltrados, usuarioCso.SEG_GrupoCSO__c);
					if(!lstComprobarFF.isEmpty()){
						for(SEG_Fotosdefacturacion__c ff : lstComprobarFF){
							if(ff.SEG_NumeroSR__c == cs.id && ff.SEG_Operativa__c == 'Grupo'){
								for (SEG_ServiciosCSO__c servicioCSO : lstServCSO) {
									if(servicioCSO.Id == ff.SEG_IDServicio__c){
										contieneGrupo = true;
									}
								}
							}
						}	
					}
					if(!contieneGrupo){
						lstFF = createFFGrupo(cs, lstServCSO, setCaseADeterminar.contains(cs.Id), usuarioCso);
						lstInsertFF.addAll(lstFF);
					}
				}
			}
		}

		if (lstInsertFF.size() > 0) {
			insert lstInsertFF;
		}
	}

	public void updateFF() {

		Map<Id, SEG_Fotosdefacturacion__c> mapFF = new Map<Id, SEG_Fotosdefacturacion__c> ([SELECT Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c
		                                                                                   From SEG_Fotosdefacturacion__c Where Id = :lstFF]);

		Set<Id> caseIds = new Set<Id> ();
		for (SEG_Fotosdefacturacion__c foto : mapFF.values()) {
			caseIds.add(foto.SEG_NumeroSR__c);
		}

		Map<Id, Case> mapCase = getMapCases(caseIds);

		mapUsuarioCSO = getMapUsuariosCSO(mapFF.values());

		Map<Id, ServicioCsoWrapper> mapServCsoW = getMapServiciosCSO(mapCase.values());

		Set<Id> setCaseADeterminar = getSetCaseADeterminar(mapCase.values());

		List<SEG_Fotosdefacturacion__c> lstUpdFF = new List<SEG_Fotosdefacturacion__c> ();
		List<SEG_Fotosdefacturacion__c> lstInsertFF = new List<SEG_Fotosdefacturacion__c> ();
		List<SEG_Fotosdefacturacion__c> lstFF;
		List<ServicioCsoWrapper> lstServiciosFiltrados;
		List<SEG_ServiciosCSO__c> lstServCSO;
		SEG_UsuariosCSO__c usuarioCso;
		SEG_Operacion__c operacion;
		Case cs;
		for (SEG_Fotosdefacturacion__c ff : mapFF.values()) {
			cs = mapCase.get(ff.SEG_NumeroSR__c);
			usuarioCso = mapUsuarioCSO.get(ff.SEG_Usuariogenerador__c);
			lstServiciosFiltrados = getServiciosCsoFiltered(cs, mapServCsoW.values());
			if (op == Operativa.MCC) {
				operacion = new SEG_Operacion__c();
				operacion.SEG_N_Operaciones__c = (ff.SEG_NumerooperacionesCSO__c == null ? 0 : ff.SEG_NumerooperacionesCSO__c) - (ff.SEG_Valor__c == null ? 0 : ff.SEG_Valor__c);
				if (usuarioCso != null && ff.SEG_IDServicio__c != null) {
					ff.SEG_Estado__c = usuarioCso.SEG_ActivoCSO__c && usuarioCso.SEG_GrupoCSO__r.SEG_ActivoCSO__c ? 'Vigente' : 'Ignorar';
					lstUpdFF.add(ff);
				}
				else if (usuarioCso != null) {
					lstServCSO = getIdServicioMcc(lstServiciosFiltrados, usuarioCso.SEG_GrupoCSO__c, detalle, producto, motivo, tematica);
					lstFF = createFFMcc(cs, lstServCSO, operacion, setCaseADeterminar.contains(cs.Id), usuarioCso, detalle, producto, motivo, tematica);
					lstInsertFF.addAll(getFFtoUpsert(lstFF, ff));
					lstUpdFF.add(ff);
				} else {
					ff.SEG_Estado__c = 'Ignorar';
					lstUpdFF.add(ff);
				}
			}
			else if (op == Operativa.Marca) {
				if (usuarioCso != null && ff.SEG_IDServicio__c != null) {
					ff.SEG_Estado__c = usuarioCso.SEG_ActivoCSO__c && usuarioCso.SEG_GrupoCSO__r.SEG_ActivoCSO__c ? 'Vigente' : 'Ignorar';
					lstUpdFF.add(ff);
				}
				else if (usuarioCso != null) {
					lstServCSO = getIdServicioMarca(cs, lstServiciosFiltrados, ff.SEG_Marcadelcaso__c, usuarioCso.SEG_GrupoCSO__c);
					lstFF = createFFMarca(cs, lstServCSO, ff.SEG_Marcadelcaso__c, setCaseADeterminar.contains(cs.Id), usuarioCso,false);
					lstInsertFF.addAll(getFFtoUpsert(lstFF, ff));
					lstUpdFF.add(ff);
				} else {
					ff.SEG_Estado__c = 'Ignorar';
					lstUpdFF.add(ff);
				}
			}
			else {
				if (usuarioCso != null && ff.SEG_IDServicio__c != null) {
					ff.SEG_Estado__c = usuarioCso.SEG_ActivoCSO__c && usuarioCso.SEG_GrupoCSO__r.SEG_ActivoCSO__c ? 'Vigente' : 'Ignorar';
					lstUpdFF.add(ff);
				}
				else if (usuarioCso != null) {
					lstServCSO = getIdServicioGrupo(cs, lstServiciosFiltrados, usuarioCso.SEG_GrupoCSO__c);
					lstFF = createFFGrupo(cs, lstServCSO, setCaseADeterminar.contains(cs.Id), usuarioCso);
					lstInsertFF.addAll(getFFtoUpsert(lstFF, ff));
					lstUpdFF.add(ff);
				} else {
					ff.SEG_Estado__c = 'Ignorar';
					lstUpdFF.add(ff);
				}
			}
		}
		if (lstInsertFF.size() > 0) {
			insert lstInsertFF;
		}
		if (lstUpdFF.size() > 0) {
			update lstUpdFF;
		}
	}

	private Map<Id, Case> getMapCases(Set<Id> caseIds) {
		return new Map<Id, Case> ([SELECT Id, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
		                         SEG_Detalle__c, SEG_Organizacion__c, SEG_Zona__c, SEG_Grupo__c,
		                         SEG_N_operaciones_CSO__c, Origin, OwnerId
		                         From Case Where Id = :caseIds]);
	}

	private List<SEG_Fotosdefacturacion__c> getFFtoUpsert(List<SEG_Fotosdefacturacion__c> lstFF, SEG_Fotosdefacturacion__c ff) {
		List<SEG_Fotosdefacturacion__c> lstInsertFF = new List<SEG_Fotosdefacturacion__c> ();
		Boolean first = true;
		for (SEG_Fotosdefacturacion__c ffIdServ : lstFF) {
			if (first) {
				first = false;
				ff.SEG_IDServicio__c = ffIdServ.SEG_IDServicio__c;
				ff.SEG_Estado__c = ffIdServ.SEG_Estado__c == 'Revisar' ? 'Ignorar' : ffIdServ.SEG_Estado__c;
			} else {
				ffIdServ.SEG_Estado__c = ffIdServ.SEG_Estado__c == 'Revisar' ? 'Ignorar' : ffIdServ.SEG_Estado__c;
				lstInsertFF.add(ffIdServ);
			}
		}
		return lstInsertFF;
	}

	private List<SEG_Fotosdefacturacion__c> createFFGrupo(Case cs, List<SEG_ServiciosCSO__c> lstServicios, Boolean aDeterminar, SEG_UsuariosCSO__c usuarioCSO) {
		SEG_Fotosdefacturacion__c ff;
		List<SEG_Fotosdefacturacion__c> lstInsertFF = new List<SEG_Fotosdefacturacion__c> ();
		for (SEG_ServiciosCSO__c serv : lstServicios) {
			ff = generateFF(cs, serv.Id, usuarioCSO);
			ff.SEG_Valor__c = 1;
			lstInsertFF.add(ff);
		}
		//No hay idServicios
		if (lstServicios.size() == 0 && aDeterminar) {
			ff = generateFF(cs, null, usuarioCSO);
			ff.SEG_Estado__c = 'A determinar';
			ff.SEG_Valor__c = 1;
			lstInsertFF.add(ff);
		}
		return lstInsertFF;
	}

	private List<SEG_Fotosdefacturacion__c> createFFMarca(Case cs, List<SEG_ServiciosCSO__c> lstServicios, Id marcaId, Boolean aDeterminar, SEG_UsuariosCSO__c usuarioCSO,Boolean isMarcaDeleted) {
		SEG_Fotosdefacturacion__c ff;
		List<SEG_Fotosdefacturacion__c> lstInsertFF = new List<SEG_Fotosdefacturacion__c> ();
		for (SEG_ServiciosCSO__c serv : lstServicios) {
			ff = generateFF(cs, serv.Id, usuarioCSO);
			ff.SEG_Marcadelcaso__c = marcaId;
			ff.SEG_Valor__c = isMarcaDeleted ? -1 : 1;
			lstInsertFF.add(ff);
		}
		//No hay idServicios
		if (lstServicios.size() == 0) {
			ff = generateFF(cs, null, usuarioCSO);
			ff.SEG_Marcadelcaso__c = marcaId;
			ff.SEG_Estado__c = aDeterminar ? 'A determinar' : 'Revisar';
			ff.SEG_Valor__c = isMarcaDeleted ? -1 : 1;
			lstInsertFF.add(ff);
		}
		return lstInsertFF;
	}

	private List<SEG_Fotosdefacturacion__c> createFFMcc(Case cs, List<SEG_ServiciosCSO__c> lstServicios, SEG_Operacion__c operacion, Boolean aDeterminar, SEG_UsuariosCSO__c usuarioCSO, Id detalle, Id producto, Id motivo, Id tematica) {
		SEG_Fotosdefacturacion__c ff;
		List<SEG_Fotosdefacturacion__c> lstInsertFF = new List<SEG_Fotosdefacturacion__c> ();
		for (SEG_ServiciosCSO__c serv : lstServicios) {
			ff = generateFFMcc(cs, serv.Id, usuarioCSO, detalle, producto, motivo, tematica);
			ff.SEG_NumerooperacionesCSO__c = cs.SEG_N_operaciones_CSO__c;
			ff.SEG_Valor__c = operacion.SEG_N_Operaciones__c;
			lstInsertFF.add(ff);
		}
		//No hay idServicios
		if (lstServicios.size() == 0) {
			ff = generateFFMcc(cs, null, usuarioCSO, detalle, producto, motivo, tematica);
			ff.SEG_NumerooperacionesCSO__c = cs.SEG_N_operaciones_CSO__c;
			ff.SEG_Valor__c = operacion.SEG_N_Operaciones__c;
			ff.SEG_Estado__c = aDeterminar ? 'A determinar' : 'Revisar';
			lstInsertFF.add(ff);
		}
		return lstInsertFF;
	}

	private SEG_Fotosdefacturacion__c generateFF(Case cs, Id idServ, SEG_UsuariosCSO__c usuarioCSO) {
		SEG_Fotosdefacturacion__c ff = new SEG_Fotosdefacturacion__c();
		ff.SEG_NumeroSR__c = cs.Id;
		ff.SEG_Usuariogenerador__c = usuarioCSO.SEG_Usuario__c;
		ff.SEG_Estado__c = usuarioCso.SEG_ActivoCSO__c && usuarioCso.SEG_GrupoCSO__r.SEG_ActivoCSO__c ? 'Vigente' : 'Revisar';
		ff.SEG_IDServicio__c = idServ;
		ff.SEG_Tematica__c = cs.CC_MCC_Tematica__c;
		ff.SEG_Producto__c = cs.CC_MCC_ProdServ__c;
		ff.SEG_Motivo__c = cs.CC_MCC_Motivo__c;
		ff.SEG_Detalle__c = cs.SEG_Detalle__c;
		ff.SEG_GrupoCSO__c = usuarioCSO.SEG_GrupoCSO__c;
		ff.SEG_Grupodetrabajo__c = cs.SEG_Grupo__c;
		ff.SEG_Canaldeentrada__c = cs.Origin;
		ff.SEG_Operativa__c = op.name();
		return ff;
	}

	private SEG_Fotosdefacturacion__c generateFFMcc(Case cs, Id idServ, SEG_UsuariosCSO__c usuarioCSO, Id detalle, Id producto, Id motivo, Id tematica) {
		SEG_Fotosdefacturacion__c ff = new SEG_Fotosdefacturacion__c();
		ff.SEG_NumeroSR__c = cs.Id;
		ff.SEG_Usuariogenerador__c = usuarioCSO.SEG_Usuario__c;
		ff.SEG_Estado__c = usuarioCso.SEG_ActivoCSO__c && usuarioCso.SEG_GrupoCSO__r.SEG_ActivoCSO__c ? 'Vigente' : 'Revisar';
		ff.SEG_IDServicio__c = idServ;
		ff.SEG_Tematica__c = tematica;
		ff.SEG_Producto__c = producto;
		ff.SEG_Motivo__c = motivo;
		ff.SEG_Detalle__c = detalle;
		ff.SEG_GrupoCSO__c = usuarioCSO.SEG_GrupoCSO__c;
		ff.SEG_Grupodetrabajo__c = cs.SEG_Grupo__c;
		ff.SEG_Canaldeentrada__c = cs.Origin;
		ff.SEG_Operativa__c = op.name();
		return ff;
	}

	private Set<Id> getSetCaseADeterminar(List<Case> lstCase) {
		Set<Id> setCaseADeterminar = new Set<Id> ();
		for (Case cs : lstCase) {
			if (cs.SEG_Organizacion__c == null || cs.SEG_Zona__c == null) {
				setCaseADeterminar.add(cs.Id);
			}
			else if (op == Operativa.MCC && (cs.CC_MCC_Tematica__c == null || cs.CC_MCC_ProdServ__c == null)) {
				setCaseADeterminar.add(cs.Id);
			}
			else if ((op == Operativa.Marca || op == Operativa.Grupo) && cs.SEG_Grupo__c == null) {
				setCaseADeterminar.add(cs.Id);
			}
		}
		return setCaseADeterminar;
	}

	private Map<Id, SEG_UsuariosCSO__c> getMapUsuariosCSO(List<SEG_Fotosdefacturacion__c> lstFF) {
		Map<Id, SEG_UsuariosCSO__c> mapUserCSO = new Map<Id, SEG_UsuariosCSO__c> ();
		for (SEG_Fotosdefacturacion__c ff : lstFF) {
			mapUserCSO.put(ff.SEG_Usuariogenerador__c, null);
		}
		fillMapUsuariosCSO(mapUserCSO);
		return mapUserCSO;
	}

	private Map<Id, SEG_UsuariosCSO__c> getMapUsuariosCSO(List<Case> lstCase) {
		Map<Id, SEG_UsuariosCSO__c> mapUserCSO = new Map<Id, SEG_UsuariosCSO__c> ();
		if (op == Operativa.Grupo) {
			for (Case cs : lstCase) {
				if (cs.OwnerId.getSObjectType() == User.SObjectType) {
					mapUserCSO.put(cs.OwnerId, null);
				}
			}
		} else if (op == Operativa.MCC) {
			for (List<SEG_Operacion__c> lstOp : caseOperaciones.values()) {
				for (SEG_Operacion__c op : lstOp) {
					mapUserCSO.put(op.SEG_Usuario__c, null);
				}
			}
		} else {
			for (List<SEG_Marcasdeuncaso__c> lstMa : caseMarcas.values()) {
				for (SEG_Marcasdeuncaso__c ma : lstMa) {
					mapUserCSO.put(ma.SEG_Usuario__c, null);
				}
			}
		}

		fillMapUsuariosCSO(mapUserCSO);
		return mapUserCSO;
	}

	private void fillMapUsuariosCSO(Map<Id, SEG_UsuariosCSO__c> mapUserCSO) {
		List<SEG_UsuariosCSO__c> lstUsuarioCso = [SELECT SEG_Usuario__c, SEG_ActivoCSO__c, SEG_GrupoCSO__c, SEG_GrupoCSO__r.SEG_ActivoCSO__c
		                                          From SEG_UsuariosCSO__c Where SEG_Usuario__c IN :mapUserCSO.keySet()];

		for (SEG_UsuariosCSO__c userCSO : lstUsuarioCso) {
			mapUserCSO.put(userCSO.SEG_Usuario__c, userCSO);
		}
	}

	private List<ServicioCsoWrapper> getServiciosCsoFiltered(Case cs, List<ServicioCSOWrapper> lstAllServiciosCso) {
		List<ServicioCsoWrapper> lstServciosCsoFiltered = new List<ServicioCsoWrapper> ();
		for (ServicioCSOWrapper srvW : lstAllServiciosCso) {
			if (isZonaOrganizacionCaseIncluded(srvW.servicioCSO, cs)) {
				lstServciosCsoFiltered.add(srvW);
			}
		}
		return lstServciosCsoFiltered;
	}

	private List<SEG_ServiciosCSO__c> getIdServicioMcc(List<ServicioCSOWrapper> lstAllServiciosCso, Id grupoCSO, String detalle, String producto, String motivo, String tematica) {
		List<SEG_ServiciosCSO__c> lstServciosCso = new List<SEG_ServiciosCSO__c> ();
		string checkSumMccCase;
		Boolean findMCC;
		for (ServicioCSOWrapper srvW : lstAllServiciosCso) {
			checkSumMccCase = getCheckSumMcc(tematica, producto, motivo, detalle);
			findMCC = false;
			for(String mcc : srvW.mmcs){
				if(checkSumMccCase.contains(mcc)){
					findMCC = true;
				}
			}
			if (findMCC && srvW.idGruposCso.contains(grupoCso)) {
				lstServciosCso.add(srvW.servicioCso);
			}
		}
		return lstServciosCso;
	}
	private List<SEG_ServiciosCSO__c> getIdServicioMarca(Case cs, List<ServicioCSOWrapper> lstAllServiciosCso, Id idMarca, Id grupoCSO) {
		List<SEG_ServiciosCSO__c> lstServciosCso = new List<SEG_ServiciosCSO__c> ();
		for (ServicioCSOWrapper srvW : lstAllServiciosCso) {
			if (srvW.idDetalleGrupos.contains(cs.SEG_Grupo__c) && srvW.idMarcas.contains(idMarca) && srvW.idGruposCso.contains(grupoCso)) {
				lstServciosCso.add(srvW.servicioCso);
			}
		}
		return lstServciosCso;
	}
	private List<SEG_ServiciosCSO__c> getIdServicioGrupo(Case cs, List<ServicioCSOWrapper> lstAllServiciosCso, Id grupoCSO) {
		List<SEG_ServiciosCSO__c> lstServciosCso = new List<SEG_ServiciosCSO__c> ();
		for (ServicioCSOWrapper srvW : lstAllServiciosCso) {
			if (srvW.idDetalleGrupos.contains(cs.SEG_Grupo__c) && srvW.idGruposCso.contains(grupoCso)) {
				lstServciosCso.add(srvW.servicioCso);
			}
		}
		return lstServciosCso;
	}
	//Comprueba que la zona y la organizacion del caso este incluido en el servicioCso
	private Boolean isZonaOrganizacionCaseIncluded(SEG_ServiciosCSO__c servicioCso, Case cs) {
		List<String> lstOrganizacion;
		List<String> lstZona;
		lstOrganizacion = servicioCso.SEG_Organizacion__c != null ? servicioCso.SEG_Organizacion__c.split(';') : new List<String> ();
		lstZona = servicioCso.SEG_Zona__c != null ? servicioCso.SEG_Zona__c.split(';') : new List<String> ();
		return(lstOrganizacion.contains(cs.SEG_Organizacion__c) && (lstZona.size() == 0 || lstZona.contains(cs.SEG_Zona__c)));
	}

	private string getCheckSumMcc(String tematica, string producto, string motivo, string detalle) {
		return(String.isNotBlank(tematica) ? tematica : '')
		+ (String.isNotBlank(producto) ? producto : '')
		+ (String.isNotBlank(motivo) ? motivo : '')
		+ (String.isNotBlank(detalle) ? detalle : '');
	}

	private Map<Id, ServicioCsoWrapper> getMapServiciosCSO(List<Case> lstCase) {
		Map<Id, ServicioCsoWrapper> mapServCsoW = new Map<Id, ServicioCsoWrapper> ();

		SEG_ServiciosCSO__c c = new SEG_ServiciosCSO__c();
		Id recordTypeIdServ = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get(op.name()).getRecordTypeId();
		Map<Id, SEG_ServiciosCSO__c> mapServCSO = new Map<Id, SEG_ServiciosCSO__c> ([SELECT Id, SEG_Zona__c, SEG_Organizacion__c FROM SEG_ServiciosCSO__c
		                                                                            WHERE RecordTypeId = :recordTypeIdServ AND SEG_Activo__c = true]);

		//Generar Map Servicios Wrapper
		ServicioCsoWrapper servCsoW;
		for (SEG_ServiciosCSO__c servCso : mapServCSO.values()) {
			servCsoW = new ServicioCsoWrapper();
			servCsoW.servicioCso = mapServCSO.get(servCso.Id);
			mapServCsoW.put(servCso.Id, servCsoW);
			mapServCsoW.get(servCso.Id).mmcs = new Set<String> ();
			mapServCsoW.get(servCso.Id).idDetalleGrupos = new Set<Id> ();
			mapServCsoW.get(servCso.Id).idGruposCso = new Set<Id> ();
			mapServCsoW.get(servCso.Id).idMarcas = new Set<Id> ();
		}

		fillGruposCso(mapServCsoW);

		fillMccs(mapServCsoW);

		fillMarcasCso(mapServCsoW);

		fillDetalleGrupos(mapServCsoW);

		return mapServCsoW;
	}

	private void fillMccs(Map<Id, ServicioCsoWrapper> mapServCsoW) {
		List<SEG_MCCServiciosCSO__c> lstMccsServicio = [SELECT Id, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Detalle__c, SEG_ServiciosCSO__c FROM SEG_MCCServiciosCSO__c
		                                                WHERE SEG_ServiciosCSO__c in :mapServCsoW.keySet() and SEG_Activo__c = true];
		ServicioCsoWrapper servCso;
		for (SEG_MCCServiciosCSO__c mccServ : lstMccsServicio) {
			mapServCsoW.get(mccServ.SEG_ServiciosCSO__c).mmcs.add(getCheckSumMcc(mccServ.SEG_Tematica__c, mccServ.SEG_Producto__c, mccServ.SEG_Motivo__c, mccServ.SEG_Detalle__c));
		}
	}
	private void fillGruposCso(Map<Id, ServicioCsoWrapper> mapServCsoW) {
		List<SEG_GruposServiciosCSO__c> lstGruposServCso = [SELECT Id, SEG_ServiciosCSO__c, SEG_GrupoCSO__c FROM SEG_GruposServiciosCSO__c
		                                                    WHERE SEG_ServiciosCSO__c = :mapServCsoW.keySet() and SEG_Activo__c = true];

		for (SEG_GruposServiciosCSO__c grupoCso : lstGruposServCso) {
			mapServCsoW.get(grupoCso.SEG_ServiciosCSO__c).idGruposCso.add(grupoCso.SEG_GrupoCSO__c);
		}
	}
	private void fillMarcasCso(Map<Id, ServicioCsoWrapper> mapServCsoW) {
		List<SEG_MarcasCSO__c> lstMarcasServCso = [SELECT Id, SEG_ServiciosCSO__c, SEG_Marca__c FROM SEG_MarcasCSO__c
		                                           WHERE SEG_ServiciosCSO__c = :mapServCsoW.keySet() and SEG_Activo__c = true];

		for (SEG_MarcasCSO__c marcaCso : lstMarcasServCso) {
			mapServCsoW.get(marcaCso.SEG_ServiciosCSO__c).idMarcas.add(marcaCso.SEG_Marca__c);
		}
	} 

	private void fillDetalleGrupos(Map<Id, ServicioCsoWrapper> mapServCsoW) {
		List<SEG_GrupoTrabajoRelacionado__c> lstDetalleGruposServ = [SELECT Id, SEG_ServiciosCSO__c, SEG_GrupoTrabajo__c FROM SEG_GrupoTrabajoRelacionado__c
		                                                             WHERE SEG_ServiciosCSO__c = :mapServCsoW.keySet() and SEG_Activo__c = true];

		for (SEG_GrupoTrabajoRelacionado__c detalleGrupo : lstDetalleGruposServ) {
			mapServCsoW.get(detalleGrupo.SEG_ServiciosCSO__c).idDetalleGrupos.add(detalleGrupo.SEG_GrupoTrabajo__c);
		}
	}
}