global class CC_SocialPostReclScheduled implements Schedulable {

    global void execute(SchedulableContext SC) {
        CC_SocialPostReclBatch batch = new CC_SocialPostReclBatch();
        Database.executeBatch(batch,50);
    }
}