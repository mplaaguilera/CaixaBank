public class AV_CJWrapperError{

    public Envelope Envelope;
    
    public class LookUpCJResponse {
        public Acresults_Z acresults;
        public String encodingStyle;
    }
    
    public class Acresults {
        public Global_Z global_Z;// in json: global
        public Acresult acresult;
    }
    
    public class Acresults_Z {
        public Acresults acresults;
        public String type_Z;// in json: type
        public String encodingStyle;
    }
    
    public class Acresult {
        public String message;
        public String result;
    }
    
    public class Envelope {
        public Body Body;
    }
    
    public class Body {
        public LookUpCJResponse lookUpCJResponse;
    }
    
    public class Global_Z {
        public String code;
        public String message;
    }

}