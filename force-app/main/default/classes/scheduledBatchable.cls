global class scheduledBatchable implements Schedulable {
   global void execute(SchedulableContext sc) {
      Batch_File_Type_Update  b = new Batch_File_Type_Update(); 
      database.executebatch(b);
   }
}