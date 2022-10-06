import json
import boto3
from datetime import datetime, date, timedelta


def lambda_handler(event, context):
    print(event)
    
    cw = event['current-weight']
    func_name = event['function-name']
    version = event['new-version']
    alias_name = event['alias-name']
    
    # data = health_check_metrics_errors2(func_name, alias_name, version)
    
    # print(data)
    
    return usage_check(func_name, version, alias_name, cw)
    
def usage_check(func_name, version, alias_name, cw):
    threshold = usage_check_metrics(func_name, version, alias_name, cw)
    
    return "FULL" if threshold else "NOT-FULL"
    
def usage_check_metrics(func_name, version, alias_name, cw):
    client = boto3.client('cloudwatch')

    func_plus_alias = func_name + ":" + alias_name
    now = datetime.utcnow()
    start_time = now - timedelta(minutes=60)

    response = client.get_metric_statistics(
        Namespace='AWS/Lambda',
        MetricName='Invocations',
        Dimensions=[
            {
                'Name': 'FunctionName',
                'Value': func_name
            },
            {
                'Name': 'Resource',
                'Value': func_plus_alias
            },
            {
                'Name': 'ExecutedVersion',
                'Value': version
            }
        ],
        StartTime=start_time,
        EndTime=now,
        Period=300,
        Statistics=['Sum']
    )
    datapoints = response['Datapoints']
    #thresh = 100 * cw
    thresh = 0.0
    check = 0
    for datapoint in datapoints:
        check += datapoint['Sum']
    if check >= thresh:
        return True

    return False