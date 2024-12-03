public with sharing class CSBD_DatosEntrevistaHipoteca {

	public class Metadata {
		public DateTime fechaGuardado;
		public String usuario;
		public String version;
	}

	public class NominasNetas {
		public Decimal ingresos;
		public Decimal numPagosImpuestos;
		public String tipo;

		public Decimal neto {
			get {
				return this.ingresos * this.numPagosImpuestos;
			}
		}
	}

	public class IngresosNetosIrpf {
		public Decimal ingresos;
		public Decimal numPagosImpuestos;
		public String tipo;

		public Decimal neto {
			get {
				return this.ingresos - this.numPagosImpuestos;
			}
		}
	}

	public class OtrosIngresos {
		public Decimal ingresos;
		public Decimal numPagosImpuestos;
		public String tipo;
	}

	public class IngresosAlquiler {
		public Decimal ingresos;
		public Decimal numPagosImpuestos;
		public String tipo;
	}

	public class Titular {
		public IngresosAlquiler ingresosAlquiler;
		public IngresosNetosIrpf ingresosNetosIrpf;
		public NominasNetas nominasNetas;
		public OtrosIngresos otrosIngresos;

		public Decimal totalIngresosNomina {
			get {
				return (this.nominasNetas?.ingresos ?? 0) + (this.otrosIngresos?.ingresos ?? 0) + (this.ingresosAlquiler?.ingresos ?? 0);
			}
		}

		public Decimal totalIngresosNominaProrrateado {
			get {
				Decimal retorno = 0;
				retorno += (this.nominasNetas?.ingresos ?? 0) * (this.nominasNetas?.numPagosImpuestos ?? 0) / 12;
				retorno += (this.otrosIngresos?.ingresos ?? 0) * (this.otrosIngresos?.numPagosImpuestos ?? 0) / 12;
				retorno += (this.ingresosAlquiler?.ingresos ?? 0) * (this.ingresosAlquiler?.numPagosImpuestos ?? 0) / 12 / 2;
				return retorno;
			}
		}

		public Decimal totalIngresosIrpf {
			get {
				return (this.ingresosNetosIrpf?.ingresos ?? 0) + (this.otrosIngresos?.ingresos ?? 0) + (this.ingresosAlquiler?.ingresos ?? 0);
			}
		}

		public Decimal totalIngresosIrpfProrrateado {
			get {
				Decimal retorno = 0;
				retorno += ((this.ingresosNetosIrpf?.ingresos ?? 0) - (this.ingresosNetosIrpf?.numPagosImpuestos ?? 0)) / 12;
				retorno += (this.otrosIngresos?.ingresos ?? 0) * (this.otrosIngresos?.numPagosImpuestos ?? 0) / 12;
				retorno += (this.ingresosAlquiler?.ingresos ?? 0) * (this.ingresosAlquiler?.numPagosImpuestos ?? 0) / 12 / 2;
				return retorno;
			}
		}
	}

	public class Hipoteca {
		public Decimal primerTitular;
		public Decimal segundoTitular;
	}

	public class Prestamo {
		public Decimal primerTitular;
		public Decimal segundoTitular;
	}

	public class Tarjetas {
		public Decimal primerTitular;
		public Decimal segundoTitular;
	}

	public class Alquiler {
		public Decimal primerTitular;
		public Decimal segundoTitular;
	}

	public class Deuda {
		public CSBD_DatosEntrevistaHipoteca parent;
		private Boolean dosTitulares;
		public Hipoteca hipoteca;
		public Prestamo prestamo;
		public Tarjetas tarjetas;
		public Alquiler alquiler;

		public Deuda(CSBD_DatosEntrevistaHipoteca parent) {
			this.parent = parent;
			this.hipoteca = new Hipoteca();
			this.prestamo = new Prestamo();
			this.tarjetas = new Tarjetas();
			this.alquiler = new Alquiler();
		}

		public Decimal cuota {
			get {
				return this.parent.cuota;
			}
		}

		public Decimal cuotaBonificada {
			get {
				return this.parent.cuotaBonificada;
			}
		}

		public Decimal sumaDeudasPrimerTitular {
			get {
				Decimal resultado = this.hipoteca.primerTitular;
				resultado += this.prestamo.primerTitular;
				resultado += this.tarjetas.primerTitular;
				resultado += this.alquiler.primerTitular;
				return redondear(resultado);
			}
		}

		public Decimal sumaDeudasSegundoTitular {
			get {
				if (this.parent.dosTitulares) {
					Decimal resultado = this.hipoteca.segundoTitular;
					resultado += this.prestamo.segundoTitular;
					resultado += this.tarjetas.segundoTitular;
					resultado += this.alquiler.segundoTitular;
					return redondear(resultado);
				} else {
					return 0;
				}
			}
		}

		public Decimal cuotaPrimerTitular {
			get {
				if (this.parent.cuota == null) {
					return null;
				} else {
					return this.parent.dosTitulares ? this.parent.cuota / 2 : this.parent.cuota;
				}
			}
		}

		public Decimal cuotaBonificadaPrimerTitular {
			get {
				if (this.cuotaBonificada == null) {
					return null;
				} else {
					return this.parent.dosTitulares ? this.cuotaBonificada / 2 : this.cuotaBonificada;
				}
			}
		}

		public Decimal cuotaSegundoTitular {
			get {
				if (this.parent.cuota == null) {
					return null;
				} else {
					return this.parent.dosTitulares ? this.parent.cuota / 2 : null;
				}
			}
		}

		public Decimal cuotaBonificadaSegundoTitular {
			get {
				if (this.cuotaBonificada == null) {
					return null;
				} else {
					return this.parent.dosTitulares ? this.cuotaBonificada / 2 : null;
				}
			}
		}

		public Decimal totalDeudaPrimerTitular {
			get {
				return (this.sumaDeudasPrimerTitular ?? 0) + (this.cuotaPrimerTitular ?? 0);
			}
		}

		public Decimal totalDeudaPrimerTitularBonificacion {
			get {
				return (this.sumaDeudasPrimerTitular ?? 0) + (this.cuotaBonificadaPrimerTitular ?? 0);
			}
		}

		public Decimal totalDeudaSegundoTitular {
			get {
				return (this.sumaDeudasSegundoTitular ?? 0) + (this.cuotaSegundoTitular ?? 0);
			}
		}

		public Decimal totalDeudaSegundoTitularBonificacion {
			get {
				return (this.sumaDeudasSegundoTitular ?? 0) + (this.cuotaBonificadaSegundoTitular ?? 0);
			}
		}

		public Decimal totalDeuda {
			get {
				return redondear(this.totalDeudaPrimerTitular + this.totalDeudaSegundoTitular);
			}
		}

		public Decimal totalDeudaBonificacion {
			get {
				return redondear(this.totalDeudaPrimerTitularBonificacion + this.totalDeudaSegundoTitularBonificacion);
			}
		}
	}

	public Metadata metadata;
	public Decimal importeCompraventa;
	public Decimal importeHipoteca;
	public Integer plazo;
	public Decimal interes;
	public Decimal porcentajeBonificacion;
	public Decimal porcentajeGastosConstitucion;
	public Decimal ahorro;
	public Boolean dosTitulares;
	public Titular primerTitular;
	public Titular segundoTitular;
	public Deuda deuda;

	public CSBD_DatosEntrevistaHipoteca(Opportunity oportunidad) {
		if (oportunidad == null) {
			throw new CustomException('Id de oportunidad no válido');
		}

		this.dosTitulares = oportunidad.CSBD_ContactoTitular1__c != null && oportunidad.CSBD_ContactoTitular2__c != null;
		this.importeCompraventa = oportunidad.CSBD_PrecioInmueble__c ?? 0;
		this.importeHipoteca = oportunidad.Amount ?? 0;
		this.plazo = Integer.valueOf(oportunidad.CSBD_Now_Plazo__c) ?? 0;
		this.interes = oportunidad.CSBD_TIN_Inicial__c ?? 0;
		this.porcentajeBonificacion = oportunidad.CSBD_PorcentajeBonificacion__c ?? 0;

		if (String.isNotBlank(oportunidad.CSBD_Datos_Calculo_DTI__c)) {
            CSBD_DatosEntrevistaHipoteca aux = (CSBD_DatosEntrevistaHipoteca)JSON.deserializeStrict(oportunidad.CSBD_Datos_Calculo_DTI__c, CSBD_DatosEntrevistaHipoteca.class);
			this.metadata = aux.metadata;
			this.porcentajeGastosConstitucion = aux.porcentajeGastosConstitucion;
			this.ahorro = aux.ahorro;
			this.primerTitular = aux.primerTitular;
			this.segundoTitular = aux.segundoTitular;
			this.deuda = aux.deuda;
			this.deuda.parent = this;
		}
	}

	public Decimal interesBonificado {
		get {
			Decimal resultado = this.interes - this.porcentajeBonificacion;
			return resultado < 0 ? 0 : resultado;
		}
	}

	public Decimal tasa {
		get {
			return (1 + (this.interes / 100) / 12) - 1;
		}
	}

	public Decimal tasaBonificada {
		get {
			return (1 + (this.interesBonificado / 100) / 12) - 1;
		}
	}

	public Decimal cuota {
		get {
			if (this.plazo == 0) {
				return null;
			} else {
				if (this.tasa == 0) {
					return this.importeHipoteca / (this.plazo * 12) / 12;
				} else {
					Decimal factorPresenteValorFuturo = Decimal.valueOf(Math.pow(Double.valueOf(1 + this.tasa), this.plazo));
					return -this.tasa * (-this.importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
				}
			}
		}
	}

	public Decimal cuotaBonificada {
		get {
			if (this.plazo == 0) {
				return null;
			} else {
				if (this.tasaBonificada == 0) {
					return this.importeHipoteca / (this.plazo * 12) / 12;
				} else {
					Decimal factorPresenteValorFuturo = Math.pow(Double.valueOf(1 + this.tasaBonificada), this.plazo);
					return -this.tasaBonificada * (-this.importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
				}
			}
		}
	}

	public Map<String, Decimal> getIndicadoresViabilidad() {
		Map<String, Decimal> indicadores = new Map<String, Decimal>();

		Decimal dtiNominaSinBonificacion;
		Decimal dtiNominaBonificacion;
		Decimal dtiIrpfSinBonificacion;
		Decimal dtiIrpfBonificacion;

		//LTV
		if (this.importeHipoteca > 0 && this.importeCompraventa > 0) {
			indicadores.put('ltv', redondear(100 * this.importeHipoteca / this.importeCompraventa));
		} else {
			indicadores.put('ltv', null);
		}

		//DTI Nómina
		Decimal totalIngresosNominaTitulares = this.primerTitular?.totalIngresosNominaProrrateado ?? 0;
		totalIngresosNominaTitulares += this.segundoTitular?.totalIngresosNominaProrrateado ?? 0;
		if (totalIngresosNominaTitulares > 0) {
			dtiNominaSinBonificacion = 100 * this.deuda.totalDeuda / totalIngresosNominaTitulares;
			dtiNominaBonificacion = 100 * this.deuda.totalDeudaBonificacion / totalIngresosNominaTitulares;
		}
		indicadores.put('dti nómina', redondear(dtiNominaSinBonificacion));
		indicadores.put('dti nómina bonificado', redondear(dtiNominaBonificacion));

		//DTI IRPF
		Decimal totalIngresosIrpfTitulares = this.primerTitular?.totalIngresosIrpfProrrateado ?? 0;
		totalIngresosIrpfTitulares += this.segundoTitular?.totalIngresosIrpfProrrateado ?? 0;
		if (totalIngresosIrpfTitulares > 0) {
			dtiIrpfSinBonificacion = 100 * this.deuda.totalDeuda / totalIngresosIrpfTitulares;
			dtiIrpfBonificacion = 100 * this.deuda.totalDeudaBonificacion / totalIngresosIrpfTitulares;
		}
		indicadores.put('dti irpf', redondear(dtiIrpfSinBonificacion));
		indicadores.put('dti irpf bonificado', redondear(dtiIrpfBonificacion));

		return indicadores;
	}

	public static Decimal redondear(Decimal valor) {
		return valor != null ? valor.setScale(2, RoundingMode.HALF_UP) : 0;
	}

	private class CustomException extends Exception {}
}