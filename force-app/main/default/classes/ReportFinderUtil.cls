public with sharing class ReportFinderUtil {

  public ReportFinderUtil(){}
  
  public String findReportId(String reportName){
    
    Sobject myReport = [select Id,Name From Report /*Where Name=:reportName*/ limit 1];
    return myReport.Id;
    
  }
  
  
}