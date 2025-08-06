/* 
    An utility class to parse XML and create the equivalent JSON
*/
public class AV_XMLParser {

/*    
    // To find the root element so that we can enclose it in the curly braces 
    public static String rootElementName; 
    
    /* Method which is parsing the XML content into JSON 
    * @param xml : XML String 
    * return     : JSON String
    /
*/
    public static boolean prueba(String xml) {
        return true;

    }
   /* 
    public static String xmlToJson(String xml) {
        
        // Load the xml in the document
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.XMLNode root = doc.getRootElement();
        
        // Pass the root element and false as the second parameter
        String jsonContent = AV_XMLParser.parse(root, false);
        return jsonContent;
    }
    
    
    /* Method which makes the recursive calls and creates the JSON for
    * each element, it processes each node and finds the attributes and text content of a node
    * @param node      : Dom.XMLNode instance - XML node which will be processed
    * @param isChild   : Boolean - To control the structure of JSON, should be true for child element
    * return           : JSON string 
    /
    public static String parse(Dom.XMLNode node, Boolean isChild){
        String json = '';
        Boolean isArray = false;
        if ( rootElementName == null ) {
            rootElementName = node.getName();
        }
        
        if ( node.getNodeType() == Dom.XmlNodeType.ELEMENT ){
            
            Map<String, List<String>> mapChildrenJSON = new Map<String, List<String>>();
            List<String> lstJSONForChildren = new List<String>();
            
            // Check whether node has any child
            List<Dom.XMLNode> children = node.getChildElements();
            
            if ( children.size() > 0 ){
            
                // Process all the children in a row
                for ( Dom.XMLNode child : children ){
                    
                    String tmp = parse( child, true );
                    
                    if( tmp != '' ) {
                    
                        if ( !mapChildrenJSON.containsKey( child.getName() ) ){
                        
                            mapChildrenJSON.put( child.getName(), new List<String>() );     
                        
                        }
                        
                        // Add into a map to make a collection for the repeatative child nodes
                        mapChildrenJSON.get( child.getName() ).add( tmp );  
                    
                    }
                    
                } 
                
                // Strcuture the JSON based on the repeation 
                // Should be treated as an array if there are multiple elements with the same node name
                for ( String key : mapChildrenJSON.keySet() ){
                    
                    if ( mapChildrenJSON.get(key).size() > 1 ){
                        if(isChild) {
                        
                            lstJSONForChildren.add( '[' + String.join(mapChildrenJSON.get(key), ', ') + ']' );
                        
                        }
                        else {
                        
                            lstJSONForChildren.add( '"' + key + '": [' + String.join(mapChildrenJSON.get(key), ', ') + ']' );
                                
                        }
                        isArray = true;
                    }
                    else {
                    
                        lstJSONForChildren.add( '"' + key + '": ' + mapChildrenJSON.get(key)[0] );
                    
                    }
                }
            }
            
            // Construc the JSON for all the node attributes 
            List<String> lstAttributes = new List<String>( lstJSONForChildren );
            
            for ( Integer i=0; i<node.getAttributeCount(); i++){
                
                String key = node.getAttributeKeyAt( i );
                String value = node.getAttribute( key, '' );
                lstAttributes.add( '"' + key + '": "' + value + '"' );    
            
            }  
            
            // Look for the text content 
            String textContent = node.getText();
            if ( textContent != null && textContent.trim() != '' ) {
            
                textContent = textContent.replace( '"', '\\"' );
                lstAttributes.add( '"ele_text": "' + textContent + '"' );  
                
            }
            if ( !isChild ){
            
                if(!isArray) {
                
                    json = '"' + node.getName() + '": {' + String.join(lstAttributes,  ', ') + '}'; 
                    
                }
                else {
                
                    json = ' {' + String.join(lstAttributes,  ', ') + '}'; 
                    
                }
            }else {
                if ( lstAttributes.size() == 1 && textContent != null && textContent.trim() != '' ){
                    
                    json = '"' + textContent + '"';
                    
                }else {
                    if(!isArray) {
                    
                        if( lstAttributes.size() > 0 ){
                        
                            json = '{' + String.join(lstAttributes,  ', ') + '}'; 
                            
                        }
                        
                    }
                    else {
                    
                        json = String.join(lstAttributes,  ', '); 
                        
                    }
                }   
            }
        }
        if ( rootElementName == node.getName() ) {
        
            if(!isArray) {
            
                json = '{' + json + '}';
            
            }
            else {
                
                json = '{"' + node.getName() + '" : ' + json + '}';
                
            }
        
        }
        
        //system.debug(node.getName()+ ':' + json);
        return json;
    }


    public static Map<String, String> xmlDataMap = new Map<String,String>(); 
    public static recipientElement recipient = new recipientElement();
    private static void iterateThroughXML(DOM.XMLNode node){
        
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT){
        
           
            if(node.getName().equalsIgnoreCase('recipient')){
                if (node.getAttributeCount() > 0) {
                  recipient.id = node.getAttributeValue(node.getAttributeKeyAt(0), node.getAttributeKeyNsAt(0));
                }
                List<broadLogElement> broadLogs = new List<broadLogElement>();
                List<broadLogAppSubRcpElement> broadLogAppSubRcps = new List<broadLogAppSubRcpElement>();
                for(Dom.XmlNode grandchildNode :node.getChildElements()){
                    
                    if(grandchildNode.getName().equalsIgnoreCase('broadLog')){
                        broadLogElement broadLog = new broadLogElement();
                        if (grandchildNode.getAttributeCount() > 0) {
                            broadLog.id = node.getAttributeValue(grandchildNode.getAttributeKeyAt(3), grandchildNode.getAttributeKeyNsAt(3));
                            broadLog.eventDate  = grandchildNode.getAttributeValue(grandchildNode.getAttributeKeyAt(2), grandchildNode.getAttributeKeyNsAt(2));
                            broadLog.broadLogId = grandchildNode.getAttributeValue(grandchildNode.getAttributeKeyAt(1), grandchildNode.getAttributeKeyNsAt(1));
                            broadLog.status = grandchildNode.getAttributeValue(grandchildNode.getAttributeKeyAt(4), grandchildNode.getAttributeKeyNsAt(4));
                            
                        }
                        for (Dom.XMLNode child: grandchildNode.getChildElements()){
                            if(child.getName().equalsIgnoreCase('delivery')){
                                deliveryElement delivery = new deliveryElement();
                                if (child.getAttributeCount() > 0) {
                                    delivery.code = child.getAttributeValue(child.getAttributeKeyAt(0), child.getAttributeKeyNsAt(0));
                                    delivery.deliveryId  = child.getAttributeValue(child.getAttributeKeyAt(1), child.getAttributeKeyNsAt(1));
                                    delivery.label = child.getAttributeValue(child.getAttributeKeyAt(2), child.getAttributeKeyNsAt(2));
                                    delivery.messageType = child.getAttributeValue(child.getAttributeKeyAt(3), child.getAttributeKeyNsAt(3));
                                    broadLog.delivery = delivery;
                                }
                            }
                            for(Dom.XMLNode grandChild: child.getChildElements()){
                                if(grandChild.getName().equalsIgnoreCase('operation')){
                                    if (grandChild.getAttributeCount() > 0) {
                                        operationElement operation = new operationElement(); 
                                        operation.lookUpCJs_Boap_Id = grandChild.getAttributeValue(grandChild.getAttributeKeyAt(0), grandChild.getAttributeKeyNsAt(0));
                                        broadLog.operation = operation;
                                    }
                                }
                            }
                        }
                        broadLogs.add(broadLog);
                        
                    }

                    if(grandchildNode.getName().equalsIgnoreCase('broadLogAppSubRcp')){
                        broadLogAppSubRcpElement broadLogAppSub = new broadLogAppSubRcpElement();
                        if (grandchildNode.getAttributeCount() > 0) {
                            broadLogAppSub.id = node.getAttributeValue(grandchildNode.getAttributeKeyAt(3), grandchildNode.getAttributeKeyNsAt(3));
                            broadLogAppSub.eventDate  = grandchildNode.getAttributeValue(grandchildNode.getAttributeKeyAt(2), grandchildNode.getAttributeKeyNsAt(2));
                            broadLogAppSub.broadLogId = grandchildNode.getAttributeValue(grandchildNode.getAttributeKeyAt(1), grandchildNode.getAttributeKeyNsAt(1));
                            broadLogAppSub.status = grandchildNode.getAttributeValue(grandchildNode.getAttributeKeyAt(4), grandchildNode.getAttributeKeyNsAt(4));
                            
                        }
                        for (Dom.XMLNode child: grandchildNode.getChildElements()){
                            if(child.getName().equalsIgnoreCase('delivery')){
                                deliveryElement delivery = new deliveryElement();
                                if (child.getAttributeCount() > 0) {
                                    delivery.code = child.getAttributeValue(child.getAttributeKeyAt(0), child.getAttributeKeyNsAt(0));
                                    delivery.deliveryId  = child.getAttributeValue(child.getAttributeKeyAt(1), child.getAttributeKeyNsAt(1));
                                    delivery.label = child.getAttributeValue(child.getAttributeKeyAt(2), child.getAttributeKeyNsAt(2));
                                    delivery.messageType = child.getAttributeValue(child.getAttributeKeyAt(3), child.getAttributeKeyNsAt(3));
                                    broadLogAppSub.delivery = delivery;
                                }
                            }
                            for(Dom.XMLNode grandChild: child.getChildElements()){
                                if(grandChild.getName().equalsIgnoreCase('operation')){
                                    if (grandChild.getAttributeCount() > 0) {
                                        operationElement operation = new operationElement(); 
                                        operation.lookUpCJs_Boap_Id = grandChild.getAttributeValue(grandChild.getAttributeKeyAt(0), grandChild.getAttributeKeyNsAt(0));
                                        broadLogAppSub.operation = operation;
                                    }
                                }
                            }
                        }
                        broadLogAppSubRcps.add(broadLogAppSub);
                        
                    }
                    recipient.broadLog = broadLogs;
                    recipient.broadLogAppSubRcp = broadLogAppSubRcps;
                }
                
            }
           
           
            for (Dom.XMLNode child: node.getChildElements()){
              iterateThroughXML(child);
            }
        }
    }

    public static recipientElement parserXML(String toParse){

        DOM.Document doc = new DOM.Document();
        doc.load(toParse);
        DOM.XMLNode root = doc.getRootElement();
        iterateThroughXML(root);
        return recipient;
       
    }

    public class recipientElement{
        public String id;
        public broadLogElement[] broadLog;
        public broadLogAppSubRcpElement[] broadLogAppSubRcp; 
    }

    public class broadLogAppSubRcpElement{
        public operationElement operation;
        public deliveryElement delivery;
        public String address;
        public String broadLogId;
        public String eventDate;
        public String id;
        public String status;
    }


    public class recipientInfoElement{
        public String created;
        public String email;
        public String firstName;
        public String gender;
        public String lastName;
        public String status;
    }

    public class broadLogElement{
        public operationElement operation;
        public deliveryElement delivery;
        public String address;
        public String broadLogId;
        public String eventDate;
        public String id;
        public String status;
    }


    public class deliveryElement{
        public operationElement operation;
        public String code;
        public String deliveryId;
        public String label;
        public String messageType;
    }

    public class operationElement{
        public String lookUpCJs_Boap_Id;
    }

    */
    
}