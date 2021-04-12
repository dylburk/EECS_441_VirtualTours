import base64
import json
import os
import urllib
from urllib import request, parse


TWILIO_SMS_URL = "https://api.twilio.com/2010-04-01/Accounts/{}/Messages.json"
TWILIO_ACCOUNT_SID = os.environ.get("TWILIO_ACCOUNT_SID")
TWILIO_AUTH_TOKEN = os.environ.get("TWILIO_AUTH_TOKEN")
GOOGLE_PLACES_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/?"
GOOGLE_API_KEY =  os.environ.get("GOOGLE_API_KEY")


def lambda_handler(event, context):
    queryPhone = event['queryStringParameters']['phone']
    lat = event['queryStringParameters']['lat']
    long = event['queryStringParameters']['long']
    to_number = '+1' + queryPhone #hard-coded for skeletal
    from_number = "+18573228013"
    locals_list = ''
    # insert Twilio Account SID into the REST API URL
    req = request.Request("https://po4sn5eftg.execute-api.us-east-2.amazonaws.com/nearby?longitude=%s&latitude=%s" % (str(long), str(lat)))
    try:
        # perform HTTP POST request
        #print(data)
        with request.urlopen(req) as f:
            
            locals_list = str(f.read().decode('utf-8'))
    except Exception as e:
        # something went wrong!
        return e
    locals_list = json.loads(locals_list)
    print(locals_list["landmarks"])
    text_message = "Nearby Landmarks:\n" 
    found = False
    for element in locals_list["landmarks"]:
        if int(element["rating"]) >= 4.0: //TODO: narrow down nearby to 1 landmark per text
            text_message += element["name"] + " (%s) - %.1f/5.0\n" % (element["types"][0].replace("_", " "), element["rating"])
            found = True
            break

    if found == False:
        for element in locals_list["landmarks"]:
        if int(element["rating"]) >= 0.0: //TODO: narrow down nearby to 1 landmark per text
            text_message += element["name"] + " (%s) - %.1f/5.0\n" % (element["types"][0].replace("_", " "), element["rating"])
            found = True
            break
    
    if found == False:
        for element in locals_list["landmarks"]:
            text_message += element["name"] + " (%s) - No Rating\n" % (element["types"][0].replace("_", " "), element["rating"])
            found = True
            break
    
    if found == False:
        return "No Nearby Landmarks"
    
    print(text_message)
    body = locals_list

    print(body)
    if not TWILIO_ACCOUNT_SID:
        return "Unable to access Twilio Account SID."
    elif not TWILIO_AUTH_TOKEN:
        return "Unable to access Twilio Auth Token."
    elif not to_number:
        return "The function needs a 'To' number in the format +12023351493"
    elif not from_number:
        return "The function needs a 'From' number in the format +19732644156"
    elif not body:
        return "The function needs a 'Body' message to send."
    body = text_message
    # insert Twilio Account SID into the REST API URL
    populated_url = TWILIO_SMS_URL.format(TWILIO_ACCOUNT_SID)
    post_params = {"To": to_number, "From": from_number, "Body": body}

    # encode the parameters for Python's urllib
    data = parse.urlencode(post_params).encode()
    req = request.Request(populated_url)

    # add authentication header to request based on Account SID + Auth Token
    authentication = "{}:{}".format(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    base64string = base64.b64encode(authentication.encode('utf-8'))
    req.add_header("Authorization", "Basic %s" % base64string.decode('ascii'))
    #commenting out for now to save on twilio funds (sms demo done)
    try:
        # perform HTTP POST request
        with request.urlopen(req, data) as f:
            print("Twilio returned {}".format(str(f.read().decode('utf-8'))))
    except Exception as e:
        # something went wrong!
        return e

    return "SMS sent successfully!"
