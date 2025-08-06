/**
*   @description OS_receiveFromCognitive
*/
public class OS_receiveFromCognitive{ 
	public String sr;	//03928936
	public String model_name;	//model-001
	public String category;	//UAFE Confirming
	public cls_categories[] categories;
	public cls_attributes attributes;
	class cls_categories {
		public String category;	//Robot No Clasificado
		public String ratio;	//0.99953
	}
	class cls_attributes {
		public cls_text_regex[] text_regex;
		//public cls_text_vector_words[] text_vector_words;
		//public cls_text_vector_tokenizer[] text_vector_tokenizer;
		//public cls_text_features[] text_features;
	}
	/*class cls_text_regex {
		public String name;	//IBAN_regex
		public String value;	//ES97...00
	}
	class cls_text_vector_words {
		public String name;	//mes_anyo
		public String value;	//7
	}
	class cls_text_vector_tokenizer {
		public String name;	//mes_anyo
		public String value;	//10
	}
	class cls_text_features {
		public String name;	//mes_anyo
		public String value;	//10
	}*/
	class cls_text_regex {
	}
	class cls_text_vector_words {
	}
	class cls_text_vector_tokenizer {
	}
	class cls_text_features {
	}
	
	public static OS_receiveFromCognitive parse(String json){
		return (OS_receiveFromCognitive) System.JSON.deserialize(json, OS_receiveFromCognitive.class);
	}

}