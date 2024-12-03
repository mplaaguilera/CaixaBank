public with sharing class CSBD_Bypass_Trigger {

        public static Map<String, Boolean> triggerNameBypassed = new Map<String, Boolean>();
    
        public static void bypass(String triggerName) {
            triggerNameBypassed.put(triggerName, true);
        }
    
        public static void undoBypass(String triggerName) {
            triggerNameBypassed.put(triggerName, false);
        }
    
        public static Boolean isBypassed(String triggerName) {
            return triggerNameBypassed.containsKey(triggerName) && triggerNameBypassed.get(triggerName);
        }
    
}