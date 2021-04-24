import json
import urllib3

def lambda_handler(event, context):

    id = event['queryStringParameters']['id']

    APIKey = "API KEY HERE"
    url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=" + id + \
    "&key=" +  APIKey

    response_url = "/landmark/json?id=" + id

    # Make call to Google Places API
    http = urllib3.PoolManager()
    response = json.loads(http.request('GET', url).data.decode('utf-8'))

    # Alternative hardcoded JSON response to save API calls

    # Construct body of response object

    response_body = {
    "landmark": {},
    "url": response_url
    }

    rating = -1
    try:
        rating = response['result']['rating']
    except KeyError:
        pass

    desc = "No description available";
    address = "No address available"
    website = "No website available"
    hours = "No hours available"
    phone = "No phone available"
    try:
        desc = response['result']['reviews'][0]['text']
        address = response['result']['formatted_address']
        website = response['result']['website']
        hours = response['result']['opening_hours']
        phone = response['result']['formatted_phone_number']
    except KeyError:
        pass

    landmark_object = {
        "id": response['result']['place_id'],
        "name": response['result']['name'],
        "types": response['result']['types'],
        "address": address,
        "location": {
            "lat": response['result']['geometry']['location']['lat'],
            "lng": response['result']['geometry']['location']['lng']
        },
        "rating": rating,
        "website": website,
        "phone": phone,
        "hours": hours,
        "map": response['result']['url'],
        "desc": desc
    }

    response_body['landmark'] = landmark_object

    # Construct http response object

    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(response_body)

    return responseObject
