export const cambiarSeccion = async function(self, tipoAsignacionOrigen, tipoAsignacionDestino) {
	const modalContainer = self.refs.modalContainer;

	try {
		modalContainer.style.pointerEvents = 'none';

		const SECCIONES = {
			'A gestor específico': {
				nombre: 'A gestor específico', display: 'flex', elemento: self.refs.lookupGestor},
			'Según disponibilidad': {
				nombre: 'Según disponibilidad', display: 'block', elemento: self.refs.lwcDisponibilidadContainer},
			'Automática': {
				nombre: 'Automática', display: 'flex', elemento: self.refs.infoAsignacionAuto}
		};
		const seccionOrigen = SECCIONES[tipoAsignacionOrigen];
		const seccionDestino = SECCIONES[tipoAsignacionDestino];

		if (seccionDestino.nombre === 'Según disponibilidad') {
			//Primero se oculta la sección actual y luego se muestra el calendario
			seccionOrigen.elemento.style.opacity = '0';
			//seccionDestino.elemento.style.opacity = '0';
			await new Promise(resolve => seccionOrigen.elemento.addEventListener('transitionend', resolve, {once: true}));
			seccionOrigen.elemento.style.display = 'none';
			await mostrarOcultarCalendario(self, true);
			//self.refs.lwcDisponibilidad.scrollToHorarioLaboral();

		} else if (seccionOrigen.nombre === 'Según disponibilidad') {
			//Primero se oculta el calendario y luego se muestra la sección actual
			await mostrarOcultarCalendario(self, false);
			seccionDestino.elemento.style.display = 'flex';
			window.setTimeout(() => seccionDestino.elemento.style.opacity = '1', 0);

		} else {
			await new Promise(resolve => {
				seccionOrigen.elemento.addEventListener('transitionend', resolve, {once: true});
				seccionOrigen.elemento.style.opacity = '0';
			});
			seccionOrigen.elemento.style.display = 'none';
			seccionDestino.elemento.style.display = 'flex';
			window.setTimeout(() => seccionDestino.elemento.style.opacity = '1', 0);
		}
	} catch (error) {
		console.error(error);
	} finally {
		modalContainer.style.pointerEvents = 'auto';
	}
};

async function mostrarOcultarCalendario(self, mostrar) {
	const modalContainer = self.refs.modalContainer;
	const calendario = self.refs.lwcDisponibilidadContainer;
	calendario.style.opacity = mostrar ? '0' : '1';
	const modalContainerMaxWidth = parseFloat(window.getComputedStyle(modalContainer).maxWidth);
	const modalContainerWidthNew = Math.min(Math.max(self.componente.lwcDisponibilidadWidth + 50, 698), modalContainerMaxWidth);
	const calendarioScrollHeight = calendario.scrollHeight;
	return new Promise(resolve => {
		calendario.addEventListener('transitionend', () => resolve(), {once: true});
		//calendario.style.display = 'block';
		calendario.style.opacity = mostrar ? '1' : '0';
		modalContainer.style.width = (mostrar ? modalContainerWidthNew : 640) + 'px';
		calendario.style.maxHeight = mostrar ? calendarioScrollHeight + 'px' : 0;
		modalContainer.style.pointerEvents = 'auto';
	});
}