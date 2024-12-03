public class CC_Consulta_RUC_JSON {
	public ResultError ResultError;
	public List<Contacto> ListadoContactos;

	public class ResultError {
		public String codError;
		public String descError;
	}

	public class Contacto {
		public Integer anoMes;
		public Integer numPerson;
		public Integer codContacto;
		//public Long fechaContacto;
		//public Integer codFuente;
		public String descFuente;
		public String descOrigen;
		//public Integer empleado;
		//public Integer centro;
		//public Integer codMedio;
		public String descMedio;
		//public Integer codCanal;
		//public Integer tipoComunicacion;
		public String descComunic;
	}
    
	public static CC_Consulta_RUC_JSON parse(String json) {
		return(CC_Consulta_RUC_JSON) System.JSON.deserialize(json, CC_Consulta_RUC_JSON.class);        
	}
}