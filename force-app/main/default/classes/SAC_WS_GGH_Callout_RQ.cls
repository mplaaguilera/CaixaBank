/**
@name SAC_WS_Gescon_RQ
@version 1.0
@date 31-05-2022.
@author Nicolás García Muñoz, IBM
@description Clase que contiene las estructuras de datos de la petición del servicio de recuperación de GGH
*/
public class SAC_WS_GGH_Callout_RQ {

    public class GGHRequest{

        private String usuarioAlta{get;set;}
        private Reclamacion reclamacion{get;set;}
        private List<Documentacion> lstDocumentacion;
        
        public GGHRequest(String usuarioAlta, Reclamacion reclamacion, List<Documentacion> lstDocumentacion){
			this.usuarioAlta	= usuarioAlta;
			this.reclamacion	= reclamacion;
            this.lstDocumentacion	= lstDocumentacion;
		}

        public String serialize(){
            return JSON.serialize(this, true);
        }
    }

    /**
	*   @author     	IBM
	*   @since      	Jun, 2022
	*   @description	Clase para generar el wrapper de la reclamación
	*   @history    	Jun, 2022 - IBM - Create Apex Class 
	*/
	public class Reclamacion{
		
        private String idPretension {get;set;}
        private String idTarea {get;set;}
        private String dni_Reclamante1 {get;set;}
        private String impNotaria {get;set;}
        private String impGestoria {get;set;}
        private String impRegistro {get;set;}
        private String impTasacion {get;set;}
        private String contrato {get;set;}
        private String ccAbono {get;set;}
        private String observaciones {get;set;}

		public Reclamacion( String idPretension, String idTarea, String dni_Reclamante1, String impNotaria, String impGestoria, String impRegistro, String impTasacion, String contrato, String ccAbono, String observaciones){
			this.idPretension = idPretension;
            this.idTarea = idTarea;
            this.dni_Reclamante1 = dni_Reclamante1;
            this.impNotaria = impNotaria;
            this.impGestoria = impGestoria;
            this.impRegistro = impRegistro;
            this.impTasacion = impTasacion;
            this.contrato = contrato;
            this.ccAbono = ccAbono;
            this.observaciones = observaciones;
		}

		public String getIdPretension(){
			return this.idPretension;
		}

		public String getIdTarea(){
			return this.idTarea;
		}

        public String getDniReclamante(){
			return this.dni_Reclamante1;
		}

        public String getImpNotaria(){
			return this.impNotaria;
		}

        public String getImpRegistro(){
			return this.impRegistro;
		}

        public String getImpTasacion(){
			return this.impTasacion;
		}

        public String getContrato(){
			return this.contrato;
		}

        public String getCCabono(){
			return this.ccAbono;
		}

        public String getObservaciones(){
			return this.observaciones;
		}
    }

    /**
	*   @author     	IBM
	*   @since      	May, 2022
	*   @description	Clase para generar el wrapper de los datos del resultado
	*   @history    	May, 2022 - IBM - Create Apex Class 
	*/
	public class Documentacion{

        public String content;
        public String name;

		public Documentacion( String content, String name ){
			this.content			= content;
			this.name		= name;
		}

		public String getContent(){
			return this.content;
		}

		public String getName(){
			return this.name;
		}
    }

}