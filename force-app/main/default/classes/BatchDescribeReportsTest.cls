@isTest
private class BatchDescribeReportsTest 
{
    @isTest(SeeAllData=true)
    static void testDescribedReport() 
    {
		BatchDescribeReports batchClass = new BatchDescribeReports();
		batchClass.Session = UserInfo.getSessionId();         
		batchClass.Endpoint = URl.getSalesforceBaseUrl().toExternalForm();         

        batchClass.execute(null, (List<sobject>) [select Id, Name, LastRunDate, LastViewedDate, LastModifiedDate, LastModifiedById from Report limit 1] );
    }
       
    static testmethod void testDescribedReportTypeData()
    {
		DescribeReportInfo.ReportTypeMetadata reportTypeMetadata = new DescribeReportInfo.ReportTypeMetadata(JSON.createParser(
		'{'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"categories\" : [ {'+
		'      \"columns\" : {'+
		'        \"Account.RM_Percentage_of_Premium__c\" : {'+
		'          \"dataType\" : \"percent\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"% of Premium\"'+
		'        },'+
		'        \"Account.AccountSource\" : {'+
		'          \"dataType\" : \"picklist\",'+
		'          \"filterValues\" : [ {'+
		'            \"label\" : \"B&A Identified\",'+
		'            \"name\" : \"B&A Identified\"'+
		'          }, {'+
		'            \"label\" : \"Word of mouth\",'+
		'            \"name\" : \"Word of mouth\"'+
		'          }, {'+
		'            \"label\" : \"Find an Adviser\",'+
		'            \"name\" : \"Find an Adviser\"'+
		'          } ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Account Source\"'+
		'        },'+
		'        \"Lead.PostalCode\" : {'+
		'          \"dataType\" : \"string\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Zip/Postal Code\"'+
		'        }'+
		'      },'+
		'      \"label\" : \"Leads\"'+
		'    } ],'+
		'    \"dataTypeFilterOperatorMap\" : {'+
		'      \"phone\" : [ {'+
		'        \"label\" : \"equals\",'+
		'        \"name\" : \"equals\"'+
		'      }, {'+
		'        \"label\" : \"does not contain\",'+
		'        \"name\" : \"notContain\"'+
		'      }, {'+
		'        \"label\" : \"starts with\",'+
		'        \"name\" : \"startsWith\"'+
		'      } ]'+
		'    }'+
		'  }'+
		'}'));
		DescribeReportInfo.ReportType reportType = new DescribeReportInfo.ReportType(JSON.createParser(
		'{'+
		'      \"InvalidObject\" : "consumeObjectcalled",'+
		'      \"label\" : \"Accounts with Leads\",'+
		'      \"type\" : \"Accounts_with_Leads__c\"'+
		'}'));
		
		BatchDescribeReports batchClass = new BatchDescribeReports();
		batchClass.Session = UserInfo.getSessionId();         
		batchClass.Endpoint = URl.getSalesforceBaseUrl().toExternalForm();    
		
		report_type__c reportObject1 = batchClass.ReportType(reportType, reportTypeMetadata);
		system.assertNotEquals(null,reportObject1);
		system.assertEquals('Accounts_with_Leads__c',reportObject1.Name);
		system.assertEquals('Accounts with Leads',reportObject1.Label__c);
		upsert reportObject1;
		
		//Test we get the same answer - if we requery
		report_type__c reportObject2 = batchClass.ReportType(reportType, reportTypeMetadata);
		system.assertNotEquals(null,reportObject2);
		system.assertEquals(reportObject1,reportObject2);

		DescribeReportInfo describeReport = new DescribeReportInfo(JSON.createParser(
		'{'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"reportExtendedMetadata\" : {'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"aggregateColumnInfo\" : {'+
		'      \"RowCount\" : {'+
		'        \"acrossGroupingContext\" : null,'+
		'        \"dataType\" : \"int\",'+
		'        \"downGroupingContext\" : null,'+
		'        \"label\" : \"Record Count\"'+
		'      }'+
		'    },'+
		'    \"detailColumnInfo\" : {'+
		'      \"Lead.FirstName\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"label\" : \"First Name\"'+
		'      },'+
		'      \"Lead.LastName\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"label\" : \"Last Name\"'+
		'      },'+
		'      \"Lead.Rating\" : {'+
		'        \"dataType\" : \"picklist\",'+
		'        \"label\" : \"Rating\"'+
		'      }'+
		'    },'+
		'    \"groupingColumnInfo\" : {'+
		'      \"Account.Name\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"groupingLevel\" : 0,'+
		'        \"label\" : \"Account Name\"'+
		'      },'+
		'      \"Lead.Status\" : {'+
		'        \"dataType\" : \"picklist\",'+
		'        \"groupingLevel\" : 2,'+
		'        \"label\" : \"Lead Status\"'+
		'      },'+
		'      \"Account.Owner.Name\" : {'+
		'        \"dataType\" : \"string\",'+
		'        \"groupingLevel\" : 1,'+
		'        \"label\" : \"Account Owner: Full Name\"'+
		'      }'+
		'  }' +
		'}, \"reportTypeMetadata\" : {'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"categories\" : [ {'+
		'      \"columns\" : {'+
		'        \"Account.RM_Percentage_of_Premium__c\" : {'+
		'          \"dataType\" : \"percent\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"% of Premium\"'+
		'        },'+
		'        \"Account.AccountSource\" : {'+
		'          \"dataType\" : \"picklist\",'+
		'          \"filterValues\" : [ {'+
		'            \"label\" : \"B&A Identified\",'+
		'            \"name\" : \"B&A Identified\"'+
		'          }, {'+
		'            \"label\" : \"Word of mouth\",'+
		'            \"name\" : \"Word of mouth\"'+
		'          }, {'+
		'            \"label\" : \"Find an Adviser\",'+
		'            \"name\" : \"Find an Adviser\"'+
		'          } ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Account Source\"'+
		'        },'+
		'        \"Lead.PostalCode\" : {'+
		'          \"dataType\" : \"string\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Zip/Postal Code\"'+
		'        }'+
		'      },'+
		'      \"label\" : \"Leads\"'+
		'    } ],'+
		'    \"dataTypeFilterOperatorMap\" : {'+
		'      \"phone\" : [ {'+
		'        \"label\" : \"equals\",'+
		'        \"name\" : \"equals\"'+
		'      }, {'+
		'        \"label\" : \"does not contain\",'+
		'        \"name\" : \"notContain\"'+
		'      }, {'+
		'        \"label\" : \"starts with\",'+
		'        \"name\" : \"startsWith\"'+
		'      } ]'+
		'    }'+
		'}, \"reportMetadata\" : {'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"aggregates\" : [ \"RowCount\" ],'+
		'    \"currency\" : "Currency",'+
		'    \"historicalSnapshotDates\" : [ \"DummyDate\", \"DummyDate1\" ],'+
		'    \"detailColumns\" : [ \"Lead.FirstName\", \"Lead.LastName\", \"Lead.Description\", \"Lead.CreatedDate\", \"Lead.Email\", \"Lead.Phone\", \"Lead.Adviser_Product_Type__c\", \"Lead.Adviser_Product_Category__c\", \"Lead.Rating\" ],'+
		'    \"developerName\" : \"VIC_Find_an_Adviser_Lead_Summary_Report\",'+
		'    \"groupingsAcross\" : [ {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Owner.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Lead.Status\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    } ],'+
		'    \"groupingsDown\" : [ {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Account.Owner.Name\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    }, {'+
		'      \"dateGranularity\" : \"None\",'+
		'      \"name\" : \"Lead.Status\",'+
		'      \"sortOrder\" : \"Asc\"'+
		'    } ],'+
		'    \"id\" : \"00OD0000006XPKwMAO\",'+
		'    \"name\" : \"VIC Find an Adviser Lead Summary Report\",'+
		'    \"reportBooleanFilter\" : null,'+
		'    \"reportFilters\" : [ {'+
		'      \"column\" : \"Lead.Owner.Name\",'+
		'      \"operator\" : \"equals\",'+
		'      \"value\" : \"FAAUser\"'+
		'    }, {'+
		'      \"column\" : \"Lead.LeadSource\",'+
		'      \"operator\" : \"equals\",'+
		'      \"value\" : \"Find an Adviser\"'+
		'    }, {'+
		'      \"column\" : \"Account.State_Grouping__c\",'+
		'      \"operator\" : \"contains\",'+
		'      \"value\" : \"VIC\"'+
		'    } ],'+
		'    \"reportFormat\" : \"SUMMARY\",'+
		'    \"reportType\" : {'+
		'      \"label\" : \"Accounts with Leads",'+
		'      \"type\" : \"Accounts_with_Leads__c$Account.Account\"'+
		'    }'+
		'  }'+
		'}'));
		system.AssertNotEquals(null,describeReport);
		
		Report__c report1 = batchClass.ReportInstance(describeReport);
		system.AssertNotEquals(null,report1);
		system.AssertEquals('SUMMARY',report1.reportFormat__c);
		system.AssertEquals('VIC_Find_an_Adviser_Lead_Summary_Report',report1.developerName__c);
		system.AssertEquals('VIC Find an Adviser Lead Summary Report',report1.reportName__c);
		upsert report1;

		batchClass = new BatchDescribeReports();
		batchClass.Session = UserInfo.getSessionId();         
		batchClass.Endpoint = URl.getSalesforceBaseUrl().toExternalForm();    
		
		Report__c report2 = batchClass.ReportInstance(describeReport);
		system.AssertNotEquals(null,report2);
		system.AssertEquals(report1.developerName__c, report2.developerName__c);	
		Report__c report3 = batchClass.ProcessReport(new Report());
	
		System.assertEquals(batchClass.start(null).getQuery(), Database.getQueryLocator([select Id, Name, LastRunDate, LastViewedDate, LastModifiedDate, LastModifiedById from Report order by LastModifiedDate asc]).getQuery());
    }
}