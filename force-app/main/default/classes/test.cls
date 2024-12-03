public with sharing class test {
  public static void closeTasks(List<Case> cases) {
    Set<Id> userIds = new Set<Id>();
    for (Case c : cases) {
      userIds.add(c.OwnerId);
    }

    List<Task> tasks = new List<Task> ();
    tasks = [SELECT Id, Status FROM Task WHERE OwnerId IN :userIds];
    System.debug('tasks to be closed: ' + tasks);

    if (tasks.size() > 0) {
      for (Task t : tasks) {
        t.Status = 'Closed';
      }
      try {
        update tasks;
      } catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
      }
    }
  }
}
