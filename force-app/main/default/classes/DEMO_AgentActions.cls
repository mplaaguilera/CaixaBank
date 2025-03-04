public with sharing class DEMO_AgentActions {

    @InvocableMethod(label='Agent Action')
    public static List<Boolean> agentAction(List<AgentRequest> requests) {
        AgentRequest request = requests[0];
        return new List<Boolean>{true};
    }

    public class AgentRequest {
        @InvocableVariable(required=true)
        public String customerId;
    }

}