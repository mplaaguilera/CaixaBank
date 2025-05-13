global class CBK_WS_APIGraph_NextLink_Schedule implements Queueable{
    Map<String, CBK_APIGraph_Mailbox__c> nextLink =  new Map<String, CBK_APIGraph_Mailbox__c>();

    public CBK_WS_APIGraph_NextLink_Schedule(Map<String, CBK_APIGraph_Mailbox__c> nexExecutionParams) {
        nextLink = nexExecutionParams;
    }
    
    global void execute(QueueableContext qc) {
        for(String urlnext : nextLink.keySet()){ 
            CBK_WS_APIGraph api = new CBK_WS_APIGraph(urlnext, true, nextLink.get(urlnext));
            if(!Test.isRunningTest()){
                System.enqueueJob(api);
            }
        }
        system.abortJob(qc.getJobId());
    }        
}