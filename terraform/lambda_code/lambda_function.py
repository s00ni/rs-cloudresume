import json
import boto3
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    #Define Table
    table=dynamodb.Table('cloudresume-visitor-counter')

    #Update Table
    response = table.update_item(
        Key={'counter_id':1},
        UpdateExpression='SET visitor_count = visitor_count + :val',
        ExpressionAttributeValues={':val':1},
        ReturnValues='UPDATED_NEW'
    )
    #Set updated value as an integer for serialization prep
    updated=int(response['Attributes']['visitor_count'])

    return {
        #Required ke-value pairs for CORS
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
        }
        ,
        #Set python dictionary as json string
        'body': json.dumps({'visitor_count': updated})
    }

