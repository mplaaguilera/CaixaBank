/*eslint-disable new-cap */
import {LightningElement, wire, track} from 'lwc';
import currentUserId from '@salesforce/user/Id';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import {createRecord} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {getObjectInfo, getPicklistValuesByRecordType} from 'lightning/uiObjectInfoApi';
import {getAllTabInfo, setTabIcon, setTabLabel} from 'lightning/platformWorkspaceApi';


//Apex
import getZonas from '@salesforce/apex/SEG_Casos_Por_Grupo.getZonas';
import definicionCamposCase from '@salesforce/apex/SEG_Casos_Por_Grupo.definicionCamposCase';
import getGruposListviews from '@salesforce/apex/SEG_Casos_Por_Grupo.getGruposListviews';
import getCasosGruposOperativos from '@salesforce/apex/SEG_Casos_Por_Grupo.getCasosGruposOperativos';
import tomarPropiedad from '@salesforce/apex/SEG_Casos_Por_Grupo.tomarPropiedad';
import esSupervisor from '@salesforce/apex/SEG_Casos_Por_Grupo.esSupervisor';
import rechazar from '@salesforce/apex/SEG_Casos_Por_Grupo.rechazar';
import cambioPropietario from '@salesforce/apex/SEG_Casos_Por_Grupo.cambiarPropietarioMasivo';
import cambioGrupo from '@salesforce/apex/SEG_Casos_Por_Grupo.cambiarGrupoMasivoLWC';
import cerrarCasos from '@salesforce/apex/SEG_Casos_Por_Grupo.cerrarCasoMasivoLWC';
import validarNifApex from '@salesforce/apex/SEG_Casos_Por_Grupo.validarNif';
import getUsuariosSEG from '@salesforce/apex/SEG_Casos_Por_Grupo.getUsuariosSEG';

//Schema
import OBJETO_CASE from '@salesforce/schema/Case';
import CAMPO_SUBJECT from '@salesforce/schema/Case.Subject';
import CAMPO_DESCRIPTION from '@salesforce/schema/Case.Description';
import CAMPO_IDIOMA from '@salesforce/schema/Case.CC_Idioma__c';
import CAMPO_CANALENTRADA from '@salesforce/schema/Case.Origin';
import CAMPO_RECORDTYPE from '@salesforce/schema/Case.RecordTypeId';
import CAMPO_OWNER from '@salesforce/schema/Case.OwnerId';
import CAMPO_ACCOUNT from '@salesforce/schema/Case.AccountId';
import CAMPO_ORG from '@salesforce/schema/Case.SEG_Organizacion__c';
import CAMPO_ZONA from '@salesforce/schema/Case.SEG_Zona__c';

const VERSION_FORMATO_FAVORITOS = 2;

//eslint-disable-next-line camelcase
export default class seg_Casos_Por_Grupo extends NavigationMixin(LightningElement) {

	funcionesBind = {};

	usuarioEsSupervisor = false;

	@track filtros = [];

	@track filtrosEdit = [];

	@wire(getObjectInfo, {objectApiName: OBJETO_CASE}) caseObjectInfo;

	casillasSelected = false;

	renderizarModales = false;

	zonas = [];

	zonasSeleccionadas = [];

	idTimeouts = {};

	camposCaseDefinicion;

	camposCasePicklist;

	camposCaseSeleccionados;

	camposCaseSeleccionadosEdit;

	modalCrearNuevoCasoIdiomaOptions;

	modalCrearNuevoCasoCanalEntradaOptions;

	logicaFiltro = null;

	filtroEditadoId;

	tipoBusquedaSeleccionada = {
		nombre: 'Grupos operativos',
		iconName: 'utility:people',
		iconNameResultado: 'custom:custom15',
		inputPlaceholder: 'Selecciona una opción...'
	};

	cargandoCasos = false;

	guardando = false;

	grupos = [];

	listviews = [];

	modalCrearNuevoCasoCuenta;

	resultadosBusqueda = [];

	gruposSeleccionados = {
		totalCount: 0,
		grupos: [],
		count: '',
		fechaActualizacion: ''
	};

	tipoBusquedaGetCasosGruposOperativos;

	//listadoSeleccionado = {id: '', nombre: ''};

	filtroCamposOptions = [
		{label: 'Número de centro', value: 'SEG_Numero_centro__c'},
		{label: 'Cuenta', value: 'Account.Name'},
		{label: 'Clasificación rápida', value: 'SEG_ClasificacionRapida__r.Name'},
		{label: 'Producto/Servicio', value: 'CC_MCC_ProdServ__r.Name'},
		{label: 'Motivo', value: 'CC_MCC_Motivo__r.Name'},
		{label: 'Detalle', value: 'SEG_Detalle__r.Name'},
		{label: 'Prioridad', value: 'Priority'},
		{label: 'Propietario Anterior', value: 'CC_Owner_Anterior__r.Name'},
		{label: 'Propietario Anterior de mi grupo', value: 'SEG_PropAnteriorGrupo__c'},
		{label: 'Número OSN', value: 'SEG_Numero_OSN__c'},
		{label: 'Número SOE', value: 'SEG_Numero_SOE__c'},
		{label: 'Gestor Comercial', value: 'SEG_Gestor_comercial__c'},
		{label: 'Gestor Operativa Nacional', value: 'SEG_Gestor_Operativa_Nacional__c'}
	];

	filtroOperadoresOtions = [
		{label: 'igual a', value: '='},
		{label: 'no igual a', value: '!='},
		{label: 'menor que', value: '<'},
		{label: 'mayor que', value: '>'},
		{label: 'menor o igual', value: '<='},
		{label: 'mayor o igual', value: '>='},
		{label: 'contiene', value: 'LIKE1'},
		{label: 'no contiene', value: 'LIKE2'},
		{label: 'comienza por', value: 'LIKE3'}
	];

	modalCrearFavoritoTitulo;

	camposCaseRequired = ['priority', 'createddate', 'casenumber'];

	pagina;

	datatableColumnas = [];

	//eslint-disable-next-line camelcase
	datatableColumnasWidths = {anchosManuales: false};

	//datatableColumnasVisibles = [];

	datatableDataSinFiltrar = [];

	filtrando = false;

	filtroEditado = false;

	datatableData = [];

	datatableSortedBy;

	datatableSortedDirection;

	favoritos = [];

	mostrarMenuFavoritos = false;

	primerRecordIdSeleccionado;

	mensajeNumeroZonasSeleccionadas = 'Todas las zonas seleccionadas';

	selectedItem;

	options = [];

	projectSelect;

	//showProject = true;
	showProject = false;

	showbutton;

	currentPageReference = null;

	typePage = null;

	disableButtonOwner = true;

	tiposBusqueda = [
		{label: 'Usuario', iconName: 'standard:user'},
		{label: 'Cola', iconName: 'standard:orders'}
	];

	tipoBusquedaSeleccionado = {label: 'Usuario', iconName: 'standard:user'};

	idTimeoutBusqueda;

	resultados = [];

	resultadoSeleccionado;

	get accionesDisabled() {
		return this.cargandoCasos || !this.casillasSelected;
	}

	/*No es necesario mientras no se habilite el tipo de bísqueda "Listados de casos"
	get tipoBusquedaSeleccionadaEsListviews() {
		return this.tipoBusquedaSeleccionada.nombre === 'Listados de casos';
	}
	*/

	/*No es necesario mientras no se habilite el tipo de bísqueda "Listados de casos"
	get mostrarInputBuscador() {
		if (this.buscando || this.tipoBusquedaSeleccionada.nombre === 'Grupos operativos') {
			return true;
		} else {
			return !this.listadoSeleccionado.nombre;
		}
	}
	*/

	get logicaFiltrosDisponible() {
		return this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre !== 'Nuevo filtro*').length > 1;
	}

	get zonasFiltradas() {
		return this.zonas.filter(zona => zona.seleccionada);
	}

	get botonFavoritoIconClases() {
		return this.botonFavoritosDisabled ? 'botonFavoritoIcon botonFavoritoIconDisabled' : 'botonFavoritoIcon';
	}

	//REVISAR
	get botonFavoritosDisabled() {
		return this.tipoBusquedaGetCasosGruposOperativos !== 'Casos de los grupos seleccionados'
			|| !this.gruposSeleccionados.grupos.length; //|| this.filtrosEdit.length;
	}

	get favoritoSeleccionadoAtributos() {
		let favoritoSeleccionado = this.favoritoSeleccionado();
		let objetoReturn = {
			favoritoSeleccionadoNombre: favoritoSeleccionado ? favoritoSeleccionado.nombre : '',
			botonFavoritoClases: 'botonFavorito slds-button slds-button_neutral slds-button_first' + (favoritoSeleccionado?.claseColor ? ' ' + favoritoSeleccionado.claseColor : ''),
			botonFavoritoIconoVariant: favoritoSeleccionado ? 'inverse' : ''
		};
		return objetoReturn;
	}

	get idRecordTypeCaseCliente() {
		if (this.caseObjectInfo?.data) {
			for (let [key, value] of Object.entries(this.caseObjectInfo.data.recordTypeInfos)) {
				if (value.name === 'Cliente (SEG)') {
					return key;
				}
			}
		}
		return null;
	}


	@wire(esSupervisor, {idUsuario: currentUserId})
	wiredEsSupervisor({error, data}) {
		if (error) {
			let errorMessage = error.body ? error.body.message : error.message;
			this.mostrarToast('error', 'Error recuperando información del usuario', JSON.stringify(errorMessage));
		} else if (data) {
			this.usuarioEsSupervisor = data;
		}
	}

	@wire(getPicklistValuesByRecordType, {objectApiName: OBJETO_CASE, recordTypeId: '$idRecordTypeCaseCliente'})
	wiredGetPicklistValuesByRecordType({error, data}) {
		if (error) {
			let errorMessage = error.body ? error.body.message : error.message;
			this.mostrarToast('error', 'Error recuperando información en Salesforce', JSON.stringify(errorMessage));
		} else if (data) {
			this.modalCrearNuevoCasoIdiomaOptions = data.picklistFieldValues.CC_Idioma__c.values;
			this.modalCrearNuevoCasoCanalEntradaOptions = data.picklistFieldValues.Origin.values;
		}
	}


	connectedCallback() {
		this.cambiarLabelTab(); //Cambiar icono y label del tab vía Workspace API

		if (localStorage.getItem('SEG_Casos_Por_Grupo_Personalizacion_' + currentUserId)) {
			this.personalizacionCargar(false, false);
		} else {
			this.personalizacionPorDefecto(false);
		}

		getZonas()
			.then(zonas => this.zonas = zonas.map(zona => ({...zona, seleccionada: this.zonasSeleccionadas.includes(zona.name)})));

		Promise.all([definicionCamposCase({}), this.obtenerGruposListViews()])
			.then(responses => {
				this.camposCaseDefinicion = responses[0];
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => {
					this.obtenerCasos();
					this.template.querySelector('.botonFiltros').disabled = this.tipoBusquedaGetCasosGruposOperativos !== 'Casos de los grupos seleccionados';
				}, 0, this);
			});

		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.cargarFavoritos(), 4000); //retraso para aligerar las acciones iniciales
	}

	async cargarFavoritos(jsonFavoritos = localStorage.getItem('SEG_Casos_Por_Grupo_Favoritos_' + currentUserId)) {
		if (jsonFavoritos) {
			let favoritos = JSON.parse(jsonFavoritos);
			if (!favoritos?.version || favoritos?.version < 2) {
				favoritos = favoritos.map(favorito => {
					let nuevoFavorito = {
						...favorito,
						zonasSeleccionadas: favorito.zonas,
						filtros: []
					};
					delete nuevoFavorito.zonas;
					return nuevoFavorito;
				});
				this.guardarFavoritos(favoritos);
				this.cargarFavoritos();
			} else {
				this.añadirFavoritos(favoritos.favoritos, false);
			}
		}
	}

	async obtenerGruposListViews(cacheTimestamp) {
		getGruposListviews({cacheTimestamp: cacheTimestamp})
			.then(retorno => {
				this.grupos = retorno.gruposOperativos.map(grupo => {
					const organizaciones = grupo.SEG_Organizacion__c ? grupo.SEG_Organizacion__c.replaceAll(';', ',  ') : '';
					const zonas = grupo.SEG_Zona__c ? grupo.SEG_Zona__c.replaceAll(';', ',  ') : '';
					return {
						...grupo,
						'SEG_Organizacion__c': organizaciones, 'SEG_Zona__c': zonas,
						'title': organizaciones + (organizaciones && zonas ? ' · ' : '') + zonas,
						'mostrarSeparador': organizaciones && zonas
					};
				});
				this.calcularEstilosResultadosGrupos();
				//this.listviews = retorno.listViews;
				if (this.tipoBusquedaSeleccionada.nombre === 'Grupos operativos') {
					this.resultadosBusqueda = this.grupos;
				}//else if (this.tipoBusquedaSeleccionada.nombre === 'Listados de casos') {
				//this.resultadosBusqueda = retorno.listViews;
				//}
				if (cacheTimestamp) {
					this.mostrarToast('success', 'Grupos y listados actualizados', 'Se han actualizado los grupos operativos y listados de casos seleccionables');
				}
			}).catch(error => this.mostrarError(error, 'Error recuperando los grupos operativos y listados de casos'));
	}

	calcularEstilosResultadosGrupos() {
		this.grupos = this.grupos.map(grupoOperativo => {
			grupoOperativo = {...grupoOperativo};
			//if (this.gruposSeleccionados.grupos.map(grupoSeleccionado => grupoSeleccionado.Id).includes(grupoOperativo.Id)) {
			if (this.gruposSeleccionados.grupos.some(grupoSeleccionado => grupoSeleccionado.Id === grupoOperativo.Id)) {
				grupoOperativo.disabled = 'true';
				grupoOperativo.iconName = 'standard:task2';
				grupoOperativo.iconClass = 'iconoResultadoSeleccionado';
				grupoOperativo.mediaBodyStyle = 'color: #121111;';
			} else {
				grupoOperativo.disabled = 'false';
				grupoOperativo.iconName = this.tipoBusquedaSeleccionada.iconNameResultado;
				grupoOperativo.iconClass = '';
				grupoOperativo.mediaBodyStyle = '';
			}
			return grupoOperativo;
		});
	}

	obtenerCasos(showMore = false) {
		let fieldNames = [...this.camposCaseSeleccionados];
		if (this.tipoBusquedaGetCasosGruposOperativos === 'Mis casos planificados' && !fieldNames.includes('seg_fecha_planificaci_n__c')) {
			fieldNames.splice(fieldNames.indexOf('createddate') + 1, 0, 'seg_fecha_planificaci_n__c');
		}
		this.datatableColumnasActualizar(fieldNames)
			.then(() => {
				if (this.tipoBusquedaGetCasosGruposOperativos === 'Casos de los grupos seleccionados' && !this.gruposSeleccionados.grupos.length) {
					this.gruposSeleccionados.totalCount = 0;
					this.gruposSeleccionados.count = 0;
					this.gruposSeleccionados.fechaActualizacion = '';
					this.datatableDataSinFiltrar = [];
					this.datatableData = [];
				} else {
					this.setCargandoCasos(true);
					this.animarBotoActualizarInicio();
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout(() => {
						let datatableCasos = this.template.querySelector('.datatableCasos');
						if (datatableCasos) {
							datatableCasos.enableInfiniteLoading = true;
						}
						this.pagina = showMore ? this.pagina + 1 : 0;
						this.stringFiltros();
						getCasosGruposOperativos({
							idGruposOperativos: this.gruposSeleccionados.grupos.map(grupoSeleccionado => grupoSeleccionado.Id),
							tipoBusqueda: this.tipoBusquedaGetCasosGruposOperativos,
							fieldNames: [...fieldNames, 'seg_priority_orden__c'],
							zonas: this.zonasSeleccionadas,
							pagina: this.pagina,
							incluirCount: !showMore,
							filtrosJSON: JSON.stringify(this.filtros),
							logicaFiltro: this.logicaFiltro
						}).then(retorno => {
							if (retorno.casos?.length) {
								//Recuperar definición de campos lookups esperados en la respuesta
								const relationships = this.camposCaseDefinicion.filter(campoCaseDefinicion => this.camposCaseSeleccionados.includes(campoCaseDefinicion.name)
									&& campoCaseDefinicion.displayType === 'REFERENCE').map(campoCaseDefinicion => ({name: campoCaseDefinicion.name, relationshipName: campoCaseDefinicion.relationshipName}));

								let casos = retorno.casos.map(caso => {
									//Pasar claves a minúsculas
									let key, keys = Object.keys(caso);
									let n = keys.length;
									let casoNew = {};
									while (n--) {
										key = keys[n];
										casoNew[key.toLowerCase()] = caso[key];
									}

									//eslint-disable-next-line camelcase
									casoNew.casenumber__url = '/' + casoNew.id;
									casoNew.priority = casoNew.priority ?? '';

									//Lookups
									relationships.forEach(relationship => {
										if (Object.prototype.hasOwnProperty.call(casoNew, relationship.relationshipName.toLowerCase())) {
											casoNew[relationship.name + '__label'] = casoNew[relationship.relationshipName.toLowerCase()]?.Name;
										}
										if (Object.prototype.hasOwnProperty.call(casoNew, relationship.name.toLowerCase())) {
											casoNew[relationship.name] = '/' + casoNew[relationship.name];
										}
									});
									return casoNew;
								});

								if (this.datatableSortedBy !== 'priority' || this.datatableSortedDirection !== 'desc') {
									this.datatableDataSinFiltrar = this.datatableDataOrdenar(
										showMore ? [...this.datatableDataSinFiltrar, ...casos] : casos,
										this.datatableSortedBy,
										this.datatableSortedDirection
									);
								} else {
									this.datatableDataSinFiltrar = showMore ? [...this.datatableDataSinFiltrar, ...casos] : casos;
								}

								//Eliminar búsqueda existente
								this.datatableData = this.datatableDataSinFiltrar;
								let inputBuscarEnLista = this.template.querySelector('.inputBuscarEnLista');
								if (inputBuscarEnLista) {
									inputBuscarEnLista.value = null;
									inputBuscarEnLista.classList.remove('inputBordeNaranja');
								}
								this.filtrando = false;

								if (!showMore) {
									this.gruposSeleccionados.totalCount = retorno.totalCount;
								}
								//eslint-disable-next-line @lwc/lwc/no-async-operation
								//window.setTimeout(() => {
								this.gruposSeleccionados.count = this.datatableDataSinFiltrar.length;
								const ahora = new Date();
								this.gruposSeleccionados.fechaActualizacion = ahora.getHours() + ':' + ahora.getMinutes().toString().padStart(2, '0') + ':' + ahora.getSeconds().toString().padStart(2, '0');
								//}, 20);

								if (this.datatableDataSinFiltrar.length >= this.gruposSeleccionados.totalCount) {
									datatableCasos.enableInfiniteLoading = false;
								} else if (!this.template.querySelector('.datatableCasos').enableInfiniteLoading && this.datatableDataSinFiltrar.length < this.gruposSeleccionados.totalCount) {
									datatableCasos.enableInfiniteLoading = true;
								}
							} else {
								this.gruposSeleccionados.totalCount = retorno.totalCount;
								this.datatableData = [];
							}
						}).catch(error => this.mostrarError(error, 'Error recuperando la lista de casos'))
							.finally(() => this.setCargandoCasos(false));
					}, 0);
				}
			});
	}

	stringFiltros() {
		let retorno = '';
		if (this.filtros?.length) {
			if (this.logicaFiltro) {
				retorno = this.logicaFiltro;
			} else {
				retorno = this.logicaFiltro ? this.logicaFiltro : this.filtros.reduce((s, _f, i) => s += (i + 1).toString() + ' AND ', '');
				retorno = retorno.substring(0, retorno.lastIndexOf(' AND '));
			}
			this.filtros.forEach((filtro, index) => {
				let conjuntoFiltro;
				if (filtro.operador === 'contiene') {
					conjuntoFiltro = filtro.campo + ' LIKE \'%' + filtro.valor + '%\'';
				} else if (filtro.operador === 'no contiene') {
					conjuntoFiltro = '(NOT ' + filtro.campo + ' LIKE \'%' + filtro.valor + '%\')';
				} else if (filtro.operador === 'comienza por') {
					conjuntoFiltro = filtro.campo + ' LIKE \'' + filtro.valor + '%\'';
				} else {
					conjuntoFiltro = filtro.campo + ' ' + filtro.operadorApi + ' \'' + filtro.valor + '\'';
				}
				retorno = retorno.replaceAll(index + 1, conjuntoFiltro);
			});
		}
		return retorno ? ' AND (' + retorno + ')' : '';
	}

	async menuSettingsOnclick(event) {
		event.stopPropagation();
		await this.panelFiltrosCerrar();
	}

	menuSettingsOnselect(event) {
		if (event.detail.value === 'refrescarDatos') {
			this.obtenerGruposListViews(new Date);
		} else if (event.detail.value === 'guardarPersonalizacion') {
			let personalizacion = {
				camposCaseSeleccionados: this.camposCaseSeleccionados,
				tipoBusquedaGetCasosGruposOperativos: this.tipoBusquedaGetCasosGruposOperativos,
				datatableSortedBy: this.datatableSortedBy,
				datatableSortedDirection: this.datatableSortedDirection,
				gruposSeleccionados: [...this.gruposSeleccionados.grupos],
				zonasSeleccionadas: [...this.zonasSeleccionadas],
				filtros: [...this.filtros],
				logicaFiltro: this.logicaFiltro,
				datatableColumnasWidths: {...this.datatableColumnasWidths}
			};
			localStorage.setItem('SEG_Casos_Por_Grupo_Personalizacion_' + currentUserId, JSON.stringify(personalizacion));
			this.mostrarToast('success', 'Personalización guardada', 'La personalización actual se guardó correctamente');
		} else if (event.detail.value === 'cargarPersonalizacion') {
			this.personalizacionCargar();
		} else if (event.detail.value === 'restablecerPsizeersonalizacionPorDefecto') {
			this.modalRestablecerPersonalizacionPorDefectoAbrir();
		} else if (event.detail.value === 'importarFavoritos') {
			this.modalImportarExportarFavoritosAbrir(true);
		} else if (event.detail.value === 'exportarFavoritos') {
			this.modalImportarExportarFavoritosAbrir(false);
		} else if (event.detail.value === 'eliminarFavoritos') {
			this.favoritosEliminarTodos();
		} else if (event.detail.value === 'log') {
			//eslint-disable-next-line no-console
			//debugger;
		}
	}

	datatableOnresize(event) {
		if (event.detail.isUserTriggered) {
			let datatableColumnasWidths = {anchosManuales: true};
			event.detail.columnWidths.forEach((columnWidth, index) => {
				datatableColumnasWidths[this.datatableColumnas[index].fieldName] = columnWidth;
			});
			this.datatableColumnasWidths = datatableColumnasWidths;
		}
	}

	tipoBusquedaClick() {
		this.template.querySelector('.tipoBusqueda').classList.remove('slds-hide');
	}

	tipoBusquedaBlur() {
		this.template.querySelector('.tipoBusqueda').classList.add('slds-hide');
	}

	seleccionarTipoBusqueda(event) {
		if (event.currentTarget.classList.contains('tipoBusquedaGruposOperativos')) {
			this.tipoBusquedaSeleccionada = {
				nombre: 'Grupos operativos',
				iconName: 'utility:people',
				iconNameResultado: 'custom:custom15',
				inputPlaceholder: 'Seleccionar o buscar una opción...'
			};
			this.resultadosBusqueda = this.grupos;
			this.template.querySelector('.tipoBusquedaGruposOperativos').classList.add('slds-is-selected');
			this.template.querySelector('.tipoBusquedaListadosCasos').classList.remove('slds-is-selected');
		} else if (event.currentTarget.classList.contains('tipoBusquedaListadosCasos')) {
			this.tipoBusquedaSeleccionada = {
				nombre: 'Listados de casos',
				iconName: 'utility:case',
				iconNameResultado: 'standard:case',
				inputPlaceholder: 'Seleccionar listado de casos'
			};
			this.resultadosBusqueda = this.listviews;
			this.template.querySelector('.tipoBusquedaListadosCasos').classList.add('slds-is-selected');
			this.template.querySelector('.tipoBusquedaGruposOperativos').classList.remove('slds-is-selected');
		}
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.template.querySelector('.inputBuscarGrupo').mousedown();
			this.template.querySelector('.inputBuscarGrupo').focus();
			this.inputBuscarChange();
		}, 150);
	}

	inputBuscarChange(event) {
		const textoBusqueda = event.detail.value.trim().toLowerCase();
		let inputBuscarGrupoIconoDropdown = this.template.querySelector('.inputBuscarGrupoIconoDropdown');
		if (textoBusqueda) {
			inputBuscarGrupoIconoDropdown.classList.add('oculto');
			this.resultadosBuscadorAbrir();
		} else {
			inputBuscarGrupoIconoDropdown.classList.remove('oculto');
		}

		if (this.tipoBusquedaSeleccionada.nombre === 'Grupos operativos') {
			if (this.grupos.length > 0) {
				this.resultadosBusqueda = this.grupos.filter(grupo => grupo.Name.toLowerCase().includes(textoBusqueda));
			}
		} else if (this.tipoBusquedaSeleccionada.nombre === 'Listados de casos') {
			if (this.listviews.length > 0) {
				this.resultadosBusqueda = this.listviews.filter(listview => listview.Name.toLowerCase().includes(textoBusqueda));
			}
		}
	}

	inputBuscarMousedown(event) {
		this.resultadosBuscadorAbrir();
		event.stopPropagation();
	}

	resultadosBuscadorAbrir() {
		let resultadosBuscador = this.template.querySelector('.resultadosBuscador');
		if (!resultadosBuscador.classList.contains('visible')) {
			this.funcionesBind.resultadosBuscadorCerrar = this.resultadosBuscadorCerrar.bind(this);
			window.addEventListener('mousedown', this.funcionesBind.resultadosBuscadorCerrar);
			resultadosBuscador.classList.add('visible');
			this.template.querySelector('.busquedaBackdrop').classList.add('slds-backdrop--open');
			this.template.querySelector('.inputBuscarGrupo').focus();
		}
	}

	resultadosBuscadorCerrar(deseleccionarGrupos = false) {
		window.removeEventListener('mousedown', this.funcionesBind.resultadosBuscadorCerrar);
		deseleccionarGrupos = typeof deseleccionarGrupos === 'boolean' && deseleccionarGrupos;
		//this.buscando = false;
		this.template.querySelector('.busquedaBackdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.resultadosBuscador').classList.remove('visible');
		if (deseleccionarGrupos) {
			this.gruposSeleccionados.grupos = [];
			this.calcularEstilosResultadosGrupos();
			this.resultadosBusqueda = this.grupos;
			this.obtenerCasos();
		}
	}

	inputBuscarTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.resultadosBuscadorCerrar();
		}
	}

	selectMenuSettingsDatatable(event) {
		if (event.detail.value === 'modalCamposAbrir') {
			this.modalCamposAbrir();
		} else if (event.detail.value === 'restablecerOrdenacion') {
			this.datatableDataOrdenar(this.datatableData, 'priority', 'desc');
			this.datatableData = [...this.datatableData];
		} else if (event.detail.value === 'restablecerTamañoColumnas') {
			this.datatableColumnasWidths = {anchosManuales: false};
			let fieldNames = [...this.camposCaseSeleccionados];
			if (this.tipoBusquedaGetCasosGruposOperativos === 'Mis casos planificados' && !fieldNames.includes('seg_fecha_planificaci_n__c')) {
				fieldNames.splice(fieldNames.indexOf('createddate') + 1, 0, 'seg_fecha_planificaci_n__c');
			}
			this.datatableColumnasActualizar(fieldNames);
		}
	}

	clonarFavorito() {
		this.mostrarMenuFavoritos = false;
		this.modalCrearFavoritoTitulo = 'Clonar favorito';
		this.modalCrearFavoritoAbrir();
	}

	cambiarTipoBusquedaGetCasosGruposOperativos(nuevoTipoBusqueda) {
		if (this.tipoBusquedaGetCasosGruposOperativos !== nuevoTipoBusqueda) {
			if (nuevoTipoBusqueda !== 'Casos de los grupos seleccionados') {
				this.filtros = [];
				this.filtrosEdit = [];
			}

			let botonFiltros = this.template.querySelector('.botonFiltros');
			if (botonFiltros) {
				botonFiltros.disabled = nuevoTipoBusqueda !== 'Casos de los grupos seleccionados';
			}
			this.panelFiltrosCerrar();
			this.tipoBusquedaGetCasosGruposOperativos = nuevoTipoBusqueda;
		}
	}

	seleccionarResultado(event) {
		let idGrupoSeleccionado = event.currentTarget.dataset.id;
		let tipoBusquedaSeleccionada = event.currentTarget.dataset.tipobusqueda;
		//if (this.tipoBusquedaSeleccionada.nombre === 'Grupos operativos') {
		if (tipoBusquedaSeleccionada !== 'Casos de los grupos seleccionados') {
			if (this.gruposSeleccionados.grupos.length > 1 && !this.favoritoSeleccionado()) {
				this.confirmacionDeseleccionarGruposAbrir(tipoBusquedaSeleccionada);
			} else {
				this.cambiarTipoBusquedaGetCasosGruposOperativos(tipoBusquedaSeleccionada);
				this.gruposSeleccionados.grupos = [];
				this.calcularEstilosResultadosGrupos();
				this.resultadosBusqueda = this.grupos; //?
				this.datatableRefresh();
			}
		} else if (tipoBusquedaSeleccionada === 'Casos de los grupos seleccionados') {
			let resultadoSeleccionado = this.grupos.find(grupo => grupo.Id === idGrupoSeleccionado);
			if (resultadoSeleccionado) {
				//Mostrar casos del grupo operativo seleccionado
				let temp = this.template.querySelector('[data-id="' + idGrupoSeleccionado + '"]');
				temp.classList.add('slds-is-selected');
				if (!this.gruposSeleccionados.grupos.length
					|| !this.gruposSeleccionados.grupos.some(grupoSeleccionado => grupoSeleccionado.Id === idGrupoSeleccionado)) {
					this.cambiarTipoBusquedaGetCasosGruposOperativos('Casos de los grupos seleccionados');
					this.gruposSeleccionados.grupos.push({Id: idGrupoSeleccionado, Name: resultadoSeleccionado.Name});
					this.gruposSeleccionados = {...this.gruposSeleccionados};
					this.calcularEstilosResultadosGrupos();
					this.zonasSeleccionadas = [...this.zonasSeleccionadas];
					this.actualizarMensajeNumeroZonasSeleccionadas();
					this.resultadosBusqueda = this.grupos;
					this.datatableRefresh();
				}
			}
		}
		/*
		} else if (this.tipoBusquedaSeleccionada.nombre === 'Listados de casos' && idGrupoSeleccionado) {
			let resultadoSeleccionado = this.listviews.find(listview => listview.Id === idGrupoSeleccionado);
			if (resultadoSeleccionado) {
				//Mostrar casos del listado de casos seleccionado
				let temp = this.template.querySelector('[data-id="' + idGrupoSeleccionado + '"]');
				temp.classList.add('slds-is-selected');

				this.listadoSeleccionado.id = idGrupoSeleccionado;
				this.listadoSeleccionado.nombre = resultadoSeleccionado.Name;
				this.listadoSeleccionado = {...this.listadoSeleccionado};
			}
		}
		*/
		this.resultadosBuscadorCerrar();
	}

	modalCamposAbrir() {
		if (!this.camposCasePicklist) {
			//La picklist espera el nombre del campo en la propiedad "name"
			this.camposCasePicklist = this.camposCaseDefinicion.filter(campoCase => campoCase.name !== 'seg_priority_orden__c')
				.map(campoCase => Object.fromEntries(Object.entries(campoCase).map(([campo, valorCampo]) => [campo === 'name' ? 'value' : campo, valorCampo])))
				//eslint-disable-next-line no-confusing-arrow
				.sort((a, b) => a.label > b.label ? 1 : b.label > a.label ? -1 : 0);
		}
		this.template.querySelector('.modalCampos').classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelector('.botonCamposCancelar').focus(), 150);
		this.camposCaseSeleccionadosEdit = this.camposCaseSeleccionados;
	}

	modalCambiarPropietarioAbrir() {
		this.template.querySelector('.modalCambiarPropietario').classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		this.template.querySelector('.botonPropietarioCancelar').focus();
	}

	modalCambiarGrupoAbrir() {
		this.template.querySelector('.modalCambiarGrupo').classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		this.template.querySelector('.botonGrupoCancelar').focus();
	}

	modalCamposTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalCamposCerrar();
		}
	}

	modalCrearNuevoCasoTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalCrearNuevoCasoCerrar();
		}
	}

	modalCambiarPropietarioTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalCambiarPropietarioCerrar();
		}
	}

	modalCambiarGrupoTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalCambiarGrupoCerrar();
		}
	}

	modalCamposCerrar() {
		this.template.querySelector('.modalCampos').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalCambiarPropietarioCerrar() {
		this.template.querySelector('.modalCambiarPropietario').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
		//this.template.querySelector('.inputNuevoPropietario').value = null;
		this.resultadoSeleccionado = null;
	}

	modalCambiarGrupoCerrar() {
		this.template.querySelector('.modalCambiarGrupo').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.inputNuevoGrupo').value = null;
	}

	camposCaseChange(event) {
		this.camposCaseSeleccionadosEdit = event.detail.value;
	}

	modalCamposGuardar() {
		this.camposCaseSeleccionados = [...this.añadirLookups(this.camposCaseSeleccionadosEdit)];
		this.camposCaseSeleccionadosEdit = [];
		this.obtenerCasos();
		this.template.querySelector('.modalCampos').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	async datatableColumnasActualizar(campos) {
		const datatableColumnas = [];
		if (campos) {
			campos = campos.filter(campoCaseSeleccionado => !campoCaseSeleccionado.includes('.'));
			campos.forEach(campoSeleccionado => {
				const definicionCampo = this.camposCaseDefinicion.find(campoCaseDefinicion => campoCaseDefinicion.name === campoSeleccionado);
				const definicionCampoDisplayType = this.displayTypeToDatatableColumnType(definicionCampo.displayType);
				const datatableColumna = {
					type: definicionCampoDisplayType,
					label: definicionCampo.label,
					fieldName: definicionCampo.name,
					sortable: true,
					initialWidth: this.datatableColumnasWidths[campoSeleccionado],
					hideDefaultActions: definicionCampoDisplayType !== 'text' || campoSeleccionado === 'priority',
					typeAttributes: null
				};
				if (campoSeleccionado === 'casenumber') {
					datatableColumna.fieldName = 'casenumber__url';
					datatableColumna.type = 'url';
					datatableColumna.typeAttributes = {label: {fieldName: definicionCampo.name}, target: '_self'};
				} else if (campoSeleccionado === 'priority') {
					datatableColumna.type = 'iconoPrioridad';
					datatableColumna.hideLabel = true;
					datatableColumna.iconName = 'utility:priority';
					datatableColumna.fixedWidth = 53;
					datatableColumna.typeAttributes = {prioridad: {fieldName: 'priority'}, tooltip: {fieldName: 'priority'}};
					datatableColumna.cellAttributes = {alignment: 'center'};
				} else if (definicionCampo.displayType === 'DATE') {
					datatableColumna.typeAttributes = {
						day: 'numeric', month: 'numeric', year: 'numeric'
					};
				} else if (definicionCampo.displayType === 'DATETIME') {
					if (campoSeleccionado === 'createddate') {
						datatableColumna.label = 'Fecha creación';
						datatableColumna.fixedWidth = 120;
					}
					datatableColumna.typeAttributes = {
						year: '2-digit', month: 'numeric', day: '2-digit', hour: 'numeric', minute: 'numeric'
					};
				} else if (definicionCampo.displayType === 'REFERENCE') {
					datatableColumna.fieldName = definicionCampo.name;
					datatableColumna.typeAttributes = {
						label: {fieldName: definicionCampo.name + '__label'}, target: '_self'
					};
				}
				datatableColumnas.push(datatableColumna);
			});
			this.datatableColumnas = datatableColumnas;
			//this.datatableColumnasVisibles = datatableColumnas.filter(datatableColumna => datatableColumna.fieldName !== 'seg_priority_orden__c');
		}
	}

	datatableSort(event) {
		this.datatableData = this.datatableDataOrdenar(this.datatableData, event.detail.fieldName, event.detail.sortDirection);
	}

	datatableDataOrdenar(data, sortedBy, sortedDirection) {
		let nombreCampoSort = sortedBy;
		this.datatableSortedBy = sortedBy;
		this.datatableSortedDirection = sortedDirection;
		const columnType = this.datatableColumnas.find(columna => columna.fieldName === nombreCampoSort).type;
		if (nombreCampoSort === 'priority') {
			nombreCampoSort = 'seg_priority_orden__c';
			sortedDirection = sortedDirection === 'asc' ? 'desc' : 'asc';
		} else if (nombreCampoSort === 'casenumber__url') {
			nombreCampoSort = 'casenumber';
		} else if (columnType === 'url') {
			nombreCampoSort += '__label';
		}

		let convertir;
		if (columnType === 'date') {
			convertir = valor => valor && new Date(valor);
		} else if (columnType === 'number') {
			//eslint-disable-next-line no-extra-parens
			convertir = valor => (valor != null ? valor : -1);
		} else {
			//eslint-disable-next-line no-extra-parens
			convertir = valor => (valor ? valor : '');
		}
		return [...data.sort((registro1, registro2) => {
			let sortedDirectionAux = sortedDirection === 'asc' ? 1 : -1;
			let valorRegistro1 = convertir(registro1[nombreCampoSort]);
			let valorRegistro2 = convertir(registro2[nombreCampoSort]);

			if (valorRegistro1 === valorRegistro2) {
				valorRegistro1 = convertir(registro1.seg_priority_orden__c);
				valorRegistro2 = convertir(registro2.seg_priority_orden__c);
				sortedDirectionAux = '1';
				if (valorRegistro1 === valorRegistro2) {
					valorRegistro1 = convertir(registro1.createddate);
					valorRegistro2 = convertir(registro2.createddate);
				}
			}
			return valorRegistro1 < valorRegistro2 ? -sortedDirectionAux : sortedDirectionAux;
		})];

	}

	datatableRefresh() {
		this.obtenerCasos();
		this.template.querySelector('.datatableCasos').selectedRows = [];
		this.casillasSelected = false;
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}

	displayTypeToDatatableColumnType(displayType) {
		switch (displayType) {
			case 'REFERENCE':
			case 'URL':
				return 'url';
			case 'CHECKBOX':
				return 'boolean';
			case 'DATE':
			case 'DATETIME':
				return 'date';
			case 'PHONE':
				return 'phone';
			case 'EMAIL':
				return 'email';
			case 'DOUBLE':
				return 'number';
			case 'CURRENCY':
				return 'currency';
			default:
				return 'text';
		}
	}

	añadirLookups(listaCampos) {
		listaCampos.filter(nombreCampo => !nombreCampo.includes('.') && this.camposCaseDefinicion.find(definicionCampoCase => nombreCampo === definicionCampoCase.name).displayType === 'REFERENCE').forEach(lookup => {
			listaCampos.push(this.camposCaseDefinicion.find(definicionCampoCase => lookup === definicionCampoCase.name).relationshipName + '.Name');
		});
		return [...new Set(listaCampos)];
	}

	modalRestablecerPersonalizacionPorDefectoAbrir() {
		this.template.querySelector('.modalRestablecerPersonalizacionPorDefecto').classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		this.template.querySelector('.botonRestablecerPersonalizacionPorDefectoCancelar').focus();
	}

	modalRestablecerPersonalizacionPorDefectoCerrar() {
		this.template.querySelector('.modalRestablecerPersonalizacionPorDefecto').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalRestablecerPersonalizacionPorDefectoTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalRestablecerPersonalizacionPorDefectoCerrar();
		}
	}

	modalRestablecerPersonalizacionPorDefectoRestablecer() {
		this.personalizacionPorDefecto();
		this.modalRestablecerPersonalizacionPorDefectoCerrar();
		this.mostrarToast('info', 'Personalización por defecto restaurada', 'La personalización por defecto se restauró correctamente');
	}

	personalizacionCargar(cargarCasos = true, mostrarToast = true) {
		let personalizacionString = localStorage.getItem('SEG_Casos_Por_Grupo_Personalizacion_' + currentUserId);
		if (personalizacionString) {
			let personalizacion = JSON.parse(personalizacionString);
			this.camposCaseSeleccionados = personalizacion.camposCaseSeleccionados ? [...personalizacion.camposCaseSeleccionados] : [];
			this.cambiarTipoBusquedaGetCasosGruposOperativos(personalizacion.tipoBusquedaGetCasosGruposOperativos);
			this.datatableSortedBy = personalizacion?.datatableSortedBy;
			this.datatableSortedDirection = personalizacion?.datatableSortedDirection;
			this.gruposSeleccionados.grupos = personalizacion.gruposSeleccionados ? [...personalizacion.gruposSeleccionados] : [];
			this.filtros = personalizacion.filtros ? [...personalizacion.filtros] : [];
			this.filtrosEdit = [...this.filtros];
			this.logicaFiltro = personalizacion?.logicaFiltro;
			this.datatableColumnasWidths = personalizacion.datatableColumnasWidths ? {...personalizacion.datatableColumnasWidths} : {anchosManuales: false};
			this.zonasSeleccionadas = personalizacion.zonasSeleccionadas ? [...personalizacion.zonasSeleccionadas] : [];
			this.actualizarMensajeNumeroZonasSeleccionadas();
			this.actualizarZonasSeleccionadas(cargarCasos);
			if (cargarCasos) {
				this.obtenerCasos();
			}
			if (mostrarToast) {
				this.mostrarToast('success', 'Personalización restaurada', 'La personalización guardada en este equipo se restauró correctamente');
			}
		}
	}

	personalizacionPorDefecto(cargarCasos = true) {
		localStorage.removeItem('SEG_Casos_Por_Grupo_Personalizacion_' + currentUserId);
		this.camposCaseSeleccionados = ['priority', 'createddate', 'casenumber', 'seg_zona__c', 'seg_numero_centro__c', 'accountid', 'Account.Name', 'contactid', 'Contact.Name', 'subject', 'status', 'seg_subestado__c', 'seg_clasificacionrapida__c', 'SEG_ClasificacionRapida__r.Name', 'seg_grupo__c', 'SEG_Grupo__r.Name', 'seg_case_owner__c'];
		this.cambiarTipoBusquedaGetCasosGruposOperativos('Mis casos');
		this.datatableSortedBy = 'priority';
		this.datatableSortedDirection = 'desc';
		this.gruposSeleccionados = {grupos: [], count: '', fechaActualizacion: ''};
		this.zonasSeleccionadas = [];
		this.actualizarMensajeNumeroZonasSeleccionadas();
		this.filtros = [];
		this.logicaFiltro = null;
		this.datatableColumnasWidths = {anchosManuales: false};
		if (cargarCasos) {
			this.obtenerCasos();
		}
	}

	inputBuscarEnListaKeydown(event) {
		if (event.keyCode === 13) { //Intro
			let inputBuscarEnLista = this.template.querySelector('.inputBuscarEnLista');
			if (inputBuscarEnLista.value) {
				this.filtrando = true;
				this.datatableData = this.filtrarDatatableData(inputBuscarEnLista.value);
				inputBuscarEnLista.classList.add('inputBordeNaranja');
			} else {
				this.filtrando = false;
				this.datatableData = this.datatableDataSinFiltrar;
				inputBuscarEnLista.classList.remove('inputBordeNaranja');
			}
		}
	}

	filtrarDatatableData(filtro) {
		return this.datatableDataSinFiltrar.filter(registro => {
			let filtrar = false;

			for (let [key, value] of Object.entries(registro)) {
				let keysIgnoradas = ['id', 'casenumber', 'seg_priority_orden__c', 'priority'];
				if (value !== null && !key.endsWith('__label') && !key.endsWith('__url') && !key.endsWith('id') && !keysIgnoradas.includes(key)) {
					if (typeof value === 'object') {
						if (value.Name.toLowerCase().includes(filtro.toLowerCase())) {
							filtrar = true;
						}
					} else if (typeof value === 'string') {
						if (value.toLowerCase().includes(filtro.toLowerCase())) {
							filtrar = true;
						}
					} else if (typeof value === 'boolean') {
						if (String(value).toLowerCase() === filtro.toLowerCase()) {
							filtrar = true;
						}
					} else if (typeof value === 'number') {
						if ((value + '').includes(filtro.toLowerCase())) {
							filtrar = true;
						}
					} else {
						if (value.includes(filtro)) {
							filtrar = true;
						}
					}
				}
			}
			return filtrar;
		});
	}

	deseleccionarGrupo(event) {
		this.gruposSeleccionados.grupos = this.gruposSeleccionados.grupos.filter(grupoSeleccionado => grupoSeleccionado.Id !== event.currentTarget.dataset.idgrupo);
		this.gruposSeleccionados = {...this.gruposSeleccionados};
		//this.zonasSeleccionadas = [...this.zonasSeleccionadas];
		this.calcularEstilosResultadosGrupos();
		this.resultadosBusqueda = this.grupos;
		this.obtenerCasos();
	}

	confirmacionDeseleccionarGruposAbrir(nuevoTipoBusquedaGetCasosGruposOperativos) {
		let confirmacionDeseleccionarGrupos = this.template.querySelector('.confirmacionDeseleccionarGrupos');
		confirmacionDeseleccionarGrupos.querySelector('.confirmacionDeseleccionarGruposContinuar').dataset.nuevoTipoBusqueda = nuevoTipoBusquedaGetCasosGruposOperativos;
		confirmacionDeseleccionarGrupos.classList.add('visible');
		confirmacionDeseleccionarGrupos.querySelector('.confirmacionDeseleccionarGruposCancelar').focus();
	}

	confirmacionDeseleccionarGruposCancelar(event) {
		event.currentTarget.closest('.confirmacionDeseleccionarGrupos').classList.remove('visible');
		this.resultadosBuscadorAbrir();
	}

	confirmacionDeseleccionarGruposCerrar() {
		this.resultadosBuscadorAbrir();
		this.template.querySelector('.inputBuscarGrupo').focus();
	}

	confirmacionDeseleccionarGruposContinuar(event) {
		event.currentTarget.closest('.confirmacionDeseleccionarGrupos').classList.remove('visible');
		this.cambiarTipoBusquedaGetCasosGruposOperativos(event.currentTarget.dataset.nuevoTipoBusqueda);
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		this.resultadosBuscadorCerrar(true);
	}

	confirmacionDeseleccionarGruposKeyDown(event) {
		if (event.keyCode === 27) { //ESC
			this.confirmacionDeseleccionarGruposCancelar();
		}
	}

	comboboxZonasAbrirCerrar() {
		let comboboxZonas = this.template.querySelector('.comboboxZonas');
		if (comboboxZonas.classList.contains('slds-is-open')) {
			this.comboboxZonasCerrar(comboboxZonas);
		} else {
			this.comboboxZonasAbrir(comboboxZonas);
		}
	}

	comboboxZonasAbrir(comboboxZonas) {
		comboboxZonas.classList.add('slds-is-open');
		this.funcionesBind.comboboxZonasCerrar = this.comboboxZonasCerrar.bind(this, comboboxZonas);
		window.addEventListener('click', this.funcionesBind.comboboxZonasCerrar);
	}

	comboboxZonasCerrar(comboboxZonas) {
		window.removeEventListener('click', this.funcionesBind.comboboxZonasCerrar);
		comboboxZonas.classList.remove('slds-is-open');
	}

	zonaOnClick(event) {
		let zonaName = event.currentTarget.dataset.zona;
		if (!this.zonasSeleccionadas.includes(zonaName)) {
			this.zonasSeleccionadas.push(zonaName);
		} else {
			this.zonasSeleccionadas.splice(this.zonasSeleccionadas.indexOf(this.zonasSeleccionadas.find(zonaSeleccionada => zonaSeleccionada === zonaName)), 1);
		}
		this.actualizarMensajeNumeroZonasSeleccionadas();
		this.actualizarZonasSeleccionadas();
	}

	actualizarZonasSeleccionadas(actualizarCasos = true, delay = true) {
		this.zonas = [...this.zonas.map(zona => ({...zona, seleccionada: this.zonasSeleccionadas.includes(zona.name)}))];
		if (actualizarCasos) {
			window.clearTimeout(this.idTimeouts.zonasClick);
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.idTimeouts.zonasClick = window.setTimeout(() => this.obtenerCasos(), delay ? 1200 : 0);
		}
	}

	deseleccionarZona(event) {
		this.zonasSeleccionadas.splice(this.zonasSeleccionadas.indexOf(this.zonasSeleccionadas.find(zonaSeleccionada => zonaSeleccionada === event.currentTarget.dataset.zona)), 1);
		this.actualizarMensajeNumeroZonasSeleccionadas();
		this.actualizarZonasSeleccionadas(true, false);
	}

	deseleccionarFiltro(event) {
		if (!this.logicaFiltro) {
			this.filtros.splice(this.filtros.findIndex(filtro => filtro.id === event.currentTarget.dataset.filtroId), 1);
			this.filtrosEdit.splice(this.filtrosEdit.findIndex(filtro => filtro.id === event.currentTarget.dataset.filtroId), 1);
			this.obtenerCasos();
		}
	}

	deseleccionarLogicaFiltro() {
		this.eliminarLogicaFiltro();
		this.logicaFiltro = null;
		this.obtenerCasos();
	}

	tomarPropiedad() {
		this.setCargandoCasos(true);
		tomarPropiedad({idCasos: this.template.querySelector('.datatableCasos').getSelectedRows().map(caso => caso.id)})
			.then(() => {
				this.mostrarToast('success', 'Se han reasignado los casos', 'Ahora es el propietario de los casos seleccionados');
				this.datatableRefresh();
			}).catch(error => this.mostrarError(error, 'Problema cambiando el propietario de los casos seleccionados'))
			.finally(() => this.setCargandoCasos(false));
	}

	rechazarMasivo() {
		let casosSeleccionados = this.template.querySelector('.datatableCasos').getSelectedRows().map(caso => caso.id);

		if (casosSeleccionados.length > 500) {
			this.mostrarToast('error', 'Con más de 500 registros la operativa podría fallar debido a limitaciones, por favor seleccione un lote más pequeño');
		} else {
			this.setCargandoCasos(true);
			rechazar({idCasos: casosSeleccionados})
				.then(() => {
					this.mostrarToast('success', 'Se están rechazando los casos seleccionados', 'Por favor, recargue la página en unos minutos para verificar');
				}).catch(error => this.mostrarError(error, 'No se pudieron rechazar los casos'))
				.finally(() => this.setCargandoCasos(false));
		}
	}

	cerrarCasos() {
		this.setCargandoCasos(true);
		cerrarCasos({idCasos: this.template.querySelector('.datatableCasos').getSelectedRows().map(caso => caso.id)}).
			then(() => {
				this.mostrarToast('success', 'Se han cerrado los casos', 'Los casos han sido cerrados');
				this.datatableRefresh();
			}).catch(error => this.mostrarError(error, 'Problema cerrando los casos'))
			.finally(() => this.setCargandoCasos(false));
	}

	menuFavoritoClick(event) {
		if (event.currentTarget.dataset.nombreFavorito) {
			this.cargarFavorito(event.currentTarget.dataset.nombreFavorito, true);
			this.menuFavoritosCerrar();
		}
	}

	cargarFavorito(nombreFavorito, actualizarCasos = false) {
		this.panelFiltrosCerrar();
		this.cambiarTipoBusquedaGetCasosGruposOperativos('Casos de los grupos seleccionados');
		let favoritoCargar = this.favoritos.find(favorito => favorito.nombre === nombreFavorito);
		this.gruposSeleccionados.grupos = favoritoCargar.grupos ? [...favoritoCargar.grupos] : [];
		this.gruposSeleccionados = {...this.gruposSeleccionados};
		this.zonasSeleccionadas = favoritoCargar.zonasSeleccionadas ? [...favoritoCargar.zonasSeleccionadas] : [];
		this.filtros = favoritoCargar.filtros ? [...favoritoCargar.filtros] : [];
		this.filtrosEdit = [...this.filtros];
		this.template.querySelectorAll('.divFiltro.modificado').forEach(divFiltro => divFiltro.classList.remove('modificado'));
		this.logicaFiltro = favoritoCargar?.logicaFiltro ? favoritoCargar.logicaFiltro : null;

		this.actualizarMensajeNumeroZonasSeleccionadas();
		this.actualizarZonasSeleccionadas(false);
		this.calcularEstilosResultadosGrupos();
		this.resultadosBusqueda = [...this.grupos];
		if (actualizarCasos) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.obtenerCasos(), 100);
		}
		this.animarBotonFavoritoInicio();
	}

	botonFavoritoClick() {
		if (!this.favoritoSeleccionado()) {
			this.modalCrearFavoritoTitulo = 'Guardar como favorito';
			this.modalCrearFavoritoAbrir();
		}
	}

	modalCrearFavoritoAbrir() {
		this.template.querySelector('.modalCrearFavorito').classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			let inputCrearFavorito = this.template.querySelector('.inputCrearFavoritoNombre');
			inputCrearFavorito.focus();
			inputCrearFavorito.setCustomValidity('');
			inputCrearFavorito.reportValidity();
		}, 170);
	}

	modalCrearFavoritoCerrar() {
		this.template.querySelector('.modalCrearFavorito').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
		let inputCrearFavorito = this.template.querySelector('.inputCrearFavoritoNombre');
		this.template.querySelector('.inputCrearFavoritoNombre').value = '';
		inputCrearFavorito.setCustomValidity('');
		inputCrearFavorito.reportValidity();
	}

	modalCrearFavoritoTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalCrearFavoritoCerrar();
		}
	}

	inputCrearFavoritoNombreBlur() {
		let inputCrearFavorito = this.template.querySelector('.inputCrearFavoritoNombre');
		let nombreNuevoFavorito = inputCrearFavorito.value.trim();
		if (!nombreNuevoFavorito) {
			inputCrearFavorito.setCustomValidity('Indica el nombre para el nuevo favorito');
		} else if (inputCrearFavorito.value.length > 0 && this.favoritos.find(favorito => favorito.nombre === nombreNuevoFavorito)) {
			inputCrearFavorito.setCustomValidity('Ya existe un favorito con nombre "' + nombreNuevoFavorito + '".');
		} else {
			inputCrearFavorito.setCustomValidity('');
		}
		inputCrearFavorito.reportValidity();
	}

	modalCrearFavoritoGuardar() {
		if (this.template.querySelector('.inputCrearFavoritoNombre').validity.valid) {
			let nombreNuevoFavorito = this.template.querySelector('.inputCrearFavoritoNombre').value.trim();

			const nombreGrupos = this.gruposSeleccionados.grupos.map(grupo => grupo.Name);
			let helptext = 'Grupos: ' + nombreGrupos.join(', ') + '.';
			if (this.zonasSeleccionadas?.length) {
				helptext += ' Zonas: ' + this.zonasSeleccionadas.join(', ') + '.';
			}
			if (this.filtros?.length) {
				helptext += ' Filtros: ' + this.filtros.map(filtro => filtro.nombre).join(', ') + '.';
			}
			this.añadirFavoritos([{
				nombre: nombreNuevoFavorito,
				grupos: this.gruposSeleccionados.grupos,
				zonasSeleccionadas: this.zonasSeleccionadas,
				filtros: this.filtrosEdit,
				logicaFiltro: this.logicaFiltro,
				clasesIndicadorColor: 'indicadorColorSeleccionado indicadorColorAzul',
				clasesIndicadorColorMenu: 'indicadorColorMenu indicadorColorAzul',
				claseColor: 'indicadorColorAzul',
				helptext: helptext
			}]);
			this.filtroEditado = false;
			this.template.querySelectorAll('.listaFiltros .divFiltro').forEach(divFiltro => divFiltro.classList.remove('modificado'));
			this.cargarFavorito(nombreNuevoFavorito, false);
			this.modalCrearFavoritoCerrar();
			this.guardarFavoritos(this.favoritos);
		}
	}

	filtroModificado(idFiltro = this.filtroEditadoId) {
		let divFiltro = this.template.querySelector('.listaFiltros .divFiltro[data-id="' + idFiltro + '"]');
		if (divFiltro) {
			divFiltro.classList.add('modificado');
		}
	}

	modalEditarFavoritosAbrir() {
		this.mostrarMenuFavoritos = false;
		this.template.querySelector('.modalEditarFavoritos').classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelector('.modalEditarFavoritosBotonCerrar').focus(), 200);
	}

	modalEditarFavoritosCerrar() {
		this.template.querySelector('.modalEditarFavoritos').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalEditarFavoritosTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalEditarFavoritosCerrar();
		}
	}

	modalEditarFavoritosEliminar(event) {
		this.eliminarFavorito(event.currentTarget.dataset.nombreFavorito);
	}

	datatableLoadMore() {
		if (!this.cargandoCasos) {
			if (this.filtrando) {
				let indicadorLoadMoreNoDisponible = this.template.querySelector('.indicadorLoadMoreNoDisponible');
				indicadorLoadMoreNoDisponible.classList.add('indicadorLoadMoreNoDisponibleBlink');
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => indicadorLoadMoreNoDisponible.classList.remove('indicadorLoadMoreNoDisponibleBlink'), 3000);
			} else {
				this.obtenerCasos(true);
			}
		}
	}

	verTodasLasZonas() {
		this.zonasSeleccionadas = [];
		this.actualizarMensajeNumeroZonasSeleccionadas();
		this.actualizarZonasSeleccionadas();
	}

	favoritoSeleccionado() {
		if (!this.favoritos.length || this.tipoBusquedaGetCasosGruposOperativos !== 'Casos de los grupos seleccionados') {
			return null;
		} else {
			return this.favoritos.find(favorito => favorito.grupos.length === this.gruposSeleccionados.grupos.length
				&& favorito.zonasSeleccionadas.length === this.zonasSeleccionadas.length
				&& favorito.filtros.length === this.filtros.length
				&& this.listasObjetosIguales(favorito.grupos, this.gruposSeleccionados.grupos)
				&& favorito.zonasSeleccionadas.sort().join(',') === this.zonasSeleccionadas.sort().join(',')
				&& this.listasObjetosIguales(favorito.filtros, this.filtros)
				&& (!this.logicaFiltro && !favorito.logicaFiltro || favorito.logicaFiltro === this.logicaFiltro));
		}
	}

	eliminarFavorito(nombreFavorito) {
		this.favoritos.splice(this.favoritos.indexOf(this.favoritos.find(favorito => favorito.nombre === nombreFavorito)), 1);
		this.favoritos = [...this.favoritos];
		if (this.favoritos.length) {
			this.template.querySelector('.botonMenuFavoritos').classList.remove('botonMenuFavoritosDisabled');
		} else {
			this.template.querySelector('.botonMenuFavoritos').classList.add('botonMenuFavoritosDisabled');
		}
		this.gruposSeleccionados = {...this.gruposSeleccionados};
		this.guardarFavoritos(this.favoritos);
	}

	favoritoCambiarNombreClick(event) {
		this.template.querySelectorAll('.popoverCambiarNombre, .popoverColores').forEach(popover => {
			popover.style.display = 'none';
		});
		let idPopover = event.currentTarget.dataset.idPopover;
		let popoverInput = this.template.querySelector('[data-popover-input="' + idPopover + '"]');
		popoverInput.value = idPopover;

		this.idPopover = idPopover;
		this.funcionesBind.favoritoCambiarNombreCerrar = this.favoritoCambiarNombreCerrar.bind(this);
		window.addEventListener('click', this.funcionesBind.favoritoCambiarNombreCerrar);
		event.stopPropagation();

		this.template.querySelector('.popoverCambiarNombre[data-popover="' + idPopover + '"]').style.display = 'block';
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => popoverInput.focus(), 70);
	}

	favoritoCambiarNombreCerrar() {
		this.template.querySelectorAll('.popoverCambiarNombre').forEach(popoverCambiarNombre => {
			popoverCambiarNombre.style.display = 'none';
		});
		window.removeEventListener('click', this.funcionesBind.favoritoCambiarNombreCerrar);
	}

	favoritoCambiarNombreGuardar(event) {
		let idPopover = event.currentTarget.dataset.idPopover;
		let popoverInput = this.template.querySelector('[data-popover-input="' + idPopover + '"]');
		let nuevoNombreFavorito = popoverInput.value.trim();
		if (nuevoNombreFavorito.length > 0 && !this.favoritos.some(favorito => favorito.nombre.toLowerCase() === nuevoNombreFavorito.toLowerCase())) {
			this.favoritoCambiarNombre(idPopover, nuevoNombreFavorito);
			this.template.querySelector('.popoverCambiarNombre[data-popover="' + idPopover + '"]').style.display = 'none';
		}
	}

	favoritoCambiarNombreInputKeyDown(event) {
		if (event.keyCode === 13) { //Intro
			let idPopover = event.currentTarget.dataset.popoverInput;
			let nuevoNombreFavorito = event.currentTarget.value.trim();
			if (nuevoNombreFavorito.length > 0 && !this.favoritos.some(favorito => favorito.nombre.toLowerCase() === nuevoNombreFavorito.toLowerCase())) {
				this.favoritoCambiarNombre(idPopover, nuevoNombreFavorito);
			}
		} else if (event.keyCode === 27) { //ESC
			this.favoritoCambiarNombreCerrar();
			event.stopPropagation();
		}
	}

	inputCrearFavoritoNombreKeyDown(event) {
		if (event.keyCode === 13) { //Intro
			this.modalCrearFavoritoGuardar();
		}
		event.stopPropagation();
	}

	favoritoCambiarNombre(nombreAnterior, nombreNuevo) {
		this.favoritos.find(favorito => favorito.nombre === nombreAnterior).nombre = nombreNuevo;
		this.favoritos = [...this.favoritos];
		this.guardarFavoritos(this.favoritos);
	}

	favoritoDragStart(event) {
		this.template.querySelectorAll('.popoverCambiarNombre, .popoverColores').forEach(popover => {
			popover.style.display = 'none';
		});
		event.currentTarget.classList.add('favoritoDrag');
		event.dataTransfer.setData('text/plain', event.currentTarget.dataset.nombreFavorito);
	}

	popoverCambiarNombreDragStart(event) {
		event.preventDefault();
		event.stopPropagation();
	}

	favoritoDragEnd() {
		this.template.querySelectorAll('.favorito').forEach(favorito => favorito.classList.remove('favoritoDrag', 'favoritoDragOver'));
	}

	favoritoDragOver(event) {
		event.preventDefault();
		event.currentTarget.classList.add('favoritoDragOver');
	}

	favoritoDragLeave(event) {
		event.currentTarget.classList.remove('favoritoDragOver');
	}

	favoritoDrop(event) {
		event.stopPropagation();
		this.template.querySelectorAll('.favorito').forEach(favorito => favorito.classList.remove('favoritoDrag', 'favoritoDragOver'));
		let favoritoOrigenIndex = this.favoritos.indexOf(this.favoritos.find(favorito => favorito.nombre === event.dataTransfer.getData('text/plain')));
		let favoritoDestinoIndex = this.favoritos.indexOf(this.favoritos.find(favorito => favorito.nombre === event.currentTarget.dataset.nombreFavorito));
		if (favoritoOrigenIndex !== favoritoDestinoIndex) {
			this.favoritos[favoritoOrigenIndex] = this.favoritos.splice(favoritoDestinoIndex, 1, this.favoritos[favoritoOrigenIndex])[0];
			this.favoritos = [...this.favoritos];
			this.guardarFavoritos(this.favoritos);
		}
	}

	favoritoCambiarColorClick(event) {
		//Cerrar popovers abiertos
		this.template.querySelectorAll('.popoverCambiarNombre, .popoverColores').forEach(popover => {
			popover.style.display = 'none';
		});
		//Registrar listener para cerrar al hacer click fuera del popover
		this.idPopover = event.currentTarget.dataset.idPopover;
		this.funcionesBind.favoritoCambiarColorCerrar = this.favoritoCambiarColorCerrar.bind(this);
		window.addEventListener('click', this.funcionesBind.favoritoCambiarColorCerrar);
		event.stopPropagation();
		//Abrir popover
		this.template.querySelector('.popoverColores[data-popover="' + this.idPopover + '"]').style.display = 'block';
	}

	favoritoCambiarColorCerrar(event) {
		this.template.querySelectorAll('.popoverColores').forEach(popover => {
			popover.style.display = 'none';
		});
		event.stopPropagation();
		window.removeEventListener('click', this.funcionesBind.favoritoCambiarColorCerrar);
	}

	favoritoCambiarColor(event) {
		let nombreFavorito = event.currentTarget.dataset.nombreFavorito;
		let claseColor = event.currentTarget.dataset.clase;
		this.favoritos.find(favorito => favorito.nombre === nombreFavorito).clasesIndicadorColor = 'indicadorColorSeleccionado ' + claseColor;
		this.favoritos.find(favorito => favorito.nombre === nombreFavorito).clasesIndicadorColorMenu = 'indicadorColorMenu ' + claseColor;
		this.favoritos.find(favorito => favorito.nombre === nombreFavorito).claseColor = claseColor;
		this.favoritos = [...this.favoritos];
		this.template.querySelector('.popoverColores[data-popover="' + nombreFavorito + '"]').style.display = 'none';
		event.stopPropagation();
		this.guardarFavoritos(this.favoritos);
	}

	guardarFavoritos(favoritos) {
		localStorage.setItem('SEG_Casos_Por_Grupo_Favoritos_' + currentUserId, JSON.stringify({version: VERSION_FORMATO_FAVORITOS, favoritos: favoritos}));
	}

	eventStopPropagation(event) {
		event.stopPropagation();
	}

	async menuFavoritosAbrir(event) {
		if (this.favoritos.length) {
			event.stopPropagation();
			await this.panelFiltrosCerrar();
			this.mostrarMenuFavoritos = true;
			this.funcionesBind.menuFavoritosCerrar = this.menuFavoritosCerrar.bind(this);
			window.addEventListener('click', this.funcionesBind.menuFavoritosCerrar);
		}
	}

	menuFavoritosCerrar() {
		this.mostrarMenuFavoritos = false;
		window.removeEventListener('click', this.funcionesBind.menuFavoritosCerrar);
	}

	panelFiltrosAbrirCerrar() {
		let panelFiltros = this.template.querySelector('.panelFiltros');
		if (panelFiltros?.classList.contains('slds-is-open')) { //Cerrar panel
			this.panelFiltrosCerrar();
		} else { //Abrir panel
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => {
				panelFiltros.classList.add('slds-is-open');
				panelFiltros.querySelectorAll('.listaFiltros .divFiltro').forEach(divFiltro => divFiltro.classList.add('visible'));
				if (this.logicaFiltro) {
					this.template.querySelector('.textareaLogicaFiltros').value = this.logicaFiltro;
					this.agregarLogicaFiltro();
				}
				this.template.querySelector('.botonFiltros').variant = 'brand';
			}, 100);
		}
	}

	async panelFiltrosCerrar() {
		let panelFiltros = this.template.querySelector('.panelFiltros');
		if (panelFiltros?.classList.contains('slds-is-open')) {
			this.template.querySelector('.botonFiltros').variant = 'border-filled';
			this.funcionesBind.panelFiltrosTransitionend = (panelFiltrosTransitionEnd => {
				panelFiltrosTransitionEnd.removeEventListener('transitionend', this.funcionesBind.panelFiltrosTransitionend);
			}).bind(this, panelFiltros);
			panelFiltros.addEventListener('transitionend', this.funcionesBind.panelFiltrosTransitionend);
			panelFiltros.classList.remove('slds-is-open');
			this.eliminarFiltros(this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre === 'Nuevo filtro*').map(filtroEdit => filtroEdit.id));
		}
	}

	aplicarFiltros() {
		const textareaLogicaFiltros = this.template.querySelector('.textareaLogicaFiltros');
		if (!textareaLogicaFiltros || textareaLogicaFiltros.validity.valid) {
			this.filtrosEdit = this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre !== 'Nuevo filtro*');
			this.template.querySelectorAll('.divFiltro.modificado').forEach(divFiltro => divFiltro.classList.remove('modificado'));
			this.filtroEditado = false;
			if (!this.listasObjetosIguales(this.filtrosEdit, this.filtros) || this.logicaFiltro !== textareaLogicaFiltros?.value) {
				this.filtros = [...this.filtrosEdit];
				this.logicaFiltro = textareaLogicaFiltros?.value;
				let divLogicaActual = this.template.querySelector('.divLogicaActual');
				if (divLogicaActual) {
					this.template.querySelector('.divLogicaActual').classList.remove('visible');
				}
				this.obtenerCasos();
			}
		}
	}

	listasObjetosIguales(lista1, lista2) {
		return lista1.length === lista2.length
			&& lista1.every(item1 => lista2.some(item2 => Object.keys(item1).every(key => item1[key] === item2[key])));
	}

	guardarFiltrosEnFavorito() {
		this.eliminarFiltros(this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre === 'Nuevo filtro*').map(filtroEdit => filtroEdit.id));
		let favoritoSeleccionado = this.favoritoSeleccionado();
		if (!favoritoSeleccionado) {
			this.modalCrearFavoritoAbrir();
		} else {
			this.aplicarFiltros();
			favoritoSeleccionado.filtros = [...this.filtros];
			if (this.logicaFiltrosActiva) {
				favoritoSeleccionado.logicaFiltro = this.template.querySelector('.textareaLogicaFiltros').value;
			}
			this.favoritos = [...this.favoritos];
			this.guardarFavoritos(this.favoritos);
		}
	}

	descartarFiltros() {
		this.filtroEditado = false;
		this.filtrosEdit = [...this.filtros];
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelectorAll('.divFiltro').forEach(divFiltro => {
			divFiltro.classList.remove('modificado');
			divFiltro.classList.add('visible');
		}), 0);

		let textareaLogicaFiltros = this.template.querySelector('.textareaLogicaFiltros');
		if (textareaLogicaFiltros) {
			textareaLogicaFiltros.value = this.logicaFiltro;
			textareaLogicaFiltros.classList.remove('modificado');
		}
	}

	modalCambiarPropietarioGuardar() {
		//let inputNuevoPropietario = this.template.querySelector('.inputNuevoPropietario');
		if (this.resultadoSeleccionado == null) {
			//inputNuevoPropietario.focus();
			//this.template.querySelector('.botonPropietarioGuardar').focus();
		} else {
			this.guardando = true;
			cambioPropietario({
				idCasos: this.template.querySelector('.datatableCasos').getSelectedRows().map(caso => caso.id),
				userId: this.resultadoSeleccionado
			}).then(() => {
				this.mostrarToast('success', 'Se reasignaron los casos al nuevo propietario', 'Se han reasignado correctamente los casos al nuevo propietario');
				this.modalCambiarPropietarioCerrar();
				this.datatableRefresh();
			}).catch(error => this.mostrarError(error, 'Problema reasignando los casos al nuevo propietario'))
				.finally(() => this.guardando = false);
		}
	}

	modalCambiarGrupoGuardar() {
		let inputNuevoGrupo = this.template.querySelector('.inputNuevoGrupo');
		if (!inputNuevoGrupo.value) {
			inputNuevoGrupo.focus();
			this.template.querySelector('.botonGrupoGuardar').focus();
		} else {
			this.guardando = true;
			cambioGrupo({
				idCasos: this.template.querySelector('.datatableCasos').getSelectedRows().map(caso => caso.id),
				grupoId: inputNuevoGrupo.value
			}).then(result => {
				if (result != null && result.nombreMsg != null && result.datosMsg != null) {
					this.mostrarToast('error', result.nombreMsg, result.datosMsg);
				} else {
					this.mostrarToast('success', 'Se reasignaron los casos al nuevo Grupo', 'Se han reasignado correctamente los casos al nuevo grupo');
				}
				this.modalCambiarGrupoCerrar();
				this.datatableRefresh();
			}).catch(error => this.mostrarError(error, 'Problema reasignando los casos al nuevo grupo'))
				.finally(() => this.guardando = false);
		}
	}

	datatableRowSelection(event) {
		this.casillasSelected = event.detail.selectedRows.length > 0;
		this.primerRecordIdSeleccionado = !event.detail.selectedRows.length ? null : event.detail.selectedRows[0].id;
	}

	botonCambiarPropietarioOnClick() {
		if (this.renderizarModales) {
			this.modalCambiarPropietarioAbrir();
		} else {
			this.renderizarModales = true;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.modalCambiarPropietarioAbrir(), 200);
		}
	}

	botonCrearNuevoCaso() {
		if (this.renderizarModales) {
			this.modalCrearNuevoCasoAbrir();
		} else {
			this.renderizarModales = true;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.modalCrearNuevoCasoAbrir(), 200);
		}
	}

	botonCambiarGrupoOnClick() {
		if (this.renderizarModales) {
			this.modalCambiarGrupoAbrir();
		} else {
			this.renderizarModales = true;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.modalCambiarGrupoAbrir(), 200);
		}
	}

	añadirFiltro(event) {
		event.stopPropagation();
		const nuevoFiltro = {id: (Math.floor(Math.random() * 9999) + 1).toString(), nombre: 'Nuevo filtro*', operadorApi: '='};
		this.filtrosEdit.push(nuevoFiltro);
		this.filtroEditado = true;
		this.filtroEditadoId = nuevoFiltro.id;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.filtroModificado(nuevoFiltro.id);
			this.template.querySelector('.divFiltro[data-id="' + nuevoFiltro.id + '"]').classList.add('visible');
			this.abrirModalFiltro(nuevoFiltro.id);
		}, 0, this);
	}

	eliminarTodosLosFiltros() {
		const filtros = this.template.querySelectorAll('.listaFiltros .divFiltro');
		this.eliminarFiltros(Array.from(filtros).map(divFiltro => divFiltro.dataset.id));
		this.filtroEditado = true;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.filtrosEdit = [], 250);
	}

	agregarLogicaFiltro() {
		this.eliminarFiltros(this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre === 'Nuevo filtro*').map(filtroEdit => filtroEdit.id));
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.filtrosEdit = this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre !== 'Nuevo filtro*');
			if (this.filtrosEdit.length > 1) {
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => {
					this.template.querySelector('.botonAnadirLogica').classList.add('slds-hide');
					let textAreaLogica = this.template.querySelector('.textAreaLogica');
					textAreaLogica.classList.add('visible');
					this.template.querySelector('.listaFiltros').classList.add('listaNumerada');
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout(() => {
						this.template.querySelector('.textareaLogicaFiltros').focus();
					}, 30);
				}, 0);
				this.logicaFiltrosActiva = true;
			}
		}, 200);
	}

	eliminarLogicaFiltro() {
		let textAreaLogica = this.template.querySelector('.textAreaLogica');
		if (textAreaLogica) {
			if (textAreaLogica.classList.contains('visible')) {
				textAreaLogica.classList.remove('visible');
				let textareaLogicaFiltros = textAreaLogica.querySelector('.textareaLogicaFiltros');
				textareaLogicaFiltros.value = null;
				textareaLogicaFiltros.setCustomValidity('');
				textareaLogicaFiltros.reportValidity();
				this.template.querySelector('.listaFiltros').classList.remove('listaNumerada');
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => {
					let botonAnadirLogica = this.template.querySelector('.botonAnadirLogica');
					if (botonAnadirLogica) {
						botonAnadirLogica.classList.remove('slds-hide');
					}
				}, 90, this);
			}
			if (textAreaLogica.value !== this.logicaFiltro) {
				this.filtroEditado = true;
			}
		}
		this.logicaFiltrosActiva = false;
	}

	liFiltroOnclick(event) {
		event.stopPropagation();
		this.abrirModalFiltro(event.currentTarget.dataset.id);
	}

	abrirModalFiltro(idFiltro) {
		this.filtroEditadoId = idFiltro;
		this.funcionesBind.cerrarModalFiltro = this.cerrarModalFiltro.bind(this);
		window.addEventListener('click', this.funcionesBind.cerrarModalFiltro);

		let popoverEditarFiltro = this.template.querySelector('.popoverEditarFiltro');
		const panelFiltros = this.template.querySelector('.panelFiltros');
		const liFiltro = panelFiltros.querySelector('.liFiltro[data-id="' + idFiltro + '"]');
		let offset = liFiltro.getBoundingClientRect().top - panelFiltros.getBoundingClientRect().top;
		offset -= Math.floor(popoverEditarFiltro.offsetHeight / 2);
		offset += Math.floor(liFiltro.offsetHeight / 2);
		popoverEditarFiltro.style.top = parseInt(offset, 10) + 'px';

		let filtroEdit = this.filtrosEdit.find(f => f.id === idFiltro);
		popoverEditarFiltro.querySelector('[data-id="popoverEditarComboboxCampo"]').value = filtroEdit?.campo;
		popoverEditarFiltro.querySelector('[data-id="popoverEditarComboboxOperador"]').value = filtroEdit.operadorApi;
		popoverEditarFiltro.querySelector('[data-id="popoverEditarInputValor"]').value = filtroEdit?.valor;

		this.template.querySelector('.popoverEditarFiltroBackdrop').classList.add('slds-backdrop--open');
		popoverEditarFiltro.classList.add('popoverEditarFiltroVisible');
	}

	cerrarModalFiltro() {
		window.removeEventListener('click', this.funcionesBind.cerrarModalFiltro);
		this.template.querySelector('.popoverEditarFiltroBackdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.popoverEditarFiltro').classList.remove('popoverEditarFiltroVisible');
		this.filtroEditadoId = null;
	}

	popoverEditarFiltroCamposOnblur() {
		const filtroEdicion = this.template.querySelector('[data-id="filtroEdicion"]');
		filtroEdicion.querySelectorAll('.campoFiltro').forEach(campoFiltro => campoFiltro.setCustomValidity(''));
		let comboboxCampo = filtroEdicion.querySelector('[data-id="popoverEditarComboboxCampo"]');
		let comboboxOperador = filtroEdicion.querySelector('[data-id="popoverEditarComboboxOperador"]');
		let inputValor = filtroEdicion.querySelector('[data-id="popoverEditarInputValor"]');
		if (comboboxCampo.value === 'Account.Name' && comboboxOperador.value.startsWith('LIKE')) {
			comboboxOperador.setCustomValidity('El campo "Cuenta" no admite el operador "' + this.filtroOperadoresOtions.find(operador => operador.value === comboboxOperador.value).label + '".');
		}
		if (['<', '>', '<=', '>=', 'LIKE1', 'LIKE2', 'LIKE3'].includes(comboboxOperador.value) && !inputValor.value) {
			inputValor.setCustomValidity('El operador "' + this.filtroOperadoresOtions.find(operador => operador.value === comboboxOperador.value).label + '" no admite el valor "".');
		}
		filtroEdicion.querySelectorAll('.campoFiltro').forEach(campoFiltro => campoFiltro.reportValidity());
	}

	actualizarFiltro() {
		let valoresOk = true;
		const comboboxCampo = this.template.querySelector('[data-id="popoverEditarComboboxCampo"]');
		this.template.querySelectorAll('.campoFiltro').forEach(campoFiltro => {
			valoresOk &&= campoFiltro.validity.valid;
			campoFiltro.reportValidity();
		});
		if (valoresOk) {
			const comboboxOperador = this.template.querySelector('[data-id="popoverEditarComboboxOperador"]');
			const filtroIndex = this.filtrosEdit.findIndex(f => f.id === this.filtroEditadoId);
			this.filtrosEdit[filtroIndex] = {
				id: this.filtrosEdit[filtroIndex].id,
				nombre: this.filtroCamposOptions.find(opt => opt.value === comboboxCampo.value).label,
				campo: comboboxCampo.value,
				operador: this.filtroOperadoresOtions.find(opt => opt.value === comboboxOperador.value).label,
				operadorApi: comboboxOperador.value,
				valor: this.template.querySelector('[data-id="popoverEditarInputValor"]').value,
				title: this.filtroCamposOptions.find(opt => opt.value === comboboxCampo.value).label + ' ' + this.filtroOperadoresOtions.find(opt => opt.value === comboboxOperador.value).label + ' "' + this.template.querySelector('[data-id="popoverEditarInputValor"]').value + '"'
			};
			//this.template.querySelector('.popoverEditarFiltro').classList.remove('popoverEditarFiltroVisible');
			this.cerrarModalFiltro();
			this.filtroEditado = true;
			this.filtroModificado(this.filtroEditadoId);
		}
	}

	eliminarFiltroOnclick(event) {
		event.stopPropagation();
		this.cerrarModalFiltro();
		this.eliminarFiltros([event.currentTarget.dataset.id]);
	}

	eliminarFiltros(idFiltros) {
		const listaFiltros = this.template.querySelector('.listaFiltros');
		idFiltros.forEach(idFiltro => {
			let divFiltro = listaFiltros.querySelector('.divFiltro[data-id="' + idFiltro + '"');
			this.funcionesBind['eliminarFiltrosTransitionend_' + idFiltro] = this.eliminarFiltrosTransitionend.bind(this, idFiltro, divFiltro);
			divFiltro.addEventListener('transitionend', this.funcionesBind['eliminarFiltrosTransitionend_' + idFiltro]);
			divFiltro.classList.remove('visible');
		});
	}

	eliminarFiltrosTransitionend(idFiltro, divFiltro) {
		divFiltro.removeEventListener('transitionend', this.funcionesBind['eliminarFiltrosTransitionend_' + idFiltro]);
		this.filtrosEdit.splice(this.filtrosEdit.findIndex(f => f.id === idFiltro), 1);
		if (this.filtrosEdit.length !== this.filtros.length) {
			this.filtroEditado = true;
		} else {
			this.filtroEditado = this.filtrosEdit.some((f, i) => f.nombre !== this.filtros[i].nombre || f.operador !== this.filtros[i].operador || f.valor !== this.filtros[i].valor);
		}
	}

	//Funcionalidad futura.
	modalCrearNuevoCasoAbrir() {
		let modalCrearNuevoCaso = this.template.querySelector('.modalCrearNuevoCaso');
		modalCrearNuevoCaso.classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoCanalEntrada"]').value = 'Oficina';
		const valorCastellano = this.modalCrearNuevoCasoIdiomaOptions.find(idioma => idioma.label === 'Castellano').value;
		modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoIdioma"]').value = valorCastellano;

		let modalCrearNuevoCasoRecordTypeId = modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoRecordTypeId"]');
		if (!modalCrearNuevoCasoRecordTypeId.value) {
			/*
			picklistsNuevoCaso({}).then(data => {
				modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoRecordTypeId"]').value = data.idRecordTypeSegCliente;
				modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoCanalEntrada"]').options = data.picklistCanalEntrada;
				modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoIdioma"]').options = data.picklistIdioma;
			});
			*/
		}
		modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoAsunto"]').focus();
	}

	modalCrearNuevoCasoCerrar() {
		let modalCrearNuevoCaso = this.template.querySelector('.modalCrearNuevoCaso');
		modalCrearNuevoCaso.classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
		modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoAsunto"]').value = null;
		modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoDescripcion"]').value = null;
		modalCrearNuevoCaso.querySelector('[data-id="modalCrearNuevoCasoCanalEntrada"]').value = null;
		this.template.querySelector('[data-id="modalCrearNuevoCasoNIF"]').value = null;
	}

	crearCaso() {
		let modalCrearNuevoCasoCanalEntrada = this.template.querySelector('[data-id="modalCrearNuevoCasoCanalEntrada"]');
		let modalCrearNuevoCasoNIF = this.template.querySelector('[data-id="modalCrearNuevoCasoNIF"]');
		if (!modalCrearNuevoCasoCanalEntrada.value || !modalCrearNuevoCasoNIF.checkValidity()) {
			modalCrearNuevoCasoCanalEntrada.reportValidity();
			modalCrearNuevoCasoNIF.reportValidity();
		} else {
			this.guardando = true;
			const fields = {};
			/*
			fields[CAMPO_SUBJECT.fieldApiName] = this.subjectValue;
			fields[CAMPO_DESCRIPTION.fieldApiName] = this.descriptionValue;
			fields[CAMPO_IDIOMA.fieldApiName] = this.languageValue;
			fields[CAMPO_CANALENTRADA.fieldApiName] = this.entryChannelValue;
			fields[CAMPO_RECORDTYPE.fieldApiName] = this.idRecordTypeCaseCliente;
			fields[CAMPO_OWNER.fieldApiName] = currentUserId;
			*/
			fields[CAMPO_SUBJECT.fieldApiName] = this.template.querySelector('[data-id="modalCrearNuevoCasoAsunto"]').value;
			fields[CAMPO_DESCRIPTION.fieldApiName] = this.template.querySelector('[data-id="modalCrearNuevoCasoDescripcion"]').value;
			fields[CAMPO_IDIOMA.fieldApiName] = this.template.querySelector('[data-id="modalCrearNuevoCasoIdioma"]').value;
			fields[CAMPO_CANALENTRADA.fieldApiName] = this.template.querySelector('[data-id="modalCrearNuevoCasoCanalEntrada"]').value;
			fields[CAMPO_RECORDTYPE.fieldApiName] = this.idRecordTypeCaseCliente;
			fields[CAMPO_OWNER.fieldApiName] = currentUserId;
			if (this.modalCrearNuevoCasoCuenta) {
				fields[CAMPO_ACCOUNT.fieldApiName] = this.modalCrearNuevoCasoCuenta.cuenta.Id;
				fields[CAMPO_ORG.fieldApiName] = this.modalCrearNuevoCasoCuenta.org;
				fields[CAMPO_ZONA.fieldApiName] = this.modalCrearNuevoCasoCuenta.zona;
			}
			createRecord({apiName: OBJETO_CASE.objectApiName, fields: fields})
				.then(record => {
					this.mostrarToast('success', 'Se creó Caso', 'Se creo correctamente el caso ' + record.fields.CaseNumber.value);
					this.datatableRefresh();
					this.modalCrearNuevoCasoCerrar();
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: record.id,
							objectApiName: 'Case',
							actionName: 'view'
						}
					});
				}).catch(error => {
					console.error(error);
					this.mostrarToast('error', 'Problema creando caso', error.body.message);
				}).finally(() => this.guardando = false);
		}
	}


	popoverEditarFiltroInputValorOnkeypress(event) {
		if (event.keyCode === 13) {
			this.actualizarFiltro();
		}
	}

	actualizarMensajeNumeroZonasSeleccionadas() {
		if (!this.zonasSeleccionadas.length) {
			this.mensajeNumeroZonasSeleccionadas = 'Todas las zonas';
		} else if (this.zonasSeleccionadas.length === 1) {
			this.mensajeNumeroZonasSeleccionadas = '1 zona seleccionada';
		} else {
			this.mensajeNumeroZonasSeleccionadas = this.zonasSeleccionadas.length + ' zonas seleccionadas';
		}
	}

	textareaLogicaFiltrosOnfocus() {
		this.eliminarFiltros(this.filtrosEdit.filter(filtroEdit => filtroEdit.nombre === 'Nuevo filtro*').map(filtroEdit => filtroEdit.id));
		if (this.filtrosEdit.length < 2) {
			this.eliminarLogicaFiltro();
		}
	}

	textareaLogicaFiltrosOnblur(event) {
		let logicaFiltro = null;
		let textareaLogicaFiltro = event.currentTarget;
		if (textareaLogicaFiltro.value) {
			logicaFiltro = textareaLogicaFiltro.value.replace(/\s+/g, ' ');
			logicaFiltro = logicaFiltro.replace(/\(/g, ' $&').replace(/\)/g, '$& ');
			logicaFiltro = logicaFiltro.replace(/,|AND|OR/g, ' $& ');
			logicaFiltro = logicaFiltro.replace(/\s+\(\s+/g, ' (').replace(/\s+\)\s+/g, ') ');
			logicaFiltro = logicaFiltro.replace(/\s+/g, ' ').trim().toUpperCase();
			textareaLogicaFiltro.value = logicaFiltro;
		}
		textareaLogicaFiltro.setCustomValidity(this.logicaFiltroValidacion(textareaLogicaFiltro.value));
		textareaLogicaFiltro.reportValidity();
		if (logicaFiltro === this.logicaFiltro) {
			textareaLogicaFiltro.classList.remove('modificado');
		} else {
			textareaLogicaFiltro.classList.add('modificado');
			this.filtroEditado = true;
		}
	}

	textareaLogicaFiltrosOnchange(event) {
		if (event.detail.value !== this.logicaFiltro) {
			this.template.querySelector('.divLogicaActual').classList.add('visible');
		} else {
			this.template.querySelector('.divLogicaActual').classList.remove('visible');
		}
		if (!event.detail.value) {
			event.detail.value = null;
		}
	}

	logicaFiltroValidacion(logicaFiltro) {
		if (!logicaFiltro) {
			return '';
		}
		if (logicaFiltro.match(/\(/g)?.length !== logicaFiltro.match(/\)/g)?.length) {
			return 'La lógica indicada contiene errores.';
		}
		let referenciasLogicaFiltro = logicaFiltro.split(/,| |\(|\)|AND|OR/);
		if (referenciasLogicaFiltro.some(referencia => isNaN(referencia))) {
			return 'La lógica indicada contiene errores.';
		}
		referenciasLogicaFiltro = referenciasLogicaFiltro.filter(s => s && !isNaN(s) && ![' ', '.'].includes(s)).map(referencia => parseInt(referencia, 10));
		if (this.filtrosEdit.some((_filtro, index) => !referenciasLogicaFiltro.includes(index + 1))) {
			return 'Debes hacer referencia a todos los filtros.';
		}
		if (!referenciasLogicaFiltro.every(referencia => referencia > 0 && referencia <= this.filtrosEdit.length)) {
			return 'Hay referencias a filtros inexistentes.';
		}
		return '';
	}

	pillLogicaFiltroOnmouseenter(event) {
		let logicaFiltroPopover = event.currentTarget.querySelector('.popoverPillLogicaFiltro');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		this.idTimeouts.logicaFiltroPopoverAbrir = window.setTimeout(this.logicaFiltroPopoverAbrir.bind(this, logicaFiltroPopover), 300);
	}

	logicaFiltroPopoverAbrir(popover) {
		popover.classList.add('visible');
	}

	pillLogicaFiltroOnmouseleave(event) {
		window.clearTimeout(this.idTimeouts.logicaFiltroPopoverAbrir);
		event.currentTarget.querySelector('.popoverPillLogicaFiltro').classList.remove('visible');
	}

	añadirFavoritos(nuevosFavoritos, añadir = true) {
		this.favoritos = añadir ? [...this.favoritos, ...nuevosFavoritos] : nuevosFavoritos;
		let botonMenuFavoritos = this.template.querySelector('.botonMenuFavoritos');
		if (this.favoritos.length) {
			botonMenuFavoritos.classList.remove('botonMenuFavoritosDisabled');
		} else {
			botonMenuFavoritos.classList.add('botonMenuFavoritosDisabled');
		}
	}

	setCargandoCasos(mostrar) {
		window.clearTimeout(this.idTimeouts.cargandoCasosTrue);
		if (mostrar) {
			this.template.querySelector('.botonActualizar').classList.add('disabled');
			this.cargandoCasos = true;
			this.mostarSpinner = true;
		} else {
			this.cargandoCasos = false;
			this.mostarSpinner = false;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.template.querySelector('.botonActualizar').classList.remove('disabled'), 600, this);
		}
	}

	mostrarError(error, tituloToast) {
		console.error(error);
		this.mostrarToast('error', tituloToast, error.body ? error.body.message : error.message);
	}

	animarBotonFavoritoInicio(event) {
		if (event) { //onmouseenter
			if (!Array.from(event.currentTarget.classList).some(clase => clase.startsWith('indicadorColor'))) {
				//solo se inicia la animación si no hay favorito seleccionado
				let botonFavoritoIcon = this.template.querySelector('.botonFavoritoIcon');
				this.funcionesBind.animarBotonFavoritoFin = this.animarBotonFavoritoFin.bind(this, botonFavoritoIcon, 'animarBotonFavoritoIcon2');
				botonFavoritoIcon.addEventListener('animationend', this.funcionesBind.animarBotonFavoritoFin);
				botonFavoritoIcon.classList.add('animarBotonFavoritoIcon2');
			}
		} else {
			let botonFavoritoIcon = this.template.querySelector('.botonFavoritoIcon');
			this.funcionesBind.animarBotonFavoritoFin = this.animarBotonFavoritoFin.bind(this, botonFavoritoIcon, 'animarBotonFavoritoIcon');
			botonFavoritoIcon.addEventListener('animationend', this.funcionesBind.animarBotonFavoritoFin);
			botonFavoritoIcon.classList.add('animarBotonFavoritoIcon');
		}
	}

	animarBotonFavoritoFin(botonFavoritoIcon, claseAnimacion) {
		botonFavoritoIcon.removeEventListener('animationend', this.funcionesBind.animarBotonFavoritoFin);
		botonFavoritoIcon.classList.remove(claseAnimacion);
	}

	animarBotoActualizarInicio() {
		let iconoBotonActualizar = this.template.querySelector('.botonActualizar lightning-icon');
		this.funcionesBind.animarBotonActualizarFin = this.animarBotoActualizarFin.bind(this, iconoBotonActualizar);
		iconoBotonActualizar.addEventListener('animationend', this.funcionesBind.animarBotonActualizarFin);
		iconoBotonActualizar.classList.add('animarBotonActualizar');
	}

	animarBotoActualizarFin(iconoBotonActualizar) {
		iconoBotonActualizar.removeEventListener('animationend', this.funcionesBind.animarBotonActualizarFin);
		iconoBotonActualizar.classList.remove('animarBotonActualizar');
	}

	async favoritosEliminarTodos() {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'warning', label: 'Eliminar todos los favoritos',
			message: 'Se eliminarán todos los favoritos guardados en este equipo. ¿Seguro que quieres continuar?'
		})) {
			//Borrado de favoritos
			this.añadirFavoritos([], false);
			this.guardarFavoritos(this.favoritos);
			this.mostrarToast('success', 'Favoritos eliminados', 'Se eliminaron correctamente los favoritos guardados en este equipo');
		}
	}

	modalImportarExportarFavoritosAbrir(importar = false) {
		const modal = this.template.querySelector('.modalImportarExportarFavoritos');
		let modalImportarExportarFavoritosTextarea = modal.querySelector('.modalImportarExportarFavoritosTextarea');
		modalImportarExportarFavoritosTextarea.disabled = !importar;
		modalImportarExportarFavoritosTextarea.required = false;
		let claseBotonFocus = '.modalImportarExportarFavoritosTextarea';
		if (importar) {
			modal.querySelector('.modalImportarExportarFavoritosTitulo').value = 'Importar favoritos';
			modal.querySelector('.modalImportarExportarFavoritosWarning').classList.remove('slds-hide');
			modal.querySelector('.modalImportarExportarFavoritosImportar').classList.remove('slds-hide');
			modal.querySelector('.modalImportarExportarFavoritosCopiar').classList.add('slds-hide');
			modalImportarExportarFavoritosTextarea.value = null;
			modalImportarExportarFavoritosTextarea.reportValidity();
			modalImportarExportarFavoritosTextarea.required = true;
		} else {
			modal.querySelector('.modalImportarExportarFavoritosTitulo').value = 'Exportar favoritos';
			modal.querySelector('.modalImportarExportarFavoritosWarning').classList.add('slds-hide');
			modal.querySelector('.modalImportarExportarFavoritosImportar').classList.add('slds-hide');
			modal.querySelector('.modalImportarExportarFavoritosCopiar').classList.remove('slds-hide');
			modalImportarExportarFavoritosTextarea.value = JSON.stringify({version: VERSION_FORMATO_FAVORITOS, favoritos: this.favoritos}, null, '\t');
			modalImportarExportarFavoritosTextarea.reportValidity();
			claseBotonFocus = '.modalImportarExportarFavoritosCopiar';
		}
		modal.classList.add('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.add('slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelector(claseBotonFocus).focus(), 50);
	}

	modalImportarExportarFavoritosTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.modalImportarExportarFavoritosCerrar();
		}
	}

	copiarFavoritosAlPortapapeles(event) {
		//Copiar al porapapeles
		let hiddenElement = document.createElement('input');
		hiddenElement.setAttribute('value', this.template.querySelector('.modalImportarExportarFavoritosTextarea').value);
		document.body.appendChild(hiddenElement);
		hiddenElement.select();
		document.execCommand('copy');
		document.body.removeChild(hiddenElement);

		//Feedback visual
		let boton = event.target;
		event.target.label = 'Copiado al portapapeles';
		event.target.iconName = 'utility:check';
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			boton.label = 'Copiar al portapapeles';
			boton.iconName = 'utility:copy';
		}, 1600);
	}

	async modalImportarExportarFavoritosImportar() {
		const modalImportarExportarFavoritosTextarea = this.template.querySelector('.modalImportarExportarFavoritosTextarea');
		if (modalImportarExportarFavoritosTextarea.validity.valid) {
			this.cargarFavoritos(modalImportarExportarFavoritosTextarea.value.trim())
				.then(() => {
					this.mostrarToast('success', 'Se importaron los favoritos', 'Se importaron correctamente ' + this.favoritos.length + ' favoritos');
					this.modalImportarExportarFavoritosCerrar();
				}).catch(error => this.mostrarError(error, 'Problema importando los favoritos'));
		} else {
			modalImportarExportarFavoritosTextarea.reportValidity();
		}
	}

	modalImportarExportarFavoritosCerrar() {
		this.template.querySelector('.modalImportarExportarFavoritos').classList.remove('slds-fade-in-open');
		this.template.querySelector('.modalBackdrop').classList.remove('slds-backdrop--open');
	}

	modalCrearNuevoCasoNifOnchange(event) {
		event.currentTarget.value = event.detail.value.toUpperCase();
	}

	modalCrearNuevoCasoNifOnblur(event) {
		const inputNif = event.currentTarget;
		if (inputNif.value) {
			const botonCrearNuevoCasoGuardar = this.template.querySelector('.botonCrearNuevoCasoGuardar');
			botonCrearNuevoCasoGuardar.disabled = true;
			validarNifApex({nif: inputNif.value})
			.then(resultado => {
				if (resultado.validación !== 'OK') {
					this.modalCrearNuevoCasoCuenta = null;
					inputNif.setCustomValidity(resultado.validación);
				} else {
					this.modalCrearNuevoCasoCuenta = {cuenta: resultado.cuenta, org: resultado.org, zona: resultado.zona};
					inputNif.setCustomValidity('');
				}
				inputNif.reportValidity();
			}).catch(error => this.mostrarError(error, 'Problema consultando el NIF indicado'))
			.finally(() => botonCrearNuevoCasoGuardar.disabled = false);
		}
	}

	menuTipoBusquedaAbrir() {
		this.template.querySelector('.menuOpcionesTipoBusqueda').classList.remove('slds-hide');
	}

	menuTipoBusquedaCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelector('.menuOpcionesTipoBusqueda').classList.add('slds-hide'), 200);
	}

	menuTipoBusquedaSeleccion(event) {
		this.resultados = [];
		this.tipoBusquedaSeleccionado = this.tiposBusqueda.find(
			tipoBusqueda => tipoBusqueda.label === event.currentTarget.dataset.tipoBusqueda
		);
		this.tipoBusquedaSeleccionado = {...this.tipoBusquedaSeleccionado};
		let inputBusqueda = this.template.querySelector('.inputBusqueda');
		inputBusqueda.value = '';
		inputBusqueda.focus();

		this.busquedaApex(this.tipoBusquedaSeleccionado.label, '');
	}

	inputBusquedaChange(event) {
		window.clearTimeout(this.idTimeoutBusqueda);
		let cadenaBusqueda = event.currentTarget.value.trim();
		if (!cadenaBusqueda) {
			let inputBusqueda = this.template.querySelector('.inputBusqueda');
			inputBusqueda.blur();
		}
		if (cadenaBusqueda.length > 3) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.idTimeoutBusqueda = window.setTimeout(this.busquedaApex.bind(this, this.tipoBusquedaSeleccionado.label, cadenaBusqueda), 200);
		} else {
			this.resultados = [];
		}
	}

	busquedaApex(tipoObjeto, cadenaBusqueda) {
		this.template.querySelector('.inputBusqueda').isLoading = true;
		if (cadenaBusqueda) {
			getUsuariosSEG({cadenaBusqueda: cadenaBusqueda})
				.then(registros => {
					if (this.template.querySelector('.inputBusqueda').value.trim() === cadenaBusqueda) {
						this.resultados = registros;
					}
				}).catch(error => console.error('Problema obteniendo registros: ' + JSON.stringify(error)))
				.finally(() => this.template.querySelector('.inputBusqueda').isLoading = false);
		}
	}

	menuResultadosAbrir() {
		this.template.querySelector('.menuResultados').classList.add('slds-is-open');
		this.busquedaApex(this.tipoBusquedaSeleccionado.label, '');
	}

	menuResultadosCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelector('.menuResultados').classList.remove('slds-is-open'), 200);
	}

	resultadoClick(event) {
		this.resultadoSeleccionado = event.currentTarget.dataset.idResultado;
		let infoSeleccionado = this.resultados.find(resultado => resultado.Id === this.resultadoSeleccionado);
		this.selectedItem = infoSeleccionado.Name;
	}

	cambiarLabelTab() {
		getAllTabInfo()
			.then(tabInfos => {
				const tabId = tabInfos.find(tabInfo => tabInfo.pageReference.attributes.apiName === 'SEG_Casos_Segmentos')?.tabId;
				if (tabId) {
					setTabIcon(tabId, 'custom:custom55');
					setTabLabel(tabId, 'Casos Segmentos');
				}
			});
	}
}