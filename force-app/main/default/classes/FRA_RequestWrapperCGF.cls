public with sharing class FRA_RequestWrapperCGF {
    public String negocio_CGF;
	public String tipoOperacion_CGF;
	public String userId_CGF;
	public String numPerso_CGF;
	public String numDoc_CGF;
	public String idExpediente_CGF;
	public String canal_CGF;
	public List<Alertas_CGF> alertas_CGF;
	
    public class Alertas_CGF {
		public String idOperacion_CGF;
		public String tipoOperacion;
		public String fechaOperacion;
		public String importe;
		public String cuenta_Origen;
		public String cuenta_Destino;
		public String tipologia;
		public String campana;
		public String estado;
		public String numeroTarjeta;
		public String MCC;
		public String pais;
		public String nombreComercio;
		public String numDocPersonaConectada;
	}


    public static FRA_RequestWrapperCGF parse(String json) {
		return (FRA_RequestWrapperCGF) System.JSON.deserialize(json, FRA_RequestWrapperCGF.class);
	}

}