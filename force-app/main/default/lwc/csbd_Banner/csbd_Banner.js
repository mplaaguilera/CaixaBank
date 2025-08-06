import {LightningElement, api} from 'lwc';

export default class csbdBanner extends LightningElement {

	renderInicial = true;

	@api recordId;

	@api idBanner;

	@api iconSize = 'small';

	@api iconName = 'utility:info';

	@api texto = '';

	@api enlace;

	@api clickToDialNumTelefono;

	@api backgroundColor = '#f3f2f2';

	@api color = '#474646';

	@api descartable = false;

	@api lista = false;

	@api popover = false;

	@api listaPrimero = false;

	@api listaUltimo = false;

	get bannerClass() {
		const classList = ['banner', 'slds-card', 'slds-theme_alert-texture'];
		this.lista && classList.push('lista');
		this.listaPrimero && classList.push('listaPrimero');
		this.listaUltimo && classList.push('listaUltimo');
		this.popover && classList.push('popover');
		return classList;
	}

	get _texto() {
		return `<span style="color: rgb(47, 50, 50);">${this.texto}</span>`;
	}

	connectedCallback() {
		const hostStyle = this.template.host.style;
		hostStyle.setProperty('--csbd-banner-background-color', this.backgroundColor);
		hostStyle.setProperty('--csbd-banner-color', this.color);
	}

	renderedCallback() {
		if (this.renderInicial) {
			this.renderInicial = false;
			/*eslint-disable-next-line @locker/locker/distorted-element-inner-html-setter, @lwc/lwc/no-inner-html */
			this.refs.texto.innerHTML = this._texto;
		}
	}

	enlaceOnclick({currentTarget: {dataset: {idBanner, idEnlace}}}) {
		this.dispatchEvent(new CustomEvent('enlaceonclick', {detail: {idBanner, idEnlace}}));
	}

	cerrarBanner() {
		this.dispatchEvent(new CustomEvent('cerrarbanner', {
			detail: {idBanner: this.idBanner}
		}));
	}
}