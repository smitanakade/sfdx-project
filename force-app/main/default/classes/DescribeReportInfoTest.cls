@isTest
private class DescribeReportInfoTest 
{
    static testMethod void TestClassCreaton() 
    {
    	/* Test Exception */
    	try
    	{
    		throw new DescribeReportInfo.TDescribeReportException('Test');
    	}
    	catch(DescribeReportInfo.TDescribeReportException ex)
    	{
    		system.assert(true,'Exception creation failed');
    	}
    	catch(Exception ex)
    	{
    		system.assert(false,'Exception handler failed');
    	}

		DescribeReportInfo.AggregateColumnInfo aggregateColumnInfo = new DescribeReportInfo.AggregateColumnInfo(JSON.createParser(
		'{'+
		'        \"InvalidObject\" : { ' +
		'        \"Account.RM_Percentage_of_Premium__c\" : {'+
		'          \"dataType\" : \"percent\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"% of Premium\"'+
		'        }},'+
		'        \"InvalidObjectAgain\" : "consumeObjectcalled",'+
		'        \"acrossGroupingContext\" : "Test",'+
		'        \"dataType\" : \"int\",'+
		'        \"downGroupingContext\" : "Test",'+
		'        \"label\" : \"Record Count\"'+
		'}'));
		system.AssertEquals('Record Count',aggregateColumnInfo.label);
		system.AssertEquals('int',aggregateColumnInfo.dataType);
		system.AssertEquals('Test',aggregateColumnInfo.downGroupingContext);
		system.AssertEquals('Test',aggregateColumnInfo.acrossGroupingContext);
		system.AssertEquals('Aggregate',aggregateColumnInfo.ColumnType);

		DescribeReportInfo.DetailColumnInfo detailColumnInfo = new DescribeReportInfo.DetailColumnInfo(JSON.createParser(
		'{'+
		'        \"InvalidObject\" : "consumeObjectcalled",'+
		'        \"dataType\" : \"string\",'+
		'        \"label\" : \"First Name\"'+
		'}'));
		system.AssertEquals('First Name',detailColumnInfo.label);
		system.AssertEquals('string',detailColumnInfo.dataType);
		system.AssertEquals('Detail',detailColumnInfo.ColumnType);

		DescribeReportInfo.GroupingColumnInfo groupingColumnInfo = new DescribeReportInfo.GroupingColumnInfo(JSON.createParser(
		'{'+
		'        \"dataType\" : \"string\",'+
		'        \"InvalidObject\" : "consumeObjectcalled",'+
		'        \"label\" : \"First Name\",'+
		'        \"groupingLevel\" : \"1\"'+
		'}'));
		system.AssertEquals('First Name',groupingColumnInfo.label);
		system.AssertEquals('string',groupingColumnInfo.dataType);
		system.AssertEquals('Grouping',groupingColumnInfo.ColumnType);

		DescribeReportInfo.FilterOperator filterOperator = new DescribeReportInfo.FilterOperator(JSON.createParser(
		'{'+
		'        \"InvalidObject\" : "consumeObjectcalled",'+
		'        \"label\" : \"equals\",'+
		'        \"name\" : \"equals\"'+
		'}'));
		system.AssertEquals('equals',filterOperator.label);
		system.AssertEquals('equals',filterOperator.name);

		DescribeReportInfo.Column column = new DescribeReportInfo.Column(JSON.createParser(
		'{'+
		'        \"InvalidObject\" : "consumeObjectcalled",'+
		'         \"dataType\" : \"email\",'+
		'         \"filterValues\" : [ ],'+
		'         \"filterable\" : true,'+
		'         \"label\" : \"Broadcast Email\"'+
		'}'));
		system.AssertEquals('Broadcast Email',column.label);
		system.AssertEquals('email',column.dataType);

		DescribeReportInfo.Categories categories = new DescribeReportInfo.Categories(JSON.createParser(
		'{'+
		'      \"InvalidObject\" : "consumeObjectcalled",'+
		'      \"columns\" : {'+
		'        \"Account.RM_Percentage_of_Premium__c\" : {'+
		'          \"dataType\" : \"percent\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"% of Premium\"'+
		'        },'+
		'        \"Account.AnnualRevenue\" : {'+
		'          \"dataType\" : \"currency\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Annual Revenue\"'+
		'        },'+
		'        \"Account.ANZSIC_1__c\" : {'+
		'          \"dataType\" : \"picklist\",'+
		'          \"filterValues\" : [ {'+
		'            \"label\" : \"111_Plant Nurseries\",'+
		'            \"name\" : \"111_Plant Nurseries\"'+
		'          }, {'+
		'            \"label\" : \"9634_Waste Disposal Services\",'+
		'            \"name\" : \"9634_Waste Disposal Services\"'+
		'          }, {'+
		'            \"label\" : \"9700_Private Households Employing Staff\",'+
		'            \"name\" : \"9700_Private Households Employing Staff\"'+
		'          } ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"ANZSIC 3\"'+
		'        },'+
		'        \"Account.assumed_Segmentation__c\" : {'+
		'          \"dataType\" : \"picklist\",'+
		'          \"filterValues\" : [ {'+
		'            \"label\" : \"Express\",'+
		'            \"name\" : \"Express\"'+
		'          }, {'+
		'            \"label\" : \"Focus\",'+
		'            \"name\" : \"Focus\"'+
		'          } ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"assumed Segmentation\"'+
		'        },'+
		'        \"Lead.PostalCode\" : {'+
		'          \"dataType\" : \"string\",'+
		'          \"filterValues\" : [ ],'+
		'          \"filterable\" : true,'+
		'          \"label\" : \"Zip/Postal Code\"'+
		'        }'+
		'      },'+
		'      \"label\" : \"Leads\"'+
		'}'));
		system.AssertEquals('Leads',categories.label);
		system.AssertNotEquals(null,categories.columns);
		system.AssertEquals(5,categories.columns.size());
		
		DescribeReportInfo.GroupingInfo groupingInfo = new DescribeReportInfo.GroupingInfo(JSON.createParser(
		'{'+
		'          \"InvalidObject\" : "consumeObjectcalled",'+
		'          \"name\" : \"DateField\",'+
		'          \"sortOrder\" : \"1\",'+
		'          \"dateGranularity\" : \"Monthly\"'+
		'}'));
		system.AssertEquals('Monthly',groupingInfo.dateGranularity);
		system.AssertEquals('1',groupingInfo.sortOrder);
		system.AssertEquals('DateField',groupingInfo.name);
		
		DescribeReportInfo.ReportType reportType = new DescribeReportInfo.ReportType(JSON.createParser(
		'{'+
		'      \"InvalidObject\" : "consumeObjectcalled",'+
		'      \"label\" : \"Accounts with Leads\",'+
		'      \"type\" : \"Accounts_with_Leads__c\"'+
		'}'));
		system.AssertEquals('Accounts with Leads',reportType.label);
		system.AssertEquals('Accounts_with_Leads__c',reportType.type);

		DescribeReportInfo.FilterInfo filterInfo = new DescribeReportInfo.FilterInfo(JSON.createParser(
		'{'+
		'      \"InvalidObject\" : "consumeObjectcalled",'+
		'      \"column\" : \"Lead.LeadSource\",'+
		'      \"operator\" : \"equals\",'+
		'      \"value\" : \"Find an Adviser\"'+
		'}'));
		system.AssertEquals('Find an Adviser',filterInfo.value);
		system.AssertEquals('equals',filterInfo.operator);
		system.AssertEquals('Lead.LeadSource',filterInfo.column);

		DescribeReportInfo.ReportExtendedMetadata reportExtendedMetadata = new DescribeReportInfo.ReportExtendedMetadata(JSON.createParser(
		'{'+
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
		'    }'+
		'  },'+
		'}'));
		system.AssertNotEquals(null,reportExtendedMetadata);
		
		DescribeReportInfo.ReportMetadata reportMetaData = new DescribeReportInfo.ReportMetadata(JSON.createParser(
		'{'+
		'    \"InvalidObject\" : "consumeObjectcalled",'+
		'    \"aggregates\" : [ \"RowCount\" ],'+
		'    \"reportBooleanFilter\" : "(1 OR 2) AND 3",'+
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
		'      \"label\" : \"Accounts with Leads\",'+
		'      \"type\" : \"Accounts_with_Leads__c\"'+
		'    }'+
		'  }'+
		'}'));
		system.AssertNotEquals(null,reportMetaData);

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
		system.AssertNotEquals(null,reportTypeMetadata);
		
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
//		'    \"InvalidObject\" : "consumeObjectcalled",'+
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
		'      \"label\" : \"Accounts with Leads\",'+
		'      \"type\" : \"Accounts_with_Leads__c\"'+
		'    }'+
		'  }'+
		'}'));
		system.AssertNotEquals(null,describeReport);
		system.AssertNotEquals(null,describeReport.reportMetadata);
		system.AssertNotEquals(null,describeReport.reportExtendedMetadata);
		system.AssertNotEquals(null,describeReport.reportTypeMetadata);
		
		
    }
}