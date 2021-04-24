import urllib3
import uuid
import json
import boto3
import dynamodbgeo
from dynamodb_json import json_util as json2

def lambda_handler(event, context):
    
    latitude = event['queryStringParameters']['latitude']
    longitude = event['queryStringParameters']['longitude']
    
    try:
        googleRadius = event['queryStringParameters']['googleRadius']
    except KeyError:
        googleRadius = 50
        
    try:
        dbRadius = event['queryStringParameters']['dbRadius']
    except KeyError:
        dbRadius = 25
        
    
    APIKey = "API KEY HERE"
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + latitude + \
    "," + longitude + \
    "&radius=" + str(googleRadius) + \
    "&key=" +  APIKey
    response_url = "/nearby/json?location=" + latitude + \
    "," + longitude
    
    response_url = "/nearby/json?location=" + latitude + \
    "," + longitude
    
    # Connect to DB
    dynamodb = boto3.client('dynamodb', region_name='us-east-2')
    config = dynamodbgeo.GeoDataManagerConfiguration(dynamodb, 'geo_test_0')
    geoDataManager = dynamodbgeo.GeoDataManager(config)
    config.hashKeyLength = 11
    
    # Check if there is a point in DB within 25m
    QueryRadiusInput = {}
    point = query_reduis_result=geoDataManager.queryRadius(
    dynamodbgeo.QueryRadiusRequest(
        dynamodbgeo.GeoPoint(float(latitude), float(longitude)), # center point
        float(dbRadius), QueryRadiusInput, sort = True)) # diameter
    response_body = {
        "landmarks": [],
        "url": response_url   
    }
    
    # Make call to Google Places API
    http = urllib3.PoolManager()
    response = json.loads(http.request('GET', url).data.decode('utf-8'))
    
    # Alternative hardcoded JSON response to save API calls
    # response = {'html_attributions': [], 'results': [{'geometry': {'location': {'lat': 42.27979620000245, 'lng': -83.74083164982625}, 'viewport': {'northeast': {'lat': 42.2811451802915, 'lng': -83.73948266970851}, 'southwest': {'lat': 42.2784472197085, 'lng': -83.74218063029151}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png', 'name': '200-298 State St', 'place_id': 'ChIJrynufUCuPIgRV0H-VHmb-JA', 'reference': 'ChIJrynufUCuPIgRV0H-VHmb-JA', 'scope': 'GOOGLE', 'types': ['route'], 'vicinity': 'Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.27945999999999, 'lng': -83.74096}, 'viewport': {'northeast': {'lat': 42.28080898029149, 'lng': -83.73961101970849}, 'southwest': {'lat': 42.2781110197085, 'lng': -83.74230898029151}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/cafe-71.png', 'name': 'Starbucks', 'opening_hours': {'open_now': True}, 'photos': [{'height': 1440, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/105467685234590874106">Jimm Sansabrino</a>'], 'photo_reference': 'ATtYBwIk-a_iscrCQ7IfVpeWw7w89VyhscbsbRdFPngIz0JRQXdhx8v5Q2NmV4uuXPrHN1oLpGXyDcZaWndaQJOm1KQPg9Azke-6y-c67Tn2iqkNHKNaJSgyIvKQO1C4mKkrqsyUM8ERicaKsY5_nXnBGIyXG-Ny8jMCWzEByr0_MLCaIASV', 'width': 2560}], 'place_id': 'ChIJ-3bRg0CuPIgRODtG17yNtCQ', 'plus_code': {'compound_code': '77H5+QJ Ann Arbor, MI, USA', 'global_code': '86JR77H5+QJ'}, 'price_level': 2, 'rating': 4.2, 'reference': 'ChIJ-3bRg0CuPIgRODtG17yNtCQ', 'scope': 'GOOGLE', 'types': ['cafe', 'restaurant', 'food', 'point_of_interest', 'store', 'establishment'], 'user_ratings_total': 574, 'vicinity': '222 South State Street, Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.2792121, 'lng': -83.74097549999999}, 'viewport': {'northeast': {'lat': 42.2805622802915, 'lng': -83.73954116970849}, 'southwest': {'lat': 42.2778643197085, 'lng': -83.74223913029151}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png', 'name': 'Potbelly Sandwich Shop', 'opening_hours': {'open_now': True}, 'photos': [{'height': 900, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/103222781369775763403">Potbelly Sandwich Shop</a>'], 'photo_reference': 'ATtYBwJ7bSX0rojUDZT5jytLB5dRdS8QTGpFAV6MWvAMXYbFIUwO6RfHJojZFnSJo_f3Ckxzr5xF1FrA__c-648MOXIxlHdaMwyAqsRtjs1oFkBMek1zaqhS-UDcMJhrK3lErtUlQPyL7Am08M2Rd5XJL4HvT2QIW2FtBNhXnL6RKqFR4KPL', 'width': 1600}], 'place_id': 'ChIJrxzXnECuPIgRnBbAroFGUS8', 'plus_code': {'compound_code': '77H5+MJ Ann Arbor, MI, USA', 'global_code': '86JR77H5+MJ'}, 'price_level': 1, 'rating': 4.3, 'reference': 'ChIJrxzXnECuPIgRnBbAroFGUS8', 'scope': 'GOOGLE', 'types': ['restaurant', 'food', 'point_of_interest', 'store', 'establishment'], 'user_ratings_total': 252, 'vicinity': '300 South State Street, Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.2794436, 'lng': -83.7409412}, 'viewport': {'northeast': {'lat': 42.2807943802915, 'lng': -83.73952846970849}, 'southwest': {'lat': 42.2780964197085, 'lng': -83.7422264302915}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png', 'name': 'State Plaza', 'place_id': 'ChIJSbbMke-vPIgRTaRG8OAXKZw', 'plus_code': {'compound_code': '77H5+QJ Ann Arbor, MI, USA', 'global_code': '86JR77H5+QJ'}, 'rating': 4, 'reference': 'ChIJSbbMke-vPIgRTaRG8OAXKZw', 'scope': 'GOOGLE', 'types': ['point_of_interest', 'establishment'], 'user_ratings_total': 1, 'vicinity': '222 South State Street, Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.2794742, 'lng': -83.7410584}, 'viewport': {'northeast': {'lat': 42.28075778029149, 'lng': -83.73971321970849}, 'southwest': {'lat': 42.2780598197085, 'lng': -83.7424111802915}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png', 'name': 'Kimberlee J Karey DDS', 'opening_hours': {'open_now': False}, 'photos': [{'height': 900, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/117479591159622461990">Karey Kimberlee J DDS</a>'], 'photo_reference': 'ATtYBwKGnKdR6a1zMeIgEtclw1NUqD5m9AVH3XQaHozWjlw8EQlod_jpC1Y_po41cgkNEj_5ePOnsQXoRsKKEatEH8N8iFh8L2vfzudEMtCJNT3eTTm-txTQSYx2TMVAJGa1wlnGg4ZTT4msO14ywfFwATD0UhCwLn0JjLMAGktcndGKmmKx', 'width': 1600}], 'place_id': 'ChIJV89bfD-uPIgRxPrYwv1JviA', 'plus_code': {'compound_code': '77H5+QH Ann Arbor, MI, USA', 'global_code': '86JR77H5+QH'}, 'rating': 4.9, 'reference': 'ChIJV89bfD-uPIgRxPrYwv1JviA', 'scope': 'GOOGLE', 'types': ['dentist', 'health', 'point_of_interest', 'establishment'], 'user_ratings_total': 17, 'vicinity': '625 East Liberty Street, Ann Arbor'}, {'geometry': {'location': {'lat': 42.2808256, 'lng': -83.7430378}, 'viewport': {'northeast': {'lat': 42.32397282999803, 'lng': -83.67580689670298}, 'southwest': {'lat': 42.22266799911632, 'lng': -83.79957202857067}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png', 'name': 'Ann Arbor', 'photos': [{'height': 4032, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/109083680843429098052">Jordan Cohen</a>'], 'photo_reference': 'ATtYBwIWzHlU0D7xSQt3LnSIHWVsUHDxMsYHrEmiLOMjQlOMQQftGUteGM6jKPUaQjNJbEz21MNs4CNhc-lTSHDl5fqMRHRTWMrQtHuKtnY_I2Vr5aIyH6GRbqGW_ls9sagCq-u1FYH8dcFkYykvoy9FqQDYaR8jUlllM3p0zRXgwha5jbeY', 'width': 2268}], 'place_id': 'ChIJMx9D1A2wPIgR4rXIhkb5Cds', 'reference': 'ChIJMx9D1A2wPIgR4rXIhkb5Cds', 'scope': 'GOOGLE', 'types': ['locality', 'political'], 'vicinity': 'Ann Arbor'}], 'status': 'OK'}
    
    # Construct body of response object
        
    response_body = {
    "landmarks": [],
    "url": response_url   
    }
    
    #check if DB query returned any points. If list is empty use Places API else use first returned point
    if not point:
    
        http = urllib3.PoolManager()
        response = json.loads(http.request('GET', url).data.decode('utf-8'))
        # response = {'html_attributions': [], 'results': [{'geometry': {'location': {'lat': 42.27979620000245, 'lng': -83.74083164982625}, 'viewport': {'northeast': {'lat': 42.2811451802915, 'lng': -83.73948266970851}, 'southwest': {'lat': 42.2784472197085, 'lng': -83.74218063029151}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png', 'name': '200-298 State St', 'place_id': 'ChIJrynufUCuPIgRV0H-VHmb-JA', 'reference': 'ChIJrynufUCuPIgRV0H-VHmb-JA', 'scope': 'GOOGLE', 'types': ['route'], 'vicinity': 'Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.27945999999999, 'lng': -83.74096}, 'viewport': {'northeast': {'lat': 42.28080898029149, 'lng': -83.73961101970849}, 'southwest': {'lat': 42.2781110197085, 'lng': -83.74230898029151}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/cafe-71.png', 'name': 'Starbucks', 'opening_hours': {'open_now': True}, 'photos': [{'height': 1440, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/105467685234590874106">Jimm Sansabrino</a>'], 'photo_reference': 'ATtYBwIk-a_iscrCQ7IfVpeWw7w89VyhscbsbRdFPngIz0JRQXdhx8v5Q2NmV4uuXPrHN1oLpGXyDcZaWndaQJOm1KQPg9Azke-6y-c67Tn2iqkNHKNaJSgyIvKQO1C4mKkrqsyUM8ERicaKsY5_nXnBGIyXG-Ny8jMCWzEByr0_MLCaIASV', 'width': 2560}], 'place_id': 'ChIJ-3bRg0CuPIgRODtG17yNtCQ', 'plus_code': {'compound_code': '77H5+QJ Ann Arbor, MI, USA', 'global_code': '86JR77H5+QJ'}, 'price_level': 2, 'rating': 4.2, 'reference': 'ChIJ-3bRg0CuPIgRODtG17yNtCQ', 'scope': 'GOOGLE', 'types': ['cafe', 'restaurant', 'food', 'point_of_interest', 'store', 'establishment'], 'user_ratings_total': 574, 'vicinity': '222 South State Street, Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.2792121, 'lng': -83.74097549999999}, 'viewport': {'northeast': {'lat': 42.2805622802915, 'lng': -83.73954116970849}, 'southwest': {'lat': 42.2778643197085, 'lng': -83.74223913029151}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png', 'name': 'Potbelly Sandwich Shop', 'opening_hours': {'open_now': True}, 'photos': [{'height': 900, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/103222781369775763403">Potbelly Sandwich Shop</a>'], 'photo_reference': 'ATtYBwJ7bSX0rojUDZT5jytLB5dRdS8QTGpFAV6MWvAMXYbFIUwO6RfHJojZFnSJo_f3Ckxzr5xF1FrA__c-648MOXIxlHdaMwyAqsRtjs1oFkBMek1zaqhS-UDcMJhrK3lErtUlQPyL7Am08M2Rd5XJL4HvT2QIW2FtBNhXnL6RKqFR4KPL', 'width': 1600}], 'place_id': 'ChIJrxzXnECuPIgRnBbAroFGUS8', 'plus_code': {'compound_code': '77H5+MJ Ann Arbor, MI, USA', 'global_code': '86JR77H5+MJ'}, 'price_level': 1, 'rating': 4.3, 'reference': 'ChIJrxzXnECuPIgRnBbAroFGUS8', 'scope': 'GOOGLE', 'types': ['restaurant', 'food', 'point_of_interest', 'store', 'establishment'], 'user_ratings_total': 252, 'vicinity': '300 South State Street, Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.2794436, 'lng': -83.7409412}, 'viewport': {'northeast': {'lat': 42.2807943802915, 'lng': -83.73952846970849}, 'southwest': {'lat': 42.2780964197085, 'lng': -83.7422264302915}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png', 'name': 'State Plaza', 'place_id': 'ChIJSbbMke-vPIgRTaRG8OAXKZw', 'plus_code': {'compound_code': '77H5+QJ Ann Arbor, MI, USA', 'global_code': '86JR77H5+QJ'}, 'rating': 4, 'reference': 'ChIJSbbMke-vPIgRTaRG8OAXKZw', 'scope': 'GOOGLE', 'types': ['point_of_interest', 'establishment'], 'user_ratings_total': 1, 'vicinity': '222 South State Street, Ann Arbor'}, {'business_status': 'OPERATIONAL', 'geometry': {'location': {'lat': 42.2794742, 'lng': -83.7410584}, 'viewport': {'northeast': {'lat': 42.28075778029149, 'lng': -83.73971321970849}, 'southwest': {'lat': 42.2780598197085, 'lng': -83.7424111802915}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png', 'name': 'Kimberlee J Karey DDS', 'opening_hours': {'open_now': False}, 'photos': [{'height': 900, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/117479591159622461990">Karey Kimberlee J DDS</a>'], 'photo_reference': 'ATtYBwKGnKdR6a1zMeIgEtclw1NUqD5m9AVH3XQaHozWjlw8EQlod_jpC1Y_po41cgkNEj_5ePOnsQXoRsKKEatEH8N8iFh8L2vfzudEMtCJNT3eTTm-txTQSYx2TMVAJGa1wlnGg4ZTT4msO14ywfFwATD0UhCwLn0JjLMAGktcndGKmmKx', 'width': 1600}], 'place_id': 'ChIJV89bfD-uPIgRxPrYwv1JviA', 'plus_code': {'compound_code': '77H5+QH Ann Arbor, MI, USA', 'global_code': '86JR77H5+QH'}, 'rating': 4.9, 'reference': 'ChIJV89bfD-uPIgRxPrYwv1JviA', 'scope': 'GOOGLE', 'types': ['dentist', 'health', 'point_of_interest', 'establishment'], 'user_ratings_total': 17, 'vicinity': '625 East Liberty Street, Ann Arbor'}, {'geometry': {'location': {'lat': 42.2808256, 'lng': -83.7430378}, 'viewport': {'northeast': {'lat': 42.32397282999803, 'lng': -83.67580689670298}, 'southwest': {'lat': 42.22266799911632, 'lng': -83.79957202857067}}}, 'icon': 'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png', 'name': 'Ann Arbor', 'photos': [{'height': 4032, 'html_attributions': ['<a href="https://maps.google.com/maps/contrib/109083680843429098052">Jordan Cohen</a>'], 'photo_reference': 'ATtYBwIWzHlU0D7xSQt3LnSIHWVsUHDxMsYHrEmiLOMjQlOMQQftGUteGM6jKPUaQjNJbEz21MNs4CNhc-lTSHDl5fqMRHRTWMrQtHuKtnY_I2Vr5aIyH6GRbqGW_ls9sagCq-u1FYH8dcFkYykvoy9FqQDYaR8jUlllM3p0zRXgwha5jbeY', 'width': 2268}], 'place_id': 'ChIJMx9D1A2wPIgR4rXIhkb5Cds', 'reference': 'ChIJMx9D1A2wPIgR4rXIhkb5Cds', 'scope': 'GOOGLE', 'types': ['locality', 'political'], 'vicinity': 'Ann Arbor'}], 'status': 'OK'}
    
        typesNotAllowed = ['neighborhood', 'political', 'route']
        for landmark in response['results']:
            skipObject = False
    
            for type in landmark['types']:
                    if type in typesNotAllowed:
                        skipObject = True
    
            if skipObject:
                continue
    
            rating = -1
            try:
                rating = landmark['rating']
            except KeyError:
                pass
    
            landmark_object = {
                "id": landmark['place_id'],
                "name": landmark['name'],
                "types": landmark['types'],
                "rating": rating,
                "location": {
                    "lat": landmark['geometry']['location']['lat'],
                    "lng": landmark['geometry']['location']['lng']
                }
            }

            response_body['landmarks'].append(landmark_object)
        
        # Store new landmarks in DB
        PutItemInput = {
            'Item': json2.dumps(response_body, as_dict=True)
        }
        geoDataManager.put_Point(dynamodbgeo.PutPointInput(
            dynamodbgeo.GeoPoint(float(latitude), float(longitude)), # latitude then latitude longitude
            str( uuid.uuid4()), # Use this to ensure uniqueness of the hash/range pairs.
            PutItemInput # pass the dict here
        ))
    else:
        # load first point returned from DB into JSON response
        returtedPoint = json2.loads(point[0])
        response_body["landmarks"] = returtedPoint["landmarks"]
        
    # Construct http response object
        
    responseObject = {}
    responseObject['statusCode'] = 200
    responseObject['headers'] = {}
    responseObject['headers']['Content-Type'] = 'application/json'
    responseObject['body'] = json.dumps(response_body)
        
    return responseObject
