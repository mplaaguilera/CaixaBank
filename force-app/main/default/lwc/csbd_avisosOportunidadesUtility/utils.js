export class Aviso {
	id;

	titulo;

	fecha;

	fechaFormat;

	enlaceFuncion;

	constructor(titulo, enlaceFuncion) {
		this.id = this.generateUID();
		this.titulo = titulo;
		this.fecha = new Date();
		this.fechaFormat = `${this.fecha.getHours().toString().padStart(2, '0')}:${this.fecha.getMinutes().toString().padStart(2, '0')}`;
		this.enlaceFuncion = enlaceFuncion;
	}

	generateUID() {
		return 'xxxx-4xxx-yxxx'.replace(/[xy]/g, c => ((c === 'x' ? Math.random() * 16 : Math.random() * 4 + 8) | 0).toString(16));
	}
}

export function mostrarToastCsbd(opciones = {}) {
	const {titulo, mensaje, lista = [], icono = 'info', backgroundColor = 'rgb(116, 116, 116)'} = opciones;

	if (titulo) {
		const toastsCsbd = document.body.querySelectorAll('div.csbdToast');
		const toasCsbdAnteriores = toastsCsbd.length > 0;
		toastsCsbd.forEach(toastCsbd => toastCsbd.remove());

		const toastContainer = nuevoElemento('div', {
			classList: ['csbdToast', 'slds-notify_container'],
			style: {top: '130px', cursor: 'default', pointerEvents: 'none'}
		});

		const toast = nuevoElemento('div', {
			classList: ['slds-notify', 'slds-notify_toast', 'slds-theme_warning'],
			style: {
				maxWidth: '76%',
				pointerEvents: 'auto',
				backgroundColor,
				border: 'solid 1px rgba(187, 187, 187, 0.35)',
				boxShadow: 'rgba(0, 0, 0, 0.1) 0px 3px 9px 3px',
				opacity: toasCsbdAnteriores ? '1' : '0',
				transformOrigin: 'center',
				transform: toasCsbdAnteriores ? 'scale(0.95)' : 'scale(0.8)',
				transition: 'all 220ms cubic-bezier(0, 0.3, 0.15, 1)'
			}
		});

		const toastContent = nuevoElemento('div', {
			classList: ['slds-notify__content']
		});

		nuevoElemento('h2', {
			parent: toastContent,
			classList: ['slds-text-heading_small', 'slds-var-p-right_x-large'],
			textContent: titulo
		});

		if (mensaje) {
			const toastMessage = nuevoElemento('p', {
				parent: toastContent,
				classList: ['slds-var-m-top_small'],
				style: {fontSize: '13.2px', lineHeight: '21px', marginBottom: '1px'},
				innerHTML: mensaje
			});

			if (lista.length) {
				const toastMessageLista = nuevoElemento('ul', {
					parent: toastMessage,
					classList: ['slds-var-m-top_xx-small', 'slds-var-m-left_medium']
				});

				lista.forEach(item => {
					const li = nuevoElemento('li', {
						parent: toastMessageLista,
						attributes: {title: 'Ver detalle'},
						style: {cursor: 'pointer', width: 'fit-content'}
					});
					//item.bullet && nuevoElemento('span', {
					//parent: li,
					//classList: ['slds-var-m-horizontal_small'],
					//style: {fontSize: '16px', fontWeight: '900'},
					//innerHTML: '·'
					//});
					item.bullet && nuevoElemento('span', {
						parent: li,
						classList: ['slds-icon_container', 'slds-var-m-right_x-small', 'slds-is-relative'],
						style: {top: '-2px'},
						innerHTML: `<svg class="slds-icon slds-icon_xx-small" aria-hidden="true" style="fill: rgb(69, 117, 145);">
							<use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#opportunity"></use></svg>`
					});
					nuevoElemento('span', {
						parent: li,
						classList: ['slds-text-link'],
						style: {'font-weight': '500'},
						innerHTML: item.label + (item.detalle ? ':' : '')
					});
					li.addEventListener('click', () => item.funcion(item.recordId));
					item.detalle && nuevoElemento('span', {
						parent: li,
						classList: ['slds-var-m-left_small', 'slds-text-color_weak'],
						innerHTML: item.detalle
					});
				});
			}
		}

		const toastIcon = nuevoElemento('span', {
			classList: ['slds-icon_container', 'slds-icon-utility-info', 'slds-var-m-right_medium'],
			innerHTML: `<svg class="slds-icon slds-icon_small" aria-hidden="true">
				<use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#${icono}"></use></svg>`
		});

		const toastContentList = nuevoElemento('div', {
			classList: ['slds-list_inline']
		});
		toastContentList.appendChild(toastIcon);
		toastContentList.appendChild(toastContent);

		const toastCloseButton = nuevoElemento('button', {
			classList: ['slds-button', 'slds-button_icon', 'slds-button_icon-inverse'],
			innerHTML: `<svg class="slds-button__icon slds-slds-icon slds-icon_xxx-small" aria-hidden="true">
				<use xlink:href="/_slds/icons/utility-sprite/svg/symbols.svg#close"></use></svg>`
		});

		const cerrarToastCsbd = toastCsbd => {
			Object.assign(toastCsbd.style, {transform: 'scale(0.8)', opacity: '0'});
			setTimeout(() => toastCsbd.closest('div.csbdToast').remove(), 220);
		};
		toastCloseButton.addEventListener('click', () => cerrarToastCsbd(toast), {once: true});
		toastCloseButton.addEventListener('keydown', e => e.key === 'Escape' && cerrarToastCsbd(toast), {once: true});

		const toastClose = nuevoElemento('div', {
			classList: ['slds-notify__close']
		});
		toastClose.appendChild(toastCloseButton);

		toast.appendChild(toastContentList);
		toast.appendChild(toastClose);

		toastContainer.appendChild(toast);
		document.body.appendChild(toastContainer);

		setTimeout(() => Object.assign(toast.style, {transform: 'scale(1)', opacity: '1'}), 50);
	}
}

function nuevoElemento(tipo, opciones = {}) {
	const {
		parent = null,
		classList = [],
		attributes = {},
		innerHTML = '',
		textContent = '',
		style = {}
	} = opciones;

	const element = document.createElement(tipo);
	classList.forEach(classe => element.classList.add(classe));
	Object.entries(attributes).forEach(([key, value]) => {
		//eslint-disable-next-line @locker/locker/distorted-element-set-attribute
		element.setAttribute(key, value);
	});
	if (innerHTML) {
		//eslint-disable-next-line @lwc/lwc/no-inner-html, @locker/locker/distorted-element-inner-html-setter
		element.innerHTML = innerHTML;
	} else if (textContent) {
		//eslint-disable-next-line @locker/locker/distorted-node-text-content-setter
		element.textContent = textContent;
	}
	Object.assign(element.style, style);
	if (parent) {
		parent.appendChild(element);
	}
	return element;
}