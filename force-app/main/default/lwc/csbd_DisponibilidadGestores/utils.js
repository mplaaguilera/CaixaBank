export function formatNombreCalendario(nombre) {
	return nombre.toLowerCase().split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
}

export function publicarEvento(self, nombre, detail) {
	self.dispatchEvent(new CustomEvent(nombre, {detail}));
}

export function prepararEventosTramo(calendarView, tramos, i, eventosTramo, mostrarDetallesEventos) {
	const retorno = eventosTramo.map(e => {
		const inicioEvento = new Date(e.StartDateTime);
		const finEvento = new Date(e.EndDateTime);

		let esTramoInicial;
		if (i === 0) {
			esTramoInicial = true;
		} else {
			const inicioTramoAnterior = tramos[i - 1].fecha;
			const finTramoAnterior = new Date(inicioTramoAnterior.getTime() + 30 * 60 * 1000);
			const transcurreEnTramoAnterior = inicioEvento < finTramoAnterior && finEvento > inicioTramoAnterior;
			esTramoInicial = !transcurreEnTramoAnterior;
		}

		let esTramoFinal = false;
		if (i === tramos.length - 1) {
			esTramoFinal = true;
		} else {
			const inicioTramoSiguiente = tramos[i + 1].fecha;
			const finTramoSiguiente = new Date(inicioTramoSiguiente.getTime() + 60 * 60 * 1000);
			const transcurreEnTramoSiguiente = inicioEvento < finTramoSiguiente && finEvento > inicioTramoSiguiente;
			esTramoFinal = !transcurreEnTramoSiguiente;
		}

		let style = `background-color: ${ajustarColor(calendarView.color)};`;
		if (esTramoInicial) {
			style += ' border-top-left-radius: 9px; border-top-right-radius: 9px; margin-top: 1px;';
		}
		if (esTramoFinal) {
			style += ' border-bottom-left-radius: 9px; border-bottom-right-radius: 9px; margin-bottom: 1px;';
		}

		const title = `${e.Subject}  ·  ${calendarView.publisherName.toUpperCase()} (${tramos[i].label} - ${tramos[i + 1].label})`;
		return {
			...e, style,
			title: mostrarDetallesEventos ? title : null,
			esTramoInicial, esTramoIntermedio: !esTramoInicial && !esTramoFinal, esTramoFinal,
		};
	});
	return retorno;
}

export function generarFechaTramos(nuevaFecha) {
	//Normalitzar la data a mitjanit
	const fechaBase = new Date(nuevaFecha);
	fechaBase.setHours(0, 0, 0, 0);

	return Array.from({length: 48}, (_, i) => {
		const hora = Math.floor(i / 2);
		const minutos = i % 2 === 0 ? 0 : 30;
		const fecha = new Date(fechaBase.getTime() + (hora * 60 + minutos) * 60000);

		return {
			key: fecha.toISOString(),
			fecha,
			esHoraEnPunto: minutos === 0,
			horaEnPunto: hora,
			esHorarioLaboral: hora >= 9 && hora <= 18,
			label: `${String(hora).padStart(2, '0')}:${String(minutos).padStart(2, '0')}`
		};
	});
}

export function ajustarColor(hex, opacity = 0.6) {
	const hexToRgb = h => {
		h = h.replace('#', '');
		return {
			r: parseInt(h.substring(0, 2), 16),
			g: parseInt(h.substring(2, 4), 16),
			b: parseInt(h.substring(4, 6), 16)
		};
	};

	const rgbToHex = ({r, g, b}) => {
		const toHex = v => {
			const h = v.toString(16);
			return h.length === 1 ? '0' + h : h;
		};
		return '#' + toHex(r) + toHex(g) + toHex(b);
	};

	hex = hex.startsWith('#') ? hex.slice(1) : hex;
	const {r, g, b} = hexToRgb(hex);

	let rgb = [r, g, b].map(channel => {
		const adjustedChannel = Math.round(channel * opacity + 255 * (1 - opacity));
		return Math.max(adjustedChannel, 100);
	});

	return rgbToHex({r: rgb[0], g: rgb[1], b: rgb[2]});
}

export function tramoLabel(fecha) {
	if (!fecha) {
		return null;
	}

	const minutes = fecha.getMinutes();
	const hours = fecha.getHours();

	let roundedHours = hours;
	let roundedMinutes = 0;
	if (minutes >= 30) {
		roundedMinutes = 30;
	}

	return `${String(roundedHours).padStart(2, '0')}:${String(roundedMinutes).padStart(2, '0')}`;
}