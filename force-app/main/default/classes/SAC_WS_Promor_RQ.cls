/**
@name SAC_WS_Proesp_RQ
@version 1.0
@date 24-01-2022.
@author Nicolás García Muñoz, IBM
@description Clase que contiene las estructuras de datos de la petición del servicio de recuperación de Antecedentes de PROESP
*/
public class SAC_WS_Promor_RQ {

    public class RequestWrapper{

        private List<String> customerIds {get;set;}
        
        public RequestWrapper(List<String> customerIds){
			this.customerIds = customerIds;
		}

        public String serialize(){
            return JSON.serialize(this, true);
        }
    }

}