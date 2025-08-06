public class CC_FAQ_JSON {

	public class Topics {
		public String idTopic;
		public String idEspacio;
		public String topic;
		public String descripcionEs;
		public String descripcionCa;
		public String tfnoEs;
		public String tfnoCa;
	}

	public List<Faqs> faqs;
	public Espacio espacio;
	public List<Topics> topics;

	public class Intents {
		public Integer idIntent;
		public String intent;
		public String respuestaCortaEs;
		public String respuestaCortaCa;
		public String descripcion;
        public List<CustomsIntent> customsIntent;
	}

	public class Espacio {
		public String idEspacio;
		public String espacio;
		public String descripcionEs;
		public String descripcionCa;
	}

	public class Faqs {
		public String idFaq;
		public String texto;
		public String textoParaUsuarioEs;
		public String textoParaUsuarioCa;
		public String idEspacio;
		public String idTopic;
        public String idFaqSiebel;
		public String link;
		public List<Intents> intents;
        public List<CustomsFaq> customsFaq;
	}

	public class CustomsIntent {
        public String idGlobal;
        public String idIntent;
        public String respCorta;
	}

	public class CustomsFaq {
        public String idGlobal;
        public String idFaq;
        public String textoParaUsuario;
	}
    
    public class Customs {
        public String idGlobal;
        public String textoParaUsuario;
        public String respuestaCorta;
    }
	
	public static CC_FAQ_JSON parse(String json) {
		return (CC_FAQ_JSON) System.JSON.deserialize(json, CC_FAQ_JSON.class);
	}
}